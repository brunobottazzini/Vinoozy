// The level in the edit form and the correction of "Recommended until" in
// the detail (label-autofill-windows FR4.3, FR4.4, FR5.1-FR5.4, BR4.3,
// BR4.6): a saved level is never replaced by a suggestion; "Correggi"
// preselects the estimated end and saves one year; "Ripristina stima" asks
// and writes once.
import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/ui/edit_wine_screen.dart';
import 'package:vinoozy/cellar/ui/wine_detail_screen.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/sharing/domain/membership.dart';

import '../../helpers/ui_harness.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

void main() {
  late CellarUi ui;
  late List<WineDraft> edits;
  final l10n = lookupAppLocalizations(const Locale('it'));

  setUp(() {
    ui = CellarUi();
    edits = [];
    when(
      () => ui.actions.saveEdit(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        before: any(named: 'before'),
        draft: any(named: 'draft'),
        targetQuantity: any(named: 'targetQuantity'),
      ),
    ).thenAnswer((invocation) async {
      edits.add(invocation.namedArguments[#draft] as WineDraft);
      return EditResult.saved;
    });
  });

  Finder key(String value) => find.byKey(Key(value));

  /// [screen] pushed from a host page.
  Future<void> push(WidgetTester tester, Widget Function() screen) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const Key('open'),
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => screen())),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      overrides: ui.overrides,
    );
    await tester.tap(key('open'));
    await tester.pump();
  }

  Future<void> saveEdit(WidgetTester tester) async {
    await tester.tap(key('edit-wine-save'));
    await tester.pumpAndSettle();
  }

  group('EditWineScreen: the level (FR4.3, BR4.3)', () {
    Future<void> openEdit(WidgetTester tester, Wine wine) async {
      await push(
        tester,
        () =>
            EditWineScreen(user: cellarOwner, cellar: ownerCellar, wine: wine),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a saved level is selected and never replaced by a '
        'suggestion', (tester) async {
      await openEdit(
        tester,
        cellarWine('w1', name: 'Barolo Riserva', level: WineLevel.good),
      );
      await tester.ensureVisible(key('wine-level-good'));
      expect(find.text(l10n.levelSuggested), findsNothing);
      await saveEdit(tester);
      expect(edits.single.level, WineLevel.good);
    });

    testWidgets('no saved level: the name suggests one, Save accepts it', (
      tester,
    ) async {
      await openEdit(tester, cellarWine('w1', name: 'Barolo Riserva'));
      expect(find.text(l10n.levelSuggested), findsOneWidget);
      await saveEdit(tester);
      expect(edits.single.level, WineLevel.aging);
    });

    testWidgets('a level chosen in the edit is saved', (tester) async {
      await openEdit(tester, cellarWine('w1', level: WineLevel.good));
      await tester.ensureVisible(key('wine-level-everyday'));
      await tester.tap(key('wine-level-everyday'));
      await tester.pumpAndSettle();
      await saveEdit(tester);
      expect(edits.single.level, WineLevel.everyday);
    });

    testWidgets('"Nessuno" goes back to "not chosen"', (tester) async {
      await openEdit(tester, cellarWine('w1', level: WineLevel.aging));
      await tester.ensureVisible(key('wine-level-none'));
      await tester.tap(key('wine-level-none'));
      await tester.pumpAndSettle();
      await saveEdit(tester);
      expect(edits.single.level, isNull);
    });

    testWidgets('the appellation can be written and is saved', (tester) async {
      await openEdit(
        tester,
        cellarWine('w1', name: 'Rosso', denomination: 'Langhe DOC'),
      );
      expect(
        tester
            .widget<TextField>(key('edit-wine-denomination'))
            .controller!
            .text,
        'Langhe DOC',
      );
      await tester.enterText(key('edit-wine-denomination'), 'Barolo DOCG');
      await tester.pumpAndSettle();
      await saveEdit(tester);
      expect(edits.single.denomination, 'Barolo DOCG');
    });

    testWidgets('an appellation over 120 characters is refused', (
      tester,
    ) async {
      await openEdit(tester, cellarWine('w1'));
      await tester.enterText(key('edit-wine-denomination'), 'x' * 121);
      await tester.pumpAndSettle();
      await saveEdit(tester);
      expect(edits, isEmpty);
      expect(find.text(l10n.denominationTooLong), findsOneWidget);
    });
  });

  group('WineDetailScreen: the correction (FR5.1-FR5.4)', () {
    final base = windowOf(2024, 2028, 2034);
    final plain = cellarWine('w1', window: base, baseWindow: base);
    final corrected = cellarWine(
      'w1',
      window: windowOf(2024, 2028, 2030),
      baseWindow: base,
      windowOverride: const WindowOverride(endYear: 2030),
    );

    Future<void> openDetail(
      WidgetTester tester,
      Wine wine, {
      AccessibleCellar cellar = ownerCellar,
    }) async {
      await push(
        tester,
        () => WineDetailScreen(
          user: cellarOwner,
          cellar: cellar,
          wineId: wine.id,
        ),
      );
      ui.emitWines([wine]);
      await tester.pumpAndSettle();
    }

    void stubOverride(bool result) => when(
      () => ui.actions.setOverride(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
        endYear: any(named: 'endYear'),
      ),
    ).thenAnswer((_) async => result);

    void stubRestore(bool result) => when(
      () => ui.actions.restoreEstimate(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
      ),
    ).thenAnswer((_) async => result);

    testWidgets('"Correggi": the estimated end preselected; a year saved '
        'once, "Correzione salvata"', (tester) async {
      stubOverride(true);
      await openDetail(tester, plain);
      await tester.ensureVisible(key('override-correct'));
      await tester.tap(key('override-correct'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ChoiceChip>(key('override-year-2034')).selected,
        isTrue,
      );
      await tester.tap(key('override-year-2030'));
      await tester.pumpAndSettle();
      await tester.tap(key('override-save'));
      await tester.pumpAndSettle();
      verify(
        () => ui.actions.setOverride(
          cellar: ownerCellar,
          user: cellarOwner,
          wine: plain,
          endYear: 2030,
        ),
      ).called(1);
      expect(find.text(l10n.overrideSaved), findsOneWidget);
    });

    testWidgets('a refused correction says so', (tester) async {
      stubOverride(false);
      await openDetail(tester, plain);
      await tester.ensureVisible(key('override-correct'));
      await tester.tap(key('override-correct'));
      await tester.pumpAndSettle();
      await tester.tap(key('override-save'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.saveFailed), findsOneWidget);
    });

    testWidgets('closing the sheet writes nothing', (tester) async {
      stubOverride(true);
      await openDetail(tester, plain);
      await tester.ensureVisible(key('override-correct'));
      await tester.tap(key('override-correct'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      verifyNever(
        () => ui.actions.setOverride(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          wine: any(named: 'wine'),
          endYear: any(named: 'endYear'),
        ),
      );
    });

    testWidgets('with a correction: "corretto da te", the app estimate, '
        'and "Correggi" preselects the corrected year', (tester) async {
      await openDetail(tester, corrected);
      expect(find.text(l10n.overrideCorrectedByYou), findsOneWidget);
      expect(find.text(l10n.overrideAppEstimate('2034')), findsOneWidget);
      await tester.ensureVisible(key('override-correct'));
      await tester.tap(key('override-correct'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ChoiceChip>(key('override-year-2030')).selected,
        isTrue,
      );
    });

    testWidgets('"Ripristina stima": the question with the app year; '
        '"Annulla" writes nothing, "Ripristina" writes once', (tester) async {
      stubRestore(true);
      await openDetail(tester, corrected);
      await tester.ensureVisible(key('override-restore'));
      await tester.tap(key('override-restore'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.overrideRestoreTitle('2034')), findsOneWidget);
      await tester.tap(key('restore-estimate-cancel'));
      await tester.pumpAndSettle();
      verifyNever(
        () => ui.actions.restoreEstimate(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          wine: any(named: 'wine'),
        ),
      );
      await tester.tap(key('override-restore'));
      await tester.pumpAndSettle();
      await tester.tap(key('restore-estimate-confirm'));
      await tester.pumpAndSettle();
      verify(
        () => ui.actions.restoreEstimate(
          cellar: ownerCellar,
          user: cellarOwner,
          wine: corrected,
        ),
      ).called(1);
      expect(find.text(l10n.overrideRestored), findsOneWidget);
    });

    testWidgets('a failed restore says so', (tester) async {
      stubRestore(false);
      await openDetail(tester, corrected);
      await tester.ensureVisible(key('override-restore'));
      await tester.tap(key('override-restore'));
      await tester.pumpAndSettle();
      await tester.tap(key('restore-estimate-confirm'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.saveFailed), findsOneWidget);
    });

    testWidgets('a reader sees the correction, never the commands', (
      tester,
    ) async {
      const reader = AccessibleCellar(
        cellarId: 'user-a',
        ownerId: 'user-a',
        ownerName: 'A',
        role: CellarRole.read,
      );
      await openDetail(tester, corrected, cellar: reader);
      expect(find.text(l10n.overrideCorrectedByYou), findsOneWidget);
      expect(key('override-correct'), findsNothing);
      expect(key('override-restore'), findsNothing);
    });

    testWidgets('the level saved is shown in the ideal moment (FR4.4)', (
      tester,
    ) async {
      await openDetail(
        tester,
        cellarWine(
          'w1',
          window: base,
          baseWindow: base,
          level: WineLevel.aging,
        ),
      );
      expect(find.text(l10n.levelDetail(l10n.levelAging)), findsOneWidget);
    });
  });
}
