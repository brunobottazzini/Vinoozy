// Adapters of u8-account on the Firestore SDK doubles: UserRepository
// (deletionStartedAt, profile deletion) and FirestoreDeletionBackend (the
// invitation batches, server reads, pages of 400).
// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/account/data/user_repository.dart';
import 'package:vinoozy/account/deletion/deletion_backend.dart';
import 'package:vinoozy/account/deletion/firestore_deletion_backend.dart';
import 'package:vinoozy/sharing/domain/membership.dart';

import '../helpers/firestore_mocks.dart';
import 'account_harness.dart';

class MockBatch extends Mock implements WriteBatch {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockUserRepo extends Mock implements UserRepository {}

MockQueryDocSnapshot queryDoc(String path, Map<String, dynamic> data) {
  final ref = MockDocRef();
  when(() => ref.path).thenReturn(path);
  final doc = MockQueryDocSnapshot();
  when(() => doc.reference).thenReturn(ref);
  when(() => doc.data()).thenReturn(data);
  return doc;
}

MockQuerySnapshot querySnapshot(List<MockQueryDocSnapshot> docs) {
  final snapshot = MockQuerySnapshot();
  when(() => snapshot.docs).thenReturn(docs);
  return snapshot;
}

void main() {
  setUpAll(() {
    registerFirestoreFallbacks();
    registerFallbackValue(mario);
  });

  group('UserRepository (BR1.7 step 1 and 6, BR1.10)', () {
    late MockFirestore db;
    late MockDocRef profile;
    late MockTransaction transaction;
    late UserRepository repository;

    setUp(() {
      db = MockFirestore();
      profile = MockDocRef();
      transaction = MockTransaction();
      when(() => db.doc('users/${mario.uid}')).thenReturn(profile);
      when(() => transaction.set<Map<String, dynamic>>(any(), any()))
          .thenReturn(transaction);
      when(() => transaction.update(any(), any())).thenReturn(transaction);
      runTransactionsWith(db, transaction);
      repository = UserRepository(db: db);
    });

    test('BR1.10 a missing profile is created with deletionStartedAt and the '
        'U1 fields', () async {
      when(() => transaction.get<Map<String, dynamic>>(profile))
          .thenAnswer((_) async => docSnapshot(exists: false));

      await repository.markDeletionStarted(mario);

      final created =
          verify(
                () => transaction.set<Map<String, dynamic>>(
                  profile,
                  captureAny(),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(created.keys, {
        'displayName',
        'email',
        'onboardingSeen',
        'schemaVersion',
        'createdAt',
        'deletionStartedAt',
      });
      expect(created['deletionStartedAt'], isA<FieldValue>());
      expect(created['onboardingSeen'], isFalse);
    });

    test('BR1.7 an existing profile only gets deletionStartedAt', () async {
      when(() => transaction.get<Map<String, dynamic>>(profile)).thenAnswer(
        (_) async => docSnapshot(exists: true, data: {'email': mario.email}),
      );

      await repository.markDeletionStarted(mario);

      final update =
          verify(() => transaction.update(profile, captureAny()))
                  .captured
                  .single
              as Map<Object, Object?>;
      expect(update.keys, ['deletionStartedAt']);
    });

    test('NFR6.1 deletionStartedAt already set is never rewritten', () async {
      when(() => transaction.get<Map<String, dynamic>>(profile)).thenAnswer(
        (_) async => docSnapshot(
          exists: true,
          data: {'deletionStartedAt': Timestamp.fromMillisecondsSinceEpoch(1)},
        ),
      );

      await repository.markDeletionStarted(mario);

      verifyNever(() => transaction.update(any(), any()));
      verifyNever(() => transaction.set<Map<String, dynamic>>(any(), any()));
    });

    test('BR1.8 isDeletionStarted reads the field; a read error reaches the '
        'gate', () async {
      when(() => profile.get()).thenAnswer(
        (_) async => docSnapshot(
          exists: true,
          data: {'deletionStartedAt': Timestamp.fromMillisecondsSinceEpoch(1)},
        ),
      );
      expect(await repository.isDeletionStarted(mario.uid), isTrue);

      when(() => profile.get())
          .thenAnswer((_) async => docSnapshot(exists: false));
      expect(await repository.isDeletionStarted(mario.uid), isFalse);

      when(() => profile.get()).thenThrow(firestoreError('unavailable'));
      await expectLater(
        repository.isDeletionStarted(mario.uid),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('BR1.7 deleteProfile deletes only an existing profile', () async {
      when(() => profile.delete()).thenAnswer((_) async {});
      when(() => profile.get(any()))
          .thenAnswer((_) async => docSnapshot(exists: false));
      await repository.deleteProfile(mario.uid);
      verifyNever(() => profile.delete());

      when(() => profile.get(any()))
          .thenAnswer((_) async => docSnapshot(exists: true, data: {}));
      await repository.deleteProfile(mario.uid);
      verify(() => profile.delete()).called(1);
    });
  });

  group('FirestoreDeletionBackend (BR1.7, BR1.9)', () {
    late MockFirestore db;
    late MockUserRepo users;
    late MockBatch batch;
    late FirestoreDeletionBackend backend;
    final docs = <String, MockDocRef>{};

    MockDocRef refOf(String path) => docs.putIfAbsent(path, () {
      final ref = MockDocRef();
      when(() => ref.path).thenReturn(path);
      return ref;
    });

    setUp(() {
      docs.clear();
      db = MockFirestore();
      users = MockUserRepo();
      batch = MockBatch();
      when(() => db.doc(any())).thenAnswer(
        (invocation) => refOf(invocation.positionalArguments.first as String),
      );
      when(() => db.batch()).thenReturn(batch);
      when(() => batch.commit()).thenAnswer((_) async {});
      backend = FirestoreDeletionBackend(db: db, users: users);
    });

    test('BR1.7 steps 1 and 6 go through UserRepository', () async {
      when(() => users.markDeletionStarted(any())).thenAnswer((_) async {});
      when(() => users.deleteProfile(any())).thenAnswer((_) async {});
      await backend.markStarted(mario);
      await backend.deleteProfile(mario.uid);
      verify(() => users.markDeletionStarted(mario)).called(1);
      verify(() => users.deleteProfile(mario.uid)).called(1);
    });

    test(
      'BR1.9 the received invitations are read from the server by email',
      () async {
        final group = MockQuery();
        final filtered = MockQuery();
        when(() => db.collectionGroup('members')).thenReturn(group);
        when(() => group.where('inviteeEmail', isEqualTo: 'mario@example.com'))
            .thenReturn(filtered);
        when(() => filtered.get(any())).thenAnswer(
          (_) async => querySnapshot([
            queryDoc('cellars/anna/members/mario@example.com', {
              'status': 'invited',
            }),
            queryDoc('odd', {'status': 'active'}),
          ]),
        );

        final list = await backend.invitationsReceived(
          AppUser(
            uid: mario.uid,
            email: 'Mario@Example.com',
            displayName: mario.displayName,
          ),
        );

        expect(list, [
          const DeletionInvitation(
            cellarId: 'anna',
            memberKey: 'mario@example.com',
            status: MemberStatus.invited,
          ),
        ]);
        final options =
            verify(() => filtered.get(captureAny())).captured.single
                as GetOptions;
        expect(options.source, Source.server);
      },
    );

    test('BR1.9 activate, leave and revoke write the C4 batches', () async {
      await backend.activate('anna', mario);
      final activation =
          verify(
                () => batch.update<Map<String, dynamic>>(
                  refOf('cellars/anna/members/mario@example.com'),
                  captureAny(),
                ),
              ).captured.single
              as Map<Object, Object?>;
      expect(activation['status'], 'active');
      expect(activation['inviteeUserId'], mario.uid);
      expect(activation['inviteeName'], 'Mario Rossi');

      await backend.leave('anna', mario);
      final counter =
          verify(
                () => batch.update<Map<String, dynamic>>(
                  refOf('cellars/anna'),
                  captureAny(),
                ),
              ).captured.single
              as Map<Object, Object?>;
      expect(counter['memberOpKey'], 'mario@example.com');
      expect(counter['memberSlots'], isA<FieldValue>());

      await backend.revoke(mario.uid, 'giulia@example.com');
      final revoked =
          verify(
                () => batch.update<Map<String, dynamic>>(
                  refOf('cellars/${mario.uid}/members/giulia@example.com'),
                  captureAny(),
                ),
              ).captured.single
              as Map<Object, Object?>;
      expect(revoked['closedBy'], 'owner');
      expect(revoked['status'], 'revoked');
      verify(() => batch.commit()).called(3);
    });

    test('BR1.7 the own invitations are listed from the server', () async {
      final members = MockCollectionRef();
      when(() => db.collection('cellars/${mario.uid}/members'))
          .thenReturn(members);
      when(() => members.get(any())).thenAnswer(
        (_) async => querySnapshot([
          queryDoc('cellars/${mario.uid}/members/giulia@example.com', {
            'status': 'revoked',
          }),
        ]),
      );
      final list = await backend.invitationsGiven(mario.uid);
      expect(list.single.isOpen, isFalse);
      expect(list.single.memberKey, 'giulia@example.com');
    });

    test('NFR6.1 deleting a document that is gone does nothing', () async {
      final member = refOf('cellars/anna/members/mario@example.com');
      when(() => member.get(any()))
          .thenAnswer((_) async => docSnapshot(exists: false));
      await backend.deleteInvitation('anna', 'mario@example.com');
      verifyNever(() => member.delete());

      final cellar = refOf('cellars/${mario.uid}');
      when(() => cellar.get(any()))
          .thenAnswer((_) async => docSnapshot(exists: true, data: {}));
      when(() => cellar.delete()).thenAnswer((_) async {});
      await backend.deleteCellar(mario.uid);
      verify(() => cellar.delete()).called(1);
      expect(await backend.cellarExists(mario.uid), isTrue);
    });

    test('BR1.7 step 4 reads a page of 400 from the server and deletes it in '
        'one batch', () async {
      final records = MockCollectionRef();
      final page = MockQuery();
      when(() => db.collection('cellars/${mario.uid}/drinkingRecords'))
          .thenReturn(records);
      when(() => records.limit(400)).thenReturn(page);
      final first = [
        for (var i = 0; i < 3; i++)
          queryDoc('cellars/${mario.uid}/drinkingRecords/r$i', {}),
      ];
      when(() => page.get(any())).thenAnswer((_) async => querySnapshot(first));
      when(() => batch.delete(any())).thenReturn(null);

      expect(await backend.deletePage(mario.uid, 'drinkingRecords'), 3);
      verify(() => batch.delete(any())).called(3);
      verify(() => batch.commit()).called(1);

      when(() => page.get(any())).thenAnswer((_) async => querySnapshot([]));
      expect(await backend.deletePage(mario.uid, 'drinkingRecords'), 0);
      verifyNever(() => batch.commit());
    });

    test('NFR6.4 a commit that never returns times out', () async {
      final slow = FirestoreDeletionBackend(
        db: db,
        users: users,
        timeout: const Duration(milliseconds: 1),
      );
      when(() => batch.commit()).thenAnswer((_) => Completer<void>().future);
      await expectLater(
        slow.activate('anna', mario),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
