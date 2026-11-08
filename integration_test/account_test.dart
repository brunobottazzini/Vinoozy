// End-to-end tests of u8-account (NFR7.4, NFR6.3, NFR8.1, NFR1.2) on the
// Android emulator with the Firebase Emulator Suite:
//
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/account_test.dart \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
//
// 1. First start, sign-out with a queued change ("Sign out anyway"), the
//    same account back: the change is not lost and reaches the cloud.
// 2. The whole account deletion with a shared cellar, 50 wines, 100 drinks
//    and an invitation in someone else's cellar, within 60 s; then
//    nothing of the account is left in the cloud.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/e2e/emulator_google_auth_service.dart';
import 'package:vinoozy/e2e/test_network_control.dart';
import 'package:vinoozy/firebase/firebase_env.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

import 'e2e_helpers.dart';

/// The CI limit of NFR1.2 for 50 wines and 100 drinks.
const deletionLimit = Duration(seconds: 60);

String _doc(String path) =>
    'projects/demo-vinoozy/databases/(default)/documents/$path';

/// 50 wines and 100 drinks in [uid]'s cellar, as the emulator admin.
Future<void> seedCellarContent(String uid) => commitWrites([
  for (var i = 0; i < 50; i++)
    {
      'update': {
        'name': _doc('cellars/$uid/wines/w$i'),
        'fields': {
          'name': {'stringValue': 'Vino $i'},
          'quantity': {'integerValue': '${i % 3}'},
          'createdAt': {'timestampValue': '2026-11-06T10:00:00Z'},
          'updatedAt': {'timestampValue': '2026-11-06T10:00:00Z'},
          'updatedBy': {'stringValue': uid},
        },
      },
    },
  for (var i = 0; i < 100; i++)
    {
      'update': {
        'name': _doc('cellars/$uid/drinkingRecords/r$i'),
        'fields': {
          'wineId': {'stringValue': 'w${i % 50}'},
          'wineName': {'stringValue': 'Vino'},
          'drankOn': {'stringValue': '2026-11-01'},
          'recordedBy': {'stringValue': uid},
          'createdAt': {'timestampValue': '2026-11-06T10:00:00Z'},
        },
      },
    },
]);

Future<int> cloudCount(String path) async {
  final (status, body) = await emulatorRequest(
    'GET',
    FirebaseEnvConfig.firestoreEmulatorPort,
    '/v1/projects/demo-vinoozy/databases/(default)/documents/$path',
  );
  if (status != 200) throw StateError('list $path -> $status');
  return ((body as Map?)?['documents'] as List?)?.length ?? 0;
}

