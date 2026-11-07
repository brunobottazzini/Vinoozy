# Code Generation Plan — u8-account

## Summary

- Builds: presentazione al primo avvio, profilo, uscita con avviso sulle modifiche in coda, cancellazione dell'account dall'app con ripresa, regole del cloud per la cancellazione, pagina web di cancellazione con accesso Google su GitHub Pages.
- Touches: `lib/account/` (UI, deletion, gate, repository, auth), `lib/app/`, `firestore.rules`, `test/account/`, `test/rules/u8.rules.test.mjs`, `docs/account-deletion/`, `test/web/`, `package.json`, `tool/`, `.github/workflows/ci.yml`, `promote.yml`, nuovo `pages.yml`, `integration_test/`, `docs/release-checklist.md`.
- Tests: circa 120 test di Dart (logica, runner, gate, schermate nelle tre lingue), circa 30 asserzioni sulle regole, test della pagina web in Node e in Chromium headless, 1 file end-to-end con 2 scenari.

Fonti:
- Functional Design di U8: `functional-spec.md` (BR1.1–BR1.13, i chiarimenti delle due revisioni, la decisione sulla pagina web), `rules.md`, `frontend-components.md`;
- NFR Requirements: `performance-requirements.md`, `security-requirements.md`, `tech-stack-decisions.md`;
- NFR Design: `logical-components.md`, `security-design.md` (con il §7), `performance-design.md`;
- Infrastructure Design: `infrastructure-specification.md` (con le due correzioni), `monitoring-design.md`, `cicd-pipeline.md`;
- `contract-summary.md` (C3, C4), `unit-of-work.md`, `requirements.md`, `stories.md` (US1.2, US1.3).

Storie: US1.2, US1.3.

Strati testabili:
- **modello dei dati:** `DeletionPlan`, segnali locali, `AccountOperationError`;
- **accesso ai dati:** regole, `UserRepository`, `AuthService`, runner della cancellazione;
- **logica:** gate e provider;
- **interfaccia:** schermate dell'app e pagina web.

## File dell'utente toccati da questo lavoro

