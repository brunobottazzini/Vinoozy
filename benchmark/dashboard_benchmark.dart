// CI speed gate of the Dashboard calculation (u5-dashboard
// performance-design.md, "Misure"; NFR2.2). It imports only
// lib/dashboard/domain/, lib/cellar/domain/wine.dart and the estimation
// package, none of which uses Flutter, so it runs with `dart run`.
//
// DashboardCalculator.compute on 500 wines: 3 warm-up rounds, then the
// median of 10 timed rounds, threshold 10 ms. Over the threshold the measure
// is run once more from scratch; over again, the script exits with code 1.
// The threshold is a fixed input: never raise it to make the job pass.
//
// Usage (from the project root): dart run benchmark/dashboard_benchmark.dart
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/dashboard/domain/dashboard_calculator.dart';

const _warmupRounds = 3;
const _timedRounds = 10;
const _wineCount = 500;
const _limitMicros = 10000.0;

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
  'sparkling',
  'rose',
  'sweet',
  'red',
  'fortified',
  null,
];
const _regions = [
  'Piemonte',
  'Toscana',
  'Veneto',
  'piemonte',
  'Sicilia',
  'Lombardia',
  'Campania',
  'Puglia',
  'Sardegna',
  'Marche',
  'Abruzzo',
  'Umbria',
  null,
];
const _denominations = [
  'Barolo DOCG',
  "Barbera d'Asti",
  'Chianti Classico',
  'Prosecco DOC',
  'Vino da tavola',
];

/// 500 synthetic wines, no personal data: two thirds with a window (a few
/// invalid ones included), mixed types, regions and denominations, so every
/// branch of the calculation runs.
List<Wine> _cellar(int baseYear) => List.generate(_wineCount, (i) {
  final start = baseYear - 8 + i % 11;
  final peak = start + i % 5;
  final window = i % 3 == 0
      ? null
      : DrinkingWindow(
          startYear: i % 97 == 0 ? peak + 1 : start,
          peakYear: peak,
          endYear: peak + i % 9,
          confidence: Confidence.values[i % 3],
          source: WindowSource.values[i % 2],
          basis: EstimationBasis.values[i % 4],
        );
  return Wine(
    id: 'w$i',
    name: '${_names[i % _names.length]} Vigna $i',
    vintage: i % 7 == 0 ? null : 1995 + i % 30,
    storedQuantity: i % 41 == 0 ? -1 : 1 + i % 6,
    producer: i % 4 == 0 ? null : 'Cantina ${i % 37}',
    wineType: _types[i % _types.length],
    region: i % 2 == 0 ? _regions[i % _regions.length] : null,
    denomination: _denominations[i % _denominations.length],
    window: window,
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

/// One measure from scratch: a new calculator and a new cellar.
(double, int) _measure() {
  final today = DateTime.now();
  final wines = _cellar(today.year);
  const calculator = DashboardCalculator();
  var bottles = 0;
  final micros = _medianMicros(() {
    bottles = calculator.compute(wines, today).totalBottles;
  });
  return (micros, bottles);
}

String _ms(double micros) => '${(micros / 1000).toStringAsFixed(3)} ms';

void main() {
  const label = 'DashboardCalculator.compute, $_wineCount wines';
  var (micros, bottles) = _measure();
  if (micros > _limitMicros) {
    stdout.writeln('RETRY $label: ${_ms(micros)} (limit <= 10 ms)');
    (micros, bottles) = _measure();
  }
  final ok = micros <= _limitMicros;
  stdout.writeln(
    '${ok ? 'OK  ' : 'FAIL'} $label ($bottles bottles): ${_ms(micros)} '
    '(limit <= 10 ms)',
  );
  if (!ok) exit(1);
}
