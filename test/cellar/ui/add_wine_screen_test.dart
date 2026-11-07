// AddWineScreen of u4-cellar (BR1.1-BR1.4, BR1.15, BR1.18; NFR1.1, NFR1.2,
// NFR3.4): suggestions after 250 ms, the minimal path in 3 taps, the new
// producer, the duplicate dialog, in it, en and pt-BR.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';

import '../../helpers/ui_harness.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

void main() {
  late CellarUi ui;
  late List<WineDraft> saved;
  late AddResult result;

  setUp(() {
    ui = CellarUi();
    saved = [];
    result = AddSaved(cellarWine('wine-1'));
    when(
      () => ui.actions.saveNewWine(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((invocation) async {
      saved.add(invocation.namedArguments[#draft] as WineDraft);
      return result;
    });
    ui.catalog.internal = const [
      WineCandidate(
        name: 'Barolo',
        producer: 'Cantina Esempio',
        vintage: 2016,
        wineType: CatalogWineType.red,
        denomination: 'Barolo DOCG',
        region: 'Piemonte',
        source: CandidateSource.internal,
      ),
    ];
  });

  /// The form opened from the Cellar, as the user does.
  Future<void> openFromCellar(
    WidgetTester tester, {
    Locale locale = const Locale('it'),
  }) async {
    await pumpScreen(
      tester,
      const CellarScreen(
        user: cellarOwner,
        setup: CellarSetup.ready,
        onRetrySetup: _noRetry,
      ),
      overrides: ui.overrides,
      locale: locale,
    );
    ui
      ..emitCellar()
      ..emitWines([cellarWine('w1', name: 'Soave', producer: 'Pieropan')]);
    await tester.pumpAndSettle();
  }

  Finder key(String value) => find.byKey(Key(value));

  testWidgets('BR1.18 NFR1.1 the minimal path: "Aggiungi", a proposal, '
      '"Salva" (3 taps)', (tester) async {
    await openFromCellar(tester);
    var taps = 0;

    await tester.tap(key('cellar-add-button'));
    taps++;
    await tester.pumpAndSettle();
    final name = tester.widget<TextField>(key('add-wine-name-field'));
    expect(name.autofocus, isTrue, reason: 'the name is active at opening');

    await tester.enterText(key('add-wine-name-field'), 'Bar');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(key('add-wine-suggestion-0'));
    taps++;
    await tester.pumpAndSettle();
    await tester.tap(key('add-wine-save-button'));
    taps++;
    await tester.pumpAndSettle();

    expect(taps, 3);
    final draft = saved.single;
    expect(draft.name, 'Barolo');
    expect(draft.producer, 'Cantina Esempio');
    expect(draft.vintage, 2016);
    expect(draft.wineType, 'redStructured');
    expect(draft.denomination, 'Barolo DOCG');
    expect(draft.region, 'Piemonte');
    expect(find.byType(AddWineScreen), findsNothing, reason: 'back at once');
  });

  testWidgets('BR1.1 no suggestion before the third character', (tester) async {
    await openFromCellar(tester);
    await tester.tap(key('cellar-add-button'));
    await tester.pumpAndSettle();

    await tester.enterText(key('add-wine-name-field'), 'Ba');
    await tester.pump(const Duration(seconds: 1));

    expect(key('add-wine-suggestions'), findsNothing);
    expect(ui.catalog.suggestQueries, isEmpty);
    expect(ui.catalog.lastCellarWines, isNull);
  });

  testWidgets('BR1.2 known producers and "Aggiungi «testo» come nuovo '
      'produttore"', (tester) async {
    await openFromCellar(tester);
    await tester.tap(key('cellar-add-button'));
    await tester.pumpAndSettle();

    await tester.tap(key('add-wine-producer'));
    await tester.enterText(key('add-wine-producer'), 'Pier');
    await tester.pumpAndSettle();

    expect(find.text('Pieropan'), findsOneWidget);
    expect(find.text('Aggiungi «Pier» come nuovo produttore'), findsOneWidget);
    await tester.tap(key('add-wine-new-producer'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(key('add-wine-producer')).controller!.text,
      'Pier',
    );
  });

  testWidgets('BR1.3 a producer over 120 characters shows its error', (
    tester,
  ) async {
    await openFromCellar(tester);
    await tester.tap(key('cellar-add-button'));
    await tester.pumpAndSettle();

    await tester.enterText(key('add-wine-name-field'), 'Barolo');
    await tester.enterText(key('add-wine-producer'), 'p' * 121);
    await tester.tap(key('add-wine-no-vintage-switch'));
    await tester.ensureVisible(key('add-wine-save-button'));
    await tester.tap(key('add-wine-save-button'));
    await tester.pumpAndSettle();

    expect(find.text('Al massimo 120 caratteri'), findsOneWidget);
    expect(saved, isEmpty);
  });

  group('BR1.4 duplicates', () {
    final existing = cellarWine('old', name: 'Barolo', quantity: 0);

    Future<void> saveDuplicate(WidgetTester tester) async {
      result = AddDuplicate(existing);
      await openFromCellar(tester);
      await tester.tap(key('cellar-add-button'));
      await tester.pumpAndSettle();
      await tester.enterText(key('add-wine-name-field'), 'Barolo');
      await tester.enterText(key('add-wine-vintage-field'), '2016');
      await tester.ensureVisible(key('add-wine-save-button'));
      await tester.tap(key('add-wine-save-button'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'BR1.4 BR1.15 confirming adds the bottles to the finished wine',
      (tester) async {
        await saveDuplicate(tester);

        expect(key('duplicate-dialog'), findsOneWidget);
        expect(find.textContaining('nessuna bottiglia'), findsOneWidget);
        await tester.tap(key('duplicate-confirm'));
        await tester.pumpAndSettle();

        verify(
          () => ui.actions.addBottles(
            cellar: any(named: 'cellar'),
            user: cellarOwner,
            wine: existing,
            n: 1,
          ),
        ).called(1);
        expect(find.byType(AddWineScreen), findsNothing);
      },
    );

    testWidgets('BR1.3 R-05 the bottles added stop at 99 in all', (
      tester,
    ) async {
      result = AddDuplicate(cellarWine('old', name: 'Barolo', quantity: 98));
      await openFromCellar(tester);
      await tester.tap(key('cellar-add-button'));
      await tester.pumpAndSettle();
      await tester.enterText(key('add-wine-name-field'), 'Barolo');
      await tester.enterText(key('add-wine-vintage-field'), '2016');
      for (var i = 0; i < 2; i++) {
        await tester.tap(key('quantity-increase-button'));
        await tester.pump();
      }
      await tester.ensureVisible(key('add-wine-save-button'));
      await tester.tap(key('add-wine-save-button'));
      await tester.pumpAndSettle();

      expect(find.text('Aggiungi 1 bottiglia'), findsOneWidget);
      await tester.tap(key('duplicate-confirm'));
      await tester.pumpAndSettle();
      verify(
        () => ui.actions.addBottles(
          cellar: any(named: 'cellar'),
          user: cellarOwner,
          wine: any(named: 'wine'),
          n: 1,
        ),
      ).called(1);
    });

    testWidgets('BR1.4 cancelling goes back to the form with its data', (
      tester,
    ) async {
      await saveDuplicate(tester);

      await tester.tap(key('duplicate-cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AddWineScreen), findsOneWidget);
      expect(
        tester.widget<TextField>(key('add-wine-name-field')).controller!.text,
        'Barolo',
      );
      verifyNever(
        () => ui.actions.addBottles(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          wine: any(named: 'wine'),
          n: any(named: 'n'),
        ),
      );
    });

    testWidgets('a failed addition keeps the form with "Impossibile salvare"', (
      tester,
    ) async {
      when(
        () => ui.actions.addBottles(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          wine: any(named: 'wine'),
          n: any(named: 'n'),
        ),
      ).thenAnswer((_) async => SaveFailure(StateError('ledger')));
      await saveDuplicate(tester);
      await tester.tap(key('duplicate-confirm'));
      await tester.pumpAndSettle();

      expect(key('add-wine-save-failed'), findsOneWidget);
    });
  });

  testWidgets('BR1.16 "Aggiungi di nuovo" fills the form with the wine', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      AddWineScreen(
        user: cellarOwner,
        cellarId: 'user-a',
        cellar: ownerCellar,
        prefill: cellarWine(
          'w9',
          name: 'Vermentino',
          producer: 'Cantina Sarda',
          vintage: null,
          wineType: 'white',
        ),
      ),
      overrides: ui.overrides,
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(key('add-wine-name-field')).controller!.text,
      'Vermentino',
    );
    expect(
      tester.widget<SwitchListTile>(key('add-wine-no-vintage-switch')).value,
      isTrue,
    );
    expect(find.text('Bianco'), findsOneWidget);
  });

  for (final (locale, title, body) in [
    (const Locale('en'), 'Already in the cellar', 'no bottles'),
    (const Locale('pt', 'BR'), 'Já está na adega', 'nenhuma garrafa'),
  ]) {
    testWidgets('BR1.4 the duplicate dialog in ${locale.toLanguageTag()}', (
      tester,
    ) async {
      result = AddDuplicate(cellarWine('old', quantity: 0));
      await openFromCellar(tester, locale: locale);
      await tester.tap(key('cellar-add-button'));
      await tester.pumpAndSettle();
      await tester.enterText(key('add-wine-name-field'), 'Barolo');
      await tester.tap(key('add-wine-no-vintage-switch'));
      await tester.ensureVisible(key('add-wine-save-button'));
      await tester.tap(key('add-wine-save-button'));
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
      expect(find.textContaining(body), findsOneWidget);
    });
  }

  accessibilityMatrix(
    'AddWineScreen (u4) with suggestions',
    () => const AddWineScreen(
      user: cellarOwner,
      cellarId: 'user-a',
      cellar: ownerCellar,
    ),
    overrides: () {
      ui = CellarUi();
      ui.catalog.internal = const [
        WineCandidate(name: 'Barolo', source: CandidateSource.internal),
      ];
      return ui.overrides;
    },
    afterPump: (tester) async {
      await tester.enterText(
        find.byKey(const Key('add-wine-name-field')),
        'Bar',
      );
      await tester.pump(const Duration(milliseconds: 700));
    },
  );
}

Future<void> _noRetry() async {}
