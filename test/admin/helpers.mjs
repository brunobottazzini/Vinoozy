// Helpers of the admin script tests (freemium-plus Step 14): they run the
// real scripts as child processes with --emulator and look at the Firestore
// and Auth emulators through their REST APIs, so no extra dependency.
import { execFile } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

export const PROJECT_ID = 'demo-vinoozy';
export const REPO_ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const FIRESTORE = process.env.FIRESTORE_EMULATOR_HOST;
const AUTH = process.env.FIREBASE_AUTH_EMULATOR_HOST;

if (!FIRESTORE || !AUTH) {
  throw new Error(
    'Run these tests inside the emulator: npm run test:admin ' +
      '(FIRESTORE_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST are missing).',
  );
}

const DOCUMENTS = `http://${FIRESTORE}/v1/projects/${PROJECT_ID}/databases/(default)/documents`;
// `Bearer owner` makes the Firestore emulator skip the security rules.
const OWNER = { authorization: 'Bearer owner', 'content-type': 'application/json' };

/** Runs tool/admin/<script> with [args]; never rejects. */
export function runScript(script, args, env = process.env) {
  return new Promise((resolve) => {
    execFile(
      process.execPath,
      [join(REPO_ROOT, 'tool', 'admin', script), ...args],
      { cwd: REPO_ROOT, env },
      (error, stdout, stderr) => {
        resolve({ code: error ? (error.code ?? 1) : 0, stdout, stderr });
      },
    );
  });
}

export async function resetEmulators() {
  const responses = await Promise.all([
    fetch(`http://${FIRESTORE}/emulator/v1/projects/${PROJECT_ID}/databases/(default)/documents`, {
      method: 'DELETE',
    }),
    fetch(`http://${AUTH}/emulator/v1/projects/${PROJECT_ID}/accounts`, { method: 'DELETE' }),
  ]);
  for (const response of responses) {
    if (!response.ok) throw new Error(`Emulator reset failed: ${response.status}`);
  }
}

/** Creates an Auth emulator account and returns its uid. */
export async function createUser(email) {
  const response = await fetch(
    `http://${AUTH}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key`,
    {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ email, password: 'secret-123', returnSecureToken: true }),
    },
  );
  const json = await response.json();
  if (!json.localId) throw new Error(`signUp failed: ${JSON.stringify(json)}`);
  return json.localId;
}

function encode(value) {
  if (value === null) return { nullValue: null };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (Number.isInteger(value)) return { integerValue: String(value) };
  if (typeof value === 'number') return { doubleValue: value };
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  return { stringValue: String(value) };
}

function decode(value) {
  if ('nullValue' in value) return null;
  if ('booleanValue' in value) return value.booleanValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return value.doubleValue;
  if ('timestampValue' in value) return new Date(value.timestampValue);
  if ('stringValue' in value) return value.stringValue;
  throw new Error(`Unsupported value ${JSON.stringify(value)}`);
}

/** Writes several documents ({path: data}) in one commit, rules skipped. */
export async function seed(documents) {
  const writes = Object.entries(documents).map(([path, data]) => ({
    update: {
      name: `projects/${PROJECT_ID}/databases/(default)/documents/${path}`,
      fields: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, encode(v)])),
    },
  }));
  const response = await fetch(`${DOCUMENTS}:commit`, {
    method: 'POST',
    headers: OWNER,
    body: JSON.stringify({ writes }),
  });
  if (!response.ok) throw new Error(`seed failed: ${response.status} ${await response.text()}`);
}

/** The document at [path] as a plain object, or null. */
export async function readDoc(path) {
  const response = await fetch(`${DOCUMENTS}/${path}`, { headers: OWNER });
  if (response.status === 404) return null;
  if (!response.ok) throw new Error(`read failed: ${response.status}`);
  const json = await response.json();
  return Object.fromEntries(Object.entries(json.fields ?? {}).map(([k, v]) => [k, decode(v)]));
}

/** Ids of the documents of a collection. */
export async function listIds(collectionPath) {
  const response = await fetch(`${DOCUMENTS}/${collectionPath}?pageSize=300`, { headers: OWNER });
  if (!response.ok) throw new Error(`list failed: ${response.status}`);
  const json = await response.json();
  return (json.documents ?? []).map((doc) => doc.name.split('/').pop());
}

/** The environment without emulator hosts, as on the owner's Mac. */
export function productionEnv(extra = {}) {
  const env = { ...process.env, ...extra };
  delete env.FIRESTORE_EMULATOR_HOST;
  delete env.FIREBASE_AUTH_EMULATOR_HOST;
  delete env.GOOGLE_APPLICATION_CREDENTIALS;
  return env;
}