Future<void> openProfile(WidgetTester tester) async {
  await waitFor(tester, find.byKey(const Key('cellar-menu')));
  await tester.tap(find.byKey(const Key('cellar-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('cellar-menu-profile')));
  await waitFor(tester, find.byKey(const Key('profile-screen')));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final network = TestNetworkControl(() => FirebaseFirestore.instance);

  tearDown(() => showOnboarding = false);

  testWidgets('BR1.1 BR1.4 NFR6.3 first start, sign-out with a queued change, '
      'the same account back keeps it', (tester) async {
    showOnboarding = true;
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);

    // BR1.1: the presentation before sign-in, "Skip" leads to sign-in.
    await waitFor(tester, find.byKey(const Key('onboarding-screen')));
    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await signIn(tester, userA, then: find.byKey(const Key('cellar-screen')));

    // A wine saved offline stays queued (U1): the network goes off once the
    // cellar is ready.
    await eventually(
      tester,
      () async =>
          tester
              .widget<FloatingActionButton>(
                find.byKey(const Key('cellar-add-button')),
              )
              .onPressed !=
          null,
      reason: 'the cellar is ready',
    );
    await network.disableNetwork();
    await addWine(tester, name: 'Barolo in coda', vintage: '2016');

    // BR1.4: "You have 1 change not saved yet", then "Sign out anyway".
    await openProfile(tester);
    await tester.tap(find.byKey(const Key('profile-sign-out')));
    await waitFor(tester, find.byKey(const Key('sign-out-warning-dialog')));
    await tester.tap(find.byKey(const Key('sign-out-anyway')));
    await waitFor(tester, find.byKey(const Key('sign-in-google-button')));
    expect(find.byKey(const Key('onboarding-screen')), findsNothing);

    // NFR6.3: the same account back, the network back: nothing is lost.
    await network.enableNetwork();
    await signIn(tester, userA, then: wineRow('Barolo in coda'));
    await eventually(
      tester,
      () async => (await cloudWineNames(currentUid)).contains('Barolo in coda'),
      reason: 'the queued wine reached the cloud after signing in again',
    );
  });

  testWidgets('BR1.7 NFR1.2 NFR8.1 the whole deletion with a shared cellar '
      'leaves nothing of the account', (tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(tester, userA, then: find.byKey(const Key('cellar-screen')));
    final uid = currentUid;

    // Mario's cellar shared with userB, 50 wines and 100 drinks, and an
    // invitation of Mario in userB's cellar (the app activates it; the
    // pending case is covered by the rules and web tests).
    final mario = await ownerRestClient(userA);
    expect(mario.uid, uid);
    await waitForCloudCellar(tester, uid);
    await mario.invite(userB.email, 'edit', 'user-a');
    await seedCellarContent(uid);
    final other = await ownerRestClient(userB);
    await other.createCellar('Cantina di user-b');
    await other.invite(userA.email, 'read', 'user-b');
    // The app activates the invitation and says "user-b shared their
    // cellar with you" (u7 BR1.4): close it, it would cover the buttons.
    await waitFor(
      tester,
      find.byKey(const Key('shared-cellar-notice')),
      timeout: const Duration(seconds: 15),
    );
    await tester.tap(find.byKey(const Key('shared-cellar-notice-ok')));
    await tester.pumpAndSettle();

    await openProfile(tester);
    await tester.tap(find.byKey(const Key('profile-delete')));
    final field = find.byKey(const Key('delete-confirm-word'));
    await waitFor(tester, field);
    // The word of the phone's language (BR1.6).
    final l10n = AppLocalizations.of(tester.element(field));
    await tester.enterText(field, l10n.deleteAccountConfirmWord);
    await tester.pump();
    // The real keyboard of the emulator would cover "Delete forever".
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    EmulatorGoogleAuthService.nextIdentity = userA;
    final forever = find.byKey(const Key('delete-forever'));
    await tester.ensureVisible(forever);
    await tester.pumpAndSettle();
    final stopwatch = Stopwatch()..start();
    await tester.tap(forever);

    // BR1.5: only the progress, then sign-in with "Account deleted".
    await waitFor(tester, find.byKey(const Key('deletion-progress')));
    await waitFor(
      tester,
      find.text(l10n.signInAccountDeleted),
      timeout: deletionLimit,
    );
    stopwatch.stop();
    expect(stopwatch.elapsed, lessThan(deletionLimit));

    // NFR8.1: nothing of the account is left in the cloud.
    expect(await cloudDocument('users/$uid'), isNull);
    expect(await cloudDocument('cellars/$uid'), isNull);
    expect(await cloudCount('cellars/$uid/wines'), 0);
    expect(await cloudCount('cellars/$uid/drinkingRecords'), 0);
    expect(await cloudCount('cellars/$uid/members'), 0);
    expect(
      await cloudDocument('cellars/${other.uid}/members/${userA.email}'),
      isNull,
    );
    expect(await cloudDocument('cellars/${other.uid}'), isNotNull);
    // The Auth user is gone: the same Google account is a new account.
    EmulatorGoogleAuthService.nextIdentity = userA;
    await tester.tap(find.byKey(const Key('sign-in-google-button')));
    await waitFor(tester, find.byKey(const Key('cellar-screen')));
    expect(currentUid, isNot(uid));
  });
}
