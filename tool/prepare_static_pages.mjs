// Export the public privacy notice and email-based deletion request pages.
// This export has no Firebase client, sign-in form or credentials. The
// automatic deletion application is published separately by pages.yml once
// its Firebase/App Check configuration and real deletion test are complete.
import { readFileSync, writeFileSync, mkdirSync, rmSync, existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const output = resolve(root, 'build/publication-web/static');
const email = 'bottazzinibruno@gmail.com';
const locales = [
  {
    suffix: '', lang: 'it', title: 'Vinoozy — Richiedi la cancellazione dell’account',
    nav: '<a href="./en/" lang="en">English</a> <a href="./pt-BR/" lang="pt-BR">Português (Brasil)</a>',
    intro: 'Puoi richiedere la cancellazione del tuo account Vinoozy e dei dati associati anche senza avere l’app installata.',
    heading: 'Invia la richiesta via email',
    instructions: 'Scrivi dall’indirizzo Google usato per Vinoozy, oppure indica l’indirizzo dell’account interessato. Chiedi esplicitamente la cancellazione dell’account Vinoozy e dei suoi dati. Non inviare password o documenti di identità non richiesti. Prima di procedere verificheremo che la richiesta provenga dal titolare dell’account.',
    subject: 'Richiesta cancellazione account Vinoozy', button: 'Richiedi la cancellazione via email',
    timing: 'Rispondiamo normalmente entro un mese dal ricevimento della richiesta e comunichiamo eventuali estensioni previste dalla legge. La richiesta non cancella il tuo account Google.',
    whatHeading: 'Quali dati vengono cancellati',
    what: 'La cancellazione rimuove il profilo Vinoozy, la cantina personale con i vini e lo Storico, gli inviti e gli accessi associati all’account. Le persone con cui avevi condiviso la tua cantina ne perderanno l’accesso.',
    retainedHeading: 'Dati che possono rimanere',
    retained: 'Registrazioni e note inserite nelle cantine di altre persone possono rimanere con identificativi tecnici persistenti: non sono necessariamente anonime. Puoi chiederne la rimozione nella stessa email. Le copie esportate da altri utenti restano sotto il loro controllo. I dati diagnostici e le copie tecniche dei fornitori seguono i tempi descritti nell’informativa privacy.',
    appHeading: 'Cancellazione dall’app',
    app: 'Se hai l’app installata, puoi avviare la procedura da Profilo → Cancella account. La richiesta via email è disponibile anche senza reinstallare l’app.',
    privacy: 'Informativa privacy completa',
  },
  {
    suffix: 'en/', lang: 'en', title: 'Vinoozy — Request account deletion',
    nav: '<a href="../" lang="it">Italiano</a> <a href="../pt-BR/" lang="pt-BR">Português (Brasil)</a>',
    intro: 'You can request deletion of your Vinoozy account and associated data without having the app installed.',
    heading: 'Send a deletion request by email',
    instructions: 'Write from the Google email address you use for Vinoozy, or identify the email address of the account concerned. Explicitly request deletion of your Vinoozy account and its data. Do not send passwords or unsolicited identity documents. We will verify that the request comes from the account owner before proceeding.',
    subject: 'Vinoozy account deletion request', button: 'Request deletion by email',
    timing: 'We normally respond within one month of receiving the request and explain any lawful extension. This request does not delete your Google account.',
    whatHeading: 'Data that will be deleted',
    what: 'Deletion removes your Vinoozy profile, personal cellar with its wines and History, and invitations and access records associated with your account. People you shared your own cellar with will lose access to it.',
    retainedHeading: 'Data that may remain',
    retained: 'Records and notes you entered in other people’s cellars may remain with persistent technical identifiers; they are not necessarily anonymous. You can request their removal in the same email. Copies exported by other users remain under their control. Provider diagnostic data and technical copies follow the retention periods described in the privacy notice.',
    appHeading: 'Deletion from the app',
    app: 'If you have the app installed, you can start deletion under Profile → Delete account. The email request is also available without reinstalling the app.',
    privacy: 'Full privacy notice',
  },
  {
    suffix: 'pt-BR/', lang: 'pt-BR', title: 'Vinoozy — Solicite a exclusão da conta',
    nav: '<a href="../" lang="it">Italiano</a> <a href="../en/" lang="en">English</a>',
    intro: 'Você pode solicitar a exclusão da sua conta Vinoozy e dos dados associados mesmo sem ter o aplicativo instalado.',
    heading: 'Envie a solicitação por e-mail',
    instructions: 'Escreva pelo endereço Google usado no Vinoozy ou informe o e-mail da conta em questão. Solicite explicitamente a exclusão da conta Vinoozy e dos seus dados. Não envie senhas ou documentos de identidade não solicitados. Antes de prosseguir, verificaremos se a solicitação foi feita pelo titular da conta.',
    subject: 'Solicitação de exclusão da conta Vinoozy', button: 'Solicitar exclusão por e-mail',
    timing: 'Normalmente respondemos em até um mês do recebimento e informamos eventuais prorrogações previstas em lei. A solicitação não exclui sua conta Google.',
    whatHeading: 'Quais dados serão excluídos',
    what: 'A exclusão remove seu perfil Vinoozy, a adega pessoal com os vinhos e o Histórico, além dos convites e acessos vinculados à conta. As pessoas com quem você compartilhou sua própria adega perderão o acesso a ela.',
    retainedHeading: 'Dados que podem permanecer',
    retained: 'Registros e notas inseridos nas adegas de outras pessoas podem permanecer com identificadores técnicos persistentes; não são necessariamente anônimos. Você pode solicitar sua remoção no mesmo e-mail. Cópias exportadas por outros usuários continuam sob o controle deles. Dados de diagnóstico e cópias técnicas dos fornecedores seguem os prazos descritos na política de privacidade.',
    appHeading: 'Exclusão pelo aplicativo',
    app: 'Com o aplicativo instalado, você pode iniciar a exclusão em Perfil → Excluir conta. A solicitação por e-mail também está disponível sem reinstalar o aplicativo.',
    privacy: 'Política de privacidade completa',
  },
];
const escape = value => value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
const files = [];
const save = (path, content) => {
  const target = resolve(output, path);
  mkdirSync(dirname(target), { recursive: true });
  writeFileSync(target, content);
  files.push({ path, sha256: createHash('sha256').update(content).digest('hex') });
};
rmSync(output, { recursive: true, force: true });
save('.nojekyll', '');
save('account-deletion/style.css', readFileSync(resolve(root, 'docs/account-deletion/style.css'), 'utf8'));
for (const locale of locales) {
  const prefix = locale.suffix ? '../../' : '../';
  const css = locale.suffix ? '../style.css' : './style.css';
  const request = `mailto:${email}?subject=${encodeURIComponent(locale.subject)}`;
  save(`account-deletion/${locale.suffix}index.html`, `<!doctype html>
<html lang="${locale.lang}">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'self'; img-src 'self'; object-src 'none'; base-uri 'none'">
<title>${escape(locale.title)}</title><link rel="stylesheet" href="${css}"></head>
<body><main>
<nav aria-label="Language">${locale.nav}</nav>
<h1>${escape(locale.title)}</h1><p>${escape(locale.intro)}</p>
<section><h2>${escape(locale.heading)}</h2><p>${escape(locale.instructions)}</p>
<p><a href="${request}">${escape(locale.button)}</a>: <a href="mailto:${email}">${email}</a></p>
<p>${escape(locale.timing)}</p></section>
<section><h2>${escape(locale.whatHeading)}</h2><p>${escape(locale.what)}</p></section>
<section><h2>${escape(locale.retainedHeading)}</h2><p>${escape(locale.retained)}</p></section>
<section><h2>${escape(locale.appHeading)}</h2><p>${escape(locale.app)}</p></section>
<p><a href="${prefix}privacy/${locale.suffix}">${escape(locale.privacy)}</a></p>
</main></body></html>
`);
  save(`privacy/${locale.suffix}index.html`, readFileSync(resolve(root, `docs/privacy/${locale.suffix}index.html`), 'utf8'));
}
save('index.html', '<!doctype html><html lang="it"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Vinoozy</title></head><body><main><h1>Vinoozy</h1><p><a href="./privacy/">Informativa privacy</a></p><p><a href="./account-deletion/">Richiedi la cancellazione dell’account</a></p></main></body></html>\n');

// Fail before publishing if any page is incomplete, scripted or has broken
// local navigation. Do not reuse the full Firebase web-app readiness check:
// no Firebase SDK or automatic deletion UI is included in this export.
for (const entry of files.filter(file => file.path.endsWith('.html'))) {
  const fullPath = resolve(output, entry.path);
  const html = readFileSync(fullPath, 'utf8');
  if (/\bTODO\b|Nota editoriale|\[[A-Z][A-Z _]+\]|<script\b|\son\w+=/i.test(html)) throw new Error(`${entry.path}: unfinished or scripted page`);
  for (const [, href] of html.matchAll(/(?:href|src)="([^"]+)"/g)) {
    if (/^(https?:|mailto:|#)/.test(href)) continue;
    const target = resolve(dirname(fullPath), href, href.endsWith('/') ? 'index.html' : '');
    if (!target.startsWith(output + '/') || !existsSync(target)) throw new Error(`${entry.path}: invalid local link ${href}`);
  }
}
writeFileSync(resolve(output, '../static-manifest.json'), JSON.stringify({ deletion_request: 'email', files }, null, 2) + '\n');
console.log(`Static publication export checked: ${files.length} files, 3 privacy pages, 3 email deletion request pages.`);
console.log(output);
