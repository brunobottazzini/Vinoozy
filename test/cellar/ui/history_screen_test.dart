// HistoryScreen (BR1.16, BR1.11; FR6.3, AC6.2.1, AC6.2.2; NFR5.2, NFR3.4):
// the drinks from the most recent, the empty and error states, the edit for
// the author or the owner, the next page near the end, in three languages.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/ui/drinking_record_sheet.dart';
import 'package:vinoozy/cellar/ui/history_screen.dart';
import 'package:vinoozy/cellar/ui/wine_detail_screen.dart';

import '../../helpers/firestore_mocks.dart';
import '../../helpers/ui_harness.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

void main() {
  late CellarUi ui;

  setUpAll(() => registerFallbackValue(MockDocSnapshot()));

  setUp(() => ui = CellarUi());

  /// The pages in order; the last one again for any later read.
  void stubPages(List<HistoryPage> pages) {
    var calls = 0;
    when(
      () =>
          ui.records.pageHistory(any(), after: any(named: 'after'), limit: 30),
    ).thenAnswer((_) async {
      final next = pages[calls < pages.length ? calls : pages.length - 1];
      calls++;
      return next;
    });
  }

  HistoryPage page(List<DrinkingRecord> records, {bool hasMore = false}) =>
      HistoryPage(
        records: records,
        cursor: records.isEmpty ? null : HistoryCursor(MockDocSnapshot()),
        hasMore: hasMore,
      );

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('it'),
  }) => pumpScreen(
    tester,
    const HistoryScreen(user: cellarOwner),
    overrides: ui.overrides,
    locale: locale,
  );

  testWidgets('BR1.16 no drinks: "Qui troverai le bottiglie che hai bevuto"', (
    tester,
  ) async {
    stubPages([page(const [])]);
    await pump(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Qui troverai le bottiglie che hai bevuto'),
      findsOneWidget,
    );
  });

  testWidgets('BR1.16 each drink: name and vintage of the time, date, rating, '
      'condition, notes', (tester) async {
    stubPages([
      page([
        drinkRecord(
          'r1',
          wineName: 'Barolo',
          drankOn: DateTime(2026, 11, 5),
          rating: 4,
          notes: 'Con il brasato',
          condition: DrinkCondition.tooYoung,
        ),
        drinkRecord(
          'r2',
          wineName: 'Soave',
          vintage: null,
          recordedBy: 'user-c',
        ),
      ]),
    ]);
    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.text('Barolo 2016'), findsOneWidget);
    expect(find.text('Soave Senza annata'), findsOneWidget);
    expect(find.textContaining('Voto 4 su 5'), findsOneWidget);
    expect(find.textContaining('Ancora troppo giovane'), findsOneWidget);
    expect(find.textContaining('Con il brasato'), findsOneWidget);
    // The owner can change every drink.
    expect(find.byKey(const Key('history-edit-r2')), findsOneWidget);
  });

  testWidgets('BR1.16 a row opens the wine, finished ones included', (
    tester,
  ) async {
    when(() => ui.wines.watchWine('user-a', 'w1'))
        .thenAnswer((_) => Stream.value(cellarWine('w1', quantity: 0)));
    stubPages([
      page([drinkRecord('r1')]),
    ]);
    await pump(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('history-tile-r1')));
    await tester.pump();
    // The finished wine is not in the list: one document read.
    ui.emitWines(const []);
    await tester.pumpAndSettle();

    expect(find.byType(WineDetailScreen), findsOneWidget);
    expect(find.byKey(const Key('wine-add-again')), findsOneWidget);
  });

  testWidgets('BR1.11 the edit opens the sheet and reloads after saving', (
    tester,
  ) async {
    stubPages([
      page([drinkRecord('r1')]),
    ]);
    await pump(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('history-edit-r1')));
    await tester.pumpAndSettle();
    expect(find.byType(DrinkingRecordSheet), findsOneWidget);
    await tester.tap(find.byKey(const Key('record-rating-5')));
    await tester.ensureVisible(find.byKey(const Key('record-save')));
    await tester.tap(find.byKey(const Key('record-save')));
    await tester.pumpAndSettle();

    expect(find.byType(DrinkingRecordSheet), findsNothing);
    verify(
      () =>
          ui.records.pageHistory(any(), after: any(named: 'after'), limit: 30),
    ).called(2);
  });

  testWidgets('BR1.16 an error (index not ready) offers "Riprova"', (
    tester,
  ) async {
    var fail = true;
    when(
      () =>
          ui.records.pageHistory(any(), after: any(named: 'after'), limit: 30),
    ).thenAnswer((_) async {
      if (fail) throw firestoreError('failed-precondition');
      return page([drinkRecord('r1')]);
    });
    await pump(tester);
    await tester.pumpAndSettle();
    expect(find.text('Impossibile caricare lo Storico'), findsOneWidget);

    fail = false;
    await tester.tap(find.byKey(const Key('history-retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('history-tile-r1')), findsOneWidget);
  });

  testWidgets('NFR5.2 the next page is read near the end only', (tester) async {
    final first = [for (var i = 0; i < 30; i++) drinkRecord('a$i')];
    final second = [for (var i = 0; i < 3; i++) drinkRecord('b$i')];
    stubPages([page(first, hasMore: true), page(second)]);
    await pump(tester);
    await tester.pumpAndSettle();
    verify(
      () =>
          ui.records.pageHistory(any(), after: any(named: 'after'), limit: 30),
    ).called(1);

    await tester.scrollUntilVisible(
      find.byKey(const Key('history-tile-a28')),
      300,
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('history-tile-b2')),
      300,
    );

    expect(find.byKey(const Key('history-tile-b2')), findsOneWidget);
  });

  for (final (locale, empty) in [
    (const Locale('en'), 'Here you will find the bottles you drank'),
    (const Locale('pt', 'BR'), 'Aqui você encontrará as garrafas que bebeu'),
  ]) {
    testWidgets('BR1.16 the empty History in ${locale.toLanguageTag()}', (
      tester,
    ) async {
      stubPages([page(const [])]);
      await pump(tester, locale: locale);
      await tester.pumpAndSettle();
      expect(find.text(empty), findsOneWidget);
    });
  }

  accessibilityMatrix(
    'HistoryScreen',
    () => const HistoryScreen(user: cellarOwner),
    overrides: () {
      ui = CellarUi();
      stubPages([
        page([
          drinkRecord(
            'r1',
            rating: 3,
            notes: 'Buono',
            condition: DrinkCondition.pastPeak,
          ),
          drinkRecord('r2', wineName: 'Soave'),
        ]),
      ]);
      return ui.overrides;
    },
  );
}
