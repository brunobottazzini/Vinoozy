// Firestore security rules of freemium-plus (FR1.1, FR2.2-FR2.4, FR2.6,
// FR6.5, NFR1, NFR2; plan decisions D1 and D2): the server-only collections,
// the active-wine counter paired with every wine write that changes whether
// the wine is active (quantity > 0), the capacity limit with the owner's
// Plus, the writes of the published app while the limit is off, and the
// worst case of the rules budget. Every allowed case is an assertSucceeds,
// every denied one an assertFails. Seeds are written with the rules disabled,
// as the backend and the admin scripts do.
import { after, before, beforeEach, describe, test } from 'node:test';
import assert from 'node:assert/strict';

import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  collection,
  increment,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

import { googleUser, startEnv } from './helpers.mjs';

const CELLAR = 'user-a';
const T0 = Timestamp.fromMillis(0);
const OWNER = { uid: 'user-a', email: 'mario@example.com' };
const EDITOR = { uid: 'user-c', email: 'luca@example.com' };
const READER = { uid: 'user-b', email: 'giulia@example.com' };
const STRANGER = { uid: 'user-f', email: 'zoe@example.com' };
const DAY_MS = 24 * 60 * 60 * 1000;

let env;

const as = (person) => googleUser(env, person.uid, person.email);
const cellarPath = `cellars/${CELLAR}`;
const winePath = (id) => `${cellarPath}/wines/${id}`;
const recordPath = (id) => `${cellarPath}/drinkingRecords/${id}`;

async function seed(write) {
  await env.withSecurityRulesDisabled(async (ctx) => write(ctx.firestore()));
}

const member = (person, permission) => ({
  inviteeEmail: person.email,
  permission,
  status: 'active',
  invitedAt: T0,
  ownerId: OWNER.uid,
  ownerName: 'Mario',
  updatedAt: T0,
  inviteeUserId: person.uid,
  inviteeName: 'Persona',
});

const storedWine = (quantity, extra = {}) => ({
  name: 'Barolo',
  vintage: 2016,
  quantity,
  createdAt: T0,
  updatedAt: T0,
  updatedBy: OWNER.uid,
  ...extra,
});

const newWine = (uid, extra = {}) => ({
  name: 'Nebbiolo',
  vintage: 2019,
  quantity: 1,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  updatedBy: uid,
  ...extra,
});

const stamp = (uid) => ({ updatedAt: serverTimestamp(), updatedBy: uid });

/**
 * Mario's cellar with an `edit` and a `read` member and the given wines
 * ({id: quantity}). [cellar] adds cellar fields (activeWineCount, the legacy
 * limit); [policy] writes config/policy; [plus] writes Mario's entitlement.
 */
async function seedCellar({ cellar = {}, wines = {}, policy = null, plus = null } = {}) {
  await seed(async (db) => {
    await setDoc(doc(db, cellarPath), {
      ownerId: OWNER.uid,
      name: 'La cantina di Mario',
      createdAt: T0,
      schemaVersion: 1,
      memberSlots: 2,
      ...cellar,
    });
    await setDoc(doc(db, `${cellarPath}/members/${EDITOR.email}`), member(EDITOR, 'edit'));
    await setDoc(doc(db, `${cellarPath}/members/${READER.email}`), member(READER, 'read'));
    for (const [id, quantity] of Object.entries(wines)) {
      await setDoc(doc(db, winePath(id)), storedWine(quantity));
    }
    if (policy !== null) await setDoc(doc(db, 'config/policy'), policy);
    if (plus !== null) await setDoc(doc(db, `entitlements/${OWNER.uid}`), plus);
  });
}

/**
 * A migrated, counted cellar: the counter and the legacy limit written by the
 * admin migration exist (D1, FR2.3), so every change of the active state must
 * carry the counter; the limit is [limitOn].
 */
