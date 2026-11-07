// Properties of the public C2 API as a whole: needsRefinement (BR1.5),
// determinism (BR4.4, NFR4.4) and the single error type (NFR4.2), checked on
// inputs generated with a fixed seed.
import 'dart:math';

import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

const _cases = 1000;

const _names = [
  'Barolo',
  'Barolo Riserva',
  "Barbera d'Asti Superiore",
  'Chianti Classico Gran Selezione',
  'Castiglione',
  'Vino di Mario',
  'Prosecco Superiore',
  'Marsala Superiore Riserva',
  'Rosé della casa',
  'Lagréin',
  '',
  '   ',
  "''--..",
];

const _texts = [null, 'Barolo', 'Franciacorta', 'IGT Toscana', '', 'Soave'];
const _catalogTypes = [null, 'red', 'white', 'rose', 'sparkling', 'sweet', 'x'];

int? _maybeYear(Random random, {bool allowInvalid = false}) {
  final roll = random.nextInt(10);
  if (roll == 0) return null;
  if (allowInvalid && roll == 1) return random.nextInt(4000) - 500;
  return 1900 + random.nextInt(301);
}

String _randomText(Random random) {
  final length = random.nextInt(80);
  return String.fromCharCodes(
    List.generate(length, (_) => 0x20 + random.nextInt(0x2F0)),
  );
}

WineFacts _wine(Random random, {bool allowInvalid = false}) {
  final pickName = random.nextBool();
  return WineFacts(
    name: pickName
        ? _names[random.nextInt(_names.length)]
        : _randomText(random),
    vintage: _maybeYear(random, allowInvalid: allowInvalid),
    referenceYear: random.nextBool()
        ? _maybeYear(random, allowInvalid: allowInvalid)
        : null,
    wineType: random.nextInt(3) == 0
        ? null
        : WineType.values[random.nextInt(WineType.values.length)],
    denomination: _texts[random.nextInt(_texts.length)],
  );
}

ExternalProfile? _external(Random random, {bool allowInvalid = false}) {
  if (random.nextInt(3) == 0) return null;
  return ExternalProfile(
    startYear: _maybeYear(random, allowInvalid: allowInvalid),
    peakYear: _maybeYear(random, allowInvalid: allowInvalid),
    endYear: _maybeYear(random, allowInvalid: allowInvalid),
    confidence: random.nextBool()
        ? null
        : Confidence.values[random.nextInt(Confidence.values.length)],
    vintage: _maybeYear(random),
    pairings: List.generate(random.nextInt(8), (i) => 'pairing $i'),
    wineType: _catalogTypes[random.nextInt(_catalogTypes.length)],
    denomination: _texts[random.nextInt(_texts.length)],
  );
}

DrinkingWindow _window(Random random) {
  final start = 1900 + random.nextInt(301);
  final peak = start + random.nextInt(40) - 5;
  final end = peak + random.nextInt(40) - 5;
  return DrinkingWindow(
    startYear: start,
    peakYear: peak,
    endYear: end,
    confidence: Confidence.values[random.nextInt(Confidence.values.length)],
    source: WindowSource.values[random.nextInt(WindowSource.values.length)],
    basis:
        EstimationBasis.values[random.nextInt(EstimationBasis.values.length)],
  );
}

DateTime _day(Random random) => DateTime(
  1890 + random.nextInt(330),
  1 + random.nextInt(12),
  1 + random.nextInt(28),
);

/// Runs [call] and returns its result, or the error code it threw.
Object? _outcome(Object? Function() call) {
  try {
    return call();
  } on EstimationArgumentError catch (error) {
    return error.code;
  }
}

