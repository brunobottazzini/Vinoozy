// End-to-end test of two drinks of the same wine at the same time (u4-cellar
// NFR6.3, AC9.2.1; BR1.15) on the Android emulator with the Firebase
// Emulator Suite, with the real rules:
//
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/concurrent_drink_test.dart \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
//
// 1. The owner (userA, REST with their own token) creates a wine with 4
//    bottles and invites the person of the app (userB) with "edit".
// 2. The app signs in, activates the invitation, picks the shared cellar
//    and waits for the wine, so it is in the cache.
// 3. The app goes offline and records a drink, which stays queued.
// 4. Meanwhile the owner records a drink with increment(−1).
// 5. The app goes online: the server has 2 bottles, the two decrements add
//    up.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/e2e/test_network_control.dart';

import 'e2e_helpers.dart';

const _wait = Duration(seconds: 15);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final network = TestNetworkControl(() => FirebaseFirestore.instance);

  testWidgets('two drinks, one offline, add up on the server', (tester) async {
    await clearPhone();
    await clearEmulators();
    final owner = await ownerRestClient(userA);
    await owner.createCellar('Cantina di user-a');
    await owner.createWine('shared-w1', name: 'Barbaresco', quantity: 4);
    await owner.invite(userB.email, 'edit', 'user-a');

    await launchApp(tester);
    await signIn(
      tester,
      userB,
      then: find.byKey(const Key('dashboard-screen')),
      viaCellarTab: false,
    );
    final switcher = find.byKey(const Key('cellar-switcher'));
    await waitFor(tester, switcher, timeout: _wait, viaCellarTab: false);
    // u7 BR1.4: "user-a shared their cellar with you" covers the screen.
    await acknowledgeSharedNotice(tester, timeout: _wait);
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();
    await tapWhenHittable(tester, switcher);
    await waitFor(tester, find.byKey(Key('cellar-option-${owner.uid}')));
    await tester.tap(find.byKey(Key('cellar-option-${owner.uid}')));
    await waitFor(tester, wineRow('Barbaresco'), timeout: _wait);

    await network.disableNetwork();
    // ux-redesign FR2.2: "Ho bevuto", then "Sì, l'ho bevuta".
    await drinkAndConfirm(tester, drinkButtonOf('Barbaresco'));
    await waitFor(tester, find.byKey(const Key('drink-undo')));
    await owner.recordDrink(
      'shared-w1',
      'owner-drink',
      wineName: 'Barbaresco',
      drankOn: formatDrankOn(DateTime.now()),
    );
    await network.enableNetwork();

    await eventually(
      tester,
      () async => await cloudQuantity(owner.uid, 'shared-w1') == 2,
      timeout: _wait,
      reason: 'both decrements reached the server (4 - 1 - 1)',
    );
    expect(await cloudDrinkCount(owner.uid), 2);
  });
}
