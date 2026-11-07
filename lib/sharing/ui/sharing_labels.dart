import '../../l10n/app_localizations.dart';
import '../domain/membership.dart';
import '../domain/sharing_error.dart';
import '../domain/invite_validator.dart';

/// Translated texts of the sharing values: the permission and the status are
/// always read as text, never only as an icon or a color (NFR3.1).
extension SharingLabels on AppLocalizations {
  String permissionLabel(MemberPermission permission) => switch (permission) {
    MemberPermission.read => sharingPermissionRead,
    MemberPermission.edit => sharingPermissionEdit,
  };

  String roleLabel(CellarRole role) => switch (role) {
    CellarRole.owner => sharingRoleOwner,
    CellarRole.edit => sharingPermissionEdit,
    CellarRole.read => sharingPermissionRead,
  };

  /// "invited", "active", "revoked" or "left" (BR1.10, BR1.12).
  String statusLabel(Membership member) => switch (member.status) {
    MemberStatus.invited => sharingStatusInvited,
    MemberStatus.active => sharingStatusActive,
    MemberStatus.revoked =>
      member.closedBy == ClosedBy.invitee
          ? sharingStatusLeft
          : sharingStatusRevoked,
  };

  /// The name of a cellar in the switcher (BR1.5).
  String cellarLabel(AccessibleCellar cellar) =>
      cellar.isPersonal ? sharingYourCellar : sharingOwnedBy(cellar.ownerName);

  /// The fixed message of [error] (security-design.md §4); [invite] picks
  /// "Invitation failed. Try again" for a server failure of an invitation.
  String sharingErrorMessage(SharingError error, {bool invite = false}) =>
      switch (error) {
        SharingError.invalidEmail => sharingInvalidEmail,
        SharingError.selfInvite => sharingSelfInvite,
        SharingError.alreadyInvited => sharingAlreadyInvited,
        SharingError.limitReached => sharingLimitReached(
          InviteValidator.maxInvitees,
        ),
        SharingError.notOwner => sharingNotOwner,
        SharingError.notFound => sharingNotFound,
        SharingError.offline => sharingOfflineHint,
        SharingError.timeout ||
        SharingError.failed => invite ? sharingInviteFailed : sharingFailed,
      };
}
