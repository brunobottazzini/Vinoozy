// The Style in the interface (wine-style-profiles BR5.1-BR5.5, BR6.4-BR6.6,
// BR7.3, BR8.1, BR8.2, NFR5.2): style chips, "✦ suggested", "Restore
// suggestion", the date field and its errors, "Style to confirm", the ideal
// moment in months, without a peak or an end; the accessibility matrix
// (3 languages × text 1.0/2.0 × light/dark).
import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_estimate.dart';
import 'package:vinoozy/cellar/domain/wine_validator.dart';
import 'package:vinoozy/cellar/ui/classification_state.dart';
import 'package:vinoozy/cellar/ui/ideal_moment_card.dart';
import 'package:vinoozy/cellar/ui/style_widgets.dart';
import 'package:vinoozy/cellar/ui/wine_labels.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

import '../../helpers/ui_harness.dart';

Finder key(String value) => find.byKey(Key(value));

DrinkingWindow _window(WineFacts facts) => estimateWindow(facts)!;

final _champagne = _window(
  const WineFacts(
    name: 'Champagne',
    vintage: 2018,
    referenceYear: 2026,
    agingStartYear: 2024,
    agingStartMonth: 3,
  ),
); // SP_CLASSIC_AGE: 2025-03 / 2027-03 / 2030-03

final _lbv = _window(const WineFacts(name: 'Porto LBV', referenceYear: 2026));

final _sherry = _window(const WineFacts(name: 'Jerez Fino', vintage: 2020));

class _ChipsHost extends StatefulWidget {
  const _ChipsHost({this.type = WineType.sparklingClassic});

  final WineType type;

  @override
  State<_ChipsHost> createState() => _ChipsHostState();
}

class _ChipsHostState extends State<_ChipsHost> {
  WineStyle? selected = WineStyle.classicFresh;
  bool suggested = true;
  bool restorable = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          StyleField(
            wineType: widget.type,
            selected: selected,
            suggested: suggested,
            onChanged: (style) => setState(() {
              selected = style;
              suggested = false;
              restorable = true;
            }),
          ),
          RestoreSuggestionLink(
            key: const Key('restore'),
            visible: restorable,
            onRestore: () => setState(() {
              selected = WineStyle.classicFresh;
              suggested = true;
              restorable = false;
            }),
          ),
          const StyleToConfirmBanner(),
        ],
      ),
    ),
  );
}

class _DateHost extends StatefulWidget {
  const _DateHost({this.error});

  final AgingStartError? error;

  @override
  State<_DateHost> createState() => _DateHostState();
}

class _DateHostState extends State<_DateHost> {
  final year = TextEditingController();
  int? month;

  @override
  void dispose() {
    year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: AgingStartField(
        anchor: AgingAnchor.disgorgement,
        month: month,
        yearController: year,
        error: widget.error,
        onMonthChanged: (m) => setState(() => month = m),
        onYearChanged: (_) {},
      ),
    ),
  );
}

Widget _card(DrinkingWindow window, {WineLevel? level}) => Scaffold(
  body: SingleChildScrollView(
    child: IdealMomentCard(
      estimate: WineEstimate(baseWindow: window, window: window),
      today: DateTime(2026, 11, 9),
      level: level,
    ),
  ),
);

