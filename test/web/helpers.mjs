// Shared setup of the web page tests (u8-account security-design.md §7):
// the Firestore and Auth emulators of `npm run test:web`, the current
// firestore.rules loaded explicitly, and a Google sign-in simulated with an
// unsigned id token, which only the Auth emulator accepts.
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { deleteApp, initializeApp } from 'firebase/app';
import {
  connectAuthEmulator,
  deleteUser,
  getAuth,
  GoogleAuthProvider,
  reauthenticateWithCredential,
  signInWithCredential,
  signOut,
} from 'firebase/auth';
import * as firestore from 'firebase/firestore';

export const PROJECT_ID = 'demo-vinoozy';
const here = dirname(fileURLToPath(import.meta.url));
export const ROOT = join(here, '..', '..');

function hostPort(variable, fallback) {
  const [host, port] = (process.env[variable] ?? fallback).split(':');
  return { host, port: Number(port) };
}

export const FIRESTORE = hostPort('FIRESTORE_EMULATOR_HOST', '127.0.0.1:8080');
export const AUTH = hostPort('FIREBASE_AUTH_EMULATOR_HOST', '127.0.0.1:9099');

/** Rules-unit-testing environment with the rules of this commit. */
export function startRulesEnv() {
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(join(ROOT, 'firestore.rules'), 'utf8'),
      host: FIRESTORE.host,
      port: FIRESTORE.port,
    },
  });
}

/** Removes every Auth emulator user of the demo project. */
export async function clearAuth() {
  await fetch(
    `http://${AUTH.host}:${AUTH.port}/emulator/v1/projects/${PROJECT_ID}/accounts`,
    { method: 'DELETE' },
  );
}

/** Google credential of [identity], as the Auth emulator accepts it. */
export function googleCredential(identity) {
  return GoogleAuthProvider.credential(
    JSON.stringify({
      sub: identity.sub,
      email: identity.email,
      email_verified: true,
      name: identity.name ?? identity.email.split('@')[0],
    }),
  );
}

let appCount = 0;

/**
 * A browser-like client: app, Auth and Firestore on the emulators, plus the
 * `sdk` object the page passes to createAccountDeletion, with the popups
 * replaced by credential sign-ins of [identity] (or of `picker.next`, the
 * account "chosen" in the Google picker).
 */
export async function client() {
  const app = initializeApp(
    { projectId: PROJECT_ID, apiKey: 'demo-key', appId: 'demo-app' },
    `web-test-${appCount++}`,
  );
  const auth = getAuth(app);
  connectAuthEmulator(auth, `http://${AUTH.host}:${AUTH.port}`, { disableWarnings: true });
  const db = firestore.getFirestore(app);
  firestore.connectFirestoreEmulator(db, FIRESTORE.host, FIRESTORE.port);
  const picker = { next: null, cancel: false };
  const popupError = () =>
    Object.assign(new Error('popup closed'), { code: 'auth/popup-closed-by-user' });
  const sdk = {
    ...firestore,
    GoogleAuthProvider,
    deleteUser,
    signOut,
    signInWithPopup: async (target) => {
      if (picker.cancel) throw popupError();
      return signInWithCredential(target, googleCredential(picker.next));
    },
    reauthenticateWithPopup: async (user) => {
      if (picker.cancel) throw popupError();
      return reauthenticateWithCredential(user, googleCredential(picker.next));
    },
  };
  return {
    app,
    auth,
    db,
    sdk,
    picker,
    async signIn(identity) {
      picker.next = identity;
      const result = await signInWithCredential(auth, googleCredential(identity));
      return result.user;
    },
    close: () => deleteApp(app),
  };
}
