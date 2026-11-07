import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

DrinkingWindow windowOf(int start, int peak, int end) => DrinkingWindow(
  startYear: start,
  peakYear: peak,
  endYear: end,
  confidence: Confidence.medium,
  source: WindowSource.internalRules,
  basis: EstimationBasis.denomination,
);

void main() {
  group('acceptance criteria (NFR7.3)', () {
    test('AC4.2.1: 15-year window, 11 months left -> drinkSoon', () {
      // 2012..2026 is 15 years; on 1 February 2026, 11 months are left.
      expect(
        statusOf(windowOf(2012, 2018, 2026), DateTime(2026, 2, 1)),
        WineStatus.drinkSoon,
      );
    });

    test('AC4.2.2: 1-year window, 4 months left -> ready', () {
      // Notice is 25% of 12 months = 3; on 1 September 4 months are left.
      expect(
        statusOf(windowOf(2026, 2026, 2026), DateTime(2026, 9, 1)),
        WineStatus.ready,
      );
    });
  });

  group('window boundaries (BR3.2)', () {
    final window = windowOf(2024, 2031, 2046);

    test('before 1 January of startYear -> waiting', () {
      expect(statusOf(window, DateTime(2023, 12, 31)), WineStatus.waiting);
    });

    test('from 1 January of startYear -> ready', () {
      expect(statusOf(window, DateTime(2024, 1, 1)), WineStatus.ready);
    });

    test('after 31 December of endYear -> pastWindow', () {
      expect(statusOf(window, DateTime(2047, 1, 1)), WineStatus.pastWindow);
    });

    test('last month of the window -> drinkSoon', () {
      expect(statusOf(window, DateTime(2046, 12, 31)), WineStatus.drinkSoon);
      expect(
        statusOf(windowOf(2026, 2026, 2026), DateTime(2026, 12, 1)),
        WineStatus.drinkSoon,
      );
    });
  });

  group('drink-soon notice (BR3.3)', () {
    test('notice is capped at 12 months on long windows', () {
      final window = windowOf(2024, 2031, 2046);
      expect(statusOf(window, DateTime(2046, 1, 1)), WineStatus.drinkSoon);
      expect(statusOf(window, DateTime(2045, 12, 1)), WineStatus.ready);
    });

    test('notice is 25% of the window in between (2 years -> 6 months)', () {
      final window = windowOf(2025, 2025, 2026);
      expect(statusOf(window, DateTime(2026, 7, 1)), WineStatus.drinkSoon);
      expect(statusOf(window, DateTime(2026, 6, 30)), WineStatus.ready);
    });

    test('the time of day is ignored', () {
      final window = windowOf(2026, 2026, 2026);
      expect(
        statusOf(window, DateTime(2026, 9, 30, 23, 59, 59)),
        statusOf(window, DateTime(2026, 9, 1)),
      );
    });
  });

  group('incoherent windows (NFR4.2)', () {
    Matcher invalidWindow() => throwsA(
      isA<EstimationArgumentError>().having(
        (e) => e.code,
        'code',
        EstimationErrorCode.invalidWindow,
      ),
    );

    test('start after peak', () {
      expect(
        () => statusOf(windowOf(2030, 2025, 2040), DateTime(2026, 1, 1)),
        invalidWindow(),
      );
    });

    test('peak after end', () {
      expect(
        () => statusOf(windowOf(2020, 2045, 2040), DateTime(2026, 1, 1)),
        invalidWindow(),
      );
    });
  });
}
