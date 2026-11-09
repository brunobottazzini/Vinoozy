# Risultati dei test — profili di stile e classificazione automatica

## Fonti

- `construction/code-generation/unit-test-instructions.md` (comandi)
- `construction/code-generation/code-summary.md` (cosa è stato costruito e scostamenti)
- `construction/nfr-requirements/` (obiettivi misurabili)
- Esecuzioni del 2026-11-09 su macOS (seconda esecuzione dopo il loop-back 1, log in `.cache/bt2/`), emulatore Android `emulator-5554` e Firebase Emulator Suite (porte 8080/9099, avviata da un'altra sessione e mai riavviata). Log in `.cache/bt/` (ignorata da git).

## Riepilogo

| Controllo | Comando | Uscita | Esito |
|---|---|---|---|
| Formattazione | `dart format --set-exit-if-changed .` | 0 | 467 file, 0 cambiati |
| Analisi dell'app | `flutter analyze --fatal-infos` | 0 | nessun problema |
| Pacchetto: analisi, test, copertura | `cd packages/estimation && dart analyze --fatal-infos && dart test --coverage=coverage && … check_coverage.sh 90` | 0 | **2011 passati, 0 falliti**; copertura **98,10%** (2730/2783), soglia 90% |
| App: test e copertura del progetto | `dart run tool/gen_coverage_helper.dart && flutter test --coverage && cat … > coverage/merged.lcov.info && tool/check_coverage.sh 80 …` | 0 | **2638 passati, 0 falliti**; copertura **89,30%** (17353/19432), soglia 80%, senza esclusioni |
| Regole esistenti e compatibilità | `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm --prefix test/rules test -- u1 u7 u4 u8 label_autofill compat/` | 0 | **215 passati, 0 falliti, 2 saltati** (scritture `requiresRules` della direzione 2, come prima) |
| Regole di questo lavoro | `… npm --prefix test/rules test -- style_profiles.rules.test.mjs` | 0 | **30/30**, compresi i budget delle 1000 espressioni |
| Benchmark del pacchetto | `dart run benchmark/estimation_benchmark.dart` | 0 | tutti OK (vedi sotto) |
| Base dei vini | `bash tool/check_wine_db_release.sh` | 0 | OK: 15.490 vini da Open Food Facts |
| Tabella delle denominazioni | `bash tool/check_appellations_release.sh` | 0 | OK: 2424 denominazioni, 1700 generate |
| Generazione della base | `time dart run tool/build_wine_db.dart --input .cache/off/en.openfoodfacts.org.products.csv.gz --output assets/wine_db --export-date 2026-11-07` | 0 | **1 min 25 s**; base identica byte per byte alla precedente (`cmp`), 15.490 vini, `classifiedTypeShare` 0,8422 |
| End-to-end | `flutter test integration_test/style_profile_flow_test.dart -d emulator-5554 --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true` | 1 | **non caricato** (vedi sotto) |

## Prestazioni (benchmark)

| Misura | Risultato | Limite |
|---|---|---|
| `classifyWine`, media su 1000 vini (NFR3.1) | 0,018 ms per vino | ≤ 5 ms |
| Stima + stato + abbinamenti di 500 vini (NFR3.2, NFR3.7) | 6,80 ms | ≤ 10 ms |
| Secondo blocco di 500 stime rispetto al primo | −0,3% | ≤ +10% |
| Riconoscimento di 500 nomi | 2,06 ms | ≤ 4 ms |
| Migrazione di 200 vini, calcolo (NFR3.4, `estimates_migration_test.dart`) | < 1 s (test verde) | ≤ 1 s |
| Migrazione di 500 vini, calcolo (NFR3.7, `estimates_migration_test.dart`) | < 2,5 s (test verde) | ≤ 2,5 s |
| Generazione della base (NFR3.3) | 1 min 25 s (prima del loop-back 3 min 30 s) | ≤ 2 min |

## Qualità della classificazione

- Campione di 100 vini (NFR4.3): Tipologia 85/87 = 97,7% (soglia 95%), Livello 86/87 = 98,9% (soglia 85%), 10/10 vini senza indizi lasciati vuoti (`classification_sample_test.dart`, verde).
- Base spedita (FR2.1): **84,22%** con Tipologia, uguale a `classifiedTypeShare` del manifest; minimo accettato dal proprietario 84% (messaggio 2c43a871), obiettivo 90% stampato.
- Mappa (NFR4.2): 5946 combinazioni identiche alla fixture; stima che la riproduce salvo 3 eccezioni fissate per nome.

## End-to-end

Tre tentativi in questa fase, l'ultimo dopo il loop-back 1 (oltre a quelli di Code Generation). L'app si compila e si installa sull'emulatore, poi il caricamento si ferma prima del primo test:

```
00:00 +0 -1: loading …/integration_test/style_profile_flow_test.dart [E]
  Failed to load "…/style_profile_flow_test.dart": WebSocketChannelException: HttpException:
  Connection closed before full header was received, uri = http://127.0.0.1:51000/…/ws
```

Lo stesso errore colpisce anche gli e2e già esistenti (`label_test.dart`), quindi non dipende dal codice di questo lavoro: in questo ambiente il collegamento al servizio VM dell'app attraverso il port forwarding di adb non riesce. L'esecuzione fuori dalla sandbox non è stata autorizzata e non è stata aggirata. Il progetto non ha un runner di strumentazione Android (`android/app/src/androidTest`) che eviterebbe il servizio VM.

Il proprietario ha provato l'app sul telefono con le regole pubblicate (2026-11-09: "funziona benissimo"), ma prima delle correzioni della revisione (R-01–R-05), che hanno cambiato di nuovo le regole e la scrittura della modifica.

## Difetti trovati e corretti

Nessuno in questa fase. Le correzioni della revisione del codice (R-01–R-05) sono in `code-summary.md`.

## Loop-Back Log

### Loop-back 1 — 2026-11-09T00:00:00Z

- **Diagnosis**: NFR3.3 Not Met. La generazione della base dura circa 3 min 30 s, oltre il limite di 2 minuti. Quasi tutto il tempo va nella lettura dei 4,9 milioni di righe dell'export compresso, perché ogni riga viene decodificata come JSON anche quando non è un vino. NFR3.7 Unverified: per la migrazione di 500 vini non c'è un test con il tempo. NFR4.5-E2E Unverified per l'ambiente (servizio VM via adb): non è una causa del codice, resta da eseguire dal terminale del proprietario.
- **Root-cause stage**: code-generation (approccio di lettura in `tool/build_wine_db.dart`; test mancante in `test/cellar/estimates_migration_test.dart`).
- **Planned fix**: in `tool/build_wine_db.dart`, scartare le righe senza indizi di vino con un controllo sul testo grezzo prima di `jsonDecode`, con un risultato identico (stessa base, stesso manifest, `classifiedTypeShare` invariato) e un tempo misurato ≤ 2 minuti. Aggiungere il test "NFR3.7 500 wines are computed in under 2.5 s". Scelta del proprietario: "Retry with fix" (messaggio 8f50641e).
- **Estimated impact**: circa 1 ora, 0 €, rischio basso (la base generata deve restare identica byte per byte; i controlli di rilascio lo verificano).

## Fallimento accettato (2026-11-09)

Dopo il loop-back 1 restano `Unverified` solo NFR4.5-E2E (gli e2e non si caricano in questo ambiente) e NFR3.1-PHONE (misura sul telefono). Nessuna correzione del codice è possibile per questi due punti. Il proprietario ha scelto "Accept failure" (messaggio 8599e98c). Gli e2e restano da eseguire da un terminale del proprietario o in GitHub Actions prima del merge in `main`, come richiede `team.md`.
