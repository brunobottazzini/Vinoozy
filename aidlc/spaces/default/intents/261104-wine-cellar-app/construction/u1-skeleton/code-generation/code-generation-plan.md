# Code Generation Plan — u1-skeleton

## Summary

- Builds: lo scheletro funzionante dell'app Flutter Android: accesso Google, cantina personale, aggiunta di un vino scritto, uso offline con sincronizzazione, regole di sicurezza Firestore e pipeline GitHub Actions.
- Touches: `pubspec.yaml`, `lib/`, `android/`, `test/`, `integration_test/`, `firestore.rules`, `firebase.json`, `.github/workflows/`, `tool/`, `docs/`; aggiunge righe Flutter/Firebase a `.gitignore`.
- Tests: circa 75 test: unit test e test dei widget (5–8 per componente), circa 25 test delle regole Firestore sull'emulatore, 8 test end-to-end su emulatore Android, più la prova di riavvio di Firestore.

Fonti: `functional-spec.md`, `rules.md`, `frontend-components.md` (Functional Design); `security-requirements.md`, `performance-requirements.md`, `tech-stack-decisions.md` (NFR Requirements); `security-design.md`, `performance-design.md`, `logical-components.md` (NFR Design); `infrastructure-specification.md`, `cicd-pipeline.md`, `monitoring-design.md` (Infrastructure Design); `contract-summary.md` (C3); `unit-of-work.md` (U1); `requirements.md`; `mockups.md`, `design-system-mapping.md` (Refined Mockups).

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

## Prerequisiti sul computer

- Flutter stabile (versione fissata in `.flutter-version` allo Step 1), Android SDK con un emulatore API 34, JDK 17.
- Node LTS (fissato in `.nvmrc`), per `firebase-tools` e i test delle regole. Entrambi sono dipendenze di sviluppo in `package.json`, senza installazioni globali.
- Nessun account Firebase o Google Play per costruire e testare lo scheletro: tutto gira sugli emulatori con il progetto `demo-vinoozy`. La configurazione di produzione (checklist `docs/firebase-setup.md`) serve solo per `release.yml`.

## Strato "API / endpoint"

U1 non ha API proprie: il confine verso il cloud sono le **regole di sicurezza Firestore**. Nel profilo del Testing Contract, lo strato "API / endpoint" corrisponde quindi a `firestore.rules` e ai suoi test sull'emulatore (Step 10–11).

## Punti aperti delle revisioni, risolti in questo piano

| Origine | Punto | Step |
|---------|-------|------|
| NFR Design, revisione 2 | Indicatore offline: segue subito `isFromCache`, ignorando solo il primo snapshot della cache all'apertura (niente attesa di 2 s), entro 1 s | 8 |
| NFR Design, revisione 2 | `tryReleaseOwner` dopo `dismiss` e `noticeShown` | 6 |
| NFR Design, revisione 2 | `resetPending` nello schema `ledger.v1`, conservato da `reset` | 6 |
| NFR Design, revisione 2 | `waitForPendingWrites()` con timeout di 30 s, che libera l'esecuzione unica | 8 |
| NFR Design, revisione 2 | Errore locale della cache: `beginWrite` e `set()` dentro `try`, eccezioni sincrone mostrate come "Impossibile salvare" (NFR6.4) | 7 |
| NFR Design, revisione 2 | Nomi dei campi di NFR8.1 allineati a `ledger.v1` nella checklist Data Safety | 16 |
| NFR Design §5 | Prova di riavvio di Firestore dopo `terminate` e `clearPersistence` con piano B | 9 |
| Infrastructure Design, revisione 2 | CI senza segreti: `options_demo.dart` nel repository, `FIREBASE_ENV=demo` predefinito; `options_prod.dart` generato solo da `release.yml`, con uno stub che compila e fallisce all'avvio se usato | 1, 14 |
| Infrastructure Design, revisione 2 | Tag `v*` protetti (ruleset); tag di promozione `v<versionName>+<versionCode>` per evitare collisioni | 14, 16 |
| Infrastructure Design, revisione 2 | Regole compatibili nei due sensi: test `test/rules/compat/` con client vecchi e nuovi | 11 |
| Infrastructure Design, revisione 2 | Soglia dell'alert di velocità di Crashlytics e verifica del nome della metrica delle regole nella checklist | 16 |

