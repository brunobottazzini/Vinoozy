// Rules compatibility in both directions (cicd-pipeline.md §4, Infrastructure
// Design review 2): rules are deployed separately from the app, so
//  1. the current rules must accept the writes of every recorded app version;
//  2. the current app's writes must pass the rules of the latest v* tag (the
//     rules running in production), when such a tag exists.
//
// u7-sharing (cicd-pipeline.md §1-bis): a write may carry
// `"requiresRules": "<feature>"` when it needs rules that production does not
// have yet. Direction 2 skips it and logs the skip; direction 1 still runs
// it. The skip is allowed only for a feature named in RULES_FEATURES of
// .github/workflows/promote.yml, whose check stops a promotion until the
// rules of the build are the ones deployed.
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { after, describe, test } from 'node:test';
import { fileURLToPath } from 'node:url';

import { assertSucceeds } from '@firebase/rules-unit-testing';
import {
  deleteDoc,
  deleteField,
  doc,
  increment,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

import { googleUser, startEnv } from '../helpers.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(here, '..', '..', '..');
const fixtures = JSON.parse(readFileSync(join(here, 'app-writes.json'), 'utf8'));
const UID = 'compat-user';
const INVITEE_UID = 'compat-invitee';
const INVITEE_EMAIL = 'compat-invitee@example.com';

function resolve(value) {
  if (Array.isArray(value)) return value.map(resolve);
  if (value !== null && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, resolve(v)]));
  }
  if (typeof value !== 'string') return value;
  if (value === '$uid') return UID;
  if (value === '$inviteeUid') return INVITEE_UID;
  if (value === '$inviteeEmail') return INVITEE_EMAIL;
  if (value === '$serverTimestamp') return serverTimestamp();
  if (value === '$deleteField') return deleteField();
  if (value === '$currentYear') return new Date().getUTCFullYear();
  if (value.startsWith('$increment:')) return increment(Number(value.slice('$increment:'.length)));
  return value;
}

const resolvePath = (path) =>
  path.replaceAll('$uid', UID).replaceAll('$inviteeEmail', INVITEE_EMAIL);

/** The signed-in app of a write: the owner, or the invited person. */
function dbOf(env, write) {
  return write.as === 'invitee'
    ? googleUser(env, INVITEE_UID, INVITEE_EMAIL)
    : googleUser(env, UID, 'user-a@example.com');
}

function operation(db, write) {
  if (write.op === 'batch') {
    const batch = writeBatch(db);
    for (const step of write.writes) {
      const ref = doc(db, resolvePath(step.path));
      if (step.op === 'set') batch.set(ref, resolve(step.data));
      else if (step.op === 'update') batch.update(ref, resolve(step.data));
      else batch.delete(ref);
    }
    return batch.commit();
  }
  const ref = doc(db, resolvePath(write.path));
  if (write.op === 'set') return setDoc(ref, resolve(write.data));
  if (write.op === 'update') return updateDoc(ref, resolve(write.data));
  return deleteDoc(ref);
}

async function replay(env, writes, { skipRequiringRules = false } = {}) {
  await env.clearFirestore();
  for (const write of writes) {
    if (skipRequiringRules && write.requiresRules) {
      console.log(
        `compat: skipped "${write.label}" (requiresRules: ${write.requiresRules}); ` +
          'production rules do not have it yet',
      );
      continue;
    }
    try {
      await assertSucceeds(operation(dbOf(env, write), write));
    } catch (error) {
      throw new Error(`"${write.label}" was denied: ${error.message}`);
    }
  }
}

/** Rules of the most recent v* tag, or null when there is none. */
function previousRules() {
  let tags;
  try {
    tags = execFileSync('git', ['tag', '--list', 'v*', '--sort=-v:refname'], {
      cwd: repoRoot,
      encoding: 'utf8',
    })
      .split('\n')
      .filter(Boolean);
  } catch {
    return null;
  }
  if (tags.length === 0) return null;
  try {
    return {
      tag: tags[0],
      rules: execFileSync('git', ['show', `${tags[0]}:firestore.rules`], {
        cwd: repoRoot,
        encoding: 'utf8',
      }),
    };
  } catch {
    return null;
  }
}

/** Features listed in RULES_FEATURES of the promotion workflow. */
function promotionFeatures() {
  const workflow = readFileSync(join(repoRoot, '.github', 'workflows', 'promote.yml'), 'utf8');
  const line = workflow.split('\n').find((text) => /^\s*RULES_FEATURES:/.test(text));
  if (!line) return [];
  return line
    .replace(/^\s*RULES_FEATURES:\s*/, '')
    .replace(/["']/g, '')
    .split(/[\s,]+/)
    .filter(Boolean);
}

const envs = [];
after(async () => {
  for (const env of envs) await env.cleanup();
});

describe('rules compatibility', () => {
  test('the fixtures describe at least one app version with writes', () => {
    if (!Array.isArray(fixtures.versions) || fixtures.versions.length === 0) {
      throw new Error('app-writes.json has no versions');
    }
    for (const version of fixtures.versions) {
      if (!Array.isArray(version.writes) || version.writes.length === 0) {
        throw new Error(`version ${version.app} has no writes`);
      }
    }
  });

  test('every requiresRules feature is guarded by the promotion check', () => {
    const guarded = promotionFeatures();
    for (const version of fixtures.versions) {
      for (const write of version.writes) {
        if (write.requiresRules && !guarded.includes(write.requiresRules)) {
          throw new Error(
            `"${write.label}" requires rules "${write.requiresRules}", ` +
              'missing from RULES_FEATURES in .github/workflows/promote.yml',
          );
        }
      }
    }
  });

  for (const version of fixtures.versions) {
    test(`current rules accept the writes of app version ${version.app}`, async () => {
      const env = await startEnv();
      envs.push(env);
      await replay(env, version.writes);
    });
  }

  const previous = previousRules();
  const latest = fixtures.versions.at(-1);
  test(
    'the rules of the latest v* tag accept the current app writes',
    { skip: previous === null ? 'no v* tag yet: nothing deployed to compare with' : false },
    async () => {
      const env = await startEnv(previous.rules);
      envs.push(env);
      await replay(env, latest.writes, { skipRequiringRules: true });
    },
  );
});
