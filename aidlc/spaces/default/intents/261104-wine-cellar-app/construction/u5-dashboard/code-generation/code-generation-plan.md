# Code Generation Plan — u5-dashboard

Fonti:
- Functional Design di U5: `functional-spec.md`, `rules.md`, `frontend-components.md`;
- NFR Requirements: `performance-`, `security-`, `tech-stack-decisions.md`;
- NFR Design: `logical-components.md`, `performance-design.md`, `security-design.md`;
- Infrastructure Design: `infrastructure-specification.md`, `monitoring-design.md`, `cicd-pipeline.md`;
- `contract-summary.md` (C2, C3), `unit-of-work.md`, `requirements.md`.

U5 è il Cruscotto dentro l'app (`lib/dashboard/`), in sola lettura. Si compone di:
- un nucleo puro, `lib/dashboard/domain/`, con il calcolo e i modelli di vista;
- i provider Riverpod;
- i widget.

Diventa la prima schermata dopo l'accesso, con una barra di navigazione Cruscotto/Cantina. Storie: US5.1, US5.2 (FR5.1–FR5.6).

Gli strati testabili che si applicano sono:
- **modello dei dati**: lettura dei nuovi campi di `Wine`, `DashboardSummary`;
- **logica**: `DashboardCalculator`, `todayProvider`, `dashboardSummaryProvider`, registratore;
- **interfaccia**: schermata, card, grafici, shell.

Non si applicano l'accesso ai dati, perché U5 riusa i repository di U1 senza scrivere, né le API.

## File dell'utente toccati da questo lavoro

- `lib/cellar/domain/wine.dart` (U1): campi facoltativi in sola lettura `producer`, `wineType`, `region`, `denomination`, `window` e mapper che non lancia mai.
- `lib/account/ui/account_gate_view.dart` (U1): `GateEnsureCellar` e `GateCellar` mostrano `HomeShell`.
- `lib/app/home_shell.dart` (nuovo, U1): `NavigationBar` e `IndexedStack` con Cruscotto e Cantina.
- `lib/app/theme.dart` (U1): `ThemeExtension` `StatusColors`.
- `lib/firebase/firebase_env.dart` (U1): costante `kIsPerfBuild`.
- File di traduzione `lib/l10n/*.arb` (it, en, pt-BR): chiavi del cruscotto con i plurali ICU.
- `pubspec.yaml`, `pubspec.lock`: `shared_preferences` come dipendenza diretta, se non lo è già.
- Test di U1 che aprivano l'elenco come prima schermata: `test/` del gate e della cantina, `integration_test/u1_skeleton_test.dart`, `integration_test/force_stop_queue.dart`, `integration_test/e2e_helpers.dart`, `tool/e2e_force_stop.sh`. Passano dalla scheda "Cantina".
- `tool/check_release_build.sh`: marcatore `VINOOZY_DASHBOARD_READY`; la build di controllo passa a `E2E=true` più `PERF=true`.
- `.github/workflows/ci.yml`: script di sola lettura nel job `analyze`; copertura di `lib/dashboard/` e benchmark nel job `unit`.
- `docs/release-checklist.md`: §1-ter Cruscotto e riga del controllo mensile.

## Steps

### Step 1 — Struttura e configurazione — [x]
- [x] Cartelle `lib/dashboard/domain/` e `lib/dashboard/ui/`, `test/dashboard/`, `tool/fixtures/dashboard_readonly/`.
- [x] `shared_preferences` in `pubspec.yaml` se manca, poi `flutter pub get`.
- [x] `kIsPerfBuild = bool.fromEnvironment('PERF')` in `lib/firebase/firebase_env.dart`.
- Traccia: `logical-components.md`; `infrastructure-specification.md` §1.

### Step 2 — Runner dei test — [x]
- [x] Cartella `test/dashboard/` con i generatori di vini sintetici in `test/dashboard/fixtures.dart`.
- [x] Comando in `unit-test-instructions.md`: `flutter test test/dashboard`.

### Step 3 — Modello dei dati: implementazione — [x]
- [x] `lib/cellar/domain/wine.dart`:
  - campi facoltativi `producer`, `wineType`, `region`, `denomination` (stringhe, altrimenti `null`) e `window` (`DrinkingWindow?`);
  - `_windowFrom` restituisce `null` se `window` non è una mappa o se `startYear`, `peakYear` o `endYear` mancano o non sono interi;
  - `confidence` e `source` si leggono per nome, con `low` e `internalRules` come valori di riserva;
  - `basis` si legge per nome, altrimenti `EstimationBasis.resolveStoredBasis`.
