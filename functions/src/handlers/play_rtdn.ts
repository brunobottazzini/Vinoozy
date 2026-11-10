// Play Real-time developer notifications and the daily reconciliation
// (freemium-plus FR3.4; study §5.4). A notification is only a hint: the
// state always comes from a fresh read of the Play API.
import { logger } from 'firebase-functions';
import { Timestamp } from 'firebase-admin/firestore';

import { Collections, PACKAGE_NAME } from '../config.js';
import { Deps } from '../deps.js';
import { PlayPurchaseNotFoundError } from '../clients/play_client.js';
import {
  plusLineItem,
  PlaySubscription,
  PlayVerdict,
  RTDN_SUBSCRIPTION_REVOKED,
  verdictFor,
} from '../domain/play_state.js';
import {
  acknowledgeIfNeeded,
  applyVerdictInTx,
  logTag,
  purchaseRef,
  stateName,
  tokenHash,
} from './purchase_store.js';

/** The JSON Play publishes (DeveloperNotification). */
export interface DeveloperNotification {
  version?: string;
  packageName?: string;
  eventTimeMillis?: string | number;
  subscriptionNotification?: {
    version?: string;
    notificationType?: number;
    purchaseToken?: string;
    subscriptionId?: string;
  };
  voidedPurchaseNotification?: {
    purchaseToken?: string;
    productType?: number;
    refundType?: number;
  };
  testNotification?: { version?: string };
}

export type RtdnOutcome =
  | 'applied'
  | 'duplicate'
  | 'stale'
  | 'ignored-package'
  | 'ignored-test'
  | 'ignored-unknown-token'
  | 'ignored-not-found'
  | 'ignored-malformed';

export type RefreshOutcome = 'applied' | 'stale' | 'unbound' | 'not-found';

/**
 * Re-reads Play for the record [hash] and applies the state. An
 * [eventAtMillis] older than the last applied event means an out-of-order
 * notification: nothing changes. Null means no event (the reconciliation):
 * never stale, and the last event time stays. A revocation is final for the
 * token and is never treated as stale.
 */
export async function refreshPurchase(params: {
  deps: Deps;
  hash: string;
  eventAtMillis: number | null;
  revoked: boolean;
}): Promise<RefreshOutcome> {
  const { deps, hash, eventAtMillis } = params;
  const record = (await purchaseRef(deps, hash).get()).data();
  const token = record?.purchaseToken;
  if (typeof token !== 'string') return 'unbound';
  let sub: PlaySubscription;
  try {
    sub = await deps.play.getSubscription(token);
  } catch (error) {
    if (error instanceof PlayPurchaseNotFoundError) return 'not-found';
    throw error;
  }
  const item = plusLineItem(sub);
  if (!item) return 'not-found';
  const result = await deps.db.runTransaction(
    async (tx): Promise<{ outcome: RefreshOutcome; verdict?: PlayVerdict }> => {
      const current = (await tx.get(purchaseRef(deps, hash))).data();
      const uid = current?.uid;
      if (typeof uid !== 'string') return { outcome: 'unbound' };
      const lastEvent =
        typeof current?.lastEventAtMillis === 'number' ? current.lastEventAtMillis : 0;
      if (!params.revoked && eventAtMillis !== null && eventAtMillis < lastEvent) {
        return { outcome: 'stale' };
      }
      const revoked = params.revoked || current?.revoked === true;
      const verdict = verdictFor(sub, item, deps.now(), revoked);
      await applyVerdictInTx({
        tx,
        deps,
        uid,
        hash,
        verdict,
        recordPatch: { revoked, lastEventAtMillis: Math.max(lastEvent, eventAtMillis ?? 0) },
      });
      return { outcome: 'applied', verdict };
    },
  );
  if (result.verdict) {
    await acknowledgeIfNeeded({ deps, hash, purchaseToken: token, sub, verdict: result.verdict });
    logger.info('Purchase refreshed', {
      purchase: logTag(hash),
      state: stateName(result.verdict),
    });
  }
  return result.outcome;
}

function eventMillis(value: unknown): number | null {
  const millis = typeof value === 'string' ? Number(value) : value;
  return typeof millis === 'number' && Number.isSafeInteger(millis) && millis >= 0 ? millis : null;
}

/**
 * Handles one RTDN message. Duplicates (same Pub/Sub messageId) are
 * skipped; a message for another package is not from our Play app and is
 * ignored. Play unavailable throws, so Pub/Sub delivers it again.
 */
export async function handlePlayNotification(
  deps: Deps,
  messageId: string,
  payload: DeveloperNotification | null,
): Promise<RtdnOutcome> {
  const eventRef = deps.db.collection(Collections.playEvents).doc(messageId);
  if ((await eventRef.get()).exists) return 'duplicate';
  const outcome = await processNotification(deps, payload);
  await eventRef.set({ outcome, processedAt: Timestamp.fromDate(deps.now()) });
  logger.info('Play notification', { messageId, outcome });
  return outcome;
}

async function processNotification(
  deps: Deps,
  payload: DeveloperNotification | null,
): Promise<RtdnOutcome> {
  if (!payload || typeof payload !== 'object') return 'ignored-malformed';
  if (payload.packageName !== PACKAGE_NAME) return 'ignored-package';
  if (payload.testNotification) return 'ignored-test';
  const eventAt = eventMillis(payload.eventTimeMillis);
  const subscription = payload.subscriptionNotification;
  const voided = payload.voidedPurchaseNotification;
  const token = subscription?.purchaseToken ?? voided?.purchaseToken;
  if (typeof token !== 'string' || token.length === 0 || eventAt === null) {
    return 'ignored-malformed';
  }
  const revoked =
    voided !== undefined || subscription?.notificationType === RTDN_SUBSCRIPTION_REVOKED;
  const result = await refreshPurchase({ deps, hash: tokenHash(token), eventAtMillis: eventAt, revoked });
  switch (result) {
    case 'applied':
      return 'applied';
    case 'stale':
      return 'stale';
    case 'unbound':
      // Never verified by the app yet: verifyPurchase binds it later.
      return 'ignored-unknown-token';
    default:
      return 'ignored-not-found';
  }
}

/**
 * The daily job: re-reads Play for every record that can still change and
 * retries pending acknowledgements. Returns how many records it refreshed.
 */
export async function reconcileEntitlementsHandler(deps: Deps): Promise<number> {
  const snapshot = await deps.db
    .collection(Collections.purchases)
    .where('reconcile', '==', true)
    .get();
  let refreshed = 0;
  for (const doc of snapshot.docs) {
    try {
      const result = await refreshPurchase({
        deps,
        hash: doc.id,
        eventAtMillis: null,
        revoked: false,
      });
      if (result === 'applied') refreshed++;
    } catch (error) {
      logger.warn('Reconciliation of one purchase failed', {
        purchase: logTag(doc.id),
        error: (error as Error).name,
      });
    }
  }
  return refreshed;
}
