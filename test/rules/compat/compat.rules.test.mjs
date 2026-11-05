// Rules compatibility in both directions (cicd-pipeline.md §4, Infrastructure
// Design review 2): rules are deployed separately from the app, so
//  1. the current rules must accept the writes of every recorded app version;
//  2. the current app's writes must pass the rules of the latest v* tag (the
//     rules running in production), when such a tag exists.
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { after, describe, test } from 'node:test';
import { fileURLToPath } from 'node:url';

import { assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, increment, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';

import { googleUser, startEnv } from '../helpers.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const fixtures = JSON.parse(readFileSync(join(here, 'app-writes.json'), 'utf8'));
const UID = 'compat-user';

function resolve(value) {
  if (Array.isArray(value)) return value.map(resolve);
  if (value !== null && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, resolve(v)]));
  }
  if (typeof value !== 'string') return value;
  if (value === '$uid') return UID;
  if (value === '$serverTimestamp') return serverTimestamp();
  if (value === '$currentYear') return new Date().getUTCFullYear();
  if (value.startsWith('$increment:')) return increment(Number(value.slice('$increment:'.length)));
  return value;
}

async function replay(env, writes) {
  await env.clearFirestore();
  const db = googleUser(env, UID, 'user-a@example.com');
  for (const write of writes) {
    const ref = doc(db, write.path.replaceAll('$uid', UID));
    const data = resolve(write.data);
    const operation = write.op === 'set' ? setDoc(ref, data) : updateDoc(ref, data);
    try {
      await assertSucceeds(operation);
    } catch (error) {
      throw new Error(`"${write.label}" was denied: ${error.message}`);
    }
  }
}

/** Rules of the most recent v* tag, or null when there is none. */
function previousRules() {
  const repoRoot = join(here, '..', '..', '..');
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
      await replay(env, latest.writes);
    },
  );
});
