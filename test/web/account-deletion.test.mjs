// Logic of the account deletion page (u8-account BR1.11, NFR7.6, NFR8.5)
// against the Firestore and Auth emulators, with the rules of this commit:
// the whole sequence, the resume, another account refused, deleteUser.
import assert from 'node:assert/strict';
import { after, before, beforeEach, describe, test } from 'node:test';

import { doc, getDoc, getDocs, collection, setDoc, Timestamp } from 'firebase/firestore';

import {
  classify,
  createAccountDeletion,
  displayNameOrFallback,
  PAGE_SIZE,
  STEPS,
} from '../../docs/account-deletion/account-deletion.js';
import { clearAuth, client, startRulesEnv } from './helpers.mjs';

const T0 = Timestamp.fromMillis(0);
const MARIO = { sub: 'google-mario', email: 'mario@example.com', name: 'Mario Rossi' };
const GIULIA = { sub: 'google-giulia', email: 'giulia@example.com' };
const ANNA_UID = 'uid-anna';
const PAOLO_UID = 'uid-paolo';

let env;
const clients = [];

before(async () => {
  env = await startRulesEnv();
});

after(async () => {
  for (const c of clients) await c.close();
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await clearAuth();
});

async function seed(write) {
  await env.withSecurityRulesDisabled(async (ctx) => write(ctx.firestore()));
}

async function stored(path) {
  let data;
  await env.withSecurityRulesDisabled(async (ctx) => {
    const snapshot = await getDoc(doc(ctx.firestore(), path));
    data = snapshot.exists() ? snapshot.data() : undefined;
  });
  return data;
}

async function count(path) {
  let size = 0;
  await env.withSecurityRulesDisabled(async (ctx) => {
    size = (await getDocs(collection(ctx.firestore(), path))).size;
  });
  return size;
}

const member = (ownerUid, email, extra = {}) => ({
  inviteeEmail: email,
  permission: 'edit',
  status: 'active',
  invitedAt: T0,
  ownerId: ownerUid,
  ownerName: 'Owner',
  updatedAt: T0,
  ...extra,
});

/**
 * Mario's account (unit-test-instructions.md, "Dati di test"): a cellar
 * with 2 invitations, a pending invitation in Anna's cellar, a closed one
 * in Paolo's, [wines] wines and [drinks] drinks.
 */
async function seedMario(uid, { wines = 50, drinks = 100, profile = true } = {}) {
  await seed(async (db) => {
    if (profile) {
      await setDoc(doc(db, `users/${uid}`), {
        displayName: 'Mario Rossi', email: MARIO.email, onboardingSeen: true, createdAt: T0, schemaVersion: 1,
      });
    }
    await setDoc(doc(db, `cellars/${uid}`), { ownerId: uid, name: 'La mia cantina', createdAt: T0, schemaVersion: 1, memberSlots: 2 });
    await setDoc(doc(db, `cellars/${uid}/members/giulia@example.com`), member(uid, 'giulia@example.com'));
    await setDoc(doc(db, `cellars/${uid}/members/luca@example.com`), member(uid, 'luca@example.com', { status: 'invited' }));
    for (let i = 0; i < wines; i++) {
      await setDoc(doc(db, `cellars/${uid}/wines/w${i}`), {
        name: `Vino ${i}`, quantity: i % 3, createdAt: T0, updatedAt: T0, updatedBy: uid,
      });
    }
    for (let i = 0; i < drinks; i++) {
      await setDoc(doc(db, `cellars/${uid}/drinkingRecords/r${i}`), {
        wineId: `w${i % 60}`, wineName: 'Vino', drankOn: '2026-11-01', recordedBy: uid, createdAt: T0,
      });
    }
    await setDoc(doc(db, `cellars/${ANNA_UID}`), { ownerId: ANNA_UID, name: 'Anna', createdAt: T0, schemaVersion: 1, memberSlots: 1 });
    await setDoc(doc(db, `cellars/${ANNA_UID}/members/${MARIO.email}`), member(ANNA_UID, MARIO.email, { status: 'invited' }));
    await setDoc(doc(db, `cellars/${PAOLO_UID}`), { ownerId: PAOLO_UID, name: 'Paolo', createdAt: T0, schemaVersion: 1, memberSlots: 0 });
    await setDoc(doc(db, `cellars/${PAOLO_UID}/members/${MARIO.email}`), member(PAOLO_UID, MARIO.email, { status: 'revoked', closedBy: 'owner' }));
    await setDoc(doc(db, `cellars/${PAOLO_UID}/drinkingRecords/p1`), {
      wineId: 'pw', wineName: 'Vino di Paolo', drankOn: '2026-10-01', recordedBy: uid, createdAt: T0,
    });
  });
}

