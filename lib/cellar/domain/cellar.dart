import 'firestore_values.dart';

/// Field names of `cellars/{cellarId}` (C3).
abstract final class CellarFields {
  static const String ownerId = 'ownerId';
  static const String name = 'name';
  static const String createdAt = 'createdAt';
  static const String schemaVersion = 'schemaVersion';
}

/// A cellar. In U1 every user has exactly one personal cellar whose id is
/// the user's uid (BR1.3), so several phones never create duplicates.
class Cellar {
  const Cellar({
    required this.id,
    required this.ownerId,
    required this.name,
    this.createdAt,
    this.schemaVersion = currentSchemaVersion,
  });

  factory Cellar.fromMap(String id, Map<String, Object?> data) => Cellar(
    id: id,
    ownerId: FirestoreValues.string(data[CellarFields.ownerId]) ?? '',
    name: FirestoreValues.string(data[CellarFields.name]) ?? '',
    createdAt: FirestoreValues.dateTime(data[CellarFields.createdAt]),
    schemaVersion:
        FirestoreValues.integer(data[CellarFields.schemaVersion]) ??
        currentSchemaVersion,
  );

  /// Maximum cellar name length accepted by the rules (NFR4.3).
  static const int maxNameLength = 60;

  /// Id of the personal cellar of [uid] (BR1.3).
  static String personalCellarId(String uid) => uid;

  /// Fields written when the personal cellar is created, without `createdAt`,
  /// which the repository sets to the server timestamp (rules require
  /// `createdAt == request.time`).
  static Map<String, Object?> createFields({
    required String uid,
    required String name,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > maxNameLength) {
      throw ArgumentError.value(name, 'name', 'must be 1-$maxNameLength chars');
    }
    return {
      CellarFields.ownerId: uid,
      CellarFields.name: trimmed,
      CellarFields.schemaVersion: currentSchemaVersion,
    };
  }

  final String id;
  final String ownerId;
  final String name;
  final DateTime? createdAt;
  final int schemaVersion;
}
