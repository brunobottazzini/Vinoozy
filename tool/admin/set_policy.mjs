#!/usr/bin/env node
// Sets the product switches of config/policy (freemium-plus FR2.4, FR3.5,
// FR6.2, FR7.1). Only the fields passed change; the rest stays.
//
//   node tool/admin/set_policy.mjs [--ads-enabled true|false]
//        [--capacity-limit-enabled true|false] [--purchases-enabled true|false]
//        [--usage-budget-euro 0.005] [--free-active-wine-limit 15]
//        [--policy-version freemium-v1] --project <id> [--credentials <path>]
//   add --emulator (project demo-vinoozy) to work on the local emulator.
import { AdminError, openProject, parseOptions, runCli } from './lib/admin_context.mjs';

const USAGE = `Usage: set_policy.mjs [--ads-enabled true|false] [--capacity-limit-enabled true|false]
  [--purchases-enabled true|false] [--usage-budget-euro <decimal>] [--free-active-wine-limit <n>]
  [--policy-version <text>]  --project <id> [--credentials <path>] | --emulator`;

/** CLI option → policy field and parser. */
const FIELDS = {
  'ads-enabled': ['adsEnabled', parseBoolean],
  'capacity-limit-enabled': ['capacityLimitEnabled', parseBoolean],
  'purchases-enabled': ['purchasesEnabled', parseBoolean],
  'usage-budget-euro': ['usageBudgetEuro', parseBudget],
  'free-active-wine-limit': ['freeActiveWineLimit', parseLimit],
  'policy-version': ['policyVersion', parseVersion],
};

function parseBoolean(option, text) {
  if (text === 'true') return true;
  if (text === 'false') return false;
  throw new AdminError(`--${option} must be true or false.`, 2);
}

function parseBudget(option, text) {
  // Kept as a decimal string so the cost comparison stays exact (D3).
  if (!/^[0-9]+(\.[0-9]+)?$/.test(text)) {
    throw new AdminError(`--${option} must be a decimal such as 0.005.`, 2);
  }
  return text;
}

function parseLimit(option, text) {
  const limit = Number(text);
  if (!/^[0-9]+$/.test(text) || !Number.isSafeInteger(limit) || limit < 1) {
    throw new AdminError(`--${option} must be a whole number of at least 1.`, 2);
  }
  return limit;
}

function parseVersion(option, text) {
  if (!/^[A-Za-z0-9._-]{1,64}$/.test(text)) {
    throw new AdminError(`--${option} must be 1-64 letters, digits, dots, dashes or underscores.`, 2);
  }
  return text;
}

/** The fields to merge into config/policy from the parsed [values]. */
export function policyPatch(values) {
  const patch = {};
  for (const [option, [field, parse]] of Object.entries(FIELDS)) {
    if (values[option] !== undefined) patch[field] = parse(option, values[option]);
  }
  return patch;
}

export async function main(argv, { out }) {
  const options = Object.fromEntries(Object.keys(FIELDS).map((name) => [name, { type: 'string' }]));
  const { values, positionals } = parseOptions(argv, options);
  if (values.help) {
    out(USAGE);
    return;
  }
  if (positionals.length > 0) throw new AdminError(USAGE, 2);
  const patch = policyPatch(values);
  if (Object.keys(patch).length === 0) {
    throw new AdminError(`Nothing to set.\n${USAGE}`, 2);
  }
  const project = openProject(values, out);
  const ref = project.db.collection('config').doc('policy');
  await ref.set(patch, { merge: true });
  const policy = (await ref.get()).data();
  out('config/policy is now:');
  for (const key of Object.keys(policy).sort()) out(`  ${key}: ${JSON.stringify(policy[key])}`);
}

await runCli(main);
