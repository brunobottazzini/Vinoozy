import '../../sharing/domain/membership.dart';
import '../app_user.dart';

/// One invitation document as the deletion needs it (C3 `members`).
class DeletionInvitation {
  const DeletionInvitation({
    required this.cellarId,
    required this.memberKey,
    required this.status,
  });

  final String cellarId;

  /// The invitee email in lower case (the document id).
  final String memberKey;

  /// Null for an unknown stored value: treated as closed.
  final MemberStatus? status;

  bool get isOpen =>
      status == MemberStatus.invited || status == MemberStatus.active;

  @override
  bool operator ==(Object other) =>
      other is DeletionInvitation &&
      other.cellarId == cellarId &&
      other.memberKey == memberKey &&
      other.status == status;

  @override
  int get hashCode => Object.hash(cellarId, memberKey, status);
}

/// The cloud operations of the account deletion (BR1.7 steps 1-6), behind
/// the app's own interface so the runner is tested with an in-memory fake
/// that records every batch and read (unit-test-instructions.md).
///
/// Every operation checks the current state before writing, so it can be
/// repeated after a partial success (NFR6.1): a missing document is not
/// deleted, a closed invitation is not closed again. Every read goes to the
/// server and every write waits for the server's confirmation; nothing goes
/// through the ledger.
abstract interface class DeletionBackend {
  /// Step 1: `users/{uid}.deletionStartedAt`, creating the profile if needed.
  Future<void> markStarted(AppUser user);

  /// Step 2: the invitations [user] received, in every state.
  Future<List<DeletionInvitation>> invitationsReceived(AppUser user);

  /// Step 2: `invited` → `active`, the only way the rules let the invited
  /// person close an invitation.
  Future<void> activate(String cellarId, AppUser user);

  /// Step 2: `active` → `revoked` by the invited person, counter -1.
  Future<void> leave(String cellarId, AppUser user);

  /// Steps 3-5: whether `cellars/{uid}` exists. A new account may have none:
  /// its subcollections are then skipped.
  Future<bool> cellarExists(String uid);

  /// Step 3: the invitations of the own cellar.
  Future<List<DeletionInvitation>> invitationsGiven(String uid);

  /// Step 3: open → `revoked` by the owner, counter -1.
  Future<void> revoke(String cellarId, String memberKey);

  /// Steps 2 and 3: deletes a closed invitation if it still exists.
  Future<void> deleteInvitation(String cellarId, String memberKey);

  /// Step 4: reads at most one page of [collection] (`drinkingRecords` or
  /// `wines`) of the own cellar from the server and deletes it in one
  /// confirmed batch. Returns how many documents were deleted (0: empty).
  Future<int> deletePage(String uid, String collection);

  /// Step 5: deletes `cellars/{uid}` if it exists.
  Future<void> deleteCellar(String uid);

  /// Step 6: deletes `users/{uid}` if it exists.
  Future<void> deleteProfile(String uid);
}
