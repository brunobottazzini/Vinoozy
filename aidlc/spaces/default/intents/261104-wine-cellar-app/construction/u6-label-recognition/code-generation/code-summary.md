# Code Summary — u6-label-recognition

U6 aggiunge un vino dalla foto dell'etichetta (US2.2, AC2.2.1–AC2.2.5; BR1.1–BR1.15):
- "Aggiungi" offre tre strade: "Scatta foto", "Importa una foto", "Scrivi";
- una foto condivisa da un'altra app ("Condividi → Vinoozy") apre direttamente la lettura;
- la lettura di codice a barre e testo avviene sul telefono con ML Kit, con i modelli inclusi nell'app;
- la ricerca usa il catalogo di U3: prima il codice con la rete, poi il testo;
- la proposta ha la quantità da 1 a 99; "Conferma" salva con U4 (doppioni compresi), "Correggi" apre il modulo di U4 compilato;
- la foto non si conserva: la copia di lavoro in `cache/label/` si cancella in ogni caso.

Metodo: test-after, strato per strato (modello, accesso ai dati, logica, interfaccia), ogni strato con i suoi test verdi prima del successivo.

## File creati

**Nucleo puro** (`lib/label/core/`, Dart senza Flutter):
- `label_reading.dart`: tipi della lettura e interfaccia `LabelReader`.
- `label_line_picker.dart`: riga più significativa (BR1.12).
- `vintage_parser.dart`: annata letta sull'etichetta (BR1.8).
- `barcode_filter.dart`: EAN-13, EAN-8, UPC-A con `normalizeBarcode` di U3 e cifra di controllo (BR1.7).
- `label_lookup_flow.dart`: ordine di ricerca, al più 2 richieste, errori del catalogo come "nessun risultato" (BR1.8, NFR5.1, NFR6.3).
- `label_session.dart`: stati e transizioni, "Annulla" con identificatore di lettura (BR1.13).
- `shared_image_policy.dart`: regole della foto condivisa prima della lettura (BR1.4, NFR4.5).

**Adattatori** (`lib/label/platform/`):
- `mlkit_label_reader.dart`, `picker_image_source.dart`, `shared_image_channel.dart`, `temp_label_store.dart`, `label_error_reporter.dart`.

**Logica e interfaccia:**
- `lib/label/label_providers.dart`: provider, `labelSessionProvider`, `sharedImageProvider`, `labelFlowProvider`.
- `lib/label/ui/`: `add_choice_screen.dart`, `label_capture_flow.dart`, `label_reading_screen.dart`, `label_proposal_sheet.dart`, `label_unreadable_view.dart`, `barcode_only_view.dart`, `permission_denied_view.dart`, `label_message_layout.dart`, `replace_label_dialog.dart`.

**Android:**
- `android/app/src/main/kotlin/com/vinoozy/vinoozy/LabelImagePreparer.kt` e `SharedImageReceiver.kt`.
- `android/app/src/test/kotlin/com/vinoozy/vinoozy/LabelImagePreparerTest.kt` e `SharedImageReceiverTest.kt` (Robolectric).
- `android/app/proguard-rules.pro` (vedi "Scostamenti").

**Test Dart:** `test/label/` (harness, `core/`, `platform/`, `ui/`, controller della sessione, foto condivisa); `test/cellar/ui/add_wine_initial_values_test.dart`.

**End-to-end:** `integration_test/label_test.dart`, `integration_test/support/ean13_painter.dart`, `integration_test/support/fake_image_source.dart`.

**Strumenti:** `tool/check_label_imports.sh`, `tool/check_label_imports_test.sh`, `tool/fixtures/label_imports/` (`ok/`, `firestore_import/`), `tool/check_app_size.sh`, `tool/app_size_baseline.txt`.

## File modificati

