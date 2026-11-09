// Windows in months, without a peak or an end (wine-style-profiles BR6.1,
// BR6.3, BR6.8, BR6.10, D2).
import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

DrinkingWindow _months((int, int) start, (int, int)? peak, (int, int)? end) =>
    DrinkingWindow(
      startYear: start.$1,
      startMonth: start.$2,
      peakYear: peak?.$1,
      peakMonth: peak?.$2,
      endYear: end?.$1,
      endMonth: end?.$2,
      unit: WindowUnit.months,
      confidence: Confidence.low,
      source: WindowSource.internalRules,
      basis: EstimationBasis.wineType,
    );

DrinkingWindow _years(int start, int? peak, int? end) => DrinkingWindow(
  startYear: start,
  peakYear: peak,
  endYear: end,
  confidence: Confidence.low,
  source: WindowSource.internalRules,
  basis: EstimationBasis.wineType,
);

void main() {
  group('BR6.1 month indexes', () {
    test('monthIndex and monthOfIndex are inverse', () {
      expect(monthIndex(2027, 3), 2027 * 12 + 2);
      expect(monthOfIndex(monthIndex(2027, 12)), (year: 2027, month: 12));
      expect(monthOfIndex(monthIndex(2028, 1)), (year: 2028, month: 1));
    });

    test('a window in years spans January to December', () {
      final w = _years(2024, 2026, 2030);
      expect(w.startIndex, monthIndex(2024, 1));
      expect(w.peakIndex, monthIndex(2026, 1));
      expect(w.endIndex, monthIndex(2030, 12));
      expect(w.inMonths, isFalse);
    });

    test('a window without peak or end has null indexes', () {
      final w = _months((2024, 3), null, null);
      expect(w.peakIndex, isNull);
      expect(w.endIndex, isNull);
    });
  });

  group('BR6.3 statusOf', () {
    test('years: today\'s rules are kept', () {
      final w = _years(2024, 2026, 2030);
      expect(statusOf(w, DateTime(2023, 12, 31)), WineStatus.waiting);
      expect(statusOf(w, DateTime(2027, 6)), WineStatus.ready);
      expect(statusOf(w, DateTime(2030, 1)), WineStatus.drinkSoon);
      expect(statusOf(w, DateTime(2031, 1)), WineStatus.pastWindow);
    });

    test('months: SP_TANK March to September of the same year', () {
      final w = _months((2025, 3), (2025, 6), (2025, 9));
      expect(statusOf(w, DateTime(2025, 2, 28)), WineStatus.waiting);
      expect(statusOf(w, DateTime(2025, 3)), WineStatus.ready);
      // 7 months, notice 3 (minimum): July to September.
      expect(statusOf(w, DateTime(2025, 6)), WineStatus.ready);
      expect(statusOf(w, DateTime(2025, 7)), WineStatus.drinkSoon);
      expect(statusOf(w, DateTime(2025, 9, 30)), WineStatus.drinkSoon);
      expect(statusOf(w, DateTime(2025, 10)), WineStatus.pastWindow);
    });

    test('without a peak the notice is the last 3 months (Sherry)', () {
      final fino = _months((2025, 1), null, (2025, 12));
      expect(statusOf(fino, DateTime(2025, 9)), WineStatus.ready);
      expect(statusOf(fino, DateTime(2025, 10)), WineStatus.drinkSoon);
    });

    test('without an end the wine is always ready (BR6.5)', () {
      final lbv = _months((2020, 5), null, null);
      expect(statusOf(lbv, DateTime(2020, 4)), WineStatus.waiting);
      expect(statusOf(lbv, DateTime(2020, 5)), WineStatus.ready);
      expect(statusOf(lbv, DateTime(2090, 1)), WineStatus.ready);
    });
  });

  group('BR6.10 validateWindow through statusOf', () {
    test('September to March is refused', () {
      expect(
        () => statusOf(_months((2025, 9), null, (2025, 3)), DateTime(2025)),
        throwsA(isA<EstimationArgumentError>()),
      );
    });

    test('a month outside 1-12 is refused', () {
      expect(
        () => statusOf(_months((2025, 13), null, null), DateTime(2025)),
        throwsA(isA<EstimationArgumentError>()),
      );
    });

    test('a peak after the end in years is refused', () {
      expect(
        () => statusOf(_years(2020, 2030, 2025), DateTime(2025)),
        throwsA(isA<EstimationArgumentError>()),
      );
    });
  });

  group('BR6.8 effectiveWindow with months', () {
    final w = _months((2025, 3), (2025, 9), (2026, 9));

    test('the override month becomes the end; December when missing', () {
      final m = effectiveWindow(w, overrideEndYear: 2027, overrideEndMonth: 4);
      expect([m.endYear, m.endMonth], [2027, 4]);
      final dec = effectiveWindow(w, overrideEndYear: 2027);
      expect([dec.endYear, dec.endMonth], [2027, 12]);
    });

    test('start and peak stop at an earlier end', () {
      final m = effectiveWindow(w, overrideEndYear: 2025, overrideEndMonth: 5);
      expect([m.peakYear, m.peakMonth], [2025, 5]);
      expect([m.startYear, m.startMonth], [2025, 3]);
    });

    test('a window in years without a peak keeps it null', () {
      final y = effectiveWindow(
        _years(2020, null, 2030),
        overrideEndYear: 2025,
      );
      expect(y.peakYear, isNull);
      expect(y.endYear, 2025);
    });

    test('ranges: 120 months for months, 60 years for years', () {
      expect(overrideMonthRange(w).last - overrideMonthRange(w).first, 120);
      expect(isValidOverrideYear(w, 2035, 3), isTrue);
      expect(isValidOverrideYear(w, 2035, 4), isFalse);
      expect(isValidOverrideYear(w, 2025, 2), isFalse);
      expect(isValidOverrideYear(w, 2026, 13), isFalse);
      expect(overrideYearRange(w), (first: 2025, last: 2035));
      expect(isValidOverrideYear(_years(2020, 2022, 2025), 2080), isTrue);
    });

    test('withIndexes on a window in years keeps only years', () {
      final y = _years(
        2020,
        2022,
        2025,
      ).withIndexes(monthIndex(2021, 5), null, monthIndex(2024, 2));
      expect([y.startYear, y.peakYear, y.endYear], [2021, null, 2024]);
      expect(y.startMonth, isNull);
    });
  });

  group('validation of the new inputs (BR8.2)', () {
    test('month out of range and half a date are refused', () {
      expect(
        () => estimateWindow(
          const WineFacts(name: 'X', referenceYear: 2025, referenceMonth: 0),
        ),
        throwsA(isA<EstimationArgumentError>()),
      );
      expect(
        () => estimateWindow(
          const WineFacts(name: 'X', referenceYear: 2025, agingStartYear: 2024),
        ),
        throwsA(isA<EstimationArgumentError>()),
      );
      expect(
        () => estimateWindow(
          const WineFacts(
            name: 'X',
            referenceYear: 2025,
            agingStartYear: 1800,
            agingStartMonth: 2,
          ),
        ),
        throwsA(isA<EstimationArgumentError>()),
      );
    });

    test('the new WineFacts fields count in equality and text', () {
      const a = WineFacts(
        name: 'X',
        referenceYear: 2025,
        referenceMonth: 3,
        style: WineStyle.tankFresh,
        styleChosen: true,
        agingStartYear: 2024,
        agingStartMonth: 2,
      );
      const b = WineFacts(name: 'X', referenceYear: 2025);
      expect(a == b, isFalse);
      expect(a.hashCode == b.hashCode, isFalse);
      expect(a.toString(), contains('tankFresh'));
      expect(a.toString(), contains('2024-2'));
    });

    test('DrinkingWindow text shows months, profile and flags', () {
      final w = estimateWindow(
        const WineFacts(name: 'Prosecco', referenceYear: 2025),
      )!;
      expect(w.toString(), contains('SP_TANK'));
      expect(w.toString(), contains('anchorFallback'));
      expect(w.toString(), contains('2025-1'));
    });
  });
}
