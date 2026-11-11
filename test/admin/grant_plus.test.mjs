// tool/admin/grant_plus.mjs on the emulator (freemium-plus FR4.1, FR4.2,
// FR4.4). Run with:
//   firebase emulators:exec --only firestore,auth --project demo-vinoozy "node --test test/admin/grant_plus.test.mjs"
import assert from 'node:assert/strict';
import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { beforeEach, describe, it } from 'node:test';

import {
  createUser,
  listIds,
  productionEnv,
  readDoc,
  resetEmulators,
  runScript,
  seed,
} from './helpers.mjs';

const grant = (...args) => runScript('grant_plus.mjs', ['grant', '--emulator', ...args]);
const revoke = (...args) => runScript('grant_plus.mjs', ['revoke', '--emulator', ...args]);

describe('grant_plus.mjs', () => {
  let uid;

  beforeEach(async () => {
    await resetEmulators();
    uid = await createUser('friend@example.com');
  });

  it('grants Plus with an expiry, printing project, uid and expiry', async () => {
    const result = await grant('--email', 'friend@example.com', '--until', '2099-01-31');

    assert.equal(result.code, 0, result.stderr);
    assert.match(result.stdout, /Project: demo-vinoozy \(emulator/);
    assert.match(result.stdout, new RegExp(`uid: ${uid}`));
    assert.match(result.stdout, /expires: 2099-02-01T00:00:00.000Z/);
    const entitlement = await readDoc(`entitlements/${uid}`);
    assert.equal(entitlement.plan, 'plus');
    assert.equal(entitlement.source, 'manual_grant');
    assert.equal(entitlement.status, 'active');
    assert.equal(entitlement.reason, 'gift');
    assert.equal(entitlement.expiresAt.toISOString(), '2099-02-01T00:00:00.000Z');
    assert.ok(entitlement.startedAt instanceof Date);
    assert.equal('purchaseToken' in entitlement, false, 'never a purchase token');
  });

  it('grants Plus without expiry for the owner test', async () => {
    const result = await grant('--email', 'friend@example.com', '--no-expiry', '--reason', 'owner_test');

    assert.equal(result.code, 0, result.stderr);
    assert.match(result.stdout, /expires: never/);
    const entitlement = await readDoc(`entitlements/${uid}`);
    assert.equal(entitlement.reason, 'owner_test');
    assert.equal('expiresAt' in entitlement, false);
  });

  it('stops on an unknown email and writes nothing', async () => {
    const result = await grant('--email', 'nobody@example.com', '--no-expiry');

    assert.equal(result.code, 1);
    assert.match(result.stderr, /No registered account with email nobody@example.com/);
    assert.deepEqual(await listIds('entitlements'), []);
  });

  it('revokes a grant and leaves the cellar untouched', async () => {
    await seed({
      [`cellars/${uid}`]: { name: 'Cantina', activeWineCount: 1 },
      [`cellars/${uid}/wines/w1`]: { name: 'Barolo', quantity: 3 },
    });
    await grant('--email', 'friend@example.com', '--no-expiry');

    const result = await revoke('--email', 'friend@example.com');

    assert.equal(result.code, 0, result.stderr);
    assert.equal((await readDoc(`entitlements/${uid}`)).status, 'revoked');
    assert.equal((await readDoc(`cellars/${uid}/wines/w1`)).quantity, 3);
    assert.equal((await readDoc(`cellars/${uid}`)).activeWineCount, 1);
  });

  it('never revokes or hides a Play subscription', async () => {
    await seed({
      [`entitlements/${uid}`]: {
        plan: 'plus',
        source: 'play_purchase',
        status: 'active',
        expiresAt: new Date('2099-01-01T00:00:00Z'),
      },
    });

    const revoked = await revoke('--email', 'friend@example.com');
    const granted = await grant('--email', 'friend@example.com', '--no-expiry');

    assert.equal(revoked.code, 1);
    assert.match(revoked.stderr, /managed by Google Play/);
    assert.equal(granted.code, 1);
    assert.match(granted.stderr, /--force/);
    assert.equal((await readDoc(`entitlements/${uid}`)).source, 'play_purchase');
  });

  it('refuses bad dates and option combinations', async () => {
    const cases = [
      ['--email', 'friend@example.com', '--until', '2099-02-30'],
      ['--email', 'friend@example.com', '--until', '2000-01-01'],
      ['--email', 'friend@example.com'],
      ['--email', 'friend@example.com', '--no-expiry', '--until', '2099-01-01'],
      ['--email', 'friend@example.com', '--no-expiry', '--reason', 'bribe'],
    ];
    for (const args of cases) {
      const result = await grant(...args);
      assert.equal(result.code, 2, `${args.join(' ')}\n${result.stderr}`);
    }
    assert.deepEqual(await listIds('entitlements'), []);
  });

  it('works on the emulator only with the demo project', async () => {
    const result = await grant('--email', 'friend@example.com', '--no-expiry', '--project', 'vinoozy-d6f45');
    assert.equal(result.code, 1);
    assert.match(result.stderr, /--emulator works only with project demo-vinoozy/);
    assert.deepEqual(await listIds('entitlements'), []);
  });

  it('without --emulator explains what is missing and stops', async () => {
    const args = ['grant', '--email', 'friend@example.com', '--no-expiry'];
    const withEmulatorHosts = await runScript('grant_plus.mjs', [...args, '--project', 'vinoozy-d6f45']);
    const noCredentials = await runScript('grant_plus.mjs', [...args, '--project', 'vinoozy-d6f45'], productionEnv());
    const keyInRepo = await runScript(
      'grant_plus.mjs',
      [...args, '--project', 'vinoozy-d6f45', '--credentials', 'tool/admin/owner.key.json'],
      productionEnv(),
    );

    assert.match(withEmulatorHosts.stderr, /Emulator hosts are set/);
    assert.match(noCredentials.stderr, /Missing credentials/);
    assert.match(keyInRepo.stderr, /inside the repository/);
    for (const result of [withEmulatorHosts, noCredentials, keyInRepo]) assert.equal(result.code, 1);
    assert.deepEqual(await listIds('entitlements'), []);
  });

  it('--firebase-login needs a Firebase CLI login and excludes the other credentials', async () => {
    const args = ['grant', '--email', 'friend@example.com', '--no-expiry', '--firebase-login'];
    // An empty home and config directory: no Firebase CLI login is stored.
    const home = await mkdtemp(join(tmpdir(), 'vinoozy-admin-'));
    const noLoginEnv = productionEnv({ HOME: home, XDG_CONFIG_HOME: join(home, '.config') });
    try {
      const notLoggedIn = await runScript('grant_plus.mjs', [...args, '--project', 'vinoozy-d6f45'], noLoginEnv);
      const both = await runScript(
        'grant_plus.mjs',
        [...args, '--project', 'vinoozy-d6f45', '--credentials', '/tmp/key.json'],
        noLoginEnv,
      );
      const noProject = await runScript('grant_plus.mjs', args, noLoginEnv);
      const onEmulator = await grant('--email', 'friend@example.com', '--no-expiry', '--firebase-login');

      assert.equal(notLoggedIn.code, 1);
      assert.match(notLoggedIn.stderr, /Not logged in to the Firebase CLI/);
      assert.equal(both.code, 2);
      assert.match(both.stderr, /either --credentials or --firebase-login/);
      assert.equal(noProject.code, 1);
      assert.match(noProject.stderr, /Missing --project/);
      assert.equal(onEmulator.code, 1);
      assert.match(onEmulator.stderr, /--emulator takes no --credentials or --firebase-login/);
    } finally {
      await rm(home, { recursive: true, force: true });
    }
    assert.deepEqual(await listIds('entitlements'), []);
  });
});
