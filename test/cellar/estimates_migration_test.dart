// The one-off migration to the style profiles (wine-style-profiles BR7.4-
// BR7.7, D4, NFR4.4, NFR4.6, NFR4.9), which replaced the re-estimate of
// label-autofill-windows BR3.9: candidates by `migrationVersion`, one
// transaction per wine, skipped when changed meanwhile, offline not started,
// refusals counted over 3 starts. The repository is a test double of
// `migrateWine`; the transaction itself is tested in
// data/wine_repository_style_test.dart.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/app_event_logger.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/data/record_reconciler.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/estimate_refresher.dart';
import 'package:vinoozy/cellar/estimates_migration.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../helpers/fakes.dart';
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

class _Repo extends Mock implements WineRepository {}

final _seen = DateTime.utc(2026, 11, 1, 10);

/// A wine of today's app: estimated with the tables of version 2.
Wine _oldWine(String id, {String name = 'Barolo', WineLevel? level}) {
  final old = windowOf(2024, 2031, 2046);
  return cellarWine(
    id,
    name: name,
    window: old,
    baseWindow: old,
    level: level,
    updatedAt: _seen,
  );
}

void main() {
  setUpAll(() {
    registerCellarFallbacks();
    registerFallbackValue(<String, Object?>{});
  });

  late _Repo repo;
  late RecordingErrorSink sink;
  late MemoryMigrationAttemptStore store;
  late _Logger logger;
  late FakeClock clock;
  late List<(String, Map<String, Object?>)> writes;
  late MigrationWrite answer;
  late bool online;

  setUp(() {
    repo = _Repo();
    sink = RecordingErrorSink();
    store = MemoryMigrationAttemptStore();
    logger = _Logger();
    clock = FakeClock(DateTime(2026, 11, 9));
    writes = [];
    answer = MigrationWrite.written;
    online = true;
    when(
      () => repo.migrateWine(
        cellarId: any(named: 'cellarId'),
        user: any(named: 'user'),
        wineId: any(named: 'wineId'),
        seenUpdatedAt: any(named: 'seenUpdatedAt'),
        fields: any(named: 'fields'),
      ),
    ).thenAnswer((invocation) async {
      writes.add((
        invocation.namedArguments[#wineId]! as String,
        invocation.namedArguments[#fields]! as Map<String, Object?>,
      ));
      return answer;
    });
  });

  EstimatesMigration newStart({int version = estimationTablesVersion}) =>
      EstimatesMigration(
        wines: repo,
        reporter: recordingReporter(sink),
        clock: clock,
        store: store,
        logger: logger,
        tablesVersion: version,
        isOnline: () async => online,
      );

  group('BR7.6 candidates', () {
    test('migrationVersion missing or below 3 only', () {
      expect(EstimatesMigration.needsMigration(_oldWine('w1')), isTrue);
      expect(
        EstimatesMigration.needsMigration(
          cellarWine('w2', migrationVersion: 2),
        ),
        isTrue,
      );
      expect(
        EstimatesMigration.needsMigration(
          cellarWine('w3', migrationVersion: 3),
        ),
        isFalse,
      );
      expect(
        EstimatesMigration.needsMigration(
          cellarWine('w4', migrationVersion: 3),
          version: 4,
        ),
        isTrue,
      );
    });
  });

  group('NFR4.4 online', () {
    test(
      'each wine is written once with the version and the seen time',
      () async {
        final migration = newStart();
        final count = await migration.run(ownerCellar, cellarOwner, [
          _oldWine('w1'),
          _oldWine('w2', level: WineLevel.aging),
          cellarWine('w3', migrationVersion: 3, updatedAt: _seen),
        ]);

        expect(count, 2);
        expect(writes.map((w) => w.$1), ['w1', 'w2']);
        expect(writes.first.$2[WineFields.migrationVersion], 3);
        verify(
          () => repo.migrateWine(
            cellarId: ownerCellar.cellarId,
            user: cellarOwner,
            wineId: 'w1',
            seenUpdatedAt: _seen,
            fields: any(named: 'fields'),
          ),
        ).called(1);
        expect(logger.migrated.single.$1, 2);
        expect(sink.reasons, isEmpty);
      },
    );

    test(
      'a reader, a pending write or a migrated cellar write nothing',
      () async {
        final migration = newStart();
        expect(
          await migration.run(readCellar, cellarEditor, [_oldWine('w1')]),
          0,
        );
        expect(
          await migration.run(ownerCellar, cellarOwner, [
            cellarWine('w2'), // no updatedAt yet: pending
            cellarWine('w3', migrationVersion: 3),
          ]),
          0,
        );
        expect(writes, isEmpty);
      },
    );

    test('BR7.4 a wine changed by someone else is skipped and kept for the '
        'next start', () async {
      answer = MigrationWrite.skipped;
      final first = newStart();
      expect(await first.run(ownerCellar, cellarOwner, [_oldWine('w1')]), 0);
      expect(sink.reasons, isEmpty);
      answer = MigrationWrite.written;
      final next = newStart();
      expect(await next.run(ownerCellar, cellarOwner, [_oldWine('w1')]), 1);
    });
  });

  group('NFR4.9 offline', () {
    test('without network the migration does not start', () async {
      online = false;
      final migration = newStart();
      expect(
        await migration.run(ownerCellar, cellarOwner, [_oldWine('w1')]),
        0,
      );
      expect(writes, isEmpty);
      online = true;
      expect(
        await migration.run(ownerCellar, cellarOwner, [_oldWine('w1')]),
        1,
      );
    });

    test('a network failure stops this start without counting', () async {
      answer = MigrationWrite.failed;
      final migration = newStart();
      final count = await migration.run(ownerCellar, cellarOwner, [
        _oldWine('w1'),
        _oldWine('w2'),
      ]);
      expect(count, 0);
      expect(writes, hasLength(1));
      expect(await store.attempts(estimationTablesVersion), 0);
      expect(sink.reasons, isEmpty);
    });

    test('NFR4.6 an interrupted run continues with the wines left', () async {
      final first = newStart();
      await first.run(ownerCellar, cellarOwner, [_oldWine('w1')]);
      final next = newStart();
      final count = await next.run(ownerCellar, cellarOwner, [
        cellarWine('w1', migrationVersion: 3, updatedAt: _seen),
        _oldWine('w2'),
      ]);
      expect(count, 1);
      expect(writes.map((w) => w.$1), ['w1', 'w2']);
    });
  });

  group('BR7.6 rules not deployed: permission denied', () {
    test('one estimates_migration_failed, stopped for the start', () async {
      answer = MigrationWrite.rejected;
      final migration = newStart();
      final count = await migration.run(ownerCellar, cellarOwner, [
        _oldWine('w1'),
        _oldWine('w2'),
      ]);
      expect(count, 0);
      expect(writes, hasLength(1));
      expect(sink.reasons, ['estimates_migration_failed']);
      expect(
        await migration.run(ownerCellar, cellarOwner, [_oldWine('w3')]),
        0,
      );
      expect(await store.attempts(estimationTablesVersion), 1);
    });

    test('at most 3 attempts in 3 different starts, then it waits', () async {
      answer = MigrationWrite.rejected;
      for (var start = 0; start < 3; start++) {
        await newStart().run(ownerCellar, cellarOwner, [_oldWine('w1')]);
      }
      expect(await store.attempts(estimationTablesVersion), 3);
      writes.clear();
      await newStart().run(ownerCellar, cellarOwner, [_oldWine('w1')]);
      expect(writes, isEmpty);
      // A new version starts counting again.
      await newStart(version: 4)
          .run(ownerCellar, cellarOwner, [_oldWine('w1')]);
      expect(writes, hasLength(1));
    });
  });

  test('NFR3.4 200 wines are computed in under 1 s', () async {
    final wines = [
      for (var i = 0; i < 200; i++)
        _oldWine('w$i', name: i.isEven ? 'Barolo Riserva' : 'Prosecco'),
    ];
    final watch = Stopwatch()..start();
    final count = await newStart().run(ownerCellar, cellarOwner, wines);
    watch.stop();
    expect(count, 200);
    expect(watch.elapsedMilliseconds, lessThan(1000));
  });

  test('NFR3.7 500 wines are computed in under 2.5 s', () async {
    const names = [
      'Barolo Riserva',
      'Prosecco',
      'Champagne Brut',
      'Rosso della casa',
      'Porto Tawny',
    ];
    final wines = [
      for (var i = 0; i < 500; i++)
        _oldWine('w$i', name: names[i % names.length]),
    ];
    final watch = Stopwatch()..start();
    final count = await newStart().run(ownerCellar, cellarOwner, wines);
    watch.stop();
    expect(count, 500);
    expect(writes, hasLength(500));
    expect(watch.elapsedMilliseconds, lessThan(2500));
  });

  test('CellarActions.ensureEstimates runs the migration after the missing '
      'estimates', () async {
    SharedPreferences.setMockInitialValues({});
    when(
      () => repo.setEstimate(
        cellarId: any(named: 'cellarId'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
        estimate: any(named: 'estimate'),
      ),
    ).thenAnswer((_) async => const SaveAccepted());
    final actions = CellarActions(
      wines: repo,
      records: MockDrinkingRecordRepository(),
      reconciler: RecordReconciler(
        preferences: SharedPreferences.getInstance,
        clock: clock,
        reporter: recordingReporter(sink),
      ),
      refresher: EstimateRefresher(
        wines: repo,
        catalog: FakeWineCatalog(),
        network: FakeCellarNetwork(online: false),
        reporter: recordingReporter(sink),
        clock: clock,
      ),
      bus: SyncErrorBus(),
      reporter: recordingReporter(sink),
      clock: clock,
      migration: newStart(),
    );

    final count = await actions.ensureEstimates(
      cellar: ownerCellar,
      user: cellarOwner,
      wines: [
        cellarWine('w0', wineType: 'white', migrationVersion: 3),
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
