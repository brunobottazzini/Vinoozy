# Piano di generazione del codice: rilascio automatico e E2E stabile

## Summary

- Builds: verifica dei segreti di release e promozione, messaggi chiari di `play_api.sh`, guida di configurazione, correzione del cambio di cantina attiva durante la build
- Touches: `tool/check_release_inputs.sh`, `tool/play_api.sh`, `.github/workflows/{release,promote,ci}.yml`, `docs/github-actions-setup.md`, `lib/sharing/sharing_providers.dart`, test in `tool/` e `test/sharing/`
- Tests: 2 script di test bash con stub e fixture finte (~20 casi), 1 test di widget di regressione, riproduzione E2E ripetuta sul Mac

## Contesto

Lavoro senza Unit (scope express): un solo passaggio di costruzione. Fonti:
`inception/requirements-analysis/requirements.md` (FR1-FR7, NFR1-NFR6) e la
mappa del codice `aidlc/spaces/default/codekb/Vinoozy/`. Le modifiche locali
del proprietario non committate (`distribution/google-play/data-safety.csv`,
`docs/play-console-handoff.md`, `docs/release-checklist.md`, file non
tracciati) restano intatte; `docs/play-console-handoff.md` riceve solo il
rimando di FR5.4, aggiunto senza toccare il resto.

Analisi d'impatto (brownfield):

| File | Chi lo usa | Impatto |
|---|---|---|
| `.github/workflows/release.yml` | push su `main` dopo `ci` | medio: nuovo step prima della scrittura dei segreti |
| `.github/workflows/promote.yml` | avvio manuale | basso: verifica prima di scrivere la credenziale |
| `.github/workflows/ci.yml` | ogni push e PR | basso: due test in più nel job `analyze` |
| `tool/play_api.sh` | `release.yml`, `promote.yml` | medio: stesso contratto di stdout e degli argomenti |
| `lib/sharing/sharing_providers.dart` | `CellarScreen`, `CellarSwitcher`, Dashboard, `CellarActions` | medio: solo il momento in cui la cantina attiva cambia |

## Testing Contract

```json
{
  "version": 1,
  "methodology": "test-after",
  "source": "team",
  "ordering": "Per ogni strato testabile (dominio, dati e sincronizzazione, interfaccia) implementiamo prima il codice, poi scriviamo ed eseguiamo i test di quello strato, e passiamo allo strato successivo solo con quei test verdi.",
  "scope": "express",
  "test_strategy": "minimal",
  "project_type": "brownfield",
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
    "strategy": "minimal",
    "strategy_volume": [
      "One verifiable test per requirement at the narrowest effective level.",
      "At least one happy-path unit test per component.",
      "Unit tests are the default; a bugfix/security scope floor may require an integration or E2E regression when that is the narrowest level that reproduces the defect."
    ],
    "scope_floor": [
      "Keep the existing test suite green.",
      "This scope adds no extra new-test floor beyond the selected test strategy."
    ],
    "combination_rule": "Apply every selected-strategy obligation and every scope-floor obligation; neither replaces the other, and a targeted scope regression may add the narrowest necessary test type beyond the strategy default."
  },
  "plan_profile": {
    "methodology": "test-after",
    "runner_step": "Verify the existing test runner/configuration and record the exact unit-scoped command.",
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
      "Verify the existing test runner/configuration and record the exact unit-scoped command.",
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
  "input_sha256": "sha256:865343873c9f0b328d34ded3554c226044cb3a9b68eef7ea66181ee9d1d90ade",
  "contract_sha256": "sha256:225d0e3aa565626c2c5d1d4d16cc8ad5c6cd32fb293c1c2ca264b1e79bca33f9"
}
```

## Strati e ordine

Metodo test-after, strato per strato. Gli strati del Testing Contract senza
oggetto qui (modello dati, repository, API) sono omessi. Gli strati di questo
lavoro sono: script di consegna (logica), workflow (configurazione), app
(provider della cantina attiva e interfaccia), documentazione.

## Passi

### Preparazione

- [x] **Step 1. Base dei test.** Verificare i comandi già usati dal
  progetto: `bash tool/check_wine_db_release_test.sh` (schema dei test di
  script), `flutter test test/sharing/` (test dei provider di condivisione).
  Installare `actionlint` sul Mac solo per le verifiche locali (`brew install
  actionlint`; non entra nel progetto). Registrare i comandi in
  `unit-test-instructions.md`. Eseguire la baseline: `flutter test
  test/sharing/` e `bash tool/check_rule_ids_test.sh` devono essere verdi
  prima delle modifiche. (NFR4)

### Strato 1: script di consegna (logica)

