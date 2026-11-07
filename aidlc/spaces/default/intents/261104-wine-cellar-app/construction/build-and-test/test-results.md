# Risultati di Build and Test — Vinoozy

Data: 2026-11-07. Macchina: MacBook Air (Apple Silicon, 10 core, 16 GB), Flutter 3.47.9, Node 22.23.4, Java 17. Emulatore Android: AVD `Medium_Phone_API_36.1` (arm64), avviato con 4 core e 4 GB, densità 420. Firebase Emulator Suite (Auth + Firestore) sul progetto `demo-vinoozy`. Nessun servizio reale usato.

**Esito complessivo: NON superato.** La build e tutti i test di unità, delle regole, della pagina web, nativi e i benchmark passano. Gli end-to-end hanno ancora 3 problemi, descritti al §5. Uno è un probabile difetto dell'app in U4 (§6).

## 1. Build e controlli statici

| Comando | Uscita | Note |
|---|---|---|
| `flutter pub get` | 0 | |
| `dart format --output=none --set-exit-if-changed .` | 0 | |
| `flutter gen-l10n` | 0 | avviso: `"pt": 316 untranslated message(s)` (vedi §7) |
| `flutter analyze --fatal-infos` | 0 | nessun problema |
| `tool/check_off_config.sh` | 0 | |
| `tool/check_dashboard_readonly.sh` + `_test.sh` | 0 / 0 | |
| `tool/check_rule_ids.sh BR1. 20 test/cellar test/rules/u4.rules.test.mjs` | 0 | |
| `tool/check_rule_ids.sh BR1. 15 test/label` | 0 | |
| `tool/check_rule_ids.sh BR1. 13 test/account test/rules/u8.rules.test.mjs` | 0 | |
| `tool/check_rule_ids_test.sh` | 0 | |
| `tool/check_label_imports.sh` + `_test.sh` | 0 / 0 | |
| `tool/check_web_pins.sh` + `_test.sh` | 0 / 0 | |
| `tool/check_web_config_test.sh` | 0 | |
| `tool/check_firestore_indexes.sh` + `_test.sh` | 0 / 0 | |
| Pacchetto di stima: `dart format`, `dart analyze --fatal-infos`, `tool/check_estimation_purity.sh` | 0 | |
| `tool/check_release_build.sh` | 0 | manifest unito senza `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE`; filtro di condivisione solo `image/*`; nessun `EmulatorGoogleAuthService`, `VINOOZY_DASHBOARD_READY`, `VINOOZY_E2E_LOCALE` nel rilascio; controllo positivo sulla build E2E+PERF superato |

Nota: nel primo giro tre righe `check_rule_ids.sh` erano uscite con 127. Era un errore del mio script, che passava gli argomenti come un'unica parola. Rieseguite correttamente, escono con 0.

## 2. Test di unità e copertura

Comandi deduplicati dai file `unit-test-instructions.md` delle 8 unità. La suite completa `flutter test` contiene i comandi per unità (`flutter test test/<unità>`), quindi ognuno è stato eseguito una volta sola, dentro la suite.

| Comando | Uscita | Risultato |
|---|---|---|
| `dart run tool/gen_coverage_helper.dart && flutter test --coverage` | 0 | **1.528 superati, 0 falliti, 0 saltati** (48 s) |
| `cd packages/estimation && dart test --coverage=coverage` + `format_coverage` + `check_coverage.sh 90` | 0 | tutti superati; **righe 100,00%** (343/343), soglia 90% |
| `cat coverage/lcov.info packages/estimation/coverage/lcov.info > coverage/merged.lcov.info && tool/check_coverage.sh 80 coverage/merged.lcov.info` | 0 | **progetto 89,13%** (9.005/10.103), soglia 80%, senza esclusioni |
| `tool/check_coverage.sh 80 coverage/lcov.info` (solo app) | 0 | 88,75% (8.662/9.760) |
| `tool/check_coverage.sh 80 coverage/lcov.info lib/catalog/` | 0 | 99,48% (766/770) |
| `tool/check_coverage.sh 80 coverage/lcov.info lib/dashboard/` | 0 | 99,04% (621/627) |
| `tool/check_coverage.sh 80 coverage/lcov.info lib/sharing/` | 0 | 98,42% (873/887) |
| `tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/` | 0 | 95,34% (2.698/2.830) |
| `tool/check_coverage.sh 80 coverage/lcov.info lib/label/` | 0 | 98,62% (926/939) |
| `tool/check_coverage.sh 80 coverage/lcov.info lib/account/` | 0 | 97,44% (1.104/1.133) |