async function assertNothingLeft(uid) {
  assert.equal(await stored(`users/${uid}`), undefined);
  assert.equal(await stored(`cellars/${uid}`), undefined);
  assert.equal(await count(`cellars/${uid}/members`), 0);
  assert.equal(await count(`cellars/${uid}/wines`), 0);
  assert.equal(await count(`cellars/${uid}/drinkingRecords`), 0);
  assert.equal(await stored(`cellars/${ANNA_UID}/members/${MARIO.email}`), undefined);
  assert.equal(await stored(`cellars/${PAOLO_UID}/members/${MARIO.email}`), undefined);
  // BR1.9: the drink in Paolo's cellar stays, with only the technical uid.
  assert.equal((await stored(`cellars/${PAOLO_UID}/drinkingRecords/p1`)).recordedBy, uid);
  assert.equal((await stored(`cellars/${ANNA_UID}`)).memberSlots, 0);
}

async function newClient() {
  const c = await client();
  clients.push(c);
  return c;
}

describe('account deletion page', () => {
  test('BR1.11 the whole sequence of BR1.7 deletes everything and the Auth user', async () => {
    const c = await newClient();
    const user = await c.signIn(MARIO);
    await seedMario(user.uid);
    const deletion = createAccountDeletion(c.sdk, c.db, c.auth);
    const progress = [];

    const result = await deletion.deleteAccount({ onProgress: (p) => progress.push(p) });

    assert.deepEqual(result, { status: 'completed' });
    await assertNothingLeft(user.uid);
    assert.equal(c.auth.currentUser, null);
    assert.deepEqual(
      [...new Set(progress.map((p) => p.step))],
      STEPS,
    );
    assert.equal(progress.filter((p) => p.deleted > 0).at(-1).deleted, 150);
    // The Auth user is gone: signing in again creates a new account.
    const again = await c.signIn(MARIO);
    assert.notEqual(again.uid, user.uid);
  });

  test('BR1.8 an interrupted run resumes from deletionStartedAt after a new sign-in', async () => {
    const c = await newClient();
    const user = await c.signIn(MARIO);
    await seedMario(user.uid, { wines: 3, drinks: 2 });
    let failCellar = true;
    const flaky = {
      ...c.sdk,
      deleteDoc: async (ref) => {
        if (ref.path === `cellars/${user.uid}` && failCellar) {
          failCellar = false;
          throw Object.assign(new Error('offline'), { code: 'unavailable' });
        }
        return c.sdk.deleteDoc(ref);
      },
    };
    const deletion = createAccountDeletion(flaky, c.db, c.auth);

    const first = await deletion.deleteAccount();
    assert.deepEqual(first, { status: 'stopped', step: 'deleteCellar', reason: 'network' });
    assert.equal(await deletion.isStarted(), true);
    assert.ok((await stored(`users/${user.uid}`)).deletionStartedAt);

    // Another browser (or the same page reloaded) completes it.
    const other = await newClient();
    await other.signIn(MARIO);
    const resumed = createAccountDeletion(other.sdk, other.db, other.auth);
    assert.equal(await resumed.isStarted(), true);
    assert.deepEqual(await resumed.deleteAccount(), { status: 'completed' });
    await assertNothingLeft(user.uid);
  });

  test('NFR4.6 a sign-in with another Google account deletes nothing', async () => {
    const c = await newClient();
    const user = await c.signIn(MARIO);
    await seedMario(user.uid, { wines: 1, drinks: 1 });
    await (await newClient()).signIn(GIULIA);
    const deletion = createAccountDeletion(c.sdk, c.db, c.auth);

    c.picker.next = GIULIA;
    assert.deepEqual(await deletion.deleteAccount(), {
      status: 'notConfirmed',
      reason: 'differentAccount',
    });
    assert.equal((await stored(`users/${user.uid}`)).deletionStartedAt, undefined);
    assert.equal(await count(`cellars/${user.uid}/wines`), 1);
    assert.equal(c.auth.currentUser.uid, user.uid);
  });

  test('NFR4.6 deleteUser asking for a recent sign-in stops at the last step; Try again finishes', async () => {
    const c = await newClient();
    const user = await c.signIn(MARIO);
    await seedMario(user.uid, { wines: 0, drinks: 0 });
    let refuse = true;
    const sdk = {
      ...c.sdk,
      deleteUser: async (target) => {
        if (refuse) {
          refuse = false;
          throw Object.assign(new Error('login'), { code: 'auth/requires-recent-login' });
        }
        return c.sdk.deleteUser(target);
      },
    };
    const deletion = createAccountDeletion(sdk, c.db, c.auth);

    assert.deepEqual(await deletion.deleteAccount(), {
      status: 'stopped',
      step: 'deleteProfileAndUser',
      reason: 'reauthRequired',
    });
    assert.equal(await stored(`users/${user.uid}`), undefined);
    assert.deepEqual(await deletion.deleteAccount(), { status: 'completed' });
    assert.equal(c.auth.currentUser, null);
  });

  test('BR1.10 a missing profile is created with deletionStartedAt, then deleted', async () => {
    const c = await newClient();
    const user = await c.signIn(MARIO);
    await seedMario(user.uid, { wines: 0, drinks: 0, profile: false });
    const deletion = createAccountDeletion(c.sdk, c.db, c.auth);
    assert.equal(await deletion.isStarted(), false);
    assert.deepEqual(await deletion.deleteAccount(), { status: 'completed' });
    await assertNothingLeft(user.uid);
  });

  test('BR1.8 an account without a cellar is deleted too', async () => {
    const c = await newClient();
    const user = await c.signIn(GIULIA);
    const deletion = createAccountDeletion(c.sdk, c.db, c.auth);
    assert.deepEqual(await deletion.deleteAccount(), { status: 'completed' });
    assert.equal(await stored(`users/${user.uid}`), undefined);
  });

  test('BR1.7 drinks and wines go in pages of 400', async () => {
    const c = await newClient();
    const user = await c.signIn(MARIO);
    await seedMario(user.uid, { wines: 10, drinks: 450 });
    const sizes = [];
    const sdk = {
      ...c.sdk,
      writeBatch: (db) => {
        const batch = c.sdk.writeBatch(db);
        let deletes = 0;
        const original = batch.delete.bind(batch);
        batch.delete = (ref) => {
          deletes++;
          return original(ref);
        };
        const commit = batch.commit.bind(batch);
        batch.commit = () => {
          if (deletes > 0) sizes.push(deletes);
          return commit();
        };
        return batch;
      },
    };
    const deletion = createAccountDeletion(sdk, c.db, c.auth);
    assert.deepEqual(await deletion.deleteAccount(), { status: 'completed' });
    assert.equal(PAGE_SIZE, 400);
    assert.deepEqual(sizes, [400, 50, 10]);
  });

  test('BR1.11 sign-in, cancel and sign-out of the page', async () => {
    const c = await newClient();
    const deletion = createAccountDeletion(c.sdk, c.db, c.auth);
    assert.equal(await deletion.reauthenticate(), 'failed', 'nobody is signed in');
    await assert.rejects(deletion.run(), /not signed in/);

    c.picker.cancel = true;
    assert.equal(await deletion.signIn(), 'cancelled');
    c.picker.cancel = false;
    c.picker.next = { sub: '', email: 'broken' };
    assert.equal(await deletion.signIn(), 'failed');

    c.picker.next = MARIO;
    assert.equal(await deletion.signIn(), 'signedIn');
    c.picker.cancel = true;
    assert.deepEqual(await deletion.deleteAccount(), { status: 'notConfirmed', reason: 'cancelled' });
    c.picker.cancel = false;
    await deletion.signOut();
    assert.equal(c.auth.currentUser, null);
  });

  test('BR1.10 the rules refusing a step stop the run as "rejected"', async () => {
    const c = await newClient();
    const user = await c.signIn(MARIO);
    await seedMario(user.uid, { wines: 0, drinks: 0 });
    // A run that skips step 1 is refused by the rules at step 5.
    const sdk = { ...c.sdk, runTransaction: async () => {} };
    const deletion = createAccountDeletion(sdk, c.db, c.auth);
    const result = await deletion.run();
    assert.deepEqual(result, { status: 'stopped', step: 'deleteCellar', reason: 'rejected' });
  });
});

describe('helpers', () => {
  test('classify maps the Firebase codes', () => {
    assert.equal(classify({ code: 'permission-denied' }), 'rejected');
    assert.equal(classify({ code: 'firestore/unavailable' }), 'network');
    assert.equal(classify({ code: 'auth/network-request-failed' }), 'network');
    assert.equal(classify({ code: 'auth/requires-recent-login' }), 'reauthRequired');
    assert.equal(classify(new Error('x')), 'failed');
    assert.equal(classify(undefined), 'failed');
  });

  test('displayNameOrFallback matches the app', () => {
    assert.equal(displayNameOrFallback('  Mario  ', 'm@example.com'), 'Mario');
    assert.equal(displayNameOrFallback(null, 'mario@example.com'), 'mario');
    assert.equal(displayNameOrFallback('', '@x'), '@x');
    assert.equal(displayNameOrFallback('', ''), '?');
    assert.equal(displayNameOrFallback('a'.repeat(120), 'm@x').length, 100);
    assert.equal(displayNameOrFallback(`${'a'.repeat(99)}🍷`, 'm@x').length, 99);
  });
});
