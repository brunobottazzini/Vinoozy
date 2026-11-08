# Valutazione della qualità del codice — Vinoozy

## Test

| Livello | Dove | Strumento |
|---|---|---|
| Unit e widget | `test/` per modulo (it, en, pt-BR per le schermate) | `flutter test --coverage`, mocktail, `MockClient` |
| Pacchetto estimation | `packages/estimation/test/` | `dart test` + `coverage` |
| Kotlin | `android/app/src/test/kotlin/` (`LabelImagePreparerTest.kt`, `SharedImageReceiverTest.kt`) | JUnit 4 + Robolectric |
| Regole Firestore | `test/rules/*.rules.test.mjs`, `test/rules/compat/` | `@firebase/rules-unit-testing` su emulatore |
| Pagina web | `test/web/*.test.mjs` | node:test + c8 (80%) |
| End-to-end | `integration_test/*.dart` | `integration_test` su emulatore Android API 34 + Firebase Emulator Suite |

Copertura: soglia 80% delle righe sul lcov unito app + `estimation`, senza esclusioni (`tool/check_coverage.sh 80`), job `unit` di `ci.yml`. `test/coverage_helper_test.dart` è generato da `tool/gen_coverage_helper.dart` e importa ogni file di `lib/`, così un file nuovo senza test conta 0%.

### Banco di prova dei widget

- `test/helpers/ui_harness.dart`: `pumpScreen` e `accessibilityMatrix` (it, en, pt-BR × testo 1.0/2.0 × chiaro/scuro: overflow, contrasto, aree di tocco, etichette).
- Schermate dell'etichetta sotto matrice (3 chiamate alla scansione ux-redesign).
- Harness di modulo: `test/cellar/cellar_harness.dart` (`BatchRecorder`), `test/cellar/ui/cellar_ui_harness.dart`, `test/label/label_harness.dart`, `test/label/ui/label_ui_harness.dart`, `test/catalog/catalog_test_helpers.dart`, `test/dashboard/dashboard_harness.dart`.
- Nessun test golden.

### Test dell'etichetta e del catalogo (numero di `test`/`testWidgets` per file)

Conteggi della scansione label-recognition; quelli attuali sono nella sezione dell'intent 261108-label-autofill-windows in fondo.

| File | Test |
|---|---|
| `test/label/core/barcode_filter_test.dart` | 8 |
| `test/label/core/label_line_picker_test.dart` | 10 |
| `test/label/core/label_lookup_flow_test.dart` | 17 |
| `test/label/core/label_session_test.dart` | 8 |
| `test/label/core/vintage_parser_test.dart` | 9 |
| `test/label/label_session_controller_test.dart` | 15 |
| `test/label/shared_image_test.dart` | 17 |
| `test/label/platform/label_error_reporter_test.dart` | 3 |
| `test/label/platform/mlkit_label_reader_test.dart` | 6 |
| `test/label/platform/picker_image_source_test.dart` | 5 |
| `test/label/platform/shared_image_channel_test.dart` | 4 |
| `test/label/platform/temp_label_store_test.dart` | 8 |
| `test/label/ui/label_screens_test.dart` | 23 |
| `test/label/ui/shell_share_test.dart` | 5 |
| `test/catalog/backup_rules_test.dart` | 3 |
| `test/catalog/catalog_cache_store_test.dart` | 19 |
| `test/catalog/catalog_coordinator_test.dart` | 27 |
| `test/catalog/catalog_providers_test.dart` | 8 |
| `test/catalog/crashlytics_catalog_event_logger_test.dart` | 3 |
| `test/catalog/file_cache_file_test.dart` | 6 |
| `test/catalog/internal_catalog_test.dart` | 11 |
| `test/catalog/off_circuit_breaker_test.dart` | 6 |
| `test/catalog/open_food_facts_source_test.dart` | 18 |
| `test/catalog/release_docs_test.dart` | 3 |
| `test/catalog/request_budget_test.dart` | 4 |
| `test/catalog/wine_catalog_types_test.dart` | 12 |

Fixture OFF finte in `test/catalog/fixtures/`: `product_wine.json`, `product_not_wine.json`, `product_not_found.json`, `search_wines.json`, `search_empty.json`, `search_malformed_fields.json`, `invalid_json.txt`. `release_docs_test.dart` verifica che `docs/release-checklist.md` contenga le voci su `OFF_CONTACT`.

