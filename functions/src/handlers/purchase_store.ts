// Shared by verifyPurchase, the RTDN handler and the reconciliation job:
// the private record of a Play token and the entitlement it gives
// (freemium-plus FR3.3, FR3.4; study §5.2–§5.5).
import { createHash } from 'node:crypto';
import { logger } from 'firebase-functions';
import {
  DocumentReference,
  Timestamp,
  Transaction,
} from 'firebase-admin/firestore';

import { Collections, PLUS_PRODUCT_ID } from '../config.js';
import { Deps } from '../deps.js';
import { EntitlementDoc, isPlusValidAt, PLUS_PLAN_ID } from '../domain/entitlement.js';
import { needsAcknowledge, PlaySubscription, PlayVerdict } from '../domain/play_state.js';

/**
 * `purchases/{sha256(token)}`: server only (firestore.rules). It keeps the
 * token itself because the reconciliation and the acknowledgement need it;
 * it is never logged and never copied into `entitlements` (NFR6).
 */
export interface PurchaseRecord {
  /** Null after the account was deleted: the token may bind again. */
  uid: string | null;
  purchaseToken: string;
  productId: string;
  lastState: string;
  /** The reconciliation re-reads Play for this record. */
  reconcile: boolean;
  revoked: boolean;
  acknowledged: boolean;
  /** Event time of the last RTDN applied (out-of-order guard). */
  lastEventAtMillis: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export function tokenHash(purchaseToken: string): string {
  return createHash('sha256').update(purchaseToken, 'utf8').digest('hex');
}

/** A short, non-reversible tag for logs: never the token (NFR6). */
export function logTag(hash: string): string {
  return hash.slice(0, 12);
}

export function purchaseRef(deps: Deps, hash: string): DocumentReference {
  return deps.db.collection(Collections.purchases).doc(hash);
}

export function entitlementRef(deps: Deps, uid: string): DocumentReference {
  return deps.db.collection(Collections.entitlements).doc(uid);
}

/** The state name stored in the purchase record. */
export function stateName(verdict: PlayVerdict): string {
  return verdict.kind === 'entitlement' ? verdict.status : verdict.kind;
}

/** Records that can still change and need the daily reconciliation. */
export function needsReconcile(verdict: PlayVerdict): boolean {
  if (verdict.kind === 'pending') return true;
  if (verdict.kind === 'none') return false;
  return !['expired', 'revoked'].includes(verdict.status);
}

/**
 * The entitlement to write for [verdict], or null to leave [existing] as it
 * is. A state that gives no Plus never replaces a still valid entitlement
 * that another token or a manual grant wrote (an old subscription expiring
 * must not take away a new one or a gift).
 */
export function nextEntitlement(params: {
  existing: Record<string, unknown> | undefined;
  verdict: PlayVerdict;
  hash: string;
  now: Date;
}): EntitlementDoc | null {
  const { existing, verdict, hash, now } = params;
  if (verdict.kind !== 'entitlement') return null;
  const nowTs = Timestamp.fromDate(now);
  const sameToken = existing?.purchaseTokenHash === hash;
  const next: EntitlementDoc = {
    plan: PLUS_PLAN_ID,
    source: 'play_purchase',
    status: verdict.status,
    expiresAt: verdict.expiresAt ? Timestamp.fromDate(verdict.expiresAt) : null,
    startedAt:
      sameToken && existing?.startedAt instanceof Timestamp
        ? existing.startedAt
        : nowTs,
    updatedAt: nowTs,
    purchaseTokenHash: hash,
  };
  if (verdict.basePlanId) next.basePlanId = verdict.basePlanId;
  const grants = isPlusValidAt(next as unknown as Record<string, unknown>, now);
  if (!grants && !sameToken && isPlusValidAt(existing, now)) return null;
  return next;
}

/**
 * Applies [verdict] for [uid] inside [tx]: updates the purchase record and,
 * when it should, the entitlement. Every read happens before any write.
 */
export async function applyVerdictInTx(params: {
  tx: Transaction;
  deps: Deps;
  uid: string;
  hash: string;
  verdict: PlayVerdict;
  recordPatch: Partial<PurchaseRecord>;
}): Promise<EntitlementDoc | null> {
  const { tx, deps, uid, hash, verdict, recordPatch } = params;
  const now = deps.now();
  const entRef = entitlementRef(deps, uid);
  const existing = (await tx.get(entRef)).data();
  const next = nextEntitlement({ existing, verdict, hash, now });
  tx.set(
    purchaseRef(deps, hash),
    {
      ...recordPatch,
      lastState: stateName(verdict),
      reconcile: needsReconcile(verdict),
      updatedAt: Timestamp.fromDate(now),
    },
    { merge: true },
  );
  if (next) tx.set(entRef, next);
  return next;
}

/**
 * Acknowledges a paid purchase once (study §5.3). A failure is logged and
 * left for the reconciliation; it never takes the entitlement away.
 */
export async function acknowledgeIfNeeded(params: {
  deps: Deps;
  hash: string;
  purchaseToken: string;
  sub: PlaySubscription;
  verdict: PlayVerdict;
}): Promise<boolean> {
  const { deps, hash, purchaseToken, sub, verdict } = params;
  const paid =
    verdict.kind === 'entitlement' &&
    ['active', 'grace'].includes(verdict.status);
  if (!needsAcknowledge(sub)) {
    await purchaseRef(deps, hash).set({ acknowledged: true }, { merge: true });
    return true;
  }
  if (!paid) return false;
  try {
    await deps.play.acknowledge(PLUS_PRODUCT_ID, purchaseToken);
    await purchaseRef(deps, hash).set({ acknowledged: true }, { merge: true });
    return true;
  } catch (error) {
    logger.warn('Purchase acknowledgement failed; the reconciliation retries', {
      purchase: logTag(hash),
      error: (error as Error).name,
    });
    return false;
  }
}
