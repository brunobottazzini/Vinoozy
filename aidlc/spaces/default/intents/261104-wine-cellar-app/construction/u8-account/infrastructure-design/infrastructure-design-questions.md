# Infrastructure Design — u8-account — Domande

Contesto:
- design non funzionale di U8 approvato (`logical-components.md`, `security-design.md` con le correzioni del §7, `performance-design.md`);
- `functional-spec.md` di U8, `components.md`, `contract-summary.md`;
- infrastruttura esistente: `ci.yml` (job `format`, `analyze`, `unit`, `estimation`, `rules`, `e2e`), `release.yml`, `promote.yml` (con `RULES_FEATURES`), `firebase-deploy.yml`, `docs/release-checklist.md`.

Non ci sono domande aperte. Le decisioni sono riassunte qui sotto per conferma.

## Consolidated Summary Confirmation

- **Risorse:** nessuna nuova nel cloud a pagamento. Costo 0 €. Cambiano:
  - `firestore.rules`: cancellazione del profilo e della cantina solo durante la cancellazione dell'account, e `deletionStartedAt`;
  - la nuova pagina web su **GitHub Pages**, pubblicata dal ramo `gh-pages`;
  - nella console Firebase, azioni tue:
    - registrare l'app web;
    - aggiungere il dominio `github.io` ai domini autorizzati;
    - attivare App Check con reCAPTCHA v3 per il web e renderlo obbligatorio per Firestore.
- **Pubblicazione, in quest'ordine:**
  1. merge su `main` con tutti i controlli verdi;
  2. regole con `firebase-deploy.yml`, con la tua approvazione;
  3. pagina web con il nuovo workflow manuale `pages.yml`, che parte solo se le regole pubblicate sono quelle del commit;
  4. app con `promote.yml` (`RULES_FEATURES` = `sharing cellar account`).
  
  Le regole nuove sono compatibili con l'app attuale: aggiungono solo permessi di cancellazione.
- **Controlli automatici in `ci.yml`, nessun job nuovo:**
  - `analyze`: ID delle regole BR1.1–BR1.13; `tool/check_web_pins.sh` per la libreria della pagina copiata nel repository;
  - `unit`: copertura dell'80% su `lib/account/`;
  - `rules`: `test:rules` con `u8.rules.test.mjs`; nuovo `npm run test:web` con gli emulatori di Firestore e Auth;
  - `e2e`: `account_test.dart` (uscita con modifiche in coda; cancellazione completa).
- **Monitoraggio:**
  - nessun avviso nuovo;
  - gli errori `account_*` arrivano in Crashlytics senza dati personali;
  - nel controllo mensile si guardano anche questi e le richieste via email ricevute.
- **Checklist di rilascio:**
  - nuova sezione "Account":
    - presentazione;
    - uscita con modifiche in coda;
    - cancellazione completa su un account di prova con una cantina condivisa;
    - ripresa dopo aver chiuso l'app a metà;
    - pagina web dal browser;
  - impostazioni della console Firebase (domini, App Check obbligatorio);
  - scheda "Sicurezza dei dati" con l'URL della pagina di cancellazione;
  - informativa aggiornata;
  - procedura per le richieste via email.
- **Rollback:**
  - app: si ferma il rilascio graduale e si pubblica una correzione;
  - pagina: si ripubblica la versione precedente di `gh-pages` con `pages.yml`;
  - regole: prima della promozione si possono riportare indietro; dopo si corregge in avanti, come in U4.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
