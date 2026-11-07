// Review R-01 and R-02 (BR1.16, US6.2, BR1.9): the History and the last
// drinks of the detail are read again after a drink, "Undo", a rating or
// notes change, a delete and a merge, in the same session.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/cellar_providers.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/cellar/ui/drinking_record_sheet.dart';
import 'package:vinoozy/cellar/ui/wine_detail_screen.dart';

import '../../helpers/firestore_mocks.dart';
import '../../helpers/ui_harness.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

void main() {
  late CellarUi ui;
  late List<DrinkingRecord> history;
  late int historyReads;

  setUpAll(() => registerFallbackValue(MockDocSnapshot()));

  setUp(() {
    ui = CellarUi();
    history = const [];
    historyReads = 0;
    when(
      () =>
          ui.records.pageHistory(any(), after: any(named: 'after'), limit: 30),
    ).thenAnswer((_) async {
      historyReads++;
      return HistoryPage(records: history, cursor: null, hasMore: false);
    });
  });

  const recentKey = (cellarId: 'user-a', wineId: 'w1');
  final barolo = cellarWine('w1', name: 'Barolo', matchKey: 'barolo||2016');

  /// The History and the last drinks of w1 kept open, as the History tab
  /// (mounted in the IndexedStack) and the detail do.
  ProviderContainer keepReadsOpen(WidgetTester tester, Type screen) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(screen)),
    );
    container
      ..listen(historyPagerProvider('user-a'), (_, _) {})
      ..listen(recentDrinksProvider(recentKey), (_, _) {});
    return container;
  }

  int recentReads() => verify(
    () => ui.records.recordsOfWine('user-a', 'w1', source: RecordsSource.cache),
  ).callCount;

  Future<void> pumpCellar(WidgetTester tester) async {
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
      ..emitWines([barolo]);
    await tester.pumpAndSettle();
  }

  testWidgets('BR1.16 R-01 after "Bevuta" the History shows the new drink, '
      'after "Annulla" it is gone', (tester) async {
    await pumpCellar(tester);
    final container = keepReadsOpen(tester, CellarScreen);
    await tester.pumpAndSettle();
    expect(container.read(historyPagerProvider('user-a')).records, isEmpty);

    history = [drinkRecord('r-new')];
    await tester.tap(find.byKey(const Key('wine-tile-drink-w1')));
    await tester.pumpAndSettle();
    expect(
      container.read(historyPagerProvider('user-a')).records.single.id,
      'r-new',
    );

    history = const [];
    await tester.tap(find.byKey(const Key('drink-undo')));
    await tester.pumpAndSettle();
    expect(container.read(historyPagerProvider('user-a')).records, isEmpty);
    expect(historyReads, 3);
  });

  testWidgets('BR1.9 R-02 the last drinks are read again after "Bevuta" and '
      'after "Annulla"', (tester) async {
    await pumpCellar(tester);
    keepReadsOpen(tester, CellarScreen);
    await tester.pumpAndSettle();
    expect(recentReads(), 1);

    await tester.tap(find.byKey(const Key('wine-tile-drink-w1')));
    await tester.pumpAndSettle();
    expect(recentReads(), 1, reason: 'counted from the last verify');

    await tester.tap(find.byKey(const Key('drink-undo')));
    await tester.pumpAndSettle();
    expect(recentReads(), 1);
  });

  testWidgets('BR1.11 R-01 R-02 saving rating and notes refreshes the History '
      'and the last drinks', (tester) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            key: const Key('open'),
            onPressed: () => DrinkingRecordSheet.show(
              context,
              user: cellarOwner,
              cellar: ownerCellar,
              record: drinkRecord('r1'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
      overrides: ui.overrides,
    );
    keepReadsOpen(tester, Scaffold);
    await tester.pumpAndSettle();
    final before = historyReads;
    recentReads();

    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('record-rating-4')));
    await tester.ensureVisible(find.byKey(const Key('record-save')));
    await tester.tap(find.byKey(const Key('record-save')));
    await tester.pumpAndSettle();

    expect(historyReads, before + 1);
    expect(recentReads(), 1);
  });

  Future<void> pumpDetail(WidgetTester tester) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            key: const Key('open-detail'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WineDetailScreen(
                  user: cellarOwner,
                  cellar: ownerCellar,
                  wineId: 'w1',
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
      overrides: ui.overrides,
    );
    await tester.tap(find.byKey(const Key('open-detail')));
    await tester.pump();
    ui.emitWines([barolo]);
    await tester.pumpAndSettle();
  }

  testWidgets('BR1.14 R-01 a delete refreshes the History', (tester) async {
    await pumpDetail(tester);
    keepReadsOpen(tester, WineDetailScreen);
    await tester.pumpAndSettle();
    final before = historyReads;

    await tester.ensureVisible(find.byKey(const Key('wine-delete')));
    await tester.tap(find.byKey(const Key('wine-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-confirm')));
    await tester.pumpAndSettle();

    expect(historyReads, before + 1);
  });

  testWidgets('BR1.20 R-01 a merge refreshes the History', (tester) async {
    final older = cellarWine('old', createdAt: DateTime.utc(2026, 1));
    ui.duplicates = [older, barolo];
    await pumpDetail(tester);
    keepReadsOpen(tester, WineDetailScreen);
    await tester.pumpAndSettle();
    final before = historyReads;

    await tester.tap(find.byKey(const Key('duplicate-merge')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('merge-confirm')));
    await tester.pumpAndSettle();

    expect(historyReads, before + 1);
  });
}

Future<void> _noRetry() async {}