- **Regole:** `firestore.rules` (`users` delete e `deletionStartedAt`, `cellars` delete durante la cancellazione, tabella degli accessi).
- **Test delle regole e compatibilità:** `test/rules/u8.rules.test.mjs` nuovo; `test/rules/compat/app-writes.json` (versione `u8-account`); `package.json` (`test:rules`, nuovo `test:web`, devDependency `esbuild`, `c8`, `firebase`, `playwright` a versione fissata).
- **CI e workflow:** `.github/workflows/ci.yml` (`analyze`, `unit`, `rules`); `promote.yml` (`RULES_FEATURES: sharing cellar account`); nuovo `pages.yml`.
- **Strumenti:** nuovi `tool/check_web_pins.sh`, il suo test, `tool/fixtures/web_csp_allowed.txt`, `tool/build_web_bundle.sh`.
- **Codice di U1:** `lib/account/account_gate.dart`, `gate_state.dart`, `auth_service.dart`, `google_auth_service.dart`, `data/user_repository.dart`, `reset_coordinator.dart` (parametro `openCellar`); `lib/app/` (provider, menu verso il profilo, presentazione prima dell'accesso).
- **Codice di U6:** `TempLabelStore` usato dalla pulizia finale, senza modifiche se possibile.
- **Traduzioni:** `lib/l10n/*.arb`.
- **Test esistenti di U1:** dove cambia `AccountGate`.
- **Documenti:** `docs/release-checklist.md` (§1-septies Account, console Firebase, repository pubblico con controllo dei segreti, §2, §3, §5, procedura email), `docs/firebase-setup.md` (app web, domini, App Check web).

## Steps

### Step 1 — Struttura e configurazione — [x]
- [x] Cartelle `lib/account/deletion/`, `test/account/`, `docs/account-deletion/` (`index.html`, `en/`, `pt-BR/`), `test/web/`.
- [x] devDependency npm a versione fissata: `firebase` (stessa per bundle e test), `esbuild`, `c8`, `playwright`; `npm install` e `pubspec` invariato.
- Traccia: `tech-stack-decisions.md`; `infrastructure-specification.md`.

### Step 2 — Runner dei test — [x]
- [x] `test/account/account_harness.dart`: `AuthService`, `UserRepository`, Firestore, `LocalLedger`, `ResetCoordinator`, `ErrorSink`, rete e `shared_preferences` finti; orologio iniettato.
- [x] Script `test:web` (emulatori Firestore e Auth, `c8 --check-coverage --lines 80`) e comandi in `unit-test-instructions.md`.

### Step 3 — Modello dei dati: implementazione — [x]
- [x] `lib/account/deletion/deletion_plan.dart`: passi 0–7 come dati.
- [x] `lib/account/deletion/deletion_signal.dart`, `lib/account/onboarding_flag.dart`.
- [x] `lib/account/account_operation_error.dart`: motivo, passo, tipo dell'eccezione, `toString` senza messaggio.
- Traccia: BR1.1, BR1.7, BR1.8; NFR8.2.

### Step 4 — Modello dei dati: test — [x]
- [x] Un test per regola con l'ID nel nome; segnali scritti, letti, tolti; `AccountOperationError` senza marcatori.
- [x] Eseguire `flutter test test/account`.

### Step 5 — Accesso ai dati: implementazione — [x]
- [x] `firestore.rules` come in `security-design.md` §1 e §7.
- [x] `UserRepository`: `markDeletionStarted` (crea o aggiorna), `deleteProfile`.
- [x] `AuthService`: `reauthenticate` con controllo dell'uid, `deleteUser`.
- [x] `lib/account/deletion/account_deletion_runner.dart`:
  - passo 0 (fermo di `SyncWatcher` e ascolti, `waitForPendingWrites` 30 s, azzeramento del registro);
  - passo 2 (attivazione e uscita, cancellazione dei `members` propri chiusi);
  - passo 3 (revoca e cancellazione degli inviti);
  - passo 4 (letture dal server a pagine di 400, batch confermati);
  - passi 5–7;
  - ripetibilità e arresto al primo errore.
- [x] `ResetCoordinator.reset(uid, openCellar: false)`.
- Traccia: BR1.5–BR1.10, BR1.13; NFR4.1–NFR4.6, NFR6.1, NFR8.1, NFR8.3.

### Step 6 — Accesso ai dati: test — [x]
- [x] `test/rules/u8.rules.test.mjs`: casi di NFR4.1–NFR4.3 e sequenza completa (NFR4.4); `app-writes.json` e `package.json` aggiornati.
- [x] `test/account/`: runner con interruzione dopo ogni passo e ripresa; attesa scaduta; contatore sfasato; riautenticazione con altro account; nessun marcatore nei report.
- [x] Eseguire `npm run test:rules` e `flutter test test/account test/u1`.

### Step 7 — Logica: implementazione — [x]
- [x] `AccountGate`: controllo della cancellazione dopo `_admit` e prima di `ensureProfile`; stati `GateDeleting(step)` e `GateDeleted`; riautenticazione prima della ripresa; comportamento senza rete.
- [x] Provider dell'account e della presentazione; presentazione saltata con una sessione esistente.
- Traccia: BR1.1, BR1.8, BR1.13; NFR6.2.

### Step 8 — Logica: test — [x]
- [x] Gate: profilo assente senza segnale → apertura normale; segnale locale offline; `deletionStartedAt` su un altro telefono; `GateDeleted` dopo `deleteUser`.
- [x] Eseguire `flutter test`.

### Step 9 — Interfaccia: implementazione — [x]
- [x] `OnboardingScreen`, `ProfileScreen` con i dialoghi, `DeleteAccountScreen`, `DeletionProgressView`; voce di menu; semantica e chiavi di prova.
- [x] Traduzioni it, en, pt-BR; `flutter gen-l10n`.
- [x] Pagina web: tre `index.html` con CSP, `firebase-config.js`, `account-deletion.js` (`createAccountDeletion(sdk, db, auth)`), `tool/build_web_bundle.sh` che produce `app.bundle.js` riproducibile.
- Traccia: BR1.1–BR1.6, BR1.11; NFR3.x, NFR8.5.

### Step 10 — Interfaccia: test — [x]
- [x] Test dei widget nelle tre lingue, `textScaler` 2.0, guideline, avanzamento annunciato.
- [x] `test/web/`: sequenza completa, ripresa, altro account, `deleteUser` (Node, emulatori, `c8` ≥ 80%); prova del bundle in Chromium headless con Playwright (avvio, nessun errore CSP).
- [x] Eseguire `flutter test` e `npm run test:web`.

### Step 11 — Strumenti, CI e workflow — [x]
- [x] `tool/check_web_pins.sh` con il criterio esatto e il suo test; `tool/fixtures/web_csp_allowed.txt`.
- [x] `ci.yml`: `analyze` (ID delle regole, `check_web_pins`), `unit` (copertura di `lib/account/`), `rules` (`test:web` con l'emulatore di Auth e Chromium).
- [x] `promote.yml`: `RULES_FEATURES: sharing cellar account`.
- [x] `pages.yml`: manuale, `contents: write` e `actions: read`, ambiente `github-pages-publish`, `mode: publish | rollback`, controllo delle regole come `promote.yml`, creazione di `gh-pages` alla prima pubblicazione.
- [x] `integration_test/account_test.dart`: uscita con modifiche in coda; cancellazione completa con una cantina condivisa e verifica del cloud.
- [x] Eseguire: formattazione, analisi, `npm run test:rules`, `npm run test:web`, script, copertura del progetto e di `lib/account/`.
  
  Gli end-to-end richiedono gli emulatori Android: si eseguono in Build and Test, oppure qui se disponibili.

### Step 12 — Documentazione e tracciabilità — [x]
- [x] `docs/release-checklist.md` e `docs/firebase-setup.md` come in `monitoring-design.md` §5 e nelle correzioni dell'infrastruttura (repository pubblico dopo il controllo dei segreti, reCAPTCHA, App Check al 99% per 7 giorni, procedura email con l'indirizzo `bottazzinibruno@gmail.com`).
- [x] `code-summary.md`, `source-manifest.json`, `traceability.json`.

## Testing Contract

```json
{
  "version": 1,
  "methodology": "test-after",
  "source": "team",
  "ordering": "Per ogni strato testabile (dominio, dati e sincronizzazione, interfaccia) implementiamo prima il codice, poi scriviamo ed eseguiamo i test di quello strato, e passiamo allo strato successivo solo con quei test verdi.",
  "scope": "mvp",
  "test_strategy": "standard",
  "project_type": "greenfield",
  "applicable_notes": [
    {
      "layer": "org",
      "text": "We treat tests as a first-class deliverable in every Bolt. The specific\nmethodology (TDD, BDD, ATDD, or classic test-after) is affirmed at\npractices-discovery and recorded in `team.md` under this heading with explicit\n`Methodology` and `Ordering` fields; Code Generation resolves those fields\nindependently from coverage, tooling, and scope notes.\n\nWhen no posture has been affirmed, our default per scope is:\n- **Methodology**: test-after\n- **Ordering**: implement each applicable testable layer, then write and run\n  that layer's tests.\n- `mvp`, `enterprise`, `feature`, `infra`, `classic` add an 80% line-coverage\n  floor and CI execution before merge.\n- `bugfix`, `security-patch` add a targeted regression for the specific\n  bug/vulnerability and require the existing suite to remain green.\n- `express` uses the Minimal strategy: requirement-driven unit tests (one per\n  requirement, with a happy-path floor per component); existing tests remain\n  green.\n- `poc`, `refactor`, `workshop` add no extra new-test floor and require the\n  existing suite to remain green.\n\nThe active `Test Strategy` still applies in every scope and determines test\nvolume/types. Scope floors are additive; they never reduce or replace the\nselected strategy.\n\nBuild and Test verifies defined coverage floors and affirmed quality targets;\nthey may not be weakened to make a step pass.\n\nAffirm a stricter posture in `team.md` if the team commits to one."
    },
    {
      "layer": "team",
      "text": "- **Methodology**: test-after\n- **Methodology evidence**: scelta in Q5 (\"Dopo il codice, strato per strato\"); coincide con il default di `org.md`.\n- **Ordering**: Per ogni strato testabile (dominio, dati e sincronizzazione, interfaccia) implementiamo prima il codice, poi scriviamo ed eseguiamo i test di quello strato, e passiamo allo strato successivo solo con quei test verdi.\n- **Copertura**: almeno l'**80% delle righe**, calcolato su tutto il codice **senza esclusioni**, compresi codice generato e file di traduzione (Q6). La soglia viene verificata in GitHub Actions e se non è raggiunta il merge in `main` è bloccato.\n- **Strumenti**: `flutter test` con `--coverage` per unit test e test dei widget. Unit test sulla logica (in particolare la stima del momento ideale e l'indice di fiducia), test dei widget per le schermate principali nelle tre lingue dell'interfaccia (it, en, pt-BR).\n- **Integrazione con Firebase**: i test di integrazione girano sulla **Firebase Emulator Suite**, in locale e in GitHub Actions, così non usano il progetto di produzione e non costano nulla (Q9).\n- **End-to-end**: i test che simulano l'uso reale dell'app girano in GitHub Actions su un **emulatore Android** (es. `integration_test` di Flutter), collegato alla Firebase Emulator Suite (Q7). Se falliscono, il merge è bloccato.\n- **Gate prima del merge**: formattazione, analisi statica, test, copertura ed end-to-end devono passare tutti. Un controllo rosso non si aggira e la soglia non si abbassa per far passare un blocco."
    }
  ],
  "obligations": {
    "strategy": "standard",
    "strategy_volume": [
      "Five to eight tests per component.",
      "Unit tests plus integration tests for key boundaries.",
      "Add E2E, performance, or security tests when requirements demand them."
    ],
    "scope_floor": [
      "Meet an 80% line-coverage floor.",
      "Run the selected tests in CI before merge."
    ],
    "combination_rule": "Apply every selected-strategy obligation and every scope-floor obligation; neither replaces the other, and a targeted scope regression may add the narrowest necessary test type beyond the strategy default."
  },
  "plan_profile": {
    "methodology": "test-after",
    "runner_step": "Bootstrap the minimal test runner/configuration and record the exact unit-scoped command.",
    "runner_ready_before_first_test": true,
    "testable_layers": [
      "Data model / database behavior",
      "Repository / data access",
      "Business logic",
      "API / endpoint",
      "Frontend behavior"
    ],
    "steps": [
      "Project structure and production configuration skeleton.",
      "Bootstrap the minimal test runner/configuration and record the exact unit-scoped command.",
      "Data model / database behavior - implement.",
      "Data model / database behavior - write and run its tests after implementation.",
      "Repository / data access - implement.",
      "Repository / data access - write and run its tests after implementation.",
      "Business logic - implement.",
      "Business logic - write and run its tests after implementation.",
      "API / endpoint - implement.",
      "API / endpoint - write and run its tests after implementation.",
      "Frontend behavior - implement.",
      "Frontend behavior - write and run its tests after implementation.",
      "Environment/build configuration.",
      "Documentation and traceability."
    ]
  },
  "input_sha256": "sha256:3f9fa92fb9ad83e0ec0f1af50617f2c04e8d7a08cfdcc021d34045ebd5ab2b38",
  "contract_sha256": "sha256:247ca09a44e4e91e3493fea6cc62706b293bbb1a745bc0c2c27a073498900f19"
}
```
