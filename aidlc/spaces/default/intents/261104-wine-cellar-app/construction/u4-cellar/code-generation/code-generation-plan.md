# Code Generation Plan — u4-cellar

## Summary

- Builds: gestione completa della cantina: suggerimenti, nuovo produttore, doppioni e unione, elenco dei soli vini presenti con archivio "Bevuti", ricerca e filtri, dettaglio, modifica, eliminazione, bevuta con Annulla, Storico, riscontro sulla finestra, recupero dopo la rete.
- Touches: `lib/cellar/` (dominio, dati, provider, schermate), `lib/sync/sync_status.dart`, `lib/app/`, `firestore.rules`, `firestore.indexes.json`, `test/cellar/`, `test/rules/u4.rules.test.mjs`, `tool/`, `.github/workflows/ci.yml` e `promote.yml`, `integration_test/`, `docs/release-checklist.md`.
- Tests: circa 130 test di Dart (unit, repository, provider e schermate nelle tre lingue), circa 80 asserzioni sulle regole nell'emulatore, 2 test end-to-end, 1 benchmark, 1 test di script.

Fonti:
- Functional Design di U4: `functional-spec.md` (BR1.1–BR1.20), `rules.md`, `frontend-components.md`;
- NFR Requirements: `performance-requirements.md`, `security-requirements.md`, `tech-stack-decisions.md`;
- NFR Design: `logical-components.md`, `security-design.md`, `performance-design.md`;
- Infrastructure Design: `infrastructure-specification.md`, `monitoring-design.md`, `cicd-pipeline.md`;
- `contract-summary.md` (C3 con le aggiunte di U4), `unit-of-work.md`, `requirements.md`, `stories.md`.

Storie: US2.1, US2.3, US3.1–US3.4, US4.1, US4.2, US6.1, US6.2, US7.1, US9.1, US9.2.

US2.2 (aggiunta da foto) è di U6 e non è in questo piano.

Strati testabili:
- **modello dei dati:** nucleo puro di `lib/cellar/domain/` e campi nuovi di `Wine`;
- **accesso ai dati:** regole cloud, indice, repository dei vini e delle bevute, backfill, riconciliazione, `PendingWritesProbe`;
- **logica:** provider, `EstimateRefresher`, ricalcolo del riscontro;
- **interfaccia:** schermate della Cantina, del dettaglio, della modifica, dello Storico, dialoghi e integrazione con il Cruscotto.

## File dell'utente toccati da questo lavoro

- **Regole e indici:** `firestore.rules`, `firestore.indexes.json`.
- **Test delle regole:**
  - `test/rules/compat/app-writes.json`: nuova versione `u4-cellar` con `requiresRules: "cellar"`;
  - `package.json`: `test:rules` con `u4.rules.test.mjs`.
- **CI e workflow:**
  - `.github/workflows/ci.yml`: job `analyze`, `unit`, `rules`;
  - `.github/workflows/promote.yml`: `RULES_FEATURES: sharing cellar`.
- **Strumenti:**
  - `tool/check_firestore_indexes.sh` e il suo test, con le cartelle di prova;
  - nuovi: `tool/check_rule_ids.sh`, `tool/check_rule_ids_test.sh`, `tool/fixtures/rule_ids/`.
- **Codice di U1:**
  - `lib/cellar/domain/wine.dart`, `wine_draft.dart`, `quantity.dart`;
  - `lib/cellar/data/wine_repository.dart` (`watchWines` → `watchCellarWines`);
  - `lib/cellar/ui/cellar_screen.dart`, `add_wine_screen.dart`, `wine_list_tile.dart`, `quantity_stepper.dart`;
  - `lib/sync/sync_status.dart` (`SyncSource.drinkingRecords`, `setPending`);
  - `lib/app/providers.dart`, `lib/app/home_shell.dart`.
