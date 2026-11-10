// Pure domain rules of the backend: cost (D3, FR6.2), Play states (FR3.3,
// FR3.4), Plus validity (FR1.2) and the entitlement guard.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { Timestamp } from 'firebase-admin/firestore';

import { PACKAGE_NAME } from '../src/config.js';
import { isPlusValidAt } from '../src/domain/entitlement.js';
import { plusLineItem, verdictFor } from '../src/domain/play_state.js';
import { policyFromData, SAFE_POLICY } from '../src/domain/policy.js';
import {
  isAboveBudget,
  nextResetUtc,
  periodIdOf,
  previousPeriodId,
  UsageCounters,
} from '../src/domain/usage.js';
import { nextEntitlement } from '../src/handlers/purchase_store.js';
import { playSub } from './helpers.js';

const usage = (reads: number, writes = 0, egressBytes = 0): UsageCounters => ({
  reads,
  writes,
  egressBytes,
});
const times = (unit: UsageCounters, n: number): UsageCounters =>
  usage(unit.reads * n, unit.writes * n, unit.egressBytes * n);

describe('usage cost (D3, the same boundaries as test/usage/usage_cost_test.dart)', () => {
  const budget = '0.005';

  it('14,285 reads are below, 14,286 above', () => {
    assert.equal(isAboveBudget(usage(14285), budget), false);
    assert.equal(isAboveBudget(usage(14286), budget), true);
  });

  it('4,807 writes are below, 4,808 above', () => {
    assert.equal(isAboveBudget(usage(0, 4807), budget), false);
    assert.equal(isAboveBudget(usage(0, 4808), budget), true);
  });

  it('44,739,242 bytes are below, 44,739,243 above', () => {
    assert.equal(isAboveBudget(usage(0, 0, 44739242), budget), false);
    assert.equal(isAboveBudget(usage(0, 0, 44739243), budget), true);
  });

  it('14,256 reads + 10 writes are exactly the threshold: not above', () => {
    assert.equal(isAboveBudget(usage(14256, 10), budget), false);
    assert.equal(isAboveBudget(usage(14257, 10), budget), true);
  });

  it('479 loads are below, 480 above; 427 cycles below, 428 above', () => {
    const load = usage(20, 0, 30 * 1024);
    const cycle = usage(20, 1, 32 * 1024);
    assert.equal(isAboveBudget(times(load, 479), budget), false);
    assert.equal(isAboveBudget(times(load, 480), budget), true);
    assert.equal(isAboveBudget(times(cycle, 427), budget), false);
    assert.equal(isAboveBudget(times(cycle, 428), budget), true);
  });

  it('reads other budgets exactly and refuses a non-decimal one', () => {
    assert.equal(isAboveBudget(usage(28571), '0.01'), false);
    assert.equal(isAboveBudget(usage(28572), '0.01'), true);
    assert.equal(isAboveBudget(usage(0), '0'), false);
    assert.equal(isAboveBudget(usage(1), '0'), true);
    assert.throws(() => isAboveBudget(usage(1), '5e-3'));
  });
});

describe('periods', () => {
  it('uses the UTC month, the previous one and the next reset', () => {
    assert.equal(periodIdOf(new Date('2026-11-30T23:59:59Z')), '2026-11');
    assert.equal(periodIdOf(new Date('2026-12-01T00:00:00Z')), '2026-12');
    assert.equal(previousPeriodId('2026-01'), '2025-12');
    assert.equal(nextResetUtc(new Date('2026-12-15T10:00:00Z')).toISOString(), '2027-01-01T00:00:00.000Z');
  });
});

describe('policy', () => {
  it('falls back to the safe defaults for missing or damaged fields', () => {
    assert.deepEqual(policyFromData(undefined), SAFE_POLICY);
    const policy = policyFromData({
      adsEnabled: 'yes',
      usageBudgetEuro: 0.005,
      freeActiveWineLimit: 0,
      purchasesEnabled: true,
    });
    assert.equal(policy.adsEnabled, false);
    assert.equal(policy.usageBudgetEuro, '0.005');
    assert.equal(policy.freeActiveWineLimit, 15);
    assert.equal(policy.purchasesEnabled, true);
  });
});

