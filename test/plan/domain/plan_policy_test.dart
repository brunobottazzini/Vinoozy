// PlanPolicy (freemium-plus FR2.4, FR3.5, FR6.2, FR7.1, NFR4): the
// `config/policy` document with safe defaults.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/plan/domain/plan_policy.dart';

void main() {
  test('the safe defaults: everything off, freemium-v1, 0.005, 15', () {
    const policy = PlanPolicy.safeDefaults;

    expect(policy.adsEnabled, isFalse);
    expect(policy.capacityLimitEnabled, isFalse);
    expect(policy.purchasesEnabled, isFalse);
    expect(policy.policyVersion, 'freemium-v1');
    expect(policy.usageBudgetEuro, '0.005');
    expect(policy.freeActiveWineLimit, 15);
  });

  test('reads every field of a full document', () {
    final policy = PlanPolicy.fromMap({
      PlanPolicyFields.adsEnabled: true,
      PlanPolicyFields.capacityLimitEnabled: true,
      PlanPolicyFields.purchasesEnabled: true,
      PlanPolicyFields.policyVersion: 'freemium-v2',
      PlanPolicyFields.usageBudgetEuro: '0.010',
      PlanPolicyFields.freeActiveWineLimit: 20,
    });

    expect(
      policy,
      const PlanPolicy(
        adsEnabled: true,
        capacityLimitEnabled: true,
        purchasesEnabled: true,
        policyVersion: 'freemium-v2',
        usageBudgetEuro: '0.010',
        freeActiveWineLimit: 20,
      ),
    );
    expect(policy.hashCode, isNot(PlanPolicy.safeDefaults.hashCode));
  });

  test('an empty document is the safe defaults', () {
    expect(PlanPolicy.fromMap(const {}), PlanPolicy.safeDefaults);
    expect(
      PlanPolicy.fromMap(const {}).hashCode,
      PlanPolicy.safeDefaults.hashCode,
    );
  });

  test('mistyped switches stay off', () {
    final policy = PlanPolicy.fromMap({
      PlanPolicyFields.adsEnabled: 'true',
      PlanPolicyFields.capacityLimitEnabled: 1,
      PlanPolicyFields.purchasesEnabled: null,
      PlanPolicyFields.policyVersion: 7,
    });

    expect(policy, PlanPolicy.safeDefaults);
  });

  test('a budget that is not a plain decimal string keeps 0.005', () {
    for (final value in [0.005, '-0.1', '1e-3', '0,005', '', '.5']) {
      expect(
        PlanPolicy.fromMap({PlanPolicyFields.usageBudgetEuro: value})
            .usageBudgetEuro,
        '0.005',
        reason: '$value',
      );
    }
  });

  test('a limit below 1 or not an integer keeps 15', () {
    for (final value in [0, -3, 2.5, '20']) {
      expect(
        PlanPolicy.fromMap({PlanPolicyFields.freeActiveWineLimit: value})
            .freeActiveWineLimit,
        15,
        reason: '$value',
      );
    }
  });

  test('FR2.4 the effective limit is the legacy limit, else the free one', () {
    expect(PlanPolicy.safeDefaults.effectiveActiveWineLimit(), 15);
    expect(
      PlanPolicy.safeDefaults.effectiveActiveWineLimit(
        legacyActiveWineLimit: 22,
      ),
      22,
    );
  });
}
