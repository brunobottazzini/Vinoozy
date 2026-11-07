# Code Generation Plan — u2-estimation

Fonti: `functional-spec.md`, `rules.md`, `entities.md` (Functional Design di U2), `performance-requirements.md`, `security-requirements.md`, `tech-stack-decisions.md` (NFR Requirements), `security-design.md`, `logical-components.md` (NFR Design), `cicd-pipeline.md` (Infrastructure Design), `contract-summary.md` (C2), `unit-of-work.md`, `requirements.md`.

U2 è il pacchetto Dart puro `packages/estimation` (C2 v1 con le aggiunte compatibili di `entities.md`). Gli strati testabili che si applicano sono **modello dei dati** (tipi di C2, tabelle) e **logica** (riconoscimento, finestra, stato, abbinamenti, API). Non ci sono accesso ai dati, endpoint né interfaccia: gli strati "Repository / data access", "API / endpoint" e "Frontend behavior" del contratto non si applicano a una libreria pura (l'API pubblica è la logica stessa, testata nello strato della logica).

Storie coperte (per la parte di calcolo): US4.1 (finestra e fiducia), US4.2 (stato e "da bere presto"), US7.1 (abbinamenti). FR4.1–FR4.7, FR7.2.

## File dell'utente toccati da questo lavoro

- `pubspec.yaml` dell'app: aggiunta della dipendenza `estimation: path: packages/estimation` (serve alla misura sul telefono, `cicd-pipeline.md` §5, e a U4/U5).
- `analysis_options.yaml` della radice: `packages/**` negli `exclude` (`cicd-pipeline.md` §2).
- `.gitignore`: `packages/estimation/coverage/` (`cicd-pipeline.md` §1).
- `.github/workflows/ci.yml`: nuovo job `estimation`, unione della copertura nel job `unit`, commento "six" (`cicd-pipeline.md` §1–§3).
- `docs/release-checklist.md`: riga della misura sul telefono (`cicd-pipeline.md` §5).

## Steps

### Step 1 — Struttura del pacchetto e configurazione — [x]
- [x] `packages/estimation/pubspec.yaml` (nessuna dipendenza di produzione; dev: `test`, `lints`, `benchmark_harness`, `coverage`), `analysis_options.yaml` (`package:lints/recommended.yaml`), `lib/estimation.dart` (esporta solo l'API di C2), `README.md` breve del pacchetto.
- Traccia: NFR4.1, NFR7.4; `logical-components.md` (API pubblica).

### Step 2 — Avvio del runner dei test — [x]
- [x] `dart pub get` nel pacchetto; un primo test vuoto di avvio sostituito dagli step successivi; comando registrato in `unit-test-instructions.md`: `cd packages/estimation && dart test`.
- Traccia: Testing Contract (runner prima del primo test).

### Step 3 — Modello dei dati: implementazione — [x]
- [x] `lib/src/models.dart`: enum `WineType` (con `tryParse` per i nomi dell'enum e i valori di C1, BR1.7), `Qualifier`, `Confidence`, `WindowSource`, `EstimationBasis` (con `resolveStoredBasis`), `WineStatus`, `PairingCategory`; classi immutabili con uguaglianza per valore `WineFacts`, `ExternalProfile` (finestra facoltativa), `DrinkingWindow` (con `warningCode` = `GENERIC_ESTIMATE` per `basis = generic`), `Pairings`.
- [x] `lib/src/errors.dart`: `EstimationErrorCode`, `EstimationArgumentError extends ArgumentError`.
- [x] `lib/src/tables.dart`: tabella `const` delle denominazioni (tutte le righe di `rules.md`, con alias e scostamenti delle qualifiche) e delle tipologie più la riga generica; mappa `const` per chiave.
- Traccia: `entities.md`; BR1.7, BR2.1, BR2.2, BR4.1, BR4.3; US4.1, US7.1.

### Step 4 — Modello dei dati: test — [x]
- [x] `test/models_test.dart`: uguaglianza, `WineType.tryParse`, `resolveStoredBasis`, `warningCode`, campi di `WineFacts` senza dati personali (NFR8.1), codici d'errore.
- [x] `test/tables_test.dart`: test generati per ogni riga (inizio ≤ picco ≤ fine anche per le qualifiche, da 3 a 5 categorie valide, ogni alias riconosciuto, alias unici, chiavi uniche) — NFR7.2.
- [x] Eseguire `cd packages/estimation && dart test test/models_test.dart test/tables_test.dart`: verdi prima dello step 5.

### Step 5 — Logica: implementazione — [x]
- [x] `lib/src/validation.dart`: BR4.5 per `estimateWindow` e `pairingsFor`, finestra incoerente per `statusOf` (NFR4.2).
- [x] `lib/src/recognizer.dart`: normalizzazione (minuscole, senza accenti, apostrofi e punteggiatura come spazi, massimo 60 caratteri), `buildAliasIndex()` e `final aliasIndex = buildAliasIndex();`, `recognize()` per parole intere con l'alias più lungo e a parità il primo, qualifiche (BR1.1); risoluzione con le precedenze di BR1.2 e BR1.7.
- [x] `lib/src/window.dart`: `estimateWindow` (W1, BR1.3, BR1.4, BR1.6, BR2.1, BR2.2, BR3.1).
- [x] `lib/src/status.dart`: `statusOf` con aritmetica intera (W2, BR3.2, BR3.3).
- [x] `lib/src/pairings.dart`: `pairingsFor` (W3, BR4.1, BR4.2, NFR4.3).
- [x] `needsRefinement` in `lib/src/window.dart` (BR1.5, mai errori).
- Traccia: US4.1, US4.2, US7.1; FR4.1–FR4.7, FR7.2.

### Step 6 — Logica: test — [x]
- [x] `test/recognizer_test.dart`: parole intere ("Castiglione" non è Asti), alias più lungo, qualifiche, nomi con accenti e apostrofi, precedenze utente → C1 → nome, tipologia a mano diversa.
- [x] `test/window_test.dart`: esempi di `functional-spec.md` (Barolo 2016, Barolo Riserva 2016, Barbera d'Asti Superiore senza annata, Rosso della casa redLight, Vino di Mario generico), profilo esterno valido e incoerente, fiducia BR3.1, annata futura e molto vecchia, spumanti senza annata, ingressi non validi con codice.
- [x] `test/status_test.dart`: AC4.2.1, AC4.2.2, ultimo mese, prima dell'inizio, dopo la fine, finestra incoerente.
- [x] `test/pairings_test.dart`: fonte con più di 5 abbinamenti, fonte vuota, denominazione, tipologia, generico, ingressi non validi.
- [x] `test/api_test.dart`: `needsRefinement` (anche con finestra incoerente), determinismo con 1000 casi `Random(42)` per funzione, solo `EstimationArgumentError` con ingressi casuali (NFR4.2, NFR4.4).
- [x] `test/coverage_helper_test.dart`: importa ogni file di `lib/` e controlla che l'elenco coincida con i file presenti.
- [x] Eseguire `cd packages/estimation && dart test`: tutto verde.

### Step 7 — Strumenti di CI e prestazioni — [x]
- [x] `tool/check_estimation_purity.sh` (dipendenze, import, parole vietate, stato globale, 2 occorrenze di `buildAliasIndex(`), eseguibile.
- [x] `packages/estimation/benchmark/estimation_benchmark.dart`: misure di `logical-components.md` (riconoscimento ≤ 4 ms, 500 stime ≤ 10 ms, secondo blocco ≤ +10%, stima ≤ 1/10 della costruzione dell'indice), una ripetizione se sfora, `exit(1)` alla seconda.
- [x] `integration_test_perf/estimation_perf_test.dart` e `test_driver/perf_driver.dart` (misura sul telefono, ≤ 25 ms).
- [x] Eseguire purezza, copertura del pacchetto (≥ 90%) e benchmark in locale.
- Traccia: NFR2.1, NFR2.2, NFR2.3, NFR4.1, NFR4.4, NFR7.1, NFR7.5.

### Step 8 — Configurazione del progetto — [x]
- [x] `pubspec.yaml` dell'app (dipendenza `path`), `analysis_options.yaml` (exclude `packages/**`), `.gitignore`, `.github/workflows/ci.yml` (job `estimation`, unione lcov nel job `unit`, commento), `docs/release-checklist.md`.
- [x] Verificare che `flutter analyze` e `flutter test` dell'app restino verdi.
- Traccia: `cicd-pipeline.md` §1–§5; NFR7.1, NFR7.4.

### Step 9 — Documentazione e tracciabilità — [x]
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
