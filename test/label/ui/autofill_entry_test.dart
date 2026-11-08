// The ways into the form filled from a text (label-autofill-windows FR1.2,
// FR2.1, FR2.6, BR2.1, BR2.4, BR2.5): "Aggiungi" with four choices and "Da
// Google Lens", the label photo with no wine found, and a text shared by
// Lens to the shell (app closed, form changed, empty text). Fake Lens, fake
// clipboard, fake share channel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/core/label_reading.dart';
import 'package:vinoozy/label/core/lens_session.dart';
import 'package:vinoozy/label/label_providers.dart';
import 'package:vinoozy/label/platform/picker_image_source.dart';

import '../../dashboard/dashboard_harness.dart';
import '../../dashboard/fixtures.dart';
import '../../helpers/ui_harness.dart';
import '../autofill_fakes.dart';
import '../label_harness.dart';
import 'label_ui_harness.dart';

const String baroloText = 'Barolo Vietti\n2019';

void main() {
  final l10n = lookupAppLocalizations(const Locale('it'));
  Finder key(String value) => find.byKey(Key(value));

  String textOf(WidgetTester tester, String fieldKey) =>
      tester.widget<TextField>(key(fieldKey)).controller!.text;

  group('"Aggiungi" (FR2.6)', () {
    late LabelUi ui;
    late AutofillFakes fakes;

    setUp(() {
      ui = LabelUi();
      fakes = AutofillFakes();
      ui.extraOverrides = fakes.overrides;
    });

    testWidgets('four choices in order, each with its explanation', (
      tester,
    ) async {
      await ui.pumpAddChoice(tester);
      final order = [
        'add-choice-photo',
        'add-choice-lens',
        'add-choice-import',
        'add-choice-write',
      ];
      for (var i = 1; i < order.length; i++) {
        expect(
          tester.getTopLeft(key(order[i - 1])).dy,
          lessThan(tester.getTopLeft(key(order[i])).dy),
        );
      }
      for (final hint in [
        l10n.addChoicePhotoHint,
        l10n.addChoiceLensHint,
        l10n.addChoiceImportHint,
        l10n.addChoiceWriteHint,
      ]) {
        expect(find.text(hint), findsOneWidget);
      }
    });

    testWidgets('"Da Google Lens" opens the empty form, then Lens; back from '
        'Lens the form is there', (tester) async {
      fakes.camera.opening = const LensCameraOpening(
        LensCameraRoute.lensApp,
        openedAt: 1,
      );
      await ui.pumpAddChoice(tester);
      await tester.tap(key('add-choice-lens'));
      await tester.pumpAndSettle();
      expect(find.byType(AddWineScreen), findsOneWidget);
      expect(textOf(tester, 'add-wine-name-field'), isEmpty);
      expect(fakes.camera.openCalls, 1);
      expect(fakes.events.events, ['lens lensApp']);
    });

    testWidgets('"Da Google Lens" with no Lens: the three steps over the '
        'empty form', (tester) async {
      await ui.pumpAddChoice(tester);
      await tester.tap(key('add-choice-lens'));
      await tester.pumpAndSettle();
      expect(key('lens-instructions'), findsOneWidget);
      await tester.tap(key('lens-instructions-ok'));
      await tester.pumpAndSettle();
      expect(find.byType(AddWineScreen), findsOneWidget);
    });

    testWidgets('BR2.1 the photo with no wine but fields read: the form '
        'filled above "not found", with "Lens" and "Cerca online"', (
      tester,
    ) async {
      ui.env.source.outcome = const PickedImage('/cache/1/pick.jpg');
      ui.env.reader.reading = const LabelReading(text: baroloText);
      await ui.pumpAddChoice(tester);
      await tester.tap(key('add-choice-photo'));
      await tester.pumpAndSettle();
      await tester.tap(key('label-back-skip'));
      await tester.pumpAndSettle();
      expect(find.byType(AddWineScreen), findsOneWidget);
      expect(find.text(l10n.autofillFilledNotice), findsOneWidget);
      expect(textOf(tester, 'add-wine-name-field'), 'Barolo Vietti');
      expect(find.text(l10n.autofillFromText), findsNWidgets(6));
      expect(key('autofill-lens'), findsOneWidget);
      await tester.tap(key('autofill-search-online'));
      await tester.pumpAndSettle();
      expect(key('online-search-screen'), findsOneWidget);
      expect(
        tester.widget<TextField>(key('online-search-field')).controller!.text,
        'Barolo Vietti Barolo DOCG 2019',
      );
    });

    testWidgets('BR2.1 the photo with no useful line: "not found" as '
        'today', (tester) async {
      ui.env.source.outcome = const PickedImage('/cache/1/pick.jpg');
      ui.env.reader.reading = const LabelReading(text: '750 ml\n13% vol');
      await ui.pumpAddChoice(tester);
      await tester.tap(key('add-choice-photo'));
      await tester.pumpAndSettle();
      await tester.tap(key('label-back-skip'));
      await tester.pumpAndSettle();
      expect(find.byType(AddWineScreen), findsNothing);
    });
  });

  group('a text shared by Lens to the shell (BR2.4)', () {
    late DashboardStreams streams;
    late LabelEnv env;
    late AutofillFakes fakes;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      streams = DashboardStreams();
      env = LabelEnv();
      fakes = AutofillFakes();
    });

    Future<void> pumpShell(WidgetTester tester) async {
      await pumpScreen(
        tester,
        HomeShell(
          user: dashboardUser,
          setup: CellarSetup.ready,
          onRetrySetup: () async {},
        ),
        overrides: [
          ...streams.overrides,
          ...env.labelOnlyOverrides,
          ...fakes.overrides,
        ],
      );
      streams
        ..emitCellar()
        ..emitWines(const []);
      await tester.pumpAndSettle();
      ProviderScope.containerOf(tester.element(find.byType(HomeShell)))
          .read(sharedImageProvider.notifier)
          .updateShell(cellarReady: true, canEdit: true);
    }

    Future<void> openEmptyForm(WidgetTester tester) async {
      await tester.tap(key('home-nav-cellar'));
      await tester.pumpAndSettle();
      await tester.tap(key('cellar-add-button'));
      await tester.pumpAndSettle();
      await tester.tap(key('add-choice-write'));
      await tester.pumpAndSettle();
    }

    testWidgets('no form open: the form opens filled, the text taken once', (
      tester,
    ) async {
      await pumpShell(tester);
      env.channel.arriveText(baroloText);
      await tester.pumpAndSettle();
      expect(find.byType(AddWineScreen), findsOneWidget);
      expect(textOf(tester, 'add-wine-name-field'), 'Barolo Vietti');
      expect(env.channel.sharedText, isNull);
      expect(fakes.events.events, ['autofill share filled 6']);
    });

    testWidgets('an empty text: "Nessun testo ricevuto"', (tester) async {
      await pumpShell(tester);
      env.channel.arriveText('   ');
      await tester.pumpAndSettle();
      expect(find.text(l10n.autofillShareEmpty), findsOneWidget);
      expect(find.byType(AddWineScreen), findsNothing);
    });

    testWidgets('a form open and untouched: its empty fields, no question', (
      tester,
    ) async {
      await pumpShell(tester);
      await openEmptyForm(tester);
      env.channel.arriveText(baroloText);
      await tester.pumpAndSettle();
      expect(key('use-shared-text-dialog'), findsNothing);
      expect(textOf(tester, 'add-wine-name-field'), 'Barolo Vietti');
    });

    testWidgets('a form changed by hand: "Usare il testo per i campi '
        'vuoti?"; "Ignora" keeps it, "Usa" fills the empty fields', (
      tester,
    ) async {
      await pumpShell(tester);
      await openEmptyForm(tester);
      await tester.enterText(key('add-wine-name-field'), 'Il mio vino');
      await tester.pumpAndSettle();
      env.channel.arriveText(baroloText);
      await tester.pumpAndSettle();
      expect(find.text(l10n.autofillShareUseTitle), findsOneWidget);
      await tester.tap(key('use-shared-text-ignore'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'add-wine-vintage-field'), isEmpty);
      env.channel.arriveText(baroloText);
      await tester.pumpAndSettle();
      await tester.tap(key('use-shared-text-use'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'add-wine-name-field'), 'Il mio vino');
      expect(textOf(tester, 'add-wine-vintage-field'), '2019');
    });
  });
}