- [x] `lib/dashboard/domain/dashboard_summary.dart`, con uguaglianza per valore:
  - `DashboardSummary`: totale, quattro conteggi di stato, `toEstimate`, `drinkSoon` (fino a 10) e `drinkSoonTotal`, colonne dei picchi, `byType`, `byRegion` (fino a 8 più "altre"), `invalidWindowCount`;
  - `DrinkSoonRow`, `PeakYearBar`, `BreakdownBar`.
- Traccia: `functional-spec.md` (Interfacce usate, C3); BR1.1–BR1.6; NFR4.1, NFR6.1.

### Step 4 — Modello dei dati: test — [x]
- [x] `test/cellar/wine_test.dart` (esteso): campi nuovi letti; `window` assente, non mappa, incompleta, con anni di tipo sbagliato, con `confidence`, `source` o `basis` sconosciuti; nessuna eccezione in nessun caso.
- [x] `test/dashboard/dashboard_summary_test.dart`: uguaglianza e `hashCode`.
- [x] Eseguire `flutter test test/cellar test/dashboard`.

### Step 5 — Logica: implementazione — [x]
- [x] `lib/dashboard/domain/dashboard_calculator.dart`:
  - `compute(wines, today)`, puro e in un solo passaggio;
  - try/catch su `statusOf` per singolo vino, con `invalidWindowCount`;
  - quantità negative uguali a 0, tipologia sconosciuta come "non indicata";
  - normalizzazione di tipologia e regione, con la regione ricavata da `recognizeDenomination` e memorizzata per denominazione;
  - ordinamenti BR1.3–BR1.6.
- [x] `lib/dashboard/today_provider.dart`: data da `clockProvider`; `Timer` fino a `DateTime(y, m, d + 1)`, riprogrammato a ogni scatto; `AppLifecycleListener` per il ritorno in primo piano; il timer si cancella in `ref.onDispose`.
- [x] `lib/dashboard/dashboard_event_logger.dart`:
  - interfaccia `DashboardEventLogger.invalidWindow()`;
  - `DashboardInvalidWindow`, con il messaggio fisso `dashboard_invalid_window: estimation_error=invalidWindow`;
  - implementazione su `ErrorReporter`, al massimo un evento per processo;
  - `dashboardEventLoggerProvider`, senza `autoDispose`.
- [x] `lib/dashboard/dashboard_providers.dart`:
  - `dashboardSummaryProvider(uid)`, che usa `winesStreamProvider(Cellar.personalCellarId(uid))`, `cellarStreamProvider(uid)` e `todayProvider`;
  - stati caricamento, sincronizzazione (`isFromCache`), errore, vuoto e dati, con la chiamata al registratore;
  - `breakdownModeProvider`, salvato in `shared_preferences` con la chiave `dashboard.breakdownMode` e "Tipologia" come valore di riserva.
- Traccia: BR1.1–BR1.9; NFR2.2, NFR2.3, NFR6.1–NFR6.4, NFR8.1.

### Step 6 — Logica: test — [x]
- [x] `test/dashboard/dashboard_calculator_test.dart`: un test per regola con l'ID nel nome (BR1.1–BR1.9), più:
  - vini rovinati, quantità negative, tipologie strane, regioni da denominazione;
  - un caso con 500 vini;
  - il limite di 10 righe con "Vedi tutti" e il limite di 8 regioni con "altre".
- [x] `test/dashboard/today_provider_test.dart`: passaggio della mezzanotte, ritorno in primo piano, giorni del cambio dell'ora legale in Europa/Roma (orologio finto).
- [x] `test/dashboard/dashboard_providers_test.dart`:
  - un calcolatore finto conta le chiamate: il cambio del selettore non ne produce (NFR2.3);
  - stati di caricamento, sincronizzazione, errore, vuoto e dati;
  - preferenza assente o non valida.
- [x] `test/dashboard/dashboard_event_logger_test.dart`: anni e nome marcatori non arrivano al `ErrorSink` finto; una sola chiamata anche dopo due ricalcoli.
- [x] Eseguire `flutter test test/dashboard`.

### Step 7 — Interfaccia: implementazione — [x]
- [x] `lib/app/theme.dart`: `StatusColors` (`waiting`, `ready`, `drinkSoon`, `pastWindow`, neutro) in tema chiaro e scuro, registrata in `ThemeData.extensions`.
- [x] `lib/dashboard/ui/`:
  - `DashboardScreen`, che riceve `user`, `setup`, `onRetrySetup`, `onOpenWine`, `onOpenStatus` e `onAddFirstWine`;
  - `DashboardContent` (`CustomScrollView`, chiave `dashboard-content`, segnale `VINOOZY_DASHBOARD_READY` solo se `kIsPerfBuild`);
  - `DrinkSoonSection`, `StatusChartCard`, `PeakYearChartCard`, `BreakdownChartCard`, `BarChart`;
  - `statusIcons` condivise;
  - semantica: contenitori, `ExcludeSemantics` per titoli e numeri, barre figlie con ruolo di pulsante;
  - aree di tocco di 48 dp e scorrimento orizzontale con testo grande;
  - stati di preparazione, errore con "Riprova", sincronizzazione con "Aggiungi il primo vino", vuoto.
