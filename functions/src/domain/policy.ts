// Server mirror of lib/plan/domain/plan_policy.dart (`config/policy`).
import { isValidBudget } from './usage.js';

export interface PlanPolicy {
  adsEnabled: boolean;
  capacityLimitEnabled: boolean;
  purchasesEnabled: boolean;
  policyVersion: string;
  usageBudgetEuro: string;
  freeActiveWineLimit: number;
}

/** Every default is the safe one: no ads, no limit, no purchases. */
export const SAFE_POLICY: PlanPolicy = Object.freeze({
  adsEnabled: false,
  capacityLimitEnabled: false,
  purchasesEnabled: false,
  policyVersion: 'freemium-v1',
  usageBudgetEuro: '0.005',
  freeActiveWineLimit: 15,
});

function bool(value: unknown): boolean {
  return value === true;
}

/** Reads [data] leniently: a missing or mistyped field keeps its default. */
export function policyFromData(data: Record<string, unknown> | undefined): PlanPolicy {
  if (!data) return { ...SAFE_POLICY };
  const version = data.policyVersion;
  const limit = data.freeActiveWineLimit;
  return {
    adsEnabled: bool(data.adsEnabled),
    capacityLimitEnabled: bool(data.capacityLimitEnabled),
    purchasesEnabled: bool(data.purchasesEnabled),
    policyVersion:
      typeof version === 'string' && version.length > 0
        ? version
        : SAFE_POLICY.policyVersion,
    usageBudgetEuro: isValidBudget(data.usageBudgetEuro)
      ? data.usageBudgetEuro
      : SAFE_POLICY.usageBudgetEuro,
    freeActiveWineLimit:
      typeof limit === 'number' && Number.isInteger(limit) && limit >= 1
        ? limit
        : SAFE_POLICY.freeActiveWineLimit,
  };
}
