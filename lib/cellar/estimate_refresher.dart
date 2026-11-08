import 'package:estimation/estimation.dart';

import '../account/app_user.dart';
import '../account/network_status.dart';
import '../app/error_reporter.dart';
import '../catalog/core/wine_catalog.dart';
import '../core/clock.dart';
import '../sharing/domain/membership.dart';
import 'data/cellar_errors.dart';
import 'data/wine_repository.dart';
import 'domain/wine.dart';
import 'domain/wine_estimate.dart';
import 'wine_estimator.dart';

/// Improves the internal estimates with the catalog (BR1.5, BR1.6, BR1.19;
/// NFR5.4, NFR6.4).
///
/// - Candidates: wines without an estimate, and wines whose base window
///   comes from the internal rules (`needsRefinement`).
/// - At most [maxPerRun] wines per network return, one at a time, within
///   the limits of U3 (its own request budget).
/// - Only with `canEdit` on the active cellar: a reader never writes, so it
///   never causes a refusal and a false "access lost" (BR1.19).
/// - A wine is tried once per session; an error on one wine is reported
///   (`estimate_refresh_failed`), leaves it to the next network return and
///   does not stop the others. A result equal to the stored estimate writes
///   nothing.
class EstimateRefresher {
  EstimateRefresher({
    required this._wines,
    required this._catalog,
    required this._network,
    required this._reporter,
    required this._clock,
    this._estimator = const WineEstimator(),
    this.maxPerRun = 20,
  });

  final WineRepository _wines;
  final WineCatalog _catalog;
  final NetworkStatus _network;
  final ErrorReporter _reporter;
  final Clock _clock;
  final WineEstimator _estimator;
  final int maxPerRun;
  final Set<String> _attempted = {};
  bool _running = false;

  /// Whether [wine] should be estimated again with the catalog.
  static bool isCandidate(Wine wine) {
    final base = wine.baseWindow ?? wine.window;
    return base == null || needsRefinement(base);
  }

  /// One run over [wines]; returns how many wines were written.
  Future<int> refresh(
    AccessibleCellar cellar,
    AppUser user,
    Iterable<Wine> wines,
  ) async {
    if (!cellar.canEdit || _running) return 0;
    if (!await _hasNetwork()) return 0;
    _running = true;
    var written = 0;
    try {
      final queue = [
        for (final wine in wines)
          if (isCandidate(wine) && !_attempted.contains(_key(cellar, wine)))
            wine,
      ].take(maxPerRun).toList();
      for (final wine in queue) {
        if (await _refreshOne(cellar, user, wine)) written++;
      }
    } finally {
      _running = false;
    }
    return written;
  }

  /// The wine just saved (BR1.5): refined at once when there is a network,
  /// without delaying the save.
  Future<bool> refreshWine(
    AccessibleCellar cellar,
    AppUser user,
    Wine wine,
  ) async {
    if (!cellar.canEdit || !isCandidate(wine)) return false;
    if (!await _hasNetwork()) return false;
    return _refreshOne(cellar, user, wine);
  }

  Future<bool> _refreshOne(
    AccessibleCellar cellar,
    AppUser user,
    Wine wine,
  ) async {
    final key = _key(cellar, wine);
    _attempted.add(key);
    try {
      final input = WineFactsInput.ofWine(
        wine,
        fallbackYear: _clock.now().year,
      );
      final profile = await _catalog.getWineProfile(
        wine.name,
        producer: wine.producer,
        vintage: wine.vintage,
      );
      // label-autofill-windows BR4.5: the level (in the input) and the
      // owner's correction survive the refinement.
      final refined = _estimator.refine(
        input,
        profile,
        adjustment: wine.windowAdjustment,
        override: wine.windowOverride,
      );
      if (refined.window == null || refined == WineEstimate.of(wine)) {
        return false;
      }
      final outcome = await _wines.setEstimate(
        cellarId: cellar.cellarId,
        user: user,
        wine: wine,
        estimate: refined,
      );
      return outcome is SaveAccepted;
    } catch (error, stack) {
      // Try again at the next network return.
      _attempted.remove(key);
      await _reporter.report(
        error,
        stack,
        reason: CellarErrorReasons.estimateRefreshFailed,
        sensitive: sensitiveOfWine(wine),
      );
      return false;
    }
  }

  Future<bool> _hasNetwork() async {
    try {
      return await _network.hasNetwork();
    } catch (_) {
      // Unknown: the catalog answers from the phone anyway.
      return true;
    }
  }

  static String _key(AccessibleCellar cellar, Wine wine) =>
      '${cellar.cellarId}/${wine.id}';
}
