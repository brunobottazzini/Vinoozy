import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account/account_gate.dart';
import '../account/auth_service.dart';
import '../account/network_status.dart';
import '../cellar/data/cellar_repository.dart';
import '../cellar/data/wine_repository.dart';
import '../core/clock.dart';
import '../core/id_generator.dart';
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

/// The only listener on `cellars/{uid}` (NFR5.1). Invalidated by the reset.
final cellarStreamProvider = StreamProvider.autoDispose
    .family<CellarSnapshot, String>(
      (ref, uid) => ref.watch(cellarRepositoryProvider).watchCellar(uid),
    );

/// The only listener on `cellars/{uid}/wines` (NFR5.1). Invalidated by the
/// reset.
final winesStreamProvider = StreamProvider.autoDispose
    .family<WinesSnapshot, String>(
      (ref, cellarId) => ref.watch(wineRepositoryProvider).watchWines(cellarId),
    );

/// Ledger state for the rejected-wine notice.
final ledgerStateProvider = StreamProvider.autoDispose<LedgerState>(
  (ref) => ref.watch(localLedgerProvider).watch(),
);

/// Sync state derived from the two listeners above, without opening new ones
/// (performance-design.md: syncStatusProvider).
final syncStatusProvider = NotifierProvider.autoDispose
    .family<SyncStatusNotifier, SyncState, String>(SyncStatusNotifier.new);

class SyncStatusNotifier extends Notifier<SyncState> {
  SyncStatusNotifier(this.uid);

  final String uid;
  final SyncStatusTracker _tracker = SyncStatusTracker();

  @override
  SyncState build() {
    var building = true;
    ref.listen<AsyncValue<CellarSnapshot>>(
      cellarStreamProvider(uid),
      (_, next) => _feed(SyncSource.cellar, next.value?.meta, building),
      fireImmediately: true,
    );
    ref.listen<AsyncValue<WinesSnapshot>>(
      winesStreamProvider(uid),
      (_, next) => _feed(SyncSource.wines, next.value?.meta, building),
      fireImmediately: true,
    );
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

/// Invalidates every provider that holds a Firestore listener, before the
/// local data is cleared (NFR4.10).
void invalidateFirestoreListeners(ProviderContainer container) {
  container
    ..invalidate(cellarStreamProvider)
    ..invalidate(winesStreamProvider)
    ..invalidate(syncStatusProvider)
    ..invalidate(ledgerStateProvider);
}