const counted = (count, limitOn = false, extra = {}) => ({
  cellar: { activeWineCount: count, legacyActiveWineLimit: 15, ...extra.cellar },
  wines: extra.wines ?? {},
  policy: { capacityLimitEnabled: limitOn, policyVersion: 'freemium-v1' },
  plus: extra.plus ?? null,
});

/**
 * A batch of [person] with the wine writes of [writeWines] and, when [delta]
 * is a number, the cellar counter moved by [delta] naming [wineId].
 */
function batchOf(person, { wineId, delta = null, opWineId = wineId }, writeWines) {
  const db = as(person);
  const batch = writeBatch(db);
  writeWines(batch, db);
  if (delta !== null) {
    batch.update(doc(db, cellarPath), {
      activeWineCount: increment(delta),
      activeOpWineId: opWineId,
    });
  }
  return batch.commit();
}

const createWine = (person, wineId, delta, extra = {}) =>
  batchOf(person, { wineId, delta }, (batch, db) => {
    batch.set(doc(db, winePath(wineId)), newWine(person.uid, extra));
  });

const addBottles = (person, wineId, bottles, delta) =>
  batchOf(person, { wineId, delta }, (batch, db) => {
    batch.update(doc(db, winePath(wineId)), {
      quantity: increment(bottles),
      ...stamp(person.uid),
    });
  });

const deleteWine = (person, wineId, delta) =>
  batchOf(person, { wineId, delta }, (batch, db) => {
    batch.delete(doc(db, winePath(wineId)));
  });

async function activeWineCount() {
  let count;
  await seed(async (db) => {
    count = (await getDoc(doc(db, cellarPath))).data().activeWineCount;
  });
  return count;
}

const future = () => Timestamp.fromMillis(Date.now() + 30 * DAY_MS);
const past = () => Timestamp.fromMillis(Date.now() - DAY_MS);

const purchasedPlus = (overrides = {}) => ({
  plan: 'plus',
  source: 'play_purchase',
  status: 'active',
  expiresAt: future(),
  updatedAt: T0,
  ...overrides,
});

