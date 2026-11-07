import 'firestore_values.dart';

/// Field names of `cellars/{cellarId}/drinkingRecords/{recordId}` (C3, with
/// the u4-cellar additions `condition` and `updatedAt`).
abstract final class DrinkingRecordFields {
  static const String wineId = 'wineId';
  static const String wineName = 'wineName';
  static const String vintage = 'vintage';
  static const String drankOn = 'drankOn';
  static const String rating = 'rating';
  static const String notes = 'notes';
  static const String condition = 'condition';
  static const String recordedBy = 'recordedBy';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
}

/// Answer to "How was it?" (BR1.11, BR1.12).
enum DrinkCondition {
  tooYoung,
  justRight,
  pastPeak;

  /// Reads a stored value; anything else is "no answer".
  static DrinkCondition? tryParse(Object? raw) {
    if (raw is! String) return null;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

/// Validation errors of a drinking record (BR1.11).
enum RecordFieldError {
  ratingOutOfRange,
  notesTooLong,
  dateInFuture,
  dateBeforeVintage,
}

/// Limits of a drinking record (BR1.11, security-design.md §1).
abstract final class RecordRules {
  static const int minRating = 1;
  static const int maxRating = 5;
  static const int maxNotesLength = 1000;

  /// Errors of rating, notes and date; empty when the values are valid.
  /// Notes count Unicode code points, like the length check of the rules.
  static Set<RecordFieldError> validate({
    required int? rating,
    required String? notes,
    required DateTime drankOn,
    required int? vintage,
    required DateTime today,
  }) {
    final errors = <RecordFieldError>{};
    if (rating != null && (rating < minRating || rating > maxRating)) {
      errors.add(RecordFieldError.ratingOutOfRange);
    }
    if (notes != null && notes.runes.length > maxNotesLength) {
      errors.add(RecordFieldError.notesTooLong);
    }
    final day = dateOnly(drankOn);
    if (day.isAfter(dateOnly(today))) errors.add(RecordFieldError.dateInFuture);
    if (vintage != null && day.year < vintage) {
      errors.add(RecordFieldError.dateBeforeVintage);
    }
    return errors;
  }
}

/// Local calendar date of [time], at 00:00.
DateTime dateOnly(DateTime time) => DateTime(time.year, time.month, time.day);

/// `YYYY-MM-DD`, the stored form of `drankOn` (C3, u7-sharing addition).
String formatDrankOn(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${date.year.toString().padLeft(4, '0')}-${two(date.month)}-'
      '${two(date.day)}';
}

/// Parses `YYYY-MM-DD`; `null` for any other text or an impossible date.
DateTime? parseDrankOn(Object? raw) {
  if (raw is! String) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw);
  if (match == null) return null;
  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

/// A drink of a bottle (US6.1, US6.2) as read from Firestore.
class DrinkingRecord {
  const DrinkingRecord({
    required this.id,
    required this.wineId,
    required this.wineName,
    required this.drankOn,
    required this.recordedBy,
    this.vintage,
    this.rating,
    this.notes,
    this.condition,
    this.createdAt,
    this.updatedAt,
  });

  /// Builds a record from document data, or `null` when the document has no
  /// usable `wineId` or `drankOn`. Never throws: other malformed fields
  /// become `null` (a rating outside 1-5 included).
  static DrinkingRecord? fromMap(String id, Map<String, Object?> data) {
    final wineId = FirestoreValues.string(data[DrinkingRecordFields.wineId]);
    final drankOn = parseDrankOn(data[DrinkingRecordFields.drankOn]);
    if (wineId == null || wineId.isEmpty || drankOn == null) return null;
    final rating = FirestoreValues.integer(data[DrinkingRecordFields.rating]);
    return DrinkingRecord(
      id: id,
      wineId: wineId,
      wineName:
          FirestoreValues.string(data[DrinkingRecordFields.wineName]) ?? '',
      drankOn: drankOn,
      recordedBy:
          FirestoreValues.string(data[DrinkingRecordFields.recordedBy]) ?? '',
      vintage: FirestoreValues.integer(data[DrinkingRecordFields.vintage]),
      rating:
          rating != null &&
              rating >= RecordRules.minRating &&
              rating <= RecordRules.maxRating
          ? rating
          : null,
      notes: FirestoreValues.string(data[DrinkingRecordFields.notes]),
      condition: DrinkCondition.tryParse(data[DrinkingRecordFields.condition]),
      createdAt: FirestoreValues.dateTime(data[DrinkingRecordFields.createdAt]),
      updatedAt: FirestoreValues.dateTime(data[DrinkingRecordFields.updatedAt]),
    );
  }

  final String id;
  final String wineId;

  /// Name and vintage at the time of the drink, immutable (functional-spec
  /// "Nome nello Storico").
  final String wineName;
  final int? vintage;

  /// Local date of the drink.
  final DateTime drankOn;
  final String recordedBy;
  final int? rating;
  final String? notes;
  final DrinkCondition? condition;

  /// Null while the server timestamp of a pending write is not resolved.
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Most recent first: by `drankOn`, then `createdAt`, both descending; a
  /// pending `createdAt` counts as the newest; then by id (BR1.12, BR1.16).
  static int compareRecentFirst(DrinkingRecord a, DrinkingRecord b) {
    final byDay = b.drankOn.compareTo(a.drankOn);
    if (byDay != 0) return byDay;
    final aTime = a.createdAt;
    final bTime = b.createdAt;
    if (aTime != null && bTime != null) {
      final byTime = bTime.compareTo(aTime);
      if (byTime != 0) return byTime;
    } else if (aTime != bTime) {
      return aTime == null ? -1 : 1;
    }
    return b.id.compareTo(a.id);
  }
}
