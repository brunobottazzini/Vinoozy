// End-to-end check of the Dashboard with 500 wines (u5-dashboard
// security-design.md §5, cicd-pipeline.md §1; NFR2.1, CI part). Runs in the
// `e2e` job with `flutter test integration_test`, on the Android emulator
// against the Firebase Emulator Suite (demo-vinoozy):
//
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/dashboard_500_test.dart \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
//
// Its own identity (userDashboard) keeps the cellar apart from every other
// test. The 500 wines are written with one `:commit` of the emulator REST
// API after sign-in (the uid comes from the Auth emulator), part with a
// window and part without. There is no time threshold here: the emulator is
// too variable (NFR2.1); the wait for the first sync is capped at 60 s.
import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/dashboard/domain/dashboard_calculator.dart';

import 'e2e_helpers.dart';

const _wineCount = 500;

/// 500 synthetic wines, one bottle each: two thirds with a window spread
/// around the current year, one third not estimated yet.
List<Wine> _cellar(int year) => List.generate(_wineCount, (i) {
  final start = year - 6 + i % 9;
  final peak = start + i % 5;
  return Wine(
    id: 'dash-${i.toString().padLeft(3, '0')}',
    name: 'Vino Cruscotto $i',
    vintage: i % 7 == 0 ? null : 2000 + i % 25,
    storedQuantity: 1,
    wineType: const ['redStructured', 'white', 'sparkling', 'rose'][i % 4],
    region: const ['Piemonte', 'Toscana', 'Veneto', 'Sicilia'][i % 4],
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

  testWidgets('500 wines give a Dashboard with 500 bottles and the expected '
      'status counts', (tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(
      tester,
      userDashboard,
      then: find.byKey(const Key('dashboard-empty')),
      viaCellarTab: false,
    );
    final uid = currentUid;
    final today = DateTime.now();
    final wines = _cellar(today.year);
    final expected = const DashboardCalculator().compute(wines, today);

    try {
      await seedCloudWines(uid, wines);

      await waitFor(
        tester,
        find.byKey(const Key('dashboard-content')),
        timeout: const Duration(seconds: 60),
        viaCellarTab: false,
      );
      await eventually(
        tester,
        () async =>
            (tester
                        .widget<Text>(find.byKey(const Key('dashboard-total')))
                        .data ??
                    '')
                .contains('500'),
        timeout: const Duration(seconds: 60),
        reason: 'all 500 wines synced to the Dashboard',
      );

      expect(expected.totalBottles, _wineCount);
      for (final status in WineStatus.values) {
        final bar = find.byKey(Key('chart-status-${status.name}'));
        // The Dashboard list is lazy (SliverList): a card below the fold is
        // not built yet, so scroll until it is, instead of ensureVisible.
        await tester.scrollUntilVisible(
          bar,
          200,
          scrollable: find
              .descendant(
                of: find.byKey(const Key('dashboard-content')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pump();
        expect(
          find.descendant(
            of: bar,
            matching: find.text('${expected.bottlesWith(status)}'),
          ),
          findsOneWidget,
          reason: '${status.name} bar',
        );
      }
      expect(
        find.byKey(const Key('chart-status-to-estimate')),
        findsOneWidget,
        reason: '${expected.toEstimateBottles} bottles to estimate',
      );
    } finally {
      await deleteCloudCellar(uid, [for (final wine in wines) wine.id]);
    }
  });
}