End-to-end `integration_test/label_test.dart` (un test): immagini disegnate sull'emulatore (nessun file nel repository), `FakeImageSource` al posto della fotocamera, canale nativo e ML Kit reali; file danneggiato → `label-unreadable`; solo codice EAN-13 → `label-barcode-only` (OFF spento nella build demo); "Barolo DOCG 2016" → `label-proposal` → `label-confirm` → vino nell'emulatore Firestore; cartella `label/` vuota alla fine. Limite di lettura sull'emulatore 10 s.

## Analisi statica e CI

- `flutter_lints` (`analysis_options.yaml`), `dart format` in CI.
- `ci.yml`: `format`, `secrets`, `analyze` (con `check_label_imports.sh`, `check_off_config.sh`), `unit` (con `check_app_size.sh`), `estimation`, `rules`, `e2e`; tutti bloccano il merge.
- `release.yml` (AAB sul canale interno, con le definizioni di produzione dal segreto), `promote.yml`, `firebase-deploy.yml`, `pages.yml`.
- Script di controllo in `tool/` con i propri test.

## Documentazione

`README.md` presente; commenti di classe e metodo ricchi, legati a requisiti e documenti di design. `docs/release-checklist.md` copre misure, smoke test e privacy per u3 e u6.

## Difetto NFR6.6: fascia "in attesa" dopo una bevuta offline

Analisi della scansione pending-banner-fix. La correzione è nel working tree (non committata) e i file citati sono cambiati; numeri di riga e descrizione si riferiscono al codice di allora.

### Sintomo

Dopo "Bevuto" senza rete, in particolare sull'ultima bottiglia, la fascia "modifiche in attesa" a volte non compariva. L'e2e `integration_test/cellar_test.dart` falliva in modo intermittente.

### Causa

Le due chiamate di piattaforma `batch.commit()` e `waitForPendingWrites()` partono dal Dart nell'ordine giusto, ma il plugin Android `cloud_firestore` 7.1.0 le esegue ciascuna in un thread del pool di `firebase_core`, senza ordine garantito. Se `waitForPendingWrites` raggiunge il SDK prima del batch, la coda è vuota e l'attesa si chiude subito, anche offline: la sonda torna a `false` e la fascia non compare. L'ultima bottiglia è il caso più esposto perché nessun'altra fonte segnala "in attesa".

### Fatto utile per la correzione

Il `Future` di `batch.commit()` si completa solo alla conferma del server (o con errore): è il segnale esatto "questa scrittura è arrivata", indipendente dall'ordine con `waitForPendingWrites()`.

### Test esistenti alla scansione

`test/cellar/data/pending_writes_probe_test.dart`, `test/cellar/data/drinking_record_repository_test.dart`, `test/u1/sync/sync_status_test.dart`, `test/cellar/cellar_providers_test.dart`, `integration_test/cellar_test.dart`; strumento per la regressione `BatchRecorder.commitWith` in `test/cellar/cellar_harness.dart`.

## UX 1-3 (scansione ux-redesign, storico)

Alla scansione ux-redesign il form non aveva paese né regione, la "Bevuta" salvava subito senza conferma e il tema aveva 5 token per tema. Quell'intent ha cambiato tutti e tre i punti nel working tree. Per il form la situazione attuale è riverificata (vedi [component-inventory.md](component-inventory.md#addwinescreen)): `CountryPicker` e `RegionPicker` nel form, `country` ISO nel modello, nel validatore e nelle regole Firestore, regione canonica ≤ 120 validata in app. Bevuta e tema non sono stati riletti.

## Label 1: una sola foto per lettura

- **Fatto**: l'unità di lettura è un'immagine. `LabelReader.read(String imagePath)` (`lib/label/core/label_reading.dart:54`), `LabelInput` con un solo percorso (`lib/label/label_providers.dart:82-91`), `LabelCaptureFlow.run` apre un solo selettore e una sola `LabelReadingScreen` (`lib/label/ui/label_capture_flow.dart:41-71`), `SharedImageReceiver` tiene solo la prima immagine condivisa.
- **Testo**: tagliato a 2000 caratteri in `MlKitLabelReader.read` e in `LabelLookupFlow.run` (`LabelReading.clampText`); `matchLabelText` rifiuta oltre 2000 (`textTooLong`). Fronte + retro superano più facilmente il limite: il retro (ingredienti, allergeni, indirizzi) aggiunge rumore che `labelSearchWords` (6 parole più lunghe) potrebbe preferire alle parole del fronte.
- **Codici**: `BarcodeFilter.firstValid` prende il primo valido; il codice sta di solito sul retro, quindi con due foto conviene unire anche i codici.
- **Ordine dei blocchi**: `orderedText` ordina per `top` poi `left` dentro una sola immagine; l'unione di due letture va decisa (fronte prima).
- **Costo**: ogni lettura crea al più un lettore ML Kit per sessione e lo riusa (`_reader ??= newReader()`); due immagini nella stessa sessione possono riusare lo stesso lettore.

