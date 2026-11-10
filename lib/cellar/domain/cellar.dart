import 'firestore_values.dart';

/// Field names of `cellars/{cellarId}` (C3).
abstract final class CellarFields {
  static const String ownerId = 'ownerId';
  static const String name = 'name';
  static const String createdAt = 'createdAt';
  static const String schemaVersion = 'schemaVersion';

  /// Open invitations (`invited` + `active`), 0 when missing (u7-sharing).
  static const String memberSlots = 'memberSlots';

  /// Member key changed in the same batch as [memberSlots] (u7-sharing).
  static const String memberOpKey = 'memberOpKey';

  /// Wines with `quantity > 0` of the cellar (freemium-plus FR2.2, D1).
  /// Absent until the first write of an app that keeps it.
  static const String activeWineCount = 'activeWineCount';

  /// Wine id changed in the same batch as [activeWineCount] (D1).
  static const String activeOpWineId = 'activeOpWineId';

  /// Active-wine limit frozen by the admin migration (FR2.3); never written
  /// by the client.
  static const String legacyActiveWineLimit = 'legacyActiveWineLimit';
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
    this.memberSlots = 0,
    this.memberOpKey,
    this.activeWineCount,
    this.legacyActiveWineLimit,
  });

  /// Never throws: missing or mistyped fields get safe defaults; a cellar
  /// written before u7-sharing has no `memberSlots` and counts 0.
  factory Cellar.fromMap(String id, Map<String, Object?> data) => Cellar(
    id: id,
    ownerId: FirestoreValues.string(data[CellarFields.ownerId]) ?? '',
    name: FirestoreValues.string(data[CellarFields.name]) ?? '',
    createdAt: FirestoreValues.dateTime(data[CellarFields.createdAt]),
    schemaVersion:
        FirestoreValues.integer(data[CellarFields.schemaVersion]) ??
        currentSchemaVersion,
    memberSlots: _nonNegative(
      FirestoreValues.integer(data[CellarFields.memberSlots]),
    ),
    memberOpKey: FirestoreValues.string(data[CellarFields.memberOpKey]),
    activeWineCount: FirestoreValues.integer(
      data[CellarFields.activeWineCount],
    ),
    legacyActiveWineLimit: _positive(
      FirestoreValues.integer(data[CellarFields.legacyActiveWineLimit]),
    ),
  );

  static int? _positive(int? value) =>
      value == null || value < 1 ? null : value;

  static int _nonNegative(int? value) => value == null || value < 0 ? 0 : value;

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

  /// Open invitations of the cellar (u7-sharing BR1.2): 0 when missing.
  final int memberSlots;

  /// Key of the invitation changed with the last counter update.
  final String? memberOpKey;

  /// Active wines as kept by the rules-checked counter (FR2.2); null before
  /// the first counted write. It may be negative before the admin migration
  /// recounts it (FR2.3), like a quantity after concurrent decrements.
  final int? activeWineCount;

  /// Limit frozen by the migration (FR2.3); null when the cellar was never
  /// migrated, so the free limit of the policy applies.
  final int? legacyActiveWineLimit;
}
