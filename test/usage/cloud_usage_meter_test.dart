// freemium-plus FR6.1, FR6.4 (study §7.5, §7.11): the usage meter counts
// once where an operation starts or is confirmed. A listener shared by two
// screens counts once; cache and metadata snapshots count nothing; an empty
// query is one read and no bytes; a write only queued offline counts when
// the server confirms it; a server request that completes after the cache
// fallback counts once; system operations stay apart from the personal ones.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/data/server_or_cache.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';
import 'package:vinoozy/usage/cloud_usage_meter.dart';
import 'package:vinoozy/usage/domain/usage_counters.dart';
import 'package:vinoozy/usage/firestore_metering.dart';

import '../cellar/cellar_harness.dart';
import '../helpers/fakes.dart';
import '../helpers/firestore_mocks.dart';

class _MockChange extends Mock
    implements DocumentChange<Map<String, dynamic>> {}

void main() {
  setUpAll(registerFirestoreFallbacks);

  late InMemoryKeyValueStore store;
  late RecordingErrorSink sink;
  late FakeClock clock;
  late CloudUsageMeter meter;

  CloudUsageMeter newMeter() => CloudUsageMeter(
    store: store,
    reporter: recordingReporter(sink),
    clock: clock,
    ids: SequenceIdGenerator(prefix: 'install'),
  );

  setUp(() async {
    store = InMemoryKeyValueStore();
    sink = RecordingErrorSink();
    clock = FakeClock(DateTime.utc(2026, 11, 10, 12));
    meter = newMeter();
    await meter.start('user-a');
  });

  UsageCounters personal() =>
      meter.periods['2026-11']?.personal ?? UsageCounters.zero;
  UsageCounters system() =>
      meter.periods['2026-11']?.system ?? UsageCounters.zero;

  group('FR6.1 listeners', () {
    test('the same listener used by Cellar and Dashboard counts once', () {
      final cellar = meter.subscription(UsageScope.personal, key: 'wines/a');
      final dashboard = meter.subscription(UsageScope.personal, key: 'wines/a');

      for (final screen in [cellar, dashboard]) {
        screen.onQuerySnapshot(
          fromCache: false,
          documents: 3,
          changed: 3,
          removed: 0,
        );
      }

      expect(personal(), const UsageCounters(reads: 3, egressBytes: 6144));
    });

    test('a separate listener (the wine detail) counts its own reads', () {
      meter
          .subscription(UsageScope.personal, key: 'wines/a')
          .onQuerySnapshot(
            fromCache: false,
            documents: 2,
            changed: 2,
            removed: 0,
          );
      meter
          .subscription(UsageScope.personal, key: 'wine/a/w1')
          .onDocumentSnapshot(exists: true, fromCache: false);

      expect(personal().reads, 3);
    });

    test('cache and metadata-only snapshots add nothing', () {
      final listener = meter.subscription(UsageScope.personal, key: 'q');

      listener.onQuerySnapshot(
        fromCache: true,
        documents: 5,
        changed: 5,
        removed: 0,
      );
      expect(personal(), UsageCounters.zero);

      listener.onQuerySnapshot(
        fromCache: false,
        documents: 5,
        changed: 5,
        removed: 0,
      );
      listener.onQuerySnapshot(
        fromCache: false,
        documents: 5,
        changed: 0,
        removed: 0,
      );
      expect(personal(), const UsageCounters(reads: 5, egressBytes: 10240));
    });

    test('after the first server snapshot only the changes count', () {
      final listener = meter.subscription(UsageScope.personal);
      listener.onQuerySnapshot(
        fromCache: false,
        documents: 4,
        changed: 4,
        removed: 0,
      );

      listener.onQuerySnapshot(
        fromCache: false,
        documents: 3,
        changed: 1,
        removed: 2,
      );

      // 4 + 1 modified (2 KiB) + 2 that left the filter (no bytes).
      expect(personal(), const UsageCounters(reads: 7, egressBytes: 10240));
    });

    test('an empty query is one read and zero bytes', () {
      meter
          .subscription(UsageScope.personal)
          .onQuerySnapshot(
            fromCache: false,
            documents: 0,
            changed: 0,
            removed: 0,
          );
      meter.recordQuery(documents: 0);

      expect(personal(), const UsageCounters(reads: 2));
    });

    test('a closed shared listener lets the other one count', () {
      final first = meter.subscription(UsageScope.personal, key: 'q');
      final second = meter.subscription(UsageScope.personal, key: 'q');
      first.onQuerySnapshot(
        fromCache: false,
        documents: 1,
        changed: 1,
        removed: 0,
      );
      first.close();

      second.onQuerySnapshot(
        fromCache: false,
        documents: 2,
        changed: 1,
        removed: 0,
      );

      expect(personal().reads, 2, reason: '1 initial + 1 change, not 2 more');
    });

    test(
      'the adapter leaves out cache snapshots and pending changes',
      () async {
        QuerySnapshot<Map<String, dynamic>> snapshot({
          required bool fromCache,
          required List<(DocumentChangeType, bool)> changes,
          int documents = 2,
        }) {
          final query = MockQuerySnapshot();
          final queryMeta = metadata(fromCache: fromCache);
          when(() => query.metadata).thenReturn(queryMeta);
          final docs = [
            for (var i = 0; i < documents; i++) MockQueryDocSnapshot(),
          ];
          when(() => query.docs).thenReturn(docs);
          final docChanges = <DocumentChange<Map<String, dynamic>>>[];
          for (final (type, pending) in changes) {
            final change = _MockChange();
            final doc = MockQueryDocSnapshot();
            final docMeta = metadata(pending: pending);
            when(() => doc.metadata).thenReturn(docMeta);
            when(() => change.type).thenReturn(type);
            when(() => change.doc).thenReturn(doc);
            docChanges.add(change);
          }
          when(() => query.docChanges).thenReturn(docChanges);
          return query;
        }

        final source = Stream.fromIterable([
          snapshot(fromCache: true, changes: []),
          snapshot(
            fromCache: false,
            changes: [
              (DocumentChangeType.added, false),
              (DocumentChangeType.added, false),
            ],
          ),
          snapshot(
            fromCache: false,
            changes: [
              (DocumentChangeType.modified, true),
              (DocumentChangeType.modified, false),
              (DocumentChangeType.removed, false),
            ],
          ),
        ]);

        await meteredQuerySnapshots(source, meter, key: 'wines').toList();

        // 2 initial + 1 confirmed change + 1 removal; the pending one is local.
        expect(personal(), const UsageCounters(reads: 4, egressBytes: 6144));
      },
    );

    test('without a meter the stream is untouched', () {
      final source = Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
      expect(identical(meteredQuerySnapshots(source, null), source), isTrue);
    });
  });

  group('FR6.1 writes counted on the confirmation', () {
    test(
      'a write queued offline counts only when the server confirms it',
      () async {
        final db = MockFirestore();
        final pending = Completer<void>();
        final batches = BatchRecorder(
          db,
          commitWith: (_, result) => pending.future.then(
            result.complete,
            onError: result.completeError,
          ),
        );
        final repository = WineRepository(
          db: db,
          ledger: LocalLedger(
            store: InMemoryKeyValueStore(),
            reporter: recordingReporter(sink),
          ),
          bus: SyncErrorBus(),
          reporter: recordingReporter(sink),
          meter: meter,
        );

        await repository.addBottles(
          cellarId: 'user-a',
          user: cellarOwner,
          wine: cellarWine('w1', quantity: 0),
          n: 1,
        );
        await pumpEventQueue();
        expect(batches.single.committed, isTrue);
        expect(personal().writes, 0, reason: 'still in the offline queue');

        pending.complete();
        await pumpEventQueue();

        // The wine and the cellar counter (FR2.2): two documents updated.
        expect(personal().writes, 2);
      },
    );

    test('a refused write never counts', () async {
      final db = MockFirestore();
      BatchRecorder(
        db,
        commitWith: (_, result) =>
            result.completeError(firestoreError('invalid-argument')),
      );
      final repository = WineRepository(
        db: db,
        ledger: LocalLedger(
          store: InMemoryKeyValueStore(),
          reporter: recordingReporter(sink),
        ),
        bus: SyncErrorBus(),
        reporter: recordingReporter(sink),
        meter: meter,
      );

      await repository.removeBottle(
        cellarId: 'user-a',
        user: cellarOwner,
        wine: cellarWine('w1', quantity: 3),
      );
      await pumpEventQueue();

      expect(personal().writes, 0);
    });
  });

  group('FR6.1 server_or_cache', () {
    test(
      'a server answer that arrives after the cache fallback counts once',
      () async {
        final query = MockQuery();
        final server = Completer<QuerySnapshot<Map<String, dynamic>>>();
        when(() => query.get(any())).thenAnswer((invocation) {
          final options = invocation.positionalArguments.first as GetOptions;
          return options.source == Source.server
              ? server.future
              : Future.value(querySnapshotOf({'w1': {}}, fromCache: true));
        });

        final read = await readServerOrCache(
          query,
          const Duration(milliseconds: 1),
          meter: meter,
        );
        expect(read.fromServer, isFalse);
        expect(personal(), UsageCounters.zero);

        server.complete(querySnapshotOf({'w1': {}, 'w2': {}}));
        await pumpEventQueue();

        expect(personal(), const UsageCounters(reads: 2, egressBytes: 4096));
      },
    );

    test('a server answer in time counts once too', () async {
      final query = MockQuery();
      when(() => query.get(any())).thenAnswer((_) async => querySnapshotOf({}));

      await readServerOrCache(query, const Duration(seconds: 1), meter: meter);
      await pumpEventQueue();

      expect(personal(), const UsageCounters(reads: 1));
    });
  });

  group('FR6.4 system usage stays apart', () {
    test('migrations, estimates and deletions are system, not personal', () {
      meter.recordWrites(3, scope: UsageScope.system);
      meter.recordQuery(documents: 5, scope: UsageScope.system);
      meter.recordWrites(1);

      expect(personal(), const UsageCounters(writes: 1));
      expect(
        system(),
        const UsageCounters(reads: 5, writes: 3, egressBytes: 10240),
      );
    });
  });

  group('FR6.3 local persistence per account, installation and month', () {
    test(
      'the counters survive a restart; another account starts empty',
      () async {
        meter.recordWrites(2);
        await meter.flush();

        final restarted = newMeter();
        await restarted.start('user-a');
        expect(restarted.periods['2026-11']!.personal.writes, 2);
        expect(restarted.installationId, meter.installationId);

        final other = newMeter();
        await other.start('user-b');
        expect(other.periods, isEmpty);
      },
    );

    test('a new UTC month starts new counters and keeps the old ones', () {
      clock.current = DateTime.utc(2026, 11, 30, 23, 59);
      meter.recordWrites(1);
      clock.current = DateTime.utc(2026, 12, 1, 0, 1);
      meter.recordWrites(4);

      expect(meter.periods['2026-11']!.personal.writes, 1);
      expect(meter.periods['2026-12']!.personal.writes, 4);
    });

    test('the period follows the server time, not the phone clock', () {
      clock.current = DateTime.utc(2026, 11, 30, 23, 59);
      meter.serverOffset = const Duration(minutes: 5);

      meter.recordWrites(1);

      expect(meter.currentPeriod.id, '2026-12');
      expect(meter.periods.keys, ['2026-12']);
    });

    test('nothing is counted without a signed-in account', () async {
      await meter.stop();
      meter.recordWrites(1);
      expect(meter.periods, isEmpty);
    });

    test('a damaged saved value reads as no usage', () async {
      store.values['${CloudUsageMeter.storagePrefix}user-c'] =
          '{"2026-11": {"p": [1, -5, "x"]}, "bad": 3}';

      final damaged = newMeter();
      await damaged.start('user-c');

      expect(
        damaged.periods['2026-11']!.personal,
        const UsageCounters(reads: 1),
      );
      expect(damaged.periods.containsKey('bad'), isFalse);
    });

    test('a failed save is reported, never thrown', () async {
      store.failNextWrite = StateError('disk full');

      meter.recordWrites(1);
      await meter.flush();

      expect(sink.reasons, contains('UsageMeterSaveFailed'));
      expect(personal().writes, 1);
    });

    test('clear and forget drop the saved counters', () async {
      meter.recordWrites(1);
      await meter.forget('2026-11');
      expect(meter.periods, isEmpty);

      meter.recordWrites(1);
      await meter.clear('user-a');
      expect(meter.periods, isEmpty);
      expect(store.values['${CloudUsageMeter.storagePrefix}user-a'], '');
    });
  });
}
