// Firestore security rules of u4-cellar (security-design.md §1; NFR4.1-
// NFR4.9, NFR8.1; BR1.4, BR1.5, BR1.10-BR1.12, BR1.14, BR1.19, BR1.20).
// Every allowed case is an assertSucceeds, every denied one an assertFails.
// Drinks with a createdAt in the past are seeded with the rules disabled.
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
  writeBatch,
} from 'firebase/firestore';

import { googleUser, startEnv } from './helpers.mjs';

const CELLAR = 'user-a';
const T0 = Timestamp.fromMillis(0);

const PEOPLE = {
  owner: { uid: 'user-a', email: 'mario@example.com' },
  read: { uid: 'user-b', email: 'giulia@example.com' },
  edit: { uid: 'user-c', email: 'luca@example.com' },
  edit2: { uid: 'user-g', email: 'sara@example.com' },
  revoked: { uid: 'user-e', email: 'paolo@example.com' },
  stranger: { uid: 'user-f', email: 'zoe@example.com' },
};

let env;

const as = (role) => googleUser(env, PEOPLE[role].uid, PEOPLE[role].email);
const cellarPath = () => `cellars/${CELLAR}`;
const winePath = (id = 'w1') => `${cellarPath()}/wines/${id}`;
const recordPath = (id = 'r1') => `${cellarPath()}/drinkingRecords/${id}`;

async function seed(write) {
  await env.withSecurityRulesDisabled(async (ctx) => write(ctx.firestore()));
}

function member(person, overrides = {}) {
  return {
    inviteeEmail: person.email,
    permission: 'edit',
    status: 'active',
    invitedAt: T0,
    ownerId: PEOPLE.owner.uid,
    ownerName: 'Mario',
    updatedAt: T0,
    inviteeUserId: person.uid,
    inviteeName: 'Persona',
    ...overrides,
  };
}

const baseWine = {
  name: 'Barolo',
  vintage: 2016,
  quantity: 3,
  createdAt: T0,
  updatedAt: T0,
  updatedBy: PEOPLE.owner.uid,
};

/** A drink recorded [minutesAgo] minutes ago by [person]. */
function seededRecord(person, minutesAgo = 0, overrides = {}) {
  return {
    wineId: 'w1',
    wineName: 'Barolo',
    vintage: 2016,
    drankOn: '2026-11-06',
    recordedBy: person.uid,
    createdAt: Timestamp.fromMillis(Date.now() - minutesAgo * 60 * 1000),
    ...overrides,
  };
}

/** Mario's cellar with read, edit, edit2 and revoked members, wine w1. */
async function seedCellar({ cellar = {}, wine = {} } = {}) {
  await seed(async (db) => {
    await setDoc(doc(db, cellarPath()), {
      ownerId: PEOPLE.owner.uid,
      name: 'La cantina di Mario',
      createdAt: T0,
      schemaVersion: 1,
      memberSlots: 2,
      ...cellar,
    });
    await setDoc(doc(db, `${cellarPath()}/members/${PEOPLE.read.email}`),
      member(PEOPLE.read, { permission: 'read' }));
    await setDoc(doc(db, `${cellarPath()}/members/${PEOPLE.edit.email}`), member(PEOPLE.edit));
    await setDoc(doc(db, `${cellarPath()}/members/${PEOPLE.edit2.email}`), member(PEOPLE.edit2));
    await setDoc(doc(db, `${cellarPath()}/members/${PEOPLE.revoked.email}`),
      member(PEOPLE.revoked, { status: 'revoked', closedBy: 'owner' }));
    await setDoc(doc(db, winePath()), { ...baseWine, ...wine });
  });
}

