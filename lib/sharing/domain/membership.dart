import '../../cellar/domain/firestore_values.dart';

/// Field names of `cellars/{cellarId}/members/{memberKey}` (C3 and the
/// compatible additions of 2026-11-06).
abstract final class MemberFields {
  static const String inviteeEmail = 'inviteeEmail';
  static const String inviteeUserId = 'inviteeUserId';
  static const String permission = 'permission';
  static const String status = 'status';
  static const String invitedAt = 'invitedAt';
  static const String ownerId = 'ownerId';
  static const String ownerName = 'ownerName';
  static const String inviteeName = 'inviteeName';
  static const String closedBy = 'closedBy';
  static const String updatedAt = 'updatedAt';
}

/// State of an invitation (C3).
enum MemberStatus {
  invited,
  active,
  revoked;

  /// The stored value, or `null` when it is absent or unknown.
  static MemberStatus? parse(Object? raw) => _parse(values, raw);
}

/// What an invited person may do (C3, BR1.6).
enum MemberPermission {
  read,
  edit;

  static MemberPermission? parse(Object? raw) => _parse(values, raw);
}

/// Who closed an access (`revoked`): the owner or the invited person.
enum ClosedBy {
  owner,
  invitee;

  static ClosedBy? parse(Object? raw) => _parse(values, raw);
}

T? _parse<T extends Enum>(List<T> values, Object? raw) {
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return null;
}

/// Longest name shown to the other person, as in the rules (NFR4.9).
const int maxDisplayNameLength = 100;

/// [name] trimmed, or the part of [email] before the `@` when the name is
/// missing or blank, cut to [maxDisplayNameLength] (security-design.md §1,
/// "Nomi di ripiego"). Never empty, so an activation never fails for a
/// missing Google name.
///
/// The cut counts UTF-16 code units and never splits a surrogate pair, so
/// the result is within the limit however the rules count characters.
String displayNameOrFallback(String? name, String email) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isNotEmpty) return _truncate(trimmed);
  final at = email.indexOf('@');
  final local = (at > 0 ? email.substring(0, at) : email).trim();
  if (local.isNotEmpty) return _truncate(local);
  return '?';
}

String _truncate(String value) {
  if (value.length <= maxDisplayNameLength) return value;
  final buffer = StringBuffer();
  var units = 0;
  for (final rune in value.runes) {
    final size = rune > 0xFFFF ? 2 : 1;
    if (units + size > maxDisplayNameLength) break;
    buffer.writeCharCode(rune);
    units += size;
  }
  return buffer.toString();
}

/// One invitation of a cellar (C3 `members`), read from Firestore.
///
/// [Membership.fromMap] never throws: a document written by an older or
/// newer app, or damaged, maps to safe values (an unknown status is
/// `revoked`, which grants nothing; an unknown permission is `read`).
class Membership {
  const Membership({
    required this.cellarId,
    required this.memberKey,
    required this.inviteeEmail,
    required this.permission,
    required this.status,
    required this.ownerId,
    required this.ownerName,
    this.inviteeUserId,
    this.inviteeName,
    this.closedBy,
    this.invitedAt,
    this.updatedAt,
  });

  factory Membership.fromMap(
    String cellarId,
    String memberKey,
    Map<String, Object?> data,
  ) => Membership(
    cellarId: cellarId,
    memberKey: memberKey,
    inviteeEmail:
        FirestoreValues.string(data[MemberFields.inviteeEmail]) ?? memberKey,
    permission:
        MemberPermission.parse(data[MemberFields.permission]) ??
        MemberPermission.read,
    status:
        MemberStatus.parse(data[MemberFields.status]) ?? MemberStatus.revoked,
    ownerId: FirestoreValues.string(data[MemberFields.ownerId]) ?? '',
    ownerName: FirestoreValues.string(data[MemberFields.ownerName]) ?? '',
    inviteeUserId: FirestoreValues.string(data[MemberFields.inviteeUserId]),
    inviteeName: FirestoreValues.string(data[MemberFields.inviteeName]),
    closedBy: ClosedBy.parse(data[MemberFields.closedBy]),
    invitedAt: FirestoreValues.dateTime(data[MemberFields.invitedAt]),
    updatedAt: FirestoreValues.dateTime(data[MemberFields.updatedAt]),
  );

  final String cellarId;

  /// The document id: the invitee email in lower case (C3).
  final String memberKey;
  final String inviteeEmail;
  final MemberPermission permission;
  final MemberStatus status;
  final String ownerId;
  final String ownerName;
  final String? inviteeUserId;
  final String? inviteeName;
  final ClosedBy? closedBy;
  final DateTime? invitedAt;
  final DateTime? updatedAt;

  /// `invited` or `active`: it takes one of the 2 places (BR1.2).
  bool get isOpen =>
      status == MemberStatus.invited || status == MemberStatus.active;

  /// Only an `active` invitation gives access (BR1.4).
  bool get grantsAccess => status == MemberStatus.active;

  /// Name shown to the owner: the invitee name, or the email (BR1.12).
  String get label {
    final name = inviteeName?.trim() ?? '';
    return name.isEmpty ? inviteeEmail : name;
  }

  /// Name of the owner shown to the invitee, never empty.
  String get ownerLabel => ownerName.trim().isEmpty ? '?' : ownerName.trim();
}

/// What the current user may do in a cellar (BR1.6).
enum CellarRole {
  /// The personal cellar: everything.
  owner,

  /// "Can edit": add and change wines, quantities and drinks.
  edit,

  /// "Read only": sees everything, changes nothing.
  read;

  static CellarRole fromPermission(MemberPermission permission) =>
      switch (permission) {
        MemberPermission.edit => CellarRole.edit,
        MemberPermission.read => CellarRole.read,
      };
}

/// A cellar the user can open (C4 `listAccessibleCellars`).
class AccessibleCellar {
  const AccessibleCellar({
    required this.cellarId,
    required this.ownerId,
    required this.ownerName,
    required this.role,
  });

  /// The personal cellar of [uid], whose id is the uid (U1 BR1.3).
  factory AccessibleCellar.personal({
    required String uid,
    required String ownerName,
  }) => AccessibleCellar(
    cellarId: uid,
    ownerId: uid,
    ownerName: ownerName,
    role: CellarRole.owner,
  );

  /// A cellar shared through an `active` invitation.
  factory AccessibleCellar.shared(Membership membership) => AccessibleCellar(
    cellarId: membership.cellarId,
    ownerId: membership.ownerId,
    ownerName: membership.ownerLabel,
    role: CellarRole.fromPermission(membership.permission),
  );

  final String cellarId;
  final String ownerId;
  final String ownerName;
  final CellarRole role;

  bool get isPersonal => role == CellarRole.owner;

  /// Add, change wines and quantities, record drinks (BR1.6).
  bool get canEdit => role != CellarRole.read;

  /// Delete wines, rename, invite, revoke: the owner only (BR1.1, BR1.6).
  bool get isOwner => role == CellarRole.owner;

  @override
  bool operator ==(Object other) =>
      other is AccessibleCellar &&
      other.cellarId == cellarId &&
      other.ownerId == ownerId &&
      other.ownerName == ownerName &&
      other.role == role;

  @override
  int get hashCode => Object.hash(cellarId, ownerId, ownerName, role);
}
