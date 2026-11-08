// DashboardScreen (u5-dashboard frontend-components.md; FR5.1-FR5.6,
// BR1.3-BR1.8, NFR3.1-NFR3.5, NFR6.2, NFR6.3) in it, en and pt-BR.
import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/ui/country_flag.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/dashboard/dashboard_providers.dart';
import 'package:vinoozy/dashboard/domain/dashboard_summary.dart';
import 'package:vinoozy/dashboard/ui/bar_chart.dart';
import 'package:vinoozy/dashboard/ui/chart_cards.dart';
import 'package:vinoozy/dashboard/ui/dashboard_screen.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

import '../helpers/ui_harness.dart';
import 'dashboard_harness.dart';
import 'fixtures.dart';

/// On 6 November 2026: waiting 3, ready 1, drink soon 2, past window 1,
/// 2 to estimate; 9 bottles.
List<Wine> sampleCellar() => [
  wineOf(
    'w1',
    name: 'Barolo',
    vintage: 2016,
    producer: 'Cantina Esempio',
    quantity: 2,
    wineType: 'redStructured',
    region: 'Piemonte',
    window: window(2020, 2024, 2026),
  ),
  wineOf(
    'w2',
    name: 'Soave',
    quantity: 1,
    wineType: 'white',
    region: 'Veneto',
    window: window(2024, 2030, 2040),
  ),
  wineOf(
    'w3',
    name: 'Amarone',
    quantity: 3,
    wineType: 'red',
    region: 'Veneto',
    window: window(2028, 2032, 2040),
  ),
  wineOf(
    'w4',
    name: 'Prosecco',
    quantity: 1,
    wineType: 'sparkling',
    window: window(2010, 2015, 2020),
  ),
  wineOf('w5', name: 'Vino della casa', vintage: null, quantity: 2),
];

/// Scrolls the Dashboard (not the horizontal peak chart) until [finder] is
/// visible.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    150,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('dashboard-content')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  // Fully on screen, not only its first pixels, so a tap hits it.
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

class _Actions {
  final List<String> openedWines = [];
  final List<WineStatus> openedStatuses = [];
  int addFirstWine = 0;
  int retries = 0;
}

