# Inventario dei componenti — Vinoozy

Ultima scansione: intent 261108-label-autofill-windows (stima della finestra, campi del vino, form, regole dei vini, flusso dal testo dell'etichetta al form). I componenti riletti in questa scansione sono descritti in base al codice attuale e segnati "(riverificato 261108)"; i nuovi sono nella sezione "Componenti della stima e dei campi del vino" e in quella dell'etichetta attuale, in fondo. I componenti dell'etichetta e del catalogo descritti alla scansione 261107-label-recognition e non riletti ora restano come allora; dove il codice attuale li smentisce è indicato. I componenti del percorso del bug NFR6.6 (intent 261107-pending-banner-fix) e della superficie UX (intent 261107-ux-redesign) non riletti in questa scansione sono descritti come alla scansione precedente: i loro file sono cambiati da allora con le modifiche non committate di quegli intent. Gli altri moduli sono elencati a livello di cartella.

## Componenti del percorso dello stato di sincronizzazione

### DrinkingRecordRepository

- **File**: `lib/cellar/data/drinking_record_repository.dart`
- **Responsabilità**: scritture e letture delle bevute; `_commit` comune a `drink`, `undo`, `updateRecord`.
- **Dipende da**: `FirebaseFirestore`, `LocalLedger`, `SyncErrorBus`, `ErrorReporter`, `PendingWritesProbe`, `IdGenerator`, callback `onWriteStarted` (= `SyncWatcher.trigger`).
- **Usato da**: `CellarActions`, provider di lettura in `lib/cellar/cellar_providers.dart`.

### PendingWritesProbe

- **File**: `lib/cellar/data/pending_writes_probe.dart`
- **Responsabilità**: tenere "in attesa" la fonte `drinkingRecords` dopo ogni scrittura di bevuta; controllo all'avvio con grazia di 300 ms.
- **Usato da**: `DrinkingRecordRepository._commit` (`trackWrite`), `AppBootstrap._wire` (`checkAtStartup`).

### SyncStatusTracker

- **File**: `lib/sync/sync_status.dart`
- **Responsabilità**: calcolare `SyncState` dai metadati degli snapshot e dalle fonti segnate "in attesa", senza listener propri.

### SyncStatusNotifier

- **File**: `lib/app/providers.dart`
- **Responsabilità**: `syncStatusProvider(cellarId)`; ascolta cantina, vini e `drinkingRecordsPendingProvider`; avvia `SyncWatcher` al ritorno in rete.

### DrinkingRecordsPending

- **File**: `lib/app/providers.dart`
- **Responsabilità**: `drinkingRecordsPendingProvider`, booleano globale impostato dalla sonda.

### AppBootstrap

- **File**: `lib/app/bootstrap.dart`
- **Responsabilità**: crea le istanze reali e il `ProviderContainer`; cabla la sonda, il repository delle bevute e il controllo all'avvio. Per l'etichetta chiama `scheduleLabelCleanup` dopo il primo frame e collega `SharedImageNotifier` al gate dell'account (`attachGate`, `checkColdStart`).

### OfflineBanner

- **File**: `lib/sync/ui/offline_banner.dart`
- **Responsabilità**: mostrare "Sincronizzazione" o "Offline - in attesa" in base a `syncStatusProvider`.

### SyncWatcher

- **File**: `lib/sync/sync_watcher.dart` (analisi superficiale)
- **Responsabilità**: al ritorno in rete o dopo una scrittura, attendere la coda e verificare le voci del ledger.

## Componenti della superficie UX

### AddWineScreen

- **File**: `lib/cellar/ui/add_wine_screen.dart` (riverificato)
- **Responsabilità**: form "Aggiungi vino": nome con proposte dal 3° carattere, produttore con proposte, paese (`CountryPicker`), regione (`RegionPicker`), annata o "Senza annata", `WineTypeField`, `QuantityStepper`; "Salva" fisso in basso con controllo dei doppioni (`DuplicateDialog`).
- **Riempimento**: in `initState` da `prefill` ("Aggiungi di nuovo": paese mostrato con `displayCountry`) o da `initialValues` (etichetta: paese con `WineOrigins.effectiveCountry`); in `_pick` da una proposta: nome, produttore (se presente), annata (se presente), tipologia, paese e regione da `guessOrigin` (se c'è un paese sostituisce la selezione; se c'è solo la regione la imposta), denominazione. Tutto resta modificabile.
- **Elementi riusabili**: `_SuggestionList` (lista di candidati con produttore · annata · denominazione, "dalla cantina" e riga di attribuzione `offAttribution` se c'è un candidato OFF), `AddWineInitialValues`, `guessOrigin`, `wineFamilyOf`.
- **Dipende da**: `wineSuggestionsProvider` (catalogo interno subito, OFF dopo 600 ms), `cellarActionsProvider`, `clockProvider`, `idGeneratorProvider`, `WineValidator`, `WineOrigins`, `producerOptions`, `DuplicateDialog`, `origin_pickers.dart`, `wine_badges.dart`.
- **Aperto da**: `CellarScreen`, `LabelCaptureFlow.openForm` ("Scrivi", "Scrivi a mano", etichetta incompleta, "Correggi"), `WineDetailScreen` ("Aggiungi di nuovo").
- **(riverificato 261108)**: la denominazione non è un campo visibile: è lo stato `_denomination`, impostato da `prefill`, `initialValues` o da una proposta (`_pick`), e resta anche se poi il nome cambia. `guessOrigin` usa anche `WineCandidate.country` (base offline) quando i testi non nominano un paese. `openCandidateForm` apre il form con `returnToRootOnSave: true`. Nessun campo per livello o fine della finestra; nessuna azione "Incolla".

### WineTypeField

- **File**: `lib/cellar/ui/add_wine_screen.dart`
- **Responsabilità**: menu con "Non indicata" e gli 8 `WineType` di C2, dall'intent ux-redesign con l'icona colorata della famiglia. Chiave `add-wine-type`.

### EditWineScreen

- **File**: `lib/cellar/ui/edit_wine_screen.dart` (riverificato 261108, 250 righe)
- **Responsabilità**: modifica di nome, produttore, paese (`CountryPicker`), regione (`RegionPicker`), annata, tipologia e quantità (anche 0); un vino con regione italiana e senza paese si apre con l'Italia. La denominazione è copiata da `widget.wine.denomination` e non si può cambiare. Salva con `CellarActions.saveEdit`, che ricalcola la stima. Chiavi `edit-wine-screen`, `edit-wine-name`, `edit-wine-producer`, `edit-wine-vintage`, `edit-wine-no-vintage`, `edit-wine-error`, `edit-wine-save`.

### WineDraft

- **File**: `lib/cellar/domain/wine_draft.dart`
- **Responsabilità**: `WineRules` (nome 1-120, annata 1900-anno corrente) e bozza validata; `withDetails` aggiunge produttore, tipologia, regione, denominazione e paese (spazi tolti, vuoto → `null`).

### WineValidator

- **File**: `lib/cellar/domain/wine_validator.dart` (riverificato)
- **Responsabilità**: `WineInput` → `WineValidation`; un errore per campo: nome, produttore ≤ 120, annata, quantità, regione ≤ 120 code point (`RegionError.tooLong`), paese ISO (`CountryError.unknown`). La regione elencata si salva col nome canonico (`WineOrigins.canonicalRegion`); una regione italiana senza paese salva `IT`. Tipologia e denominazione non sono validate.
- **Usato da**: `AddWineScreen`, `EditWineScreen`, `LabelReadingScreen._confirm`.

### Wine

- **File**: `lib/cellar/domain/wine.dart`
- **Responsabilità**: vino letto da Firestore (`Wine.fromMap`, mai eccezioni); `WineFields` con i nomi dei campi, compreso `country`; `country` accettato solo se codice ISO; `displayCountry` = paese, oppure Italia per una regione italiana.

### WineOrigins

- **File**: `lib/cellar/domain/wine_origins.dart` (nuovo, intent ux-redesign, Dart puro)
- **Responsabilità**: dati e regole di paese e regione: 249 paesi ISO 3166-1 con nomi it/en/pt e bandiera emoji, 21 paesi della griglia e 16 "rari", regioni dei 21 paesi (tutte le 20 italiane), alias di paesi, circa 47 denominazioni estere (Francia, Spagna, Portogallo, Ungheria, Australia, Stati Uniti), confronto di testo senza accenti (`foldOriginText`) e `guess` (denominazione italiana → denominazione estera → testo `origins`).
- **Usato da**: `AddWineScreen`, `LabelProposalSheet`, `LabelReadingScreen._confirm` (via `guessOrigin`), `WineValidator`, `Wine`.

### InternalCatalog

- **File**: `lib/catalog/core/internal_catalog.dart`
- **Responsabilità**: proposte per prefisso di parola: prima i vini della cantina (≤ 500, senza regione né denominazione), poi le denominazioni di `denominationCatalog` di `estimation` (47 voci italiane alla prima scansione, ciascuna con regione e tipologia); più parole intere prima, poi ordine alfabetico; ≤ 10 senza doppioni (`mergeCandidates`: stesso nome, produttore, annata ⇒ resta la fonte migliore: cantina, interno, OFF). Costruito una volta per sessione.
- **Non contiene prodotti** (nessun produttore, codice a barre o etichetta reale): è l'unica fonte offline del catalogo.

### drinkWithUndo

- **File**: `lib/cellar/ui/drink_flow.dart` (descrizione della scansione ux-redesign)
- **Responsabilità**: "Bevuta" dalla riga o dal dettaglio, con messaggio e "Annulla".

### DrinkSnackBar

- **File**: `lib/cellar/ui/drink_snack_bar.dart` (descrizione della scansione ux-redesign)
- **Responsabilità**: messaggio "Bevuta segnata: nome" con "Annulla" e "Aggiungi voto e note".

### WineListTile

- **File**: `lib/cellar/ui/wine_list_tile.dart` (descrizione della scansione ux-redesign)
- **Responsabilità**: riga della cantina con stato, fiducia, quantità e azione "Bevuta".

### WineDetailScreen

- **File**: `lib/cellar/ui/wine_detail_screen.dart` (descrizione della scansione ux-redesign)
- **Responsabilità**: dettagli, finestra, abbinamenti, quantità, "Bevuta", comandi, ultime bevute.

### QuantityStepper

- **File**: `lib/cellar/ui/quantity_stepper.dart`
- **Responsabilità**: "−" valore "+" tra `min` e 99; usato da `AddWineScreen`, `EditWineScreen`, `LabelProposalSheet`.

### AppTheme

- **File**: `lib/app/theme.dart` (descrizione della scansione ux-redesign)
- **Responsabilità**: tema Material 3 chiaro e scuro.

### StatusColors

- **File**: `lib/app/theme.dart`
- **Responsabilità**: `ThemeExtension` con i colori degli stati; contrasto verificato in `test/app/status_colors_test.dart`.

## Componenti dell'etichetta

### AddChoiceScreen

- **File**: `lib/label/ui/add_choice_screen.dart`
- **Responsabilità**: "Aggiungi un vino" con tre pulsanti tonali alti ≥ 72 dp: "Scatta foto" (`PhotoOrigin.camera`), "Importa una foto" (`gallery`), "Scrivi" (form vuoto). Mostrata solo a chi può modificare la cantina.
- **Aperto da**: `HomeShell`, `LabelReadingScreen._retry` dopo una foto condivisa.

### LabelCaptureFlow

- **File**: `lib/label/ui/label_capture_flow.dart`
- **Responsabilità**: `run` apre fotocamera o selettore, traduce `PickOutcome` in `LabelInput` e apre `LabelReadingScreen`; ripete con la stessa origine se la lettura torna `LabelRetry`; uscita senza foto = nessun messaggio. `openForm` apre `AddWineScreen` sopra la shell (eliminando le schermate intermedie) dentro `LabelFormTracker`, che segna "dati non salvati" se il form è precompilato. Contiene anche `LabelTarget` (utente, cantina, vini).

### LabelReadingScreen

- **File**: `lib/label/ui/label_reading_screen.dart`
- **Responsabilità**: una sessione per schermata (token); mostra "Leggo l'etichetta…" con "Annulla", poi l'esito: `LabelProposalSheet`, form incompleto (`AddWineInitialValues(name, vintage, notice: labelNotFound)`), `LabelUnreadableView`, `BarcodeOnlyView`, `PermissionDeniedView`. Annuncia gli esiti a TalkBack. "Conferma": `guessOrigin` → `WineValidator` → `CellarActions.saveNewWine` (doppione → `DuplicateDialog` + `addBottles`; bozza non valida → "Correggi"); poi torna alla cantina con "Vino aggiunto alla cantina". "Correggi": form con `AddWineInitialValues.fromCandidate`. "Riprova": stessa origine, o `AddChoiceScreen` dopo una condivisione.

### LabelProposalSheet

- **File**: `lib/label/ui/label_proposal_sheet.dart`
- **Responsabilità**: "Ho riconosciuto:": nome, produttore ("—"), annata ("Senza annata"), bandiera e nome del paese, regione nella lingua dell'app, distintivo del tipo (intent ux-redesign), avviso "Senza rete riconosco solo la denominazione" se offline, quantità 1-99, errore di salvataggio, "Conferma" e "Correggi". Non salva nulla da sé.

### LabelUnreadableView

- **Stato attuale**: file cancellato nel working tree, sostituito da `NotFoundView` (vedi in fondo). Descrizione della scansione label-recognition:
- **File**: `lib/label/ui/label_unreadable_view.dart`
- **Responsabilità**: "Non riesco a leggere l'etichetta" con "Riprova" e "Scrivi a mano".

### BarcodeOnlyView

- **Stato attuale**: file cancellato nel working tree, sostituito da `NotFoundView` (vedi in fondo). Descrizione della scansione label-recognition:
- **File**: `lib/label/ui/barcode_only_view.dart`
- **Responsabilità**: codice letto senza vino: con rete "Ho letto il codice a barre ma non trovo il vino" + "Fotografa il fronte dell'etichetta"; senza rete "…serve la rete per cercarlo" + "Riprova quando torna la rete"; sempre "Riprova" e "Scrivi a mano".

### PermissionDeniedView

- **File**: `lib/label/ui/permission_denied_view.dart`
- **Responsabilità**: accesso negato ("Apri impostazioni", "Scrivi a mano") o fotocamera assente ("Importa una foto", "Scrivi a mano").

### ReplaceLabelDialog

- **File**: `lib/label/ui/replace_label_dialog.dart`
- **Responsabilità**: "Hai un vino non salvato. Vuoi leggere la nuova foto?" quando arriva una condivisione con una proposta o un form aperti.

### LabelSessionController

- **File**: `lib/label/label_providers.dart` (`labelSessionProvider`, `autoDispose.family` per token)
- **Responsabilità**: esegue una lettura: attende `TempLabelStore.beforeRead`, prepara con `SharedImageChannel`, legge con il `LabelReader` della sessione, cerca con `LabelLookupFlow`, cancella sempre la copia (`finally`); ogni errore diventa un motivo fisso; "Annulla" e la chiusura lasciano finire il lavoro e ne ignorano l'esito; `retryBarcode` ripete la ricerca del codice senza foto.

### LabelSession

- **File**: `lib/label/core/label_session.dart`
- **Responsabilità**: macchina a stati pura e sincrona di una lettura, con id di lettura per ignorare letture annullate o sostituite.

### LabelLookupFlow

- **File**: `lib/label/core/label_lookup_flow.dart` (riverificato 261108, 179 righe)
- **Responsabilità**: ricerca di una lettura unita (`MergedReading`) con **una** chiamata `WineCatalog.matchLabel(text, barcode)`; esiti `LookupSure` (con alternative per "Non è questo"), `LookupCandidates`, `LookupNotFound(kind: unreadable | barcodeNotFound | noMatch, name, vintage, query)`. L'annata letta da `VintageParser` sostituisce quella del candidato sicuro e completa i candidati senza annata; `name` è la riga di `LabelLinePicker`; `query` (per "Cerca online") sono le 6 parole più lunghe più l'annata, o il codice, ≤ 120. Errori del catalogo = "nessun risultato" (segnalati salvo `CatalogArgumentError`). Dal testo non ricava produttore, denominazione, tipo, paese né regione.
- **Prima** (scansione label-recognition): ordine codice su OFF → `matchLabelText` → riga significativa, al massimo 2 chiamate.

### BarcodeFilter

- **File**: `lib/label/core/barcode_filter.dart`
- **Responsabilità**: primo codice EAN-13, EAN-8 o UPC-A normalizzato con cifra di controllo GS1 valida.

### VintageParser

- **File**: `lib/label/core/vintage_parser.dart`
- **Responsabilità**: annata dal testo (scelte di squadra correggibili nel form).

### LabelLinePicker

- **File**: `lib/label/core/label_line_picker.dart`
- **Responsabilità**: riga per il nome del form incompleto: prima riga con una denominazione, altrimenti la più lunga che non sia volume, gradi o solfiti (it, en, pt); ≤ 120.

### MlKitLabelReader

- **File**: `lib/label/platform/mlkit_label_reader.dart`
- **Responsabilità**: `TextRecognizer(script: latin)` e `BarcodeScanner([ean13, ean8, upca])` sulla stessa `InputImage.fromFilePath`, in parallelo; testo per blocchi ordinati (alto, poi sinistra), una riga per linea; ≤ 2000 caratteri; `close` rilascia i due riconoscitori.

### PickerImageSource

- **File**: `lib/label/platform/picker_image_source.dart`
- **Responsabilità**: `ImagePicker.pickImage` senza ridimensionamento e senza metadati completi; codici `camera_access_denied`/`photo_access_denied` → negato, `no_available_camera` → assente; `discardLostData` cancella i file persi da un processo ucciso.

### SharedImageChannel

- **File**: `lib/label/platform/shared_image_channel.dart`
- **Responsabilità**: lato Dart del canale `com.vinoozy.app/label` (vedi [api-documentation.md](api-documentation.md#canale-comvinoozyapplabel)).

### TempLabelStore

- **File**: `lib/label/platform/temp_label_store.dart`
- **Responsabilità**: copie temporanee in `<temp>/label/`: pulizia completa all'avvio (in background dopo il primo frame), cancellazione dei file > 10 minuti prima di ogni lettura, cancellazione della copia a fine lettura; non cancella mai fuori dalla cartella (percorsi con link simbolici risolti); errori come `label_cleanup_failed`.

### LabelErrorReporter

- **File**: `lib/label/platform/label_error_reporter.dart`
- **Responsabilità**: unico punto di segnalazione del modulo; invia solo il tipo dell'eccezione con uno dei 4 motivi fissi; non lancia mai.

### SharedImageNotifier

- **File**: `lib/label/label_providers.dart` (`sharedImageProvider`)
- **Responsabilità**: tiene la condivisione (solo come URI nativo) finché `SharedImagePolicy` decide: leggere, "Non puoi aggiungere vini a questa cantina", scaduta o scartata; segue il gate dell'account e la shell.

### SharedImagePolicy

- **File**: `lib/label/core/shared_image_policy.dart`
- **Responsabilità**: regole pure dell'immagine condivisa: attesa durante l'accesso, scarto se l'accesso è annullato, 60 s per la cantina, 5 s per il permesso.

## Componenti del catalogo

### CatalogCoordinator

- **File**: `lib/catalog/core/catalog_coordinator.dart`
- **Responsabilità** (riverificato 261108 per `matchLabel`): implementa `WineCatalog`; valida gli ingressi; apre la base offline al primo uso (`WineDbOpener`); `matchLabel` segue l'ordine codice offline → testo offline → denominazione interna (0,70) → con rete e OFF codice, poi testo → candidati deduplicati (stesso codice, o stesso nome e produttore normalizzati; vince la fonte offline; ≤ 10); `_external` = cache → rete? → OFF acceso? → interruttore → budget → richiesta → cache (risposta scartata se l'utente è cambiato); senza rete nulla è chiesto e nulla conta come guasto. `getWineProfile` risponde sempre `found: false`. Sessione per hash dell'uid.
- **Prima** (scansione label-recognition): `matchLabelText` con `labelSearchWords` e ripiego sulla denominazione; non conosceva lo stato della rete.

### OpenFoodFactsSource

- **File**: `lib/catalog/core/off/open_food_facts_source.dart`
- **Responsabilità**: unico codice che conosce il formato OFF: costruzione degli URI, richiesta con scadenza e limite di dimensione, parsing in `OffOutcome`, `mapProduct`, `normalizeBarcode`, `wineTypeFromTags`, `cleanText`. Non lancia mai.

### CatalogCacheStore

- **File**: `lib/catalog/core/catalog_cache_store.dart`
- **Responsabilità**: cache in memoria delle risposte OFF (200 voci × 10 candidati, 30 giorni) e indice di suggerimenti di profilo (500); caricata una volta per sessione, salvata al più ogni 2 s con file temporaneo e rinomina; proprietario controllato; epoca per scartare dati di un utente precedente.

### RequestBudget

- **File**: `lib/catalog/core/request_budget.dart`
- **Responsabilità**: finestra mobile di 60 s, 8 ricerche e 60 prodotti; in memoria.

### OffCircuitBreaker

- **File**: `lib/catalog/core/off_circuit_breaker.dart`
- **Responsabilità**: sospende OFF per 5 minuti dopo 3 guasti di seguito, registra un `off_suspended`; contatori di sessione in `CatalogHealth`.

### CatalogConfig

- **File**: `lib/catalog/core/catalog_config.dart`
- **Responsabilità**: host fisso, URL della licenza ODbL, contatto `OFF_CONTACT` dalla definizione di compilazione, `offEnabled`, User-Agent.

### FileCacheFile

- **File**: `lib/catalog/platform/file_cache_file.dart`
- **Responsabilità**: `catalog_cache.json` nella cartella di supporto dell'app (esclusa dal backup).

### CrashlyticsCatalogEventLogger

- **File**: `lib/catalog/platform/crashlytics_catalog_event_logger.dart`
- **Responsabilità**: unico uso di Crashlytics del catalogo: errore non fatale `off_suspended` con chiavi numeriche; eventi di debug solo in console.

## Componenti nativi Android

### MainActivity

- **File**: `android/app/src/main/kotlin/com/vinoozy/vinoozy/MainActivity.kt`
- **Responsabilità**: unica activity (`singleTop`); crea `LabelImagePreparer` e `SharedImageReceiver`; espone il canale `com.vinoozy.app/label`; lavoro su un esecutore a thread singolo; `openAppSettings` con `ACTION_APPLICATION_DETAILS_SETTINGS`. È l'unico punto che avvia un'altra activity.

### LabelImagePreparer

- **File**: `android/app/src/main/kotlin/com/vinoozy/vinoozy/LabelImagePreparer.kt`
- **Responsabilità**: unico punto di verifica e preparazione delle immagini: solo file dentro `cacheDir`, ≤ 20 MB, JPEG/PNG/WebP/HEIC (HEIC da Android 9), ≤ 50 Mpx, riduzione a 2048 px, orientamento EXIF, JPEG q90 in `cacheDir/label/<uuid>.jpg`; cancella sempre l'input (e la cartella vuota di image_picker); tutto protetto da `catch (Throwable)`.

### SharedImageReceiver

- **File**: `android/app/src/main/kotlin/com/vinoozy/vinoozy/SharedImageReceiver.kt`
- **Responsabilità**: riceve `SEND`/`SEND_MULTIPLE` con tipo `image/` e URI `content://`, tiene solo il primo URI in memoria, consuma l'intent (niente ripetizioni dopo rotazione o ripristino); alla lettura copia a blocchi di 64 KB in `cacheDir/label/`, si ferma oltre 20 MB, poi passa al preparatore.

## Altri moduli (analisi superficiale)

| Modulo | Componenti principali |
|---|---|
| `lib/cellar/` | `WineRepository`, `CellarRepository`, `CellarActions`, `CellarMaintenance`, `EstimateRefresher`, `MatchKeyBackfill`, `RecordReconciler`, `WineEstimator`, `WineSuggestions` (`wineSuggestionsProvider`: interno subito, OFF dopo 600 ms), `CellarScreen`, `HistoryScreen`, `ArchivedWinesScreen`, `DrinkingRecordSheet`, `DuplicateBanner`, `WindowCard`, `CountryPicker`, `RegionPicker`, dialoghi |
| `lib/app/` | `VinoozyApp`, `HomeShell` (apre `AddChoiceScreen`, ascolta `sharedImageProvider`), `resolveAppLocale`, `CountryFlag` |
| `lib/sync/` | `LocalLedger`, `SyncErrorBus`, `FirestoreSyncGateway`, `SnapshotMeta` |
| `lib/account/` | `AccountGate`, `GoogleAuthService`, `ResetCoordinator`, `UserRepository`, `AccountDeletionRunner`, `NetworkStatus` (connectivity_plus) |
| `lib/sharing/` | `SharingRepository`, `MembershipTracker`, `InviteValidator` |
| `lib/dashboard/` | `DashboardCalculator`, `DashboardScreen`, `DashboardCard`, `BarChart`, `ColumnChart`, `DrinkSoonSection`, `statusIcons` |
| `packages/estimation/` | API C2 (`estimateWindow`, `statusOf`, `pairingsFor`, `needsRefinement`, `denominationCatalog`, `recognizeDenomination`) |
| `docs/account-deletion/` | `account-deletion.js`, `page.js`, bundle `app.bundle.js` |

## Componenti della stima e dei campi del vino (intent 261108-label-autofill-windows)

### estimateWindow

- **File**: `packages/estimation/lib/src/window.dart`
- **Responsabilità**: finestra di un vino: quella del catalogo se `ExternalProfile` ha tre anni validi e ordinati (`source: catalog`), altrimenti anno base + scostamenti della riga scelta da `resolveWine` (`source: internalRules`). Anno base: annata; senza annata l'anno di riferimento (spumanti e generica) o l'anno prima (altri tipi). Fiducia `medium` solo con denominazione e annata.
- **Usato da**: `WineEstimator`.

### resolveWine

- **File**: `packages/estimation/lib/src/recognizer.dart`
- **Responsabilità**: sceglie la base della stima: denominazione dell'utente → con un tipo, denominazione del catalogo o del nome solo se dello stesso tipo, altrimenti riga del tipo → senza tipo, denominazione del catalogo o del nome → riga generica. Qualificatore (gran selezione, riserva, superiore, il più specifico) letto da nome e denominazione, usato solo se la riga ha scostamenti propri. Il riconoscimento è a parole intere sugli alias normalizzati; `tokenize` esamina i primi 60 caratteri. Regione e paese non sono usati.

### denominationTable

- **File**: `packages/estimation/lib/src/tables.dart`
- **Responsabilità**: 47 righe `const`, tutte italiane (rossi, bianchi, spumanti, dolci, Marsala), ciascuna con alias, tipo, `YearOffsets(start, peak, end)`, scostamenti per qualificatore e 3-5 categorie di abbinamento. Ogni riga ha nome mostrato e regione in `denominationLabels` (`catalog.dart`). Nessuna denominazione estera, nessun vitigno.
- **Verificato da**: `packages/estimation/test/tables_test.dart` (test generati per ogni riga).

### typeTable

- **File**: `packages/estimation/lib/src/tables.dart`
- **Responsabilità**: 8 righe per tipo (`redLight` 1/2/4, `redStructured` 3/7/15, `white` 0/2/4, `rose` 0/1/2, `sparklingClassic` 1/3/6, `sparklingTank` 0/1/2, `sweet` 2/8/20, `fortified` 3/10/30) e `genericTypeProfile` 1/3/6.

### recognizeDenomination

- **File**: `packages/estimation/lib/src/catalog.dart`
- **Responsabilità**: denominazione italiana nominata in un testo di qualunque lunghezza, con nome mostrato, tipo, regione e qualificatore. Usata da catalogo, `LabelLinePicker`, `WineOrigins.guess` e `getWineProfile`.

### WindowAdjuster

- **File**: `lib/cellar/domain/window_adjuster.dart`
- **Responsabilità**: applica alla finestra base il riscontro dell'ultima bevuta con "Com'era?" (`tooYoung`, `justRight`, `pastPeak`): sposta o accorcia la finestra e abbassa la fiducia di un livello; ricade sulla base se esce da 1900-2200. `labelOf` dà la fonte mostrata (catalogo, stima per tipologia, corretta dalle bevute).

### WineEstimate

- **File**: `lib/cellar/domain/wine_estimate.dart`
- **Responsabilità**: `baseWindow`, `window` effettiva, `adjustment`, `pairings`; `toFields` scrive i quattro campi (un `null` cancella).

### WineEstimator

- **File**: `lib/cellar/wine_estimator.dart`
- **Responsabilità**: `WineFactsInput` (nome, produttore, annata, tipo come stringa, regione, denominazione, anno di riferimento; nessun paese) → `estimateWindow` + `pairingsFor` → `WindowAdjuster`; `refine` con un profilo del catalogo; `displayed` calcola in memoria la stima di un vino senza finestra salvata. Un errore della stima non blocca il salvataggio ("da stimare").

### EstimateRefresher

- **File**: `lib/cellar/estimate_refresher.dart`
- **Responsabilità**: al ritorno della rete e dopo un nuovo vino, rifà la stima dei vini senza finestra o con finestra `internalRules` (≤ 20 per giro, una volta per sessione, solo con `canEdit`) e scrive se il risultato cambia. Riscriverebbe un valore manuale salvato nella finestra.

### CellarActions

- **File**: `lib/cellar/cellar_actions.dart`
- **Responsabilità** (parte della stima): `saveNewWine` (doppioni, stima interna, `addWine`, poi `refreshWine` senza attendere); `saveEdit` (stima ricalcolata a ogni salvataggio, riscontro mantenuto); `recomputeAdjustment` (dopo bevuta, annullamento o modifica di "Com'era?": parte da `baseWindow`); `ensureEstimates` (vini senza finestra).

### WineRepository

- **File**: `lib/cellar/data/wine_repository.dart`
- **Responsabilità** (campi del vino): `addWine` scrive i campi della bozza (i valori assenti sono omessi), `matchKey`, la stima senza i `null`, `createdAt`/`updatedAt` del server; `updateWine` scrive testi, `country` (solo se c'è o c'era), `matchKey`, stima e variazione di quantità; `setEstimate` scrive solo la stima. Tutto passa da `_commit`: ledger atteso, batch non atteso, errore con motivo fisso.

### IdealMomentCard

- **File**: `lib/cellar/ui/ideal_moment_card.dart`
- **Responsabilità**: "Momento ideale" nel dettaglio: "Consigliato fino al {anno}" (`uxIdealUntil`, `window.endYear`; "…: è passato" oltre la finestra), "Al meglio dal {inizio} al {fine}", `WindowBar` con il segno di oggi, stato, inizio/picco/fine, fiducia, fonte, avviso "Indicativo". Sola lettura: nessun comando per correggere la fine. Chiavi `window-card`, `window-none`, `ideal-hint`, `ideal-until`, `ideal-best`, `window-source`.

### WineSecurityRules

- **File**: `firestore.rules` (sezione `cellars/{cellarId}/wines/{wineId}`)
- **Responsabilità**: elenco chiuso di 16 campi (`wineFields()`); creazione con nome 1-120, annata 1900-anno del server + 1, quantità 1-99, timestamp del server; modifica che valida solo i campi cambiati; forme chiuse di `window`/`baseWindow`, `windowAdjustment`, `pairings`; `producer`, `region`, `denomination` ≤ 120; `country` di due lettere maiuscole; `wineType` non validato. Lettura a proprietario e invitati, scrittura a proprietario e invitati `edit`, eliminazione al proprietario.
- **Verificato da**: `test/rules/u4.rules.test.mjs` (45 test), `test/rules/compat/` (scritture di ogni versione dell'app; nuove forme con `requiresRules` e `RULES_FEATURES` di `promote.yml`).

## Componenti dell'etichetta attuale (intent 261108-label-autofill-windows)

### MergedReading

- **File**: `lib/label/core/label_merge.dart`
- **Responsabilità**: unisce fronte e retro: testo di ciascuna foto ≤ 2000, righe del fronte poi righe del retro non già presenti (confronto normalizzato), ≤ 4000; codice a barre valido del fronte, altrimenti del retro; stato del retro `skipped`, `taken`, `unreadable`; `isUnreadable` senza codice e con meno di 3 lettere.

### LensIntentLauncher

- **File**: `android/app/src/main/kotlin/com/vinoozy/vinoozy/LensIntentLauncher.kt`
- **Responsabilità**: "Apri in Google Lens": solo un file di `cacheDir/label/`, passato con `FileProvider` (`<applicationId>.labelfiles`) e permesso di sola lettura temporaneo, con `ACTION_SEND` `image/jpeg` all'app Google (`com.google.android.googlequicksearchbox`), altrimenti al menu Condividi senza Vinoozy. Risposta `direct`, `chooser` o `failed`. Nulla torna all'app.

### WineCatalog

- **File**: `lib/catalog/core/wine_catalog.dart`
- **Responsabilità**: contratto C1 attuale: `suggestWines`, `suggestExternal`, `matchLabel`, `searchOnline`, `getWineProfile`, `lookupBarcode`; `WineCandidate` con `country`; `CandidateSource.offline`; `LabelMatchResult`, `OnlineSearchResult`. Vedi [api-documentation.md](api-documentation.md#winecatalog-attuale-intent-261108-label-autofill-windows).

### NotFoundView

- **File**: `lib/label/ui/not_found_view.dart` (analisi superficiale)
- **Responsabilità**: "Non trovato" per illeggibile, codice senza vino, testo senza vino; poi "Cerca online", "Scrivi a mano" e, finché la foto del fronte c'è, "Apri in Google Lens".

### OnlineSearchScreen

- **File**: `lib/label/ui/online_search_screen.dart` (analisi superficiale)
- **Responsabilità**: "Cerca online" con la query proposta e modificabile; chiama `WineCatalog.searchOnline`; lista di candidati e avvisi di stato; un candidato apre il form con `openCandidateForm`.

### OfflineWineDb

- **File**: `lib/catalog/core/offline/` e `lib/catalog/platform/wine_db_loader.dart` (analisi superficiale)
- **Responsabilità**: base dei vini sul telefono da `assets/wine_db/wines.jsonl.gz` (oggi 45 vini di prova), aperta una volta in un isolate; ricerca per codice e per testo con punteggio a parole distintive (`text_score.dart`). I record hanno codice, nome, produttore, tipo, denominazione, paese, annata; nessuna regione.

## Componenti di tipo, livello, stile e finestra (intent 261108-wine-style-profiles)

### Aggiornamenti dei componenti già elencati

Verificati in questa scansione (commit `baba947` più il working tree); dove le voci precedenti dicono altro, vale questo elenco.

- **estimateWindow**: applica `WineLevel.apply` agli scarti prima dell'anno base; fiducia `medium` solo per una riga dedicata (non generata) con annata; scrive `denominationKey` e `tablesVersion`.
- **resolveWine**: cinque passi (denominazione dell'utente, del catalogo, del nome; vitigno; tipo; generica); una zona con più tipi prende il tipo del vitigno nominato accanto, altrimenti il principale.
- **denominationTable**: 2424 righe, cioè 47 italiane originali, 677 scritte a mano per il mondo (149 IT, 209 FR, 173 resto d'Europa, 146 Nuovo Mondo) e 1700 generate; le dedicate vincono sulle generate.
- **typeTable**: invariata (8 tipi e generica 1/3/6).
- **IdealMomentCard**: mostra anche il livello, l'origine della stima e, per chi può modificare, "Correggi" e "Ripristina la stima".
- **WineRepository**: `addWine` e `updateWine` scrivono anche `level`; `setOverride` e `clearOverride` scrivono `windowOverride` e `window` insieme.
- **WineSecurityRules**: 18 campi (`level`, `windowOverride` in più); `validLevel`, `validOverride`, `validWindow` con `grape`, 14 qualificativi, `denominationKey`, `tablesVersion`; `wineType` ancora non validato.
- **OfflineWineDb**: 15.616 vini reali (non più 45 di prova).
- **WineTypeField**: 8 tipi con icona e colore della famiglia; usato da `AddWineScreen` ed `EditWineScreen`.

### WineType

- **File**: `packages/estimation/lib/src/models.dart`
- **Responsabilità**: gli 8 tipi (`redLight`, `redStructured`, `white`, `rose`, `sparklingClassic`, `sparklingTank`, `sweet`, `fortified`); `isSparkling`; `tryParse` accetta i nomi e i valori C1 (`red` → `redStructured`, `sparkling` → `sparklingClassic`). È la "Tipologia" mostrata nel form.

### WineLevel

- **File**: `packages/estimation/lib/src/wine_level.dart`
- **Responsabilità**: livello del vino (`everyday` 50/60/60%, `good` 100%, `aging` 125/130/140%) applicato agli scarti in anni; arrotondamento intero e ordine garantito; `aging` non rimoltiplica gli scarti di un qualificativo. `null` vale "Buono".

### agingQualifiers

- **File**: `packages/estimation/lib/src/qualifiers.dart`
- **Responsabilità**: frasi dei 14 qualificativi a parole intere, priorità, e l'insieme dei qualificativi che suggeriscono "Da invecchiamento". È l'unica regola che oggi preseleziona un livello.

### grapeTable

- **File**: `packages/estimation/lib/src/grapes.dart`
- **Responsabilità**: 46 vitigni con nome, un solo tipo, scarti medi e alias; ripiego della stima quando nessuna denominazione è riconosciuta; il vitigno non dà mai paese né regione.

### appellationTemplates

- **File**: `packages/estimation/lib/src/world_tables.dart`
- **Responsabilità**: 9 modelli (paese e livello di classificazione) con scarti per tipo, usati dalle righe generate; un tipo assente nel modello viene tolto dalla riga generata. `defaultGeneratedTypes` = `redLight`, `white`, `rose`.

### extractLabelFields

- **File**: `packages/estimation/lib/src/label_fields.dart` (con le parti `label_candidates.dart`, `label_lines.dart`, `label_words.dart`, `label_scoring.dart`)
- **Responsabilità**: dal testo dell'etichetta ricava nome, produttore, denominazione, annata, tipo, paese, regione, qualificativo e livello suggerito. Tipo: parole di stile prima del colore (fortificato, dolce, spumante, rosato, bianco, rosso), poi tipo unico della riga, poi tipo del vitigno. Livello: `aging` solo con un qualificativo da invecchiamento.

### LevelChoice

- **File**: `lib/cellar/ui/level_section.dart`
- **Responsabilità**: stato del livello nel form: valore scelto, salvato, toccato, suggerimento spento; `suggestionFor` (qualificativo del nome o della denominazione, o del testo dell'etichetta finché il nome è quello letto); `effective` (scelto, altrimenti `aging` se suggerito).

### LevelSection

- **File**: `lib/cellar/ui/level_section.dart`
- **Responsabilità**: il selettore del livello e l'anteprima della finestra con e senza livello, calcolate con `WineEstimator` a ogni build.

### WineLevelSelector

- **File**: `lib/cellar/ui/wine_level_selector.dart`
- **Responsabilità**: scelta singola tra Quotidiano, Buono, Da invecchiamento e Nessuno (≥ 48 dp); il suggerito ha bordo tratteggiato e la parola "suggerito" con il motivo; `LevelPreview` mostra la finestra risultante.

### WineTypeFamily

- **File**: `lib/cellar/ui/wine_badges.dart`
- **Responsabilità**: le 5 famiglie mostrate (rosso, bianco, rosato, spumante, dolce, con il fortificato tra i dolci), colori, icone e `WineTypeBadge`. La stessa mappatura è ripetuta in `TypeFilter.of` (`lib/cellar/domain/cellar_filter.dart`) e in `DashboardCalculator.familyOf`.

### DashboardCalculator

- **File**: `lib/dashboard/domain/dashboard_calculator.dart`
- **Responsabilità**: un passaggio sui vini: stato con `statusOf` sulla finestra effettiva (finestre non valide contate a parte), famiglia dal `wineType` salvato ("non specificato" se assente), picchi per anno, "da bere presto" con l'anno di fine.

### EstimatesMigration

- **File**: `lib/cellar/estimates_migration.dart`
- **Responsabilità**: stima una tantum con le nuove tabelle: candidati con finestra base `internalRules` e `tablesVersion` diversa; un vino alla volta con `setEstimate(quiet)`; conserva livello, correzione e abbinamenti del catalogo; si ferma al primo rifiuto e, dopo 3 avvii con rifiuto, aspetta la versione successiva. Non riscrive tipo né livello. Avviata da `CellarActions` (provider `estimatesMigrationProvider`).

### WineDbRecord

- **File**: `lib/catalog/core/offline/wine_db_record.dart`
- **Responsabilità**: un vino della base offline: `code`, `name`, `producer?`, `wineType?` (8 tipi), `denomination?`, `country?`, `vintage?`; righe JSON a chiavi brevi, righe danneggiate scartate; `toCandidate` riduce il tipo a `CatalogWineType` (5 famiglie). Nessun vitigno, livello, regione o stile.

### buildWineDb

- **File**: `tool/build_wine_db.dart`
- **Responsabilità**: costruisce `assets/wine_db/` dall'export CSV di Open Food Facts scaricato a mano: tiene solo i vini, ricava tipo dai tag (`wineTypeOfTags`: fortificato, dolce, metodo classico, Charmat, rosato, bianco, rosso strutturato salvo "light/young/nouveau/primeur"), denominazione (`denominationOf`), paese, annata; controlli di plausibilità (≥ 5000 vini, export ≤ 180 giorni, ≤ 3 MB compressi, ≤ 30 MB).

### buildAppellations

- **File**: `tool/build_appellations.dart`
- **Responsabilità**: genera `appellations.g.dart` e il manifest da eAmbrosia e dai CSV di `tool/data/appellations/`: modello per paese e protezione; tipi dal CSV, altrimenti dalle parole del nome (`typesFromName`: liquoroso/porto → fortificato, passito/recioto → dolce, spumante/cava/crémant → spumante, rosato, bianco, rosso → `redLight`), altrimenti `redLight,white,rose`; esclude le righe già dedicate e i nomi di vitigni; almeno 1500 denominazioni.
