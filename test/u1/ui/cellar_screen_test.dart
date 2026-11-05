import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/cellar.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';

import '../../helpers/fakes.dart';
import '../../helpers/service_mocks.dart';
import '../../helpers/ui_harness.dart';

const userA = AppUser(
  uid: 'user-a',
  email: 'user-a@example.com',
  displayName: 'A',
);
const synced = SnapshotMeta(hasPendingWrites: false, isFromCache: false);

CellarSnapshot cellarSnapshot({bool exists = true}) => CellarSnapshot(
  cellar: exists
      ? const Cellar(id: 'user-a', ownerId: 'user-a', name: 'La mia cantina')
      : null,
  meta: synced,
);

Wine wine(String id, String name, {int? vintage, int quantity = 1}) =>
    Wine(id: id, name: name, vintage: vintage, storedQuantity: quantity);

/// Overrides for a cellar screen backed by controllable streams.
class CellarFixture {
  CellarFixture() {
    when(() => cellars.watchCellar('user-a')).thenAnswer((_) => cellar.stream);
    when(() => wines.watchWines('user-a'))
        .thenAnswer((_) => winesStream.stream);
    when(() => watcher.trigger()).thenAnswer((_) async {});
    registerFallbackValue(
      const JournalEntry(wineId: '', cellarId: '', name: '', ownerUid: ''),
    );
    when(() => watcher.reconcileRejected(any())).thenAnswer((_) async => false);
  }

  final cellars = MockCellarRepository();
  final wines = MockWineRepository();
  final watcher = MockSyncWatcher();
  final cellar = StreamController<CellarSnapshot>.broadcast();
  final winesStream = StreamController<WinesSnapshot>.broadcast();
  final ledger = LocalLedger(
    store: InMemoryKeyValueStore(),
    reporter: recordingReporter(RecordingErrorSink()),
  );

  List<Override> get overrides => [
    cellarRepositoryProvider.overrideWithValue(cellars),
    wineRepositoryProvider.overrideWithValue(wines),
    syncWatcherProvider.overrideWithValue(watcher),
    localLedgerProvider.overrideWithValue(ledger),
    idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
    clockProvider.overrideWithValue(FakeClock(DateTime(2026, 11, 5))),
  ];

  Future<void> emit(
    WidgetTester tester, {
    bool cellarExists = true,
    List<Wine> list = const [],
  }) async {
    cellar.add(cellarSnapshot(exists: cellarExists));
    winesStream.add(WinesSnapshot(wines: list, meta: synced));
    await tester.pumpAndSettle();
  }
}

void main() {
  late CellarFixture fixture;
  late int retries;

  setUp(() {
    fixture = CellarFixture();
    retries = 0;
  });

  Future<void> pump(WidgetTester tester, CellarSetup setup) => pumpScreen(
    tester,
    CellarScreen(
      user: userA,
      setup: setup,
      onRetrySetup: () async => retries++,
    ),
    overrides: fixture.overrides,
  );

  ButtonStyleButton addButton(WidgetTester tester) => tester
      .widget<ButtonStyleButton>(find.byKey(const Key('cellar-add-button')));

  testWidgets('while the cellar is prepared: loading, "Aggiungi" disabled', (
    tester,
  ) async {
    await pump(tester, CellarSetup.preparing);

    expect(find.byKey(const Key('cellar-loading')), findsOneWidget);
    expect(addButton(tester).onPressed, isNull);
  });

  testWidgets('a failed setup shows the error and "Riprova" (BR1.3)', (
    tester,
  ) async {
    await pump(tester, CellarSetup.failed);
    await fixture.emit(tester, cellarExists: false);

    expect(find.text('Impossibile preparare la cantina'), findsOneWidget);
    expect(addButton(tester).onPressed, isNull);
    await tester.tap(find.byKey(const Key('cellar-retry-button')));
    expect(retries, 1);
  });

  testWidgets('an empty cellar says so', (tester) async {
    await pump(tester, CellarSetup.ready);
    await fixture.emit(tester);

    expect(find.text('La tua cantina è vuota'), findsOneWidget);
    expect(addButton(tester).onPressed, isNotNull);
  });

  testWidgets('wines show name, vintage, quantity and "Stima in arrivo"', (
    tester,
  ) async {
    await pump(tester, CellarSetup.ready);
    await fixture.emit(
      tester,
      list: [
        wine('w1', 'Barolo', vintage: 2016, quantity: 2),
        wine('w2', "Barbera d'Asti Superiore DOCG", quantity: -1),
      ],
    );

    expect(find.text('Barolo'), findsOneWidget);
    expect(find.text('2016 · Stima in arrivo'), findsOneWidget);
    expect(find.text('Senza annata · Stima in arrivo'), findsOneWidget);
    expect(find.text('x2'), findsOneWidget);
    expect(find.text('x0'), findsOneWidget, reason: 'ADR-004');
    expect(find.byKey(const ValueKey('w1')), findsOneWidget);
  });

  testWidgets('"Aggiungi" stays disabled until the cellar document exists', (
    tester,
  ) async {
    await pump(tester, CellarSetup.ready);
    await fixture.emit(tester, cellarExists: false);
    expect(addButton(tester).onPressed, isNull);

    fixture.cellar.add(cellarSnapshot());
    await tester.pumpAndSettle();
    expect(addButton(tester).onPressed, isNotNull);
  });

  testWidgets('"Aggiungi" opens the form', (tester) async {
    await pump(tester, CellarSetup.ready);
    await fixture.emit(tester);

    await tester.tap(find.byKey(const Key('cellar-add-button')));
    await tester.pumpAndSettle();

    expect(find.byType(AddWineScreen), findsOneWidget);
  });

  testWidgets('a broken wines listener shows the error with retry', (
    tester,
  ) async {
    await pump(tester, CellarSetup.ready);
    fixture.cellar.add(cellarSnapshot());
    fixture.winesStream.addError(StateError('listener failed'));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('cellar-error')), findsOneWidget);
    await tester.tap(find.byKey(const Key('cellar-retry-button')));
    await tester.pump();
  });

  testWidgets('a rejected wine notice reopens the form with its name', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await fixture.ledger.beginWrite(
        uid: 'user-a',
        email: 'user-a@example.com',
        entry: const JournalEntry(
          wineId: 'lost',
          cellarId: 'user-a',
          name: 'Barolo',
          ownerUid: 'user-a',
        ),
      );
      await fixture.ledger.markRejected('lost');
    });
    await pump(tester, CellarSetup.ready);
    await fixture.emit(tester);
    // The ledger stream is fed by real futures: let them run, then rebuild.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Il vino Barolo non è stato salvato nel cloud'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('rejected-wine-add-again-button')));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(
      find.byKey(const Key('add-wine-name-field')),
    );
    expect(field.controller!.text, 'Barolo');
  });

  accessibilityMatrix(
    'CellarScreen',
    () => CellarScreen(
      user: userA,
      setup: CellarSetup.ready,
      onRetrySetup: () async {},
    ),
    overrides: () {
      fixture = CellarFixture();
      return fixture.overrides;
    },
    afterPump: (tester) => fixture.emit(
      tester,
      list: [
        wine('w1', 'Barolo', vintage: 2016, quantity: 2),
        wine('w2', 'Barbera ${'d' * 110}', quantity: 1),
      ],
    ),
  );
}
