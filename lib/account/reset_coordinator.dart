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
    this._clearAccountState,
  });

  final LocalLedger _ledger;
  final FirestoreBootstrap _bootstrap;
  final SyncWatcher _watcher;
  final ErrorReporter _reporter;
  final void Function() _invalidateListeners;
  final bool _inProcessReset;

  /// freemium-plus FR1.4, FR5.5, FR6.1: the plan state of the previous
  /// account on this phone (developer override, entitlement copy, usage
  /// counters and upload state). Run before the listeners are invalidated,
  /// so the plan listeners are closed too; a failure is reported and never
  /// stops the reset.
  final Future<void> Function()? _clearAccountState;

  /// Clears the local data before [newUid] opens its cellar.
  ///
  /// u8-account BR1.7 step 7: with [openCellar] false, [newUid] is the account
  /// just deleted; no cellar opens after the reset and no account is recorded
  /// as the phone's last user, so the next sign-in, of any account, opens its
  /// cellar without clearing the (already empty) data again.
  Future<ResetOutcome> reset(String newUid, {bool openCellar = true}) async {
    _watcher.stop();
    final clearAccountState = _clearAccountState;
    if (clearAccountState != null) {
      try {
        await clearAccountState();
      } catch (error, stack) {
        await _reporter.report(error, stack, reason: 'ResetPlanStateFailed');
      }
    }
    _invalidateListeners();
    try {
      await _ledger.setResetPending(true);
      await _ledger.reset(openCellar ? newUid : null);
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
