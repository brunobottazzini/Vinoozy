// Data preparation of the on-phone cold-start measure of the Dashboard
// (u5-dashboard performance-design.md, "Misura dell'avvio a freddo sul
// telefono"; NFR2.1). Run by tool/perf_cold_start.sh, never in CI:
//
//   flutter drive --profile --keep-app-running \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test_perf/dashboard_seed.dart \
//     --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true \
//     --dart-define=PERF=true --dart-define=EMULATOR_HOST=127.0.0.1
//
// The phone reaches the Firebase emulators of the computer through
// `adb reverse` (127.0.0.1). It signs in as userA with the fake sign-in of
// the E2E builds, reads the uid given by the Auth emulator, only then
// creates 500 wines in cellars/{uid}/wines with the emulator REST API, and
// waits until the Dashboard shows 500 bottles, so Firestore has filled its
// local cache. The session stays saved on the phone for the cold starts.
//
// The file name has no `_test.dart` suffix: no test runner picks it up.
import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/cellar/domain/wine.dart';

import '../integration_test/e2e_helpers.dart';

/// Wines of the measure: 500 different wines, one bottle each.
const perfWineCount = 500;

List<Wine> perfCellar(int year) => List.generate(perfWineCount, (i) {
  final start = year - 6 + i % 9;
  final peak = start + i % 5;
  return Wine(
    id: 'perf-${i.toString().padLeft(3, '0')}',
    name: 'Vino Misura $i',
    vintage: i % 7 == 0 ? null : 2000 + i % 25,
    storedQuantity: 1,
    producer: 'Cantina ${i % 37}',
    wineType: const [
      'redStructured',
      'white',
      'sparkling',
      'rose',
      'sweet',
    ][i % 5],
    region: const ['Piemonte', 'Toscana', 'Veneto', 'Sicilia', 'Puglia'][i % 5],
    window: i % 3 == 0
        ? null
        : DrinkingWindow(
            startYear: start,
            peakYear: peak,
            endYear: peak + i % 7,
            confidence: Confidence.medium,
            source: WindowSource.internalRules,
            basis: EstimationBasis.denomination,
          ),
  );
});

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('seed 500 wines and wait for the Dashboard', (tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(
      tester,
      userA,
      then: find.byKey(const Key('dashboard-empty')),
      viaCellarTab: false,
    );
    final uid = currentUid;

    await seedCloudWines(uid, perfCellar(DateTime.now().year));

    await waitFor(
      tester,
      find.byKey(const Key('dashboard-content')),
      timeout: const Duration(seconds: 90),
      viaCellarTab: false,
    );
    await eventually(
      tester,
      () async =>
          (tester.widget<Text>(find.byKey(const Key('dashboard-total'))).data ??
                  '')
              .contains('$perfWineCount'),
      timeout: const Duration(seconds: 90),
      reason: 'the 500 wines are in the local cache',
    );
    debugPrint(
      'dashboard_seed: $perfWineCount wines cached for the cold start',
    );
  });
}
