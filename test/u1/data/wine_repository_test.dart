import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../../helpers/fakes.dart';
import '../../helpers/firestore_mocks.dart';

void main() {
  setUpAll(registerFirestoreFallbacks);

  const user = AppUser(
    uid: 'user-a',
    email: 'user-a@example.com',
    displayName: 'User A',
  );
  late MockFirestore db;
  late MockDocRef wineRef;
  late InMemoryKeyValueStore store;
  late LocalLedger ledger;
  late SyncErrorBus bus;
  late RecordingErrorSink sink;
  late List<SyncEvent> events;
  late int writesStarted;
  late WineRepository repository;
  late Completer<void> serverWrite;

  WineDraft draft({String id = 'wine-1', String name = 'Barolo'}) =>
      WineDraft.validate(
        id: id,
        rawName: name,
        rawVintage: '2016',
        noVintage: false,
        quantity: 2,
        currentYear: 2026,
      ).draft!;

  setUp(() {
    db = MockFirestore();
    wineRef = MockDocRef();
    store = InMemoryKeyValueStore();
    sink = RecordingErrorSink();
    ledger = LocalLedger(store: store, reporter: recordingReporter(sink));
    bus = SyncErrorBus();
    events = [];
    bus.events.listen(events.add);
    writesStarted = 0;
    serverWrite = Completer<void>();
    when(() => db.doc('cellars/user-a/wines/wine-1')).thenReturn(wineRef);
    when(() => wineRef.set(any())).thenAnswer((_) => serverWrite.future);
    repository = WineRepository(
      db: db,
      ledger: ledger,
      bus: bus,
      reporter: recordingReporter(sink),
      onWriteStarted: () => writesStarted++,
    );
  });

  Future<SaveOutcome> create() =>
      repository.create(cellarId: 'user-a', user: user, draft: draft());

  test(
    'create journals the wine, writes C3 fields and confirms on success',
    () async {
      final outcome = await create();

      expect(outcome, isA<SaveAccepted>());
      expect(writesStarted, 1);
      final written =
          verify(() => wineRef.set(captureAny())).captured.single
              as Map<String, dynamic>;
      expect(written['name'], 'Barolo');
      expect(written['vintage'], 2016);
      expect(written['quantity'], 2);
      expect(written['updatedBy'], 'user-a');
      expect(written['createdAt'], isA<FieldValue>());
      expect(written['updatedAt'], isA<FieldValue>());
      expect(
        (await ledger.read()).openEntriesOf('user-a').single.wineId,
        'wine-1',
      );

      serverWrite.complete();
      await pumpEventQueue();

      expect((await ledger.read()).journal, isEmpty);
      expect(events, isEmpty);
    },
  );

  test(
    'a server rejection marks the entry rejected and publishes it',
    () async {
      await create();

      serverWrite.completeError(firestoreError('permission-denied'));
      await pumpEventQueue();

      final state = await ledger.read();
      expect(state.rejectedEntriesOf('user-a').single.wineId, 'wine-1');
      final event = events.single as WriteRejected;
      expect(event.wineName, 'Barolo');
      expect(sink.reasons, ['SyncRejected']);
      expect(sink.recorded.single.error.message, isNot(contains('Barolo')));
    },
  );

  test(
    'unauthenticated keeps the entry open and expires the session',
    () async {
      await create();

      serverWrite.completeError(firestoreError('unauthenticated'));
      await pumpEventQueue();

      expect((await ledger.read()).openEntriesOf('user-a'), hasLength(1));
      expect(events.single, isA<SessionExpired>());
    },
  );

  test(
    'a transient error keeps the entry open and reports WriteFailed',
    () async {
      await create();

      serverWrite.completeError(firestoreError('internal'));
      await pumpEventQueue();

      expect((await ledger.read()).openEntriesOf('user-a'), hasLength(1));
      expect(events.single, isA<WriteFailed>());
      expect(sink.reasons, ['WriteFailed']);
    },
  );

  test('a callback from an older generation is ignored', () async {
    await create();
    await ledger.reset('user-b');

    serverWrite.completeError(firestoreError('permission-denied'));
    await pumpEventQueue();

    expect(events, isEmpty);
    expect(sink.reasons, isEmpty);
    expect((await ledger.read()).journal, isEmpty);
  });

  test(
    'a ledger failure returns SaveFailure and never writes Firestore',
    () async {
      store.failNextWrite = Exception('prefs unavailable');

      final outcome = await create();

      expect(outcome, isA<SaveFailure>());
      verifyNever(() => wineRef.set(any()));
      expect(writesStarted, 0);
      expect(sink.reasons, ['LedgerWriteFailed']);
    },
  );

  test(
    'a synchronous cache error returns SaveFailure and drops the entry',
    () async {
      when(() => wineRef.set(any())).thenThrow(StateError('cache closed'));

      final outcome = await create();

      expect(outcome, isA<SaveFailure>());
      expect((await ledger.read()).journal, isEmpty);
      expect(sink.reasons, ['LocalCacheWriteFailed']);
      expect(writesStarted, 0);
    },
  );

  group('incrementQuantity (BR3.4)', () {
    test('writes an increment, not an absolute value', () async {
      when(() => wineRef.update(any())).thenAnswer((_) async {});

      final outcome = await repository.incrementQuantity(
        cellarId: 'user-a',
        wineId: 'wine-1',
        wineName: 'Barolo',
        user: user,
        delta: -1,
      );

      expect(outcome, isA<SaveAccepted>());
      final update =
          verify(() => wineRef.update(captureAny())).captured.single
              as Map<Object, Object?>;
      expect(update['quantity'], isA<FieldValue>());
      expect(update['updatedBy'], 'user-a');
      expect((await ledger.read()).owner!.seq, 1);
    });

    test('a rejected increment is published without a journal entry', () async {
      final failing = Completer<void>();
      when(() => wineRef.update(any())).thenAnswer((_) => failing.future);

      await repository.incrementQuantity(
        cellarId: 'user-a',
        wineId: 'wine-1',
        wineName: 'Barolo',
        user: user,
        delta: 1,
      );
      failing.completeError(firestoreError('permission-denied'));
      await pumpEventQueue();

      expect(events.single, isA<WriteRejected>());
      expect((await ledger.read()).journal, isEmpty);
    });

    test('a zero delta is refused', () {
      expect(
        () => repository.incrementQuantity(
          cellarId: 'user-a',
          wineId: 'wine-1',
          wineName: 'Barolo',
          user: user,
          delta: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  test('watchCellarWines (u4 BR1.7: quantity > 0) sorts by name and '
      'exposes the metadata', () async {
    final collection = MockCollectionRef();
    final present = _MockQuery();
    final query = MockQuerySnapshot();
    MockQueryDocSnapshot doc(String id, String name) {
      final snapshot = MockQueryDocSnapshot();
      when(() => snapshot.id).thenReturn(id);
      when(() => snapshot.data()).thenReturn({
        'name': name,
        'quantity': 1,
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(0),
      });
      return snapshot;
    }

    when(() => db.collection('cellars/user-a/wines')).thenReturn(collection);
    when(() => collection.where('quantity', isGreaterThan: 0))
        .thenReturn(present);
    when(() => present.snapshots(includeMetadataChanges: true))
        .thenAnswer((_) => Stream.value(query));
    final docs = [doc('2', 'Barolo'), doc('1', 'Arneis')];
    when(() => query.docs).thenReturn(docs);
    final meta = metadata(pending: true, fromCache: true);
    when(() => query.metadata).thenReturn(meta);

    final snapshot = await repository.watchCellarWines('user-a').first;

    expect(snapshot.wines.map((w) => w.name), ['Arneis', 'Barolo']);
    expect(snapshot.wines.first.createdAt, DateTime.utc(1970));
    expect(snapshot.meta.hasPendingWrites, isTrue);
    expect(snapshot.meta.isFromCache, isTrue);
  });

  group('refusals in a shared cellar (u7-sharing BR1.7, BR1.14)', () {
    late MockDocRef sharedRef;
    late Completer<void> sharedWrite;

    setUp(() {
      sharedRef = MockDocRef();
      sharedWrite = Completer<void>();
      when(() => db.doc('cellars/user-z/wines/wine-1')).thenReturn(sharedRef);
      when(() => sharedRef.set(any())).thenAnswer((_) => sharedWrite.future);
      when(() => sharedRef.update(any())).thenAnswer((_) => sharedWrite.future);
    });

    test('BR1.14 a refused wine creation publishes WriteRejected and '
        'CellarAccessLost with the cellar of the path', () async {
      await repository.create(cellarId: 'user-z', user: user, draft: draft());

      sharedWrite.completeError(firestoreError('permission-denied'));
      await pumpEventQueue();

      expect(events, hasLength(2));
      expect((events[0] as WriteRejected).wineName, 'Barolo');
      final lost = events[1] as CellarAccessLost;
      expect(lost.cellarId, 'user-z');
      expect(lost.fromQueuedWrite, isTrue);
    });

    test('BR1.14 a refused increment publishes CellarAccessLost too', () async {
      await repository.incrementQuantity(
        cellarId: 'user-z',
        wineId: 'wine-1',
        wineName: 'Barolo',
        user: user,
        delta: -1,
      );
      sharedWrite.completeError(firestoreError('permission-denied'));
      await pumpEventQueue();

      expect(events.whereType<CellarAccessLost>().single.cellarId, 'user-z');
    });

    test('an invalid-argument refusal is not an access loss', () async {
      await repository.create(cellarId: 'user-z', user: user, draft: draft());

      sharedWrite.completeError(firestoreError('invalid-argument'));
      await pumpEventQueue();

      expect(events.single, isA<WriteRejected>());
    });
  });

  group('reportWriteRejected (u7-sharing security-design.md §4)', () {
    test('the personal cellar never gives CellarAccessLost', () {
      reportWriteRejected(
        bus,
        cellarId: 'user-a',
        uid: 'user-a',
        error: firestoreError('permission-denied'),
        wineId: 'w1',
        wineName: 'Barolo',
      );
      return pumpEventQueue().then((_) {
        expect(events.single, isA<WriteRejected>());
      });
    });

    test('without a wine only the access loss is published', () async {
      reportWriteRejected(
        bus,
        cellarId: 'user-z',
        uid: 'user-a',
        error: firestoreError('permission-denied'),
      );
      await pumpEventQueue();

      expect(events.single, isA<CellarAccessLost>());
    });
  });

  test('classifyWriteError maps the Firestore codes', () {
    for (final code in [
      'permission-denied',
      'invalid-argument',
      'failed-precondition',
    ]) {
      expect(classifyWriteError(firestoreError(code)), WriteErrorKind.rejected);
    }
    expect(
      classifyWriteError(firestoreError('unauthenticated')),
      WriteErrorKind.unauthenticated,
    );
    expect(
      classifyWriteError(firestoreError('resource-exhausted')),
      WriteErrorKind.transient,
    );
    expect(classifyWriteError(StateError('x')), WriteErrorKind.transient);
  });
}

// A test double of the SDK query (sealed in the SDK; tests only).
// ignore: subtype_of_sealed_class
class _MockQuery extends Mock implements Query<Map<String, dynamic>> {}