void main() {
  group('needsRefinement (BR1.5)', () {
    test('true for internal estimates, false for catalog ones', () {
      final internal = estimateWindow(
        const WineFacts(name: 'Barolo', vintage: 2016),
      );
      final catalog = estimateWindow(
        const WineFacts(name: 'Barolo', vintage: 2016),
        const ExternalProfile(startYear: 2022, peakYear: 2030, endYear: 2045),
      );
      expect(needsRefinement(internal), isTrue);
      expect(needsRefinement(catalog), isFalse);
    });

    test('never throws, even on an incoherent window', () {
      const incoherent = DrinkingWindow(
        startYear: 2050,
        peakYear: 2010,
        endYear: 1990,
        confidence: Confidence.low,
        source: WindowSource.internalRules,
        basis: EstimationBasis.generic,
      );
      expect(needsRefinement(incoherent), isTrue);
    });
  });

  group('determinism with Random(42) (BR4.4, NFR4.4)', () {
    test('estimateWindow gives equal results for equal inputs', () {
      final random = Random(42);
      for (var i = 0; i < _cases; i++) {
        final wine = _wine(random);
        final external = _external(random);
        expect(
          _outcome(() => estimateWindow(wine, external)),
          _outcome(() => estimateWindow(wine, external)),
          reason: '$wine $external',
        );
      }
    });

    test('pairingsFor gives equal results for equal inputs', () {
      final random = Random(42);
      for (var i = 0; i < _cases; i++) {
        final wine = _wine(random);
        final external = _external(random);
        expect(
          _outcome(() => pairingsFor(wine, external)),
          _outcome(() => pairingsFor(wine, external)),
          reason: '$wine $external',
        );
      }
    });

    test('statusOf gives equal results for equal inputs', () {
      final random = Random(42);
      for (var i = 0; i < _cases; i++) {
        final window = _window(random);
        final today = _day(random);
        expect(
          _outcome(() => statusOf(window, today)),
          _outcome(() => statusOf(window, today)),
          reason: '$window $today',
        );
      }
    });

    test('needsRefinement gives equal results for equal inputs', () {
      final random = Random(42);
      for (var i = 0; i < _cases; i++) {
        final window = _window(random);
        expect(needsRefinement(window), needsRefinement(window));
      }
    });
  });

  group('only EstimationArgumentError on random inputs (NFR4.2)', () {
    test('estimateWindow and pairingsFor', () {
      final random = Random(42);
      var rejected = 0;
      for (var i = 0; i < _cases; i++) {
        final wine = _wine(random, allowInvalid: true);
        final external = _external(random, allowInvalid: true);
        for (final call in [
          () => estimateWindow(wine, external),
          () => pairingsFor(wine, external),
        ]) {
          try {
            final result = call();
            expect(result, isNotNull);
          } on EstimationArgumentError {
            rejected++;
          }
        }
      }
      // The generator produces both valid and invalid inputs.
      expect(rejected, inExclusiveRange(0, _cases * 2));
    });

    test('estimates are coherent windows that statusOf accepts', () {
      final random = Random(42);
      for (var i = 0; i < _cases; i++) {
        final wine = _wine(random);
        final DrinkingWindow window;
        try {
          window = estimateWindow(wine, _external(random));
        } on EstimationArgumentError {
          continue;
        }
        expect(window.startYear, lessThanOrEqualTo(window.peakYear));
        expect(window.peakYear, lessThanOrEqualTo(window.endYear));
        expect(
          window.basis == EstimationBasis.catalog,
          window.source == WindowSource.catalog,
        );
        expect(
          () => statusOf(window, _day(random)),
          returnsNormally,
          reason: '$window',
        );
      }
    });

    test('statusOf', () {
      final random = Random(42);
      var rejected = 0;
      for (var i = 0; i < _cases; i++) {
        try {
          statusOf(_window(random), _day(random));
        } on EstimationArgumentError catch (error) {
          expect(error.code, EstimationErrorCode.invalidWindow);
          rejected++;
        }
      }
      expect(rejected, inExclusiveRange(0, _cases));
    });
  });

  test('pairings respect the 1-5 items or 3-5 keys rule', () {
    final random = Random(42);
    for (var i = 0; i < _cases; i++) {
      final Pairings pairings;
      try {
        pairings = pairingsFor(_wine(random), _external(random));
      } on EstimationArgumentError {
        continue;
      }
      if (pairings.source == WindowSource.catalog) {
        expect(pairings.items.length, inInclusiveRange(1, 5));
        expect(pairings.categoryKeys, isEmpty);
      } else {
        expect(pairings.items, isEmpty);
        expect(pairings.categoryKeys.length, inInclusiveRange(3, 5));
      }
    }
  });
}
