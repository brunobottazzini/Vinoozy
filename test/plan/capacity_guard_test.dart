// freemium-plus FR2.4, FR2.5: the check before a write that adds an active
// wine, the same rule as the Firestore rules.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/plan/capacity_guard.dart';
import 'package:vinoozy/plan/domain/capabilities.dart';
import 'package:vinoozy/plan/domain/plan_policy.dart';

void main() {
  const limitOn = PlanPolicy(capacityLimitEnabled: true);

  CapacityDecision check({
    PlanPolicy policy = limitOn,
    Capabilities capabilities = Capabilities.free,
    bool ownCellar = true,
    int activeWines = 15,
    int activeDelta = 1,
    int? legacy,
  }) => CapacityGuard.check(
    policy: policy,
    capabilities: capabilities,
    ownCellar: ownCellar,
    activeWines: activeWines,
    activeDelta: activeDelta,
    legacyActiveWineLimit: legacy,
  );

  test('FR2.4 15 of 15: the 16th is blocked with the limit and count', () {
    final decision = check() as CapacityBlocked;
    expect(decision.limit, 15);
    expect(decision.activeWines, 15);
  });

  test('FR2.4 14 of 15: the 15th is allowed', () {
    expect(check(activeWines: 14), isA<CapacityAllowed>());
  });

  test('FR2.4 more bottles of an active wine are never blocked', () {
    expect(check(activeDelta: 0), isA<CapacityAllowed>());
    expect(check(activeWines: 30, activeDelta: -1), isA<CapacityAllowed>());
  });

  test('FR2.3 FR2.4 a legacy limit of 22 replaces 15', () {
    expect(check(activeWines: 21, legacy: 22), isA<CapacityAllowed>());
    expect((check(activeWines: 22, legacy: 22) as CapacityBlocked).limit, 22);
  });

  test('FR2.4 Plus has no limit', () {
    expect(
      check(activeWines: 40, capabilities: Capabilities.plus),
      isA<CapacityAllowed>(),
    );
  });

  test('FR2.4 FR2.6 with the limit off nothing is blocked', () {
    expect(
      check(policy: PlanPolicy.safeDefaults, activeWines: 99),
      isA<CapacityAllowed>(),
    );
  });

  test('FR2.1 in a shared cellar the owner\'s plan decides: the rules', () {
    expect(check(ownCellar: false, activeWines: 50), isA<CapacityAllowed>());
  });

  test(
    'FR1.5 after Plus with 30 wines: editing stays, a new one is blocked',
    () {
      expect(check(activeWines: 30, activeDelta: 0), isA<CapacityAllowed>());
      expect(check(activeWines: 30), isA<CapacityBlocked>());
    },
  );
}
