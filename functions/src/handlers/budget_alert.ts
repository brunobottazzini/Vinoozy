// onBudgetAlert (freemium-plus FR9.2; study §8.7): when the month's cost
// goes over the budget, unlink the billing account so the project falls
// back to the free quotas. Cloud Billing sends budget notifications with a
// delay (up to several hours), so a few cents can still be spent: the
// protection limits the loss, it does not make it zero (docs/blaze-switch.md).
import { logger } from 'firebase-functions';
import { Timestamp } from 'firebase-admin/firestore';

import { Collections } from '../config.js';
import { Deps } from '../deps.js';

/** The fields of a Cloud Billing budget notification the guard reads. */
export interface BudgetNotification {
  budgetDisplayName?: string;
  costAmount?: number;
  budgetAmount?: number;
  currencyCode?: string;
  costIntervalStart?: string;
}

export type BudgetOutcome =
  | 'below-budget'
  | 'billing-disabled'
  | 'already-disabled'
  | 'ignored-malformed';

function isAmount(value: unknown): value is number {
  return typeof value === 'number' && Number.isFinite(value) && value >= 0;
}

/** Strictly over the budget: at equality nothing happens. */
export function isOverBudget(payload: BudgetNotification): boolean {
  return (
    isAmount(payload.costAmount) &&
    isAmount(payload.budgetAmount) &&
    payload.costAmount > payload.budgetAmount
  );
}

async function recordEvent(
  deps: Deps,
  messageId: string,
  outcome: BudgetOutcome,
  payload: BudgetNotification,
): Promise<void> {
  try {
    await deps.db.collection(Collections.billingEvents).doc(messageId).set({
      outcome,
      costAmount: payload.costAmount ?? null,
      budgetAmount: payload.budgetAmount ?? null,
      currencyCode: payload.currencyCode ?? null,
      at: Timestamp.fromDate(deps.now()),
    });
  } catch (error) {
    // Without billing Firestore may refuse the write: the log stays.
    logger.error('Billing event not stored', { messageId, outcome, error: (error as Error).name });
  }
}

export async function handleBudgetAlert(
  deps: Deps,
  messageId: string,
  payload: BudgetNotification | null,
): Promise<BudgetOutcome> {
  if (!payload || !isAmount(payload.costAmount) || !isAmount(payload.budgetAmount)) {
    logger.error('Malformed budget notification', { messageId });
    return 'ignored-malformed';
  }
  if (!isOverBudget(payload)) return 'below-budget';
  const projectId = deps.projectId;
  if (!(await deps.billing.isBillingEnabled(projectId))) {
    await recordEvent(deps, messageId, 'already-disabled', payload);
    return 'already-disabled';
  }
  await deps.billing.disableBilling(projectId);
  logger.error('Budget exceeded: billing disabled', {
    projectId,
    costAmount: payload.costAmount,
    budgetAmount: payload.budgetAmount,
    currencyCode: payload.currencyCode,
  });
  await recordEvent(deps, messageId, 'billing-disabled', payload);
  return 'billing-disabled';
}
