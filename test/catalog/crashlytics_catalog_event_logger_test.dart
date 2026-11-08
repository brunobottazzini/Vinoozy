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

  group('label-recognition events', () {
    test('NFR4.13 the informative events stay on the console, never on '
        'Crashlytics', () async {
      final lines = <String>[];
      final logger = CrashlyticsCatalogEventLogger(
        crashlytics,
        debugLogging: true,
        sink: lines.add,
      );
      logger
        ..wineDbOpened(17000, 840)
        ..labelOutcome(LabelOutcomeKind.candidates, LabelMatchStep.offlineText)
        ..onlineSearch(3, 7, limited: false)
        ..lensOpened(LensRoute.chooser);
      await settle();
      expect(lines, [
        'catalog: wine_db_opened (17000 wines, 840 ms)',
        'catalog: label_outcome (candidates, offlineText)',
        'catalog: online_search (3 offline, 7 online, limited: false)',
        'catalog: lens_opened (chooser)',
      ]);
      verifyNever(() => crashlytics.setCustomKey(any(), any()));
      verifyNever(
        () => crashlytics.recordError(
          any(),
          any(),
          reason: any(named: 'reason'),
          fatal: any(named: 'fatal'),
        ),
      );
    });

    test('NFR4.15 wine_db_unavailable is one non-fatal error with the '
        'reason and the skipped rows only', () async {
      final logger = CrashlyticsCatalogEventLogger(
        crashlytics,
        debugLogging: false,
      );
      logger.wineDbUnavailable(WineDbFailure.corruptGzip, 4);
      await settle();
      verify(() => crashlytics.setCustomKey('wine_db_reason', 'corrupt_gzip'));
      verify(() => crashlytics.setCustomKey('wine_db_skipped_rows', 4));
      final captured = verify(
        () => crashlytics.recordError(
          captureAny(),
          null,
          reason: 'wine_db_unavailable',
          fatal: false,
        ),
      ).captured;
      expect(captured.single, isA<WineDbUnavailableEvent>());
      expect(captured.single.toString(), 'wine_db_unavailable');
      verifyNoMoreInteractions(crashlytics);
    });

    test(
      'NFR4.15 a failing Crashlytics never throws for the database',
      () async {
        when(() => crashlytics.setCustomKey(any(), any()))
            .thenAnswer((_) async => throw Exception('down'));
        final logger = CrashlyticsCatalogEventLogger(
          crashlytics,
          debugLogging: false,
        );
        logger.wineDbUnavailable(WineDbFailure.missing, 0);
        await settle();
      },
    );

    test('NFR4.14 a console without debug logging prints nothing', () {
      final lines = <String>[];
      ConsoleCatalogEventLogger(debugLogging: false, sink: lines.add)
        ..wineDbOpened(1, 1)
        ..wineDbUnavailable(WineDbFailure.unexpected, 0)
        ..labelOutcome(LabelOutcomeKind.noMatch, LabelMatchStep.none)
        ..onlineSearch(0, 0, limited: true)
        ..lensOpened(LensRoute.failed);
      expect(lines, isEmpty);
    });
  });
}
