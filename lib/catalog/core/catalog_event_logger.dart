// The catalog's only way out to logs and Crashlytics (observability-design.md,
// NFR6.6, NFR8.3). Every method takes enums and numbers only, so no query,
// label text, barcode or URL can ever reach a log through it.
//
// label-recognition (observability-requirements.md): four informative
// events printed to the console only (`wine_db_opened`, `label_outcome`,
// `online_search`, `lens_opened`, NFR4.13) and one more non-fatal error for
// Crashlytics, `wine_db_unavailable` (NFR4.15); still enums and numbers
// only (NFR4.14).

import 'wine_catalog.dart' show LabelMatchStep;

export 'wine_catalog.dart' show LabelMatchStep;

/// Why the offline wine database could not be opened (NFR4.15): a closed
/// list, sent as its [wireName].
enum WineDbFailure {
  missing('missing'),
  corruptGzip('corrupt_gzip'),
  noValidRows('no_valid_rows'),
  unexpected('unexpected');

  const WineDbFailure(this.wireName);

  final String wireName;
}

/// The outcome shown after a label reading (label-recognition BR3.4).
enum LabelOutcomeKind { sure, candidates, unreadable, barcodeNotFound, noMatch }

/// How the front photo left for Google Lens (label-recognition BR5.2):
/// straight to the Google app, through the share menu, or not at all.
enum LensRoute { direct, chooser, failed }

/// Kind of a failed Open Food Facts request (reliability-design.md).
enum OffFailureKind {
  timeout('timeout'),
  network('network'),
  http('http'),
  tooLarge('too_large'),
  invalidJson('invalid_json');

  const OffFailureKind(this.wireName);

  /// Name used in Crashlytics, as in NFR6.6.
  final String wireName;
}

/// A failed request: its kind and, for [OffFailureKind.http], the status.
class OffFailure {
  const OffFailure(this.kind) : statusCode = null;

  const OffFailure.http(int this.statusCode) : kind = OffFailureKind.http;

  final OffFailureKind kind;
  final int? statusCode;

  /// `timeout`, `network`, `http_<code>`, `too_large` or `invalid_json`.
  String get label =>
      kind == OffFailureKind.http ? 'http_$statusCode' : kind.wireName;

  @override
  bool operator ==(Object other) =>
      other is OffFailure &&
      other.kind == kind &&
      other.statusCode == statusCode;

  @override
  int get hashCode => Object.hash(kind, statusCode);

  @override
  String toString() => 'OffFailure($label)';
}

/// Session counters of the catalog at one moment (NFR6.7), sent only
/// together with an `off_suspended` event.
class CatalogHealthSnapshot {
  const CatalogHealthSnapshot({
    required this.offOk,
    required this.offFailed,
    required this.cacheHitRatio,
    required this.cacheResets,
  });

  /// Open Food Facts requests answered `found` or `notFound`.
  final int offOk;
  final int offFailed;

  /// Share of cache lookups answered from the cache, 0 to 1.
  final double cacheHitRatio;
  final int cacheResets;
}

/// Debug-only events: printed in debug builds, never sent anywhere.
enum CatalogDebugEvent {
  offDisabled,
  // label-recognition FR5: no network, Open Food Facts not asked.
  offSkippedOffline,
  offSkippedSuspended,
  offSkippedBudget,
  offFound,
  offNotFound,
  offFailed,
  offResponseDiscarded,
  cacheHit,
  cacheReset,
  cacheOwnerMismatch,
  cacheWriteFailed,
  cacheCleared,
}

/// Destination of the catalog events, injected (Crashlytics in production,
/// a recording fake in tests).
abstract interface class CatalogEventLogger {
  /// Open Food Facts was suspended after three failures in a row (BR2.2):
  /// the only event sent to Crashlytics.
  void offSuspended(OffFailure lastFailure, CatalogHealthSnapshot health);

  /// A debug event; [failure] only for [CatalogDebugEvent.offFailed].
  void debug(CatalogDebugEvent event, {OffFailure? failure});

  /// `wine_db_opened`, console only: wines loaded and opening time
  /// (NFR2.3, NFR4.13).
  void wineDbOpened(int wineCount, int durationMs);

  /// `wine_db_unavailable`: the database is missing or broken in this build
  /// (NFR4.5, NFR4.15); the only new event sent to Crashlytics.
  void wineDbUnavailable(WineDbFailure reason, int skippedRows);

  /// `label_outcome`, console only: the outcome and the step that decided
  /// it (NFR4.13).
  void labelOutcome(LabelOutcomeKind kind, LabelMatchStep step);

  /// `online_search`, console only: how many offline and online results,
  /// and whether Open Food Facts was unavailable (NFR4.13).
  void onlineSearch(int offlineCount, int onlineCount, {required bool limited});

  /// `lens_opened`, console only: direct or through the share menu
  /// (NFR4.13).
  void lensOpened(LensRoute route);
}

/// Prints event names and outcomes through [sink] when [debugLogging] is
/// on (the provider sets it from `kDebugMode`, so the core never imports
/// Flutter); prints nothing otherwise.
class ConsoleCatalogEventLogger implements CatalogEventLogger {
  const ConsoleCatalogEventLogger({
    required this.debugLogging,
    void Function(String message)? sink,
  }) : _sink = sink ?? _discard;

  final bool debugLogging;
  final void Function(String message) _sink;

  static void _discard(String message) {}

  @override
  void offSuspended(OffFailure lastFailure, CatalogHealthSnapshot health) {
    if (!debugLogging) return;
    _sink(
      'catalog: off_suspended (${lastFailure.label}); ok ${health.offOk}, '
      'failed ${health.offFailed}, cache hit ratio '
      '${health.cacheHitRatio.toStringAsFixed(2)}, cache resets '
      '${health.cacheResets}',
    );
  }

  @override
  void debug(CatalogDebugEvent event, {OffFailure? failure}) {
    if (!debugLogging) return;
    _sink(
      failure == null
          ? 'catalog: ${event.name}'
          : 'catalog: ${event.name} (${failure.label})',
    );
  }

  void _print(String message) {
    if (debugLogging) _sink('catalog: $message');
  }

  @override
  void wineDbOpened(int wineCount, int durationMs) =>
      _print('wine_db_opened ($wineCount wines, $durationMs ms)');

  @override
  void wineDbUnavailable(WineDbFailure reason, int skippedRows) => _print(
    'wine_db_unavailable (${reason.wireName}, $skippedRows rows skipped)',
  );

  @override
  void labelOutcome(LabelOutcomeKind kind, LabelMatchStep step) =>
      _print('label_outcome (${kind.name}, ${step.name})');

  @override
  void onlineSearch(
    int offlineCount,
    int onlineCount, {
    required bool limited,
  }) => _print(
    'online_search ($offlineCount offline, $onlineCount online, '
    'limited: $limited)',
  );

  @override
  void lensOpened(LensRoute route) => _print('lens_opened (${route.name})');
}
