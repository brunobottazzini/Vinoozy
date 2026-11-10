// The exported callables: authentication through firebase-functions-test,
// and App Check enforcement through the real Functions emulator (NFR1).
import assert from 'node:assert/strict';
import functionsTest from 'firebase-functions-test';

import { overrideDepsForTests } from '../src/deps.js';
import { recordAdOutcome, reportUsage, reserveAdSlot, verifyPurchase } from '../src/index.js';
import { clearFirestore, makeDeps, PROJECT_ID, playSub, rejection, TestDeps } from './helpers.js';

const testEnv = functionsTest({ projectId: PROJECT_ID });

function request(data: unknown, uid?: string): any {
  return {
    data,
    auth: uid ? { uid, token: { uid } } : undefined,
    app: { appId: '1:123:android:abc', token: {} },
    rawRequest: {},
  };
}

describe('callables (wrapped)', () => {
  let deps: TestDeps;

  beforeEach(async () => {
    await clearFirestore();
    deps = makeDeps();
    overrideDepsForTests(deps);
  });

  after(() => {
    overrideDepsForTests(null);
    testEnv.cleanup();
  });

  it('refuse a caller without authentication', async () => {
    const callables: any[] = [verifyPurchase, reportUsage, reserveAdSlot, recordAdOutcome];
    for (const fn of callables) {
      const error = await rejection(async () => testEnv.wrap(fn)(request({})));
      assert.equal(error.code, 'unauthenticated');
      assert.equal(error.details?.reason, 'UNAUTHENTICATED');
    }
  });

  it('verifyPurchase takes the uid from Auth', async () => {
    deps.play.subscriptions.set('t-wrap', playSub('SUBSCRIPTION_STATE_ACTIVE'));
    const result = await testEnv.wrap(verifyPurchase)(request({ purchaseToken: 't-wrap', uid: 'someone-else' }, 'jo'));
    assert.equal(result.state, 'active');
    assert.equal((await deps.db.collection('entitlements').doc('jo').get()).exists, true);
    assert.equal((await deps.db.collection('entitlements').doc('someone-else').get()).exists, false);
  });

  it('turns an unexpected failure into internal, without details of the request', async () => {
    deps.play.getSubscription = async () => {
      throw new TypeError('boom');
    };
    const error = await rejection(async () =>
      testEnv.wrap(verifyPurchase)(request({ purchaseToken: 't-boom' }, 'jo')),
    );
    assert.equal(error.code, 'internal');
    assert.equal(error.details?.reason, 'INTERNAL');
  });
});

// ---- Through the Functions emulator ----------------------------------------

const FUNCTIONS_HOST = process.env.FUNCTIONS_EMULATOR_HOST ?? '127.0.0.1:5001';
const AUTH_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST ?? '127.0.0.1:9099';

/** An emulator ID token for a new user (unsigned; the emulator decodes it). */
async function emulatorIdToken(): Promise<{ idToken: string; uid: string }> {
  const response = await fetch(
    `http://${AUTH_HOST}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key`,
    {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ email: `u${Date.now()}@example.com`, password: 'secret-123', returnSecureToken: true }),
    },
  );
  const json = (await response.json()) as { idToken: string; localId: string };
  return { idToken: json.idToken, uid: json.localId };
}

/** An unsigned App Check token: the emulator decodes it without verifying. */
function fakeAppCheckToken(): string {
  const part = (value: object) => Buffer.from(JSON.stringify(value)).toString('base64url');
  const now = Math.floor(Date.now() / 1000);
  return `${part({ alg: 'none', typ: 'JWT' })}.${part({ sub: '1:123:android:abc', iat: now, exp: now + 3600 })}.sig`;
}

async function callEmulator(name: string, data: unknown, headers: Record<string, string>) {
  const response = await fetch(`http://${FUNCTIONS_HOST}/${PROJECT_ID}/europe-west8/${name}`, {
    method: 'POST',
    headers: { 'content-type': 'application/json', ...headers },
    body: JSON.stringify({ data }),
  });
  return { status: response.status, body: (await response.json()) as any };
}

describe('callables (Functions emulator, enforceAppCheck)', () => {
  before(async function () {
    try {
      await fetch(`http://${FUNCTIONS_HOST}/`);
    } catch {
      throw new Error(`The Functions emulator is not running on ${FUNCTIONS_HOST}: use npm run test:functions.`);
    }
    await clearFirestore();
  });

  const usage = {
    installationId: 'emulator-phone',
    periodId: new Date().toISOString().slice(0, 7),
    sequence: 1,
    cumulativeReadCount: 12,
    cumulativeWriteCount: 1,
    cumulativeEgressBytes: 4096,
  };

  it('refuses a request without an App Check token', async () => {
    const { idToken } = await emulatorIdToken();
    const result = await callEmulator('reportUsage', usage, { authorization: `Bearer ${idToken}` });
    assert.equal(result.status, 401);
    assert.equal(result.body.error.status, 'UNAUTHENTICATED');
  });

  it('refuses a request without a signed-in user', async () => {
    const result = await callEmulator('reportUsage', usage, { 'x-firebase-appcheck': fakeAppCheckToken() });
    assert.equal(result.body.error.status, 'UNAUTHENTICATED');
  });

  it('serves reportUsage with Auth and App Check, writing only on the emulator', async () => {
    const { idToken, uid } = await emulatorIdToken();
    const result = await callEmulator('reportUsage', usage, {
      authorization: `Bearer ${idToken}`,
      'x-firebase-appcheck': fakeAppCheckToken(),
    });
    assert.equal(result.status, 200, JSON.stringify(result.body));
    assert.equal(result.body.result.accepted, true);
    assert.equal(result.body.result.estimatedReadCount, 12);
    const stored = await makeDeps()
      .db.collection('usage')
      .doc(uid)
      .collection('periods')
      .doc(usage.periodId)
      .get();
    assert.equal(stored.data()?.estimatedEgressBytes, 4096);
  });
});