void main() {
  late AppLocalizations l10n;

  group('BR5.2 StyleField', () {
    testWidgets('the options of the type, the suggestion marked once', (
      tester,
    ) async {
      await pumpScreen(tester, const _ChipsHost());
      l10n = AppLocalizations.of(tester.element(key('style-field')));
      expect(key('style-classicFresh'), findsOneWidget);
      expect(key('style-classicAge'), findsOneWidget);
      expect(key('style-tankFresh'), findsNothing);
      expect(find.text(l10n.suggestedMark), findsOneWidget);
    });

    testWidgets('a tap chooses, the mark goes, Restore brings it back', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, const _ChipsHost());
      await tester.tap(key('style-classicAge'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ChoiceChip>(key('style-classicAge')).selected,
        isTrue,
      );
      expect(key('style-suggested'), findsOneWidget);
      l10n = AppLocalizations.of(tester.element(key('style-field')));
      expect(find.text(l10n.suggestedMark), findsNothing);
      expect(find.text(l10n.restoreSuggestion), findsOneWidget);
      await tester.tap(find.text(l10n.restoreSuggestion));
      await tester.pumpAndSettle();
      expect(find.text(l10n.suggestedMark), findsOneWidget);
      expect(find.text(l10n.restoreSuggestion), findsNothing);
      handle.dispose();
    });

    testWidgets('the screen reader reads style, position and suggestion', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, const _ChipsHost(type: WineType.fortified));
      l10n = AppLocalizations.of(tester.element(key('style-field')));
      expect(
        find.bySemanticsLabel(
          l10n.styleGroupSemantics(l10n.stylePortVintage, 1, 9),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('BR8.2 AgingStartField', () {
    for (final (error, text) in [
      (
        AgingStartError.incomplete,
        (AppLocalizations l) => l.agingStartIncomplete,
      ),
      (AgingStartError.future, (AppLocalizations l) => l.agingStartFuture),
      (
        AgingStartError.beforeVintage,
        (AppLocalizations l) => l.agingStartBeforeVintage,
      ),
    ]) {
      testWidgets('${error.name} shows its message under the field', (
        tester,
      ) async {
        await pumpScreen(tester, _DateHost(error: error));
        l10n = AppLocalizations.of(tester.element(key('aging-start-field')));
        expect(find.text(text(l10n)), findsOneWidget);
        expect(find.text(l10n.agingStartDisgorgement), findsOneWidget);
        expect(find.text(l10n.agingStartHint), findsOneWidget);
      });
    }

    testWidgets('the months are written in the app language', (tester) async {
      await pumpScreen(tester, const _DateHost(), locale: const Locale('it'));
      await tester.tap(key('aging-start-month'));
      await tester.pumpAndSettle();
      expect(find.text('marzo').last, findsOneWidget);
    });
  });

  group('BR6.4-BR6.6 IdealMomentCard', () {
    testWidgets('a window in months: months in long form, no level effect', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        _card(_champagne, level: WineLevel.good),
        locale: const Locale('it'),
      );
      expect(find.textContaining('marzo 2027'), findsWidgets);
      expect(key('ideal-peak'), findsOneWidget);
      expect(key('ideal-level-no-effect'), findsOneWidget);
      expect(key('estimate-origin'), findsOneWidget);
    });

    testWidgets('no end: "Ready, no end estimated", bar open', (tester) async {
      await pumpScreen(tester, _card(_lbv), locale: const Locale('en'));
      l10n = AppLocalizations.of(tester.element(key('window-card')));
      expect(find.text(l10n.windowNoEnd), findsOneWidget);
      expect(key('ideal-peak'), findsNothing);
      expect(key('ideal-bar-open'), findsOneWidget);
      // From the date added: the invitation to add the bottling.
      expect(find.text(l10n.estimateFromEntryDateBottling), findsOneWidget);
    });

    testWidgets('no peak (Sherry): no "At its best" peak line', (tester) async {
      await pumpScreen(
        tester,
        _card(_sherry),
        locale: const Locale('pt', 'BR'),
      );
      expect(key('ideal-peak'), findsNothing);
      expect(find.textContaining('2021'), findsWidgets);
    });
  });

  group('BR6.6 formats', () {
    testWidgets('long and short months in the three languages', (tester) async {
      for (final (locale, long, short) in [
        (const Locale('it'), 'marzo 2027', 'mar 2027'),
        (const Locale('en'), 'March 2027', 'Mar 2027'),
        (const Locale('pt', 'BR'), 'março de 2027', 'mar. de 2027'),
      ]) {
        late BuildContext context;
        await pumpScreen(
          tester,
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
          locale: locale,
        );
        expect(formatMonthLong(context, 2027, 3), long);
        expect(formatMonthShort(context, 2027, 3), short);
      }
    });

    testWidgets('labels of every style and profile exist', (tester) async {
      late BuildContext context;
      await pumpScreen(
        tester,
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );
      l10n = AppLocalizations.of(context);
      for (final style in WineStyle.values) {
        expect(styleLabel(l10n, style), isNotEmpty);
        expect(agingStartLabel(l10n, style) == null, !style.profile.inMonths);
      }
      for (final profile in StyleProfile.values) {
        expect(profileName(l10n, profile), isNotEmpty);
      }
    });
  });

  group('ClassificationState (F2, BR7.2, BR7.3, BR5.1, BR8.1)', () {
    test('the preselection fills automatic fields, never the user ones', () {
      final state = ClassificationState()
        ..refresh(name: 'Prosecco Superiore', referenceYear: 2026);
      expect(state.type, WineType.sparklingTank);
      expect(state.typeSource, FieldSource.auto);
      expect(state.style, WineStyle.tankFresh);
      expect(state.agingStartVisible, isTrue);
      expect(state.agingStartAnchor, AgingAnchor.bottling);
      state
        ..chooseType(WineType.sparklingClassic)
        ..refresh(name: 'Prosecco Superiore', referenceYear: 2026);
      expect(state.type, WineType.sparklingClassic);
      expect(state.canRestoreType, isTrue);
      expect(state.style, WineStyle.classicFresh);
      state
        ..restoreType()
        ..refresh(name: 'Prosecco Superiore', referenceYear: 2026);
      expect(state.type, WineType.sparklingTank);
    });

    test('a chosen style is kept; a style of another type goes', () {
      final state = ClassificationState()
        ..refresh(name: 'Champagne', referenceYear: 2026)
        ..chooseStyle(WineStyle.classicAge)
        ..refresh(name: 'Champagne Brut', referenceYear: 2026);
      expect(state.style, WineStyle.classicAge);
      expect(state.canRestoreStyle, isTrue);
      state
        ..chooseType(WineType.white)
        ..refresh(name: 'Champagne Brut', referenceYear: 2026);
      expect(state.style, isNot(WineStyle.classicAge));
      state
        ..agingYear = 2024
        ..agingMonth = 3;
      expect(state.agingStart, isNull); // white: years profile, no date
    });

    test('BR5.1 the field shows when it matters', () {
      final barolo = ClassificationState()
        ..refresh(name: 'Barolo', referenceYear: 2026);
      expect(barolo.styleVisible, isFalse);
      final red = ClassificationState()
        ..refresh(name: 'Rosso della casa', referenceYear: 2026);
      expect(red.styleVisible, isTrue);
      expect(red.styleToConfirm, isTrue);
      final rose = ClassificationState()
        ..refresh(name: 'Rosato del Salento', referenceYear: 2026);
      expect(rose.styleVisible, isFalse);
      final sherry = ClassificationState()
        ..refresh(name: 'Jerez', referenceYear: 2026);
      expect(sherry.styleVisible, isTrue);
      expect(sherry.style, isNull);
      final empty = ClassificationState()
        ..refresh(name: '  ', referenceYear: 2026);
      expect(empty.type, isNull);
      expect(empty.styleVisible, isFalse);
    });

    test('ofWine reads the sources; an old wine is the user\'s', () {
      final state = ClassificationState.ofWine(
        const Wine(
          id: 'w1',
          name: 'Barolo',
          vintage: 2016,
          storedQuantity: 1,
          wineType: 'redStructured',
          style: WineStyle.redLong,
          agingStart: AgingStart(2024, 3),
        ),
      );
      expect(state.typeIsUser, isTrue);
      expect(state.styleIsUser, isTrue);
      expect(state.agingYear, 2024);
    });
  });

  accessibilityMatrix('StyleField and notice', () => const _ChipsHost());
  accessibilityMatrix('AgingStartField', () => const _DateHost());
  accessibilityMatrix('IdealMomentCard in months', () => _card(_champagne));
  accessibilityMatrix('IdealMomentCard without end', () => _card(_lbv));
}
