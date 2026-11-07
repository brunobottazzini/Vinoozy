# Infrastructure Specification — u8-account

Fonti:
- `logical-components.md`, `security-design.md` (con il §7) e `performance-design.md` di U8;
- `components.md` (inception), `functional-spec.md` di U8, `contract-summary.md` (C3, C4);
- `ci.yml`, `release.yml`, `promote.yml`, `firebase-deploy.yml`, `docs/release-checklist.md`;
- riepilogo confermato in `infrastructure-design-questions.md`.

Per un'unità di interfaccia il design non funzionale non ha file separati `scalability-design.md`, `reliability-design.md` e `observability-design.md`:
- la scala è quella di `performance-design.md`;
- l'affidabilità è in `security-design.md` §6;
- l'osservabilità è descritta in `monitoring-design.md`.

## 1. Deployment

| Aspetto | Scelta | Motivo |
|---|---|---|
| Calcolo | Tutto sul client: app Android e pagina web nel browser | Budget 0 €, nessuna funzione nel cloud |
| Rete | App e pagina parlano con Firebase Auth e Firestore tramite gli SDK, con App Check obbligatorio | Stesse regole per entrambi |
| Archiviazione | Firestore (nessun dato nuovo oltre a `deletionStartedAt`); `shared_preferences` sul telefono | Segnali locali |
| Ambienti | Emulatori di Firestore e Auth in CI; progetto `vinoozy-d6f45` in produzione; GitHub Pages dal ramo `gh-pages` | — |
| Configurazione | `firestore.rules`; `docs/account-deletion/` con `firebase-config.js` (valori web pubblici) e `app.bundle.js` | Nessun segreto |

## 2. Risorse

| Risorsa | Ruolo | Configurazione | Note |
|---|---|---|---|
| `firestore.rules` | Regole | `users` delete e `deletionStartedAt`; `cellars` delete durante la cancellazione (`security-design.md` §7) | Compatibile con l'app attuale |
| GitHub Pages (ramo `gh-pages`) | Pagina web di cancellazione | Pubblicata da `pages.yml` | Gratuita |
| Firebase Auth, app web | Accesso Google dalla pagina | App web registrata; dominio `<utente>.github.io` autorizzato | Azione del proprietario |
| App Check | Protezione | reCAPTCHA v3 per il web, Play Integrity per Android (già attivo); applicazione obbligatoria su Firestore | Azione del proprietario; verificare prima che l'app Android in produzione abbia già App Check, altrimenti l'obbligo la bloccherebbe |
| Workflow | CI e pubblicazione | Passi in `ci.yml`; nuovo `pages.yml`; `promote.yml` con `RULES_FEATURES: sharing cellar account` | `cicd-pipeline.md` |
| Segreti | — | Nessuno nuovo | La configurazione web di Firebase non è un segreto |

## 3. Costi

| Voce | Costo |
|---|---|
| Cancellazione (uso previsto ≈ 200 bottiglie) | Qualche centinaio di letture e scritture, nella quota gratuita |
| GitHub Pages | 0 € |
| reCAPTCHA v3 | 0 € nei limiti gratuiti |
| **Totale** | **0 €/mese** |

## 4. Pubblicazione

1. Merge su `main` con tutti i controlli verdi.
2. Regole con `firebase-deploy.yml` e approvazione di `firebase-prod`.
3. Console Firebase (una volta): app web, dominio autorizzato, App Check per il web; obbligo di App Check su Firestore solo dopo aver verificato le richieste valide nelle metriche di App Check.
4. Pagina con `pages.yml`, che si ferma se le regole pubblicate non sono quelle del commit.
5. App con `promote.yml`.
6. Scheda "Sicurezza dei dati" di Google Play con l'URL della pagina.

## 5. Sicurezza

- Nessun permesso Android nuovo, nessun segreto nuovo.
- La libreria Firebase della pagina è nel bundle `app.bundle.js` (vedi "Correzioni dopo la revisione"). Le origini esterne ammesse a runtime sono solo quelle elencate nella seconda correzione.
- La cancellazione è permessa solo all'utente stesso, solo dopo `deletionStartedAt`, e solo con riautenticazione.

## 6. Rollback

| Cosa | Come | Effetto |
|---|---|---|
| App | Fermare il rilascio graduale e pubblicare una correzione | Come per le altre unità |
| Pagina | `pages.yml` con `mode: rollback` | La pagina torna alla versione precedente |
| Regole, prima della promozione | `firebase-deploy.yml` con il tag precedente | La cancellazione non è disponibile, nessun dato toccato |
| Regole, dopo la promozione | Correzione in avanti | Come in U4 |
| App Check obbligatorio | Si toglie l'obbligo dalla console | Torna il comportamento precedente |

## Correzioni dopo la revisione (2026-11-06)

Dove differiscono, questi punti sostituiscono quanto scritto sopra e in `security-design.md` §7.

- **Libreria Firebase della pagina, in un solo file (correzione del problema grave).** I file del pacchetto npm `firebase` importano altri moduli, da gstatic o con nomi di pacchetto, quindi copiarli non basta.
  - `esbuild`, devDependency a versione fissata, impacchetta `account-deletion.js` e i moduli Firebase usati in **un solo file autonomo**, `docs/account-deletion/app.bundle.js`, senza import esterni. Il pacchetto `firebase` è alla stessa versione di `package.json` usata dai test.
  - Il file generato sta nel repository. `tool/check_web_pins.sh` lo ricostruisce con `npm ci` e `esbuild`, lo confronta byte per byte con quello presente (build riproducibile, senza mappe e con data fissa), e controlla che né il bundle né l'HTML contengano `import` o `src` verso `http`.
  - La cartella `vendor/` non esiste più.