- [x] **Step 2. Implementare `tool/check_release_inputs.sh`** (FR1.1-FR1.4,
  FR4.1, NFR1, NFR5). Script bash `set -euo pipefail` che legge le variabili
  d'ambiente e le controlla secondo un profilo:
  - `--profile internal`: i sette segreti di `play-internal` e la variabile
    `GOOGLE_SERVER_CLIENT_ID`;
  - `--profile production`: `PLAY_PRODUCTION_SA_JSON` di `play-production`.
  Raccoglie **tutti** gli errori prima di uscire; ogni riga nomina il tipo
  (secret o variable), il nome, l'ambiente e la regola violata ("missing",
  "not valid Base64", "empty after decoding", "not valid JSON", "missing
  field client_email"...). Controlli: non vuoto; Base64 decodificabile e non
  vuoto per i tre `_B64`; account di servizio con `type == service_account`,
  `client_email`, `private_key`; `google-services.json` con `project_info` e
  un `client` con `package_name` `com.vinoozy.app`; dart-defines con
  `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_PROJECT_ID` non vuoti. I
  valori decodificati passano solo per pipe a `jq` (mai su disco, mai su
  stdout o stderr). Uscita 0 se tutto è valido, 1 con l'elenco degli errori.
- [x] **Step 3. Implementare le modifiche a `tool/play_api.sh`** (FR2.1-FR2.4,
  NFR1, NFR5):
  - funzione `fail <code> <message>` che scrive su stderr con prefisso
    `play_api:`;
  - controllo del file della chiave: variabile assente (uscita 3), file
    assente o non leggibile (3), vuoto (3), JSON non valido (3), `type` diverso
    da `service_account` o campi mancanti (3); nessun contenuto stampato;
  - autenticazione: l'output di `gcloud auth activate-service-account` viene
    catturato; in caso di errore si stampa "Google Play authentication failed
    for the service account in PLAY_SA_JSON_FILE" più il motivo di `gcloud`
    ripulito (righe che contengono `private_key`, `BEGIN`, `token` o
    sequenze Base64 lunghe vengono rimosse) e si esce con 4; lo stesso per
    `print-access-token`;
  - `call()`: con `--fail-with-body` cattura lo stato HTTP e, in errore,
    scrive "Play API <METHOD> <path> failed with HTTP <status>" e il corpo
    della risposta limitato a 500 caratteri senza il token; uscita 5;
  - `next-version-code` stampa su stdout solo il numero; `promote`,
    `complete`, `halt` invariati negli argomenti e nei codici 1 e 2 già
    esistenti.
- [x] **Step 4. Test dello strato 1** (FR3.1-FR3.3, NFR1, NFR5):
  - `tool/check_release_inputs_test.sh` con fixture in
    `tool/fixtures/release_inputs/` (account di servizio finto con chiave
    `-----BEGIN PRIVATE KEY-----FAKE`, `google-services` finto, defines finti,
    keystore finto di pochi byte). Casi: tutto valido (passa); due segreti
    mancanti insieme (elencati entrambi); variabile mancante; Base64 non
    valido; vuoto dopo la decodifica; JSON non valido; `type` sbagliato;
    package diverso; define mancante; profilo `production` valido e mancante;
    controllo che nessun valore delle fixture compaia nell'output.
  - `tool/play_api_test.sh` con stub in `tool/fixtures/play_api/bin/`
    (`gcloud` e `curl` finti, comandati da variabili d'ambiente, messi in
    testa al `PATH`). Casi: variabile assente, file assente, file vuoto, JSON
    non valido, tipo sbagliato, autenticazione fallita (messaggio e uscita 4,
    nessun frammento di chiave), richiesta del token fallita, API fallita con
    HTTP 403 (metodo, percorso, stato; uscita 5; nessun token), riuscita
    (stdout esattamente `42` con tracce che hanno 41 come massimo), `promote`
    con frazione non valida (uscita 2).
  - Eseguire entrambi e correggere fino al verde.

### Strato 2: workflow (configurazione)

- [x] **Step 5. `release.yml`** (FR1.1, FR1.5, NFR3): nuovo primo step dopo
  il checkout, `Check the play-internal configuration`, che passa i sette
  segreti e la variabile come `env` e lancia `tool/check_release_inputs.sh
  --profile internal`, prima di `setup-java`, del setup di Flutter e di
  `Write secret files`. Il `printf` di `Write secret files` e lo step
  `Remove secret files` con `if: always()` restano.
- [x] **Step 6. `promote.yml`** (FR4.1, FR4.2): step `Check the
  play-production configuration` con `tool/check_release_inputs.sh --profile
  production` prima di `Write the Play credentials`; pulizia `if: always()`
  invariata.
- [x] **Step 7. `ci.yml`** (FR3.4): nel job `analyze`, eseguire
  `tool/check_release_inputs_test.sh` e `tool/play_api_test.sh` accanto agli
  altri `tool/check_*_test.sh`.
- [x] **Step 8. Test dello strato 2** (NFR2): `actionlint` su tutti i
  workflow con le stesse opzioni della CI (`-shellcheck= -pyflakes=`); poi
  una prova locale di `tool/check_release_inputs.sh --profile internal` senza
  variabili, che deve elencare tutti gli otto nomi.

