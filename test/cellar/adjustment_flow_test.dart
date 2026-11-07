// CellarActions and CellarMaintenance (BR1.4, BR1.5, BR1.10-BR1.14, BR1.19,
// BR1.20; NFR6.6): the drink feedback applied, undone and changed from the
// History, the offline recovery entries, the background work.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/cellar_maintenance.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/data/match_key_backfill.dart';
import 'package:vinoozy/cellar/data/record_reconciler.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/domain/window_adjuster.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/domain/wine_estimate.dart';
import 'package:vinoozy/cellar/domain/wine_validator.dart';
import 'package:vinoozy/cellar/estimate_refresher.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../helpers/fakes.dart';
import '../helpers/firestore_mocks.dart';
import '../helpers/service_mocks.dart';
import 'cellar_harness.dart';

void main() {
  setUpAll(registerCellarFallbacks);

  late MockWineRepository wines;
  late MockDrinkingRecordRepository records;
  late RecordReconciler reconciler;
  late FakeWineCatalog catalog;
  late FakeCellarNetwork network;
  late SyncErrorBus bus;
  late List<SyncEvent> events;
  late RecordingErrorSink sink;
  late FakeClock clock;
  late CellarActions actions;
  late List<WineEstimate> estimates;
  late WineRecords stored;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    wines = MockWineRepository();
    records = MockDrinkingRecordRepository();
    clock = FakeClock(DateTime(2026, 11, 6, 20));
    sink = RecordingErrorSink();
    reconciler = RecordReconciler(
      preferences: SharedPreferences.getInstance,
      clock: clock,
      reporter: recordingReporter(sink),
    );
    catalog = FakeWineCatalog();
    network = FakeCellarNetwork(online: false);
    bus = SyncErrorBus();
    events = [];
    bus.events.listen(events.add);
    estimates = [];
    stored = const WineRecords(records: [], fromServer: true);
    when(
      () => wines.setEstimate(
        cellarId: any(named: 'cellarId'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
        estimate: any(named: 'estimate'),
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((invocation) async {
      estimates.add(invocation.namedArguments[#estimate] as WineEstimate);
      return const SaveAccepted();
    });
    when(
      () => records.recordsOfWine(any(), any(), source: any(named: 'source')),
    ).thenAnswer((_) async => stored);
    actions = CellarActions(
      wines: wines,
      records: records,
      reconciler: reconciler,
      refresher: EstimateRefresher(
        wines: wines,
        catalog: catalog,
        network: network,
        reporter: recordingReporter(sink),
        clock: clock,
      ),
      bus: bus,
      reporter: recordingReporter(sink),
      clock: clock,
    );
  });

  // Base 2020 / 2024 / 2030, medium confidence.
  final base = windowOf(2020, 2024, 2030);
  Wine estimatedWine({String id = 'w1'}) =>
      cellarWine(id, window: base, baseWindow: base);

  DrinkingRecord withCondition(String id, DrinkCondition condition, int year) =>
      drinkRecord(id, drankOn: DateTime(year, 6, 1), condition: condition);

  group('BR1.12 the feedback on the window', () {
    test('BR1.12 a "too young" drink moves the window forward', () async {
      stored = WineRecords(
        records: [withCondition('r1', DrinkCondition.tooYoung, 2026)],
        fromServer: true,
      );

      await actions.recomputeAdjustment(
        cellar: ownerCellar,
        user: cellarOwner,
        wine: estimatedWine(),
      );

      final estimate = estimates.single;
      expect(estimate.baseWindow, base);
      expect(estimate.window!.startYear, 2027);
      expect(estimate.window!.endYear, 2037);
      expect(estimate.adjustment!.recordId, 'r1');
      expect(await reconciler.pending(cellarOwner.uid), isEmpty);
    });

    test(
      'BR1.10 BR1.12 undoing the drink of the feedback restores the base',
      () async {
        final adjusted = cellarWine(
          'w1',
          quantity: 1,
          baseWindow: base,
          window: windowOf(2027, 2031, 2037),
          adjustment: tooYoung2026,
        );
        when(
          () => records.undo(
            cellarId: any(named: 'cellarId'),
            user: any(named: 'user'),
            wine: any(named: 'wine'),
            recordId: any(named: 'recordId'),
          ),
        ).thenAnswer((_) async => UndoResult.undone);

        final result = await actions.undoDrink(
          cellar: editCellar,
          user: cellarEditor,
          wine: adjusted,
          recordId: 'r1',
        );

        expect(result, UndoResult.undone);
        final estimate = estimates.single;
        expect(estimate.window, base);
        expect(estimate.adjustment, isNull);
      },
    );

    test('BR1.10 undoing another drink does not touch the window', () async {
      when(
        () => records.undo(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
          wine: any(named: 'wine'),
          recordId: any(named: 'recordId'),
        ),
      ).thenAnswer((_) async => UndoResult.nothingToUndo);

      await actions.undoDrink(
        cellar: ownerCellar,
        user: cellarOwner,
        wine: estimatedWine(),
        recordId: 'r9',
      );

      expect(estimates, isEmpty);
    });

    test(
      'BR1.11 BR1.12 a condition changed from the History recomputes',
      () async {
        when(
          () => records.updateRecord(
            cellarId: any(named: 'cellarId'),
            user: any(named: 'user'),
            record: any(named: 'record'),
            rating: any(named: 'rating'),
            notes: any(named: 'notes'),
            drankOn: any(named: 'drankOn'),
            condition: any(named: 'condition'),
          ),
        ).thenAnswer((_) async => const SaveAccepted());
        stored = WineRecords(
          records: [withCondition('r1', DrinkCondition.pastPeak, 2026)],
          fromServer: true,
        );

        await actions.updateRecord(
          cellar: ownerCellar,
          user: cellarOwner,
          record: drinkRecord('r1', drankOn: DateTime(2026, 6, 1)),
          wine: estimatedWine(),
          rating: 3,
          notes: null,
          drankOn: DateTime(2026, 6, 1),
          condition: DrinkCondition.pastPeak,
        );

        expect(estimates.single.window!.endYear, 2026);

        // Only rating and notes changed: no recomputation.
        await actions.updateRecord(
          cellar: ownerCellar,
          user: cellarOwner,
          record: withCondition('r1', DrinkCondition.pastPeak, 2026),
          wine: estimatedWine(),
          rating: 5,
          notes: 'Buono',
          drankOn: DateTime(2026, 6, 1),
          condition: DrinkCondition.pastPeak,
        );
        expect(estimates, hasLength(1));
      },
    );

    test(
      'NFR6.6 offline the result is written and reapplyAdjustment is queued',
      () async {
        stored = WineRecords(
          records: [withCondition('r1', DrinkCondition.justRight, 2032)],
          fromServer: false,
        );

        await actions.recomputeAdjustment(
          cellar: ownerCellar,
          user: cellarOwner,
          wine: estimatedWine(),
        );

        expect(estimates.single.window!.endYear, 2033);
        final pending = await reconciler.pending(cellarOwner.uid);
        expect(pending.single.kind, PendingOpKind.reapplyAdjustment);
        expect(pending.single.wineId, 'w1');
      },
    );

    test('BR1.19 read only: nothing read, nothing written', () async {
      await actions.recomputeAdjustment(
        cellar: readCellar,
        user: cellarEditor,
        wine: estimatedWine(),
      );

      expect(estimates, isEmpty);
      verifyNever(
        () => records.recordsOfWine(any(), any(), source: any(named: 'source')),
      );
    });

    test(
      'BR1.12 a wine without estimate keeps the feedback without effect',
      () async {
        stored = WineRecords(
          records: [withCondition('r1', DrinkCondition.tooYoung, 2026)],
          fromServer: true,
        );

        await actions.recomputeAdjustment(
          cellar: ownerCellar,
          user: cellarOwner,
          wine: cellarWine('w1'),
        );

        expect(estimates, isEmpty);
      },
    );
  });

  group('BR1.4 BR1.5 BR1.13 saving', () {
    WineDraft draft({String name = 'Barolo'}) => WineValidator.validate(
      WineInput(
        id: 'new',
        name: name,
        producer: 'Cantina Esempio',
        vintage: '2016',
        noVintage: false,
        quantity: 2,
        wineType: 'redStructured',
      ),
      currentYear: 2026,
    ).draft!;

    void stubAdd() => when(
      () => wines.addWine(
        cellarId: any(named: 'cellarId'),
        user: any(named: 'user'),
        draft: any(named: 'draft'),
        estimate: any(named: 'estimate'),
      ),
    ).thenAnswer((_) async => const SaveAccepted());

    test(
      'BR1.4 an existing entry (also finished) is returned, nothing saved',
      () async {
        final finished = cellarWine('old', quantity: 0);
        when(
          () => wines.findByMatchKey('user-a', 'barolo|cantina esempio|2016'),
        ).thenAnswer((_) async => [finished]);
        stubAdd();

        final result = await actions.saveNewWine(
          cellar: ownerCellar,
          user: cellarOwner,
          draft: draft(),
        );

        expect((result as AddDuplicate).existing.id, 'old');
        verifyNever(
          () => wines.addWine(
            cellarId: any(named: 'cellarId'),
            user: any(named: 'user'),
            draft: any(named: 'draft'),
            estimate: any(named: 'estimate'),
          ),
        );
      },
    );

    test('BR1.5 BR1.18 a new wine is saved with the internal estimate, offline too', () async {
      when(() => wines.findByMatchKey(any(), any()))
          .thenAnswer((_) async => []);
      stubAdd();

      final result = await actions.saveNewWine(
        cellar: ownerCellar,
        user: cellarOwner,
        draft: draft(),
      );

      final saved = (result as AddSaved).wine;
      expect(saved.window, isNotNull);
      expect(saved.matchKey, 'barolo|cantina esempio|2016');
      final estimate =
          verify(
                () => wines.addWine(
                  cellarId: 'user-a',
                  user: cellarOwner,
                  draft: any(named: 'draft'),
                  estimate: captureAny(named: 'estimate'),
                ),
              ).captured.single
              as WineEstimate;
      expect(estimate.baseWindow, estimate.window);
      expect(catalog.profileNames, isEmpty, reason: 'offline: no catalog');
    });

    test('BR1.4 a failing duplicate query never blocks the save', () async {
      when(() => wines.findByMatchKey(any(), any()))
          .thenThrow(firestoreError('unavailable'));
      stubAdd();

      final result = await actions.saveNewWine(
        cellar: ownerCellar,
        user: cellarOwner,
        draft: draft(),
      );

      expect(result, isA<AddSaved>());
      expect(sink.reasons, ['cellar_save_failed']);
    });

    test('BR1.13 an edit matching another wine is not saved', () async {
      when(() => wines.findByMatchKey(any(), any()))
          .thenAnswer((_) async => [cellarWine('other')]);

      final result = await actions.saveEdit(
        cellar: ownerCellar,
        user: cellarOwner,
        before: cellarWine('w1'),
        draft: draft(),
        targetQuantity: 1,
      );

      expect(result, EditResult.duplicate);
    });

    test('BR1.13 an edit keeps the feedback on the new estimate', () async {
      when(() => wines.findByMatchKey(any(), any()))
          .thenAnswer((_) async => [cellarWine('w1')]);
      when(
        () => wines.updateWine(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
          before: any(named: 'before'),
          draft: any(named: 'draft'),
          targetQuantity: any(named: 'targetQuantity'),
          estimate: any(named: 'estimate'),
        ),
      ).thenAnswer((_) async => const SaveAccepted());
      const feedback = tooYoung2026;

      final result = await actions.saveEdit(
        cellar: ownerCellar,
        user: cellarOwner,
        before: cellarWine('w1', adjustment: feedback),
        draft: draft(),
        targetQuantity: 0,
      );

      expect(result, EditResult.saved);
      final estimate =
          verify(
                () => wines.updateWine(
                  cellarId: 'user-a',
                  user: cellarOwner,
                  before: any(named: 'before'),
                  draft: any(named: 'draft'),
                  targetQuantity: 0,
                  estimate: captureAny(named: 'estimate'),
                ),
              ).captured.single
              as WineEstimate;
      expect(estimate.adjustment, feedback);
    });
  });

  group('BR1.14 BR1.20 deleting and merging', () {
    void stubDelete(DeleteOutcome outcome) => when(
      () => wines.deleteWineWithRecords(
        cellarId: any(named: 'cellarId'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
      ),
    ).thenAnswer((_) async => outcome);

    test('BR1.14 offline: a purge entry completes it later', () async {
      stubDelete(DeleteOutcome.queued);

      final outcome = await actions.deleteWine(
        cellar: ownerCellar,
        user: cellarOwner,
        wine: cellarWine('w1'),
      );

      expect(outcome, DeleteOutcome.queued);
      expect(
        (await reconciler.pending(cellarOwner.uid)).single.kind,
        PendingOpKind.purgeRecords,
      );
      expect(events, isEmpty);
    });

    test('BR1.14 refused twice: purge entry and a notice', () async {
      stubDelete(DeleteOutcome.failed);

      await actions.deleteWine(
        cellar: ownerCellar,
        user: cellarOwner,
        wine: cellarWine('w1'),
      );

      expect(await reconciler.pending(cellarOwner.uid), hasLength(1));
      expect(
        (events.single as CellarNotice).kind,
        CellarNoticeKind.deleteFailed,
      );
    });

    test('BR1.14 not the owner: nothing deleted', () async {
      stubDelete(DeleteOutcome.deleted);

      expect(
        await actions.deleteWine(
          cellar: editCellar,
          user: cellarEditor,
          wine: cellarWine('w1'),
        ),
        DeleteOutcome.failed,
      );
      verifyNever(
        () => wines.deleteWineWithRecords(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
          wine: any(named: 'wine'),
        ),
      );
    });

    test(
      'BR1.20 merge only by the owner and without drinks on the newer',
      () async {
        when(
          () => wines.mergeInto(
            cellarId: any(named: 'cellarId'),
            user: any(named: 'user'),
            older: any(named: 'older'),
            newer: any(named: 'newer'),
          ),
        ).thenAnswer((_) async => const SaveAccepted());
        final older = cellarWine('old');
        final newer = cellarWine('new');

        expect(
          await actions.merge(
            cellar: editCellar,
            user: cellarEditor,
            older: older,
            newer: newer,
          ),
          MergeResult.notOwner,
        );

        stored = WineRecords(
          records: [drinkRecord('r1', wineId: 'new')],
          fromServer: true,
        );
        expect(
          await actions.merge(
            cellar: ownerCellar,
            user: cellarOwner,
            older: older,
            newer: newer,
          ),
          MergeResult.newerHasDrinks,
        );
        expect(await actions.hasDrinks('user-a', newer), isTrue);

        stored = const WineRecords(records: [], fromServer: true);
        expect(
          await actions.merge(
            cellar: ownerCellar,
            user: cellarOwner,
            older: older,
            newer: newer,
          ),
          MergeResult.merged,
        );
      },
    );
  });

  group('BR1.19 estimates of wines without one', () {
    test('BR1.19 written with canEdit, never with read only', () async {
      final noEstimate = cellarWine('w1', wineType: 'white');

      expect(
        await actions.ensureEstimates(
          cellar: readCellar,
          user: cellarEditor,
          wines: [noEstimate],
        ),
        0,
      );
      expect(
        await actions.ensureEstimates(
          cellar: editCellar,
          user: cellarEditor,
          wines: [
            noEstimate,
            estimatedWine(id: 'w2'),
          ],
        ),
        1,
      );
      expect(estimates.single.window, isNotNull);
    });
  });

  group('NFR6.6 CellarMaintenance', () {
    late MockMatchKeyBackfill backfill;
    late CellarMaintenance maintenance;

    setUp(() {
      backfill = MockMatchKeyBackfill();
      when(() => backfill.run(any()))
          .thenAnswer((_) async => BackfillOutcome.completed);
      when(() => backfill.keyLoaded(any(), any())).thenAnswer((_) async {});
      when(() => wines.purgeRecords(any(), any())).thenAnswer((_) async {});
      maintenance = CellarMaintenance(
        backfill: backfill,
        reconciler: reconciler,
        refresher: EstimateRefresher(
          wines: wines,
          catalog: catalog,
          network: network,
          reporter: recordingReporter(sink),
          clock: clock,
        ),
        actions: actions,
        wines: wines,
        network: network,
        reporter: recordingReporter(sink),
      );
    });

    test(
      'BR1.4 online: backfill, keys, recovery entries of this cellar only',
      () async {
        network.online = true;
        PendingOp purge(String cellarId) => PendingOp(
          kind: PendingOpKind.purgeRecords,
          cellarId: cellarId,
          wineId: 'gone',
          createdAt: clock.now(),
        );
        await reconciler.add(cellarOwner.uid, purge('user-a'));
        await reconciler.add(cellarOwner.uid, purge('other-cellar'));

        expect(
          await maintenance.run(ownerCellar, cellarOwner, [estimatedWine()]),
          isTrue,
        );

        verify(() => backfill.run('user-a')).called(1);
        verify(() => backfill.keyLoaded('user-a', any())).called(1);
        verify(() => wines.purgeRecords('user-a', 'gone')).called(1);
        final left = await reconciler.pending(cellarOwner.uid);
        expect(left.single.cellarId, 'other-cellar');
      },
    );

    test('offline only the internal estimates run', () async {
      expect(
        await maintenance.run(ownerCellar, cellarOwner, [cellarWine('w1')]),
        isTrue,
      );

      verifyNever(() => backfill.run(any()));
      expect(estimates, hasLength(1));
    });

    test('R-04 a run asked while one is in progress waits, then runs once '
        'with the latest wines', () async {
      network.online = true;
      final gate = Completer<BackfillOutcome>();
      var calls = 0;
      when(() => backfill.run(any())).thenAnswer((_) {
        calls++;
        return calls == 1
            ? gate.future
            : Future.value(BackfillOutcome.alreadyDone);
      });

      final first = maintenance.run(ownerCellar, cellarOwner, const []);
      await pumpEventQueue();
      expect(
        await maintenance.run(ownerCellar, cellarOwner, [cellarWine('w1')]),
        isFalse,
        reason: 'queued, not run at the same time',
      );
      await maintenance.run(ownerCellar, cellarOwner, [cellarWine('w2')]);
      expect(calls, 1);

      gate.complete(BackfillOutcome.completed);
      await first;
      expect(calls, 2, reason: 'one rerun, not two');
      final loaded =
          verify(() => backfill.keyLoaded('user-a', captureAny())).captured.last
              as List<Wine>;
      expect(loaded.single.id, 'w2');
    });

    test('BR1.19 read only: nothing runs', () async {
      network.online = true;

      expect(
        await maintenance.run(readCellar, cellarEditor, [cellarWine('w1')]),
        isFalse,
      );
      verifyNever(() => backfill.run(any()));
    });

    test(
      'NFR6.6 reapplyAdjustment reads the wine and its drinks from the server',
      () async {
        network.online = true;
        when(() => wines.watchWine('user-a', 'w1'))
            .thenAnswer((_) => Stream.value(estimatedWine()));
        stored = WineRecords(
          records: [withCondition('r1', DrinkCondition.tooYoung, 2026)],
          fromServer: true,
        );
        await reconciler.add(
          cellarOwner.uid,
          PendingOp(
            kind: PendingOpKind.reapplyAdjustment,
            cellarId: 'user-a',
            wineId: 'w1',
            createdAt: clock.now(),
          ),
        );

        await maintenance.run(ownerCellar, cellarOwner, const []);

        verify(
          () => records.recordsOfWine(
            'user-a',
            'w1',
            source: RecordsSource.server,
          ),
        ).called(1);
        expect(estimates.single.window!.startYear, 2027);
        expect(await reconciler.pending(cellarOwner.uid), isEmpty);
      },
    );
  });
}

/// The feedback "too young" of drink r1, drunk in 2026.
const tooYoung2026 = WindowAdjustment(
  kind: DrinkCondition.tooYoung,
  year: 2026,
  recordId: 'r1',
);