before(async () => {
  env = await startEnv();
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

describe('NFR1 server-only collections', () => {
  test('FR1.1 a user reads only their own entitlement and never writes it', async () => {
    await seedCellar({ plus: purchasedPlus() });
    await seed(async (db) => setDoc(doc(db, `entitlements/${EDITOR.uid}`), purchasedPlus()));

    await assertSucceeds(getDoc(doc(as(OWNER), `entitlements/${OWNER.uid}`)));
    await assertFails(getDoc(doc(as(OWNER), `entitlements/${EDITOR.uid}`)));
    await assertFails(getDocs(collection(as(OWNER), 'entitlements')));
    await assertFails(setDoc(doc(as(STRANGER), `entitlements/${STRANGER.uid}`), purchasedPlus()));
    await assertFails(updateDoc(doc(as(OWNER), `entitlements/${OWNER.uid}`), {
      expiresAt: future(),
    }));
    await assertFails(deleteDoc(doc(as(OWNER), `entitlements/${OWNER.uid}`)));
  });

  test('config/policy is read by every signed-in user and written by none', async () => {
    await seedCellar({ policy: { capacityLimitEnabled: false } });

    await assertSucceeds(getDoc(doc(as(STRANGER), 'config/policy')));
    await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'config/policy')));
    await assertFails(updateDoc(doc(as(OWNER), 'config/policy'), { capacityLimitEnabled: true }));
    await assertFails(setDoc(doc(as(OWNER), 'config/other'), { adsEnabled: true }));
    await assertFails(getDocs(collection(as(OWNER), 'config')));
  });

  test('FR6.5 usage: own counters readable, never writable', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, `usage/${OWNER.uid}/periods/2026-11`), { estimatedReadCount: 10 });
      await setDoc(doc(db, `usage/${EDITOR.uid}/periods/2026-11`), { estimatedReadCount: 10 });
    });
    const own = `usage/${OWNER.uid}/periods/2026-11`;

    await assertSucceeds(getDoc(doc(as(OWNER), own)));
    await assertSucceeds(getDocs(collection(as(OWNER), `usage/${OWNER.uid}/periods`)));
    await assertFails(getDoc(doc(as(OWNER), `usage/${EDITOR.uid}/periods/2026-11`)));
    await assertFails(updateDoc(doc(as(OWNER), own), { estimatedReadCount: 0 }));
    await assertFails(setDoc(doc(as(OWNER), `${own}/devices/phone`), { lastSequence: 1 }));
    await assertFails(setDoc(doc(as(OWNER), `usage/${OWNER.uid}`), { reset: true }));
  });

  test('FR7.2 ad slots: own slots readable, never writable', async () => {
    await seed(async (db) => {
      await setDoc(doc(db, `adSlots/${OWNER.uid}/days/2026-11-10`), { reservationId: 'r' });
    });
    const own = `adSlots/${OWNER.uid}/days/2026-11-10`;

    await assertSucceeds(getDoc(doc(as(OWNER), own)));
    await assertFails(getDoc(doc(as(EDITOR), own)));
    await assertFails(setDoc(doc(as(OWNER), `adSlots/${OWNER.uid}/days/2026-11-11`), {
      reservationId: 'mine',
    }));
    await assertFails(deleteDoc(doc(as(OWNER), own)));
  });

  test('FR3.3 purchases: no client access at all', async () => {
    await seed(async (db) => setDoc(doc(db, 'purchases/abc'), { uid: OWNER.uid }));

    await assertFails(getDoc(doc(as(OWNER), 'purchases/abc')));
    await assertFails(setDoc(doc(as(OWNER), 'purchases/def'), { uid: OWNER.uid }));
  });

  test('FR2.3 legacyActiveWineLimit is never written by the client', async () => {
    await seedCellar(counted(3, false, { wines: { w1: 0 } }));

    await assertFails(updateDoc(doc(as(OWNER), cellarPath), { legacyActiveWineLimit: 99 }));
    // Not even hidden in a valid counter update.
    await assertFails(batchOf(OWNER, { wineId: 'w1' }, (batch, db) => {
      batch.update(doc(db, winePath('w1')), { quantity: increment(1), ...stamp(OWNER.uid) });
      batch.update(doc(db, cellarPath), {
        activeWineCount: increment(1),
        activeOpWineId: 'w1',
        legacyActiveWineLimit: 99,
      });
    }));
    await env.clearFirestore();
    await assertFails(setDoc(doc(as(OWNER), cellarPath), {
      ownerId: OWNER.uid,
      name: 'Cantina',
      createdAt: serverTimestamp(),
      schemaVersion: 1,
      legacyActiveWineLimit: 99,
    }));
  });
});

