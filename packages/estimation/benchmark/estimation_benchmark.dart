// CI speed gate of the estimation package (NFR2.1 a, NFR2.2, NFR2.3,
// NFR7.5; thresholds from logical-components.md, "Prestazioni").
//
// Each measure runs 3 warm-up rounds, then 10 timed rounds, and compares the
// median with its threshold. A measure over its threshold is run once more
// from scratch; when it is over again the script exits with code 1. The
// thresholds are fixed inputs: never raise them to make the job pass.
//
// Usage (from packages/estimation): dart run benchmark/estimation_benchmark.dart
import 'dart:io';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:estimation/estimation.dart';
import 'package:estimation/src/appellations.dart' show buildDenominationTable;
import 'package:estimation/src/recognizer.dart';

const _wineCount = 500;
const _nameLength = 60;
const _warmupRounds = 3;
const _timedRounds = 10;

final _today = DateTime(2026, 9, 1);

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

/// 500 synthetic names of exactly 60 characters, recognised and not.
final List<String> _names = List.generate(_wineCount, (i) {
  final base = '${_baseNames[i % _baseNames.length]} Cantina Vigna Alta $i';
  return base.padRight(_nameLength, ' x').substring(0, _nameLength);
});

/// 500 synthetic wines: with and without vintage, with and without a type.
final List<WineFacts> _wines = List.generate(_wineCount, (i) {
  return WineFacts(
    name: _names[i],
    vintage: i % 4 == 0 ? null : 1990 + i % 35,
    referenceYear: 2026,
    wineType: i % 5 == 0 ? WineType.values[i % WineType.values.length] : null,
  );
});

/// Recognition of 500 names of 60 characters, alone (NFR2.3).
class RecognizeBenchmark extends BenchmarkBase {
  RecognizeBenchmark() : super('recognize x$_wineCount');

  @override
  void run() {
    for (final name in _names) {
      recognize(name);
    }
  }
}

/// Estimate, status and pairings of 500 wines, recognition included
/// (NFR2.1 a).
class FullEstimateBenchmark extends BenchmarkBase {
  FullEstimateBenchmark() : super('estimate+status+pairings x$_wineCount');

  @override
  void run() {
    for (final wine in _wines) {
      // wine-style-profiles BR2.9: a fortified wine without a style has no
      // window ("To estimate"), so no status.
      final window = estimateWindow(wine);
      if (window != null) statusOf(window, _today);
      pairingsFor(wine);
    }
  }
}

/// A block of 500 estimates (NFR2.2).
class EstimateBlockBenchmark extends BenchmarkBase {
  EstimateBlockBenchmark() : super('estimateWindow x$_wineCount');

  @override
  void run() {
    for (final wine in _wines) {
      estimateWindow(wine);
    }
  }
}

/// 1000 classifications of wine names (wine-style-profiles NFR3.1).
const _classifyCount = 1000;

class ClassifyBenchmark extends BenchmarkBase {
  ClassifyBenchmark() : super('classifyWine x$_classifyCount');

  static final List<String> _classifyNames = [
    for (var i = 0; i < _classifyCount; i++)
      '${_classifyBase[i % _classifyBase.length]} $i',
  ];

  static const _classifyBase = [
    'Barolo Riserva',
    'Château Lagrange',
    "Lambrusco dell'Emilia Dolce",
    'Vin rouge',
    'Fetzer Sundial Chardonnay',
    'Porto Ruby',
    'Cuvée Mario',
    'Mosel Riesling Kabinett',
  ];

  @override
  void run() {
    for (final name in _classifyNames) {
      classifyWine(name, producer: 'Cantina', dbType: WineType.white);
    }
  }
}

/// One construction of the alias index (NFR2.2).
class BuildIndexBenchmark extends BenchmarkBase {
  BuildIndexBenchmark() : super('buildAliasIndex x1');

  @override
  void run() {
    buildAliasIndex();
  }
}

/// A label text of 4000 characters: real label lines repeated, with noise
/// (label-autofill-windows NFR4.1).
final String _labelText = () {
  const lines = [
    'CHÂTEAU MEYNEY',
    'SAINT-ESTÈPHE',
    'Appellation Saint-Estèphe Contrôlée',
    'Mis en bouteille au château',
    'La Rioja Alta S.A. · Gran Reserva 904 · Rioja',
    'Denominación de Origen Calificada 2015',
    'Imbottigliato da Cantina Esempio, Via Roma 1, 12060 Barolo (CN)',
    'Contiene solfiti 750 ml 14,5% vol L.1234',
    'Product of Argentina · Catena · Malbec · Mendoza',
  ];
  final buffer = StringBuffer();
  var i = 0;
  while (buffer.length < 4000) {
    buffer.writeln(lines[i++ % lines.length]);
  }
  return buffer.toString().substring(0, 4000);
}();

/// `extractLabelFields` on 4000 characters (NFR4.1).
class ExtractBenchmark extends BenchmarkBase {
  ExtractBenchmark() : super('extractLabelFields 4000 chars');

  @override
  void run() {
    extractLabelFields(_labelText, currentYear: 2026);
  }
}

/// `analyzeLabelText` on 4000 characters: candidates, certainty and words
/// of the guided check (label-autofill-windows NFR4.19, NFR5.9).
class AnalyzeBenchmark extends BenchmarkBase {
  AnalyzeBenchmark() : super('analyzeLabelText 4000 chars');

