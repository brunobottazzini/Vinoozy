# Code Generation Plan — u7-sharing

Fonti:
- Functional Design di U7: `functional-spec.md`, `rules.md`, `frontend-components.md`;
- NFR Requirements: `security-`, `performance-requirements.md`, `tech-stack-decisions.md`;
- NFR Design: `logical-components.md`, `security-design.md`, `performance-design.md`;
- Infrastructure Design: `infrastructure-specification.md`, `monitoring-design.md`, `cicd-pipeline.md`;
- `contract-summary.md` (C3 con le aggiunte del 2026-11-06, C4), `unit-of-work.md`, `requirements.md` (FR8.1 con limite 2), `stories.md` (US8.1–US8.4).

U7 aggiunge la condivisione della cantina con al massimo **2 persone invitate**. Si compone di:
- le regole di sicurezza e l'indice di Firestore;
- il modulo `lib/sharing/`: dominio puro, repository, provider, schermate;
- l'integrazione con U1 e U5, che passano dalla cantina personale alla **cantina attiva**.

Storie: US8.1–US8.4.

Strati testabili:
- **modello dei dati:** dominio di `lib/sharing/` e campi nuovi di `Cellar`;
- **accesso ai dati:** regole cloud, `SharingRepository`, modifiche ai repository di U1, `SyncErrorBus`, `NetworkStatus`;
- **logica:** provider e gestione dell'accesso perso;
- **interfaccia:** schermate della condivisione, selettore, integrazione nelle schermate di U1 e U5.

## File dell'utente toccati da questo lavoro

- **Regole e indici:** `firestore.rules`, `firestore.indexes.json`.
- **Test delle regole:**
  - `test/rules/helpers.mjs`: `googleUser()` con `email_verified`, nuovo `unverifiedGoogleUser()`;
  - `test/rules/compat/compat.rules.test.mjs` e `app-writes.json`: campo `requiresRules`;
  - `package.json`: `test:rules` con `u7.rules.test.mjs`.
- **CI e workflow:** `.github/workflows/ci.yml` (job `rules` e `unit`), `.github/workflows/firebase-deploy.yml` (job `rules`), `.github/workflows/promote.yml` (controllo delle regole pubblicate).
- **Codice di U1:**
  - `lib/cellar/domain/cellar.dart`, `lib/cellar/data/cellar_repository.dart`, `lib/cellar/data/wine_repository.dart`;
  - `lib/cellar/ui/*`, `lib/sync/sync_error_bus.dart`, `lib/sync/ui/offline_banner.dart`;
  - `lib/account/network_status.dart`, `lib/account/account_gate.dart`;
  - `lib/app/providers.dart`, `lib/app/home_shell.dart`, `lib/app/bootstrap.dart`, se serve per il collegamento.
- **Codice di U5:** `lib/dashboard/dashboard_providers.dart`, `lib/dashboard/ui/dashboard_screen.dart`.
- **Traduzioni:** `lib/l10n/*.arb` (it, en, pt-BR).
- **Dipendenze:** `pubspec.yaml`, `pubspec.lock` (`share_plus`).
- **Test esistenti di U1 e U5:** dove cambiano le firme (`cellarId` al posto di `uid`, `onChanged` nei finti della rete, `FakeNetwork` in `test/u1/ui/sign_in_screen_test.dart` e simili).
- **Test end-to-end:** `integration_test/e2e_helpers.dart` (`ownerRestClient()`).
- **Documenti:** `docs/release-checklist.md` (§1-quater, §2, §3, §5), `docs/firebase-setup.md` (§7, avviso sulle letture).

## Steps

### Step 1 — Struttura e configurazione — [x]
- [x] Cartelle `lib/sharing/domain/`, `lib/sharing/data/`, `lib/sharing/ui/`, `test/sharing/`, `tool/fixtures/firestore_indexes/`.
- [x] `share_plus` (ultima versione stabile) in `pubspec.yaml`, poi `flutter pub get`.
- Traccia: `logical-components.md`; `tech-stack-decisions.md`.

### Step 2 — Runner dei test — [x]
- [x] `test/sharing/` con i finti condivisi in `test/sharing/sharing_harness.dart`: repository finto con `mocktail`, flussi finti, `ErrorSink` finto.
- [x] Comandi in `unit-test-instructions.md`: `flutter test test/sharing` e `npm run test:rules`.

### Step 3 — Modello dei dati: implementazione — [x]
- [x] `lib/sharing/domain/invite_validator.dart`:
  - normalizzazione dell'email (trim, minuscolo);
  - formato con al più 254 caratteri e senza `/`;
  - controllo di `selfInvite`, `alreadyInvited` e `limitReached` (limite 2).
