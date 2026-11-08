import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart'
    show ConsoleCatalogEventLogger;
import 'package:vinoozy/catalog/core/offline/wine_db_record.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/catalog/platform/catalog_providers.dart';
import 'package:vinoozy/catalog/platform/wine_db_loader.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/core/label_reading.dart';
import 'package:vinoozy/label/core/label_session.dart';
import 'package:vinoozy/label/core/lens_launcher.dart';
import 'package:vinoozy/label/label_providers.dart';
import 'package:vinoozy/label/platform/picker_image_source.dart';
import 'package:vinoozy/label/platform/shared_image_channel.dart';
import 'package:vinoozy/label/ui/add_choice_screen.dart';
import 'package:vinoozy/label/ui/label_reading_screen.dart';

import '../../cellar/cellar_harness.dart';
import '../../helpers/ui_harness.dart';
import '../label_harness.dart';
import 'label_ui_harness.dart';

void main() {
  late LabelUi ui;

  setUp(() => ui = LabelUi());

  AppLocalizations l10nOf(Locale locale) => lookupAppLocalizations(locale);

  /// A photo that reads [text] and the [barcodes].
  void photoReads(String text, {List<String> barcodes = const []}) {
    ui.env.source.outcome = const PickedImage('/cache/1/pick.jpg');
    ui.env.reader.reading = LabelReading(
      text: text,
      barcodes: [
        for (final code in barcodes)
          ReadBarcode(LabelBarcodeFormat.ean13, code),
      ],
    );
  }

  /// "Scatta foto" then "Salta" on "Ora il retro" (label-recognition BR1.1).
  Future<void> takeFrontOnly(
    WidgetTester tester, {
    String button = 'add-choice-photo',
  }) async {
    await tester.tap(find.byKey(Key(button)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('label-back-skip')));
    await tester.pumpAndSettle();
  }

  /// label-autofill-windows BR2.1: a text with fields and no wine opens the
  /// form filled from it above "not found"; back returns to "not found".
  Future<void> backFromFilledForm(
    WidgetTester tester, {
    bool guide = true,
  }) async {
    final form = tester.widget<AddWineScreen>(find.byType(AddWineScreen));
    expect(form.initialValues!.filledKeys, isNotEmpty);
    expect(form.returnToRootOnSave, isTrue);
    // FR7.1, A19: the guide opens on the form of the photo; close it first.
    if (guide) {
      await closeGuideSheet(tester);
    } else {
      // Every key field certain or absent: no guide (FR7.1).
      expect(find.byKey(const Key('guide-sheet')), findsNothing);
    }
    await Navigator.of(tester.element(find.byType(AddWineScreen))).maybePop();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('label-not-found-noMatch')), findsOneWidget);
  }

  WineDraft savedDraft() =>
      verify(
            () => ui.actions.saveNewWine(
              cellar: any(named: 'cellar'),
              user: any(named: 'user'),
              draft: captureAny(named: 'draft'),
            ),
          ).captured.single
          as WineDraft;

  for (final locale in testLocales) {
    final tag = locale.toLanguageTag();

    group('($tag)', () {
      testWidgets('BR1.1 "Aggiungi" shows three buttons; "Scrivi" opens the '
          'U4 form', (tester) async {
        final l10n = l10nOf(locale);
        await ui.pumpAddChoice(tester, locale: locale);
        expect(find.text(l10n.addChoicePhoto), findsOneWidget);
        expect(find.text(l10n.addChoiceImport), findsOneWidget);
        expect(find.text(l10n.addChoiceWrite), findsOneWidget);
        await tester.tap(find.byKey(const Key('add-choice-write')));
        await tester.pumpAndSettle();
        expect(find.byType(AddWineScreen), findsOneWidget);
        expect(find.byType(AddChoiceScreen), findsNothing);
      });

      testWidgets('BR1.9 BR1.10 minimum path: "Scatta foto", "Salta", '
          '"Conferma" and back to the cellar with a message', (tester) async {
        final l10n = l10nOf(locale);
        photoReads('Barolo DOCG 2016', barcodes: [testEan13]);
        ui.env.catalog.byLabel = sureMatch(
          candidateOf(
            'Barolo Bussia',
            producer: 'Cantina A',
            wineType: CatalogWineType.red,
            source: CandidateSource.offline,
          ),
          step: LabelMatchStep.offlineBarcode,
        );
        await ui.pumpAddChoice(tester, locale: locale);
        await tester.tap(find.byKey(const Key('add-choice-photo')));
        await tester.pumpAndSettle();
        expect(find.text(l10n.labelBackTitle), findsOneWidget);
        await tester.tap(find.byKey(const Key('label-back-skip')));
        await tester.pumpAndSettle();
        expect(find.text(l10n.labelRecognized), findsOneWidget);
        expect(find.text('Barolo Bussia'), findsOneWidget);
        expect(find.textContaining('2016'), findsOneWidget);
        expect(find.text(l10n.labelSourceOffline), findsOneWidget);
        expect(find.text(l10n.labelOffAttribution), findsOneWidget);
        await tester.tap(find.byKey(const Key('label-confirm')));
        await tester.pumpAndSettle();
        final draft = savedDraft();
        expect(draft.name, 'Barolo Bussia');
        expect(draft.vintage, 2016);
        expect(draft.quantity, 1);
        // ux-redesign FR1.3: "Barolo" in the name gives Piemonte, Italy.
        expect(draft.country, 'IT');
        expect(draft.region, 'Piemonte');
        expect(find.byKey(const Key('root-page')), findsOneWidget);
        expect(find.text(l10n.labelWineAdded), findsOneWidget);
        expect(ui.env.source.origins, [PhotoOrigin.camera]);
        await tester.pumpAndSettle();
        expect(ui.env.files.files, isEmpty, reason: 'BR1.4 copies deleted');
      });
    });
  }

  group('BR1.2 BR1.3 picker', () {
    testWidgets('BR1.2 back from the camera without a photo: "Aggiungi", no '
        'message', (tester) async {
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      expect(find.byType(AddChoiceScreen), findsOneWidget);
      expect(find.byType(LabelReadingScreen), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('BR1.3 "Importa una foto" opens the gallery', (tester) async {
      photoReads('Cantina del Lago');
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-import')));
      await tester.pumpAndSettle();
      expect(ui.env.source.origins, [PhotoOrigin.gallery]);
    });
  });

  group('label-recognition BR1.1 the back', () {
    testWidgets('BR1.1 "Scatta il retro" reads the back too: barcode only on '
        'the back', (tester) async {
      photoReads('Barolo Ravera');
      ui.env.catalog.byLabel = sureMatch(candidateOf('Barolo Ravera'));
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      ui.env.source.outcome = const PickedImage('/cache/2/back.jpg');
      await tester.tap(find.byKey(const Key('label-back-take')));
      await tester.pumpAndSettle();
      expect(ui.env.source.origins, [PhotoOrigin.camera, PhotoOrigin.camera]);
      expect(ui.env.reader.paths, hasLength(2));
      expect(find.byKey(const Key('label-proposal')), findsOneWidget);
    });

    testWidgets('BR1.6 the gallery cancelled for the back is "Salta"', (
      tester,
    ) async {
      photoReads('Barolo Ravera');
      ui.env.catalog.byLabel = sureMatch(candidateOf('Barolo Ravera'));
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      ui.env.source.outcome = const PickCancelled();
      await tester.tap(find.byKey(const Key('label-back-gallery')));
      await tester.pumpAndSettle();
      expect(ui.env.source.origins.last, PhotoOrigin.gallery);
      expect(ui.env.reader.paths, hasLength(1));
      expect(find.byKey(const Key('label-proposal')), findsOneWidget);
    });

    testWidgets('BR1.5 an unreadable back says "Retro non leggibile"', (
      tester,
    ) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('Barolo Ravera');
      ui.env.catalog.byLabel = sureMatch(candidateOf('Barolo Ravera'));
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      ui.env.source.outcome = const PickedImage('/back.jpg');
      ui.env.channel.result = const RejectedImage('decode');
      await tester.tap(find.byKey(const Key('label-back-take')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelBackUnreadable), findsOneWidget);
      expect(find.byKey(const Key('label-proposal')), findsOneWidget);
    });
  });

  group('BR1.9 proposal', () {
    testWidgets('BR1.9 quantity 1 to 99, producer "—", "Senza annata", the '
        'source "dal catalogo"', (tester) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('Barolo DOCG');
      ui.env.catalog.byLabel = sureMatch(
        candidateOf('Barolo DOCG', source: CandidateSource.internal),
      );
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      expect(find.text(l10n.labelSourceCatalog), findsOneWidget);
      expect(find.text(l10n.labelOffAttribution), findsNothing);
      expect(find.textContaining('—'), findsOneWidget);
      expect(find.textContaining(l10n.noVintage), findsOneWidget);
      final decrease = find.byKey(const Key('quantity-decrease-button'));
      expect(tester.widget<IconButton>(decrease).onPressed, isNull);
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const Key('quantity-increase-button')));
        await tester.pump();
      }
      await tester.tap(find.byKey(const Key('label-confirm')));
      await tester.pumpAndSettle();
      expect(savedDraft().quantity, 3);
    });

    testWidgets('BR1.10 "Correggi" opens the U4 form with the proposal and '
        'the quantity (BR1.15)', (tester) async {
      photoReads('Barolo DOCG 2016', barcodes: [testEan13]);
      ui.env.catalog.byLabel = sureMatch(
        candidateOf(
          'Barolo Bussia',
          producer: 'Cantina A',
          wineType: CatalogWineType.red,
          region: 'Piemonte',
          denomination: 'Barolo DOCG',
        ),
      );
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      await tester.tap(find.byKey(const Key('quantity-increase-button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('label-correct')));
      await tester.pumpAndSettle();
      final form = tester.widget<AddWineScreen>(find.byType(AddWineScreen));
      final values = form.initialValues!;
      expect(values.name, 'Barolo Bussia');
      expect(values.producer, 'Cantina A');
      expect(values.vintage, 2016);
      expect(values.quantity, 2);
      expect(values.wineType, 'redStructured');
      expect(values.country, 'IT');
      expect(values.region, 'Piemonte');
      verifyNever(
        () => ui.actions.saveNewWine(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          draft: any(named: 'draft'),
        ),
      );
    });

    testWidgets('BR1.15 a duplicate shows the U4 dialog and adds the bottles', (
      tester,
    ) async {
      photoReads('Barolo DOCG');
      ui.env.catalog.byLabel = sureMatch(candidateOf('Barolo DOCG'));
      final existing = cellarWine('old', name: 'Barolo DOCG', quantity: 97);
      ui.saveResult = AddDuplicate(existing);
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byKey(const Key('quantity-increase-button')));
        await tester.pump();
      }
      await tester.tap(find.byKey(const Key('label-confirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('duplicate-dialog')), findsOneWidget);
      await tester.tap(find.byKey(const Key('duplicate-confirm')));
      await tester.pumpAndSettle();
      verify(
        () => ui.actions.addBottles(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          wine: existing,
          n: 2,
        ),
      ).called(1);
      expect(find.byKey(const Key('root-page')), findsOneWidget);
    });

    testWidgets(
      'BR1.15 cancelling the duplicate dialog stays on the proposal',
      (tester) async {
        photoReads('Barolo DOCG');
        ui.env.catalog.byLabel = sureMatch(candidateOf('Barolo DOCG'));
        ui.saveResult = AddDuplicate(cellarWine('old', name: 'Barolo DOCG'));
        await ui.pumpAddChoice(tester);
        await takeFrontOnly(tester);
        await tester.tap(find.byKey(const Key('label-confirm')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('duplicate-cancel')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('label-proposal')), findsOneWidget);
        final confirm = find.byKey(const Key('label-confirm'));
        expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
      },
    );

    testWidgets('BR1.15 a failed save keeps the proposal and the quantity', (
      tester,
    ) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('Barolo DOCG');
      ui.env.catalog.byLabel = sureMatch(candidateOf('Barolo DOCG'));
      ui.saveResult = const AddFailed();
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      await tester.tap(find.byKey(const Key('quantity-increase-button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('label-confirm')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.saveFailed), findsOneWidget);
      expect(find.byKey(const Key('label-proposal')), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('BR1.15 a failed add to a duplicate keeps the proposal', (
      tester,
    ) async {
      photoReads('Barolo DOCG');
      ui.env.catalog.byLabel = sureMatch(candidateOf('Barolo DOCG'));
      ui.saveResult = AddDuplicate(cellarWine('old', name: 'Barolo DOCG'));
      when(
        () => ui.actions.addBottles(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          wine: any(named: 'wine'),
          n: any(named: 'n'),
        ),
      ).thenAnswer((_) async => SaveFailure(StateError('local')));
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      await tester.tap(find.byKey(const Key('label-confirm')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('duplicate-confirm')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('label-save-failed')), findsOneWidget);
    });

    testWidgets('BR1.10 a catalog name the form refuses opens the form', (
      tester,
    ) async {
      photoReads('Barolo DOCG');
      ui.env.catalog.byLabel = sureMatch(candidateOf('B' * 130));
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      await tester.tap(find.byKey(const Key('label-confirm')));
      await tester.pumpAndSettle();
      expect(find.byType(AddWineScreen), findsOneWidget);
    });

    group('review R-02 the sample database', () {
      /// The loader of the app, already opened on a database whose
      /// manifest says [source].
      Future<WineDbLoader> openedLoader(String source) async {
        final manifest = utf8.encode(
          jsonEncode({
            'formatVersion': wineDbFormatVersion,
            'exportDate': '2026-11-07',
            'wineCount': 1,
            'source': source,
          }),
        );
        final wines = gzip.encode(
          utf8.encode(
            '${const WineDbRecord(code: '8001234567897', name: 'Barolo Ravera').toJsonLine()}\n',
          ),
        );
        final loader = WineDbLoader(
          logger: const ConsoleCatalogEventLogger(debugLogging: false),
          readAsset: (key) async =>
              Uint8List.fromList(key == wineDbManifestAsset ? manifest : wines),
          runInBackground: <R>(FutureOr<R> Function() work) async => work(),
        );
        await loader.open();
        return loader;
      }

      Future<void> showOfflineProposal(
        WidgetTester tester,
        WineDbLoader loader,
      ) async {
        photoReads('Barolo Ravera');
        ui.env.catalog.byLabel = sureMatch(
          candidateOf('Barolo Ravera', source: CandidateSource.offline),
          others: [
            candidateOf('Barolo Bussia', source: CandidateSource.offline),
          ],
        );
        ui.extraOverrides = [wineDbLoaderProvider.overrideWithValue(loader)];
        await ui.pumpAddChoice(tester);
        await takeFrontOnly(tester);
        expect(find.byKey(const Key('label-proposal')), findsOneWidget);
      }

      testWidgets('an offline proposal and its candidates carry no Open Food '
          'Facts attribution', (tester) async {
        final loader = await tester.runAsync(() => openedLoader('sample'));
        await showOfflineProposal(tester, loader!);
        expect(find.byKey(const Key('label-off-attribution')), findsNothing);
        await tester.tap(find.byKey(const Key('label-not-this')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('label-candidate-list')), findsOneWidget);
        expect(find.byKey(const Key('label-off-attribution')), findsNothing);
      });

      testWidgets('the real export keeps the attribution on an offline '
          'proposal', (tester) async {
        final loader = await tester.runAsync(
          () => openedLoader('Open Food Facts'),
        );
        await showOfflineProposal(tester, loader!);
        await tester.scrollUntilVisible(
          find.byKey(const Key('label-off-attribution')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(const Key('label-off-attribution')), findsOneWidget);
      });
    });

    testWidgets('BR3.5 "Non è questo" shows the candidates, a candidate '
        'opens the form above the list (BR4.4)', (tester) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('Barolo 2016');
      ui.env.catalog.byLabel = sureMatch(
        candidateOf('Barolo Ravera'),
        others: [candidateOf('Barolo Bussia', producer: 'Elvio Cogno')],
      );
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      await tester.tap(find.byKey(const Key('label-not-this')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelCandidatesTitle), findsOneWidget);
      await tester.tap(find.byKey(const Key('label-candidate-0')));
      await tester.pumpAndSettle();
      final form = tester.widget<AddWineScreen>(find.byType(AddWineScreen));
      expect(form.initialValues!.name, 'Barolo Bussia');
      expect(form.initialValues!.producer, 'Elvio Cogno');
      expect(form.initialValues!.vintage, 2016);
      expect(form.returnToRootOnSave, isTrue);
      Navigator.of(tester.element(find.byType(AddWineScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelCandidatesTitle), findsOneWidget);
      await tester.tap(find.byKey(const Key('label-candidates-none')));
      await tester.pumpAndSettle();
      await backFromFilledForm(tester, guide: false);
    });

    testWidgets('BR4.4 saving a candidate goes back to the cellar', (
      tester,
    ) async {
      photoReads('Barbaresco');
      ui.env.catalog.byLabel = candidatesMatch([
        candidateOf('Barbaresco Asili', producer: 'Produttori'),
      ]);
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      await tester.tap(find.byKey(const Key('label-candidate-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add-wine-save-button')));
      await tester.pumpAndSettle();
      expect(savedDraft().name, 'Barbaresco Asili');
      expect(find.byKey(const Key('root-page')), findsOneWidget);
    });
  });

  group('BR1.11 BR3.4 not found', () {
    testWidgets('BR1.11 unreadable: "Riprova" opens the same button again', (
      tester,
    ) async {
      photoReads('12');
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester, button: 'add-choice-import');
      expect(
        find.byKey(const Key('label-not-found-unreadable')),
        findsOneWidget,
      );
      ui.env.source.outcome = const PickCancelled();
      await tester.tap(find.byKey(const Key('label-retry')));
      await tester.pumpAndSettle();
      expect(ui.env.source.origins, [PhotoOrigin.gallery, PhotoOrigin.gallery]);
      expect(find.byType(AddChoiceScreen), findsOneWidget);
    });

    testWidgets('BR1.11 unreadable: "Scrivi a mano" opens the empty form', (
      tester,
    ) async {
      photoReads('');
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      await tester.tap(find.byKey(const Key('label-write-by-hand')));
      await tester.pumpAndSettle();
      final form = tester.widget<AddWineScreen>(find.byType(AddWineScreen));
      expect(form.initialValues, isNull);
    });

    testWidgets('BR1.11 BR1.12 no wine found: the text read; "Scrivi a mano" '
        'opens the form with the line, the vintage and the notice', (
      tester,
    ) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('750 ml\nCantina del Lago Rosso\n2019');
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      await backFromFilledForm(tester);
      expect(find.text(l10n.labelNoMatch), findsOneWidget);
      expect(find.textContaining('Cantina del Lago Rosso'), findsOneWidget);
      await tester.tap(find.byKey(const Key('label-write-by-hand')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelNotFound), findsOneWidget);
      expect(find.text('Cantina del Lago Rosso'), findsOneWidget);
      expect(find.text('2019'), findsOneWidget);
    });

    testWidgets('BR3.4 barcode not found: front photo hint and "Cerca '
        'online" with the barcode', (tester) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('', barcodes: [testEan13]);
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      expect(find.text(l10n.labelBarcodeNotFound), findsOneWidget);
      expect(find.text(l10n.labelBarcodeFrontHint), findsOneWidget);
      await tester.tap(find.byKey(const Key('label-search-online')));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(
        find.byKey(const Key('online-search-field')),
      );
      expect(field.controller!.text, testEan13);
    });

    testWidgets('BR1.14 a refused image is unreadable with label_pick_failed', (
      tester,
    ) async {
      photoReads('Barolo');
      ui.env.channel.result = const RejectedImage('format');
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('label-not-found-unreadable')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('label-lens')), findsNothing);
      expect(ui.env.reasons, [pickFailed]);
    });

    testWidgets(
      'BR1.14 a failing picker is unreadable with label_pick_failed',
      (tester) async {
        ui.env.source.outcome = PickFailed(StateError('x'), StackTrace.current);
        await ui.pumpAddChoice(tester);
        await tester.tap(find.byKey(const Key('add-choice-photo')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('label-not-found-unreadable')),
          findsOneWidget,
        );
        expect(ui.env.reasons, [pickFailed]);
      },
    );
  });

  group('BR5.1 Google Lens', () {
    testWidgets('BR5.1 NFR3.1 "Annulla" on the confirmation sends nothing; '
        '"Apri Google Lens" sends the front', (tester) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('Château Musar');
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      await backFromFilledForm(tester);
      await tester.tap(find.byKey(const Key('label-lens')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelLensBody), findsOneWidget);
      await tester.tap(find.byKey(const Key('lens-cancel')));
      await tester.pumpAndSettle();
      expect(ui.env.lens.paths, isEmpty);
      await tester.tap(find.byKey(const Key('label-lens')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('lens-confirm')));
      await tester.pumpAndSettle();
      expect(ui.env.lens.paths.single, startsWith('/cache/label/'));
      expect(find.byKey(const Key('label-not-found-noMatch')), findsOneWidget);
    });

    testWidgets('NFR4.10 when nothing opens, a message and the outcome stays', (
      tester,
    ) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('Château Musar');
      ui.env.lens.route = LensRoute.failed;
      await ui.pumpAddChoice(tester);
      await takeFrontOnly(tester);
      await backFromFilledForm(tester);
      await tester.tap(find.byKey(const Key('label-lens')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('lens-confirm')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelLensFailed), findsOneWidget);
      expect(find.byKey(const Key('label-not-found-noMatch')), findsOneWidget);
    });
  });

  group('BR1.5 permissions', () {
    testWidgets('BR1.5 camera refused: explanation, "Apri impostazioni", '
        '"Scrivi a mano"', (tester) async {
      final l10n = l10nOf(const Locale('it'));
      ui.env.source.outcome = const PickDenied();
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelCameraDenied), findsOneWidget);
      await tester.tap(find.byKey(const Key('label-open-settings')));
      await tester.pump();
      expect(ui.env.channel.settingsCalls, 1);
      await tester.tap(find.byKey(const Key('label-write-by-hand')));
      await tester.pumpAndSettle();
      expect(find.byType(AddWineScreen), findsOneWidget);
    });

    testWidgets('BR1.5 photos refused says "alle foto"', (tester) async {
      final l10n = l10nOf(const Locale('it'));
      ui.env.source.outcome = const PickDenied();
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-import')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelPhotosDenied), findsOneWidget);
    });

    testWidgets('BR1.5 no camera: "Importa una foto" opens the gallery', (
      tester,
    ) async {
      final l10n = l10nOf(const Locale('it'));
      ui.env.source.outcome = const PickCameraUnavailable();
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelCameraUnavailable), findsOneWidget);
      ui.env.source.outcome = const PickCancelled();
      await tester.tap(find.byKey(const Key('label-import')));
      await tester.pumpAndSettle();
      expect(ui.env.source.origins, [PhotoOrigin.camera, PhotoOrigin.gallery]);
    });
  });

  group('BR1.13 Annulla', () {
    testWidgets('BR1.13 "Leggo l\'etichetta…" then "Annulla" back to '
        '"Aggiungi" within 300 ms (NFR1.4); the copy is deleted', (
      tester,
    ) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('Barolo');
      ui.env.reader.gate = Completer<void>();
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('label-back-skip')));
      await tester.pump();
      await tester.pump();
      expect(find.text(l10n.labelReading), findsOneWidget);
      final route = ModalRoute.of(
        tester.element(find.byType(LabelReadingScreen)),
      )!;
      await tester.tap(find.byKey(const Key('label-cancel')));
      // NFR1.4: the way back starts in the frame of the tap, without waiting
      // for the reading; the screen is gone when the page transition ends
      // (the route was fully shown, so the whole transition plays).
      await tester.pump();
      expect(route.isCurrent, isFalse);
      expect(route.animation!.status, AnimationStatus.reverse);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(LabelReadingScreen), findsNothing);
      expect(find.byType(AddChoiceScreen), findsOneWidget);
      ui.env.reader.gate!.complete();
      await tester.pumpAndSettle();
      expect(ui.env.files.files, isEmpty);
      expect(find.byType(AddChoiceScreen), findsOneWidget);
    });
  });

  group('NFR3 accessibility', () {
    testWidgets('NFR3.2 the reading is a live region, buttons are labelled', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      photoReads('Barolo');
      ui.env.reader.gate = Completer<void>();
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('label-back-skip')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      final text = l10nOf(const Locale('it')).labelReading;
      expect(
        tester.getSemantics(find.bySemanticsLabel(text)),
        isSemantics(label: text, isLiveRegion: true),
      );
      ui.env.reader.gate!.complete();
      await tester.pumpAndSettle();
      handle.dispose();
    });

    accessibilityMatrix(
      'AddChoiceScreen',
      () => const AddChoiceScreen(target: labelTarget),
      overrides: () => LabelUi().overrides,
    );

    Future<void> skip(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('label-back-skip')));
    }

    for (final (name, text, codes) in [
      ('LabelProposalSheet', 'Barolo DOCG 2016', <String>[]),
      ('NotFoundView unreadable', '', <String>[]),
      ('NotFoundView barcodeNotFound', '', [testEan13]),
      ('NotFoundView noMatch', 'Cantina del Lago', <String>[]),
    ]) {
      accessibilityMatrix(
        name,
        () => const LabelReadingScreen(
          target: labelTarget,
          input: PickedLabelInput('/cache/1/pick.jpg'),
          origin: PhotoOrigin.camera,
        ),
        afterPump: skip,
        overrides: () {
          final screen = LabelUi();
          screen.env.reader.reading = LabelReading(
            text: text,
            barcodes: [
              for (final code in codes)
                ReadBarcode(LabelBarcodeFormat.ean13, code),
            ],
          );
          if (name == 'LabelProposalSheet') {
            screen.env.catalog.byLabel = sureMatch(
              candidateOf(
                'Barolo DOCG',
                producer: 'Cantina A',
                vintage: 2016,
                source: CandidateSource.offline,
              ),
            );
          }
          return screen.overrides;
        },
      );
    }

    accessibilityMatrix(
      'PermissionDeniedView',
      () => const LabelReadingScreen(
        target: labelTarget,
        input: DeniedLabelInput(PhotoOrigin.camera),
        origin: PhotoOrigin.camera,
      ),
      overrides: () => LabelUi().overrides,
    );
  });
}
