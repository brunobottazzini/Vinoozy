import '../app/error_reporter.dart';
import '../firebase/firestore_bootstrap.dart';
import '../sync/ledger/local_ledger.dart';
import '../sync/sync_watcher.dart';

/// How a local reset ended (NFR4.10).
enum ResetOutcome {
  /// Local data cleared; the new account may open its cellar.
  completed,

  /// Plan B: Firestore cannot be reused in this process; the app must be
  /// restarted, and the next start clears the data before any use.
  restartRequired,

  /// Clearing failed: the account stays blocked with "Try again".
  failed,
}

/// The single entry point of the local reset (logical-components.md,
/// "Isolamento"; security-design.md §5).
///
/// Order: stop SyncWatcher, invalidate the listeners, mark `resetPending`,
/// reset the ledger (its new generation silences callbacks of earlier
/// writes), and only then clear Firestore.
class ResetCoordinator {
  ResetCoordinator({
    required this._ledger,
    required this._bootstrap,
    required this._watcher,
    required this._reporter,
    required this._invalidateListeners,
    this._inProcessReset = kInProcessFirestoreReset,
  });

  final LocalLedger _ledger;
  final FirestoreBootstrap _bootstrap;
  final SyncWatcher _watcher;
  final ErrorReporter _reporter;
  final void Function() _invalidateListeners;
  final bool _inProcessReset;

  Future<ResetOutcome> reset(String newUid) async {
    _watcher.stop();
    _invalidateListeners();
    try {
      await _ledger.setResetPending(true);
      await _ledger.reset(newUid);
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'ResetLedgerFailed');
      return ResetOutcome.failed;
    }
    if (!_inProcessReset) return ResetOutcome.restartRequired;
    try {
      await _bootstrap.resetPersistence();
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'ResetPersistenceFailed');
      return ResetOutcome.failed;
    }
    try {
      await _ledger.setResetPending(false);
    } catch (error, stack) {
      // The data is already cleared; the next start would only clear the
      // (empty) cache again, so the reset still counts as completed.
      await _reporter.report(error, stack, reason: 'ResetLedgerFailed');
    }
    return ResetOutcome.completed;
  }
}