## 3. Regole, pagina web e codice nativo

| Comando | Uscita | Risultato | Dove gira |
|---|---|---|---|
| `npm run test:rules` | 0 | **192 test: 191 superati, 0 falliti, 1 saltato** (il confronto con l'ultimo tag `v*`: non esiste ancora un tag) | Node + emulatore di Firestore |
| `npm run test:web` | 0 | **16/16 superati**; `c8` sulle righe di `account-deletion.js`: **100%** (rami 92,63%), soglia 80% | Node + emulatori; il test `account deletion page in Chromium` gira in **Chromium vero** (Playwright) |
| `cd android && ./gradlew :app:testDebugUnitTest :app:jacocoLabelReport` | 0 | **31 test** (15 `LabelImagePreparerTest`, 16 `SharedImageReceiverTest`), 0 falliti; JaCoCo **90,45%** delle righe (142/157), soglia 80% (`jacocoLabelVerification` superata) | JVM (Robolectric) |

## 4. Benchmark (soglie di velocità)

| Comando | Uscita | Misure |
|---|---|---|
| `dart run benchmark/estimation_benchmark.dart` | 0 | riconoscimento di 500 nomi 0,86 ms (≤ 4); stima + stato + abbinamenti di 500 vini 1,60 ms (≤ 10); secondo blocco −1,6% (≤ +10%) |
| `dart run benchmark/catalog_benchmark.dart` | 0 | `suggestWines` 0,48 ms (≤ 5); `matchLabelText` 0,24 ms (≤ 10); cache in memoria 0,001 ms (≤ 1); `InternalCatalog.build` 0,25 ms (≤ 20) |
| `dart run benchmark/dashboard_benchmark.dart` | 0 | `DashboardCalculator.compute` su 500 vini 0,59 ms (≤ 10) |
| `dart run benchmark/cellar_benchmark.dart` | 0 | `CellarFilter.apply` 0,86 ms (≤ 20); `WindowAdjuster.effective` 0,03 ms (≤ 5) |

## 5. End-to-end (emulatore Android + Firebase Emulator Suite)

Comando, come nel job `e2e` di `ci.yml`:

```bash
flutter test integration_test --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true
tool/e2e_force_stop.sh
```

### Corse

| Corsa | Emulatore | Superati | Falliti | Riavvio forzato | Note |
|---|---|---|---|---|---|
| 1 | 1 core, 2 GB (configurazione dell'AVD) | 12 | 8 | — | stato di partenza, test non ancora corretti |
| 2 | 1 core, 4 GB | 16 | 4 | **superato** | dopo le correzioni dei test (§5.1) |
| 3 | **4 core**, 4 GB | **17** | **3** | **superato** | durata dimezzata (6 min 47 s contro 12 min 37 s) |
| singole dopo la corsa 3 | 4 core, 4 GB | — | — | — | `label_test` **superato** dopo la correzione del disegnatore EAN-13; `cellar_test` superato 2 volte su 5; `u1_skeleton_test` 10 su 11 |

L'AVD era configurato con **1 solo core e 2 GB** (`hw.cpu.ncore=1`, `hw.ramSize=2048`). Con un core ogni passo durava molto di più: il controllo dei duplicati 4,4 s, la scrittura 2,2 s, la comparsa nella lista 3,8 s, quindi 10–20 s per un salvataggio che di solito ne richiede meno di uno. Le corse valide per le misure sono quelle con 4 core. In parallelo il Mac aveva `mediaanalysisd` di macOS al 214% di CPU, quindi i tempi locali restano rumorosi.

### 5.1 Correzioni fatte ai test in questa fase (approvate dal proprietario al gate di U8)

Solo file di test; nessun limite di tempo cambiato, nessun test saltato.

| File | Problema | Correzione |
|---|---|---|
| `integration_test/e2e_helpers.dart` | i tocchi arrivavano su un bersaglio coperto (SnackBar in entrata, dialogo di condivisione) | nuovi `tapWhenHittable` (aspetta che il bersaglio riceva davvero il tocco, come farebbe una persona), `acknowledgeSharedNotice` (chiude "… ti ha condiviso la sua cantina" con OK), `waitForCloudCellar` (aspetta che la cantina sia sul server) |
| `concurrent_drink_test.dart`, `sharing_test.dart` | il dialogo "ti ha condiviso la sua cantina" copriva il selettore delle cantine | chiusura del dialogo con OK, poi tocco sul selettore quando è libero |
| `label_test.dart` | `find.byType(HomeShell)` non trova la shell fuori scena sotto le pagine della foto (`Bad state: No element`) | `skipOffstage: false` |
| `integration_test/support/ean13_painter.dart` | **tabella delle parità EAN-13 sbagliata per le prime cifre 7, 8 e 9**: il codice disegnato (`8001234567897`) non era un EAN-13 valido e ML Kit giustamente non lo leggeva. Il passo non era mai stato eseguito (in U6 non c'era un emulatore) | parità corrette secondo GS1: 7 = `LGLGLG`, 8 = `LGLGGL`, 9 = `LGGLGL` |
| `dashboard_500_test.dart` | `ensureVisible` su una scheda della Dashboard non ancora costruita (lista pigra) | `scrollUntilVisible` sulla lista della Dashboard |
| `cellar_test.dart` | tocchi su "Aggiungi", "Bevuta" e "Annulla" coperti da una SnackBar; nello Storico il testo della SnackBar "Bevuta segnata: Dolcetto di Dogliani" contava come seconda riga | `tapWhenHittable`; conteggio solo dentro `history-list` |
| `account_test.dart` | l'invito veniva creato prima che la cantina dell'utente arrivasse al server: regole → 403 | `waitForCloudCellar` prima dell'invito |

### 5.2 Problemi ancora aperti

| Test | Esito | Diagnosi |
|---|---|---|
| `cellar_test.dart` "add, duplicate, drink and undo…" riga 95 | **fallisce 3 volte su 5** | dopo l'ultima bottiglia bevuta offline la fascia "modifiche in attesa" (NFR6.6 di U4) non compare. Probabile **difetto dell'app**, vedi §6 |
| `u1_skeleton_test.dart` scenario 2-3 | 2.084 ms (corsa 3, primo test a freddo) e 1.987 ms (corsa singola), limite **provvisorio** 2 s | misura al limite su emulatore debug; il limite non si alza. L'obiettivo vero (300 ms, NFR1.1) si misura sul telefono con build release (`docs/release-checklist.md` §1) |
| `u1_skeleton_test.dart` scenario 8 "after a restart…" | **fallisce 2 volte su 4** (non nella corsa 3) | scade l'attesa di 20 s della "cantina vuota" subito dopo l'accesso, prima del riavvio. Causa non individuata; la prova del riavvio vero (`tool/e2e_force_stop.sh`) è passata in tutte le corse |

### 5.3 Tempi misurati (corsa 3)

- Avvio con la lista (NFR2.1, limite CI 4 s): campioni 510, 568, 586, 797, 877 ms; **mediana 586 ms**.
- Salvataggio offline fino alla lista (limite provvisorio 2 s): 2.084 ms (corsa 3), 1.987 ms (corsa singola).

## 6. Diagnosi del difetto di U4 (NFR6.6)

In `lib/cellar/data/drinking_record_repository.dart` (`_commit`) l'app avvia la scrittura con `batch.commit()` senza attenderla e subito dopo chiama `_probe.trackWrite()`. Quest'ultimo segna "in attesa" e chiede a Firestore `waitForPendingWrites()` (`lib/cellar/data/pending_writes_probe.dart`). Le due chiamate passano dal canale nativo di FlutterFire e su Android possono raggiungere il client Firestore in ordine inverso. Se `waitForPendingWrites()` arriva prima che la scrittura sia in coda, non trova nulla da attendere e finisce subito, e la fascia si spegne anche se la bevuta è ancora solo sul telefono. Con 1 core l'ordine era quasi sempre giusto (corsa 2 superata); con 4 core la corsa si vede spesso. I telefoni veri hanno 8 core.

**Correzione proposta:** tenere "in attesa" finché si completa il `Future` della stessa scrittura (`write`), che su Firestore si completa solo quando il server conferma, invece di affidarsi a `waitForPendingWrites()` dopo ogni scrittura. Il controllo all'avvio (`checkAtStartup`) resta com'è. Va aggiunto un test di unità che simuli l'ordine inverso. Riguarda solo U4 (Code Generation di `u4-cellar`).

## 7. Altre osservazioni (non bloccanti)

- **SnackBar sopra "Aggiungi".** La SnackBar della bevuta compare sopra la barra in basso della shell e copre il pulsante "Aggiungi" della Cantina per qualche secondo. Non blocca nulla (sparisce da sola o con uno scorrimento), ma è un fastidio d'uso da valutare.
- **`"pt": 316 untranslated message(s)`.** `flutter gen-l10n` segnala la lingua base `pt` senza traduzioni proprie; l'app ha `pt_BR`. Un telefono in portoghese europeo riceverebbe i testi di ripiego. Da valutare: aggiungere `app_pt.arb` uguale a `pt_BR` o lasciarlo così.
- **CI Pipeline.** Il job `e2e` di `ci.yml` non imposta core e RAM dell'emulatore. Conviene fissare `cores: 4` e `ram-size: 4096M` in `reactivecircus/android-emulator-runner`, così le misure non dipendono dai valori predefiniti.
- **Plugin con Kotlin Gradle Plugin.** Gradle avverte che `firebase_app_check`, `firebase_auth`, `firebase_core` e `firebase_crashlytics` applicano KGP, che le prossime versioni di Flutter non accetteranno più. Da seguire con gli aggiornamenti dei plugin.

## Loop-Back Log

### Loop-back 1 — 2026-11-07T10:40:00Z

- **Diagnosis:** `cellar_test.dart` riga 95 fallisce 3 volte su 5: dopo l'ultima bottiglia bevuta offline la fascia "modifiche in attesa" non compare (u4-cellar NFR6.6 `Not Met`). In `DrinkingRecordRepository._commit` la scrittura `batch.commit()` non viene attesa e subito dopo `PendingWritesProbe.trackWrite()` chiama `waitForPendingWrites()`. Le due chiamate attraversano il canale nativo e possono raggiungere Firestore in ordine inverso: l'attesa finisce subito e la fascia si spegne anche se la bevuta non è ancora sul server.
- **Root-cause stage:** code-generation, unit `u4-cellar` (`lib/cellar/data/drinking_record_repository.dart`, `lib/cellar/data/pending_writes_probe.dart`).
- **Planned fix:** dopo ogni scrittura delle bevute, lo stato "in attesa" resta acceso finché si completa il `Future` della stessa scrittura (confermata dal server o rifiutata). Resta valido il "vince l'ultima scrittura": solo il completamento dell'ultima spegne la fascia. Il controllo all'avvio (`checkAtStartup`, con `waitForPendingWrites()`) non cambia. Un nuovo test di unità simula l'ordine inverso (attesa finita prima che la scrittura sia confermata) e verifica che la fascia resti accesa. Poi `flutter test`, copertura e una nuova corsa completa degli end-to-end.
- **Estimated impact:** effort circa 1–2 ore (2 file di U4 e i loro test, revisione, nuova corsa di Build and Test); costo 0 €; rischio basso: cambia solo quando la fascia si spegne, e le altre unità non vengono toccate.
- **Choice:** "Retry with fix", scelto dal proprietario (messaggio c66ebe48).
- **Decisione finale:** "Accept failure" (messaggio b40e6dce). Il fallimento resta registrato qui e la fase va al gate con u4-cellar NFR6.6 `Not Met`. La correzione pianificata sopra resta da fare come lavoro separato.
- **Esito:** il ritorno non è stato eseguito. Code Generation era stata approvata per tutte le unità insieme e si può riaprire solo per tutte; il proprietario ha scelto di non riaprirla (messaggio 42a98e95). Nessun file dell'app è cambiato.

## 8. Stato dell'emulatore locale

Per le prove ho cambiato temporaneamente l'emulatore: densità da 540 a 420, Play Store disattivato per l'utente, avvio con 4 core e 4 GB (solo opzioni di avvio, la configurazione dell'AVD è invariata). Alla fine della fase ho ripristinato densità 540 e Play Store; l'emulatore resta acceso con gli emulatori Firebase.
