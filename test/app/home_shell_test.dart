// HomeShell (u5-dashboard logical-components.md; FR5.1, NFR7.5): Dashboard
// first, Cellar second, one shared listener, injected navigation.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/cellar/ui/history_screen.dart';
import 'package:vinoozy/cellar/ui/wine_detail_screen.dart';
import 'package:vinoozy/dashboard/ui/dashboard_screen.dart';
import 'package:vinoozy/label/ui/add_choice_screen.dart';

import '../dashboard/dashboard_harness.dart';
import '../dashboard/fixtures.dart';
import '../helpers/ui_harness.dart';

void main() {
  late DashboardStreams streams;
  late int retries;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    streams = DashboardStreams();
    retries = 0;
  });

  Future<void> pump(
    WidgetTester tester, {
    CellarSetup setup = CellarSetup.ready,
  }) => pumpScreen(
    tester,
    HomeShell(
      user: dashboardUser,
      setup: setup,
      onRetrySetup: () async => retries++,
    ),
    overrides: streams.overrides,
  );

  Future<void> emit(WidgetTester tester, List wines) async {
    streams
      ..emitCellar()
      ..emitWines([...wines]);
    await tester.pumpAndSettle();
  }

  Finder onScreen(Type type) => find.byType(type);
  Finder mounted(Type type) => find.byType(type, skipOffstage: false);

  testWidgets('opens on the Dashboard; the Cellar tab stays mounted', (
    tester,
  ) async {
    await pump(tester);
    await emit(tester, [wineOf('w1', name: 'Barolo')]);

    expect(onScreen(DashboardScreen), findsOneWidget);
    expect(onScreen(CellarScreen), findsNothing);
    expect(mounted(CellarScreen), findsOneWidget);
  });

  testWidgets('the navigation bar switches between the two tabs', (
    tester,
  ) async {
    await pump(tester);
    await emit(tester, [wineOf('w1', name: 'Barolo')]);

    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();
    expect(onScreen(CellarScreen), findsOneWidget);
    expect(find.byKey(const Key('cellar-wine-list')), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-nav-dashboard')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard-content')), findsOneWidget);
  });

  testWidgets('both tabs share one wines and one cellar listener', (
    tester,
  ) async {
    await pump(tester);
    await emit(tester, [wineOf('w1')]);
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();

    verify(() => streams.wines.watchCellarWines(dashboardUser.uid)).called(1);
    verify(() => streams.cellars.watchCellar(dashboardUser.uid)).called(1);
  });

  testWidgets('BR1.17 a wine of the Dashboard opens its detail', (
    tester,
  ) async {
    await pump(tester);
    await emit(tester, [
      wineOf('w1', name: 'Barolo', window: window(2020, 2024, 2026)),
    ]);

    await tester.tap(find.byKey(const Key('drink-soon-w1')));
    await tester.pumpAndSettle();

    expect(find.byType(WineDetailScreen), findsOneWidget);
    expect(find.byKey(const Key('window-card')), findsOneWidget);
  });

  testWidgets('BR1.17 a status opens the Cellar filtered by that status', (
    tester,
  ) async {
    await pump(tester);
    await emit(tester, [
      wineOf('w1', name: 'Barolo', window: window(2020, 2024, 2030)),
      wineOf('w2', name: 'Soave', window: window(2030, 2031, 2033)),
    ]);

    await tester.ensureVisible(find.byKey(const Key('chart-status-ready')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chart-status-ready')));
    await tester.pumpAndSettle();

    expect(onScreen(CellarScreen), findsOneWidget);
    final chip = tester.widget<FilterChip>(
      find.byKey(const Key('cellar-filter-status-ready')),
    );
    expect(chip.selected, isTrue);
    expect(find.byKey(const ValueKey('w1')), findsOneWidget);
    expect(find.byKey(const ValueKey('w2')), findsNothing);
  });

  testWidgets('BR1.16 R-01 coming back to the History reads it again', (
    tester,
  ) async {
    final records = streams.records;
    when(
      () => records.pageHistory(any(), after: any(named: 'after'), limit: 30),
    ).thenAnswer(
      (_) async => const HistoryPage(records: [], cursor: null, hasMore: false),
    );
    await pump(tester);
    await emit(tester, [wineOf('w1')]);

    await tester.tap(find.byKey(const Key('home-nav-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-nav-history')));
    await tester.pumpAndSettle();

    verify(
      () => records.pageHistory(any(), after: any(named: 'after'), limit: 30),
    ).called(2);
  });

  testWidgets('BR1.16 the third tab is the History, read when opened', (
    tester,
  ) async {
    final records = streams.records;
    when(
      () => records.pageHistory(any(), after: any(named: 'after'), limit: 30),
    ).thenAnswer(
      (_) async => const HistoryPage(records: [], cursor: null, hasMore: false),
    );
    await pump(tester);
    await emit(tester, [wineOf('w1')]);
    verifyNever(
      () => records.pageHistory(any(), after: any(named: 'after'), limit: 30),
    );

    await tester.tap(find.byKey(const Key('home-nav-history')));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(
      find.text('Qui troverai le bottiglie che hai bevuto'),
      findsOneWidget,
    );
  });

  testWidgets('"Aggiungi il primo vino" opens the three ways to add, '
      '"Scrivi" the add-wine form (u6 BR1.1)', (tester) async {
    await pump(tester);
    await emit(tester, const []);

    await tester.tap(find.byKey(const Key('dashboard-empty-add')));
    await tester.pumpAndSettle();
    expect(find.byType(AddChoiceScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-choice-write')));
    await tester.pumpAndSettle();
    expect(find.byType(AddWineScreen), findsOneWidget);
    expect(find.byType(AddChoiceScreen), findsNothing);
  });

  testWidgets('setup and retry reach both tabs', (tester) async {
    await pump(tester, setup: CellarSetup.failed);

    final dashboard = tester.widget<DashboardScreen>(mounted(DashboardScreen));
    final cellar = tester.widget<CellarScreen>(mounted(CellarScreen));
    expect(dashboard.setup, CellarSetup.failed);
    expect(cellar.setup, CellarSetup.failed);
    expect(dashboard.user, dashboardUser);
    expect(cellar.user, dashboardUser);

    await tester.tap(find.byKey(const Key('dashboard-retry-button')));
    await cellar.onRetrySetup();
    expect(retries, 2);
  });

  accessibilityMatrix(
    'HomeShell',
    () => HomeShell(
      user: dashboardUser,
      setup: CellarSetup.ready,
      onRetrySetup: () async {},
    ),
    overrides: () {
      streams = DashboardStreams();
      return streams.overrides;
    },
    afterPump: (tester) => emit(tester, [wineOf('w1', name: 'Barolo')]),
  );
}
