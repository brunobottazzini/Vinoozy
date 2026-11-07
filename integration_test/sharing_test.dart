// End-to-end test of the sharing with two people (u7-sharing NFR2.2, NFR2.3,
// NFR7.4; performance-design.md §2). The app on the Android emulator is the
// invited person (userB); the owner (userA) acts from the test through the
// emulators' REST API with their own token (ownerRestClient), so every write
// passes the real rules:
//
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/sharing_test.dart \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
//
// Sequence: invitation -> the cellar appears -> "edit" and a wine added ->
// revocation -> the cellar disappears with the notice. Every wait is at most
// 15 seconds (the CI margin of the 5-second phone targets).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'e2e_helpers.dart';

/// The CI limit of NFR2.2 and NFR2.3.
const sharingWait = Duration(seconds: 15);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('invitation, access, edit permission and revocation with two '
      'people', (tester) async {
    await clearPhone();
    await clearEmulators();
    final owner = await ownerRestClient(userA);
    await owner.createCellar('Cantina di user-a');
    await owner.invite(userB.email, 'read', 'user-a');

    await launchApp(tester);
    await signIn(
      tester,
      userB,
      then: find.byKey(const Key('dashboard-screen')),
      viaCellarTab: false,
    );

    // NFR2.2: the shared cellar appears (search, activation) within 15 s.
    final switcher = find.byKey(const Key('cellar-switcher'));
    await waitFor(tester, switcher, timeout: sharingWait, viaCellarTab: false);
    // u7 BR1.4: "user-a shared their cellar with you" covers the screen.
    await acknowledgeSharedNotice(tester, timeout: sharingWait);
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();
    await tapWhenHittable(tester, switcher);
    await waitFor(tester, find.byKey(Key('cellar-option-${owner.uid}')));
    await tester.tap(find.byKey(Key('cellar-option-${owner.uid}')));
    await waitFor(tester, find.text('Cantina di user-a · Solo lettura'));
    expect(find.byKey(const Key('cellar-add-button')), findsNothing);

    // NFR2.3: "edit" reaches the open app within 15 s and shows "Add".
    await owner.changePermission(userB.email, 'edit');
    await waitFor(
      tester,
      find.byKey(const Key('cellar-add-button')),
      timeout: sharingWait,
    );
    await addWine(tester, name: 'Nebbiolo condiviso', vintage: '2019');
    await eventually(
      tester,
      () async =>
          (await cloudWineNames(owner.uid)).contains('Nebbiolo condiviso'),
      timeout: sharingWait,
      reason: 'the wine of userB is in the cellar of userA (BR1.6)',
    );

    // NFR2.3 BR1.8: the revocation removes the cellar, with the notice.
    await owner.revoke(userB.email);
    await waitFor(
      tester,
      find.byKey(const Key('shared-cellar-notice')),
      timeout: sharingWait,
    );
    await tester.tap(find.byKey(const Key('shared-cellar-notice-ok')));
    await tester.pumpAndSettle();
    expect(switcher, findsNothing);
  });
}
