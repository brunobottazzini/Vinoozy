// DrinkingRecord (u4-cellar BR1.10, BR1.11, BR1.16; C3 additions condition
// and updatedAt): lenient mapper, validation, order and date format.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';

void main() {
  Map<String, Object?> document() => {
    DrinkingRecordFields.wineId: 'w1',
    DrinkingRecordFields.wineName: 'Barolo',
    DrinkingRecordFields.vintage: 2016,
    DrinkingRecordFields.drankOn: '2026-11-06',
    DrinkingRecordFields.rating: 4,
    DrinkingRecordFields.notes: 'Ottimo',
    DrinkingRecordFields.condition: 'justRight',
    DrinkingRecordFields.recordedBy: 'user-a',
    DrinkingRecordFields.createdAt: DateTime.utc(2026, 11, 6, 20),
    DrinkingRecordFields.updatedAt: DateTime.utc(2026, 11, 7),
  };

  group('BR1.16 fromMap', () {
    test('reads every field', () {
      final record = DrinkingRecord.fromMap('r1', document())!;

      expect(record.wineId, 'w1');
      expect(record.wineName, 'Barolo');
      expect(record.vintage, 2016);
      expect(record.drankOn, DateTime(2026, 11, 6));
      expect(record.rating, 4);
      expect(record.notes, 'Ottimo');
      expect(record.condition, DrinkCondition.justRight);
      expect(record.recordedBy, 'user-a');
      expect(record.createdAt, DateTime.utc(2026, 11, 6, 20));
      expect(record.updatedAt, DateTime.utc(2026, 11, 7));
    });

    test('no wineId or no valid date: not a record', () {
      expect(
        DrinkingRecord.fromMap('r1', document()..remove('wineId')),
        isNull,
      );
      expect(
        DrinkingRecord.fromMap('r1', document()..['drankOn'] = '6/11/2026'),
        isNull,
      );
      expect(
        DrinkingRecord.fromMap('r1', document()..['drankOn'] = '2026-02-30'),
        isNull,
      );
    });

    test('wrong types and out-of-range values are null, never thrown', () {
      final record = DrinkingRecord.fromMap('r1', {
        ...document(),
        'rating': 9,
        'notes': 12,
        'condition': 'corked',
        'vintage': 'old',
        'wineName': null,
        'recordedBy': 3,
      })!;

      expect(record.rating, isNull);
      expect(record.notes, isNull);
      expect(record.condition, isNull);
      expect(record.vintage, isNull);
      expect(record.wineName, '');
      expect(record.recordedBy, '');
    });
  });

  group('BR1.11 validation', () {
    final today = DateTime(2026, 11, 6, 15);

    Set<RecordFieldError> check({
      int? rating = 3,
      String? notes = 'ok',
      DateTime? drankOn,
      int? vintage = 2016,
    }) => RecordRules.validate(
      rating: rating,
      notes: notes,
      drankOn: drankOn ?? DateTime(2026, 11, 6),
      vintage: vintage,
      today: today,
    );

    test('valid values have no error; rating and notes are optional', () {
      expect(check(), isEmpty);
      expect(check(rating: null, notes: null), isEmpty);
      expect(check(notes: 'n' * 1000), isEmpty);
    });

    test('rating outside 1-5 and notes over 1000 characters', () {
      expect(check(rating: 0), {RecordFieldError.ratingOutOfRange});
      expect(check(rating: 6), {RecordFieldError.ratingOutOfRange});
      expect(check(notes: 'n' * 1001), {RecordFieldError.notesTooLong});
    });

    test('a future date or a date before the vintage', () {
      expect(check(drankOn: DateTime(2026, 11, 7)), {
        RecordFieldError.dateInFuture,
      });
      expect(check(drankOn: DateTime(2015, 12, 31)), {
        RecordFieldError.dateBeforeVintage,
      });
      expect(check(drankOn: DateTime(2015, 12, 31), vintage: null), isEmpty);
    });
  });

  test('BR1.16 most recent first by drankOn, then createdAt', () {
    DrinkingRecord record(String id, DateTime day, [DateTime? created]) =>
        DrinkingRecord(
          id: id,
          wineId: 'w1',
          wineName: 'Barolo',
          drankOn: day,
          recordedBy: 'user-a',
          createdAt: created,
        );
    final records = [
      record('a', DateTime(2026, 1, 1), DateTime.utc(2026, 1, 1, 10)),
      record('b', DateTime(2026, 2, 1), DateTime.utc(2026, 2, 1)),
      record('c', DateTime(2026, 1, 1), DateTime.utc(2026, 1, 1, 12)),
      record('d', DateTime(2026, 1, 1)),
    ]..sort(DrinkingRecord.compareRecentFirst);

    expect(records.map((r) => r.id), ['b', 'd', 'c', 'a']);
  });

  test('drankOn is stored as YYYY-MM-DD', () {
    expect(formatDrankOn(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
    expect(parseDrankOn('2026-03-07'), DateTime(2026, 3, 7));
    expect(parseDrankOn(20260307), isNull);
    expect(DrinkCondition.tryParse('pastPeak'), DrinkCondition.pastPeak);
    expect(DrinkCondition.tryParse(null), isNull);
  });
}
