// Production event logger of the catalog (observability-design.md, NFR6.6,
// NFR6.7, NFR8.3): one non-fatal `off_suspended` error with the kind of the
// last failure and the session counters as custom keys. The method signatures
// take enums and numbers only, so no query, label text, barcode or URL can
// reach Crashlytics. The only Crashlytics use of the module (NFR5.1).

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../core/catalog_event_logger.dart';

/// The recorded non-fatal error: a fixed message, nothing else.
class OffSuspendedEvent implements Exception {
  const OffSuspendedEvent();

  @override
  String toString() => 'off_suspended';
}

/// [CatalogEventLogger] backed by Crashlytics; debug events go to the
/// console only when [debugLogging] is on.
class CrashlyticsCatalogEventLogger implements CatalogEventLogger {
  CrashlyticsCatalogEventLogger(
    this._crashlytics, {
    required bool debugLogging,
    void Function(String message)? sink,
  }) : _console = ConsoleCatalogEventLogger(
         debugLogging: debugLogging,
         sink: sink,
       );

  final FirebaseCrashlytics _crashlytics;
  final ConsoleCatalogEventLogger _console;

  @override
  void offSuspended(OffFailure lastFailure, CatalogHealthSnapshot health) {
    _console.offSuspended(lastFailure, health);
    // Reporting never throws and never blocks the catalog.
    unawaited(_record(lastFailure, health).catchError((Object _) {}));
  }

  Future<void> _record(
    OffFailure lastFailure,
    CatalogHealthSnapshot health,
  ) async {
    await _crashlytics.setCustomKey('off_last_failure', lastFailure.label);
    await _crashlytics.setCustomKey('off_ok', health.offOk);
    await _crashlytics.setCustomKey('off_failed', health.offFailed);
    await _crashlytics.setCustomKey('cache_hit_ratio', health.cacheHitRatio);
    await _crashlytics.setCustomKey('cache_resets', health.cacheResets);
    await _crashlytics.recordError(
      const OffSuspendedEvent(),
      null,
      reason: 'off_suspended',
      fatal: false,
    );
  }

  @override
  void debug(CatalogDebugEvent event, {OffFailure? failure}) =>
      _console.debug(event, failure: failure);

  // label-recognition NFR4.13: the informative events stay on the console,
  // they would be usage data on Crashlytics.

  @override
  void wineDbOpened(int wineCount, int durationMs) =>
      _console.wineDbOpened(wineCount, durationMs);

  @override
  void labelOutcome(LabelOutcomeKind kind, LabelMatchStep step) =>
      _console.labelOutcome(kind, step);

  @override
  void onlineSearch(
    int offlineCount,
    int onlineCount, {
    required bool limited,
  }) => _console.onlineSearch(offlineCount, onlineCount, limited: limited);

  @override
  void lensOpened(LensRoute route) => _console.lensOpened(route);

  /// label-recognition NFR4.15: a broken build is seen even when the owner
  /// has no phone connected; the reason and one number, nothing else.
  @override
  void wineDbUnavailable(WineDbFailure reason, int skippedRows) {
    _console.wineDbUnavailable(reason, skippedRows);
    unawaited(_recordWineDb(reason, skippedRows).catchError((Object _) {}));
  }

  Future<void> _recordWineDb(WineDbFailure reason, int skippedRows) async {
    await _crashlytics.setCustomKey('wine_db_reason', reason.wireName);
    await _crashlytics.setCustomKey('wine_db_skipped_rows', skippedRows);
    await _crashlytics.recordError(
      const WineDbUnavailableEvent(),
      null,
      reason: 'wine_db_unavailable',
      fatal: false,
    );
  }
}

/// The recorded non-fatal error of a missing or broken offline database.
class WineDbUnavailableEvent implements Exception {
  const WineDbUnavailableEvent();

  @override
  String toString() => 'wine_db_unavailable';
}
