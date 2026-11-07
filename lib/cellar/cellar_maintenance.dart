import '../account/app_user.dart';
import '../account/network_status.dart';
import '../app/error_reporter.dart';
import '../sharing/domain/membership.dart';
import 'cellar_actions.dart';
import 'data/cellar_errors.dart';
import 'data/match_key_backfill.dart';
import 'data/record_reconciler.dart';
import 'data/wine_repository.dart';
import 'domain/wine.dart';
import 'estimate_refresher.dart';

/// The background work of the cellar (logical-components.md; BR1.4, BR1.6,
/// BR1.12, BR1.14, BR1.19; NFR6.6), started when the cellar is opened and
/// when the network comes back (`NetworkStatus.onChanged(true)`):
///
/// 1. the estimate of the wines that have none (offline too);
/// 2. with a network: the one-off `matchKey` backfill, then the key of the
///    loaded wines still without one;
/// 3. the operations left half done offline ([RecordReconciler]);
/// 4. the catalog refinement of the estimates ([EstimateRefresher]).
///
/// Everything runs only with `canEdit` (BR1.19). One run at a time; a
/// failure in one part is reported by that part and never stops the next.
class CellarMaintenance {
  CellarMaintenance({
    required this._backfill,
    required this._reconciler,
    required this._refresher,
    required this._actions,
    required this._wines,
    required this._network,
    required this._reporter,
  });

  final MatchKeyBackfill _backfill;
  final RecordReconciler _reconciler;
  final EstimateRefresher _refresher;
  final CellarActions _actions;
  final WineRepository _wines;
  final NetworkStatus _network;
  final ErrorReporter _reporter;
  bool _running = false;
  _MaintenanceRequest? _queued;

  /// Runs the maintenance of [cellar] with its [loaded] wines; returns false
  /// when it did not run now (read-only cellar, or already running). A
  /// request that arrives while a run is in progress is never run at the
  /// same time: the latest one is queued and runs once right after
  /// (review R-04).
  Future<bool> run(
    AccessibleCellar cellar,
    AppUser user,
    List<Wine> loaded,
  ) async {
    if (!cellar.canEdit) return false;
    if (_running) {
      _queued = _MaintenanceRequest(cellar, user, loaded);
      return false;
    }
    _running = true;
    try {
      return await _runOnce(cellar, user, loaded);
    } finally {
      _running = false;
      final next = _queued;
      _queued = null;
      if (next != null) await run(next.cellar, next.user, next.loaded);
    }
  }

  Future<bool> _runOnce(
    AccessibleCellar cellar,
    AppUser user,
    List<Wine> loaded,
  ) async {
    try {
      await _actions.ensureEstimates(cellar: cellar, user: user, wines: loaded);
      if (!await _hasNetwork()) return true;
      final backfill = await _backfill.run(cellar.cellarId);
      if (backfill != BackfillOutcome.failed) {
        await _backfill.keyLoaded(cellar.cellarId, loaded);
      }
      await _reconciler.run(user.uid, (op) => _perform(cellar, user, op));
      await _refresher.refresh(cellar, user, loaded);
      return true;
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: CellarErrorReasons.reconcileFailed,
      );
      return true;
    }
  }

  /// One pending operation; entries of other cellars wait for their cellar.
  Future<void> _perform(
    AccessibleCellar cellar,
    AppUser user,
    PendingOp op,
  ) async {
    if (op.cellarId != cellar.cellarId) throw const ReconcileLater();
    switch (op.kind) {
      case PendingOpKind.purgeRecords:
        await _wines.purgeRecords(op.cellarId, op.wineId);
      case PendingOpKind.reapplyAdjustment:
        final wine = await _wines.watchWine(op.cellarId, op.wineId).first;
        // A deleted wine has nothing left to adjust.
        if (wine == null) return;
        await _actions.recomputeAdjustment(
          cellar: cellar,
          user: user,
          wine: wine,
          serverOnly: true,
        );
    }
  }

  Future<bool> _hasNetwork() async {
    try {
      return await _network.hasNetwork();
    } catch (_) {
      // Unknown: try; every part handles its own network failure.
      return true;
    }
  }
}

/// A run asked for while another one was in progress.
class _MaintenanceRequest {
  const _MaintenanceRequest(this.cellar, this.user, this.loaded);

  final AccessibleCellar cellar;
  final AppUser user;
  final List<Wine> loaded;
}
