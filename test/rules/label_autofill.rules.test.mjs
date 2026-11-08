// Firestore security rules of label-autofill-windows (BR5.1, BR5.2;
// NFR1.1-NFR1.4): the wine level, the owner's correction of "Recommended
// until", basis `grape`, the foreign qualifiers, `denominationKey` and
// `tablesVersion` of the window. Every allowed case is an assertSucceeds,
// every denied one an assertFails.
import { execFileSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { after, before, beforeEach, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';

import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  deleteField,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
} from 'firebase/firestore';

import { googleUser, startEnv } from './helpers.mjs';

const CELLAR = 'user-a';
const T0 = Timestamp.fromMillis(0);
const OWNER = { uid: 'user-a', email: 'mario@example.com' };
const EDITOR = { uid: 'user-c', email: 'luca@example.com' };
const READER = { uid: 'user-b', email: 'giulia@example.com' };

let env;

const as = (person) => googleUser(env, person.uid, person.email);
const winePath = (id = 'w1') => `cellars/${CELLAR}/wines/${id}`;

const window = (overrides = {}) => ({
  startYear: 2024,
  peakYear: 2031,
  endYear: 2046,
  confidence: 'medium',
  source: 'internalRules',
  basis: 'denomination',
  denominationKey: 'barolo',
  tablesVersion: 2,
  ...overrides,
});

const newWine = (uid, extra = {}) => ({
  name: 'Barolo',
  vintage: 2016,
  quantity: 2,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  updatedBy: uid,
  ...extra,
});

const stamp = (uid) => ({ updatedAt: serverTimestamp(), updatedBy: uid });

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

/** Mario's cellar, an edit and a read member, and wine w1 as [wine]. */
async function seed(wine = {}) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, `cellars/${CELLAR}`), {
      ownerId: OWNER.uid,
      name: 'La cantina di Mario',
      createdAt: T0,
      schemaVersion: 1,
      memberSlots: 2,
    });
    await setDoc(doc(db, `cellars/${CELLAR}/members/${EDITOR.email}`), member(EDITOR, 'edit'));
    await setDoc(doc(db, `cellars/${CELLAR}/members/${READER.email}`), member(READER, 'read'));
    await setDoc(doc(db, winePath()), {
      name: 'Barolo',
      vintage: 2016,
      quantity: 2,
      createdAt: T0,
      updatedAt: T0,
      updatedBy: OWNER.uid,
      ...wine,
    });
  });
}

