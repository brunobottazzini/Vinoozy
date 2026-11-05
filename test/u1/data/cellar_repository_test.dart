import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/cellar/data/retry.dart';

import '../../helpers/firestore_mocks.dart';

void main() {
  setUpAll(registerFirestoreFallbacks);

  late MockFirestore db;
  late MockDocRef cellarRef;
  late MockTransaction transaction;
  late List<Duration> sleeps;
  late CellarRepository repository;

  setUp(() {
    db = MockFirestore();
    cellarRef = MockDocRef();
    transaction = MockTransaction();
    sleeps = [];
    when(() => db.doc('cellars/user-a')).thenReturn(cellarRef);
    when(() => transaction.set<Map<String, dynamic>>(any(), any()))
        .thenReturn(transaction);
    repository = CellarRepository(
      db: db,
      sleep: (duration) async => sleeps.add(duration),
    );
  });

  Future<void> ensure() => repository.ensurePersonalCellar(
    uid: 'user-a',
    defaultName: 'La mia cantina',
  );

  test(
    'creates cellars/{uid} in a transaction when it does not exist',
    () async {
      runTransactionsWith(db, transaction);
      when(() => transaction.get<Map<String, dynamic>>(cellarRef))
          .thenAnswer((_) async => docSnapshot(exists: false));

      await ensure();

      final written =
          verify(
                () => transaction.set<Map<String, dynamic>>(
                  cellarRef,
                  captureAny(),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(written['ownerId'], 'user-a');
      expect(written['name'], 'La mia cantina');
      expect(written['schemaVersion'], 1);
      expect(written['createdAt'], isA<FieldValue>());
    },
  );

  test('never overwrites an existing cellar (BR1.3, NFR4.11)', () async {
    runTransactionsWith(db, transaction);
    when(() => transaction.get<Map<String, dynamic>>(cellarRef))
        .thenAnswer((_) async => docSnapshot(exists: true, data: {}));

    await ensure();

    verifyNever(() => transaction.set<Map<String, dynamic>>(any(), any()));
  });

  test('retries transient errors with growing waits, then succeeds', () async {
    var calls = 0;
    when(() => db.runTransaction<void>(any())).thenAnswer((_) async {
      calls++;
      if (calls < 3) throw firestoreError('unavailable');
    });

    await ensure();

    expect(calls, 3);
    expect(sleeps, [
      const Duration(milliseconds: 400),
      const Duration(milliseconds: 800),
    ]);
  });

  test('gives up after 3 attempts with CellarSetupException', () async {
    when(() => db.runTransaction<void>(any()))
        .thenThrow(firestoreError('aborted'));

    await expectLater(ensure(), throwsA(isA<CellarSetupException>()));
    verify(() => db.runTransaction<void>(any())).called(3);
    expect(sleeps, hasLength(2));
  });

  test('a permanent error is not retried', () async {
    when(() => db.runTransaction<void>(any()))
        .thenThrow(firestoreError('permission-denied'));

    await expectLater(
      ensure(),
      throwsA(
        isA<CellarSetupException>().having(
          (e) => e.toString(),
          'message',
          contains('permission-denied'),
        ),
      ),
    );
    verify(() => db.runTransaction<void>(any())).called(1);
    expect(sleeps, isEmpty);
  });

  test(
    'isCached reads only the cache and treats "not cached" as false',
    () async {
      when(() => cellarRef.get(any()))
          .thenAnswer((_) async => docSnapshot(exists: true, data: {}));
      expect(await repository.isCached('user-a'), isTrue);
      final options =
          verify(() => cellarRef.get(captureAny())).captured.single
              as GetOptions;
      expect(options.source, Source.cache);

      when(() => cellarRef.get(any())).thenThrow(firestoreError('unavailable'));
      expect(await repository.isCached('user-a'), isFalse);
    },
  );

  test('watchCellar maps the document and its metadata', () async {
    when(() => cellarRef.snapshots(includeMetadataChanges: true)).thenAnswer(
      (_) => Stream.fromIterable([
        docSnapshot(exists: false, fromCache: true),
        docSnapshot(
          exists: true,
          data: {
            'ownerId': 'user-a',
            'name': 'La mia cantina',
            'createdAt': Timestamp.fromMillisecondsSinceEpoch(0),
            'schemaVersion': 1,
          },
          pending: true,
        ),
      ]),
    );

    final snapshots = await repository.watchCellar('user-a').toList();

    expect(snapshots.first.cellar, isNull);
    expect(snapshots.first.meta.isFromCache, isTrue);
    expect(snapshots.last.cellar!.name, 'La mia cantina');
    expect(snapshots.last.cellar!.createdAt, DateTime.utc(1970));
    expect(snapshots.last.meta.hasPendingWrites, isTrue);
  });

  test('retryTransient rejects a non-positive attempt count', () {
    expect(
      () => retryTransient<void>(() async {}, attempts: 0),
      throwsArgumentError,
    );
  });
}
