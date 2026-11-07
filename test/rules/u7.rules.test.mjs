// Firestore security rules of u7-sharing (security-design.md §1; NFR4.1-
// NFR4.9, NFR6.2, NFR8.3; BR1.7, BR1.13). Every allowed case is an
// assertSucceeds, every denied one an assertFails.
import { after, before, beforeEach, describe, test } from 'node:test';

import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection,
  collectionGroup,
  deleteDoc,
  deleteField,
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

import { googleUser, startEnv, unverifiedGoogleUser } from './helpers.mjs';

const CELLAR = 'user-a';
const T0 = Timestamp.fromMillis(0);

// The six roles of NFR4.1, each with its uid and email.
const PEOPLE = {
  owner: { uid: 'user-a', email: 'mario@example.com' },
  read: { uid: 'user-b', email: 'giulia@example.com' },
  edit: { uid: 'user-c', email: 'luca@example.com' },
  invited: { uid: 'user-d', email: 'anna@example.com' },
  revoked: { uid: 'user-e', email: 'paolo@example.com' },
  stranger: { uid: 'user-f', email: 'zoe@example.com' },
};

let env;

const as = (role) => googleUser(env, PEOPLE[role].uid, PEOPLE[role].email);
const cellarPath = (id = CELLAR) => `cellars/${id}`;
const memberPath = (key, id = CELLAR) => `cellars/${id}/members/${key}`;

/** Seeds documents bypassing the rules. */
async function seed(write) {
  await env.withSecurityRulesDisabled(async (ctx) => write(ctx.firestore()));
}

/** Reads a document bypassing the rules. */
async function stored(path) {
  let data;
  await env.withSecurityRulesDisabled(async (ctx) => {
    data = (await getDoc(doc(ctx.firestore(), path))).data();
  });
  return data;
}

function seededMember(email, overrides = {}) {
  return {
    inviteeEmail: email,
    permission: 'edit',
    status: 'active',
    invitedAt: T0,
    ownerId: PEOPLE.owner.uid,
    ownerName: 'Mario',
    updatedAt: T0,
    ...overrides,
  };
}

async function seedCellar(fields = {}) {
  await seed((db) =>
    setDoc(doc(db, cellarPath()), {
      ownerId: PEOPLE.owner.uid,
      name: 'La cantina di Mario',
      createdAt: T0,
      schemaVersion: 1,
      ...fields,
    }),
  );
}

/** The cellar of Mario with one member document per role of NFR4.1. */
async function seedSharedCellar() {
  await seedCellar({ memberSlots: 2 });
  await seed(async (db) => {
    await setDoc(doc(db, memberPath(PEOPLE.read.email)), seededMember(PEOPLE.read.email, {
      permission: 'read',
      inviteeUserId: PEOPLE.read.uid,
      inviteeName: 'Giulia',
    }));
    await setDoc(doc(db, memberPath(PEOPLE.edit.email)), seededMember(PEOPLE.edit.email, {
      inviteeUserId: PEOPLE.edit.uid,
      inviteeName: 'Luca',
    }));
    await setDoc(doc(db, memberPath(PEOPLE.invited.email)), seededMember(PEOPLE.invited.email, {
      status: 'invited',
    }));
    await setDoc(doc(db, memberPath(PEOPLE.revoked.email)), seededMember(PEOPLE.revoked.email, {
      status: 'revoked',
      closedBy: 'owner',
      inviteeUserId: PEOPLE.revoked.uid,
      inviteeName: 'Paolo',
    }));
    await setDoc(doc(db, `${cellarPath()}/wines/w1`), {
      name: 'Barolo',
      vintage: 2016,
      quantity: 2,
      createdAt: T0,
      updatedAt: T0,
      updatedBy: PEOPLE.owner.uid,
    });
    await setDoc(doc(db, `${cellarPath()}/drinkingRecords/r1`), {
      wineId: 'w1',
      wineName: 'Barolo',
      drankOn: '2026-11-01',
      recordedBy: PEOPLE.owner.uid,
      createdAt: T0,
    });
  });
}

const wineFor = (uid) => ({
  name: 'Nebbiolo',
  vintage: 2019,
  quantity: 1,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  updatedBy: uid,
});

