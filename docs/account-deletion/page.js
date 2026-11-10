// Entry point of the account deletion page (u8-account BR1.11, NFR8.5),
// bundled with the Firebase JS SDK into app.bundle.js by
// tool/build_web_bundle.sh. Never edit app.bundle.js by hand.
//
// Every text the page shows is in its HTML file (it, en, pt-BR); this code
// only shows and hides those elements. It sends no telemetry (privacy
// choice, monitoring-design.md §5): an error shows its message with
// "Try again" and the email address as the last resort.
import { initializeApp } from 'firebase/app';
import { initializeAppCheck, ReCaptchaEnterpriseProvider } from 'firebase/app-check';
import {
  connectAuthEmulator,
  deleteUser,
  getAuth,
  GoogleAuthProvider,
  onAuthStateChanged,
  reauthenticateWithPopup,
  signInWithPopup,
  signOut,
} from 'firebase/auth';
import {
  collection,
  collectionGroup,
  connectFirestoreEmulator,
  deleteDoc,
  doc,
  getDocFromServer,
  getDocsFromServer,
  getFirestore,
  increment,
  limit,
  query,
  runTransaction,
  serverTimestamp,
  where,
  writeBatch,
} from 'firebase/firestore';

// Kept out of the bundle (tool/build_web_bundle.sh): the owner fills it
// without rebuilding app.bundle.js.
import { emulators, firebaseConfig, recaptchaSiteKey } from './firebase-config.js';
import { createAccountDeletion } from './account-deletion.js';

const $ = (selector) => document.querySelector(selector);

function show(element, visible) {
  if (element) element.hidden = !visible;
}

/** Shows only the message named [name] (data-message), or none. */
function message(name) {
  for (const element of document.querySelectorAll('[data-message]')) {
    show(element, element.dataset.message === name);
  }
}

function configured() {
  return !Object.values(firebaseConfig).some((value) => String(value).startsWith('TODO'));
}

function start() {
  if (!configured()) {
    message('config');
    $('#sign-in').disabled = true;
    return;
  }
  const app = initializeApp(firebaseConfig);
  if (recaptchaSiteKey && !String(recaptchaSiteKey).startsWith('TODO')) {
    initializeAppCheck(app, {
      provider: new ReCaptchaEnterpriseProvider(recaptchaSiteKey),
      isTokenAutoRefreshEnabled: true,
    });
  }
  const auth = getAuth(app);
  const db = getFirestore(app);
  if (emulators) {
    connectAuthEmulator(auth, emulators.auth, { disableWarnings: true });
    connectFirestoreEmulator(db, emulators.firestoreHost, emulators.firestorePort);
  }
  const deletion = createAccountDeletion(
    {
      collection,
      collectionGroup,
      deleteDoc,
      deleteUser,
      doc,
      getDocFromServer,
      getDocsFromServer,
      GoogleAuthProvider,
      increment,
      limit,
      query,
      reauthenticateWithPopup,
      runTransaction,
      serverTimestamp,
      signInWithPopup,
      signOut,
      where,
      writeBatch,
    },
    db,
    auth,
  );
  bind(deletion, auth);
}

function bind(deletion, auth) {
  const word = $('#confirm-word');
  const remove = $('#delete');
  const retry = $('#retry');

  word.addEventListener('input', () => {
    remove.disabled = word.value.trim().toUpperCase() !== word.dataset.word;
  });

  $('#sign-in').addEventListener('click', async () => {
    message(null);
    const result = await deletion.signIn();
    if (result === 'failed') message('failed');
  });

  $('#sign-out').addEventListener('click', () => deletion.signOut());

  async function runDeletion() {
    if (!navigator.onLine) {
      message('offline');
      show(retry, true);
      return;
    }
    message(null);
    remove.disabled = true;
    show(retry, false);
    show($('#progress'), true);
    const result = await deletion.deleteAccount({ onProgress: progress });
    if (result.status === 'completed') {
      show($('#signed-in'), false);
      message('done');
      return;
    }
    message(result.status === 'notConfirmed' ? 'sameAccount' : result.reason);
    show(retry, true);
    remove.disabled = word.value.trim().toUpperCase() !== word.dataset.word;
  }

  remove.addEventListener('click', runDeletion);
  retry.addEventListener('click', runDeletion);

  onAuthStateChanged(auth, async (user) => {
    show($('#signed-out'), !user);
    show($('#signed-in'), Boolean(user));
    if (!user) return;
    $('#account-email').textContent = user.email ?? '';
    try {
      if (await deletion.isStarted()) message('started');
    } catch {
      // Unreadable: the deletion can still be confirmed and run.
    }
  });
}

function progress({ index, deleted }) {
  for (const item of document.querySelectorAll('#progress [data-step]')) {
    const step = Number(item.dataset.step);
    item.dataset.state = step < index ? 'done' : step === index ? 'current' : 'todo';
  }
  const count = $('#deleted-count');
  if (count) count.textContent = deleted > 0 ? String(deleted) : '';
}

start();
