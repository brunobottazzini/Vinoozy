#!/usr/bin/env node
// The capacity migration (freemium-plus FR2.3): for every cellar, counts the
// wines with quantity > 0 and writes activeWineCount and, once,
// legacyActiveWineLimit = max(15, active wines). Run it before turning
// capacityLimitEnabled on. Re-running recounts activeWineCount and keeps an
// existing legacyActiveWineLimit.
//
//   node tool/admin/migrate_capacity.mjs [--dry-run] --project <id> [--credentials <path>]
//   add --emulator (project demo-vinoozy) to work on the local emulator.
import { AdminError, openProject, parseOptions, runCli } from './lib/admin_context.mjs';

const USAGE = `Usage: migrate_capacity.mjs [--dry-run]  --project <id> [--credentials <path>] | --emulator`;

/** The free plan's active wines (FR2.4). */
export const FREE_ACTIVE_WINE_LIMIT = 15;

export function legacyLimitFor(activeWines) {
  return Math.max(FREE_ACTIVE_WINE_LIMIT, activeWines);
}

/**
 * Migrates one cellar in a transaction, so a wine written meanwhile makes
 * the transaction retry with the new count.
 */
async function migrateCellar(db, cellarRef, dryRun) {
  return db.runTransaction(async (tx) => {
    const activeQuery = cellarRef.collection('wines').where('quantity', '>', 0).count();
    const [cellar, aggregate] = await Promise.all([tx.get(cellarRef), tx.get(activeQuery)]);
    const active = aggregate.data().count;
    const existingLimit = cellar.data()?.legacyActiveWineLimit;
    const legacy = typeof existingLimit === 'number' ? existingLimit : legacyLimitFor(active);
    if (!dryRun) {
      tx.update(cellarRef, { activeWineCount: active, legacyActiveWineLimit: legacy });
    }
    return { active, legacy, kept: typeof existingLimit === 'number' };
  });
}

export async function main(argv, { out }) {
  const { values, positionals } = parseOptions(argv, {
    'dry-run': { type: 'boolean', default: false },
  });
  if (values.help) {
    out(USAGE);
    return;
  }
  if (positionals.length > 0) throw new AdminError(USAGE, 2);
  const dryRun = values['dry-run'];
  const project = openProject(values, out);
  const cellars = await project.db.collection('cellars').get();
  let migrated = 0;
  for (const cellar of cellars.docs) {
    const result = await migrateCellar(project.db, cellar.ref, dryRun);
    migrated++;
    out(
      `${cellar.id}: activeWineCount=${result.active} legacyActiveWineLimit=${result.legacy}` +
        (result.kept ? ' (kept)' : ''),
    );
  }
  out(`${dryRun ? 'Dry run: would migrate' : 'Migrated'} ${migrated} cellars.`);
}

await runCli(main);
