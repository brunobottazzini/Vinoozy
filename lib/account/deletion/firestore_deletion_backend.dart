import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cellar/data/firestore_codec.dart';
import '../../cellar/domain/cellar.dart';
import '../../sharing/data/sharing_repository.dart'
    show memberPath, membersPath;
import '../../sharing/domain/invite_validator.dart';
import '../../sharing/domain/membership.dart';
import '../app_user.dart';
import '../data/user_repository.dart';
import 'deletion_backend.dart';
import 'deletion_plan.dart';

/// [DeletionBackend] on Firestore (BR1.7, clarifications of the second
/// review): server reads, batches confirmed by the server, the same
/// invitation batches as `SharingRepository` (C4), without its reporting,
/// since the deletion reports only `account_delete_failed` (NFR8.2).
///
/// Every read and commit waits at most [timeout]: with the offline
/// persistence a commit without network would wait for ever, and the runner
/// must stop with "Try again" instead (NFR6.4).
class FirestoreDeletionBackend implements DeletionBackend {
  FirestoreDeletionBackend({
    required this._db,
    required this._users,
    this._timeout = const Duration(seconds: 30),
  });

  static const GetOptions _server = GetOptions(source: Source.server);

  final FirebaseFirestore _db;
  final UserRepository _users;
  final Duration _timeout;

  Future<T> _limited<T>(Future<T> work) => work.timeout(_timeout);

  @override
  Future<void> markStarted(AppUser user) =>
      _limited(_users.markDeletionStarted(user));

  @override
  Future<List<DeletionInvitation>> invitationsReceived(AppUser user) async {
    final snapshot = await _limited(
      _db
          .collectionGroup('members')
          .where(
            MemberFields.inviteeEmail,
            isEqualTo: InviteValidator.normalizeEmail(user.email),
          )
          .get(_server),
    );
    return [for (final doc in snapshot.docs) ?_invitationOf(doc)];
  }

  @override
  Future<List<DeletionInvitation>> invitationsGiven(String uid) async {
    final snapshot = await _limited(
      _db.collection(membersPath(Cellar.personalCellarId(uid))).get(_server),
    );
    return [for (final doc in snapshot.docs) ?_invitationOf(doc)];
  }

  /// `cellars/{cellarId}/members/{key}` → invitation; null for another path.
  static DeletionInvitation? _invitationOf(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final segments = doc.reference.path.split('/');
    if (segments.length < 4) return null;
    return DeletionInvitation(
      cellarId: segments[segments.length - 3],
      memberKey: segments.last,
      status: MemberStatus.parse(doc.data()[MemberFields.status]),
    );
  }

  @override
  Future<void> activate(String cellarId, AppUser user) {
    final key = InviteValidator.normalizeEmail(user.email);
    final batch = _db.batch()
      ..update(_db.doc(memberPath(cellarId, key)), {
        MemberFields.status: MemberStatus.active.name,
        MemberFields.inviteeUserId: user.uid,
        MemberFields.inviteeName: displayNameOrFallback(
          user.displayName,
          user.email,
        ),
        MemberFields.updatedAt: FieldValue.serverTimestamp(),
      });
    return _limited(batch.commit());
  }

  @override
  Future<void> leave(String cellarId, AppUser user) => _close(
    cellarId,
    InviteValidator.normalizeEmail(user.email),
    ClosedBy.invitee,
  );

  @override
  Future<void> revoke(String cellarId, String memberKey) =>
      _close(cellarId, memberKey, ClosedBy.owner);

  Future<void> _close(String cellarId, String memberKey, ClosedBy closedBy) {
    final batch = _db.batch()
      ..update(_db.doc(memberPath(cellarId, memberKey)), {
        MemberFields.status: MemberStatus.revoked.name,
        MemberFields.closedBy: closedBy.name,
        MemberFields.updatedAt: FieldValue.serverTimestamp(),
      })
      ..update(_db.doc(cellarPath(cellarId)), {
        CellarFields.memberSlots: FieldValue.increment(-1),
        CellarFields.memberOpKey: memberKey,
      });
    return _limited(batch.commit());
  }

  @override
  Future<void> deleteInvitation(String cellarId, String memberKey) =>
      _deleteIfExists(_db.doc(memberPath(cellarId, memberKey)));

  @override
  Future<bool> cellarExists(String uid) async {
    final snapshot = await _limited(
      _db.doc(cellarPath(Cellar.personalCellarId(uid))).get(_server),
    );
    return snapshot.exists;
  }

  @override
  Future<int> deletePage(String uid, String collection) async {
    final cellarId = Cellar.personalCellarId(uid);
    final snapshot = await _limited(
      _db
          .collection('${cellarPath(cellarId)}/$collection')
          .limit(DeletionPlan.pageSize)
          .get(_server),
    );
    if (snapshot.docs.isEmpty) return 0;
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await _limited(batch.commit());
    return snapshot.docs.length;
  }

  @override
  Future<void> deleteCellar(String uid) =>
      _deleteIfExists(_db.doc(cellarPath(Cellar.personalCellarId(uid))));

  @override
  Future<void> deleteProfile(String uid) => _limited(_users.deleteProfile(uid));

  Future<void> _deleteIfExists(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    final snapshot = await _limited(ref.get(_server));
    if (!snapshot.exists) return;
    await _limited(ref.delete());
  }
}
