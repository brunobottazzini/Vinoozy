import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../account/app_user.dart';
import '../../account/network_status.dart';
import '../../app/error_reporter.dart';
import '../../cellar/data/firestore_codec.dart';
import '../../cellar/domain/cellar.dart';
import '../../usage/cloud_usage_meter.dart';
import '../../usage/firestore_metering.dart';
import '../domain/invite_validator.dart';
import '../domain/membership.dart';
import '../domain/sharing_error.dart';

/// Path of the invitations of a cellar (C3).
String membersPath(String cellarId) => '${cellarPath(cellarId)}/members';

/// Path of one invitation (C3): the key is the invitee email in lower case.
String memberPath(String cellarId, String memberKey) =>
    '${membersPath(cellarId)}/$memberKey';

/// The invitations of the signed-in person, with where they came from.
class MembershipsSnapshot {
  const MembershipsSnapshot({
    required this.memberships,
    required this.isFromCache,
  });

  final List<Membership> memberships;

  /// True while only the local cache answered: no activation is written
  /// then, only after the server confirmed the list (BR1.4).
  final bool isFromCache;
}

/// The sharing service of C4 on Firestore (logical-components.md:
/// SharingRepository).
///
/// Every management operation is one [WriteBatch]: the invitation plus,
/// when the open invitations change, the cellar with `memberSlots` +/-1 and
/// `memberOpKey` (security-design.md §1). It starts only with network and
/// waits for `commit()`, which with the offline persistence completes only
/// when the server accepted it, for at most [commitTimeout] (BR1.11,
/// NFR2.1). Repeating an operation after a timeout gives the same final
/// state: the rules refuse a transition that is no longer valid (NFR6.2).
///
/// Errors become [SharingException]s with fixed messages; unexpected ones are
/// reported with a fixed `sharing_*_failed` reason and every email and name
/// among the sensitive values (NFR8.2).
class SharingRepository {
  SharingRepository({
    required this._db,
    required this._network,
    required this._reporter,
    this._timeout = commitTimeout,
    this._meter,
  });

  /// Longest wait for the server's confirmation (BR1.11).
  static const Duration commitTimeout = Duration(seconds: 10);

  final FirebaseFirestore _db;

  /// freemium-plus FR6.1 (study §7.5): the sharing listeners, queries and
  /// confirmed writes of the account.
  final CloudUsageMeter? _meter;

  /// Above 0 while [revokeAllForUser] runs: an account deletion is system
  /// usage, never personal (FR6.4).
  int _systemDepth = 0;

  UsageScope get _scope =>
      _systemDepth > 0 ? UsageScope.system : UsageScope.personal;
  final NetworkStatus _network;
  final ErrorReporter _reporter;
  final Duration _timeout;

  // ---- Listeners ---------------------------------------------------------

  /// The person's own invitations in every state (BR1.4, BR1.14): one query
  /// on the `members` collection group filtered on `inviteeEmail` only, so
  /// the rules can prove every result is theirs (NFR4.5).
  Stream<MembershipsSnapshot> watchMyMemberships(String email) =>
      meteredQuerySnapshots(
        _db
            .collectionGroup('members')
            .where(
              MemberFields.inviteeEmail,
              isEqualTo: InviteValidator.normalizeEmail(email),
            )
            .snapshots(includeMetadataChanges: true),
        _meter,
        key: 'memberships/${InviteValidator.normalizeEmail(email)}',
      ).map(
        (snapshot) => MembershipsSnapshot(
          memberships: [
            for (final doc in snapshot.docs)
              ?_membershipOf(doc.reference.path, doc.data()),
          ],
          isFromCache: snapshot.metadata.isFromCache,
        ),
      );

  /// The invitations of [cellarId], for the owner's "People" screen only
  /// (BR1.12, NFR5.1).
  Stream<List<Membership>> watchCellarMembers(String cellarId) =>
      meteredQuerySnapshots(
        _db.collection(membersPath(cellarId)).snapshots(),
        _meter,
        key: membersPath(cellarId),
      ).map(
        (snapshot) => [
          for (final doc in snapshot.docs)
            ?_membershipOf(doc.reference.path, doc.data()),
        ],
      );

  /// `cellars/{cellarId}/members/{key}` → membership; null for another path.
  static Membership? _membershipOf(String path, Map<String, dynamic> data) {
    final segments = path.split('/');
    if (segments.length < 4) return null;
    final cellarId = segments[segments.length - 3];
    final key = segments.last;
    return Membership.fromMap(cellarId, key, decodeDocument(data));
  }

