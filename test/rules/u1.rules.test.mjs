// Firestore security rules of U1 (security-design.md §2; NFR4.1-NFR4.5,
// NFR4.11; NFR7.2: every rule has at least one allowed and one denied case).
import { after, before, beforeEach, describe, test } from 'node:test';

import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  increment,
  query,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  where,
} from 'firebase/firestore';

import { googleUser, startEnv, userWithProvider } from './helpers.mjs';

const A = 'user-a';
const B = 'user-b';
const YEAR = new Date().getUTCFullYear();

let env;

const validProfile = () => ({
  displayName: 'User A',
  email: 'user-a@example.com',
  onboardingSeen: false,
  createdAt: serverTimestamp(),
  schemaVersion: 1,
});

const validCellar = (ownerId = A) => ({
  ownerId,
  name: 'La mia cantina',
  createdAt: serverTimestamp(),
  schemaVersion: 1,
});

const validWine = (overrides = {}) => ({
  name: 'Barolo',
  vintage: 2016,
  quantity: 2,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  updatedBy: A,
  ...overrides,
});

/** Seeds documents bypassing the rules. */
async function seed(write) {
  await env.withSecurityRulesDisabled(async (ctx) => write(ctx.firestore()));
}

async function seedCellarOfA() {
  await seed((db) =>
    setDoc(doc(db, `cellars/${A}`), {
      ownerId: A,
      name: 'La mia cantina',
      createdAt: Timestamp.fromMillis(0),
      schemaVersion: 1,
    }),
  );
}

async function seedWineOfA(id = 'w1', quantity = 1) {
  await seed((db) =>
    setDoc(doc(db, `cellars/${A}/wines/${id}`), {
      name: 'Barolo',
      vintage: 2016,
      quantity,
      createdAt: Timestamp.fromMillis(0),
      updatedAt: Timestamp.fromMillis(0),
      updatedBy: A,
    }),
  );
}

before(async () => {
  env = await startEnv();
});

beforeEach(async () => {
  await env.clearFirestore();
});

after(async () => {
  await env?.cleanup();
});

describe('authentication (NFR4.1)', () => {
  test('a request without authentication is denied', async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, `cellars/${A}`)));
    await assertFails(setDoc(doc(db, `users/${A}`), validProfile()));
  });

  test('an anonymous token is denied even on its own documents', async () => {
    const db = userWithProvider(env, A, 'anonymous');
    await assertFails(getDoc(doc(db, `cellars/${A}`)));
    await assertFails(setDoc(doc(db, `cellars/${A}`), validCellar()));
  });

  test('an email/password token is denied', async () => {
    const db = userWithProvider(env, A, 'password');
    await assertFails(getDoc(doc(db, `users/${A}`)));
  });
});

describe('users/{uid} (NFR4.2)', () => {
  test('the owner creates a valid profile', async () => {
    await assertSucceeds(setDoc(doc(googleUser(env, A), `users/${A}`), validProfile()));
  });

  test('creation with onboardingSeen true, a client createdAt or schemaVersion 2 is denied', async () => {
    const ref = doc(googleUser(env, A), `users/${A}`);
    await assertFails(setDoc(ref, { ...validProfile(), onboardingSeen: true }));
    await assertFails(setDoc(ref, { ...validProfile(), createdAt: Timestamp.now() }));
    await assertFails(setDoc(ref, { ...validProfile(), schemaVersion: 2 }));
  });

  test('extra or missing fields are denied', async () => {
    const ref = doc(googleUser(env, A), `users/${A}`);
    await assertFails(setDoc(ref, { ...validProfile(), admin: true }));
    const { email, ...withoutEmail } = validProfile();
    await assertFails(setDoc(ref, withoutEmail));
  });

  test('nobody creates or reads the profile of someone else', async () => {
    await seed((db) => setDoc(doc(db, `users/${A}`), { ...validProfile(), createdAt: Timestamp.now() }));
    const b = googleUser(env, B);
    await assertFails(getDoc(doc(b, `users/${A}`)));
    await assertFails(setDoc(doc(b, `users/${B}x`), validProfile()));
    await assertSucceeds(getDoc(doc(googleUser(env, A), `users/${A}`)));
  });

  test('update may change displayName, email and onboardingSeen only', async () => {
    await seed((db) =>
      setDoc(doc(db, `users/${A}`), { ...validProfile(), createdAt: Timestamp.fromMillis(0) }),
    );
    const ref = doc(googleUser(env, A), `users/${A}`);
    await assertSucceeds(updateDoc(ref, { displayName: 'A', email: 'a@x.com', onboardingSeen: true }));
    await assertFails(updateDoc(ref, { createdAt: Timestamp.now() }));
    await assertFails(updateDoc(ref, { schemaVersion: 2 }));
    await assertFails(updateDoc(ref, { onboardingSeen: 'yes' }));
  });

  test('list and delete are always denied', async () => {
    await seed((db) => setDoc(doc(db, `users/${A}`), { ...validProfile(), createdAt: Timestamp.now() }));
    const db = googleUser(env, A);
    await assertFails(getDocs(collection(db, 'users')));
    await assertFails(deleteDoc(doc(db, `users/${A}`)));
  });
});

