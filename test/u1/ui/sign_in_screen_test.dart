import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/account/gate_state.dart';
import 'package:vinoozy/account/network_status.dart';
import 'package:vinoozy/account/ui/sign_in_screen.dart';
import 'package:vinoozy/app/providers.dart';

import '../../helpers/ui_harness.dart';

/// A network the test switches on and off; [onChanged] emits each change
/// (u7-sharing BR1.11, NFR6.1).
class FakeNetwork implements NetworkStatus {
  FakeNetwork({this._online = true});

  bool _online;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  bool get online => _online;

  set online(bool value) {
    _online = value;
    _changes.add(value);
  }

  @override
  Future<bool> hasNetwork() async => _online;

  @override
  Stream<bool> get onChanged => _changes.stream;
}

void main() {
  late FakeNetwork network;
  late int signIns;

  setUp(() {
    network = FakeNetwork();
    signIns = 0;
  });

  Future<void> pump(
    WidgetTester tester, {
    SignInNotice? notice,
    bool busy = false,
    Locale locale = const Locale('it'),
  }) => pumpScreen(
    tester,
    SignInScreen(onSignIn: () async => signIns++, notice: notice, busy: busy),
    locale: locale,
    overrides: [networkStatusProvider.overrideWithValue(network)],
  );

  testWidgets('shows the tagline and the only Google button (M1)', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('La tua cantina, al momento giusto'), findsOneWidget);
    expect(find.text('Continua con Google'), findsOneWidget);
    expect(find.byKey(const Key('sign-in-message')), findsNothing);
  });

  testWidgets('a tap with network starts the sign-in', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('sign-in-google-button')));
    await tester.pumpAndSettle();

    expect(signIns, 1);
  });

  testWidgets('without network the first sign-in is explained, not started', (
    tester,
  ) async {
    network.online = false;
    await pump(tester);
    await tester.pumpAndSettle();
    expect(
      find.text('Serve la connessione per il primo accesso'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('sign-in-google-button')));
    await tester.pumpAndSettle();

    expect(signIns, 0);
  });

  testWidgets('a failed sign-in shows the error and "Riprova"', (tester) async {
    await pump(tester, notice: SignInNotice.failed);
    await tester.pumpAndSettle();

    expect(find.text('Accesso non riuscito'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sign-in-retry-button')));
    await tester.pumpAndSettle();
    expect(signIns, 1);
  });

  testWidgets('while busy the button is disabled and shows progress', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, busy: true);

    final button = tester.widget<ButtonStyleButton>(
      find.byKey(const Key('sign-in-google-button')),
    );
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // The button merges its children: TalkBack reads progress and label.
    expect(find.bySemanticsLabel(RegExp('Accesso in corso')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a revoked session is explained (W2)', (tester) async {
    await pump(tester, notice: SignInNotice.sessionExpired);
    await tester.pumpAndSettle();

    expect(find.text('La sessione è scaduta: accedi di nuovo'), findsOneWidget);
    expect(find.byKey(const Key('sign-in-retry-button')), findsNothing);
  });

  testWidgets('English and Brazilian Portuguese texts are used', (
    tester,
  ) async {
    await pump(tester, locale: const Locale('en'));
    expect(find.text('Continue with Google'), findsOneWidget);

    await pump(tester, locale: const Locale('pt', 'BR'));
    expect(find.text('Continuar com o Google'), findsOneWidget);
  });

  accessibilityMatrix(
    'SignInScreen',
    () => SignInScreen(onSignIn: () async {}, notice: SignInNotice.failed),
    overrides: () => [networkStatusProvider.overrideWithValue(FakeNetwork())],
  );
}
