// u4-cellar providers (BR1.1, BR1.7, BR1.8, BR1.16, BR1.17; NFR1.2, NFR5.1,
// NFR5.2, NFR6.6): the list without finished wines, the archive read on
// demand, the History pages, the suggestions after 250 ms (fake time of
// testWidgets), the maintenance trigger and the pending drinks.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/cellar/cellar_providers.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/cellar/domain/cellar_filter.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/sharing/sharing_providers.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';
import 'package:vinoozy/sync/sync_status.dart';

import '../helpers/fakes.dart';
import '../helpers/firestore_mocks.dart';
import '../helpers/service_mocks.dart';
import '../sharing/sharing_harness.dart' show noSharingOverrides;
import 'cellar_harness.dart';

void main() {
  setUpAll(() {
    registerCellarFallbacks();
    registerFallbackValue(MockDocSnapshot());
  });

  late MockWineRepository wines;
  late MockCellarRepository cellars;
  late MockDrinkingRecordRepository records;
  late MockCellarMaintenance maintenance;
  late FakeWineCatalog catalog;
  late FakeCellarNetwork network;
  late StreamController<WinesSnapshot> winesStream;
  late StreamController<CellarSnapshot> cellarStream;
  late ProviderContainer container;

  const fromServer = SnapshotMeta(hasPendingWrites: false, isFromCache: false);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    wines = MockWineRepository();
    cellars = MockCellarRepository();
    records = MockDrinkingRecordRepository();
    maintenance = MockCellarMaintenance();
    catalog = FakeWineCatalog();
    network = FakeCellarNetwork();
    winesStream = StreamController<WinesSnapshot>.broadcast();
    cellarStream = StreamController<CellarSnapshot>.broadcast();
    when(() => wines.watchCellarWines('user-a'))
        .thenAnswer((_) => winesStream.stream);
    when(() => cellars.watchCellar('user-a'))
        .thenAnswer((_) => cellarStream.stream);
    when(() => maintenance.run(any(), any(), any()))
        .thenAnswer((_) async => true);
    container = ProviderContainer(
      overrides: [
        wineRepositoryProvider.overrideWithValue(wines),
        cellarRepositoryProvider.overrideWithValue(cellars),
        networkStatusProvider.overrideWithValue(network),
        errorReporterProvider.overrideWithValue(
          recordingReporter(RecordingErrorSink()),
        ),
        syncWatcherProvider.overrideWithValue(MockSyncWatcher()),
        ...cellarServiceOverrides(
          catalog: catalog,
          records: records,
          maintenance: maintenance,
        ),
        ...noSharingOverrides(),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await winesStream.close();
    await cellarStream.close();
  });

  test(
    'BR1.7 NFR5.1 the list listens to the wines still in the cellar',
    () async {
      final sub = container.listen(winesStreamProvider('user-a'), (_, _) {});
      winesStream.add(
        WinesSnapshot(wines: [cellarWine('w1')], meta: fromServer),
      );
      await pumpEventQueue();

      expect(sub.read().value!.wines.single.id, 'w1');
      verify(() => wines.watchCellarWines('user-a')).called(1);
      sub.close();
    },
  );

  test('BR1.7 the archive is read only when it is opened', () async {
    when(() => wines.fetchArchived('user-a'))
        .thenAnswer((_) async => [cellarWine('w9', quantity: 0)]);
    verifyNever(() => wines.fetchArchived(any()));

    final archived = await container.read(
      archivedWinesProvider('user-a').future,
    );

    expect(archived.single.id, 'w9');
    verify(() => wines.fetchArchived('user-a')).called(1);
  });

  test('BR1.16 a finished wine is read as one document', () async {
    when(() => wines.watchWine('user-a', 'w9'))
        .thenAnswer((_) => Stream.value(cellarWine('w9', quantity: 0)));

    final sub = container.listen(
      wineProvider((cellarId: 'user-a', wineId: 'w9')),
      (_, _) {},
    );
    await pumpEventQueue();

    expect(sub.read().value!.quantity, 0);
    sub.close();
  });

  test('BR1.9 the last 3 drinks come from the cache', () async {
    when(
      () => records.recordsOfWine('user-a', 'w1', source: RecordsSource.cache),
    ).thenAnswer(
      (_) async => WineRecords(
        records: [for (var i = 0; i < 5; i++) drinkRecord('r$i')],
        fromServer: false,
      ),
    );

    final recent = await container.read(
      recentDrinksProvider((cellarId: 'user-a', wineId: 'w1')).future,
    );

    expect(recent.map((r) => r.id), ['r0', 'r1', 'r2']);
  });

  group('BR1.16 NFR5.2 History pages', () {
    HistoryPage page(int count, {bool hasMore = true, int from = 0}) =>
        HistoryPage(
          records: [
            for (var i = from; i < from + count; i++) drinkRecord('r$i'),
          ],
          cursor: count == 0 ? null : HistoryCursor(MockDocSnapshot()),
          hasMore: hasMore,
        );

    test(
      'BR1.16 the first page loads at once, the next one with the cursor',
      () async {
        final first = page(30);
        when(() => records.pageHistory('user-a', after: null, limit: 30))
            .thenAnswer((_) async => first);
        when(
          () => records.pageHistory('user-a', after: first.cursor, limit: 30),
        ).thenAnswer((_) async => page(4, hasMore: false, from: 30));
        final sub = container.listen(historyPagerProvider('user-a'), (_, _) {});
        expect(sub.read().loading, isTrue);
        await pumpEventQueue();

        expect(sub.read().records, hasLength(30));
        await container
            .read(historyPagerProvider('user-a').notifier)
            .loadMore();
        expect(sub.read().records, hasLength(34));
        expect(sub.read().hasMore, isFalse);

        // Nothing after the last page: no other read.
        await container
            .read(historyPagerProvider('user-a').notifier)
            .loadMore();
        verify(
          () =>
              records.pageHistory(any(), after: any(named: 'after'), limit: 30),
        ).called(2);
        sub.close();
      },
    );

    test('BR1.16 overlapping pages keep one row per drinking record', () async {
      final first = page(30);
      when(() => records.pageHistory('user-a', after: null, limit: 30))
          .thenAnswer((_) async => first);
      when(() => records.pageHistory('user-a', after: first.cursor, limit: 30))
          .thenAnswer((_) async => page(3, from: 29, hasMore: false));
      final sub = container.listen(historyPagerProvider('user-a'), (_, _) {});
      await pumpEventQueue();
      await container.read(historyPagerProvider('user-a').notifier).loadMore();
      expect(sub.read().records, hasLength(32));
      expect(
        sub.read().records.where((record) => record.id == 'r29'),
        hasLength(1),
      );
      sub.close();
    });

    test('BR1.16 a failed page shows the error; "Try again" reloads', () async {
      var fail = true;
      when(
        () => records.pageHistory(any(), after: any(named: 'after'), limit: 30),
      ).thenAnswer((_) async {
        if (fail) throw firestoreError('failed-precondition');
        return page(2, hasMore: false);
      });
      final sub = container.listen(historyPagerProvider('user-a'), (_, _) {});
      await pumpEventQueue();
      expect(sub.read().failed, isTrue);

      fail = false;
      await container.read(historyPagerProvider('user-a').notifier).reload();
      expect(sub.read().failed, isFalse);
      expect(sub.read().records, hasLength(2));
      sub.close();
    });
  });

  group('BR1.1 NFR1.2 suggestions', () {
    testWidgets(
      'BR1.1 nothing before 3 characters; the internal ones after 250 ms',
      (tester) async {
        catalog.internal = const [
          WineCandidate(name: 'Barolo DOCG', source: CandidateSource.internal),
        ];
        final sub = container.listen(wineSuggestionsProvider, (_, _) {});
        final notifier = container.read(wineSuggestionsProvider.notifier);

        notifier.update('Ba');
        await tester.pump(const Duration(seconds: 1));
        expect(catalog.suggestQueries, isEmpty);

        notifier.update(
          'Bar',
          cellarWines: const [CellarWineRef(name: 'Barolo')],
        );
        await tester.pump(const Duration(milliseconds: 249));
        expect(sub.read().suggestions, isEmpty);
        await tester.pump(const Duration(milliseconds: 1));
        expect(sub.read().suggestions.single.name, 'Barolo DOCG');
        expect(catalog.lastCellarWines!.single.name, 'Barolo');
        // The Open Food Facts pause ends too.
        await tester.pump(const Duration(milliseconds: 400));
        expect(catalog.externalQueries, ['Bar']);
        // The container is disposed in tearDown, outside the fake time.
      },
    );

    testWidgets(
      'BR1.1 Open Food Facts are added after the pause, no duplicates',
      (tester) async {
        catalog
          ..internal = const [
            WineCandidate(name: 'Barolo', source: CandidateSource.internal),
          ]
          ..external = const [
            WineCandidate(
              name: 'barolo',
              source: CandidateSource.openFoodFacts,
            ),
            WineCandidate(
              name: 'Barolo Riserva',
              source: CandidateSource.openFoodFacts,
            ),
          ];
        final sub = container.listen(wineSuggestionsProvider, (_, _) {});
        final notifier = container.read(wineSuggestionsProvider.notifier);

        notifier.update('Barolo');
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump();

        expect(sub.read().suggestions.map((s) => s.name), [
          'Barolo',
          'Barolo Riserva',
        ]);

        // Typing again cancels: only the last query is asked.
        notifier
          ..update('Barolo R')
          ..update('Barolo Ri');
        await tester.pump(const Duration(seconds: 1));
        expect(catalog.suggestQueries.last, 'Barolo Ri');
        expect(catalog.suggestQueries.where((q) => q == 'Barolo R'), isEmpty);

        notifier.clear();
        expect(sub.read().suggestions, isEmpty);
      },
    );
  });

  test('BR1.8 BR1.17 filters: toggles, a status from the Dashboard, clear', () {
    final notifier = container.read(cellarFilterProvider.notifier);

    notifier
      ..setQuery('barolo')
      ..toggleStatus(StatusFilter.ready)
      ..toggleType(TypeFilter.red)
      ..toggleType(TypeFilter.white)
      ..toggleType(TypeFilter.white);
    expect(
      container.read(cellarFilterProvider),
      const CellarFilter(
        query: 'barolo',
        statuses: {StatusFilter.ready},
        types: {TypeFilter.red},
      ),
    );

    notifier.showOnly(StatusFilter.drinkSoon);
    expect(
      container.read(cellarFilterProvider),
      const CellarFilter(statuses: {StatusFilter.drinkSoon}),
    );

    notifier.clear();
    expect(container.read(cellarFilterProvider).isEmpty, isTrue);
  });

  test(
    'NFR6.6 maintenance at the opening and at every network return',
    () async {
      const user = AppUser(
        uid: 'user-a',
        email: 'mario@example.com',
        displayName: 'Mario',
      );
      final sub = container.listen(
        cellarMaintenanceTriggerProvider(user),
        (_, _) {},
      );
      await pumpEventQueue();
      verifyNever(() => maintenance.run(any(), any(), any()));

      winesStream.add(
        WinesSnapshot(wines: [cellarWine('w1')], meta: fromServer),
      );
      await pumpEventQueue();
      winesStream.add(
        WinesSnapshot(wines: [cellarWine('w2')], meta: fromServer),
      );
      await pumpEventQueue();
      verify(() => maintenance.run(any(), any(), any())).called(1);

      network.online = false;
      await pumpEventQueue();
      network.online = true;
      await pumpEventQueue();
      final loaded =
          verify(() => maintenance.run(any(), any(), captureAny()))
                  .captured
                  .single
              as List<Wine>;
      expect(loaded.single.id, 'w2');
      sub.close();
    },
  );

  test('BR1.4 BR1.6 R-04 a first empty cache snapshot runs again with the '
      'first server snapshot, once', () async {
    const cache = SnapshotMeta(hasPendingWrites: false, isFromCache: true);
    const user = AppUser(
      uid: 'user-a',
      email: 'mario@example.com',
      displayName: 'Mario',
    );
    final sub = container.listen(
      cellarMaintenanceTriggerProvider(user),
      (_, _) {},
    );
    winesStream.add(const WinesSnapshot(wines: [], meta: cache));
    await pumpEventQueue();
    winesStream.add(WinesSnapshot(wines: [cellarWine('w1')], meta: fromServer));
    await pumpEventQueue();
    winesStream.add(WinesSnapshot(wines: [cellarWine('w2')], meta: fromServer));
    await pumpEventQueue();

    final runs = verify(() => maintenance.run(any(), any(), captureAny()))
        .captured
        .cast<List<Wine>>();
    expect(runs, hasLength(2));
    expect(runs.first, isEmpty, reason: 'the opening, from the cache');
    expect(runs.last.single.id, 'w1', reason: 'the first server snapshot');
    sub.close();
  });

  test('NFR6.6 pending drinks keep the sync state "syncing"', () async {
    final sub = container.listen(syncStatusProvider('user-a'), (_, _) {});
    winesStream.add(WinesSnapshot(wines: const [], meta: fromServer));
    await pumpEventQueue();
    expect(sub.read(), SyncState.synced);

    container.read(drinkingRecordsPendingProvider.notifier).set(true);
    expect(sub.read(), SyncState.syncing);

    container.read(drinkingRecordsPendingProvider.notifier).set(false);
    expect(sub.read(), SyncState.synced);
    sub.close();
  });

  test('the active cellar of the trigger comes from u7-sharing', () {
    const user = AppUser(
      uid: 'user-a',
      email: 'mario@example.com',
      displayName: 'Mario',
    );
    expect(container.read(activeCellarProvider(user)).cellarId, 'user-a');
  });
}