describe('cellars/{cellarId} (NFR4.3, NFR4.11)', () => {
  test('the owner reads cellars/{uid} even before it exists; others cannot', async () => {
    await assertSucceeds(getDoc(doc(googleUser(env, A), `cellars/${A}`)));
    await assertFails(getDoc(doc(googleUser(env, B), `cellars/${A}`)));
  });

  test('the owner creates the personal cellar', async () => {
    await assertSucceeds(setDoc(doc(googleUser(env, A), `cellars/${A}`), validCellar()));
  });

  test('creating another user cellar or with another ownerId is denied', async () => {
    const db = googleUser(env, A);
    await assertFails(setDoc(doc(db, `cellars/${B}`), validCellar(A)));
    await assertFails(setDoc(doc(db, `cellars/${A}`), validCellar(B)));
  });

  test('invalid cellar fields are denied', async () => {
    const ref = doc(googleUser(env, A), `cellars/${A}`);
    await assertFails(setDoc(ref, { ...validCellar(), name: 'x'.repeat(61) }));
    await assertFails(setDoc(ref, { ...validCellar(), name: '' }));
    await assertFails(setDoc(ref, { ...validCellar(), createdAt: Timestamp.now() }));
    await assertFails(setDoc(ref, { ...validCellar(), schemaVersion: 2 }));
  });

  test('update may rename only; ownerId and createdAt cannot change', async () => {
    await seedCellarOfA();
    const ref = doc(googleUser(env, A), `cellars/${A}`);
    await assertSucceeds(updateDoc(ref, { name: 'Cantina' }));
    await assertFails(updateDoc(ref, { ownerId: B }));
    await assertFails(setDoc(ref, { ...validCellar(), createdAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(googleUser(env, B), `cellars/${A}`), { name: 'Mine' }));
  });

  test('a second create on an existing cellar is an update and is denied', async () => {
    await seedCellarOfA();
    await assertFails(setDoc(doc(googleUser(env, A), `cellars/${A}`), validCellar()));
  });

  test('delete is denied', async () => {
    await seedCellarOfA();
    await assertFails(deleteDoc(doc(googleUser(env, A), `cellars/${A}`)));
  });

  test('list only with the ownerId filter of the caller', async () => {
    await seedCellarOfA();
    const db = googleUser(env, A);
    await assertSucceeds(getDocs(query(collection(db, 'cellars'), where('ownerId', '==', A))));
    await assertFails(getDocs(collection(db, 'cellars')));
    await assertFails(getDocs(query(collection(googleUser(env, B), 'cellars'), where('ownerId', '==', A))));
  });
});

describe('cellars/{cellarId}/wines/{wineId} (NFR4.4, NFR4.5)', () => {
  test('the owner creates a valid wine, also without vintage', async () => {
    await seedCellarOfA();
    const db = googleUser(env, A);
    await assertSucceeds(setDoc(doc(db, `cellars/${A}/wines/w1`), validWine()));
    await assertSucceeds(setDoc(doc(db, `cellars/${A}/wines/w2`), validWine({ vintage: null })));
  });

  test('names outside 1-120 characters are denied', async () => {
    await seedCellarOfA();
    const db = googleUser(env, A);
    await assertSucceeds(setDoc(doc(db, `cellars/${A}/wines/w120`), validWine({ name: 'a'.repeat(120) })));
    await assertFails(setDoc(doc(db, `cellars/${A}/wines/w121`), validWine({ name: 'a'.repeat(121) })));
    await assertFails(setDoc(doc(db, `cellars/${A}/wines/w0`), validWine({ name: '' })));
  });

  test('vintage: 1900 to next year (one year of tolerance) only', async () => {
    await seedCellarOfA();
    const db = googleUser(env, A);
    await assertSucceeds(setDoc(doc(db, `cellars/${A}/wines/v1`), validWine({ vintage: 1900 })));
    await assertSucceeds(setDoc(doc(db, `cellars/${A}/wines/v2`), validWine({ vintage: YEAR + 1 })));
    await assertFails(setDoc(doc(db, `cellars/${A}/wines/v3`), validWine({ vintage: YEAR + 2 })));
    await assertFails(setDoc(doc(db, `cellars/${A}/wines/v4`), validWine({ vintage: 1899 })));
    await assertFails(setDoc(doc(db, `cellars/${A}/wines/v5`), validWine({ vintage: '2016' })));
  });

  test('quantity at creation: integer between 1 and 99', async () => {
    await seedCellarOfA();
    const db = googleUser(env, A);
    await assertSucceeds(setDoc(doc(db, `cellars/${A}/wines/q99`), validWine({ quantity: 99 })));
    await assertFails(setDoc(doc(db, `cellars/${A}/wines/q0`), validWine({ quantity: 0 })));
    await assertFails(setDoc(doc(db, `cellars/${A}/wines/q100`), validWine({ quantity: 100 })));
    await assertFails(setDoc(doc(db, `cellars/${A}/wines/qf`), validWine({ quantity: 1.5 })));
  });

  test('updatedBy, timestamps and unknown fields are enforced at creation', async () => {
    await seedCellarOfA();
    const db = googleUser(env, A);
    await assertFails(setDoc(doc(db, `cellars/${A}/wines/x1`), validWine({ updatedBy: B })));
    await assertFails(setDoc(doc(db, `cellars/${A}/wines/x2`), validWine({ createdAt: Timestamp.now() })));
    await assertFails(setDoc(doc(db, `cellars/${A}/wines/x3`), validWine({ format: '1.5L' })));
  });

  test('two concurrent decrements may take the quantity to -1 (ADR-004)', async () => {
    await seedCellarOfA();
    await seedWineOfA('w1', 1);
    const ref = doc(googleUser(env, A), `cellars/${A}/wines/w1`);
    const decrement = () =>
      updateDoc(ref, { quantity: increment(-1), updatedAt: serverTimestamp(), updatedBy: A });
    await assertSucceeds(decrement());
    await assertSucceeds(decrement());
    let stored;
    await env.withSecurityRulesDisabled(async (ctx) => {
      stored = (await getDoc(doc(ctx.firestore(), `cellars/${A}/wines/w1`))).data();
    });
    if (stored?.quantity !== -1) throw new Error(`expected -1, got ${stored?.quantity}`);
  });

  test('updates cannot change createdAt, must stamp updatedBy/updatedAt, keep limits', async () => {
    await seedCellarOfA();
    await seedWineOfA();
    const ref = doc(googleUser(env, A), `cellars/${A}/wines/w1`);
    await assertSucceeds(updateDoc(ref, { name: 'Barolo DOCG', updatedAt: serverTimestamp(), updatedBy: A }));
    await assertFails(updateDoc(ref, { createdAt: serverTimestamp(), updatedAt: serverTimestamp(), updatedBy: A }));
    await assertFails(updateDoc(ref, { quantity: 3, updatedAt: serverTimestamp(), updatedBy: B }));
    await assertFails(updateDoc(ref, { quantity: 3 }));
    await assertFails(updateDoc(ref, { name: 'a'.repeat(121), updatedAt: serverTimestamp(), updatedBy: A }));
    await assertFails(updateDoc(ref, { quantity: 'two', updatedAt: serverTimestamp(), updatedBy: A }));
  });

  test('another user can neither read nor write the wines of A', async () => {
    await seedCellarOfA();
    await seedWineOfA();
    const b = googleUser(env, B);
    await assertFails(getDoc(doc(b, `cellars/${A}/wines/w1`)));
    await assertFails(getDocs(collection(b, `cellars/${A}/wines`)));
    await assertFails(setDoc(doc(b, `cellars/${A}/wines/w9`), validWine({ updatedBy: B })));
    await assertSucceeds(getDocs(collection(googleUser(env, A), `cellars/${A}/wines`)));
  });

  test('wines of a cellar that does not exist cannot be written', async () => {
    await assertFails(setDoc(doc(googleUser(env, A), `cellars/${A}/wines/w1`), validWine()));
  });

  // U1 had no delete; u7-sharing opened it for the owner only (security
  // design §1, second review of 2026-11-06), for u4-cellar's "Delete".
  test('delete: the owner may delete, another user may not', async () => {
    await seedCellarOfA();
    await seedWineOfA();
    await assertFails(deleteDoc(doc(googleUser(env, B), `cellars/${A}/wines/w1`)));
    await assertSucceeds(deleteDoc(doc(googleUser(env, A), `cellars/${A}/wines/w1`)));
  });
});
