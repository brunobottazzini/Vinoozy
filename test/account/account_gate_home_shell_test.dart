// AccountGateView with the Dashboard (u5-dashboard security-design.md §5,
// NFR7.5): GateEnsureCellar and GateCellar show the HomeShell and pass setup
// and onRetrySetup to both tabs; the other gate states are unchanged.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/account_gate.dart';
import 'package:vinoozy/account/ui/account_gate_view.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/dashboard/ui/dashboard_screen.dart';

import '../dashboard/dashboard_harness.dart';
import '../dashboard/fixtures.dart';
import '../helpers/ui_harness.dart';

class _MockAccountGate extends Mock implements AccountGate {}

void main() {
  late _MockAccountGate gate;
  late ValueNotifier<GateState> state;
  late DashboardStreams streams;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    gate = _MockAccountGate();
    state = ValueNotifier(const GateStarting());
    streams = DashboardStreams();
    when(() => gate.state).thenReturn(state);
    when(() => gate.retryCellar()).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester) => pumpScreen(
    tester,
    const AccountGateView(),
    // The network comes from streams.overrides since u4-cellar.
    overrides: [
      ...streams.overrides,
      accountGateProvider.overrideWithValue(gate),
    ],
  );

  Finder mounted(Type type) => find.byType(type, skipOffstage: false);

  testWidgets('GateEnsureCellar shows the shell on the Dashboard, preparing', (
    tester,
  ) async {
    await pump(tester);
    state.value = const GateEnsureCellar(dashboardUser);
    await tester.pump();

    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byKey(const Key('dashboard-loading')), findsOneWidget);
    final shell = tester.widget<HomeShell>(find.byType(HomeShell));
    expect(shell.setup, CellarSetup.preparing);
    expect(
      tester.widget<CellarScreen>(mounted(CellarScreen)).setup,
      CellarSetup.preparing,
    );
  });

  testWidgets('GateCellar ready shows the Dashboard with the wines', (
    tester,
  ) async {
    await pump(tester);
    state.value = const GateCellar(dashboardUser);
    await tester.pump();
    streams
      ..emitCellar()
      ..emitWines([wineOf('w1', quantity: 3)]);
    await tester.pumpAndSettle();

    expect(find.text('3 bottiglie in cantina'), findsOneWidget);
    expect(
      tester.widget<DashboardScreen>(mounted(DashboardScreen)).setup,
      CellarSetup.ready,
    );
  });

  testWidgets('GateCellar failed: both tabs failed, "Riprova" calls '
      'retryCellar', (tester) async {
    await pump(tester);
    state.value = const GateCellar(dashboardUser, setupFailed: true);
    await tester.pump();

    expect(find.byKey(const Key('dashboard-error')), findsOneWidget);
    expect(
      tester.widget<CellarScreen>(mounted(CellarScreen)).setup,
      CellarSetup.failed,
    );
    await tester.tap(find.byKey(const Key('dashboard-retry-button')));
    verify(() => gate.retryCellar()).called(1);
  });

  testWidgets('the tab stays selected when the setup becomes ready', (
    tester,
  ) async {
    await pump(tester);
    state.value = const GateEnsureCellar(dashboardUser);
    await tester.pump();
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    // The cellar spinner never settles while preparing.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('cellar-loading')), findsOneWidget);

    state.value = const GateCellar(dashboardUser);
    await tester.pump();
    streams
      ..emitCellar()
      ..emitWines(const []);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cellar-empty')), findsOneWidget);
  });
}
