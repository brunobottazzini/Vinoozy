// Server mirror of lib/usage/domain/usage_counters.dart and
// lib/usage/usage_cost.dart (study §7.3, §7.6; freemium-plus FR6.2, D3).

/** Reads, confirmed writes and received bytes. Non-negative integers. */
export interface UsageCounters {
  reads: number;
  writes: number;
  egressBytes: number;
}

export const ZERO_USAGE: UsageCounters = { reads: 0, writes: 0, egressBytes: 0 };

/** Field names shared with the app (UsageFields in usage_counters.dart). */
export const UsageFields = {
  policyVersion: 'policyVersion',
  estimatedReadCount: 'estimatedReadCount',
  estimatedWriteCount: 'estimatedWriteCount',
  estimatedEgressBytes: 'estimatedEgressBytes',
  updatedAt: 'updatedAt',
  lastSequence: 'lastSequence',
  cumulativeReadCount: 'cumulativeReadCount',
  cumulativeWriteCount: 'cumulativeWriteCount',
  cumulativeEgressBytes: 'cumulativeEgressBytes',
} as const;

function count(value: unknown): number {
  return typeof value === 'number' && Number.isSafeInteger(value) && value >= 0
    ? value
    : 0;
}

/** The account total of a period document; damaged values read as 0. */
export function countersFromPeriod(
  data: Record<string, unknown> | undefined,
): UsageCounters {
  return {
    reads: count(data?.[UsageFields.estimatedReadCount]),
    writes: count(data?.[UsageFields.estimatedWriteCount]),
    egressBytes: count(data?.[UsageFields.estimatedEgressBytes]),
  };
}

/** The last cumulative accepted for one installation. */
export function countersFromDevice(
  data: Record<string, unknown> | undefined,
): UsageCounters {
  return {
    reads: count(data?.[UsageFields.cumulativeReadCount]),
    writes: count(data?.[UsageFields.cumulativeWriteCount]),
    egressBytes: count(data?.[UsageFields.cumulativeEgressBytes]),
  };
}

export function addCounters(a: UsageCounters, b: UsageCounters): UsageCounters {
  return {
    reads: a.reads + b.reads,
    writes: a.writes + b.writes,
    egressBytes: a.egressBytes + b.egressBytes,
  };
}

export function sameCounters(a: UsageCounters, b: UsageCounters): boolean {
  return (
    a.reads === b.reads && a.writes === b.writes && a.egressBytes === b.egressBytes
  );
}

/** Usage added since [previous]; null when any cumulative went down. */
export function deltaSince(
  current: UsageCounters,
  previous: UsageCounters,
): UsageCounters | null {
  if (
    current.reads < previous.reads ||
    current.writes < previous.writes ||
    current.egressBytes < previous.egressBytes
  ) {
    return null;
  }
  return {
    reads: current.reads - previous.reads,
    writes: current.writes - previous.writes,
    egressBytes: current.egressBytes - previous.egressBytes,
  };
}

// ---- Periods (one UTC calendar month) -------------------------------------

const PERIOD_ID = /^([0-9]{4})-([0-9]{2})$/;

export function periodIdOf(instant: Date): string {
  const year = instant.getUTCFullYear().toString().padStart(4, '0');
  const month = (instant.getUTCMonth() + 1).toString().padStart(2, '0');
  return `${year}-${month}`;
}

/** First instant (UTC) of the period [periodId]; null when not a period. */
export function periodStart(periodId: string): Date | null {
  const match = PERIOD_ID.exec(periodId);
  if (!match) return null;
  const month = Number(match[2]);
  if (month < 1 || month > 12) return null;
  return new Date(Date.UTC(Number(match[1]), month - 1, 1));
}

/** The id of the period before [periodId] (which must be valid). */
export function previousPeriodId(periodId: string): string {
  const start = periodStart(periodId);
  if (!start) throw new Error(`not a period id: ${periodId}`);
  return periodIdOf(new Date(Date.UTC(start.getUTCFullYear(), start.getUTCMonth() - 1, 1)));
}

/** When the counters of the period containing [instant] start again. */
export function nextResetUtc(instant: Date): Date {
  return new Date(Date.UTC(instant.getUTCFullYear(), instant.getUTCMonth() + 1, 1));
}

/** `YYYY-MM-DD` of [instant] in UTC: the ad slot day (study §7.7). */
export function utcDayId(instant: Date): string {
  return instant.toISOString().slice(0, 10);
}

// ---- Cost (D3: exact integer arithmetic) ----------------------------------

const GIB = 2n ** 30n;
const READ_UNITS = 35n * GIB;
const WRITE_UNITS = 104n * GIB;
const BYTE_UNITS = 12_000_000n;
/** `10^8 · 2^30`: one euro in the units of [scaledCost]. */
export const EURO_UNITS = 100_000_000n * GIB;

/** `C_hat · 10^8 · 2^30`, an exact integer. */
export function scaledCost(usage: UsageCounters): bigint {
  return (
    BigInt(usage.reads) * READ_UNITS +
    BigInt(usage.writes) * WRITE_UNITS +
    BigInt(usage.egressBytes) * BYTE_UNITS
  );
}

const DECIMAL = /^([0-9]+)(?:\.([0-9]+))?$/;

export function isValidBudget(text: unknown): text is string {
  return typeof text === 'string' && DECIMAL.test(text);
}

/**
 * Whether `C_hat` is strictly above [budgetEuro] (at equality no ads). A
 * budget that is not a plain non-negative decimal throws.
 */
export function isAboveBudget(usage: UsageCounters, budgetEuro: string): boolean {
  const match = DECIMAL.exec(budgetEuro);
  if (!match) throw new Error(`not a decimal budget: ${budgetEuro}`);
  const fraction = match[2] ?? '';
  const numerator = BigInt(`${match[1]}${fraction}`);
  const scale = 10n ** BigInt(fraction.length);
  return scaledCost(usage) * scale > numerator * EURO_UNITS;
}
