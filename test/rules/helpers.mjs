// Shared helpers for the Firestore rules tests.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { initializeTestEnvironment } from '@firebase/rules-unit-testing';

export const PROJECT_ID = 'demo-vinoozy';
const here = dirname(fileURLToPath(import.meta.url));
export const RULES_PATH = join(here, '..', '..', 'firestore.rules');

export function currentRules() {
  return readFileSync(RULES_PATH, 'utf8');
}

/** Starts a test environment on the running Firestore emulator. */
export async function startEnv(rules = currentRules()) {
  const hostPort = process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
  const [host, port] = hostPort.split(':');
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules, host, port: Number(port) },
  });
}

/**
 * Firestore of a user signed in with Google (the only allowed provider).
 * Google accounts always carry a verified email (u7-sharing NFR4.4).
 */
export function googleUser(env, uid, email = `${uid}@example.com`) {
  return env
    .authenticatedContext(uid, {
      email,
      email_verified: true,
      firebase: { sign_in_provider: 'google.com' },
    })
    .firestore();
}

/** Firestore of a Google user whose email is not verified (NFR4.4). */
export function unverifiedGoogleUser(env, uid, email = `${uid}@example.com`) {
  return env
    .authenticatedContext(uid, {
      email,
      email_verified: false,
      firebase: { sign_in_provider: 'google.com' },
    })
    .firestore();
}

/** Firestore of a user signed in with another provider. */
export function userWithProvider(env, uid, provider) {
  return env
    .authenticatedContext(uid, { firebase: { sign_in_provider: provider } })
    .firestore();
}
