// End-to-end test of the style profiles (wine-style-profiles NFR4.5, BR11.2,
// BR7.4, F5) on the Android emulator with the Firebase Emulator Suite
// (demo-vinoozy), never the real project:
//
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/style_profile_flow_test.dart -d <id> \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
//
// 1. The form: a Champagne written by hand gets Type and Style suggested,
//    "Da evoluzione" is chosen, the disgorgement March 2024 entered, and the
//    detail shows the peak in March 2027; a Prosecco Dolce stays a
//    tank-method sparkling wine. Each document is checked in the emulator,
//    through the real security rules.
// 2. The one-off migration on the emulator: wines in today's format are
//    migrated in a transaction (sources, style, estimate, version 3), a
//    "Style to confirm" wine shows the notice and its style is chosen in the
//    detail.
import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/cellar_providers.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/sharing/sharing_providers.dart';

import 'e2e_helpers.dart';

Future<Map<String, Object?>> cloudWineWhen(
  WidgetTester tester,
  String name,
  bool Function(Map<String, Object?> doc) ready, {
  required String reason,
}) async {
  Map<String, Object?>? found;
  await eventually(tester, () async {
    for (final doc in await cloudWineDocuments(currentUid)) {
      if (restValue(doc['name']) == name && ready(doc)) found = doc;
    }
    return found != null;
  }, reason: reason);
  return found!;
}

/// A window as the app of today writes it: internal, without a version.
DrinkingWindow oldWindow(int start, int peak, int end) => DrinkingWindow(
  startYear: start,
  peakYear: peak,
  endYear: end,
  confidence: Confidence.medium,
  source: WindowSource.internalRules,
  basis: EstimationBasis.denomination,
);

Map<Object?, Object?> mapOf(Map<String, Object?> doc, String field) =>
    restValue(doc[field])! as Map;

Future<void> openForm(WidgetTester tester) async {
  await waitFor(tester, find.byKey(const Key('cellar-add-button')));
  await tester.tap(find.byKey(const Key('cellar-add-button')));
  await waitFor(tester, find.byKey(const Key('add-choice-write')));
  await tester.tap(find.byKey(const Key('add-choice-write')));
  await waitFor(tester, find.byKey(const Key('add-wine-name-field')));
}

Future<void> saveForm(WidgetTester tester, String name) async {
  final save = find.byKey(const Key('add-wine-save-button'));
  await tester.ensureVisible(save);
  await tester.pump();
  await tester.tap(save);
  await waitFor(tester, wineRow(name));
}

Future<void> openDetail(WidgetTester tester, String name) async {
  await tapVisible(tester, wineCardOf(name));
  await waitFor(
    tester,
    find.byKey(const Key('wine-detail')),
    viaCellarTab: false,
  );
}

