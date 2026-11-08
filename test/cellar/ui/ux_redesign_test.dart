// ux-redesign widgets (FR1.1-FR1.4, FR2.1-FR2.4, FR3.2, FR3.4; NFR1;
// interaction-spec.md; accessibility-checklist.md A2-A7): country grid,
// every-country sheet, region chips, wine cards of the 5 families, the
// "I drank one" confirmation, the ideal moment card, "remove a bottle
// without a drink", the History rows and the label proposal, in it, en and
// pt-BR with text 1.0 / 2.0 and light / dark theme.
import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/app/ui/country_flag.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/domain/cellar_filter.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_estimate.dart';
import 'package:vinoozy/cellar/domain/wine_origins.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/cellar/ui/drink_confirm_sheet.dart';
import 'package:vinoozy/cellar/ui/history_screen.dart';
import 'package:vinoozy/cellar/ui/ideal_moment_card.dart';
import 'package:vinoozy/cellar/ui/origin_pickers.dart';
import 'package:vinoozy/cellar/ui/wine_badges.dart';
import 'package:vinoozy/cellar/ui/wine_card.dart';
import 'package:vinoozy/cellar/ui/wine_detail_screen.dart';
import 'package:vinoozy/label/ui/label_proposal_sheet.dart';

import '../../helpers/firestore_mocks.dart';
import '../../helpers/ui_harness.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