  @override
  void run() {
    analyzeLabelText(_labelText, currentYear: 2026);
  }
}

/// The joined table and its alias index built from scratch (NFR4.3).
class BuildTableBenchmark extends BenchmarkBase {
  BuildTableBenchmark() : super('buildDenominationTable + index');

  @override
  void run() {
    buildDenominationTable();
    buildAliasIndex();
  }
}

/// Median duration of [benchmark.run] in microseconds, after warm-up.
double medianMicros(BenchmarkBase benchmark) {
  benchmark.setup();
  for (var i = 0; i < _warmupRounds; i++) {
    benchmark.run();
  }
  final samples = <double>[];
  final watch = Stopwatch();
  for (var i = 0; i < _timedRounds; i++) {
    watch
      ..reset()
      ..start();
    benchmark.run();
    watch.stop();
    samples.add(watch.elapsedTicks * 1e6 / watch.frequency);
  }
  benchmark.teardown();
  return _median(samples);
}

double _median(List<double> samples) {
  final sorted = List.of(samples)..sort();
  final middle = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[middle]
      : (sorted[middle - 1] + sorted[middle]) / 2;
}

/// One gate: a measured value, its threshold and a readable description.
class Measure {
  const Measure(this.label, this.limitLabel, this.measure);

  final String label;
  final String limitLabel;

  /// Returns the measured value as text and whether it is within the limit.
  final (String, bool) Function() measure;
}

(String, bool) _recognition() {
  final micros = medianMicros(RecognizeBenchmark());
  return (_ms(micros), micros <= 4000);
}

(String, bool) _fullEstimate() {
  final micros = medianMicros(FullEstimateBenchmark());
  return (_ms(micros), micros <= 10000);
}

(String, bool) _secondBlock() {
  final first = <double>[];
  final second = <double>[];
  final block = EstimateBlockBenchmark()..setup();
  for (var i = 0; i < _warmupRounds; i++) {
    block
      ..run()
      ..run();
  }
  final watch = Stopwatch();
  for (var i = 0; i < _timedRounds; i++) {
    for (final samples in [first, second]) {
      watch
        ..reset()
        ..start();
      block.run();
      watch.stop();
      samples.add(watch.elapsedTicks * 1e6 / watch.frequency);
    }
  }
  final ratio = _median(second) / _median(first);
  final change = (ratio - 1) * 100;
  return (
    'first ${_ms(_median(first))}, second ${_ms(_median(second))} '
        '(${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%)',
    ratio <= 1.10,
  );
}

(String, bool) _estimateVersusBuild() {
  final perEstimate = medianMicros(EstimateBlockBenchmark()) / _wineCount;
  final build = medianMicros(BuildIndexBenchmark());
  final ratio = perEstimate / build;
  return (
    'estimate ${perEstimate.toStringAsFixed(2)} us, '
        'buildAliasIndex ${build.toStringAsFixed(2)} us '
        '(ratio ${ratio.toStringAsFixed(3)})',
    ratio <= 0.1,
  );
}

(String, bool) _extract() {
  final micros = medianMicros(ExtractBenchmark());
  return (_ms(micros), micros <= 200000);
}

(String, bool) _analyze() {
  final micros = medianMicros(AnalyzeBenchmark());
  return (_ms(micros), micros <= 100000);
}

(String, bool) _buildTable() {
  final micros = medianMicros(BuildTableBenchmark());
  return (_ms(micros), micros <= 150000);
}

(String, bool) _classify() {
  final perWine = medianMicros(ClassifyBenchmark()) / _classifyCount;
  return (
    '${(perWine / 1000).toStringAsFixed(3)} ms per wine',
    perWine <= 5000,
  );
}

String _ms(double micros) => '${(micros / 1000).toStringAsFixed(3)} ms';

final List<Measure> measures = [
  const Measure(
    'recognize $_wineCount names of $_nameLength chars',
    '<= 4 ms',
    _recognition,
  ),
  const Measure(
    'estimate + status + pairings of $_wineCount wines',
    '<= 10 ms',
    _fullEstimate,
  ),
  const Measure(
    'second block of $_wineCount estimates vs first',
    '<= +10%',
    _secondBlock,
  ),
  const Measure(
    'one estimate vs one buildAliasIndex',
    '<= 1/10',
    _estimateVersusBuild,
  ),
  // wine-style-profiles NFR3.1: the preselection of one wine.
  const Measure(
    'classifyWine, mean of $_classifyCount wines',
    '<= 5 ms',
    _classify,
  ),
  // label-autofill-windows (performance-requirements.md): CI pass criteria.
  const Measure('extractLabelFields on 4000 characters', '<= 200 ms', _extract),
  // label-autofill-windows reopening (NFR4.19, NFR5.9): candidates and words
  // of the guided check, target 80 ms.
  const Measure('analyzeLabelText on 4000 characters', '<= 100 ms', _analyze),
  const Measure(
    'joined table and alias index built once',
    '<= 150 ms',
    _buildTable,
  ),
];

void main() {
  for (final measure in measures) {
    var (value, ok) = measure.measure();
    if (!ok) {
      stdout.writeln(
        'RETRY ${measure.label}: $value (limit ${measure.limitLabel})',
      );
      (value, ok) = measure.measure();
    }
    stdout.writeln(
      '${ok ? 'OK  ' : 'FAIL'} ${measure.label}: $value '
      '(limit ${measure.limitLabel})',
    );
    if (!ok) exit(1);
  }
}
