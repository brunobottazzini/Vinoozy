// CellarSwitcher (u7-sharing BR1.5; NFR2.4, NFR3.1-NFR3.3) in it, en and
// pt-BR: hidden without sharing, the choice of the cellar, its label for
// TalkBack and the switch shown from the cache.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/sharing/domain/membership.dart';
import 'package:vinoozy/sharing/ui/cellar_switcher.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';

import '../helpers/ui_harness.dart';
import 'sharing_harness.dart';

const _cached = SnapshotMeta(hasPendingWrites: false, isFromCache: true);

// u4-cellar BR1.7: an empty list from the cache shows "loading", not the
// invitation, so the starting cellar is confirmed by the server here.
const _server = SnapshotMeta(hasPendingWrites: false, isFromCache: false);

void main() {
  setUpAll(registerSharingFallbacks);

  late SharingUi ui;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ui = SharingUi();
  });

  final annas = membership(
    cellarId: 'user-z',
    ownerId: 'user-z',
    ownerName: 'Anna',
    permission: MemberPermission.read,
  );

  Widget host() => const Scaffold(
    body: Column(children: [CellarSwitcher(user: invitee)]),
  );

  Future<void> pumpSwitcher(
    WidgetTester tester, {
    List<Membership> mine = const [],
    Locale locale = const Locale('it'),
  }) async {
    await pumpScreen(tester, host(), overrides: ui.overrides, locale: locale);
    ui.sharing.emitMine(mine);
    await tester.pumpAndSettle();
  }

  testWidgets('BR1.5 with the personal cellar only nothing is shown', (
    tester,
  ) async {
    await pumpSwitcher(tester);

    expect(find.byKey(const Key('cellar-switcher')), findsNothing);
  });

  testWidgets('BR1.5 starts from the personal cellar and lists every '
      'accessible cellar', (tester) async {
    await pumpSwitcher(tester, mine: [membership(), annas]);

    expect(find.text('La tua cantina · proprietario'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cellar-switcher')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cellar-option-user-b')), findsOneWidget);
    expect(find.byKey(const Key('cellar-option-user-a')), findsOneWidget);
    expect(find.byKey(const Key('cellar-option-user-z')), findsOneWidget);
    expect(find.text('Cantina di Anna'), findsOneWidget);
  });

  testWidgets('BR1.5 a choice changes the active cellar and is remembered', (
    tester,
  ) async {
    await pumpSwitcher(tester, mine: [membership(), annas]);

    await tester.tap(find.byKey(const Key('cellar-switcher')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cellar-option-user-z')));
    await tester.pumpAndSettle();

    expect(find.text('Cantina di Anna · Solo lettura'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('sharing.activeCellar.user-b'), 'user-z');
  });

  testWidgets('closing the list keeps the active cellar', (tester) async {
    await pumpSwitcher(tester, mine: [membership()]);

    await tester.tap(find.byKey(const Key('cellar-switcher')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('La tua cantina · proprietario'), findsOneWidget);
  });

  testWidgets('NFR3.1 TalkBack reads the cellar, the permission and the hint', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues({
      'sharing.activeCellar.user-b': 'user-a',
    });
    await pumpSwitcher(tester, mine: [membership()]);

    expect(
      find.bySemanticsLabel(
        'Cantina di Mario, Può modificare. Tocca per cambiare cantina',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  for (final (locale, label) in [
    (const Locale('en'), 'Your cellar · owner'),
    (const Locale('pt', 'BR'), 'Sua adega · proprietário'),
  ]) {
    testWidgets('the label in ${locale.toLanguageTag()}', (tester) async {
      await pumpSwitcher(tester, mine: [membership()], locale: locale);
      expect(find.text(label), findsOneWidget);
    });
  }

  testWidgets('NFR2.4 switching shows the cached wines of the chosen cellar '
      'within 1 second', (tester) async {
    await pumpScreen(
      tester,
      CellarScreen(
        user: invitee,
        setup: CellarSetup.ready,
        onRetrySetup: () async {},
      ),
      overrides: ui.overrides,
    );
    ui.sharing.emitMine([membership()]);
    ui.emitCellar('user-b');
    ui.winesStream('user-b').add(const WinesSnapshot(wines: [], meta: _server));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cellar-switcher')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cellar-option-user-a')));
    await tester.pump();
    ui.emitCellar('user-a');
    ui
        .winesStream('user-a')
        .add(
          const WinesSnapshot(
            wines: [
              Wine(id: 'w1', name: 'Barolo', vintage: 2016, storedQuantity: 2),
            ],
            meta: _cached,
          ),
        );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Barolo'), findsOneWidget);
    expect(find.text('Cantina di Mario · Può modificare'), findsOneWidget);
  });

  accessibilityMatrix(
    'CellarSwitcher',
    host,
    overrides: () {
      ui = SharingUi();
      return ui.overrides;
    },
    afterPump: (tester) async {
      ui.sharing.emitMine([membership(), annas]);
      await tester.pumpAndSettle();
    },
  );
}