describe('FR2.2 the counter follows every change of the active state', () => {
  test('a new wine with +1 is accepted and counted', async () => {
    await seedCellar(counted(3));

    await assertSucceeds(createWine(OWNER, 'new', 1));
    assert.equal(await activeWineCount(), 4);
  });

  test('a new wine without the counter, or with a wrong one, is refused', async () => {
    await seedCellar(counted(3, false, { wines: { other: 2 } }));

    await assertFails(createWine(OWNER, 'new', null));
    await assertFails(createWine(OWNER, 'new', 2));
    await assertFails(createWine(OWNER, 'new', -1));
    await assertFails(batchOf(OWNER, { wineId: 'new', delta: 1, opWineId: 'other' },
      (batch, db) => batch.set(doc(db, winePath('new')), newWine(OWNER.uid))));
    assert.equal(await activeWineCount(), 3);
  });

  test('0 -> 2 without the counter is refused, with +1 it is accepted', async () => {
    await seedCellar(counted(3, false, { wines: { w1: 0 } }));

    await assertFails(addBottles(OWNER, 'w1', 2, null));
    await assertSucceeds(addBottles(OWNER, 'w1', 2, 1));
    assert.equal(await activeWineCount(), 4);
  });

  test('the same holds for an `edit` member', async () => {
    await seedCellar(counted(3, false, { wines: { w1: 0 } }));

    await assertFails(addBottles(EDITOR, 'w1', 2, null));
    await assertSucceeds(addBottles(EDITOR, 'w1', 2, 1));
    assert.equal(await activeWineCount(), 4);
  });

  test('a `read` member or a stranger cannot move the counter', async () => {
    await seedCellar(counted(3, false, { wines: { w1: 0 } }));

    await assertFails(addBottles(READER, 'w1', 1, 1));
    await assertFails(addBottles(STRANGER, 'w1', 1, 1));
  });

  test('drinking the last bottle needs -1', async () => {
    await seedCellar(counted(3, false, { wines: { w1: 1 } }));

    await assertFails(addBottles(OWNER, 'w1', -1, null));
    await assertFails(addBottles(OWNER, 'w1', -1, 1));
    await assertSucceeds(addBottles(OWNER, 'w1', -1, -1));
    assert.equal(await activeWineCount(), 2);
  });

  test('"Undo" of a drink, 0 -> 1, with +1', async () => {
    await seedCellar(counted(3, false, { wines: { w1: 0 } }));
    await seed(async (db) => setDoc(doc(db, recordPath('r1')), {
      wineId: 'w1',
      wineName: 'Barolo',
      drankOn: '2026-11-10',
      recordedBy: OWNER.uid,
      createdAt: Timestamp.now(),
    }));

    const undo = (delta) => batchOf(OWNER, { wineId: 'w1', delta }, (batch, db) => {
      batch.delete(doc(db, recordPath('r1')));
      batch.update(doc(db, winePath('w1')), { quantity: increment(1), ...stamp(OWNER.uid) });
    });
    await assertFails(undo(null));
    await assertSucceeds(undo(1));
    assert.equal(await activeWineCount(), 4);
  });

  test('deleting an active wine needs -1; an inactive one needs nothing', async () => {
    await seedCellar(counted(3, false, { wines: { w1: 2, w0: 0 } }));

    await assertFails(deleteWine(OWNER, 'w1', null));
    await assertSucceeds(deleteWine(OWNER, 'w1', -1));
    await assertSucceeds(deleteWine(OWNER, 'w0', null));
    await assertFails(deleteWine(OWNER, 'w0', -1) /* already deleted, counter unpaired */);
    assert.equal(await activeWineCount(), 2);
  });

  test('a retried delete of a wine already gone is still allowed', async () => {
    await seedCellar(counted(3));

    await assertSucceeds(deleteDoc(doc(as(OWNER), winePath('gone'))));
  });

  test('more bottles of an active wine: no counter; a counter is refused', async () => {
    await seedCellar(counted(3, false, { wines: { w1: 2 } }));

    await assertFails(addBottles(OWNER, 'w1', 1, 1));
    await assertSucceeds(addBottles(OWNER, 'w1', 1, null));
    assert.equal(await activeWineCount(), 3);
  });

  test('the counter never moves without its wine', async () => {
    await seedCellar(counted(3, false, { wines: { w1: 0 } }));

    await assertFails(updateDoc(doc(as(OWNER), cellarPath), {
      activeWineCount: increment(-1),
      activeOpWineId: 'w1',
    }));
    await assertFails(updateDoc(doc(as(OWNER), cellarPath), { activeWineCount: 0 }));
    await assertFails(updateDoc(doc(as(OWNER), cellarPath), { activeOpWineId: 'w1' }));
  });

  test('D1 a reactivation already done by another device is a conflict', async () => {
    // The phone saw quantity 0 and sends +1, but another device already
    // brought the wine back to 1: the increment resolves to 2, the wine was
    // already active, so the counter change is refused (FR2.5).
    await seedCellar(counted(4, false, { wines: { w1: 1 } }));

    await assertFails(addBottles(OWNER, 'w1', 1, 1));
    assert.equal(await activeWineCount(), 4);
  });
});

