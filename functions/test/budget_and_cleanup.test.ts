// onBudgetAlert (FR9.2), onUserDeleted and purgeOldUsage (NFR6).
import assert from 'node:assert/strict';
import { Timestamp } from 'firebase-admin/firestore';

import { cleanupDeletedUser, purgeOldDetails } from '../src/handlers/account_cleanup.js';
import { handleBudgetAlert } from '../src/handlers/budget_alert.js';
import { tokenHash } from '../src/handlers/purchase_store.js';
import { verifyPurchaseHandler } from '../src/handlers/verify_purchase.js';
import { clearFirestore, makeDeps, PROJECT_ID, playSub, TestDeps } from './helpers.js';

describe('onBudgetAlert (FR9.2)', () => {
  let deps: TestDeps;

  beforeEach(async () => {
    await clearFirestore();
    deps = makeDeps();
  });

  const alert = (costAmount: number, budgetAmount = 1) => ({
    budgetDisplayName: 'Vinoozy 1 EUR',
    costAmount,
    budgetAmount,
    currencyCode: 'EUR',
  });

  it('unlinks billing when the cost goes over the budget, and records it', async () => {
    assert.equal(await handleBudgetAlert(deps, 'b1', alert(1.02)), 'billing-disabled');
    assert.deepEqual(deps.billing.disabledProjects, [PROJECT_ID]);
    const event = (await deps.db.collection('billingEvents').doc('b1').get()).data();
    assert.equal(event?.outcome, 'billing-disabled');
    assert.equal(event?.costAmount, 1.02);
  });

  it('does nothing below or at the budget', async () => {
    assert.equal(await handleBudgetAlert(deps, 'b2', alert(0.4)), 'below-budget');
    assert.equal(await handleBudgetAlert(deps, 'b3', alert(1)), 'below-budget');
    assert.deepEqual(deps.billing.disabledProjects, []);
  });

  it('does not unlink twice, and ignores malformed notifications', async () => {
    deps.billing.enabled = false;
    assert.equal(await handleBudgetAlert(deps, 'b4', alert(3)), 'already-disabled');
    assert.equal(await handleBudgetAlert(deps, 'b5', null), 'ignored-malformed');
    assert.equal(await handleBudgetAlert(deps, 'b6', { costAmount: 2 }), 'ignored-malformed');
    assert.deepEqual(deps.billing.disabledProjects, []);
  });
});

describe('onUserDeleted (NFR6)', () => {
  let deps: TestDeps;

  beforeEach(async () => {
    await clearFirestore();
    deps = makeDeps();
  });

  async function seed(uid: string): Promise<void> {
    const db = deps.db;
    await db.collection('entitlements').doc(uid).set({ plan: 'plus', source: 'manual_grant', status: 'active' });
    const period = db.collection('usage').doc(uid).collection('periods').doc('2026-11');
    await period.set({ estimatedReadCount: 10 });
    await period.collection('devices').doc('phone').set({ lastSequence: 1 });
    await db.collection('adSlots').doc(uid).collection('days').doc('2026-11-10').set({ reservationId: 'r' });
  }

  it("deletes the account's entitlement, usage and ad slots, and unbinds its purchases", async () => {
    await seed('gina');
    await seed('hank');
    deps.play.subscriptions.set('t-gina', playSub('SUBSCRIPTION_STATE_ACTIVE'));
    await verifyPurchaseHandler(deps, 'gina', { purchaseToken: 't-gina' });

    await cleanupDeletedUser(deps, 'gina');

    const db = deps.db;
    assert.equal((await db.collection('entitlements').doc('gina').get()).exists, false);
    assert.equal((await db.collection('usage').doc('gina').collection('periods').get()).size, 0);
    assert.equal((await db.collectionGroup('devices').get()).size, 1, "only hank's device stays");
    assert.equal((await db.collection('adSlots').doc('gina').collection('days').get()).size, 0);
    const purchase = (await db.collection('purchases').doc(tokenHash('t-gina')).get()).data();
    assert.equal(purchase?.uid, null);
    assert.ok(purchase?.accountDeletedAt);
    assert.equal((await db.collection('entitlements').doc('hank').get()).exists, true);

    await verifyPurchaseHandler(deps, 'gina-new', { purchaseToken: 't-gina' });
    assert.equal((await db.collection('entitlements').doc('gina-new').get()).data()?.status, 'active');
  });
});

describe('purgeOldUsage (NFR6, 90 days)', () => {
  let deps: TestDeps;

  beforeEach(async () => {
    await clearFirestore();
    deps = makeDeps(new Date('2026-11-10T09:30:00Z')); // cutoff: 2026-08-12
  });

  it('deletes only the details older than 90 days', async () => {
    const db = deps.db;
    const periods = db.collection('usage').doc('ivy').collection('periods');
    for (const id of ['2026-07', '2026-08', '2026-11']) {
      await periods.doc(id).set({ estimatedReadCount: 1 });
      await periods.doc(id).collection('devices').doc('phone').set({ lastSequence: 1 });
    }
    const days = db.collection('adSlots').doc('ivy').collection('days');
    for (const id of ['2026-08-11', '2026-08-12', '2026-11-10']) await days.doc(id).set({ reservationId: id });
    await db.collection('playEvents').doc('old').set({ processedAt: Timestamp.fromDate(new Date('2026-08-01T00:00:00Z')) });
    await db.collection('playEvents').doc('new').set({ processedAt: Timestamp.fromDate(new Date('2026-11-01T00:00:00Z')) });

    const result = await purgeOldDetails(deps);

    assert.deepEqual(result, { periods: 1, adSlotDays: 1, playEvents: 1 });
    assert.deepEqual((await periods.get()).docs.map((d) => d.id), ['2026-08', '2026-11']);
    assert.equal((await db.collectionGroup('devices').get()).size, 2);
    assert.deepEqual((await days.get()).docs.map((d) => d.id), ['2026-08-12', '2026-11-10']);
    assert.deepEqual((await db.collection('playEvents').get()).docs.map((d) => d.id), ['new']);
  });
});
