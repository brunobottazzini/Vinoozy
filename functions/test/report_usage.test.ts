// reportUsage on the Firestore emulator (FR6.3, FR6.5).
import assert from 'node:assert/strict';

import { reportUsageHandler } from '../src/handlers/report_usage.js';
import { clearFirestore, makeDeps, rejection, TestDeps } from './helpers.js';

function report(sequence: number, reads: number, writes = 0, bytes = 0, extra: Record<string, unknown> = {}) {
  return {
    installationId: 'phone-a',
    periodId: '2026-11',
    sequence,
    policyVersion: 'freemium-v1',
    cumulativeReadCount: reads,
    cumulativeWriteCount: writes,
    cumulativeEgressBytes: bytes,
    ...extra,
  };
}

describe('reportUsage (FR6.3, FR6.5)', () => {
  let deps: TestDeps;

  beforeEach(async () => {
    await clearFirestore();
    deps = makeDeps(new Date('2026-11-10T09:30:00Z'));
  });

  /** Moves the server clock on, so reports are not refused as too frequent. */
  const later = (seconds = 60) => {
    deps.clock.now = new Date(deps.clock.now.getTime() + seconds * 1000);
  };
  const send = (data: unknown, uid = 'dana') => reportUsageHandler(deps, uid, data);
  const period = async (id = '2026-11', uid = 'dana') =>
    (await deps.db.collection('usage').doc(uid).collection('periods').doc(id).get()).data();

  it('accepts a first report and answers total, policy, server time and next reset', async () => {
    const result = await send(report(1, 100, 2, 2048));

    assert.equal(result.accepted, true);
    assert.equal(result.reason, null);
    assert.equal(result.estimatedReadCount, 100);
    assert.equal(result.estimatedWriteCount, 2);
    assert.equal(result.estimatedEgressBytes, 2048);
    assert.equal(result.aboveBudget, false);
    assert.equal(result.serverTime, '2026-11-10T09:30:00.000Z');
    assert.equal(result.nextResetUtc, '2026-12-01T00:00:00.000Z');
    assert.equal(result.policy.adsEnabled, false);
    assert.equal(result.policy.usageBudgetEuro, '0.005');
    const stored = await period();
    assert.equal(stored?.estimatedReadCount, 100);
    assert.equal(stored?.policyVersion, 'freemium-v1');
  });

  it('applies only the delta of a new cumulative', async () => {
    await send(report(1, 100));
    later();
    const result = await send(report(2, 150, 1));
    assert.equal(result.estimatedReadCount, 150);
    assert.equal(result.estimatedWriteCount, 1);
  });

  it('is idempotent for an identical resend', async () => {
    await send(report(1, 100));
    later();
    const result = await send(report(1, 100));
    assert.equal(result.accepted, true);
    assert.equal(result.estimatedReadCount, 100);
  });

  it('adds nothing for an old sequence', async () => {
    await send(report(1, 100));
    later();
    await send(report(2, 200));
    later();
    const result = await send(report(1, 100));
    assert.equal(result.accepted, false);
    assert.equal(result.reason, 'STALE_SEQUENCE');
    assert.equal(result.estimatedReadCount, 200);
  });

  it('refuses a repeated sequence with other values', async () => {
    await send(report(1, 100));
    later();
    const result = await send(report(1, 999));
    assert.equal(result.reason, 'SEQUENCE_CONFLICT');
    assert.equal((await period())?.estimatedReadCount, 100);
  });

  it('refuses decreasing cumulatives', async () => {
    await send(report(1, 100, 5));
    later();
    const result = await send(report(2, 120, 4));
    assert.equal(result.reason, 'DECREASING_CUMULATIVE');
    assert.equal(result.estimatedReadCount, 100);
  });

  it('refuses a new report sent too soon after the last one', async () => {
    await send(report(1, 100));
    later(5);
    const result = await send(report(2, 200));
    assert.equal(result.reason, 'TOO_FREQUENT');
    later(10);
    assert.equal((await send(report(3, 200))).accepted, true);
  });

  it('adds two devices of the same account; a reinstall does not reset it', async () => {
    await send(report(1, 100));
    await send(report(1, 40, 0, 0, { installationId: 'phone-b' }));
    const reinstall = await send(report(1, 10, 0, 0, { installationId: 'phone-a-reinstalled' }));
    assert.equal(reinstall.estimatedReadCount, 150);
  });

  it('applies a late upload of last month to last month only', async () => {
    deps.clock.now = new Date('2026-12-01T00:05:00Z');
    await send(report(1, 30, 0, 0, { periodId: '2026-12' }));

    const late = await send(report(1, 14286, 0, 0, { periodId: '2026-11' }));

    assert.equal(late.accepted, true);
    assert.equal(late.periodId, '2026-11');
    assert.equal(late.aboveBudget, true);
    assert.equal((await period('2026-11'))?.estimatedReadCount, 14286);
    assert.equal((await period('2026-12'))?.estimatedReadCount, 30);
  });

  it('refuses closed and future periods', async () => {
    const closed = await send(report(1, 10, 0, 0, { periodId: '2026-09' }));
    const future = await send(report(1, 10, 0, 0, { periodId: '2026-12' }));
    assert.equal(closed.reason, 'PERIOD_CLOSED');
    assert.equal(future.reason, 'PERIOD_NOT_STARTED');
    assert.equal(await period('2026-09'), undefined);
  });

  it('reads the threshold and the switches from config/policy', async () => {
    await deps.db.collection('config').doc('policy').set({ adsEnabled: true, usageBudgetEuro: '0.0001' });
    const result = await send(report(1, 300));
    assert.equal(result.policy.adsEnabled, true);
    assert.equal(result.aboveBudget, true);
  });

  it('refuses malformed reports', async () => {
    const bad = [
      report(0, 1),
      report(1, -1),
      report(1, 1.5),
      report(1, 1, 0, 0, { installationId: 'has space' }),
      report(1, 1, 0, 0, { periodId: '2026-13' }),
      report(1, 1, 0, 0, { cumulativeEgressBytes: '10' }),
      'not an object',
    ];
    for (const data of bad) {
      const error = await rejection(() => send(data));
      assert.equal(error.code, 'invalid-argument', JSON.stringify(data));
    }
  });
});
