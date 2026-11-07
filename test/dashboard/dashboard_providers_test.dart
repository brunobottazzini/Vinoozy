// dashboardSummaryProvider and breakdownModeProvider (u5-dashboard
// logical-components.md; BR1.6, BR1.8, BR1.9; NFR2.3, NFR6.2, NFR6.3).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/dashboard/dashboard_providers.dart';

import 'dashboard_harness.dart';
import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DashboardStreams streams;
  late ProviderContainer container;
  late List<DashboardState> states;

  // Stream events and Riverpod's scheduled rebuilds take a few turns of the
  // event loop.
  Future<void> settle() => pumpEventQueue();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    streams = DashboardStreams();
    container = ProviderContainer(overrides: streams.overrides);
    states = [];
    container.listen<DashboardState>(
      dashboardSummaryProvider(dashboardUser.uid),
      (_, next) => states.add(next),
      fireImmediately: true,
    );
  });

  tearDown(() async {
    container.dispose();
    await streams.close();
  });

  DashboardState current() =>
      container.read(dashboardSummaryProvider(dashboardUser.uid));

  group('states (BR1.8, BR1.9, NFR6.2, NFR6.3)', () {
    test('loading until the first wines snapshot', () async {
      streams.emitCellar();
      await settle();

      expect(current(), isA<DashboardLoading>());
      expect(streams.calculator.calls, 0);
    });

    test('wines give the summary', () async {
      streams
        ..emitCellar()
        ..emitWines([
          wineOf('w1', quantity: 2, window: window(2020, 2024, 2026)),
        ]);
      await settle();

      final state = current() as DashboardReady;
      expect(state.summary.totalBottles, 2);
      expect(state.summary.drinkSoonBottles, 2);
      expect(state, DashboardReady(state.summary));
      expect(state.hashCode, state.summary.hashCode);
    });

    test('0 bottles from the local cache only: syncing, not empty', () async {
      streams.emitWines(const [], meta: fromCache);
      await settle();

      expect(current(), isA<DashboardSyncing>());
    });

    test('0 bottles confirmed by the server: empty', () async {
      streams.emitWines([wineOf('zero', quantity: 0)]);
      await settle();

      expect(current(), isA<DashboardEmpty>());
    });

    test('a wines listener error shows the failure', () async {
      streams.emitCellar();
      streams.winesStream.addError(StateError('permission-denied'));
      await settle();

      expect(current(), isA<DashboardFailed>());
    });

    test('a cellar listener error shows the failure too', () async {
      streams.emitWines([wineOf('w1')]);
      streams.cellar.addError(StateError('permission-denied'));
      await settle();

      expect(current(), isA<DashboardFailed>());
    });

    test('new wines recompute the summary by themselves (BR1.9)', () async {
      streams.emitWines([wineOf('w1')]);
      await settle();
      streams.emitWines([wineOf('w1'), wineOf('w2', quantity: 3)]);
      await settle();

      expect((current() as DashboardReady).summary.totalBottles, 4);
      expect(streams.calculator.calls, 2);
    });
  });

  group('recalculation only when needed (NFR2.3)', () {
    test('changing the breakdown selector does not recompute', () async {
      streams.emitWines(syntheticCellar(50));
      await settle();
      expect(streams.calculator.calls, 1);

      await container
          .read(breakdownModeProvider.notifier)
          .select(BreakdownMode.region);
      await container
          .read(breakdownModeProvider.notifier)
          .select(BreakdownMode.type);
      await settle();

      expect(streams.calculator.calls, 1);
      expect(current(), isA<DashboardReady>());
    });

    test('a new cellar snapshot does not recompute', () async {
      streams
        ..emitCellar()
        ..emitWines([wineOf('w1')]);
      await settle();
      final calls = streams.calculator.calls;

      streams.emitCellar();
      await settle();

      expect(streams.calculator.calls, calls);
    });
  });

  group('invalid windows (BR1.2, NFR8.1)', () {
    test('the provider reports them once, through the U1 error exit', () async {
      streams.emitWines([wineOf('bad', window: window(2030, 2020, 2040))]);
      await settle();
      streams.emitWines([
        wineOf('bad', window: window(2030, 2020, 2040)),
        wineOf('bad2', window: window(2031, 2020, 2040)),
      ]);
      await settle();

      expect(streams.calculator.calls, 2);
      expect(streams.sink.reasons, ['dashboard_invalid_window']);
    });

    test('valid wines report nothing', () async {
      streams.emitWines(syntheticCellar(30));
      await settle();

      expect(streams.sink.recorded, isEmpty);
    });
  });

  group('breakdown selector preference (BR1.6)', () {
    Future<BreakdownMode> restored(Map<String, Object> stored) async {
      SharedPreferences.setMockInitialValues(stored);
      final fresh = ProviderContainer(overrides: streams.overrides);
      addTearDown(fresh.dispose);
      fresh.read(breakdownModeProvider);
      await settle();
      await settle();
      return fresh.read(breakdownModeProvider);
    }

    test('absent: starts from Type', () async {
      expect(await restored({}), BreakdownMode.type);
    });

    test('a stored Region is restored', () async {
      expect(
        await restored({breakdownModeKey: 'region'}),
        BreakdownMode.region,
      );
    });

    test('an unknown or wrongly typed value falls back to Type', () async {
      expect(await restored({breakdownModeKey: 'pie'}), BreakdownMode.type);
      expect(await restored({breakdownModeKey: 3}), BreakdownMode.type);
    });

    test('the choice is saved under dashboard.breakdownMode', () async {
      await container
          .read(breakdownModeProvider.notifier)
          .select(BreakdownMode.region);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(breakdownModeKey), 'region');
      expect(prefs.getKeys(), {breakdownModeKey}, reason: 'the only write');
      expect(container.read(breakdownModeProvider), BreakdownMode.region);
    });

    test('preferences that cannot be opened: Type, and a choice still '
        'changes the view without errors', () async {
      streams.preferencesError = StateError('disk unavailable');
      final fresh = ProviderContainer(overrides: streams.overrides);
      addTearDown(fresh.dispose);

      expect(fresh.read(breakdownModeProvider), BreakdownMode.type);
      await settle();
      await fresh
          .read(breakdownModeProvider.notifier)
          .select(BreakdownMode.region);

      expect(fresh.read(breakdownModeProvider), BreakdownMode.region);
    });

    test('a choice made before the restore finishes wins', () async {
      SharedPreferences.setMockInitialValues({breakdownModeKey: 'type'});
      final fresh = ProviderContainer(overrides: streams.overrides);
      addTearDown(fresh.dispose);
      fresh.read(breakdownModeProvider);
      await fresh
          .read(breakdownModeProvider.notifier)
          .select(BreakdownMode.region);
      await settle();

      expect(fresh.read(breakdownModeProvider), BreakdownMode.region);
    });

    test('BreakdownMode.parse accepts only the two names', () {
      expect(BreakdownMode.parse('type'), BreakdownMode.type);
      expect(BreakdownMode.parse('region'), BreakdownMode.region);
      expect(BreakdownMode.parse(null), isNull);
      expect(BreakdownMode.parse(1), isNull);
    });
  });
}
