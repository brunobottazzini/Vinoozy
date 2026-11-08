// The one-off estimate with the new tables (label-autofill-windows BR3.9,
// NFR4.4, NFR4.7, NFR4.8, NFR4.8a, NFR4.16) on the real WineRepository with a
// recorded Firestore: online, offline (writes that never reach the server),
// refused by old rules in production, two people, 1000 wines, interrupted.
import 'dart:async';

import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/app_event_logger.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/data/record_reconciler.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/estimate_refresher.dart';
import 'package:vinoozy/cellar/estimates_migration.dart';
import 'package:vinoozy/cellar/wine_estimator.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../helpers/fakes.dart';
import '../helpers/firestore_mocks.dart';
import 'cellar_harness.dart';

class _Logger implements AppEventLogger {
  final List<(int, int)> migrated = [];

  @override
  void autofillResult(AutofillOrigin origin, AutofillOutcome outcome, int n) {}

  @override
  void lensOpen(LensOpenResult result) {}

  @override
  void estimatesMigrated(int wineCount, int durationMs) =>
      migrated.add((wineCount, durationMs));
}

/// A window of the u2 tables: internal, no version.
final _old = windowOf(2024, 2031, 2046);

Wine _oldWine(String id, {WineLevel? level, WindowOverride? override}) =>
    cellarWine(
      id,
      name: 'Pauillac',
      vintage: 2016,
      wineType: 'redStructured',
      window: _old,
      baseWindow: _old,
      level: level,
      windowOverride: override,
    );

