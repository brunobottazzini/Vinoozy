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

// The store listing languages (wine-culture-languages FR4.1): every folder of
// distribution/google-play/languages.json, with its three texts within the
// Google Play limits, and one release-notes block per folder.
const RELEASE_NOTES_LIMIT = 500;

function storeFolders() {
  const file = 'distribution/google-play/languages.json';
  const text = read(file);
  if (!text) return [];
  let languages;
  try { languages = JSON.parse(text).languages; }
  catch (error) { problems.push(`${file}: invalid JSON (${error.message})`); return []; }
  if (!languages || typeof languages !== 'object' || Array.isArray(languages)) {
    problems.push(`${file}: "languages" must map each app language to a store folder`);
    return [];
  }
  const folders = Object.values(languages);
  const invalid = folders.filter((folder) => typeof folder !== 'string' || !/^[a-z]{2,3}(-[A-Z]{2})?$/.test(folder));
  for (const folder of invalid) problems.push(`${file}: invalid store folder ${JSON.stringify(folder)}`);
  const duplicated = folders.filter((folder, index) => folders.indexOf(folder) !== index);
  for (const folder of new Set(duplicated)) problems.push(`${file}: store folder ${folder} listed twice`);
  return folders.filter((folder) => !invalid.includes(folder));
}

function checkReleaseNotes(folders) {
  const file = 'distribution/google-play/release-notes.txt';
  const text = read(file);
  if (!text) return;
  const blocks = new Map();
  for (const [, tag, body] of text.matchAll(/<([A-Za-z-]+)>\n?([\s\S]*?)\n?<\/\1>/g)) {
    if (blocks.has(tag)) problems.push(`${file}: <${tag}> appears twice`);
    blocks.set(tag, body.trim());
  }
  for (const folder of folders) {
    const notes = blocks.get(folder);
    const count = notes === undefined ? 0 : [...notes].length;
    if (!count || count > RELEASE_NOTES_LIMIT) {
      problems.push(`${file}: <${folder}> ${count} characters (required 1–${RELEASE_NOTES_LIMIT})`);
    } else {
      console.log(`${folder} release-notes: ${count}/${RELEASE_NOTES_LIMIT}`);
    }
  }
  for (const tag of blocks.keys()) {
    if (!folders.includes(tag)) problems.push(`${file}: <${tag}> is not a folder of languages.json`);
  }
}

if (!webOnly) {
  const folders = storeFolders();
  for (const locale of folders) {
    for (const [name, limit] of [['title', 30], ['short-description', 80], ['full-description', 4000]]) {
      const file = `distribution/google-play/${locale}/${name}.txt`;
      const value = read(file).trim();
      const count = [...value].length;
      if (!count || count > limit) problems.push(`${file}: ${count} characters (required 1–${limit})`);
      else console.log(`${locale} ${name}: ${count}/${limit}`);
    }
  }
  checkReleaseNotes(folders);
}

const config = spawnSync(process.execPath, ['tool/check_web_config.mjs'], { cwd: root, encoding: 'utf8' });
if (config.status !== 0) pending.push(config.stderr.trim() || 'Public Firebase web configuration check failed');
for (const problem of problems) console.error(`ERROR: ${problem}`);
for (const item of pending) console.error(`PENDING: ${item}`);
if (problems.length || (!draft && pending.length)) process.exitCode = 1;
else if (pending.length) console.log('Draft structure OK; publication is BLOCKED by the pending items above.');
else console.log('Publication files OK. Complete the console, device, assets and policy checklist before release.');