- **Copertura del JavaScript della pagina (team.md, 80% senza esclusioni).** `npm run test:web` gira con `c8` e una soglia dell'80% delle righe su `docs/account-deletion/account-deletion.js`; sotto soglia il job `rules` fallisce. Il bundle generato non si misura: contiene solo codice di terze parti più il modulo già misurato.
- **`pages.yml`:**
  - permessi dichiarati: `contents: write`, nient'altro;
  - ambiente GitHub `github-pages-publish` con l'**approvazione del proprietario**, come `firebase-prod`;
  - input `mode`, con due valori:
    - `publish`: controllo delle regole come `promote.yml`, poi pubblicazione;
    - `rollback`: ripubblica il commit precedente del ramo `gh-pages` (`git revert` dell'ultimo commit di pubblicazione) senza controllo delle regole, perché torna a una pagina già compatibile con regole pubblicate in passato.
- **GitHub Pages e repository (scelta del proprietario 2026-11-06: GitHub Pages).** GitHub Pages nel piano gratuito richiede che il repository `brunobottazzini/Vinoozy` sia **pubblico**. È un'azione del proprietario, nella checklist, da fare prima della prima pubblicazione della pagina.
  - Prima di rendere pubblico il repository, la checklist chiede di verificare che non contenga segreti: `config/firebase_prod.json` e `google-services.json` sono in `.gitignore` e mai committati, e la cronologia git si controlla con uno strumento di ricerca dei segreti (per esempio `gitleaks`).
  - L'URL della pagina sarà `https://brunobottazzini.github.io/Vinoozy/account-deletion/`.
- **reCAPTCHA:** il dominio `brunobottazzini.github.io` va registrato anche tra i domini della chiave reCAPTCHA v3, oltre che tra i domini autorizzati di Firebase Auth. Entrambi sono nella checklist.
- **App Check:**
  - è già attivo nell'app Android (`lib/app/bootstrap.dart`) e in tutte le versioni pubblicate;
  - l'obbligo su Firestore segue il criterio già scritto in `docs/firebase-setup.md` §2: si attiva solo quando le richieste verificate sono almeno il **99% per 7 giorni consecutivi**, contando insieme Android e web;
  - finché non è così, Firestore resta in modalità di controllo.

## Seconda correzione dopo la revisione (2026-11-06)

- **Origini esterne ammesse a runtime.** Il nostro codice e la libreria Firebase stanno nel bundle. Il browser carica però alcune risorse di Google che non si possono impacchettare:
  - `https://www.google.com/recaptcha/` e `https://www.gstatic.com/recaptcha/` (reCAPTCHA v3 di App Check);
  - `https://apis.google.com` e `https://accounts.google.com` (accesso Google);
  - `https://vinoozy-d6f45.firebaseapp.com` (pagina di ritorno dell'accesso di Firebase Auth);
  - gli endpoint delle API: `https://firestore.googleapis.com`, `https://identitytoolkit.googleapis.com`, `https://securetoken.googleapis.com`, `https://firebaseappcheck.googleapis.com`, `https://content-firebaseappcheck.googleapis.com`.
  
  Nessun'altra origine.
- **Content Security Policy** in un `<meta http-equiv="Content-Security-Policy">` in ogni pagina (GitHub Pages non permette intestazioni proprie):
  - `default-src 'self'`;
  - `script-src 'self'` più le origini di reCAPTCHA e `apis.google.com`;
  - `frame-src` per reCAPTCHA, `accounts.google.com` e `firebaseapp.com`;
  - `connect-src` per gli endpoint delle API;
  - `img-src 'self' data:`;
  - `object-src 'none'`;
  - `base-uri 'none'`.
  
  Nessun `unsafe-inline` né `unsafe-eval`.
- **Criterio esatto di `tool/check_web_pins.sh`:**
  1. il bundle ricostruito è identico a quello nel repository;
  2. nell'HTML ogni `<script>` ha `src` relativo (`./app.bundle.js`), e non ci sono script in linea;
  3. il bundle non contiene `import(` o `import ` verso URL `http`;
  4. la CSP di ogni pagina contiene esattamente l'elenco di origini sopra, confrontato con un file di riferimento `tool/fixtures/web_csp_allowed.txt`.
- **Prova del bundle in un browser.** `npm run test:web` aggiunge un controllo con Playwright e Chromium headless: apre la pagina servita in locale, collegata agli emulatori, e verifica che il bundle parta, che la CSP non blocchi nulla delle origini ammesse (nessun errore CSP in console) e che il pulsante di accesso compaia. L'accesso vero non si prova nel browser, perché lo copre il test Node.
- **`pages.yml`:**
  - permessi `contents: write` e `actions: read`, quest'ultimo per leggere le esecuzioni di `firebase-deploy.yml` come fa `promote.yml`;
  - la prima pubblicazione crea il ramo `gh-pages` se manca;
  - `mode: rollback` con un solo commit di pubblicazione si ferma con "Non c'è una versione precedente da ripristinare".
- **Testo superato:** le righe su `vendor/` e sul rollback con "commit precedente" sono sostituite da questa sezione e dalla precedente.

