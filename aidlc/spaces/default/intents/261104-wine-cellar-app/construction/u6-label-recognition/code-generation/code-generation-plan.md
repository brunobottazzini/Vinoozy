# Code Generation Plan — u6-label-recognition

## Summary

- Builds: aggiunta di un vino dalla foto dell'etichetta (scatto, galleria, condivisione verso Vinoozy), lettura sul telefono di testo e codice a barre con ML Kit, proposta con quantità, conferma o correzione tramite U4, foto mai conservata.
- Touches: nuovo `lib/label/`, `android/app/src/main/kotlin/` (preparatore e ricevitore), `AndroidManifest.xml`, `pubspec.yaml`, `lib/cellar/ui/` (estensioni di U4), `lib/app/`, `test/label/`, `android/app/src/test/`, `integration_test/`, `tool/`, `.github/workflows/ci.yml`, `docs/release-checklist.md`.
- Tests: circa 110 test di Dart (logica, adattatori finti, schermate nelle tre lingue), circa 25 test Kotlin con Robolectric, 1 test end-to-end con ML Kit vero, test di script.

Fonti:
- Functional Design di U6: `functional-spec.md` (BR1.1–BR1.15 e chiarimenti), `rules.md`, `frontend-components.md`;
- NFR Requirements: `performance-requirements.md`, `security-requirements.md`, `tech-stack-decisions.md`;
- NFR Design: `logical-components.md`, `security-design.md`, `performance-design.md`;
- Infrastructure Design: `infrastructure-specification.md`, `monitoring-design.md`, `cicd-pipeline.md`;
- `contract-summary.md` (C1), `unit-of-work.md`, `requirements.md` (FR2.2–FR2.4, FR1.4 e NFR8 aggiornati), `stories.md` (US2.2, AC2.2.1–AC2.2.5).

Storia: US2.2.

Strati testabili:
- **modello dei dati:** nucleo puro di `lib/label/core/`;
- **accesso ai dati:** adattatori (ML Kit, selettore, canale, cartella temporanea, report) e codice nativo Android;
- **logica:** provider e sessione di lettura;
- **interfaccia:** schermate di U6 e integrazione con U4 e con la shell.

## File dell'utente toccati da questo lavoro

