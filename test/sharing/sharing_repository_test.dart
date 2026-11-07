// SharingRepository (u7-sharing security-design.md §1 and §4; BR1.8-BR1.13,
// NFR2.1, NFR6.2, NFR8.2): one batch per operation with the counter, the
// 10-second limit with a fake clock, the translation of every cloud error,
// no email in the reports.
// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/cellar/domain/cellar.dart';
import 'package:vinoozy/sharing/data/sharing_repository.dart';
import 'package:vinoozy/sharing/domain/membership.dart';
import 'package:vinoozy/sharing/domain/sharing_error.dart';

import '../helpers/fakes.dart';
import '../helpers/firestore_mocks.dart';
import '../u1/ui/sign_in_screen_test.dart' show FakeNetwork;
import 'sharing_harness.dart';

const giulia = 'giulia@example.com';
const cellar = Cellar(id: 'user-a', ownerId: 'user-a', name: 'Cantina');

Matcher throwsSharing(SharingError error) =>
    throwsA(isA<SharingException>().having((e) => e.error, 'error', error));

MockDocSnapshot snapshotWith({
  required bool exists,
  Map<String, dynamic>? data,
  String id = 'user-a',
}) {
  final snapshot = docSnapshot(exists: exists, data: data);
  when(() => snapshot.id).thenReturn(id);
  return snapshot;
}

