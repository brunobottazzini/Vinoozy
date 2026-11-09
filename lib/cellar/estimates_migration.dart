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
import 'domain/wine_classification.dart';
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

/// The one-off migration of every cellar wine to the style profiles
/// (wine-style-profiles BR7.4-BR7.7, D4, NFR4.4, NFR4.6, NFR4.9), which
/// replaces the re-estimate of label-autofill-windows BR3.9:
///
/// - candidates: wines with `migrationVersion` missing or below
///   [tablesVersion]; a migrated wine is never done again (FR4.2);
/// - provenance (BR7.4): a saved type or level is the user's; the empty ones
///   and the style are preselected with [classifyWine] as `auto`; a field
///   chosen by the user is never changed (BR7.2);
/// - the estimate is computed again with the profiles for the internal
///   windows; catalog windows stay; the drink feedback and the owner's
///   correction are kept (BR7.5);
/// - one wine at a time, each in a transaction that reads it again and
///   skips it when its `updatedAt` changed since it was read (another
///   member edited it): it stays to migrate for the next start;
/// - a transaction needs the server: offline the migration does not start
///   (NFR4.9) and starts again when the network comes back;
/// - a refusal of the rules stops it for this start with one
///   `estimates_migration_failed` (permissionDenied); after 3 starts with a
///   refusal it waits for the next table version (BR7.6). Silent (BR7.7).
class EstimatesMigration {
  EstimatesMigration({
    required this._wines,
    required this._reporter,
    required this._clock,
    MigrationAttemptStore? store,
    this._logger = const ConsoleAppEventLogger(debugLogging: false),
    this._estimator = const WineEstimator(),
    this.tablesVersion = estimationTablesVersion,
    Future<bool> Function()? isOnline,
  }) : _store = store ?? MemoryMigrationAttemptStore(),
       _isOnline = isOnline ?? _alwaysOnline;

  static Future<bool> _alwaysOnline() async => true;

  /// Most starts with a refusal before the migration waits (NFR4.8a).
  static const int maxAttempts = 3;

  final WineRepository _wines;
  final ErrorReporter _reporter;
  final Clock _clock;
  final MigrationAttemptStore _store;
  final AppEventLogger _logger;
  final WineEstimator _estimator;
  final Future<bool> Function() _isOnline;

  /// The version the wines are moved to (`migrationVersion`).
  final int tablesVersion;

  bool _stopped = false;
  bool _failureCounted = false;
  int? _attempts;

  /// Whether [wine] still has to be migrated to [version] (BR7.6).
  static bool needsMigration(
    Wine wine, {
    int version = estimationTablesVersion,
  }) => (wine.migrationVersion ?? 0) < version;

  /// The classification of [wine] after the migration (BR7.4): the saved
  /// type and level are the user's, the rest is preselected.
  static WineClassification classificationOf(Wine wine) {
    final type = WineType.tryParse(wine.wineType);
    final stored = WineClassification(
      wineType: type,
      typeSource: type == null ? null : wine.typeSource ?? FieldSource.user,
      level: wine.level,
      levelSource: wine.level == null
          ? null
          : wine.levelSource ?? FieldSource.user,
      style: wine.style,
      styleSource: wine.style == null ? null : wine.styleSource,
    );
    return stored.withPreselection(
      classifyWine(
        wine.name,
        producer: wine.producer,
        denomination: wine.denomination,
        // The saved type is a clue too (its style when nothing else says).
        dbType: type,
        country: wine.displayCountry,
        vintage: wine.vintage,
      ),
    );
  }

  /// Migrates the wines of [wines] that need it; returns how many were
  /// written.
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
    if (!await _isOnline()) return 0;
    final watch = Stopwatch()..start();
    final now = _clock.now();
    var written = 0;
    for (final wine in candidates) {
      if (_stopped) break;
      // A pending write has no server time yet: next start.
      if (wine.updatedAt == null) continue;
      final outcome = await _wines.migrateWine(
        cellarId: cellar.cellarId,
        user: user,
        wineId: wine.id,
        seenUpdatedAt: wine.updatedAt,
        fields: fieldsOf(wine, now),
      );
      switch (outcome) {
        case MigrationWrite.written:
          written++;
        case MigrationWrite.skipped:
          break;
        case MigrationWrite.rejected:
          await _fail(EstimatesMigrationFailureReason.permissionDenied);
        case MigrationWrite.failed:
          // Network or server: the remaining wines wait for the next start.
          _stopped = true;
      }
    }
    watch.stop();
    _logger.estimatesMigrated(written, watch.elapsedMilliseconds);
    return written;
  }

  /// The fields the migration writes for [wine] at [now] (BR7.4).
  Map<String, Object?> fieldsOf(Wine wine, DateTime now) {
    final classification = classificationOf(wine);
    final fields = <String, Object?>{
      ...classification.toFields(),
      WineFields.migrationVersion: tablesVersion,
    };
    // A catalog estimate stays, also for a wine saved with a drink feedback
    // and without a base window: its window is the catalog's.
    final base = wine.baseWindow ?? wine.window;
    if (base != null && base.source == WindowSource.catalog) return fields;
    final migrated = Wine(
      id: wine.id,
      name: wine.name,
      vintage: wine.vintage,
      storedQuantity: wine.storedQuantity,
      producer: wine.producer,
      wineType: classification.wineType?.name,
      region: wine.region,
      denomination: wine.denomination,
      createdAt: wine.createdAt,
      level: classification.level,
      style: classification.style,
      styleSource: classification.styleSource,
      agingStart: wine.agingStart,
    );
    final computed = _estimator.estimate(
      WineFactsInput.ofWine(
        migrated,
        fallbackYear: now.year,
        fallbackMonth: now.month,
      ),
      adjustment: wine.windowAdjustment,
      override: wine.windowOverride,
    );
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
    return {...fields, ...estimate.toFields()};
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
