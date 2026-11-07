// Public web configuration of Firebase for the account deletion page
// (u8-account security-design.md §3). These values are public by nature and
// are not secrets: Firestore is protected by the rules and by App Check.
// No service credential ever goes here.
//
// TODO(owner): fill every value from the Firebase console of the production
// project (Project settings > Your apps > Web app, and App Check > reCAPTCHA
// v3 site key), then run pages.yml. While a value starts with "TODO" the page
// shows "not configured yet" and signs nobody in. The real values were not
// available when this file was written, so none is invented here.
export const firebaseConfig = {
  apiKey: 'TODO_WEB_API_KEY',
  authDomain: 'TODO_PROJECT_ID.firebaseapp.com',
  projectId: 'TODO_PROJECT_ID',
  appId: 'TODO_WEB_APP_ID',
};

// TODO(owner): public reCAPTCHA v3 site key registered for
// brunobottazzini.github.io in App Check.
export const recaptchaSiteKey = 'TODO_RECAPTCHA_V3_SITE_KEY';

// Emulator addresses, only for the tests (test/web/); always null here.
export const emulators = null;
