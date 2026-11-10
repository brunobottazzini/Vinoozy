// Play RTDN and the daily reconciliation (FR3.4).
import assert from 'node:assert/strict';
import { Timestamp } from 'firebase-admin/firestore';

import { PACKAGE_NAME } from '../src/config.js';
import {
  DeveloperNotification,
  handlePlayNotification,
  reconcileEntitlementsHandler,
} from '../src/handlers/play_rtdn.js';
import { tokenHash } from '../src/handlers/purchase_store.js';
import { verifyPurchaseHandler } from '../src/handlers/verify_purchase.js';
import { clearFirestore, makeDeps, playSub, rejection, TestDeps } from './helpers.js';

const TOKEN = 'token-bob.1';
const EXPIRY = new Date('2026-12-10T10:00:00Z');

function rtdn(type: number, eventTimeMillis: number, token = TOKEN): DeveloperNotification {
  return {
    version: '1.0',
    packageName: PACKAGE_NAME,
    eventTimeMillis: String(eventTimeMillis),
    subscriptionNotification: { version: '1.0', notificationType: type, purchaseToken: token },
  };
}

describe('Play RTDN (FR3.4)', () => {
  let deps: TestDeps;
  let messages = 0;

  beforeEach(async () => {
    await clearFirestore();
    deps = makeDeps();
    deps.play.subscriptions.set(TOKEN, playSub('SUBSCRIPTION_STATE_ACTIVE', { expiry: EXPIRY }));
    await verifyPurchaseHandler(deps, 'bob', { purchaseToken: TOKEN });
  });

  const send = (payload: DeveloperNotification | null, id = `m${++messages}`) =>
    handlePlayNotification(deps, id, payload);
  const setPlay = (state: string, expiry: Date | null = EXPIRY) =>
    deps.play.subscriptions.set(TOKEN, playSub(state, { expiry, acknowledged: true }));
  const entitlement = async () => (await deps.db.collection('entitlements').doc('bob').get()).data();

  it('keeps a cancelled subscription active until its expiry', async () => {
    setPlay('SUBSCRIPTION_STATE_CANCELED');

    assert.equal(await send(rtdn(3, 1000)), 'applied');

    const ent = await entitlement();
    assert.equal(ent?.status, 'active');
    assert.equal((ent?.expiresAt as Timestamp).toDate().toISOString(), EXPIRY.toISOString());
  });

  it('turns a refund into revoked at once, for good', async () => {
    setPlay('SUBSCRIPTION_STATE_EXPIRED');
    const refund: DeveloperNotification = {
      packageName: PACKAGE_NAME,
      eventTimeMillis: '1000',
      voidedPurchaseNotification: { purchaseToken: TOKEN, productType: 1, refundType: 1 },
    };

    assert.equal(await send(refund), 'applied');
    assert.equal((await entitlement())?.status, 'revoked');

    setPlay('SUBSCRIPTION_STATE_ACTIVE');
    await send(rtdn(1, 2000)); // RECOVERED cannot revive a revoked token
    assert.equal((await entitlement())?.status, 'revoked');
  });

  it('turns a SUBSCRIPTION_REVOKED notification into revoked', async () => {
    setPlay('SUBSCRIPTION_STATE_EXPIRED');
    await send(rtdn(12, 1000));
    assert.equal((await entitlement())?.status, 'revoked');
  });

  it('follows grace period, account hold, pause, recovery and expiry', async () => {
    const steps: Array<[string, number, string]> = [
      ['SUBSCRIPTION_STATE_IN_GRACE_PERIOD', 6, 'grace'],
      ['SUBSCRIPTION_STATE_ON_HOLD', 5, 'on_hold'],
      ['SUBSCRIPTION_STATE_ACTIVE', 1, 'active'],
      ['SUBSCRIPTION_STATE_PAUSED', 10, 'paused'],
      ['SUBSCRIPTION_STATE_EXPIRED', 13, 'expired'],
    ];
    let time = 1000;
    for (const [state, type, expected] of steps) {
      setPlay(state);
      await send(rtdn(type, (time += 1000)));
      assert.equal((await entitlement())?.status, expected, state);
    }
  });

  it('ignores an out-of-order notification', async () => {
    setPlay('SUBSCRIPTION_STATE_ON_HOLD');
    await send(rtdn(5, 5000));
    setPlay('SUBSCRIPTION_STATE_ACTIVE');

    assert.equal(await send(rtdn(2, 4000)), 'stale');

    assert.equal((await entitlement())?.status, 'on_hold');
  });

  it('skips a duplicate message without calling Play again', async () => {
    setPlay('SUBSCRIPTION_STATE_CANCELED');
    await send(rtdn(3, 1000), 'dup-1');
    const calls = deps.play.getCalls;

    assert.equal(await send(rtdn(3, 1000), 'dup-1'), 'duplicate');
    assert.equal(deps.play.getCalls, calls);
  });

  it('ignores another package, test notifications and unknown tokens', async () => {
    assert.equal(await send({ ...rtdn(4, 1000), packageName: 'com.other.app' }), 'ignored-package');
    assert.equal(
      await send({ packageName: PACKAGE_NAME, eventTimeMillis: '1', testNotification: { version: '1.0' } }),
      'ignored-test',
    );
    assert.equal(await send(rtdn(4, 1000, 'never-verified')), 'ignored-unknown-token');
    assert.equal(await send(null), 'ignored-malformed');
  });

  it('grants a pending purchase when the payment arrives, and acknowledges it', async () => {
    deps.play.subscriptions.set('t-pending', playSub('SUBSCRIPTION_STATE_PENDING'));
    await verifyPurchaseHandler(deps, 'carol', { purchaseToken: 't-pending' });
    assert.equal((await deps.db.collection('entitlements').doc('carol').get()).exists, false);

    deps.play.subscriptions.set('t-pending', playSub('SUBSCRIPTION_STATE_ACTIVE'));
    await send(rtdn(4, 1000, 't-pending'));

    assert.equal((await deps.db.collection('entitlements').doc('carol').get()).data()?.status, 'active');
    assert.ok(deps.play.acknowledged.includes('t-pending'));
  });

  it('lets Pub/Sub retry when Play is unreachable', async () => {
    deps.play.unavailable = true;
    await rejection(() => send(rtdn(2, 1000), 'retry-1'));
    assert.equal((await deps.db.collection('playEvents').doc('retry-1').get()).exists, false);
  });

  it('does not let an old token expiring take away a new subscription', async () => {
    deps.play.subscriptions.set('t-new', playSub('SUBSCRIPTION_STATE_ACTIVE', { expiry: new Date('2027-01-10T00:00:00Z') }));
    await verifyPurchaseHandler(deps, 'bob', { purchaseToken: 't-new' });
    setPlay('SUBSCRIPTION_STATE_EXPIRED', new Date('2026-11-01T00:00:00Z'));

    await send(rtdn(13, 1000));

    const ent = await entitlement();
    assert.equal(ent?.status, 'active');
    assert.equal(ent?.purchaseTokenHash, tokenHash('t-new'));
  });

  it('reconciles daily: an expiry missed by the notifications is applied', async () => {
    deps.clock.now = new Date('2026-12-11T00:00:00Z');
    setPlay('SUBSCRIPTION_STATE_EXPIRED');

    assert.equal(await reconcileEntitlementsHandler(deps), 1);

    assert.equal((await entitlement())?.status, 'expired');
    const record = (await deps.db.collection('purchases').doc(tokenHash(TOKEN)).get()).data();
    assert.equal(record?.reconcile, false, 'a finished subscription leaves the daily job');
    assert.equal(await reconcileEntitlementsHandler(deps), 0);
  });
});
