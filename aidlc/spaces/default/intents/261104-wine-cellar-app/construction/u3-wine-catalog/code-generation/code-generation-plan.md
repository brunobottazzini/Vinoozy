# Code Generation Plan — u3-wine-catalog

Fonti: `functional-spec.md`, `rules.md`, `entities.md` (Functional Design di U3); `performance-`, `security-`, `scalability-`, `reliability-`, `observability-requirements.md`, `tech-stack-decisions.md` (NFR Requirements); `logical-components.md`, `performance-`, `security-`, `scalability-`, `reliability-`, `observability-design.md` (NFR Design); `infrastructure-specification.md`, `monitoring-design.md`, `cicd-pipeline.md` (Infrastructure Design); `contract-summary.md` (C1, C2, C5); `unit-of-work.md`; `requirements.md`.

U3 è il catalogo dei vini dentro l'app (`lib/catalog/`): un nucleo puro `lib/catalog/core/` e una parte di piattaforma `lib/catalog/platform/`. Usa le funzioni di catalogo di C2, che si aggiungono al pacchetto `packages/estimation` di U2 come modifica compatibile. Storie: US4.1, US7.1 (dati esterni), più le operazioni per FR2.1 e FR2.2 usate da U4 e U6.

Gli strati testabili che si applicano sono: **modello dei dati** (tipi di C1, funzioni di catalogo di C2, cache in memoria), **accesso ai dati** (adattatore di Open Food Facts, file di cache), **logica** (coordinatore, catalogo interno, budget, circuit breaker) e **API** (interfaccia `WineCatalog` e provider). Lo strato interfaccia non si applica: le schermate sono di U4 e U6.

## File dell'utente toccati da questo lavoro

- `packages/estimation/` (U2): aggiunte compatibili di C2 (`normalizeWineText`, `recognizeDenomination`, `denominationCatalog`, `displayName` e `region` delle denominazioni) e relativi test, mantenendo copertura del 90% e purezza.
- `pubspec.yaml`, `pubspec.lock`: dipendenze `http`, `path_provider`, `package_info_plus`, `crypto`.
- `tool/check_coverage.sh`: terzo argomento facoltativo per filtrare per prefisso.
- `.github/workflows/ci.yml`: passo `tool/check_off_config.sh` nel job `analyze`; copertura di `lib/catalog/` e benchmark del catalogo nel job `unit`.
- File di traduzione (`lib/l10n/*.arb`): chiave `offAttribution` in it, en e pt-BR.
- `docs/release-checklist.md`, `docs/firebase-setup.md`: righe e sezione su `OFF_CONTACT`, privacy, attribuzione, misure sul telefono e controllo mensile.
- `integration_test_perf/estimation_perf_test.dart`: misure di `suggestWines` e `matchLabelText`.

## Steps

### Step 1 — Struttura e dipendenze — [x]
- [x] Cartelle `lib/catalog/core/`, `lib/catalog/core/off/`, `lib/catalog/platform/`; dipendenze in `pubspec.yaml` e `flutter pub get`.
- Traccia: `logical-components.md`; `infrastructure-specification.md` (dipendenze).

### Step 2 — Runner dei test — [x]
- [x] Cartella `test/catalog/` con le risposte registrate in `test/catalog/fixtures/`; comando in `unit-test-instructions.md`: `flutter test test/catalog`.

### Step 3 — Modello dei dati: implementazione — [x]
- [x] `packages/estimation`: funzioni di catalogo di C2 (`normalizeWineText`, `recognizeDenomination`, `denominationCatalog` con `displayName`, `aliases`, `wineType`, `region`), esportate da `lib/estimation.dart`.
- [x] `lib/catalog/core/wine_catalog.dart`: interfaccia `WineCatalog` (5 operazioni), `WineCandidate`, `CellarWineRef`, `SuggestResult`, `LabelMatch`, `WineProfileResult`, `CatalogArgumentError` (solo codice).
- [x] `lib/catalog/core/catalog_cache_store.dart`: cache e indice in memoria, scadenza 30 giorni, limiti (200 voci, 10 proposte, 500 indice), epoca, proprietario (hash), salvataggi serializzati verso l'interfaccia `CacheFile`.
- Traccia: `entities.md`; BR2.1; NFR2.3, NFR6.4, NFR8.1.

### Step 4 — Modello dei dati: test — [x]
- [x] `packages/estimation/test/catalog_functions_test.dart`: normalizzazione, riconoscimento, elenco; il pacchetto resta al 90% e passa lo script di purezza.
- [x] `test/catalog/wine_catalog_types_test.dart`, `test/catalog/catalog_cache_store_test.dart`: uguaglianza, errori senza valori, scadenza, limiti in byte UTF-8, epoca, proprietario diverso, `clear()` con salvataggio in corso.
- [x] Eseguire `cd packages/estimation && dart test` e `flutter test test/catalog`.

