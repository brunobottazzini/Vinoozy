import 'firestore_values.dart';

/// Field names of the `windowOverride` map of a wine (label-autofill-windows
/// ENT-001).
abstract final class OverrideFields {
  static const String endYear = 'endYear';
  static const String setAt = 'setAt';

  /// wine-style-profiles BR6.8: the month (1-12) of the end, for a window
  /// in months or without an end.
  static const String endMonth = 'endMonth';
}

/// The owner's correction of "Recommended until" (FR5, BR4.4, BR4.6): the
/// end year of the window, which wins over the estimate and the drink
/// feedback until "Restore the estimate" removes it.
class WindowOverride {
  const WindowOverride({required this.endYear, this.setAt, this.endMonth});

  /// Reads a stored `windowOverride`, or `null` when it is not a map with an
  /// integer `endYear` (NFR1.1: wines without it behave as before).
  static WindowOverride? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final endYear = FirestoreValues.integer(raw[OverrideFields.endYear]);
    if (endYear == null) return null;
    final endMonth = FirestoreValues.integer(raw[OverrideFields.endMonth]);
    return WindowOverride(
      endYear: endYear,
      endMonth: endMonth != null && endMonth >= 1 && endMonth <= 12
          ? endMonth
          : null,
      setAt: FirestoreValues.dateTime(raw[OverrideFields.setAt]),
    );
  }

  /// The end year chosen.
  final int endYear;

  /// The end month chosen (BR6.8); `null` for a correction in years, read
  /// as December on a window in months (BR7.5).
  final int? endMonth;

  /// When it was set; `null` while the server time of a pending write is
  /// not resolved.
  final DateTime? setAt;

  @override
  bool operator ==(Object other) =>
      other is WindowOverride &&
      other.endYear == endYear &&
      other.endMonth == endMonth &&
      other.setAt == setAt;

  @override
  int get hashCode => Object.hash(endYear, endMonth, setAt);

  @override
  String toString() =>
      'WindowOverride($endYear${endMonth == null ? '' : '-$endMonth'})';
}
