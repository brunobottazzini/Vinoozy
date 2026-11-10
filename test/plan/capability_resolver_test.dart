// freemium-plus FR1.2, FR1.5, FR5.3, FR5.4: the single resolution of the
// plan from the entitlement, the estimated server time and the developer
// override.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/dev/dev_cheats.dart';
import 'package:vinoozy/plan/capability_resolver.dart';
import 'package:vinoozy/plan/domain/capabilities.dart';
import 'package:vinoozy/plan/domain/entitlement.dart';

import '../helpers/fakes.dart';

void main() {
  final now = DateTime.utc(2026, 11, 10, 12);

  Entitlement entitlement({
    String status = 'active',
    String source = 'play_purchase',
    DateTime? expiresAt,
    bool noExpiry = false,
    String? reason,
  }) => Entitlement.fromMap('user-a', {
    'plan': 'plus',
    'source': source,
    'status': status,
    if (!noExpiry) 'expiresAt': expiresAt ?? now.add(const Duration(days: 30)),
    'reason': ?reason,
  });

  ResolvedPlan resolve(Entitlement? e, {DevOverride? override}) =>
      CapabilityResolver.resolve(
        entitlement: e,
        serverNow: now,
        override: override,
      );

  test('FR1.2 no entitlement is the free plan', () {
    final plan = resolve(null);
    expect(plan, ResolvedPlan.free);
    expect(plan.capabilities, Capabilities.free);
  });

  test('FR1.2 active with expiresAt in the future is Plus', () {
    final plan = resolve(entitlement());
    expect(plan.tier, const PlanTier(PlanKind.plus, PlanOrigin.playPurchase));
    expect(plan.capabilities.unlimitedActiveWines, isTrue);
    expect(plan.capabilities.adFree, isTrue);
  });

  test('FR1.2 a valid grace period is Plus', () {
    expect(resolve(entitlement(status: 'grace')).tier.isPlus, isTrue);
  });

  test('FR1.2 expired, revoked, on hold and paused are the free plan', () {
    for (final status in ['expired', 'revoked', 'on_hold', 'paused', 'new']) {
      expect(
        resolve(entitlement(status: status)),
        ResolvedPlan.free,
        reason: status,
      );
    }
  });

  test('FR1.2 FR1.5 an expiresAt in the past is the free plan', () {
    expect(
      resolve(entitlement(expiresAt: now.subtract(const Duration(seconds: 1)))),
      ResolvedPlan.free,
    );
    expect(resolve(entitlement(expiresAt: now)), ResolvedPlan.free);
  });

  test('FR1.3 a manual grant without expiry is Plus "in regalo"', () {
    final plan = resolve(
      entitlement(source: 'manual_grant', noExpiry: true, reason: 'gift'),
    );
    expect(plan.tier, const PlanTier(PlanKind.plus, PlanOrigin.manualGrant));
  });

  test('FR1.2 a purchase without expiresAt never gives Plus', () {
    expect(resolve(entitlement(noExpiry: true)), ResolvedPlan.free);
  });

  test('FR5.3 FR5.4 the developer override wins and is marked', () {
    final unlock = resolve(
      null,
      override: const DevOverride(scenario: DevScenario.unlockAll, uid: 'u'),
    );
    expect(
      unlock.tier,
      const PlanTier(PlanKind.plus, PlanOrigin.developerOverride),
    );
    expect(unlock.scenario, DevScenario.unlockAll);

    for (final scenario in [
      DevScenario.simulateFree,
      DevScenario.simulateExpired,
    ]) {
      final plan = resolve(
        entitlement(),
        override: DevOverride(scenario: scenario, uid: 'u'),
      );
      expect(plan.tier.kind, PlanKind.free);
      expect(plan.tier.origin, PlanOrigin.developerOverride);
      expect(plan.scenario, scenario);
      expect(plan.capabilities, Capabilities.free);
    }
  });

  test('the server time estimate follows the learnt offset', () {
    final clock = FakeClock(now);
    final server = ServerTimeEstimate(clock: clock);
    expect(server.now(), now);

    server.learn(now.add(const Duration(minutes: 3)));
    clock.current = now.add(const Duration(hours: 1));

    expect(server.now(), now.add(const Duration(hours: 1, minutes: 3)));
  });
}
