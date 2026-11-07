// Account deletion of the web page (u8-account BR1.11, NFR8.5): the same
// steps 1-6 of BR1.7 the app runs, with the same rules, from the browser.
// Step 0 and step 7 concern only the phone and are skipped here.
//
// The module never imports Firebase itself: `sdk` carries the functions it
// uses, so the page passes the ones bundled in app.bundle.js and the tests
// pass the same functions of the npm `firebase` package, against the
// emulators (security-design.md §7). Popups do not exist in Node: the tests
// replace `signInWithPopup` and `reauthenticateWithPopup` in `sdk`.
//
// Every step checks the state before writing, so a run interrupted anywhere
// (or racing with the app) can be repeated from step 1 (NFR6.1): the page has
// no local signal, `deletionStartedAt` is the only one it needs (BR1.8).

/** Largest page read and batch written by step 4 (performance-design.md). */
export const PAGE_SIZE = 400;

/** The cloud steps of BR1.7, in order. */
export const STEPS = Object.freeze([
  'markStarted',
  'leaveOtherCellars',
  'closeOwnInvitations',
  'deleteWinesAndRecords',
  'deleteCellar',
  'deleteProfileAndUser',
]);

const MAX_NAME = 100;

/** Same fallback as the app's displayNameOrFallback (u7-sharing). */
export function displayNameOrFallback(name, email) {
  const trimmed = (name ?? '').trim();
  const local = (email.indexOf('@') > 0 ? email.slice(0, email.indexOf('@')) : email).trim();
  const value = trimmed || local || '?';
  return [...value].reduce(
    (out, ch) => (out.length + ch.length <= MAX_NAME ? out + ch : out),
    '',
  );
}

