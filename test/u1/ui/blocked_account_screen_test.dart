import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/account/gate_state.dart';
import 'package:vinoozy/account/ui/blocked_account_screen.dart';

import '../../helpers/ui_harness.dart';

void main() {
  const userB = AppUser(
    uid: 'user-b',
    email: 'b@example.com',
    displayName: 'B',
  );
  const blocked = GateBlocked(
    user: userB,
    ownerEmail: 'user-a@example.com',
    unsavedCount: 2,
  );
  late int signInWithOwner;
  late int discards;

  setUp(() {
    signInWithOwner = 0;
    discards = 0;
  });

  Future<void> pump(WidgetTester tester, GateBlocked state) => pumpScreen(
    tester,
    BlockedAccountScreen(
      state: state,
      onSignInWithOwner: () async => signInWithOwner++,
      onDiscard: () async => discards++,
    ),
  );

  testWidgets('explains whose changes are pending (BR1.4)', (tester) async {
    await pump(tester, blocked);

    expect(
      find.text(
        'Ci sono modifiche di user-a@example.com non ancora salvate nel '
        "cloud: accedi con quell'account e collegati alla rete",
      ),
      findsOneWidget,
    );
    expect(find.text('Accedi con user-a@example.com'), findsOneWidget);
  });

  testWidgets('"Accedi con <email>" signs out', (tester) async {
    await pump(tester, blocked);

    await tester.tap(
      find.byKey(const Key('blocked-sign-in-with-owner-button')),
    );
    await tester.pumpAndSettle();

    expect(signInWithOwner, 1);
    expect(discards, 0);
  });

  testWidgets('discard asks with email and count, never wine names', (
    tester,
  ) async {
    await pump(tester, blocked);

    await tester.tap(find.byKey(const Key('blocked-discard-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('discard-dialog')), findsOneWidget);
    expect(
      find.text(
        '2 vini di user-a@example.com non sono ancora nel cloud e verranno '
        'eliminati da questo telefono.',
      ),
      findsOneWidget,
    );
    expect(discards, 0);
  });

  testWidgets('cancelling the dialog keeps the changes', (tester) async {
    await pump(tester, blocked);
    await tester.tap(find.byKey(const Key('blocked-discard-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('discard-dialog-cancel-button')));
    await tester.pumpAndSettle();

    expect(discards, 0);
    expect(find.byKey(const Key('discard-dialog')), findsNothing);
  });

  testWidgets('confirming the dialog deletes the changes', (tester) async {
    await pump(tester, blocked);
    await tester.tap(find.byKey(const Key('blocked-discard-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('discard-dialog-confirm-button')));
    await tester.pumpAndSettle();

    expect(discards, 1);
  });

  testWidgets('a failed reset stays blocked with "Riprova" (NFR4.10)', (
    tester,
  ) async {
    await pump(
      tester,
      const GateBlocked(
        user: userB,
        ownerEmail: 'user-a@example.com',
        unsavedCount: 1,
        resetFailed: true,
      ),
    );

    expect(
      find.text('Impossibile cancellare i dati di questo telefono'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('blocked-discard-button')), findsNothing);
    await tester.tap(find.byKey(const Key('blocked-retry-button')));
    await tester.pumpAndSettle();
    expect(discards, 1);
  });

  testWidgets('a failed automatic reset shows only the retry', (tester) async {
    await pump(
      tester,
      const GateBlocked(
        user: userB,
        ownerEmail: '',
        unsavedCount: 0,
        resetFailed: true,
      ),
    );

    expect(find.byKey(const Key('blocked-message')), findsNothing);
    expect(
      find.byKey(const Key('blocked-sign-in-with-owner-button')),
      findsNothing,
    );
    expect(find.byKey(const Key('blocked-retry-button')), findsOneWidget);
  });

  accessibilityMatrix(
    'BlockedAccountScreen',
    () => BlockedAccountScreen(
      state: blocked,
      onSignInWithOwner: () async {},
      onDiscard: () async {},
    ),
  );
}