- [x] `lib/sharing/domain/membership.dart`:
  - `Membership` con un mapper che non lancia mai;
  - `AccessibleCellar`;
  - `MemberStatus`, `MemberPermission`, `ClosedBy`;
  - `displayNameOrFallback(name, email)`, troncato a 100 caratteri.
- [x] `lib/sharing/domain/sharing_error.dart`: `invalidEmail`, `selfInvite`, `alreadyInvited`, `limitReached`, `notOwner`, `notFound`, `offline`, `timeout`, `failed`.
- [x] `lib/cellar/domain/cellar.dart`: `memberSlots` (0 se manca) e `memberOpKey?`, letti senza mai lanciare.
- Traccia: BR1.2, BR1.4, BR1.13; NFR4.9; C3, C4.

### Step 4 — Modello dei dati: test — [x]
- [x] `test/sharing/invite_validator_test.dart`, `membership_test.dart`, `display_name_test.dart`: un test per regola con l'ID nel nome (BR1.2), più valori al limite (254 e 255 caratteri, `/`, maiuscole, spazi) e mappe incomplete o con tipi sbagliati.
- [x] Il test esistente di `Cellar` aggiunge i campi nuovi.
- [x] Eseguire `flutter test test/sharing test/u1`.

### Step 5 — Accesso ai dati: implementazione — [x]
- [x] `firestore.rules` come in `security-design.md` §1:
  - funzioni comuni;
  - `get` della cantina per la persona invitata;
  - update del contatore legato a `memberOpKey`, tra 0 e 2;
  - blocco `members` con le 8 transizioni e `pairedOp`;
  - gruppo di collezioni;
  - `wines` con `canReadCellar`/`canEditCellar` ed eliminazione del proprietario;
  - `drinkingRecords` con `validDrinkingRecord`;
  - in testa al file, la tabella degli accessi in commento.
- [x] `firestore.indexes.json`: `fieldOverride` su `members.inviteeEmail`, `COLLECTION_GROUP`, ordine crescente.
- [x] `lib/sharing/data/sharing_repository.dart`:
  - le 7 operazioni (`invite`, `changePermission`, `revoke`, `leave`, `activate`, `deleteClosed`, `revokeAllForUser`);
  - un solo `WriteBatch` per operazione, con `memberSlots` e `memberOpKey`;
  - `commit().timeout(10 s)`;
  - controlli prima della scrittura e traduzione degli errori (`security-design.md` §4).
- [x] Modifiche a U1:
  - `CellarRepository.watchCellar(cellarId)`;
  - `WineRepository`: il `cellarId` arriva al gestore degli errori;
  - `SyncErrorBus`: `CellarAccessLost` e `reportWriteRejected`;
  - `NetworkStatus.onChanged` e `ConnectivityNetworkStatus`.
- Traccia: BR1.1, BR1.7–BR1.13; NFR4.1–NFR4.9, NFR5.2, NFR6.2, NFR8.2, NFR8.3.

### Step 6 — Accesso ai dati: test — [x]
- [x] `test/rules/u7.rules.test.mjs`:
  - matrice 6 ruoli × 9 operazioni generata da tabella;
  - ogni transizione consentita;
  - le transizioni vietate;
  - il contatore: +2, senza `members`, due inviti con un solo +1, terzo invito, `memberOpKey` di un altro invito;
  - i campi al limite;
  - `unverifiedGoogleUser()`;
  - il nome di ripiego;
  - `drinkingRecords`;
  - eliminazione del proprio documento `revoked`.
- [x] `test/rules/helpers.mjs` (`email_verified`, `unverifiedGoogleUser`), `compat/` (`requiresRules: "sharing"` sulle scritture nuove; la direzione 2 le salta e lo scrive nel log), `package.json` (`test:rules`).
- [x] `test/sharing/sharing_repository_test.dart` con `mocktail`: batch composto correttamente per ogni operazione, tempo scaduto, traduzione di ogni errore, nessuna email nel `ErrorSink`.
- [x] Test di U1 aggiornati: `watchCellar(cellarId)`, `reportWriteRejected` (cantina personale → nessun `CellarAccessLost`; condivisa → evento), `onChanged` nei finti della rete.
- [x] Eseguire `npm run test:rules`, che richiede Java per l'emulatore, e `flutter test test/sharing test/u1`.