### Strato 3: app (cantina attiva)

- [x] **Step 9. Riproduzione sul Mac** (FR7.1): avviare gli emulatori
  Firebase (`npx firebase emulators:start --only auth,firestore,functions
  --project demo-vinoozy`, dopo `npm --prefix functions run build`) e
  l'emulatore Android; eseguire il test 8 almeno 10 volte con `flutter test
  integration_test/u1_skeleton_test.dart --plain-name "8. after a restart"
  --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true`, poi la suite
  completa una volta. Registrare quante volte fallisce. Se l'AVD API 36.1 non
  lo riproduce, creare un AVD API 34 come in CI e ripetere.
- [x] **Step 10. Test di widget che riproduce la causa** (FR7.1, FR7.3):
  `test/sharing/active_cellar_build_test.dart`. Monta `CellarSwitcher` e un
  widget che osserva `activeCellarProvider(user)` dentro la stessa build (come
  `CellarScreen`), con override di `myMembershipsProvider` comandato dal test;
  fa emettere agli inviti un valore nuovo **durante** la build del widget
  padre, così `ActiveCellarNotifier._refresh` assegna `state`. Sul codice
  attuale il test deve fallire con "setState() or markNeedsBuild() called
  during build"; registrare l'esito. Se la sequenza esatta richiede un altro
  innesco (per esempio `_restore` o il ricreare il notifier dopo il riavvio),
  seguire quello che mostra lo Step 9.
- [x] **Step 11. Correzione** (FR7.2): in `ActiveCellarNotifier`, i cambi di
  `state` che nascono dai callback di `ref.listen` (`_refresh` chiamato da
  `accessibleCellarsProvider`, `myMembershipsProvider` e `_restore`) vengono
  rinviati fuori dalla fase di build, nello stesso modo già usato da
  `_backToPersonal` (`scheduleMicrotask` con controllo `ref.mounted`),
  evitando doppie pianificazioni; `select()` resta sincrono, perché nasce da
  un tocco dell'utente. Nessun cambio visibile: cantina personale all'avvio,
  scelta salvata ripristinata, ritorno alla personale quando l'accesso si
  perde.
- [ ] **Step 12. Test dello strato 3** (FR7.3, FR7.4, NFR4):
  - il test dello Step 10 passa;
  - `flutter test test/sharing/` verde (comportamento invariato);
  - il test 8 sul Mac passa 10 volte consecutive e la suite E2E completa
    passa una volta;
  - `flutter analyze --fatal-infos` e `dart format --set-exit-if-changed .`
    puliti.

### Strato 4: documentazione e tracciabilità

- [x] **Step 13. Guida `docs/github-actions-setup.md`** in italiano (FR5.1-FR5.3,
  NFR1, NFR6): per `play-internal` una tabella con nome, tipo, formato e
  origine di ogni segreto e della variabile, e un comando macOS per ciascuno
  che copia il valore negli appunti senza stamparlo (`base64 -i <file> |
  pbcopy`, `pbcopy < <file>`); creazione di `play-production` (approvazione
  obbligatoria del proprietario, solo `main`) e del suo segreto; controllo
  con `gh secret list --env ...` e `gh variable list --env ...` (solo nomi);
  come avviare la prima release dopo la configurazione e cosa controllare
  (versionCode, AAB, canale interno, tag `build-<versionCode>`), con la
  nota sul rerun di una vecchia release.
- [x] **Step 14. Rimandi** (FR5.4): in `docs/firebase-setup.md` §5 e §6 una
  riga che rimanda alla guida; in `docs/play-console-handoff.md` §3 una riga
  di rimando, senza toccare le modifiche locali del proprietario.
- [x] **Step 15. Riepilogo e tracciabilità**: `code-summary.md` e
  `traceability.json` di questa fase.

### Fuori dalla costruzione (dopo l'approvazione del codice)

- La configurazione dei segreti e di `play-production` la fa il proprietario
  con la guida (FR5).
- La release reale (FR6.1) si verifica in Build and Test, dopo commit e push
  su `main` fatti solo con il consenso del proprietario (FR6.2).

## Tracciabilità piano → requisiti

| Requisito | Passi |
|---|---|
| FR1.1-FR1.4 | 2, 4, 5 |
| FR1.5 | 5 |
| FR2.1-FR2.4 | 3, 4 |
| FR3.1-FR3.3 | 4 |
| FR3.4 | 7 |
| FR4.1-FR4.2 | 2, 4, 6 |
| FR5.1-FR5.4 | 13, 14 |
| FR6.1-FR6.2 | Build and Test |
| FR7.1 | 9, 10 |
| FR7.2 | 11 |
| FR7.3-FR7.4 | 10, 12 |
| NFR1 | 2, 3, 4, 13 |
| NFR2 | 8 |
| NFR3 | 5 |
| NFR4 | 1, 12 |
| NFR5 | 2, 3, 4 |
| NFR6 | tutti |