- `pubspec.yaml`, `pubspec.lock`: `image_picker` 1.2.4, `google_mlkit_text_recognition` 1.0.0, `google_mlkit_barcode_scanning` 1.0.0. Usano gli artefatti con il modello incluso (`com.google.mlkit:text-recognition`, `com.google.mlkit:barcode-scanning`).
- `android/app/build.gradle.kts`: `androidx.exifinterface` 1.4.2; JUnit 4.13.2, Robolectric 4.17, `androidx.test:core` 1.7.0; JaCoCo 0.8.14 con `jacocoLabelReport` e la soglia dell'80% sulle due classi; file di regole R8.
- `AndroidManifest.xml`: `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE` rimossi con `tools:node="remove"`; filtro `SEND`/`SEND_MULTIPLE` con `image/*` su `MainActivity`.
- `MainActivity.kt`: canale `com.vinoozy.app/label`, intent consumato in `onCreate` e `onNewIntent`, lavoro su un thread in background.
- `lib/cellar/ui/add_wine_screen.dart` (U4): `AddWineInitialValues`, avviso in alto, `wineFamilyOf` usata sia dai suggerimenti sia dalla foto.
- `lib/cellar/ui/cellar_screen.dart` (U4): parametro facoltativo `onAdd`; senza di esso il comportamento è quello di prima.
- `lib/app/home_shell.dart`: "Aggiungi" e "Aggiungi il primo vino" aprono `AddChoiceScreen`; ascolto delle foto condivise e domanda prima di sostituire dati non salvati.
- `lib/app/bootstrap.dart`: pulizia di `label/` dopo il primo frame; collegamento della foto condivisa al gate dell'account e controllo dell'avvio a freddo.
- `lib/l10n/app_en.arb`, `app_it.arb`, `app_pt_BR.arb` e i file generati da `flutter gen-l10n`: 28 testi nuovi.
- `test/app/home_shell_test.dart`, `test/sharing/permissions_screens_test.dart`: il percorso di "Aggiungi" passa da "Scrivi".
- `integration_test/e2e_helpers.dart`, `integration_test/cellar_test.dart`: stesso cambio di percorso negli end-to-end esistenti.
- `tool/check_release_build.sh`: controllo negativo e positivo sul manifest unito in chiaro; conserva l'AAB semplice per `check_app_size.sh`.
- `.github/workflows/ci.yml`: in `analyze` gli ID BR1.1–BR1.15 e il controllo degli import con il suo test; in `unit` la copertura di `lib/label/`, Gradle con Robolectric e JaCoCo, e la dimensione dell'app.
- `docs/release-checklist.md`: §1-bis, nuovo §1-sexies (misure, condivisione, file rimasti, dimensione, limite HEIC, prima build iPhone), §2 (foto non raccolte, ML Kit, informativa), §5 (eventi `label_*`).

## Decisioni di implementazione

- **Un solo punto nativo per le immagini.** Sia le foto di `image_picker` sia quelle condivise passano da `LabelImagePreparer`. Dart non decodifica mai un'immagine. I rifiuti arrivano a Dart solo come codice (`scheme`, `type`, `size`, `format`, `decode`).
- **Lavoro che sopravvive alla schermata.** Una lettura annullata o una schermata chiusa lasciano finire il lavoro in background. Le dipendenze si prendono all'avvio della lettura, così il lavoro non usa più `ref` dopo la chiusura. La copia si cancella nel `finally`, e nessun errore arriva ai gestori globali (verificato con marcatori).
- **Una sessione per schermata.** `labelSessionProvider` ha un token per ogni schermata. Una schermata sostituita da una nuova condivisione non vede lo stato della nuova.
- **Foto condivisa.**
  - Il gate dell'account si collega in `AppBootstrap` (`attachGate`, `checkColdStart`). Così i test esistenti della shell non cambiano.
  - L'immagine aspetta l'accesso anche se è lento. Si scarta quando un tentativo di accesso finisce senza account (BR1.4 letto con NFR4.5).
  - Con l'accesso fatto, "can edit" in caricamento si aspetta al più 5 s. Se la cantina non è pronta entro 60 s dalla fine dell'accesso, la foto scade.
