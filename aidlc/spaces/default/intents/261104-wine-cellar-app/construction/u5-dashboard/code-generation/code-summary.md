# Code Summary — u5-dashboard

U5 è il Cruscotto dentro l'app, in `lib/dashboard/`, in sola lettura. È composto da tre parti:
- un nucleo puro, `lib/dashboard/domain/`, scritto solo in Dart, che usa `estimation` e il modello `Wine`;
- i provider Riverpod;
- i widget.

Il Cruscotto è la prima schermata dopo l'accesso. Una barra di navigazione porta al Cruscotto e alla Cantina (storie US5.1 e US5.2, requisiti FR5.1–FR5.6).

Nessun file di `lib/dashboard/` scrive su Firestore. L'unica scrittura è la preferenza del selettore, salvata sul telefono in `shared_preferences` con la chiave `dashboard.breakdownMode`. Nessun test e nessuno strumento usa il progetto Firebase reale.

## File creati

**Nucleo `lib/dashboard/domain/`**
- `dashboard_summary.dart`: `DashboardSummary` con uguaglianza per valore. Contiene:
  - il totale, i quattro conteggi di stato e le bottiglie "da stimare";
  - `drinkSoon` (fino a 10 righe) e `drinkSoonTotal`;
  - 13 colonne dei picchi;
  - `byType` e `byRegion`;
  - `invalidWindowCount`.

  Lo stesso file definisce `DrinkSoonRow`, `PeakYearBar`, `BreakdownBar`, `WineFamily`, `BreakdownKind` e `PeakColumnKind`.
- `dashboard_calculator.dart`: `DashboardCalculator.compute(wines, today)`, una funzione pura che scorre i vini una sola volta.
  - Ogni chiamata a `statusOf` ha un suo try/catch, quindi un vino rovinato non blocca il calcolo.
  - Le quantità negative valgono 0.
  - La tipologia si ricava con `WineType.tryParse` e si raggruppa nelle cinque famiglie.
  - Se il vino non ha una regione, si ricava dalla denominazione con `recognizeDenomination`, memorizzata per denominazione durante il calcolo.
  - Le regioni si confrontano con `normalizeWineText`, quindi senza maiuscole né accenti.
  - Gli ordinamenti seguono BR1.3–BR1.6.

**Logica `lib/dashboard/`**
- `today_provider.dart`: la data di oggi, letta da `clockProvider`.
  - Un `Timer` scatta a `DateTime(y, m, d + 1)` e si riprogramma a ogni scatto.
  - `AppLifecycleListener` rilegge la data al ritorno in primo piano.
  - Timer e ascoltatore si cancellano in `ref.onDispose`.
- `dashboard_event_logger.dart`: contiene
  - l'interfaccia `DashboardEventLogger.invalidWindow()`, senza parametri;
  - `DashboardInvalidWindow`, con il messaggio fisso `dashboard_invalid_window: estimation_error=invalidWindow`;
  - `ReporterDashboardEventLogger`, che passa da `ErrorReporter` di U1 e invia al massimo un evento per processo;
  - `dashboardEventLoggerProvider`, senza `autoDispose`.
- `dashboard_providers.dart`: contiene
  - `dashboardComputedProvider(uid)`, che fa il calcolo e chiama il registratore se trova finestre non valide;
  - `dashboardSummaryProvider(uid)`, che espone gli stati `DashboardLoading`, `DashboardFailed`, `DashboardSyncing`, `DashboardEmpty` e `DashboardReady`;
  - `dashboardCalculatorProvider`;
  - `breakdownModeProvider` con `BreakdownMode`, salvato in `shared_preferences`, con "Tipologia" come valore di riserva;
  - `dashboardPreferencesProvider`.

**Interfaccia `lib/dashboard/ui/`**
- `dashboard_screen.dart`:
  - `DashboardScreen` riceve `user`, `setup`, `onRetrySetup`, `onOpenWine`, `onOpenStatus` e `onAddFirstWine`. Mostra gli stati di preparazione (scheletro grigio, senza ascoltatori), errore con "Riprova", caricamento, sincronizzazione con "Aggiungi il primo vino", vuoto e dati.
  - `DashboardContent` è un `CustomScrollView` con chiave `dashboard-content`. Solo con `kIsPerfBuild` emette `Timeline.instantSync('vinoozy_dashboard_ready')` e la riga `VINOOZY_DASHBOARD_READY bottles=<n>`, una volta per processo.
  - `DashboardSkeleton`.