/** Why a run stopped, from a Firebase error code (functional-spec.md). */
export function classify(error) {
  const code = String(error?.code ?? '').replace(/^(auth|firestore)\//, '');
  if (code === 'permission-denied') return 'rejected';
  if (code === 'requires-recent-login') return 'reauthRequired';
  if (['unavailable', 'deadline-exceeded', 'network-request-failed'].includes(code)) {
    return 'network';
  }
  return 'failed';
}

/**
 * Creates the deletion bound to a Firestore [db] and an Auth [auth].
 *
 * @param {object} sdk Firebase functions: doc, collection, collectionGroup,
 *   query, where, limit, getDocFromServer, getDocsFromServer, writeBatch,
 *   runTransaction, serverTimestamp, increment, deleteDoc, GoogleAuthProvider,
 *   signInWithPopup, reauthenticateWithPopup, deleteUser, signOut.
 */
export function createAccountDeletion(sdk, db, auth) {
  const provider = () => new sdk.GoogleAuthProvider();

  function requireUser() {
    const user = auth.currentUser;
    if (!user) throw Object.assign(new Error('not signed in'), { code: 'auth/no-current-user' });
    return user;
  }

  /** "Sign in with Google". Returns 'signedIn', 'cancelled' or 'failed'. */
  async function signIn() {
    try {
      await sdk.signInWithPopup(auth, provider());
      return 'signedIn';
    } catch (error) {
      return isCancel(error) ? 'cancelled' : 'failed';
    }
  }

  /**
   * NFR4.6: the same Google account again before deleting or resuming.
   * Returns 'confirmed', 'cancelled', 'differentAccount' or 'failed'.
   */
  async function reauthenticate() {
    const user = auth.currentUser;
    if (!user) return 'failed';
    try {
      const result = await sdk.reauthenticateWithPopup(user, provider());
      return result.user.uid === user.uid ? 'confirmed' : 'differentAccount';
    } catch (error) {
      if (String(error?.code) === 'auth/user-mismatch') return 'differentAccount';
      return isCancel(error) ? 'cancelled' : 'failed';
    }
  }

  function isCancel(error) {
    return ['auth/popup-closed-by-user', 'auth/cancelled-popup-request'].includes(
      String(error?.code),
    );
  }

  /** BR1.8: whether a deletion of the signed-in account already started. */
  async function isStarted() {
    const user = requireUser();
    const snapshot = await sdk.getDocFromServer(sdk.doc(db, `users/${user.uid}`));
    return snapshot.exists() && snapshot.data().deletionStartedAt != null;
  }

  async function deleteIfExists(ref) {
    const snapshot = await sdk.getDocFromServer(ref);
    if (snapshot.exists()) await sdk.deleteDoc(ref);
  }

  async function cellarExists(uid) {
    return (await sdk.getDocFromServer(sdk.doc(db, `cellars/${uid}`))).exists();
  }

  function closeBatch(cellarId, memberKey, closedBy) {
    return sdk
      .writeBatch(db)
      .update(sdk.doc(db, `cellars/${cellarId}/members/${memberKey}`), {
        status: 'revoked',
        closedBy,
        updatedAt: sdk.serverTimestamp(),
      })
      .update(sdk.doc(db, `cellars/${cellarId}`), {
        memberSlots: sdk.increment(-1),
        memberOpKey: memberKey,
      })
      .commit();
  }

  // ---- Steps -------------------------------------------------------------

  /** Step 1: deletionStartedAt, creating the profile when it is missing. */
  async function markStarted(user) {
    const ref = sdk.doc(db, `users/${user.uid}`);
    await sdk.runTransaction(db, async (transaction) => {
      const snapshot = await transaction.get(ref);
      if (!snapshot.exists()) {
        transaction.set(ref, {
          displayName: user.displayName ?? user.email ?? '',
          email: user.email ?? '',
          onboardingSeen: false,
          schemaVersion: 1,
          createdAt: sdk.serverTimestamp(),
          deletionStartedAt: sdk.serverTimestamp(),
        });
      } else if (snapshot.data().deletionStartedAt == null) {
        transaction.update(ref, { deletionStartedAt: sdk.serverTimestamp() });
      }
    });
  }

  /** Step 2 (BR1.9): activate and leave, then delete every own invitation. */
  async function leaveOtherCellars(user) {
    const key = (user.email ?? '').toLowerCase();
    const received = await sdk.getDocsFromServer(
      sdk.query(sdk.collectionGroup(db, 'members'), sdk.where('inviteeEmail', '==', key)),
    );
    for (const invitation of received.docs) {
      const cellarId = invitation.ref.parent.parent.id;
      if (cellarId === user.uid) continue;
      const status = invitation.data().status;
      if (status === 'invited') {
        await sdk
          .writeBatch(db)
          .update(invitation.ref, {
            status: 'active',
            inviteeUserId: user.uid,
            inviteeName: displayNameOrFallback(user.displayName, key),
            updatedAt: sdk.serverTimestamp(),
          })
          .commit();
      }
      if (status === 'invited' || status === 'active') {
        await closeBatch(cellarId, key, 'invitee');
      }
      await deleteIfExists(invitation.ref);
    }
  }

  /** Step 3: revoke every open invitation of the own cellar, delete all. */
  async function closeOwnInvitations(user) {
    if (!(await cellarExists(user.uid))) return;
    const given = await sdk.getDocsFromServer(
      sdk.collection(db, `cellars/${user.uid}/members`),
    );
    for (const invitation of given.docs) {
      const status = invitation.data().status;
      if (status === 'invited' || status === 'active') {
        await closeBatch(user.uid, invitation.id, 'owner');
      }
      await deleteIfExists(invitation.ref);
    }
  }

  async function deletePage(uid, name) {
    const page = await sdk.getDocsFromServer(
      sdk.query(sdk.collection(db, `cellars/${uid}/${name}`), sdk.limit(PAGE_SIZE)),
    );
    if (page.empty) return 0;
    const batch = sdk.writeBatch(db);
    page.docs.forEach((d) => batch.delete(d.ref));
    await batch.commit();
    return page.size;
  }

  /** Step 4: drinks, then wines, page after page, until both are empty. */
  async function deleteWinesAndRecords(user, report) {
    if (!(await cellarExists(user.uid))) return;
    let deleted = 0;
    for (;;) {
      let round = 0;
      for (const name of ['drinkingRecords', 'wines']) {
        for (let page = await deletePage(user.uid, name); page > 0; page = await deletePage(user.uid, name)) {
          round += page;
          deleted += page;
          report(deleted);
        }
      }
      if (round === 0) return;
    }
  }

  /** Step 6: the profile, then the Firebase user. */
  async function deleteProfileAndUser(user) {
    await deleteIfExists(sdk.doc(db, `users/${user.uid}`));
    await sdk.deleteUser(user);
  }

  /**
   * Runs steps 1-6 for the signed-in account (BR1.7), stopping at the first
   * error. [onProgress] receives `{ step, index, deleted }`.
   * Returns `{ status: 'completed' }` or `{ status: 'stopped', step, reason }`.
   */
  async function run({ onProgress = () => {} } = {}) {
    const user = requireUser();
    const actions = {
      markStarted: () => markStarted(user),
      leaveOtherCellars: () => leaveOtherCellars(user),
      closeOwnInvitations: () => closeOwnInvitations(user),
      deleteWinesAndRecords: () =>
        deleteWinesAndRecords(user, (deleted) =>
          onProgress({ step: 'deleteWinesAndRecords', index: 4, deleted }),
        ),
      deleteCellar: () => deleteIfExists(sdk.doc(db, `cellars/${user.uid}`)),
      deleteProfileAndUser: () => deleteProfileAndUser(user),
    };
    for (const [position, step] of STEPS.entries()) {
      onProgress({ step, index: position + 1, deleted: 0 });
      try {
        await actions[step]();
      } catch (error) {
        return { status: 'stopped', step, reason: classify(error) };
      }
    }
    return { status: 'completed' };
  }

  /**
   * "Delete forever" and "Try again": the Google sign-in with the same
   * account, then the whole run. Returns the run result, or
   * `{ status: 'notConfirmed', reason }` when the sign-in did not confirm.
   */
  async function deleteAccount(options = {}) {
    const confirmed = await reauthenticate();
    if (confirmed !== 'confirmed') return { status: 'notConfirmed', reason: confirmed };
    return run(options);
  }

  async function signOut() {
    await sdk.signOut(auth);
  }

  return { signIn, reauthenticate, isStarted, run, deleteAccount, signOut };
}
