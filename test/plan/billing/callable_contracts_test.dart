// freemium-plus: the Flutter side of the callable contracts of
// functions/README.md (verifyPurchase, reportUsage, reserveAdSlot,
// recordAdOutcome), read leniently and never trusted beyond what they say.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/ads/ad_slot_client.dart';
import 'package:vinoozy/plan/billing/purchase_verifier.dart';
import 'package:vinoozy/usage/functions_usage_report_client.dart';
import 'package:vinoozy/usage/usage_uploader.dart';

void main() {
  test('FR3.3 the package sent to the backend is the Play applicationId, '
      'not the Kotlin namespace', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final applicationId = RegExp(r'applicationId\s*=\s*"([^"]+)"')
        .firstMatch(gradle)
        ?.group(1);
    expect(plusPackageName, applicationId);
    expect(plusPackageName, isNot('com.vinoozy.vinoozy'));
  });

  group('verifyPurchase (FR3.3)', () {
    test('active or grace is verified; pending unlocks nothing', () {
      expect(
        verificationOf({'state': 'active', 'plusActive': true}),
        PurchaseVerificationResult.verified,
      );
      expect(
        verificationOf({'state': 'grace'}),
        PurchaseVerificationResult.verified,
      );
      expect(
        verificationOf({'state': 'pending', 'plusActive': false}),
        PurchaseVerificationResult.pending,
      );
      expect(
        verificationOf({'state': 'expired', 'plusActive': false}),
        PurchaseVerificationResult.invalid,
      );
      expect(verificationOf(null), PurchaseVerificationResult.invalid);
    });

    test('errors by details.reason, then by code', () {
      expect(
        verificationOfError('permission-denied', 'TOKEN_IN_USE'),
        PurchaseVerificationResult.ownedByAnotherAccount,
      );
      expect(
        verificationOfError('failed-precondition', 'WRONG_PRODUCT'),
        PurchaseVerificationResult.invalid,
      );
      expect(
        verificationOfError('not-found', 'PURCHASE_NOT_FOUND'),
        PurchaseVerificationResult.invalid,
      );
      expect(
        verificationOfError('unavailable', 'PLAY_UNAVAILABLE'),
        PurchaseVerificationResult.unavailable,
      );
      expect(
        verificationOfError('unauthenticated'),
        PurchaseVerificationResult.unavailable,
        reason: 'App Check or session: retried later, never "invalid"',
      );
      expect(reasonOf({'reason': 'TOKEN_IN_USE'}), 'TOKEN_IN_USE');
      expect(reasonOf('x'), isNull);
    });
  });

  group('reportUsage (FR6.3)', () {
    test('reads the account total, the reason and the ISO times', () {
      final result = parseUsageReportResult({
        'accepted': false,
        'reason': 'PERIOD_CLOSED',
        'periodId': '2026-09',
        'estimatedReadCount': 5400,
        'estimatedWriteCount': 120,
        'estimatedEgressBytes': 9830400,
        'serverTime': '2026-11-10T09:30:00.000Z',
        'nextResetUtc': '2026-12-01T00:00:00.000Z',
      }, periodId: '2026-09');

      expect(result.accepted, isFalse);
      expect(result.reason, UsageReportResult.periodClosed);
      expect(result.accountTotal.reads, 5400);
      expect(result.accountTotal.egressBytes, 9830400);
      expect(result.serverTime, DateTime.utc(2026, 11, 10, 9, 30));
      expect(result.nextResetUtc, DateTime.utc(2026, 12));
    });

    test('an answer without server time is not trusted', () {
      expect(
        () => parseUsageReportResult({'accepted': true}, periodId: '2026-11'),
        throwsFormatException,
      );
    });

    test('negative or mistyped counts read as 0', () {
      final result = parseUsageReportResult({
        'accepted': true,
        'estimatedReadCount': -3,
        'estimatedWriteCount': 'many',
        'serverTime': '2026-11-10T09:30:00Z',
      }, periodId: '2026-11');
      expect(result.accountTotal.reads, 0);
      expect(result.accountTotal.writes, 0);
      expect(result.nextResetUtc, DateTime.utc(2026, 12));
    });
  });

  group('reserveAdSlot and recordAdOutcome (FR7.2, FR7.6)', () {
    test('only a granted slot with id and day is granted', () {
      final granted = parseReservation({
        'granted': true,
        'reservationId': 'r-1',
        'day': '2026-11-10',
      });
      expect(granted.granted, isTrue);
      expect(granted.reservationId, 'r-1');
      expect(granted.day, '2026-11-10');

      final refused = parseReservation({
        'granted': false,
        'reason': 'ALREADY_RESERVED',
        'reservationId': null,
      });
      expect(refused.granted, isFalse);
      expect(refused.reason, 'ALREADY_RESERVED');
      expect(parseReservation({'granted': true}).granted, isFalse);
    });

    test('the SDK precision names in the backend words', () {
      expect(wirePrecision('publisherProvided'), 'publisher_provided');
      expect(wirePrecision('precise'), 'precise');
      expect(wirePrecision('other'), isNull);
    });
  });
}
