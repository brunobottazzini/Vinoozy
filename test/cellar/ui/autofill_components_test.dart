// The new components of label-autofill-windows (frontend-components.md,
// interaction-spec.md; A1-A14): the autofill bar, the "✦ from the text"
// mark, "Paste from Lens", the dialogs, the Lens steps, the level, the
// correction of "Recommended until" and the origin of the estimate, in it,
// en and pt-BR, text 1.0 / 2.0, light and dark.
import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/window_override.dart';
import 'package:vinoozy/cellar/domain/wine_estimate.dart';
import 'package:vinoozy/cellar/ui/autofill_widgets.dart';
import 'package:vinoozy/cellar/ui/ideal_moment_card.dart';
import 'package:vinoozy/cellar/ui/window_override_widgets.dart';
import 'package:vinoozy/cellar/ui/wine_level_selector.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/ui/lens_instructions_sheet.dart';

import '../../helpers/ui_harness.dart';
import '../cellar_harness.dart';

final DateTime today = DateTime(2026, 11, 8);

AppLocalizations it() => lookupAppLocalizations(const Locale('it'));

DrinkingWindow baroloWindow({int end = 2040, Qualifier? qualifier}) =>
    DrinkingWindow(
      startYear: 2024,
      peakYear: 2030,
      endYear: end,
      confidence: Confidence.medium,
      source: WindowSource.internalRules,
      basis: EstimationBasis.denomination,
      qualifier: qualifier,
      denominationKey: 'barolo',
      tablesVersion: estimationTablesVersion,
    );

/// A page with the components that are not dialogs.
class _Gallery extends StatelessWidget {
  const _Gallery();

  @override
  Widget build(BuildContext context) {
    final window = baroloWindow();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AutofillToolbar(onClear: () {}, onSearchOnline: () {}, onLens: () {}),
          const FilledFromTextBadge(visible: true),
          PasteFromLensCard(onPaste: () {}, onOpenLens: () {}),
          WineLevelSelector(
            value: null,
            suggested: WineLevel.aging,
            suggestedReason: 'Gran Reserva',
            onChanged: (_) {},
          ),
          LevelPreview(
            window: baroloWindow(end: 2050),
            level: WineLevel.aging,
            before: window,
          ),
          IdealMomentCard(
            estimate: WineEstimate(
              baseWindow: window,
              window: baroloWindow(end: 2035),
            ),
            today: today,
            windowOverride: const WindowOverride(endYear: 2035),
            level: WineLevel.aging,
            onCorrect: () {},
            onRestore: () {},
          ),
        ],
      ),
    );
  }
}

/// A button that opens [open] when tapped.
class _Opener extends StatelessWidget {
  const _Opener(this.open);

  final Future<void> Function(BuildContext context) open;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Builder(
        builder: (context) => TextButton(
          key: const Key('open'),
          onPressed: () => open(context),
          child: const Text('open'),
        ),
      ),
    ),
  );
}

Future<void> tapOpen(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open')));
  await tester.pumpAndSettle();
}

Finder key(String value) => find.byKey(Key(value));

