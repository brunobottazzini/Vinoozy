import '../../label/platform/temp_label_store.dart';
import '../../sync/ledger/local_ledger.dart';
import '../../sync/sync_watcher.dart';
import '../reset_coordinator.dart';

/// The phone side of the deletion (BR1.7 steps 0 and 7, BR1.13), behind the
/// app's own interface so the runner is tested without Firebase.
abstract interface class DeletionDevice {
  /// Step 0: stops SyncWatcher and every Firestore listener; they do not
  /// restart until the deletion ends (BR1.13).
  void stopSyncAndListeners();

  /// Step 0: waits for the writes already queued in Firestore. The runner
  /// bounds it to 30 s (NFR1.3).
  Future<void> waitForPendingWrites();

  /// Step 0: clears the ledger of the writes still to confirm, so none is
  /// retried against deleted data.
  Future<void> clearLedger(String uid);

  /// Step 7: local reset of U1 for the deleted account, without opening a
  /// cellar afterwards.
  Future<ResetOutcome> resetPhone(String uid);

  /// Step 7: the temporary label photos of U6 (NFR8.3). Never throws.
  Future<void> clearLabelFiles();
}

/// [DeletionDevice] of the app, wired in lib/app/bootstrap.dart.
class AppDeletionDevice implements DeletionDevice {
  AppDeletionDevice({
    required this._watcher,
    required this._invalidateListeners,
    required this._waitForPendingWrites,
    required this._ledger,
    required this._resets,
    required this._labels,
  });

  final SyncWatcher _watcher;
  final void Function() _invalidateListeners;
  final Future<void> Function() _waitForPendingWrites;
  final LocalLedger _ledger;
  final ResetCoordinator _resets;
  final TempLabelStore Function() _labels;

  @override
  void stopSyncAndListeners() {
    _watcher.stop();
    _invalidateListeners();
  }

  @override
  Future<void> waitForPendingWrites() => _waitForPendingWrites();

  @override
  Future<void> clearLedger(String uid) => _ledger.reset(uid);

  @override
  Future<ResetOutcome> resetPhone(String uid) =>
      _resets.reset(uid, openCellar: false);

  @override
  Future<void> clearLabelFiles() async {
    final labels = _labels()..startCleanup();
    await labels.cleanup;
  }
}
