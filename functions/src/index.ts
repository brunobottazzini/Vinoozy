// Vinoozy Cloud Functions entry point (freemium-plus D4, FR9.3).
//
// Every function runs in europe-west8, the region of the Firestore database
// (docs/firebase-setup.md). The callables take the uid from Firebase Auth
// and require App Check (`enforceAppCheck: true`); in the Functions emulator
// tokens are decoded but not verified, so local runs work with any App
// Check debug token (functions/README.md).
//
// Nothing here is deployed by CI: the owner deploys after the Blaze switch
// described in docs/blaze-switch.md (FR9.1).
import { setGlobalOptions } from 'firebase-functions/v2';
import { CallableRequest, onCall } from 'firebase-functions/v2/https';
import { onMessagePublished } from 'firebase-functions/v2/pubsub';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import * as functionsV1 from 'firebase-functions/v1';

import { BUDGET_ALERT_TOPIC, FUNCTIONS_REGION, PLAY_RTDN_TOPIC } from './config.js';
import { getDeps } from './deps.js';
import { recordAdOutcomeHandler, reserveAdSlotHandler } from './handlers/ad_slots.js';
import { cleanupDeletedUser, purgeOldDetails } from './handlers/account_cleanup.js';
import { BudgetNotification, handleBudgetAlert } from './handlers/budget_alert.js';
import { requireUid, runCallable } from './handlers/callable_support.js';
import {
  DeveloperNotification,
  handlePlayNotification,
  reconcileEntitlementsHandler,
} from './handlers/play_rtdn.js';
import { reportUsageHandler } from './handlers/report_usage.js';
import { verifyPurchaseHandler } from './handlers/verify_purchase.js';

export { FUNCTIONS_REGION };

setGlobalOptions({ region: FUNCTIONS_REGION, maxInstances: 2 });

const callableOptions = { enforceAppCheck: true, maxInstances: 2 } as const;

/** FR3.3: binds a Play purchase to the caller and grants Plus if paid. */
export const verifyPurchase = onCall(callableOptions, (request: CallableRequest<unknown>) =>
  runCallable('verifyPurchase', () =>
    verifyPurchaseHandler(getDeps(), requireUid(request), request.data),
  ),
);

/** FR6.3: applies the delta of one installation's cumulative counters. */
export const reportUsage = onCall(callableOptions, (request: CallableRequest<unknown>) =>
  runCallable('reportUsage', () =>
    reportUsageHandler(getDeps(), requireUid(request), request.data),
  ),
);

/** FR7.2: the one ad attempt of the account for the UTC day. */
export const reserveAdSlot = onCall(callableOptions, (request: CallableRequest<unknown>) =>
  runCallable('reserveAdSlot', () => reserveAdSlotHandler(getDeps(), requireUid(request))),
);

/** FR7.6: request, load, impression, failure and revenue of an attempt. */
export const recordAdOutcome = onCall(callableOptions, (request: CallableRequest<unknown>) =>
  runCallable('recordAdOutcome', () =>
    recordAdOutcomeHandler(getDeps(), requireUid(request), request.data),
  ),
);

/** FR3.4: Play RTDN. Retried by Pub/Sub when Play is unreachable. */
export const onPlayRtdn = onMessagePublished(
  { topic: PLAY_RTDN_TOPIC, retry: true },
  async (event) => {
    const message = event.data.message;
    let payload: DeveloperNotification | null = null;
    try {
      payload = message.json as DeveloperNotification;
    } catch {
      payload = null;
    }
    await handlePlayNotification(getDeps(), message.messageId, payload);
  },
);

/** FR3.4: daily reconciliation of the purchases that can still change. */
export const reconcileEntitlements = onSchedule(
  { schedule: 'every day 03:00', timeZone: 'Etc/UTC' },
  async () => {
    await reconcileEntitlementsHandler(getDeps());
  },
);

/** FR9.2: unlinks billing when the budget is exceeded. */
export const onBudgetAlert = onMessagePublished(
  { topic: BUDGET_ALERT_TOPIC, retry: false },
  async (event) => {
    const message = event.data.message;
    let payload: BudgetNotification | null = null;
    try {
      payload = message.json as BudgetNotification;
    } catch {
      payload = null;
    }
    await handleBudgetAlert(getDeps(), message.messageId, payload);
  },
);

/** NFR6: account deletion removes entitlement, usage and ad slots. */
export const onUserDeleted = functionsV1
  .region(FUNCTIONS_REGION)
  .auth.user()
  .onDelete(async (user) => {
    await cleanupDeletedUser(getDeps(), user.uid);
  });

/** NFR6: measurement details are kept for 90 days. */
export const purgeOldUsage = onSchedule(
  { schedule: 'every day 04:00', timeZone: 'Etc/UTC' },
  async () => {
    await purgeOldDetails(getDeps());
  },
);
