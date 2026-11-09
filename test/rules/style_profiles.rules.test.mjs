// Firestore security rules of wine-style-profiles (BR10.1-BR10.3, NFR2.1,
// NFR2.2): style, the three sources, the disgorgement/bottling month, the
// migration version, the window in months with an optional peak and end, the
// month of the override and of the drink feedback. Each new validator has a
// valid case and at least two invalid ones; the windows of today's app keep
// passing. Every allowed case is an assertSucceeds, every denied one an
// assertFails.
import { after, before, beforeEach, describe, test } from 'node:test';
import assert from 'node:assert/strict';

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


const monthsWindow = (overrides = {}) => ({
  startYear: 2025,
  startMonth: 3,
  peakYear: 2025,
  peakMonth: 6,
  endYear: 2025,
  endMonth: 9,
  unit: 'months',
  confidence: 'low',
  source: 'internalRules',
  basis: 'denomination',
  profile: 'SP_TANK',
  anchor: 'bottling',
  anchorFallback: true,
  tablesVersion: 3,
  ...overrides,
});

const update = (person, fields) =>
  updateDoc(doc(as(person), winePath()), { ...fields, ...stamp(person.uid) });

describe('BR10.1 the new fields are accepted on create', () => {
  test('a wine with every new field', async () => {
    await seed();
    await assertSucceeds(setDoc(doc(as(OWNER), winePath('new')), newWine(OWNER.uid, {
      wineType: 'sparklingClassic',
      style: 'classicAge',
      typeSource: 'auto',
      levelSource: 'user',
      styleSource: 'auto',
      level: 'good',
      agingStartMonth: { year: 2024, month: 3 },
      migrationVersion: 3,
      window: monthsWindow({ profile: 'SP_CLASSIC_AGE', anchor: 'disgorgement' }),
      baseWindow: monthsWindow({ profile: 'SP_CLASSIC_AGE', anchor: 'disgorgement' }),
    })));
  });

  test('NFR2.1 a wine without the new fields stays valid', async () => {
    await seed();
    await assertSucceeds(setDoc(doc(as(OWNER), winePath('old')), newWine(OWNER.uid, {
      window: window(),
    })));
  });

  test('an unknown field is still refused', async () => {
    await seed();
    await assertFails(setDoc(doc(as(OWNER), winePath('x')), newWine(OWNER.uid, {
      styleNote: 'fresh',
    })));
  });
});