const validWindow = (overrides = {}) => ({
  startYear: 2024,
  peakYear: 2028,
  endYear: 2034,
  confidence: 'medium',
  source: 'internalRules',
  basis: 'denomination',
  ...overrides,
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

before(async () => {
  env = await startEnv();
});

beforeEach(async () => {
  await env.clearFirestore();
});

after(async () => {
  await env?.cleanup();
});

// ---- NFR4.1: wines, new fields ---------------------------------------------

describe('NFR4.1 BR1.4 BR1.5 BR1.12 wines: matchKey, window, baseWindow, windowAdjustment', () => {
  test('BR1.5 a wine with matchKey, window, baseWindow, adjustment and pairings is created', async () => {
    await seedCellar();
    await assertSucceeds(setDoc(doc(as('owner'), winePath('n1')), newWine(PEOPLE.owner.uid, {
      producer: 'Cantina Esempio',
      wineType: 'redStructured',
      matchKey: 'nebbiolo|cantina esempio|2019',
      baseWindow: validWindow(),
      window: validWindow({ endYear: 2035, confidence: 'low', qualifier: 'riserva' }),
      windowAdjustment: { kind: 'justRight', year: 2035, recordId: 'r9' },
      pairings: { items: [], categoryKeys: ['game'], source: 'internalRules' },
    })));
    await assertSucceeds(setDoc(doc(as('edit'), winePath('n2')), newWine(PEOPLE.edit.uid, {
      matchKey: 'nebbiolo||2019',
      window: validWindow({ source: 'catalog', basis: 'catalog', confidence: 'high' }),
    })));
  });

  test('BR1.5 a window without basis is still valid (windows saved before it)', async () => {
    await seedCellar();
    const { basis, ...withoutBasis } = validWindow();
    await assertSucceeds(setDoc(doc(as('owner'), winePath('n3')),
      newWine(PEOPLE.owner.uid, { window: withoutBasis })));
  });

  test('NFR4.1 windows out of shape are refused on create', async () => {
    await seedCellar();
    const owner = as('owner');
    const bad = [
      validWindow({ startYear: 1899 }),
      validWindow({ endYear: 2201 }),
      validWindow({ startYear: 2030, peakYear: 2028 }),
      validWindow({ peakYear: 2040 }),
      validWindow({ confidence: 'certain' }),
      validWindow({ source: 'guess' }),
      validWindow({ basis: 'oracle' }),
      validWindow({ qualifier: 'grandCru' }),
      validWindow({ extra: 1 }),
      validWindow({ startYear: '2024' }),
      { startYear: 2024, peakYear: 2028, endYear: 2034, source: 'catalog' },
      '2024-2034',
    ];
    for (const [i, window] of bad.entries()) {
      await assertFails(setDoc(doc(owner, winePath(`b${i}`)), newWine(PEOPLE.owner.uid, { window })));
      await assertFails(setDoc(doc(owner, winePath(`c${i}`)),
        newWine(PEOPLE.owner.uid, { baseWindow: window })));
    }
  });

  test('BR1.12 windowAdjustment out of shape is refused', async () => {
    await seedCellar();
    const owner = as('owner');
    const bad = [
      { kind: 'tooOld', year: 2026, recordId: 'r1' },
      { kind: 'pastPeak', year: 1899, recordId: 'r1' },
      { kind: 'pastPeak', year: 2201, recordId: 'r1' },
      { kind: 'pastPeak', year: '2026', recordId: 'r1' },
      { kind: 'pastPeak', year: 2026, recordId: '' },
      { kind: 'pastPeak', year: 2026, recordId: 'r'.repeat(129) },
      { kind: 'pastPeak', year: 2026, recordId: 'r1', note: 'x' },
    ];
    for (const [i, windowAdjustment] of bad.entries()) {
      await assertFails(setDoc(doc(owner, winePath(`a${i}`)),
        newWine(PEOPLE.owner.uid, { windowAdjustment })));
    }
    await assertSucceeds(setDoc(doc(owner, winePath('a-ok')), newWine(PEOPLE.owner.uid, {
      windowAdjustment: { kind: 'tooYoung', year: 2200, recordId: 'r'.repeat(128) },
    })));
  });

  test('BR1.4 NFR4.1 matchKey up to 400 characters, a string', async () => {
    await seedCellar();
    const owner = as('owner');
    await assertSucceeds(setDoc(doc(owner, winePath('k400')),
      newWine(PEOPLE.owner.uid, { matchKey: 'k'.repeat(400) })));
    await assertFails(setDoc(doc(owner, winePath('k401')),
      newWine(PEOPLE.owner.uid, { matchKey: 'k'.repeat(401) })));
    await assertFails(setDoc(doc(owner, winePath('knum')),
      newWine(PEOPLE.owner.uid, { matchKey: 42 })));
  });

  test('BR1.12 an update with a valid estimate passes, an invalid one is refused', async () => {
    await seedCellar();
    const edit = as('edit');
    await assertSucceeds(updateDoc(doc(edit, winePath()), {
      baseWindow: validWindow(),
      window: validWindow({ peakYear: 2027, endYear: 2027, confidence: 'low' }),
      windowAdjustment: { kind: 'pastPeak', year: 2027, recordId: 'r1' },
      ...stamp(PEOPLE.edit.uid),
    }));
    await assertSucceeds(updateDoc(doc(edit, winePath()), {
      windowAdjustment: null,
      window: validWindow(),
      ...stamp(PEOPLE.edit.uid),
    }));
    await assertFails(updateDoc(doc(edit, winePath()), {
      window: validWindow({ peakYear: 2040 }),
      ...stamp(PEOPLE.edit.uid),
    }));
    await assertFails(updateDoc(doc(edit, winePath()), {
      matchKey: 'k'.repeat(401),
      ...stamp(PEOPLE.edit.uid),
    }));
    await assertFails(updateDoc(doc(edit, winePath()), {
      windowAdjustment: { kind: 'pastPeak', year: 2027 },
      ...stamp(PEOPLE.edit.uid),
    }));
  });

  test('BR1.13 an edit with name and matchKey passes for edit, not for read', async () => {
    await seedCellar();
    await assertSucceeds(updateDoc(doc(as('edit'), winePath()), {
      name: 'Barolo Riserva',
      producer: 'Cantina Esempio',
      matchKey: 'barolo riserva|cantina esempio|2016',
      quantity: increment(-1),
      ...stamp(PEOPLE.edit.uid),
    }));
    await assertFails(updateDoc(doc(as('read'), winePath()), {
      name: 'Barolo Riserva',
      ...stamp(PEOPLE.read.uid),
    }));
  });

  test('NFR4.1 a wine of the app before u4 (no new fields) is still valid', async () => {
    await seedCellar();
    await assertSucceeds(setDoc(doc(as('owner'), winePath('old')), newWine(PEOPLE.owner.uid)));
    await assertSucceeds(updateDoc(doc(as('owner'), winePath()), {
      quantity: increment(1),
      ...stamp(PEOPLE.owner.uid),
    }));
  });
});

// ---- Review R-05: 99-bottle cap and text limits on update ------------------

describe('BR1.3 BR1.15 NFR4.1 cap of 99 bottles and text limits (review R-05)', () => {
  test('BR1.15 an increment up to 99 passes, over 99 is refused', async () => {
    await seedCellar({ wine: { quantity: 97 } });
    const edit = as('edit');
    await assertSucceeds(updateDoc(doc(edit, winePath()), {
      quantity: increment(2),
      ...stamp(PEOPLE.edit.uid),
    }));
    await assertFails(updateDoc(doc(edit, winePath()), {
      quantity: increment(1),
      ...stamp(PEOPLE.edit.uid),
    }));
  });

  test('BR1.15 a negative stored value can still change, and other fields of a '
    + 'wine over 99 can be edited', async () => {
    await seedCellar({ wine: { quantity: -2 } });
    await assertSucceeds(updateDoc(doc(as('owner'), winePath()), {
      quantity: increment(-1),
      ...stamp(PEOPLE.owner.uid),
    }));
    await seedCellar({ wine: { quantity: 120 } });
    await assertSucceeds(updateDoc(doc(as('owner'), winePath()), {
      name: 'Barolo Riserva',
      ...stamp(PEOPLE.owner.uid),
    }));
  });

  test('BR1.3 producer, region and denomination over 120 characters are refused', async () => {
    await seedCellar();
    const owner = as('owner');
    for (const field of ['producer', 'region', 'denomination']) {
      await assertSucceeds(updateDoc(doc(owner, winePath()), {
        [field]: 'p'.repeat(120),
        ...stamp(PEOPLE.owner.uid),
      }));
      await assertFails(updateDoc(doc(owner, winePath()), {
        [field]: 'p'.repeat(121),
        ...stamp(PEOPLE.owner.uid),
      }));
      await assertFails(setDoc(doc(owner, winePath(`t-${field}`)),
        newWine(PEOPLE.owner.uid, { [field]: 'p'.repeat(121) })));
      await assertFails(updateDoc(doc(owner, winePath()), {
        [field]: 42,
        ...stamp(PEOPLE.owner.uid),
      }));
    }
  });

  test('BR1.5 pairings out of shape are refused on create and update', async () => {
    await seedCellar();
    const owner = as('owner');
    const bad = [
      { items: [], categoryKeys: [], source: 'oracle' },
      { items: 'brasato', source: 'catalog' },
      { items: [], source: 'catalog', extra: 1 },
      { categoryKeys: Array(11).fill('game'), source: 'internalRules' },
      'brasato',
    ];
    for (const [i, pairings] of bad.entries()) {
      await assertFails(setDoc(doc(owner, winePath(`p${i}`)),
        newWine(PEOPLE.owner.uid, { pairings })));
      await assertFails(updateDoc(doc(owner, winePath()), {
        pairings,
        ...stamp(PEOPLE.owner.uid),
      }));
    }
    await assertSucceeds(updateDoc(doc(owner, winePath()), {
      pairings: { items: ['Brasato'], categoryKeys: [], source: 'catalog' },
      ...stamp(PEOPLE.owner.uid),
    }));
  });
});

// ---- NFR4.2: matchKey backfill ---------------------------------------------

describe('NFR4.2 BR1.4 BR1.19 matchKey backfill', () => {
  test('BR1.19 only matchKey, by the owner or an edit member, without updatedBy', async () => {
    await seedCellar();
    await assertSucceeds(updateDoc(doc(as('owner'), winePath()), { matchKey: 'barolo||2016' }));
    await seed((db) => setDoc(doc(db, winePath('w2')), baseWine));
    await assertSucceeds(updateDoc(doc(as('edit'), winePath('w2')), { matchKey: 'barolo||2016' }));
  });

  test('BR1.19 read, revoked and strangers cannot backfill', async () => {
    await seedCellar();
    for (const role of ['read', 'revoked', 'stranger']) {
      await assertFails(updateDoc(doc(as(role), winePath()), { matchKey: 'barolo||2016' }));
    }
  });

  test('NFR4.2 matchKey with name and without updatedBy is refused', async () => {
    await seedCellar();
    await assertFails(updateDoc(doc(as('edit'), winePath()), {
      matchKey: 'barolo x||2016',
      name: 'Barolo X',
    }));
    await assertFails(updateDoc(doc(as('owner'), winePath()), { matchKey: 'k'.repeat(401) }));
    await assertFails(updateDoc(doc(as('owner'), winePath()), { matchKey: null }));
  });
});

// ---- NFR4.9: the cellar flag -----------------------------------------------

describe('NFR4.9 BR1.4 cellars.matchKeyBackfill', () => {
  test('owner and edit set the flag from absent to true', async () => {
    await seedCellar();
    await assertSucceeds(updateDoc(doc(as('edit'), cellarPath()), { matchKeyBackfill: true }));
  });

  test('from false to true by the owner', async () => {
    await seedCellar({ cellar: { matchKeyBackfill: false } });
    await assertSucceeds(updateDoc(doc(as('owner'), cellarPath()), { matchKeyBackfill: true }));
  });

  test('read members and strangers cannot set it', async () => {
    await seedCellar();
    await assertFails(updateDoc(doc(as('read'), cellarPath()), { matchKeyBackfill: true }));
    await assertFails(updateDoc(doc(as('stranger'), cellarPath()), { matchKeyBackfill: true }));
  });

  test('true never goes back to false; with name from edit it is refused', async () => {
    await seedCellar({ cellar: { matchKeyBackfill: true } });
    await assertFails(updateDoc(doc(as('owner'), cellarPath()), { matchKeyBackfill: false }));
    await seedCellar();
    await assertFails(updateDoc(doc(as('edit'), cellarPath()), {
      matchKeyBackfill: true,
      name: 'Rinominata',
    }));
    await assertFails(updateDoc(doc(as('owner'), cellarPath()), { matchKeyBackfill: 'yes' }));
  });
});

// ---- NFR4.5: drinks, creation ----------------------------------------------

const drink = (uid, overrides = {}) => ({
  wineId: 'w1',
  wineName: 'Barolo',
  vintage: 2016,
  drankOn: '2026-11-06',
  recordedBy: uid,
  createdAt: serverTimestamp(),
  ...overrides,
});

describe('NFR4.5 BR1.10 drinks: creation', () => {
  test('BR1.10 the drink batch (quantity -1 and the record) passes for edit', async () => {
    await seedCellar();
    const db = as('edit');
    const batch = writeBatch(db);
    batch.update(doc(db, winePath()), { quantity: increment(-1), ...stamp(PEOPLE.edit.uid) });
    batch.set(doc(db, recordPath('new')), drink(PEOPLE.edit.uid));
    await assertSucceeds(batch.commit());
  });

  test('BR1.11 condition and updatedAt are accepted, other values refused', async () => {
    await seedCellar();
    const db = as('owner');
    await assertSucceeds(setDoc(doc(db, recordPath('c1')), drink(PEOPLE.owner.uid, {
      condition: 'pastPeak',
      updatedAt: serverTimestamp(),
      rating: 5,
      notes: 'Ottimo',
    })));
    await assertFails(setDoc(doc(db, recordPath('c2')), drink(PEOPLE.owner.uid, { condition: 'corked' })));
    await assertFails(setDoc(doc(db, recordPath('c3')), drink(PEOPLE.owner.uid, { updatedAt: T0 })));
    await assertFails(setDoc(doc(db, recordPath('c4')), drink(PEOPLE.owner.uid, { extra: true })));
  });

  test('read members cannot record a drink', async () => {
    await seedCellar();
    await assertFails(setDoc(doc(as('read'), recordPath('x')), drink(PEOPLE.read.uid)));
  });
});

// ---- NFR4.3: drinks, update ------------------------------------------------

describe('NFR4.3 BR1.11 BR1.12 drinks: update', () => {
  const change = (overrides = {}) => ({
    rating: 4,
    notes: 'Ancora giovane',
    condition: 'tooYoung',
    drankOn: '2026-11-05',
    updatedAt: serverTimestamp(),
    ...overrides,
  });

  async function seedRecords() {
    await seedCellar();
    await seed(async (db) => {
      await setDoc(doc(db, recordPath('byEdit')), seededRecord(PEOPLE.edit, 60));
      await setDoc(doc(db, recordPath('byOwner')), seededRecord(PEOPLE.owner, 60));
    });
  }

  test('BR1.11 the author updates rating, notes, date and condition', async () => {
    await seedRecords();
    await assertSucceeds(updateDoc(doc(as('edit'), recordPath('byEdit')), change()));
  });

  test('BR1.11 the owner updates a drink of another person', async () => {
    await seedRecords();
    await assertSucceeds(updateDoc(doc(as('owner'), recordPath('byEdit')), change({ condition: null })));
  });

  test('BR1.11 another edit member, a read member, a revoked author are refused', async () => {
    await seedRecords();
    await assertFails(updateDoc(doc(as('edit2'), recordPath('byEdit')), change()));
    await assertFails(updateDoc(doc(as('edit'), recordPath('byOwner')), change()));
    await assertFails(updateDoc(doc(as('read'), recordPath('byEdit')), change()));
    await seed((db) => setDoc(doc(db, recordPath('byRevoked')), seededRecord(PEOPLE.revoked, 60)));
    await assertFails(updateDoc(doc(as('revoked'), recordPath('byRevoked')), change()));
  });

  test('NFR4.3 immutable fields and bad values are refused', async () => {
    await seedRecords();
    const db = as('edit');
    for (const field of [
      { wineId: 'w2' },
      { wineName: 'Altro' },
      { vintage: 2017 },
      { recordedBy: PEOPLE.owner.uid },
      { createdAt: serverTimestamp() },
      { rating: 0 },
      { rating: 6 },
      { notes: 'n'.repeat(1001) },
      { drankOn: '5/11/2026' },
      { condition: 'corked' },
      { updatedAt: T0 },
    ]) {
      await assertFails(updateDoc(doc(db, recordPath('byEdit')), change(field)));
    }
    await assertFails(updateDoc(doc(db, recordPath('byEdit')), { rating: 3 }));
  });
});

// ---- NFR4.4: drinks, delete ------------------------------------------------

describe('NFR4.4 BR1.10 BR1.14 drinks: delete', () => {
  test('BR1.10 the author undoes within 10 minutes (9 minutes ago)', async () => {
    await seedCellar();
    await seed((db) => setDoc(doc(db, recordPath('r9')), seededRecord(PEOPLE.edit, 9)));
    await assertSucceeds(deleteDoc(doc(as('edit'), recordPath('r9'))));
  });

  test('BR1.10 the undo batch (delete and +1) passes for the author', async () => {
    await seedCellar();
    await seed((db) => setDoc(doc(db, recordPath('r1')), seededRecord(PEOPLE.edit, 1)));
    const db = as('edit');
    const batch = writeBatch(db);
    batch.delete(doc(db, recordPath('r1')));
    batch.update(doc(db, winePath()), { quantity: increment(1), ...stamp(PEOPLE.edit.uid) });
    await assertSucceeds(batch.commit());
  });

  test('BR1.10 after 11 minutes the author can no longer undo', async () => {
    await seedCellar();
    await seed((db) => setDoc(doc(db, recordPath('r11')), seededRecord(PEOPLE.edit, 11)));
    await assertFails(deleteDoc(doc(as('edit'), recordPath('r11'))));
  });

  test('an author moved to read or revoked cannot undo', async () => {
    await seedCellar();
    await seed(async (db) => {
      await setDoc(doc(db, recordPath('rr')), seededRecord(PEOPLE.read, 1));
      await setDoc(doc(db, recordPath('rv')), seededRecord(PEOPLE.revoked, 1));
    });
    await assertFails(deleteDoc(doc(as('read'), recordPath('rr'))));
    await assertFails(deleteDoc(doc(as('revoked'), recordPath('rv'))));
  });

  test('another edit member cannot delete a drink of the author', async () => {
    await seedCellar();
    await seed((db) => setDoc(doc(db, recordPath('r1')), seededRecord(PEOPLE.edit, 1)));
    await assertFails(deleteDoc(doc(as('edit2'), recordPath('r1'))));
  });

  test('BR1.14 the owner deletes any drink, also after 10 minutes', async () => {
    await seedCellar();
    await seed((db) => setDoc(doc(db, recordPath('old')), seededRecord(PEOPLE.edit, 600)));
    await assertSucceeds(deleteDoc(doc(as('owner'), recordPath('old'))));
  });

  test('BR1.10 a drink already deleted cannot be deleted again, also by the owner', async () => {
    await seedCellar();
    await assertFails(deleteDoc(doc(as('owner'), recordPath('gone'))));
    const db = as('owner');
    const batch = writeBatch(db);
    batch.delete(doc(db, recordPath('gone')));
    batch.update(doc(db, winePath()), { quantity: increment(1), ...stamp(PEOPLE.owner.uid) });
    await assertFails(batch.commit());
  });
});

// ---- NFR4.6: wines are deleted by the owner only ---------------------------

describe('NFR4.6 BR1.14 BR1.20 deleting and merging wines', () => {
  test('BR1.14 the owner deletes the wine and its drinks in one batch', async () => {
    await seedCellar();
    await seed((db) => setDoc(doc(db, recordPath('r1')), seededRecord(PEOPLE.edit, 600)));
    const db = as('owner');
    const batch = writeBatch(db);
    batch.delete(doc(db, recordPath('r1')));
    batch.delete(doc(db, winePath()));
    await assertSucceeds(batch.commit());
  });

  test('BR1.14 edit and read members cannot delete a wine', async () => {
    await seedCellar();
    await assertFails(deleteDoc(doc(as('edit'), winePath())));
    await assertFails(deleteDoc(doc(as('read'), winePath())));
  });

  test('BR1.20 the owner merges: increment on the older, delete the newer', async () => {
    await seedCellar();
    await seed((db) => setDoc(doc(db, winePath('w2')), { ...baseWine, quantity: 2 }));
    const db = as('owner');
    const batch = writeBatch(db);
    batch.update(doc(db, winePath()), { quantity: increment(2), ...stamp(PEOPLE.owner.uid) });
    batch.delete(doc(db, winePath('w2')));
    await assertSucceeds(batch.commit());
  });

  test('BR1.20 an edit member cannot merge (the delete is refused)', async () => {
    await seedCellar();
    await seed((db) => setDoc(doc(db, winePath('w2')), baseWine));
    const db = as('edit');
    const batch = writeBatch(db);
    batch.update(doc(db, winePath()), { quantity: increment(3), ...stamp(PEOPLE.edit.uid) });
    batch.delete(doc(db, winePath('w2')));
    await assertFails(batch.commit());
  });
});

// ---- NFR8.1: reading -------------------------------------------------------

describe('NFR8.1 BR1.16 reading drinks and wines', () => {
  test('BR1.16 owner, edit and read members read the drinks; others do not', async () => {
    await seedCellar();
    await seed((db) => setDoc(doc(db, recordPath('r1')), seededRecord(PEOPLE.owner, 5, {
      notes: 'Note private',
      rating: 4,
    })));
    for (const role of ['owner', 'edit', 'read']) {
      await assertSucceeds(getDocs(collection(as(role), `${cellarPath()}/drinkingRecords`)));
      await assertSucceeds(getDoc(doc(as(role), recordPath('r1'))));
    }
    for (const role of ['revoked', 'stranger']) {
      await assertFails(getDocs(collection(as(role), `${cellarPath()}/drinkingRecords`)));
    }
  });

  test('BR1.4 BR1.7 the duplicate and archive queries are allowed to readers', async () => {
    await seedCellar();
    const db = as('read');
    const wines = collection(db, `${cellarPath()}/wines`);
    await assertSucceeds(getDocs(query(wines, where('matchKey', '==', 'barolo||2016'))));
    await assertSucceeds(getDocs(query(wines, where('quantity', '>', 0))));
    await assertSucceeds(getDocs(query(wines, where('quantity', '<=', 0))));
    await assertSucceeds(getDocs(query(collection(db, `${cellarPath()}/drinkingRecords`),
      where('wineId', '==', 'w1'))));
    await assertFails(getDocs(query(collection(as('stranger'), `${cellarPath()}/wines`),
      where('quantity', '>', 0))));
  });
});