  // ---- Owner operations --------------------------------------------------

  /// Invites [rawEmail] to [cellar] with [permission] (BR1.2, C4 `invite`).
  ///
  /// [members] are the invitations the screen shows; together with
  /// `cellar.memberSlots` they give the local checks. Then the invitation
  /// document decides between a new invitation and the renewal of a closed
  /// one. Returns the member key (the normalized email).
  Future<String> invite({
    required Cellar cellar,
    required AppUser owner,
    required String rawEmail,
    required MemberPermission permission,
    Iterable<Membership> members = const [],
  }) async {
    final error = InviteValidator.validate(
      rawEmail: rawEmail,
      ownerEmail: owner.email,
      members: members,
      memberSlots: cellar.memberSlots,
    );
    if (error != null) throw SharingException(error);
    final key = InviteValidator.normalizeEmail(rawEmail);
    final sensitive = _sensitive(owner, [key]);
    await _requireNetwork();
    final memberRef = _db.doc(memberPath(cellar.id, key));
    final cellarRef = _db.doc(cellarPath(cellar.id));
    await _run(
      reason: 'sharing_invite_failed',
      sensitive: sensitive,
      cellarRef: cellarRef,
      memberRef: memberRef,
      writes: 2,
      build: () async {
        final current = await memberRef.get();
        recordDocumentRead(_meter, current, scope: _scope);
        final existing = current.exists
            ? Membership.fromMap(cellar.id, key, decodeDocument(current.data()))
            : null;
        if (existing != null && existing.isOpen) {
          throw const SharingException(SharingError.alreadyInvited);
        }
        final batch = _db.batch();
        if (existing == null) {
          batch.set(memberRef, {
            MemberFields.inviteeEmail: key,
            MemberFields.permission: permission.name,
            MemberFields.status: MemberStatus.invited.name,
            MemberFields.invitedAt: FieldValue.serverTimestamp(),
            MemberFields.ownerId: owner.uid,
            MemberFields.ownerName: displayNameOrFallback(
              owner.displayName,
              owner.email,
            ),
            MemberFields.updatedAt: FieldValue.serverTimestamp(),
          });
        } else {
          batch.update(memberRef, {
            MemberFields.status: MemberStatus.invited.name,
            MemberFields.permission: permission.name,
            MemberFields.invitedAt: FieldValue.serverTimestamp(),
            MemberFields.closedBy: FieldValue.delete(),
            MemberFields.updatedAt: FieldValue.serverTimestamp(),
          });
        }
        batch.update(cellarRef, _counter(1, key));
        return batch;
      },
    );
    return key;
  }

  /// Changes the permission of an open invitation (BR1.9, C4).
  Future<void> changePermission({
    required String cellarId,
    required String memberKey,
    required MemberPermission permission,
    required AppUser owner,
  }) async {
    await _requireNetwork();
    final memberRef = _db.doc(memberPath(cellarId, memberKey));
    await _run(
      reason: 'sharing_permission_failed',
      writes: 1,
      sensitive: _sensitive(owner, [memberKey]),
      cellarRef: _db.doc(cellarPath(cellarId)),
      memberRef: memberRef,
      build: () async => _db.batch()
        ..update(memberRef, {
          MemberFields.permission: permission.name,
          MemberFields.updatedAt: FieldValue.serverTimestamp(),
        }),
    );
  }

  /// Revokes an open invitation (BR1.8, C4): `revoked`, closed by the owner,
  /// counter -1.
  Future<void> revoke({
    required String cellarId,
    required String memberKey,
    required AppUser owner,
  }) async {
    await _requireNetwork();
    await _close(
      cellarId: cellarId,
      memberKey: memberKey,
      closedBy: ClosedBy.owner,
      reason: 'sharing_revoke_failed',
      sensitive: _sensitive(owner, [memberKey]),
    );
  }

  /// Deletes a closed invitation for good (BR1.12, NFR8.3).
  Future<void> deleteClosed({
    required String cellarId,
    required String memberKey,
    required AppUser owner,
  }) async {
    await _requireNetwork();
    await _delete(
      cellarId: cellarId,
      memberKey: memberKey,
      reason: 'sharing_delete_failed',
      sensitive: _sensitive(owner, [memberKey]),
    );
  }

