// Public web configuration of Firebase for the account deletion page
// (u8-account security-design.md §3). These values are public by nature and
// are not secrets: Firestore is protected by the rules and by App Check.
// No service credential ever goes here.
//
// Public configuration copied from the registered "Vinoozy Web" app in the
// production Firebase project on 2026-11-09. The public reCAPTCHA site key
// below still needs configuration. While a value starts with "TODO" the
// page shows "not configured yet" and signs nobody in.
export const firebaseConfig = {
  apiKey: "AIzaSyDMNC_kLEeoeVb3wcKMtzqZwNQJrqbjfFU",
  authDomain: "vinoozy-d6f45.firebaseapp.com",
  projectId: "vinoozy-d6f45",
  appId: "1:742143174654:web:815bb282e4a519d0e042af",
};

// TODO(owner): public reCAPTCHA v3 site key registered for
// brunobottazzini.github.io in App Check.
export const recaptchaSiteKey = 'TODO_RECAPTCHA_V3_SITE_KEY';

// Emulator addresses, only for the tests (test/web/); always null here.
export const emulators = null;