describe('expression budget (1000 per request)', () => {
  // The heaviest writes of the app: a new sparkling wine with everything
  // known, and the edit form of a wine with a drink feedback (window and
  // base window different) whose texts, classification and estimate all
  // change. The feedback and the correction already saved do not change.
  test('a create with every field', async () => {
    await seed();
    await assertSucceeds(setDoc(doc(as(EDITOR), winePath('budget')), newWine(EDITOR.uid, {
      producer: 'Cantina', wineType: 'sparklingTank', region: 'Veneto',
      denomination: 'Prosecco', country: 'IT', level: 'everyday',
      style: 'tankFresh', typeSource: 'auto', levelSource: 'auto', styleSource: 'user',
      agingStartMonth: { year: 2025, month: 3 }, migrationVersion: 3,
      matchKey: 'prosecco|cantina|',
      window: monthsWindow({ qualifier: 'superiore', denominationKey: 'prosecco' }),
      baseWindow: monthsWindow({ qualifier: 'superiore', denominationKey: 'prosecco' }),
      pairings: { items: [], categoryKeys: ['aperitif'], source: 'internalRules' },
    })));
  });

  test('the heaviest edit, as the app writes it: texts and classification, '
      + 'then the estimate', async () => {
    // WineRepository.updateWine splits the edit of a wine whose window
    // differs from its base window (drink feedback) in two updates: each
    // stays within the 1000 expressions of a request.
    const adjustment = { kind: 'justRight', year: 2025, month: 10, recordId: 'r1' };
    const override = { endYear: 2025, endMonth: 11, setAt: T0 };
    await seed({ wineType: 'white', windowAdjustment: adjustment, windowOverride: override });
    await assertSucceeds(update(EDITOR, {
      name: 'Prosecco Superiore', producer: 'Cantina', region: 'Veneto',
      denomination: 'Prosecco', country: 'IT', vintage: null,
      matchKey: 'prosecco superiore|cantina|', wineType: 'sparklingTank',
      level: 'everyday', style: 'tankFresh', typeSource: 'user', levelSource: 'auto',
      styleSource: 'user', agingStartMonth: { year: 2025, month: 3 },
      quantity: 3,
    }));
    await assertSucceeds(update(EDITOR, {
      window: monthsWindow({ endMonth: 11, denominationKey: 'prosecco' }),
      baseWindow: monthsWindow({ denominationKey: 'prosecco' }),
      windowAdjustment: adjustment,
      pairings: { items: [], categoryKeys: ['aperitif'], source: 'internalRules' },
    }));
    const stored = await storedWine();
    assert.equal(stored.style, 'tankFresh');
    assert.equal(stored.window.endMonth, 11);
  });

  test('the style chosen in the detail of a wine with a feedback', async () => {
    const adjustment = { kind: 'justRight', year: 2025, month: 10, recordId: 'r1' };
    const override = { endYear: 2025, endMonth: 11, setAt: T0 };
    await seed({ wineType: 'sparklingTank', level: 'good', windowAdjustment: adjustment,
      windowOverride: override, window: window(), baseWindow: window() });
    await assertSucceeds(update(EDITOR, {
      wineType: 'sparklingTank', typeSource: 'user', level: 'everyday', levelSource: 'auto',
      style: 'lambrusco', styleSource: 'user',
      window: monthsWindow({ endMonth: 11, profile: 'LAM_FRESH', denominationKey: 'lambrusco' }),
      baseWindow: monthsWindow({ profile: 'LAM_FRESH', denominationKey: 'lambrusco' }),
      windowAdjustment: adjustment,
      pairings: { items: [], categoryKeys: ['aperitif', 'curedMeats'], source: 'internalRules' },
    }));
  });

  test('the one-off migration of a wine with a feedback', async () => {
    const adjustment = { kind: 'justRight', year: 2025, month: 10, recordId: 'r1' };
    await seed({ wineType: 'sparklingTank', level: 'good', windowAdjustment: adjustment,
      window: window(), baseWindow: window() });
    await assertSucceeds(update(EDITOR, {
      typeSource: 'user', levelSource: 'user', style: 'tankFresh', styleSource: 'auto',
      migrationVersion: 3,
      window: monthsWindow({ endMonth: 11, denominationKey: 'prosecco' }),
      baseWindow: monthsWindow({ denominationKey: 'prosecco' }),
      pairings: { items: [], categoryKeys: ['aperitif'], source: 'internalRules' },
    }));
  });

  test('a base window written with a different window is checked in full', async () => {
    await seed();
    for (const bad of [
      { confidence: 'certain' },
      { source: 'guess' },
      { profile: 'P_NOPE' },
      { anchor: 'harvest' },
      { unit: 'weeks' },
      { peakMonth: 13 },
      { endYear: 2025.5 },
      { anchorFallback: 'yes' },
      { denominationKey: 'k'.repeat(61) },
    ]) {
      try {
        await assertFails(update(OWNER, {
          window: monthsWindow({ endMonth: 11 }),
          baseWindow: monthsWindow(bad),
        }));
      } catch (error) {
        throw new Error(`accepted: ${JSON.stringify(bad)}`);
      }
    }
    await assertSucceeds(update(OWNER, {
      window: monthsWindow({ endMonth: 11 }),
      baseWindow: monthsWindow(),
    }));
  });

  test('a base window written alone is checked in full', async () => {
    await seed({ window: monthsWindow() });
    await assertFails(update(OWNER, { baseWindow: monthsWindow({ profile: 'NOPE' }) }));
    await assertSucceeds(update(OWNER, { baseWindow: monthsWindow() }));
  });
});

describe('BR10.2 style', () => {
  test('a style key is accepted', async () => {
    await seed();
    for (const style of ['redLong', 'madeira', 'sherryPx']) {
      await assertSucceeds(update(OWNER, { style }));
    }
  });

  test('an unknown key, UNKNOWN or a number is refused', async () => {
    await seed();
    for (const style of ['UNKNOWN', 'R_LONG', 'fresh', 3]) {
      await assertFails(update(OWNER, { style }));
      await assertFails(setDoc(doc(as(OWNER), winePath('s')), newWine(OWNER.uid, { style })));
    }
  });

  test('a style can be removed', async () => {
    await seed({ style: 'redAge', styleSource: 'user' });
    await assertSucceeds(update(OWNER, { style: deleteField(), styleSource: deleteField() }));
  });
});

describe('BR10.2 sources', () => {
  test('user and auto on the three sources', async () => {
    await seed();
    for (const value of ['user', 'auto']) {
      await assertSucceeds(update(EDITOR, {
        typeSource: value, levelSource: value, styleSource: value,
      }));
    }
  });

  test('another value or type is refused', async () => {
    await seed();
    for (const field of ['typeSource', 'levelSource', 'styleSource']) {
      for (const value of ['manual', 'User', true]) {
        await assertFails(update(OWNER, { [field]: value }));
      }
    }
  });
});

describe('BR10.2 agingStartMonth', () => {
  test('a month and a year', async () => {
    await seed();
    await assertSucceeds(update(OWNER, { agingStartMonth: { year: 2024, month: 12 } }));
  });

  test('half a date, a month out of 1..12, a year out of range, an extra key', async () => {
    await seed();
    for (const agingStartMonth of [
      { year: 2024 },
      { month: 3 },
      { year: 2024, month: 13 },
      { year: 2024, month: 0 },
      { year: 1899, month: 3 },
      { year: 2024, month: 3, day: 1 },
      { year: '2024', month: 3 },
      '2024-03',
    ]) {
      await assertFails(update(OWNER, { agingStartMonth }));
    }
  });
});

