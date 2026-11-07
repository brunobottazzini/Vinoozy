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
}
