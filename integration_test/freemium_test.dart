// End-to-end tests of Freemium and Plus (freemium-plus plan Step 18; FR2.4,
// FR2.5, FR4.1, FR4.3, FR5.2, FR5.3, FR5.6, FR6.3) on the Android emulator
// with the Firebase Emulator Suite (demo-vinoozy), never the real project.
//
// They need the developer tools, which exist only in a build made with
// `--dart-define=ENABLE_DEV_CHEATS=true` (FR5.1), and the host side of the
// gift: tool/admin/grant_plus.mjs in `--emulator` mode, run by the host while
// the app waits on the Profile. tool/e2e_freemium.sh runs both:
//
//   npx firebase emulators:exec --only auth,firestore,functions \
//     --project demo-vinoozy "tool/e2e_freemium.sh -d <emulator-id>"
//
// In the ordinary `flutter test integration_test` run (no flag) every test
// of this file is skipped: the CI `e2e` job runs it again through
// tool/e2e_freemium.sh.
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/dev/dev_cheats.dart';
import 'package:vinoozy/dev/ui/dev_tools_screen.dart';
import 'package:vinoozy/e2e/emulator_google_auth_service.dart';
import 'package:vinoozy/firebase/firebase_env.dart';
import 'package:vinoozy/firebase/functions_config.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

import 'e2e_helpers.dart';

/// The account the host gifts Plus to (tool/e2e_freemium.sh waits for it in
/// the Auth emulator, then runs grant_plus.mjs).
const userGift = E2EIdentity(sub: 'user-gift', email: 'gift@example.com');

/// Own identity of the capacity test: a cellar no other test counts.
const userCapacity = E2EIdentity(
  sub: 'user-capacity',
  email: 'capacity@example.com',
);

/// Own identity of the callable check.
const userUsage = E2EIdentity(sub: 'user-usage', email: 'usage@example.com');

const _freeLimit = 15;

/// Skipped in a build without the developer tools (no
/// `--dart-define=ENABLE_DEV_CHEATS=true`): tool/e2e_freemium.sh runs them.
const bool _skipped = !kDevCheatsAvailable;

/// `config/policy` as the owner's set_policy.mjs leaves it, with the
/// capacity limit on (FR2.4) and everything else off (FR3.5, FR7.1).
Future<void> seedPolicy({required bool capacityLimitEnabled}) => commitWrites([
  {
    'update': {
      'name':
          'projects/demo-vinoozy/databases/(default)/documents/config/policy',
      'fields': {
        'capacityLimitEnabled': {'booleanValue': capacityLimitEnabled},
        'adsEnabled': {'booleanValue': false},
        'purchasesEnabled': {'booleanValue': false},
        'freeActiveWineLimit': {'integerValue': '$_freeLimit'},
        'policyVersion': {'stringValue': 'freemium-v1'},
        'usageBudgetEuro': {'stringValue': '0.005'},
      },
    },
  },
]);

/// [count] active wines in the cellar of [uid] and `activeWineCount` equal
/// to them, as the emulator admin: the state of a free account at its limit.
Future<void> seedActiveWines(String uid, int count) async {
  await seedCloudWines(uid, [
    for (var i = 1; i <= count; i++)
      Wine(
        id: 'cap-${i.toString().padLeft(2, '0')}',
        name: 'Vino Limite ${i.toString().padLeft(2, '0')}',
        vintage: 2018,
        storedQuantity: 1,
      ),
  ]);
  final (status, body) = await emulatorRequest(
    'PATCH',
    FirebaseEnvConfig.firestoreEmulatorPort,
    '/v1/projects/demo-vinoozy/databases/(default)/documents/cellars/$uid'
        '?updateMask.fieldPaths=activeWineCount',
    body: {
      'fields': {
        'activeWineCount': {'integerValue': '$count'},
      },
    },
  );
  if (status != 200) throw StateError('PATCH activeWineCount -> $status $body');
}

int? restInt(Map<String, Object?>? fields, String name) =>
    restValue(fields?[name]) as int?;

