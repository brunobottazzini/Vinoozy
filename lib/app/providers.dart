import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account/account_gate.dart';
import '../account/auth_service.dart';
import '../account/network_status.dart';
import '../cellar/cellar_providers.dart'
    show
        archivedWinesProvider,
        historyPagerProvider,
        recentDrinksProvider,
        wineProvider;
import '../cellar/data/cellar_repository.dart';
import '../cellar/data/wine_repository.dart';
import '../core/clock.dart';
import '../core/id_generator.dart';
import '../sharing/sharing_providers.dart' show invalidateSharingListeners;
import '../sync/ledger/local_ledger.dart';
import '../sync/snapshot_meta.dart';
import '../sync/sync_error_bus.dart';
import '../sync/sync_status.dart';
import '../sync/sync_watcher.dart';
import 'error_reporter.dart';

/// Service providers. The ones without a default are created at start-up
/// (lib/app/bootstrap.dart) and injected with `overrideWithValue`; tests
/// override them with fakes.
Never _injected(String name) =>
    throw UnimplementedError('$name must be overridden at start-up');

final errorReporterProvider = Provider<ErrorReporter>(
  (ref) => _injected('errorReporterProvider'),
);
final authServiceProvider = Provider<AuthService>(
  (ref) => _injected('authServiceProvider'),
);
final localLedgerProvider = Provider<LocalLedger>(
  (ref) => _injected('localLedgerProvider'),
);
final cellarRepositoryProvider = Provider<CellarRepository>(
  (ref) => _injected('cellarRepositoryProvider'),
);
final wineRepositoryProvider = Provider<WineRepository>(
  (ref) => _injected('wineRepositoryProvider'),
);

/// Has no dependencies, so it also works in the start-up error screen.
final syncErrorBusProvider = Provider<SyncErrorBus>((ref) {
  final bus = SyncErrorBus();
  ref.onDispose(bus.close);
  return bus;
});
final syncWatcherProvider = Provider<SyncWatcher>(
  (ref) => _injected('syncWatcherProvider'),
);
final accountGateProvider = Provider<AccountGate>(
  (ref) => _injected('accountGateProvider'),
);
final networkStatusProvider = Provider<NetworkStatus>(
  (ref) => ConnectivityNetworkStatus(),
);
final clockProvider = Provider<Clock>((ref) => const SystemClock());
final idGeneratorProvider = Provider<IdGenerator>((ref) => RandomIdGenerator());

/// The only listener on `cellars/{cellarId}` (NFR5.1), keyed by the active
/// cellar since u7-sharing (the personal cellar id is the uid). Invalidated
/// by the reset.
final cellarStreamProvider = StreamProvider.autoDispose
    .family<CellarSnapshot, String>(
      (ref, cellarId) =>
          ref.watch(cellarRepositoryProvider).watchCellar(cellarId),
    );

/// The only listener on `cellars/{cellarId}/wines` (NFR5.1). Invalidated by
/// the reset.
final winesStreamProvider = StreamProvider.autoDispose
    .family<WinesSnapshot, String>(
      (ref, cellarId) =>
          ref.watch(wineRepositoryProvider).watchCellarWines(cellarId),
    );

/// Whether drinks are waiting to reach the server (u4-cellar NFR6.6). Set by
/// `PendingWritesProbe` (wired in lib/app/bootstrap.dart); no listener.
final drinkingRecordsPendingProvider =
    NotifierProvider<DrinkingRecordsPending, bool>(DrinkingRecordsPending.new);

class DrinkingRecordsPending extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool pending) => state = pending;
}

/// Ledger state for the rejected-wine notice.
final ledgerStateProvider = StreamProvider.autoDispose<LedgerState>(
  (ref) => ref.watch(localLedgerProvider).watch(),
);

/// Sync state derived from the two listeners above, without opening new ones
/// (performance-design.md: syncStatusProvider). Keyed by the active cellar
/// id since u7-sharing.
final syncStatusProvider = NotifierProvider.autoDispose
    .family<SyncStatusNotifier, SyncState, String>(SyncStatusNotifier.new);

class SyncStatusNotifier extends Notifier<SyncState> {
  SyncStatusNotifier(this.cellarId);

  final String cellarId;
  final SyncStatusTracker _tracker = SyncStatusTracker();

  @override
  SyncState build() {
    var building = true;
    ref.listen<AsyncValue<CellarSnapshot>>(
      cellarStreamProvider(cellarId),
      (_, next) => _feed(SyncSource.cellar, next.value?.meta, building),
      fireImmediately: true,
    );
    ref.listen<AsyncValue<WinesSnapshot>>(
      winesStreamProvider(cellarId),
      (_, next) => _feed(SyncSource.wines, next.value?.meta, building),
      fireImmediately: true,
    );
    // u4-cellar: queued drinks keep the banner "pending" (PendingWritesProbe).
    ref.listen<bool>(drinkingRecordsPendingProvider, (_, pending) {
      final next = _tracker.setPending(SyncSource.drinkingRecords, pending);
      if (!building) state = next;
    }, fireImmediately: true);
    building = false;
    return _tracker.state;
  }

  void _feed(SyncSource source, SnapshotMeta? meta, bool building) {
    if (meta == null) return;
    final update = _tracker.onSnapshot(source, meta);
    // Network back: verify pending writes (security-design.md §4).
    if (update.backOnline) ref.read(syncWatcherProvider).trigger();
    // During build the returned value is the state; setting it is not allowed.
    if (!building) state = update.state;
  }
}

/// Recreates the cellar and wines listeners after "Try again" on the cellar
/// error (security-design.md §6): a stream closed by an error, such as a
/// rules rejection, stays in error until its provider is rebuilt. Since
/// u7-sharing it also reopens the person's invitations and the active
/// cellar (functional-spec.md, "Integrazione con U1").
void reopenCellarListeners(ProviderContainer container) {
  container
    ..invalidate(cellarStreamProvider)
    ..invalidate(winesStreamProvider);
  invalidateSharingListeners(container);
}

/// Invalidates every provider that holds a Firestore listener, before the
/// local data is cleared (NFR4.10; u7 NFR6.4: the invitations too).
void invalidateFirestoreListeners(ProviderContainer container) {
  container
    ..invalidate(cellarStreamProvider)
    ..invalidate(winesStreamProvider)
    ..invalidate(syncStatusProvider)
    ..invalidate(ledgerStateProvider)
    // u4-cellar: the single-wine listener and the cellar reads.
    ..invalidate(wineProvider)
    ..invalidate(archivedWinesProvider)
    ..invalidate(recentDrinksProvider)
    ..invalidate(historyPagerProvider);
  invalidateSharingListeners(container);
}
