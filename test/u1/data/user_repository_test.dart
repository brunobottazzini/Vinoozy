import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/account/data/user_repository.dart';

import '../../helpers/firestore_mocks.dart';

void main() {
  setUpAll(registerFirestoreFallbacks);

  const user = AppUser(
    uid: 'user-a',
    email: 'user-a@example.com',
    displayName: 'User A',
  );
  late MockFirestore db;
  late MockDocRef profileRef;
  late MockTransaction transaction;
  late List<Duration> sleeps;
  late UserRepository repository;

  setUp(() {
    db = MockFirestore();
    profileRef = MockDocRef();
    transaction = MockTransaction();
    sleeps = [];
    when(() => db.doc('users/user-a')).thenReturn(profileRef);
    when(() => transaction.set<Map<String, dynamic>>(any(), any()))
        .thenReturn(transaction);
    when(() => transaction.update(any(), any())).thenReturn(transaction);
    repository = UserRepository(db: db, sleep: (d) async => sleeps.add(d));
  });

  test('creates the profile when missing, with onboardingSeen false', () async {
    runTransactionsWith(db, transaction);
    when(() => transaction.get<Map<String, dynamic>>(profileRef))
        .thenAnswer((_) async => docSnapshot(exists: false));

    await repository.ensureProfile(user);

    final created =
        verify(
              () => transaction.set<Map<String, dynamic>>(
                profileRef,
                captureAny(),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(created['displayName'], 'User A');
    expect(created['email'], 'user-a@example.com');
    expect(created['onboardingSeen'], isFalse);
    expect(created['schemaVersion'], 1);
    expect(created['createdAt'], isA<FieldValue>());
    verifyNever(() => transaction.update(any(), any()));
  });

  test(
    'an existing profile only gets displayName and email (NFR4.11)',
    () async {
      runTransactionsWith(db, transaction);
      when(() => transaction.get<Map<String, dynamic>>(profileRef)).thenAnswer(
        (_) async => docSnapshot(exists: true, data: {'onboardingSeen': true}),
      );

      await repository.ensureProfile(user);

      final update =
          verify(() => transaction.update(profileRef, captureAny()))
                  .captured
                  .single
              as Map<String, dynamic>;
      expect(update, {'displayName': 'User A', 'email': 'user-a@example.com'});
      verifyNever(() => transaction.set<Map<String, dynamic>>(any(), any()));
    },
  );

  test('a transient failure is retried', () async {
    var calls = 0;
    when(() => db.runTransaction<void>(any())).thenAnswer((_) async {
      if (++calls == 1) throw firestoreError('deadline-exceeded');
    });

    await repository.ensureProfile(user);

    expect(calls, 2);
    expect(sleeps, [const Duration(milliseconds: 400)]);
  });

  test('a permanent failure reaches the caller', () async {
    when(() => db.runTransaction<void>(any()))
        .thenThrow(firestoreError('permission-denied'));

    await expectLater(
      repository.ensureProfile(user),
      throwsA(isA<FirebaseException>()),
    );
    verify(() => db.runTransaction<void>(any())).called(1);
  });

  test('after 3 transient failures the error is thrown', () async {
    when(() => db.runTransaction<void>(any()))
        .thenThrow(firestoreError('unavailable'));

    await expectLater(
      repository.ensureProfile(user),
      throwsA(isA<FirebaseException>()),
    );
    verify(() => db.runTransaction<void>(any())).called(3);
  });
}
