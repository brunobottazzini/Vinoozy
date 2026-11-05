import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/ui/rejected_wine_notice.dart';

import '../../helpers/ui_harness.dart';
import 'cellar_screen_test.dart' show CellarFixture;

void main() {
  late CellarFixture fixture;
  late List<String> addedAgain;

  setUp(() {
    fixture = CellarFixture();
    addedAgain = [];
  });

  Future<void> reject(
    String wineId,
    String name, {
    String uid = 'user-a',
  }) async {
    await fixture.ledger.beginWrite(
      uid: uid,
      email: '$uid@example.com',
      entry: JournalEntry(
        wineId: wineId,
        cellarId: uid,
        name: name,
        ownerUid: uid,
      ),
    );
    await fixture.ledger.markRejected(wineId);
  }

  /// Lets the ledger's real futures run, then rebuilds.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pump(WidgetTester tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: RejectedWineNotices(uid: 'user-a', onAddAgain: addedAgain.add),
      ),
      overrides: fixture.overrides,
    );
    await settle(tester);
  }

  testWidgets('nothing is shown without rejected wines', (tester) async {
    await pump(tester);

    expect(find.byKey(const Key('rejected-wine-notices')), findsNothing);
  });

  testWidgets('shows one notice per rejected wine of the user (NFR6.3)', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await reject('w1', 'Barolo');
      await reject('w2', 'Arneis');
    });
    await pump(tester);

    expect(
      find.text('Il vino Barolo non è stato salvato nel cloud'),
      findsOneWidget,
    );
    expect(
      find.text('Il vino Arneis non è stato salvato nel cloud'),
      findsOneWidget,
    );
  });

  testWidgets('"Ignora" removes the notice and releases the owner', (
    tester,
  ) async {
    await tester.runAsync(() => reject('w1', 'Barolo'));
    await pump(tester);

    await tester.tap(find.byKey(const Key('rejected-wine-ignore-button')));
    await settle(tester);

    expect(find.byKey(const Key('rejected-wine-notices')), findsNothing);
    final state = await tester.runAsync(fixture.ledger.read);
    expect(state!.owner, isNull);
  });

  testWidgets('"Aggiungi di nuovo" passes the name and clears the entry', (
    tester,
  ) async {
    await tester.runAsync(() => reject('w1', 'Barolo'));
    await pump(tester);

    await tester.tap(find.byKey(const Key('rejected-wine-add-again-button')));
    await settle(tester);

    expect(addedAgain, ['Barolo']);
    final state = await tester.runAsync(fixture.ledger.read);
    expect(state!.journal, isEmpty);
  });

  testWidgets('"Aggiungi di nuovo" on a wine that is not lost opens no form '
      'and creates no duplicate (review R-01)', (tester) async {
    await tester.runAsync(() => reject('w1', 'Barolo'));
    when(() => fixture.watcher.reconcileRejected(any()))
        .thenAnswer((invocation) async {
          final entry = invocation.positionalArguments.single as JournalEntry;
          await fixture.ledger.markConfirmed(entry.wineId);
          return true;
        });
    await pump(tester);

    await tester.tap(find.byKey(const Key('rejected-wine-add-again-button')));
    await settle(tester);

    expect(addedAgain, isEmpty);
    expect(find.byKey(const Key('rejected-wine-notices')), findsNothing);
    final checked =
        verify(() => fixture.watcher.reconcileRejected(captureAny()))
                .captured
                .single
            as JournalEntry;
    expect(checked.wineId, 'w1');
  });

  testWidgets('each notice counts one view per app session', (tester) async {
    await tester.runAsync(() => reject('w1', 'Barolo'));
    await pump(tester);
    await settle(tester);
    await settle(tester);

    final state = await tester.runAsync(fixture.ledger.read);
    expect(state!.rejectedEntriesOf('user-a').single.notices, 1);
  });

  accessibilityMatrix(
    'RejectedWineNotice',
    () => Scaffold(
      body: RejectedWineNotice(
        entry: const JournalEntry(
          wineId: 'w1',
          cellarId: 'user-a',
          name: 'Barbera d\'Asti Superiore DOCG',
          ownerUid: 'user-a',
          state: JournalState.rejected,
        ),
        onAddAgain: () {},
        onIgnore: () {},
      ),
    ),
  );
}
