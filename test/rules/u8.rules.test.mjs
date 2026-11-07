// Firestore security rules of u8-account (security-design.md §1 and §7;
// NFR4.1-NFR4.4; BR1.10). Every allowed case is an assertSucceeds, every
// denied one an assertFails. The last test runs the whole deletion of
// BR1.7 as the app does it, batch by batch.
import { after, before, beforeEach, describe, test } from 'node:test';
import assert from 'node:assert/strict';

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
  limit,
  query,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

import { startEnv } from './helpers.mjs';

const T0 = Timestamp.fromMillis(0);

const MARIO = { uid: 'uid-mario', email: 'mario@example.com' };
const GIULIA = { uid: 'uid-giulia', email: 'giulia@example.com' };
const LUCA = { uid: 'uid-luca', email: 'luca@example.com' };
const ANNA = { uid: 'uid-anna', email: 'anna@example.com' };
const PAOLO = { uid: 'uid-paolo', email: 'paolo@example.com' };

let env;

const as = (person) =>
  env
    .authenticatedContext(person.uid, {
      email: person.email,
      email_verified: true,
      firebase: { sign_in_provider: 'google.com' },
    })
    .firestore();

async function seed(write) {
  await env.withSecurityRulesDisabled(async (ctx) => write(ctx.firestore()));
}

async function stored(path) {
  let snapshot;
  await env.withSecurityRulesDisabled(async (ctx) => {
    snapshot = await getDoc(doc(ctx.firestore(), path));
  });
  return snapshot.exists() ? snapshot.data() : undefined;
}

async function storedPaths(path) {
  let paths = [];
  await env.withSecurityRulesDisabled(async (ctx) => {
    const snapshot = await getDocs(collection(ctx.firestore(), path));
    paths = snapshot.docs.map((d) => d.ref.path);
  });
  return paths;
}

function profile(person, extra = {}) {
  return {
    displayName: person.email.split('@')[0],
    email: person.email,
    onboardingSeen: false,
    createdAt: T0,
    schemaVersion: 1,
    ...extra,
  };
}

function cellar(owner, extra = {}) {
  return { ownerId: owner.uid, name: 'Cantina', createdAt: T0, schemaVersion: 1, ...extra };
}

function member(owner, invitee, extra = {}) {
  return {
    inviteeEmail: invitee.email,
    permission: 'edit',
    status: 'active',
    invitedAt: T0,
    ownerId: owner.uid,
    ownerName: owner.email.split('@')[0],
    updatedAt: T0,
    ...extra,
  };
}