const drinkFor = (uid, overrides = {}) => ({
  wineId: 'w1',
  wineName: 'Barolo',
  vintage: 2016,
  drankOn: '2026-11-06',
  rating: 4,
  notes: 'Ottimo con il brasato',
  recordedBy: uid,
  createdAt: serverTimestamp(),
  ...overrides,
});

// ---- NFR4.1: the 6 roles x 9 operations matrix ---------------------------

const OPERATIONS = {
  'get the cellar': (db) => getDoc(doc(db, cellarPath())),
  'rename the cellar': (db) => updateDoc(doc(db, cellarPath()), { name: 'Rinominata' }),
  'read the wines': (db) => getDocs(collection(db, `${cellarPath()}/wines`)),
  'create a wine': (db, uid) => setDoc(doc(db, `${cellarPath()}/wines/new`), wineFor(uid)),
  'update a wine (quantity increment)': (db, uid) =>
    updateDoc(doc(db, `${cellarPath()}/wines/w1`), {
      quantity: increment(-1),
      updatedAt: serverTimestamp(),
      updatedBy: uid,
    }),
  'delete a wine': (db) => deleteDoc(doc(db, `${cellarPath()}/wines/w1`)),
  'read the drinking records': (db) => getDocs(collection(db, `${cellarPath()}/drinkingRecords`)),
  'create a drinking record': (db, uid) =>
    setDoc(doc(db, `${cellarPath()}/drinkingRecords/new`), drinkFor(uid)),
  'list the members of the cellar': (db) => getDocs(collection(db, `${cellarPath()}/members`)),
};

// true = allowed. Columns: owner, read, edit, invited, revoked, stranger.
const MATRIX = {
  'get the cellar': [true, true, true, false, false, false],
  'rename the cellar': [true, false, false, false, false, false],
  'read the wines': [true, true, true, false, false, false],
  'create a wine': [true, false, true, false, false, false],
  'update a wine (quantity increment)': [true, false, true, false, false, false],
  'delete a wine': [true, false, false, false, false, false],
  'read the drinking records': [true, true, true, false, false, false],
  'create a drinking record': [true, false, true, false, false, false],
  'list the members of the cellar': [true, false, false, false, false, false],
};

const ROLES = ['owner', 'read', 'edit', 'invited', 'revoked', 'stranger'];

before(async () => {
  env = await startEnv();
});

beforeEach(async () => {
  await env.clearFirestore();
});

after(async () => {
  await env?.cleanup();
});

describe('NFR4.1 BR1.6 BR1.7 access matrix: 6 roles x 9 operations', () => {
  for (const [operation, allowed] of Object.entries(MATRIX)) {
    ROLES.forEach((role, column) => {
      const expected = allowed[column];
      test(`${role}: ${operation} is ${expected ? 'allowed' : 'denied'}`, async () => {
        await seedSharedCellar();
        const attempt = OPERATIONS[operation](as(role), PEOPLE[role].uid);
        await (expected ? assertSucceeds(attempt) : assertFails(attempt));
      });
    });
  }
});

// ---- BR1.13 NFR4.2: allowed transitions -----------------------------------

