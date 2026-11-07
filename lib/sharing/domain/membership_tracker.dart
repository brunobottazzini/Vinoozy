import 'membership.dart';

/// Compares successive lists of the person's own invitations and tells which
/// accesses were lost (security-design.md §4, "Accesso perso", source 1).
///
/// An access is lost when an invitation that was `active` becomes `revoked`
/// by the owner, or disappears. Leaving (`closedBy: invitee`) is not a loss:
/// the person chose it, so no notice is shown (BR1.10). The first list only
/// sets the baseline.
class MembershipTracker {
  Map<String, Membership>? _active;

  /// The invitations of [memberships] whose access was lost since the
  /// previous call.
  List<Membership> update(Iterable<Membership> memberships) {
    final byCellar = {
      for (final membership in memberships) membership.cellarId: membership,
    };
    final previous = _active;
    _active = {
      for (final membership in byCellar.values)
        if (membership.grantsAccess) membership.cellarId: membership,
    };
    if (previous == null) return const [];
    final lost = <Membership>[];
    for (final MapEntry(key: cellarId, value: before) in previous.entries) {
      final now = byCellar[cellarId];
      if (now == null) {
        lost.add(before);
      } else if (now.status == MemberStatus.revoked &&
          now.closedBy != ClosedBy.invitee) {
        lost.add(now);
      }
    }
    return lost;
  }
}