- **Codice di U5:** `lib/dashboard/` solo per collegare `onOpenWine`, `onOpenStatus` e `onAddFirstWine` (BR1.17).
- **Codice di U7:** nessuna modifica prevista. La cantina attiva si legge da `activeCellarProvider`.
- **Traduzioni:** `lib/l10n/*.arb` (it, en, pt-BR).
- **Test esistenti di U1, U5 e U7:** dove cambia `watchWines` in `watchCellarWines`, e dove l'elenco ora esclude i vini finiti.
- **Test end-to-end:** nuovi `integration_test/cellar_test.dart`, `integration_test/concurrent_drink_test.dart` e `integration_test_perf/cellar_perf_test.dart`, quest'ultimo fuori dalla CI.
- **Benchmark:** nuovo `benchmark/cellar_benchmark.dart`.
- **Documenti:** `docs/release-checklist.md` (§1-quinquies, §2, §3, §4, §5).
- **Dipendenze:** nessuna nuova (`tech-stack-decisions.md`).

## Steps

### Step 1 — Struttura e configurazione — [x]
- [x] Cartelle `lib/cellar/domain/`, `lib/cellar/data/` e `lib/cellar/ui/` (esistenti, da estendere), `test/cellar/domain/`, `test/cellar/data/`, `test/cellar/ui/`, `tool/fixtures/rule_ids/`.
- [x] Nessuna dipendenza nuova: si usano `cloud_firestore`, `flutter_riverpod`, `shared_preferences`, `mocktail` e il pacchetto `estimation` già presenti.
- Traccia: `logical-components.md`; `tech-stack-decisions.md`.

### Step 2 — Runner dei test — [x]
- [x] `test/cellar/cellar_harness.dart`:
  - repository finti con `mocktail`;
  - `WineCatalog` finto;
  - `ErrorSink` finto;
  - rete finta con `onChanged`;
  - `SharedPreferences.setMockInitialValues`;
  - fabbrica di vini e bevute di prova.
- [x] Comandi in `unit-test-instructions.md`: `flutter test test/cellar` e `npm run test:rules`.

### Step 3 — Modello dei dati: implementazione — [x]
- [x] `lib/cellar/domain/wine.dart`: campi `matchKey`, `baseWindow`, `windowAdjustment` (`kind`, `year`, `recordId`), letti senza mai lanciare.
- [x] `lib/cellar/domain/drinking_record.dart`: `DrinkingRecord` con `condition` (`tooYoung`, `justRight`, `pastPeak`) e `updatedAt`.
- [x] `lib/cellar/domain/wine_validator.dart`: nome, produttore, annata e quantità, con un errore per campo (BR1.3).
- [x] `lib/cellar/domain/match_key.dart`: `matchKeyOf(name, producer, vintage)` con `normalizeWineText`, al più 400 caratteri (BR1.4).
- [x] `lib/cellar/domain/window_adjuster.dart`, puro:
  - `effective(base, adjustment)` con le regole di BR1.12;
  - fiducia abbassata di un livello;
  - etichetta della fonte "stima corretta dalle tue bevute";
  - scelta del riscontro valido (`drankOn`, poi `createdAt`).
- [x] `lib/cellar/domain/quantity_delta.dart`: `forIncrease(stored, n) = n − min(0, stored)` e `canDecrease(stored)` (BR1.15).
- [x] `lib/cellar/domain/cellar_filter.dart`:
  - ricerca senza maiuscole e accenti su nome e produttore;
  - filtri per stato e per famiglia;
  - ordinamento (BR1.8).
- [x] `lib/cellar/domain/producer_options.dart`: produttori del catalogo e delle cantine, più l'ultima voce "Aggiungi «testo» come nuovo produttore" (BR1.2).
- Traccia: BR1.2–BR1.4, BR1.8, BR1.12, BR1.15; NFR2.4, NFR4.1, NFR6.2; C3.

