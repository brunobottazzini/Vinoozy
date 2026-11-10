// PlanTier and Capabilities (freemium-plus FR1.2): one answer per plan.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/plan/domain/capabilities.dart';

void main() {
  test('the free plan has no Plus capability', () {
    expect(PlanTier.free.isPlus, isFalse);
    expect(Capabilities.of(PlanTier.free), Capabilities.free);
    expect(Capabilities.free.unlimitedActiveWines, isFalse);
    expect(Capabilities.free.adFree, isFalse);
  });

  test('every Plus origin has both Plus capabilities', () {
    for (final origin in PlanOrigin.values) {
      final tier = PlanTier(PlanKind.plus, origin);
      expect(tier.isPlus, isTrue);
      expect(Capabilities.of(tier), Capabilities.plus, reason: origin.name);
    }
    expect(Capabilities.plus.unlimitedActiveWines, isTrue);
    expect(Capabilities.plus.adFree, isTrue);
  });

  test('a simulated free plan of the developer tools is still free', () {
    const tier = PlanTier(PlanKind.free, PlanOrigin.developerOverride);
    expect(Capabilities.of(tier), Capabilities.free);
    expect(tier, isNot(PlanTier.free));
  });

  test('value equality and a readable description', () {
    const gift = PlanTier(PlanKind.plus, PlanOrigin.manualGrant);
    expect(gift, const PlanTier(PlanKind.plus, PlanOrigin.manualGrant));
    expect(
      gift.hashCode,
      const PlanTier(PlanKind.plus, PlanOrigin.manualGrant).hashCode,
    );
    expect(gift.toString(), 'PlanTier(plus, manualGrant)');
    expect(Capabilities.free.hashCode, isNot(Capabilities.plus.hashCode));
  });
}
