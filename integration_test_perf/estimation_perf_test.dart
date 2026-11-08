// On-phone speed check of the estimation package (NFR2.1 b,
// cicd-pipeline.md §5), run by the owner once per version before approving
// production, on the connected phone:
//
//   flutter drive --profile --driver=test_driver/perf_driver.dart \
//     --target=integration_test_perf/estimation_perf_test.dart
//
// It calls the four C2 functions on 500 synthetic wines, 3 warm-up rounds
// then 10 timed rounds, prints the median and fails above 25 ms. This folder
// is outside integration_test/, so the CI `e2e` job never runs it.
//
// The same run measures the wine catalog (u3-wine-catalog
// performance-design.md, "Misura sul telefono"): suggestWines with 500
// cellar wines within 25 ms and matchLabelText on 2000 characters, without
// Open Food Facts, within 50 ms. Both medians go in the release checklist.
import 'package:estimation/estimation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/catalog/core/catalog_cache_store.dart';
import 'package:vinoozy/catalog/core/catalog_coordinator.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/internal_catalog.dart';
import 'package:vinoozy/catalog/core/off_circuit_breaker.dart';
import 'package:vinoozy/catalog/core/request_budget.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/core/clock.dart';

const _wineCount = 500;
const _warmupRounds = 3;
const _timedRounds = 10;
const _limitMs = 25.0;
const _suggestLimitMs = 25.0;
const _labelLimitMs = 50.0;

/// Memory-only cache file: the measures never touch the disk.
class _MemoryFile implements CacheFile {
  @override
  Future<String?> read() async => null;
  @override
  Future<void> writeTemp(String contents) async {}
  @override
  Future<void> commitTemp() async {}
  @override
  Future<void> deleteTemp() async {}
  @override
  Future<void> deleteAll() async {}
}

/// The catalog without Open Food Facts, as in a build with no contact.
CatalogCoordinator _catalog() {
  const clock = SystemClock();
  const logger = ConsoleCatalogEventLogger(debugLogging: false);
  final health = CatalogHealth();
  return CatalogCoordinator(
    internal: InternalCatalog.build(),
    cache: CatalogCacheStore(
      file: _MemoryFile(),
      clock: clock,
      health: health,
      logger: logger,
    ),
    budget: RequestBudget(clock),
    breaker: OffCircuitBreaker(clock: clock, logger: logger, health: health),
    logger: logger,
  );
}

/// Median in milliseconds of [round], after the warm-up rounds.
Future<double> _medianMs(Future<void> Function() round) async {
  for (var i = 0; i < _warmupRounds; i++) {
    await round();
  }
  final samples = <double>[];
  final watch = Stopwatch();
  for (var i = 0; i < _timedRounds; i++) {
    watch
      ..reset()
      ..start();
    await round();
    watch.stop();
    samples.add(watch.elapsedMicroseconds / 1000);
  }
  samples.sort();
  return (samples[4] + samples[5]) / 2;
}

const _baseNames = [
  'Barolo Riserva',
  "Barbera d'Asti Superiore",
  'Chianti Classico Gran Selezione',
  'Amarone della Valpolicella',
  'Prosecco Superiore',
  'Franciacorta Brut',
  'Vino di Mario',
  'Rosso della casa',
  'Etna Bianco',
  'Castiglione Falletto',
];

List<WineFacts> _syntheticWines() => List.generate(_wineCount, (i) {
  final base = '${_baseNames[i % _baseNames.length]} Cantina Vigna Alta $i';
  return WineFacts(
    name: base.padRight(60, ' x').substring(0, 60),
    vintage: i % 4 == 0 ? null : 1990 + i % 35,
    referenceYear: 2026,
    wineType: i % 5 == 0 ? WineType.values[i % WineType.values.length] : null,
  );
});

void _round(List<WineFacts> wines, DateTime today) {
  for (final wine in wines) {
    final window = estimateWindow(wine);
    statusOf(window, today);
    pairingsFor(wine);
    needsRefinement(window);
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('500 wines estimated within 25 ms (NFR2.1 b)', (tester) async {
    final wines = _syntheticWines();
    final today = DateTime(2026, 9, 1);
    for (var i = 0; i < _warmupRounds; i++) {
      _round(wines, today);
    }

    final samples = <double>[];
    final watch = Stopwatch();
    for (var i = 0; i < _timedRounds; i++) {
      watch
        ..reset()
        ..start();
      _round(wines, today);
      watch.stop();
      samples.add(watch.elapsedMicroseconds / 1000);
    }
    samples.sort();
    final median = (samples[4] + samples[5]) / 2;

    debugPrint(
      'estimation_perf: median ${median.toStringAsFixed(2)} ms over '
      '$_timedRounds rounds of $_wineCount wines (limit $_limitMs ms)',
    );
    binding.reportData = {
      'estimation_median_ms': median,
      'estimation_limit_ms': _limitMs,
    };
    expect(median, lessThanOrEqualTo(_limitMs));
  });

  testWidgets('catalog: suggestWines within 25 ms, matchLabelText within '
      '50 ms (u3 NFR1.1, NFR1.2)', (tester) async {
    final catalog = _catalog();
    final cellar = List<CellarWineRef>.unmodifiable(
      List.generate(
        _wineCount,
        (i) => CellarWineRef(
          name: '${_baseNames[i % _baseNames.length]} Vigna $i',
          producer: 'Cantina ${i % 37}',
        ),
      ),
    );
    const query = 'castiglione falletto vigna alta cantina storica del borgo';
    final label = List.filled(
      60,
      'BAROLO Denominazione di Origine Controllata 2016 ',
    ).join().substring(0, 2000);

    final suggest = await _medianMs(
      () async => catalog.suggestWines(query, cellarWines: cellar),
    );
    final match = await _medianMs(() => catalog.matchLabel(label));

    debugPrint(
      'catalog_perf: suggestWines ${suggest.toStringAsFixed(2)} ms '
      '(limit $_suggestLimitMs), matchLabel ${match.toStringAsFixed(2)} '
      'ms (limit $_labelLimitMs)',
    );
    binding.reportData = {
      ...?binding.reportData,
      'catalog_suggest_median_ms': suggest,
      'catalog_label_median_ms': match,
    };
    expect(suggest, lessThanOrEqualTo(_suggestLimitMs));
    expect(match, lessThanOrEqualTo(_labelLimitMs));
  });
}
