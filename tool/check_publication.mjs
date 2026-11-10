// Local preparation checks. A pass does not certify Play/Firebase console
// configuration, legal decisions, device smoke tests or store assets.
// --draft permits unfinished public configuration, for ordinary CI only.
// --web-only checks the material pages.yml actually publishes.
import { readFileSync, existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const draft = process.argv.includes('--draft');
const webOnly = process.argv.includes('--web-only');
const problems = [];
const pending = [];
const read = (file) => {
  try { return readFileSync(resolve(root, file), 'utf8'); }
  catch { problems.push(`${file}: missing`); return ''; }
};

for (const [suffix, lang] of [['', 'it'], ['en/', 'en'], ['pt-BR/', 'pt-BR']]) {
  const file = `docs/privacy/${suffix}index.html`;
  const html = read(file);
  if (!html.includes(`<html lang="${lang}">`)) problems.push(`${file}: wrong language`);
  if (/\[[A-Z][A-Z _]+\]|\bTODO\b/.test(html)) pending.push(`${file}: complete the remaining placeholders`);
  if (!html.includes('bottazzinibruno@gmail.com')) problems.push(`${file}: missing privacy contact`);
  if (/<script\b|\son\w+=/i.test(html)) problems.push(`${file}: the privacy notice must work without scripts`);
  if (!html.includes('/account-deletion/')) problems.push(`${file}: missing account deletion link`);
  for (const [, href] of html.matchAll(/(?:href|src)="([^"]+)"/g)) {
    if (/^(?:https?:|mailto:|#)/.test(href)) continue;
    const target = resolve(dirname(resolve(root, file)), href, href.endsWith('/') ? 'index.html' : '');
    if (!existsSync(target)) problems.push(`${file}: broken local link ${href}`);
  }
  const deletion = read(`docs/account-deletion/${suffix}index.html`);
  if (!deletion.includes('privacy/')) problems.push(`account-deletion/${suffix}: missing full privacy notice link`);
  if (/Nessun altro dato|No other data|Nenhum outro dado|codice tecnico casuale|random technical code|código técnico aleatório/i.test(deletion)) {
    problems.push(`account-deletion/${suffix}: misleading retention promise`);
  }
}

if (!webOnly) {
  for (const locale of ['it-IT', 'en-US', 'pt-BR']) {
    for (const [name, limit] of [['title', 30], ['short-description', 80], ['full-description', 4000]]) {
      const file = `distribution/google-play/${locale}/${name}.txt`;
      const value = read(file).trim();
      const count = [...value].length;
      if (!count || count > limit) problems.push(`${file}: ${count} characters (required 1–${limit})`);
      else console.log(`${locale} ${name}: ${count}/${limit}`);
    }
  }
}

const config = spawnSync(process.execPath, ['tool/check_web_config.mjs'], { cwd: root, encoding: 'utf8' });
if (config.status !== 0) pending.push(config.stderr.trim() || 'Public Firebase web configuration check failed');
for (const problem of problems) console.error(`ERROR: ${problem}`);
for (const item of pending) console.error(`PENDING: ${item}`);
if (problems.length || (!draft && pending.length)) process.exitCode = 1;
else if (pending.length) console.log('Draft structure OK; publication is BLOCKED by the pending items above.');
else console.log('Publication files OK. Complete the console, device, assets and policy checklist before release.');
