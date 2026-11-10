// verifyPurchase on the Firestore emulator with a fake Play (FR3.3).
import assert from 'node:assert/strict';
import { Timestamp } from 'firebase-admin/firestore';

import { reconcileEntitlementsHandler } from '../src/handlers/play_rtdn.js';
import { tokenHash } from '../src/handlers/purchase_store.js';
import { verifyPurchaseHandler } from '../src/handlers/verify_purchase.js';
import { clearFirestore, makeDeps, playSub, rejection, TestDeps } from './helpers.js';

const TOKEN = 'token-alice.1';
const EXPIRY = new Date('2026-12-10T10:00:00Z');

describe('verifyPurchase (FR3.3)', () => {
  let deps: TestDeps;

  beforeEach(async () => {
    await clearFirestore();
    deps = makeDeps();
  });

  const entitlement = async (uid: string) =>
    (await deps.db.collection('entitlements').doc(uid).get()).data();
  const purchase = async (token: string) =>
    (await deps.db.collection('purchases').doc(tokenHash(token)).get()).data();

  it('grants Plus for a paid purchase with the expiry read from Play, and acknowledges it', async () => {
    deps.play.subscriptions.set(TOKEN, playSub('SUBSCRIPTION_STATE_ACTIVE', { expiry: EXPIRY }));

    const result = await verifyPurchaseHandler(deps, 'alice', { purchaseToken: TOKEN, productId: 'vinoozy_plus' });

    assert.deepEqual(result, {
      state: 'active',
      plusActive: true,
      expiresAt: EXPIRY.toISOString(),
      acknowledged: true,
    });
    const ent = await entitlement('alice');
    assert.equal(ent?.status, 'active');
    assert.equal(ent?.source, 'play_purchase');
    assert.equal((ent?.expiresAt as Timestamp).toDate().toISOString(), EXPIRY.toISOString());
    assert.equal(ent?.purchaseTokenHash, tokenHash(TOKEN));
    assert.equal(JSON.stringify(ent).includes(TOKEN), false, 'no token in the entitlement');
    assert.deepEqual(deps.play.acknowledged, [TOKEN]);
    assert.equal((await purchase(TOKEN))?.uid, 'alice');
    assert.equal((await purchase(TOKEN))?.acknowledged, true);
  });

  it('is idempotent when the same token is sent twice', async () => {
    deps.play.subscriptions.set(TOKEN, playSub('SUBSCRIPTION_STATE_ACTIVE', { expiry: EXPIRY }));
    await verifyPurchaseHandler(deps, 'alice', { purchaseToken: TOKEN });
    const first = await entitlement('alice');

    const again = await verifyPurchaseHandler(deps, 'alice', { purchaseToken: TOKEN });

    assert.equal(again.state, 'active');
    assert.equal(again.acknowledged, true);
    assert.deepEqual(deps.play.acknowledged, [TOKEN], 'acknowledged once');
    const purchases = await deps.db.collection('purchases').get();
    assert.equal(purchases.size, 1);
    assert.deepEqual((await entitlement('alice'))?.startedAt, first?.startedAt);
  });

  it('refuses a fake token and creates nothing', async () => {
    const error = await rejection(() => verifyPurchaseHandler(deps, 'alice', { purchaseToken: 'fake' }));
    assert.equal(error.code, 'not-found');
    assert.equal(error.details?.reason, 'PURCHASE_NOT_FOUND');
    assert.equal(await entitlement('alice'), undefined);
    assert.equal((await deps.db.collection('purchases').get()).size, 0);
  });

  it('refuses a malformed token before calling Play', async () => {
    for (const purchaseToken of ['', 'with space', 42, 'x'.repeat(4097)]) {
      const error = await rejection(() => verifyPurchaseHandler(deps, 'alice', { purchaseToken }));
      assert.equal(error.details?.reason, 'INVALID_TOKEN');
    }
    assert.equal(deps.play.getCalls, 0);
  });

  it('refuses another package or product', async () => {
    deps.play.subscriptions.set('t-other', playSub('SUBSCRIPTION_STATE_ACTIVE', { productId: 'other_product' }));
    deps.play.subscriptions.set('t-weekly', playSub('SUBSCRIPTION_STATE_ACTIVE', { basePlanId: 'weekly' }));
    deps.play.subscriptions.set(TOKEN, playSub('SUBSCRIPTION_STATE_ACTIVE'));

    const wrongPackage = await rejection(() =>
      verifyPurchaseHandler(deps, 'alice', { purchaseToken: TOKEN, packageName: 'com.other.app' }),
    );
    const wrongProductParam = await rejection(() =>
      verifyPurchaseHandler(deps, 'alice', { purchaseToken: TOKEN, productId: 'other_product' }),
    );
    const wrongProduct = await rejection(() => verifyPurchaseHandler(deps, 'alice', { purchaseToken: 't-other' }));
    const wrongBasePlan = await rejection(() => verifyPurchaseHandler(deps, 'alice', { purchaseToken: 't-weekly' }));

    assert.equal(wrongPackage.details?.reason, 'WRONG_PACKAGE');
    assert.equal(wrongProductParam.details?.reason, 'WRONG_PRODUCT');
    assert.equal(wrongProduct.details?.reason, 'WRONG_PRODUCT');
    assert.equal(wrongBasePlan.details?.reason, 'WRONG_PRODUCT');
    assert.equal(await entitlement('alice'), undefined);
  });

  it('refuses the replay of a token on another account', async () => {
    deps.play.subscriptions.set(TOKEN, playSub('SUBSCRIPTION_STATE_ACTIVE'));
    await verifyPurchaseHandler(deps, 'alice', { purchaseToken: TOKEN });

    const error = await rejection(() => verifyPurchaseHandler(deps, 'mallory', { purchaseToken: TOKEN }));

    assert.equal(error.code, 'permission-denied');
    assert.equal(error.details?.reason, 'TOKEN_IN_USE');
    assert.equal(await entitlement('mallory'), undefined);
    assert.equal((await purchase(TOKEN))?.uid, 'alice');
  });

  it('refuses an upgrade token linked to another account', async () => {
    deps.play.subscriptions.set(TOKEN, playSub('SUBSCRIPTION_STATE_ACTIVE'));
    await verifyPurchaseHandler(deps, 'alice', { purchaseToken: TOKEN });
    deps.play.subscriptions.set('t-new', playSub('SUBSCRIPTION_STATE_ACTIVE', { linkedPurchaseToken: TOKEN }));

    const error = await rejection(() => verifyPurchaseHandler(deps, 'mallory', { purchaseToken: 't-new' }));

    assert.equal(error.details?.reason, 'TOKEN_IN_USE');
    assert.equal(await entitlement('mallory'), undefined);
  });

  it('grants nothing and does not acknowledge a PENDING purchase', async () => {
    deps.play.subscriptions.set(TOKEN, playSub('SUBSCRIPTION_STATE_PENDING'));

    const result = await verifyPurchaseHandler(deps, 'alice', { purchaseToken: TOKEN });

    assert.equal(result.state, 'pending');
    assert.equal(result.plusActive, false);
    assert.equal(await entitlement('alice'), undefined);
    assert.deepEqual(deps.play.acknowledged, []);
    assert.equal((await purchase(TOKEN))?.uid, 'alice', 'bound, so the RTDN can grant it later');
    assert.equal((await purchase(TOKEN))?.reconcile, true);
  });

  it('keeps the entitlement when the acknowledgement fails, and the reconciliation retries it', async () => {
    deps.play.subscriptions.set(TOKEN, playSub('SUBSCRIPTION_STATE_ACTIVE'));
    deps.play.failAcknowledge = true;

    const result = await verifyPurchaseHandler(deps, 'alice', { purchaseToken: TOKEN });

    assert.equal(result.acknowledged, false);
    assert.equal(result.plusActive, true);
    assert.equal((await purchase(TOKEN))?.acknowledged, false);

    deps.play.failAcknowledge = false;
    await reconcileEntitlementsHandler(deps);
    assert.deepEqual(deps.play.acknowledged, [TOKEN]);
    assert.equal((await purchase(TOKEN))?.acknowledged, true);
  });

  it('answers unavailable when Play is down, without writing', async () => {
    deps.play.unavailable = true;
    const error = await rejection(() => verifyPurchaseHandler(deps, 'alice', { purchaseToken: TOKEN }));
    assert.equal(error.code, 'unavailable');
    assert.equal(error.details?.reason, 'PLAY_UNAVAILABLE');
    assert.equal((await deps.db.collection('purchases').get()).size, 0);
  });
});