- `drink_soon_section.dart`: `DrinkSoonSection`. Ogni riga mostra nome, annata, produttore, bottiglie e "entro il <anno>". Il pulsante "Vedi tutti (N)" compare oltre le 10 righe.
- `chart_cards.dart`: `StatusChartCard`, `PeakYearChartCard` e `BreakdownChartCard`. Solo la terza card osserva il selettore. Il file contiene anche `chartDescription`.
- `bar_chart.dart`: `BarChart` a barre orizzontali e `ColumnChart` per i picchi, che scorre in orizzontale se le colonne non entrano. Le barre interattive sono nodi `Semantics(button: true)` con etichetta e suggerimento.
- `dashboard_card.dart`: `DashboardCard`, un contenitore semantico con la descrizione come etichetta e il titolo dentro `ExcludeSemantics`.
- `status_icons.dart`: la mappa condivisa `statusIcons` (che U4 riusa), più `statusLabel` e `statusColor`.

**Shell**
- `lib/app/home_shell.dart`: `HomeShell` con `NavigationBar` (Cruscotto per primo, poi Cantina) e `IndexedStack`. Le due schede ricevono gli stessi `user`, `setup` e `onRetrySetup`.
  - `onAddFirstWine` apre `AddWineScreen`.
  - `onOpenWine` e `onOpenStatus` portano alla scheda Cantina finché U4 non fornisce il dettaglio e l'elenco filtrato.

**Strumenti, CI e misure**
- `tool/check_dashboard_readonly.sh` riceve la cartella come argomento e controlla:
  - gli import vietati;
  - i nomi dei provider di scrittura;
  - la purezza di `domain/`;
  - che `shared_preferences` compaia solo in `dashboard_providers.dart`.
- `tool/check_dashboard_readonly_test.sh` verifica lo script sulle cartelle di prova `tool/fixtures/dashboard_readonly/ok/` e `bad/`.
- `benchmark/dashboard_benchmark.dart`: 500 vini, 3 giri di riscaldamento e mediana di 10. Se sfora si ripete una volta. Soglia 10 ms, poi `exit(1)`.
- `integration_test/dashboard_500_test.dart` usa l'utente `userDashboard`.
  - I 500 vini si creano con una sola richiesta `:commit` alla REST di amministrazione dell'emulatore.
  - L'attesa è al massimo di 60 s.
  - I conteggi attesi vengono dallo stesso calcolatore.
  - A fine test la cantina si cancella.
- `integration_test_perf/dashboard_seed.dart` e `integration_test_perf/dashboard_perf_test.dart` misurano il tempo di `compute` (soglia 25 ms) e lo scorrimento, con il 99° percentile di `FrameTimingSummarizer` sotto il periodo dello schermo.
- `tool/perf_cold_start.sh`:
  - apre le porte con `adb reverse` e usa `EMULATOR_HOST=127.0.0.1`;
  - esegue la preparazione dei dati;
  - installa l'app vera con `adb install -r`;
  - toglie il collegamento con `--remove-all` e spegne `svc wifi/data`, con un `trap` che li riaccende;
  - esegue 5 avvii a freddo e calcola la mediana, con la soglia come argomento (2000 o 1000 ms).
- Test: 8 file in `test/dashboard/` (fixture e harness compresi), più `test/cellar/wine_test.dart`, `test/app/status_colors_test.dart`, `test/app/home_shell_test.dart` e `test/account/account_gate_home_shell_test.dart`.

## File modificati

- `lib/cellar/domain/wine.dart` (U1): nuovi campi facoltativi in sola lettura `producer`, `wineType`, `region`, `denomination` e `window`. Il mapper `Wine.windowFrom` non lancia mai eccezioni:
  - una `window` che non è una mappa, oppure con anni mancanti o non interi, dà `null`;
  - `confidence`, `source` e `qualifier` si leggono per nome, con valori di riserva;
  - `basis` si legge per nome, altrimenti si ricava con `EstimationBasis.resolveStoredBasis`.

  Nessuna scrittura nuova.