### Step 5 — Accesso ai dati: implementazione — [x]
- [x] `lib/catalog/core/off/open_food_facts_source.dart`: URL con `Uri.https`, `followRedirects = false`, scadenza unica di 5 s su invio e lettura, lettura a flusso fino a 1 MB, esiti `found` / `notFound` / `failure(kind)`, mappatura (BR4.1), pulizia e troncamento.
- [x] `lib/catalog/platform/file_cache_file.dart`: `catalog_cache.json` nella cartella di supporto, scrittura su `.tmp` e rinomina, cancellazione di file e `.tmp`.
- Traccia: BR1.2, BR1.3, BR1.5, BR4.1, BR5.1; NFR1.3, NFR4.1–NFR4.4, NFR6.2.

### Step 6 — Accesso ai dati: test — [x]
- [x] `test/catalog/open_food_facts_source_test.dart` con `MockClient`: 200, 404, `status: 0`, 429, 503, 301, corpo di 2 MB, JSON non valido, lentezza oltre 5 s, campi strani e troppo lunghi, header e parametri inviati (nessun dato della cantina).
- [x] `test/catalog/file_cache_file_test.dart` su cartella temporanea: scrittura atomica, file rovinato, cancellazione.
- [x] `test/catalog/backup_rules_test.dart`: manifest e `data_extraction_rules.xml` di U1.
- [x] Eseguire `flutter test test/catalog`.

### Step 7 — Logica: implementazione — [x]
- [x] `lib/catalog/core/internal_catalog.dart` (BR1.1), `request_budget.dart` (BR2.3), `off_circuit_breaker.dart` (BR2.2, `CatalogHealth`), `catalog_event_logger.dart` (interfaccia, `debugLogging`), `catalog_config.dart` (`OFF_CONTACT`, host, versione), `catalog_coordinator.dart` (validazione, ordine delle fonti, unione BR1.4, `matchLabelText` BR1.3, `lookupBarcode` BR1.5, `getWineProfile` BR3.1, epoca delle risposte in volo, attesa di `clear()`).
- Traccia: BR1.1–BR3.1, BR5.1; NFR1.1, NFR1.5, NFR2.1, NFR2.2, NFR6.1–NFR6.3, NFR6.6, NFR6.7.

### Step 8 — Logica: test — [x]
- [x] `test/catalog/internal_catalog_test.dart`, `request_budget_test.dart`, `off_circuit_breaker_test.dart`, `catalog_coordinator_test.dart`: un test per ogni regola con l'ID nel nome (BR1.1–BR5.3), orologio simulato, OFF spento senza contatto, nessun testo dell'utente nel registratore, cambio di utente durante una richiesta.
- [x] Eseguire `flutter test test/catalog`.

### Step 9 — API e piattaforma: implementazione e test — [x]
- [x] `lib/catalog/platform/crashlytics_catalog_event_logger.dart`, `lib/catalog/platform/catalog_providers.dart` (`catalogProvider`, `catalogSessionProvider` che chiama `clear()` a ogni cambio di uid, versione da `package_info_plus`).
- [x] `test/catalog/catalog_providers_test.dart`: composizione, `clear()` al cambio di utente, nessun utente → nessuna cache.
- [x] Chiave `offAttribution` nei file di traduzione e generazione con `flutter gen-l10n`.
- [x] Eseguire `flutter test test/catalog`.

### Step 10 — Strumenti, CI e prestazioni — [x]
- [x] `tool/check_off_config.sh` (contatto committato anche nei workflow, email in `.dart` di `lib/` escluso `lib/l10n/`, Firestore e Functions in `lib/catalog/`, Flutter, `path_provider` e Firebase in `lib/catalog/core/`; esclude se stesso), eseguibile.
- [x] `tool/check_coverage.sh`: terzo argomento facoltativo per il prefisso.
- [x] `benchmark/catalog_benchmark.dart` (5, 10, 1 e 20 ms; ripetizione, `exit(1)`).
- [x] `.github/workflows/ci.yml`: passi nei job `analyze` e `unit`.
- [x] `integration_test_perf/estimation_perf_test.dart`: misure di `suggestWines` e `matchLabelText`.
- [x] Eseguire script, benchmark, `flutter analyze --fatal-infos`, `dart run tool/gen_coverage_helper.dart`, `flutter test --coverage`, copertura di progetto e di `lib/catalog/`.

### Step 11 — Documentazione e tracciabilità — [x]
- [x] `docs/release-checklist.md`, `docs/firebase-setup.md` (sezione `OFF_CONTACT` nell'ambiente `play-internal`).
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
