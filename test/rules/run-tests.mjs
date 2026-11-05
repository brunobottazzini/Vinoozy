// Runs the rules test files given as arguments (files or directories) with the
// Node test runner, one file at a time: every file loads its own rules into
// the single demo-vinoozy emulator project, so files must not overlap.
//
//   npm --prefix test/rules test -- u1.rules.test.mjs compat/
//   npm --prefix test/rules test            # every *.test.mjs
import { spawnSync } from 'node:child_process';
import { readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';

function collect(target) {
  const stats = statSync(target);
  if (stats.isFile()) return [target];
  return readdirSync(target)
    .flatMap((name) => collect(join(target, name)))
    .filter((file) => file.endsWith('.test.mjs'));
}

const targets = process.argv.slice(2);
const files = (targets.length > 0 ? targets : ['.']).flatMap(collect).sort();
if (files.length === 0) {
  console.error('run-tests: no *.test.mjs files found in', targets);
  process.exit(2);
}

const result = spawnSync(
  process.execPath,
  ['--test', '--test-concurrency=1', ...files],
  { stdio: 'inherit' },
);
process.exit(result.status ?? 1);
