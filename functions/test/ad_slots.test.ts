// reserveAdSlot and recordAdOutcome (FR7.2, FR7.6).
import assert from 'node:assert/strict';
import { Timestamp } from 'firebase-admin/firestore';

import { recordAdOutcomeHandler, reserveAdSlotHandler } from '../src/handlers/ad_slots.js';
import { clearFirestore, makeDeps, rejection, TestDeps } from './helpers.js';

describe('reserveAdSlot (FR7.2)', () => {
  let deps: TestDeps;

  beforeEach(async () => {
    await clearFirestore();
    deps = makeDeps(new Date('2026-11-10T09:30:00Z'));
    await deps.db.collection('config').doc('policy').set({ adsEnabled: true });
    // Over the 0.005 € threshold this month.
    await deps.db
      .collection('usage')
      .doc('erin')
      .collection('periods')
      .doc('2026-11')
      .set({ estimatedReadCount: 20000, estimatedWriteCount: 0, estimatedEgressBytes: 0 });
  });

  const reserve = () => reserveAdSlotHandler(deps, 'erin');
  const slots = async () => (await deps.db.collection('adSlots').doc('erin').collection('days').get()).docs;

  it('grants one slot per account and UTC day', async () => {
    const result = await reserve();
    assert.equal(result.granted, true);
    assert.equal(result.day, '2026-11-10');
    assert.match(result.reservationId ?? '', /^[0-9a-f-]{36}$/);

    const second = await reserve();
    assert.equal(second.granted, false);
    assert.equal(second.reason, 'ALREADY_RESERVED');

    deps.clock.now = new Date('2026-11-11T00:00:01Z');
    assert.equal((await reserve()).granted, true, 'a new UTC day has a new slot');
  });

  it('gives the slot to only one of two concurrent devices', async function () {
    // Contending transactions wait for each other's locks in the emulator.
    this.timeout(30_000);
    const results = await Promise.all([reserve(), reserve()]);
    assert.equal(results.filter((r) => r.granted).length, 1);
    assert.equal(results.filter((r) => r.reason === 'ALREADY_RESERVED').length, 1);
    assert.equal((await slots()).length, 1);
  });

  it('never reserves with a valid Plus', async () => {
    await deps.db.collection('entitlements').doc('erin').set({
      plan: 'plus',
      source: 'manual_grant',
      status: 'active',
      reason: 'gift',
    });
    const result = await reserve();
    assert.equal(result.granted, false);
    assert.equal(result.reason, 'PLUS_ACTIVE');
    assert.equal((await slots()).length, 0);
  });

  it('reserves again after Plus expired', async () => {
    await deps.db.collection('entitlements').doc('erin').set({
      plan: 'plus',
      source: 'play_purchase',
      status: 'active',
      expiresAt: Timestamp.fromDate(new Date('2026-11-01T00:00:00Z')),
    });
    assert.equal((await reserve()).granted, true);
  });

  it('refuses with ads switched off or below the threshold', async () => {
    await deps.db.collection('config').doc('policy').set({ adsEnabled: false });
    assert.equal((await reserve()).reason, 'ADS_DISABLED');

    await deps.db.collection('config').doc('policy').set({ adsEnabled: true });
    await deps.db.collection('usage').doc('erin').collection('periods').doc('2026-11').set({ estimatedReadCount: 14285 });
    assert.equal((await reserve()).reason, 'BELOW_THRESHOLD');
    assert.equal((await slots()).length, 0);
  });

  it('counts only the current server month', async () => {
    deps.clock.now = new Date('2026-12-01T00:00:01Z');
    assert.equal((await reserve()).reason, 'BELOW_THRESHOLD');
  });
});

describe('recordAdOutcome (FR7.6)', () => {
  let deps: TestDeps;
  let reservationId: string;
  const day = '2026-11-10';

  beforeEach(async () => {
    await clearFirestore();
    deps = makeDeps(new Date('2026-11-10T09:30:00Z'));
    await deps.db.collection('config').doc('policy').set({ adsEnabled: true });
    await deps.db.collection('usage').doc('erin').collection('periods').doc('2026-11').set({ estimatedReadCount: 20000 });
    reservationId = (await reserveAdSlotHandler(deps, 'erin')).reservationId!;
  });

  const record = (data: Record<string, unknown>, uid = 'erin') =>
    recordAdOutcomeHandler(deps, uid, { reservationId, day, ...data });
  const slot = async () => (await deps.db.collection('adSlots').doc('erin').collection('days').doc(day).get()).data();

  it('records request, load and impression separately: a load is not an impression', async () => {
    assert.deepEqual(await record({ event: 'request' }), { recorded: true });
    assert.deepEqual(await record({ event: 'loaded' }), { recorded: true });
    let stored = await slot();
    assert.ok(stored?.requestedAt);
    assert.ok(stored?.loadedAt);
    assert.equal(stored?.impressionAt, undefined);

    await record({ event: 'impression' });
    stored = await slot();
    assert.ok(stored?.impressionAt);
  });

  it('deduplicates a repeated callback, keeping the first time', async () => {
    await record({ event: 'impression' });
    const first = (await slot())?.impressionAt;
    deps.clock.now = new Date('2026-11-10T09:31:00Z');
    assert.deepEqual(await record({ event: 'impression' }), { recorded: false });
    assert.deepEqual((await slot())?.impressionAt, first);
  });

  it('records the estimated revenue with currency and precision', async () => {
    await record({ event: 'revenue', valueMicros: 1200, currencyCode: 'EUR', precision: 'estimated' });
    const stored = await slot();
    assert.equal(stored?.revenueMicros, 1200);
    assert.equal(stored?.revenueCurrency, 'EUR');
    assert.equal(stored?.revenuePrecision, 'estimated');
  });

  it('refuses another reservation, another account and malformed events', async () => {
    const otherReservation = await rejection(() =>
      record({ event: 'impression', reservationId: '00000000-0000-0000-0000-000000000000' }),
    );
    const otherAccount = await rejection(() => record({ event: 'impression' }, 'frank'));
    const badEvent = await rejection(() => record({ event: 'click' }));
    const badRevenue = await rejection(() => record({ event: 'revenue', valueMicros: -1, currencyCode: 'EUR' }));
    assert.equal(otherReservation.details?.reason, 'NO_RESERVATION');
    assert.equal(otherAccount.details?.reason, 'NO_RESERVATION');
    assert.equal(badEvent.code, 'invalid-argument');
    assert.equal(badRevenue.code, 'invalid-argument');
  });
});
