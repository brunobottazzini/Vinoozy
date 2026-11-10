#!/usr/bin/env node
// Gives or takes back Plus by hand (freemium-plus FR4.1, FR4.2, FR4.4;
// study §9.4). It writes entitlements/{uid} with source manual_grant and
// never a purchase token; revoking keeps every cellar data.
//
//   node tool/admin/grant_plus.mjs grant --email <e> (--until YYYY-MM-DD | --no-expiry)
//        [--reason gift|owner_test] [--force] --project <id> [--credentials <path>]
//   node tool/admin/grant_plus.mjs revoke --email <e> --project <id> [--credentials <path>]
//   add --emulator (project demo-vinoozy) to work on the local emulator.
import { Timestamp } from 'firebase-admin/firestore';

import { AdminError, openProject, parseOptions, runCli } from './lib/admin_context.mjs';

const USAGE = `Usage:
  grant_plus.mjs grant --email <e> (--until YYYY-MM-DD | --no-expiry) [--reason gift|owner_test] [--force]
  grant_plus.mjs revoke --email <e>
Common: --project <id> [--credentials <path>] | --emulator`;

const OPTIONS = {
  email: { type: 'string' },
  until: { type: 'string' },
  'no-expiry': { type: 'boolean', default: false },
  reason: { type: 'string', default: 'gift' },
  force: { type: 'boolean', default: false },
};

const REASONS = ['gift', 'owner_test'];
const DATE = /^([0-9]{4})-([0-9]{2})-([0-9]{2})$/;

/** `--until 2027-01-31` keeps Plus through that whole UTC day. */
export function expiryFromUntil(until, now) {
  const match = DATE.exec(until ?? '');
  if (!match) throw new AdminError('--until must be a date YYYY-MM-DD.', 2);
  const [year, month, day] = match.slice(1).map(Number);
  const start = new Date(Date.UTC(year, month - 1, day));
  // Date.UTC normalises 2027-02-30 to March: such dates are refused.
  if (start.getUTCMonth() !== month - 1 || start.getUTCDate() !== day) {
    throw new AdminError(`--until ${until} is not a calendar date.`, 2);
  }
  const endOfDay = new Date(Date.UTC(year, month - 1, day + 1));
  if (endOfDay.getTime() <= now.getTime()) {
    throw new AdminError(`--until ${until} is already past.`, 2);
  }
  return endOfDay;
}

async function findUser(auth, email) {
  if (!email) throw new AdminError('Missing --email.', 2);
  try {
    return await auth.getUserByEmail(email);
  } catch (error) {
    if (error?.code === 'auth/user-not-found') {
      throw new AdminError(`No registered account with email ${email}. Nothing was written.`);
    }
    if (error?.code === 'auth/invalid-email') {
      throw new AdminError(`${email} is not a valid email. Nothing was written.`, 2);
    }
    throw error;
  }
}

function isValidPlayPurchase(data, now) {
  if (!data || data.source !== 'play_purchase') return false;
  if (!['active', 'grace'].includes(data.status)) return false;
  return data.expiresAt instanceof Timestamp && data.expiresAt.toMillis() > now.getTime();
}

async function grant(values, out) {
  const noExpiry = values['no-expiry'];
  if (noExpiry === (values.until !== undefined)) {
    throw new AdminError('Pass exactly one of --until YYYY-MM-DD and --no-expiry.', 2);
  }
  if (!REASONS.includes(values.reason)) {
    throw new AdminError(`--reason must be one of ${REASONS.join(', ')}.`, 2);
  }
  const now = new Date();
  const expiresAt = noExpiry ? null : expiryFromUntil(values.until, now);
  const project = openProject(values, out);
  const user = await findUser(project.auth, values.email);
  const ref = project.db.collection('entitlements').doc(user.uid);
  const existing = (await ref.get()).data();
  if (isValidPlayPurchase(existing, now) && !values.force) {
    throw new AdminError(
      `${values.email} has a valid Play subscription; a grant would hide it. Add --force to grant anyway.`,
    );
  }
  const entitlement = {
    plan: 'plus',
    source: 'manual_grant',
    status: 'active',
    reason: values.reason,
    startedAt: Timestamp.fromDate(now),
    updatedAt: Timestamp.fromDate(now),
  };
  if (expiresAt) entitlement.expiresAt = Timestamp.fromDate(expiresAt);
  await ref.set(entitlement);
  out(`Granted Plus (${values.reason}) to ${values.email}`);
  out(`uid: ${user.uid}`);
  out(`expires: ${expiresAt ? expiresAt.toISOString() : 'never'}`);
}

async function revoke(values, out) {
  const project = openProject(values, out);
  const user = await findUser(project.auth, values.email);
  const ref = project.db.collection('entitlements').doc(user.uid);
  const existing = (await ref.get()).data();
  if (!existing) {
    throw new AdminError(`${values.email} has no Plus to revoke. Nothing was written.`);
  }
  if (existing.source !== 'manual_grant') {
    throw new AdminError(
      `${values.email} has a Play subscription, not a grant: it is managed by Google Play. Nothing was written.`,
    );
  }
  await ref.update({ status: 'revoked', updatedAt: Timestamp.now() });
  out(`Revoked the Plus grant of ${values.email}; cellar data is untouched.`);
  out(`uid: ${user.uid}`);
}

export async function main(argv, { out }) {
  const { values, positionals } = parseOptions(argv, OPTIONS);
  const [command, ...extra] = positionals;
  if (values.help) {
    out(USAGE);
    return;
  }
  if (extra.length > 0 || !['grant', 'revoke'].includes(command)) {
    throw new AdminError(`Expected the command grant or revoke.\n${USAGE}`, 2);
  }
  if (command === 'grant') await grant(values, out);
  else await revoke(values, out);
}

await runCli(main);
