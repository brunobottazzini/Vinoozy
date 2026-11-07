// Phase 1 of the force-stop check of the walking skeleton
// (cicd-pipeline.md §1, "Riavvio dell'app"; NFR6.1, NFR6.3), driven by
// tool/e2e_force_stop.sh with `flutter drive --keep-app-running`.
//
// It signs in, turns the network off and adds a wine, which stays queued on
// the phone. The app is then left running with the network still off; the
// script kills the process with `adb shell am force-stop`, starts the real app
// with `adb shell am start` and checks that the queued wine is still there
// and reaches the cloud.
//
// The file name has no `_test.dart` suffix on purpose: `flutter test
// integration_test` must not run it, because it leaves state behind.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/e2e/test_network_control.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';

import 'e2e_helpers.dart';

/// Name of the queued wine; tool/e2e_force_stop.sh looks for it.
const forceStopWine = 'Sangiovese';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final network = TestNetworkControl(() => FirebaseFirestore.instance);

  testWidgets('queue a wine offline and leave the app running', (tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    // The app opens on the Dashboard: signIn opens the "Cantina" tab to
    // find the empty cellar (u5-dashboard), and the app is left on it.
    await signIn(tester, userA, then: find.byKey(const Key('cellar-empty')));
    final uid = currentUid;

    await network.disableNetwork();
    await addWine(tester, name: forceStopWine, vintage: '2019');

    expect(await cloudWineNames(uid), isEmpty, reason: 'still on the phone');
    // The ledger entry is on disk, not only in memory.
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    expect(prefs.getString(LocalLedger.storageKey), contains(forceStopWine));
    debugPrint('E2E force-stop phase 1: "$forceStopWine" queued for $uid');
  });
}
