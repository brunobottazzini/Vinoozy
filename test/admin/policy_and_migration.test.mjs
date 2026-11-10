// tool/admin/set_policy.mjs and migrate_capacity.mjs on the emulator
// (freemium-plus FR2.3, FR2.4, FR3.5, FR7.1).
import assert from 'node:assert/strict';
import { beforeEach, describe, it } from 'node:test';

import { readDoc, resetEmulators, runScript, seed } from './helpers.mjs';

describe('set_policy.mjs', () => {
  beforeEach(resetEmulators);

  const setPolicy = (...args) => runScript('set_policy.mjs', ['--emulator', ...args]);

  it('sets only the fields passed', async () => {
    await seed({ 'config/policy': { adsEnabled: false, policyVersion: 'freemium-v1' } });

    const result = await setPolicy('--capacity-limit-enabled', 'true', '--usage-budget-euro', '0.005');

    assert.equal(result.code, 0, result.stderr);
    assert.deepEqual(await readDoc('config/policy'), {
      adsEnabled: false,
      capacityLimitEnabled: true,
      policyVersion: 'freemium-v1',
      usageBudgetEuro: '0.005',
    });
    assert.match(result.stdout, /capacityLimitEnabled: true/);
  });

  it('refuses bad values and writes nothing', async () => {
    for (const args of [
      ['--ads-enabled', 'yes'],
      ['--usage-budget-euro', '5e-3'],
      ['--free-active-wine-limit', '0'],
      [],
    ]) {
      const result = await setPolicy(...args);
      assert.equal(result.code, 2, args.join(' '));
    }
    assert.equal(await readDoc('config/policy'), null);
  });
});

describe('migrate_capacity.mjs (FR2.3)', () => {
  beforeEach(resetEmulators);

  async function seedCellar(id, quantities) {
    const docs = { [`cellars/${id}`]: { name: id } };
    quantities.forEach((quantity, index) => {
      docs[`cellars/${id}/wines/w${index}`] = { quantity };
    });
    await seed(docs);
  }

  it('writes the active count and legacy limit max(15, active wines)', async () => {
    await seedCellar('big', [...Array(22).fill(1), 0, -1]);
    await seedCellar('small', [6, 1, 1, 2, 0]);

    const result = await runScript('migrate_capacity.mjs', ['--emulator']);

    assert.equal(result.code, 0, result.stderr);
    assert.deepEqual(await readDoc('cellars/big'), { name: 'big', activeWineCount: 22, legacyActiveWineLimit: 22 });
    assert.deepEqual(await readDoc('cellars/small'), { name: 'small', activeWineCount: 4, legacyActiveWineLimit: 15 });
    assert.match(result.stdout, /Migrated 2 cellars/);
  });

  it('recounts on a re-run and keeps the legacy limit', async () => {
    await seedCellar('big', Array(22).fill(1));
    await runScript('migrate_capacity.mjs', ['--emulator']);
    await seed({ 'cellars/big/wines/w0': { quantity: 0 }, 'cellars/big/wines/w1': { quantity: 0 } });

    await runScript('migrate_capacity.mjs', ['--emulator']);

    const cellar = await readDoc('cellars/big');
    assert.equal(cellar.activeWineCount, 20);
    assert.equal(cellar.legacyActiveWineLimit, 22);
  });

  it('writes nothing in a dry run', async () => {
    await seedCellar('small', [1, 1]);
    const result = await runScript('migrate_capacity.mjs', ['--emulator', '--dry-run']);
    assert.equal(result.code, 0, result.stderr);
    assert.match(result.stdout, /Dry run: would migrate 1 cellars/);
    assert.deepEqual(await readDoc('cellars/small'), { name: 'small' });
  });
});
