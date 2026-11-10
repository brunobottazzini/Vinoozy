// Account deletion clean-up and the retention of measurement details
// (freemium-plus NFR6; study §7.6).
import { logger } from 'firebase-functions';
import { FieldPath, Timestamp } from 'firebase-admin/firestore';

import { Collections, DETAIL_RETENTION_DAYS } from '../config.js';
import { Deps } from '../deps.js';
import { periodIdOf, utcDayId } from '../domain/usage.js';

/**
 * Deletes the plan, usage and ad data of a deleted account. Purchase
 * records keep only the minimum documented retention: the token stays (a
 * refund or a chargeback may still arrive) but loses its account, so the
 * same Play subscription can be restored on a new account.
 */
export async function cleanupDeletedUser(deps: Deps, uid: string): Promise<void> {
  const db = deps.db;
  await db.collection(Collections.entitlements).doc(uid).delete();
  await db.recursiveDelete(db.collection(Collections.usage).doc(uid));
  await db.recursiveDelete(db.collection(Collections.adSlots).doc(uid));
  const purchases = await db.collection(Collections.purchases).where('uid', '==', uid).get();
  const now = Timestamp.fromDate(deps.now());
  for (const doc of purchases.docs) {
    await doc.ref.update({ uid: null, accountDeletedAt: now, updatedAt: now });
  }
  logger.info('Deleted account cleaned up', { purchases: purchases.size });
}

export interface PurgeResult {
  periods: number;
  adSlotDays: number;
  playEvents: number;
}

/**
 * Deletes the measurement details older than 90 days: usage months that
 * ended before the cutoff (with their devices), ad slot days and processed
 * Play notification ids. Queries go by document id, so no extra index.
 */
export async function purgeOldDetails(deps: Deps): Promise<PurgeResult> {
  const db = deps.db;
  const cutoff = new Date(deps.now().getTime() - DETAIL_RETENTION_DAYS * 86_400_000);
  const cutoffPeriod = periodIdOf(cutoff);
  const cutoffDay = utcDayId(cutoff);
  const result: PurgeResult = { periods: 0, adSlotDays: 0, playEvents: 0 };
  for (const user of await db.collection(Collections.usage).listDocuments()) {
    const old = await user
      .collection(Collections.periods)
      .where(FieldPath.documentId(), '<', cutoffPeriod)
      .get();
    for (const doc of old.docs) {
      await db.recursiveDelete(doc.ref);
      result.periods++;
    }
  }
  for (const user of await db.collection(Collections.adSlots).listDocuments()) {
    const old = await user
      .collection(Collections.days)
      .where(FieldPath.documentId(), '<', cutoffDay)
      .get();
    for (const doc of old.docs) {
      await doc.ref.delete();
      result.adSlotDays++;
    }
  }
  const events = await db
    .collection(Collections.playEvents)
    .where('processedAt', '<', Timestamp.fromDate(cutoff))
    .get();
  for (const doc of events.docs) {
    await doc.ref.delete();
    result.playEvents++;
  }
  logger.info('Old details purged', { ...result });
  return result;
}