- **Scelte enologiche prese in autonomia** (project.md, Corrections), sempre correggibili nel modulo:
  - l'annata ignora gli anni dopo parole di fondazione ("dal", "since", "fondata nel");
  - con più anni, vince quello sulla stessa riga di una parola d'annata o di una sigla (DOC, DOCG…), altrimenti il più recente.
- **Riga più significativa.** Le righe di volume si riconoscono solo con un numero davanti ("750 ml"), così l'apostrofo italiano ("dell'") non scarta la riga.
- **Codici a barre.** Oltre a `normalizeBarcode` di U3 si controlla la cifra di controllo GS1, così il catalogo non riceve codici danneggiati.

## Risultati

Prima delle modifiche, sull'albero invariato: **1.142 test superati**.

| Controllo | Risultato |
|---|---|
| `flutter test --coverage` (tutta la suite, dopo le correzioni della revisione) | **1.348 superati**, 0 falliti (206 nuovi) |
| `flutter test test/label` | tutti verdi (core, adattatori, logica, interfaccia nelle tre lingue con `textScaler` 1.0 e 2.0, chiaro e scuro) |
| Copertura di `lib/label/` | **98,62%** (926/939 righe), soglia 80% |
| Copertura del progetto (lcov dell'app + pacchetto `estimation`) | **89,45%** (8.053/9.003), soglia 80% |
| Altre cartelle (prima della revisione) | `lib/cellar/` 95,33%, `lib/catalog/` 99,48%, `lib/dashboard/` 99,04%, `lib/sharing/` 98,42% |
| Pacchetto `estimation` (`dart test`) | 321 superati |
| `./gradlew :app:testDebugUnitTest :app:jacocoLabelReport` | **31 test Kotlin** (16 del preparatore, 15 del receiver), 0 falliti; JaCoCo **90,4%** (142/157 righe) sulle due classi, soglia 80% superata |
| `tool/check_rule_ids.sh BR1. 15 test/label` | OK (BR1.1–BR1.15 in 14 file); quello di U4 resta OK |
| `tool/check_label_imports.sh` e `tool/check_label_imports_test.sh` | OK (22 file, nessun Firestore né Storage; la prova `firestore_import/` fallisce come atteso) |
| `dart format --output=none --set-exit-if-changed .` | 0 file cambiati |
| `flutter analyze --fatal-infos` | nessun problema |
| `tool/check_release_build.sh` | OK: niente `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE` nel manifest unito; filtro di condivisione con solo `SEND`/`SEND_MULTIPLE` e `image/*`; marcatori E2E e PERF come prima |

**Dimensione dell'app.**
- AAB semplice (arm64, `FIREBASE_ENV=demo`): da 24.634.405 byte prima di U6 a 46.292.219 byte dopo.
- L'AAB contiene però le librerie native di ML Kit anche per `armeabi-v7a` e `x86_64`, che un telefono arm64 non scarica.
- Stima dalla somma compressa delle voci per arm64: da 11.271.086 a 19.939.955 byte, cioè **circa +8,7 MB**, sotto i 15 MB. È una stima, non la misura di `bundletool`.

## Test scritti ma non eseguiti

- **`integration_test/label_test.dart` e gli end-to-end esistenti con il nuovo percorso di "Aggiungi"** (`cellar_test.dart`, `e2e_helpers.dart`). Servono un emulatore Android avviato e la Firebase Emulator Suite: nessun dispositivo era collegato, quindi non sono stati eseguiti. Si eseguono nel job `e2e` o in Build and Test.
  - Il test inietta la fotocamera finta con un `ProviderScope` annidato sopra i servizi veri dell'app; il funzionamento sull'emulatore va verificato.
  - La build demo non ha il contatto di Open Food Facts, quindi il catalogo è solo interno. Per questo l'immagine con il codice a barre finisce in "Ho letto il codice a barre ma non trovo il vino" (prova che il codice è stato letto) e non in una proposta da un catalogo finto. Il caso "senza rete" non è provato nell'end-to-end: `TestNetworkControl` agisce su Firestore, non sulla connettività.
- **`tool/check_app_size.sh`.** Eseguire il jar di `bundletool` scaricato non è stato permesso in questa sessione. Il jar (1.18.3) è stato scaricato e il suo SHA-256 coincide con quello pubblicato da GitHub, ma lo script non è mai stato eseguito fino in fondo.

## Scostamenti dal piano

- **Valore di base della dimensione non misurato.**
  - L'AAB di rilascio è stato costruito sull'albero **prima** di aggiungere le dipendenze di U6 e conservato fuori da git in `android/captures/pre-u6-app-release.aab` (SHA-256 `eab0ee48…332cd`).
  - `tool/app_size_baseline.txt` contiene `UNSET` e spiega il comando da eseguire: `tool/check_app_size.sh --measure android/captures/pre-u6-app-release.aab`. Il numero stampato va scritto al posto di `UNSET`.
  - Finché `UNSET` resta, il passo `check_app_size.sh` del job `unit` fallisce di proposito.
- **`android/app/proguard-rules.pro` nuovo** e collegato alla build di rilascio. Senza, R8 ferma la build sulle classi di ML Kit per cinese, devanagari, giapponese e coreano: il plugin le dichiara `compileOnly`, e l'app usa solo il latino. Si silenziano solo quelle 8 classi.
- **`lib/cellar/ui/cellar_screen.dart` modificato** (non era nell'elenco del piano). Il pulsante "Aggiungi" della Cantina sta lì, non in `HomeShell`. Ha un parametro facoltativo `onAdd`, passato dalla shell; senza di esso il comportamento di U4 è identico.
- **`lib/app/providers.dart` non modificato.** I provider di U6 stanno in `lib/label/label_providers.dart`, e la pulizia all'avvio è chiamata da `bootstrap.dart`.
- **`DuplicateDialog` era già pubblico** in U4. Nessun cambio; si è aggiunto solo un test d'uso da fuori U4.
- **Test Kotlin.** OOM e "60 milioni di pixel" si simulano iniettando un decoder (`LabelBitmapDecoder`) invece di `ShadowBitmapFactory`. HEIC con API 27 e 28 si prova passando `sdkInt` al preparatore invece di cambiare l'SDK di Robolectric.
- **Immagini dell'end-to-end.** Si scrivono nella cartella temporanea dell'app (dentro `cacheDir`, come fa `image_picker`), non in `cacheDir/label/`, e passano comunque dal preparatore.
- **`timeout-minutes` del job `unit`** resta 15: non è stato possibile misurare il job in GitHub Actions. Va alzato a 25 solo se la prima esecuzione supera 12 minuti.

## Correzioni dopo la revisione

Revisione `reviews/review-01.md` (NOT-READY, iterazione 1).

- **R-01 (critico): la copia temporanea poteva restare su disco.**
  - Il problema: Kotlin restituiva il percorso sotto `cacheDir` canonico (`/data/data/...`). Dart invece confrontava in modo letterale con `getTemporaryDirectory()/label` (`/data/user/0/...`, un collegamento simbolico). La cancellazione falliva con `label_cleanup_failed` e la copia restava.
  - Kotlin: `LabelImagePreparer` costruisce `labelDir` e i percorsi restituiti dal `cacheDir` così come lo riceve, non canonico. Usa i percorsi canonici solo per il proprio controllo di confinamento (`isInsideCache`, cancellazione della cartella vuota di `image_picker`).
  - Dart: `IoLabelFileSystem.delete` risolve i collegamenti simbolici (`resolveSymbolicLinks`) sia della cartella `label` sia della cartella del file, prima di confrontarle. Se la cartella non esiste usa il percorso così com'è: lì non c'è nulla da cancellare.
  - Test nuovi:
    - Dart (`test/label/platform/temp_label_store_test.dart`): cartella temporanea dietro un `Link` vero. Cancella sia il percorso canonico sia quello attraverso il collegamento, e rifiuta ancora `gallery.jpg` fuori da `label/`, una cartella `labels/` simile e `label/../x.jpg`. Un secondo test copre la cartella che non esiste.
    - Kotlin (`LabelImagePreparerTest.theReturnedPathStaysUnderTheNonCanonicalCacheDir`): con `cacheDir` dietro un collegamento simbolico, il percorso restituito sta sotto `cacheDir.path` non canonico.
  - Resta da verificare su un emulatore o un telefono che `cache/label/` sia vuota dopo ogni lettura: l'end-to-end non è stato eseguito.
- **R-02 (maggiore): controllo della dimensione con base `UNSET`.**
  - Il passo resta nel job `unit`, come chiesto: deve fallire finché la base non è misurata.
  - Lo script ora controlla la base **prima** di scaricare o eseguire `bundletool`, ed esce subito con un messaggio chiaro in inglese: "App size baseline is UNSET: run tool/check_app_size.sh --measure <pre-change AAB> and commit the number in tool/app_size_baseline.txt."
  - Verificato in locale: uscita 1 con quel messaggio, senza eseguire `bundletool`.
  - La misura spetta al proprietario (sezione sotto). In questa sessione `bundletool` non è stato eseguito: eseguirlo non è permesso.
- **R-03 (minore): condivisione riconsegnata.**
  - `SharedImageReceiver.onCreate(intent, restored, replaceIntent)` ignora la condivisione quando l'attività è ripristinata (`savedInstanceState != null`, passato da `MainActivity`) o riaperta dai recenti (`FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY`). L'intent vecchio viene consumato senza essere letto.
  - Due test Robolectric nuovi: `aRestoredActivityDoesNotDeliverTheOldShareAgain` e `anActivityReopenedFromRecentsDoesNotDeliverTheOldShareAgain`.
- **R-04 (minore):**
  - Gli end-to-end restano non eseguiti, perché non c'è un emulatore (vedi "Test scritti ma non eseguiti").
  - `timeout-minutes: 15` del job `unit` resta invariato: nessuna nuova misura. Va alzato a 25 solo se la prima esecuzione in GitHub Actions supera 12 minuti.

## Da fare dal proprietario

**Decisione del proprietario (2026-11-06, approvazione del codice):** "se lapp è pesante non fa niente". Il controllo della dimensione dell'app non blocca più il merge: il passo `tool/check_app_size.sh` è tolto dal job `unit` di `ci.yml`. Lo script resta per una misura a mano facoltativa (`tool/check_app_size.sh --measure <AAB>`), e `tool/app_size_baseline.txt` può restare `UNSET`. NFR2.3 diventa una misura informativa, non un limite.

1. **Eseguire gli end-to-end** su emulatore con la Firebase Emulator Suite: `integration_test/label_test.dart`, più `cellar_test.dart` e gli altri che usano `addWine`. Controllare che `cache/label/` sia vuota dopo le letture (R-01).

2. **Alla prima esecuzione del job `unit`** in GitHub Actions, guardare la durata. Se supera 12 minuti, alzare `timeout-minutes` a 25.

## Comandi

```bash
flutter test test/label
cd android && ./gradlew :app:testDebugUnitTest :app:jacocoLabelReport
flutter test test/cellar test/app
flutter test --coverage test/label && tool/check_coverage.sh 80 coverage/lcov.info lib/label/
tool/check_rule_ids.sh BR1. 15 test/label
tool/check_label_imports.sh
tool/check_label_imports_test.sh
tool/check_release_build.sh
tool/check_app_size.sh --measure android/captures/pre-u6-app-release.aab
tool/check_app_size.sh
```