void main() {
  setUpAll(registerSharingFallbacks);

  late MockFirestore db;
  late MockWriteBatch batch;
  late MockDocRef memberRef;
  late MockDocRef cellarRef;
  late FakeNetwork network;
  late RecordingErrorSink sink;
  late SharingRepository repository;

  setUp(() {
    db = MockFirestore();
    batch = MockWriteBatch();
    memberRef = MockDocRef();
    cellarRef = MockDocRef();
    network = FakeNetwork();
    sink = RecordingErrorSink();
    when(() => db.batch()).thenReturn(batch);
    when(() => db.doc('cellars/user-a/members/$giulia')).thenReturn(memberRef);
    when(() => db.doc('cellars/user-a')).thenReturn(cellarRef);
    when(() => batch.commit()).thenAnswer((_) async {});
    when(() => memberRef.get())
        .thenAnswer((_) async => snapshotWith(exists: false));
    repository = SharingRepository(
      db: db,
      network: network,
      reporter: recordingReporter(sink),
    );
  });

  Future<String> invite({
    String email = giulia,
    Cellar target = cellar,
    List<Membership> members = const [],
  }) => repository.invite(
    cellar: target,
    owner: owner,
    rawEmail: email,
    permission: MemberPermission.read,
    members: members,
  );

  Map<Object?, Object?> capturedUpdate(MockDocRef ref) =>
      verify(() => batch.update<Map<String, dynamic>>(ref, captureAny()))
              .captured
              .single
          as Map<Object?, Object?>;

  void expectNoEmailReported() {
    for (final recorded in sink.recorded) {
      expect(recorded.error.message, isNot(contains('@example.com')));
      expect(recorded.error.message, isNot(contains('giulia')));
      expect(recorded.reason, isNot(contains('@')));
    }
  }

  group('invite (BR1.2, BR1.11, BR1.13)', () {
    test('BR1.2 a new invitation is one batch: the member and the counter '
        '+1 with its key', () async {
      final key = await invite(email: ' Giulia@Example.com ');

      expect(key, giulia);
      final written =
          verify(() => batch.set<Map<String, dynamic>>(memberRef, captureAny()))
                  .captured
                  .single
              as Map<String, dynamic>;
      expect(written[MemberFields.inviteeEmail], giulia);
      expect(written[MemberFields.permission], 'read');
      expect(written[MemberFields.status], 'invited');
      expect(written[MemberFields.ownerId], 'user-a');
      expect(written[MemberFields.ownerName], 'Mario');
      expect(written[MemberFields.invitedAt], isA<FieldValue>());
      expect(written[MemberFields.updatedAt], isA<FieldValue>());
      final counter = capturedUpdate(cellarRef);
      expect(counter[CellarFields.memberSlots], isA<FieldValue>());
      expect(counter[CellarFields.memberOpKey], giulia);
      verify(() => batch.commit()).called(1);
    });

    test(
      'BR1.2 a revoked invitation is renewed with closedBy removed',
      () async {
        when(() => memberRef.get()).thenAnswer(
          (_) async => snapshotWith(
            exists: true,
            data: memberData(
              membership(
                status: MemberStatus.revoked,
                closedBy: ClosedBy.owner,
              ),
            ),
          ),
        );

        await invite();

        final update = capturedUpdate(memberRef);
        expect(update[MemberFields.status], 'invited');
        expect(update[MemberFields.permission], 'read');
        expect(update[MemberFields.closedBy], isA<FieldValue>());
        expect(capturedUpdate(cellarRef)[CellarFields.memberOpKey], giulia);
        verifyNever(() => batch.set<Map<String, dynamic>>(any(), any()));
      },
    );

    test('BR1.2 an open invitation found on the document is alreadyInvited, '
        'nothing written', () async {
      when(() => memberRef.get()).thenAnswer(
        (_) async => snapshotWith(exists: true, data: memberData(membership())),
      );

      await expectLater(invite(), throwsSharing(SharingError.alreadyInvited));
      verifyNever(() => batch.commit());
    });

    test(
      'BR1.2 the local checks stop before any network or Firestore use',
      () async {
        await expectLater(
          invite(email: 'x'),
          throwsSharing(SharingError.invalidEmail),
        );
        await expectLater(
          invite(email: owner.email),
          throwsSharing(SharingError.selfInvite),
        );
        await expectLater(
          invite(
            target: const Cellar(
              id: 'user-a',
              ownerId: 'user-a',
              name: 'C',
              memberSlots: 2,
            ),
          ),
          throwsSharing(SharingError.limitReached),
        );
        verifyNever(() => db.batch());
        verifyNever(() => memberRef.get());
      },
    );

    test('BR1.11 without network nothing starts: offline', () async {
      network.online = false;

      await expectLater(invite(), throwsSharing(SharingError.offline));
      verifyNever(() => memberRef.get());
      verifyNever(() => db.batch());
    });

    // testWidgets runs on fake time (flutter_test's FakeAsync zone): the
    // 10 seconds pass without real waiting.
    testWidgets('NFR2.1 BR1.11 no confirmation in 10 s gives timeout and a '
        'fixed report without the email', (tester) async {
      when(() => batch.commit()).thenAnswer((_) => Completer<void>().future);
      Object? outcome;
      invite().then<void>(
        (_) => outcome = 'done',
        onError: (Object e) => outcome = e,
      );

      await tester.pump(const Duration(seconds: 9));
      expect(outcome, isNull);
      await tester.pump(const Duration(seconds: 2));

      expect(
        outcome,
        isA<SharingException>().having(
          (e) => e.error,
          'error',
          SharingError.timeout,
        ),
      );
      expect(sink.reasons, ['sharing_invite_failed']);
      expectNoEmailReported();
    });
  });

  group('cloud errors (security-design.md §4)', () {
    void commitFails(String code) =>
        when(() => batch.commit()).thenThrow(firestoreError(code));

    test(
      'BR1.2 permission-denied with a full cellar is limitReached',
      () async {
        commitFails('permission-denied');
        when(() => cellarRef.get()).thenAnswer(
          (_) async => snapshotWith(
            exists: true,
            data: {CellarFields.ownerId: 'user-a', CellarFields.memberSlots: 2},
          ),
        );

        await expectLater(invite(), throwsSharing(SharingError.limitReached));
        expectNoEmailReported();
      },
    );

    test(
      'BR1.2 permission-denied with an open invitation is alreadyInvited',
      () async {
        commitFails('permission-denied');
        when(() => cellarRef.get()).thenAnswer(
          (_) async =>
              snapshotWith(exists: true, data: {CellarFields.memberSlots: 1}),
        );
        var reads = 0;
        when(() => memberRef.get()).thenAnswer((_) async {
          reads++;
          // First read: before the batch (absent); second: the second look.
          return reads == 1
              ? snapshotWith(exists: false)
              : snapshotWith(exists: true, data: memberData(membership()));
        });

        await expectLater(invite(), throwsSharing(SharingError.alreadyInvited));
      },
    );

    test('BR1.1 any other permission-denied is notOwner', () async {
      commitFails('permission-denied');
      when(() => cellarRef.get())
          .thenAnswer((_) async => snapshotWith(exists: true, data: const {}));

      await expectLater(invite(), throwsSharing(SharingError.notOwner));
    });

    test('BR1.1 a failing second look keeps notOwner', () async {
      commitFails('permission-denied');
      when(() => cellarRef.get()).thenThrow(firestoreError('unavailable'));

      await expectLater(invite(), throwsSharing(SharingError.notOwner));
    });

    test('BR1.8 a refused revoke in a full cellar is notOwner, never '
        'limitReached', () async {
      when(() => memberRef.get()).thenAnswer(
        (_) async => snapshotWith(
          exists: true,
          data: memberData(membership(status: MemberStatus.active)),
        ),
      );
      when(() => cellarRef.get()).thenAnswer(
        (_) async => snapshotWith(
          exists: true,
          data: {CellarFields.ownerId: 'user-a', CellarFields.memberSlots: 2},
        ),
      );
      commitFails('permission-denied');

      await expectLater(
        repository.revoke(cellarId: 'user-a', memberKey: giulia, owner: owner),
        throwsSharing(SharingError.notOwner),
      );
    });

    test('not-found is notFound, unavailable and deadline-exceeded are '
        'timeout, the rest failed', () async {
      final cases = {
        'not-found': SharingError.notFound,
        'unavailable': SharingError.timeout,
        'deadline-exceeded': SharingError.timeout,
        'internal': SharingError.failed,
      };
      for (final MapEntry(key: code, value: error) in cases.entries) {
        commitFails(code);
        await expectLater(
          repository.revoke(
            cellarId: 'user-a',
            memberKey: giulia,
            owner: owner,
          ),
          throwsSharing(error),
        );
      }
      when(() => batch.commit()).thenThrow(StateError('boom'));
      await expectLater(
        repository.revoke(cellarId: 'user-a', memberKey: giulia, owner: owner),
        throwsSharing(SharingError.failed),
      );
      expect(sink.reasons.toSet(), {'sharing_revoke_failed'});
      expectNoEmailReported();
    });
  });

  group('other operations: one batch each', () {
    test(
      'BR1.9 changePermission writes the permission only, no counter',
      () async {
        await repository.changePermission(
          cellarId: 'user-a',
          memberKey: giulia,
          permission: MemberPermission.edit,
          owner: owner,
        );

        final update = capturedUpdate(memberRef);
        expect(update[MemberFields.permission], 'edit');
        expect(
          update.keys,
          unorderedEquals([MemberFields.permission, MemberFields.updatedAt]),
        );
        verifyNever(() => batch.update<Map<String, dynamic>>(cellarRef, any()));
      },
    );

    test('BR1.8 revoke: revoked, closed by the owner, counter -1', () async {
      await repository.revoke(
        cellarId: 'user-a',
        memberKey: giulia,
        owner: owner,
      );

      final update = capturedUpdate(memberRef);
      expect(update[MemberFields.status], 'revoked');
      expect(update[MemberFields.closedBy], 'owner');
      expect(capturedUpdate(cellarRef)[CellarFields.memberOpKey], giulia);
      verify(() => batch.commit()).called(1);
    });

    test(
      'BR1.10 leave: the key of the own email, closed by the invitee',
      () async {
        await repository.leave(cellarId: 'user-a', user: invitee);

        final update = capturedUpdate(memberRef);
        expect(update[MemberFields.status], 'revoked');
        expect(update[MemberFields.closedBy], 'invitee');
        expect(
          capturedUpdate(cellarRef)[CellarFields.memberSlots],
          isA<FieldValue>(),
        );
      },
    );

    test('BR1.4 activate: active with the uid and the fallback name, no '
        'counter, no network check', () async {
      network.online = false;
      // Giulia without a Google name: the fallback is the email prefix.
      const unnamed = AppUser(uid: 'user-b', email: giulia, displayName: '');

      await repository.activate(cellarId: 'user-a', user: unnamed);

      final update = capturedUpdate(memberRef);
      expect(update[MemberFields.status], 'active');
      expect(update[MemberFields.inviteeUserId], 'user-b');
      expect(update[MemberFields.inviteeName], 'giulia');
      verifyNever(() => batch.update<Map<String, dynamic>>(cellarRef, any()));
    });

    test(
      'BR1.4 a failed activation is reported as sharing_activate_failed',
      () async {
        when(() => batch.commit())
            .thenThrow(firestoreError('permission-denied'));
        when(() => cellarRef.get())
            .thenThrow(firestoreError('permission-denied'));

        await expectLater(
          repository.activate(cellarId: 'user-a', user: invitee),
          throwsSharing(SharingError.notOwner),
        );
        expect(sink.reasons, ['sharing_activate_failed']);
        expectNoEmailReported();
      },
    );

    test('BR1.12 deleteClosed deletes the invitation only', () async {
      await repository.deleteClosed(
        cellarId: 'user-a',
        memberKey: giulia,
        owner: owner,
      );

      verify(() => batch.delete(memberRef)).called(1);
      verifyNever(() => batch.update<Map<String, dynamic>>(any(), any()));
    });

    test('BR1.11 the owner operations need the network', () async {
      network.online = false;
      await expectLater(
        repository.changePermission(
          cellarId: 'user-a',
          memberKey: giulia,
          permission: MemberPermission.edit,
          owner: owner,
        ),
        throwsSharing(SharingError.offline),
      );
      await expectLater(
        repository.leave(cellarId: 'user-a', user: invitee),
        throwsSharing(SharingError.offline),
      );
      await expectLater(
        repository.deleteClosed(
          cellarId: 'user-a',
          memberKey: giulia,
          owner: owner,
        ),
        throwsSharing(SharingError.offline),
      );
      verifyNever(() => db.batch());
    });
  });

  group('listeners (BR1.4, BR1.12, BR1.14)', () {
    test('watchMyMemberships queries the collection group on the normalized '
        'email and maps the cellar from the path', () async {
      final group = MockQuery();
      final filtered = MockQuery();
      when(() => db.collectionGroup('members')).thenReturn(group);
      when(() => group.where(MemberFields.inviteeEmail, isEqualTo: giulia))
          .thenReturn(filtered);
      when(() => filtered.snapshots(includeMetadataChanges: true)).thenAnswer(
        (_) => Stream.value(
          memberQuerySnapshot([
            membership(cellarId: 'user-a'),
            membership(cellarId: 'user-z', status: MemberStatus.invited),
          ], fromCache: true),
        ),
      );

      final snapshot = await repository
          .watchMyMemberships('Giulia@Example.com')
          .first;

      expect(snapshot.isFromCache, isTrue);
      expect(snapshot.memberships.map((m) => m.cellarId), ['user-a', 'user-z']);
      expect(snapshot.memberships.last.status, MemberStatus.invited);
    });

    test('watchCellarMembers lists the members of one cellar', () async {
      final collection = MockCollectionRef();
      when(() => db.collection('cellars/user-a/members'))
          .thenReturn(collection);
      when(() => collection.snapshots())
          .thenAnswer((_) => Stream.value(memberQuerySnapshot([membership()])));

      final members = await repository.watchCellarMembers('user-a').first;

      expect(members.single.memberKey, giulia);
    });
  });

  group('revokeAllForUser (C4, for u8-account)', () {
    late MockCollectionRef ownMembers;
    late MockQuery group;
    late MockQuery received;

    setUp(() {
      ownMembers = MockCollectionRef();
      group = MockQuery();
      received = MockQuery();
      when(() => db.collection('cellars/user-b/members'))
          .thenReturn(ownMembers);
      when(() => db.collectionGroup('members')).thenReturn(group);
      when(() => group.where(MemberFields.inviteeEmail, isEqualTo: giulia))
          .thenReturn(received);
      when(() => db.doc(any())).thenReturn(MockDocRef());
      when(() => db.doc('cellars/user-a/members/$giulia'))
          .thenReturn(memberRef);
      when(() => db.doc('cellars/user-a')).thenReturn(cellarRef);
    });

    test(
      'closes the own cellar invitations and leaves the received ones',
      () async {
        final ownSnapshot = memberQuerySnapshot([
          membership(cellarId: 'user-b', email: 'luca@example.com'),
          membership(
            cellarId: 'user-b',
            email: 'anna@example.com',
            status: MemberStatus.revoked,
          ),
        ]);
        when(() => ownMembers.get()).thenAnswer((_) async => ownSnapshot);
        final receivedSnapshot = memberQuerySnapshot([
          membership(status: MemberStatus.invited),
        ]);
        when(() => received.get()).thenAnswer((_) async => receivedSnapshot);

        await repository.revokeAllForUser(invitee);

        // Own: revoke luca (1) + delete luca and anna (2); received: activate,
        // leave, delete (3).
        verify(() => batch.commit()).called(6);
        verify(() => batch.delete(memberRef)).called(1);
      },
    );

    test('keeps going after a failure and throws the first one', () async {
      when(() => ownMembers.get()).thenAnswer(
        (_) async => memberQuerySnapshot([
          membership(cellarId: 'user-b', email: 'luca@example.com'),
        ]),
      );
      when(() => received.get())
          .thenAnswer((_) async => memberQuerySnapshot(const []));
      var commits = 0;
      when(() => batch.commit()).thenAnswer((_) async {
        commits++;
        if (commits == 1) throw firestoreError('unavailable');
      });

      await expectLater(
        repository.revokeAllForUser(invitee),
        throwsSharing(SharingError.timeout),
      );
      expect(commits, 2);
    });

    test(
      'a failing read stops with its error, reported without email',
      () async {
        when(() => ownMembers.get()).thenThrow(firestoreError('unavailable'));

        await expectLater(
          repository.revokeAllForUser(invitee),
          throwsSharing(SharingError.timeout),
        );
        expect(sink.reasons, ['sharing_revoke_all_failed']);
        expectNoEmailReported();
      },
    );
  });
}
