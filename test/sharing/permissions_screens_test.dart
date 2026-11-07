// Permissions in the screens of U1 and U5 (u7-sharing BR1.6, AC8.3.1,
// AC8.4.1; NFR8.1): "read" hides the commands, "edit" hides only deletion,
// "People" is in the cellar menu for everyone; the manifest asks for no
// contacts permission.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/ui/profile_screen.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/dashboard/ui/dashboard_screen.dart';
import 'package:vinoozy/sharing/domain/membership.dart';
import 'package:vinoozy/sharing/ui/sharing_screen.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';

import '../account/account_harness.dart' show FakeAuthService;
import '../helpers/ui_harness.dart';
import 'sharing_harness.dart';

const _synced = SnapshotMeta(hasPendingWrites: false, isFromCache: false);

void main() {
  setUpAll(registerSharingFallbacks);

  late SharingUi ui;

  setUp(() {
    // Giulia chose Mario's cellar before.
    SharedPreferences.setMockInitialValues({
      'sharing.activeCellar.user-b': 'user-a',
    });
    ui = SharingUi();
  });

  /// Shows [screen] on Mario's cellar with [permission], empty.
  Future<void> pumpOnMarios(
    WidgetTester tester,
    Widget screen,
    MemberPermission permission,
  ) async {
    await pumpScreen(tester, screen, overrides: ui.overrides);
    ui.sharing.emitMine([membership(permission: permission)]);
    await tester.pump();
    ui.emitCellar('user-a');
    ui.winesStream('user-a').add(const WinesSnapshot(wines: [], meta: _synced));
    await tester.pumpAndSettle();
  }

  Widget cellarScreen() => CellarScreen(
    user: invitee,
    setup: CellarSetup.ready,
    onRetrySetup: () async {},
  );

  Widget dashboardScreen() => DashboardScreen(
    user: invitee,
    setup: CellarSetup.ready,
    onRetrySetup: () async {},
    onOpenWine: (_) {},
    onOpenStatus: (_) {},
    onAddFirstWine: () {},
  );

  group('CellarScreen (BR1.6)', () {
    testWidgets('AC8.3.1 BR1.6 "read": no command to add, change or delete', (
      tester,
    ) async {
      await pumpOnMarios(tester, cellarScreen(), MemberPermission.read);

      expect(find.byKey(const Key('cellar-empty')), findsOneWidget);
      expect(find.byKey(const Key('cellar-add-button')), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('AC8.4.1 BR1.6 "edit": "Aggiungi" is there, deletion is not', (
      tester,
    ) async {
      await pumpOnMarios(tester, cellarScreen(), MemberPermission.edit);

      final add = tester.widget<ButtonStyleButton>(
        find.byKey(const Key('cellar-add-button')),
      );
      expect(add.onPressed, isNotNull);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('BR1.6 "Aggiungi" writes to the active cellar', (tester) async {
      await pumpOnMarios(tester, cellarScreen(), MemberPermission.edit);

      await tester.tap(find.byKey(const Key('cellar-add-button')));
      await tester.pumpAndSettle();

      expect(
        tester.widget<AddWineScreen>(find.byType(AddWineScreen)).cellarId,
        'user-a',
      );
    });

    testWidgets('"Persone" is in the cellar menu for an invited person too', (
      tester,
    ) async {
      await pumpOnMarios(tester, cellarScreen(), MemberPermission.read);

      await tester.tap(find.byKey(const Key('cellar-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cellar-menu-people')));
      await tester.pumpAndSettle();

      expect(find.byType(SharingScreen), findsOneWidget);
      expect(find.text('Cantina di Mario'), findsWidgets);
    });

    testWidgets('u8-account BR1.2 "Profilo" in the cellar menu opens the '
        'profile', (tester) async {
      await pumpScreen(
        tester,
        cellarScreen(),
        overrides: [
          ...ui.overrides,
          authServiceProvider.overrideWithValue(FakeAuthService()),
        ],
      );
      ui.sharing.emitMine([membership(permission: MemberPermission.read)]);
      await tester.pump();
      ui.emitCellar('user-a');
      ui
          .winesStream('user-a')
          .add(const WinesSnapshot(wines: [], meta: _synced));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cellar-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cellar-menu-profile')));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text(invitee.email), findsOneWidget);
    });

    testWidgets('BR1.6 a permission change shows the commands at once', (
      tester,
    ) async {
      await pumpOnMarios(tester, cellarScreen(), MemberPermission.read);
      expect(find.byKey(const Key('cellar-add-button')), findsNothing);

      ui.sharing.emitMine([membership(permission: MemberPermission.edit)]);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cellar-add-button')), findsOneWidget);
    });
  });

  group('Dashboard (BR1.6)', () {
    testWidgets('BR1.6 "read" hides "Aggiungi il primo vino"', (tester) async {
      await pumpOnMarios(tester, dashboardScreen(), MemberPermission.read);

      expect(find.byKey(const Key('dashboard-empty')), findsOneWidget);
      expect(find.byKey(const Key('dashboard-empty-add')), findsNothing);
    });

    testWidgets('BR1.6 "edit" keeps "Aggiungi il primo vino"', (tester) async {
      await pumpOnMarios(tester, dashboardScreen(), MemberPermission.edit);

      expect(find.byKey(const Key('dashboard-empty-add')), findsOneWidget);
    });

    testWidgets('HomeShell: "Aggiungi il primo vino" opens the form on the '
        'active cellar', (tester) async {
      await pumpOnMarios(
        tester,
        HomeShell(
          user: invitee,
          setup: CellarSetup.ready,
          onRetrySetup: () async {},
        ),
        MemberPermission.edit,
      );

      await tester.tap(find.byKey(const Key('dashboard-empty-add')));
      await tester.pumpAndSettle();
      // u6-label-recognition BR1.1: "Scrivi" among the three ways to add.
      await tester.tap(find.byKey(const Key('add-choice-write')));
      await tester.pumpAndSettle();

      expect(
        tester.widget<AddWineScreen>(find.byType(AddWineScreen)).cellarId,
        'user-a',
      );
    });
  });

  group('NFR8.1 Android manifest', () {
    test('NFR8.1 no contacts permission: the email is typed by hand', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();

      expect(manifest, isNot(contains('READ_CONTACTS')));
      expect(manifest, isNot(contains('WRITE_CONTACTS')));
      expect(manifest, isNot(contains('GET_ACCOUNTS')));
    });
  });
}