Future<void> closeDetail(WidgetTester tester) async {
  await Navigator.of(tester.element(find.byKey(const Key('wine-detail'))))
      .maybePop();
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BR11.2 Champagne with style and disgorgement; Prosecco Dolce '
      'stays Charmat', (tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(tester, userA, then: find.byKey(const Key('cellar-empty')));

    await openForm(tester);
    await tester.enterText(
      find.byKey(const Key('add-wine-name-field')),
      'Champagne Brut',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('type-suggested')), findsOneWidget);
    await tapVisible(
      tester,
      find.byKey(const Key('add-wine-no-vintage-switch')),
    );
    await tapVisible(tester, find.byKey(const Key('style-classicAge')));
    await tapVisible(tester, find.byKey(const Key('aging-start-month')));
    await tester.tap(find.text('marzo').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('aging-start-year')), '2024');
    await tester.pumpAndSettle();
    await saveForm(tester, 'Champagne Brut');

    final champagne = await cloudWineWhen(
      tester,
      'Champagne Brut',
      (doc) => doc.containsKey('window'),
      reason: 'the Champagne and its estimate reached the emulator',
    );
    expect(restValue(champagne['wineType']), 'sparklingClassic');
    expect(restValue(champagne['typeSource']), 'auto');
    expect(restValue(champagne['style']), 'classicAge');
    expect(restValue(champagne['styleSource']), 'user');
    expect(mapOf(champagne, 'agingStartMonth'), {'year': 2024, 'month': 3});
    final window = mapOf(champagne, 'window');
    expect(window['unit'], 'months');
    expect([window['peakYear'], window['peakMonth']], [2027, 3]);

    await openDetail(tester, 'Champagne Brut');
    await waitFor(
      tester,
      find.byKey(const Key('ideal-peak')),
      viaCellarTab: false,
    );
    await tester.ensureVisible(find.byKey(const Key('ideal-peak')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ideal-peak')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('ideal-peak'))).data,
      contains('marzo 2027'),
    );
    await closeDetail(tester);

    await openForm(tester);
    await tester.enterText(
      find.byKey(const Key('add-wine-name-field')),
      'Prosecco Dolce',
    );
    await tester.pumpAndSettle();
    await tapVisible(
      tester,
      find.byKey(const Key('add-wine-no-vintage-switch')),
    );
    await saveForm(tester, 'Prosecco Dolce');
    final prosecco = await cloudWineWhen(
      tester,
      'Prosecco Dolce',
      (doc) => doc.containsKey('window'),
      reason: 'the Prosecco reached the emulator',
    );
    expect(restValue(prosecco['wineType']), 'sparklingTank');
    expect(restValue(prosecco['style']), 'tankFresh');
    expect(mapOf(prosecco, 'window')['profile'], 'SP_TANK');
  });

  testWidgets('BR7.4 the one-off migration on the emulator, then the style '
      'chosen in the detail', (tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(tester, userA, then: find.byKey(const Key('cellar-empty')));
    final uid = currentUid;

    // Two wines written by the app of today (tables version 2).
    await seedCloudWines(uid, [
      Wine(
        id: 'old-barolo',
        name: 'Barolo',
        vintage: 2016,
        storedQuantity: 1,
        wineType: 'redStructured',
        window: oldWindow(2024, 2031, 2046),
      ),
      Wine(
        id: 'old-house',
        name: 'Rosso della casa',
        vintage: 2024,
        storedQuantity: 1,
        wineType: 'redLight',
        window: oldWindow(2025, 2026, 2028),
      ),
    ]);
    await waitFor(tester, wineRow('Barolo'));
    await waitFor(tester, wineRow('Rosso della casa'));

    // The migration the app runs on opening the cellar, on its wines now.
    final shell = find.byType(HomeShell);
    final user = tester.widget<HomeShell>(shell).user;
    final container = ProviderScope.containerOf(tester.element(shell));
    final cellar = container.read(activeCellarProvider(user));
    final wines = container
        .read(winesStreamProvider(cellar.cellarId))
        .value!
        .wines;
    final written = await container
        .read(cellarActionsProvider)
        .ensureEstimates(cellar: cellar, user: user, wines: wines);
    expect(written, 2);

    final barolo = await cloudWineWhen(
      tester,
      'Barolo',
      (doc) => doc.containsKey('migrationVersion'),
      reason: 'the Barolo was migrated in the emulator',
    );
    expect(restValue(barolo['migrationVersion']), 3);
    expect(restValue(barolo['typeSource']), 'user');
    expect(restValue(barolo['style']), 'redLong');
    expect(restValue(barolo['styleSource']), 'auto');
    final baroloWindow = mapOf(barolo, 'window');
    expect(
      [
        baroloWindow['startYear'],
        baroloWindow['peakYear'],
        baroloWindow['endYear'],
      ],
      [2024, 2031, 2046],
    );
    expect(baroloWindow['tablesVersion'], 3);

    // "Rosso della casa": a red by type, style to confirm.
    await cloudWineWhen(
      tester,
      'Rosso della casa',
      (doc) => doc.containsKey('migrationVersion'),
      reason: 'the house red was migrated',
    );
    await openDetail(tester, 'Rosso della casa');
    await waitFor(
      tester,
      find.byKey(const Key('style-to-confirm')),
      viaCellarTab: false,
    );
    await tapVisible(tester, find.byKey(const Key('style-redMedium')));
    final chosen = await cloudWineWhen(
      tester,
      'Rosso della casa',
      (doc) => restValue(doc['styleSource']) == 'user',
      reason: 'the style chosen reached the emulator',
    );
    expect(restValue(chosen['style']), 'redMedium');
    final chosenWindow = mapOf(chosen, 'window');
    expect(chosenWindow['profile'], 'R_MEDIUM');
    expect(chosenWindow['startYear'], 2026);
    await eventually(
      tester,
      () async => find.byKey(const Key('style-to-confirm')).evaluate().isEmpty,
      reason: 'the notice goes once the style is chosen',
    );
    await closeDetail(tester);
  });
}
