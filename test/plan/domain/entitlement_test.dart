// Entitlement (freemium-plus FR1.1, FR1.2): lenient mapper of
// `entitlements/{uid}` and the Plus validity test shared with the rules.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/plan/domain/entitlement.dart';

void main() {
  final now = DateTime.utc(2026, 11, 10, 12);

  Map<String, Object?> purchase({
    String status = 'active',
    DateTime? expiresAt,
  }) => {
    EntitlementFields.plan: 'plus',
    EntitlementFields.source: 'play_purchase',
    EntitlementFields.status: status,
    EntitlementFields.expiresAt: expiresAt ?? DateTime.utc(2026, 12, 10),
    EntitlementFields.updatedAt: DateTime.utc(2026, 11, 10),
  };

  group('FR1.1 fromMap', () {
    test('reads every field of a gift', () {
      final entitlement = Entitlement.fromMap('u1', {
        EntitlementFields.plan: 'plus',
        EntitlementFields.source: 'manual_grant',
        EntitlementFields.status: 'active',
        EntitlementFields.reason: 'gift',
        EntitlementFields.startedAt: DateTime.utc(2026, 11, 1),
        EntitlementFields.updatedAt: DateTime.utc(2026, 11, 2),
      });

      expect(entitlement.uid, 'u1');
      expect(entitlement.plan, plusPlanId);
      expect(entitlement.source, EntitlementSource.manualGrant);
      expect(entitlement.status, EntitlementStatus.active);
      expect(entitlement.reason, EntitlementReason.gift);
      expect(entitlement.expiresAt, isNull);
      expect(entitlement.startedAt, DateTime.utc(2026, 11, 1));
      expect(entitlement.updatedAt, DateTime.utc(2026, 11, 2));
      expect(entitlement.isManualGrant, isTrue);
    });

    test('maps every status and reason wire value', () {
      for (final status in EntitlementStatus.values) {
        expect(EntitlementStatus.fromWire(status.wireValue), status);
      }
      expect(EntitlementStatus.fromWire('on_hold'), EntitlementStatus.onHold);
      expect(
        EntitlementReason.fromWire('owner_test'),
        EntitlementReason.ownerTest,
      );
      expect(
        EntitlementSource.fromWire('play_purchase'),
        EntitlementSource.playPurchase,
      );
    });

    test('unknown or mistyped values read as null, never throw', () {
      final entitlement = Entitlement.fromMap('u1', {
        EntitlementFields.plan: 42,
        EntitlementFields.source: 'stolen',
        EntitlementFields.status: true,
        EntitlementFields.expiresAt: 'tomorrow',
        EntitlementFields.reason: 'friend',
      });

      expect(entitlement.plan, isNull);
      expect(entitlement.source, isNull);
      expect(entitlement.status, isNull);
      expect(entitlement.expiresAt, isNull);
      expect(entitlement.reason, isNull);
      expect(entitlement.isPlusValidAt(now), isFalse);
    });
  });

  group('FR1.2 isPlusValidAt', () {
    test('active with a future expiry gives Plus', () {
      expect(Entitlement.fromMap('u1', purchase()).isPlusValidAt(now), isTrue);
    });

    test('a valid grace period gives Plus', () {
      expect(
        Entitlement.fromMap('u1', purchase(status: 'grace')).isPlusValidAt(now),
        isTrue,
      );
    });

    test('expired, revoked, on hold and paused never give Plus', () {
      for (final status in ['expired', 'revoked', 'on_hold', 'paused']) {
        expect(
          Entitlement.fromMap(
            'u1',
            purchase(status: status),
          ).isPlusValidAt(now),
          isFalse,
          reason: status,
        );
      }
    });

    test('an expiry in the past, or equal to now, does not give Plus', () {
      expect(
        Entitlement.fromMap(
          'u1',
          purchase(expiresAt: DateTime.utc(2026, 11, 9)),
        ).isPlusValidAt(now),
        isFalse,
      );
      expect(
        Entitlement.fromMap('u1', purchase(expiresAt: now)).isPlusValidAt(now),
        isFalse,
      );
    });

    test('no expiry gives Plus only to a manual grant', () {
      final gift = Entitlement.fromMap('u1', {
        EntitlementFields.plan: 'plus',
        EntitlementFields.source: 'manual_grant',
        EntitlementFields.status: 'active',
      });
      final purchaseWithoutExpiry = Entitlement.fromMap(
        'u1',
        purchase()..remove(EntitlementFields.expiresAt),
      );

      expect(gift.isPlusValidAt(now), isTrue);
      expect(purchaseWithoutExpiry.isPlusValidAt(now), isFalse);
    });

    test('a plan other than plus never gives Plus', () {
      expect(
        Entitlement.fromMap('u1', {
          ...purchase(),
          EntitlementFields.plan: 'pro',
        }).isPlusValidAt(now),
        isFalse,
      );
    });
  });
}
