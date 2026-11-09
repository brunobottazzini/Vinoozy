// WindowAdjuster (u4-cellar BR1.12; NFR2.4): each case of the feedback on
// the base estimate, the confidence one level lower, the record that counts.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/domain/window_adjuster.dart';

import '../cellar_harness.dart';

void main() {
  // Base window 2020 / 2024 / 2030, medium confidence.
  final base = windowOf(2020, 2024, 2030);

  WindowAdjustment feedback(DrinkCondition kind, int year) =>
      WindowAdjustment(kind: kind, year: year, recordId: 'r1');

  DrinkingWindow apply(DrinkCondition kind, int year) =>
      WindowAdjuster.effective(base, feedback(kind, year));

  group('BR1.12 effective window', () {
    test('no feedback: the base window', () {
      expect(WindowAdjuster.effective(base, null), same(base));
    });

    test('justRight after the end: the end becomes Y + 1, the peak stays', () {
      final result = apply(DrinkCondition.justRight, 2032);

      expect(
        [result.startYear, result.peakYear, result.endYear],
        [2020, 2024, 2033],
      );
      expect(result.confidence, Confidence.low);
    });

    test('justRight inside the window changes nothing', () {
      expect(apply(DrinkCondition.justRight, 2030), same(base));
      expect(apply(DrinkCondition.justRight, 2018), same(base));
    });

    test('pastPeak inside the window: the end becomes Y, peak <= end', () {
      final result = apply(DrinkCondition.pastPeak, 2022);

      expect(
        [result.startYear, result.peakYear, result.endYear],
        [2020, 2022, 2022],
      );
      final later = apply(DrinkCondition.pastPeak, 2027);
      expect(
        [later.startYear, later.peakYear, later.endYear],
        [2020, 2024, 2027],
      );
    });

    test('pastPeak at the start year: the end becomes the start', () {
      final result = apply(DrinkCondition.pastPeak, 2020);

      expect(
        [result.startYear, result.peakYear, result.endYear],
        [2020, 2020, 2020],
      );
    });

    test('pastPeak before the start: the whole window moves back', () {
      final result = apply(DrinkCondition.pastPeak, 2018);

      // end − Y = 12 years back; the length stays 10 years.
      expect(
        [result.startYear, result.peakYear, result.endYear],
        [2008, 2012, 2018],
      );
    });

    test('pastPeak at or after the end changes nothing', () {
      expect(apply(DrinkCondition.pastPeak, 2030), same(base));
      expect(apply(DrinkCondition.pastPeak, 2031), same(base));
    });

    test('tooYoung from the start on: the window moves forward', () {
      final result = apply(DrinkCondition.tooYoung, 2023);

      // Y + 1 − start = 4 years forward.
      expect(
        [result.startYear, result.peakYear, result.endYear],
        [2024, 2028, 2034],
      );
      final atStart = apply(DrinkCondition.tooYoung, 2020);
      expect(atStart.startYear, 2021);
    });

    test('tooYoung before the start changes nothing', () {
      expect(apply(DrinkCondition.tooYoung, 2019), same(base));
    });

    test('a result outside 1900-2200 keeps the base window', () {
      final old = windowOf(1905, 1910, 1990);
      final adjusted = WindowAdjuster.effective(
        old,
        feedback(DrinkCondition.pastPeak, 1901),
      );

      expect(adjusted, same(old));
    });

    test('source, basis and qualifier come from the base window', () {
      final catalog = windowOf(
        2020,
        2024,
        2030,
        confidence: Confidence.high,
        source: WindowSource.catalog,
        basis: EstimationBasis.catalog,
      );
      final result = WindowAdjuster.effective(
        catalog,
        feedback(DrinkCondition.tooYoung, 2021),
      );

      expect(result.source, WindowSource.catalog);
      expect(result.basis, EstimationBasis.catalog);
      expect(result.confidence, Confidence.medium);
    });
  });

  test('BR1.12 confidence goes one level lower, at least low', () {
    expect(WindowAdjuster.lowered(Confidence.high), Confidence.medium);
    expect(WindowAdjuster.lowered(Confidence.medium), Confidence.low);
    expect(WindowAdjuster.lowered(Confidence.low), Confidence.low);
  });

  group('BR1.12 the feedback that counts', () {
    test('the most recent record with a condition, by drankOn', () {
      final picked = WindowAdjuster.pick([
        drinkRecord(
          'old',
          drankOn: DateTime(2025, 1, 1),
          condition: DrinkCondition.tooYoung,
        ),
        drinkRecord('none', drankOn: DateTime(2026, 6, 1)),
        drinkRecord(
          'new',
          drankOn: DateTime(2026, 1, 1),
          condition: DrinkCondition.pastPeak,
        ),
      ]);

      // wine-style-profiles BR6.9: the month of the drink is kept too.
      expect(
        picked,
        WindowAdjustment(
          kind: DrinkCondition.pastPeak,
          year: 2026,
          month: 1,
          recordId: 'new',
        ),
      );
    });

    test('same day: the latest createdAt, a pending one first', () {
      final day = DateTime(2026, 3, 3);
      final records = [
        drinkRecord(
          'early',
          drankOn: day,
          createdAt: DateTime.utc(2026, 3, 3, 8),
          condition: DrinkCondition.justRight,
        ),
        drinkRecord(
          'late',
          drankOn: day,
          createdAt: DateTime.utc(2026, 3, 3, 20),
          condition: DrinkCondition.tooYoung,
        ),
      ];

      expect(WindowAdjuster.pick(records)!.recordId, 'late');
      expect(
        WindowAdjuster.pick([
          ...records,
          drinkRecord(
            'pending',
            drankOn: day,
            condition: DrinkCondition.pastPeak,
          ),
        ])!.recordId,
        'pending',
      );
    });

    test('no record with a condition: no feedback', () {
      expect(WindowAdjuster.pick([drinkRecord('r1')]), isNull);
      expect(WindowAdjuster.pick(const []), isNull);
    });
  });

  group('BR1.9 source label', () {
    test('corrected only when a feedback changed the window', () {
      final changed = apply(DrinkCondition.tooYoung, 2023);

      expect(
        WindowAdjuster.labelOf(
          window: changed,
          base: base,
          adjustment: feedback(DrinkCondition.tooYoung, 2023),
        ),
        EstimateLabel.correctedByDrinks,
      );
      expect(
        WindowAdjuster.labelOf(
          window: base,
          base: base,
          adjustment: feedback(DrinkCondition.justRight, 2025),
        ),
        EstimateLabel.typeEstimate,
      );
    });

    test('otherwise the source of the base window', () {
      final catalog = windowOf(2020, 2024, 2030, source: WindowSource.catalog);

      expect(WindowAdjuster.labelOf(window: catalog), EstimateLabel.catalog);
      expect(WindowAdjuster.labelOf(window: base), EstimateLabel.typeEstimate);
    });
  });

  group('WindowAdjustment map', () {
    test('round trip and malformed maps', () {
      final adjustment = feedback(DrinkCondition.pastPeak, 2026);

      expect(WindowAdjustment.fromMap(adjustment.toMap()), adjustment);
      expect(WindowAdjustment.fromMap('x'), isNull);
      expect(
        WindowAdjustment.fromMap({
          'kind': 'tooOld',
          'year': 2026,
          'recordId': 'r',
        }),
        isNull,
      );
      expect(
        WindowAdjustment.fromMap({
          'kind': 'pastPeak',
          'year': '2026',
          'recordId': 'r',
        }),
        isNull,
      );
      expect(
        WindowAdjustment.fromMap({
          'kind': 'pastPeak',
          'year': 2026,
          'recordId': '',
        }),
        isNull,
      );
    });
  });
}

WindowAdjustment feedbackOf(String id, DrinkCondition kind, int year) =>
    WindowAdjustment(kind: kind, year: year, recordId: id);
