// OnlineSearchScreen, "Cerca online" (label-recognition FR3.2-FR3.4,
// BR4.1-BR4.4, BR6.2, L7): the field filled and editable, "Cerca" disabled
// when empty, the states loading, results, empty, offline, rateLimited and
// unavailable (review R-03),
// a complete candidate and a name-only one filling the form, and the
// accessibility matrix. The catalog is the fake of LabelEnv: no network.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/ui/online_search_screen.dart';

import '../../helpers/ui_harness.dart';
import 'label_ui_harness.dart';

const _complete = WineCandidate(
  name: 'Château Musar Rouge',
  producer: 'Château Musar',
  vintage: 2015,
  wineType: CatalogWineType.red,
  region: 'Bekaa Valley, Lebanon',
  source: CandidateSource.openFoodFacts,
  barcode: '8001234500092',
);
const _nameOnly = WineCandidate(
  name: 'Château Musar Blanc',
  source: CandidateSource.offline,
);

void main() {
  late LabelUi ui;

  setUp(() => ui = LabelUi());

  void answer(List<WineCandidate> candidates, OnlineSearchStatus status) =>
      ui.env.catalog.searchResult = OnlineSearchResult(
        candidates: candidates,
        status: status,
      );

  /// The search above a root page, as the reading screen pushes it.
  Future<void> pump(
    WidgetTester tester, {
    String query = 'chateau musar 2015',
    Locale locale = const Locale('it'),
  }) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          key: const Key('root-page'),
          body: Center(
            child: TextButton(
              key: const Key('open-search'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OnlineSearchScreen(
                    target: labelTarget,
                    initialQuery: query,
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      locale: locale,
      overrides: ui.overrides,
    );
    await tester.tap(find.byKey(const Key('open-search')));
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('online-search-submit')));
    await tester.pumpAndSettle();
  }

  for (final locale in testLocales) {
    testWidgets('BR4.1 BR4.2 the field starts with the words read; results '
        'with the attribution (BR6.2) (${locale.toLanguageTag()})', (
      tester,
    ) async {
      final l10n = lookupAppLocalizations(locale);
      answer(const [_nameOnly, _complete], OnlineSearchStatus.ok);
      await pump(tester, locale: locale);
      final field = tester.widget<TextField>(
        find.byKey(const Key('online-search-field')),
      );
      expect(field.controller!.text, 'chateau musar 2015');
      expect(find.text(l10n.onlineSearchHint), findsOneWidget);
      await search(tester);
      expect(ui.env.catalog.searchCalls, ['chateau musar 2015']);
      expect(find.text(l10n.onlineSearchResults(2)), findsOneWidget);
      expect(find.text(l10n.labelChipOffline), findsOneWidget);
      expect(find.text(l10n.labelChipOnline), findsOneWidget);
      expect(find.text(l10n.labelOffAttribution), findsOneWidget);
    });
  }

  testWidgets('BR4.2 "Cerca" is disabled with the field empty, with the '
      'hint "Scrivi almeno una parola"', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('it'));
    await pump(tester, query: '');
    final button = find.byKey(const Key('online-search-submit'));
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(find.text(l10n.onlineSearchEmptyField), findsOneWidget);
    await tester.enterText(find.byKey(const Key('online-search-field')), '  ');
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.enterText(
      find.byKey(const Key('online-search-field')),
      'barolo',
    );
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    expect(ui.env.catalog.searchCalls, isEmpty);
  });

  testWidgets('the field takes at most 120 characters', (tester) async {
    await pump(tester, query: 'a' * 130);
    final field = tester.widget<TextField>(
      find.byKey(const Key('online-search-field')),
    );
    expect(field.controller!.text, hasLength(120));
  });

  testWidgets('loading, then "nessun vino trovato"', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('it'));
    answer(const [], OnlineSearchStatus.ok);
    ui.env.catalog.searchGate = Completer<void>();
    await pump(tester);
    await tester.tap(find.byKey(const Key('online-search-submit')));
    await tester.pump();
    expect(find.text(l10n.onlineSearchLoading), findsOneWidget);
    ui.env.catalog.searchGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text(l10n.onlineSearchEmpty), findsOneWidget);
  });

  testWidgets('FR3.4 without network: "cerco solo nella base sul telefono" '
      'with the offline results', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('it'));
    answer(const [_nameOnly], OnlineSearchStatus.offline);
    await pump(tester);
    await search(tester);
    expect(find.text(l10n.onlineSearchOffline), findsOneWidget);
    expect(find.text('Château Musar Blanc'), findsOneWidget);
  });

  testWidgets('FR3.4 limit reached: "riprova tra qualche minuto"', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('it'));
    answer(const [], OnlineSearchStatus.rateLimited);
    await pump(tester);
    await search(tester);
    expect(find.text(l10n.onlineSearchRateLimited), findsOneWidget);
    expect(find.text(l10n.onlineSearchEmpty), findsOneWidget);
  });

  for (final locale in testLocales) {
    testWidgets('BR4.3 Open Food Facts off in the build: its own message, '
        'never "riprova tra qualche minuto" (review R-03) '
        '(${locale.toLanguageTag()})', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      answer(const [_nameOnly], OnlineSearchStatus.unavailable);
      await pump(tester, locale: locale);
      await search(tester);
      expect(
        find.byKey(const Key('online-search-unavailable')),
        findsOneWidget,
      );
      expect(find.text(l10n.onlineSearchUnavailable), findsOneWidget);
      expect(find.text(l10n.onlineSearchRateLimited), findsNothing);
      expect(find.text(l10n.onlineSearchOffline), findsNothing);
      expect(find.text('Château Musar Blanc'), findsOneWidget);
    });
  }

  test('BR4.3 the three messages differ in every language', () {
    for (final locale in testLocales) {
      final l10n = lookupAppLocalizations(locale);
      final messages = {
        l10n.onlineSearchOffline,
        l10n.onlineSearchRateLimited,
        l10n.onlineSearchUnavailable,
      };
      expect(messages, hasLength(3), reason: '$locale');
    }
  });

  testWidgets('FR3.3 a complete candidate fills the form; back returns to '
      'the list (BR4.4)', (tester) async {
    answer(const [_complete], OnlineSearchStatus.ok);
    await pump(tester);
    await search(tester);
    await tester.tap(find.byKey(const Key('label-candidate-0')));
    await tester.pumpAndSettle();
    final values = tester
        .widget<AddWineScreen>(find.byType(AddWineScreen))
        .initialValues!;
    expect(values.name, 'Château Musar Rouge');
    expect(values.producer, 'Château Musar');
    expect(values.vintage, 2015);
    expect(values.wineType, 'redStructured');
    expect(values.country, 'LB');
    Navigator.of(tester.element(find.byType(AddWineScreen))).pop();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('online-search-screen')), findsOneWidget);
  });

  testWidgets('FR3.3 a name-only candidate fills only the name; a save goes '
      'back to the cellar', (tester) async {
    answer(const [_nameOnly], OnlineSearchStatus.ok);
    await pump(tester);
    await search(tester);
    await tester.tap(find.byKey(const Key('label-candidate-0')));
    await tester.pumpAndSettle();
    final values = tester
        .widget<AddWineScreen>(find.byType(AddWineScreen))
        .initialValues!;
    expect(values.name, 'Château Musar Blanc');
    expect(values.producer, isNull);
    expect(values.vintage, isNull);
    await tester.tap(find.byKey(const Key('add-wine-save-button')));
    await tester.pumpAndSettle();
    final draft =
        verify(
              () => ui.actions.saveNewWine(
                cellar: any(named: 'cellar'),
                user: any(named: 'user'),
                draft: captureAny(named: 'draft'),
              ),
            ).captured.single
            as WineDraft;
    expect(draft.name, 'Château Musar Blanc');
    expect(find.byKey(const Key('root-page')), findsOneWidget);
  });

  for (final status in [
    OnlineSearchStatus.ok,
    OnlineSearchStatus.offline,
    OnlineSearchStatus.rateLimited,
    OnlineSearchStatus.unavailable,
  ]) {
    accessibilityMatrix(
      'OnlineSearchScreen ${status.name}',
      () => const OnlineSearchScreen(
        target: labelTarget,
        initialQuery: 'chateau musar',
      ),
      overrides: () {
        final screen = LabelUi();
        screen.env.catalog.searchResult = OnlineSearchResult(
          candidates: const [_complete, _nameOnly],
          status: status,
        );
        return screen.overrides;
      },
      afterPump: (tester) async {
        await tester.tap(find.byKey(const Key('online-search-submit')));
      },
    );
  }
}
