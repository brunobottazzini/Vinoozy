// Level and correction of "Recommended until" in the data layer
// (label-autofill-windows BR4.1-BR4.7, FR4, FR5; NFR1.1, NFR4.11, NFR4.14):
// the model, the effective window, and the six places of BR4.5 that write
// or show a window, each with a wine that has `level` and `windowOverride`.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/data/record_reconciler.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/domain/window_adjuster.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_estimate.dart';
import 'package:vinoozy/cellar/domain/wine_validator.dart';
import 'package:vinoozy/cellar/estimate_refresher.dart';
import 'package:vinoozy/cellar/wine_estimator.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../helpers/fakes.dart';
import '../helpers/service_mocks.dart';
import 'cellar_harness.dart';

List<int?> years(DrinkingWindow window) => [
  window.startYear,
  window.peakYear,
  window.endYear,
];

const _override = WindowOverride(endYear: 2035);

void main() {
  setUpAll(registerCellarFallbacks);

  group('model (NFR1.1, ENT-001, ENT-002)', () {
    test('level and windowOverride are read; malformed values are absent', () {
      final wine = Wine.fromMap('w1', {
        'name': 'Rioja',
        'quantity': 1,
        'level': 'aging',
        'windowOverride': {'endYear': 2035, 'setAt': DateTime(2026, 11, 8)},
      });
      expect(wine.level, WineLevel.aging);
      expect(
        wine.windowOverride,
        WindowOverride(endYear: 2035, setAt: DateTime(2026, 11, 8)),
      );
      final malformed = Wine.fromMap('w2', {
        'name': 'Rioja',
        'quantity': 1,
        'level': 'premium',
        'windowOverride': {'endYear': '2035'},
      });
      expect(malformed.level, isNull);
      expect(malformed.windowOverride, isNull);
      expect(WindowOverride.fromMap('x'), isNull);
    });

    test('a wine without the new fields reads as before (NFR1.1)', () {
      final wine = Wine.fromMap('w1', {'name': 'Barolo', 'quantity': 1});
      expect(wine.level, isNull);
      expect(wine.windowOverride, isNull);
    });

    test('the window keeps denominationKey and tablesVersion both ways', () {
      final window = estimateWindow(
        const WineFacts(name: 'Pauillac', vintage: 2016),
      )!;
      final map = Wine.windowToMap(window);
      expect(map[WindowFields.denominationKey], 'pauillac');
      expect(map[WindowFields.tablesVersion], estimationTablesVersion);
      expect(Wine.windowFrom(map), window);
      final noKey = Wine.windowFrom({
        ...map,
        WindowFields.denominationKey: '',
        WindowFields.tablesVersion: 'x',
      })!;
      expect(noKey.denominationKey, isNull);
      expect(noKey.tablesVersion, isNull);
      expect(Wine.windowToMap(windowOf(2020, 2024, 2030)).length, 6);
    });

    test('WindowOverride equality and string form', () {
      expect(
        const WindowOverride(endYear: 2030),
        const WindowOverride(endYear: 2030),
      );
      expect(
        const WindowOverride(endYear: 2030).hashCode,
        const WindowOverride(endYear: 2030).hashCode,
      );
      expect(
        const WindowOverride(endYear: 2030).toString(),
        'WindowOverride(2030)',
      );
    });
  });

  group('BR4.4 BR4.7 effective window and its label', () {
    final base = windowOf(2020, 2024, 2030);

    test('the correction comes after the drink feedback (FR5.6)', () {
      const tooYoung = WindowAdjustment(
        kind: DrinkCondition.tooYoung,
        year: 2026,
        recordId: 'r1',
      );
      // tooYoung in 2026 moves 2020/2024/2030 to 2027/2031/2037; the end
      // 2028 wins, peak stops there.
      expect(
        years(
          WindowAdjuster.effectiveOf(
            base,
            tooYoung,
            const WindowOverride(endYear: 2028),
          ),
        ),
        [2027, 2028, 2028],
      );
      expect(
        years(
          WindowAdjuster.effectiveOf(
            base,
            null,
            const WindowOverride(endYear: 2034),
          ),
        ),
        [2020, 2024, 2034],
      );
      expect(WindowAdjuster.effectiveOf(base, null, null), base);
    });

    test('labelOf: corrected by you > corrected by your drinks > source', () {
      const justRight = WindowAdjustment(
        kind: DrinkCondition.justRight,
        year: 2033,
        recordId: 'r1',
      );
      expect(
        WindowAdjuster.labelOf(
          window: base,
          base: base,
          adjustment: justRight,
          override: _override,
        ),
        EstimateLabel.correctedByYou,
      );
      expect(
        WindowAdjuster.labelOf(window: base, base: base, adjustment: justRight),
        EstimateLabel.correctedByDrinks,
      );
      // A level changes the base, never the label (review R-03).
      final aging = windowOf(2021, 2025, 2034);
      expect(
        WindowAdjuster.labelOf(window: aging, base: aging),
        EstimateLabel.typeEstimate,
      );
    });
  });

  group('BR4.5 the six places keep level and correction (NFR4.11)', () {
    late MockWineRepository wines;
    late MockDrinkingRecordRepository records;
    late RecordingErrorSink sink;
    late FakeClock clock;
    late CellarActions actions;
    late FakeWineCatalog catalog;
    late List<WineEstimate> estimates;
    late WineRecords stored;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      wines = MockWineRepository();
      records = MockDrinkingRecordRepository();
      sink = RecordingErrorSink();
      clock = FakeClock(DateTime(2026, 11, 8));
      catalog = FakeWineCatalog();
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
      when(() => wines.findByMatchKey(any(), any()))
          .thenAnswer((_) async => []);
      when(
        () => wines.addWine(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
          draft: any(named: 'draft'),
          estimate: any(named: 'estimate'),
        ),
      ).thenAnswer((invocation) async {
        estimates.add(invocation.namedArguments[#estimate] as WineEstimate);
        return const SaveAccepted();
      });
      when(
        () => wines.updateWine(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
          before: any(named: 'before'),
          draft: any(named: 'draft'),
          targetQuantity: any(named: 'targetQuantity'),
          estimate: any(named: 'estimate'),
        ),
      ).thenAnswer((invocation) async {
        estimates.add(invocation.namedArguments[#estimate] as WineEstimate);
        return const SaveAccepted();
      });
      when(
        () => records.recordsOfWine(any(), any(), source: any(named: 'source')),
      ).thenAnswer((_) async => stored);
      final reconciler = RecordReconciler(
        preferences: SharedPreferences.getInstance,
        clock: clock,
        reporter: recordingReporter(sink),
      );
      actions = CellarActions(
        wines: wines,
        records: records,
        reconciler: reconciler,
        refresher: EstimateRefresher(
          wines: wines,
          catalog: catalog,
          network: FakeCellarNetwork(online: false),
          reporter: recordingReporter(sink),
          clock: clock,
        ),
        bus: SyncErrorBus(),
        reporter: recordingReporter(sink),
        clock: clock,
      );
    });

    WineInput input({WineLevel? level}) => WineInput(
      id: 'w9',
      name: 'Rioja DOCa',
      vintage: '2020',
      noVintage: false,
      quantity: 1,
      wineType: 'redStructured',
      level: level,
    );

    test('1. saveNewWine: the level chosen enters the estimate', () async {
      final draft = WineValidator.validate(
        input(level: WineLevel.aging),
        currentYear: 2026,
      ).draft!;
      expect(draft.level, WineLevel.aging);

      final result = await actions.saveNewWine(
        cellar: ownerCellar,
        user: cellarOwner,
        draft: draft,
      );

      expect((result as AddSaved).wine.level, WineLevel.aging);
      expect(years(estimates.single.baseWindow!), [2023, 2025, 2031]);
    });

    test('2. saveEdit: level of the form, correction of the wine', () async {
      final before = cellarWine(
        'w1',
        name: 'Rioja DOCa',
        vintage: 2020,
        windowOverride: _override,
        level: WineLevel.good,
      );
      final draft = WineValidator.validate(
        input(level: WineLevel.everyday),
        currentYear: 2026,
      ).draft!;

      await actions.saveEdit(
        cellar: ownerCellar,
        user: cellarOwner,
        before: before,
        draft: draft,
        targetQuantity: 1,
      );

      final estimate = estimates.single;
      expect(years(estimate.baseWindow!), [2021, 2022, 2025]);
      expect(estimate.window!.endYear, 2035);
    });

    test(
      '3. ensureEstimates: a wine to estimate keeps its correction',
      () async {
        final wine = cellarWine(
          'w1',
          name: 'Rioja DOCa',
          vintage: 2020,
          level: WineLevel.aging,
          windowOverride: _override,
        );

        await actions.ensureEstimates(
          cellar: ownerCellar,
          user: cellarOwner,
          wines: [wine],
        );

        expect(years(estimates.single.baseWindow!), [2023, 2025, 2031]);
        expect(estimates.single.window!.endYear, 2035);
      },
    );

    test('4. EstimateRefresher: the catalog refinement keeps both', () async {
      catalog.profile = const WineProfileResult(found: true);
      final refresher = EstimateRefresher(
        wines: wines,
        catalog: catalog,
        network: FakeCellarNetwork(),
        reporter: recordingReporter(sink),
        clock: clock,
      );
      final internal = windowOf(2022, 2024, 2028);
      final wine = cellarWine(
        'w1',
        name: 'Rioja DOCa',
        vintage: 2020,
        window: internal,
        baseWindow: internal,
        level: WineLevel.aging,
        windowOverride: _override,
      );

      await refresher.refreshWine(ownerCellar, cellarOwner, wine);

      expect(years(estimates.single.baseWindow!), [2023, 2025, 2031]);
      expect(estimates.single.window!.endYear, 2035);
    });

    test('5. recomputeAdjustment: a drink never moves the corrected end '
        '(FR5.3, FR5.6)', () async {
      final base = windowOf(2020, 2024, 2030);
      stored = WineRecords(
        records: [
          drinkRecord(
            'r1',
            drankOn: DateTime(2026, 6),
            condition: DrinkCondition.tooYoung,
          ),
        ],
        fromServer: true,
      );

      await actions.recomputeAdjustment(
        cellar: ownerCellar,
        user: cellarOwner,
        wine: cellarWine(
          'w1',
          window: windowOf(2020, 2024, 2028),
          baseWindow: base,
          windowOverride: const WindowOverride(endYear: 2028),
        ),
      );

      expect(years(estimates.single.window!), [2027, 2028, 2028]);
      expect(estimates.single.baseWindow, base);
    });

    test('6. WineEstimator.displayed: level and correction in memory', () {
      final shown = const WineEstimator().displayed(
        cellarWine(
          'w1',
          name: 'Rioja DOCa',
          vintage: 2020,
          level: WineLevel.aging,
          windowOverride: _override,
        ),
        fallbackYear: 2026,
      );

      expect(years(shown.baseWindow!), [2023, 2025, 2031]);
      expect(shown.window!.endYear, 2035);
    });

    group('F5 correction and restore', () {
      final base = windowOf(2024, 2031, 2046);
      late List<Map<String, Object?>> calls;

      setUp(() {
        calls = [];
        when(
          () => wines.setOverride(
            cellarId: any(named: 'cellarId'),
            user: any(named: 'user'),
            wine: any(named: 'wine'),
            endYear: any(named: 'endYear'),
            window: any(named: 'window'),
          ),
        ).thenAnswer((invocation) async {
          calls.add({
            'endYear': invocation.namedArguments[#endYear],
            'window': invocation.namedArguments[#window],
          });
          return const SaveAccepted();
        });
        when(
          () => wines.clearOverride(
            cellarId: any(named: 'cellarId'),
            user: any(named: 'user'),
            wine: any(named: 'wine'),
            window: any(named: 'window'),
          ),
        ).thenAnswer((invocation) async {
          calls.add({'window': invocation.namedArguments[#window]});
          return const SaveAccepted();
        });
      });

      test('FR5.1 a valid year writes the correction and the window', () async {
        final ok = await actions.setOverride(
          cellar: ownerCellar,
          user: cellarOwner,
          wine: cellarWine('w1', window: base, baseWindow: base),
          endYear: 2028,
        );

        expect(ok, isTrue);
        expect(calls.single['endYear'], 2028);
        expect(years(calls.single['window']! as DrinkingWindow), [
          2024,
          2028,
          2028,
        ]);
      });

      test('BR4.6 a year outside start..start+60, a reader or no estimate '
          'write nothing', () async {
        final wine = cellarWine('w1', window: base, baseWindow: base);
        expect(
          await actions.setOverride(
            cellar: ownerCellar,
            user: cellarOwner,
            wine: wine,
            endYear: 2023,
          ),
          isFalse,
        );
        expect(
          await actions.setOverride(
            cellar: ownerCellar,
            user: cellarOwner,
            wine: wine,
            endYear: 2085,
          ),
          isFalse,
        );
        expect(
          await actions.setOverride(
            cellar: readCellar,
            user: cellarEditor,
            wine: wine,
            endYear: 2030,
          ),
          isFalse,
        );
        expect(
          await actions.setOverride(
            cellar: ownerCellar,
            user: cellarOwner,
            wine: cellarWine('w2'),
            endYear: 2030,
          ),
          isFalse,
        );
        expect(calls, isEmpty);
      });

      test('FR5.4 restore: back to the estimate, the feedback kept', () async {
        const justRight = WindowAdjustment(
          kind: DrinkCondition.justRight,
          year: 2048,
          recordId: 'r1',
        );
        final ok = await actions.restoreEstimate(
          cellar: editCellar,
          user: cellarEditor,
          wine: cellarWine(
            'w1',
            window: windowOf(2024, 2031, 2035),
            baseWindow: base,
            adjustment: justRight,
            windowOverride: _override,
          ),
        );

        expect(ok, isTrue);
        expect(years(calls.single['window']! as DrinkingWindow), [
          2024,
          2031,
          2049,
        ]);
        expect(
          await actions.restoreEstimate(
            cellar: ownerCellar,
            user: cellarOwner,
            wine: cellarWine('w2', window: base, baseWindow: base),
          ),
          isFalse,
        );
      });
    });
  });
}
