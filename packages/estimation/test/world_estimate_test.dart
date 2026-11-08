// Estimates of label-autofill-windows: precedences of BR3.1-BR3.3, the grape
// basis (FR3.2), the confidence of BR3.4, the level of BR4.1-BR4.2, the key
// and version stored in the window (ENT-002, BR3.9).
import 'package:estimation/estimation.dart';
import 'package:estimation/src/grapes.dart';
import 'package:estimation/src/tables.dart';
import 'package:test/test.dart';

List<int> years(DrinkingWindow window) => [
  window.startYear,
  window.peakYear,
  window.endYear,
];

DrinkingWindow estimate(
  String name, {
  int? vintage = 2020,
  WineType? type,
  String? denomination,
  WineLevel? level,
  ExternalProfile? external,
}) => estimateWindow(
  WineFacts(
    name: name,
    vintage: vintage,
    wineType: type,
    denomination: denomination,
    level: level,
    referenceYear: 2026,
  ),
  external,
);

void main() {
  group('BR3.1 precedences', () {
    test('a foreign denomination in the name gives its window', () {
      final window = estimate('Saint-Estèphe', vintage: 2016);
      expect(window.basis, EstimationBasis.denomination);
      expect(window.denominationKey, 'saintEstephe');
      expect(years(window), [2024, 2031, 2046]);
    });

    test('"Chardonnay Napa Valley" is a Napa white (review R-01)', () {
      final window = estimate('Chardonnay Napa Valley', vintage: 2021);
      expect(window.basis, EstimationBasis.denomination);
      expect(window.denominationKey, 'napaValley');
      expect(years(window), [2022, 2024, 2028]);
    });

    test('a weak alias alone in a hand-typed name is a denomination (owner '
        'decision 0b738ea2)', () {
      for (final name in const ['Toro', 'Cava Brut', 'Port Tawny', 'Rioja']) {
        final window = estimate(name);
        expect(window.basis, EstimationBasis.denomination, reason: name);
        expect(window.denominationKey, isNotNull, reason: name);
      }
      // The denomination wins over the grape named next to it (BR3.1).
      final both = estimate('Toro Tempranillo');
      expect(both.basis, EstimationBasis.denomination);
    });

    test('a weak alias counts next to an indicator or its country (BR1.2)', () {
      expect(estimate('Toro DO').denominationKey, 'toro');
      expect(estimate('Bodega X Toro D.O.').denominationKey, 'toro');
      expect(estimate('Rioja España').denominationKey, 'rioja');
      expect(estimate('Rioja Spain').denominationKey, 'rioja');
      // In a hand-typed name the weak alias counts anyway (0b738ea2).
      expect(estimate('Rioja Italia').denominationKey, 'rioja');
    });

    test('a weak alias in the denomination field always counts', () {
      expect(
        estimate('Cuvée Speciale', denomination: 'Toro').denominationKey,
        'toro',
      );
    });

    test('a longer alias that is not weak still wins over a weak one', () {
      // "Napa Valley" is not weak, "napa" alone is.
      expect(estimate('Napa Valley Cabernet').denominationKey, 'napaValley');
      // In a hand-typed name "napa" alone counts too (0b738ea2).
      expect(estimate('Napa Cabernet').denominationKey, 'napaValley');
    });

    test('"Bordeaux" with the white type chosen is a Bordeaux white', () {
      final window = estimate('Bordeaux Blanc AOC', type: WineType.white);
      expect(window.denominationKey, 'bordeauxRouge');
      expect(years(window), [2021, 2022, 2025]);
      expect(window.qualifier, isNull);
    });

    test('a denomination that does not make the chosen type is skipped', () {
      final window = estimate('Barolo', type: WineType.white);
      expect(window.basis, EstimationBasis.wineType);
    });

    test("the user's denomination wins, if it makes the chosen type", () {
      expect(
        estimate('Cuvée Speciale', denomination: 'Rioja').denominationKey,
        'rioja',
      );
      expect(
        estimate(
          'Cuvée Speciale',
          denomination: 'Rioja',
          type: WineType.white,
        ).basis,
        EstimationBasis.wineType,
      );
    });

    test('a denomination wins over a grape (FR3.4: "Barolo Nebbiolo")', () {
      final window = estimate('Barolo Nebbiolo');
      expect(window.basis, EstimationBasis.denomination);
      expect(window.denominationKey, 'barolo');
    });

    test('the grape inside a denomination name is not a grape', () {
      final window = estimate('Vino Nobile di Montepulciano');
      expect(window.denominationKey, 'vinoNobileDiMontepulciano');
    });

    test('without a denomination the grape gives the window (FR3.2)', () {
      final window = estimate('Tannat Reserva', vintage: 2023);
      expect(window.basis, EstimationBasis.grape);
      expect(window.denominationKey, 'tannat');
      expect(years(window), [2027, 2031, 2038]);
      expect(window.confidence, Confidence.low);
    });

    test('a grape of another type than the chosen one is skipped', () {
      final window = estimate('Chardonnay', type: WineType.redLight);
      expect(window.basis, EstimationBasis.wineType);
    });

    test('a grape in the denomination field counts too', () {
      final window = estimate('Vino di casa', denomination: 'Malbec');
      expect(window.basis, EstimationBasis.grape);
      expect(window.denominationKey, 'malbec');
    });

    test('nothing known is generic, the type alone a type estimate', () {
      expect(estimate('Vino di Mario').basis, EstimationBasis.generic);
      expect(
        estimate('Vino di Mario', type: WineType.rose).basis,
        EstimationBasis.wineType,
      );
    });
  });

  group('BR3.3 the chosen country is never used', () {
    test('a Spanish denomination estimates the same with any region', () {
      final a = estimateWindow(
        const WineFacts(name: 'Rioja DOCa', vintage: 2018, region: 'Toscana'),
      );
      final b = estimateWindow(
        const WineFacts(name: 'Rioja DOCa', vintage: 2018),
      );
      expect(a, b);
    });
  });

  group('BR3.4 confidence', () {
    test('a dedicated denomination with a vintage is medium, without low', () {
      expect(estimate('Pauillac').confidence, Confidence.medium);
      expect(estimate('Pauillac', vintage: null).confidence, Confidence.low);
    });

    test('a generated denomination (a model) is low', () {
      // Not a weak one: a common word alone in a name is not a denomination
      // (BR1.2).
      final generated = appellations.firstWhere(
        (a) => !a.dedicated && a.weakForms.isEmpty,
      );
      final window = estimate(generated.displayName);
      expect(window.basis, EstimationBasis.denomination);
      expect(window.denominationKey, generated.key);
      expect(window.confidence, Confidence.low);
    });

    test('the level never changes the confidence', () {
      for (final level in WineLevel.values) {
        expect(
          estimate('Pauillac', level: level).confidence,
          Confidence.medium,
        );
      }
    });
  });

  group('BR4.1 level (world-tables.md examples)', () {
    test('Rioja 2/4/8: everyday 1/2/5, aging 3/5/11', () {
      expect(years(estimate('Rioja DOCa', level: WineLevel.good)), [
        2022,
        2024,
        2028,
      ]);
      expect(years(estimate('Rioja DOCa', level: WineLevel.everyday)), [
        2021,
        2022,
        2025,
      ]);
      expect(years(estimate('Rioja DOCa', level: WineLevel.aging)), [
        2023,
        2025,
        2031,
      ]);
    });

    test('Barolo 8/15/30: everyday 4/9/18, aging 10/20/42', () {
      expect(years(estimate('Barolo', level: WineLevel.everyday)), [
        2024,
        2029,
        2038,
      ]);
      expect(years(estimate('Barolo', level: WineLevel.aging)), [
        2030,
        2040,
        2062,
      ]);
    });

    test("Barbera d'Asti 2/4/8: everyday 1/2/5, aging 3/5/11", () {
      expect(years(estimate("Barbera d'Asti", level: WineLevel.everyday)), [
        2021,
        2022,
        2025,
      ]);
      expect(years(estimate("Barbera d'Asti", level: WineLevel.aging)), [
        2023,
        2025,
        2031,
      ]);
    });

    test('not chosen equals good: the estimate of today', () {
      expect(
        estimate('Rioja DOCa'),
        estimate('Rioja DOCa', level: WineLevel.good),
      );
    });

    test('without a vintage the level applies before the base year', () {
      final window = estimate(
        'Rioja DOCa',
        vintage: null,
        level: WineLevel.aging,
      );
      expect(years(window), [2028, 2030, 2036]);
    });
  });

  group('BR4.2 level and qualifier', () {
    test('Rioja Gran Reserva: aging adds nothing, everyday shortens', () {
      expect(years(estimate('Rioja DOCa Gran Reserva')), [2026, 2032, 2045]);
      expect(
        years(estimate('Rioja DOCa Gran Reserva', level: WineLevel.aging)),
        [2026, 2032, 2045],
      );
      expect(
        years(estimate('Rioja DOCa Gran Reserva', level: WineLevel.everyday)),
        [2023, 2027, 2035],
      );
    });

    test('a catalog window is never changed by the level', () {
      const external = ExternalProfile(
        startYear: 2022,
        peakYear: 2025,
        endYear: 2030,
        vintage: 2020,
      );
      for (final level in WineLevel.values) {
        final window = estimate('Rioja DOCa', level: level, external: external);
        expect(years(window), [2022, 2025, 2030]);
        expect(window.tablesVersion, isNull);
      }
    });
  });

  group('WineLevel', () {
    test('tryParse reads the stored names only', () {
      expect(WineLevel.tryParse('aging'), WineLevel.aging);
      expect(WineLevel.tryParse('everyday'), WineLevel.everyday);
      expect(WineLevel.tryParse('good'), WineLevel.good);
      expect(WineLevel.tryParse('old'), isNull);
      expect(WineLevel.tryParse(3), isNull);
      expect(WineLevel.tryParse(null), isNull);
    });

    test('the window stays valid on the smallest offsets', () {
      expect(
        WineLevel.everyday.apply(const YearOffsets(0, 0, 1)).isValid,
        isTrue,
      );
      expect(
        WineLevel.everyday.apply(const YearOffsets(1, 1, 1)),
        const YearOffsets(1, 1, 2),
      );
      expect(
        WineLevel.aging.apply(const YearOffsets(0, 1, 2)),
        const YearOffsets(0, 1, 3),
      );
    });
  });

  group('ENT-002 key and version of the tables', () {
    test('internal windows carry the version and the row key', () {
      final window = estimate('Pauillac');
      expect(window.tablesVersion, estimationTablesVersion);
      expect(window.denominationKey, 'pauillac');
      expect(estimate('Vino di Mario').denominationKey, isNull);
      expect(estimate('Vino di Mario').tablesVersion, estimationTablesVersion);
    });

    test('withYears keeps everything but the years', () {
      final window = estimate('Pauillac');
      final moved = window.withYears(2030, 2031, 2032);
      expect(years(moved), [2030, 2031, 2032]);
      expect(moved.denominationKey, window.denominationKey);
      expect(moved.tablesVersion, window.tablesVersion);
      expect(moved.toString(), contains('denominationKey: pauillac'));
      expect(moved, isNot(window));
    });
  });

  group('grapes (FR3.2, NFR5.2)', () {
    test('at least 40 grapes', () {
      expect(grapeTable.length, greaterThanOrEqualTo(40));
    });

    for (final MapEntry(:key, value: grape) in grapeTable.entries) {
      test('$key: valid window, recognised by its forms, name shown', () {
        final offsets = grape.offsets;
        expect(offsets.isValid, isTrue, reason: key);
        for (final level in WineLevel.values) {
          expect(level.apply(offsets).isValid, isTrue, reason: '$key $level');
        }
        final window = estimate(grape.name, type: grape.wineType);
        expect(window.basis, EstimationBasis.grape, reason: key);
        expect(window.denominationKey, key);
        expect(grapeNameOf(key), grape.name);
        for (final alias in grape.aliases) {
          expect(estimate(alias).denominationKey, key, reason: alias);
        }
      });
    }

    test('unknown grape key has no name', () {
      expect(grapeNameOf('nope'), isNull);
      expect(grapeNameOf(null), isNull);
    });
  });
}
