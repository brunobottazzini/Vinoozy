import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';

import '../cellar/cellar_harness.dart';
import '../cellar/ui/cellar_ui_harness.dart';
import '../helpers/ui_harness.dart';

void main() {
  testWidgets('Undo stays available after switching from Cellar to History', (
    tester,
  ) async {
    final ui = CellarUi();
    when(
      () =>
          ui.records.pageHistory(any(), after: any(named: 'after'), limit: 30),
    ).thenAnswer(
      (_) async => const HistoryPage(records: [], cursor: null, hasMore: false),
    );
    await pumpScreen(
      tester,
      HomeShell(
        user: cellarOwner,
        setup: CellarSetup.ready,
        onRetrySetup: () async {},
      ),
      overrides: ui.overrides,
    );
    ui
      ..emitCellar()
      ..emitWines([cellarWine('w1', name: 'Barolo')]);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('wine-tile-drink-w1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drink-confirm')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-nav-history')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('drink-undo')).hitTestable(), findsOneWidget);
    await tester.tap(find.byKey(const Key('drink-undo')));
    await tester.pumpAndSettle();
    verify(
      () => ui.actions.undoDrink(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
        recordId: 'r-new',
      ),
    ).called(1);
  });
}
