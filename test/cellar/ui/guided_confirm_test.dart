// The guided check in the add form (label-autofill-windows FR7, FR2.8,
// D10-D12, BR7.10-BR7.25, NFR4.20, NFR4.22-NFR4.24, NFR6.2, A15-A22):
// the sheet, the words, the wheel, the "Guided check" button and the wait
// of "Paste from Lens" in the accessibility matrix; Yes, No, Edit, Skip,
// compose, the wheel, Close, Back, the tap outside, a new text, "Clear",
// rotation, background and the form rebuilt without state. Fake clipboard,
// fake catalog: nothing real is read or opened.
import 'dart:async';

import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/cellar/ui/autofill_widgets.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

import '../../helpers/ui_harness.dart';
import '../../label/autofill_fakes.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

/// IT01: producer and name uncertain (2 questions).
const _it01 =
    "CASCINA CASTLET\nBarbera d'Asti Superiore\n14,5% vol  75 cl\n2019";

/// FR14: only the denomination uncertain; its type follows it.
const _fr14 = 'Domaine de la Combe Haute\nVin Rouge\nCôtes de Bourg\n2020';

/// A short text without a year: only the vintage is asked.
const _noYear = 'Barolo Vietti';

/// ES08: the four fields uncertain.
const _es08 =
    'Señorío de Valcuerna\nGarnacha Viñas Viejas 2019\nNavarra\nEdición 2021';

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

  AddWineScreen form({AddWineInitialValues? initialValues, Key? formKey}) =>
      AddWineScreen(
        key: formKey,
        user: cellarOwner,
        cellarId: ownerCellar.cellarId,
        cellar: ownerCellar,
        initialValues: initialValues,
      );

  AddWineInitialValues fromText(String text) =>
      AddWineInitialValues.fromAnalysis(
        analyzeLabelText(text, currentYear: 2026),
      );

  Future<void> openForm(
    WidgetTester tester, {
    AddWineInitialValues? initialValues,
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
                  builder: (_) => form(initialValues: initialValues),
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

  Future<void> paste(WidgetTester tester, String text) async {
    fakes.clipboard.text = text;
    await tester.ensureVisible(key('autofill-paste'));
    await tester.tap(key('autofill-paste'));
    await tester.pumpAndSettle();
  }

  Future<void> tapGuide(WidgetTester tester, String guideKey) async {
    await tester.ensureVisible(key(guideKey));
    await tester.tap(key(guideKey));
    await tester.pumpAndSettle();
  }

  int wordId(WidgetTester tester, String text) {
    final semantics = tester.widgetList<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('guide-word-') &&
            !(widget.key! as ValueKey<String>).value.startsWith(
              'guide-word-used',
            ),
      ),
    );
    for (final widget in semantics) {
      final label = widget.properties.label ?? '';
      if (label == text || label.startsWith('$text,')) {
        return int.parse(
          (widget.key! as ValueKey<String>).value.substring(
            'guide-word-'.length,
          ),
        );
      }
    }
    throw StateError('no word $text');
  }

  Future<void> tapWord(WidgetTester tester, String text) async {
    final id = wordId(tester, text);
    await tester.ensureVisible(key('guide-word-$id'));
    await tester.tap(key('guide-word-$id'));
    await tester.pumpAndSettle();
  }

  bool filledMark(String field) => find
      .descendant(
        of: key('filled-$field'),
        matching: find.text(l10n.autofillFromText),
      )
      .evaluate()
      .isNotEmpty;

  group('accessibility matrix (NFR6.2, A15-A22)', () {
    List<Override> overrides() => [...ui.overrides, ...fakes.overrides];

    accessibilityMatrix(
      'guide question with words',
      () => form(initialValues: fromText(_it01)),
      overrides: overrides,
    );
    accessibilityMatrix(
      'guide compose',
      () => form(initialValues: fromText(_it01)),
      overrides: overrides,
      afterPump: (tester) async {
        await tester.pumpAndSettle();
        final word = find.byKey(Key('guide-word-${wordId(tester, 'CASCINA')}'));
        await tester.ensureVisible(word);
        await tester.tap(word);
      },
    );
    accessibilityMatrix(
      'guide vintage wheel',
      () => form(initialValues: fromText(_noYear)),
      overrides: overrides,
    );
    accessibilityMatrix(
      'guide edit',
      () => form(initialValues: fromText(_it01)),
      overrides: overrides,
      afterPump: (tester) async {
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('guide-edit')));
        await tester.tap(find.byKey(const Key('guide-edit')));
      },
    );
    accessibilityMatrix(
      'toolbar with "Guided check" and the paste card waiting',
      () => Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AutofillToolbar(onClear: () {}, onGuide: () {}),
            // The indicator spins forever: frozen so the matrix settles.
            TickerMode(
              enabled: false,
              child: PasteFromLensCard(
                onPaste: () {},
                onOpenLens: () {},
                busy: true,
              ),
            ),
          ],
        ),
      ),
    );
  });

  group('the guide on a pasted text (FR7.1, BR7.10-BR7.12)', () {
    testWidgets('IT01: question 1 of 2 read whole; Yes fills with "✦" and '
        'goes on; the last Yes closes the sheet', (tester) async {
      final handle = tester.ensureSemantics();
      await openForm(tester);
      await paste(tester, _it01);
      expect(key('guide-sheet'), findsOneWidget);
      expect(find.text(l10n.guideProgress(1, 2)), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          l10n.guideQuestionSemantics(
            1,
            2,
            l10n.guideAskProducer('Cascina Castlet'),
          ),
        ),
        findsOneWidget,
      );
      // The form under the sheet is not filled with the uncertain fields.
      expect(textOf(tester, 'add-wine-producer'), isEmpty);
      expect(textOf(tester, 'add-wine-denomination'), "Barbera d'Asti DOCG");
      await tapGuide(tester, 'guide-yes');
      expect(textOf(tester, 'add-wine-producer'), 'Cascina Castlet');
      expect(filledMark('producer'), isTrue);
      expect(find.text(l10n.guideProgress(2, 2)), findsOneWidget);
      await tapGuide(tester, 'guide-yes');
      expect(key('guide-sheet'), findsNothing);
      expect(textOf(tester, 'add-wine-name-field'), "Barbera d'Asti Superiore");
      expect(key('autofill-guide'), findsNothing);
      handle.dispose();
    });

    testWidgets('No proposes the next one with its notice for 2 s; N stays', (
      tester,
    ) async {
      await openForm(tester);
      await paste(tester, _it01);
      await tapGuide(tester, 'guide-skip');
      final first = tester.widget<Text>(key('guide-proposal')).data!;
      await tapGuide(tester, 'guide-no');
      expect(find.text(l10n.guideRejected(first)), findsOneWidget);
      expect(find.text(l10n.guideProgress(2, 2)), findsOneWidget);
      expect(tester.widget<Text>(key('guide-proposal')).data, isNot(first));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text(l10n.guideRejected(first)), findsNothing);
    });

    testWidgets('after the last No: "no other", Yes and No off; Skip at the '
        'end: the message and the "Guided check" button', (tester) async {
      await openForm(tester);
      await paste(tester, _it01);
      await tapGuide(tester, 'guide-yes');
      for (var i = 0; i < 5; i++) {
        final no = tester.widget<OutlinedButton>(key('guide-no'));
        if (no.onPressed == null) break;
        await tapGuide(tester, 'guide-no');
      }
      expect(find.text(l10n.guideNoMore), findsOneWidget);
      expect(tester.widget<FilledButton>(key('guide-yes')).onPressed, isNull);
      await tapGuide(tester, 'guide-skip');
      expect(key('guide-sheet'), findsNothing);
      expect(find.text(l10n.guideSkippedNotice('name')), findsOneWidget);
      expect(key('autofill-guide'), findsOneWidget);
      await tapGuide(tester, 'autofill-guide');
      expect(find.text(l10n.guideProgress(1, 1)), findsOneWidget);
    });

    testWidgets('Edit: a valid value fills without "✦"; too long shows the '
        'error of the form and stays', (tester) async {
      await openForm(tester);
      await paste(tester, _it01);
      await tapGuide(tester, 'guide-edit');
      expect(textOf(tester, 'guide-edit-field'), 'Cascina Castlet');
      await tester.enterText(key('guide-edit-field'), 'x' * 121);
      await tapGuide(tester, 'guide-edit-confirm');
      expect(find.text(l10n.producerTooLong), findsOneWidget);
      await tester.enterText(key('guide-edit-field'), 'Castlet & Figli');
      await tapGuide(tester, 'guide-edit-confirm');
      expect(textOf(tester, 'add-wine-producer'), 'Castlet & Figli');
      expect(filledMark('producer'), isFalse);
      expect(find.text(l10n.guideProgress(2, 2)), findsOneWidget);
    });

    testWidgets('Compose: the words in the order of the text, the preview, '
        'Confirm fills with "✦"', (tester) async {
      final handle = tester.ensureSemantics();
      await openForm(tester);
      await paste(tester, _it01);
      await tapWord(tester, 'CASTLET');
      expect(key('guide-yes'), findsNothing);
      await tapWord(tester, 'CASCINA');
      expect(
        find.descendant(
          of: key('guide-preview'),
          matching: find.text('Cascina Castlet'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(l10n.guideWordSelected('CASCINA', 1)),
        findsOneWidget,
      );
      await tapGuide(tester, 'guide-compose-confirm');
      expect(textOf(tester, 'add-wine-producer'), 'Cascina Castlet');
      expect(filledMark('producer'), isTrue);
      handle.dispose();
    });

    testWidgets('a word used by the producer stays selectable for the name, '
        'with its mark (BR7.15)', (tester) async {
      await openForm(tester);
      await paste(tester, _it01);
      await tapGuide(tester, 'guide-yes');
      final id = wordId(tester, 'CASCINA');
      expect(
        find.bySemanticsLabel(l10n.guideWordUsedFor('CASCINA', 'producer')),
        findsOneWidget,
      );
      expect(key('guide-word-used-$id'), findsOneWidget);
      await tester.ensureVisible(key('guide-word-$id'));
      await tester.tap(key('guide-word-$id'));
      await tester.pumpAndSettle();
      expect(key('guide-compose-confirm'), findsOneWidget);
    });

    testWidgets('a denomination confirmed gives type, country and region '
        '(BR7.20)', (tester) async {
      await openForm(tester);
      await paste(tester, _fr14);
      expect(find.text(l10n.guideProgress(1, 1)), findsOneWidget);
      await tapGuide(tester, 'guide-yes');
      expect(textOf(tester, 'add-wine-denomination'), 'Côtes de Bourg');
      expect(filledMark('wineType'), isTrue);
      expect(filledMark('country'), isTrue);
    });
  });

  group('the vintage wheel (BR7.13, A22)', () {
    testWidgets('it starts at the current year - 2; "No vintage" ticks the '
        'switch and is never asked again', (tester) async {
      await openForm(tester);
      await paste(tester, _noYear);
      expect(key('guide-wheel'), findsOneWidget);
      expect(find.text(l10n.guideWheelConfirm('2024')), findsOneWidget);
      await tapGuide(tester, 'guide-no-vintage');
      expect(
        tester.widget<SwitchListTile>(key('add-wine-no-vintage-switch')).value,
        isTrue,
      );
      await paste(tester, _noYear);
      expect(key('guide-sheet'), findsNothing);
    });

    testWidgets('the number pad: out of range keeps it open with the error; '
        'a valid year moves the wheel and Confirm fills it', (tester) async {
      await openForm(tester);
      await paste(tester, _noYear);
      await tapGuide(tester, 'guide-wheel-type');
      await tester.enterText(key('guide-year-field'), '1850');
      await tapGuide(tester, 'guide-year-ok');
      expect(find.text(l10n.vintageRange('2026')), findsOneWidget);
      expect(key('guide-year-field'), findsOneWidget);
      await tester.enterText(key('guide-year-field'), '1985');
      await tapGuide(tester, 'guide-year-ok');
      expect(find.text(l10n.guideWheelConfirm('1985')), findsOneWidget);
      await tapGuide(tester, 'guide-wheel-confirm');
      expect(textOf(tester, 'add-wine-vintage-field'), '1985');
      expect(filledMark('vintage'), isFalse);
    });

    testWidgets('Back with the pad open closes only the pad', (tester) async {
      await openForm(tester);
      await paste(tester, _noYear);
      await tapGuide(tester, 'guide-wheel-type');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(key('guide-year-field'), findsNothing);
      expect(key('guide-wheel'), findsOneWidget);
    });

    testWidgets('the wheel is an adjustable slider of one year', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openForm(tester);
      await paste(tester, _noYear);
      final node = tester.getSemantics(key('guide-wheel-semantics'));
      expect(node.value, '2024');
      expect(node.increasedValue, '2025');
      tester.semantics.increase(find.semantics.byValue('2024'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.guideWheelConfirm('2025')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a year of the text is marked and its Confirm fills with '
        '"✦"', (tester) async {
      await openForm(tester);
      await paste(tester, _es08);
      for (var i = 0; i < 3; i++) {
        await tapGuide(tester, 'guide-skip');
      }
      expect(key('guide-wheel-from-text'), findsOneWidget);
      expect(key('guide-other-years'), findsOneWidget);
      await tapGuide(tester, 'guide-wheel-confirm');
      expect(textOf(tester, 'add-wine-vintage-field'), '2019');
      expect(filledMark('vintage'), isTrue);
      expect(find.text(l10n.guideSkippedMany(3)), findsOneWidget);
    });
  });

  group('closing and interruptions (BR7.17-BR7.21, NFR4.22)', () {
    testWidgets('Close and the tap outside keep the confirmed fields; the '
        'button reopens what is left', (tester) async {
      await openForm(tester);
      await paste(tester, _it01);
      await tapGuide(tester, 'guide-yes');
      await tapGuide(tester, 'guide-close');
      expect(key('guide-sheet'), findsNothing);
      expect(textOf(tester, 'add-wine-producer'), 'Cascina Castlet');
      await tapGuide(tester, 'autofill-guide');
      expect(find.text(l10n.guideProgress(1, 1)), findsOneWidget);
      await tester.tapAt(const Offset(200, 120));
      await tester.pumpAndSettle();
      expect(key('guide-sheet'), findsNothing);
    });

    testWidgets('Back closes the sheet before the form (A19); in Compose '
        'Back goes to the question and the tap outside does nothing', (
      tester,
    ) async {
      await openForm(tester);
      await paste(tester, _it01);
      await tapWord(tester, 'CASCINA');
      await tester.tapAt(const Offset(200, 120));
      await tester.pumpAndSettle();
      expect(key('guide-compose-confirm'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(key('guide-yes'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(key('guide-sheet'), findsNothing);
      expect(key('add-wine-screen'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(key('add-wine-screen'), findsNothing);
    });

    testWidgets('a new text with the guide open closes it, keeps the '
        'confirmed fields and opens a new guide', (tester) async {
      await openForm(tester);
      await paste(tester, _it01);
      await tapGuide(tester, 'guide-yes');
      await tapGuide(tester, 'guide-close');
      // The guide opened again by the button, then a new text arrives.
      await tapGuide(tester, 'autofill-guide');
      final state = tester.state(find.byType(AddWineScreen));
      await (state as dynamic).applySharedText(_es08);
      await tester.pumpAndSettle();
      expect(textOf(tester, 'add-wine-producer'), 'Cascina Castlet');
      // Only the name is left: the denomination and the vintage are filled
      // and the producer has its answer (BR7.18).
      expect(key('guide-sheet'), findsOneWidget);
      expect(find.text(l10n.guideProgress(1, 1)), findsOneWidget);
      expect(find.text(l10n.guideIsName), findsOneWidget);
    });

    testWidgets('"Clear" closes the guide and empties its answers', (
      tester,
    ) async {
      await openForm(tester);
      await paste(tester, _it01);
      await tapGuide(tester, 'guide-yes');
      await tapGuide(tester, 'guide-close');
      await tapGuide(tester, 'autofill-clear');
      expect(key('autofill-guide'), findsNothing);
      await paste(tester, _it01);
      expect(find.text(l10n.guideProgress(1, 2)), findsOneWidget);
    });

    testWidgets('a field written by hand with the guide closed is not asked', (
      tester,
    ) async {
      await openForm(tester);
      await paste(tester, _it01);
      await tapGuide(tester, 'guide-close');
      await tester.ensureVisible(key('add-wine-producer'));
      await tester.enterText(key('add-wine-producer'), 'Mio produttore');
      await tester.pumpAndSettle();
      await tapGuide(tester, 'autofill-guide');
      expect(find.text(l10n.guideProgress(1, 1)), findsOneWidget);
      expect(find.text(l10n.guideIsName), findsOneWidget);
    });

    testWidgets('rotation and the background keep the question, the mode '
        'and the words chosen', (tester) async {
      await openForm(tester);
      await paste(tester, _it01);
      await tapWord(tester, 'CASCINA');
      tester.view.physicalSize = const Size(2400, 1080);
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(key('guide-compose-confirm'), findsOneWidget);
      expect(find.text(l10n.guideProgress(1, 2)), findsOneWidget);
      expect(
        find.descendant(
          of: key('guide-preview'),
          matching: find.text('Cascina'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the form rebuilt without state (Android closed the app) has '
        'no guide', (tester) async {
      await pumpScreen(
        tester,
        form(formKey: const ValueKey(1), initialValues: fromText(_it01)),
        overrides: [...ui.overrides, ...fakes.overrides],
      );
      await tester.pumpAndSettle();
      expect(key('guide-sheet'), findsOneWidget);
      await pumpScreen(
        tester,
        form(formKey: const ValueKey(2)),
        overrides: [...ui.overrides, ...fakes.overrides],
      );
      await tester.pumpAndSettle();
      expect(key('guide-sheet'), findsNothing);
      expect(key('autofill-guide'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the photo form opens its guide after the first frame and '
        'saves only with "Salva" (FR7.6)', (tester) async {
      await openForm(tester, initialValues: fromText(_fr14));
      expect(key('guide-sheet'), findsOneWidget);
      await tapGuide(tester, 'guide-yes');
      expect(saved, isEmpty);
      await tester.tap(key('add-wine-save-button'));
      await tester.pumpAndSettle();
      expect(saved.single.denomination, 'Côtes de Bourg');
    });
  });

  group('the form under the sheet (BR7.19, D10)', () {
    testWidgets('"Salva" is covered: not tapped, not read; a tap there is a '
        'tap outside', (tester) async {
      final handle = tester.ensureSemantics();
      await openForm(tester);
      await paste(tester, _it01);
      expect(key('guide-sheet'), findsOneWidget);
      expect(find.bySemanticsLabel(l10n.save), findsNothing);
      await tester.tap(key('add-wine-save-button'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(saved, isEmpty);
      verifyNever(
        () => ui.actions.saveNewWine(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          draft: any(named: 'draft'),
        ),
      );
      expect(key('guide-sheet'), findsNothing, reason: 'a tap outside');
      expect(find.bySemanticsLabel(l10n.save), findsOneWidget);
      handle.dispose();
    });
  });

  group('privacy (NFR3.8, BR7.22, FR7.9)', () {
    testWidgets('a whole guided session emits no event or log with its '
        'data', (tester) async {
      final logs = <String>[];
      final previous = debugPrint;
      debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
      try {
        await openForm(tester);
        await paste(tester, _it01);
        await tapGuide(tester, 'guide-no');
        await tapWord(tester, 'CASCINA');
        await tapWord(tester, 'CASTLET');
        await tapGuide(tester, 'guide-compose-confirm');
        await tapGuide(tester, 'guide-edit');
        await tester.enterText(key('guide-edit-field'), 'Vigna Segreta');
        await tapGuide(tester, 'guide-edit-confirm');
      } finally {
        debugPrint = previous;
      }
      expect(key('guide-sheet'), findsNothing);
      // The only events are the counts of NFR4.15, with no text.
      expect(fakes.events.events, ['autofill paste filled 5']);
      final emitted = [...fakes.events.events, ...logs].join('\n');
      for (final secret in [
        'Cascina',
        'CASCINA',
        'Castlet',
        'Barbera',
        'Vigna Segreta',
        'Superiore',
      ]) {
        expect(emitted, isNot(contains(secret)));
      }
    });
  });

  group('the wait of "Paste from Lens" (FR2.8, BR7.24, NFR4.23)', () {
    testWidgets('"Reading the text…" from the tap, a second tap ignored, '
        'back to normal at the result', (tester) async {
      final gate = Completer<void>();
      addTearDown(() {
        if (!gate.isCompleted) gate.complete();
      });
      ui.catalog.labelGate = gate;
      await openForm(tester);
      fakes.clipboard.text = 'Barolo Vietti\n2019';
      await tester.ensureVisible(key('autofill-paste'));
      await tester.tap(key('autofill-paste'));
      await tester.pump();
      expect(find.text(l10n.autofillReading), findsOneWidget);
      expect(key('autofill-reading'), findsOneWidget);
      final button = find.ancestor(
        of: find.text(l10n.autofillReading),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      expect(tester.widget<ButtonStyleButton>(button).onPressed, isNull);
      await tester.tap(key('autofill-paste'), warnIfMissed: false);
      await tester.pump();
      expect(fakes.clipboard.reads, 1);
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.text(l10n.autofillReading), findsNothing);
      expect(textOf(tester, 'add-wine-name-field'), 'Barolo Vietti');
    });
  });
}