void main() {
  late DashboardStreams streams;
  late _Actions actions;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    streams = DashboardStreams();
    actions = _Actions();
  });

  DashboardScreen screen({CellarSetup setup = CellarSetup.ready}) =>
      DashboardScreen(
        user: dashboardUser,
        setup: setup,
        onRetrySetup: () async => actions.retries++,
        onOpenWine: actions.openedWines.add,
        onOpenStatus: actions.openedStatuses.add,
        onAddFirstWine: () => actions.addFirstWine++,
      );

  Future<void> pump(
    WidgetTester tester, {
    CellarSetup setup = CellarSetup.ready,
    Locale locale = const Locale('it'),
  }) => pumpScreen(
    tester,
    screen(setup: setup),
    locale: locale,
    overrides: streams.overrides,
  );

  Future<void> emit(
    WidgetTester tester,
    List<Wine> wines, {
    bool cache = false,
  }) async {
    streams
      ..emitCellar()
      ..emitWines(wines, meta: cache ? fromCache : fromServer);
    await tester.pumpAndSettle();
  }

  group('states', () {
    testWidgets('preparing: skeleton, no Firestore listener', (tester) async {
      await pump(tester, setup: CellarSetup.preparing);
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const Key('dashboard-loading')), findsOneWidget);
      verifyNever(() => streams.wines.watchCellarWines(any()));
      verifyNever(() => streams.cellars.watchCellar(any()));
      expect(find.byKey(const Key('dashboard-empty')), findsNothing);
    });

    testWidgets('failed setup: the U1 error with "Riprova"', (tester) async {
      await pump(tester, setup: CellarSetup.failed);

      expect(find.text('Impossibile preparare la cantina'), findsOneWidget);
      await tester.tap(find.byKey(const Key('dashboard-retry-button')));
      expect(actions.retries, 1);
    });

    testWidgets('a wines listener error shows the error (NFR6.2)', (
      tester,
    ) async {
      await pump(tester);
      streams.emitCellar();
      streams.winesStream.addError(StateError('permission-denied'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboard-error')), findsOneWidget);
      await tester.tap(find.byKey(const Key('dashboard-retry-button')));
      expect(actions.retries, 1);
    });

    testWidgets('ready but no snapshot yet: skeleton', (tester) async {
      await pump(tester);

      expect(find.byKey(const Key('dashboard-loading')), findsOneWidget);
    });

    testWidgets('0 bottles from the cache only: "Sincronizzazione della '
        'cantina…" and "Aggiungi il primo vino" (BR1.8, NFR6.3)', (
      tester,
    ) async {
      await pump(tester);
      await emit(tester, const [], cache: true);

      expect(find.text('Sincronizzazione della cantina…'), findsOneWidget);
      expect(find.text('La tua cantina è vuota'), findsNothing);
      await tester.tap(find.byKey(const Key('dashboard-syncing-add')));
      expect(actions.addFirstWine, 1);
    });

    testWidgets('0 bottles from the server: "La tua cantina è vuota" with '
        '"Aggiungi il primo vino" (BR1.8)', (tester) async {
      await pump(tester);
      await emit(tester, [wineOf('zero', quantity: 0)]);

      expect(find.text('La tua cantina è vuota'), findsOneWidget);
      expect(find.byKey(const Key('dashboard-content')), findsNothing);
      await tester.tap(find.byKey(const Key('dashboard-empty-add')));
      expect(actions.addFirstWine, 1);
    });

    testWidgets('data: list, three charts and numbers (FR5.2-FR5.5)', (
      tester,
    ) async {
      await pump(tester);
      await emit(tester, sampleCellar());

      expect(find.byKey(const Key('dashboard-content')), findsOneWidget);
      expect(find.text('9 bottiglie in cantina'), findsOneWidget);
      expect(find.text('Barolo'), findsOneWidget);
      expect(
        find.text('2016 · Cantina Esempio · 2 bottiglie · entro il 2026'),
        findsOneWidget,
      );
      expect(find.text('2 bottiglie da stimare'), findsNWidgets(2));
      await scrollTo(tester, find.byKey(const Key('breakdown-type')));
      expect(find.text('Bottiglie per tipologia'), findsOneWidget);
      expect(find.text('non indicata'), findsOneWidget);
    });

    testWidgets('no drink-soon wine: "Nessuna bottiglia in scadenza"', (
      tester,
    ) async {
      await pump(tester);
      await emit(tester, [wineOf('r', window: window(2024, 2030, 2040))]);

      expect(find.text('Nessuna bottiglia in scadenza'), findsOneWidget);
      expect(find.byKey(const Key('drink-soon-all')), findsNothing);
    });
  });

  group('injected actions', () {
    testWidgets('a drink-soon row opens the wine', (tester) async {
      await pump(tester);
      await emit(tester, sampleCellar());

      await tester.tap(find.byKey(const Key('drink-soon-w1')));
      expect(actions.openedWines, ['w1']);
    });

    testWidgets('each status bar opens its status', (tester) async {
      await pump(tester);
      await emit(tester, sampleCellar());

      for (final status in WineStatus.values) {
        final bar = find.byKey(Key('chart-status-${status.name}'));
        await scrollTo(tester, bar);
        await tester.tap(bar);
      }
      expect(actions.openedStatuses, WineStatus.values);
    });

    testWidgets('more than 10 drink-soon wines: 10 rows and "Vedi tutti '
        '(N)" opens the status (BR1.3)', (tester) async {
      await pump(tester);
      await emit(tester, [
        for (var i = 0; i < 12; i++)
          wineOf('d$i', name: 'Vino $i', window: window(2020, 2024, 2026)),
      ]);

      final rows = find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('drink-soon-d'),
      );
      expect(rows, findsNWidgets(10));
      final seeAll = find.byKey(const Key('drink-soon-all'));
      await scrollTo(tester, seeAll);
      expect(find.text('Vedi tutti (12)'), findsOneWidget);
      await tester.tap(seeAll);
      expect(actions.openedStatuses, [WineStatus.drinkSoon]);
    });

    testWidgets('the selector switches to regions, is remembered and '
        'rebuilds only the third card (BR1.6, NFR2.3)', (tester) async {
      await pump(tester);
      await emit(tester, sampleCellar());
      final calls = streams.calculator.calls;
      final statusCard = tester.widget(find.byType(StatusChartCard));
      final peakCard = tester.widget(find.byType(PeakYearChartCard));

      final region = find.byKey(const Key('breakdown-region'));
      await scrollTo(tester, region);
      await tester.tap(region);
      await tester.pumpAndSettle();

      expect(find.text('Bottiglie per regione'), findsOneWidget);
      expect(find.text('Veneto'), findsOneWidget);
      expect(find.text('Piemonte'), findsOneWidget);
      expect(streams.calculator.calls, calls, reason: 'no recalculation');
      expect(
        identical(tester.widget(find.byType(StatusChartCard)), statusCard),
        isTrue,
        reason: 'the status card was not rebuilt',
      );
      expect(
        identical(tester.widget(find.byType(PeakYearChartCard)), peakCard),
        isTrue,
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(breakdownModeKey), 'region');
    });
  });

  group('screen reader (BR1.7, NFR3.1, NFR3.5)', () {
    const descriptions = {
      'it':
          'Stato delle bottiglie: da aspettare: 3 bottiglie, pronte: '
          '1 bottiglia, da bere presto: 2 bottiglie, oltre la finestra: '
          '1 bottiglia',
      'en':
          'Bottle status: to wait: 3 bottles, ready: 1 bottle, drink soon: '
          '2 bottles, past the window: 1 bottle',
      'pt-BR':
          'Situação das garrafas: aguardar: 3 garrafas, prontas: 1 garrafa, '
          'beber em breve: 2 garrafas, fora da janela: 1 garrafa',
    };

    for (final locale in testLocales) {
      testWidgets('one node per card with the description '
          '(${locale.toLanguageTag()})', (tester) async {
        final handle = tester.ensureSemantics();
        await pump(tester, locale: locale);
        await emit(tester, sampleCellar());

        final description = descriptions[locale.toLanguageTag()]!;
        expect(find.bySemanticsLabel(description), findsOneWidget);
        final title = description.split(':').first;
        expect(
          find.bySemanticsLabel(RegExp('^${RegExp.escape(title)}\$')),
          findsNothing,
          reason: 'the title is not read twice',
        );
        handle.dispose();
      });
    }

    testWidgets('every chart card has a single description node', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, locale: const Locale('en'));
      await emit(tester, sampleCellar());

      await scrollTo(tester, find.byKey(const Key('breakdown-type')));
      expect(
        find.bySemanticsLabel(
          RegExp(
            r'^Peak year: past peak: 3 bottles, 2026: 0 bottles, .*'
            r'2030: 1 bottle, 2031: 0 bottles, 2032: 3 bottles, .*'
            r'later: 0 bottles$',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          // ux-redesign: the family names of the cards (FR3.2, FR3.4).
          'Bottles by type: Red: 5 bottles, White: 1 bottle, Rosé: 0 bottles, '
          'Sparkling: 1 bottle, Sweet: 0 bottles, not specified: 2 bottles',
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Peak year'), findsNothing);
      handle.dispose();
    });

    testWidgets('a status bar is a button with icon, label, number and hint', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester);
      await emit(tester, sampleCellar());

      final bar = find.byKey(const Key('chart-status-waiting'));
      expect(
        tester.getSemantics(bar),
        matchesSemantics(
          label: 'da aspettare: 3 bottiglie',
          // u4-cellar BR1.17: the bar opens the list filtered by status.
          hint: "Apri l'elenco",
          isButton: true,
          hasTapAction: true,
        ),
      );
      for (final status in WineStatus.values) {
        final row = find.byKey(Key('chart-status-${status.name}'));
        expect(
          find.descendant(of: row, matching: find.byType(Icon)),
          findsOneWidget,
          reason: '${status.name} is not shown by color only',
        );
      }
      handle.dispose();
    });
  });

  testWidgets('text x2.0: the peak chart scrolls horizontally, no overflow '
      '(NFR3.4)', (tester) async {
    await pumpScreen(
      tester,
      screen(),
      textScale: 2.0,
      overrides: streams.overrides,
    );
    await emit(tester, sampleCellar());
    await scrollTo(tester, find.byKey(const Key('chart-peak')));

    expect(find.byKey(const Key('column-chart-scroll')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('ux-redesign FR1.4 FR3.3 flags and the top box', () {
    List<Wine> withCountries() => [
      ...sampleCellar(),
      wineOf(
        'w6',
        name: 'Malbec Reserva',
        quantity: 4,
        wineType: 'redStructured',
        region: 'Mendoza',
        country: 'AR',
        window: window(2019, 2023, 2026),
      ),
    ];

    testWidgets('the box shows the total and the bottles to drink now', (
      tester,
    ) async {
      await pump(tester);
      await emit(tester, withCountries());

      // 13 bottles; ready 1 + drink soon 2 + Malbec 4 = 7 to drink now.
      expect(find.text('13 bottiglie in cantina'), findsOneWidget);
      expect(find.text('7 da bere ora'), findsOneWidget);
      expect(find.byKey(const Key('dashboard-hero')), findsOneWidget);
    });

    testWidgets('"Da bere presto" rows show the flag, read as the country', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester);
      await emit(tester, withCountries());

      expect(
        find.descendant(
          of: find.byKey(const Key('drink-soon-w6')),
          matching: find.byKey(const Key('flag-AR')),
        ),
        findsOneWidget,
      );
      // Barolo has no country but an Italian region: shown as Italy (R-06).
      expect(
        find.descendant(
          of: find.byKey(const Key('drink-soon-w1')),
          matching: find.byKey(const Key('flag-IT')),
        ),
        findsOneWidget,
      );
      // The row merges the flag label with the wine (A3).
      expect(find.bySemanticsLabel(RegExp('^Argentina\\n')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('region bars: flag per region, an icon for "non indicata"', (
      tester,
    ) async {
      await pump(tester);
      await emit(tester, withCountries());
      final region = find.byKey(const Key('breakdown-region'));
      await scrollTo(tester, region);
      await tester.tap(region);
      await tester.pumpAndSettle();

      final chart = find.byKey(const Key('chart-breakdown'));
      expect(
        find.descendant(of: chart, matching: find.byKey(const Key('flag-AR'))),
        findsOneWidget,
      );
      expect(
        find.descendant(of: chart, matching: find.byKey(const Key('flag-IT'))),
        findsNWidgets(2),
        reason: 'Piemonte and Veneto',
      );
      expect(
        find.descendant(of: chart, matching: find.byIcon(Icons.help_outline)),
        findsOneWidget,
      );
    });

    testWidgets('type bars: the family icon and name (FR3.2 FR3.3)', (
      tester,
    ) async {
      await pump(tester);
      await emit(tester, withCountries());
      await scrollTo(tester, find.byKey(const Key('chart-breakdown')));

      final chart = find.byKey(const Key('chart-breakdown'));
      expect(
        find.descendant(of: chart, matching: find.text('Rosso')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: chart, matching: find.byIcon(Icons.water_drop)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: chart, matching: find.byIcon(Icons.bubble_chart)),
        findsOneWidget,
      );
    });

    testWidgets('"altre" has the globe, a region without country the place '
        'icon, a listed region is shown translated (R-02)', (tester) async {
      late List<BarDatum> bars;
      await pumpScreen(
        tester,
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            bars = [
              for (final bar in const [
                BreakdownBar(
                  kind: BreakdownKind.region,
                  region: 'Bourgogne',
                  country: 'FR',
                  bottles: 2,
                ),
                BreakdownBar(
                  kind: BreakdownKind.region,
                  region: 'Vigna del nonno',
                  bottles: 1,
                ),
                BreakdownBar(kind: BreakdownKind.otherRegions, bottles: 3),
              ])
                BreakdownChartCard.barOf(context, l10n, bar),
            ];
            return const SizedBox();
          },
        ),
        overrides: streams.overrides,
      );

      expect(bars[0].label, 'Borgogna');
      expect(bars[0].leading, isA<CountryFlag>());
      expect(bars[0].icon, isNull);
      expect(bars[1].label, 'Vigna del nonno');
      expect(bars[1].icon, Icons.place_outlined);
      expect(bars[2].label, 'altre');
      expect(bars[2].icon, Icons.public);
    });
  });

  accessibilityMatrix(
    'DashboardScreen with data',
    screen,
    overrides: () {
      SharedPreferences.setMockInitialValues({});
      streams = DashboardStreams();
      return streams.overrides;
    },
    afterPump: (tester) => emit(tester, sampleCellar()),
  );

  accessibilityMatrix(
    'DashboardScreen empty',
    screen,
    overrides: () {
      streams = DashboardStreams();
      return streams.overrides;
    },
    afterPump: (tester) => emit(tester, const []),
  );
}