describe('BR10.2 migrationVersion', () => {
  test('an integer 1..1000', async () => {
    await seed();
    await assertSucceeds(update(OWNER, { migrationVersion: 3 }));
  });

  test('zero, too large or not an integer is refused', async () => {
    await seed();
    for (const migrationVersion of [0, 1001, '3', 3.5]) {
      await assertFails(update(OWNER, { migrationVersion }));
    }
  });
});

describe('BR10.2 window in months', () => {
  test('March to September of the same year is accepted', async () => {
    await seed();
    await assertSucceeds(update(OWNER, { window: monthsWindow(), baseWindow: monthsWindow() }));
  });

  test('September to March of the same year is refused', async () => {
    await seed();
    await assertFails(update(OWNER, {
      window: monthsWindow({ startMonth: 9, peakMonth: 9, endMonth: 3 }),
    }));
    await assertFails(update(OWNER, {
      window: monthsWindow({ startMonth: 9, peakYear: 2025, peakMonth: 3 }),
    }));
  });

  test('a month out of range or a date without its month is refused', async () => {
    await seed();
    await assertFails(update(OWNER, { window: monthsWindow({ endMonth: 13 }) }));
    const noMonth = monthsWindow();
    delete noMonth.startMonth;
    await assertFails(update(OWNER, { window: noMonth }));
    const noPeakMonth = monthsWindow();
    delete noPeakMonth.peakMonth;
    await assertFails(update(OWNER, { window: noPeakMonth }));
  });

  test('BR6.5 no peak and no end: Porto LBV ready with no end', async () => {
    await seed();
    await assertSucceeds(update(OWNER, {
      window: {
        startYear: 2024, startMonth: 5, unit: 'months', confidence: 'low',
        source: 'internalRules', profile: 'PORT_LBV', anchor: 'bottling',
      },
    }));
  });

  test('unknown unit, profile, anchor or flag type is refused', async () => {
    await seed();
    for (const overrides of [
      { unit: 'weeks' },
      { profile: 'P_UNKNOWN' },
      { anchor: 'harvest' },
      { anchorFallback: 'yes' },
      { indicative: 1 },
    ]) {
      await assertFails(update(OWNER, { window: monthsWindow(overrides) }));
    }
  });

  test('a window in years keeps the rules of today, without peak or end too', async () => {
    await seed();
    await assertSucceeds(update(OWNER, { window: window({ tablesVersion: 3, profile: 'R_LONG',
      anchor: 'vintage' }) }));
    const noPeak = window();
    delete noPeak.peakYear;
    await assertSucceeds(update(OWNER, { window: noPeak }));
    const noEnd = window();
    delete noEnd.endYear;
    delete noEnd.peakYear;
    await assertSucceeds(update(OWNER, { window: { ...noEnd, indicative: true } }));
    await assertFails(update(OWNER, { window: window({ peakYear: 2050 }) }));
    await assertFails(update(OWNER, { window: window({ startYear: 1899 }) }));
  });

  test('the new qualifiers are accepted', async () => {
    await seed();
    for (const qualifier of ['beerenauslese', 'trockenbeerenauslese', 'eiswein']) {
      await assertSucceeds(update(OWNER, { window: window({ qualifier }) }));
    }
    await assertFails(update(OWNER, { window: window({ qualifier: 'icewine' }) }));
  });
});

describe('BR6.8, BR6.9 months of the override and of the feedback', () => {
  test('endMonth of the override 1..12', async () => {
    await seed();
    await assertSucceeds(update(OWNER, {
      windowOverride: { endYear: 2027, endMonth: 4, setAt: serverTimestamp() },
    }));
    for (const endMonth of [0, 13, '4']) {
      await assertFails(update(OWNER, {
        windowOverride: { endYear: 2027, endMonth, setAt: serverTimestamp() },
      }));
    }
  });

  test('month of the feedback 1..12', async () => {
    await seed();
    const adjustment = (month) => ({ kind: 'tooYoung', year: 2025, month, recordId: 'r1' });
    await assertSucceeds(update(OWNER, { windowAdjustment: adjustment(5) }));
    for (const month of [0, 13, 'may']) {
      await assertFails(update(OWNER, { windowAdjustment: adjustment(month) }));
    }
  });
});

describe('BR7.4 migration write and the reader', () => {
  test('the migration update of an editor passes', async () => {
    await seed({ wineType: 'redStructured', level: 'good', window: window() });
    await assertSucceeds(update(EDITOR, {
      typeSource: 'user', levelSource: 'user', style: 'redLong', styleSource: 'auto',
      migrationVersion: 3, window: window({ tablesVersion: 3, profile: 'R_LONG' }),
      baseWindow: window({ tablesVersion: 3, profile: 'R_LONG' }),
    }));
    const stored = await storedWine();
    assert.equal(stored.migrationVersion, 3);
  });

  test('a reader cannot write the new fields', async () => {
    await seed();
    await assertFails(update(READER, { style: 'redLong' }));
    await assertFails(update(READER, { migrationVersion: 3 }));
  });

  test('an unrelated edit of a migrated wine passes without checking again', async () => {
    await seed({ style: 'redLong', styleSource: 'auto', migrationVersion: 3 });
    await assertSucceeds(update(OWNER, { name: 'Barolo Cannubi' }));
  });
});
