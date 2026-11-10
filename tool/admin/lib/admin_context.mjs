// Shared start-up of the owner's admin scripts (freemium-plus D7, FR4.4):
// options, credentials, project verification and Firebase Admin.
//
// Production: credentials come only from --credentials <path> or
// GOOGLE_APPLICATION_CREDENTIALS, from a file outside the repository, and
// the key's project_id must equal the --project the owner typed.
// Emulator (--emulator): project demo-vinoozy on loopback hosts only.
import { readFileSync } from 'node:fs';
import { dirname, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';

import { cert, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

export const DEMO_PROJECT_ID = 'demo-vinoozy';
const DEFAULT_FIRESTORE_EMULATOR = '127.0.0.1:8080';
const DEFAULT_AUTH_EMULATOR = '127.0.0.1:9099';
const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
const LOOPBACK = /^(127\.0\.0\.1|localhost|\[::1\]):[0-9]+$/;

/** A user-facing failure: printed without a stack trace. */
export class AdminError extends Error {
  constructor(message, exitCode = 1) {
    super(message);
    this.name = 'AdminError';
    this.exitCode = exitCode;
  }
}

/** Options every script accepts. */
export const COMMON_OPTIONS = {
  project: { type: 'string' },
  credentials: { type: 'string' },
  emulator: { type: 'boolean', default: false },
  help: { type: 'boolean', default: false },
};

/** Parses [argv] with the common options plus [options]. */
export function parseOptions(argv, options) {
  try {
    return parseArgs({
      args: argv,
      options: { ...COMMON_OPTIONS, ...options },
      allowPositionals: true,
      strict: true,
    });
  } catch (error) {
    throw new AdminError(error.message, 2);
  }
}

function isInsideRepo(path) {
  const absolute = resolve(path);
  return absolute === REPO_ROOT || absolute.startsWith(REPO_ROOT + sep);
}

function readServiceAccount(path) {
  if (isInsideRepo(path)) {
    throw new AdminError(
      `The credentials file ${path} is inside the repository. Move it outside ` +
        'the repository (it must never be committed) and pass its new path.',
    );
  }
  let json;
  try {
    json = JSON.parse(readFileSync(path, 'utf8'));
  } catch (error) {
    throw new AdminError(`Cannot read the credentials file ${path}: ${error.message}`);
  }
  if (typeof json.project_id !== 'string' || typeof json.private_key !== 'string') {
    throw new AdminError(`${path} is not a service account key file.`);
  }
  return json;
}

function emulatorContext(values, out) {
  const projectId = values.project ?? DEMO_PROJECT_ID;
  if (projectId !== DEMO_PROJECT_ID) {
    throw new AdminError(`--emulator works only with project ${DEMO_PROJECT_ID}, not ${projectId}.`);
  }
  if (values.credentials) {
    throw new AdminError('--emulator takes no --credentials.');
  }
  process.env.FIRESTORE_EMULATOR_HOST ??= DEFAULT_FIRESTORE_EMULATOR;
  process.env.FIREBASE_AUTH_EMULATOR_HOST ??= DEFAULT_AUTH_EMULATOR;
  for (const name of ['FIRESTORE_EMULATOR_HOST', 'FIREBASE_AUTH_EMULATOR_HOST']) {
    if (!LOOPBACK.test(process.env[name])) {
      throw new AdminError(`${name}=${process.env[name]} is not a local emulator host.`);
    }
  }
  const app = initializeApp({ projectId }, `admin-${projectId}`);
  out(`Project: ${projectId} (emulator, Firestore ${process.env.FIRESTORE_EMULATOR_HOST})`);
  return { app, projectId, emulator: true };
}

function productionContext(values, out) {
  if (process.env.FIRESTORE_EMULATOR_HOST || process.env.FIREBASE_AUTH_EMULATOR_HOST) {
    throw new AdminError(
      'Emulator hosts are set in the environment: add --emulator, or unset ' +
        'FIRESTORE_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST to work on the real project.',
    );
  }
  const path = values.credentials ?? process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!path) {
    throw new AdminError(
      'Missing credentials: pass --credentials <path to the service account key, ' +
        'outside the repository> or set GOOGLE_APPLICATION_CREDENTIALS.',
    );
  }
  if (!values.project) {
    throw new AdminError('Missing --project <id>: type the project id you mean to change.');
  }
  if (values.project.startsWith('demo-')) {
    throw new AdminError(`${values.project} is a demo project: use --emulator.`);
  }
  const account = readServiceAccount(path);
  if (account.project_id !== values.project) {
    throw new AdminError(
      `The credentials are for project ${account.project_id}, not ${values.project}. Nothing was written.`,
    );
  }
  const app = initializeApp(
    { credential: cert(account), projectId: values.project },
    `admin-${values.project}`,
  );
  out(`Project: ${values.project} (PRODUCTION)`);
  return { app, projectId: values.project, emulator: false };
}

/**
 * Initialises Firebase Admin after checking the project. [out] prints the
 * verified project id before anything is written.
 */
export function openProject(values, out) {
  const context = values.emulator ? emulatorContext(values, out) : productionContext(values, out);
  return {
    ...context,
    db: getFirestore(context.app),
    auth: getAuth(context.app),
  };
}

/** Runs [main] as a CLI: AdminError → message and exit code, no stack. */
export async function runCli(main) {
  const out = (line) => process.stdout.write(`${line}\n`);
  const err = (line) => process.stderr.write(`${line}\n`);
  try {
    await main(process.argv.slice(2), { out, err });
  } catch (error) {
    if (error instanceof AdminError) {
      err(`Error: ${error.message}`);
      process.exitCode = error.exitCode;
      return;
    }
    err(`Unexpected error: ${error?.stack ?? error}`);
    process.exitCode = 1;
  }
}
