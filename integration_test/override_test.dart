// End-to-end test of the owner's correction of "Recommended until"
// (label-autofill-windows NFR5.4; FR5.1-FR5.4, BR4.4, BR4.6) on the
// Android emulator with the Firebase Emulator Suite (demo-vinoozy), never
// the real project:
//
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/override_test.dart -d <emulator-id> \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
//
// A wine added by hand, "Correggi" with the first year allowed, the detail
// opened again with "corretto da te", then "Ripristina stima": each step
// checked in the Firestore emulator through the real security rules.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'e2e_helpers.dart';

/// The cloud document of the wine named [name] when [ready] holds.
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

Map<Object?, Object?> windowOf(Map<String, Object?> doc, String field) =>
    restValue(doc[field])! as Map;

Future<void> openDetail(WidgetTester tester, String name) async {
  await tapVisible(tester, wineCardOf(name));
  await waitFor(
    tester,
    find.byKey(const Key('wine-detail')),
    viaCellarTab: false,
  );
}

/// "Back" from the detail, as the system back button does.
Future<void> closeDetail(WidgetTester tester) async {
  await Navigator.of(tester.element(find.byKey(const Key('wine-detail'))))
      .maybePop();
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FR5.1-FR5.4 "Correggi", the detail opened again, then '
      '"Ripristina stima"', (tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(tester, userA, then: find.byKey(const Key('cellar-empty')));
    await addWine(tester, name: 'Barolo', vintage: '2016');
    await waitFor(tester, wineRow('Barolo'));
    final saved = await cloudWineWhen(
      tester,
      'Barolo',
      (doc) => doc.containsKey('baseWindow'),
      reason: 'the wine and its estimate reached the emulator',
    );
    final base = windowOf(saved, 'baseWindow');
    final start = base['startYear']! as int;
    final end = base['endYear']! as int;

    // "Correggi": the estimated end preselected; the first year allowed.
    await openDetail(tester, 'Barolo');
    await tapVisible(tester, find.byKey(const Key('override-correct')));
    await waitFor(
      tester,
      find.byKey(const Key('override-sheet')),
      viaCellarTab: false,
    );
    expect(
      tester.widget<ChoiceChip>(find.byKey(Key('override-year-$end'))).selected,
      isTrue,
    );
    await tapVisible(tester, find.byKey(Key('override-year-$start')));
    await tapVisible(tester, find.byKey(const Key('override-save')));
    await waitFor(
      tester,
      find.byKey(const Key('corrected-badge')),
      viaCellarTab: false,
    );
    final corrected = await cloudWineWhen(
      tester,
      'Barolo',
      (doc) => doc.containsKey('windowOverride'),
      reason: 'the correction reached the emulator',
    );
    expect(windowOf(corrected, 'windowOverride')['endYear'], start);
    expect(windowOf(corrected, 'window')['endYear'], start);
    expect(windowOf(corrected, 'window')['startYear'], start);
    expect(windowOf(corrected, 'baseWindow')['endYear'], end);

    // Opened again: the correction stays.
    await closeDetail(tester);
    await openDetail(tester, 'Barolo');
    expect(find.byKey(const Key('corrected-badge')), findsOneWidget);
    expect(find.byKey(const Key('override-app-estimate')), findsOneWidget);

    // "Ripristina stima": one write, the estimate is back.
    await tapVisible(tester, find.byKey(const Key('override-restore')));
    await waitFor(
      tester,
      find.byKey(const Key('restore-estimate-dialog')),
      viaCellarTab: false,
    );
    await tester.tap(find.byKey(const Key('restore-estimate-confirm')));
    await tester.pumpAndSettle();
    await waitFor(
      tester,
      find.byKey(const Key('window-disclaimer')),
      viaCellarTab: false,
    );
    final restored = await cloudWineWhen(
      tester,
      'Barolo',
      (doc) => !doc.containsKey('windowOverride'),
      reason: 'the correction was removed in the emulator',
    );
    expect(windowOf(restored, 'window')['endYear'], end);
    await closeDetail(tester);
  });
}