describe('FR2.4 the capacity limit, with the limit on', () => {
  test('the 16th active wine is refused', async () => {
    await seedCellar(counted(15, true));

    await assertFails(createWine(OWNER, 'w16', 1));
    assert.equal(await activeWineCount(), 15);
  });

  test('the 15th is accepted', async () => {
    await seedCellar(counted(14, true));

    await assertSucceeds(createWine(OWNER, 'w15', 1));
  });

  test('more bottles of an active wine are accepted at 15 of 15', async () => {
    await seedCellar(counted(15, true, { wines: { w1: 1 } }));

    await assertSucceeds(addBottles(OWNER, 'w1', 3, null));
  });

  test('reactivating an archived wine at 15 of 15 is refused', async () => {
    await seedCellar(counted(15, true, { wines: { w0: 0 } }));

    await assertFails(addBottles(OWNER, 'w0', 1, 1));
    await assertFails(addBottles(OWNER, 'w0', 1, null));
  });

  test('the limit never blocks drinking, deleting or editing', async () => {
    await seedCellar(counted(16, true, { wines: { w1: 1, w2: 3 } }));

    await assertSucceeds(addBottles(OWNER, 'w1', -1, -1));
    await assertSucceeds(deleteWine(OWNER, 'w2', -1));
    await assertSucceeds(createWine(OWNER, 'back', 1) /* 14 -> 15 */);
  });

  test('the legacy limit of a migrated cellar replaces 15', async () => {
    await seedCellar(counted(21, true, { cellar: { legacyActiveWineLimit: 22 } }));

    await assertSucceeds(createWine(OWNER, 'w22', 1));
    await assertFails(createWine(OWNER, 'w23', 1));
  });

  test('a valid Plus of the owner allows the 16th, also for an `edit` member', async () => {
    await seedCellar(counted(15, true, { plus: purchasedPlus() }));

    await assertSucceeds(createWine(OWNER, 'w16', 1));
    await assertSucceeds(createWine(EDITOR, 'w17', 1));
    assert.equal(await activeWineCount(), 17);
  });

  test('an `edit` member without the owner\'s Plus is refused', async () => {
    await seedCellar(counted(15, true));
    await seed(async (db) => setDoc(doc(db, `entitlements/${EDITOR.uid}`), purchasedPlus()));

    // The member's own Plus does not count: the cellar owner's plan does.
    await assertFails(createWine(EDITOR, 'w16', 1));
  });

  test('an expired, revoked, on-hold or unknown Plus does not lift the limit', async () => {
    for (const plus of [
      purchasedPlus({ expiresAt: past() }),
      purchasedPlus({ status: 'revoked' }),
      purchasedPlus({ status: 'on_hold' }),
      purchasedPlus({ status: 'expired' }),
      purchasedPlus({ expiresAt: null }),
      purchasedPlus({ plan: 'pro' }),
    ]) {
      await env.clearFirestore();
      await seedCellar(counted(15, true, { plus }));
      await assertFails(createWine(OWNER, 'w16', 1), JSON.stringify(plus));
    }
  });

  test('a valid grace period and a gift without expiry lift the limit', async () => {
    for (const plus of [
      purchasedPlus({ status: 'grace' }),
      { plan: 'plus', source: 'manual_grant', status: 'active', reason: 'gift' },
    ]) {
      await env.clearFirestore();
      await seedCellar(counted(15, true, { plus }));
      await assertSucceeds(createWine(OWNER, 'w16', 1));
    }
  });

  test('the published app (no counter) is refused once the limit is on', async () => {
    await seedCellar({
      wines: { w0: 0 },
      policy: { capacityLimitEnabled: true },
    });

    await assertFails(createWine(OWNER, 'new', null));
    await assertFails(addBottles(OWNER, 'w0', 1, null));
  });
});

