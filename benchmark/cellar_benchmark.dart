// CI speed gate of the cellar (u4-cellar performance-design.md §2; NFR2.1,
// NFR2.4). It imports only lib/cellar/domain/ (wine.dart and quantity.dart
// included) and the estimation package, none of which uses Flutter, so it
// runs with `dart run`.
//
// Two measures on 500 wines, each the median of 10 timed rounds after 3
// warm-up rounds:
// - "filters": a search plus a status and a type filter (CellarFilter.apply,
//   statuses computed on the fly), threshold 20 ms;
// - "effective window": WindowAdjuster.effective on every wine, threshold
//   5 ms.
// Over its threshold a measure is run once more from scratch; over again,
// the script exits with code 1. The thresholds are fixed inputs: never
// raise them to make the job pass.
//
// Usage (from the project root): dart run benchmark/cellar_benchmark.dart
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:vinoozy/cellar/domain/cellar_filter.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/domain/window_adjuster.dart';
import 'package:vinoozy/cellar/domain/wine.dart';

const _warmupRounds = 3;
const _timedRounds = 10;
const _wineCount = 500;
const _filtersLimitMicros = 20000.0;
const _windowLimitMicros = 5000.0;

const _names = [
  'Barolo Riserva',
  "Barbera d'Asti Superiore",
  'Chianti Classico Gran Selezione',
  'Amarone della Valpolicella',
  'Prosecco Superiore',
  'Franciacorta Brut',
  'Etna Bianco',
  'Soave Classico',
  'Passito di Pantelleria',
  'Vino della casa',
];
const _types = [
  'redStructured',
  'white',
  'sparklingClassic',
  'rose',
  'sweet',
  'redLight',
  'fortified',
  null,
];

/// 500 synthetic wines, no personal data: most with a window and some with a
/// feedback, mixed types and producers (accents included), so every branch
/// of the filters and of the adjuster runs.
List<Wine> _cellar(int baseYear) => List.generate(_wineCount, (i) {
  final start = baseYear - 8 + i % 11;
  final peak = start + i % 5;
  final window = i % 7 == 0
      ? null
      : DrinkingWindow(
          startYear: start,
          peakYear: peak,
          endYear: peak + 1 + i % 9,
          confidence: Confidence.values[i % 3],
          source: WindowSource.values[i % 2],
          basis: EstimationBasis.values[i % 4],
        );
  final adjustment = i % 3 == 0
      ? WindowAdjustment(
          kind: DrinkCondition.values[i % 3],
          year: baseYear - 4 + i % 9,
          recordId: 'r$i',
        )
      : null;
  return Wine(
    id: 'w$i',
    name: '${_names[i % _names.length]} Vigna $i',
    vintage: i % 9 == 0 ? null : 1995 + i % 30,
    storedQuantity: 1 + i % 6,
    producer: i % 4 == 0 ? null : 'Cantina Città ${i % 37}',
    wineType: _types[i % _types.length],
    window: window,
    baseWindow: window,
    windowAdjustment: adjustment,
  );
});

double _medianMicros(void Function() round) {
  for (var i = 0; i < _warmupRounds; i++) {
    round();
  }
  final samples = <double>[];
  final watch = Stopwatch();
  for (var i = 0; i < _timedRounds; i++) {
    watch
      ..reset()
      ..start();
    round();
    watch.stop();
    samples.add(watch.elapsedTicks * 1e6 / watch.frequency);
  }
  samples.sort();
  return (samples[_timedRounds ~/ 2 - 1] + samples[_timedRounds ~/ 2]) / 2;
}

/// "filters": search plus two filters, from scratch.
(double, int) _measureFilters() {
  final today = DateTime.now();
  final wines = _cellar(today.year);
  const filter = CellarFilter(
    query: 'citta',
    statuses: {StatusFilter.ready, StatusFilter.drinkSoon},
    types: {TypeFilter.red, TypeFilter.white},
  );
  var shown = 0;
  final micros = _medianMicros(() {
    shown = filter.apply(wines, today).length;
  });
  return (micros, shown);
}

/// "effective window": the feedback applied to every base window.
(double, int) _measureWindows() {
  final wines = _cellar(DateTime.now().year);
  var changed = 0;
  final micros = _medianMicros(() {
    changed = 0;
    for (final wine in wines) {
      final base = wine.baseWindow;
      if (base == null) continue;
      if (!identical(
        WindowAdjuster.effective(base, wine.windowAdjustment),
        base,
      )) {
        changed++;
      }
    }
  });
  return (micros, changed);
}

String _ms(double micros) => '${(micros / 1000).toStringAsFixed(3)} ms';

/// Runs [measure] and, over [limitMicros], once more; true when within it.
bool _gate(
  String label,
  double limitMicros,
  (double, int) Function() measure,
  String unit,
) {
  var (micros, count) = measure();
  final limit = _ms(limitMicros);
  if (micros > limitMicros) {
    stdout.writeln('RETRY $label: ${_ms(micros)} (limit <= $limit)');
    (micros, count) = measure();
  }
  final ok = micros <= limitMicros;
  stdout.writeln(
    '${ok ? 'OK  ' : 'FAIL'} $label ($count $unit): ${_ms(micros)} '
    '(limit <= $limit)',
  );
  return ok;
}

void main() {
  final filtersOk = _gate(
    'CellarFilter.apply (search + 2 filters), $_wineCount wines',
    _filtersLimitMicros,
    _measureFilters,
    'shown',
  );
  final windowsOk = _gate(
    'WindowAdjuster.effective, $_wineCount wines',
    _windowLimitMicros,
    _measureWindows,
    'adjusted',
  );
  if (!filtersOk || !windowsOk) exit(1);
}
