// CrashlyticsCatalogEventLogger: one non-fatal `off_suspended` with enum and
// number keys only; never throws (NFR6.6, NFR6.7, NFR8.3).
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/platform/crashlytics_catalog_event_logger.dart';

import 'catalog_test_helpers.dart';

class _MockCrashlytics extends Mock implements FirebaseCrashlytics {}

const _health = CatalogHealthSnapshot(
  offOk: 5,
  offFailed: 3,
  cacheHitRatio: 0.25,
  cacheResets: 1,
);

void main() {
  late _MockCrashlytics crashlytics;

  setUp(() {
    crashlytics = _MockCrashlytics();
    when(() => crashlytics.setCustomKey(any(), any())).thenAnswer((_) async {});
    when(
      () => crashlytics.recordError(
        any(),
        any(),
        reason: any(named: 'reason'),
        fatal: any(named: 'fatal'),
      ),
    ).thenAnswer((_) async {});
  });

  test(
    'NFR6.6 records one non-fatal off_suspended with the session keys',
    () async {
      final logger = CrashlyticsCatalogEventLogger(
        crashlytics,
        debugLogging: false,
      );
      logger.offSuspended(const OffFailure.http(429), _health);
      await settle();
      verify(() => crashlytics.setCustomKey('off_last_failure', 'http_429'));
      verify(() => crashlytics.setCustomKey('off_ok', 5));
      verify(() => crashlytics.setCustomKey('off_failed', 3));
      verify(() => crashlytics.setCustomKey('cache_hit_ratio', 0.25));
      verify(() => crashlytics.setCustomKey('cache_resets', 1));
      final captured = verify(
        () => crashlytics.recordError(
          captureAny(),
          null,
          reason: 'off_suspended',
          fatal: false,
        ),
      ).captured;
      expect(captured.single, isA<OffSuspendedEvent>());
      expect(captured.single.toString(), 'off_suspended');
    },
  );

  test('a failing Crashlytics never throws to the catalog', () async {
    when(() => crashlytics.setCustomKey(any(), any()))
        .thenAnswer((_) async => throw Exception('down'));
    final logger = CrashlyticsCatalogEventLogger(
      crashlytics,
      debugLogging: false,
    );
    logger.offSuspended(const OffFailure(OffFailureKind.timeout), _health);
    await settle();
    verifyNever(
      () => crashlytics.recordError(
        any(),
        any(),
        reason: any(named: 'reason'),
        fatal: any(named: 'fatal'),
      ),
    );
  });

  test('debug events go to the console only, never to Crashlytics', () {
    final lines = <String>[];
    final logger = CrashlyticsCatalogEventLogger(
      crashlytics,
      debugLogging: true,
      sink: lines.add,
    );
    logger
      ..debug(CatalogDebugEvent.offFailed, failure: const OffFailure.http(503))
      ..offSuspended(const OffFailure(OffFailureKind.network), _health);
    expect(lines.first, 'catalog: offFailed (http_503)');
    expect(lines.last, startsWith('catalog: off_suspended (network)'));
    verifyNever(() => crashlytics.log(any()));
  });
}
