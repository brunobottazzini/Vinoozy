import 'firestore_values.dart';

/// Field names of the `windowOverride` map of a wine (label-autofill-windows
/// ENT-001).
abstract final class OverrideFields {
  static const String endYear = 'endYear';
  static const String setAt = 'setAt';
}

/// The owner's correction of "Recommended until" (FR5, BR4.4, BR4.6): the
/// end year of the window, which wins over the estimate and the drink
/// feedback until "Restore the estimate" removes it.
class WindowOverride {
  const WindowOverride({required this.endYear, this.setAt});

  /// Reads a stored `windowOverride`, or `null` when it is not a map with an
  /// integer `endYear` (NFR1.1: wines without it behave as before).
  static WindowOverride? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final endYear = FirestoreValues.integer(raw[OverrideFields.endYear]);
    if (endYear == null) return null;
    return WindowOverride(
      endYear: endYear,
      setAt: FirestoreValues.dateTime(raw[OverrideFields.setAt]),
    );
  }

  /// The end year chosen.
  final int endYear;

  /// When it was set; `null` while the server time of a pending write is
  /// not resolved.
  final DateTime? setAt;

  @override
  bool operator ==(Object other) =>
      other is WindowOverride &&
      other.endYear == endYear &&
      other.setAt == setAt;

  @override
  int get hashCode => Object.hash(endYear, setAt);

  @override
  String toString() => 'WindowOverride($endYear)';
}
