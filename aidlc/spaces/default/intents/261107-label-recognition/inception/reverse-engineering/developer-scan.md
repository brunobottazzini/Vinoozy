# Scansione del codice — intent 261107-label-recognition

Repository: progetto alla radice (Vinoozy), commit di riferimento `0d99791d02005b8a90a78d17ec57cc994c820cf2`, working tree con le modifiche non committate (già approvate) degli intent 261107-pending-banner-fix e 261107-ux-redesign. Profondità Standard, scansione mirata sulla superficie "riconoscimento dell'etichetta e catalogo".

**Nota sullo stato dell'archivio**: il brief indicava un archivio CURRENT, ma `codekb-scope-diff` al momento della scansione risponde **STALE** (i 26 percorsi analizzati in precedenza sono cambiati con le modifiche non committate). La sintesi applica quindi le regole STALE: `analyzed.paths` contiene solo ciò che questa scansione ha letto a fondo; i percorsi profondi precedenti non riletti passano in `shallow.paths`; la prosa precedente è conservata, con le parti smentite dal codice attuale corrette o segnate come storiche.

## Developer Code Scan Results

### Scan Coverage
- **Analyzed deeply**:
  - lib/label/ (core, platform, ui, label_providers.dart: tutti i 24 file)
  - lib/catalog/ (core, core/off, platform: tutti i 13 file)
  - android/app/src/main/kotlin/ (MainActivity.kt, LabelImagePreparer.kt, SharedImageReceiver.kt)
  - test/label/ (elenco file e numero di test; harness letti per nome)
  - test/catalog/ (elenco file, numero di test, fixture)
  - integration_test/label_test.dart
  - tool/check_off_config.sh
  - lib/cellar/domain/wine_origins.dart (logica di `WineOrigins.guess`, struttura delle tabelle; le tabelle di dati scorse)
  - lib/cellar/ui/add_wine_screen.dart (riletto: `AddWineInitialValues`, `guessOrigin`, `_pick`, `_save`, corpo del form, `_SuggestionList`)
  - lib/cellar/domain/wine_validator.dart (riletto: validazione di regione e paese)