### Step 4 — Modello dei dati: test — [x]
- [x] `test/cellar/domain/`:
  - `wine_validator_test.dart`, `match_key_test.dart`, `window_adjuster_test.dart`, `quantity_delta_test.dart`, `cellar_filter_test.dart`, `producer_options_test.dart`, `drinking_record_test.dart`;
  - un test per regola, con l'ID nel nome (`BR1.x`), più i valori al limite: 120 e 121 caratteri, annata 1900 e anno corrente, chiave di 400 caratteri, quantità salvate −2, 0 e 3;
  - ogni caso di BR1.12: `justRight` dopo la fine, `pastPeak` dentro la finestra e prima dell'inizio, `tooYoung` dopo l'inizio, nessun riscontro;
  - mappe incomplete o con tipi sbagliati.
- [x] `test/cellar/wine_test.dart` aggiunge i campi nuovi.
- [x] Eseguire `flutter test test/cellar`.

### Step 5 — Accesso ai dati: implementazione — [x]
- [x] `firestore.rules` come in `security-design.md` §1:
  - `validWindow`, `validAdjustment`, `validMatchKey`;
  - `validRating`, `validNotes`, `validDrankOn`, `validCondition`;
  - `validDrinkingRecord` completa;
  - caso di update del backfill;
  - update e delete delle bevute (10 minuti, `resource != null`);
  - flag `matchKeyBackfill` della cantina;
  - campi facoltativi letti con `get(…, null)`.
- [x] `firestore.indexes.json`: composito su `drinkingRecords` (`drankOn` DESC, `createdAt` DESC, `COLLECTION`).
- [x] `lib/cellar/data/wine_repository.dart`:
  - `watchCellarWines(cellarId)` con `where quantity > 0`, al posto di `watchWines`;
  - `watchWine(id)`, `findByMatchKey` (server e cache, tempo massimo 1 s);
  - `addWine`, `addBottles`, `updateWine`, `setEstimate`;
  - `deleteWineWithRecords` a parti di 400, con un nuovo tentativo e poi la voce `purgeRecords`;
  - `mergeInto`, solo per il proprietario e solo se il vino più recente non ha bevute (BR1.20);
  - tutte le quantità passano da `QuantityDelta` e `FieldValue.increment`.
- [x] `lib/cellar/data/drinking_record_repository.dart`:
  - `drink`: batch con −1 e la bevuta;
  - `undo`: lettura dalla cache, `nothingToUndo`, rifiuto con `cellar_undo_failed` senza `reportWriteRejected`;
  - `updateRecord`: un cambio di `condition` o `drankOn` fa ripartire il ricalcolo;
  - `pageHistory(after, 30)`, `recordsOfWine(wineId)`.
- [x] `lib/cellar/data/match_key_backfill.dart`: una volta per cantina, batch da 400, poi il flag.
- [x] `lib/cellar/data/record_reconciler.dart`:
  - chiave `cellar.pending.<uid>`;
  - operazioni `reapplyAdjustment` e `purgeRecords`;
  - al più 50 voci, scadenza dopo 7 giorni;
  - ripiego in memoria senza `shared_preferences`.
- [x] `lib/cellar/data/pending_writes_probe.dart`: `waitForPendingWrites()`, controllo all'avvio con attesa di 300 ms, motivo `pending_probe_failed`.
- [x] `lib/sync/sync_status.dart`: `SyncSource.drinkingRecords` e `setPending(source, bool)`, che non conta come passaggio da cache a server.
- [x] Motivi fissi degli errori (`security-design.md` §2), senza nome, produttore, denominazione o note.
- Traccia: BR1.4, BR1.7, BR1.10, BR1.11, BR1.13–BR1.16, BR1.19, BR1.20; NFR4.1–NFR4.9, NFR5.1–NFR5.5, NFR6.1–NFR6.6, NFR8.1, NFR8.2; C3.

