import '../../cellar/domain/firestore_values.dart';

/// Field names of `entitlements/{uid}` (freemium-plus FR1.1). The document is
/// written only by the backend (verifyPurchase, RTDN, reconciliation) or by
/// the owner's admin script; the client may only read its own (NFR1).
abstract final class EntitlementFields {
  static const String plan = 'plan';
  static const String source = 'source';
  static const String status = 'status';
  static const String expiresAt = 'expiresAt';
  static const String reason = 'reason';
  static const String startedAt = 'startedAt';
  static const String updatedAt = 'updatedAt';
}

/// The only paid plan stored in `plan` (FR1.1).
const String plusPlanId = 'plus';

/// Where a Plus entitlement comes from (FR1.1).
enum EntitlementSource {
  playPurchase('play_purchase'),
  manualGrant('manual_grant');

  const EntitlementSource(this.wireValue);

  /// Value stored in Firestore.
  final String wireValue;

  /// Null for a missing or unknown value (a newer backend may add one).
  static EntitlementSource? fromWire(Object? value) =>
      _byWire(values, value, (source) => source.wireValue);
}

/// Lifecycle state of an entitlement (FR1.1, Play subscription states).
enum EntitlementStatus {
  active('active'),
  grace('grace'),
  onHold('on_hold'),
  paused('paused'),
  expired('expired'),
  revoked('revoked');

  const EntitlementStatus(this.wireValue);

  final String wireValue;

  /// Only these states can give Plus, and only before `expiresAt` (FR1.2).
  bool get canGrantPlus =>
      this == EntitlementStatus.active || this == EntitlementStatus.grace;

  static EntitlementStatus? fromWire(Object? value) =>
      _byWire(values, value, (status) => status.wireValue);
}

/// Why the owner granted Plus by hand (FR4.1).
enum EntitlementReason {
  gift('gift'),
  ownerTest('owner_test');

  const EntitlementReason(this.wireValue);

  final String wireValue;

  static EntitlementReason? fromWire(Object? value) =>
      _byWire(values, value, (reason) => reason.wireValue);
}

T? _byWire<T>(List<T> values, Object? value, String Function(T) wireOf) {
  if (value is! String) return null;
  for (final candidate in values) {
    if (wireOf(candidate) == value) return candidate;
  }
  return null;
}

/// The Plus entitlement of one user, as read from `entitlements/{uid}`.
///
/// Read leniently: the document is external input and a field can be
/// missing or of another type. An unknown `plan`, `source` or `status` never
/// throws; it simply never gives Plus ([isPlusValidAt] is false), so an
/// uncertain state falls back to the free plan without hiding data (NFR4).
class Entitlement {
  const Entitlement({
    required this.uid,
    this.plan,
    this.source,
    this.status,
    this.expiresAt,
    this.reason,
    this.startedAt,
    this.updatedAt,
  });

  /// [data] has its Firestore `Timestamp` values already converted to
  /// [DateTime] by the repository, like every other domain model.
  factory Entitlement.fromMap(String uid, Map<String, Object?> data) =>
      Entitlement(
        uid: uid,
        plan: FirestoreValues.string(data[EntitlementFields.plan]),
        source: EntitlementSource.fromWire(data[EntitlementFields.source]),
        status: EntitlementStatus.fromWire(data[EntitlementFields.status]),
        expiresAt: FirestoreValues.dateTime(data[EntitlementFields.expiresAt]),
        reason: EntitlementReason.fromWire(data[EntitlementFields.reason]),
        startedAt: FirestoreValues.dateTime(data[EntitlementFields.startedAt]),
        updatedAt: FirestoreValues.dateTime(data[EntitlementFields.updatedAt]),
      );

  final String uid;
  final String? plan;
  final EntitlementSource? source;
  final EntitlementStatus? status;

  /// Absent only for a `manual_grant` without expiry (FR1.1).
  final DateTime? expiresAt;
  final EntitlementReason? reason;
  final DateTime? startedAt;
  final DateTime? updatedAt;

  /// Whether this entitlement gives Plus at the (estimated) server time
  /// [serverNow] (FR1.2): plan `plus`, status `active` or `grace`, and
  /// `expiresAt` after [serverNow], or no `expiresAt` for a `manual_grant`.
  /// The Firestore rules apply the same test (firestore.rules,
  /// `ownerHasPlus`).
  bool isPlusValidAt(DateTime serverNow) {
    final currentStatus = status;
    if (plan != plusPlanId || currentStatus == null) return false;
    if (!currentStatus.canGrantPlus) return false;
    final expiry = expiresAt;
    if (expiry == null) return source == EntitlementSource.manualGrant;
    return expiry.isAfter(serverNow);
  }

  /// A Plus given by the owner rather than bought (FR1.3 "Plus in regalo").
  bool get isManualGrant => source == EntitlementSource.manualGrant;
}