describe('Play state → entitlement (FR3.3, FR3.4)', () => {
  const now = new Date('2026-11-10T09:30:00Z');
  const future = new Date('2026-12-10T10:00:00Z');
  const past = new Date('2026-11-01T00:00:00Z');
  const status = (state: string, expiry: Date | null = future, revoked = false) => {
    const sub = playSub(state, { expiry });
    const verdict = verdictFor(sub, plusLineItem(sub)!, now, revoked);
    return verdict.kind === 'entitlement' ? verdict.status : verdict.kind;
  };

  it('maps every subscription state', () => {
    assert.equal(status('SUBSCRIPTION_STATE_ACTIVE'), 'active');
    assert.equal(status('SUBSCRIPTION_STATE_IN_GRACE_PERIOD'), 'grace');
    assert.equal(status('SUBSCRIPTION_STATE_ON_HOLD'), 'on_hold');
    assert.equal(status('SUBSCRIPTION_STATE_PAUSED'), 'paused');
    assert.equal(status('SUBSCRIPTION_STATE_EXPIRED'), 'expired');
    assert.equal(status('SUBSCRIPTION_STATE_PENDING'), 'pending');
    assert.equal(status('SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED'), 'none');
    assert.equal(status('SUBSCRIPTION_STATE_UNSPECIFIED'), 'none');
  });

  it('keeps a cancelled subscription active until it expires', () => {
    assert.equal(status('SUBSCRIPTION_STATE_CANCELED', future), 'active');
    assert.equal(status('SUBSCRIPTION_STATE_CANCELED', past), 'expired');
  });

  it('makes a revocation final whatever Play reports', () => {
    assert.equal(status('SUBSCRIPTION_STATE_ACTIVE', future, true), 'revoked');
  });

  it('accepts only the Plus product with a known base plan', () => {
    assert.equal(plusLineItem(playSub('SUBSCRIPTION_STATE_ACTIVE', { productId: 'other' })), null);
    assert.equal(plusLineItem(playSub('SUBSCRIPTION_STATE_ACTIVE', { basePlanId: 'weekly' })), null);
    assert.notEqual(plusLineItem(playSub('SUBSCRIPTION_STATE_ACTIVE', { basePlanId: 'annual' })), null);
  });
});

describe('Plus validity (FR1.2)', () => {
  const now = new Date('2026-11-10T09:30:00Z');
  const ts = (iso: string) => Timestamp.fromDate(new Date(iso));

  it('needs plan plus, an active or grace status and a future expiry', () => {
    const base = { plan: 'plus', source: 'play_purchase', status: 'active', expiresAt: ts('2026-12-01T00:00:00Z') };
    assert.equal(isPlusValidAt(base, now), true);
    assert.equal(isPlusValidAt({ ...base, status: 'grace' }, now), true);
    assert.equal(isPlusValidAt({ ...base, status: 'on_hold' }, now), false);
    assert.equal(isPlusValidAt({ ...base, expiresAt: ts('2026-11-01T00:00:00Z') }, now), false);
    assert.equal(isPlusValidAt({ ...base, expiresAt: null }, now), false);
    assert.equal(isPlusValidAt({ ...base, source: 'manual_grant', expiresAt: null }, now), true);
    assert.equal(isPlusValidAt(undefined, now), false);
  });
});

describe('entitlement guard', () => {
  const now = new Date('2026-11-10T09:30:00Z');
  const gift = { plan: 'plus', source: 'manual_grant', status: 'active', reason: 'gift' };
  const expired = {
    kind: 'entitlement' as const,
    status: 'expired' as const,
    expiresAt: new Date('2026-11-01T00:00:00Z'),
    basePlanId: 'monthly',
  };

  it('never lets a state without Plus replace a valid gift or another token', () => {
    assert.equal(nextEntitlement({ existing: gift, verdict: expired, hash: 'h1', now }), null);
    const otherToken = {
      plan: 'plus',
      source: 'play_purchase',
      status: 'active',
      expiresAt: Timestamp.fromDate(new Date('2026-12-01T00:00:00Z')),
      purchaseTokenHash: 'h2',
    };
    assert.equal(nextEntitlement({ existing: otherToken, verdict: expired, hash: 'h1', now }), null);
  });

  it('applies any state of the same token, and Plus over a gift', () => {
    const sameToken = { ...gift, source: 'play_purchase', purchaseTokenHash: 'h1' };
    assert.equal(nextEntitlement({ existing: sameToken, verdict: expired, hash: 'h1', now })?.status, 'expired');
    const active = { ...expired, status: 'active' as const, expiresAt: new Date('2026-12-01T00:00:00Z') };
    assert.equal(nextEntitlement({ existing: gift, verdict: active, hash: 'h1', now })?.source, 'play_purchase');
    assert.equal(nextEntitlement({ existing: undefined, verdict: { kind: 'pending' }, hash: 'h1', now }), null);
  });
});

describe('Play package (FR3.3)', () => {
  it('is the applicationId of the Android app, not the Kotlin namespace', () => {
    // functions/lib/test/ → repository root.
    const gradle = readFileSync(resolve(__dirname, '../../../android/app/build.gradle.kts'), 'utf8');
    const applicationId = /applicationId\s*=\s*"([^"]+)"/.exec(gradle)?.[1];
    assert.equal(PACKAGE_NAME, applicationId);
    assert.notEqual(PACKAGE_NAME, 'com.vinoozy.vinoozy');
  });
});
