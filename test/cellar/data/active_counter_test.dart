// freemium-plus FR2.1, FR2.2, FR2.5 (plan decision D1): every write path
// that changes whether a wine is active (quantity > 0) adds the counter of
// the owner's cellar to the same batch, and only then; a refusal by the
// rules becomes a recoverable draft with its reason, and a counter conflict
// is retried once with the wine read again from the server.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/data/active_wine_counter.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/data/pending_writes_probe.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine_estimate.dart';
import 'package:vinoozy/cellar/domain/wine_validator.dart';
import 'package:vinoozy/sync/capacity_rejection.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../../helpers/fakes.dart';
import '../../helpers/firestore_mocks.dart';
import '../cellar_harness.dart';

void main() {
  setUpAll(registerFirestoreFallbacks);

  const user = cellarOwner;
  late MockFirestore db;
  late BatchRecorder batches;
  late LocalLedger ledger;
  late RecordingErrorSink sink;
  late SyncErrorBus bus;
  late List<SyncEvent> events;
  late bool limitOn;
  late WineRepository wines;
  late DrinkingRecordRepository drinks;

  String path(String id) => 'cellars/user-a/wines/$id';

  setUp(() {
    db = MockFirestore();
    batches = BatchRecorder(db);
    sink = RecordingErrorSink();
    ledger = LocalLedger(
      store: InMemoryKeyValueStore(),
      reporter: recordingReporter(sink),
    );
    bus = SyncErrorBus();
    events = [];
    bus.events.listen(events.add);
    limitOn = false;
    final counter = ActiveWineCounter(
      db: db,
      capacityLimitEnabled: () => limitOn,
    );
    wines = WineRepository(
      db: db,
      ledger: ledger,
      bus: bus,
      reporter: recordingReporter(sink),
      counter: counter,
    );
    drinks = DrinkingRecordRepository(
      db: db,
      ledger: ledger,
      bus: bus,
      reporter: recordingReporter(sink),
      probe: PendingWritesProbe(
        waitForPendingWrites: () async {},
        onPendingChanged: (_) {},
        reporter: recordingReporter(sink),
      ),
      ids: SequenceIdGenerator(prefix: 'r'),
      counter: counter,
    );
  });

  /// The counter update of the batch, or null when it carries none.
  Map<String, Object?>? counterOf(RecordingBatch batch) {
    final ops = batch.ops.where((op) => op.path == 'cellars/user-a');
    return ops.isEmpty ? null : ops.single.data;
  }

  Map<String, Object?> moved(int delta, String wineId) => {
    'activeWineCount': FieldValue.increment(delta),
    'activeOpWineId': wineId,
  };

  /// The wine as the server holds it after a refusal: [quantity], or missing
  /// when null.
  void serverHas(String wineId, int? quantity, {String cellarId = 'user-a'}) {
    final winePath = 'cellars/$cellarId/wines/$wineId';
    final ref = MockDocRef();
    when(() => ref.path).thenReturn(winePath);
    when(() => ref.get(any())).thenAnswer(
      (_) async => quantity == null
          ? docSnapshot(exists: false)
          : docSnapshot(exists: true, data: {'quantity': quantity}),
    );
    when(() => db.doc(winePath)).thenReturn(ref);
  }

  group('FR2.1 FR2.2 pure rules', () {
    test('active means quantity > 0; a missing wine is not active', () {
      expect(isActiveQuantity(1), isTrue);
      expect(isActiveQuantity(0), isFalse);
      expect(isActiveQuantity(-1), isFalse);
      expect(isActiveQuantity(null), isFalse);
      expect(activeDelta(null, 2), 1);
      expect(activeDelta(0, 2), 1);
      expect(activeDelta(-1, 1), 1);
      expect(activeDelta(1, 0), -1);
      expect(activeDelta(3, null), -1);
      expect(activeDelta(6, 7), 0);
      expect(activeDelta(0, -1), 0);
    });
  });

  group('FR2.2 every write path carries the right delta, and only then', () {
    test('a new wine: +1', () async {
      await wines.addWine(
        cellarId: 'user-a',
        user: user,
        draft: WineValidator.validate(
          const WineInput(
            id: 'w9',
            name: 'Barolo',
            vintage: '2016',
            noVintage: false,
            quantity: 6,
          ),
          currentYear: 2026,
        ).draft!,
      );

      expect(batches.single.opAt(path('w9')).kind, 'set');
      expect(counterOf(batches.single), moved(1, 'w9'));
    });

    test('more bottles of an active wine: no counter (6 bottles = 1 slot)', () {
      return wines
          .addBottles(
            cellarId: 'user-a',
            user: user,
            wine: cellarWine('w1', quantity: 6),
            n: 2,
          )
          .then((_) => expect(counterOf(batches.single), isNull));
    });

    test('bottles added to a finished wine, even a negative one: +1', () async {
      await wines.addBottles(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1', quantity: 0),
        n: 2,
      );
      await wines.addBottles(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w2', quantity: -1),
        n: 1,
      );

      expect(counterOf(batches.batches[0]), moved(1, 'w1'));
      expect(
        batches.batches[1].opAt(path('w2')).data!['quantity'],
        FieldValue.increment(2),
      );
      expect(counterOf(batches.batches[1]), moved(1, 'w2'));
    });

    test('"−" on the last bottle: -1; on 3 bottles: nothing', () async {
      await wines.removeBottle(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1', quantity: 1),
      );
      await wines.removeBottle(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w2', quantity: 3),
      );

      expect(counterOf(batches.batches[0]), moved(-1, 'w1'));
      expect(counterOf(batches.batches[1]), isNull);
    });

    test(
      'the edit form: to 0 is -1, from 0 is +1, the same is nothing',
      () async {
        final draft = WineValidator.validate(
          const WineInput(
            id: 'w1',
            name: 'Barolo',
            vintage: '2016',
            noVintage: false,
            quantity: 1,
          ),
          currentYear: 2026,
        ).draft!;
        Future<void> edit(int stored, int target) => wines.updateWine(
          cellarId: 'user-a',
          user: user,
          before: cellarWine('w1', quantity: stored),
          draft: draft,
          targetQuantity: target,
          estimate: WineEstimate.none,
        );

        await edit(2, 0);
        await edit(0, 3);
        await edit(4, 4);

        expect(counterOf(batches.batches[0]), moved(-1, 'w1'));
        expect(counterOf(batches.batches[1]), moved(1, 'w1'));
        expect(counterOf(batches.batches[2]), isNull);
        expect(
          batches.batches[2].opAt(path('w1')).data!.containsKey('quantity'),
          isFalse,
        );
      },
    );

    test(
      'a merge of two active entries is one batch: -1 for the newer',
      () async {
        await wines.mergeInto(
          cellarId: 'user-a',
          user: user,
          older: cellarWine('old', quantity: 2),
          newer: cellarWine('new', quantity: 1),
        );

        final batch = batches.single;
        expect(
          batch.opAt(path('old')).data!['quantity'],
          FieldValue.increment(1),
        );
        expect(batch.opAt(path('new')).kind, 'delete');
        expect(counterOf(batch), moved(-1, 'new'));
      },
    );

    test('a merge with a finished newer entry carries no counter', () async {
      await wines.mergeInto(
        cellarId: 'user-a',
        user: user,
        older: cellarWine('old', quantity: 2),
        newer: cellarWine('new', quantity: 0),
      );

      expect(counterOf(batches.single), isNull);
    });

    test('deleting a finished wine carries no counter', () async {
      final records = MockQuery();
      final collection = MockCollectionRef();
      when(() => db.collection('cellars/user-a/drinkingRecords'))
          .thenReturn(collection);
      when(() => collection.where('wineId', isEqualTo: 'w1'))
          .thenReturn(records);
      when(() => records.get(any()))
          .thenAnswer((_) async => querySnapshotOf({}));

      expect(
        await wines.deleteWineWithRecords(
          cellarId: 'user-a',
          user: user,
          wine: cellarWine('w1', quantity: 0),
        ),
        DeleteOutcome.deleted,
      );
      expect(batches.single.ops.single.kind, 'delete');
    });

    test('"Drunk" on the last bottle: -1; on 3 bottles: nothing', () async {
      await drinks.drink(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1', quantity: 1),
        today: DateTime(2026, 11, 10),
      );
      await drinks.drink(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w2', quantity: 3),
        today: DateTime(2026, 11, 10),
      );

      expect(counterOf(batches.batches[0]), moved(-1, 'w1'));
      expect(counterOf(batches.batches[1]), isNull);
    });

    test('"Undo" of the last bottle: +1; of one of several: nothing', () async {
      final record = MockDocRef();
      when(() => record.path).thenReturn('cellars/user-a/drinkingRecords/r-1');
      when(() => record.get(any())).thenAnswer(
        (_) async => docSnapshot(exists: true, data: {'wineId': 'w1'}),
      );
      when(() => db.doc('cellars/user-a/drinkingRecords/r-1'))
          .thenReturn(record);
      Future<void> undo(int stored) => drinks.undo(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1', quantity: stored),
        recordId: 'r-1',
      );

      await undo(0);
      await undo(2);

      expect(counterOf(batches.batches[0]), moved(1, 'w1'));
      expect(counterOf(batches.batches[1]), isNull);
    });
  });

  group('FR2.5 a refusal becomes a recoverable draft with its reason', () {
    test('a new wine refused while the limit is on stays as a draft with '
        '"capacityLimit", never as synced', () async {
      limitOn = true;
      // A cellar shared with the user: the refusal is the owner's plan.
      serverHas('w9', null, cellarId: 'user-z');
      batches.commitWith = (_, result) =>
          result.completeError(firestoreError('permission-denied'));

      await wines.addWine(
        cellarId: 'user-z',
        user: user,
        draft: WineValidator.validate(
          const WineInput(
            id: 'w9',
            name: 'Barolo',
            vintage: '2016',
            noVintage: false,
            quantity: 1,
          ),
          currentYear: 2026,
        ).draft!,
      );
      await pumpEventQueue();

      final entry = (await ledger.read()).rejectedEntriesOf('user-a').single;
      expect(entry.wineId, 'w9');
      expect(entry.reason, CapacityRejection.capacityLimit);
      final rejected = events.whereType<WriteRejected>().single;
      expect(rejected.reason, CapacityRejection.capacityLimit);
      // The owner's plan, not a lost access to the shared cellar.
      expect(events.whereType<CellarAccessLost>(), isEmpty);
    });

    test(
      'a refused reactivation with the limit off is a plain refusal',
      () async {
        serverHas('w1', 0);
        batches.commitWith = (_, result) =>
            result.completeError(firestoreError('permission-denied'));

        await wines.addBottles(
          cellarId: 'user-a',
          user: user,
          wine: cellarWine('w1', quantity: 0),
          n: 1,
        );
        await pumpEventQueue();

        expect(events.whereType<WriteRejected>().single.reason, isNull);
        expect(
          batches.batches,
          hasLength(1),
          reason: 'no retry without conflict',
        );
      },
    );

    test('D1 a conflict is retried once with the server quantity', () async {
      // The phone saw 0 and sent +1; another device already brought the wine
      // back to 1, so the rules refused the counter. Read again: the retry
      // adds the bottles without the counter, and passes.
      serverHas('w1', 1);
      batches.commitWith = (index, result) => index == 0
          ? result.completeError(firestoreError('permission-denied'))
          : result.complete();

      await wines.addBottles(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1', quantity: 0),
        n: 2,
      );
      await pumpEventQueue();

      expect(batches.batches, hasLength(2));
      expect(counterOf(batches.batches[0]), moved(1, 'w1'));
      expect(counterOf(batches.batches[1]), isNull);
      expect(
        batches.batches[1].opAt(path('w1')).data!['quantity'],
        FieldValue.increment(2),
      );
      expect(events, isEmpty);
    });

    test('D1 a conflict refused again is "capacityConflict"', () async {
      serverHas('w1', 2);
      batches.commitWith = (_, result) =>
          result.completeError(firestoreError('permission-denied'));

      await wines.removeBottle(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1', quantity: 1),
      );
      await pumpEventQueue();

      expect(batches.batches, hasLength(2), reason: 'one retry only');
      expect(
        events.whereType<WriteRejected>().single.reason,
        CapacityRejection.capacityConflict,
      );
    });

    test(
      'a refused "Undo" over the limit is explained, not a late Undo',
      () async {
        limitOn = true;
        serverHas('w1', 0);
        final record = MockDocRef();
        when(() => record.path)
            .thenReturn('cellars/user-a/drinkingRecords/r-1');
        when(() => record.get(any())).thenAnswer(
          (_) async => docSnapshot(exists: true, data: {'wineId': 'w1'}),
        );
        when(() => db.doc('cellars/user-a/drinkingRecords/r-1'))
            .thenReturn(record);
        batches.commitWith = (_, result) =>
            result.completeError(firestoreError('permission-denied'));

        await drinks.undo(
          cellarId: 'user-a',
          user: user,
          wine: cellarWine('w1', quantity: 0),
          recordId: 'r-1',
        );
        await pumpEventQueue();

        expect(
          events.whereType<WriteRejected>().single.reason,
          CapacityRejection.capacityLimit,
        );
        expect(events.whereType<CellarNotice>(), isEmpty);
      },
    );

    test('a server that cannot be read keeps the original refusal', () async {
      batches.commitWith = (_, result) =>
          result.completeError(firestoreError('permission-denied'));
      limitOn = true;

      // db.doc() of the wine is a FakeDocRef that cannot read: no reason is
      // invented.
      await wines.addBottles(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1', quantity: 0),
        n: 1,
      );
      await pumpEventQueue();

      expect(events.whereType<WriteRejected>().single.reason, isNull);
    });
  });

  group('FR2.5 the reason in the local ledger', () {
    test('kept across a restart, cleared when the entry opens again', () async {
      final store = InMemoryKeyValueStore();
      final first = LocalLedger(
        store: store,
        reporter: recordingReporter(sink),
      );
      await first.beginWrite(
        uid: 'user-a',
        email: 'a@example.com',
        entry: const JournalEntry(
          wineId: 'w1',
          cellarId: 'user-a',
          name: 'Barolo',
          ownerUid: 'user-a',
        ),
      );
      await first.markRejected('w1', reason: CapacityRejection.capacityLimit);

      final again = LocalLedger(
        store: store,
        reporter: recordingReporter(sink),
      );
      expect(
        (await again.read()).journal.single.reason,
        CapacityRejection.capacityLimit,
      );
      await again.reopen('w1');
      expect((await again.read()).journal.single.reason, isNull);
    });

    test('an unknown reason from a newer version reads as none', () {
      final entry = JournalEntry.fromJson({
        'wineId': 'w1',
        'cellarId': 'user-a',
        'name': 'Barolo',
        'ownerUid': 'user-a',
        'state': 'rejected',
        'notices': 0,
        'reason': 'somethingNew',
      });
      expect(entry.reason, isNull);
      expect(entry.toJson().containsKey('reason'), isFalse);
    });
  });
}