  // ---- Invitee operations ------------------------------------------------

  /// First access of [user] to [cellarId] (BR1.4): `invited` → `active`,
  /// with the person's uid and name (the email prefix when Google gives no
  /// name). Runs in the background, so it does not ask for the network.
  Future<void> activate({
    required String cellarId,
    required AppUser user,
  }) async {
    final key = InviteValidator.normalizeEmail(user.email);
    final memberRef = _db.doc(memberPath(cellarId, key));
    await _run(
      reason: 'sharing_activate_failed',
      writes: 1,
      sensitive: _sensitive(user, [key]),
      cellarRef: _db.doc(cellarPath(cellarId)),
      memberRef: memberRef,
      build: () async => _db.batch()
        ..update(memberRef, {
          MemberFields.status: MemberStatus.active.name,
          MemberFields.inviteeUserId: user.uid,
          MemberFields.inviteeName: displayNameOrFallback(
            user.displayName,
            user.email,
          ),
          MemberFields.updatedAt: FieldValue.serverTimestamp(),
        }),
    );
  }

  /// "Leave this cellar" (BR1.10): `revoked`, closed by the invitee,
  /// counter -1. The owner sees "left" and can invite again.
  Future<void> leave({required String cellarId, required AppUser user}) async {
    await _requireNetwork();
    final key = InviteValidator.normalizeEmail(user.email);
    await _close(
      cellarId: cellarId,
      memberKey: key,
      closedBy: ClosedBy.invitee,
      reason: 'sharing_leave_failed',
      sensitive: _sensitive(user, [key]),
    );
  }

  /// For u8-account (C4 `revokeAllForUser`): revokes and deletes the
  /// invitations of [user]'s own cellar, then leaves and deletes every
  /// invitation [user] received (an `invited` one is activated first, the
  /// only way the rules let the invitee close it). Each step is its own
  /// batch; all are tried, and the first failure is thrown at the end.
  ///
  /// freemium-plus FR6.4: an account deletion step, counted as system usage.
  Future<void> revokeAllForUser(AppUser user) async {
    _systemDepth++;
    try {
      await _revokeAll(user);
    } finally {
      _systemDepth--;
    }
  }

  Future<void> _revokeAll(AppUser user) async {
    await _requireNetwork();
    final ownCellar = Cellar.personalCellarId(user.uid);
    SharingException? firstFailure;
    Future<void> attempt(Future<void> Function() step) async {
      try {
        await step();
      } on SharingException catch (error) {
        firstFailure ??= error;
      }
    }

    for (final member in await _readOnce(
      () => _db.collection(membersPath(ownCellar)).get(),
      user,
    )) {
      if (member.isOpen) {
        await attempt(
          () => revoke(
            cellarId: ownCellar,
            memberKey: member.memberKey,
            owner: user,
          ),
        );
      }
      await attempt(
        () => deleteClosed(
          cellarId: ownCellar,
          memberKey: member.memberKey,
          owner: user,
        ),
      );
    }

    final key = InviteValidator.normalizeEmail(user.email);
    for (final member in await _readOnce(
      () => _db
          .collectionGroup('members')
          .where(MemberFields.inviteeEmail, isEqualTo: key)
          .get(),
      user,
    )) {
      if (member.status == MemberStatus.invited) {
        await attempt(() => activate(cellarId: member.cellarId, user: user));
      }
      if (member.isOpen) {
        await attempt(() => leave(cellarId: member.cellarId, user: user));
      }
      await attempt(
        () => _delete(
          cellarId: member.cellarId,
          memberKey: key,
          reason: 'sharing_delete_failed',
          sensitive: _sensitive(user, [key]),
        ),
      );
    }
    final failure = firstFailure;
    if (failure != null) throw failure;
  }

  // ---- Shared steps ------------------------------------------------------

  Map<String, dynamic> _counter(int delta, String memberKey) => {
    CellarFields.memberSlots: FieldValue.increment(delta),
    CellarFields.memberOpKey: memberKey,
  };

