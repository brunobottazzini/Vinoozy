// Checks the public web configuration of the account deletion page before
// pages.yml publishes it (u8-account review R-04):
//   - every value of firebaseConfig (apiKey, authDomain, projectId, appId)
//     is a non-empty string without "TODO", whatever the quotes used;
//   - recaptchaSiteKey is a non-empty string without "TODO";
//   - emulators is null or absent, so the published page never talks to
//     the Firebase emulators.
// Every problem is listed; the exit status is 1 if there is any, 2 when the
// file cannot be read.
//
// Usage: node tool/check_web_config.mjs [firebase-config.js]
//   default: docs/account-deletion/firebase-config.js
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const file = resolve(process.argv[2] ?? 'docs/account-deletion/firebase-config.js');

let config;
try {
  // Imported from its text, so the check never depends on how Node types
  // the .js file and never runs it from its own folder.
  const source = readFileSync(file, 'utf8');
  config = await import(`data:text/javascript,${encodeURIComponent(source)}`);
} catch (error) {
  console.error(`check_web_config: cannot read ${file}: ${error.message}`);
  process.exit(2);
}

const problems = [];
const filled = (value) =>
  typeof value === 'string' && value.trim() !== '' && !/todo/i.test(value);

const required = ['apiKey', 'authDomain', 'projectId', 'appId'];
if (config.firebaseConfig === null || typeof config.firebaseConfig !== 'object') {
  problems.push('firebaseConfig is missing');
} else {
  for (const key of required) {
    if (!filled(config.firebaseConfig[key])) {
      problems.push(`firebaseConfig.${key} is empty or still TODO`);
    }
  }
}
if (!filled(config.recaptchaSiteKey)) {
  problems.push('recaptchaSiteKey is empty or still TODO');
}
if (config.emulators !== null && config.emulators !== undefined) {
  problems.push('emulators must be null: the published page would use the emulators');
}

if (problems.length > 0) {
  console.error(`check_web_config: FAILED for ${file}`);
  for (const problem of problems) console.error(`  - ${problem}`);
  process.exit(1);
}
console.log(`check_web_config: OK (${file})`);