describe('FR2.6 the published app while the limit is off', () => {
  for (const [label, policy] of [
    ['no config/policy', null],
    ['capacityLimitEnabled false', { capacityLimitEnabled: false }],
  ]) {
    test(`${label}, cellar without counter: creates, reactivations, drinks and deletes pass`,
      async () => {
        await seedCellar({ wines: { w0: 0, w1: 1, w2: 2 }, policy });

        await assertSucceeds(setDoc(doc(as(OWNER), winePath('new')), newWine(OWNER.uid)));
        await assertSucceeds(updateDoc(doc(as(OWNER), winePath('w0')), {
          quantity: increment(2),
          ...stamp(OWNER.uid),
        }));
        await assertSucceeds(updateDoc(doc(as(EDITOR), winePath('w1')), {
          quantity: increment(-1),
          ...stamp(EDITOR.uid),
        }));
        await assertSucceeds(deleteDoc(doc(as(OWNER), winePath('w2'))));
      });
  }

  test('mixed-version cellar before the migration: the published app still writes after '
    + 'the new app started the counter', async () => {
    // The owner runs the new app and already wrote activeWineCount; an `edit`
    // member still runs the published app, which never writes the counter.
    // Until the admin migration writes legacyActiveWineLimit those writes pass.
    await seedCellar({
      cellar: { activeWineCount: 2 },
      wines: { w0: 0, w1: 1, w2: 2 },
      policy: { capacityLimitEnabled: false },
    });

    await assertSucceeds(setDoc(doc(as(EDITOR), winePath('new')), newWine(EDITOR.uid)));
    await assertSucceeds(updateDoc(doc(as(EDITOR), winePath('w0')), {
      quantity: increment(2),
      ...stamp(EDITOR.uid),
    }));
    await assertSucceeds(updateDoc(doc(as(EDITOR), winePath('w1')), {
      quantity: increment(-1),
      ...stamp(EDITOR.uid),
    }));
    await assertSucceeds(deleteDoc(doc(as(OWNER), winePath('w2'))));
    assert.equal(await activeWineCount(), 2);
  });

  test('mixed-version cellar before the migration: a counter that is sent must be right',
    async () => {
      await seedCellar({
        cellar: { activeWineCount: 2 },
        wines: { w0: 0, w1: 3 },
        policy: { capacityLimitEnabled: false },
      });

      await assertFails(addBottles(OWNER, 'w0', 1, 2));
      await assertFails(addBottles(OWNER, 'w1', 1, 1) /* already active */);
      await assertSucceeds(addBottles(OWNER, 'w0', 1, 1));
      assert.equal(await activeWineCount(), 3);
    });

  test('after the migration a write that changes the active state without the counter '
    + 'is refused, even with the limit off', async () => {
    await seedCellar({
      cellar: { activeWineCount: 2, legacyActiveWineLimit: 15 },
      wines: { w0: 0, w1: 1, w2: 2 },
      policy: { capacityLimitEnabled: false },
    });

    await assertFails(setDoc(doc(as(EDITOR), winePath('new')), newWine(EDITOR.uid)));
    await assertFails(updateDoc(doc(as(EDITOR), winePath('w0')), {
      quantity: increment(2),
      ...stamp(EDITOR.uid),
    }));
    await assertFails(updateDoc(doc(as(EDITOR), winePath('w1')), {
      quantity: increment(-1),
      ...stamp(EDITOR.uid),
    }));
    await assertFails(deleteDoc(doc(as(OWNER), winePath('w2'))));
    // Writes that keep the active state still need nothing.
    await assertSucceeds(updateDoc(doc(as(EDITOR), winePath('w2')), {
      quantity: increment(1),
      ...stamp(EDITOR.uid),
    }));
    assert.equal(await activeWineCount(), 2);
  });

  test('a cellar without counter: the new app\'s first counted write starts it', async () => {
    await seedCellar({ wines: { w1: 1 } });

    await assertSucceeds(addBottles(OWNER, 'w1', -1, -1));
    // Before the admin migration the counter starts from 0 (FR2.3 recounts).
    assert.equal(await activeWineCount(), -1);
  });
});

