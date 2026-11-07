// WineDetailScreen (BR1.9, BR1.10, BR1.12, BR1.14, BR1.19, BR1.20; NFR2.2,
// NFR3.1-NFR3.4): window, status, confidence, source and the fixed notice,
// pairings, commands by permission, the duplicate banner, in three
// languages.
import 'dart:async';

import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/domain/window_adjuster.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/cellar/ui/drinking_record_sheet.dart';
import 'package:vinoozy/cellar/ui/edit_wine_screen.dart';
import 'package:vinoozy/cellar/ui/wine_detail_screen.dart';
import 'package:vinoozy/sharing/domain/membership.dart';

import '../../helpers/ui_harness.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

void main() {
  late CellarUi ui;

  setUp(() => ui = CellarUi());

  final base = windowOf(2024, 2028, 2034);
  final barolo = cellarWine(
    'w1',
    name: 'Barolo',
    denomination: 'Barolo DOCG',
    window: base,
    baseWindow: base,
    matchKey: 'barolo|cantina esempio|2016',
    pairings: const Pairings(
      items: [],
      categoryKeys: [PairingCategory.game, PairingCategory.agedCheese],
      source: WindowSource.internalRules,
    ),
  );

  /// The detail of [wine], listed in the cellar unless [listed] is false.
  Future<void> pump(
    WidgetTester tester, {
    Wine? wine,
    AccessibleCellar cellar = ownerCellar,
    bool listed = true,
    Locale locale = const Locale('it'),
  }) async {
    final shown = wine ?? barolo;
    if (!listed) {
      when(() => ui.wines.watchWine('user-a', shown.id))
          .thenAnswer((_) => Stream.value(shown));
    }
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const Key('open-detail'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WineDetailScreen(
                    user: cellarOwner,
                    cellar: cellar,
                    wineId: shown.id,
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      overrides: ui.overrides,
      locale: locale,
    );
    await tester.tap(find.byKey(const Key('open-detail')));
    await tester.pump();
    // The detail opens the shared wines listener; the snapshot follows.
    ui.emitWines(listed ? [shown] : const []);
    await tester.pumpAndSettle();
  }

  Finder key(String value) => find.byKey(Key(value));

  testWidgets('BR1.9 window, status, confidence, source, notice, pairings', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Inizio: 2024'), findsOneWidget);
    expect(find.text('Picco: 2028'), findsOneWidget);
    expect(find.text('Fine: 2034'), findsOneWidget);
    expect(find.text('pronte'), findsOneWidget);
    expect(find.text('Fiducia: media'), findsOneWidget);
    expect(find.text('Fonte: stima per tipologia'), findsOneWidget);
    expect(
      find.text(
        'Stima indicativa: dipende anche da come è stata conservata la '
        'bottiglia',
      ),
      findsOneWidget,
    );
    expect(find.text('• Selvaggina'), findsOneWidget);
    expect(key('pairings-generic'), findsOneWidget);
    verifyNever(() => ui.wines.watchWine(any(), any()));
  });

  testWidgets('BR1.12 a feedback that moved the window: "stima corretta dalle '
      'tue bevute"', (tester) async {
    final adjusted = cellarWine(
      'w1',
      baseWindow: base,
      window: windowOf(2027, 2031, 2037, confidence: Confidence.low),
      adjustment: const WindowAdjustment(
        kind: DrinkCondition.tooYoung,
        year: 2026,
        recordId: 'r1',
      ),
    );
    await pump(tester, wine: adjusted);

    expect(find.text('Fonte: stima corretta dalle tue bevute'), findsOneWidget);
    expect(find.text('Fiducia: bassa'), findsOneWidget);
  });

  testWidgets('BR1.19 read only: no command; a missing window is computed '
      'and shown, never written', (tester) async {
    await pump(
      tester,
      wine: cellarWine('w2', name: 'Barolo', denomination: 'Barolo DOCG'),
      cellar: readCellar,
    );

    expect(key('window-none'), findsNothing);
    expect(find.textContaining('Inizio:'), findsOneWidget);
    for (final command in [
      'wine-drink',
      'wine-plus',
      'wine-minus',
      'wine-edit',
      'wine-delete',
    ]) {
      expect(key(command), findsNothing, reason: command);
    }
    // Shown from the list, computed in memory: no read, no write.
    verifyNever(() => ui.wines.watchWine(any(), any()));
    verifyZeroInteractions(ui.actions);
  });

  testWidgets(
    'BR1.9 a wine that cannot be estimated: "Stima non disponibile"',
    (tester) async {
      await pump(tester, wine: cellarWine('w3', name: ' ', vintage: null));

      expect(find.text('Stima non disponibile'), findsOneWidget);
      expect(find.text('Da stimare'), findsOneWidget);
    },
  );

  testWidgets('BR1.10 BR1.7 a finished wine: one document, "Bevuta" and "−" '
      'off, "Aggiungi di nuovo"', (tester) async {
    await pump(tester, wine: cellarWine('w4', quantity: 0), listed: false);

    verify(() => ui.wines.watchWine('user-a', 'w4')).called(1);
    expect(
      tester.widget<ButtonStyleButton>(key('wine-drink')).onPressed,
      isNull,
    );
    expect(tester.widget<IconButton>(key('wine-minus')).onPressed, isNull);
    expect(find.text('Finito: nessuna bottiglia'), findsOneWidget);

    await tester.tap(key('wine-add-again'));
    await tester.pumpAndSettle();
    expect(find.byType(AddWineScreen), findsOneWidget);
  });

  testWidgets('BR1.10 "Bevuta", then "Aggiungi voto e note" opens the sheet', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(key('wine-drink'));
    await tester.pumpAndSettle();
    await tester.tap(key('drink-add-notes'));
    await tester.pumpAndSettle();

    expect(find.byType(DrinkingRecordSheet), findsOneWidget);
  });

  testWidgets('BR1.15 "+" and "−" change the quantity by one', (tester) async {
    await pump(tester);

    await tester.tap(key('wine-plus'));
    await tester.tap(key('wine-minus'));
    await tester.pump();

    verify(
      () => ui.actions.addBottles(
        cellar: ownerCellar,
        user: cellarOwner,
        wine: any(named: 'wine'),
        n: 1,
      ),
    ).called(1);
    verify(
      () => ui.actions.removeBottle(
        cellar: ownerCellar,
        user: cellarOwner,
        wine: any(named: 'wine'),
      ),
    ).called(1);
  });

  testWidgets('BR1.3 R-05 "+" is off at 99 bottles', (tester) async {
    await pump(tester, wine: cellarWine('w5', quantity: 99));

    expect(tester.widget<IconButton>(key('wine-plus')).onPressed, isNull);
    expect(tester.widget<IconButton>(key('wine-minus')).onPressed, isNotNull);
  });

  testWidgets('BR1.13 "Modifica" opens the edit form', (tester) async {
    await pump(tester);

    await tester.ensureVisible(key('wine-edit'));
    await tester.tap(key('wine-edit'));
    await tester.pumpAndSettle();

    expect(find.byType(EditWineScreen), findsOneWidget);
  });

  testWidgets('BR1.14 "Elimina" (owner only) asks with the name, then deletes '
      'and closes', (tester) async {
    await pump(tester);

    await tester.ensureVisible(key('wine-delete'));
    await tester.tap(key('wine-delete'));
    await tester.pumpAndSettle();
    expect(find.text('Eliminare Barolo?'), findsOneWidget);
    await tester.tap(key('delete-confirm'));
    await tester.pumpAndSettle();

    verify(
      () => ui.actions.deleteWine(
        cellar: ownerCellar,
        user: cellarOwner,
        wine: any(named: 'wine'),
      ),
    ).called(1);
    expect(find.byType(WineDetailScreen), findsNothing);
  });

  testWidgets('BR1.14 an edit member has no "Elimina"', (tester) async {
    await pump(tester, cellar: editCellar);

    expect(key('wine-edit'), findsOneWidget);
    expect(key('wine-delete'), findsNothing);
  });

  group('BR1.20 possible duplicate', () {
    final older = cellarWine('old', createdAt: DateTime.utc(2026, 1));

    testWidgets('BR1.20 the owner merges when the newer entry has no drinks', (
      tester,
    ) async {
      ui.duplicates = [older, barolo];
      await pump(tester);

      expect(find.text('Possibile doppione'), findsOneWidget);
      await tester.tap(key('duplicate-merge'));
      await tester.pumpAndSettle();
      await tester.tap(key('merge-confirm'));
      await tester.pumpAndSettle();

      verify(
        () => ui.actions.merge(
          cellar: ownerCellar,
          user: cellarOwner,
          older: older,
          newer: barolo,
        ),
      ).called(1);
      expect(find.byType(WineDetailScreen), findsNothing);
    });

    testWidgets('BR1.20 with drinks on the newer: only the hint', (
      tester,
    ) async {
      ui
        ..duplicates = [older, barolo]
        ..newerHasDrinks = true;
      await pump(tester);

      expect(key('duplicate-merge'), findsNothing);
      expect(find.text('Elimina questa voce se è un doppione'), findsOneWidget);
    });

    testWidgets('BR1.20 an edit member sees the banner without "Unisci"', (
      tester,
    ) async {
      ui.duplicates = [older, barolo];
      await pump(tester, cellar: editCellar);

      expect(key('duplicate-banner'), findsOneWidget);
      expect(key('duplicate-merge'), findsNothing);
    });
  });

  testWidgets('BR1.9 the last drinks, with rating, condition and notes', (
    tester,
  ) async {
    ui.drinks = [
      drinkRecord(
        'r1',
        rating: 4,
        notes: 'Ottimo con il brasato',
        condition: DrinkCondition.justRight,
      ),
    ];
    await pump(tester);
    await tester.scrollUntilVisible(key('wine-drink-r1'), 200);

    expect(find.textContaining('Voto 4 su 5'), findsOneWidget);
    expect(find.textContaining('Al punto giusto'), findsOneWidget);
    expect(find.textContaining('Ottimo con il brasato'), findsOneWidget);
  });

  for (final (locale, source, notice) in [
    (
      const Locale('en'),
      'Source: estimate for the type',
      'Indicative estimate: it also depends on how the bottle was stored',
    ),
    (
      const Locale('pt', 'BR'),
      'Fonte: estimativa por tipo',
      'Estimativa indicativa: depende também de como a garrafa foi guardada',
    ),
  ]) {
    testWidgets('BR1.9 the estimate in ${locale.toLanguageTag()}', (
      tester,
    ) async {
      await pump(tester, locale: locale);

      expect(find.text(source), findsOneWidget);
      expect(find.text(notice), findsOneWidget);
    });
  }

  accessibilityMatrix(
    'WineDetailScreen',
    () =>
        WineDetailScreen(user: cellarOwner, cellar: ownerCellar, wineId: 'w1'),
    overrides: () {
      ui = CellarUi()
        ..duplicates = [cellarWine('old'), barolo]
        ..drinks = [drinkRecord('r1', rating: 5, notes: 'Splendido')];
      return ui.overrides;
    },
    afterPump: (tester) async {
      ui.emitWines([barolo]);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('a wine that no longer exists says so', (tester) async {
    final gone = StreamController<Wine?>();
    when(() => ui.wines.watchWine('user-a', 'gone'))
        .thenAnswer((_) => gone.stream);
    await pumpScreen(
      tester,
      const WineDetailScreen(
        user: cellarOwner,
        cellar: ownerCellar,
        wineId: 'gone',
      ),
      overrides: ui.overrides,
    );
    ui.emitWines(const []);
    await tester.pump();
    expect(key('wine-detail-loading'), findsOneWidget);

    gone.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Questo vino non esiste più'), findsOneWidget);

    gone.addError(StateError('denied'));
    await tester.pumpAndSettle();
    await gone.close();
  });
}