## Piano

### Step 1 — Struttura del progetto e configurazione di base (US1.1, US10.1)
- [ ] `flutter create --org com.vinoozy --project-name vinoozy --platforms android .`. Il comando non sovrascrive `.gitignore` né `.mcp.json`, che restano come sono.
- [ ] `.gitignore`: aggiunte le righe Flutter, Android, Node e Firebase, più `android/app/google-services.json`, `lib/firebase/options_prod.dart`, `*.jks` e `*.keystore`, **dopo** il blocco AI-DLC esistente, senza toccarlo.
- [ ] `applicationId` `com.vinoozy.app`, `minSdk` 23, `allowBackup=false`, `usesCleartextTraffic=false` e `network_security_config` con `10.0.2.2` solo nella variante debug (NFR4.8, NFR8.4).
- [ ] `pubspec.yaml` con le dipendenze di `tech-stack-decisions.md`, cioè le ultime versioni stabili compatibili; `pubspec.lock` nel repository; `.flutter-version` e `.nvmrc`.
- [ ] `analysis_options.yaml` con `flutter_lints`.
- [ ] `lib/firebase/options_demo.dart` (progetto `demo-vinoozy`, nessuna credenziale reale) e `lib/firebase/firebase_env.dart`, che sceglie demo o prod da `--dart-define=FIREBASE_ENV`, con demo come predefinito. Il file `options_prod.dart` viene generato dalla CI di rilascio; in sua assenza, uno stub `options_prod_stub.dart` (importato in modo condizionale) fa fallire subito l'avvio con un errore chiaro.
- [ ] `firebase.json` con Auth `127.0.0.1:9099` e Firestore `127.0.0.1:8080`, `.firebaserc` (`demo-vinoozy`), `firestore.indexes.json` vuoto.
- [ ] Localizzazione: `l10n.yaml` e i file ARB `app_it.arb`, `app_en.arb` e `app_pt_BR.arb` con tutti i testi di U1, con inglese come lingua di riserva (BR5.1).
- [ ] `package.json` con `firebase-tools` e `@firebase/rules-unit-testing` a versioni fissate.

### Step 2 — Runner dei test (Testing Contract)
- [ ] `flutter_test`, `mocktail`, `integration_test`; `test/helpers/` con fake di `KeyValueStore`, `Clock` e dei servizi.
- [ ] `tool/gen_coverage_helper.dart`, che genera `test/coverage_helper_test.dart` importando ogni file di `lib/` (NFR7.1); `tool/check_coverage.sh <soglia>`.
- [ ] Test di prova `test/u1/smoke_test.dart` ed esecuzione del comando di unità registrato in `unit-test-instructions.md`.

### Step 3 — Modello dei dati: implementazione (US2.1; BR2.1–BR2.5; C3)
- [ ] `lib/cellar/domain/`:
  - `Wine` e `Cellar` con le conversioni verso e da Firestore, con i campi di C3 e `schemaVersion` 1;
  - `UserProfile`;
  - `WineDraft`, con le validazioni BR2.1–BR2.3 e il nome ripulito dagli spazi;
  - `displayQuantity`, uguale a `max(0, q)` (ADR-004).
