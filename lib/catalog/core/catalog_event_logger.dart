// The catalog's only way out to logs and Crashlytics (observability-design.md,
// NFR6.6, NFR8.3). Every method takes enums and numbers only, so no query,
// label text, barcode or URL can ever reach a log through it.

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
}
