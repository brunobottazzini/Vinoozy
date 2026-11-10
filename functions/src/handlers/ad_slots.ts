// reserveAdSlot and recordAdOutcome (freemium-plus FR7.2, FR7.6; study
// §7.7): one ad attempt per account and UTC day, shared by every device,
// and a log of what happened to it.
import { randomUUID } from 'node:crypto';
import { DocumentReference, Timestamp } from 'firebase-admin/firestore';

import { Collections, POLICY_DOC_ID } from '../config.js';
import { Deps } from '../deps.js';
import { isPlusValidAt } from '../domain/entitlement.js';
import { policyFromData } from '../domain/policy.js';
import { countersFromPeriod, isAboveBudget, periodIdOf, utcDayId } from '../domain/usage.js';
import { callableError, requireObject, requireString } from './callable_support.js';

export type SlotRefusal =
  | 'ADS_DISABLED'
  | 'PLUS_ACTIVE'
  | 'BELOW_THRESHOLD'
  | 'ALREADY_RESERVED';

export interface ReserveAdSlotResponse {
  granted: boolean;
  reason: SlotRefusal | null;
  reservationId: string | null;
  day: string;
  serverTime: string;
}

function slotRef(deps: Deps, uid: string, day: string): DocumentReference {
  return deps.db.collection(Collections.adSlots).doc(uid).collection(Collections.days).doc(day);
}

/**
 * Re-checks, inside one transaction, the switch, the Plus entitlement, the
 * account's threshold for the current server month and the day's slot.
 * Only one device gets the slot; it is used even with no fill or an error.
 */
export async function reserveAdSlotHandler(
  deps: Deps,
  uid: string,
): Promise<ReserveAdSlotResponse> {
  const now = deps.now();
  const day = utcDayId(now);
  const ref = slotRef(deps, uid, day);
  const db = deps.db;
  const decision = await db.runTransaction(async (tx) => {
    const [policySnap, entitlementSnap, periodSnap, slotSnap] = await Promise.all([
      tx.get(db.collection(Collections.config).doc(POLICY_DOC_ID)),
      tx.get(db.collection(Collections.entitlements).doc(uid)),
      tx.get(
        db.collection(Collections.usage).doc(uid).collection(Collections.periods).doc(periodIdOf(now)),
      ),
      tx.get(ref),
    ]);
    const policy = policyFromData(policySnap.data());
    if (!policy.adsEnabled) return { reason: 'ADS_DISABLED' as const };
    if (isPlusValidAt(entitlementSnap.data(), now)) return { reason: 'PLUS_ACTIVE' as const };
    if (!isAboveBudget(countersFromPeriod(periodSnap.data()), policy.usageBudgetEuro)) {
      return { reason: 'BELOW_THRESHOLD' as const };
    }
    if (slotSnap.exists) return { reason: 'ALREADY_RESERVED' as const };
    const reservationId = randomUUID();
    tx.create(ref, {
      reservationId,
      reservedAt: Timestamp.fromDate(now),
      periodId: periodIdOf(now),
    });
    return { reason: null, reservationId };
  });
  return {
    granted: decision.reason === null,
    reason: decision.reason,
    reservationId: decision.reason === null ? decision.reservationId : null,
    day,
    serverTime: now.toISOString(),
  };
}

/** Events of one reserved attempt; `loaded` is never an impression. */
export const AD_EVENTS = ['request', 'loaded', 'impression', 'failed', 'revenue'] as const;
export type AdEvent = (typeof AD_EVENTS)[number];

const EVENT_FIELD: Record<AdEvent, string> = {
  request: 'requestedAt',
  loaded: 'loadedAt',
  impression: 'impressionAt',
  failed: 'failedAt',
  revenue: 'revenueAt',
};

export interface RecordAdOutcomeResponse {
  /** False when the same event was already recorded (deduplicated). */
  recorded: boolean;
}

interface OutcomeInput {
  reservationId: string;
  day: string;
  event: AdEvent;
  revenue: Record<string, unknown> | null;
}

const RESERVATION_ID = /^[0-9a-f-]{36}$/;
const DAY = /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/;
const CURRENCY = /^[A-Z]{3}$/;
const PRECISIONS = ['unknown', 'estimated', 'publisher_provided', 'precise'];

function parseRevenue(data: Record<string, unknown>): Record<string, unknown> {
  const micros = data.valueMicros;
  if (typeof micros !== 'number' || !Number.isSafeInteger(micros) || micros < 0) {
    throw callableError('invalid-argument', 'INVALID_REQUEST', 'Invalid field: valueMicros');
  }
  const currencyCode = requireString(data, 'currencyCode', CURRENCY);
  const precision = data.precision ?? 'unknown';
  if (typeof precision !== 'string' || !PRECISIONS.includes(precision)) {
    throw callableError('invalid-argument', 'INVALID_REQUEST', 'Invalid field: precision');
  }
  return { revenueMicros: micros, revenueCurrency: currencyCode, revenuePrecision: precision };
}

function parseOutcome(raw: unknown): OutcomeInput {
  const data = requireObject(raw);
  const event = data.event;
  if (typeof event !== 'string' || !(AD_EVENTS as readonly string[]).includes(event)) {
    throw callableError('invalid-argument', 'INVALID_REQUEST', 'Invalid field: event');
  }
  return {
    reservationId: requireString(data, 'reservationId', RESERVATION_ID),
    day: requireString(data, 'day', DAY),
    event: event as AdEvent,
    revenue: event === 'revenue' ? parseRevenue(data) : null,
  };
}

/**
 * Records one event of a reserved attempt, once: a repeated callback keeps
 * the first time. Only the slot's own reservation can write to it.
 */
export async function recordAdOutcomeHandler(
  deps: Deps,
  uid: string,
  rawData: unknown,
): Promise<RecordAdOutcomeResponse> {
  const input = parseOutcome(rawData);
  const ref = slotRef(deps, uid, input.day);
  const field = EVENT_FIELD[input.event];
  const recorded = await deps.db.runTransaction(async (tx) => {
    const slot = (await tx.get(ref)).data();
    if (!slot || slot.reservationId !== input.reservationId) {
      throw callableError('not-found', 'NO_RESERVATION', 'No such ad reservation.');
    }
    if (slot[field] !== undefined) return false;
    tx.update(ref, {
      [field]: Timestamp.fromDate(deps.now()),
      ...(input.revenue ?? {}),
    });
    return true;
  });
  return { recorded };
}