void main() {
  group('AutofillToolbar (interaction-spec "La barra")', () {
    testWidgets('Clear, Search online and Lens call back', (tester) async {
      final taps = <String>[];
      await pumpScreen(
        tester,
        Scaffold(
          body: AutofillToolbar(
            onClear: () => taps.add('clear'),
            onSearchOnline: () => taps.add('search'),
            onLens: () => taps.add('lens'),
          ),
        ),
      );
      await tester.tap(key('autofill-clear'));
      await tester.tap(key('autofill-search-online'));
      await tester.tap(key('autofill-lens'));
      expect(taps, ['clear', 'search', 'lens']);
      expect(find.text(it().autofillClear), findsOneWidget);
    });

    testWidgets('no front photo: no "Lens"; no search: no "Search online"', (
      tester,
    ) async {
      await pumpScreen(tester, Scaffold(body: AutofillToolbar(onClear: () {})));
      expect(key('autofill-clear'), findsOneWidget);
      expect(key('autofill-lens'), findsNothing);
      expect(key('autofill-search-online'), findsNothing);
    });

    testWidgets('A2 every chip is at least 48 dp high', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: AutofillToolbar(
            onClear: () {},
            onSearchOnline: () {},
            onLens: () {},
          ),
        ),
      );
      for (final name in [
        'autofill-clear',
        'autofill-search-online',
        'autofill-lens',
      ]) {
        expect(tester.getSize(key(name)).height, greaterThanOrEqualTo(48));
      }
    });
  });

  group('FilledFromTextBadge (FR1.3, A1, A13)', () {
    testWidgets('visible: "✦ dal testo", read as "compilato '
        'dall\'etichetta"', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(
        tester,
        const Scaffold(body: FilledFromTextBadge(visible: true)),
      );
      expect(find.text(it().autofillFromText), findsOneWidget);
      expect(find.bySemanticsLabel(it().autofillFromTextSemantics), findsOne);
      handle.dispose();
    });

    testWidgets('hidden: nothing at all', (tester) async {
      await pumpScreen(
        tester,
        const Scaffold(body: FilledFromTextBadge(visible: false)),
      );
      expect(find.text(it().autofillFromText), findsNothing);
    });

    testWidgets('A6 the chip pair onSecondaryContainer on '
        'secondaryContainer', (tester) async {
      await pumpScreen(
        tester,
        const Scaffold(body: FilledFromTextBadge(visible: true)),
        brightness: Brightness.dark,
      );
      final scheme = Theme.of(tester.element(find.text(it().autofillFromText)))
          .colorScheme;
      final text = tester.widget<Text>(find.text(it().autofillFromText));
      expect(text.style?.color, scheme.onSecondaryContainer);
    });
  });

  group('PasteFromLensCard (FR2.2, FR2.6)', () {
    testWidgets('one button pastes, the other opens Lens', (tester) async {
      var pastes = 0;
      var lens = 0;
      await pumpScreen(
        tester,
        Scaffold(
          body: PasteFromLensCard(
            onPaste: () => pastes++,
            onOpenLens: () => lens++,
          ),
        ),
      );
      expect(find.text(it().autofillPasteTitle), findsOneWidget);
      await tester.tap(key('autofill-paste'));
      await tester.tap(key('autofill-open-lens'));
      expect((pastes, lens), (1, 1));
      expect(
        tester.getSize(key('autofill-paste')).height,
        greaterThanOrEqualTo(48),
      );
    });
  });

  group('ClearFormDialog and UseSharedTextDialog (BR2.4, BR2.7, A8)', () {
    for (final (button, expected) in [
      ('clear-form-confirm', true),
      ('clear-form-cancel', false),
    ]) {
      testWidgets('"Svuotare il modulo?" with $button gives $expected', (
        tester,
      ) async {
        bool? result;
        await pumpScreen(
          tester,
          _Opener((context) async {
            result = await ClearFormDialog.show(context);
          }),
        );
        await tapOpen(tester);
        expect(find.text(it().autofillClearTitle), findsOneWidget);
        expect(find.text(it().autofillClearBody), findsOneWidget);
        await tester.tap(key(button));
        await tester.pumpAndSettle();
        expect(result, expected);
      });
    }

    testWidgets('a dismissed dialog clears nothing', (tester) async {
      bool? result;
      await pumpScreen(
        tester,
        _Opener((context) async {
          result = await ClearFormDialog.show(context);
        }),
      );
      await tapOpen(tester);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    for (final (button, expected) in [
      ('use-shared-text-use', true),
      ('use-shared-text-ignore', false),
    ]) {
      testWidgets('"Usare il testo per i campi vuoti?" with $button gives '
          '$expected', (tester) async {
        bool? result;
        await pumpScreen(
          tester,
          _Opener((context) async {
            result = await UseSharedTextDialog.show(context);
          }),
        );
        await tapOpen(tester);
        expect(find.text(it().autofillShareUseTitle), findsOneWidget);
        await tester.tap(key(button));
        await tester.pumpAndSettle();
        expect(result, expected);
      });
    }
  });

  group('LensInstructionsSheet (BR2.5, A8, A14)', () {
    testWidgets('three numbered steps, read in order; "Ho capito" closes', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(
        tester,
        _Opener((context) => LensInstructionsSheet.show(context)),
      );
      await tapOpen(tester);
      final l10n = it();
      expect(find.text(l10n.lensInstructionsTitle), findsOneWidget);
      for (final (index, step) in [
        l10n.lensInstructionsStep1,
        l10n.lensInstructionsStep2,
        l10n.lensInstructionsStep3,
      ].indexed) {
        expect(find.bySemanticsLabel('${index + 1}. $step'), findsOneWidget);
      }
      // The steps are above "Ho capito", in order.
      expect(
        tester.getTopLeft(key('lens-step-1')).dy,
        lessThan(tester.getTopLeft(key('lens-step-3')).dy),
      );
      await tester.tap(key('lens-instructions-ok'));
      await tester.pumpAndSettle();
      expect(key('lens-instructions'), findsNothing);
      handle.dispose();
    });
  });

  group('WineLevelSelector (FR4.1-FR4.3, A3, A10)', () {
    Future<List<WineLevel?>> pumpSelector(
      WidgetTester tester, {
      WineLevel? value,
      WineLevel? suggested,
      String? reason,
    }) async {
      final taps = <WineLevel?>[];
      await pumpScreen(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: WineLevelSelector(
              value: value,
              suggested: suggested,
              suggestedReason: reason,
              onChanged: taps.add,
            ),
          ),
        ),
      );
      return taps;
    }

    testWidgets('three levels and "Nessuno", each at least 48 dp; a tap '
        'gives its level, "Nessuno" gives null', (tester) async {
      final taps = await pumpSelector(tester);
      for (final name in ['everyday', 'good', 'aging', 'none']) {
        final finder = key('wine-level-$name');
        expect(tester.getSize(finder).height, greaterThanOrEqualTo(48));
        await tester.tap(finder);
      }
      expect(taps, [WineLevel.everyday, WineLevel.good, WineLevel.aging, null]);
    });

    testWidgets('not chosen: nothing selected, no suggestion text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpSelector(tester);
      expect(find.text(it().levelSuggested), findsNothing);
      expect(
        tester.getSemantics(key('wine-level-good')),
        isNot(isSemantics(isSelected: true)),
      );
      handle.dispose();
    });

    testWidgets('A3 the suggestion: "suggerito" in words, the reason, and '
        'read as "suggerito, perché il nome contiene Gran Reserva"', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpSelector(
        tester,
        suggested: WineLevel.aging,
        reason: 'Gran Reserva',
      );
      final l10n = it();
      expect(find.text(l10n.levelSuggested), findsOneWidget);
      expect(
        find.text(l10n.levelSuggestedReason('Gran Reserva')),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(key('wine-level-aging')),
        isSemantics(
          label:
              '${l10n.levelOptionSemantics(l10n.levelAging, 3, 4)}, '
              '${l10n.levelSuggestedSemantics('Gran Reserva')}',
        ),
      );
      handle.dispose();
    });

    testWidgets('a chosen level hides the suggestion and is selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpSelector(
        tester,
        value: WineLevel.good,
        suggested: WineLevel.aging,
        reason: 'Riserva',
      );
      expect(find.text(it().levelSuggested), findsNothing);
      expect(
        tester.getSemantics(key('wine-level-good')),
        isSemantics(isSelected: true, isInMutuallyExclusiveGroup: true),
      );
      handle.dispose();
    });

    testWidgets('"Cosa cambia" shows examples for every level', (tester) async {
      await pumpSelector(tester);
      await tester.tap(key('wine-level-what-changes'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(it().levelAgingExamples, findRichText: true),
        findsOneWidget,
      );
    });
  });

  group('LevelPreview (FR4.2)', () {
    testWidgets('a changed window: "Prima" and "Con «level»"', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: LevelPreview(
            window: baroloWindow(end: 2050),
            level: WineLevel.aging,
            before: baroloWindow(),
          ),
        ),
      );
      final l10n = it();
      expect(find.text(l10n.levelPreviewBefore('2024', '2040')), findsOne);
      expect(
        find.text(l10n.levelPreviewWith(l10n.levelAging, '2024', '2050')),
        findsOneWidget,
      );
    });

    testWidgets('no level or the same window: the window alone', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: Column(
            children: [
              LevelPreview(window: baroloWindow(), level: null),
              LevelPreview(
                window: baroloWindow(),
                level: WineLevel.good,
                before: baroloWindow(),
              ),
            ],
          ),
        ),
      );
      expect(find.text(it().levelPreviewNow('2024', '2040')), findsNWidgets(2));
    });
  });

  group('CorrectEndYearSheet (FR5.1, BR4.6, A4)', () {
    test('the grid stays within start..start+60 and is sorted', () {
      expect(CorrectEndYearSheet.gridYears(2024, 2030, 2040), [
        2024,
        2030,
        2032,
        2036,
        2040,
        2044,
        2048,
        2052,
      ]);
      expect(CorrectEndYearSheet.gridYears(2024, 2025, 2026), [
        2024,
        2025,
        2026,
        2030,
        2034,
        2038,
      ]);
      // 2062, 2066 and 2070 are past start + 60 (BR4.6).
      expect(CorrectEndYearSheet.gridYears(2000, 2010, 2058), [
        2000,
        2010,
        2050,
        2054,
        2058,
      ]);
    });

    Future<int?> Function() openSheet(
      WidgetTester tester, {
      int start = 2024,
      int peak = 2030,
      int end = 2040,
    }) {
      int? picked;
      var done = false;
      return () async {
        await pumpScreen(
          tester,
          _Opener((context) async {
            picked = await CorrectEndYearSheet.show(
              context,
              startYear: start,
              peakYear: peak,
              currentEnd: end,
            );
            done = true;
          }),
        );
        await tapOpen(tester);
        return done ? picked : null;
      };
    }

    testWidgets('the estimated end is preselected; "Salva correzione" '
        'returns it', (tester) async {
      int? picked;
      await pumpScreen(
        tester,
        _Opener((context) async {
          picked = await CorrectEndYearSheet.show(
            context,
            startYear: 2024,
            peakYear: 2030,
            currentEnd: 2040,
          );
        }),
      );
      await tapOpen(tester);
      expect(
        tester.widget<ChoiceChip>(key('override-year-2040')).selected,
        isTrue,
      );
      await tester.tap(key('override-save'));
      await tester.pumpAndSettle();
      expect(picked, 2040);
    });

    testWidgets('a year before "al meglio" shows the notice; the year '
        'chosen is saved', (tester) async {
      int? picked;
      await pumpScreen(
        tester,
        _Opener((context) async {
          picked = await CorrectEndYearSheet.show(
            context,
            startYear: 2024,
            peakYear: 2030,
            currentEnd: 2040,
          );
        }),
      );
      await tapOpen(tester);
      expect(key('override-peak-notice'), findsNothing);
      await tester.tap(key('override-year-2024'));
      await tester.pumpAndSettle();
      expect(find.text(it().overridePeakNotice('2030')), findsOneWidget);
      await tester.tap(key('override-save'));
      await tester.pumpAndSettle();
      expect(picked, 2024);
    });

    testWidgets('A4 the year before "Pronto da" is struck through, not '
        'selectable and not read', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(
        tester,
        _Opener((context) async {
          await CorrectEndYearSheet.show(
            context,
            startYear: 2024,
            peakYear: 2030,
            currentEnd: 2040,
          );
        }),
      );
      await tapOpen(tester);
      final chip = tester.widget<ChoiceChip>(key('override-year-2023'));
      expect(chip.onSelected, isNull);
      expect(find.bySemanticsLabel('2023'), findsNothing);
      await tester.tap(key('override-year-2023'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(
        tester.widget<ChoiceChip>(key('override-year-2040')).selected,
        isTrue,
      );
      handle.dispose();
    });

    testWidgets('"altro…" lists every year from start to start + 60', (
      tester,
    ) async {
      int? picked;
      await pumpScreen(
        tester,
        _Opener((context) async {
          picked = await CorrectEndYearSheet.show(
            context,
            startYear: 2024,
            peakYear: 2030,
            currentEnd: 2040,
          );
        }),
      );
      await tapOpen(tester);
      await tester.tap(key('override-more'));
      await tester.pumpAndSettle();
      expect(key('override-list-2024'), findsOneWidget);
      expect(key('override-list-2023'), findsNothing);
      await tester.scrollUntilVisible(
        key('override-list-2084'),
        200,
        scrollable: find.descendant(
          of: key('override-year-list'),
          matching: find.byType(Scrollable),
        ),
      );
      expect(key('override-list-2085'), findsNothing);
      await tester.tap(key('override-list-2084'));
      await tester.pumpAndSettle();
      expect(key('override-year-2084'), findsOneWidget);
      await tester.tap(key('override-save'));
      await tester.pumpAndSettle();
      expect(picked, 2084);
    });

    testWidgets('a current end past start + 60 starts at the limit', (
      tester,
    ) async {
      final open = openSheet(tester, start: 2000, peak: 2005, end: 2090);
      await open();
      expect(
        tester.widget<ChoiceChip>(key('override-year-2060')).selected,
        isTrue,
      );
      expect(key('override-year-2090'), findsNothing);
    });

    testWidgets('closed without saving: no year', (tester) async {
      int? picked = -1;
      await pumpScreen(
        tester,
        _Opener((context) async {
          picked = await CorrectEndYearSheet.show(
            context,
            startYear: 2024,
            peakYear: 2030,
            currentEnd: 2040,
          );
        }),
      );
      await tapOpen(tester);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(picked, isNull);
    });
  });

  group('RestoreEstimateDialog (FR5.4)', () {
    for (final (button, expected) in [
      ('restore-estimate-confirm', true),
      ('restore-estimate-cancel', false),
    ]) {
      testWidgets('"Tornare alla stima dell\'app (fino al 2040)?" with '
          '$button gives $expected', (tester) async {
        bool? result;
        await pumpScreen(
          tester,
          _Opener((context) async {
            result = await RestoreEstimateDialog.show(context, 2040);
          }),
        );
        await tapOpen(tester);
        expect(find.text(it().overrideRestoreTitle('2040')), findsOneWidget);
        await tester.tap(key(button));
        await tester.pumpAndSettle();
        expect(result, expected);
      });
    }
  });

  group('EstimateSourceLine (interaction-spec "Origine della stima")', () {
    Future<void> pumpLine(WidgetTester tester, DrinkingWindow window) =>
        pumpScreen(tester, Scaffold(body: EstimateSourceLine(window: window)));

    testWidgets('the appellation, with its qualifier', (tester) async {
      await pumpLine(tester, baroloWindow());
      expect(
        find.text(it().estimateFromDenomination('Barolo DOCG')),
        findsOneWidget,
      );
      await pumpLine(tester, baroloWindow(qualifier: Qualifier.riserva));
      expect(
        find.text(
          it().estimateFromDenominationQualifier('Barolo DOCG', 'Riserva'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the grape, the type, nothing for a catalog window', (
      tester,
    ) async {
      const grape = 'merlot';
      await pumpLine(
        tester,
        DrinkingWindow(
          startYear: 2024,
          peakYear: 2026,
          endYear: 2030,
          confidence: Confidence.low,
          source: WindowSource.internalRules,
          basis: EstimationBasis.grape,
          denominationKey: grape,
        ),
      );
      expect(
        find.text(it().estimateFromGrape(grapeNameOf(grape)!)),
        findsOneWidget,
      );
      await pumpLine(
        tester,
        windowOf(2024, 2026, 2030, basis: EstimationBasis.wineType),
      );
      expect(find.text(it().estimateFromType), findsOneWidget);
      await pumpLine(
        tester,
        windowOf(2024, 2026, 2030, basis: EstimationBasis.catalog),
      );
      expect(key('estimate-origin'), findsNothing);
    });
  });

  group('IdealMomentCard with the correction (FR5.2, BR4.7)', () {
    Future<List<String>> pumpCard(
      WidgetTester tester, {
      WindowOverride? override,
      bool canEdit = true,
      WineLevel? level,
    }) async {
      final taps = <String>[];
      final base = baroloWindow();
      await pumpScreen(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: IdealMomentCard(
              estimate: WineEstimate(
                baseWindow: base,
                window: override == null
                    ? base
                    : baroloWindow(end: override.endYear),
              ),
              today: today,
              windowOverride: override,
              level: level,
              onCorrect: canEdit ? () => taps.add('correct') : null,
              onRestore: canEdit ? () => taps.add('restore') : null,
            ),
          ),
        ),
      );
      return taps;
    }

    testWidgets('without a correction: the notice, "Correggi" and no '
        '"Ripristina stima"', (tester) async {
      final taps = await pumpCard(tester);
      final l10n = it();
      expect(key('window-disclaimer'), findsOneWidget);
      expect(key('corrected-badge'), findsNothing);
      expect(key('override-restore'), findsNothing);
      expect(
        find.text(l10n.estimateFromDenomination('Barolo DOCG')),
        findsOneWidget,
      );
      await tester.tap(key('override-correct'));
      expect(taps, ['correct']);
    });

    testWidgets('with a correction: "corretto da te" instead of the notice, '
        'the app estimate under it, and "Ripristina stima"', (tester) async {
      final taps = await pumpCard(
        tester,
        override: const WindowOverride(endYear: 2035),
        level: WineLevel.aging,
      );
      final l10n = it();
      expect(find.text(l10n.uxIdealUntil('2035')), findsOneWidget);
      expect(find.text(l10n.overrideCorrectedByYou), findsOneWidget);
      expect(key('window-disclaimer'), findsNothing);
      expect(find.text(l10n.overrideAppEstimate('2040')), findsOneWidget);
      expect(find.text(l10n.levelDetail(l10n.levelAging)), findsOneWidget);
      // The origin line stays with the correction.
      expect(key('estimate-origin'), findsOneWidget);
      await tester.tap(key('override-restore'));
      expect(taps, ['restore']);
    });

    testWidgets('a reader sees the correction but no command', (tester) async {
      await pumpCard(
        tester,
        override: const WindowOverride(endYear: 2035),
        canEdit: false,
      );
      expect(key('corrected-badge'), findsOneWidget);
      expect(key('override-correct'), findsNothing);
      expect(key('override-restore'), findsNothing);
    });

    testWidgets('no estimate: the notice stays, no command', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: IdealMomentCard(
            estimate: WineEstimate.none,
            today: today,
            windowOverride: const WindowOverride(endYear: 2035),
          ),
        ),
      );
      expect(key('window-none'), findsOneWidget);
      expect(key('window-disclaimer'), findsOneWidget);
      expect(key('override-correct'), findsNothing);
    });
  });

  // A1-A14 on every new component, in the matrix of the app.
  accessibilityMatrix(
    'the autofill and level components',
    () => const _Gallery(),
  );
  accessibilityMatrix(
    'CorrectEndYearSheet',
    () => _Opener(
      (context) => CorrectEndYearSheet.show(
        context,
        startYear: 2024,
        peakYear: 2030,
        currentEnd: 2040,
      ),
    ),
    afterPump: (tester) async {
      await tapOpen(tester);
      await tester.tap(find.byKey(const Key('override-year-2024')));
    },
  );
  accessibilityMatrix(
    'LensInstructionsSheet',
    () => _Opener((context) => LensInstructionsSheet.show(context)),
    afterPump: tapOpen,
  );
  accessibilityMatrix(
    'ClearFormDialog',
    () => _Opener((context) => ClearFormDialog.show(context)),
    afterPump: tapOpen,
  );
  accessibilityMatrix(
    'RestoreEstimateDialog',
    () => _Opener((context) => RestoreEstimateDialog.show(context, 2040)),
    afterPump: tapOpen,
  );
  accessibilityMatrix(
    'UseSharedTextDialog',
    () => _Opener((context) => UseSharedTextDialog.show(context)),
    afterPump: tapOpen,
  );
}