### Step 6 — Accesso ai dati: test — [x]
- [x] `test/rules/u4.rules.test.mjs`:
  - forme di `window`, `baseWindow` e `windowAdjustment` valide e non valide;
  - `matchKey` al limite;
  - backfill concesso solo con `matchKey` e solo con `canEdit`;
  - bevute: create con `condition`, update da chi le ha registrate o dal proprietario, campi non ammessi rifiutati;
  - delete entro 10 minuti (con `createdAt` nel passato tramite `withSecurityRulesDisabled`), del proprietario, e di un documento già cancellato rifiutata;
  - flag della cantina da assente o `false` a `true`, ma non al contrario;
  - eliminazione dei vini solo del proprietario;
  - lettura con `canReadCellar`.
- [x] `test/rules/compat/app-writes.json`: versione `u4-cellar` con `requiresRules: "cellar"`, comprese le scritture che dipendono da un vino creato con `matchKey`.
- [x] `package.json`: `test:rules` aggiunge `u4.rules.test.mjs`.
- [x] `test/cellar/data/`:
  - `wine_repository_test.dart`, `drinking_record_repository_test.dart`, `match_key_backfill_test.dart`, `record_reconciler_test.dart`, `pending_writes_probe_test.dart`;
  - batch composti correttamente;
  - `increment` con le correzioni dei negativi;
  - eliminazione a parti con il nuovo tentativo;
  - `undo` senza nulla da annullare e con il rifiuto;
  - voci della riconciliazione: idempotenti, scadute, oltre 50;
  - nessun marcatore sensibile nel `ErrorSink`.
- [x] Test di U1, U5 e U7 aggiornati per `watchCellarWines` e per l'elenco senza vini finiti; test di `sync_status` per `setPending`.
- [x] Eseguire `npm run test:rules`, che richiede Java per l'emulatore, e `flutter test test/cellar test/u1 test/dashboard test/sharing`.

### Step 7 — Logica: implementazione — [x]
- [x] `lib/cellar/cellar_providers.dart`:
  - `winesStreamProvider` con `quantity > 0`;
  - `wineProvider`;
  - `archivedWinesProvider`, letto solo all'apertura di "Bevuti";
  - `historyPagerProvider`, a pagine di 30;
  - `wineSuggestionsProvider` con un'attesa di 250 ms;
  - `cellarFilterProvider`.
- [x] `lib/cellar/estimate_refresher.dart`: coda di al più 20 vini per ritorno della rete, uno per volta, solo con `canEdit`, in try/catch per vino (BR1.6, BR1.19).
- [x] Ricalcolo del riscontro (BR1.12) dopo bevuta con `condition`, `updateRecord` e `undo`. Fuori rete, crea la voce `reapplyAdjustment`.
- [x] Avvio di `MatchKeyBackfill`, `RecordReconciler` ed `EstimateRefresher` all'apertura della cantina e a `NetworkStatus.onChanged(true)`.
- [x] `lib/app/providers.dart`: collegamento di `PendingWritesProbe` a `SyncStatusTracker`.
- Traccia: BR1.5, BR1.6, BR1.7, BR1.12, BR1.16, BR1.19; NFR1.2, NFR5.3, NFR5.4, NFR6.4, NFR6.6.

### Step 8 — Logica: test — [x]
- [x] `test/cellar/cellar_providers_test.dart`, `estimate_refresher_test.dart`, `adjustment_flow_test.dart`:
  - elenco senza vini finiti, archivio caricato solo su richiesta;
  - pagine dello Storico e cursore;
  - suggerimenti con l'attesa (`fakeAsync`);
  - coda delle stime: limite di 20, nessuna scrittura senza `canEdit`, errore su un vino che non ferma gli altri;
  - riscontro applicato, annullato e cambiato dallo Storico;
  - offline con la voce in coda;
  - avvio di backfill e riconciliazione.
- [x] Eseguire `flutter test`, cioè tutta la suite.