### Step 7 — Logica: implementazione — [x]
- [x] `lib/sharing/sharing_providers.dart`:
  - `myMembershipsProvider` (query sul gruppo di collezioni filtrata solo su `inviteeEmail`; attivazione degli inviti `invited`; `CellarAccessLost` solo con `closedBy == owner` o documento sparito);
  - `accessibleCellarsProvider`;
  - `activeCellarProvider` (scelta in `shared_preferences` con la chiave `sharing.activeCellar.<uid>`, ritorno alla personale, `canEdit`, osservazione dei `permission-denied` degli ascolti con l'eccezione `leavingCellarIds`);
  - `cellarMembersProvider` (solo nella schermata "Persone", con `autoDispose`).
- [x] `lib/app/providers.dart`:
  - `cellarStreamProvider` e `syncStatusProvider` indicizzati per `cellarId`;
  - `reopenCellarListeners` e `invalidateFirestoreListeners` estesi ai provider della condivisione.
- [x] `lib/account/account_gate.dart`: `retryCellar` e reset (cancella `sharing.activeCellar.<uid>`).
- [x] Ascoltatore alla radice dell'app per `CellarAccessLost`: un solo avviso per cantina e per sessione.
- Traccia: BR1.4, BR1.5, BR1.8–BR1.10, BR1.14; NFR2.2–NFR2.4, NFR5.1, NFR6.1, NFR6.3, NFR6.4.

### Step 8 — Logica: test — [x]
- [x] `test/sharing/sharing_providers_test.dart`:
  - attivazione;
  - cantine accessibili;
  - cantina attiva ricordata e ritorno alla personale;
  - revoca con avviso;
  - uscita senza avviso;
  - `permission-denied` sulla cantina condivisa con avviso, e durante l'uscita senza avviso;
  - conteggio degli ascolti al cambio di cantina e all'apertura di "Persone";
  - reset.
- [x] Test di U1 e U5 aggiornati per `cellarId`.
- [x] Eseguire `flutter test`, cioè tutta la suite.

### Step 9 — Interfaccia: implementazione — [x]
- [x] `lib/sharing/ui/`:
  - `SharingScreen` (vista del proprietario e vista della persona invitata), `InviteForm` (x/2, rete), `MemberTile` (elenco principale e "Accessi chiusi"), `PermissionMenu`, `RevokeDialog`, `LeaveCellarDialog`, `CellarSwitcher`, `SharedCellarNotice`;
  - condivisione con `share_plus` e il messaggio pronto (BR1.3);
  - semantica come in `security-design.md` §3.
- [x] Integrazione:
  - `HomeShell`, `CellarScreen`, `AddWineScreen` e il Cruscotto usano `activeCellarProvider`;
  - i comandi seguono il permesso (BR1.6);
  - "Persone" nel menu della cantina;
  - `OfflineBanner(cellarId)`.
- [x] Chiavi di traduzione in it, en e pt-BR; `flutter gen-l10n`.
- Traccia: BR1.1–BR1.12; FR8.1–FR8.4; NFR3.1–NFR3.3.

### Step 10 — Interfaccia: test — [x]
- [x] `test/sharing/sharing_screen_test.dart`, `cellar_switcher_test.dart`, `dialogs_test.dart`, nelle tre lingue:
  - stati: proprietario, persona invitata, senza rete, operazione in corso, errore, limite raggiunto;
  - conferma della revoca con il nome;
  - uscita;
  - semantica;
  - guideline di contrasto e tocchi;
  - `textScaler` 2.0 senza overflow.
- [x] Test dei permessi nelle schermate di U1 e U5: `read` nasconde i comandi, `edit` nasconde solo l'eliminazione.
- [x] Test del manifest: nessun `READ_CONTACTS`.
- [x] Eseguire `flutter test`.

### Step 11 — Strumenti, CI e workflow — [x]
- [x] `tool/check_firestore_indexes.sh`, `tool/check_firestore_indexes_test.sh` e le cartelle di prova `ok.json` e `missing.json`.
- [x] `.github/workflows/ci.yml`:
  - job `rules`: `npm run test:rules` e i due script;
  - job `unit`: `tool/check_coverage.sh 80 coverage/lcov.info lib/sharing/`.
- [x] `.github/workflows/firebase-deploy.yml`, job `rules`: `npm run test:rules` e i due script.
- [x] `.github/workflows/promote.yml`: controllo che `firestore.rules` e `firestore.indexes.json` del commit `build-<versionCode>` coincidano con quelli dell'ultima pubblicazione riuscita su `firebase-prod`.
- [x] `integration_test/e2e_helpers.dart` (`ownerRestClient()`) e `integration_test/sharing_test.dart` (attese al massimo di 15 s).
- [x] Eseguire:
  - `dart format --output=none --set-exit-if-changed .` e `flutter analyze --fatal-infos`;
  - `npm run test:rules` e gli script;
  - `dart run tool/gen_coverage_helper.dart`, `flutter test --coverage`, la copertura di progetto e quella di `lib/sharing/`.

  I test end-to-end richiedono gli emulatori: si eseguono in Build and Test, oppure qui se sono disponibili.

### Step 12 — Documentazione e tracciabilità — [x]
- [x] `docs/release-checklist.md`: §1-quater Condivisione, §2 Data Safety, §3 ordine di pubblicazione, §5 controllo mensile.
- [x] `docs/firebase-setup.md` §7: avviso sulle letture, con la condizione principale e quella di riserva.
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