- [ ] Interfacce `Clock` e `IdGenerator` (ID del vino generato all'apertura del modulo).

### Step 4 — Modello dei dati: test
- [ ] `test/u1/domain/`, 6–8 test per tipo:
  - validazione del nome: vuoto, solo spazi, 120 e 121 caratteri;
  - annata: limiti 1900 e anno corrente + 0/1, "senza annata";
  - quantità tra 1 e 99;
  - quantità negativa mostrata come 0;
  - conversioni verso e da Firestore, campi sconosciuti ignorati.

### Step 5 — Registro locale: implementazione (NFR4.9, NFR6.3, NFR8.1)
- [ ] `lib/sync/ledger/local_ledger.dart`:
  - valore unico `ledger.v1`: `lastUid`, `generation`, `owner`, `journal` (voci con `ownerUid` e `state`), `resetPending`;
  - coda seriale `_mutate`;
  - operazioni `beginWrite`, `markConfirmed`, `markRejected`, `noticeShown`, `dismiss`, `tryReleaseOwner` e `reset`, che conserva `resetPending` finché il reset non è completato.
- [ ] `KeyValueStore` sopra `shared_preferences`.

### Step 6 — Registro locale: test
- [ ] `test/u1/sync/local_ledger_test.dart`, 8 test:
  - mutazioni concorrenti senza perdite;
  - `beginWrite` crea il proprietario e incrementa `seq`;
  - `tryReleaseOwner` non rilascia con `seq` cambiato, uid diverso o voci aperte o rifiutate;
  - `dismiss` e `noticeShown` richiamano `tryReleaseOwner`;
  - `noticeShown` alla terza volta rimuove la voce;
  - `reset` incrementa `generation`;
  - JSON corrotto rimesso a valori vuoti con un errore inviato a `ErrorReporter`.

### Step 7 — Repository e accesso ai dati: implementazione (US1.1, US2.1, US9.1, US9.2; BR1.3, BR2.4, BR3.1, BR3.4)
- [ ] `FirestoreBootstrap`:
  - `configure()`: persistenza, cache illimitata, emulatore se `FIREBASE_ENV=demo`;
  - esegue `clearPersistence` all'avvio se `resetPending`.
- [ ] `CellarRepository`: `ensurePersonalCellar` con transazione e 3 tentativi; `watchCellar`.
- [ ] `UserRepository.ensureProfile`.
- [ ] `WineRepository`:
  - `create(draft)`, che attende `beginWrite`, poi `set()` non atteso, con callback legato alla `generation`;
  - classificazione dei codici di errore;
  - errori sincroni restituiti come `SaveFailure`;
  - `incrementQuantity` con `FieldValue.increment` (BR3.4, solo livello dati);
  - `watchWines`.
- [ ] `SyncErrorBus`.

### Step 8 — Sincronizzazione e logica: implementazione (NFR2.4, NFR6.2, NFR6.3)
- [ ] `SyncStatus` (sincronizzato, in corso, offline): `hasPendingWrites` e `isFromCache`, con il primo snapshot della cache all'apertura ignorato.
- [ ] `SyncWatcher`:
  - inneschi: avvio, scrittura, rete tornata;
  - una sola esecuzione alla volta;
  - `waitForPendingWrites` con timeout di 30 s;
  - verifica `Source.server` con timeout di 10 s;
  - al massimo 3 ripetizioni immediate.
- [ ] `AccountGate` con `AuthService` (interfaccia):
  - controllo del registro a ogni avvio;
  - stati Accesso, Bloccato, Reset, AssicuraCantina, Cantina;
  - `ResetCoordinator`.
- [ ] `ErrorReporter.sanitize`.

### Step 9 — Prova di riavvio di Firestore (NFR4.10, security-design §5)
- [ ] `integration_test/firestore_restart_probe_test.dart`: `terminate`, `clearPersistence`, `configure`, poi una lettura sull'emulatore. Si esegue subito.
- [ ] Se fallisce, si attiva il piano B (`resetPending` e la schermata "Riavvia l'app"). L'esito viene scritto in `code-summary.md`.

### Step 10 — Repository, sincronizzazione e logica: test (test-after degli Step 7–8)
- [ ] `test/u1/data/` con mock di Firestore, 6–8 test per repository:
  - creazione, rifiuto e classificazione dei codici;
  - callback di una `generation` vecchia ignorato;
  - `SaveFailure`;
  - transazione della cantina ritentata.
- [ ] `test/u1/sync/`:
  - `SyncStatus`: 6 test, tra cui il primo snapshot della cache ignorato;
  - `SyncWatcher`: 8 test (timeout, `unavailable`, ripetizioni, voce rifiutata, rilascio);
  - `AccountGate`: 8 test (stessi uid, uid diverso con registro, reset, revoca della sessione);
  - `ErrorReporter`: 5 test di pulizia.

### Step 11 — Regole di sicurezza: implementazione e test ("API / endpoint"; NFR4.1–NFR4.5, NFR4.11)
- [ ] `firestore.rules` come da `security-design.md` §2 (`users`, `cellars`, `wines`, funzioni comuni).
- [ ] `test/rules/u1.rules.test.mjs`, circa 25 casi:
  - accesso anonimo, senza autenticazione e con provider diverso da Google;
  - `users`: create, update e campi vietati;
  - `cellars`: get su documento inesistente, create con altro uid, update di `ownerId` o `createdAt`, delete;
  - `wines`: create valido e campi fuori limite, annata con tolleranza di +1 anno, quantità negativa negli aggiornamenti accettata, accesso di un altro utente.
- [ ] `test/rules/compat/`: le scritture dell'app precedente devono passare con le regole nuove, e quelle dell'app nuova con le regole precedenti (tag `v*` più recente, se esiste).
- [ ] Esecuzione con `firebase emulators:exec`.

### Step 12 — Interfaccia: implementazione (US1.1, US2.1, US9.1, US10.1; BR5.1–BR5.3; M1, M3, M4b)
- [ ] `lib/app/`: `VinoozyApp` con temi chiaro e scuro dai token di `design-system-mapping.md`, localizzazione e ascoltatore di `SyncErrorBus` alla radice.
- [ ] Schermate:
  - `SignInScreen`: messaggio senza rete con `connectivity_plus`;
  - `BlockedAccountScreen`;
  - `CellarScreen`: caricamento, errore, elenco vuoto, `ListView.builder`;
  - `OfflineBanner`, con `liveRegion`;
  - `WineListTile`;
  - `AddWineScreen`, con validazione all'uscita dal campo e al Salva, pulsante disattivato dopo il primo tocco, `QuantityStepper`;
  - `RejectedWineNotice`.
- [ ] Ogni controllo ha `Key` e `Semantics`, usati nei test come `data-testid`.
- [ ] `EmulatorGoogleAuthService` e `TestNetworkControl`, inclusi solo con `--dart-define=E2E=true`; `GoogleAuthService` reale negli altri casi.

### Step 13 — Interfaccia: test
- [ ] `test/u1/ui/`, 5–8 test per schermata:
  - stati;
  - validazioni;
  - doppio tocco;
  - banner offline e in corso;
  - avviso dei vini rifiutati;
  - schermata di blocco.
- [ ] Per ogni schermata, test nelle tre lingue con `textScaler` 1.0 e 2.0 e le guide di accessibilità (contrasto, aree toccabili, etichette) (NFR3.1–NFR3.4).
- [ ] Test di build: la build release non contiene `EmulatorGoogleAuthService`.
- [ ] (Revisione 3, "Riprova") Un errore degli ascolti di cantina o vini porta allo stato "Impossibile preparare la cantina"; "Riprova" rifà `ensurePersonalCellar` e solo se riesce riapre gli ascolti (`reopenCellarListeners`). Test in `test/u1/account/account_gate_test.dart` e `test/u1/ui/cellar_retry_test.dart`.
- [ ] (Revisione 4, primo accesso; richiesta del proprietario "Correggiamo il problema prima") Durante la preparazione della cantina (`setup == preparing`) `CellarScreen` non apre nessun ascolto di Firestore e non monta `OfflineBanner`, così al primo accesso non compare l'errore. Test che falliscono sul codice precedente in `test/u1/ui/cellar_screen_test.dart` e `test/u1/ui/cellar_retry_test.dart`; test di "Riprova" che fallisce di nuovo.

### Step 14 — Test end-to-end dello scheletro (NFR7.3; prova da capo a fondo di `functional-spec.md`)
- [ ] `integration_test/u1_skeleton_test.dart`, sull'emulatore Android con la Emulator Suite:
  1. accesso;
  2. aggiunta di "Barolo 2016 x2" offline (`TestNetworkControl`), con indicatore offline;
  3. ritorno della rete: il vino è nel cloud dell'emulatore;
  3b. (Revisione 1, R-01) due vini aggiunti offline, poi la rete torna: entrambi sincronizzati, registro vuoto, nessun avviso "non salvato";
  4. il secondo utente non vede il vino;
  5. A offline aggiunge un vino ed esce, B è bloccato, A rientra e il vino arriva;
  6. B conferma l'eliminazione e vede la cantina vuota;
  7. due client creano una sola cantina;
  8. riavvio nello stesso processo (`terminate()` e nuovo `main()`) con le modifiche ancora presenti;
  9. avvio misurato come riavvio nello stesso processo (l'avvio a freddo reale resta da misurare sul telefono: NFR2.1 aperto, `docs/release-checklist.md`).
- [ ] (Revisione 1, R-02) Riavvio reale con `adb shell am force-stop` e `adb shell am start`, come passo separato (`tool/e2e_force_stop.sh` con `integration_test/force_stop_queue.dart` e `test_driver/integration_test.dart`): vino aggiunto con la rete spenta, processo ucciso, app reale reinstallata sopra mantenendo i dati e avviata; il vino è ancora sullo schermo e arriva al cloud. Collegato al job `e2e` di `ci.yml` e a `tool/verify_skeleton.sh`; eseguito in locale su `Medium_Phone_API_36.1`.
- [ ] `tool/verify_skeleton.sh`: avvia gli emulatori, esegue i test delle regole, la prova di riavvio, `e2e` e la prova con `adb force-stop`, e si ferma al primo errore. È il comando proposto per la verifica dello scheletro.

### Step 15 — Pipeline e configurazione di ambiente (`cicd-pipeline.md`)
- [ ] `.github/workflows/`:
  - `ci.yml`: format, analyze, unit con copertura, rules, e2e;
  - `release.yml`;
  - `promote.yml`, con tag `v<versionName>+<versionCode>`;
  - `firebase-deploy.yml`.

  Tutti con azioni fissate per SHA e permessi minimi.
- [ ] `.github/dependabot.yml`.
- [ ] `android/app/build.gradle`: firma letta da variabili d'ambiente, mai da file nel repository.

### Step 16 — Documentazione e tracciabilità
- [ ] `docs/firebase-setup.md`:
  - progetto, `europe-west8`, Google come unico provider;
  - App Check e Play Integrity;
  - budget di 1 €;
  - WIF;
  - i due account di servizio Play;
  - ambienti e regole del repository: `main` protetto, tag `v*` e `build-*` protetti, scansione dei segreti;
  - alert di `monitoring-design.md`, con la soglia di Crashlytics e la verifica del nome della metrica delle regole.
- [ ] `docs/release-checklist.md`: smoke test e Data Safety, con i campi di `ledger.v1`.
- [ ] `code-summary.md`, `traceability.json`, `source-manifest.json` nella cartella del record.

## Tracciabilità storie → step

| Storia | Step |
|--------|------|
| US1.1 (accesso Google, sessione) | 1, 7, 8, 10, 12, 13, 14 |
| US2.1 (aggiunta scritta, parte U1) | 3, 4, 7, 10, 12, 13, 14 |
| US9.1 (offline e sincronizzazione) | 5, 6, 7, 8, 9, 10, 14 |
| US9.2 (incrementi, livello dati) | 3, 7, 10, 11 |
| US10.1 (lingue, tema, accessibilità) | 1, 12, 13 |
| NFR4 (sicurezza) | 1, 11, 12, 15, 16 |
| NFR7 (qualità) | 2, 13, 14, 15 |
