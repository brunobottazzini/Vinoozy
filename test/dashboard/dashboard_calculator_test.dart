// DashboardCalculator (u5-dashboard rules.md BR1.1-BR1.9, NFR2.2, NFR6.1).
// Every rule has at least one test with its ID in the name.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/dashboard/domain/dashboard_calculator.dart';
import 'package:vinoozy/dashboard/domain/dashboard_summary.dart';

import 'fixtures.dart';

void main() {
  const calculator = DashboardCalculator();
  final today = DateTime(2026, 11, 6, 15, 30);

  // On 6 November 2026 (statusOf of C2):
  final waitingWindow = window(2028, 2032, 2040);
  final readyWindow = window(2024, 2030, 2040);
  final drinkSoonWindow = window(2020, 2024, 2026);
  final pastWindow = window(2010, 2015, 2020);
  final invalidWindow = window(2030, 2025, 2040);

  BreakdownBar familyBar(DashboardSummary s, WineFamily family) =>
      s.byType.singleWhere((bar) => bar.family == family);

  group('BR1.1 bottles, not rows', () {
    test('BR1.1 every wine counts for its quantity', () {
      final s = calculator.compute([
        wineOf('a', quantity: 3, window: readyWindow),
        wineOf('b', quantity: 2, window: readyWindow),
      ], today);

      expect(s.totalBottles, 5);
      expect(s.readyBottles, 5);
    });

    test('BR1.1 quantity 0 and negative quantities are excluded', () {
      final s = calculator.compute([
        wineOf('zero', quantity: 0, window: drinkSoonWindow, wineType: 'white'),
        wineOf('neg', quantity: -2, window: drinkSoonWindow, region: 'Veneto'),
        wineOf('one', quantity: 1, window: readyWindow),
      ], today);

      expect(s.totalBottles, 1);
      expect(s.drinkSoon, isEmpty);
      expect(s.drinkSoonTotal, 0);
      expect(familyBar(s, WineFamily.white).bottles, 0);
      expect(s.byRegion.any((bar) => bar.region == 'Veneto'), isFalse);
    });
  });

  group('BR1.2 status of the day', () {
    test('BR1.2 each window gets its status on today', () {
      final s = calculator.compute([
        wineOf('w', window: waitingWindow),
        wineOf('r', quantity: 2, window: readyWindow),
        wineOf('d', quantity: 3, window: drinkSoonWindow),
        wineOf('p', quantity: 4, window: pastWindow),
      ], today);

      expect(s.waitingBottles, 1);
      expect(s.readyBottles, 2);
      expect(s.drinkSoonBottles, 3);
      expect(s.pastWindowBottles, 4);
      expect(s.toEstimateBottles, 0);
      expect(s.invalidWindowCount, 0);
    });

    test('BR1.2 the time of day is ignored and the status follows the day', () {
      // A 10-year window has a 12-month notice: drink soon from 1 January
      // of its last year.
      final wines = [wineOf('d', window: window(2018, 2022, 2027))];

      final before = calculator.compute(wines, DateTime(2026, 12, 31, 23, 59));
      final after = calculator.compute(wines, DateTime(2027, 1, 1, 0, 1));

      expect(before.readyBottles, 1);
      expect(after.drinkSoonBottles, 1);
    });

    test('BR1.2 a wine without window is "to estimate"', () {
      final s = calculator.compute([
        wineOf('n', quantity: 2),
        wineOf('r', window: readyWindow),
      ], today);

      expect(s.toEstimateBottles, 2);
      expect(s.invalidWindowCount, 0);
      expect(s.readyBottles, 1);
    });

    test('BR1.2 an invalid window is counted as "to estimate" and as '
        'invalid, the rest continues (NFR6.1)', () {
      final s = calculator.compute([
        wineOf('bad1', name: 'Marker 1999', quantity: 2, window: invalidWindow),
        wineOf('bad2', window: window(2020, 2030, 2025)),
        wineOf('ok', window: drinkSoonWindow),
      ], today);

      expect(s.invalidWindowCount, 2);
      expect(s.toEstimateBottles, 3);
      expect(s.drinkSoonBottles, 1);
      expect(s.totalBottles, 4);
      final peaks = s.peakYears.fold<int>(0, (sum, bar) => sum + bar.bottles);
      expect(peaks, 1, reason: 'invalid windows are not in the peaks');
    });
  });

  group('BR1.3 drink soon', () {
    test('BR1.3 sorted by end year, then name without case and accents, '
        'then vintage', () {
      // With the C2 notice of at most 12 months, every "drink soon" wine
      // ends in the current year: end year ties, name and vintage decide.
      final s = calculator.compute([
        wineOf('e2', name: 'barolo', vintage: 2015, window: drinkSoonWindow),
        wineOf('e1', name: 'Barolo', vintage: 2012, window: drinkSoonWindow),
        wineOf('a', name: 'Ålba', vintage: 2019, window: drinkSoonWindow),
        wineOf('z', name: 'Arneis', window: drinkSoonWindow),
        wineOf('r', name: 'Amarone', window: readyWindow),
      ], DateTime(2026, 12, 1));

      expect(s.drinkSoon.map((row) => row.wineId), ['a', 'z', 'e1', 'e2']);
      expect(s.drinkSoon.map((row) => row.endYear).toSet(), {2026});
      expect(s.drinkSoonTotal, 4);
    });

    test('BR1.3 a row carries name, vintage, producer, quantity, end year', () {
      final s = calculator.compute([
        wineOf(
          'w1',
          name: 'Barolo',
          vintage: 2016,
          producer: '  Cantina Esempio ',
          quantity: 3,
          window: drinkSoonWindow,
        ),
        wineOf('w2', producer: '   ', vintage: null, window: drinkSoonWindow),
      ], today);

      expect(
        s.drinkSoon.firstWhere((row) => row.wineId == 'w1'),
        const DrinkSoonRow(
          wineId: 'w1',
          name: 'Barolo',
          vintage: 2016,
          producer: 'Cantina Esempio',
          quantity: 3,
          endYear: 2026,
        ),
      );
      final w2 = s.drinkSoon.firstWhere((row) => row.wineId == 'w2');
      expect(w2.producer, isNull);
      expect(w2.vintage, isNull);
    });

    test('BR1.3 at most 10 rows; the total gives "See all (N)"', () {
      final s = calculator.compute([
        for (var i = 0; i < 14; i++)
          wineOf(
            'w$i',
            name: 'Vino ${i.toString().padLeft(2, '0')}',
            window: drinkSoonWindow,
          ),
      ], today);

      expect(s.drinkSoon, hasLength(DashboardSummary.maxDrinkSoonRows));
      expect(s.drinkSoon.last.wineId, 'w9');
      expect(s.drinkSoonTotal, 14);
      expect(s.drinkSoonBottles, 14);
    });

    test('BR1.3 no drink-soon wine gives an empty list', () {
      final s = calculator.compute([wineOf('r', window: readyWindow)], today);

      expect(s.drinkSoon, isEmpty);
      expect(s.drinkSoonTotal, 0);
    });
  });

  group('BR1.4 status chart', () {
    test('BR1.4 four bars and the to-estimate note, wines without window '
        'outside the bars', () {
      final s = calculator.compute([
        wineOf('w', quantity: 12, window: waitingWindow),
        wineOf('r', quantity: 30, window: readyWindow),
        wineOf('d', quantity: 4, window: drinkSoonWindow),
        wineOf('p', quantity: 2, window: pastWindow),
        wineOf('n', quantity: 5),
      ], today);

      expect(
        [for (final st in WineStatus.values) s.bottlesWith(st)],
        [12, 30, 4, 2],
      );
      expect(s.toEstimateBottles, 5);
      expect(s.totalBottles, 53);
    });
  });

  group('BR1.5 peak chart', () {
    test('BR1.5 past peak, current year to +10, beyond, with empty '
        'columns at 0', () {
      final s = calculator.compute([
        wineOf('past', quantity: 2, window: window(2010, 2020, 2030)),
        wineOf('now', quantity: 3, window: window(2024, 2026, 2030)),
        wineOf('plus10', window: window(2030, 2036, 2040)),
        wineOf('beyond', quantity: 4, window: window(2030, 2037, 2050)),
        wineOf('unestimated', quantity: 9),
      ], today);

      expect(s.peakYears, hasLength(13));
      expect(
        s.peakYears.first,
        const PeakYearBar(kind: PeakColumnKind.pastPeak, bottles: 2),
      );
      expect(
        s.peakYears[1],
        const PeakYearBar(kind: PeakColumnKind.year, year: 2026, bottles: 3),
      );
      expect(s.peakYears[2].bottles, 0);
      expect(
        s.peakYears[11],
        const PeakYearBar(kind: PeakColumnKind.year, year: 2036, bottles: 1),
      );
      expect(
        s.peakYears.last,
        const PeakYearBar(kind: PeakColumnKind.beyond, bottles: 4),
      );
      expect(s.toEstimateBottles, 9);
    });

    test('BR1.5 an empty cellar still has the fixed axis', () {
      final s = calculator.compute(const [], today);

      expect(s.peakYears, hasLength(13));
      expect(s.peakYears.every((bar) => bar.bottles == 0), isTrue);
      expect(s.peakYears[1].year, 2026);
    });
  });

  group('BR1.6 type and region', () {
    test('BR1.6 U2 type names and C1 values map to the five families', () {
      final s = calculator.compute([
        wineOf('1', wineType: 'redLight'),
        wineOf('2', wineType: 'redStructured'),
        wineOf('3', wineType: 'red'),
        wineOf('4', wineType: 'white'),
        wineOf('5', wineType: 'rose'),
        wineOf('6', wineType: 'sparklingClassic'),
        wineOf('7', wineType: 'sparklingTank'),
        wineOf('8', wineType: 'sparkling'),
        wineOf('9', wineType: 'sweet'),
        wineOf('10', wineType: 'fortified'),
      ], today);

      expect(s.byType.map((bar) => (bar.family, bar.bottles)), [
        (WineFamily.red, 3),
        (WineFamily.white, 1),
        (WineFamily.rose, 1),
        (WineFamily.sparkling, 3),
        (WineFamily.sweet, 2),
      ]);
    });

    test('BR1.6 absent or strange types are "not specified"', () {
      final s = calculator.compute([
        wineOf('1'),
        wineOf('2', wineType: 'ROSSO'),
        wineOf('3', wineType: ''),
        wineOf('4', wineType: 'orange', quantity: 2),
        wineOf('5', wineType: ' white '),
      ], today);

      expect(
        s.byType.last,
        const BreakdownBar(kind: BreakdownKind.unspecified, bottles: 5),
      );
      expect(familyBar(s, WineFamily.white).bottles, 1);
    });

    test('BR1.6 region of the wine, else of its denomination, else "not '
        'specified"', () {
      final s = calculator.compute([
        wineOf('own', region: 'Toscana', denomination: 'Barolo DOCG'),
        wineOf('fromDenomination', denomination: 'Barolo DOCG', quantity: 2),
        wineOf('again', denomination: 'Barolo DOCG'),
        wineOf('unknown', denomination: 'Vino della casa', quantity: 4),
        wineOf('blankRegion', region: ' - ', quantity: 5),
      ], today);

      // ux-redesign R-06: Italian regions carry Italy for the flag.
      expect(s.byRegion, const [
        BreakdownBar(
          kind: BreakdownKind.region,
          region: 'Piemonte',
          country: 'IT',
          bottles: 3,
        ),
        BreakdownBar(
          kind: BreakdownKind.region,
          region: 'Toscana',
          country: 'IT',
          bottles: 1,
        ),
        BreakdownBar(kind: BreakdownKind.unspecified, bottles: 9),
      ]);
    });

    test('BR1.6 regions compare without case and accents and show the most '
        'frequent written form (alphabetical on a tie)', () {
      final s = calculator.compute([
        wineOf('1', region: 'piemonte'),
        wineOf('2', region: 'Piemonte'),
        wineOf('3', region: 'Piemonte'),
        wineOf('4', region: 'Valle d’Aosta'),
        wineOf('5', region: "valle d'aosta"),
        wineOf('6', region: 'Sicília'),
        wineOf('7', region: 'Sicilia'),
      ], today);

      expect(s.byRegion.map((bar) => (bar.region, bar.bottles)), [
        ('Piemonte', 3),
        ('Sicilia', 2),
        ('Valle d’Aosta', 2),
      ]);
    });

    test('BR1.6 the first 8 regions by bottles (alphabetical on a tie), then '
        '"others", then "not specified"', () {
      final regions = [
        'Veneto',
        'Toscana',
        'Piemonte',
        'Sicilia',
        'Puglia',
        'Campania',
        'Marche',
        'Abruzzo',
        'Umbria',
        'Lazio',
        'Liguria',
      ];
      final s = calculator.compute([
        for (var i = 0; i < regions.length; i++)
          wineOf('r$i', region: regions[i], quantity: i < 3 ? 5 : 2),
        wineOf('none', quantity: 7),
      ], today);

      expect(s.byRegion.map((bar) => bar.region ?? bar.kind.name), [
        'Piemonte',
        'Toscana',
        'Veneto',
        'Abruzzo',
        'Campania',
        'Lazio',
        'Liguria',
        'Marche',
        'otherRegions',
        'unspecified',
      ]);
      expect(s.byRegion[8].bottles, 6, reason: 'Puglia, Sicilia, Umbria');
      expect(s.byRegion.last.bottles, 7);
    });

    test('BR1.6 wines without window still count in the third chart', () {
      final s = calculator.compute([
        wineOf('n', wineType: 'white', region: 'Veneto', quantity: 2),
      ], today);

      expect(familyBar(s, WineFamily.white).bottles, 2);
      expect(s.byRegion.single.bottles, 2);
    });

    test('BR1.6 familyOf matches WineType.tryParse', () {
      expect(DashboardCalculator.familyOf(null), isNull);
      expect(DashboardCalculator.familyOf('fortified'), WineFamily.sweet);
      expect(DashboardCalculator.familyOf('unknown'), isNull);
    });
  });

  group('BR1.7 numbers for every bar', () {
    test('BR1.7 every bar has its number and the bars add up to the total', () {
      final wines = syntheticCellar(120);
      final s = calculator.compute(wines, today);

      int sum(Iterable<int> values) => values.fold(0, (a, b) => a + b);
      final statusSum =
          sum(WineStatus.values.map(s.bottlesWith)) + s.toEstimateBottles;
      expect(statusSum, s.totalBottles);
      expect(sum(s.byType.map((bar) => bar.bottles)), s.totalBottles);
      expect(sum(s.byRegion.map((bar) => bar.bottles)), s.totalBottles);
      expect(
        sum(s.peakYears.map((bar) => bar.bottles)) + s.toEstimateBottles,
        s.totalBottles,
      );
    });
  });

  group('BR1.8 empty cellar', () {
    test('BR1.8 no bottles gives total 0 and empty lists', () {
      final s = calculator.compute([wineOf('zero', quantity: 0)], today);

      expect(s.totalBottles, 0);
      expect(s.drinkSoon, isEmpty);
      expect(s.byRegion, isEmpty);
      expect(s.byType.every((bar) => bar.bottles == 0), isTrue);
    });
  });

  group('BR1.9 recalculation', () {
    test('BR1.9 the same input gives the same summary (pure function)', () {
      final wines = syntheticCellar(60);

      expect(
        calculator.compute(wines, today),
        calculator.compute(wines, today),
      );
    });

    test('BR1.9 a new day changes the statuses', () {
      final wines = [wineOf('d', window: window(2020, 2024, 2026))];

      expect(calculator.compute(wines, today).drinkSoonBottles, 1);
      expect(
        calculator.compute(wines, DateTime(2027, 1, 1)).pastWindowBottles,
        1,
      );
    });

    test('BR1.9 500 wines in one pass, every bottle counted', () {
      final wines = syntheticCellar(500);
      final expectedTotal = wines.fold<int>(0, (sum, w) => sum + w.quantity);

      final s = calculator.compute(wines, today);

      expect(s.totalBottles, expectedTotal);
      expect(s.drinkSoon.length, lessThanOrEqualTo(10));
      expect(s.byRegion.length, lessThanOrEqualTo(10));
      expect(s.invalidWindowCount, 0);
    });
  });
}
