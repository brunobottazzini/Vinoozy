/// Lenient readers for values coming from Firestore documents.
///
/// Documents are external input: a field can be missing, null or of another
/// type (an older or newer app wrote it). Readers never throw; they return
/// null so the caller decides the fallback. Repositories convert Firestore
/// `Timestamp` values to [DateTime] before the domain sees them, so the domain
/// stays free of Firebase types.
abstract final class FirestoreValues {
  static String? string(Object? value) => value is String ? value : null;

  static int? integer(Object? value) => switch (value) {
    final int v => v,
    final double v when v.isFinite && v == v.truncateToDouble() => v.toInt(),
    _ => null,
  };

  static bool? boolean(Object? value) => value is bool ? value : null;

  static DateTime? dateTime(Object? value) => value is DateTime ? value : null;
}

/// Version written in `schemaVersion` of the documents that carry one (C3).
const int currentSchemaVersion = 1;
