import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/account_gate.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/account/ui/account_gate_view.dart';
import 'package:vinoozy/account/ui/status_screens.dart';
import 'package:vinoozy/app/providers.dart';

import '../../helpers/ui_harness.dart';
import 'cellar_screen_test.dart' show CellarFixture;
import 'sign_in_screen_test.dart' show FakeNetwork;

class MockAccountGate extends Mock implements AccountGate {}

void main() {
  const userA = AppUser(
    uid: 'user-a',
    email: 'user-a@example.com',
    displayName: 'A',
  );
  late MockAccountGate gate;
  late ValueNotifier<GateState> state;
  late CellarFixture fixture;

  setUp(() {
    gate = MockAccountGate();
    state = ValueNotifier(const GateStarting());
    fixture = CellarFixture();
    when(() => gate.state).thenReturn(state);
    when(() => gate.retryCheck()).thenAnswer((_) async {});
    when(() => gate.signIn()).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester) => pumpScreen(
    tester,
    const AccountGateView(),
    overrides: [
      ...fixture.overrides,
      accountGateProvider.overrideWithValue(gate),
      networkStatusProvider.overrideWithValue(FakeNetwork()),
    ],
  );

  testWidgets('starting and resetting show the loading screen', (tester) async {
    await pump(tester);
    expect(find.byType(GateLoadingScreen), findsOneWidget);

    state.value = const GateResetting();
    await tester.pump();
    expect(find.byType(GateLoadingScreen), findsOneWidget);
  });

  testWidgets('sign-in, blocked and restart map to their screens', (
    tester,
  ) async {
    await pump(tester);

    state.value = const GateSignIn();
    await tester.pump();
    expect(find.byKey(const Key('sign-in-screen')), findsOneWidget);

    state.value = const GateBlocked(
      user: userA,
      ownerEmail: 'other@example.com',
      unsavedCount: 1,
    );
    await tester.pump();
    expect(find.byKey(const Key('blocked-account-screen')), findsOneWidget);

    state.value = const GateRestartRequired();
    await tester.pump();
    expect(find.byKey(const Key('restart-required-screen')), findsOneWidget);
  });

  testWidgets('an unreadable ledger shows the error with retry', (
    tester,
  ) async {
    await pump(tester);
    state.value = const GateCheckFailed(userA);
    await tester.pump();

    await tester.tap(find.byKey(const Key('gate-error-retry-button')));
    verify(() => gate.retryCheck()).called(1);
  });

  // Since u5-dashboard the shell opens on the Dashboard: the cellar screen
  // is the "Cantina" tab.
  testWidgets('ensure-cellar and cellar states show the cellar screen in the '
      '"Cantina" tab', (tester) async {
    await pump(tester);
    state.value = const GateEnsureCellar(userA);
    await tester.pump();
    expect(find.byKey(const Key('dashboard-loading')), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pump();
    expect(find.byKey(const Key('cellar-loading')), findsOneWidget);

    state.value = const GateCellar(userA, setupFailed: true);
    await tester.pump();
    expect(find.byKey(const Key('cellar-error')), findsOneWidget);
  });

  testWidgets('the restart screen closes the app (plan B)', (tester) async {
    var closed = 0;
    await pumpScreen(
      tester,
      RestartRequiredScreen(closeApp: () async => closed++),
    );

    await tester.tap(find.byKey(const Key('restart-close-app-button')));
    expect(closed, 1);
  });

  accessibilityMatrix(
    'RestartRequiredScreen',
    () => RestartRequiredScreen(closeApp: () async {}),
  );
  accessibilityMatrix(
    'GateErrorScreen',
    () => GateErrorScreen(message: 'x', onRetry: () {}),
  );
}