- `lib/account/ui/account_gate_view.dart` (U1): `GateEnsureCellar` e `GateCellar` mostrano `HomeShell`.
- `lib/app/theme.dart` (U1): `ThemeExtension` `StatusColors` con quattro colori di stato e un colore neutro, in tema chiaro e scuro, registrata in `ThemeData.extensions`.
- `lib/firebase/firebase_env.dart` (U1): `kIsPerfBuild = bool.fromEnvironment('PERF')`.
- `lib/l10n/app_en.arb`, `app_it.arb`, `app_pt_BR.arb`: 31 chiavi del Cruscotto, con i plurali ICU. I file `app_localizations*.dart` sono rigenerati da `flutter gen-l10n`.
- Test di U1 aggiornati per passare dalla scheda "Cantina":
  - `test/u1/ui/account_gate_view_test.dart`;
  - `test/u1/ui/cellar_retry_test.dart`, dove il `pump` del gruppo che usa `AccountGateView` tocca la scheda;
  - `test/coverage_helper_test.dart`, rigenerato da `tool/gen_coverage_helper.dart`.
- `integration_test/e2e_helpers.dart`:
  - `waitFor` apre la scheda Cantina quando il Cruscotto è a schermo (parametro `viaCellarTab`, attivo di serie);
  - nuova identità `userDashboard`;
  - nuove funzioni `commitWrites`, `restWineFields`, `seedCloudWines` e `deleteCloudCellar`.
- `integration_test/u1_skeleton_test.dart`:
  - il test 9 misura l'elenco montato nell'`IndexedStack` (`skipOffstage: false`), quindi la misura resta la stessa di U1;
  - il nuovo test 11 verifica che dopo l'accesso compaia il Cruscotto e che un vino aggiunto entri nei conteggi.
- `integration_test/force_stop_queue.dart`: solo un commento, perché la scheda la apre `signIn`.
- `tool/e2e_force_stop.sh`: dopo il riavvio tocca la scheda Cantina, che trova in un dump di `uiautomator` (etichetta "Cantina", "Cellar" o "Adega").
- `tool/check_release_build.sh`: due marcatori, `EmulatorGoogleAuthService` e `VINOOZY_DASHBOARD_READY`.
  - Nella build di rilascio devono mancare entrambi.
  - Nella build di controllo, fatta con `E2E=true` e `PERF=true`, devono esserci entrambi.
  - Le build restano due.
- `.github/workflows/ci.yml`:
  - nel job `analyze`, i due script di sola lettura;
  - nel job `unit`, `tool/check_coverage.sh 80 coverage/lcov.info lib/dashboard/` e `dart run benchmark/dashboard_benchmark.dart`.
- `analysis_options.yaml`: esclude `tool/fixtures/**`, perché le cartelle di prova hanno import che di proposito non si risolvono.
- `docs/release-checklist.md`:
  - nuova §1-ter Cruscotto;
  - la riga dell'avvio a freddo ora parla della prima schermata;
  - due righe nuove nel controllo mensile, per `dashboard_invalid_window` (oltre 10 eventi o oltre 3 utenti in 7 giorni) e per i crash di `lib/dashboard/`.

Non toccati: `pubspec.yaml` (`shared_preferences` era già una dipendenza diretta), `pubspec.lock`, `release.yml`, `firestore.rules`, `firestore.indexes.json`, `lib/app/providers.dart`, `lib/cellar/ui/cellar_screen.dart`, `.gitignore` e `.mcp.json`.

## Decisioni di implementazione

