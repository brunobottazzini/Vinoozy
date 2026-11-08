import 'package:estimation/estimation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../account/app_user.dart';
import '../app/app_event_logger.dart';
import '../app/error_reporter.dart';
import '../core/clock.dart';
import '../sharing/domain/membership.dart';
import 'data/cellar_errors.dart';
import 'data/wine_repository.dart';
import 'domain/wine.dart';
import 'domain/wine_estimate.dart';
import 'wine_estimator.dart';

/// Why the one-off migration stopped (NFR4.16: a closed list, no text).
enum EstimatesMigrationFailureReason {
  /// The server refused a write: the rules of the build are not deployed.
  permissionDenied,

  /// The local save of a write failed (ledger or cache).
  localWriteFailed,
}

/// The non-fatal error reported as `estimates_migration_failed`: it carries
/// only its reason.
class EstimatesMigrationFailure implements Exception {
  const EstimatesMigrationFailure(this.reason);

  final EstimatesMigrationFailureReason reason;

  @override
  String toString() => 'EstimatesMigrationFailure(${reason.name})';
}

/// Where the attempts of the migration are counted across starts of the app
/// (NFR4.8a: at most 3, in 3 different starts).
abstract interface class MigrationAttemptStore {
  Future<int> attempts(int tablesVersion);

  Future<void> record(int tablesVersion, int attempts);
}

/// Attempts kept in memory: one start of the app (tests, and the fallback).
class MemoryMigrationAttemptStore implements MigrationAttemptStore {
  final Map<int, int> _attempts = {};

  @override
  Future<int> attempts(int tablesVersion) async =>
      _attempts[tablesVersion] ?? 0;

  @override
  Future<void> record(int tablesVersion, int attempts) async =>
      _attempts[tablesVersion] = attempts;
}

/// Attempts kept in the phone preferences, `estimates.migration.v<n>`. An
/// unreadable store counts as no attempt: the migration is never blocked by
/// the phone, only by the server refusals it counts.
class PreferencesMigrationAttemptStore implements MigrationAttemptStore {
  PreferencesMigrationAttemptStore(this._open);

  static const String keyPrefix = 'estimates.migration.v';

  final Future<SharedPreferences> Function() _open;

  @override
  Future<int> attempts(int tablesVersion) async {
    try {
      return (await _open()).getInt('$keyPrefix$tablesVersion') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> record(int tablesVersion, int attempts) async {
    try {
      await (await _open()).setInt('$keyPrefix$tablesVersion', attempts);
    } catch (_) {
      // The next start tries again: at worst one more attempt.
    }
  }
}

/// The one-off estimate of every cellar wine with the new tables
/// (label-autofill-windows BR3.9, NFR4.4, NFR4.7, NFR4.8, NFR4.8a):
///
/// - candidates: wines whose base window comes from the internal rules of
///   an older table version (`tablesVersion` missing or different); catalog
///   windows do not depend on the tables and stay;
/// - one wine at a time with the existing `setEstimate` update, never a
///   batch, and only with `canEdit`; the level and the owner's correction
///   are kept (BR3.8, BR4.4);
/// - offline the writes wait in the queue like the others; an interrupted
///   run continues at the next start, for the wines still on old tables;
/// - a refusal of the server (rules not deployed) stops the migration for
///   this start with one `estimates_migration_failed` (permissionDenied);
///   after 3 starts with a refusal it waits for the next table version.
class EstimatesMigration {
  EstimatesMigration({
    required this._wines,
    required this._reporter,
    required this._clock,
    MigrationAttemptStore? store,
    this._logger = const ConsoleAppEventLogger(debugLogging: false),
    this._estimator = const WineEstimator(),
    this.tablesVersion = estimationTablesVersion,
  }) : _store = store ?? MemoryMigrationAttemptStore();

  /// Most starts with a refusal before the migration waits (NFR4.8a).
  static const int maxAttempts = 3;

  final WineRepository _wines;
  final ErrorReporter _reporter;
  final Clock _clock;
  final MigrationAttemptStore _store;
  final AppEventLogger _logger;
  final WineEstimator _estimator;

  /// The version of the tables the wines are moved to.
  final int tablesVersion;

  bool _stopped = false;
  bool _failureCounted = false;
  int? _attempts;

  /// Whether [wine] was estimated by the rules of other tables than
  /// [version] and must be estimated again.
  static bool needsMigration(
    Wine wine, {
    int version = estimationTablesVersion,
  }) {
    final base =
        wine.baseWindow ?? (wine.windowAdjustment == null ? wine.window : null);
    return base != null &&
        base.source == WindowSource.internalRules &&
        base.tablesVersion != version;
  }

  /// Estimates again the wines of [wines] that need it; returns how many
  /// were written on the phone.
  Future<int> run(
    AccessibleCellar cellar,
    AppUser user,
    Iterable<Wine> wines,
  ) async {
    if (!cellar.canEdit || _stopped) return 0;
    final candidates = [
      for (final wine in wines)
        if (needsMigration(wine, version: tablesVersion)) wine,
    ];
    if (candidates.isEmpty) return 0;
    final attempts = _attempts ??= await _store.attempts(tablesVersion);
    if (attempts >= maxAttempts) {
      _stopped = true;
      return 0;
    }
    final watch = Stopwatch()..start();
    final year = _clock.now().year;
    var written = 0;
    for (final wine in candidates) {
      if (_stopped) break;
      final computed = _estimator.estimate(
        WineFactsInput.ofWine(wine, fallbackYear: year),
        adjustment: wine.windowAdjustment,
        override: wine.windowOverride,
      );
      if (computed.window == null) continue;
      final pairings = wine.pairings;
      final estimate = WineEstimate(
        baseWindow: computed.baseWindow,
        window: computed.window,
        adjustment: computed.adjustment,
        // Catalog pairings stay; internal ones follow the new tables.
        pairings: pairings != null && pairings.source == WindowSource.catalog
            ? pairings
            : computed.pairings,
      );
      final outcome = await _wines.setEstimate(
        cellarId: cellar.cellarId,
        user: user,
        wine: wine,
        estimate: estimate,
        quiet: true,
        onFailure: _onWriteFailure,
      );
      if (outcome is SaveAccepted) {
        written++;
      } else {
        await _fail(EstimatesMigrationFailureReason.localWriteFailed);
      }
    }
    watch.stop();
    _logger.estimatesMigrated(written, watch.elapsedMilliseconds);
    return written;
  }

  void _onWriteFailure(WriteErrorKind kind) {
    // Only a refusal says the rules are missing; a transient failure or an
    // expired session leaves the wine on the old tables for the next start.
    if (kind == WriteErrorKind.rejected) {
      _fail(EstimatesMigrationFailureReason.permissionDenied);
    }
  }

  Future<void> _fail(EstimatesMigrationFailureReason reason) async {
    _stopped = true;
    if (_failureCounted) return;
    _failureCounted = true;
    final attempts = (_attempts ?? 0) + 1;
    _attempts = attempts;
    await _store.record(tablesVersion, attempts);
    await _reporter.report(
      EstimatesMigrationFailure(reason),
      StackTrace.current,
      reason: CellarErrorReasons.estimatesMigrationFailed,
    );
  }
}
