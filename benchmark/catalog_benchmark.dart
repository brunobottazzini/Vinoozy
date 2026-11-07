// CI speed gate of the wine catalog (u3-wine-catalog performance-design.md:
// NFR1.1, NFR1.2, NFR1.4, NFR1.5, NFR7.4). It imports only the pure core
// lib/catalog/core/, so it runs with `dart run`, without Flutter.
//
// Each measure runs 3 warm-up rounds, then 10 timed rounds, and compares the
// median with its threshold. A measure over its threshold is run once more
// from scratch; when it is over again the script exits with code 1. The
// thresholds are fixed inputs: never raise them to make the job pass.
//
// Usage (from the project root): dart run benchmark/catalog_benchmark.dart
import 'dart:io';

import 'package:vinoozy/catalog/core/catalog_cache_store.dart';
import 'package:vinoozy/catalog/core/catalog_coordinator.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/internal_catalog.dart';
import 'package:vinoozy/catalog/core/off_circuit_breaker.dart';
import 'package:vinoozy/catalog/core/request_budget.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/core/clock.dart';

const _warmupRounds = 3;
const _timedRounds = 10;
const _cellarSize = 500;

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

/// 500 synthetic cellar wines, no personal data.
final List<CellarWineRef> _cellar = List.unmodifiable(
  List.generate(
    _cellarSize,
    (i) => CellarWineRef(
      name: '${_baseNames[i % _baseNames.length]} Vigna $i',
      producer: 'Cantina ${i % 37}',
      vintage: i % 4 == 0 ? null : 1990 + i % 35,
    ),
  ),
);

/// Queries of 2 to 60 characters, as typed letter by letter.
const _queries = [
  'ba',
  'bar',
  'barolo',
  'barolo ris',
  'barolo riserva 2016',
  "barbera d'asti superiore",
  'chianti classico gran selezione',
  'amarone della valpolicella cantina 12',
  'castiglione falletto vigna alta cantina storica del borgo',
  'prosecco superiore valdobbiadene docg millesimato brut 2022',
];

/// A 2000-character label text.
final String _label = () {
  const lines = [
    'BAROLO',
    'Denominazione di Origine Controllata e Garantita',
    'Vigna Cannubi 2016',
    'Imbottigliato all origine dal viticoltore Cantina Esempio',
    'Contiene solfiti 14,5% vol 750 ml Prodotto in Italia',
  ];
  final buffer = StringBuffer();
  var i = 0;
  while (buffer.length < 2000) {
    buffer.writeln(lines[i++ % lines.length]);
  }
  return buffer.toString().substring(0, 2000);
}();

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

const _silent = ConsoleCatalogEventLogger(debugLogging: false);

CatalogCacheStore _store() => CatalogCacheStore(
  file: _MemoryFile(),
  clock: const SystemClock(),
  health: CatalogHealth(),
  logger: _silent,
);

/// Coordinator without Open Food Facts (no contact in CI).
CatalogCoordinator _coordinator() {
  const clock = SystemClock();
  final health = CatalogHealth();
  return CatalogCoordinator(
    internal: InternalCatalog.build(),
    cache: _store(),
    budget: RequestBudget(clock),
    breaker: OffCircuitBreaker(clock: clock, logger: _silent, health: health),
    logger: _silent,
  );
}

Future<double> _medianMicros(Future<void> Function() round) async {
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
    samples.add(watch.elapsedTicks * 1e6 / watch.frequency);
  }
  samples.sort();
  return (samples[_timedRounds ~/ 2 - 1] + samples[_timedRounds ~/ 2]) / 2;
}

String _ms(double micros) => '${(micros / 1000).toStringAsFixed(3)} ms';

/// The slowest query, each measured on its own (NFR1.1, NFR2.1).
Future<(String, bool)> _suggest() async {
  final catalog = _coordinator();
  var worst = 0.0;
  for (final query in _queries) {
    final micros = await _medianMicros(
      () async => catalog.suggestWines(query, cellarWines: _cellar),
    );
    if (micros > worst) worst = micros;
  }
  return ('slowest query ${_ms(worst)}', worst <= 5000);
}

/// Label recognition without Open Food Facts (NFR1.2).
Future<(String, bool)> _label2000() async {
  final catalog = _coordinator();
  await catalog.startSession(null);
  final micros = await _medianMicros(() => catalog.matchLabelText(_label));
  return (_ms(micros), micros <= 10000);
}

/// One lookup in the in-memory cache, full of 200 answers (NFR1.4).
Future<(String, bool)> _cacheRead() async {
  final store = _store();
  await store.open(null);
  for (var i = 0; i < CatalogCacheStore.maxEntries; i++) {
    store.put('search:query $i', [
      for (var j = 0; j < 10; j++)
        WineCandidate(
          name: 'Vino $i $j',
          source: CandidateSource.openFoodFacts,
        ),
    ], hintKeyOf: (name) => name);
  }
  final micros = await _medianMicros(
    () async => store.lookup('search:query 150'),
  );
  return (_ms(micros), micros <= 1000);
}

/// One construction of the internal catalog (NFR1.5).
Future<(String, bool)> _build() async {
  final micros = await _medianMicros(() async => InternalCatalog.build());
  return (_ms(micros), micros <= 20000);
}

class _Measure {
  const _Measure(this.label, this.limit, this.measure);

  final String label;
  final String limit;
  final Future<(String, bool)> Function() measure;
}

final _measures = [
  _Measure(
    'suggestWines, $_cellarSize cellar wines, queries of 2-60 chars',
    '<= 5 ms',
    _suggest,
  ),
  _Measure('matchLabelText, 2000 chars, no OFF', '<= 10 ms', _label2000),
  _Measure('cache read in memory', '<= 1 ms', _cacheRead),
  _Measure('InternalCatalog.build', '<= 20 ms', _build),
];

Future<void> main() async {
  for (final measure in _measures) {
    var (value, ok) = await measure.measure();
    if (!ok) {
      stdout.writeln('RETRY ${measure.label}: $value (limit ${measure.limit})');
      (value, ok) = await measure.measure();
    }
    stdout.writeln(
      '${ok ? 'OK  ' : 'FAIL'} ${measure.label}: $value '
      '(limit ${measure.limit})',
    );
    if (!ok) exit(1);
  }
}