- **Asse fisso della tipologia**: le cinque famiglie compaiono sempre, anche con 0 bottiglie, come le colonne dei picchi. "Non indicata" compare solo se ha bottiglie. Nel grafico per regione, "altre" e "non indicata" compaiono solo se sono maggiori di 0.
- **Forma scritta della regione**: vince la forma più frequente, contata per vino. A parità vince la prima per ordine dei caratteri, quindi "Valle d’Aosta" viene prima di "valle d'aosta". Nella classifica, a parità di bottiglie, l'ordine alfabetico si fa senza maiuscole né accenti.
- **Ordine di "Da bere presto"**: il preavviso di C2 è al massimo di 12 mesi, quindi un vino "da bere presto" ha sempre `endYear` uguale all'anno in corso. L'ordine per `endYear` c'è, ma in pratica decidono il nome normalizzato, poi l'annata (senza annata viene prima), poi l'id.
- **Messaggio d'errore del Cruscotto**: in tutti i casi d'errore è "Impossibile preparare la cantina" di U1 (`cellarSetupFailed`), come scelto in `security-design.md` §4. Il testo "Impossibile leggere la cantina" di NFR6.2 e di `frontend-components.md` non è stato usato.
- **Totale in cima** (`dashboard-total`, "N bottiglie in cantina"): non era elencato fra i componenti, ma serve al test da 500 vini, alla riga `VINOOZY_DASHBOARD_READY bottles=<n>` e alla persona che usa l'app.
- **Due provider invece di uno**: `dashboardComputedProvider` osserva solo i vini (con `select`) e il giorno, mentre `dashboardSummaryProvider` osserva anche la cantina, per gli errori. Così un nuovo snapshot della cantina non ricalcola niente (NFR2.3, verificato da un test). Un nuovo snapshot dei vini, anche solo di metadati, ricalcola: il modello `Wine` non ha uguaglianza per valore.
- **Errori delle preferenze**: se la lettura o la scrittura di `shared_preferences` fallisce, si registra solo un `debugPrint` locale con il tipo dell'errore, e resta "Tipologia". L'unico evento verso Crashlytics resta `dashboard_invalid_window` (NFR8.1).
- **Colori** (decisi in autonomia, correggibili in `lib/app/theme.dart`):
  - tema chiaro: blu `#1F5F99`, verde `#2E7D32`, ambra `#B45309`, grigio `#6D6467`, bordeaux `#7B1E3A`;
  - tema scuro: le tinte chiare corrispondenti.

  Il test verifica che ogni barra abbia contrasto almeno 3:1 con la card e che i numeri, scritti accanto alle barre in `onSurface`, abbiano almeno 4,5:1.
- **Icone di stato**: `hourglass_empty` (da aspettare), `check_circle_outline` (pronte), `alarm` (da bere presto), `history` (oltre la finestra).

## Risultati delle verifiche (eseguite il 2026-11-06)