describe('u8-account deletion with the counter', () => {
  test('during an account deletion, active wines go without the counter', async () => {
    await seedCellar(counted(2, true, { wines: { w1: 1, w2: 4 } }));
    await seed(async (db) => setDoc(doc(db, `users/${OWNER.uid}`), {
      displayName: 'Mario',
      email: OWNER.email,
      onboardingSeen: true,
      createdAt: T0,
      schemaVersion: 1,
      deletionStartedAt: T0,
    }));

    await assertSucceeds(deleteDoc(doc(as(OWNER), winePath('w1'))));
    await assertSucceeds(deleteWine(OWNER, 'w2', null));
  });

  test('outside a deletion the same delete needs the counter', async () => {
    await seedCellar(counted(2, true, { wines: { w1: 1 } }));

    await assertFails(deleteDoc(doc(as(OWNER), winePath('w1'))));
  });
});

describe('NFR2 worst case of the rules budget', () => {
  // The most expensive evaluation the plan names (D2): an `edit` member
  // reactivates a wine with the limit on and over the effective limit, so
  // the rules read the cellar, the membership, the wine, the policy and the
  // owner's entitlement, on top of the wine validation. The create with every
  // field adds the heaviest wine validation (style_profiles "expression
  // budget"). Both must pass: within 1000 expressions and the document
  // access limits of a request.
  const monthsWindow = {
    startYear: 2025,
    startMonth: 3,
    peakYear: 2026,
    peakMonth: 3,
    endYear: 2027,
    endMonth: 9,
    unit: 'months',
    confidence: 'medium',
    source: 'internalRules',
    basis: 'denomination',
    profile: 'SP_TANK',
    anchor: 'vintage',
    qualifier: 'superiore',
    denominationKey: 'prosecco',
    tablesVersion: 2,
    anchorFallback: false,
    indicative: false,
  };

  test('an `edit` member reactivates a wine over the limit with the owner\'s Plus', async () => {
    await seedCellar(counted(15, true, { wines: { w0: 0 }, plus: purchasedPlus() }));
    await seed(async (db) => updateDoc(doc(db, winePath('w0')), {
      window: monthsWindow,
      baseWindow: { ...monthsWindow, endMonth: 6, confidence: 'low' },
      windowAdjustment: { kind: 'justRight', year: 2025, month: 10, recordId: 'r1' },
      windowOverride: { endYear: 2027, endMonth: 11, setAt: T0 },
      producer: 'Cantina', region: 'Veneto', denomination: 'Prosecco', country: 'IT',
      level: 'everyday', style: 'tankFresh', typeSource: 'auto', levelSource: 'auto',
      styleSource: 'user', agingStartMonth: { year: 2025, month: 3 }, migrationVersion: 3,
      matchKey: 'prosecco|cantina|',
      pairings: { items: [], categoryKeys: ['aperitif'], source: 'internalRules' },
    }));

    await assertSucceeds(addBottles(EDITOR, 'w0', 6, 1));
    assert.equal(await activeWineCount(), 16);
  });

  test('an `edit` member creates a wine with every field over the limit with Plus',
    async () => {
      await seedCellar(counted(15, true, { plus: purchasedPlus() }));

      await assertSucceeds(createWine(EDITOR, 'budget', 1, {
        producer: 'Cantina', wineType: 'sparklingTank', region: 'Veneto',
        denomination: 'Prosecco', country: 'IT', level: 'everyday',
        style: 'tankFresh', typeSource: 'auto', levelSource: 'auto', styleSource: 'user',
        agingStartMonth: { year: 2025, month: 3 }, migrationVersion: 3,
        matchKey: 'prosecco|cantina|',
        window: monthsWindow,
        baseWindow: monthsWindow,
        pairings: { items: [], categoryKeys: ['aperitif'], source: 'internalRules' },
      }));
    });

  test('the same reactivation without Plus is refused',
    async () => {
      await seedCellar(counted(15, true, { wines: { w0: 0 } }));

      await assertFails(addBottles(EDITOR, 'w0', 6, 1));
    });
});
