import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/core/label_reading.dart';
import 'package:vinoozy/label/label_providers.dart';
import 'package:vinoozy/label/ui/add_choice_screen.dart';
import 'package:vinoozy/label/ui/label_reading_screen.dart';

import '../../dashboard/dashboard_harness.dart';
import '../../dashboard/fixtures.dart';
import '../../helpers/ui_harness.dart';
import '../label_harness.dart';

/// The shell and the shared image (u6-label-recognition BR1.1, BR1.4).
void main() {
  late DashboardStreams streams;
  late LabelEnv env;
  final l10n = lookupAppLocalizations(const Locale('it'));

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    streams = DashboardStreams();
    env = LabelEnv();
  });

  Future<void> pumpShell(WidgetTester tester) async {
    await pumpScreen(
      tester,
      HomeShell(
        user: dashboardUser,
        setup: CellarSetup.ready,
        onRetrySetup: () async {},
      ),
      overrides: [...streams.overrides, ...env.labelOnlyOverrides],
    );
    streams
      ..emitCellar()
      ..emitWines(const []);
    await tester.pumpAndSettle();
  }

  SharedImageNotifier shares(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(HomeShell)))
          .read(sharedImageProvider.notifier);

  /// The invitations are known and the active cellar can be edited.
  void permissionKnown(WidgetTester tester) =>
      shares(tester).updateShell(cellarReady: true, canEdit: true);

  testWidgets('BR1.1 "Aggiungi" in the Cellar opens the three ways to add', (
    tester,
  ) async {
    await pumpShell(tester);
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cellar-add-button')));
    await tester.pumpAndSettle();
    expect(find.byType(AddChoiceScreen), findsOneWidget);
  });

  testWidgets('BR1.4 a shared photo opens the reading; with several photos '
      '"Ho usato solo la prima foto"', (tester) async {
    env.reader.reading = const LabelReading(text: '');
    await pumpShell(tester);
    permissionKnown(tester);
    env.channel.arrive(multiple: true);
    await tester.pumpAndSettle();
    expect(find.byType(LabelReadingScreen), findsOneWidget);
    expect(find.text(l10n.labelSharedFirstOnly), findsOneWidget);
    expect(env.channel.readShareCalls, 1);
    // label-recognition FR1.1: a shared photo is the front, the back is
    // asked too.
    expect(find.byKey(const Key('label-back-prompt')), findsOneWidget);
    await tester.tap(find.byKey(const Key('label-back-skip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('label-not-found-unreadable')), findsOneWidget);
    // "Riprova" after a shared photo opens "Aggiungi".
    await tester.tap(find.byKey(const Key('label-retry')));
    await tester.pumpAndSettle();
    expect(find.byType(AddChoiceScreen), findsOneWidget);
  });

  testWidgets('BR1.4 the permission still loading after 5 s: "Non puoi '
      'aggiungere vini a questa cantina", nothing read', (tester) async {
    await pumpShell(tester);
    env.channel.arrive();
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(find.text(l10n.labelSharedNotAllowed), findsOneWidget);
    expect(env.channel.discardCalls, 1);
    expect(env.channel.readShareCalls, 0);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('BR1.4 a cellar that never gets ready: the photo expires', (
    tester,
  ) async {
    await pumpShell(tester);
    shares(tester).updateShell(cellarReady: false, canEdit: null);
    env.channel.arrive();
    await tester.pump();
    await tester.pump(const Duration(seconds: 60));
    await tester.pump();
    expect(find.text(l10n.labelSharedExpired), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('BR1.4 an unsaved wine open: the question first; "Continua '
      'con quello aperto" keeps it, "Leggi la nuova foto" replaces it', (
    tester,
  ) async {
    env.reader.reading = const LabelReading(text: 'Cantina del Lago');
    await pumpShell(tester);
    permissionKnown(tester);
    env.channel.arrive();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('label-back-skip')));
    await tester.pumpAndSettle();
    // No wine found but a producer read: the U4 form filled from the label
    // opens by itself (label-autofill-windows BR2.1).
    expect(find.byType(AddWineScreen), findsOneWidget);
    expect(find.text(l10n.autofillFilledNotice), findsOneWidget);

    env.channel.arrive();
    await tester.pumpAndSettle();
    expect(find.text(l10n.labelReplaceTitle), findsOneWidget);
    await tester.tap(find.byKey(const Key('label-replace-keep')));
    await tester.pumpAndSettle();
    expect(find.byType(AddWineScreen), findsOneWidget);
    expect(env.channel.discardCalls, 1);
    expect(env.channel.readShareCalls, 1);

    env.reader.reading = const LabelReading(text: '');
    env.channel.arrive();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('label-replace-read')));
    await tester.pumpAndSettle();
    expect(find.byType(AddWineScreen), findsNothing);
    await tester.tap(find.byKey(const Key('label-back-skip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('label-not-found-unreadable')), findsOneWidget);
    expect(env.channel.readShareCalls, 2);
  });
}