async function storedWine() {
  let data;
  await env.withSecurityRulesDisabled(async (ctx) => {
    data = (await getDoc(doc(ctx.firestore(), winePath()))).data();
  });
  return data;
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

describe('BR5.1 level', () => {
  test('BR5.1 the three levels on create and update', async () => {
    await seed();
    for (const level of ['everyday', 'good', 'aging']) {
      await assertSucceeds(setDoc(doc(as(OWNER), winePath(`l-${level}`)),
        newWine(OWNER.uid, { level })));
      await assertSucceeds(updateDoc(doc(as(EDITOR), winePath()), { level, ...stamp(EDITOR.uid) }));
    }
  });

  test('BR5.1 an unknown level or another type is refused', async () => {
    await seed();
    for (const [i, level] of ['premium', 'Good', 3, true, ['aging']].entries()) {
      await assertFails(setDoc(doc(as(OWNER), winePath(`bad-${i}`)),
        newWine(OWNER.uid, { level })));
      await assertFails(updateDoc(doc(as(OWNER), winePath()), { level, ...stamp(OWNER.uid) }));
    }
  });

  test('BR4.3 "None" removes a saved level', async () => {
    await seed({ level: 'aging' });
    await assertSucceeds(updateDoc(doc(as(OWNER), winePath()),
      { level: deleteField(), ...stamp(OWNER.uid) }));
    assert.equal((await storedWine()).level, undefined);
  });

  test('BR5.1 a reader can never write a level', async () => {
    await seed();
    await assertFails(updateDoc(doc(as(READER), winePath()), { level: 'good', ...stamp(READER.uid) }));
  });
});

describe('BR5.1 windowOverride', () => {
  const override = (endYear = 2038) => ({ endYear, setAt: serverTimestamp() });

  test('BR5.1 F5 the correction and the window in one update', async () => {
    await seed({ window: window(), baseWindow: window() });
    await assertSucceeds(updateDoc(doc(as(EDITOR), winePath()), {
      windowOverride: override(2038),
      window: window({ endYear: 2038 }),
      ...stamp(EDITOR.uid),
    }));
    const stored = await storedWine();
    assert.equal(stored.windowOverride.endYear, 2038);
    assert.equal(stored.window.endYear, 2038);
  });

  test('BR5.1 a wine is created with a correction', async () => {
    await seed();
    await assertSucceeds(setDoc(doc(as(OWNER), winePath('n1')),
      newWine(OWNER.uid, { windowOverride: override(), window: window({ endYear: 2038 }) })));
  });

  test('BR5.1 years 1900 and 2200 are the limits', async () => {
    await seed();
    await assertSucceeds(updateDoc(doc(as(OWNER), winePath()),
      { windowOverride: override(1900), ...stamp(OWNER.uid) }));
    await assertSucceeds(updateDoc(doc(as(OWNER), winePath()),
      { windowOverride: override(2200), ...stamp(OWNER.uid) }));
    await assertFails(updateDoc(doc(as(OWNER), winePath()),
      { windowOverride: override(1899), ...stamp(OWNER.uid) }));
    await assertFails(updateDoc(doc(as(OWNER), winePath()),
      { windowOverride: override(2201), ...stamp(OWNER.uid) }));
  });

  test('BR5.1 out of shape: no setAt, a client time, extra fields, text', async () => {
    await seed();
    const bad = [
      { endYear: 2038 },
      { endYear: 2038, setAt: Timestamp.fromMillis(1) },
      { endYear: '2038', setAt: serverTimestamp() },
      { endYear: 2038, setAt: serverTimestamp(), by: 'me' },
      { setAt: serverTimestamp() },
      2038,
    ];
    for (const [i, windowOverride] of bad.entries()) {
      await assertFails(updateDoc(doc(as(OWNER), winePath()),
        { windowOverride, ...stamp(OWNER.uid) }));
      await assertFails(setDoc(doc(as(OWNER), winePath(`o${i}`)),
        newWine(OWNER.uid, { windowOverride })));
    }
  });

  test('FR5.4 "Restore the estimate" deletes the correction, the feedback stays', async () => {
    await seed({
      window: window({ endYear: 2038 }),
      baseWindow: window(),
      windowAdjustment: { kind: 'justRight', year: 2030, recordId: 'r1' },
      windowOverride: { endYear: 2038, setAt: T0 },
    });
    await assertSucceeds(updateDoc(doc(as(OWNER), winePath()), {
      windowOverride: deleteField(),
      window: window(),
      ...stamp(OWNER.uid),
    }));
    const stored = await storedWine();
    assert.equal(stored.windowOverride, undefined);
    assert.equal(stored.windowAdjustment.kind, 'justRight');
  });

  test('R-09 an unrelated edit of a corrected wine passes: setAt is checked only when it changes', async () => {
    await seed({ windowOverride: { endYear: 2038, setAt: T0 }, level: 'aging' });
    await assertSucceeds(updateDoc(doc(as(EDITOR), winePath()),
      { name: 'Barolo Ravera', ...stamp(EDITOR.uid) }));
    const stored = await storedWine();
    assert.equal(stored.windowOverride.endYear, 2038);
    assert.equal(stored.level, 'aging');
  });
});

describe('BR5.1 window: grape, qualifiers, denominationKey, tablesVersion', () => {
  test('BR5.1 basis grape and every qualifier of ENT-002', async () => {
    await seed();
    await assertSucceeds(setDoc(doc(as(OWNER), winePath('g1')), newWine(OWNER.uid, {
      window: window({ basis: 'grape', denominationKey: 'malbec' }),
      baseWindow: window({ basis: 'grape', denominationKey: 'malbec' }),
    })));
    const qualifiers = ['riserva', 'superiore', 'granSelezione', 'crianza', 'reserva',
      'granReserva', 'premierCru', 'grandCru', 'kabinett', 'spatlese', 'auslese', 'vintage',
      'lbv', 'colheita'];
    for (const qualifier of qualifiers) {
      await assertSucceeds(setDoc(doc(as(OWNER), winePath(`q-${qualifier}`)),
        newWine(OWNER.uid, { window: window({ qualifier }) })));
    }
  });

  test('BR5.1 denominationKey 1-60 characters, tablesVersion an integer', async () => {
    await seed();
    await assertSucceeds(setDoc(doc(as(OWNER), winePath('k60')),
      newWine(OWNER.uid, { window: window({ denominationKey: 'k'.repeat(60) }) })));
    const bad = [
      window({ denominationKey: '' }),
      window({ denominationKey: 'k'.repeat(61) }),
      window({ denominationKey: 7 }),
      window({ tablesVersion: '2' }),
      window({ tablesVersion: 0 }),
      window({ tablesVersion: 2.5 }),
      window({ basis: 'vineyard' }),
    ];
    for (const [i, w] of bad.entries()) {
      await assertFails(setDoc(doc(as(OWNER), winePath(`bw${i}`)), newWine(OWNER.uid, { window: w })));
      await assertFails(updateDoc(doc(as(OWNER), winePath()), { baseWindow: w, ...stamp(OWNER.uid) }));
    }
  });

  test('BR3.9 NFR4.8a the one-off estimate writes only window and baseWindow', async () => {
    await seed({ window: window({ tablesVersion: 1 }), level: 'aging',
      windowOverride: { endYear: 2040, setAt: T0 } });
    await assertSucceeds(updateDoc(doc(as(EDITOR), winePath()), {
      baseWindow: window(),
      window: window({ endYear: 2040 }),
      pairings: { items: [], categoryKeys: ['game'], source: 'internalRules' },
      windowAdjustment: null,
      ...stamp(EDITOR.uid),
    }));
    const stored = await storedWine();
    assert.equal(stored.level, 'aging');
    assert.equal(stored.windowOverride.endYear, 2040);
  });
});

describe('NFR4.8a the rules still in production refuse the new writes', () => {
  test('NFR1.5 NFR4.8a with the rules of the last commit the migration write is denied', async (t) => {
    let previous;
    try {
      previous = execFileSync('git', ['show', 'HEAD:firestore.rules'], {
        cwd: join(dirname(fileURLToPath(import.meta.url)), '..', '..'),
        encoding: 'utf8',
      });
    } catch {
      t.skip('no committed rules to compare with');
      return;
    }
    if (previous.includes("'tablesVersion'")) {
      t.skip('the committed rules already have the new fields');
      return;
    }
    const old = await startEnv(previous);
    try {
      await old.clearFirestore();
      await old.withSecurityRulesDisabled(async (ctx) => {
        const db = ctx.firestore();
        await setDoc(doc(db, `cellars/${CELLAR}`), {
          ownerId: OWNER.uid, name: 'La cantina di Mario', createdAt: T0, schemaVersion: 1,
        });
        await setDoc(doc(db, winePath()), {
          name: 'Barolo', vintage: 2016, quantity: 2, createdAt: T0, updatedAt: T0,
          updatedBy: OWNER.uid,
        });
      });
      const db = googleUser(old, OWNER.uid, OWNER.email);
      await assertFails(updateDoc(doc(db, winePath()),
        { baseWindow: window(), window: window(), ...stamp(OWNER.uid) }));
      await assertFails(updateDoc(doc(db, winePath()), { level: 'aging', ...stamp(OWNER.uid) }));
    } finally {
      await old.cleanup();
      // Back to the rules of this file for the tests that follow.
      await env.cleanup();
      env = await startEnv();
    }
  });
});

describe('BR5.2 NFR1.4 the current app on a wine with the new fields', () => {
  test('BR5.2 a partial update of today keeps level and windowOverride', async () => {
    await seed({ level: 'aging', windowOverride: { endYear: 2038, setAt: T0 }, window: window() });
    // WineRepository.updateWine of the version in production (ux-redesign):
    // texts, key and its estimate, whose windows have no new key.
    const oldWindow = { startYear: 2024, peakYear: 2031, endYear: 2046,
      confidence: 'medium', source: 'internalRules', basis: 'denomination' };
    await assertSucceeds(updateDoc(doc(as(OWNER), winePath()), {
      name: 'Barolo',
      producer: null,
      vintage: 2016,
      wineType: null,
      region: 'Piemonte',
      denomination: null,
      country: 'IT',
      matchKey: 'barolo||2016',
      baseWindow: oldWindow,
      window: oldWindow,
      windowAdjustment: null,
      pairings: { items: [], categoryKeys: ['game'], source: 'internalRules' },
      ...stamp(OWNER.uid),
    }));
    const stored = await storedWine();
    assert.equal(stored.level, 'aging');
    assert.equal(stored.windowOverride.endYear, 2038);
  });

  test('NFR1.1 a wine without the new fields stays valid on update', async () => {
    await seed({ window: { startYear: 2024, peakYear: 2031, endYear: 2046,
      confidence: 'medium', source: 'internalRules' } });
    await assertSucceeds(updateDoc(doc(as(OWNER), winePath()),
      { quantity: 3, ...stamp(OWNER.uid) }));
  });
});