/// The provider container of the running app.
ProviderContainer appContainer(WidgetTester tester) =>
    ProviderScope.containerOf(
      tester.element(find.byKey(const Key('home-shell'))),
    );

/// The hidden sequence of the owner (FR5.2): two taps on the logo at the
/// bottom of the Dashboard, then Cellar ×3, History ×3, Cellar, History,
/// Dashboard in the navigation bar. Opens the developer tools.
Future<void> openDevToolsBySecretSequence(WidgetTester tester) async {
  await tapWhenHittable(tester, find.byKey(const Key('home-nav-dashboard')));
  await tester.pump(const Duration(milliseconds: 500));
  final footer = find.byKey(const Key('brand-footer'));
  await tester.scrollUntilVisible(
    footer,
    300,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('dashboard-screen')),
          matching: find.byWidgetPredicate(
            (widget) => widget is Scrollable && widget.axis == Axis.vertical,
          ),
        )
        .first,
  );
  await tester.pump(const Duration(milliseconds: 300));
  // A double tap: two taps closer than kDoubleTapTimeout.
  await tester.tap(footer);
  await tester.pump(const Duration(milliseconds: 60));
  await tester.tap(footer);
  await tester.pump(const Duration(milliseconds: 400));
  expect(
    find.byKey(const Key('about-screen')),
    findsNothing,
    reason: 'a double tap starts the sequence, it does not open About',
  );
  for (final tab in const [
    'cellar',
    'cellar',
    'cellar',
    'history',
    'history',
    'history',
    'cellar',
    'history',
    'dashboard',
  ]) {
    await tester.tap(find.byKey(Key('home-nav-$tab')));
    await tester.pump(const Duration(milliseconds: 200));
  }
  await waitFor(
    tester,
    find.byKey(const Key(devCheatsPanelMarker)),
    viaCellarTab: false,
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'FR4.1 FR4.3 a Plus gift written by grant_plus.mjs reaches the '
    'Profile without any action in the app',
    skip: _skipped,
    (tester) async {
      await clearPhone();
      await clearEmulators();
      await launchApp(tester);
      // tool/e2e_freemium.sh waits for this account in the Auth emulator, then
      // runs `grant_plus.mjs grant --email gift@example.com --no-expiry
      // --reason gift --emulator`.
      await signIn(
        tester,
        userGift,
        then: find.byKey(const Key('cellar-empty')),
      );
      await waitFor(tester, find.byKey(const Key('cellar-menu')));
      await tester.tap(find.byKey(const Key('cellar-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cellar-menu-profile')));
      await waitFor(
        tester,
        find.byKey(const Key('profile-plan')),
        viaCellarTab: false,
      );
      final l10n = AppLocalizations.of(
        tester.element(find.byKey(const Key('profile-plan'))),
      );
      await eventually(
        tester,
        () async =>
            tester.widget<Text>(find.byKey(const Key('profile-plan'))).data ==
            l10n.planPlusGift,
        timeout: const Duration(seconds: 120),
        reason: 'the Profile shows "${l10n.planPlusGift}" after grant_plus.mjs',
      );
      final entitlement = await cloudDocument('entitlements/$currentUid');
      expect(restValue(entitlement?['source']), 'manual_grant');
      expect(restValue(entitlement?['reason']), 'gift');
      expect(entitlement?.containsKey('expiresAt'), isFalse);
    },
  );

  testWidgets(
    'FR2.4 FR2.5 FR5.3 FR5.6 the 16th wine is blocked with the '
    'explanation, then saved and synced after "Unlock everything"',
    skip: _skipped,
    (tester) async {
      await clearPhone();
      await clearEmulators();
      await seedPolicy(capacityLimitEnabled: true);
      await launchApp(tester);
      await signIn(
        tester,
        userCapacity,
        then: find.byKey(const Key('cellar-empty')),
      );
      final uid = currentUid;
      await waitForCloudCellar(tester, uid);
      await seedActiveWines(uid, _freeLimit);
      final container = appContainer(tester);
      await eventually(
        tester,
        () async =>
            container.read(winesStreamProvider(uid)).value?.wines.length ==
            _freeLimit,
        timeout: const Duration(seconds: 60),
        reason: 'the 15 active wines reached the phone',
      );

      // FR2.5: "Add" opens the explanation and writes nothing.
      await tapWhenHittable(tester, find.byKey(const Key('cellar-add-button')));
      await waitFor(
        tester,
        find.byKey(const Key('capacity-limit-sheet')),
        viaCellarTab: false,
      );
      expect(find.byKey(const Key('capacity-limit-body')), findsOneWidget);
      expect(
        find.byKey(const Key('capacity-limit-discover-plus')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('add-choice-write')), findsNothing);
      // The sheet scrolls with a large font: centre "Close" first.
      await tapVisible(tester, find.byKey(const Key('capacity-limit-close')));
      await tester.pumpAndSettle();
      expect(await cloudWineNames(uid), hasLength(_freeLimit));

      // FR5.2, FR5.3, FR5.6: the hidden sequence, then "Unlock everything",
      // which the Firestore emulator confirms.
      await openDevToolsBySecretSequence(tester);
      await tapVisible(tester, find.byKey(const Key('dev-unlock-all')));
      await waitFor(
        tester,
        find.byKey(const Key('dev-fixture-applied')),
        viaCellarTab: false,
      );
      final entitlement = await cloudDocument('entitlements/$uid');
      expect(restValue(entitlement?['plan']), 'plus');
      expect(restValue(entitlement?['status']), 'active');
      await Navigator.of(
        tester.element(find.byKey(const Key(devCheatsPanelMarker))),
      ).maybePop();
      await tester.pumpAndSettle();

      // The 16th wine: allowed by the app and by the rules (valid Plus of the
      // cellar owner), saved and synced with the counter.
      await tapWhenHittable(tester, find.byKey(const Key('home-nav-cellar')));
      await addWine(tester, name: 'Aglianico Plus', vintage: '2019');
      await eventually(
        tester,
        () async => (await cloudWineNames(uid)).contains('Aglianico Plus'),
        timeout: const Duration(seconds: 30),
        reason: 'the 16th wine reached the emulator through the rules',
      );
      expect(await cloudWineNames(uid), hasLength(_freeLimit + 1));
      await eventually(
        tester,
        () async =>
            restInt(await cloudDocument('cellars/$uid'), 'activeWineCount') ==
            _freeLimit + 1,
        reason: 'activeWineCount is 16 in the emulator',
      );
      expect(find.byKey(const Key('rejected-wine-reason')), findsNothing);
    },
  );

  testWidgets(
    'FR6.3 reportUsage answers through the Functions emulator with '
    'the App Check debug provider of a demo build',
    skip: _skipped,
    (tester) async {
      await clearPhone();
      await clearEmulators();
      await launchApp(tester);
      await signIn(
        tester,
        userUsage,
        then: find.byKey(const Key('cellar-empty')),
      );
      final uid = currentUid;
      final now = DateTime.now().toUtc();
      final periodId =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}';
      final callable = configuredFunctions(e2eConfig)
          .httpsCallable('reportUsage');
      Map<Object?, Object?> answer;
      try {
        final result = await callable.call<Object?>({
          'installationId': 'e2e-freemium',
          'periodId': periodId,
          'sequence': 1,
          'policyVersion': 'freemium-v1',
          'cumulativeReadCount': 3,
          'cumulativeWriteCount': 1,
          'cumulativeEgressBytes': 2048,
        });
        answer = result.data! as Map<Object?, Object?>;
      } on FirebaseFunctionsException catch (error) {
        fail(
          'reportUsage was refused: code=${error.code} '
          'reason=${error.details} message=${error.message}. '
          '${error.code == 'unauthenticated' ? 'With a signed-in user this '
                    'means no App Check token reached the Functions '
                    'emulator: the debug provider could not get one for '
                    'demo-vinoozy.' : ''}',
        );
      }
      expect(answer['accepted'], isTrue);
      expect(answer['estimatedReadCount'], 3);
      final period = await cloudDocument('usage/$uid/periods/$periodId');
      expect(period, isNotNull, reason: 'the account total was written');
    },
  );
}
