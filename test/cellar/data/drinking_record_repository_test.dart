// DrinkingRecordRepository (logical-components.md; BR1.10, BR1.11, BR1.16;
// NFR6.5, NFR8.2; security-design.md §4): the drink and undo batches, the
// undo refused without a false lost access, the History pages.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/data/pending_writes_probe.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../../helpers/fakes.dart';
import '../../helpers/firestore_mocks.dart';
import '../cellar_harness.dart';

void main() {
  setUpAll(() {
    registerFirestoreFallbacks();
    registerFallbackValue(MockDocSnapshot());
  });

  late MockFirestore db;
  late BatchRecorder batches;
  late RecordingErrorSink sink;
  late SyncErrorBus bus;
  late List<SyncEvent> events;
  late List<bool> pendingChanges;
  late Completer<void> queueConfirmed;
  late DrinkingRecordRepository repository;

  setUp(() {
    db = MockFirestore();
    batches = BatchRecorder(db);
    sink = RecordingErrorSink();
    bus = SyncErrorBus();
    events = [];
    bus.events.listen(events.add);
    pendingChanges = [];
    queueConfirmed = Completer<void>();
    repository = DrinkingRecordRepository(
      db: db,
      ledger: LocalLedger(
        store: InMemoryKeyValueStore(),
        reporter: recordingReporter(sink),
      ),
      bus: bus,
      reporter: recordingReporter(sink),
      probe: PendingWritesProbe(
        waitForPendingWrites: () => queueConfirmed.future,
        onPendingChanged: pendingChanges.add,
        reporter: recordingReporter(sink),
      ),
      ids: SequenceIdGenerator(prefix: 'r'),
    );
  });

  const winePath = 'cellars/user-a/wines/w1';
  const recordPath = 'cellars/user-a/drinkingRecords/r-1';

  group('BR1.10 drink', () {
    test('BR1.10 one batch: quantity −1 and the record dated today', () async {
      final outcome = await repository.drink(
        cellarId: 'user-a',
        user: cellarEditor,
        wine: cellarWine('w1', quantity: 3),
        today: DateTime(2026, 11, 6, 21, 30),
      );

      expect((outcome as DrinkAccepted).recordId, 'r-1');
      final batch = batches.single;
      expect(batch.opAt(winePath).data!['quantity'], FieldValue.increment(-1));
      expect(batch.opAt(winePath).data!['updatedBy'], 'user-c');
      final record = batch.opAt(recordPath);
      expect(record.kind, 'set');
      expect(record.data, {
        'wineId': 'w1',
        'wineName': 'Barolo',
        'vintage': 2016,
        'drankOn': '2026-11-06',
        'recordedBy': 'user-c',
        'createdAt': FieldValue.serverTimestamp(),
      });
      expect(pendingChanges, [true], reason: 'banner pending until confirmed');

      queueConfirmed.complete();
      await pumpEventQueue();
      expect(pendingChanges, [true, false]);
    });

    test('BR1.10 refused while the shown quantity is 0', () async {
      for (final stored in [0, -2]) {
        final outcome = await repository.drink(
          cellarId: 'user-a',
          user: cellarEditor,
          wine: cellarWine('w1', quantity: stored),
          today: DateTime(2026, 11, 6),
        );
        expect(outcome, isA<DrinkFailed>());
      }
      expect(batches.batches, isEmpty);
    });

    test(
      'NFR8.2 a refused drink in a shared cellar: fixed reason, no markers',
      () async {
        batches.commitWith = (_, result) =>
            result.completeError(firestoreError('permission-denied'));

        await repository.drink(
          cellarId: 'user-a',
          user: cellarEditor,
          wine: cellarWine(
            'w1',
            name: sensitiveMarkers[0],
            producer: sensitiveMarkers[1],
            denomination: sensitiveMarkers[2],
          ),
          today: DateTime(2026, 11, 6),
        );
        await pumpEventQueue();

        expect(sink.reasons, ['cellar_drink_failed']);
        for (final marker in sensitiveMarkers) {
          expect('${sink.recorded.single.error}', isNot(contains(marker)));
        }
        expect(events.whereType<WriteRejected>(), hasLength(1));
        expect(events.whereType<CellarAccessLost>().single.cellarId, 'user-a');
      },
    );
  });

  group('BR1.10 NFR6.5 undo', () {
    late MockDocRef recordRef;

    setUp(() {
      recordRef = MockDocRef();
      when(() => recordRef.path).thenReturn(recordPath);
      when(() => db.doc(recordPath)).thenReturn(recordRef);
    });

    Future<UndoResult> undo({int stored = 1}) => repository.undo(
      cellarId: 'user-a',
      user: cellarEditor,
      wine: cellarWine('w1', quantity: stored),
      recordId: 'r-1',
    );

    test(
      'BR1.10 the drink in the cache: deleted and +1 in one batch',
      () async {
        when(() => recordRef.get(any())).thenAnswer((invocation) async {
          final options = invocation.positionalArguments.first as GetOptions;
          expect(options.source, Source.cache);
          return docSnapshot(exists: true, data: {'wineId': 'w1'});
        });

        expect(await undo(stored: -1), UndoResult.undone);

        final batch = batches.single;
        expect(batch.opAt(recordPath).kind, 'delete');
        expect(batch.opAt(winePath).data!['quantity'], FieldValue.increment(2));
      },
    );

    test('NFR6.5 a drink no longer there: nothing to undo, no write', () async {
      when(() => recordRef.get(any()))
          .thenAnswer((_) async => docSnapshot(exists: false));
      expect(await undo(), UndoResult.nothingToUndo);

      when(() => recordRef.get(any())).thenThrow(firestoreError('unavailable'));
      expect(await undo(), UndoResult.nothingToUndo);

      expect(batches.batches, isEmpty);
    });

    test(
      'BR1.10 a refused undo is not a lost access (security-design §4)',
      () async {
        when(() => recordRef.get(any())).thenAnswer(
          (_) async => docSnapshot(exists: true, data: {'wineId': 'w1'}),
        );
        batches.commitWith = (_, result) =>
            result.completeError(firestoreError('permission-denied'));

        expect(await undo(), UndoResult.undone);
        await pumpEventQueue();

        expect(sink.reasons, ['cellar_undo_failed']);
        expect(events, hasLength(1));
        expect(
          (events.single as CellarNotice).kind,
          CellarNoticeKind.undoRejected,
        );
      },
    );
  });

  group('BR1.11 updateRecord', () {
    test(
      'BR1.11 rating, trimmed notes, date, condition and updatedAt',
      () async {
        final outcome = await repository.updateRecord(
          cellarId: 'user-a',
          user: cellarEditor,
          record: drinkRecord('r7'),
          rating: 5,
          notes: '  Splendido  ',
          drankOn: DateTime(2026, 11, 5),
          condition: DrinkCondition.justRight,
        );

        expect(outcome, isA<SaveAccepted>());
        expect(batches.single.opAt('cellars/user-a/drinkingRecords/r7').data, {
          'rating': 5,
          'notes': 'Splendido',
          'drankOn': '2026-11-05',
          'condition': 'justRight',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      },
    );

    test('BR1.11 empty notes and no answer are written as null', () async {
      await repository.updateRecord(
        cellarId: 'user-a',
        user: cellarEditor,
        record: drinkRecord('r7'),
        rating: null,
        notes: '   ',
        drankOn: DateTime(2026, 11, 5),
        condition: null,
      );

      final data = batches.single
          .opAt('cellars/user-a/drinkingRecords/r7')
          .data!;
      expect(data['notes'], isNull);
      expect(data['condition'], isNull);
      expect(data['rating'], isNull);
    });

    test('NFR8.2 a refused update keeps the notes out of the report', () async {
      batches.commitWith = (_, result) =>
          result.completeError(firestoreError('invalid-argument'));

      await repository.updateRecord(
        cellarId: 'user-a',
        user: cellarEditor,
        record: drinkRecord('r7', notes: sensitiveMarkers[3]),
        rating: 3,
        notes: sensitiveMarkers[3],
        drankOn: DateTime(2026, 11, 5),
        condition: null,
      );
      await pumpEventQueue();

      expect(sink.reasons, ['cellar_record_update_failed']);
      expect(
        '${sink.recorded.single.error}',
        isNot(contains(sensitiveMarkers[3])),
      );
    });
  });

  group('BR1.16 NFR5.2 pageHistory', () {
    late MockCollectionRef collection;
    late MockQuery byDay;
    late MockQuery byTime;
    late MockQuery after;
    late MockQuery limited;

    setUp(() {
      collection = MockCollectionRef();
      byDay = MockQuery();
      byTime = MockQuery();
      after = MockQuery();
      limited = MockQuery();
      when(() => db.collection('cellars/user-a/drinkingRecords'))
          .thenReturn(collection);
      when(() => collection.orderBy('drankOn', descending: true))
          .thenReturn(byDay);
      when(() => byDay.orderBy('createdAt', descending: true))
          .thenReturn(byTime);
      when(() => byTime.startAfterDocument(any())).thenReturn(after);
      when(() => byTime.limit(30)).thenReturn(limited);
      when(() => after.limit(30)).thenReturn(limited);
    });

    test(
      'BR1.16 a page of 30 by drankOn then createdAt, with a cursor',
      () async {
        when(() => limited.get(any())).thenAnswer(
          (_) async => querySnapshotOf({
            for (var i = 0; i < 30; i++)
              'r$i': {
                'wineId': 'w1',
                'wineName': 'Barolo',
                'drankOn': '2026-11-06',
              },
          }),
        );

        final page = await repository.pageHistory('user-a');

        expect(page.records, hasLength(30));
        expect(page.hasMore, isTrue);
        expect(page.cursor, isNotNull);

        final next = await repository.pageHistory('user-a', after: page.cursor);
        verify(() => byTime.startAfterDocument(page.cursor!.lastDocument))
            .called(1);
        expect(next.records, hasLength(30));
      },
    );

    test(
      'BR1.16 a short page has nothing after it; bad documents are skipped',
      () async {
        when(() => limited.get(any())).thenAnswer(
          (_) async => querySnapshotOf({
            'r1': {'wineId': 'w1', 'drankOn': '2026-11-06'},
            'bad': {'wineId': 'w1', 'drankOn': 'yesterday'},
          }),
        );

        final page = await repository.pageHistory('user-a');

        expect(page.records.map((r) => r.id), ['r1']);
        expect(page.hasMore, isFalse);
      },
    );

    test('BR1.16 an empty history has no cursor', () async {
      when(() => limited.get(any()))
          .thenAnswer((_) async => querySnapshotOf({}));

      final page = await repository.pageHistory('user-a');

      expect(page.records, isEmpty);
      expect(page.cursor, isNull);
    });
  });

  group('BR1.12 recordsOfWine', () {
    late MockQuery query;

    setUp(() {
      final collection = MockCollectionRef();
      query = MockQuery();
      when(() => db.collection('cellars/user-a/drinkingRecords'))
          .thenReturn(collection);
      when(() => collection.where('wineId', isEqualTo: 'w1')).thenReturn(query);
    });

    test(
      'BR1.12 sorted most recent first, from the server or the cache',
      () async {
        var serverUp = true;
        when(() => query.get(any())).thenAnswer((invocation) async {
          final options = invocation.positionalArguments.first as GetOptions;
          if (options.source == Source.server && !serverUp) {
            throw firestoreError('unavailable');
          }
          return querySnapshotOf({
            'a': {'wineId': 'w1', 'drankOn': '2026-01-01'},
            'b': {'wineId': 'w1', 'drankOn': '2026-03-01'},
          });
        });

        final online = await repository.recordsOfWine('user-a', 'w1');
        expect(online.records.map((r) => r.id), ['b', 'a']);
        expect(online.fromServer, isTrue);

        serverUp = false;
        final offline = await repository.recordsOfWine('user-a', 'w1');
        expect(offline.fromServer, isFalse);

        final cache = await repository.recordsOfWine(
          'user-a',
          'w1',
          source: RecordsSource.cache,
        );
        expect(cache.records, hasLength(2));
        expect(
          () => repository.recordsOfWine(
            'user-a',
            'w1',
            source: RecordsSource.server,
          ),
          throwsA(isA<FirebaseException>()),
        );
      },
    );
  });

  test('a ledger failure stops the write and reports it', () async {
    final store = InMemoryKeyValueStore()..failReads = StateError('disk');
    final broken = DrinkingRecordRepository(
      db: db,
      ledger: LocalLedger(store: store, reporter: recordingReporter(sink)),
      bus: bus,
      reporter: recordingReporter(sink),
      probe: PendingWritesProbe(
        waitForPendingWrites: () async {},
        onPendingChanged: (_) {},
        reporter: recordingReporter(sink),
      ),
      ids: SequenceIdGenerator(),
    );

    final outcome = await broken.updateRecord(
      cellarId: 'user-a',
      user: cellarEditor,
      record: drinkRecord('r1'),
      rating: 1,
      notes: null,
      drankOn: DateTime(2026, 11, 6),
      condition: null,
    );

    expect(outcome, isA<SaveFailure>());
    expect(batches.batches, isEmpty);
  });
}