void main() {
  late CellarUi ui;

  setUpAll(() => registerFallbackValue(MockDocSnapshot()));

  setUp(() => ui = CellarUi());

  Finder key(String value) => find.byKey(Key(value));

  /// A host keeping the chosen country and region, as the forms do.
  Widget originHost({
    String? country,
    String? region,
    void Function(OriginSelection selection)? onSelection,
  }) {
    var selection = OriginSelection(country: country, region: region);
    return Scaffold(
      body: StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CountryPicker(
                selected: selection.country,
                onChanged: (code) => setState(() {
                  selection = selection.withCountry(code);
                  onSelection?.call(selection);
                }),
              ),
              RegionPicker(
                country: selection.country,
                selected: selection.region,
                onChanged: (value) => setState(() {
                  selection = selection.withRegion(value);
                  onSelection?.call(selection);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('FR1.1 CountryPicker', () {
    testWidgets('21 flags in the order of the specification, then "Altro '
        'paese…", each read with the country name (A3)', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, originHost(), overrides: ui.overrides);

      Offset at(String code) => tester.getTopLeft(key('country-cell-$code'));
      final codes = WineOrigins.wineCountryCodes;
      expect(codes, hasLength(21));
      for (var i = 1; i < codes.length; i++) {
        final previous = at(codes[i - 1]);
        final current = at(codes[i]);
        final inOrder =
            current.dy > previous.dy ||
            (current.dy == previous.dy && current.dx > previous.dx);
        expect(inOrder, isTrue, reason: '${codes[i - 1]} before ${codes[i]}');
      }
      for (final code in codes) {
        expect(
          find.descendant(
            of: key('country-cell-$code'),
            matching: key('flag-$code'),
          ),
          findsOneWidget,
        );
      }
      expect(key('country-other'), findsOneWidget);
      expect(find.bySemanticsLabel('Italia'), findsOneWidget);
      expect(find.bySemanticsLabel('Nuova Zelanda'), findsOneWidget);
      expect(find.bySemanticsLabel('Altro paese…'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a tap saves the ISO code; a second tap clears it; a new '
        'country clears the region (R-06)', (tester) async {
      final seen = <OriginSelection>[];
      await pumpScreen(
        tester,
        originHost(country: 'IT', region: 'Piemonte', onSelection: seen.add),
        overrides: ui.overrides,
      );

      await tester.tap(key('country-cell-AR'));
      await tester.pumpAndSettle();
      expect(seen.last, const OriginSelection(country: 'AR'));

      await tester.tap(key('country-cell-AR'));
      await tester.pumpAndSettle();
      expect(seen.last, const OriginSelection());
    });

    testWidgets('cells are at least 48 × 48 dp (A4)', (tester) async {
      await pumpScreen(tester, originHost(), overrides: ui.overrides);

      for (final code in ['IT', 'ZA']) {
        final size = tester.getSize(key('country-cell-$code'));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    });
  });

  group('FR1.1 AllCountriesSheet', () {
    testWidgets('"marian" finds the Northern Mariana Islands; the choice '
        'goes first in the grid', (tester) async {
      final seen = <OriginSelection>[];
      await pumpScreen(
        tester,
        originHost(onSelection: seen.add),
        overrides: ui.overrides,
      );

      await tester.ensureVisible(key('country-other'));
      await tester.tap(key('country-other'));
      await tester.pumpAndSettle();
      expect(find.text('Tutti i paesi e territori'), findsWidgets);
      expect(find.text('Rari per il vino'), findsOneWidget);
      expect(key('all-countries-rare-JP'), findsOneWidget);

      await tester.enterText(key('all-countries-search'), 'marian');
      await tester.pumpAndSettle();
      expect(find.text('Rari per il vino'), findsNothing);
      expect(find.text('Isole Marianne Settentrionali'), findsOneWidget);
      expect(find.text('MP · Northern Mariana Islands'), findsOneWidget);

      await tester.tap(key('all-countries-row-MP'));
      await tester.pumpAndSettle();
      expect(seen.last.country, 'MP');
      expect(
        tester.getTopLeft(key('country-cell-MP')).dy,
        lessThanOrEqualTo(tester.getTopLeft(key('country-cell-IT')).dy),
      );
      expect(key('region-other'), findsOneWidget, reason: 'no listed region');
    });

    testWidgets('the search works in English and Portuguese, and says when '
        'nothing matches', (tester) async {
      await pumpScreen(
        tester,
        originHost(),
        overrides: ui.overrides,
        locale: const Locale('en'),
      );
      await tester.ensureVisible(key('country-other'));
      await tester.tap(key('country-other'));
      await tester.pumpAndSettle();

      await tester.enterText(key('all-countries-search'), 'Japão');
      await tester.pumpAndSettle();
      expect(key('all-countries-row-JP'), findsOneWidget);
      expect(find.text('Japan'), findsOneWidget);

      await tester.enterText(key('all-countries-search'), 'qwxz');
      await tester.pumpAndSettle();
      expect(key('all-countries-none'), findsOneWidget);
      expect(find.text('No country found'), findsOneWidget);
    });
  });

  group('FR1.2 RegionPicker', () {
    testWidgets('Italy: the 20 regions and "Altra regione"', (tester) async {
      final seen = <OriginSelection>[];
      await pumpScreen(
        tester,
        originHost(country: 'IT', onSelection: seen.add),
        overrides: ui.overrides,
      );

      for (final region in WineOrigins.regionsOf('IT')) {
        expect(key('region-chip-${region.canonical}'), findsOneWidget);
      }
      expect(find.byType(ChoiceChip), findsNWidgets(21));
      expect(find.text('Regione · Italia'), findsOneWidget);

      await tester.ensureVisible(key("region-chip-Valle d'Aosta"));
      await tester.tap(key("region-chip-Valle d'Aosta"));
      await tester.pumpAndSettle();
      expect(seen.last.region, "Valle d'Aosta");
    });

    testWidgets('a New World country: Argentina with Mendoza', (tester) async {
      final seen = <OriginSelection>[];
      await pumpScreen(
        tester,
        originHost(country: 'AR', onSelection: seen.add),
        overrides: ui.overrides,
      );

      expect(find.text('Regione · Argentina'), findsOneWidget);
      for (final name in ['Mendoza', 'Salta', 'San Juan', 'Patagonia']) {
        expect(find.text(name), findsOneWidget);
      }
      await tester.ensureVisible(key('region-chip-Mendoza'));
      await tester.tap(key('region-chip-Mendoza'));
      await tester.pumpAndSettle();
      expect(
        seen.last,
        const OriginSelection(country: 'AR', region: 'Mendoza'),
      );
    });

    testWidgets('France is shown in Italian, saved with the canonical name '
        '(R-02)', (tester) async {
      final seen = <OriginSelection>[];
      await pumpScreen(
        tester,
        originHost(country: 'FR', onSelection: seen.add),
        overrides: ui.overrides,
      );

      expect(find.text('Borgogna'), findsOneWidget);
      await tester.ensureVisible(key('region-chip-Bourgogne'));
      await tester.tap(key('region-chip-Bourgogne'));
      await tester.pumpAndSettle();
      expect(seen.last.region, 'Bourgogne');
    });

    testWidgets('"Altra regione": free text, at most 120 characters', (
      tester,
    ) async {
      final seen = <OriginSelection>[];
      await pumpScreen(
        tester,
        originHost(country: 'IT', onSelection: seen.add),
        overrides: ui.overrides,
      );

      await tester.ensureVisible(key('region-other'));
      await tester.tap(key('region-other'));
      await tester.pumpAndSettle();
      await tester.enterText(key('region-free-field'), '  Langhe ');
      await tester.pumpAndSettle();
      expect(seen.last.region, 'Langhe');
      expect(find.text('Al massimo 120 caratteri'), findsNothing);

      await tester.enterText(key('region-free-field'), 'x' * 121);
      await tester.pumpAndSettle();
      expect(find.text('Al massimo 120 caratteri'), findsOneWidget);
    });

    testWidgets('without a country only "Altra regione"; a new country '
        'closes the free field', (tester) async {
      final seen = <OriginSelection>[];
      await pumpScreen(
        tester,
        originHost(onSelection: seen.add),
        overrides: ui.overrides,
      );

      expect(find.byType(ChoiceChip), findsOneWidget);
      expect(find.text('Regione'), findsOneWidget);
      await tester.ensureVisible(key('region-other'));
      await tester.tap(key('region-other'));
      await tester.pumpAndSettle();
      await tester.enterText(key('region-free-field'), 'Somewhere');
      await tester.pumpAndSettle();

      await tester.ensureVisible(key('country-cell-PT'));
      await tester.tap(key('country-cell-PT'));
      await tester.pumpAndSettle();
      expect(seen.last, const OriginSelection(country: 'PT'));
      expect(key('region-free-field'), findsNothing);
    });

    accessibilityMatrix(
      'CountryPicker and RegionPicker (Italy, Piemonte)',
      () => originHost(country: 'IT', region: 'Piemonte'),
      overrides: () => CellarUi().overrides,
    );
  });

  group('FR3.2 WineCard', () {
    final today = DateTime(2026, 11, 6);
    final families = [
      (
        WineTypeFamily.red,
        cellarWine(
          'red',
          name: 'Malbec',
          wineType: 'redStructured',
          country: 'AR',
          region: 'Mendoza',
          window: windowOf(2020, 2024, 2030),
        ),
        'Rosso',
      ),
      (
        WineTypeFamily.white,
        cellarWine(
          'white',
          name: 'Chablis',
          wineType: 'white',
          country: 'FR',
          region: 'Bourgogne',
          window: windowOf(2027, 2029, 2033),
        ),
        'Bianco',
      ),
      (
        WineTypeFamily.rose,
        cellarWine(
          'rose',
          name: 'Tavel',
          wineType: 'rose',
          country: 'FR',
          window: windowOf(2020, 2021, 2022),
        ),
        'Rosato',
      ),
      (
        WineTypeFamily.sparkling,
        cellarWine(
          'sparkling',
          name: 'Espumante Brut',
          wineType: 'sparklingClassic',
          country: 'BR',
          region: 'Serra Gaúcha',
          window: windowOf(2025, 2026, 2027),
        ),
        'Bollicine',
      ),
      (
        WineTypeFamily.sweet,
        cellarWine(
          'sweet',
          name: 'Porto Vintage',
          wineType: 'fortified',
          country: 'PT',
          region: 'Douro',
          window: windowOf(2030, 2040, 2060),
        ),
        'Dolce',
      ),
    ];

    Widget cards({AccessibleDrink drink = AccessibleDrink.allowed}) => Scaffold(
      body: ListView(
        children: [
          for (final (_, wine, _) in families)
            WineCard(
              wine: wine,
              status: wineStatusOn(wine, today),
              onTap: () {},
              onDrink: drink == AccessibleDrink.allowed ? () {} : null,
            ),
        ],
      ),
    );

    for (final (family, wine, name) in families) {
      testWidgets('${family.name}: icon, type name, flag and status', (
        tester,
      ) async {
        await pumpScreen(tester, cards(), overrides: ui.overrides);
        final card = key('wine-tile-${wine.id}');

        Finder inCard(Finder finder) =>
            find.descendant(of: card, matching: finder);
        expect(inCard(key('wine-type-badge-${family.name}')), findsOneWidget);
        expect(inCard(find.byIcon(wineFamilyIcon(family))), findsOneWidget);
        expect(inCard(find.text(name)), findsOneWidget);
        expect(inCard(key('flag-${wine.country}')), findsOneWidget);
        expect(
          inCard(key('state-chip-${wineStatusOn(wine, today).name}')),
          findsOneWidget,
        );
        expect(inCard(key('wine-card-band-${family.name}')), findsOneWidget);
      });
    }

    testWidgets('no country, no flag; an Italian region shows Italy (R-06)', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: Column(
            children: [
              WineCard(wine: cellarWine('plain', region: null)),
              WineCard(wine: cellarWine('old', region: 'toscana')),
            ],
          ),
        ),
        overrides: ui.overrides,
      );

      expect(
        find.descendant(
          of: key('wine-tile-plain'),
          matching: find.byType(CountryFlag),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: key('wine-tile-old'), matching: key('flag-IT')),
        findsOneWidget,
      );
    });

    testWidgets('FR2.1 "Ho bevuto": the verb, the glasses icon (not the '
        'Cellar bottle), at least 48 dp, off at 0 bottles, absent in read '
        'only', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: Column(
            children: [
              WineCard(wine: cellarWine('two'), onDrink: () {}),
              WineCard(wine: cellarWine('zero', quantity: 0), onDrink: () {}),
              WineCard(wine: cellarWine('reader')),
            ],
          ),
        ),
        overrides: ui.overrides,
      );

      final button = key('wine-tile-drink-two');
      expect(
        find.descendant(of: button, matching: find.text('Ho bevuto')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: button, matching: find.byIcon(drinkActionIcon)),
        findsOneWidget,
      );
      expect(drinkActionIcon, isNot(Icons.liquor));
      expect(drinkActionIcon, isNot(Icons.liquor_outlined));
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
      expect(
        tester
            .widget<ButtonStyleButton>(
              find.descendant(
                of: key('wine-tile-drink-zero'),
                matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
              ),
            )
            .onPressed,
        isNull,
      );
      expect(key('wine-tile-drink-reader'), findsNothing);
    });

    accessibilityMatrix(
      'WineCard of the 5 families',
      () => cards(),
      overrides: () => CellarUi().overrides,
    );
  });

  group('FR2.2 FR2.3 DrinkConfirmSheet', () {
    final barolo = cellarWine(
      'w1',
      name: 'Barolo',
      region: 'Piemonte',
      window: windowOf(2024, 2028, 2034),
    );

    Future<void> openSheet(WidgetTester tester, Wine wine) async {
      await pumpScreen(
        tester,
        const CellarScreen(
          user: cellarOwner,
          setup: CellarSetup.ready,
          onRetrySetup: _noRetry,
        ),
        overrides: ui.overrides,
      );
      ui
        ..emitCellar()
        ..emitWines([wine]);
      await tester.pumpAndSettle();
      await tester.tap(key('wine-tile-drink-${wine.id}'));
      await tester.pumpAndSettle();
    }

    void expectNoDrink() => verifyNever(
      () => ui.actions.drink(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
        rating: any(named: 'rating'),
      ),
    );

    testWidgets('the tap writes nothing: flag, name, vintage, "2 → 1" and '
        'five stars', (tester) async {
      final handle = tester.ensureSemantics();
      await openSheet(tester, barolo);

      expect(key('drink-confirm-sheet'), findsOneWidget);
      expect(find.text('Barolo 2016'), findsWidgets);
      expect(
        find.descendant(
          of: key('drink-confirm-sheet'),
          matching: key('flag-IT'),
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Bottiglie: da 2 a 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Conferma bevuta'), findsOneWidget);
      for (var star = 1; star <= 5; star++) {
        expect(key('drink-confirm-star-$star'), findsOneWidget);
      }
      expect(find.bySemanticsLabel('3 stelle su 5'), findsOneWidget);
      expectNoDrink();
      handle.dispose();
    });

    testWidgets('"Annulla" does nothing', (tester) async {
      await openSheet(tester, barolo);

      await tester.tap(key('drink-cancel'));
      await tester.pumpAndSettle();

      expect(key('drink-confirm-sheet'), findsNothing);
      expect(key('drink-snackbar'), findsNothing);
      expectNoDrink();
    });

    testWidgets('closing the sheet outside or with back does nothing', (
      tester,
    ) async {
      await openSheet(tester, barolo);
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(key('drink-confirm-sheet'), findsNothing);

      await tester.tap(key('wine-tile-drink-w1'));
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(key('drink-snackbar'), findsNothing);
      expectNoDrink();
    });

    testWidgets('confirming with 4 stars calls drink(rating: 4) once', (
      tester,
    ) async {
      await openSheet(tester, barolo);

      await tester.tap(key('drink-confirm-star-4'));
      await tester.pump();
      await tester.tap(key('drink-confirm'));
      await tester.pumpAndSettle();

      verify(
        () => ui.actions.drink(
          cellar: any(named: 'cellar'),
          user: cellarOwner,
          wine: any(named: 'wine'),
          rating: 4,
        ),
      ).called(1);
      expect(find.text('Bevuta segnata: Barolo'), findsOneWidget);
    });

    testWidgets('a star tapped twice clears the rating', (tester) async {
      await openSheet(tester, barolo);

      await tester.tap(key('drink-confirm-star-2'));
      await tester.pump();
      await tester.tap(key('drink-confirm-star-2'));
      await tester.pump();
      await tester.tap(key('drink-confirm'));
      await tester.pumpAndSettle();

      verify(
        () => ui.actions.drink(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          wine: any(named: 'wine'),
          rating: null,
        ),
      ).called(1);
    });

    testWidgets('the last bottle shows "1 → 0"', (tester) async {
      final handle = tester.ensureSemantics();
      await openSheet(tester, cellarWine('w9', name: 'Gavi', quantity: 1));

      expect(find.bySemanticsLabel('Bottiglie: da 1 a 0'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a wine without vintage and country: no flag, "Senza annata"', (
      tester,
    ) async {
      await openSheet(
        tester,
        cellarWine('nv', name: 'Spumante', vintage: null, producer: null),
      );

      expect(find.text('Spumante Senza annata'), findsWidgets);
      expect(
        find.descendant(
          of: key('drink-confirm-sheet'),
          matching: find.byType(CountryFlag),
        ),
        findsNothing,
      );
    });

    accessibilityMatrix(
      'DrinkConfirmSheet',
      () => Scaffold(body: DrinkConfirmSheet(wine: barolo)),
      overrides: () => CellarUi().overrides,
    );
  });

  group('owner request e22b8032 IdealMomentCard', () {
    final today = DateTime(2026, 11, 6);

    Future<void> pumpCard(
      WidgetTester tester,
      WineEstimate estimate, {
      Locale locale = const Locale('it'),
    }) => pumpScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: IdealMomentCard(estimate: estimate, today: today),
        ),
      ),
      overrides: ui.overrides,
      locale: locale,
    );

    final open = WineEstimate(
      window: windowOf(2024, 2028, 2032),
      baseWindow: windowOf(2024, 2028, 2032),
    );
    final past = WineEstimate(
      window: windowOf(2012, 2014, 2018),
      baseWindow: windowOf(2012, 2014, 2018),
    );

    for (final (locale, until, best, gone, none, notice) in [
      (
        const Locale('it'),
        'Consigliato fino al 2032',
        'Al meglio dal 2024 al 2032',
        'Consigliato fino al 2018: è passato',
        'Stima non disponibile',
        '⚠︎ Indicativo',
      ),
      (
        const Locale('en'),
        'Recommended until 2032',
        'At its best from 2024 to 2032',
        'Recommended until 2018: it has passed',
        'Estimate not available',
        '⚠︎ Indicative',
      ),
      (
        const Locale('pt', 'BR'),
        'Recomendado até 2032',
        'No seu melhor de 2024 a 2032',
        'Recomendado até 2018: já passou',
        'Estimativa indisponível',
        '⚠︎ Indicativo',
      ),
    ]) {
      final tag = locale.toLanguageTag();

      testWidgets('$tag: "recommended until" with the bar and the notice', (
        tester,
      ) async {
        await pumpCard(tester, open, locale: locale);

        expect(find.text(until), findsOneWidget);
        expect(find.text(best), findsOneWidget);
        expect(key('ideal-bar'), findsOneWidget);
        expect(key('ideal-today'), findsOneWidget);
        expect(find.textContaining(notice), findsOneWidget);
      });

      testWidgets('$tag: a window already over', (tester) async {
        await pumpCard(tester, past, locale: locale);

        expect(find.text(gone), findsOneWidget);
        expect(key('state-chip-pastWindow'), findsOneWidget);
        expect(find.textContaining(notice), findsOneWidget);
      });

      testWidgets('$tag: no estimate', (tester) async {
        await pumpCard(tester, WineEstimate.none, locale: locale);

        expect(find.text(none), findsOneWidget);
        expect(key('ideal-hint'), findsOneWidget);
        expect(key('ideal-bar'), findsNothing);
        expect(find.textContaining(notice), findsOneWidget);
      });
    }

    test('today sits inside the bar, the margins keep it there', () {
      final inside = WindowBar(
        window: windowOf(2024, 2028, 2032),
        today: today,
      );
      expect(inside.range, (from: 2023, to: 2033));
      expect(inside.todayFraction, inInclusiveRange(0, 1));
      final future = WindowBar(
        window: windowOf(2030, 2035, 2040),
        today: today,
      );
      expect(future.range.from, 2025, reason: 'today before the start');
      expect(future.todayFraction, lessThan(0.2));
    });
  });

  group('FR2.4 "Togli una bottiglia senza bevuta"', () {
    testWidgets('asks first; "Annulla" removes nothing', (tester) async {
      final wine = cellarWine('w1', window: windowOf(2024, 2028, 2034));
      await pumpScreen(
        tester,
        const WineDetailScreen(
          user: cellarOwner,
          cellar: ownerCellar,
          wineId: 'w1',
        ),
        overrides: ui.overrides,
      );
      ui.emitWines([wine]);
      await tester.pumpAndSettle();

      expect(find.text('Togli una bottiglia senza bevuta'), findsOneWidget);
      await tester.ensureVisible(key('wine-minus'));
      await tester.tap(key('wine-minus'));
      await tester.pumpAndSettle();
      expect(find.text('Togliere una bottiglia?'), findsOneWidget);
      expect(
        find.text(
          'Una bottiglia di Barolo viene tolta senza registrare una bevuta.',
        ),
        findsOneWidget,
      );
      await tester.tap(key('remove-bottle-cancel'));
      await tester.pumpAndSettle();

      verifyNever(
        () => ui.actions.removeBottle(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          wine: any(named: 'wine'),
        ),
      );
    });
  });

  group('review Major 3 History rows', () {
    testWidgets('flag and family of the wine still in the cellar; a drink '
        'whose wine is not loaded shows as before', (tester) async {
      when(
        () => ui.records.pageHistory(
          any(),
          after: any(named: 'after'),
          limit: 30,
        ),
      ).thenAnswer(
        (_) async => HistoryPage(
          records: [
            drinkRecord('r1', wineId: 'w1', wineName: 'Malbec'),
            drinkRecord('r2', wineId: 'gone', wineName: 'Vecchio vino'),
          ],
          cursor: HistoryCursor(MockDocSnapshot()),
          hasMore: false,
        ),
      );
      await pumpScreen(
        tester,
        const HistoryScreen(user: cellarOwner),
        overrides: ui.overrides,
      );
      ui.emitWines([
        cellarWine(
          'w1',
          name: 'Malbec',
          country: 'AR',
          wineType: 'redStructured',
        ),
      ]);
      await tester.pumpAndSettle();

      final withWine = key('history-tile-r1');
      expect(
        find.descendant(of: withWine, matching: key('flag-AR')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: withWine, matching: key('wine-type-badge-red')),
        findsOneWidget,
      );
      final without = key('history-tile-r2');
      expect(
        find.descendant(of: without, matching: find.byType(CountryFlag)),
        findsNothing,
      );
      expect(
        find.descendant(of: without, matching: find.byType(WineTypeBadge)),
        findsNothing,
      );
    });
  });

  group('FR1.3 FR3.4 label proposal', () {
    testWidgets('country with flag, region and family of the proposal', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: LabelProposalSheet(
            candidate: const WineCandidate(
              name: 'Malbec Reserva',
              producer: 'Catena',
              vintage: 2019,
              wineType: CatalogWineType.red,
              region: 'Mendoza, Argentina',
              source: CandidateSource.openFoodFacts,
            ),
            onConfirm: (_) {},
            onCorrect: (_) {},
            onNotThis: () {},
          ),
        ),
        overrides: ui.overrides,
      );

      final origin = key('label-proposal-origin');
      expect(
        find.descendant(of: origin, matching: key('flag-AR')),
        findsOneWidget,
      );
      expect(find.text('Argentina'), findsOneWidget);
      expect(find.textContaining('Mendoza'), findsOneWidget);
      expect(
        find.descendant(of: origin, matching: key('wine-type-badge-red')),
        findsOneWidget,
      );
    });
  });

  group('R-05 CountryFlag', () {
    testWidgets('an unknown code shows the code in a box, read as the code; '
        'a known one is read with the name', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(
        tester,
        const Scaffold(
          body: Row(
            children: [
              CountryFlag(code: 'ZZ'),
              CountryFlag(code: 'JP'),
            ],
          ),
        ),
        overrides: ui.overrides,
      );

      expect(key('flag-fallback-ZZ'), findsOneWidget);
      expect(find.text('ZZ'), findsOneWidget);
      expect(key('flag-JP'), findsOneWidget);
      expect(find.bySemanticsLabel('Giappone'), findsOneWidget);
      handle.dispose();
    });
  });

  testWidgets('A2 the status is never color only: chips carry icon and text', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Column(
          children: [
            for (final status in StatusFilter.values) StateChip(status: status),
          ],
        ),
      ),
      overrides: ui.overrides,
    );

    for (final label in [
      'Da aspettare',
      'Pronte',
      'Da bere presto',
      'Oltre la finestra',
      'Da stimare',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(Icon), findsNWidgets(StatusFilter.values.length));
  });

  test('every family has its own icon', () {
    expect({
      for (final family in WineTypeFamily.values) wineFamilyIcon(family),
    }, hasLength(WineTypeFamily.values.length));
    expect(WineType.values.map(WineTypeFamily.ofType).toSet(), {
      ...WineTypeFamily.values,
    });
  });
}

/// Whether the cards of a test get "I drank one".
enum AccessibleDrink { allowed, readOnly }

Future<void> _noRetry() async {}
