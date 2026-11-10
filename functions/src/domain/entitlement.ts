// Server mirror of lib/plan/domain/entitlement.dart and of the rules
// function `validPlus` (freemium-plus FR1.1, FR1.2).
import { Timestamp } from 'firebase-admin/firestore';

export type EntitlementStatus =
  | 'active'
  | 'grace'
  | 'on_hold'
  | 'paused'
  | 'expired'
  | 'revoked';

export type EntitlementSource = 'play_purchase' | 'manual_grant';

export const PLUS_PLAN_ID = 'plus';

/** Fields of `entitlements/{uid}` as the backend writes them. */
export interface EntitlementDoc {
  plan: typeof PLUS_PLAN_ID;
  source: EntitlementSource;
  status: EntitlementStatus;
  /** Absent only for a manual grant without expiry. */
  expiresAt?: Timestamp | null;
  reason?: 'gift' | 'owner_test';
  startedAt: Timestamp;
  updatedAt: Timestamp;
  /** sha256 of the Play token that set this entitlement (never the token). */
  purchaseTokenHash?: string;
  basePlanId?: string;
}

/** Statuses that can give Plus, and only before `expiresAt`. */
export function statusCanGrantPlus(status: unknown): boolean {
  return status === 'active' || status === 'grace';
}

function toDate(value: unknown): Date | null {
  if (value instanceof Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  return null;
}

/**
 * Whether [data] gives Plus at [now]: plan `plus`, status `active` or
 * `grace`, and `expiresAt` after now, or no `expiresAt` for a manual grant.
 * Unknown or damaged data never gives Plus.
 */
export function isPlusValidAt(
  data: Record<string, unknown> | undefined,
  now: Date,
): boolean {
  if (!data || data.plan !== PLUS_PLAN_ID) return false;
  if (!statusCanGrantPlus(data.status)) return false;
  const rawExpiry = data.expiresAt;
  if (rawExpiry === undefined || rawExpiry === null) {
    return data.source === 'manual_grant';
  }
  const expiry = toDate(rawExpiry);
  return expiry !== null && expiry.getTime() > now.getTime();
}