- [x] `lib/app/home_shell.dart` e `lib/account/ui/account_gate_view.dart`:
  - `HomeShell` con `NavigationBar` e `IndexedStack`;
  - `onAddFirstWine` apre `AddWineScreen`;
  - `onOpenWine` e `onOpenStatus` portano alla scheda Cantina.
- [x] Chiavi di traduzione in it, en e pt-BR, con i plurali; `flutter gen-l10n`.
- Traccia: FR5.1–FR5.6; BR1.3–BR1.8; NFR3.1–NFR3.5, NFR6.2, NFR6.3, NFR7.5.

### Step 8 — Interfaccia: test — [x]
- [x] `test/dashboard/dashboard_screen_test.dart`, nelle tre lingue:
  - tutti gli stati;
  - le azioni iniettate;
  - semantica (`tester.getSemantics`, un solo nodo per card);
  - `textContrastGuideline`, `androidTapTargetGuideline` e `labeledTapTargetGuideline`;
  - `textScaler` 2.0 senza overflow;
  - un cambio del selettore ricostruisce solo la terza card.
- [x] `test/app/status_colors_test.dart`: contrasto WCAG delle barre ≥ 3:1 e del testo ≥ 4,5:1, in tema chiaro e scuro.
- [x] `test/app/home_shell_test.dart` e test del gate aggiornati: `GateEnsureCellar` e `GateCellar` mostrano `HomeShell` e passano `setup` e `onRetrySetup`.
- [x] I test di U1 sulla cantina si aggiornano per passare dalla scheda "Cantina".
- [x] Eseguire `flutter test`, cioè tutta la suite.

### Step 9 — Strumenti, CI e prestazioni — [x]
- [x] `tool/check_dashboard_readonly.sh`, con la cartella come argomento: import vietati, provider di scrittura, purezza di `domain/`, `shared_preferences` solo in `dashboard_providers.dart`.
- [x] `tool/check_dashboard_readonly_test.sh`, con le cartelle `tool/fixtures/dashboard_readonly/ok/` e `bad/`. Le cartelle di prova sono escluse da `flutter analyze` in `analysis_options.yaml` se contengono `.dart` non compilabile.
- [x] `tool/check_release_build.sh`: marcatore `VINOOZY_DASHBOARD_READY`; controllo positivo con `E2E=true` più `PERF=true`; restano due build.
- [x] `benchmark/dashboard_benchmark.dart`: 500 vini, mediana di 10 dopo 3 di riscaldamento, una ripetizione, soglia 10 ms, `exit(1)`.
- [x] `.github/workflows/ci.yml`:
  - job `analyze`: i due script;
  - job `unit`: `tool/check_coverage.sh 80 coverage/lcov.info lib/dashboard/` e il benchmark.
- [x] Test e2e:
  - `integration_test/dashboard_500_test.dart` (utente `userDashboard`, una sola `:commit` da 500 scritture, attesa massima di 60 s, pulizia finale);
  - lo scheletro, `force_stop_queue.dart` e `tool/e2e_force_stop.sh` passano dalla scheda "Cantina".
- [x] Misure sul telefono:
  - `integration_test_perf/dashboard_seed.dart`;
  - `integration_test_perf/dashboard_perf_test.dart` (scorrimento e `compute` ≤ 25 ms);
  - `tool/perf_cold_start.sh` (`adb reverse`, `EMULATOR_HOST=127.0.0.1`, `--remove-all`, `svc wifi/data`, `trap`, 5 avvii).
- [x] Eseguire:
  - gli script e il benchmark;
  - `dart format --output=none --set-exit-if-changed .` e `flutter analyze --fatal-infos`;
  - `dart run tool/gen_coverage_helper.dart`, `flutter test --coverage`, la copertura di progetto e quella di `lib/dashboard/`.

  I test e2e richiedono gli emulatori: si eseguono in Build and Test, oppure qui se l'emulatore Android è disponibile.

### Step 10 — Documentazione e tracciabilità — [x]
- [x] `docs/release-checklist.md`: §1-ter Cruscotto e riga del controllo mensile per `dashboard_invalid_window`.
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
