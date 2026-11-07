// Open Food Facts is a help, never a block (BR2.2, reliability-design.md):
// after 3 failures in a row it is suspended for 5 minutes; a `found` or
// `notFound` answer resets the count. No request is ever retried (NFR6.3).

import '../../core/clock.dart';
import 'catalog_event_logger.dart';

/// Session counters of the catalog (NFR6.7). They leave the phone only
/// together with an `off_suspended` event.
class CatalogHealth {
  int _offOk = 0;
  int _offFailed = 0;
  int _cacheLookups = 0;
  int _cacheHits = 0;
  int _cacheResets = 0;

  void recordOffSuccess() => _offOk++;

  void recordOffFailure() => _offFailed++;

  void recordCacheLookup({required bool hit}) {
    _cacheLookups++;
    if (hit) _cacheHits++;
  }

  void recordCacheReset() => _cacheResets++;

  CatalogHealthSnapshot snapshot() => CatalogHealthSnapshot(
    offOk: _offOk,
    offFailed: _offFailed,
    cacheHitRatio: _cacheLookups == 0 ? 0 : _cacheHits / _cacheLookups,
    cacheResets: _cacheResets,
  );
}

/// Two states: closed (Open Food Facts usable) and open (suspended until a
/// precise instant of the injected clock).
class OffCircuitBreaker {
  OffCircuitBreaker({
    required this._clock,
    required this._logger,
    required this._health,
  });

  /// Failures in a row that suspend Open Food Facts.
  static const int failureThreshold = 3;

  /// How long a suspension lasts.
  static const Duration suspension = Duration(minutes: 5);

  final Clock _clock;
  final CatalogEventLogger _logger;
  final CatalogHealth _health;

  int _consecutiveFailures = 0;
  DateTime? _suspendedUntil;

  /// True while Open Food Facts is suspended.
  bool get isSuspended {
    final until = _suspendedUntil;
    return until != null && _clock.now().isBefore(until);
  }

  /// Whether a request may start now. A suspension that has ended closes
  /// the breaker: the next request is a normal one.
  bool allowRequest() {
    if (isSuspended) return false;
    _suspendedUntil = null;
    return true;
  }

  /// A `found` or `notFound` answer.
  void recordSuccess() {
    _consecutiveFailures = 0;
    _health.recordOffSuccess();
  }

  /// A failed request; the third in a row suspends Open Food Facts and
  /// records one `off_suspended` event with its kind (NFR6.6).
  void recordFailure(OffFailure failure) {
    _health.recordOffFailure();
    _consecutiveFailures++;
    if (_consecutiveFailures < failureThreshold) return;
    _consecutiveFailures = 0;
    _suspendedUntil = _clock.now().add(suspension);
    _logger.offSuspended(failure, _health.snapshot());
  }
}
