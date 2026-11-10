// Shared test helpers: Firestore emulator only, fake Play and Billing
// clients and a settable clock (freemium-plus Step 14).
import { getApps, initializeApp } from 'firebase-admin/app';
import { Firestore, getFirestore } from 'firebase-admin/firestore';

import { BillingClient } from '../src/clients/billing_client.js';
import {
  PlayClient,
  PlayPurchaseNotFoundError,
  PlayUnavailableError,
} from '../src/clients/play_client.js';
import { PLUS_PRODUCT_ID } from '../src/config.js';
import { Deps } from '../src/deps.js';
import { PlaySubscription } from '../src/domain/play_state.js';

export const PROJECT_ID = 'demo-vinoozy';

const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST;
if (!firestoreHost) {
  throw new Error(
    'FIRESTORE_EMULATOR_HOST is not set: run the tests with `npm run test:functions` ' +
      '(Firebase Emulator Suite, project demo-vinoozy). They never touch a real project.',
  );
}
if (process.env.GCLOUD_PROJECT && process.env.GCLOUD_PROJECT !== PROJECT_ID) {
  throw new Error(`Tests run only on ${PROJECT_ID}, not ${process.env.GCLOUD_PROJECT}.`);
}

export function testDb(): Firestore {
  if (getApps().length === 0) initializeApp({ projectId: PROJECT_ID });
  return getFirestore();
}

/** Deletes every document of the emulator's database. */
export async function clearFirestore(): Promise<void> {
  const url = `http://${firestoreHost}/emulator/v1/projects/${PROJECT_ID}/databases/(default)/documents`;
  const response = await fetch(url, { method: 'DELETE' });
  if (!response.ok) throw new Error(`Cannot clear the emulator: ${response.status}`);
}

/** A Play subscription as `purchases.subscriptionsv2.get` returns it. */
export function playSub(
  state: string,
  options: {
    expiry?: Date | null;
    productId?: string;
    basePlanId?: string;
    acknowledged?: boolean;
    linkedPurchaseToken?: string;
  } = {},
): PlaySubscription {
  const expiry = options.expiry === undefined ? new Date('2026-12-10T10:00:00Z') : options.expiry;
  return {
    subscriptionState: state,
    acknowledgementState: options.acknowledged
      ? 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED'
      : 'ACKNOWLEDGEMENT_STATE_PENDING',
    linkedPurchaseToken: options.linkedPurchaseToken,
    lineItems: [
      {
        productId: options.productId ?? PLUS_PRODUCT_ID,
        expiryTime: expiry ? expiry.toISOString() : null,
        offerDetails: { basePlanId: options.basePlanId ?? 'monthly' },
      },
    ],
  };
}

/** Play with programmable answers; acknowledging flips the state. */
export class FakePlay implements PlayClient {
  subscriptions = new Map<string, PlaySubscription>();
  unavailable = false;
  failAcknowledge = false;
  getCalls = 0;
  acknowledged: string[] = [];

  async getSubscription(token: string): Promise<PlaySubscription> {
    this.getCalls++;
    if (this.unavailable) throw new PlayUnavailableError('fake outage');
    const sub = this.subscriptions.get(token);
    if (!sub) throw new PlayPurchaseNotFoundError();
    return structuredClone(sub);
  }

  async acknowledge(productId: string, token: string): Promise<void> {
    if (this.failAcknowledge) throw new PlayUnavailableError('fake ack failure');
    if (productId !== PLUS_PRODUCT_ID) throw new Error(`unexpected product ${productId}`);
    this.acknowledged.push(token);
    const sub = this.subscriptions.get(token);
    if (sub) sub.acknowledgementState = 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED';
  }
}

export class FakeBilling implements BillingClient {
  enabled = true;
  disabledProjects: string[] = [];

  async isBillingEnabled(): Promise<boolean> {
    return this.enabled;
  }

  async disableBilling(projectId: string): Promise<void> {
    this.disabledProjects.push(projectId);
    this.enabled = false;
  }
}

export interface TestDeps extends Deps {
  play: FakePlay;
  billing: FakeBilling;
  clock: { now: Date };
}

/** Fresh fakes on the emulator, with the clock at [now]. */
export function makeDeps(now = new Date('2026-11-10T09:30:00Z')): TestDeps {
  const clock = { now };
  return {
    db: testDb(),
    play: new FakePlay(),
    billing: new FakeBilling(),
    now: () => new Date(clock.now.getTime()),
    projectId: PROJECT_ID,
    clock,
  };
}

/** Runs [body] and returns the HttpsError-like rejection it throws. */
export async function rejection(body: () => Promise<unknown>): Promise<{
  code: string;
  details?: { reason?: string };
}> {
  try {
    await body();
  } catch (error) {
    return error as { code: string; details?: { reason?: string } };
  }
  throw new Error('expected a rejection');
}