### Step 9 — Interfaccia: implementazione — [x]
- [x] `lib/cellar/ui/`:
  - `CellarScreen`: ricerca, filtri, voce "Bevuti";
  - `AddWineScreen`: nome attivo all'apertura, suggerimenti, nuovo produttore;
  - `WineDetailScreen`: finestra, stato, fiducia, fonte, abbinamenti, avviso sulla stima, ultime 3 bevute, `DuplicateBanner`;
  - `EditWineScreen`;
  - `HistoryScreen`, con "Aggiungi di nuovo";
  - `DrinkingRecordSheet` ("Com'era?", voto, note, data);
  - `DuplicateDialog`, `DeleteWineDialog`, `DrinkSnackBar` (6 s, 10 s con l'accessibilità).
  
  I comandi seguono il permesso: lettura, modifica, proprietario.
- [x] `lib/app/home_shell.dart`: terza scheda Storico; collegamenti dal Cruscotto (BR1.17).
- [x] Semantica come in `security-design.md` §3; chiavi di prova (`Key`) sugli elementi interattivi.
- [x] Chiavi di traduzione in it, en e pt-BR; `flutter gen-l10n`.
- Traccia: BR1.1–BR1.3, BR1.8–BR1.11, BR1.13, BR1.14, BR1.16–BR1.18, BR1.20; NFR1.1, NFR2.2, NFR2.3, NFR3.1–NFR3.4.

### Step 10 — Interfaccia: test — [x]
- [x] `test/cellar/ui/`, nelle tre lingue:
  - `cellar_screen_test.dart`, `add_wine_screen_test.dart` (percorso minimo con 3 tocchi), `wine_detail_screen_test.dart`, `edit_wine_screen_test.dart`, `history_screen_test.dart`, `dialogs_test.dart`, `drink_snack_bar_test.dart`;
  - stati: vuoto, offline, errore, permesso di lettura;
  - doppione e unione;
  - semantica delle stelle;
  - guideline di contrasto e tocchi;
  - `textScaler` 2.0 senza overflow.
- [x] Test del Cruscotto per i tre collegamenti.
- [x] Eseguire `flutter test`.

### Step 11 — Strumenti, CI e workflow — [x]
- [x] `tool/check_firestore_indexes.sh`:
  - controlla anche l'indice di `drinkingRecords`, con un messaggio per indice;
  - `ok.json` aggiornato;
  - `missing.json` fallisce ancora sul messaggio di `members`;
  - nuovo `missing_history.json`.
- [x] Nuovi `tool/check_rule_ids.sh` e `tool/check_rule_ids_test.sh`, con le cartelle `tool/fixtures/rule_ids/ok/` e `missing_br1_1/`; `BR1.10` non conta come `BR1.1`.
- [x] `.github/workflows/ci.yml`:
  - `analyze`: i due script delle regole;
  - `unit`: `tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/` e `dart run benchmark/cellar_benchmark.dart`.
- [x] `.github/workflows/promote.yml`: `RULES_FEATURES: sharing cellar`.
- [x] `benchmark/cellar_benchmark.dart`, solo con moduli senza Flutter: filtri ≤ 20 ms e finestra effettiva ≤ 5 ms su 500 vini.
- [x] `integration_test/cellar_test.dart`: inserimento, doppione, bevuta e Annulla, Storico, ultima bottiglia offline con il banner "in attesa".
- [x] `integration_test/concurrent_drink_test.dart`: due bevute contemporanee sullo stesso vino.
- [x] `integration_test_perf/cellar_perf_test.dart`, fuori dalla CI.
- [x] Eseguire:
  - `dart format --output=none --set-exit-if-changed .` e `flutter analyze --fatal-infos`;
  - `npm run test:rules` e gli script;
  - `dart run tool/gen_coverage_helper.dart`, `flutter test --coverage`, la copertura di progetto e quella di `lib/cellar/`;
  - il benchmark.
  
  I test end-to-end richiedono gli emulatori: si eseguono in Build and Test, oppure qui se sono disponibili.

### Step 12 — Documentazione e tracciabilità — [x]
- [x] `docs/release-checklist.md`: §1-quinquies Cantina, §2 Data Safety, §3 indice "Abilitato", §4 rollback delle regole solo prima della promozione, §5 controllo mensile.
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
