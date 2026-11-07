// OffCircuitBreaker, CatalogHealth and the console logger (BR2.2, NFR6.2,
// NFR6.6, NFR6.7, NFR8.3).
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/off_circuit_breaker.dart';

import 'catalog_test_helpers.dart';

const _http503 = OffFailure.http(503);

class _Harness {
  final clock = FakeClock();
  final logger = RecordingLogger();
  final health = CatalogHealth();
  late final breaker = OffCircuitBreaker(
    clock: clock,
    logger: logger,
    health: health,
  );
}

void main() {
  test(
    'BR2.2 three failures in a row suspend for 5 minutes with one event',
    () {
      final h = _Harness();
      h.breaker
        ..recordFailure(const OffFailure(OffFailureKind.timeout))
        ..recordFailure(const OffFailure(OffFailureKind.network));
      expect(h.breaker.allowRequest(), isTrue);
      h.breaker.recordFailure(_http503);
      expect(h.breaker.isSuspended, isTrue);
      expect(h.breaker.allowRequest(), isFalse);
      expect(h.logger.suspensions, hasLength(1));
      final (failure, health) = h.logger.suspensions.single;
      expect(failure.label, 'http_503');
      expect(health.offFailed, 3);

      h.clock.advance(const Duration(minutes: 5) - const Duration(seconds: 1));
      expect(h.breaker.allowRequest(), isFalse);
      h.clock.advance(const Duration(seconds: 1));
      expect(h.breaker.allowRequest(), isTrue);
      expect(h.breaker.isSuspended, isFalse);
    },
  );

  test('BR2.2 a success resets the count; after a suspension it restarts '
      'from one', () {
    final h = _Harness();
    h.breaker
      ..recordFailure(_http503)
      ..recordFailure(_http503)
      ..recordSuccess()
      ..recordFailure(_http503)
      ..recordFailure(_http503);
    expect(h.breaker.isSuspended, isFalse);
    h.breaker.recordFailure(_http503);
    expect(h.breaker.isSuspended, isTrue);
    h.clock.advance(OffCircuitBreaker.suspension);
    expect(h.breaker.allowRequest(), isTrue);
    h.breaker.recordFailure(_http503);
    expect(h.breaker.isSuspended, isFalse, reason: 'count restarted at 1');
    expect(h.logger.suspensions, hasLength(1));
  });

  test('NFR6.7 health counts successes, failures, hits and resets', () {
    final health = CatalogHealth();
    expect(health.snapshot().cacheHitRatio, 0);
    health
      ..recordOffSuccess()
      ..recordOffFailure()
      ..recordOffFailure()
      ..recordCacheLookup(hit: true)
      ..recordCacheLookup(hit: false)
      ..recordCacheLookup(hit: true)
      ..recordCacheLookup(hit: true)
      ..recordCacheReset();
    final snapshot = health.snapshot();
    expect(snapshot.offOk, 1);
    expect(snapshot.offFailed, 2);
    expect(snapshot.cacheHitRatio, 0.75);
    expect(snapshot.cacheResets, 1);
  });

  group('OffFailure', () {
    test('labels match NFR6.6', () {
      expect(const OffFailure(OffFailureKind.timeout).label, 'timeout');
      expect(const OffFailure(OffFailureKind.network).label, 'network');
      expect(const OffFailure(OffFailureKind.tooLarge).label, 'too_large');
      expect(
        const OffFailure(OffFailureKind.invalidJson).label,
        'invalid_json',
      );
      expect(const OffFailure.http(429).label, 'http_429');
      expect(const OffFailure.http(429), const OffFailure.http(429));
      expect(
        const OffFailure.http(429).hashCode,
        const OffFailure.http(429).hashCode,
      );
      expect(const OffFailure.http(429), isNot(const OffFailure.http(503)));
      expect(const OffFailure.http(301).toString(), 'OffFailure(http_301)');
    });
  });

  group('ConsoleCatalogEventLogger (NFR8.3)', () {
    const health = CatalogHealthSnapshot(
      offOk: 4,
      offFailed: 3,
      cacheHitRatio: 0.5,
      cacheResets: 0,
    );

    test('prints only event names and outcomes when debugLogging is on', () {
      final lines = <String>[];
      final logger = ConsoleCatalogEventLogger(
        debugLogging: true,
        sink: lines.add,
      );
      logger
        ..offSuspended(const OffFailure(OffFailureKind.timeout), health)
        ..debug(CatalogDebugEvent.cacheHit)
        ..debug(
          CatalogDebugEvent.offFailed,
          failure: const OffFailure.http(429),
        );
      expect(lines, [
        'catalog: off_suspended (timeout); ok 4, failed 3, cache hit ratio '
            '0.50, cache resets 0',
        'catalog: cacheHit',
        'catalog: offFailed (http_429)',
      ]);
    });

    test('prints nothing in release (debugLogging off)', () {
      final lines = <String>[];
      ConsoleCatalogEventLogger(debugLogging: false, sink: lines.add)
        ..offSuspended(const OffFailure(OffFailureKind.timeout), health)
        ..debug(CatalogDebugEvent.cacheHit);
      expect(lines, isEmpty);
      // Without a sink nothing is printed either.
      const ConsoleCatalogEventLogger(debugLogging: true)
          .debug(CatalogDebugEvent.cacheHit);
    });
  });
}
