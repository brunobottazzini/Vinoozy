# Struttura del codice — Vinoozy

## Radice del repository

| Percorso | Contenuto |
|---|---|
| `lib/` | App Flutter |
| `packages/estimation/` | Pacchetto Dart puro di stima (C2), anche fonte delle denominazioni (`lib/src/catalog.dart`) |
| `test/` | Unit test e test dei widget, per modulo (`u1/`, `cellar/`, `catalog/`, `label/`, `sharing/`, `account/`, `dashboard/`, `app/`, `helpers/`), più `web/` (node:test) e `rules/` (regole Firestore) |
| `integration_test/` | e2e su emulatore Android con Firebase Emulator Suite; `support/` con `fake_image_source.dart` ed `ean13_painter.dart` per l'etichetta |
| `test_driver/` | Driver per e2e con chiusura forzata e misure di prestazione |
| `docs/account-deletion/` | Pagina web di cancellazione account (it, en, pt-BR) |
| `docs/` | Anche `release-checklist.md` (misure e privacy), `firebase-setup.md` (§9: `OFF_CONTACT`) |
| `tool/` | Script di controllo CI (`check_*.sh` con i loro test), generatori, fixture, `app_size_baseline.txt` |
| `android/` | Progetto Gradle Android; codice Kotlin dell'app in `app/src/main/kotlin/com/vinoozy/vinoozy/`, test Robolectric in `app/src/test/kotlin/` |
| `assets/icon/` | Icona dell'app (`vinoozy_icon_1024.png`, `play_store_512.png`); non dichiarata come asset in `pubspec.yaml`, che non ha una sezione `flutter: assets:` |
| `.github/workflows/` | CI/CD |
| `firestore.rules`, `firestore.indexes.json`, `firebase.json` | Configurazione Firebase |

## Moduli di `lib/`

