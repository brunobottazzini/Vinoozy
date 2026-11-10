// WineRepository and the wine codec, wine-style-profiles additions (BR7.1,
// BR7.4, BR7.8, BR8.1, BR8.2, BR10.1, D2, D4): the new fields on create and
// edit, the classification chosen in the detail, the migration transaction
// (written, skipped when changed meanwhile, refused, failed), the windows in
// months read and written, the old documents read as before.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/domain/window_adjuster.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_classification.dart';
import 'package:vinoozy/cellar/domain/wine_estimate.dart';
import 'package:vinoozy/cellar/domain/wine_validator.dart';
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
  late RecordingErrorSink sink;
  late WineRepository repository;

  setUp(() {
    db = MockFirestore();
    batches = BatchRecorder(db);
    sink = RecordingErrorSink();
    repository = WineRepository(
      db: db,
      ledger: LocalLedger(
        store: InMemoryKeyValueStore(),
        reporter: recordingReporter(sink),
      ),
      bus: SyncErrorBus(),
      reporter: recordingReporter(sink),
    );
  });

  WineInput input({
    WineStyle? style,
    FieldSource? styleSource,
    String? wineType = 'sparklingClassic',
    FieldSource? typeSource = FieldSource.auto,
    int? agingYear,
    int? agingMonth,
    String vintage = '2018',
  }) => WineInput(
    id: 'w1',
    name: 'Champagne Brut',
    vintage: vintage,
    noVintage: false,
    quantity: 1,
    wineType: wineType,
    typeSource: typeSource,
    style: style,
    styleSource: styleSource,
    agingStartYear: agingYear,
    agingStartMonth: agingMonth,
  );

  group('BR7.1, BR8.1 create', () {
    test('style, sources, date and migrationVersion are written', () async {
      final draft = WineValidator.validate(
        input(
          style: WineStyle.classicAge,
          styleSource: FieldSource.user,
          agingYear: 2024,
          agingMonth: 3,
        ),
        currentYear: 2026,
      ).draft!;
      await repository.addWine(cellarId: 'user-a', user: user, draft: draft);
      // freemium-plus FR2.2: the batch also moves the cellar counter.
      final data = batches.batches.last.opAt('cellars/user-a/wines/w1').data!;
      expect(data[WineFields.style], 'classicAge');
      expect(data[WineFields.styleSource], 'user');
      expect(data[WineFields.typeSource], 'auto');
      expect(data[WineFields.agingStartMonth], {'year': 2024, 'month': 3});
      expect(data[WineFields.migrationVersion], estimationTablesVersion);
      expect(data.containsKey(WineFields.levelSource), isFalse);
    });

    test('a source without its value is not written', () async {
      final draft = WineValidator.validate(
        input(wineType: null, styleSource: FieldSource.auto),
        currentYear: 2026,
      ).draft!;
      expect(draft.typeSource, isNull);
      expect(draft.styleSource, isNull);
    });
  });

  group('BR8.2 validation of the date', () {
    AgingStartError? check(int? y, int? m, {int? vintage}) =>
        WineValidator.validateAgingStart(
          y,
          m,
          vintage: vintage,
          now: DateTime(2026, 11),
        );

    test('both or none, not in the future, not before the vintage', () {
      expect(check(null, null), isNull);
      expect(check(2024, 3, vintage: 2018), isNull);
      expect(check(2024, null), AgingStartError.incomplete);
      expect(check(null, 3), AgingStartError.incomplete);
      expect(check(2026, 12), AgingStartError.future);
      expect(check(2026, 11), isNull);
      expect(check(2017, 3, vintage: 2018), AgingStartError.beforeVintage);
      expect(check(1949, 3), AgingStartError.outOfRange);
      expect(check(2024, 13), AgingStartError.outOfRange);
    });

    test('an invalid date blocks the draft', () {
      final validation = WineValidator.validate(
        input(agingYear: 2015, agingMonth: 2),
        currentYear: 2026,
      );
      expect(validation.isValid, isFalse);
      expect(validation.agingStartError, AgingStartError.beforeVintage);
    });
  });

  group('BR7.1 edit', () {
    test(
      'new fields written, removed ones deleted, absent ones untouched',
      () async {
        final before = cellarWine(
          'w1',
          wineType: 'sparklingClassic',
          style: WineStyle.classicFresh,
          styleSource: FieldSource.auto,
          agingStart: const AgingStart(2024, 1),
        );
        final draft = WineValidator.validate(
          input(style: WineStyle.classicAge, styleSource: FieldSource.user),
          currentYear: 2026,
        ).draft!;
        await repository.updateWine(
          cellarId: 'user-a',
          user: user,
          before: before,
          draft: draft,
          targetQuantity: before.quantity,
          estimate: WineEstimate.none,
        );
        final data = batches.batches.last.ops.single.data!;
        expect(data[WineFields.style], 'classicAge');
        expect(data[WineFields.styleSource], 'user');
        expect(data[WineFields.agingStartMonth], isA<FieldValue>());
        expect(data.containsKey(WineFields.levelSource), isFalse);
      },
    );
  });

  group('expression budget: the edit of a wine with a drink feedback', () {
    Future<void> edit(WineEstimate estimate) async {
      final before = cellarWine('w1', wineType: 'white');
      final draft = WineValidator.validate(
        input(style: WineStyle.classicAge, styleSource: FieldSource.user),
        currentYear: 2026,
      ).draft!;
      await repository.updateWine(
        cellarId: 'user-a',
        user: user,
        before: before,
        draft: draft,
        targetQuantity: 3,
        estimate: estimate,
      );
    }

    test(
      'window different from the base: details, then the estimate',
      () async {
        await edit(
          WineEstimate(
            baseWindow: windowOf(2020, 2024, 2030),
            window: windowOf(2020, 2024, 2027),
          ),
        );
        expect(batches.batches, hasLength(2));
        final details = batches.batches.first.ops.single.data!;
        final estimate = batches.batches.last.ops.single.data!;
        expect(details[WineFields.style], 'classicAge');
        expect(details[WineFields.quantity], isA<FieldValue>());
        expect(details.containsKey(WineFields.window), isFalse);
        expect(estimate.containsKey(WineFields.window), isTrue);
        expect(estimate.containsKey(WineFields.baseWindow), isTrue);
        expect(estimate.containsKey(WineFields.name), isFalse);
        expect(estimate.containsKey(WineFields.quantity), isFalse);
      },
    );

    test('window equal to the base: one update', () async {
      final window = windowOf(2020, 2024, 2030);
      await edit(WineEstimate(baseWindow: window, window: window));
      expect(batches.batches, hasLength(1));
      final data = batches.batches.single.ops.single.data!;
      expect(data.containsKey(WineFields.window), isTrue);
      expect(data[WineFields.style], 'classicAge');
    });
  });

  test(
    'F5 updateClassification writes the classification and estimate',
    () async {
      final estimate = WineEstimate(
        baseWindow: windowOf(2020, 2024, 2030),
        window: windowOf(2020, 2024, 2030),
      );
      await repository.updateClassification(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1'),
        classification: const WineClassification(
          wineType: WineType.redStructured,
          typeSource: FieldSource.user,
          style: WineStyle.redAge,
          styleSource: FieldSource.user,
        ),
        estimate: estimate,
      );
      final data = batches.batches.last.ops.single.data!;
      expect(data[WineFields.style], 'redAge');
      expect(data[WineFields.styleSource], 'user');
      expect(data[WineFields.level], isA<FieldValue>());
      expect(data[WineFields.window], isA<Map<String, Object>>());
      expect(data[WineFields.updatedBy], user.uid);
    },
  );

  group('D4 migrateWine transaction', () {
    final seen = DateTime.utc(2026, 11, 1, 10);
    late MockTransaction transaction;
    late MockDocRef ref;

    void stubTransaction({Map<String, dynamic>? data, Object? error}) {
      transaction = MockTransaction();
      ref = MockDocRef();
      when(() => db.doc(any())).thenReturn(ref);
      final snapshot = docSnapshot(exists: data != null, data: data);
      when(() => transaction.get(ref)).thenAnswer((_) async => snapshot);
      when(() => transaction.update(ref, any())).thenReturn(transaction);
      when(() => db.runTransaction<MigrationWrite>(any()))
          .thenAnswer((invocation) async {
            if (error != null) throw error;
            final handler =
                invocation.positionalArguments.first
                    as Future<MigrationWrite> Function(Transaction);
            return handler(transaction);
          });
    }

    Future<MigrationWrite> migrate() => repository.migrateWine(
      cellarId: 'user-a',
      user: user,
      wineId: 'w1',
      seenUpdatedAt: seen,
      fields: {WineFields.migrationVersion: 3},
    );

    test('unchanged since read: updated with the stamp', () async {
      stubTransaction(data: {WineFields.updatedAt: Timestamp.fromDate(seen)});
      expect(await migrate(), MigrationWrite.written);
      final captured =
          verify(() => transaction.update(ref, captureAny())).captured.single
              as Map;
      expect(captured[WineFields.migrationVersion], 3);
      expect(captured[WineFields.updatedBy], user.uid);
      expect(captured[WineFields.updatedAt], isA<FieldValue>());
    });

    test(
      'changed by another member meanwhile: skipped, nothing written',
      () async {
        stubTransaction(
          data: {
            WineFields.updatedAt: Timestamp.fromDate(
              seen.add(const Duration(minutes: 1)),
            ),
          },
        );
        expect(await migrate(), MigrationWrite.skipped);
        verifyNever(() => transaction.update(ref, any()));
      },
    );

    test('a deleted wine is skipped', () async {
      stubTransaction();
      expect(await migrate(), MigrationWrite.skipped);
    });

    test('refused by the rules, or another error', () async {
      stubTransaction(
        data: const {},
        error: FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
        ),
      );
      expect(await migrate(), MigrationWrite.rejected);
      stubTransaction(
        data: const {},
        error: FirebaseException(plugin: 'firestore', code: 'unavailable'),
      );
      expect(await migrate(), MigrationWrite.failed);
    });
  });

  group('D2, NFR2.1 codec', () {
    test('a window in months round-trips', () {
      final window = estimateWindow(
        const WineFacts(
          name: 'Prosecco',
          referenceYear: 2026,
          agingStartYear: 2025,
          agingStartMonth: 9,
        ),
      )!;
      final map = Wine.windowToMap(window);
      expect(map[WindowFields.unit], 'months');
      expect(map[WindowFields.startMonth], 9);
      expect(map[WindowFields.profile], 'SP_TANK');
      expect(map[WindowFields.anchor], 'bottling');
      expect(Wine.windowFrom(map), window);
    });

    test('a window in years keeps the shape of before', () {
      final window = windowOf(2020, 2024, 2030);
      expect(Wine.windowToMap(window).keys.toSet(), {
        WindowFields.startYear,
        WindowFields.peakYear,
        WindowFields.endYear,
        WindowFields.confidence,
        WindowFields.source,
        WindowFields.basis,
      });
    });

    test('no peak, no end: Porto LBV', () {
      final lbv = estimateWindow(
        const WineFacts(name: 'Porto LBV', referenceYear: 2026),
      )!;
      final map = Wine.windowToMap(lbv);
      expect(map.containsKey(WindowFields.endYear), isFalse);
      expect(Wine.windowFrom(map)!.endYear, isNull);
    });

    test('BR7.8 an old document reads with no style and no sources', () {
      final wine = Wine.fromMap('w1', {
        WineFields.name: 'Barolo',
        WineFields.quantity: 1,
        WineFields.style: 'UNKNOWN',
        WineFields.typeSource: 'manual',
        WineFields.agingStartMonth: {'year': 2024, 'month': 13},
        WineFields.migrationVersion: '3',
      });
      expect(wine.style, isNull);
      expect(wine.typeSource, isNull);
      expect(wine.agingStart, isNull);
      expect(wine.migrationVersion, isNull);
    });

    test('new fields read', () {
      final wine = Wine.fromMap('w1', {
        WineFields.name: 'Champagne',
        WineFields.quantity: 1,
        WineFields.style: 'classicAge',
        WineFields.typeSource: 'auto',
        WineFields.levelSource: 'user',
        WineFields.styleSource: 'user',
        WineFields.agingStartMonth: {'year': 2024, 'month': 3},
        WineFields.migrationVersion: 3,
      });
      expect(wine.style, WineStyle.classicAge);
      expect(wine.levelSource, FieldSource.user);
      expect(wine.agingStart, const AgingStart(2024, 3));
      expect(wine.agingStart.toString(), 'AgingStart(2024-3)');
      expect(wine.agingStart.hashCode, const AgingStart(2024, 3).hashCode);
      expect(wine.migrationVersion, 3);
    });
  });

  group('BR6.8, BR6.9 corrections in months', () {
    final months = estimateWindow(
      const WineFacts(
        name: 'Prosecco',
        referenceYear: 2026,
        agingStartYear: 2025,
        agingStartMonth: 3,
      ),
    )!; // 2025-03 / 2025-09 / 2026-09

    test('tooYoung moves the whole window by months', () {
      final moved = WindowAdjuster.effective(
        months,
        const WindowAdjustment(
          kind: DrinkCondition.tooYoung,
          year: 2025,
          month: 5,
          recordId: 'r1',
        ),
      );
      expect([moved.startYear, moved.startMonth], [2025, 6]);
      expect([moved.endYear, moved.endMonth], [2026, 12]);
      expect(moved.confidence, Confidence.low);
    });

    test('pastPeak inside: the end is the month of the drink', () {
      final moved = WindowAdjuster.effective(
        months,
        const WindowAdjustment(
          kind: DrinkCondition.pastPeak,
          year: 2025,
          month: 7,
          recordId: 'r1',
        ),
      );
      expect([moved.endYear, moved.endMonth], [2025, 7]);
      expect([moved.peakYear, moved.peakMonth], [2025, 7]);
    });

    test('justRight after the end; a feedback without month is December', () {
      final moved = WindowAdjuster.effective(
        months,
        const WindowAdjustment(
          kind: DrinkCondition.justRight,
          year: 2026,
          recordId: 'r1',
        ),
      );
      expect([moved.endYear, moved.endMonth], [2027, 1]);
    });

    test('no end: justRight and pastPeak change nothing', () {
      final lbv = estimateWindow(
        const WineFacts(name: 'Porto LBV', referenceYear: 2026),
      )!;
      for (final kind in [DrinkCondition.justRight, DrinkCondition.pastPeak]) {
        expect(
          WindowAdjuster.effective(
            lbv,
            WindowAdjustment(kind: kind, year: 2030, month: 1, recordId: 'r'),
          ),
          lbv,
        );
      }
    });

    test('effectiveOf with an override in months', () {
      final window = WindowAdjuster.effectiveOf(
        months,
        null,
        const WindowOverride(endYear: 2027, endMonth: 4),
      );
      expect([window.endYear, window.endMonth], [2027, 4]);
    });

    test('override and adjustment maps carry the month', () {
      expect(
        WindowOverride.fromMap({'endYear': 2027, 'endMonth': 4}),
        const WindowOverride(endYear: 2027, endMonth: 4),
      );
      expect(
        WindowOverride.fromMap({'endYear': 2027, 'endMonth': 0})!.endMonth,
        isNull,
      );
      expect(
        WindowAdjustment.fromMap({
          'kind': 'justRight',
          'year': 2025,
          'month': 4,
          'recordId': 'r1',
        })!.toMap()['month'],
        4,
      );
      expect(
        const WindowOverride(endYear: 2027, endMonth: 4).toString(),
        'WindowOverride(2027-4)',
      );
    });
  });
}
