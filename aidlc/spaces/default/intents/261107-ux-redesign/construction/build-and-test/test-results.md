# Risultati di Build and Test — nuova UX

Data: 2026-11-07. Ambiente:
- MacBook Air, Flutter 3.47.9, Node 22, Java 17;
- emulatore Android `Medium_Phone_API_36.1` con 4 core, 4 GB, densità 420;
- Firebase Emulator Suite (`demo-vinoozy`).

**Esito: NON superato** per un solo end-to-end, `cellar_test.dart` secondo test. Fallisce per il **doppione nello Storico**, un difetto preesistente di U4 già accettato in passato e non toccato da questo lavoro. Tutto il resto è verde.

## 1. Build e controlli statici

| Comando | Uscita |
|---|---|
| `dart format --output=none --set-exit-if-changed .` | 0 |
| `flutter gen-l10n && flutter analyze --fatal-infos` | 0, nessun problema |
| `check_off_config`, `check_dashboard_readonly` (+ test), `check_rule_ids` U4/U6/U8 (+ test), `check_label_imports` (+ test), `check_web_pins` (+ test), `check_web_config_test`, `check_firestore_indexes` (+ test) | tutti 0 |
| `tool/check_release_build.sh` | 0: manifest senza permessi foto/fotocamera, nessun codice di test nel rilascio |

## 2. Test di unità e copertura

| Comando | Uscita | Risultato |
|---|---|---|
| `dart run tool/gen_coverage_helper.dart && flutter test --coverage` | 0 | **1.705 superati**, 0 falliti |
| `packages/estimation`: `dart test --coverage` + `check_coverage.sh 90` + benchmark | 0 | 100% delle righe; benchmark entro i limiti |
| `tool/check_coverage.sh 80 coverage/merged.lcov.info` | 0 | **89,26%** (10.181/11.406) |
| `check_coverage.sh 80` per `lib/catalog/`, `lib/dashboard/`, `lib/sharing/`, `lib/cellar/`, `lib/label/`, `lib/account/` | 0 | 99,48 / 98,84 / 98,42 / 95,29 / 98,65 / 97,44% |
| `dart run benchmark/catalog_benchmark.dart`, `dashboard_benchmark.dart`, `cellar_benchmark.dart` | 0 | Dashboard 0,72 ms (≤ 10); filtri 0,84 ms (≤ 20); catalogo entro i limiti |

## 3. Regole, pagina web, codice nativo

| Comando | Uscita | Risultato | Dove gira |
|---|---|---|---|
| `npm run test:rules`, comando standard dopo aver fermato l'emulatore acceso sulla porta 8080 | 0 | **199 test: 198 superati, 0 falliti, 1 saltato** (nessun tag `v*` da confrontare). Comprende `country`, il voto alla creazione e la compatibilità con le scritture della versione di oggi | Node + emulatore di Firestore |
| `npm run test:web` | 0 | 16/16 superati | Node + emulatori; Chromium vero con Playwright |
| `./gradlew :app:testDebugUnitTest :app:jacocoLabelReport` | 0 | superati, JaCoCo ≥ 80% | JVM |

## 4. End-to-end (emulatore Android + Firebase Emulator Suite)

**Prima corsa: 17 superati, 3 falliti.** Tutti e 3 i fallimenti erano nell'aiuto di test `addWine`, modificato in Code Generation e mai eseguito. I tocchi su paese, regione, "senza annata" e "+" cadevano sotto la tastiera dell'emulatore o sotto la barra fissa "Salva".

**Correzione nella fase** (supporto di test, nessun limite cambiato): `tapVisible` in `integration_test/e2e_helpers.dart` ora:
- chiude la tastiera;
- porta l'elemento al centro dello schermo;
- tocca solo quando l'elemento riceve davvero il tocco.

**Corsa finale:**

| Comando | Uscita | Risultato |
|---|---|---|
| `flutter test integration_test --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true` | 1 | **19 superati, 1 fallito**: `cellar_test.dart` "drink, History, Undo…", riga 158: la bevuta "Dolcetto di Dogliani" compare **2 volte** nello Storico |
| `tool/e2e_force_stop.sh` | 0 | il vino sopravvive al kill e arriva al cloud |

Tempi della corsa finale: salvataggio offline fino alla lista 1.298 ms (limite provvisorio 2 s); avvio con la lista, mediana 768 ms (limite CI 4 s).

Corse singole tra le due corse complete:
- lo scenario 8 di U1 ha fallito una volta (instabile già noto), e lo scenario 9 è fallito subito dopo, di conseguenza;
- da solo lo scenario 9 passa (mediana 791 ms);
- nella corsa finale sono passati entrambi.

## 5. Diagnosi del fallimento

Il doppione nello Storico (U4 BR1.16) era già stato registrato nella correzione della fascia (`261107-pending-banner-fix`, Build and Test) come difetto preesistente, accettato come lavoro separato.

Lo Storico ricarica la prima pagina sia dopo ogni bevuta (`invalidateDrinkReads`) sia quando si torna sulla sua scheda (`HomeShell._select`). In una di queste ricariche la stessa bevuta finisce due volte nella lista, circa 1 volta su 3. La causa precisa non è stata individuata, quindi non c'è una correzione definita da stimare. Questo lavoro non tocca `HistoryPager`.

**Decisione del proprietario (2026-11-07, messaggio ec71343c): "Accept failure".** Il doppione nello Storico diventa un lavoro dedicato da fare prima della pubblicazione sullo store.

## 6. Punti minori della revisione del codice (non bloccanti, da fare insieme al prossimo lavoro)

1. Dal dettaglio, "Bevuta segnata" usa il messenger principale e può coprire "Aggiungi".
2. Il pannello mostra la quantità letta all'apertura: se un altro membro finisce il vino nel frattempo, la conferma toglie comunque una bottiglia (rischio già presente prima).
3. Modificare un vino vecchio con una regione italiana scrive `country = IT`, che le regole di produzione di oggi rifiutano. Le regole vanno pubblicate prima di installare la build (vedi `build-instructions.md`).
4. `requirements.md` dice 80 caratteri per la regione, mentre il codice e le regole ne accettano 120, come stabilito nella specifica delle interazioni.
