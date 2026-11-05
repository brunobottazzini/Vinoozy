// End-to-end test of the walking skeleton (NFR7.3; functional-spec.md,
// "Prova da capo a fondo dello skeleton"). Runs the real app on the Android
// emulator against the Firebase Emulator Suite (demo-vinoozy):
//
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/u1_skeleton_test.dart \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
//
// Every test empties the emulators and the phone's local state first, so the
// tests do not depend on their order.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/cellar/ui/wine_list_tile.dart';
import 'package:vinoozy/e2e/test_network_control.dart';

import 'e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final network = TestNetworkControl(() => FirebaseFirestore.instance);
  final cellarEmpty = find.byKey(const Key('cellar-empty'));
  final blocked = find.byKey(const Key('blocked-account-screen'));
  final offlineBanner = find.byKey(const Key('offline-banner-offline'));

  Future<void> freshStart(WidgetTester tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
  }

  /// Signs out the way a revoked session does: the gate goes to sign-in and
  /// the queued writes stay on the phone (W2).
  Future<void> signOut(WidgetTester tester) async {
    await FirebaseAuth.instance.signOut();
    await waitFor(tester, find.byKey(const Key('sign-in-screen')));
  }

  testWidgets('1. sign-in with Google opens the empty personal cellar', (
    tester,
  ) async {
    await freshStart(tester);

    await signIn(tester, userA, then: cellarEmpty);

    final uid = currentUid;
    await eventually(
      tester,
      () async => (await cloudDocument('cellars/$uid')) != null,
      reason: 'cellars/{uid} created (BR1.3)',
    );
    final profile = await cloudDocument('users/$uid');
    expect(profile!['email'], {'stringValue': 'user-a@example.com'});
    expect(profile['onboardingSeen'], {'booleanValue': false});
  });

  testWidgets('2-3. offline add of "Barolo 2016 x2", then sync on return', (
    tester,
  ) async {
    await freshStart(tester);
    await signIn(tester, userA, then: cellarEmpty);
    final uid = currentUid;

    await network.disableNetwork();
    final saveToList = await addWine(
      tester,
      name: 'Barolo',
      vintage: '2016',
      quantity: 2,
    );
    debugPrint(
      'E2E NFR1.1 save-to-list offline: ${saveToList.inMilliseconds} ms',
    );
    expect(find.text('x2'), findsOneWidget);
    await waitFor(tester, offlineBanner);
    expect(await cloudWineNames(uid), isEmpty, reason: 'still on the phone');
    // Provisional non-regression limit, NOT the NFR1.1 target (300 ms): this
    // is a debug build on an emulator. NFR1.1 stays open until it is measured
    // on the reference phone with a release build (docs/release-checklist.md).
    expect(saveToList, lessThan(provisionalSaveToListLimit));

    await network.enableNetwork();
    await eventually(
      tester,
      () async => (await cloudWineNames(uid)).contains('Barolo'),
      reason: 'the wine reaches the cloud',
    );
    await waitFor(tester, find.byKey(const Key('cellar-wine-list')));
    await eventually(
      tester,
      () async => find.byKey(const Key('offline-banner')).evaluate().isEmpty,
      reason: 'banner hidden once synced',
    );
  });

  testWidgets('3b. two wines added offline both sync with no "not saved" '
      'notice (review R-01)', (tester) async {
    await freshStart(tester);
    await signIn(tester, userA, then: cellarEmpty);
    final uid = currentUid;

    await network.disableNetwork();
    await addWine(tester, name: 'Barbaresco', vintage: '2019');
    await addWine(tester, name: 'Barbera', vintage: '2022');
    expect(await cloudWineNames(uid), isEmpty, reason: 'still on the phone');

    await network.enableNetwork();
    await eventually(tester, () async {
      final names = await cloudWineNames(uid);
      return names.contains('Barbaresco') && names.contains('Barbera');
    }, reason: 'both wines reach the cloud');
    // SyncWatcher runs after the network returns and after each write: once
    // it is done the ledger must be empty (both confirmed, none rejected).
    await eventually(
      tester,
      () async {
        final ledger = await readLedger();
        return ledger.journal.isEmpty && ledger.owner == null;
      },
      timeout: const Duration(seconds: 40),
      reason: 'both journal entries confirmed, owner released',
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('rejected-wine-notices')), findsNothing);
    expect(wineRow('Barbaresco'), findsOneWidget);
    expect(wineRow('Barbera'), findsOneWidget);
  });

  testWidgets('4. a second user does not see the wines of the first', (
    tester,
  ) async {
    await freshStart(tester);
    await signIn(tester, userA, then: cellarEmpty);
    final uidA = currentUid;
    await addWine(tester, name: 'Barolo', vintage: '2016');
    await eventually(
      tester,
      () async => (await cloudWineNames(uidA)).contains('Barolo'),
    );
    // Wait until the owner is released, so B is not blocked.
    await tester.pump(const Duration(seconds: 2));

    await signOut(tester);
    await signIn(tester, userB, then: cellarEmpty);

    expect(find.text('Barolo'), findsNothing);
    await expectLater(
      FirebaseFirestore.instance
          .collection('cellars/$uidA/wines')
          .get(const GetOptions(source: Source.server)),
      throwsA(
        isA<FirebaseException>().having(
          (e) => e.code,
          'code',
          'permission-denied',
        ),
      ),
    );
  });

  testWidgets('5. A adds offline and leaves; B is blocked; A returns and the '
      'wine arrives', (tester) async {
    await freshStart(tester);
    await signIn(tester, userA, then: cellarEmpty);
    final uidA = currentUid;

    await network.disableNetwork();
    await addWine(tester, name: 'Arneis', vintage: '2024');
    await signOut(tester);

    await signIn(tester, userB, then: blocked);
    expect(find.textContaining('user-a@example.com'), findsWidgets);

    await tester.tap(
      find.byKey(const Key('blocked-sign-in-with-owner-button')),
    );
    await waitFor(tester, find.byKey(const Key('sign-in-screen')));
    await network.enableNetwork();
    await signIn(tester, userA, then: wineRow('Arneis'));

    await eventually(
      tester,
      () async => (await cloudWineNames(uidA)).contains('Arneis'),
      reason: "A's queued wine reaches the cloud",
    );
  });

  testWidgets('6. B confirms the deletion and sees an empty cellar', (
    tester,
  ) async {
    await freshStart(tester);
    await signIn(tester, userA, then: cellarEmpty);
    final uidA = currentUid;
    await network.disableNetwork();
    await addWine(tester, name: 'Dolcetto', vintage: '2024');
    await signOut(tester);

    await signIn(tester, userB, then: blocked);
    await tester.tap(find.byKey(const Key('blocked-discard-button')));
    await waitFor(tester, find.byKey(const Key('discard-dialog')));
    expect(find.textContaining('Dolcetto'), findsNothing, reason: 'no names');
    await tester.tap(find.byKey(const Key('discard-dialog-confirm-button')));

    await waitFor(tester, cellarEmpty, timeout: const Duration(seconds: 30));
    expect(find.text('Dolcetto'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(await cloudWineNames(uidA), isEmpty, reason: 'discarded locally');
  });

  testWidgets('7. two clients racing create a single cellar (NFR4.11)', (
    tester,
  ) async {
    await freshStart(tester);
    await signIn(tester, userA, then: cellarEmpty);
    final uid = currentUid;
    final before = await cloudDocument('cellars/$uid');

    final clients = [
      CellarRepository(db: FirebaseFirestore.instance),
      CellarRepository(db: FirebaseFirestore.instance),
    ];
    await Future.wait([
      for (final client in clients)
        client.ensurePersonalCellar(uid: uid, defaultName: 'Other name'),
    ]);

    final after = await cloudDocument('cellars/$uid');
    expect(after!['createdAt'], before!['createdAt']);
    expect(after['name'], before['name']);
  });

  testWidgets('8. after a restart the queued changes are still there', (
    tester,
  ) async {
    await freshStart(tester);
    await signIn(tester, userA, then: cellarEmpty);
    final uid = currentUid;
    await network.disableNetwork();
    await addWine(tester, name: 'Nebbiolo', vintage: '2020');

    // Process restart as far as Firestore and the app are concerned: the
    // instance is terminated with the write still queued, then main() runs
    // again (network enabled by the new instance).
    await FirebaseFirestore.instance.terminate();
    await launchApp(tester);

    await waitFor(tester, wineRow('Nebbiolo'));
    await eventually(
      tester,
      () async => (await cloudWineNames(uid)).contains('Nebbiolo'),
      reason: 'the restarted app sends the queued write (BR3.3, NFR6.1)',
    );
  });

  testWidgets('9. cold start shows the cellar list within 4 s (NFR2.1)', (
    tester,
  ) async {
    await freshStart(tester);
    await signIn(tester, userA, then: cellarEmpty);
    await addWine(tester, name: 'Barolo', vintage: '2016');

    final samples = <int>[];
    for (var run = 0; run < 6; run++) {
      await FirebaseFirestore.instance.terminate();
      final stopwatch = Stopwatch()..start();
      await launchApp(tester);
      await waitFor(tester, find.byType(WineListTile));
      // The first run warms up and is excluded.
      if (run > 0) samples.add(stopwatch.elapsedMilliseconds);
    }
    samples.sort();
    final median = samples[samples.length ~/ 2];
    debugPrint('E2E NFR2.1 start-to-list samples: $samples ms, median $median');
    expect(median, lessThan(4000));
  });
}