  Future<void> _close({
    required String cellarId,
    required String memberKey,
    required ClosedBy closedBy,
    required String reason,
    required List<String> sensitive,
  }) {
    final memberRef = _db.doc(memberPath(cellarId, memberKey));
    final cellarRef = _db.doc(cellarPath(cellarId));
    return _run(
      reason: reason,
      sensitive: sensitive,
      cellarRef: cellarRef,
      memberRef: memberRef,
      writes: 2,
      build: () async => _db.batch()
        ..update(memberRef, {
          MemberFields.status: MemberStatus.revoked.name,
          MemberFields.closedBy: closedBy.name,
          MemberFields.updatedAt: FieldValue.serverTimestamp(),
        })
        ..update(cellarRef, _counter(-1, memberKey)),
    );
  }

  Future<void> _delete({
    required String cellarId,
    required String memberKey,
    required String reason,
    required List<String> sensitive,
  }) {
    final memberRef = _db.doc(memberPath(cellarId, memberKey));
    return _run(
      reason: reason,
      sensitive: sensitive,
      cellarRef: _db.doc(cellarPath(cellarId)),
      memberRef: memberRef,
      build: () async => _db.batch()..delete(memberRef),
    );
  }

  Future<List<Membership>> _readOnce(
    Future<QuerySnapshot<Map<String, dynamic>>> Function() query,
    AppUser user,
  ) async {
    try {
      final snapshot = await query().timeout(_timeout);
      recordQueryRead(_meter, snapshot, scope: _scope);
      return [
        for (final doc in snapshot.docs)
          ?_membershipOf(doc.reference.path, doc.data()),
      ];
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: 'sharing_revoke_all_failed',
        sensitive: _sensitive(user, const []),
      );
      throw SharingException(_codeError(error));
    }
  }

  Future<void> _requireNetwork() async {
    if (!await _network.hasNetwork()) {
      throw const SharingException(SharingError.offline);
    }
  }

  /// Builds and commits one batch within [_timeout], translating every
  /// failure into a [SharingException].
  Future<void> _run({
    required String reason,
    required List<String> sensitive,
    required DocumentReference<Map<String, dynamic>> cellarRef,
    required DocumentReference<Map<String, dynamic>> memberRef,
    required Future<WriteBatch> Function() build,
    int writes = 0,
  }) async {
    try {
      final batch = await build().timeout(_timeout);
      await batch.commit().timeout(_timeout);
      // freemium-plus FR6.1: [writes] documents set or updated, counted on
      // the server's confirmation (a delete adds none).
      _meter?.recordWrites(writes, scope: _scope);
    } on SharingException {
      rethrow;
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: reason,
        sensitive: sensitive,
      );
      throw SharingException(
        await _translate(
          error,
          cellarRef: cellarRef,
          memberRef: memberRef,
          isInvite: reason == 'sharing_invite_failed',
        ),
      );
    }
  }

  /// Cloud error → C4 error (security-design.md §4). For an invitation a
  /// `permission-denied` is looked at again: a full cellar is "limit
  /// reached", an open invitation is "already invited", anything else "not
  /// owner". Other operations never report those two errors.
  Future<SharingError> _translate(
    Object error, {
    required DocumentReference<Map<String, dynamic>> cellarRef,
    required DocumentReference<Map<String, dynamic>> memberRef,
    required bool isInvite,
  }) async {
    if (error is! FirebaseException ||
        error.code != 'permission-denied' ||
        !isInvite) {
      return _codeError(error);
    }
    try {
      final cellar = await cellarRef.get().timeout(_timeout);
      final slots = Cellar.fromMap(
        cellar.id,
        decodeDocument(cellar.data()),
      ).memberSlots;
      if (slots >= InviteValidator.maxInvitees) {
        return SharingError.limitReached;
      }
      final member = await memberRef.get().timeout(_timeout);
      if (member.exists) {
        final status = MemberStatus.parse(member.data()?[MemberFields.status]);
        if (status == MemberStatus.invited || status == MemberStatus.active) {
          return SharingError.alreadyInvited;
        }
      }
    } catch (_) {
      // The second look is best effort: without it the refusal stays
      // "not owner", which is what the rules said.
    }
    return SharingError.notOwner;
  }

  static SharingError _codeError(Object error) {
    if (error is TimeoutException) return SharingError.timeout;
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' => SharingError.notOwner,
        'not-found' => SharingError.notFound,
        'unavailable' || 'deadline-exceeded' => SharingError.timeout,
        _ => SharingError.failed,
      };
    }
    return SharingError.failed;
  }

  static List<String> _sensitive(AppUser user, List<String> extra) => [
    user.uid,
    user.email,
    user.displayName,
    ...extra,
  ];
}