void main() {
  setUpAll(registerFirestoreFallbacks);

  late MockFirestore db;
  late BatchRecorder batches;
  late RecordingErrorSink sink;
  late SyncErrorBus bus;
  late List<SyncEvent> events;
  late WineRepository repository;
  late MemoryMigrationAttemptStore store;
  late _Logger logger;
  late FakeClock clock;

  setUp(() {
    db = MockFirestore();
    batches = BatchRecorder(db);
    sink = RecordingErrorSink();
    bus = SyncErrorBus();
    events = [];
    bus.events.listen(events.add);
    repository = WineRepository(
      db: db,
      ledger: LocalLedger(
        store: InMemoryKeyValueStore(),
        reporter: recordingReporter(sink),
      ),
      bus: bus,
      reporter: recordingReporter(sink),
    );
    store = MemoryMigrationAttemptStore();
    logger = _Logger();
    clock = FakeClock(DateTime(2026, 11, 8));
  });

  EstimatesMigration newStart() => EstimatesMigration(
    wines: repository,
    reporter: recordingReporter(sink),
    clock: clock,
    store: store,
    logger: logger,
  );

  Map<String, Object?> written(int i) => batches.batches[i].ops.single.data!;

  group('needsMigration', () {
    test('internal windows of older tables only', () {
      expect(EstimatesMigration.needsMigration(_oldWine('w1')), isTrue);
      final current = estimateWindow(
        const WineFacts(name: 'Pauillac', vintage: 2016),
      );
      expect(
        EstimatesMigration.needsMigration(
          cellarWine('w2', window: current, baseWindow: current),
        ),
        isFalse,
      );
      final catalog = windowOf(2020, 2025, 2035, source: WindowSource.catalog);
      expect(
        EstimatesMigration.needsMigration(
          cellarWine('w3', window: catalog, baseWindow: catalog),
        ),
        isFalse,
      );
      expect(EstimatesMigration.needsMigration(cellarWine('w4')), isFalse);
      expect(
        EstimatesMigration.needsMigration(_oldWine('w5'), version: 1),
        isTrue,
      );
    });
  });

  group('NFR4.8a online', () {
    test('BR3.9 each old wine is written once, with the new version, its '
        'level and its correction (BR3.8, BR4.4)', () async {
      final migration = newStart();
      final wines = [
        _oldWine('w1'),
        _oldWine('w2', level: WineLevel.aging),
        _oldWine('w3', override: const WindowOverride(endYear: 2035)),
      ];

      final count = await migration.run(ownerCellar, cellarOwner, wines);
      await pumpEventQueue();

      expect(count, 3);
      expect(batches.batches, hasLength(3));
      final first = written(0);
      expect(
        (first[WineFields.window]! as Map)[WindowFields.tablesVersion],
        estimationTablesVersion,
      );
      expect(
        (first[WineFields.window]! as Map)[WindowFields.denominationKey],
        'pauillac',
      );
      // aging on Pauillac 8/15/30 from 2016: 10/20/42.
      final aging = written(1)[WineFields.baseWindow]! as Map;
      expect(aging[WindowFields.endYear], 2058);
      final corrected = written(2);
      expect(
        (corrected[WineFields.window]! as Map)[WindowFields.endYear],
        2035,
      );
      expect(
        (corrected[WineFields.baseWindow]! as Map)[WindowFields.endYear],
        2046,
      );
      expect(corrected.containsKey(WineFields.windowOverride), isFalse);
      expect(logger.migrated.single.$1, 3);
      expect(sink.reasons, isEmpty);
    });

    test('a wine already on the new tables, a catalog window and a reader '
        'write nothing', () async {
      final migration = newStart();
      final current = estimateWindow(
        const WineFacts(name: 'Pauillac', vintage: 2016),
      );
      final catalog = windowOf(2020, 2025, 2035, source: WindowSource.catalog);

      expect(
        await migration.run(ownerCellar, cellarOwner, [
          cellarWine('w1', window: current, baseWindow: current),
          cellarWine('w2', window: catalog, baseWindow: catalog),
        ]),
        0,
      );
      expect(
        await migration.run(readCellar, cellarEditor, [_oldWine('w3')]),
        0,
      );
      expect(batches.batches, isEmpty);
    });

    test(
      'catalog pairings are kept, internal ones follow the tables',
      () async {
        final migration = newStart();
        const catalogPairings = Pairings(
          items: ['Arrosto'],
          categoryKeys: [],
          source: WindowSource.catalog,
        );
        await migration.run(ownerCellar, cellarOwner, [
          cellarWine(
            'w1',
            name: 'Pauillac',
            window: _old,
            baseWindow: _old,
            pairings: catalogPairings,
          ),
        ]);
        final pairings = written(0)[WineFields.pairings]! as Map;
        expect(pairings[PairingsFields.items], ['Arrosto']);
      },
    );
  });

  group('NFR4.8a offline', () {
    test('the writes wait in the queue: the run does not wait for the server '
        'and counts them', () async {
      batches.commitWith = (_, result) {}; // never confirmed
      final migration = newStart();

      final count = await migration.run(ownerCellar, cellarOwner, [
        _oldWine('w1'),
        _oldWine('w2'),
      ]);

      expect(count, 2);
      expect(batches.batches.every((b) => b.committed), isTrue);
      expect(sink.reasons, isEmpty);
    });

    test('NFR4.8 an interrupted run continues at the next start with the '
        'wines still on old tables', () async {
      final first = newStart();
      await first.run(ownerCellar, cellarOwner, [_oldWine('w1')]);
      // The app closed: w1 is now on the new tables, w2 not yet.
      final migrated = estimateWindow(
        const WineFacts(name: 'Pauillac', vintage: 2016),
      );
      final next = newStart();

      final count = await next.run(ownerCellar, cellarOwner, [
        cellarWine('w1', window: migrated, baseWindow: migrated),
        _oldWine('w2'),
      ]);

      expect(count, 1);
      expect(batches.batches.last.ops.single.path, 'cellars/user-a/wines/w2');
    });
  });

  group('NFR4.8a old rules in production: permission denied', () {
    setUp(() {
      batches.commitWith = (_, result) => scheduleMicrotask(
        () => result.completeError(firestoreError('permission-denied')),
      );
    });

    test(
      'one estimates_migration_failed, no notice, stopped for the start',
      () async {
        final migration = newStart();

        await migration.run(ownerCellar, cellarOwner, [
          _oldWine('w1'),
          _oldWine('w2'),
        ]);
        await pumpEventQueue();

        expect(sink.reasons, ['estimates_migration_failed']);
        expect(
          sink.recorded.single.error.message,
          contains('permissionDenied'),
        );
        expect(events, isEmpty);
        expect(await store.attempts(estimationTablesVersion), 1);
        final before = batches.batches.length;
        expect(
          await migration.run(ownerCellar, cellarOwner, [_oldWine('w3')]),
          0,
        );
        expect(batches.batches, hasLength(before));
      },
    );

    test('at most 3 attempts in 3 different starts, then it waits', () async {
      for (var start = 1; start <= 3; start++) {
        await newStart().run(ownerCellar, cellarOwner, [_oldWine('w1')]);
        await pumpEventQueue();
        expect(await store.attempts(estimationTablesVersion), start);
      }
      final before = batches.batches.length;

      expect(
        await newStart().run(ownerCellar, cellarOwner, [_oldWine('w1')]),
        0,
      );
      expect(batches.batches, hasLength(before));
      expect(sink.reasons, hasLength(3));
    });

    test('a new table version starts counting again', () async {
      await store.record(estimationTablesVersion, 3);
      final next = EstimatesMigration(
        wines: repository,
        reporter: recordingReporter(sink),
        clock: clock,
        store: store,
        tablesVersion: estimationTablesVersion + 1,
      );

      expect(await next.run(ownerCellar, cellarOwner, [_oldWine('w1')]), 1);
    });
  });

  test(
    'a transient failure leaves the wine for the next start, no report',
    () async {
      batches.commitWith = (_, result) => scheduleMicrotask(
        () => result.completeError(firestoreError('unavailable')),
      );
      final migration = newStart();

      await migration.run(ownerCellar, cellarOwner, [_oldWine('w1')]);
      await pumpEventQueue();

      expect(sink.reasons, isEmpty);
      expect(events, isEmpty);
      expect(await store.attempts(estimationTablesVersion), 0);
    },
  );

  test('a local save failure stops with localWriteFailed', () async {
    final broken = WineRepository(
      db: db,
      ledger: LocalLedger(
        store: InMemoryKeyValueStore()
          ..failReads = StateError('disk')
          ..failNextWrite = StateError('disk'),
        reporter: recordingReporter(sink),
      ),
      bus: bus,
      reporter: recordingReporter(sink),
    );
    final migration = EstimatesMigration(
      wines: broken,
      reporter: recordingReporter(sink),
      clock: clock,
      store: store,
    );

    expect(
      await migration.run(ownerCellar, cellarOwner, [
        _oldWine('w1'),
        _oldWine('w2'),
      ]),
      0,
    );
    expect(sink.reasons, contains('estimates_migration_failed'));
    expect(sink.recorded.last.error.message, contains('localWriteFailed'));
  });

  test('NFR4.8a two people: owner and editor write the same result', () async {
    final owner = newStart();
    // The editor's phone: its own ledger, the same cellar.
    final editorPhone = WineRepository(
      db: db,
      ledger: LocalLedger(
        store: InMemoryKeyValueStore(),
        reporter: recordingReporter(sink),
      ),
      bus: bus,
      reporter: recordingReporter(sink),
    );
    final editor = EstimatesMigration(
      wines: editorPhone,
      reporter: recordingReporter(sink),
      clock: clock,
    );
    final wine = _oldWine('w1', level: WineLevel.everyday);

    await owner.run(ownerCellar, cellarOwner, [wine]);
    await editor.run(editCellar, cellarEditor, [wine]);

    expect(batches.batches, hasLength(2));
    expect(written(0)[WineFields.window], written(1)[WineFields.window]);
    expect(written(1)[WineFields.updatedBy], cellarEditor.uid);
  });

  test('NFR4.7 1000 wines: one write each, computed in under 1 s', () async {
    final wines = [for (var i = 0; i < 1000; i++) _oldWine('w$i')];
    final watch = Stopwatch()..start();
    for (final wine in wines) {
      const WineEstimator().estimate(
        WineFactsInput.ofWine(wine, fallbackYear: 2026),
      );
    }
    watch.stop();
    expect(watch.elapsedMilliseconds, lessThan(1000));

    final count = await newStart().run(ownerCellar, cellarOwner, wines);

    expect(count, 1000);
    expect(batches.batches, hasLength(1000));
    expect(batches.batches.every((b) => b.ops.length == 1), isTrue);
  });

  test('CellarActions.ensureEstimates runs the migration after the missing '
      'estimates', () async {
    SharedPreferences.setMockInitialValues({});
    final actions = CellarActions(
      wines: repository,
      records: MockDrinkingRecordRepository(),
      reconciler: RecordReconciler(
        preferences: SharedPreferences.getInstance,
        clock: clock,
        reporter: recordingReporter(sink),
      ),
      refresher: EstimateRefresher(
        wines: repository,
        catalog: FakeWineCatalog(),
        network: FakeCellarNetwork(online: false),
        reporter: recordingReporter(sink),
        clock: clock,
      ),
      bus: bus,
      reporter: recordingReporter(sink),
      clock: clock,
      migration: newStart(),
    );

    final count = await actions.ensureEstimates(
      cellar: ownerCellar,
      user: cellarOwner,
      wines: [
        cellarWine('w0', wineType: 'white'),
        _oldWine('w1'),
      ],
    );

    expect(count, 2);
  });

  group('PreferencesMigrationAttemptStore', () {
    test('keeps the attempts per version in the preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferencesMigrationAttemptStore(
        SharedPreferences.getInstance,
      );
      expect(await prefs.attempts(2), 0);
      await prefs.record(2, 2);
      expect(await prefs.attempts(2), 2);
      expect(await prefs.attempts(3), 0);
    });

    test('an unreadable store counts as no attempt and never throws', () async {
      final prefs = PreferencesMigrationAttemptStore(
        () => Future.error(StateError('no preferences')),
      );
      expect(await prefs.attempts(2), 0);
      await prefs.record(2, 1);
    });
  });

  test('the failure carries only its reason', () {
    expect(
      const EstimatesMigrationFailure(
        EstimatesMigrationFailureReason.permissionDenied,
      ).toString(),
      'EstimatesMigrationFailure(permissionDenied)',
    );
  });
}
