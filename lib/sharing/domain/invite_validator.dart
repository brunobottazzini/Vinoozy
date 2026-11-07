import 'membership.dart';
import 'sharing_error.dart';

/// Checks of an invitation before it is written (BR1.2, NFR4.9). The same
/// checks run again in `firestore.rules`: this layer gives the message, the
/// rules give the guarantee (BR1.7).
abstract final class InviteValidator {
  /// At most 2 invitations `invited` + `active` per cellar (FR8.1, limit
  /// lowered from 5 to 2 on 2026-11-06).
  static const int maxInvitees = 2;

  /// Longest email accepted, as in the rules (NFR4.9).
  static const int maxEmailLength = 254;

  // Same pattern as the rules: `x@y.z`, no `@`, `/` or space in the parts.
  static final RegExp _format = RegExp(r'^[^@/\s]+@[^@/\s]+\.[^@/\s]+$');

  /// The member key of [raw]: trimmed and in lower case (C3).
  static String normalizeEmail(String raw) => raw.trim().toLowerCase();

  /// Whether [email] (already normalized) can be stored as `inviteeEmail`
  /// and used as a document id: at most 254 characters, `x@y.z`, no `/`.
  static bool isValidEmail(String email) =>
      email.isNotEmpty &&
      email.length <= maxEmailLength &&
      !email.contains('/') &&
      _format.hasMatch(email);

  /// The first broken rule of an invitation of [rawEmail] by the owner whose
  /// address is [ownerEmail], or `null` when it can be written.
  ///
  /// [members] are the invitations of the cellar as last seen and
  /// [memberSlots] its counter; the larger of the counter and the open
  /// invitations decides the limit, so a stale counter never lets a third
  /// invitation through. A `revoked` invitation of the same address can be
  /// renewed and counts again.
  static SharingError? validate({
    required String rawEmail,
    required String ownerEmail,
    required Iterable<Membership> members,
    required int memberSlots,
  }) {
    final email = normalizeEmail(rawEmail);
    if (!isValidEmail(email)) return SharingError.invalidEmail;
    if (email == normalizeEmail(ownerEmail)) return SharingError.selfInvite;
    var open = 0;
    for (final member in members) {
      if (!member.isOpen) continue;
      if (member.memberKey == email) return SharingError.alreadyInvited;
      open++;
    }
    final used = memberSlots > open ? memberSlots : open;
    if (used >= maxInvitees) return SharingError.limitReached;
    return null;
  }

  /// Places in use, shown as "x/2" (frontend-components.md, InviteForm).
  static int usedPlaces(Iterable<Membership> members, int memberSlots) {
    final open = members.where((member) => member.isOpen).length;
    final used = memberSlots > open ? memberSlots : open;
    return used > maxInvitees ? maxInvitees : used;
  }
}
