// The add form filled from a label text (label-autofill-windows F1-F4,
// interaction-spec.md): "Paste from Lens" only into the empty fields, no
// data, a sure wine, "Clear" with and without the question, the level
// (suggested, accepted on Save, "None", changed), "From Google Lens" with
// its three outcomes and the automatic paste on the way back. Fake Lens,
// fake clipboard, fake catalog: nothing real is opened or read.
import 'dart:async';

import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/autofill_providers.dart';
import 'package:vinoozy/label/core/lens_session.dart';

import '../../helpers/ui_harness.dart';
import '../../label/autofill_fakes.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

/// Name, appellation, vintage, type, country and region (BR1).
const String baroloText = 'Barolo Vietti\n2019';

void main() {
  late CellarUi ui;
  late AutofillFakes fakes;
  late List<WineDraft> saved;
  final l10n = lookupAppLocalizations(const Locale('it'));

  setUp(() {
    ui = CellarUi();
    fakes = AutofillFakes();
    saved = [];
    when(
      () => ui.actions.saveNewWine(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((invocation) async {
      saved.add(invocation.namedArguments[#draft] as WineDraft);
      return AddSaved(cellarWine('wine-1'));
    });
  });

  Finder key(String value) => find.byKey(Key(value));

  String textOf(WidgetTester tester, String fieldKey) =>
      tester.widget<TextField>(key(fieldKey)).controller!.text;

  /// The form pushed from a host page, as the app does.
  Future<void> openForm(
    WidgetTester tester, {
    AddWineInitialValues? initialValues,
    String? sharedText,
    bool openLens = false,
    VoidCallback? onLens,
    void Function(BuildContext context, String query)? onSearchOnline,
    Locale locale = const Locale('it'),
  }) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          key: const Key('host'),
          body: Center(
            child: TextButton(
              key: const Key('open-form'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AddWineScreen(
                    user: cellarOwner,
                    cellarId: ownerCellar.cellarId,
                    cellar: ownerCellar,
                    initialValues: initialValues,
                    sharedText: sharedText,
                    openLensOnStart: openLens,
                    onLens: onLens,
                    onSearchOnline: onSearchOnline,
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      overrides: [...ui.overrides, ...fakes.overrides],
      locale: locale,
    );
    await tester.tap(key('open-form'));
    await tester.pumpAndSettle();
  }

  Future<void> paste(WidgetTester tester, String? text) async {
    fakes.clipboard.text = text;
    await tester.ensureVisible(key('autofill-paste'));
    await tester.tap(key('autofill-paste'));
    await tester.pumpAndSettle();
  }

  /// "Salva"; a form with no vintage gets one first (BR1.3 asks for it).
  Future<void> save(WidgetTester tester) async {
    if (textOf(tester, 'add-wine-vintage-field').isEmpty) {
      await tester.ensureVisible(key('add-wine-vintage-field'));
      await tester.enterText(key('add-wine-vintage-field'), '2018');
      await tester.pumpAndSettle();
    }
    await tester.tap(key('add-wine-save-button'));
    await tester.pumpAndSettle();
  }

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(AddWineScreen)));

  group('"Incolla da Lens" (FR2.2, FR2.4, NFR3.1)', () {
    testWidgets('the card is there on an empty form, whatever the clipboard; '
        'the clipboard is never read to decide', (tester) async {
      await openForm(tester);
      expect(key('paste-from-lens-card'), findsOneWidget);
      expect(key('autofill-toolbar'), findsNothing);
      expect(fakes.clipboard.reads, 0);
      expect(fakes.camera.clipCalls, 0);
    });

    testWidgets('a tap reads once and fills every empty field with "✦"', (
      tester,
    ) async {
      await openForm(tester);
      await paste(tester, baroloText);
      expect(fakes.clipboard.reads, 1);
      expect(textOf(tester, 'add-wine-name-field'), 'Barolo Vietti');
      expect(textOf(tester, 'add-wine-denomination'), 'Barolo DOCG');
      expect(textOf(tester, 'add-wine-vintage-field'), '2019');
      for (final field in [
        'name',
        'denomination',
        'vintage',
        'wineType',
        'country',
        'region',
      ]) {
        expect(
          find.descendant(
            of: key('filled-$field'),
            matching: find.text(l10n.autofillFromText),
          ),
          findsOneWidget,
          reason: field,
        );
      }
      expect(key('filled-producer'), findsOneWidget);
      expect(
        find.descendant(
          of: key('filled-producer'),
          matching: find.text(l10n.autofillFromText),
        ),
        findsNothing,
      );
      expect(find.text(l10n.autofillPastedNotice), findsOneWidget);
      expect(key('autofill-toolbar'), findsOneWidget);
      expect(fakes.events.events, ['autofill paste filled 6']);
      // The catalog was asked first (BR2.2).
      expect(ui.catalog.labelTexts, hasLength(1));
    });

    testWidgets('a catalog that never answers (database opening, slow '
        'Open Food Facts): the fields of the text within 2 s, with the '
        'message', (tester) async {
      final gate = Completer<void>();
      addTearDown(gate.complete);
      ui.catalog.labelGate = gate;
      await openForm(tester);
      fakes.clipboard.text =
          "CASCINA CASTLET\nBarbera d'Asti\nDenominazione di Origine "
          'Controllata e Garantita\n2019\n14% vol\n75 cl';
      await tester.ensureVisible(key('autofill-paste'));
      await tester.tap(key('autofill-paste'));
      await tester.pump(const Duration(milliseconds: 1000));
      expect(textOf(tester, 'add-wine-name-field'), isEmpty);
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
      expect(ui.catalog.labelTexts, hasLength(1));
      // FR7.1, BR7.8: the uncertain name stays empty; the result within 2 s
      // is the first question of the guide (FR2.8).
      expect(key('guide-sheet'), findsOneWidget);
      expect(key('guide-proposal'), findsOneWidget);
      expect(find.text(l10n.guideProgress(1, 2)), findsOneWidget);
      expect(textOf(tester, 'add-wine-denomination'), "Barbera d'Asti DOCG");
      expect(textOf(tester, 'add-wine-vintage-field'), '2019');
      expect(find.text(l10n.autofillPastedNotice), findsOneWidget);
      expect(key('autofill-toolbar'), findsOneWidget);
      expect(fakes.events.events.single, startsWith('autofill paste filled'));
    });

    testWidgets('a field written by hand is never replaced (FR2.4)', (
      tester,
    ) async {
      await openForm(tester);
      await tester.enterText(key('add-wine-name-field'), 'Il mio Barolo');
      await tester.pumpAndSettle();
      await paste(tester, baroloText);
      expect(textOf(tester, 'add-wine-name-field'), 'Il mio Barolo');
      expect(textOf(tester, 'add-wine-vintage-field'), '2019');
      expect(
        find.descendant(
          of: key('filled-name'),
          matching: find.text(l10n.autofillFromText),
        ),
        findsNothing,
      );
      expect(fakes.events.events, ['autofill paste filled 5']);
    });

    testWidgets('an empty clipboard: "Negli appunti non c\'è testo", nothing '
        'changes', (tester) async {
      await openForm(tester);
      await paste(tester, '   ');
      expect(find.text(l10n.autofillClipboardEmpty), findsOneWidget);
      expect(textOf(tester, 'add-wine-name-field'), isEmpty);
      expect(key('autofill-toolbar'), findsNothing);
      expect(fakes.events.events, isEmpty);
    });

    testWidgets('no new field: "Nel testo non ho trovato dati da '
        'aggiungere", the form does not change', (tester) async {
      await openForm(tester);
      await paste(tester, '750 ml\n13% vol');
      expect(find.text(l10n.autofillNoNewFields), findsOneWidget);
      expect(textOf(tester, 'add-wine-name-field'), isEmpty);
      expect(key('autofill-toolbar'), findsNothing);
      expect(fakes.events.events, ['autofill paste noFields 0']);
    });

    testWidgets('every useful field already full: nothing to add', (
      tester,
    ) async {
      await openForm(tester);
      await paste(tester, baroloText);
      await paste(tester, baroloText);
      expect(find.text(l10n.autofillNoNewFields), findsOneWidget);
      expect(fakes.events.events.last, 'autofill paste noFields 0');
    });

    testWidgets('a sure wine in the catalog: its proposal above the form; '
        '"Usa" fills it (FR2.5)', (tester) async {
      ui.catalog.labelMatch = const LabelMatchResult.sure(
        WineCandidate(
          name: 'Barolo Rocche',
          producer: 'Vietti',
          vintage: 2017,
          wineType: CatalogWineType.red,
          denomination: 'Barolo DOCG',
          source: CandidateSource.offline,
        ),
        step: LabelMatchStep.offlineText,
      );
      await openForm(tester);
      await paste(tester, baroloText);
      expect(key('autofill-sure-match'), findsOneWidget);
      expect(find.text('Barolo Rocche'), findsOneWidget);
      expect(textOf(tester, 'add-wine-name-field'), isEmpty);
      expect(fakes.events.events, ['autofill paste sureMatch 0']);
      await tester.tap(key('autofill-sure-use'));
      await tester.pumpAndSettle();
      expect(key('autofill-sure-match'), findsNothing);
      expect(textOf(tester, 'add-wine-name-field'), 'Barolo Rocche');
      expect(textOf(tester, 'add-wine-producer'), 'Vietti');
    });

    testWidgets('"Ignora" on the sure wine keeps the form', (tester) async {
      ui.catalog.labelMatch = const LabelMatchResult.sure(
        WineCandidate(name: 'Barolo Rocche', source: CandidateSource.offline),
        step: LabelMatchStep.offlineText,
      );
      await openForm(tester);
      await paste(tester, baroloText);
      await tester.tap(key('autofill-sure-ignore'));
      await tester.pumpAndSettle();
      expect(key('autofill-sure-match'), findsNothing);
      expect(textOf(tester, 'add-wine-name-field'), isEmpty);
    });

    testWidgets('the card goes when every field is full', (tester) async {
      await openForm(
        tester,
        initialValues: const AddWineInitialValues(
          name: 'Barolo',
          producer: 'Vietti',
          denomination: 'Barolo DOCG',
          vintage: 2016,
          wineType: 'redStructured',
          country: 'IT',
          region: 'Piemonte',
        ),
      );
      expect(key('paste-from-lens-card'), findsNothing);
    });
  });

  group('the form filled from a text (FR1.2-FR1.4)', () {
    AddWineInitialValues filled() => AddWineInitialValues.fromLabelFields(
      extractLabelFields(baroloText, currentYear: 2026),
      notice: l10n.autofillFilledNotice,
    );

    testWidgets('opens with the bar, the notice and the "✦" marks', (
      tester,
    ) async {
      await openForm(tester, initialValues: filled());
      expect(key('autofill-toolbar'), findsOneWidget);
      expect(find.text(l10n.autofillFilledNotice), findsOneWidget);
      expect(find.text(l10n.autofillFromText), findsNWidgets(6));
    });

    testWidgets('changing a field removes its "✦"; the bar stays', (
      tester,
    ) async {
      await openForm(tester, initialValues: filled());
      await tester.enterText(key('add-wine-name-field'), 'Barolo Ravera');
      await tester.pumpAndSettle();
      expect(find.text(l10n.autofillFromText), findsNWidgets(5));
      expect(key('autofill-toolbar'), findsOneWidget);
    });

    testWidgets('"Lens" only with the front photo; "Cerca online" with the '
        'words of the form', (tester) async {
      var lens = 0;
      String? query;
      await openForm(
        tester,
        initialValues: filled(),
        onLens: () => lens++,
        onSearchOnline: (_, words) => query = words,
      );
      await tester.tap(key('autofill-lens'));
      await tester.tap(key('autofill-search-online'));
      await tester.pumpAndSettle();
      expect(lens, 1);
      expect(query, 'Barolo Vietti Barolo DOCG 2019');
    });

    testWidgets('no front photo: no "Lens"', (tester) async {
      await openForm(tester, initialValues: filled());
      expect(key('autofill-lens'), findsNothing);
    });

    testWidgets('BR2.7 "Pulisci" with no change by hand: no question; the '
        'descriptive fields empty, the quantity stays, "Modulo svuotato", '
        'focus on the name', (tester) async {
      await openForm(tester, initialValues: filled());
      await tester.ensureVisible(key('quantity-increase-button'));
      await tester.tap(key('quantity-increase-button'));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(key('quantity-value')).data, '2');
      await tester.ensureVisible(key('autofill-clear'));
      await tester.tap(key('autofill-clear'));
      await tester.pumpAndSettle();
      expect(key('clear-form-dialog'), findsNothing);
      expect(textOf(tester, 'add-wine-name-field'), isEmpty);
      expect(textOf(tester, 'add-wine-denomination'), isEmpty);
      expect(textOf(tester, 'add-wine-vintage-field'), isEmpty);
      expect(find.text(l10n.autofillFromText), findsNothing);
      expect(find.text(l10n.autofillCleared), findsOneWidget);
      expect(tester.widget<Text>(key('quantity-value')).data, '2');
      final name = tester.widget<TextField>(key('add-wine-name-field'));
      expect(name.focusNode!.hasFocus, isTrue);
      // The bar stays until the form closes.
      expect(key('autofill-toolbar'), findsOneWidget);
    });

    testWidgets('BR2.7 after a change by hand "Pulisci" asks: "Annulla" '
        'keeps everything, "Svuota" clears', (tester) async {
      await openForm(tester, initialValues: filled());
      await tester.enterText(key('add-wine-producer'), 'Vietti');
      await tester.pumpAndSettle();
      await tester.tap(key('autofill-clear'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.autofillClearTitle), findsOneWidget);
      await tester.tap(key('clear-form-cancel'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'add-wine-producer'), 'Vietti');
      expect(textOf(tester, 'add-wine-name-field'), 'Barolo Vietti');
      await tester.tap(key('autofill-clear'));
      await tester.pumpAndSettle();
      await tester.tap(key('clear-form-confirm'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'add-wine-producer'), isEmpty);
      expect(textOf(tester, 'add-wine-name-field'), isEmpty);
    });

    testWidgets('BR2.7 a level touched also asks; after "Svuota" the level '
        'is "not chosen" again', (tester) async {
      await openForm(tester, initialValues: filled());
      await tester.ensureVisible(key('wine-level-everyday'));
      await tester.tap(key('wine-level-everyday'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(key('autofill-clear'));
      await tester.tap(key('autofill-clear'));
      await tester.pumpAndSettle();
      expect(key('clear-form-dialog'), findsOneWidget);
      await tester.tap(key('clear-form-confirm'));
      await tester.pumpAndSettle();
      await tester.enterText(key('add-wine-name-field'), 'Barolo');
      await save(tester);
      expect(saved.single.level, isNull);
    });
  });

  group('Livello (FR4.1-FR4.3, BR4.3)', () {
    testWidgets('not chosen: nothing saved, the preview shows the window', (
      tester,
    ) async {
      await openForm(tester);
      await tester.enterText(key('add-wine-name-field'), 'Barolo');
      await tester.pumpAndSettle();
      expect(key('level-preview'), findsOneWidget);
      await save(tester);
      expect(saved.single.level, isNull);
    });

    testWidgets('a qualifier in the name suggests "Da invecchiamento"; Save '
        'with it visible accepts it', (tester) async {
      await openForm(tester);
      await tester.enterText(key('add-wine-name-field'), 'Rioja Gran Reserva');
      await tester.pumpAndSettle();
      expect(find.text(l10n.levelSuggested), findsOneWidget);
      expect(
        find.text(l10n.levelSuggestedReason('Gran Reserva')),
        findsOneWidget,
      );
      expect(
        find.textContaining(l10n.levelAging, findRichText: true),
        findsWidgets,
      );
      await save(tester);
      expect(saved.single.level, WineLevel.aging);
    });

    testWidgets('the qualifier removed before a tap: no suggestion again', (
      tester,
    ) async {
      await openForm(tester);
      await tester.enterText(key('add-wine-name-field'), 'Chianti Riserva');
      await tester.pumpAndSettle();
      expect(find.text(l10n.levelSuggested), findsOneWidget);
      await tester.enterText(key('add-wine-name-field'), 'Chianti');
      await tester.pumpAndSettle();
      expect(find.text(l10n.levelSuggested), findsNothing);
      await save(tester);
      expect(saved.single.level, isNull);
    });

    testWidgets('"Nessuno" turns the suggestion off for good; Save saves no '
        'level', (tester) async {
      await openForm(tester);
      await tester.enterText(key('add-wine-name-field'), 'Barolo Riserva');
      await tester.pumpAndSettle();
      await tester.ensureVisible(key('wine-level-none'));
      await tester.tap(key('wine-level-none'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.levelSuggested), findsNothing);
      await tester.enterText(
        key('add-wine-name-field'),
        'Barolo Riserva Speciale',
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.levelSuggested), findsNothing);
      await save(tester);
      expect(saved.single.level, isNull);
    });

    testWidgets('another option replaces the suggestion and is saved; the '
        'preview shows "Prima" and "Con"', (tester) async {
      await openForm(tester);
      await tester.enterText(key('add-wine-name-field'), 'Barolo Riserva');
      await tester.pumpAndSettle();
      await tester.ensureVisible(key('wine-level-everyday'));
      await tester.tap(key('wine-level-everyday'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.levelSuggested), findsNothing);
      expect(
        find.textContaining(l10n.levelEveryday, findRichText: true),
        findsWidgets,
      );
      expect(
        find.descendant(
          of: key('level-preview'),
          matching: find.textContaining('«${l10n.levelEveryday}»'),
        ),
        findsOneWidget,
      );
      await save(tester);
      expect(saved.single.level, WineLevel.everyday);
    });

    testWidgets('the qualifier of a label text suggests the level too', (
      tester,
    ) async {
      await openForm(
        tester,
        initialValues: AddWineInitialValues.fromLabelFields(
          extractLabelFields(
            'Rioja\nGran Reserva\nBodegas Muga\n2015',
            currentYear: 2026,
          ),
        ),
      );
      await tester.enterText(key('add-wine-name-field'), 'Muga');
      await tester.pumpAndSettle();
      // The name was written by hand: the text qualifier no longer counts.
      expect(find.text(l10n.levelSuggested), findsNothing);
    });
  });

  group('"Da Google Lens" (BR2.5, FR2.6) and the automatic paste (BR2.6)', () {
    int nowMillis() => ui.clock.now().millisecondsSinceEpoch;

    for (final (route, event) in [
      (LensCameraRoute.lensApp, 'lens lensApp'),
      (LensCameraRoute.googleApp, 'lens googleApp'),
    ]) {
      testWidgets('${route.name}: Lens opens and the trip starts', (
        tester,
      ) async {
        fakes.camera.opening = LensCameraOpening(route, openedAt: nowMillis());
        await openForm(tester);
        await tester.tap(key('autofill-open-lens'));
        await tester.pumpAndSettle();
        expect(fakes.camera.openCalls, 1);
        expect(fakes.events.events, [event]);
        expect(container(tester).read(lensSessionProvider), isNotNull);
        expect(key('lens-instructions'), findsNothing);
      });
    }

    testWidgets('neither opens: the three steps; the form stays', (
      tester,
    ) async {
      await openForm(tester);
      await tester.tap(key('autofill-open-lens'));
      await tester.pumpAndSettle();
      expect(key('lens-instructions'), findsOneWidget);
      expect(fakes.events.events, ['lens unavailable']);
      expect(container(tester).read(lensSessionProvider), isNull);
      await tester.tap(key('lens-instructions-ok'));
      await tester.pumpAndSettle();
      expect(find.byType(AddWineScreen), findsOneWidget);
    });

    testWidgets('"Da Google Lens" from "Aggiungi": the empty form first, '
        'then Lens', (tester) async {
      fakes.camera.opening = LensCameraOpening(
        LensCameraRoute.lensApp,
        openedAt: nowMillis(),
      );
      await openForm(tester, openLens: true);
      expect(find.byType(AddWineScreen), findsOneWidget);
      expect(fakes.camera.openCalls, 1);
    });

    testWidgets('back from Lens with a text copied after it opened: read '
        'once by itself, "Modulo compilato dal testo di Lens"', (tester) async {
      final openedAt = nowMillis() - 60000;
      fakes.camera.opening = LensCameraOpening(
        LensCameraRoute.lensApp,
        openedAt: openedAt,
      );
      await openForm(tester);
      await tester.tap(key('autofill-open-lens'));
      await tester.pumpAndSettle();
      fakes.camera.clip = ClipInfo(
        timestamp: openedAt + 1000,
        mime: 'text/plain',
      );
      fakes.clipboard.text = baroloText;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(fakes.clipboard.reads, 1);
      expect(textOf(tester, 'add-wine-name-field'), 'Barolo Vietti');
      expect(find.text(l10n.autofillFromLens), findsOneWidget);
      expect(fakes.events.events.last, 'autofill auto filled 6');
      // The first focus after it: the same text is never pasted twice.
      fakes.camera.focus.add(null);
      await tester.pumpAndSettle();
      expect(fakes.clipboard.reads, 1);
    });

    testWidgets('a clip older than the opening, or not text: nothing is '
        'read', (tester) async {
      final openedAt = nowMillis() - 60000;
      fakes.camera.opening = LensCameraOpening(
        LensCameraRoute.lensApp,
        openedAt: openedAt,
      );
      await openForm(tester);
      await tester.tap(key('autofill-open-lens'));
      await tester.pumpAndSettle();
      fakes.camera.clip = ClipInfo(timestamp: openedAt - 1, mime: 'text/plain');
      fakes.camera.focus.add(null);
      await tester.pumpAndSettle();
      fakes.camera.clip = ClipInfo(timestamp: openedAt + 1, mime: 'image/png');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(fakes.clipboard.reads, 0);
      expect(textOf(tester, 'add-wine-name-field'), isEmpty);
    });

    testWidgets('without "Da Google Lens" the clipboard is never looked at', (
      tester,
    ) async {
      await openForm(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      fakes.camera.focus.add(null);
      await tester.pumpAndSettle();
      expect(fakes.camera.clipCalls, 0);
      expect(fakes.clipboard.reads, 0);
    });
  });

  group('a shared text (BR2.4)', () {
    testWidgets('opened with a shared text: its fields fill the form', (
      tester,
    ) async {
      await openForm(tester, sharedText: baroloText);
      expect(textOf(tester, 'add-wine-name-field'), 'Barolo Vietti');
      expect(fakes.events.events, ['autofill share filled 6']);
    });

    testWidgets('the open form registers itself, and is dirty only after a '
        'change by hand', (tester) async {
      await openForm(tester);
      final form = container(tester).read(openAutofillFormProvider);
      expect(form, isNotNull);
      expect(form!.isDirty, isFalse);
      await form.applySharedText(baroloText);
      await tester.pumpAndSettle();
      expect(form.isDirty, isFalse);
      await tester.enterText(key('add-wine-producer'), 'Vietti');
      await tester.pumpAndSettle();
      expect(form.isDirty, isTrue);
      final host = container(tester);
      Navigator.of(tester.element(find.byType(AddWineScreen))).pop();
      await tester.pumpAndSettle();
      expect(host.read(openAutofillFormProvider), isNull);
    });
  });

  accessibilityMatrix(
    'AddWineScreen filled from a text',
    () => Builder(
      builder: (context) => AddWineScreen(
        user: cellarOwner,
        cellarId: ownerCellar.cellarId,
        cellar: ownerCellar,
        initialValues: AddWineInitialValues.fromLabelFields(
          extractLabelFields(baroloText, currentYear: 2026),
          notice: 'Compilato',
        ),
        onLens: () {},
        onSearchOnline: (_, _) {},
      ),
    ),
    overrides: () {
      final cellarUi = CellarUi();
      return [...cellarUi.overrides, ...AutofillFakes().overrides];
    },
  );
}
