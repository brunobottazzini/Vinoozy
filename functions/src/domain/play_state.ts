// From a Play `SubscriptionPurchaseV2` to an entitlement (freemium-plus
// FR3.3, FR3.4; study §5.3, §5.4).
import { PLUS_BASE_PLANS, PLUS_PRODUCT_ID } from '../config.js';
import { EntitlementStatus } from './entitlement.js';

/** The fields of `purchases.subscriptionsv2.get` the backend reads. */
export interface PlaySubscription {
  subscriptionState?: string | null;
  acknowledgementState?: string | null;
  linkedPurchaseToken?: string | null;
  lineItems?: PlayLineItem[] | null;
}

export interface PlayLineItem {
  productId?: string | null;
  expiryTime?: string | null;
  offerDetails?: { basePlanId?: string | null } | null;
}

export type PlayVerdict =
  /** Not paid yet: nothing is granted (FR3.3). */
  | { kind: 'pending' }
  /** No subscription to apply (cancelled pending purchase, unknown). */
  | { kind: 'none' }
  | {
      kind: 'entitlement';
      status: EntitlementStatus;
      expiresAt: Date | null;
      basePlanId: string | null;
    };

/** The Plus line item, or null when the purchase is for another product. */
export function plusLineItem(sub: PlaySubscription): PlayLineItem | null {
  const item = (sub.lineItems ?? []).find(
    (line) => line.productId === PLUS_PRODUCT_ID,
  );
  if (!item) return null;
  const basePlan = item.offerDetails?.basePlanId;
  if (basePlan && !PLUS_BASE_PLANS.includes(basePlan)) return null;
  return item;
}

function expiryOf(item: PlayLineItem): Date | null {
  if (!item.expiryTime) return null;
  const expiry = new Date(item.expiryTime);
  return Number.isNaN(expiry.getTime()) ? null : expiry;
}

/**
 * The entitlement Play's current state gives. A cancelled subscription
 * stays `active` until its expiry; a revoked one (refund, revocation) is
 * `revoked` whatever Play reports afterwards.
 */
export function verdictFor(
  sub: PlaySubscription,
  item: PlayLineItem,
  now: Date,
  revoked: boolean,
): PlayVerdict {
  const expiresAt = expiryOf(item);
  const basePlanId = item.offerDetails?.basePlanId ?? null;
  const entitlement = (status: EntitlementStatus): PlayVerdict => ({
    kind: 'entitlement',
    status,
    expiresAt,
    basePlanId,
  });
  if (revoked) return entitlement('revoked');
  switch (sub.subscriptionState) {
    case 'SUBSCRIPTION_STATE_PENDING':
      return { kind: 'pending' };
    case 'SUBSCRIPTION_STATE_ACTIVE':
      return entitlement('active');
    case 'SUBSCRIPTION_STATE_CANCELED':
      return entitlement(
        expiresAt !== null && expiresAt.getTime() > now.getTime()
          ? 'active'
          : 'expired',
      );
    case 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD':
      return entitlement('grace');
    case 'SUBSCRIPTION_STATE_ON_HOLD':
      return entitlement('on_hold');
    case 'SUBSCRIPTION_STATE_PAUSED':
      return entitlement('paused');
    case 'SUBSCRIPTION_STATE_EXPIRED':
      return entitlement('expired');
    default:
      return { kind: 'none' };
  }
}

/** Whether Play still waits for the acknowledgement of this purchase. */
export function needsAcknowledge(sub: PlaySubscription): boolean {
  return sub.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_PENDING';
}

/** RTDN `subscriptionNotification.notificationType` of a revocation. */
export const RTDN_SUBSCRIPTION_REVOKED = 12;