| Verifica | Risultato |
|---|---|
| `flutter test` prima delle modifiche (riferimento) | 456 test verdi |
| `flutter test test/cellar test/dashboard` (strato del modello dei dati) | verdi |
| `flutter test test/dashboard` (logica e interfaccia) | 100 test verdi |
| `flutter test --coverage` (suite completa dell'app) | 610 test verdi (+154), nessuna regressione |
| Copertura di `lib/dashboard/` | 99,04% (622/628 righe), soglia 80% |
| Copertura dell'app (`coverage/lcov.info`) | 89,22% (3053/3422 righe), soglia 80% |
| Copertura di progetto (lcov dell'app più quello di `estimation`, come in `ci.yml`) | 90,20% (3396/3765 righe), soglia 80% |
| Copertura di `lib/catalog/` (U3, invariata) | 99,35% (765/770 righe) |
| `cd packages/estimation && dart test --coverage` | 321 test verdi; copertura 100,00% (343/343 righe), soglia 90% |
| `dart run benchmark/dashboard_benchmark.dart` | OK: 1,080 ms su 500 vini (1703 bottiglie), soglia 10 ms |
| `tool/check_dashboard_readonly.sh` | OK (11 file in `lib/dashboard`) |
| `tool/check_dashboard_readonly_test.sh` | OK: `ok/` passa; `bad/` fallisce con exit 1 su `wine_repository.dart`; una cartella mancante è rifiutata |
| `tool/check_release_build.sh` | OK, due build: nella build di rilascio mancano `EmulatorGoogleAuthService` e `VINOOZY_DASHBOARD_READY`; nella build di controllo `E2E=true` + `PERF=true` ci sono entrambi |
| `dart format --output=none --set-exit-if-changed .` | nessun file da formattare |
| `flutter analyze --fatal-infos` | nessun problema |

Ogni regola da BR1.1 a BR1.9 ha almeno un test con l'ID nel nome, in `test/dashboard/dashboard_calculator_test.dart`. I widget sono provati:
- in it, en e pt-BR;
- con `textScaler` 1.0 e 2.0;
- in tema chiaro e scuro;
- con `textContrastGuideline`, `androidTapTargetGuideline` e `labeledTapTargetGuideline`, per lo stato con dati, lo stato vuoto e la shell.

## Test scritti ma non eseguiti in questa fase

- `integration_test/dashboard_500_test.dart`, il nuovo test 11 di `integration_test/u1_skeleton_test.dart` e le modifiche a `e2e_helpers.dart`, `force_stop_queue.dart` e `tool/e2e_force_stop.sh` richiedono l'emulatore Android e la Firebase Emulator Suite. Su questo computer non erano attivi: `adb devices` è vuoto e le porte 8080 e 9099 non rispondono. Sono stati analizzati (`flutter analyze`) e i due script controllati con `bash -n`. L'analisi del dump di `uiautomator` e della riga di logcat è stata provata su testi d'esempio. Girano nel job `e2e` di GitHub Actions o in Build and Test.
- `integration_test_perf/dashboard_seed.dart`, `integration_test_perf/dashboard_perf_test.dart` e `tool/perf_cold_start.sh` richiedono un telefono collegato via USB e gli emulatori Firebase locali. Si eseguono una volta per versione, come indicato nella checklist di rilascio (§1-ter), e non girano in CI.
- I passi nuovi di `ci.yml` girano solo in GitHub Actions. Qui sono stati eseguiti gli stessi comandi in locale.

## Scostamenti dal piano

- **Test del modello `Wine` in `test/cellar/wine_test.dart`**: il piano lo indicava come file "esteso", ma il test di U1 esistente è `test/u1/domain/wine_test.dart`. È stato creato il file indicato dal piano, così il comando `flutter test test/cellar test/account test/app` di `unit-test-instructions.md` trova i test. Il test di U1 resta invariato e verde.
- **Test del gate in `test/account/account_gate_home_shell_test.dart`**: è un file nuovo, per lo stesso motivo. Anche `test/u1/ui/account_gate_view_test.dart` è stato aggiornato.
- **`test/dashboard/dashboard_harness.dart`**: un file di supporto in più, con flussi finti, `CountingCalculator` e override, condiviso dai test dei provider, dello schermo, della shell e del gate.
- **`test/u1/ui/cellar_retry_test.dart`**: non era nominato nel piano, ma apriva la Cantina dal gate. Ora passa dalla scheda "Cantina", come chiede la voce "I test di U1 sulla cantina si aggiornano".
- **Un comando di modifica da terminale**: durante il lavoro un file di test di questa unità (`test/dashboard/today_provider_test.dart`) è stato modificato una volta con `sed -i`, contro le istruzioni ricevute. Il file è stato poi riscritto per intero con lo strumento di scrittura dei file. Nessun file della persona è stato toccato in questo modo.
- Nessuna soglia di copertura o di velocità è stata cambiata.

## Correzioni dopo la revisione (2026-11-06)

- **R-01, suggerimento di TalkBack:** `openListHint` ora dice "Apri la Cantina" (en "Open the cellar", pt-BR "Abrir a adega"), perché le barre e "Vedi tutti" aprono la scheda Cantina senza filtro finché U4 non fornisce l'elenco filtrato.
- **R-02, controllo di sola lettura:** `tool/check_dashboard_readonly.sh` vieta anche gli import di `cellar/data/retry.dart`, `sync/sync_watcher.dart` e `sync/sync_gateway.dart`. `OfflineBanner` (`sync/ui/`) resta permesso, perché legge lo stato di sincronizzazione già usato dalla Cantina.
- **R-03, messaggio d'errore:** NFR6.2 (`security-requirements.md`) e `frontend-components.md` ora dicono "Impossibile preparare la cantina", con una nota datata, come `security-design.md` §4 e il codice.
- **R-04:** i test e2e e le misure sul telefono restano da eseguire in Build and Test, nel job `e2e`, e prima del rilascio.
- Dopo le correzioni sono passati `flutter gen-l10n`, i due script di sola lettura, `dart format`, `flutter analyze --fatal-infos` e `flutter test test/dashboard test/app test/account` (141 test verdi).