## Label 2: nessun database locale di vini

- **Fatto**: nessun motore di database tra le dipendenze; nessun asset di dati (`pubspec.yaml` senza `assets:`); nessuno script o workflow che scarichi o trasformi l'esportazione di Open Food Facts.
- **Fonte offline attuale**: solo `InternalCatalog` = denominazioni italiane di `estimation` (47 alla prima scansione) + vini della cantina. Senza rete: un codice a barre non trova mai nulla (`LookupBarcodeOnly(needsNetwork: true)`), il testo trova solo una denominazione (`LookupProposal(offline: true)` con nome = denominazione, senza produttore).
- **Vincoli per aggiungerlo**: purezza di `lib/catalog/core/` (regola 4 di `check_off_config.sh`) ⇒ adattatore in `platform/`; controllo della dimensione +15 MB con base mai misurata (`UNSET`); copertura 80% senza esclusioni; attribuzione ODbL anche per i dati locali; `WineCandidate.source` ha solo `cellar`, `internal`, `openFoodFacts` (una fonte locale OFF userebbe probabilmente `openFoodFacts` per l'attribuzione o una nuova voce, che cambia anche la priorità di `mergeCandidates` e la cache a chiavi corte).
- **Punto d'innesto**: `CatalogCoordinator.lookupBarcode` e `matchLabelText` prima di `_external`; `LabelLookupFlow.run` chiama `lookupBarcode` solo con rete (`label_lookup_flow.dart:89`), condizione da rivedere se il database risponde offline.

## Label 3: ricerca testuale non esposta all'utente

- **Fatto**: la ricerca testuale OFF esiste (`OpenFoodFactsSource.searchUri`, `/cgi/search.pl`, categoria `wines`, 10 risultati) ed è usata da `suggestExternal` (form, 600 ms) e da `matchLabelText` (etichetta). In `matchLabelText` il primo risultato con la stessa denominazione viene scelto senza mostrare gli altri (`catalog_coordinator.dart:133-136`).
- **Mancanze**: nessuna azione "Cerca online" in `LabelUnreadableView`, `BarcodeOnlyView`, nel form incompleto o nella proposta; nessuna lista di candidati nel flusso etichetta. Il modello da riusare è `_SuggestionList` di `add_wine_screen.dart` (privato al file) con l'attribuzione ODbL.
- **Limiti da rispettare**: 8 ricerche al minuto (`RequestBudget`), sospensione dopo 3 guasti, ricerca ≥ 3 caratteri per `suggestExternal`, query ≤ 120 caratteri; OFF spento senza `OFF_CONTACT` (build demo, CI, e2e: la funzione va provata con `MockClient` e non è raggiungibile nell'e2e).
- **Riempimento parziale**: un candidato OFF può non avere produttore, tipo o regione; `AddWineInitialValues.fromCandidate` e `_pick` già lasciano vuoti i campi assenti e deducono paese/regione con `guessOrigin`.
- **Segnale di debito**: offline `LabelLookupFlow` chiama comunque `matchLabelText` (`label_lookup_flow.dart:96`) e `CatalogCoordinator._external` non controlla la rete: ogni lettura offline con testo è un guasto `network` per l'interruttore; tre di seguito producono un `off_suspended` in Crashlytics (soglia di allarme in `docs/release-checklist.md`: più di 20 eventi o più di 3 utenti in 7 giorni).

## Label 4: nessun passaggio a Google Lens

- **Fatto**: nessun intent verso altre app oltre alle impostazioni (`MainActivity.openAppSettings`); `<queries>` contiene solo `PROCESS_TEXT`; nessun `FileProvider` dichiarato dall'app; nessuna chiave di testo.
- **Ciclo di vita della foto**: la copia preparata in `cache/label/` è cancellata nel `finally` di `LabelSessionController._read` (`label_providers.dart:253-255`) prima che l'esito sia mostrato; l'originale della fotocamera è cancellato da `LabelImagePreparer.prepareFile` subito dopo la preparazione; `TempLabelStore` cancella anche tutto all'avvio e i file oltre 10 minuti. Per passare la foto a un'altra app su tocco esplicito serve trattenerne una copia finché la vista d'esito è aperta (e cancellarla dopo), o ripreparare l'immagine.
- **Privacy**: `docs/release-checklist.md` §2 dichiara le foto "non raccolte", lette solo sul telefono, mai nel cloud; l'informativa dice che non si conservano. Un passaggio esplicito a Google Lens è un invio deciso dall'utente a un'altra app e va descritto nell'informativa e valutato per la scheda "Sicurezza dei dati".
- **Android**: da Android 11 serve dichiarare in `<queries>` il pacchetto o l'intent di destinazione; il manifest unito è controllato da `tool/check_release_build.sh` (oggi solo per i permessi vietati).

## File di test interessati dall'intent 261107-label-recognition (solo nomi)

- **Cattura e lettura**: `test/label/platform/mlkit_label_reader_test.dart`, `test/label/platform/picker_image_source_test.dart`, `test/label/platform/shared_image_channel_test.dart`, `test/label/platform/temp_label_store_test.dart`, `test/label/label_session_controller_test.dart`, `test/label/core/label_session_test.dart`, `test/label/label_harness.dart`, `android/app/src/test/kotlin/com/vinoozy/vinoozy/LabelImagePreparerTest.kt`, `android/app/src/test/kotlin/com/vinoozy/vinoozy/SharedImageReceiverTest.kt`.
- **Pipeline di riconoscimento**: `test/label/core/label_lookup_flow_test.dart`, `test/label/core/barcode_filter_test.dart`, `test/label/core/vintage_parser_test.dart`, `test/label/core/label_line_picker_test.dart`, `test/catalog/catalog_coordinator_test.dart`, `test/catalog/internal_catalog_test.dart`, `test/catalog/wine_catalog_types_test.dart`.
- **Open Food Facts**: `test/catalog/open_food_facts_source_test.dart`, `test/catalog/request_budget_test.dart`, `test/catalog/off_circuit_breaker_test.dart`, `test/catalog/catalog_cache_store_test.dart`, `test/catalog/file_cache_file_test.dart`, `test/catalog/catalog_providers_test.dart`, `test/catalog/crashlytics_catalog_event_logger_test.dart`, `test/catalog/backup_rules_test.dart`, `test/catalog/release_docs_test.dart`, `test/catalog/fixtures/`.
- **Viste e form**: `test/label/ui/label_screens_test.dart`, `test/label/ui/shell_share_test.dart`, `test/label/ui/label_ui_harness.dart`, `test/label/shared_image_test.dart`, `test/cellar/ui/add_wine_screen_test.dart`, `test/cellar/ui/add_wine_initial_values_test.dart`.
- **End-to-end**: `integration_test/label_test.dart`, `integration_test/support/fake_image_source.dart`, `integration_test/support/ean13_painter.dart`.
- **Controlli di script**: `tool/check_label_imports_test.sh`, `tool/check_off_config.sh`, `tool/check_app_size.sh`, `tool/check_release_build.sh`.
- **Sempre**: `test/coverage_helper_test.dart` (rigenerato per ogni file nuovo in `lib/`).

## Altri segnali di debito tecnico

- `tool/app_size_baseline.txt` vale `UNSET`: il controllo della dimensione non ha mai confrontato nulla.
- Doppio calcolo dell'annata: `ParsedQuery` nel coordinatore (primo numero di 4 cifre) e `VintageParser` nel flusso, che sovrascrive sempre.
- `WineCandidate.copyWith` cambia solo l'annata.
- Stesso presupposto d'ordine in `SyncWatcher._drain` (scansione pending-banner-fix).
- `drinkingRecordsPendingProvider` globale e non `autoDispose` (scansione pending-banner-fix).
- `AddWineScreen` (683 righe) e `EditWineScreen` duplicano i campi del vino.

## Intent 261108-label-autofill-windows: punti di attenzione

Verificato sul working tree attuale. Le sezioni "Label 1-4" più sopra descrivono u6 alla scansione label-recognition: nel working tree fronte e retro, base offline (45 vini di prova), "Cerca online" e "Apri in Google Lens" esistono già.

### Compilazione dal testo

- **Fatto**: dal testo letto l'app ricava solo l'annata (`VintageParser.parse`) e la riga più significativa (`LabelLinePicker.pick`: prima riga con una denominazione italiana, altrimenti la più lunga che non sia volume, gradi o solfiti). Produttore, denominazione, tipo, paese e regione vengono solo da un candidato di una base dati (`AddWineInitialValues.fromCandidate`). "Scrivi a mano" da "Non trovato" passa `name` e `vintage` (`label_reading_screen.dart:172-184`).
- **Riconoscibile oggi senza base dati**: denominazioni italiane (47, con tipo e regione), denominazioni estere di `WineOrigins._denominations` (47, solo paese e regione), nomi e alias dei paesi (`countryNamed`), regioni dei 21 paesi della griglia (`findRegion`), annata. Nessun riconoscimento del produttore (né elenco di parole come "Cantina", "Tenuta", "Château", "Bodega", "Weingut"), nessun riconoscimento del tipo da parole come "rosso", "bianco", "spumante", "brut", "passito".
- **"Incolla da Lens"**: nessun ingresso di testo. Nessuna lettura degli appunti in `lib/`; il manifest accetta solo `image/*` in condivisione; Google Lens è solo in uscita e la documentazione dice che Vinoozy non riceve i risultati (`labelLensBody`, `aboutPrivacy`). Il testo di Lens copiato di solito è su più righe e senza ordine fisso: l'unione delle righe e i limiti di `MergedReading` (≤ 4000) e di `matchLabel` sono già adatti a un testo incollato.
- **Limiti da rispettare**: nome ≤ 120 (app e regole), produttore, regione e denominazione ≤ 120 (regole), annata 1900-anno corrente (app) o anno del server + 1 (regole); nulla si salva senza conferma; i testi letti non vanno mai nei report (`ReadBarcode`, `WineCandidate` e i report del modulo escludono i valori).

### Stima per tutto il mondo

- **Fatto**: `denominationTable` ha 47 righe, tutte italiane; un Rioja, un Bordeaux o un Napa Cabernet ricevono la riga del tipo scelto o, senza tipo, la generica (1, 3, 6) con fiducia `low` e avviso `GENERIC_ESTIMATE`. Nessun vitigno.
- **Doppio elenco**: le denominazioni estere sono in `WineOrigins._denominations` (app, solo origine); quelle italiane con finestra in `estimation`. Il riconoscimento è diverso: `foldOriginText` (Latin-1 e Latin Extended-A) contro `tokenizeAll` (solo Latin-1: lettere come la "ő" ungherese o la "ř" ceca diventano separatori invece di essere piegate).
- **Vincoli del pacchetto**: nessuna dipendenza (`tool/check_estimation_purity.sh`), tabelle `const`, alias già normalizzati (`tables_test.dart` lo verifica con `^[a-z0-9]+( [a-z0-9]+)*$`), 3-5 categorie di abbinamento per riga, scostamenti ordinati e non negativi; ogni riga ha un nome mostrato e una regione in `denominationLabels` (oggi sempre una regione italiana: per righe estere servirebbe anche un paese, e `recognizeDenomination` è usato da `WineOrigins.guess` per dedurre l'Italia).
- **Rischio di riconoscimento**: alias brevi come parole comuni (per esempio "cava", "porto", "douro", "napa") vanno cercati a parole intere e possono dare falsi positivi nel testo di un'etichetta; `tokenize` del nome esamina solo 60 caratteri.
- **Regola di progetto**: le scelte enologiche (finestre, scostamenti) si decidono in autonomia con motivazione, correggibili (`project.md`, Corrections).

### "Livello" e "Consigliato fino al" manuale

- **Fatto**: nessun campo nel modello (`WineFields`), nelle regole (`wineFields()`), nei form né negli ARB. `DrinkingWindow` non ha un livello; le regole ammettono per `source` solo `catalog`/`internalRules`.
- **Sovrascritture**: la finestra viene riscritta da `CellarActions.saveEdit` (ogni salvataggio della modifica), da `EstimateRefresher` (finestre `internalRules`, al ritorno della rete), da `recomputeAdjustment` (dopo una bevuta con "Com'era?", partendo da `baseWindow`) e da `ensureEstimates` (solo vini senza finestra). `WineEstimator.displayed` ricalcola in memoria quando la finestra manca. Un valore manuale salvato solo in `window.endYear` andrebbe perso; uno salvato in un campo nuovo va combinato con il riscontro delle bevute e con `statusOf` (stato "da bere presto" sugli ultimi mesi della finestra).
- **Coerenza della finestra**: `validWindow` chiede `startYear ≤ peakYear ≤ endYear` e anni 1900-2200; una fine manuale più bassa dell'inizio o del picco va gestita prima della scrittura.
- **Letture della fine**: `IdealMomentCard` ("Consigliato fino al", barra, inizio/picco/fine), `WineCard` (stato nella riga), `DashboardCalculator` (`DrinkSoonRow.endYear`, "entro il {year}"), `StatusFilter` della cantina. La fonte mostrata viene da `WindowAdjuster.labelOf` (tre valori, nessuno per "impostato da te").
- **Compatibilità**: nuovi campi richiedono una nuova versione in `test/rules/compat/app-writes.json` con `requiresRules`, la funzione in `RULES_FEATURES` di `promote.yml` e la pubblicazione delle regole prima della build (`docs/release-checklist.md`).

### Test attuali vicini all'intent (numero di `test`/`testWidgets`)

| File | Test |
|---|---|
| `packages/estimation/test/window_test.dart` | 28 |
| `packages/estimation/test/recognizer_test.dart` | 25 |
| `packages/estimation/test/models_test.dart` | 19 |
| `packages/estimation/test/catalog_functions_test.dart` | 13 |
| `packages/estimation/test/pairings_test.dart` | 12 |
| `packages/estimation/test/status_test.dart` | 11 |
| `packages/estimation/test/tables_test.dart` | 11 (più i test generati per ogni riga) |
| `packages/estimation/test/api_test.dart` | 10 |
| `test/label/core/label_lookup_flow_test.dart` | 12 |
| `test/label/core/label_merge_test.dart` | 9 |
| `test/label/core/label_line_picker_test.dart` | 10 |
| `test/label/core/vintage_parser_test.dart` | 9 |
| `test/label/label_session_controller_test.dart` | 23 |
| `test/label/ui/label_screens_test.dart` | 31 |
| `test/label/ui/not_found_view_test.dart` | 5 |
| `test/label/ui/online_search_screen_test.dart` | 10 |
| `test/catalog/catalog_coordinator_test.dart` | 37 |
| `test/catalog/online_search_test.dart` | 9 |
| `test/catalog/offline/` (4 file) | 34 |
| `test/catalog/wine_db_loader_test.dart` | 11 |
| `test/rules/u4.rules.test.mjs` | 45 |
| `integration_test/label_test.dart` | 5 scenari |

Altri test interessati (solo nomi): `test/cellar/domain/window_adjuster_test.dart`, `test/cellar/domain/wine_validator_test.dart`, `test/cellar/domain/wine_origins_test.dart`, `test/cellar/estimate_refresher_test.dart`, `test/cellar/adjustment_flow_test.dart`, `test/cellar/wine_test.dart`, `test/cellar/ui/add_wine_screen_test.dart`, `test/cellar/ui/add_wine_initial_values_test.dart`, `test/cellar/ui/edit_wine_screen_test.dart`, `test/cellar/ui/wine_detail_screen_test.dart`, `test/rules/compat/compat.rules.test.mjs`.

### Altri segnali di debito (intent 261108-label-autofill-windows)

- La denominazione è uno stato nascosto del form: una proposta scelta e poi un nome cambiato a mano lasciano la denominazione della proposta, che guida la stima (`resolveWine` dà precedenza alla denominazione dell'utente).
- `CatalogWineType` a 5 valori: `red` diventa sempre `redStructured`, `sweet` e `fortified` coincidono; con un tipo `redStructured` una denominazione leggera riconosciuta nel nome (per esempio un Dolcetto) viene scartata da `_hasType` e vale la riga del tipo.
- `WineFacts.region` e il paese non entrano nella stima, anche se sono già nel documento del vino.
- La base offline è un campione di 45 vini: la compilazione dal testo resterà spesso senza candidati finché la base non cresce.
