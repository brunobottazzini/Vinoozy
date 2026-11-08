# Risultati di Build and Test — riconoscimento delle etichette

Date: 2026-11-07 e 2026-11-08.

Ambiente:
- MacBook Air con Flutter, Node 22 e Java 17;
- emulatore Android `emulator-5554` (`Medium_Phone_API_36.1`, 4 core), riportato a testo 100% e densità di default prima della corsa finale;
- Firebase Emulator Suite (`demo-vinoozy`).

**Esito: superato con un fallimento accettato.** Tutti i test di questo lavoro sono verdi. L'unico end-to-end rosso è `cellar_test.dart` "drink, History, Undo": riguarda un'area che questo lavoro non tocca, ed è stato accettato dal proprietario (messaggio ae246174).

## 1. Build e controlli statici

| Comando | Uscita |
|---|---|
| `dart format --set-exit-if-changed .` | 0 (373 file, nessuna modifica) |
| `flutter analyze --fatal-infos` | 0, nessun problema |
| `tool/check_off_config.sh` (`lib/catalog/core` puro), `check_label_imports.sh` + test, `check_rule_ids.sh` | 0 |
| `tool/check_lens_manifest_test.sh`, con i casi dei commenti `comment_ok` e `comment_bad` | 0 |
| `tool/check_wine_db_release_test.sh` (7 fixture) | 0 |
| `flutter build apk --debug` (prod, installata sul telefono del proprietario il 2026-11-07) | 0 |

## 2. Test di unità, widget e copertura

| Comando | Risultato |
|---|---|
| `flutter test --coverage` | **2070 superati, 0 falliti** (prima di questo lavoro: 1705) |
| `tool/check_coverage.sh 80` | **89,17%** (11064/12408) |
| `tool/check_coverage.sh 80 coverage/lcov.info lib/label/` | **98,81%** (1493/1511) |
| `tool/check_coverage.sh 80 coverage/lcov.info lib/catalog/` | **98,17%** (1183/1205) |
| `./gradlew :app:testDebugUnitTest :app:jacocoLabelReport` (Code Generation) | 36 superati, compresi 5 `LensIntentLauncherTest`; JaCoCo ok |

Benchmark della base offline, dentro la suite:
- 1000 ricerche per codice ≤ 50 ms totali;
- confronto di 4000 caratteri ≤ 600 ms;
- basi sintetiche di 20.000 e 50.000 vini.

Tutti superati (NFR2.1, NFR2.2, NFR2.7).

## 3. End-to-end

### 3.1 Riconoscimento delle etichette (`integration_test/label_test.dart`)

| Scenario | Esito |
|---|---|
| NFR4.4 file danneggiato rifiutato, nessuna copia rimasta | superato |
| FR1.1 fronte e retro, codice solo sul retro → proposta sicura, salvata | superato |
| FR1.1 "Salta" → candidato → modulo compilato, salvato | superato |
| FR3.4 "Cerca online" senza rete | superato |
| BR5.1 Lens annullato: il canale non viene chiamato | superato |

5/5 in 43 secondi. Durante la corsa non si sono mai aperte né la Fotocamera reale né un'app Google.

### 3.2 Suite completa (`flutter test integration_test --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true`)

| Corsa | Risultato |
|---|---|
| Prima corsa (2026-11-07) | 18 superati, 6 falliti. Causa: emulatore con testo al 200% e densità 540 impostati a mano. Pulsanti fuori schermo, nessun difetto del codice. |
| Dopo il ripristino dell'emulatore (2026-11-08) | **22 superati, 2 falliti** |
| Rilancio dei due file falliti | `u1_skeleton_test.dart` scenario 9 **superato**: instabile, già noto. `cellar_test.dart` "drink, History, Undo" **fallito**. |

## 4. Difetti trovati e corretti in questa fase

1. **I servizi della lettura venivano dallo scope sbagliato.**
   - Il controller della lettura prendeva sorgente delle foto, catalogo e Lens dal contenitore radice, non dalla schermata che avvia la lettura. Nei test il retro apriva la fotocamera vera.
   - Correzione: `LabelServices`, passati da `label_capture_flow.dart` a `LabelReadingScreen` e a `OnlineSearchScreen`.
   - Nuovo test `test/label/ui/label_scope_test.dart`: falliva in 4 casi su 4 prima della correzione, passa in 4 su 4 dopo.
   - In produzione il comportamento non cambia.
2. **Supporto dell'e2e:**
   - pulsanti sotto il bordo dello schermo (ora `tapVisible`);
   - "Cerca online" rispondeva dalla memoria temporanea (rete spenta prima della lettura);
   - tasto indietro cercato in inglese.
3. **Correzioni della revisione del codice R-01…R-05:**
   - base di prova marcata `sample`, senza attribuzione a Open Food Facts, con blocco della promozione in `promote.yml`;
   - stato `unavailable` per "Cerca online";
   - controllo del manifest che gestisce i commenti;
   - e2e diviso in 5 scenari;
   - deviazioni dal piano scritte in `code-summary.md`.

## 5. Fallimento accettato

`cellar_test.dart` "drink, History, Undo" (righe 165-167): dopo la bevuta il test passa alla scheda Storico e non trova più "Annulla" (`drink-undo`) nel messaggio.
- Nelle corse precedenti questo test si fermava prima, sul doppione nello Storico. Questa volta il doppione non è comparso e il test è arrivato al passo dell'Annulla.
- Area coinvolta: il flusso della bevuta della nuova UX (`drink_flow.dart`, `home_shell.dart`, `drink_snack_bar.dart`, messaggio di 6 secondi). Questo lavoro non la tocca.
- **Decisione del proprietario (messaggio ae246174):** accettato. Va nel lavoro dedicato al doppione dello Storico, prima della pubblicazione sullo store.

## 6. Misure non eseguite (rimandate)

| Requisito | Stato | Perché |
|---|---|---|
| NFR1.1 crescita del bundle ≤ 15 MB | non misurato | `tool/app_size_baseline.txt` è ancora `UNSET` e la base reale non è ancora generata. Va misurato con la base reale, prima della promozione. |
| NFR2.3 apertura della base ≤ 1,5 s sul telefono | non misurato | conta solo con la base reale (oggi 45 vini di prova) |
| NFR2.5 memoria ≤ 40 MB | non misurato | come sopra |
| NFR2.1, NFR2.2 sul telefono | non misurati | coperti dai benchmark in CI; la misura sul telefono va fatta con la base reale |

Queste voci sono nella checklist di rilascio, sezione 1-nonies.