before(async () => {
  env = await startEnv();
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

describe('users/{uid} delete (NFR4.1)', () => {
  test('BR1.10 the user deletes their own profile during the deletion', async () => {
    await seed((db) => setDoc(doc(db, `users/${MARIO.uid}`), profile(MARIO, { deletionStartedAt: T0 })));
    await assertSucceeds(deleteDoc(doc(as(MARIO), `users/${MARIO.uid}`)));
  });

  test('BR1.10 without deletionStartedAt the profile is never deleted', async () => {
    await seed((db) => setDoc(doc(db, `users/${MARIO.uid}`), profile(MARIO)));
    await assertFails(deleteDoc(doc(as(MARIO), `users/${MARIO.uid}`)));
  });

  test('another user or no user cannot delete it', async () => {
    await seed((db) => setDoc(doc(db, `users/${MARIO.uid}`), profile(MARIO, { deletionStartedAt: T0 })));
    await assertFails(deleteDoc(doc(as(GIULIA), `users/${MARIO.uid}`)));
    await assertFails(deleteDoc(doc(env.unauthenticatedContext().firestore(), `users/${MARIO.uid}`)));
  });

  test('a profile that does not exist cannot be "deleted"', async () => {
    await assertFails(deleteDoc(doc(as(MARIO), `users/${MARIO.uid}`)));
  });
});

describe('deletionStartedAt (NFR4.2)', () => {
  beforeEach(async () => {
    await seed((db) => setDoc(doc(db, `users/${MARIO.uid}`), profile(MARIO)));
  });

  test('BR1.10 the first write with the server time is allowed', async () => {
    await assertSucceeds(
      updateDoc(doc(as(MARIO), `users/${MARIO.uid}`), { deletionStartedAt: serverTimestamp() }),
    );
  });

  test('BR1.10 a value other than request.time is refused', async () => {
    await assertFails(updateDoc(doc(as(MARIO), `users/${MARIO.uid}`), { deletionStartedAt: T0 }));
  });

  test('BR1.10 once written it cannot be written again, changed or removed', async () => {
    await seed((db) => updateDoc(doc(db, `users/${MARIO.uid}`), { deletionStartedAt: T0 }));
    const ref = doc(as(MARIO), `users/${MARIO.uid}`);
    await assertFails(updateDoc(ref, { deletionStartedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { deletionStartedAt: deleteField() }));
    // The U1 refresh of name and email still works.
    await assertSucceeds(updateDoc(ref, { displayName: 'Mario', email: MARIO.email }));
  });

  test('it cannot be written together with other fields', async () => {
    await assertFails(
      updateDoc(doc(as(MARIO), `users/${MARIO.uid}`), {
        deletionStartedAt: serverTimestamp(),
        onboardingSeen: true,
      }),
    );
  });

  test('another user cannot write it', async () => {
    await assertFails(
      updateDoc(doc(as(GIULIA), `users/${MARIO.uid}`), { deletionStartedAt: serverTimestamp() }),
    );
  });

  test('BR1.10 a missing profile may be created with deletionStartedAt = request.time', async () => {
    const ref = doc(as(GIULIA), `users/${GIULIA.uid}`);
    await assertFails(
      setDoc(ref, { ...profile(GIULIA, { createdAt: serverTimestamp() }), deletionStartedAt: T0 }),
    );
    await assertSucceeds(
      setDoc(ref, {
        ...profile(GIULIA, { createdAt: serverTimestamp() }),
        deletionStartedAt: serverTimestamp(),
      }),
    );
  });

  test('the U1 profile creation without the field is unchanged', async () => {
    await assertSucceeds(
      setDoc(doc(as(GIULIA), `users/${GIULIA.uid}`), profile(GIULIA, { createdAt: serverTimestamp() })),
    );
    await assertFails(
      setDoc(doc(as(LUCA), `users/${LUCA.uid}`), { email: LUCA.email, createdAt: serverTimestamp(), deletionStartedAt: serverTimestamp() }),
    );
  });
});

describe('cellars/{id} delete (NFR4.3)', () => {
  async function seedCellar({ deleting, slots }) {
    await seed(async (db) => {
      await setDoc(doc(db, `users/${MARIO.uid}`), profile(MARIO, deleting ? { deletionStartedAt: T0 } : {}));
      await setDoc(doc(db, `cellars/${MARIO.uid}`), cellar(MARIO, slots === undefined ? {} : { memberSlots: slots }));
    });
  }

  test('BR1.10 the owner deletes the cellar during the account deletion', async () => {
    await seedCellar({ deleting: true, slots: 0 });
    await assertSucceeds(deleteDoc(doc(as(MARIO), `cellars/${MARIO.uid}`)));
  });

  test('BR1.10 outside the account deletion the owner cannot delete it', async () => {
    await seedCellar({ deleting: false, slots: 0 });
    await assertFails(deleteDoc(doc(as(MARIO), `cellars/${MARIO.uid}`)));
    await seedCellar({ deleting: false, slots: 1 });
    await assertFails(deleteDoc(doc(as(MARIO), `cellars/${MARIO.uid}`)));
  });

  test('BR1.10 a drifted counter does not block the deletion', async () => {
    await seedCellar({ deleting: true, slots: 2 });
    await assertSucceeds(deleteDoc(doc(as(MARIO), `cellars/${MARIO.uid}`)));
  });

  test('an invited person or a stranger cannot delete it', async () => {
    await seedCellar({ deleting: true, slots: 1 });
    await seed(async (db) => {
      await setDoc(doc(db, `cellars/${MARIO.uid}/members/${GIULIA.email}`), member(MARIO, GIULIA));
      await setDoc(doc(db, `users/${GIULIA.uid}`), profile(GIULIA, { deletionStartedAt: T0 }));
    });
    await assertFails(deleteDoc(doc(as(GIULIA), `cellars/${MARIO.uid}`)));
    await assertFails(deleteDoc(doc(as(PAOLO), `cellars/${MARIO.uid}`)));
  });
});

describe('the whole deletion (NFR4.4)', () => {
  // Mario owns a cellar with 2 invitations (Giulia active, Luca invited),
  // has a pending invitation in Anna's cellar and a closed one in Paolo's,
  // 3 wines (one finished) and 4 drinks (one of a deleted wine).
  async function seedWorld() {
    await seed(async (db) => {
      await setDoc(doc(db, `users/${MARIO.uid}`), profile(MARIO));
      await setDoc(doc(db, `cellars/${MARIO.uid}`), cellar(MARIO, { memberSlots: 2 }));
      await setDoc(doc(db, `cellars/${MARIO.uid}/members/${GIULIA.email}`), member(MARIO, GIULIA, { inviteeUserId: GIULIA.uid, inviteeName: 'Giulia' }));
      await setDoc(doc(db, `cellars/${MARIO.uid}/members/${LUCA.email}`), member(MARIO, LUCA, { status: 'invited' }));
      for (const [id, quantity] of [['w1', 2], ['w2', 1], ['w3', 0]]) {
        await setDoc(doc(db, `cellars/${MARIO.uid}/wines/${id}`), {
          name: `Vino ${id}`, quantity, createdAt: T0, updatedAt: T0, updatedBy: MARIO.uid,
        });
      }
      for (const [id, wineId, by] of [['r1', 'w1', MARIO.uid], ['r2', 'w3', MARIO.uid], ['r3', 'gone', MARIO.uid], ['r4', 'w1', GIULIA.uid]]) {
        await setDoc(doc(db, `cellars/${MARIO.uid}/drinkingRecords/${id}`), {
          wineId, wineName: 'Vino', drankOn: '2026-11-01', recordedBy: by, createdAt: T0,
        });
      }
      await setDoc(doc(db, `cellars/${ANNA.uid}`), cellar(ANNA, { memberSlots: 1 }));
      await setDoc(doc(db, `cellars/${ANNA.uid}/members/${MARIO.email}`), member(ANNA, MARIO, { status: 'invited' }));
      await setDoc(doc(db, `cellars/${PAOLO.uid}`), cellar(PAOLO, { memberSlots: 0 }));
      await setDoc(doc(db, `cellars/${PAOLO.uid}/members/${MARIO.email}`), member(PAOLO, MARIO, { status: 'revoked', closedBy: 'owner', inviteeUserId: MARIO.uid, inviteeName: 'Mario' }));
      await setDoc(doc(db, `cellars/${PAOLO.uid}/drinkingRecords/p1`), {
        wineId: 'pw', wineName: 'Vino di Paolo', drankOn: '2026-10-01', recordedBy: MARIO.uid, createdAt: T0,
      });
    });
  }

  const closeBatch = (db, cellarId, key, closedBy) =>
    writeBatch(db)
      .update(doc(db, `cellars/${cellarId}/members/${key}`), {
        status: 'revoked', closedBy, updatedAt: serverTimestamp(),
      })
      .update(doc(db, `cellars/${cellarId}`), {
        memberSlots: increment(-1), memberOpKey: key,
      })
      .commit();

  test('NFR4.4 BR1.7 every step of the app is allowed, in order, and nothing of Mario is left', async () => {
    await seedWorld();
    const db = as(MARIO);

    // Step 1: deletionStartedAt.
    await assertSucceeds(updateDoc(doc(db, `users/${MARIO.uid}`), { deletionStartedAt: serverTimestamp() }));

    // Step 2: other people's cellars.
    const received = await assertSucceeds(
      getDocs(query(collectionGroup(db, 'members'), where('inviteeEmail', '==', MARIO.email))),
    );
    assert.equal(received.size, 2);
    for (const invitation of received.docs) {
      const cellarId = invitation.ref.parent.parent.id;
      if (invitation.data().status === 'invited') {
        await assertSucceeds(
          writeBatch(db).update(invitation.ref, {
            status: 'active', inviteeUserId: MARIO.uid, inviteeName: 'Mario', updatedAt: serverTimestamp(),
          }).commit(),
        );
        await assertSucceeds(closeBatch(db, cellarId, MARIO.email, 'invitee'));
      }
      await assertSucceeds(deleteDoc(invitation.ref));
    }

    // Step 3: own invitations.
    const given = await assertSucceeds(getDocs(collection(db, `cellars/${MARIO.uid}/members`)));
    for (const invitation of given.docs) {
      if (invitation.data().status !== 'revoked') {
        await assertSucceeds(closeBatch(db, MARIO.uid, invitation.id, 'owner'));
      }
      await assertSucceeds(deleteDoc(invitation.ref));
    }

    // Step 4: drinks, then wines, in pages.
    for (const name of ['drinkingRecords', 'wines']) {
      const page = await assertSucceeds(getDocs(query(collection(db, `cellars/${MARIO.uid}/${name}`), limit(400))));
      const batch = writeBatch(db);
      page.docs.forEach((d) => batch.delete(d.ref));
      await assertSucceeds(batch.commit());
    }

    // Step 5 and 6.
    await assertSucceeds(deleteDoc(doc(db, `cellars/${MARIO.uid}`)));
    await assertSucceeds(deleteDoc(doc(db, `users/${MARIO.uid}`)));

    // Nothing of Mario is left (NFR8.1): no profile, cellar or members; the
    // drink recorded in Paolo's cellar keeps only the technical uid.
    assert.equal(await stored(`users/${MARIO.uid}`), undefined);
    assert.equal(await stored(`cellars/${MARIO.uid}`), undefined);
    assert.deepEqual(await storedPaths(`cellars/${MARIO.uid}/members`), []);
    assert.deepEqual(await storedPaths(`cellars/${MARIO.uid}/wines`), []);
    assert.deepEqual(await storedPaths(`cellars/${MARIO.uid}/drinkingRecords`), []);
    assert.equal(await stored(`cellars/${ANNA.uid}/members/${MARIO.email}`), undefined);
    assert.equal(await stored(`cellars/${PAOLO.uid}/members/${MARIO.email}`), undefined);
    assert.equal((await stored(`cellars/${ANNA.uid}`)).memberSlots, 0);
    assert.equal((await stored(`cellars/${PAOLO.uid}/drinkingRecords/p1`)).recordedBy, MARIO.uid);
  });

  test('NFR4.4 the cellar cannot be deleted before deletionStartedAt, even after emptying it', async () => {
    await seedWorld();
    const db = as(MARIO);
    for (const id of ['r1', 'r2', 'r3', 'r4']) {
      await assertSucceeds(deleteDoc(doc(db, `cellars/${MARIO.uid}/drinkingRecords/${id}`)));
    }
    await assertFails(deleteDoc(doc(db, `cellars/${MARIO.uid}`)));
  });

  test('NFR4.4 an invited person cannot write anything else in the other cellars', async () => {
    await seedWorld();
    const db = as(MARIO);
    await assertSucceeds(updateDoc(doc(db, `users/${MARIO.uid}`), { deletionStartedAt: serverTimestamp() }));
    // An open invitation cannot be deleted without being closed first.
    await assertFails(deleteDoc(doc(db, `cellars/${ANNA.uid}/members/${MARIO.email}`)));
    // Anna's cellar and Paolo's drink stay theirs.
    await assertFails(deleteDoc(doc(db, `cellars/${ANNA.uid}`)));
    await assertFails(deleteDoc(doc(db, `cellars/${PAOLO.uid}/drinkingRecords/p1`)));
  });
});
