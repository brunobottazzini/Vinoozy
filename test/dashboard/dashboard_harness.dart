// Controllable U1 listeners and fakes for the Dashboard provider and widget
// tests (unit-test-instructions.md of u5-dashboard): fake streams behind the
// U1 repositories, a fake clock, a recording ErrorSink, mock preferences and
// a calculator that counts its calls.
import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/cellar.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/dashboard/dashboard_providers.dart';
import 'package:vinoozy/dashboard/domain/dashboard_calculator.dart';
import 'package:vinoozy/dashboard/domain/dashboard_summary.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';

import '../helpers/fakes.dart';
import '../helpers/service_mocks.dart';

import 'package:vinoozy/cellar/data/drinking_record_repository.dart';

import '../cellar/cellar_harness.dart'
    show
        FakeCellarNetwork,
        MockDrinkingRecordRepository,
        cellarServiceOverrides,
        registerCellarFallbacks;
import '../sharing/sharing_harness.dart' show noSharingOverrides;
import 'fixtures.dart';

/// The real calculator, counting its calls (NFR2.3).
class CountingCalculator extends DashboardCalculator {
  int calls = 0;

  @override
  DashboardSummary compute(List<Wine> wines, DateTime today) {
    calls++;
    return super.compute(wines, today);
  }
}

/// U1 listeners of user-a's cellar, fed by the test.
class DashboardStreams {
  DashboardStreams({DateTime? now})
    : clock = FakeClock(now ?? DateTime(2026, 11, 6, 10)) {
    when(() => cellars.watchCellar(dashboardUser.uid))
        .thenAnswer((_) => cellar.stream);
    when(() => wines.watchCellarWines(dashboardUser.uid))
        .thenAnswer((_) => winesStream.stream);
    when(() => watcher.trigger()).thenAnswer((_) async {});
    registerFallbackValue(
      const JournalEntry(wineId: '', cellarId: '', name: '', ownerUid: ''),
    );
    when(() => watcher.reconcileRejected(any())).thenAnswer((_) async => false);
    registerCellarFallbacks();
    when(
      () => records.recordsOfWine(any(), any(), source: any(named: 'source')),
    ).thenAnswer((_) async => const WineRecords(records: [], fromServer: true));
  }

  /// The drinks of u4-cellar (detail and History).
  final records = MockDrinkingRecordRepository();
  final cellars = MockCellarRepository();
  final wines = MockWineRepository();
  final watcher = MockSyncWatcher();
  final cellar = StreamController<CellarSnapshot>.broadcast();
  final winesStream = StreamController<WinesSnapshot>.broadcast();
  final sink = RecordingErrorSink();
  final calculator = CountingCalculator();
  final FakeClock clock;
  final ledger = LocalLedger(
    store: InMemoryKeyValueStore(),
    reporter: recordingReporter(RecordingErrorSink()),
  );

  /// When set, opening the preferences fails with it.
  Object? preferencesError;

  List<Override> get overrides => [
    cellarRepositoryProvider.overrideWithValue(cellars),
    wineRepositoryProvider.overrideWithValue(wines),
    syncWatcherProvider.overrideWithValue(watcher),
    localLedgerProvider.overrideWithValue(ledger),
    idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
    clockProvider.overrideWithValue(clock),
    errorReporterProvider.overrideWithValue(recordingReporter(sink)),
    dashboardCalculatorProvider.overrideWithValue(calculator),
    dashboardPreferencesProvider.overrideWithValue(() async {
      final error = preferencesError;
      if (error != null) throw error;
      return SharedPreferences.getInstance();
    }),
    ...noSharingOverrides(),
    // u4-cellar: the HomeShell starts the cellar maintenance, which follows
    // the network, and the forms use the catalog; safe fakes for all three.
    networkStatusProvider.overrideWithValue(FakeCellarNetwork()),
    ...cellarServiceOverrides(records: records),
  ];

  void emitCellar() => cellar.add(
    const CellarSnapshot(
      cellar: Cellar(id: 'user-a', ownerId: 'user-a', name: 'La mia cantina'),
      meta: fromServer,
    ),
  );

  void emitWines(List<Wine> list, {SnapshotMeta meta = fromServer}) =>
      winesStream.add(snapshotOf(list, meta: meta));

  Future<void> close() async {
    await cellar.close();
    await winesStream.close();
  }
}
