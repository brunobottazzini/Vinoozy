// Fixture of tool/check_web_config_test.sh: emulators left on, and an
// empty reCAPTCHA site key.
export const firebaseConfig = {
  apiKey: 'fake-api-key-for-the-check',
  authDomain: 'demo-project.firebaseapp.com',
  projectId: 'demo-project',
  appId: '1:000000000000:web:0000000000000000',
};
export const recaptchaSiteKey = '';
export const emulators = { auth: 'http://127.0.0.1:9099', firestoreHost: '127.0.0.1', firestorePort: 8080 };