- **Skimmed only**:
  - android/app/src/main/AndroidManifest.xml, android/app/build.gradle.kts, android/app/src/test/kotlin/ (nomi dei test Kotlin)
  - pubspec.yaml, pubspec.lock (versioni bloccate)
  - tool/ (check_app_size.sh, app_size_baseline.txt, check_label_imports.sh, check_release_build.sh)
  - docs/release-checklist.md, docs/firebase-setup.md (§9)
  - lib/cellar/domain/wine.dart, lib/cellar/domain/wine_draft.dart (solo il campo `country`)
  - lib/cellar/cellar_providers.dart (`WineSuggestions`, ritardo 600 ms)
  - lib/app/bootstrap.dart, lib/app/home_shell.dart (cablaggio di pulizia, condivisione, `AddChoiceScreen`)
  - lib/l10n/app_it.arb (chiavi `label*`, `addChoice*`, `offAttribution`)
  - packages/estimation/lib/src/catalog.dart (solo la presenza di `denominationCatalog`)
  - firestore.rules (solo il campo `country` in `wineFields()`)
  - integration_test/support/, .github/workflows/release.yml (solo l'uso del segreto delle definizioni di produzione)
- **Left out**:
  - build/, .dart_tool/, android/.gradle/, android/build/ (output di build e cache)
  - config/firebase_prod.json, android/app/google-services.json (mai aperti per istruzione)

### Packages Found
- `lib/label/` — modulo Flutter — Dart — foto dell'etichetta: scelta della sorgente, preparazione nativa, lettura ML Kit, ricerca del vino, esiti
- `lib/catalog/` — modulo Flutter con nucleo puro (`core/`) e adattatori (`platform/`) — Dart — contratto C1 `WineCatalog`: catalogo interno, Open Food Facts, cache su file
- `android/app/src/main/kotlin/com/vinoozy/vinoozy/` — codice nativo — Kotlin — canale `com.vinoozy.app/label`: preparazione dell'immagine, ricezione di "Condividi → Vinoozy", apertura delle impostazioni
- `lib/cellar/domain/wine_origins.dart` — dominio puro — Dart — paesi ISO (249), regioni dei 21 paesi della griglia, denominazioni estere, `WineOrigins.guess`
- `packages/estimation/` — pacchetto Dart puro (superficiale) — `denominationCatalog`, `recognizeDenomination`, `normalizeWineText`

### Build System
- **Type**: Flutter (pub) + Gradle Kotlin DSL per Android
- **Config Files**: `pubspec.yaml`, `pubspec.lock`, `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`
- **Build Dependencies**: `lib/label` → `lib/catalog` (C1), `lib/cellar` (form, azioni, validazione), `lib/account` (rete, gate); `lib/catalog/core` → `estimation`; `lib/catalog/platform` → `http`, `path_provider`, `crypto`, `package_info_plus`, `firebase_crashlytics`; Kotlin → `androidx.exifinterface:exifinterface:1.4.2`

### APIs Discovered
- HTTP esterna — `lib/catalog/core/off/open_food_facts_source.dart` — 2 endpoint Open Food Facts: `GET https://world.openfoodfacts.org/cgi/search.pl` (ricerca testuale nella categoria `wines`, 10 risultati) e `GET https://world.openfoodfacts.org/api/v2/product/<barcode>.json`; campi letti `code,product_name,brands,categories_tags,origins`
- Platform channel — `lib/label/platform/shared_image_channel.dart` ↔ `MainActivity.kt` — 5 metodi Dart→nativo (`prepare`, `pendingShare`, `readShare`, `discardShare`, `openSettings`) e 1 nativo→Dart (`shareArrived`)
- ML Kit on-device — `lib/label/platform/mlkit_label_reader.dart` — `TextRecognizer(latin)`, `BarcodeScanner(ean13, ean8, upca)`
- API Dart interna C1 — `lib/catalog/core/wine_catalog.dart` — 5 operazioni (`suggestWines`, `suggestExternal`, `matchLabelText`, `getWineProfile`, `lookupBarcode`)
- Intent Android — manifest — `SEND`/`SEND_MULTIPLE` `image/*` in ingresso; in uscita solo `ACTION_APPLICATION_DETAILS_SETTINGS`; `<queries>` solo per `PROCESS_TEXT` (aggiunto dal modello Flutter)

### Frameworks & Libraries
- google_mlkit_text_recognition — 1.0.0 (lock) — testo latino on-device, modello incluso nell'app
- google_mlkit_barcode_scanning — 1.0.0 (lock) — EAN-13/EAN-8/UPC-A on-device, modello incluso
- google_mlkit_commons — 1.0.0 (transitiva)
- image_picker — 1.2.4 — fotocamera di sistema e selettore di foto Android, nessun permesso
- http — 1.6.0 — Open Food Facts
- path_provider — 2.1.6 — `cacheDir/label/`, `catalog_cache.json`
- shared_preferences — 2.5.6 — non usato da label/catalog
- crypto — 3.0.8 — hash SHA-256 dell'uid come proprietario della cache
- package_info_plus — 10.2.2 (vincolo) — versione per lo User-Agent
- androidx.exifinterface — 1.4.2 — orientamento EXIF in Kotlin
- Nessun motore di database locale (nessun sqflite, drift, isar, hive); nessun `url_launcher` diretto (solo le varianti di piattaforma transitive)

### Test Coverage
- **Test Directories**: `test/label/` (core 5 file, platform 6 file, ui 3 file, più `label_session_controller_test.dart`, `shared_image_test.dart`, `label_harness.dart`), `test/catalog/` (12 file di test, `catalog_test_helpers.dart`, `fixtures/` con 7 risposte OFF finte), `integration_test/label_test.dart` (1 e2e), `android/app/src/test/kotlin/` (`LabelImagePreparerTest.kt`, `SharedImageReceiverTest.kt`, Robolectric)
- **Test Frameworks**: flutter_test, mocktail, `MockClient` di `http`, integration_test, JUnit 4 + Robolectric 4.17
- **Coverage Config**: presente (80% delle righe senza esclusioni, `tool/check_coverage.sh`, `test/coverage_helper_test.dart` generato)

### Code Quality Indicators
- **Linting**: `flutter_lints` (`analysis_options.yaml`), `dart format`
- **CI/CD**: `.github/workflows/ci.yml` (job `analyze` con `tool/check_label_imports.sh` e `tool/check_off_config.sh`, `unit` con `tool/check_app_size.sh`, `e2e`); `release.yml` costruisce con `--dart-define-from-file=config/firebase_prod.json` ricostruito dal segreto `FIREBASE_PROD_DEFINES_JSON_B64`
- **Documentation**: commenti di classe ricchi, legati a BR/NFR di u3 e u6; `docs/release-checklist.md` §1-bis, §1-sexies, §2 per privacy e misure

### Technical Debt Signals
- `lib/label/core/label_lookup_flow.dart:96` chiama `matchLabelText` anche senza rete; `CatalogCoordinator._external` (`catalog_coordinator.dart:217-263`) non conosce lo stato della rete: offline la ricerca OFF fallisce per rete e conta come guasto nell'interruttore (3 letture offline di seguito → sospensione di 5 minuti e un evento `off_suspended` in Crashlytics nelle build di rilascio).
- `tool/app_size_baseline.txt` contiene `UNSET`: il controllo della dimensione (+15 MB) non è mai stato tarato; l'AAB pre-U6 (24.634.405 byte) è fuori da git.
- `matchLabelText` sceglie in silenzio il primo risultato della ricerca (filtrato per denominazione quando riconosciuta): nessuna lista di candidati all'utente nel flusso etichetta.
- Due limiti di 2000 caratteri sullo stesso testo (`LabelReading.maxTextLength`, `maxLabelTextLength`): unire fronte e retro li raggiunge prima.
- L'annata è calcolata due volte: `ParsedQuery` nel coordinatore (primo numero a 4 cifre) e `VintageParser` nel flusso, che sovrascrive.

## Mappa per l'intent

### 1. Cattura e lettura (oggi: una sola foto)
- **Ingresso**: `HomeShell` apre `AddChoiceScreen` (`add-choice-photo`, `add-choice-import`, `add-choice-write`). "Scatta foto" e "Importa una foto" chiamano `LabelCaptureFlow.run` con `PhotoOrigin.camera`/`gallery`; "Scrivi" chiama `LabelCaptureFlow.openForm`.
- **Sorgenti**: `PickerImageSource.pick` → `ImagePicker.pickImage(source, requestFullMetadata: false)`, nessun ridimensionamento; esiti `PickedImage`, `PickCancelled`, `PickDenied`, `PickCameraUnavailable`, `PickFailed`. Terza sorgente: "Condividi → Vinoozy" (`SharedImageReceiver`, solo la prima immagine; `SharedImageNotifier` + `SharedImagePolicy` decidono quando leggerla: attesa dell'accesso, 60 s, permesso di modifica entro 5 s).
- **Preparazione nativa** (`LabelImagePreparer.kt`): solo file dentro `cacheDir`; ≤ 20 MB; firma JPEG/PNG/WebP/HEIC (HEIC da API 28); ≤ 50 Mpx; decodifica con `inSampleSize`, scala a 2048 px sul lato lungo, orientamento EXIF, JPEG q90 in `cacheDir/label/<uuid>.jpg`; l'input viene **sempre cancellato**; rifiuti con codici fissi `scheme|type|size|format|decode`.
- **Lettura**: `LabelSessionController._read` → `TempLabelStore.beforeRead` (attende la pulizia d'avvio, cancella file > 10 min) → `SharedImageChannel.prepare`/`readShare` → `MlKitLabelReader.read` (codici e testo **in parallelo** sulla stessa immagine; blocchi ordinati per `top` poi `left`, righe unite con `\n`, testo tagliato a 2000 caratteri) → `LabelLookupFlow.run` → `finally { TempLabelStore.release(path) }`: la copia preparata si cancella appena finisce la lettura, qualunque sia l'esito.
- **Lettore**: uno per sessione (`labelReaderFactoryProvider`), chiuso in `_onDispose` dopo il lavoro in corso.
- **Nessun supporto multi-foto**: `LabelInput`, `LabelSession`, `LabelReader.read(String imagePath)` e `LabelReading` sono per un'immagine; non esiste unione di testi né una seconda acquisizione.

### 2. Pipeline di riconoscimento (ordine reale)
`LabelLookupFlow.run` (`label_lookup_flow.dart:77-101`):
1. `BarcodeFilter.firstValid`: primo EAN-13/EAN-8/UPC-A con cifra di controllo GS1 valida (UPC-A portato a 13 cifre).
2. Nessun codice e meno di 3 lettere → `LookupUnreadable`.
3. Codice valido **e** rete → `lookupBarcode` = OFF `/api/v2/product/<code>.json` (attraverso cache, interruttore, budget). Trovato → `LookupProposal(offline: false)` con l'annata del testo.
4. Solo codice, poco testo → `LookupBarcodeOnly(needsNetwork: !online)`.
5. `matchLabelText(text, locale)`: (a) `recognizeDenomination` sul testo (catalogo interno C2, 47 denominazioni italiane secondo la scansione precedente); (b) ricerca OFF `search.pl` con al massimo 6 parole (le più lunghe, ≥ 3 lettere, senza cifre); (c) primo risultato che ha la stessa denominazione (o il primo in assoluto se nessuna denominazione) → candidato OFF arricchito con tipo, regione e denominazione interni; (d) altrimenti, se c'è una denominazione, candidato `internal` con nome = denominazione; (e) altrimenti `LabelMatch.none()`.
6. Candidato → `LookupProposal(offline: !online)`; nessuno → `LookupIncomplete(name: LabelLinePicker.pick(text), vintage)`.

Quindi l'ordine è **codice a barre su OFF → ricerca testuale OFF → denominazione interna → form incompleto**; il catalogo interno fa da ripiego dopo OFF, non prima. Al massimo 2 chiamate al catalogo per foto. Nessuna base dati locale di prodotti: senza rete un codice a barre non trova mai nulla.

### 3. Open Food Facts
- Host fisso `world.openfoodfacts.org`, HTTPS, nessun redirect, solo `User-Agent: Vinoozy/<versione> (<OFF_CONTACT>)`, scadenza unica 5 s, corpo ≤ 1 MB in streaming, JSON → `WineCandidate` solo se `categories_tags` contiene `en:wines`; nome ≤ 120, produttore = primo marchio ≤ 80, regione = `origins` ≤ 60, denominazione riconosciuta dal nome.
- **Budget** (`RequestBudget`): finestra mobile di 60 s, 8 ricerche e 60 letture di prodotto; in memoria; le risposte dalla cache non contano.
- **Interruttore** (`OffCircuitBreaker`): 3 guasti di seguito → sospeso 5 min, un evento non fatale `off_suspended` in Crashlytics con chiavi `off_last_failure`, `off_ok`, `off_failed`, `cache_hit_ratio`, `cache_resets`. Nessun nuovo tentativo automatico.
- **Cache** (`CatalogCacheStore` + `FileCacheFile`): `catalog_cache.json` nella cartella di supporto (esclusa dal backup), chiavi `search:<testo normalizzato>` e `product:<codice>`, 30 giorni, 200 risposte × 10 candidati, 500 suggerimenti di profilo, salvataggio raggruppato ogni 2 s con file temporaneo e rinomina, proprietario = SHA-256 dell'uid, cancellata al cambio utente.
- **Accensione**: OFF esiste solo se `OFF_CONTACT` (definizione di compilazione) non è vuoto (`catalog_providers.dart:77-89`). Le build demo, i test, l'e2e e la CI non lo hanno: `offSource` è `null`, ogni chiamata esterna registra `offDisabled` e ritorna `null`. In produzione arriva da `config/firebase_prod.json` (segreto `FIREBASE_PROD_DEFINES_JSON_B64`).
- **`tool/check_off_config.sh`**: fallisce se `OFF_CONTACT` ha un valore in un file versionato (aidlc/ e docs/ esclusi) o compare nei workflow; se c'è un indirizzo email nel Dart di `lib/` (l10n esclusa); se `lib/catalog/` importa Firestore o Cloud Functions; se `lib/catalog/core/` importa Flutter, Riverpod, path_provider, Firebase o `dart:ui`.

### 4. Dalla proposta al form
- "Conferma" (`LabelReadingScreen._confirm`): `guessOrigin(candidate)` → `WineValidator.validate(WineInput(..., region, denomination, country))` → `CellarActions.saveNewWine`; doppione → `DuplicateDialog` + `addBottles`; bozza non valida → apre "Correggi".
- "Correggi": `AddWineInitialValues.fromCandidate(candidate, quantity)` → `LabelCaptureFlow.openForm` → `AddWineScreen` con nome, produttore, annata (o "Senza annata"), quantità, tipologia (`wineFamilyOf`), paese e regione da `guessOrigin`, denominazione; tutto modificabile (`CountryPicker`, `RegionPicker`).
- Form incompleto: `AddWineInitialValues(name, vintage, notice: labelNotFound)` — nessun produttore, paese o regione.
- `WineOrigins.guess`: denominazione italiana (→ IT + regione), poi denominazione estera della tabella (circa 47 voci: FR, ES, PT, HU, AU, US), poi `origins` diviso per virgole (nome di paese → paese; regione elencata → regione; altrimenti testo libero).
- `LabelProposalSheet` mostra nome, produttore, annata, bandiera e nome del paese, regione, distintivo del tipo, avviso offline, quantità, "Conferma", "Correggi".
- Modello riusabile per una lista di candidati: `_SuggestionList` in `add_wine_screen.dart` (lista di `ListTile` con sottotitolo produttore · annata · denominazione e riga di attribuzione `offAttribution` quando c'è un candidato OFF).

### 5. Viste d'errore
- `LabelUnreadableView` (`label-unreadable`): "Riprova", "Scrivi a mano".
- `BarcodeOnlyView` (`label-barcode-only`): con rete "Ho letto il codice a barre ma non trovo il vino" + suggerimento "Fotografa il fronte"; senza rete anche "Riprova quando torna la rete" (`label-retry-online`, `retryBarcode` senza nuova foto; il codice resta solo in memoria).
- `PermissionDeniedView` (`label-permission-denied`, `label-camera-unavailable`): "Apri impostazioni" o "Importa una foto", "Scrivi a mano".
- Layout comune `LabelMessageLayout`; pulsanti `labelActionStyle()` alti ≥ 48 dp.
- Nessuna azione "Cerca online" né "Apri in Google Lens" in alcuna vista.

### 6. Android e altre app
- Manifest: permessi `INTERNET`, `ACCESS_NETWORK_STATE`; `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE` rimossi con `tools:node="remove"` (verificato sul manifest unito da `tool/check_release_build.sh`). Filtro `SEND`/`SEND_MULTIPLE` `image/*`. `<queries>` contiene solo `PROCESS_TEXT`.
- Nessun `FileProvider` dichiarato dall'app (eventuali provider dei plugin non verificati); nessun intent verso Google Lens o `com.google.android.googlequicksearchbox`; l'unico `startActivity` è `openAppSettings`.
- `minSdk 24`, Kotlin JVM 17.

### 7. Privacy (stato attuale)
- Foto: lette solo sul telefono; copia di lavoro in `cache/label/`, cancellata alla fine della lettura (al più 10 minuti, e al riavvio dopo una chiusura forzata); mai inviate. Report d'errore con soli motivi fissi (`label_read_failed`, `label_pick_failed`, `label_lookup_failed`, `label_cleanup_failed`) e tipo dell'eccezione.
- `docs/release-checklist.md` §1-bis e §2: verso OFF vanno testo cercato, alcune parole dell'etichetta e codici a barre con l'IP, mai il testo intero né l'immagine; "Foto delle etichette" **non** dichiarate come raccolte; ML Kit può inviare a Google dati diagnostici anonimi (da verificare per la scheda "Sicurezza dei dati").
- Il controllo `tool/check_label_imports.sh` vieta `cloud_firestore` e `firebase_storage` in `lib/label/`.

### 8. Dimensione e risorse
- Nessuna sezione `flutter: assets:` in `pubspec.yaml`; `assets/` contiene solo `icon/`.
- `tool/check_app_size.sh`: crescita massima +15 MB sul valore di `tool/app_size_baseline.txt`, che è `UNSET`; AAB pre-U6 di 24.634.405 byte conservato fuori da git.

### 9. Test che coprono la superficie (solo nomi)
- `test/label/core/`: `barcode_filter_test.dart`, `label_line_picker_test.dart`, `label_lookup_flow_test.dart`, `label_session_test.dart`, `vintage_parser_test.dart`
- `test/label/platform/`: `label_error_reporter_test.dart`, `mlkit_label_reader_test.dart`, `picker_image_source_test.dart`, `shared_image_channel_test.dart`, `temp_label_store_test.dart`
- `test/label/ui/`: `label_screens_test.dart`, `shell_share_test.dart`, `label_ui_harness.dart`
- `test/label/`: `label_session_controller_test.dart`, `shared_image_test.dart`, `label_harness.dart`
- `test/catalog/`: `backup_rules_test.dart`, `catalog_cache_store_test.dart`, `catalog_coordinator_test.dart`, `catalog_providers_test.dart`, `crashlytics_catalog_event_logger_test.dart`, `file_cache_file_test.dart`, `internal_catalog_test.dart`, `off_circuit_breaker_test.dart`, `open_food_facts_source_test.dart`, `release_docs_test.dart`, `request_budget_test.dart`, `wine_catalog_types_test.dart`, `catalog_test_helpers.dart`, `fixtures/`
- e2e: `integration_test/label_test.dart` (un test: file danneggiato → illeggibile; solo codice a barre → "solo codice" perché OFF è spento nella build demo; "Barolo DOCG 2016" → proposta interna → "Conferma" → vino nell'emulatore Firestore; cartella `label/` vuota)
- Kotlin: `LabelImagePreparerTest.kt`, `SharedImageReceiverTest.kt`

## Handoff Summary
- **Intent-relevant finding**: la pipeline legge una sola foto e cerca in quest'ordine: codice a barre su OFF (solo con rete) → ricerca testuale OFF automatica con 6 parole e scelta silenziosa del primo risultato → denominazione interna → form incompleto (`lib/label/core/label_lookup_flow.dart:77-101`, `lib/catalog/core/catalog_coordinator.dart:113-165`). Per i quattro punti: (1) nessun supporto a fronte+retro, l'unità di lettura è un'immagine (`LabelReader.read(String imagePath)`) e il testo è limitato a 2000 caratteri in due punti; (2) nessun motore di database locale, nessun asset, nessuna pipeline di esportazione OFF, e il nucleo `lib/catalog/core/` deve restare Dart puro (`tool/check_off_config.sh` regola 4), quindi un adattatore di database va in `lib/catalog/platform/`; il controllo della dimensione (+15 MB) ha la base `UNSET`; (3) l'endpoint di ricerca testuale **è già usato** (`/cgi/search.pl`, categoria `wines`, 10 risultati) sia dai suggerimenti del form (dopo 600 ms) sia da `matchLabelText`, ma nessuna vista d'esito offre "Cerca online" né mostra candidati; `_SuggestionList` del form è il modello da riusare, e senza `OFF_CONTACT` (build demo, CI, e2e) la ricerca è spenta; (4) nessun intent verso Google Lens, `<queries>` contiene solo `PROCESS_TEXT`, nessun `FileProvider` dell'app, e la copia preparata della foto è cancellata nel `finally` di `LabelSessionController._read` prima che l'utente possa toccare qualcosa.
- **Risks / follow-up**: (a) l'archivio era STALE e non CURRENT: la sintesi ha demotato a superficiali i percorsi precedenti non riletti (il confronto di copertura risponderà NARROWER per quelli); (b) offline `matchLabelText` prova comunque OFF e ogni lettura offline conta un guasto nell'interruttore; (c) "Apri in Google Lens" contraddice l'attuale dichiarazione "le foto non lasciano il telefono" (checklist §2, informativa) e richiede di tenere la copia fino al tocco esplicito, oltre a `<queries>` e a un `FileProvider`; (d) un database OFF sul telefono cambia la dimensione dell'app e la licenza ODbL richiede l'attribuzione anche per i dati locali; (e) nessun servizio a pagamento è usato oggi: ML Kit on-device e OFF sono gratuiti.
