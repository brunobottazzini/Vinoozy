import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/core/label_reading.dart';
import 'package:vinoozy/label/core/label_session.dart';
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

      testWidgets('BR1.9 BR1.10 minimum path: "Scatta foto", "Conferma" '
          '(NFR1.3) and back to the cellar with a message', (tester) async {
        final l10n = l10nOf(locale);
        photoReads('Barolo DOCG 2016', barcodes: [testEan13]);
        ui.env.catalog.byBarcode = candidateOf(
          'Barolo Bussia',
          producer: 'Cantina A',
          wineType: CatalogWineType.red,
        );
        await ui.pumpAddChoice(tester, locale: locale);
        var taps = 0;
        await tester.tap(find.byKey(const Key('add-choice-photo')));
        taps++;
        await tester.pumpAndSettle();
        expect(find.text(l10n.labelRecognized), findsOneWidget);
        expect(find.text('Barolo Bussia'), findsOneWidget);
        expect(find.textContaining('2016'), findsOneWidget);
        expect(find.byKey(const Key('label-offline-notice')), findsNothing);
        await tester.tap(find.byKey(const Key('label-confirm')));
        taps++;
        await tester.pumpAndSettle();
        expect(taps, 2);
        final draft = savedDraft();
        expect(draft.name, 'Barolo Bussia');
        expect(draft.vintage, 2016);
        expect(draft.quantity, 1);
        expect(find.byKey(const Key('root-page')), findsOneWidget);
        expect(find.text(l10n.labelWineAdded), findsOneWidget);
        expect(ui.env.source.origins, [PhotoOrigin.camera]);
        expect(ui.env.files.files, isEmpty, reason: 'copy deleted (BR1.6)');
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

  group('BR1.9 proposal', () {
    testWidgets('BR1.9 quantity 1 to 99, producer "—", offline notice', (
      tester,
    ) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('Barolo DOCG');
      ui.env.network.online = false;
      ui.env.catalog.byText = LabelMatch.matched(
        candidateOf('Barolo DOCG', source: CandidateSource.internal),
      );
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelOfflineNotice), findsOneWidget);
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
      ui.env.catalog.byBarcode = candidateOf(
        'Barolo Bussia',
        producer: 'Cantina A',
        wineType: CatalogWineType.red,
        region: 'Piemonte',
        denomination: 'Barolo DOCG',
      );
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
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
      expect(find.text('Barolo Bussia'), findsOneWidget);
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
      ui.env.catalog.byText = LabelMatch.matched(candidateOf('Barolo DOCG'));
      final existing = cellarWine('old', name: 'Barolo DOCG', quantity: 97);
      ui.saveResult = AddDuplicate(existing);
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
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
        ui.env.catalog.byText = LabelMatch.matched(candidateOf('Barolo DOCG'));
        ui.saveResult = AddDuplicate(cellarWine('old', name: 'Barolo DOCG'));
        await ui.pumpAddChoice(tester);
        await tester.tap(find.byKey(const Key('add-choice-photo')));
        await tester.pumpAndSettle();
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
      ui.env.catalog.byText = LabelMatch.matched(candidateOf('Barolo DOCG'));
      ui.saveResult = const AddFailed();
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
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
      ui.env.catalog.byText = LabelMatch.matched(candidateOf('Barolo DOCG'));
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
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
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
      ui.env.catalog.byText = LabelMatch.matched(candidateOf('B' * 130));
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('label-confirm')));
      await tester.pumpAndSettle();
      expect(find.byType(AddWineScreen), findsOneWidget);
    });
  });

  group('BR1.11 hard cases', () {
    testWidgets('BR1.11 unreadable: "Riprova" opens the same button again', (
      tester,
    ) async {
      photoReads('12');
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-import')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('label-unreadable')), findsOneWidget);
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
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('label-write-by-hand')));
      await tester.pumpAndSettle();
      final form = tester.widget<AddWineScreen>(find.byType(AddWineScreen));
      expect(form.initialValues, isNull);
    });

    testWidgets('BR1.11 no wine found: the form with the line, the vintage '
        'and the notice; BR1.12 most significant line', (tester) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('750 ml\nCantina del Lago Rosso\n2019');
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelNotFound), findsOneWidget);
      expect(find.text('Cantina del Lago Rosso'), findsOneWidget);
      expect(find.text('2019'), findsOneWidget);
    });

    testWidgets('BR1.11 barcode without network: "Riprova quando torna la '
        'rete" looks it up with no new photo', (tester) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('', barcodes: [testEan13]);
      ui.env.network.online = false;
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelBarcodeNeedsNetwork), findsOneWidget);
      ui.env.network.online = true;
      ui.env.catalog.byBarcode = candidateOf('Barolo');
      await tester.tap(find.byKey(const Key('label-retry-online')));
      await tester.pumpAndSettle();
      expect(find.text('Barolo'), findsOneWidget);
      expect(ui.env.source.origins, hasLength(1));
    });

    testWidgets('BR1.11 barcode not found with network: front photo hint', (
      tester,
    ) async {
      final l10n = l10nOf(const Locale('it'));
      photoReads('', barcodes: [testEan13]);
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.labelBarcodeNotFound), findsOneWidget);
      expect(find.text(l10n.labelBarcodeFrontHint), findsOneWidget);
      expect(find.byKey(const Key('label-retry-online')), findsNothing);
      await tester.tap(find.byKey(const Key('label-write-by-hand')));
      await tester.pumpAndSettle();
      expect(find.byType(AddWineScreen), findsOneWidget);
    });

    testWidgets('BR1.14 a refused image is unreadable with label_pick_failed', (
      tester,
    ) async {
      photoReads('Barolo');
      ui.env.channel.result = const RejectedImage('format');
      await ui.pumpAddChoice(tester);
      await tester.tap(find.byKey(const Key('add-choice-photo')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('label-unreadable')), findsOneWidget);
      expect(ui.env.reasons, [pickFailed]);
    });

    testWidgets(
      'BR1.14 a failing picker is unreadable with label_pick_failed',
      (tester) async {
        ui.env.source.outcome = PickFailed(StateError('x'), StackTrace.current);
        await ui.pumpAddChoice(tester);
        await tester.tap(find.byKey(const Key('add-choice-photo')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('label-unreadable')), findsOneWidget);
        expect(ui.env.reasons, [pickFailed]);
      },
    );
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
      await tester.pump();
      await tester.pump();
      expect(find.text(l10n.labelReading), findsOneWidget);
      await tester.tap(find.byKey(const Key('label-cancel')));
      await tester.pump(const Duration(milliseconds: 300));
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

    for (final (name, text, codes) in [
      ('LabelProposalSheet', 'Barolo DOCG 2016', <String>[]),
      ('LabelUnreadableView', '', <String>[]),
      ('BarcodeOnlyView', '', [testEan13]),
    ]) {
      accessibilityMatrix(
        name,
        () => const LabelReadingScreen(
          target: labelTarget,
          input: PickedLabelInput('/cache/1/pick.jpg'),
          origin: PhotoOrigin.camera,
        ),
        overrides: () {
          final screen = LabelUi();
          screen.env.reader.reading = LabelReading(
            text: text,
            barcodes: [
              for (final code in codes)
                ReadBarcode(LabelBarcodeFormat.ean13, code),
            ],
          );
          screen.env.catalog.byText = LabelMatch.matched(
            candidateOf('Barolo DOCG', producer: 'Cantina A', vintage: 2016),
          );
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