| Modulo | Ruolo | Struttura |
|---|---|---|
| `app/` | Avvio, cablaggio (`bootstrap.dart`), provider condivisi (`providers.dart`), tema (`theme.dart`), lingue (`locale_resolution.dart`), shell, errori, `ui/country_flag.dart` | — |
| `account/` | Accesso, gate dell'account, profilo, cancellazione, `NetworkStatus` | `data/`, `deletion/`, `ui/` |
| `cellar/` | Cantina, bevute, Storico | `domain/` (anche `wine_origins.dart`), `data/`, `ui/` (anche `origin_pickers.dart`, `wine_badges.dart`), `cellar_actions.dart`, `cellar_providers.dart`, `wine_estimator.dart` |
| `catalog/` | Catalogo vini (C1) e Open Food Facts | `core/` (Dart puro, `off/` per l'adattatore OFF), `platform/` |
| `dashboard/` | Cruscotto in sola lettura | `domain/`, `ui/` |
| `label/` | Foto dell'etichetta, ML Kit | `core/` (Dart puro), `platform/`, `ui/`, `label_providers.dart` |
| `sharing/` | Condivisione della cantina | `domain/`, `data/`, `ui/` |
| `sync/` | Stato della sincronizzazione, `SyncWatcher`, ledger locale, bus degli errori | `ledger/`, `ui/` |
| `firebase/` | Ambiente (`demo`/`prod`), opzioni, avvio di Firestore | — |
| `core/` | `Clock`, `IdGenerator` | — |
| `e2e/` | Sostituti solo per build e2e (`TestNetworkControl`, accesso emulatore) | — |
| `l10n/` | ARB e localizzazioni generate (versionate) | — |

## Schemi ricorrenti

- **Repository + batch non attesi**: `WineRepository._commit` e `DrinkingRecordRepository._commit` registrano nel ledger, costruiscono un `WriteBatch`, avviano `commit()` senza attenderlo e gestiscono l'errore in un `then` non atteso.
- **Iniezione per override**: i provider di repository lanciano se non sovrascritti (`_injected(...)`); le istanze reali nascono in `AppBootstrap._wire`. I provider di etichetta e catalogo hanno invece valori predefiniti reali (ML Kit, image_picker, file system, http) che i test sovrascrivono.
- **Motivi d'errore fissi** e valori sensibili esclusi dai report (`CellarErrorReasons`, `ErrorReporter`, `LabelFailure`, `OffFailureKind`, codici di rifiuto nativi); `toString()` dei tipi con dati personali non mostra mai il valore (`ReadBarcode`, `PickedImage`, `WineCandidate`).
- **Esiti tipati invece di eccezioni**: `sealed class` per `PickOutcome`, `PrepareResult`, `LookupOutcome`, `LabelState`, `OffOutcome`; l'unica eccezione del catalogo è `CatalogArgumentError`.
- **Commenti legati ai requisiti** (BRx, NFRx, sezioni di design) in quasi ogni classe.
- **Chiavi di test stabili** (`Key('add-wine-…')`, `Key('label-…')`, `Key('add-choice-…')`) su ogni elemento interattivo.
- **Testi solo da ARB**: ogni etichetta passa da `AppLocalizations`.
- **Colori solo dal tema**: `Theme.of(context).colorScheme` e `StatusColors.of(context)`.
- **Orologio e timer iniettati** (`Clock`, `CatalogTimerFactory`): nessun test attende tempo reale.

## File del percorso del bug NFR6.6

| File | Classificazione |
|---|---|
| `lib/cellar/data/drinking_record_repository.dart` | servizio dati |
| `lib/cellar/data/pending_writes_probe.dart` | servizio dati (stato di sincronizzazione) |
| `lib/sync/sync_status.dart` | dominio (calcolo dello stato) |
| `lib/app/providers.dart` | provider |
| `lib/app/bootstrap.dart` | configurazione/cablaggio |
| `lib/sync/ui/offline_banner.dart` | UI |

Dettaglio in [code-quality-assessment.md](code-quality-assessment.md#difetto-nfr66-fascia-in-attesa-dopo-una-bevuta-offline). Questi file sono cambiati dopo la scansione (correzione non committata); il dettaglio riga per riga descrive il codice di allora.

## File della superficie UX (intent 261107-ux-redesign)

Righe e ruoli alla scansione ux-redesign, salvo le righe segnate "riverificato".

| File | Righe | Classificazione | Ruolo |
|---|---|---|---|
| `lib/cellar/ui/add_wine_screen.dart` | 683 (riverificato) | UI (form) | Form "Aggiungi vino"; contiene anche `AddWineInitialValues`, `guessOrigin`, `WineTypeField`, `wineFamilyOf`, `_SuggestionList`, `_ProducerList`; usa `CountryPicker` e `RegionPicker` |
| `lib/cellar/ui/edit_wine_screen.dart` | 212 (ora 250) | UI (form) | Form "Modifica"; riusa `WineTypeField` e `QuantityStepper` |
| `lib/cellar/ui/quantity_stepper.dart` | 61 | UI (widget) | "−" / "+" 1-99 (0-99 in modifica) |
| `lib/cellar/ui/wine_labels.dart` | 129 | Utility UI | Testi tradotti di stati, tipologie, abbinamenti; `StatusLabel` |
| `lib/cellar/ui/drink_flow.dart` | 87 | UI (flusso) | `drinkWithUndo` |
| `lib/cellar/ui/drink_snack_bar.dart` | 103 | UI (widget) | Messaggio con "Annulla" e "Aggiungi voto e note" |
| `lib/cellar/ui/wine_list_tile.dart` | 78 | UI (widget) | Riga della cantina |
| `lib/cellar/ui/wine_detail_screen.dart` | 405 | UI (schermata) | Dettaglio |
| `lib/cellar/ui/cellar_screen.dart` | 541 | UI (schermata) | Lista, ricerca, filtri |
| `lib/cellar/ui/cellar_dialogs.dart` | 162 | UI (dialoghi) | `DuplicateDialog`, `DeleteWineDialog`, `MergeDialog` |
| `lib/cellar/ui/drinking_record_sheet.dart` | 252 | UI (foglio) | Voto, note, data, "Com'era?" |
| `lib/cellar/domain/wine_draft.dart` | 162 | Dominio | `WineRules`, `WineDraft`, `withDetails` (con `country`) |
| `lib/cellar/domain/wine_validator.dart` | 162 (riverificato) | Dominio | `WineInput`, `WineValidator`, `WineValidation` (con `regionError`, `countryError`) |
| `lib/cellar/domain/wine.dart` | 270 | Modello | `Wine`, `WineFields` (con `country`) |
| `lib/cellar/domain/wine_origins.dart` | 1260 (riverificato, nuovo) | Dominio puro + dati | `OriginCountry` (249 paesi ISO con nomi it/en/pt), `WineRegion`, `OriginGuess`, `OriginSelection`, `WineOrigins` (21 paesi della griglia, 16 "rari", regioni, denominazioni estere, `guess`) |
| `lib/app/theme.dart` | 182 | Configurazione UI | `AppColors`, `StatusColors`, `buildAppTheme` |
| `lib/app/locale_resolution.dart` | 27 | Configurazione | `appLocales` (en, it, pt-BR), `resolveAppLocale` |
| `lib/dashboard/ui/status_icons.dart` | 31 | Utility UI | Icona, testo e colore di ogni stato |
| `lib/l10n/app_{en,it,pt_BR}.arb` | — | Risorse | Testi; `app_pt.arb` contiene solo `@@locale` |

## File della superficie etichetta e catalogo (intent 261107-label-recognition)

Righe e ruoli alla scansione label-recognition; i file aggiunti o cambiati dopo sono nella sezione dell'intent 261108-label-autofill-windows più sotto.

### `lib/label/` (24 file)

| File | Righe | Classificazione | Ruolo |
|---|---|---|---|
| `core/label_reading.dart` | 73 | Modello + porta | `LabelBarcodeFormat`, `ReadBarcode`, `LabelReading` (`maxTextLength = 2000`, `clampText`), interfaccia `LabelReader`, `hasLetters` |
| `core/barcode_filter.dart` | 48 | Dominio | Primo EAN-13/EAN-8/UPC-A con cifra di controllo GS1 valida |
| `core/vintage_parser.dart` | 84 | Dominio | Annata dal testo: anno isolato 1900-oggi, esclude anni di fondazione, vicinanza a parole d'annata o DOC/DOCG/IGT |
| `core/label_line_picker.dart` | 70 | Dominio | Riga più significativa (denominazione o riga più lunga senza volume, gradi, solfiti), ≤ 120 |
| `core/label_lookup_flow.dart` | 139 | Servizio puro | `LookupOutcome` (`LookupProposal`, `LookupIncomplete`, `LookupBarcodeOnly`, `LookupUnreadable`), `LabelLookupFlow.run`, `retryBarcode` |
| `core/label_session.dart` | 155 | Macchina a stati pura | `PhotoOrigin`, `LabelState` (9 stati), `LabelSession` con id di lettura |
| `core/shared_image_policy.dart` | 66 | Dominio | `ShareAccount`, `ShareDecision`, `SharedImagePolicy` (60 s, 5 s) |
| `platform/mlkit_label_reader.dart` | 76 | Adattatore | ML Kit testo latino + codici a barre in parallelo, `orderedText` |
| `platform/picker_image_source.dart` | 103 | Adattatore | `PickOutcome`, interfaccia `ImageSource`, `PickerImageSource` (image_picker), `discardLostData` |
| `platform/shared_image_channel.dart` | 108 | Adattatore | `PrepareResult`, `SharedImageNotice`, canale `com.vinoozy.app/label` |
| `platform/temp_label_store.dart` | 155 | Adattatore | `LabelFileSystem`, `IoLabelFileSystem`, `TempLabelStore` (cartella `label`, 10 min) |
| `platform/label_error_reporter.dart` | 50 | Adattatore | `LabelFailure` (4 motivi), `LabelReportedError`, `LabelErrorReporter` |
| `label_providers.dart` | 562 | Provider + controllori | Provider degli adattatori, `LabelInput`, `LabelSessionController`, `LabelFlow`, `SharedImageNotifier`, `scheduleLabelCleanup` |
| `ui/add_choice_screen.dart` | 95 | UI | Tre pulsanti grandi |
| `ui/label_capture_flow.dart` | 134 | UI (flusso) | `LabelTarget`, `LabelRetry`, `LabelCaptureFlow.run/openForm`, `LabelFormTracker` |
| `ui/label_reading_screen.dart` | 349 | UI (schermata) | Lettura, esiti, "Conferma", "Correggi", "Riprova" |
| `ui/label_proposal_sheet.dart` | 199 | UI | "Ho riconosciuto:" con paese, regione, tipo |
| `ui/label_unreadable_view.dart` | 42 | UI | Illeggibile |
| `ui/barcode_only_view.dart` | 59 | UI | Solo codice a barre |
| `ui/permission_denied_view.dart` | 69 | UI | Accesso negato, fotocamera assente |
| `ui/label_message_layout.dart` | 63 | UI | Layout comune, `labelActionStyle` |
| `ui/replace_label_dialog.dart` | 38 | UI | "Hai un vino non salvato…" |

### `lib/catalog/` (13 file)

| File | Righe | Classificazione | Ruolo |
|---|---|---|---|
| `core/wine_catalog.dart` | 394 | Contratto C1 | `CatalogWineType`, `CandidateSource`, `CatalogLocale`, `WineCandidate` (JSON a chiavi corte), `CellarWineRef`, `SuggestResult`, `LabelMatch`, `WineProfileResult`, `CatalogArgumentError`, interfaccia `WineCatalog` |
| `core/catalog_coordinator.dart` | 284 | Servizio puro | `CatalogCoordinator` (ordine delle fonti, cache, interruttore, budget, sessione), `labelSearchWords` |
| `core/internal_catalog.dart` | 241 | Servizio puro | Denominazioni + vini della cantina, prefisso di parola, `mergeCandidates`, `catalogTypeOf`, `ParsedQuery` |
| `core/off/open_food_facts_source.dart` | 284 | Adattatore HTTP puro | `OffOutcome`, `normalizeBarcode`, `OpenFoodFactsSource` (URI, fetch, parsing, `mapProduct`) |
| `core/catalog_cache_store.dart` | 383 | Servizio puro | `CacheFile`, `ProfileHint`, `CatalogCacheStore` |
| `core/request_budget.dart` | 40 | Dominio | `RequestBudget` |
| `core/off_circuit_breaker.dart` | 88 | Dominio | `CatalogHealth`, `OffCircuitBreaker` |
| `core/catalog_config.dart` | 48 | Configurazione | `CatalogConfig` (host, licenza ODbL, `OFF_CONTACT`, User-Agent) |
| `core/catalog_event_logger.dart` | 125 | Porta + console | `OffFailureKind`, `OffFailure`, `CatalogHealthSnapshot`, `CatalogDebugEvent`, `ConsoleCatalogEventLogger` |
| `platform/catalog_providers.dart` | 135 | Provider | Composizione reale, sessione per uid |
| `platform/file_cache_file.dart` | 64 | Adattatore | `catalog_cache.json` |
| `platform/crashlytics_catalog_event_logger.dart` | 63 | Adattatore | `off_suspended` in Crashlytics |

### Codice nativo (`android/app/src/main/kotlin/com/vinoozy/vinoozy/`)

| File | Righe | Ruolo |
|---|---|---|
| `MainActivity.kt` | 107 | Unica activity; canale `com.vinoozy.app/label`, esecutore a thread singolo, `openAppSettings` |
| `LabelImagePreparer.kt` | 226 | Verifica e preparazione delle immagini (`PrepareResult`, `RejectCode`, `LabelBitmapDecoder`) |
| `SharedImageReceiver.kt` | 151 | "Condividi → Vinoozy" (`PendingShare`), copia limitata a 20 MB |

## File della stima e dei campi del vino (intent 261108-label-autofill-windows)

Working tree attuale, verificato in questa scansione.

### `packages/estimation/`

| File | Righe | Classificazione | Ruolo |
|---|---|---|---|
| `lib/estimation.dart` | 34 | API pubblica (C2) | Esporta solo funzioni, tipi di valore, errori e funzioni di catalogo; tabelle, riconoscitore e validazione restano interni |
| `lib/src/models.dart` | 327 | Modello | `WineType` (8 valori, `tryParse` accetta anche `red`/`white`/`rose`/`sparkling`/`sweet` di C1), `Qualifier` (`riserva`, `superiore`, `granSelezione`), `Confidence`, `WindowSource` (`catalog`, `internalRules`), `EstimationBasis` (`catalog`, `denomination`, `wineType`, `generic`), `WineStatus`, `PairingCategory` (25), `WineFacts`, `ExternalProfile`, `DrinkingWindow`, `Pairings` |
| `lib/src/tables.dart` | 696 | Dati `const` | `YearOffsets(start, peak, end)`, `DenominationProfile`, `TypeProfile`; `denominationTable` (47 denominazioni italiane, alias normalizzati, scostamenti e scostamenti per qualificatore), `typeTable` (8 tipi), `genericTypeProfile` (1, 3, 6) |
| `lib/src/recognizer.dart` | 330 | Dominio | `tokenize` (primi 60 caratteri), `tokenizeAll`, indice degli alias per prima parola, `findAlias` (alias più lungo a parole intere), `recognize`, `resolveWine` (precedenze BR1.2), maschera dei qualificatori |
| `lib/src/window.dart` | 65 | Servizio puro | `estimateWindow` (finestra del catalogo se usabile, altrimenti tabelle; anno base = annata, o anno di riferimento per spumanti e generica, o l'anno prima per gli altri), `needsRefinement` |
| `lib/src/status.dart` | 32 | Servizio puro | `statusOf`: in attesa, pronto, da bere presto (ultimo 25% della finestra, tra 3 e 12 mesi), oltre la finestra |
| `lib/src/pairings.dart` | 35 | Servizio puro | `pairingsFor` (catalogo, altrimenti categorie della riga) |
| `lib/src/catalog.dart` | 238 | Dati + servizio | `denominationLabels` (nome mostrato e regione italiana per ogni riga), `DenominationInfo`, `RecognizedDenomination`, `normalizeWineText`, `recognizeDenomination`, `denominationCatalog` |
| `lib/src/validation.dart` | 70 | Dominio | Anni 1900-2200, nome non vuoto, annata o anno di riferimento obbligatorio, finestra ordinata |
| `lib/src/errors.dart` | 21 | Errori | `EstimationArgumentError`, `EstimationErrorCode` |
| `test/` | 9 file | Test | Circa 130 test; `tables_test.dart` genera i test per ogni riga delle tabelle |

### `lib/cellar/` (parte della stima e dei campi)

| File | Righe | Classificazione | Ruolo |
|---|---|---|---|
| `domain/wine.dart` | 270 | Modello | `WineFields` (16 campi), `WindowFields`, `PairingsFields`, `Wine.fromMap`, `windowFrom`/`windowToMap`, `pairingsFrom`/`pairingsToMap`, `displayCountry` |
| `domain/wine_draft.dart` | 162 | Dominio | `WineRules` (nome 1-120, annata 1900-anno corrente), `WineDraft.validate`, `withDetails` |
| `domain/wine_validator.dart` | 162 | Dominio | `WineInput`, `WineValidation`, `WineValidator` (produttore ≤ 120, regione ≤ 120 e canonica, paese ISO; tipo e denominazione non validati) |
| `domain/wine_origins.dart` | 1260 | Dominio puro + dati | Paesi, regioni, 47 denominazioni estere (solo origine), `guess` |
| `domain/window_adjuster.dart` | 193 | Dominio puro | `WindowAdjustment`, `EstimateLabel`, `WindowAdjuster.effective`/`pick`/`labelOf` |
| `domain/wine_estimate.dart` | 59 | Modello | `WineEstimate{baseWindow, window, adjustment, pairings}`, `toFields` |
| `wine_estimator.dart` | 154 | Servizio | `WineFactsInput` (senza paese), `WineEstimator.estimate`/`refine`/`displayed`/`withAdjustment` |
| `estimate_refresher.dart` | 148 | Servizio | `EstimateRefresher` (al ritorno della rete, ≤ 20 vini, solo con `canEdit`) |
| `cellar_actions.dart` | 446 | Servizio | `saveNewWine`, `saveEdit`, `recomputeAdjustment`, `ensureEstimates` (e bevute, eliminazione, unione) |
| `data/wine_repository.dart` | 834 | Repository | `addWine`, `updateWine`, `setEstimate`, `_updateWine`, `_commit` (batch non atteso dopo il ledger) |
| `ui/add_wine_screen.dart` | 705 | UI (form) | `AddWineInitialValues` (con `fromCandidate`), `guessOrigin` (usa anche `WineCandidate.country`), form; la denominazione è uno stato nascosto (`_denomination`), non un campo |
| `ui/edit_wine_screen.dart` | 250 | UI (form) | Nome, produttore, paese, regione, annata, tipo, quantità; denominazione copiata dal vino |
| `ui/ideal_moment_card.dart` | 271 | UI | "Momento ideale": `uxIdealUntil` = "Consigliato fino al {year}" con `window.endYear`, `WindowBar`, stato, inizio/picco/fine, fiducia, fonte |
| `ui/window_card.dart` | 50 | UI | Solo `PairingsCard` (la finestra è in `IdealMomentCard`) |

### File aggiunti o cambiati in `lib/label/`, `lib/catalog/` e Android dopo la scansione label-recognition

| File | Stato | Ruolo |
|---|---|---|
| `lib/label/core/label_merge.dart` | nuovo (116) | `BarcodeSide`, `BackStatus`, `MergedReading` (≤ 2000 per foto, ≤ 4000 in tutto), `mergeLabelReadings` |
| `lib/label/core/label_lookup_flow.dart` | cambiato (179) | `NotFoundKind`, `LookupNotFound{kind, name, vintage, query}`, `LookupSure`, `LookupCandidates`, `LabelLookupFlow.run(MergedReading)`, `searchQueryOf` |
| `lib/label/core/label_session.dart` | cambiato (253) | `ReadingStep`, `StepStatus`, `ReadingProgress`, stati `LabelBackPromptState`, `LabelCandidatesState`, `LabelNotFoundState` |
| `lib/label/core/lens_launcher.dart` | nuovo (15) | Porta `LensLauncher.open(path) → LensRoute` |
| `lib/label/platform/lens_channel.dart` | nuovo (79) | Canale `vinoozy/lens` |
| `lib/label/ui/back_photo_prompt.dart` | nuovo (55) | "Ora il retro": Scatta, Galleria, Salta |
| `lib/label/ui/candidate_list.dart` | nuovo (227) | `CandidateList`, `CandidateCard`, `OffAttributionText` |
| `lib/label/ui/not_found_view.dart` | nuovo (149) | "Non trovato" per i tre casi; sostituisce `label_unreadable_view.dart` e `barcode_only_view.dart` (cancellati) |
| `lib/label/ui/online_search_screen.dart` | nuovo (262) | "Cerca online" con campo, lista e avvisi di stato |
| `lib/label/ui/lens_confirm_sheet.dart` | nuovo (79) | Conferma prima di passare la foto a Google |
| `lib/label/ui/reading_progress.dart` | nuovo (122) | Avanzamento dei passi di lettura |
| `lib/label/label_providers.dart` | cambiato (756) | `LabelSessionController` con fronte, retro, `notThis`, `noneOfThese`, `openLens` |
| `lib/catalog/core/wine_catalog.dart` | cambiato (510) | `CandidateSource.offline`, `WineCandidate.country`, `matchLabel`, `LabelMatchResult`, `searchOnline`, `OnlineSearchResult` |
| `lib/catalog/core/catalog_coordinator.dart` | cambiato (586) | Ordine di ricerca con la base offline, punteggi, deduplicazione |
| `lib/catalog/core/offline/` | nuovo | `wine_db_record.dart`, `wine_db_index.dart`, `text_score.dart` (soglie 0,85 / 0,15 / 0,45 / 0,70) |
| `lib/catalog/core/network_status.dart`, `lib/catalog/platform/connectivity_network_status.dart` | nuovi | Stato della rete visto dal catalogo |
| `lib/catalog/platform/wine_db_loader.dart` | nuovo (163) | Apertura di `assets/wine_db/wines.jsonl.gz` in un isolate |
| `android/app/src/main/kotlin/com/vinoozy/vinoozy/LensIntentLauncher.kt` | nuovo (100) | `ACTION_SEND` verso `com.google.android.googlequicksearchbox` o menu Condividi, tramite `FileProvider` |
| `assets/wine_db/` | nuovo | `wines.jsonl.gz`, `manifest.json` (45 vini, `source: sample`), `LICENSE`, `README.md` |
| `tool/build_wine_db.dart`, `tool/check_wine_db_release.sh`, `tool/check_lens_manifest.sh` | nuovi | Costruzione e controlli della base e del manifest (non letti) |

Nota storica: le due tabelle precedenti riportano righe e contenuti di allora (per esempio `tables.dart` con 47 righe soltanto, `models.dart` con 3 qualificativi, base offline di 45 vini). Lo stato attuale è nella sezione seguente.

## File di tipo, livello, stile e finestra (intent 261108-wine-style-profiles)

Commit `baba947` più il working tree, verificato in questa scansione.

### `packages/estimation/lib/src/`

| File | Righe | Classificazione | Ruolo per tipo, livello e finestra |
|---|---|---|---|
| `models.dart` | 396 | Modello | `WineType` (8) con `tryParse` e `_catalogWineTypes`, `Qualifier` (14), `EstimationBasis` (con `grape`), `WineFacts` (con `level`), `DrinkingWindow` (con `denominationKey`, `tablesVersion`) |
| `wine_level.dart` | 56 | Modello + regola | `WineLevel` con le percentuali e `apply` |
| `tables.dart` | 843 | Dati `const` | `estimationTablesVersion = 2`, `YearOffsets`, `DenominationProfile` (tipo principale, `otherTypes`, `qualifierOffsets`, `weakAliases`, `templateKey`), `italianDenominationTable` (47), `typeTable` (8), `genericTypeProfile` (1/3/6), `denominationTable` (tabella unita) |
| `italy_tables.dart` | 854 | Dati `const` | 149 righe italiane scritte a mano oltre alle 47 |
| `france_tables.dart` | 849 | Dati `const` | 209 righe francesi |
| `europe_tables.dart` | 832 | Dati `const` | 173 righe di Spagna, Portogallo, Germania, Austria, Svizzera e altri paesi europei, con i qualificativi di Rioja, Ribera, Mosel, Nahe, Pfalz |
| `new_world_tables.dart` | 778 | Dati `const` | 146 righe del Nuovo Mondo |
| `world_tables.dart` | 144 | Dati `const` | `worldDenominations`, `TemplateKeys`, `appellationTemplates` (9 modelli), `defaultGeneratedTypes` (`redLight`, `white`, `rose`) |
| `generated/appellations.g.dart` | 1714 | Dati generati | 1700 righe in testo `key\|name\|country\|region\|model\|types\|aliases\|weak` |
| `generated/appellations_manifest.json` | 11 | Metadati | 724 dedicate, 1700 generate, 2424 in tutto, 756 escluse, 1 senza tipo |
| `appellations.dart` | 206 | Servizio | `parseGeneratedRow`, `buildDenominationTable` (italiane, poi mondo, poi generate senza conflitti di chiave o forma), `AppellationInfo`, `appellations`, `findAppellation`, `grapeForms` |
| `grapes.dart` | 109 | Dati `const` | `GrapeProfile(name, wineType, offsets, aliases)`, `grapeTable` (46 vitigni, un tipo ciascuno) |
| `recognizer.dart` | 557 | Dominio | Normalizzazione, indici degli alias e dei vitigni, `resolveWine`, `ResolvedWine` (offsets, `effectiveType`, `isDedicatedDenomination`), `qualifierFor` |
| `qualifiers.dart` | 118 | Dati + dominio | `qualifierPhrases`, `qualifierPriority`, `agingQualifiers`, `qualifierMaskOf` |
| `window.dart` | 80 | Servizio puro | `estimateWindow`, `needsRefinement`, `_baseYear` |
| `effective_window.dart` | 45 | Servizio puro | `effectiveWindow`, `overrideYearRange`, `isValidOverrideYear` |
| `status.dart` | 32 | Servizio puro | `statusOf` (invariato) |
| `label_fields.dart` | 690 | Servizio puro | `LabelFields`, `extractLabelFields`, `_Reader` (`_type`, `_qualifier`, `suggestedLevel`), `agingQualifierIn` |
| `label_candidates.dart` | 2220 | Servizio puro (part) | Candidati del controllo guidato; `_Evidence.typeFor` (stessa regola del tipo con la riga) |
| `label_lines.dart`, `label_words.dart`, `label_scoring.dart`, `label_line_picker.dart` | 620, 230, 91, 100 | Servizio puro | Righe, parole e pesi dell'analisi dell'etichetta; parole di tipo e di stile |
| `catalog.dart` | 238 | Dati + servizio | `denominationLabels` delle 47 italiane, `recognizeDenomination` (solo queste) |

### App (`lib/`)

| File | Righe | Ruolo per tipo, livello e finestra |
|---|---|---|
| `cellar/domain/wine.dart` | 305 | `WineFields` (18 campi, con `level` e `windowOverride`), `WindowFields` (con `denominationKey`, `tablesVersion`), `Wine.fromMap`, `windowFrom`/`windowToMap` |
| `cellar/domain/wine_draft.dart` | 172 | `WineDraft.withDetails(wineType, ..., level)`: testi vuoti → `null` |
| `cellar/domain/wine_validator.dart` | 184 | `WineInput{..., wineType, level}`; tipo non validato |
| `cellar/domain/window_adjuster.dart` | 217 | `WindowAdjustment`, `WindowAdjuster.effectiveOf(base, adjustment, override)` |
| `cellar/domain/window_override.dart` | 46 | `OverrideFields`, `WindowOverride{endYear, setAt}` |
| `cellar/wine_estimator.dart` | 178 | `WineFactsInput` (con `level`, `wineType` grezzo), `WineEstimator.estimate`/`refine`/`displayed`/`withAdjustment` |
| `cellar/estimates_migration.dart` | 219 | `EstimatesMigration`, `MigrationAttemptStore` (memoria o preferenze `estimates.migration.v<n>`), `needsMigration` |
| `cellar/estimate_refresher.dart` | 151 | `EstimateRefresher` (catalogo, ≤ 20 vini per ritorno in rete) |
| `cellar/cellar_actions.dart` | 534 | Salvataggi, ricalcolo dopo bevuta, `ensureEstimates` che chiama anche la migrazione |
| `cellar/data/wine_repository.dart` | 910 | `addWine`, `updateWine`, `setEstimate`, `setOverride`, `clearOverride` |
| `cellar/ui/add_wine_screen.dart` | 1571 | `wineFamilyOf`, `AddWineInitialValues`, `WineTypeField` (8 tipi con icona e colore della famiglia), preselezione dal testo e dal candidato, `LevelSection` |
| `cellar/ui/edit_wine_screen.dart` | 302 | `WineTypeField`, `LevelSection` con il livello salvato |
| `cellar/ui/level_section.dart` | 142 | `LevelChoice` (scelto, toccato, suggerimento), `LevelSection` (anteprima con e senza livello) |
| `cellar/ui/wine_level_selector.dart` | 310 | `WineLevelSelector` (3 livelli più "Nessuno", suggerito con bordo tratteggiato), `LevelPreview` |
| `cellar/ui/ideal_moment_card.dart` | 351 | "Momento ideale": livello, origine della stima, correzione |
| `cellar/ui/window_override_widgets.dart` | 251 | `CorrectedBadge`, foglio degli anni di "Consigliato fino al", `EstimateSourceLine` |
| `cellar/ui/wine_labels.dart` | 183 | `wineTypeLabel`, `levelLabel`, `qualifierDisplayName`, `estimateOriginText` |
| `cellar/ui/wine_badges.dart` | 169 | `WineTypeFamily` (5 famiglie), colori e icone, `WineTypeBadge` |
| `cellar/ui/wine_card.dart`, `cellar_screen.dart`, `wine_detail_screen.dart` | 220, 575, 615 | Badge della famiglia, stato del giorno, dettaglio |
| `cellar/domain/cellar_filter.dart` | 148 | `TypeFilter.of` (5 famiglie più "non specificato") |
| `dashboard/domain/dashboard_calculator.dart` | 332 | `DashboardCalculator.familyOf`, stato, picchi, "da bere presto" |
| `catalog/core/offline/wine_db_record.dart` | 244 | `WineDbRecord`, `toCandidate` (riduce il tipo a 5 famiglie) |
| `catalog/core/offline/wine_db_index.dart`, `text_score.dart` | 155, 168 | Indice e punteggio della base offline |
| `catalog/platform/wine_db_loader.dart` | 163 | Caricamento in un isolate |
| `label/core/text_autofill.dart`, `label_merge.dart` | 141, 116 | Testo incollato o letto → analisi; nessuna logica di tipo o livello propria |

### Strumenti e dati

| File | Ruolo |
|---|---|
| `tool/build_appellations.dart` (862 righe) | Genera `appellations.g.dart` e il manifest dai registri (eAmbrosia, CSV di `tool/data/appellations/`); modello per paese e protezione (`templateOf`); tipi dal CSV (codici `rL`, `rS`, `B`, `Ro`, `SpC`, `SpT`, `D`, `F`), altrimenti da `typesFromName`, altrimenti `redLight,white,rose`; tiene solo i tipi del modello |
| `tool/data/appellations/` | `us_ava.csv`, `au_nz_gi.csv`, `za_wo.csv`, `south_america.csv`, `ch_aoc.csv`, `README.md` |
| `tool/build_wine_db.dart` | Costruisce `assets/wine_db/` dall'export CSV di Open Food Facts: `wineTypeOfTags`, `denominationOf`, `countryOfTags`, `vintageOf` |
| `assets/wine_db/` | `wines.jsonl.gz` (15.616 vini, 339.982 byte), `manifest.json` (export 2026-11-07, `source: Open Food Facts`, ODbL), `README.md`, `LICENSE` |

