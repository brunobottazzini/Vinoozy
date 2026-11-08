// CellarScreen of u4-cellar (BR1.7, BR1.8, BR1.10; NFR2.1, NFR3.1-NFR3.4):
// the wines still in the cellar with status and confidence, search and
// filters, the quick "Drunk" with "Undo", the archive, in it, en and pt-BR.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/ui/archived_wines_screen.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/cellar/ui/wine_detail_screen.dart';

import '../../helpers/ui_harness.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

void main() {
  late CellarUi ui;

  setUp(() => ui = CellarUi());

  Future<void> pump(
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
    ui.emitCellar();
  }

  final cellar = [
    cellarWine('w1', name: 'Barolo', window: windowOf(2024, 2028, 2034)),
    cellarWine(
      'w2',
      name: 'Soave',
      producer: 'Pieropan',
      wineType: 'white',
      window: windowOf(2030, 2031, 2033),
    ),
    cellarWine('w3', name: 'Vino rosso', wineType: null, producer: null),
  ];

  Finder inRow(String id, String text) =>
      find.descendant(of: find.byKey(ValueKey(id)), matching: find.text(text));

  testWidgets('BR1.7 every row: vintage, quantity, status with icon and text, '
      'confidence', (tester) async {
    await pump(tester);
    ui.emitWines(cellar);
    await tester.pumpAndSettle();

    // The status labels are the Dashboard ones (u5 statusLabel), shown in
    // the ux-redesign StateChip with a capital letter.
    expect(inRow('w1', 'Pronte'), findsOneWidget);
    expect(inRow('w1', 'Fiducia: media'), findsOneWidget);
    expect(inRow('w1', '× 2'), findsOneWidget);
    expect(inRow('w2', 'Da aspettare'), findsOneWidget);
    expect(inRow('w3', 'Da stimare'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('w1')),
        matching: find.byIcon(Icons.check_circle_outline),
      ),
      findsOneWidget,
    );
  });

  testWidgets('BR1.7 empty from the server: the invitation at once; from the '
      'cache: "syncing" until the server answers', (tester) async {
    await pump(tester);
    ui.emitWines(const [], meta: cacheMeta);
    await tester.pump();
    expect(find.byKey(const Key('cellar-empty')), findsNothing);
    expect(find.byKey(const Key('cellar-syncing')), findsOneWidget);
    expect(find.byKey(const Key('cellar-loading')), findsNothing);

    ui.emitWines(const []);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cellar-empty')), findsOneWidget);
  });

  testWidgets('BR1.7 R-03 offline, an empty list from the cache shows the '
      'invitation after 2 seconds, never an endless loading', (tester) async {
    await pump(tester);
    ui.emitWines(const [], meta: cacheMeta);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1999));
    expect(find.byKey(const Key('cellar-syncing')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byKey(const Key('cellar-empty')), findsOneWidget);
    expect(find.text('Sincronizzazione della cantina…'), findsNothing);
    expect(
      tester
          .widget<FloatingActionButton>(
            find.byKey(const Key('cellar-add-button')),
          )
          .onPressed,
      isNotNull,
    );

    // A wine arrives later and the list shows it; empty again from the
    // cache starts a new wait.
    ui.emitWines([cellarWine('w1')], meta: cacheMeta);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('w1')), findsOneWidget);
    ui.emitWines(const [], meta: cacheMeta);
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('cellar-syncing')), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('cellar-empty')), findsOneWidget);
  });

  testWidgets('BR1.8 search by producer, ignoring case and accents', (
    tester,
  ) async {
    await pump(tester);
    ui.emitWines(cellar);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('cellar-search')), 'PIÉROPAN');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('w2')), findsOneWidget);
    expect(find.byKey(const ValueKey('w1')), findsNothing);
  });

  testWidgets('BR1.8 status and type filters, no match and "Azzera filtri"', (
    tester,
  ) async {
    await pump(tester);
    ui.emitWines(cellar);
    await tester.pumpAndSettle();

    final toEstimate = find.byKey(const Key('cellar-filter-status-toEstimate'));
    await tester.ensureVisible(toEstimate);
    await tester.tap(toEstimate);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('w3')), findsOneWidget);
    expect(find.byKey(const ValueKey('w1')), findsNothing);

    await tester.ensureVisible(
      find.byKey(const Key('cellar-filter-type-white')),
    );
    await tester.tap(find.byKey(const Key('cellar-filter-type-white')));
    await tester.pumpAndSettle();
    expect(find.text('Nessun vino con questi filtri'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cellar-clear-filters')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('w1')), findsOneWidget);
    expect(find.byKey(const ValueKey('w3')), findsOneWidget);
  });

  testWidgets('BR1.10 the quick "Bevuta", then "Annulla"', (tester) async {
    await pump(tester);
    ui.emitWines(cellar);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('wine-tile-drink-w1')));
    await tester.pumpAndSettle();
    // ux-redesign FR2.2: nothing is written before the confirmation.
    verifyNever(
      () => ui.actions.drink(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
        rating: any(named: 'rating'),
      ),
    );
    await tester.tap(find.byKey(const Key('drink-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Bevuta segnata: Barolo'), findsOneWidget);

    await tester.tap(find.byKey(const Key('drink-undo')));
    await tester.pump();
    verify(
      () => ui.actions.undoDrink(
        cellar: any(named: 'cellar'),
        user: cellarOwner,
        wine: any(named: 'wine'),
        recordId: 'r-new',
      ),
    ).called(1);
  });

  testWidgets('BR1.10 "Non c\'è più nulla da annullare"', (tester) async {
    when(
      () => ui.actions.undoDrink(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
        recordId: any(named: 'recordId'),
      ),
    ).thenAnswer((_) async => UndoResult.nothingToUndo);
    await pump(tester);
    ui.emitWines(cellar);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('wine-tile-drink-w1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drink-confirm')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drink-undo')));
    await tester.pumpAndSettle();

    expect(find.text("Non c'è più nulla da annullare"), findsOneWidget);
  });

  testWidgets('a row opens the detail', (tester) async {
    await pump(tester);
    ui.emitWines(cellar);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Soave 2016'));
    await tester.pumpAndSettle();

    expect(find.byType(WineDetailScreen), findsOneWidget);
  });

  testWidgets('BR1.7 "Bevuti" reads the finished wines only when opened', (
    tester,
  ) async {
    when(() => ui.wines.fetchArchived('user-a')).thenAnswer(
      (_) async => [cellarWine('w9', name: 'Vermentino', quantity: 0)],
    );
    await pump(tester);
    ui.emitWines(cellar);
    await tester.pumpAndSettle();
    verifyNever(() => ui.wines.fetchArchived(any()));

    await tester.tap(find.byKey(const Key('cellar-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cellar-archive')));
    await tester.pumpAndSettle();

    expect(find.byType(ArchivedWinesScreen), findsOneWidget);
    expect(find.text('Vermentino'), findsOneWidget);
    verify(() => ui.wines.fetchArchived('user-a')).called(1);
  });

  testWidgets('the archive: empty and error with "Riprova"', (tester) async {
    var fail = true;
    when(() => ui.wines.fetchArchived('user-a')).thenAnswer((_) async {
      if (fail) throw StateError('offline');
      return [];
    });
    await pumpScreen(
      tester,
      const ArchivedWinesScreen(user: cellarOwner, cellar: ownerCellar),
      overrides: ui.overrides,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('archive-error')), findsOneWidget);

    fail = false;
    await tester.tap(find.byKey(const Key('archive-retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('archive-empty')), findsOneWidget);
  });

  for (final (locale, search, toEstimate) in [
    (const Locale('en'), 'Search by name or producer', 'To estimate'),
    (const Locale('pt', 'BR'), 'Buscar por nome ou produtor', 'A estimar'),
  ]) {
    testWidgets('BR1.8 labels in ${locale.toLanguageTag()}', (tester) async {
      await pump(tester, locale: locale);
      ui.emitWines(cellar);
      await tester.pumpAndSettle();

      expect(find.text(search), findsWidgets);
      expect(inRow('w3', toEstimate), findsOneWidget);
    });
  }

  accessibilityMatrix(
    'CellarScreen',
    () => const CellarScreen(
      user: cellarOwner,
      setup: CellarSetup.ready,
      onRetrySetup: _noRetry,
    ),
    overrides: () {
      ui = CellarUi();
      return ui.overrides;
    },
    afterPump: (tester) async {
      ui
        ..emitCellar()
        ..emitWines(cellar);
      await tester.pumpAndSettle();
    },
  );
}

Future<void> _noRetry() async {}
