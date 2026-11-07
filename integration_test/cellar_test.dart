// End-to-end test of the cellar (u4-cellar cicd-pipeline.md §1, job `e2e`;
// BR1.4, BR1.7, BR1.10, BR1.16; NFR6.1, NFR6.6, NFR7.4) on the Android
// emulator with the Firebase Emulator Suite (demo-vinoozy), never the real
// project:
//
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/cellar_test.dart \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
//
// Sequence: add a wine -> add it again (duplicate dialog, bottles added) ->
// "Drunk" and "Undo" -> the History -> the last bottle drunk offline keeps
// the banner "pending" until the network is back -> the finished wine added
// again comes back to the Cellar.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/cellar/ui/wine_list_tile.dart';
import 'package:vinoozy/e2e/test_network_control.dart';

import 'e2e_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final network = TestNetworkControl(() => FirebaseFirestore.instance);

  /// The row of [name], and its quick "Drunk".
  Finder drinkOf(String name) => find.descendant(
    of: find.ancestor(of: wineRow(name), matching: find.byType(WineListTile)),
    matching: find.byIcon(Icons.wine_bar),
  );

  Finder quantityOf(String name, int quantity) => find.descendant(
    of: find.ancestor(of: wineRow(name), matching: find.byType(WineListTile)),
    matching: find.text('x$quantity'),
  );

  /// The form filled with [name] without vintage, then "Save".
  Future<void> saveForm(WidgetTester tester, String name) async {
    await tapWhenHittable(tester, find.byKey(const Key('cellar-add-button')));
    // u6-label-recognition BR1.1: "Scrivi" among the three ways to add.
    await waitFor(tester, find.byKey(const Key('add-choice-write')));
    await tester.tap(find.byKey(const Key('add-choice-write')));
    await waitFor(tester, find.byKey(const Key('add-wine-name-field')));
    await tester.enterText(find.byKey(const Key('add-wine-name-field')), name);
    await tester.tap(find.byKey(const Key('add-wine-no-vintage-switch')));
    final save = find.byKey(const Key('add-wine-save-button'));
    await tester.ensureVisible(save);
    await tester.pump();
    await tester.tap(save);
  }

  testWidgets('add, duplicate, drink and undo, History, last bottle offline, '
      'add again', (tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(tester, userA, then: find.byKey(const Key('cellar-empty')));
    const name = 'Nebbiolo Langhe';

    // BR1.5 BR1.18: saved on the phone, back to the list at once.
    await addWine(tester, name: name);
    await waitFor(tester, quantityOf(name, 1));

    // BR1.4: the same wine again -> "Già in cantina" -> +1 bottle.
    await saveForm(tester, name);
    await waitFor(tester, find.byKey(const Key('duplicate-dialog')));
    await tapWhenHittable(tester, find.byKey(const Key('duplicate-confirm')));
    await waitFor(tester, quantityOf(name, 2));

    // BR1.10: "Drunk" then "Undo".
    await tapWhenHittable(tester, drinkOf(name));
    await waitFor(tester, find.byKey(const Key('drink-undo')));
    await tapWhenHittable(tester, find.byKey(const Key('drink-undo')));
    await waitFor(tester, quantityOf(name, 2));
    await eventually(
      tester,
      () async => await cloudDrinkCount(currentUid) == 0,
      reason: 'the undone drink is deleted in the cloud',
    );

    // BR1.16: one drink in the History.
    await tapWhenHittable(tester, drinkOf(name));
    await waitFor(tester, quantityOf(name, 1));
    await tester.tap(find.byKey(const Key('home-nav-history')));
    await waitFor(tester, find.textContaining(name));
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();

    // NFR6.6: the last bottle drunk offline leaves the list, the banner says
    // "pending" until the network is back.
    await network.disableNetwork();
    await tapWhenHittable(tester, drinkOf(name));
    await waitFor(tester, find.byKey(const Key('cellar-empty')));
    await waitFor(tester, find.byKey(const Key('offline-banner')));
    await network.enableNetwork();
    await eventually(
      tester,
      () async => find.byKey(const Key('offline-banner')).evaluate().isEmpty,
      reason: 'the queued drink reached the server',
    );
    expect(await cloudDrinkCount(currentUid), 2);

    // BR1.4 BR1.7: the finished wine added again comes back to the Cellar.
    await saveForm(tester, name);
    await waitFor(tester, find.byKey(const Key('duplicate-dialog')));
    await tapWhenHittable(tester, find.byKey(const Key('duplicate-confirm')));
    await waitFor(tester, quantityOf(name, 1));
  });

  // Review R-01, R-07 (BR1.16, US6.2): the History already opened in the
  // session shows the new drink and drops it after "Undo".
  testWidgets('drink, History, Undo: the History follows in the same session', (
    tester,
  ) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(tester, userA, then: find.byKey(const Key('cellar-empty')));
    const name = 'Dolcetto di Dogliani';
    await addWine(tester, name: name, quantity: 2);
    await waitFor(tester, quantityOf(name, 2));

    // The History is opened once and stays mounted in the shell.
    await tester.tap(find.byKey(const Key('home-nav-history')));
    await waitFor(tester, find.byKey(const Key('history-empty')));
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();

    await tapWhenHittable(tester, drinkOf(name));
    await waitFor(tester, quantityOf(name, 1));
    await tester.tap(find.byKey(const Key('home-nav-history')));
    await waitFor(tester, find.byKey(const Key('history-list')));
    // In the list only: the "Drunk" SnackBar names the wine too.
    expect(
      find.descendant(
        of: find.byKey(const Key('history-list')),
        matching: find.textContaining(name),
      ),
      findsOneWidget,
    );

    // "Undo" from the message, still on screen on the History tab.
    await waitFor(tester, find.byKey(const Key('drink-undo')));
    await tapWhenHittable(tester, find.byKey(const Key('drink-undo')));
    await waitFor(tester, find.byKey(const Key('history-empty')));
    await eventually(
      tester,
      () async => await cloudDrinkCount(currentUid) == 0,
      reason: 'the undone drink is deleted in the cloud',
    );
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await waitFor(tester, quantityOf(name, 2));
  });
}
