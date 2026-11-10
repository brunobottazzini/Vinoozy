// What every handler needs, injected so tests replace Play, Billing and the
// clock (freemium-plus D4).
import { getApps, initializeApp } from 'firebase-admin/app';
import { Firestore, getFirestore } from 'firebase-admin/firestore';

import {
  BillingClient,
  EmulatorBillingClient,
  GoogleBillingClient,
} from './clients/billing_client.js';
import {
  EmulatorPlayClient,
  GooglePlayClient,
  PlayClient,
} from './clients/play_client.js';

export interface Deps {
  db: Firestore;
  play: PlayClient;
  billing: BillingClient;
  /** Server time. */
  now: () => Date;
  projectId: string;
}

/** True inside the Firebase Functions emulator. */
export function runsInEmulator(): boolean {
  return process.env.FUNCTIONS_EMULATOR === 'true';
}

function projectIdFromEnv(): string {
  const id = process.env.GCLOUD_PROJECT ?? process.env.GOOGLE_CLOUD_PROJECT;
  if (!id) throw new Error('No project id in GCLOUD_PROJECT/GOOGLE_CLOUD_PROJECT');
  return id;
}

function createDeps(): Deps {
  if (getApps().length === 0) initializeApp();
  const emulator = runsInEmulator();
  return {
    db: getFirestore(),
    play: emulator ? new EmulatorPlayClient() : new GooglePlayClient(),
    billing: emulator ? new EmulatorBillingClient() : new GoogleBillingClient(),
    now: () => new Date(),
    projectId: projectIdFromEnv(),
  };
}

let current: Deps | null = null;

export function getDeps(): Deps {
  if (!current) current = createDeps();
  return current;
}

/** Tests only: replaces the dependencies of the exported functions. */
export function overrideDepsForTests(deps: Deps | null): void {
  current = deps;
}
