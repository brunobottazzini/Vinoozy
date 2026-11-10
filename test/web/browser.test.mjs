// The bundled page in headless Chromium (u8-account infrastructure-
// specification.md, "Seconda correzione"): app.bundle.js starts, the CSP of
// each page blocks nothing the page loads, and the sign-in button shows.
// The real sign-in is covered by account-deletion.test.mjs.
//
// Needs Chromium: `npx playwright install chromium`.
import assert from 'node:assert/strict';
import { createReadStream, existsSync, statSync } from 'node:fs';
import { createServer } from 'node:http';
import { extname, join, normalize } from 'node:path';
import { after, before, describe, test } from 'node:test';

import { chromium } from 'playwright';

import { AUTH, FIRESTORE, ROOT } from './helpers.mjs';

const SITE = join(ROOT, 'docs', 'account-deletion');
const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
};

/** Emulator configuration served instead of the owner's placeholders. */
const EMULATOR_CONFIG = `
export const firebaseConfig = {
  apiKey: 'demo-key',
  authDomain: 'localhost',
  projectId: 'demo-vinoozy',
  appId: 'demo-app',
};
export const recaptchaSiteKey = '';
export const emulators = {
  auth: 'http://${AUTH.host}:${AUTH.port}',
  firestoreHost: '${FIRESTORE.host}',
  firestorePort: ${FIRESTORE.port},
};
`;

/**
 * The unfilled configuration the page ships with before the owner copies the
 * real values (BR1.11). Served explicitly: the committed firebase-config.js
 * now holds the real public web configuration.
 */
const PLACEHOLDER_CONFIG = `
export const firebaseConfig = {
  apiKey: 'TODO_WEB_API_KEY',
  authDomain: 'TODO_PROJECT_ID.firebaseapp.com',
  projectId: 'TODO_PROJECT_ID',
  appId: 'TODO_WEB_APP_ID',
};
export const recaptchaSiteKey = 'TODO_RECAPTCHA_V3_SITE_KEY';
export const emulators = null;
`;

let server;
let base;
let browser;

before(async () => {
  server = createServer((request, response) => {
    let path = normalize(decodeURIComponent(new URL(request.url, 'http://x').pathname));
    if (path.endsWith('/')) path += 'index.html';
    const file = join(SITE, path);
    if (!file.startsWith(SITE) || !existsSync(file) || !statSync(file).isFile()) {
      response.writeHead(404).end();
      return;
    }
    response.writeHead(200, { 'content-type': TYPES[extname(file)] ?? 'application/octet-stream' });
    createReadStream(file).pipe(response);
  });
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  base = `http://127.0.0.1:${server.address().port}`;
  browser = await chromium.launch();
});

after(async () => {
  await browser?.close();
  await new Promise((resolve) => server.close(resolve));
});

/** Opens [path] and collects every console error and CSP violation. */
async function open(path, { config = EMULATOR_CONFIG } = {}) {
  const page = await browser.newPage();
  const errors = [];
  page.on('console', (message) => {
    if (message.type() === 'error') errors.push(message.text());
  });
  page.on('pageerror', (error) => errors.push(error.message));
  if (config !== null) {
    await page.route('**/firebase-config.js', (route) =>
      route.fulfill({ contentType: 'text/javascript', body: config }),
    );
  }
  await page.addInitScript(() => {
    window.__cspViolations = [];
    document.addEventListener('securitypolicyviolation', (event) => {
      window.__cspViolations.push(`${event.violatedDirective} ${event.blockedURI}`);
    });
  });
  await page.goto(`${base}${path}`, { waitUntil: 'networkidle' });
  return { page, errors };
}

describe('account deletion page in Chromium', () => {
  for (const [path, lang, label] of [
    ['/', 'it', 'Accedi con Google'],
    ['/en/', 'en', 'Sign in with Google'],
    ['/pt-BR/', 'pt-BR', 'Entrar com o Google'],
  ]) {
    test(`BR1.11 ${lang}: the bundle starts with no CSP error and shows the sign-in`, async () => {
      const { page, errors } = await open(path);
      const button = page.locator('#sign-in');
      await button.waitFor({ state: 'visible' });
      assert.equal(await button.textContent(), label);
      assert.equal(await button.isEnabled(), true);
      assert.equal(await page.getAttribute('html', 'lang'), lang);
      assert.equal(await page.locator('[data-message="config"]').isHidden(), true);
      assert.deepEqual(await page.evaluate(() => window.__cspViolations), []);
      assert.deepEqual(
        errors.filter((text) => /Content Security Policy|Refused to/i.test(text)),
        [],
      );
      assert.deepEqual(errors, []);
      await page.close();
    });
  }

  test('BR1.11 with the placeholder configuration the page says it is not configured', async () => {
    const { page, errors } = await open('/', { config: PLACEHOLDER_CONFIG });
    await page.locator('[data-message="config"]').waitFor({ state: 'visible' });
    assert.equal(await page.locator('#sign-in').isDisabled(), true);
    assert.deepEqual(await page.evaluate(() => window.__cspViolations), []);
    assert.deepEqual(errors, []);
    await page.close();
  });

  test('BR1.6 the delete button needs the confirmation word', async () => {
    const { page } = await open('/en/');
    // The signed-in part is hidden until sign-in; its logic is checked here.
    await page.evaluate(() => {
      document.querySelector('#signed-in').hidden = false;
    });
    const remove = page.locator('#delete');
    assert.equal(await remove.isDisabled(), true);
    await page.fill('#confirm-word', 'delet');
    assert.equal(await remove.isDisabled(), true);
    await page.fill('#confirm-word', ' delete ');
    assert.equal(await remove.isEnabled(), true);
    await page.close();
  });
});