/** The owner's invitation batch: the member plus the counter (+1). */
function inviteBatch(db, email, { permission = 'read', delta = 1, opKey = email, member } = {}) {
  const batch = writeBatch(db);
  batch.set(doc(db, memberPath(email)), member ?? {
    inviteeEmail: email,
    permission,
    status: 'invited',
    invitedAt: serverTimestamp(),
    ownerId: PEOPLE.owner.uid,
    ownerName: 'Mario',
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(db, cellarPath()), { memberSlots: increment(delta), memberOpKey: opKey });
  return batch;
}

function closeBatch(db, email, closedBy) {
  const batch = writeBatch(db);
  batch.update(doc(db, memberPath(email)), {
    status: 'revoked',
    closedBy,
    updatedAt: serverTimestamp(),
  });
  batch.update(doc(db, cellarPath()), { memberSlots: increment(-1), memberOpKey: email });
  return batch;
}

function activation(db, email, uid, name = 'Anna') {
  return updateDoc(doc(db, memberPath(email)), {
    status: 'active',
    inviteeUserId: uid,
    inviteeName: name,
    updatedAt: serverTimestamp(),
  });
}

describe('BR1.13 NFR4.2 allowed transitions of members', () => {
  test('BR1.2 (none) -> invited by the owner with the counter +1', async () => {
    await seedCellar({ memberSlots: 0 });
    await assertSucceeds(inviteBatch(as('owner'), PEOPLE.read.email).commit());
    const cellar = await stored(cellarPath());
    if (cellar.memberSlots !== 1) throw new Error(`memberSlots ${cellar.memberSlots}`);
  });

  test('NFR4.3 a cellar without memberSlots accepts the first invitation', async () => {
    await seedCellar();
    await assertSucceeds(inviteBatch(as('owner'), PEOPLE.read.email).commit());
  });

  test('BR1.4 invited -> active by the invitee, with the own uid and name', async () => {
    await seedSharedCellar();
    await assertSucceeds(activation(as('invited'), PEOPLE.invited.email, PEOPLE.invited.uid));
  });

  test('BR1.4 activation with the fallback name (email prefix) succeeds', async () => {
    await seedSharedCellar();
    await assertSucceeds(activation(as('invited'), PEOPLE.invited.email, PEOPLE.invited.uid, 'anna'));
  });

  test('BR1.9 the owner changes the permission of an active and an invited member', async () => {
    await seedSharedCellar();
    const db = as('owner');
    await assertSucceeds(updateDoc(doc(db, memberPath(PEOPLE.read.email)), {
      permission: 'edit',
      updatedAt: serverTimestamp(),
    }));
    await assertSucceeds(updateDoc(doc(db, memberPath(PEOPLE.invited.email)), {
      permission: 'read',
      updatedAt: serverTimestamp(),
    }));
  });

  test('BR1.8 the owner revokes an active and an invited member, counter -1 each', async () => {
    await seedSharedCellar();
    await assertSucceeds(closeBatch(as('owner'), PEOPLE.read.email, 'owner').commit());
    await assertSucceeds(closeBatch(as('owner'), PEOPLE.invited.email, 'owner').commit());
    const cellar = await stored(cellarPath());
    if (cellar.memberSlots !== 0) throw new Error(`memberSlots ${cellar.memberSlots}`);
  });

  test('BR1.10 the invitee leaves: active -> revoked, closedBy invitee, counter -1', async () => {
    await seedSharedCellar();
    await assertSucceeds(closeBatch(as('edit'), PEOPLE.edit.email, 'invitee').commit());
    const member = await stored(memberPath(PEOPLE.edit.email));
    if (member.closedBy !== 'invitee') throw new Error('closedBy not stored');
  });

  test('BR1.2 revoked -> invited by the owner (renewal) with the counter +1', async () => {
    await seedSharedCellar();
    await seed((db) => updateDoc(doc(db, cellarPath()), { memberSlots: 1 }));
    const db = as('owner');
    const batch = writeBatch(db);
    batch.update(doc(db, memberPath(PEOPLE.revoked.email)), {
      status: 'invited',
      permission: 'read',
      invitedAt: serverTimestamp(),
      closedBy: deleteField(),
      updatedAt: serverTimestamp(),
    });
    batch.update(doc(db, cellarPath()), {
      memberSlots: increment(1),
      memberOpKey: PEOPLE.revoked.email,
    });
    await assertSucceeds(batch.commit());
  });

  test('BR1.12 the owner deletes a closed (revoked) invitation for good', async () => {
    await seedSharedCellar();
    await assertSucceeds(deleteDoc(doc(as('owner'), memberPath(PEOPLE.revoked.email))));
  });

  test('NFR8.3 the invitee deletes the own revoked document', async () => {
    await seedSharedCellar();
    await assertSucceeds(deleteDoc(doc(as('revoked'), memberPath(PEOPLE.revoked.email))));
  });
});

// ---- BR1.13 NFR4.2: denied transitions ------------------------------------

describe('BR1.13 NFR4.2 denied transitions of members', () => {
  test('self-promotion: a read member cannot change the own permission', async () => {
    await seedSharedCellar();
    await assertFails(updateDoc(doc(as('read'), memberPath(PEOPLE.read.email)), {
      permission: 'edit',
      updatedAt: serverTimestamp(),
    }));
  });

  test('re-entry: a revoked invitee cannot become active again', async () => {
    await seedSharedCellar();
    await assertFails(activation(as('revoked'), PEOPLE.revoked.email, PEOPLE.revoked.uid, 'Paolo'));
  });

  test('activation of an invitation of another email is denied', async () => {
    await seedSharedCellar();
    await assertFails(activation(as('stranger'), PEOPLE.invited.email, PEOPLE.stranger.uid));
    await assertFails(activation(as('read'), PEOPLE.invited.email, PEOPLE.read.uid));
  });

  test('activation with another uid or a changed permission is denied', async () => {
    await seedSharedCellar();
    await assertFails(activation(as('invited'), PEOPLE.invited.email, PEOPLE.stranger.uid));
    // The seeded invitation is `edit`: a change to `read` is still a change.
    await assertFails(updateDoc(doc(as('invited'), memberPath(PEOPLE.invited.email)), {
      status: 'active',
      permission: 'read',
      inviteeUserId: PEOPLE.invited.uid,
      inviteeName: 'Anna',
      updatedAt: serverTimestamp(),
    }));
  });

  test('ownerId, ownerName and inviteeEmail never change', async () => {
    await seedSharedCellar();
    const owner = as('owner');
    await assertFails(updateDoc(doc(owner, memberPath(PEOPLE.read.email)), {
      ownerId: PEOPLE.stranger.uid,
      updatedAt: serverTimestamp(),
    }));
    await assertFails(updateDoc(doc(as('read'), memberPath(PEOPLE.read.email)), {
      ownerName: 'Giulia',
      updatedAt: serverTimestamp(),
    }));
    await assertFails(updateDoc(doc(owner, memberPath(PEOPLE.read.email)), {
      inviteeEmail: 'other@example.com',
      updatedAt: serverTimestamp(),
    }));
  });

  test('an invitee cannot revoke another member nor invite', async () => {
    await seedSharedCellar();
    await assertFails(closeBatch(as('edit'), PEOPLE.read.email, 'owner').commit());
    await seed((db) => updateDoc(doc(db, cellarPath()), { memberSlots: 0 }));
    await assertFails(inviteBatch(as('edit'), PEOPLE.stranger.email).commit());
  });

  test('an invited (not yet active) person cannot leave', async () => {
    await seedSharedCellar();
    await assertFails(closeBatch(as('invited'), PEOPLE.invited.email, 'invitee').commit());
  });

  test('the owner cannot delete an open invitation; the invitee cannot delete the own active one', async () => {
    await seedSharedCellar();
    await assertFails(deleteDoc(doc(as('owner'), memberPath(PEOPLE.read.email))));
    await assertFails(deleteDoc(doc(as('read'), memberPath(PEOPLE.read.email))));
  });

  test('NFR8.3 nobody deletes the revoked document of someone else', async () => {
    await seedSharedCellar();
    await assertFails(deleteDoc(doc(as('read'), memberPath(PEOPLE.revoked.email))));
    await assertFails(deleteDoc(doc(as('stranger'), memberPath(PEOPLE.revoked.email))));
  });

  test('a revoke that keeps the counter or names the invitee as closer is denied', async () => {
    await seedSharedCellar();
    const owner = as('owner');
    await assertFails(updateDoc(doc(owner, memberPath(PEOPLE.read.email)), {
      status: 'revoked',
      closedBy: 'owner',
      updatedAt: serverTimestamp(),
    }));
    await assertFails(closeBatch(owner, PEOPLE.read.email, 'invitee').commit());
  });
});

// ---- BR1.2 NFR4.3: the memberSlots counter -------------------------------

describe('BR1.2 NFR4.3 memberSlots counter (limit 2)', () => {
  test('two invitations succeed, the third is denied', async () => {
    await seedCellar({ memberSlots: 0 });
    const owner = as('owner');
    await assertSucceeds(inviteBatch(owner, 'one@example.com').commit());
    await assertSucceeds(inviteBatch(owner, 'two@example.com').commit());
    await assertFails(inviteBatch(owner, 'three@example.com').commit());
    const cellar = await stored(cellarPath());
    if (cellar.memberSlots !== 2) throw new Error(`memberSlots ${cellar.memberSlots}`);
  });

  test('an invitation that moves the counter by +2 is denied', async () => {
    await seedCellar({ memberSlots: 0 });
    await assertFails(inviteBatch(as('owner'), 'one@example.com', { delta: 2 }).commit());
  });

  test('an invitation without the counter is denied', async () => {
    await seedCellar({ memberSlots: 0 });
    await assertFails(setDoc(doc(as('owner'), memberPath('one@example.com')), {
      inviteeEmail: 'one@example.com',
      permission: 'read',
      status: 'invited',
      invitedAt: serverTimestamp(),
      ownerId: PEOPLE.owner.uid,
      ownerName: 'Mario',
      updatedAt: serverTimestamp(),
    }));
  });

  test('the counter changed without a members document is denied', async () => {
    await seedCellar({ memberSlots: 0 });
    const owner = as('owner');
    await assertFails(updateDoc(doc(owner, cellarPath()), {
      memberSlots: increment(1),
      memberOpKey: 'ghost@example.com',
    }));
    await seedSharedCellar();
    await assertFails(updateDoc(doc(owner, cellarPath()), {
      memberSlots: increment(-1),
      memberOpKey: PEOPLE.read.email,
    }));
  });

  test('two invitations in one batch with a single +1 are denied', async () => {
    await seedCellar({ memberSlots: 0 });
    const db = as('owner');
    const batch = inviteBatch(db, 'one@example.com');
    batch.set(doc(db, memberPath('two@example.com')), {
      inviteeEmail: 'two@example.com',
      permission: 'read',
      status: 'invited',
      invitedAt: serverTimestamp(),
      ownerId: PEOPLE.owner.uid,
      ownerName: 'Mario',
      updatedAt: serverTimestamp(),
    });
    await assertFails(batch.commit());
  });

  test('a memberOpKey of another invitation is denied', async () => {
    await seedSharedCellar();
    await seed((db) => updateDoc(doc(db, cellarPath()), { memberSlots: 1 }));
    await assertFails(
      inviteBatch(as('owner'), 'new@example.com', { opKey: PEOPLE.revoked.email }).commit(),
    );
  });

  test('the invitee may only lower the counter by leaving', async () => {
    await seedSharedCellar();
    await assertFails(updateDoc(doc(as('edit'), cellarPath()), {
      memberSlots: increment(-1),
      memberOpKey: PEOPLE.edit.email,
    }));
    await assertFails(updateDoc(doc(as('edit'), cellarPath()), {
      memberSlots: increment(1),
      memberOpKey: PEOPLE.edit.email,
    }));
  });

  test('NFR6.2 a repeated invitation or revocation is denied and the counter stays right', async () => {
    await seedCellar({ memberSlots: 0 });
    const owner = as('owner');
    await assertSucceeds(inviteBatch(owner, 'one@example.com').commit());
    await assertFails(inviteBatch(owner, 'one@example.com').commit());
    await assertSucceeds(closeBatch(owner, 'one@example.com', 'owner').commit());
    await assertFails(closeBatch(owner, 'one@example.com', 'owner').commit());
    const cellar = await stored(cellarPath());
    if (cellar.memberSlots !== 0) throw new Error(`memberSlots ${cellar.memberSlots}`);
  });

  test('the counter never goes below 0', async () => {
    await seedCellar({ memberSlots: 0 });
    await seed((db) => setDoc(doc(db, memberPath(PEOPLE.read.email)), seededMember(PEOPLE.read.email)));
    await assertFails(closeBatch(as('owner'), PEOPLE.read.email, 'owner').commit());
  });
});

// ---- NFR4.9: field limits -------------------------------------------------

describe('NFR4.9 fields shown to the other person', () => {
  const member = (email, overrides = {}) => ({
    inviteeEmail: email,
    permission: 'read',
    status: 'invited',
    invitedAt: serverTimestamp(),
    ownerId: PEOPLE.owner.uid,
    ownerName: 'Mario',
    updatedAt: serverTimestamp(),
    ...overrides,
  });

  test('ownerName of 100 characters is accepted, 101 and empty are denied', async () => {
    await seedCellar({ memberSlots: 0 });
    const owner = as('owner');
    await assertFails(inviteBatch(owner, 'a@example.com', {
      member: member('a@example.com', { ownerName: 'm'.repeat(101) }),
    }).commit());
    await assertFails(inviteBatch(owner, 'a@example.com', {
      member: member('a@example.com', { ownerName: '' }),
    }).commit());
    await assertSucceeds(inviteBatch(owner, 'a@example.com', {
      member: member('a@example.com', { ownerName: 'm'.repeat(100) }),
    }).commit());
  });

  test('an email of 254 characters is accepted, upper case or a different key is denied', async () => {
    await seedCellar({ memberSlots: 0 });
    const owner = as('owner');
    const long = `${'a'.repeat(254 - '@example.com'.length)}@example.com`;
    await assertFails(inviteBatch(owner, 'Upper@example.com').commit());
    await assertFails(inviteBatch(owner, 'key@example.com', {
      member: member('other@example.com'),
    }).commit());
    await assertFails(inviteBatch(owner, 'not-an-email').commit());
    await assertSucceeds(inviteBatch(owner, long).commit());
  });

  test('an email of 255 characters is denied', async () => {
    await seedCellar({ memberSlots: 0 });
    const tooLong = `${'a'.repeat(255 - '@example.com'.length)}@example.com`;
    await assertFails(inviteBatch(as('owner'), tooLong).commit());
  });

  test('permission and status outside C3, wrong types and extra fields are denied', async () => {
    await seedCellar({ memberSlots: 0 });
    const owner = as('owner');
    const key = 'a@example.com';
    for (const bad of [
      member(key, { permission: 'admin' }),
      member(key, { permission: 1 }),
      member(key, { status: 'active' }),
      member(key, { ownerId: PEOPLE.stranger.uid }),
      member(key, { invitedAt: Timestamp.now() }),
      member(key, { extra: true }),
    ]) {
      await assertFails(inviteBatch(owner, key, { member: bad }).commit());
    }
  });

  test('the owner cannot invite the own address', async () => {
    await seedCellar({ memberSlots: 0 });
    await assertFails(inviteBatch(as('owner'), PEOPLE.owner.email).commit());
  });

  test('inviteeName of 101 characters or a non-string is denied at activation', async () => {
    await seedSharedCellar();
    const db = as('invited');
    await assertFails(activation(db, PEOPLE.invited.email, PEOPLE.invited.uid, 'n'.repeat(101)));
    await assertFails(activation(db, PEOPLE.invited.email, PEOPLE.invited.uid, 7));
    await assertSucceeds(activation(db, PEOPLE.invited.email, PEOPLE.invited.uid, 'n'.repeat(100)));
  });
});

// ---- NFR4.4: identity -----------------------------------------------------

describe('NFR4.4 identity of the invited person', () => {
  test('an unverified email gives no access, even with an active invitation', async () => {
    await seedSharedCellar();
    const db = unverifiedGoogleUser(env, PEOPLE.edit.uid, PEOPLE.edit.email);
    await assertFails(getDoc(doc(db, cellarPath())));
    await assertFails(getDocs(collection(db, `${cellarPath()}/wines`)));
    await assertFails(getDocs(query(collectionGroup(db, 'members'),
      where('inviteeEmail', '==', PEOPLE.edit.email))));
  });

  test('an unverified email cannot activate', async () => {
    await seedSharedCellar();
    const db = unverifiedGoogleUser(env, PEOPLE.invited.uid, PEOPLE.invited.email);
    await assertFails(activation(db, PEOPLE.invited.email, PEOPLE.invited.uid));
  });

  test('an upper-case email in the token gets the right access', async () => {
    await seedSharedCellar();
    const db = googleUser(env, PEOPLE.edit.uid, 'Luca@Example.COM');
    await assertSucceeds(getDocs(collection(db, `${cellarPath()}/wines`)));
    await assertSucceeds(getDocs(query(collectionGroup(db, 'members'),
      where('inviteeEmail', '==', PEOPLE.edit.email))));
  });
});

// ---- NFR4.5: no email leaks ------------------------------------------------

describe('NFR4.5 BR1.4 BR1.14 own invitations only', () => {
  test('the invitee reads the own invitations in every state through the collection group', async () => {
    await seedSharedCellar();
    for (const role of ['read', 'invited', 'revoked']) {
      const db = as(role);
      await assertSucceeds(getDocs(query(collectionGroup(db, 'members'),
        where('inviteeEmail', '==', PEOPLE[role].email))));
      await assertSucceeds(getDoc(doc(db, memberPath(PEOPLE[role].email))));
    }
  });

  test('a query with the email of someone else is denied', async () => {
    await seedSharedCellar();
    await assertFails(getDocs(query(collectionGroup(as('read'), 'members'),
      where('inviteeEmail', '==', PEOPLE.edit.email))));
    await assertFails(getDocs(collectionGroup(as('read'), 'members')));
  });

  test('an invitee neither lists the members of the cellar nor reads another member', async () => {
    await seedSharedCellar();
    await assertFails(getDocs(collection(as('edit'), `${cellarPath()}/members`)));
    await assertFails(getDoc(doc(as('edit'), memberPath(PEOPLE.read.email))));
  });

  test('the owner reads and lists the members of the own cellar', async () => {
    await seedSharedCellar();
    await assertSucceeds(getDoc(doc(as('owner'), memberPath(PEOPLE.read.email))));
    await assertSucceeds(getDocs(collection(as('owner'), `${cellarPath()}/members`)));
  });
});

// ---- NFR4.8: drinkingRecords ----------------------------------------------

describe('NFR4.8 drinkingRecords', () => {
  test('a valid record is created by the owner and by an edit member', async () => {
    await seedSharedCellar();
    await assertSucceeds(setDoc(doc(as('owner'), `${cellarPath()}/drinkingRecords/o1`),
      drinkFor(PEOPLE.owner.uid)));
    await assertSucceeds(setDoc(doc(as('edit'), `${cellarPath()}/drinkingRecords/e1`),
      drinkFor(PEOPLE.edit.uid, { rating: null, notes: null, vintage: null })));
  });

  test('a minimal record (no vintage, rating, notes) is valid', async () => {
    await seedSharedCellar();
    const { vintage, rating, notes, ...minimal } = drinkFor(PEOPLE.edit.uid);
    await assertSucceeds(setDoc(doc(as('edit'), `${cellarPath()}/drinkingRecords/m1`), minimal));
  });

  test('read members, extra fields, another recordedBy and bad values are denied', async () => {
    await seedSharedCellar();
    const edit = as('edit');
    const path = (id) => doc(edit, `${cellarPath()}/drinkingRecords/${id}`);
    await assertFails(setDoc(doc(as('read'), `${cellarPath()}/drinkingRecords/r9`),
      drinkFor(PEOPLE.read.uid)));
    await assertFails(setDoc(path('x1'), drinkFor(PEOPLE.edit.uid, { extra: 1 })));
    await assertFails(setDoc(path('x2'), drinkFor(PEOPLE.owner.uid)));
    await assertFails(setDoc(path('x3'), drinkFor(PEOPLE.edit.uid, { rating: 6 })));
    await assertFails(setDoc(path('x4'), drinkFor(PEOPLE.edit.uid, { drankOn: '6/11/2026' })));
    await assertFails(setDoc(path('x5'), drinkFor(PEOPLE.edit.uid, { notes: 'n'.repeat(1001) })));
    await assertFails(setDoc(path('x6'), drinkFor(PEOPLE.edit.uid, { wineName: '' })));
    await assertFails(setDoc(path('x7'), drinkFor(PEOPLE.edit.uid, { vintage: 1899 })));
    await assertFails(setDoc(path('x8'), drinkFor(PEOPLE.edit.uid, { createdAt: Timestamp.now() })));
  });

  test('no update by anyone; delete by the owner only', async () => {
    await seedSharedCellar();
    await assertFails(updateDoc(doc(as('owner'), `${cellarPath()}/drinkingRecords/r1`), { rating: 5 }));
    await assertFails(updateDoc(doc(as('edit'), `${cellarPath()}/drinkingRecords/r1`), { rating: 5 }));
    await assertFails(deleteDoc(doc(as('edit'), `${cellarPath()}/drinkingRecords/r1`)));
    await assertSucceeds(deleteDoc(doc(as('owner'), `${cellarPath()}/drinkingRecords/r1`)));
  });
});

// ---- NFR4.6: the owner keeps the U1 behaviour ------------------------------

describe('NFR4.6 the owner of an unshared cellar', () => {
  test('wine writes and renames work as in U1 with memberSlots present', async () => {
    await seedCellar({ memberSlots: 1, memberOpKey: 'giulia@example.com' });
    const owner = as('owner');
    await assertSucceeds(setDoc(doc(owner, `${cellarPath()}/wines/w9`), wineFor(PEOPLE.owner.uid)));
    await assertSucceeds(updateDoc(doc(owner, cellarPath()), { name: 'Cantina' }));
    await assertFails(updateDoc(doc(owner, cellarPath()), { name: 'Cantina 2', memberSlots: 0 }));
  });
});