- **Dipendenze:** `pubspec.yaml`, `pubspec.lock` (`image_picker`, `google_mlkit_text_recognition`, `google_mlkit_barcode_scanning`, nell'ultima versione stabile); `android/app/build.gradle.kts` (`androidx.exifinterface`, Robolectric e JaCoCo per i test).
- **Android:** `android/app/src/main/AndroidManifest.xml` (filtro di condivisione, permessi rimossi con `tools:node="remove"`); `MainActivity.kt` (canale e intent).
- **Codice di U4:** `lib/cellar/ui/add_wine_screen.dart` (`AddWineInitialValues`, avviso in alto), `lib/cellar/ui/cellar_dialogs.dart` (`DuplicateDialog` pubblico).
- **Shell e avvio:** `lib/app/home_shell.dart` ("Aggiungi" apre `AddChoiceScreen`, ascolto delle condivisioni), `lib/app/bootstrap.dart` e `lib/app/providers.dart` (pulizia di `label/`, provider).
- **Traduzioni:** `lib/l10n/*.arb`.
- **CI e strumenti:** `.github/workflows/ci.yml` (job `analyze`, `unit`, eventuale `timeout-minutes`); `tool/check_release_build.sh` (manifest unito); nuovi `tool/check_label_imports.sh`, il suo test e le cartelle di prova; nuovi `tool/check_app_size.sh` e `tool/app_size_baseline.txt`.
- **Test esistenti di U4:** dove cambia il percorso di "Aggiungi".
- **Documenti:** `docs/release-checklist.md` (§1-bis, §1-sexies, §2, §5, voce iPhone).

## Steps

### Step 1 — Struttura e configurazione — [x]
- [x] Cartelle `lib/label/core/`, `lib/label/platform/`, `lib/label/ui/`, `test/label/`, `android/app/src/test/kotlin/`, `integration_test/support/`.
- [x] Dipendenze nuove in `pubspec.yaml` (modelli inclusi) e in `build.gradle.kts`; `flutter pub get`.
- [x] Manifest: rimozione dei tre permessi, filtro di condivisione su `MainActivity`.
- Traccia: `tech-stack-decisions.md`; NFR4.2.

### Step 2 — Runner dei test — [x]
- [x] `test/label/label_harness.dart`: `LabelReader`, `ImageSource`, `TempLabelStore` (file system finto), `WineCatalog`, `ErrorSink` e rete finti.
- [x] Runner Kotlin: Robolectric e JaCoCo con soglia dell'80% sulle due classi native.
- [x] Comandi in `unit-test-instructions.md`.

### Step 3 — Modello dei dati: implementazione — [x]
- [x] `lib/label/core/label_line_picker.dart`, `vintage_parser.dart`, `barcode_filter.dart`.
- [x] `lib/label/core/label_lookup_flow.dart`: codice con rete, poi testo; annata del testo che prevale; errori del catalogo come "nessun risultato"; al più 2 richieste.
- [x] `lib/label/core/label_session.dart`: stati e transizioni, "Annulla" con identificatore di lettura.
- Traccia: BR1.7–BR1.13 e chiarimenti; NFR5.1, NFR6.3.

### Step 4 — Modello dei dati: test — [x]
- [x] `test/label/core/`: un test per regola con l'ID nel nome, più casi limite (righe solo numeriche, "% vol", più anni, anno futuro, codici EAN-8/UPC-A/non validi, catalogo che lancia, codice senza risultato senza rete, annullamento).
- [x] Eseguire `flutter test test/label`.

### Step 5 — Accesso ai dati: implementazione — [x]
- [x] Kotlin: `LabelImagePreparer` (cartella `cacheDir/label`, percorsi solo dentro `cacheDir`, 20 MB, primi byte, HEIC da API 28, 50 milioni di pixel, `inSampleSize`, scala a 2.048, EXIF, JPEG q90, thread in background, `catch (Throwable)` con codici di scarto) e `SharedImageReceiver` (solo `content://` e `image/*`, primo URI, copia interrotta a 20 MB, intent consumato in `onCreate` e `onNewIntent`, riferimento a freddo).
- [x] Dart: `MlKitLabelReader` (codice e testo in parallelo, riconoscitori chiusi), `PickerImageSource` (senza riduzione, poi `prepare`), `SharedImageChannel`, `TempLabelStore` (rilascio in `finally`, pulizia dopo il primo frame con una `Future` attesa da ogni lettura, file più vecchi di 10 minuti, `retrieveLostData` scartato), `LabelErrorReporter` (4 motivi fissi).
- Traccia: BR1.2–BR1.7, BR1.14; NFR4.1–NFR4.5, NFR8.1, NFR8.2.

### Step 6 — Accesso ai dati: test — [x]
- [x] Kotlin con Robolectric: i casi di `cicd-pipeline.md` §1 (schema, percorsi fuori `cacheDir`, tipo, byte non immagine, oltre 20 MB, 60 milioni di pixel, HEIC con API 27 e 28, OOM simulato, EXIF, condivisione multipla, `onCreate` e `onNewIntent`).
- [x] Dart: adattatori con piattaforma finta; cartella temporanea per ogni caso di cancellazione; nessun marcatore nei report né nei gestori globali.
- [x] Eseguire `cd android && ./gradlew :app:testDebugUnitTest :app:jacocoLabelReport` e `flutter test test/label`.

### Step 7 — Logica: implementazione — [x]
- [x] `lib/label/label_providers.dart`: provider degli adattatori, `labelSessionProvider` (`autoDispose`), `sharedImageProvider` (attesa di accesso e cantina attiva, 60 s dal termine dell'accesso, scarto con messaggio, sostituzione con conferma se ci sono dati non salvati).
- [x] `lib/app/bootstrap.dart` e `providers.dart`: pulizia all'avvio dopo il primo frame.
- Traccia: BR1.4, BR1.13; NFR4.5, NFR8.1.

### Step 8 — Logica: test — [x]
- [x] Provider: condivisione a freddo (accesso lento, accesso annullato, `canEdit` assente o in caricamento, scadenza), sostituzione di una lettura, annullamento con errore tardivo che non arriva ai gestori globali.
- [x] Eseguire `flutter test`, cioè tutta la suite.

### Step 9 — Interfaccia: implementazione — [x]
- [x] `lib/label/ui/`: `AddChoiceScreen`, `LabelReadingScreen`, `LabelProposalSheet`, `LabelUnreadableView`, `BarcodeOnlyView`, `PermissionDeniedView`, con semantica e chiavi di prova.
- [x] Estensioni di U4: `AddWineInitialValues` con avviso in alto e tipologia convertita; `DuplicateDialog` pubblico; "Conferma" tramite `CellarActions.saveNewWine` con doppioni ed errore di salvataggio.
- [x] `HomeShell`: "Aggiungi" apre `AddChoiceScreen`; ascolto di `sharedImageProvider`.
- [x] Testi in it, en e pt-BR; `flutter gen-l10n`.
- Traccia: BR1.1, BR1.5, BR1.9–BR1.11, BR1.15; NFR1.3, NFR1.4, NFR3.1–NFR3.3.

### Step 10 — Interfaccia: test — [x]
- [x] `test/label/ui/` nelle tre lingue: ogni stato finale con "Riprova" o "Scrivi a mano"; percorso minimo (Aggiungi, Scatta foto, Conferma); proposta con quantità 1–99; doppione; errore di salvataggio; avviso senza rete; semantica e guideline; `textScaler` 2.0; Annulla entro 300 ms.
- [x] Test di U4 per `AddWineInitialValues` e `DuplicateDialog`.
- [x] Eseguire `flutter test`.

### Step 11 — Strumenti, CI e workflow — [ ]
- [x] `tool/check_label_imports.sh`, il suo test e le cartelle `ok/` e `firestore_import/`.
- [x] `tool/check_release_build.sh`: controllo negativo e positivo sul manifest unito in chiaro.
- [ ] `tool/check_app_size.sh` (bundletool a versione fissa con SHA-256) e `tool/app_size_baseline.txt` (valore misurato sulla build di `main` prima di U6).
- [x] `.github/workflows/ci.yml`: `analyze` (ID delle regole, import), `unit` (copertura di `lib/label/`, Gradle con Robolectric e JaCoCo, dimensione dell'app); `timeout-minutes` del job `unit` alzato solo se la misura lo richiede.
- [x] `integration_test/label_test.dart` con `support/ean13_painter.dart` e `support/fake_image_source.dart`: immagini disegnate sull'emulatore, ML Kit vero, catalogo finto, Firebase Emulator Suite.
- [ ] Eseguire:
  - `dart format --output=none --set-exit-if-changed .` e `flutter analyze --fatal-infos`;
  - gli script e i loro test;
  - Gradle con Robolectric e JaCoCo;
  - `dart run tool/gen_coverage_helper.dart`, `flutter test --coverage`, la copertura di progetto e quella di `lib/label/`;
  - `tool/check_release_build.sh` e `tool/check_app_size.sh`.
  
  I test end-to-end richiedono gli emulatori: si eseguono in Build and Test, oppure qui se sono disponibili.

### Step 12 — Documentazione e tracciabilità — [x]
- [x] `docs/release-checklist.md`: §1-sexies Foto dell'etichetta, §1-bis, §2 (foto non raccolte, ML Kit, informativa), §5, voce per la prima build iPhone, limite HEIC.
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
