// Everything a cellar screen needs in a widget test: the U1 listeners fed by
// the test, the cellar operations as a mocktail double, the fake catalog, a
// fake clock (2026-11-06) and a network the test drives.
import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/cellar_providers.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/cellar.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';

import '../../helpers/fakes.dart';
import '../../helpers/service_mocks.dart';
import '../../sharing/sharing_harness.dart' show noSharingOverrides;
import '../cellar_harness.dart';

const serverMeta = SnapshotMeta(hasPendingWrites: false, isFromCache: false);
const cacheMeta = SnapshotMeta(hasPendingWrites: false, isFromCache: true);

class CellarUi {
  CellarUi() {
    SharedPreferences.setMockInitialValues({});
    registerCellarFallbacks();
    registerFallbackValue(
      const JournalEntry(wineId: '', cellarId: '', name: '', ownerUid: ''),
    );
    when(() => cellars.watchCellar(any())).thenAnswer((_) => cellar.stream);
    when(() => wines.watchCellarWines(any()))
        .thenAnswer((_) => winesStream.stream);
    when(() => watcher.trigger()).thenAnswer((_) async {});
    when(() => watcher.reconcileRejected(any())).thenAnswer((_) async => false);
    when(
      () => records.recordsOfWine(any(), any(), source: any(named: 'source')),
    ).thenAnswer((_) async => WineRecords(records: drinks, fromServer: true));
    when(
      () => actions.drink(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
      ),
    ).thenAnswer((_) async => const DrinkAccepted('r-new'));
    when(
      () => actions.undoDrink(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
        recordId: any(named: 'recordId'),
      ),
    ).thenAnswer((_) async => UndoResult.undone);
    when(() => actions.entriesLike(any(), any()))
        .thenAnswer((_) async => duplicates);
    when(() => actions.hasDrinks(any(), any()))
        .thenAnswer((_) async => newerHasDrinks);
    when(
      () => actions.addBottles(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
        n: any(named: 'n'),
      ),
    ).thenAnswer((_) async => const SaveAccepted());
    when(
      () => actions.removeBottle(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
      ),
    ).thenAnswer((_) async => const SaveAccepted());
    when(
      () => actions.deleteWine(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
      ),
    ).thenAnswer((_) async => DeleteOutcome.deleted);
    when(
      () => actions.merge(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        older: any(named: 'older'),
        newer: any(named: 'newer'),
      ),
    ).thenAnswer((_) async => MergeResult.merged);
    when(
      () => actions.updateRecord(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        record: any(named: 'record'),
        wine: any(named: 'wine'),
        rating: any(named: 'rating'),
        notes: any(named: 'notes'),
        drankOn: any(named: 'drankOn'),
        condition: any(named: 'condition'),
      ),
    ).thenAnswer((_) async => const SaveAccepted());
  }

  final wines = MockWineRepository();
  final cellars = MockCellarRepository();
  final watcher = MockSyncWatcher();
  final records = MockDrinkingRecordRepository();
  final actions = MockCellarActions();
  final catalog = FakeWineCatalog();
  final network = FakeCellarNetwork();
  final sink = RecordingErrorSink();
  final clock = FakeClock(DateTime(2026, 11, 6, 20));
  final cellar = StreamController<CellarSnapshot>.broadcast();
  final winesStream = StreamController<WinesSnapshot>.broadcast();
  final ledger = LocalLedger(
    store: InMemoryKeyValueStore(),
    reporter: recordingReporter(RecordingErrorSink()),
  );

  /// The drinks [records] returns for any wine.
  List<DrinkingRecord> drinks = const [];

  /// The entries [CellarActions.entriesLike] returns (BR1.20).
  List<Wine> duplicates = const [];
  bool newerHasDrinks = false;

  List<Override> get overrides => [
    cellarRepositoryProvider.overrideWithValue(cellars),
    wineRepositoryProvider.overrideWithValue(wines),
    syncWatcherProvider.overrideWithValue(watcher),
    localLedgerProvider.overrideWithValue(ledger),
    idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
    clockProvider.overrideWithValue(clock),
    errorReporterProvider.overrideWithValue(recordingReporter(sink)),
    networkStatusProvider.overrideWithValue(network),
    cellarActionsProvider.overrideWithValue(actions),
    ...cellarServiceOverrides(catalog: catalog, records: records),
    ...noSharingOverrides(),
  ];

  void emitCellar() => cellar.add(
    const CellarSnapshot(
      cellar: Cellar(id: 'user-a', ownerId: 'user-a', name: 'La mia cantina'),
      meta: serverMeta,
    ),
  );

  void emitWines(List<Wine> list, {SnapshotMeta meta = serverMeta}) =>
      winesStream.add(WinesSnapshot(wines: list, meta: meta));
}
