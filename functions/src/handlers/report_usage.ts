// reportUsage (freemium-plus FR6.3, FR6.5; study §7.6): applies only the
// delta of one installation's cumulative counters to the account total of a
// UTC month, in one transaction.
import { Timestamp } from 'firebase-admin/firestore';

import { Collections, MIN_REPORT_INTERVAL_MS, POLICY_DOC_ID } from '../config.js';
import { Deps } from '../deps.js';
import { PlanPolicy, policyFromData } from '../domain/policy.js';
import {
  addCounters,
  countersFromDevice,
  countersFromPeriod,
  deltaSince,
  isAboveBudget,
  nextResetUtc,
  periodIdOf,
  periodStart,
  previousPeriodId,
  sameCounters,
  UsageCounters,
  UsageFields,
} from '../domain/usage.js';
import { invalid, requireCount, requireObject, requireString } from './callable_support.js';

/** Why a report was not applied; the app sends a new sequence later. */
export type UsageRefusal =
  | 'STALE_SEQUENCE'
  | 'SEQUENCE_CONFLICT'
  | 'DECREASING_CUMULATIVE'
  | 'TOO_FREQUENT'
  | 'PERIOD_CLOSED'
  | 'PERIOD_NOT_STARTED';

export interface ReportUsageResponse {
  accepted: boolean;
  reason: UsageRefusal | null;
  periodId: string;
  estimatedReadCount: number;
  estimatedWriteCount: number;
  estimatedEgressBytes: number;
  aboveBudget: boolean;
  serverTime: string;
  nextResetUtc: string;
  policy: PlanPolicy;
}

interface UsageReportInput {
  installationId: string;
  periodId: string;
  sequence: number;
  cumulative: UsageCounters;
}

const INSTALLATION_ID = /^[A-Za-z0-9_-]{1,128}$/;
const PERIOD_ID = /^[0-9]{4}-[0-9]{2}$/;
const MAX_SEQUENCE = 2 ** 31 - 1;

function parseInput(raw: unknown): UsageReportInput {
  const data = requireObject(raw);
  const periodId = requireString(data, 'periodId', PERIOD_ID);
  if (!periodStart(periodId)) throw invalid('periodId');
  const sequence = requireCount(data, 'sequence');
  if (sequence < 1 || sequence > MAX_SEQUENCE) throw invalid('sequence');
  if (data.policyVersion !== undefined && typeof data.policyVersion !== 'string') {
    throw invalid('policyVersion');
  }
  return {
    installationId: requireString(data, 'installationId', INSTALLATION_ID),
    periodId,
    sequence,
    cumulative: {
      reads: requireCount(data, UsageFields.cumulativeReadCount),
      writes: requireCount(data, UsageFields.cumulativeWriteCount),
      egressBytes: requireCount(data, UsageFields.cumulativeEgressBytes),
    },
  };
}

/** Only the current server month and the one before take reports. */
function periodRefusal(periodId: string, now: Date): UsageRefusal | null {
  const current = periodIdOf(now);
  if (periodId > current) return 'PERIOD_NOT_STARTED';
  if (periodId !== current && periodId !== previousPeriodId(current)) return 'PERIOD_CLOSED';
  return null;
}

async function readPolicy(deps: Deps): Promise<PlanPolicy> {
  const snapshot = await deps.db.collection(Collections.config).doc(POLICY_DOC_ID).get();
  return policyFromData(snapshot.data());
}

/** The device's verdict on [input] against its last accepted report. */
function deviceRefusal(
  device: Record<string, unknown> | undefined,
  input: UsageReportInput,
  now: Date,
): { refusal: UsageRefusal | null; duplicate: boolean; delta: UsageCounters | null } {
  const lastSequence = typeof device?.lastSequence === 'number' ? device.lastSequence : 0;
  const previous = countersFromDevice(device);
  if (device && input.sequence < lastSequence) {
    return { refusal: 'STALE_SEQUENCE', duplicate: false, delta: null };
  }
  if (device && input.sequence === lastSequence) {
    return sameCounters(previous, input.cumulative)
      ? { refusal: null, duplicate: true, delta: null }
      : { refusal: 'SEQUENCE_CONFLICT', duplicate: false, delta: null };
  }
  const delta = deltaSince(input.cumulative, previous);
  if (!delta) return { refusal: 'DECREASING_CUMULATIVE', duplicate: false, delta: null };
  const updatedAt = device?.updatedAt;
  if (
    updatedAt instanceof Timestamp &&
    now.getTime() - updatedAt.toMillis() < MIN_REPORT_INTERVAL_MS
  ) {
    return { refusal: 'TOO_FREQUENT', duplicate: false, delta: null };
  }
  return { refusal: null, duplicate: false, delta };
}

export async function reportUsageHandler(
  deps: Deps,
  uid: string,
  rawData: unknown,
): Promise<ReportUsageResponse> {
  const input = parseInput(rawData);
  const now = deps.now();
  const policy = await readPolicy(deps);
  const periodRef = deps.db
    .collection(Collections.usage)
    .doc(uid)
    .collection(Collections.periods)
    .doc(input.periodId);
  const deviceRef = periodRef.collection(Collections.devices).doc(input.installationId);
  const closed = periodRefusal(input.periodId, now);
  const { refusal, total } = await deps.db.runTransaction(async (tx) => {
    const [periodSnap, deviceSnap] = await Promise.all([tx.get(periodRef), tx.get(deviceRef)]);
    const current = countersFromPeriod(periodSnap.data());
    if (closed) return { refusal: closed, total: current };
    const verdict = deviceRefusal(deviceSnap.data(), input, now);
    if (verdict.refusal || verdict.duplicate || !verdict.delta) {
      return { refusal: verdict.refusal, total: current };
    }
    const total = addCounters(current, verdict.delta);
    const nowTs = Timestamp.fromDate(now);
    tx.set(deviceRef, {
      [UsageFields.lastSequence]: input.sequence,
      [UsageFields.cumulativeReadCount]: input.cumulative.reads,
      [UsageFields.cumulativeWriteCount]: input.cumulative.writes,
      [UsageFields.cumulativeEgressBytes]: input.cumulative.egressBytes,
      [UsageFields.updatedAt]: nowTs,
    });
    tx.set(periodRef, {
      [UsageFields.policyVersion]: policy.policyVersion,
      [UsageFields.estimatedReadCount]: total.reads,
      [UsageFields.estimatedWriteCount]: total.writes,
      [UsageFields.estimatedEgressBytes]: total.egressBytes,
      [UsageFields.updatedAt]: nowTs,
    });
    return { refusal: null, total };
  });
  return {
    accepted: refusal === null,
    reason: refusal,
    periodId: input.periodId,
    estimatedReadCount: total.reads,
    estimatedWriteCount: total.writes,
    estimatedEgressBytes: total.egressBytes,
    aboveBudget: isAboveBudget(total, policy.usageBudgetEuro),
    serverTime: now.toISOString(),
    nextResetUtc: nextResetUtc(now).toISOString(),
    policy,
  };
}
