# Documentazione delle API — Vinoozy

L'app non espone API di rete: è un client. Le superfici sono le API esterne che consuma e le API interne Dart tra moduli.

## API esterne consumate

| API | Dove | Note |
|---|---|---|
| Firestore (SDK `cloud_firestore` 7.1.0) | `lib/*/data/`, `lib/account/` | Collezioni: `users/{uid}`, `cellars/{cellarId}`, `cellars/{id}/wines/{wineId}`, `cellars/{id}/drinkingRecords/{recordId}`, `cellars/{id}/members/{uid}`. Forme e permessi in `firestore.rules`; indici in `firestore.indexes.json` |
| Firebase Auth + Google Sign-In | `lib/account/google_auth_service.dart` | In build e2e: `lib/e2e/emulator_google_auth_service.dart` |
| Open Food Facts (HTTP) | `lib/catalog/core/off/open_food_facts_source.dart` | Vedi sotto |
| ML Kit (on-device) | `lib/label/platform/mlkit_label_reader.dart` | Testo latino e codici EAN-13/EAN-8/UPC-A, modelli inclusi nell'app, nessuna rete |
| Platform channel `com.vinoozy.app/label` | `lib/label/platform/shared_image_channel.dart` ↔ `MainActivity.kt` | Vedi sotto |
| Intent Android | `AndroidManifest.xml`, `MainActivity.kt` | Ingresso: `SEND`/`SEND_MULTIPLE` `image/*`; uscita: solo `Settings.ACTION_APPLICATION_DETAILS_SETTINGS`; fotocamera e selettore di foto tramite image_picker |

### Open Food Facts

| Operazione | Richiesta | Uso |
|---|---|---|
| Ricerca testuale | `GET https://world.openfoodfacts.org/cgi/search.pl?search_terms=<testo>&tagtype_0=categories&tag_contains_0=contains&tag_0=wines&json=1&page_size=10&lc=<it|en|pt>&fields=code,product_name,brands,categories_tags,origins` | `suggestExternal` (form, dopo 600 ms di pausa, testo ≥ 3 caratteri) e `matchLabelText` (etichetta, al massimo 6 parole) |
| Prodotto | `GET https://world.openfoodfacts.org/api/v2/product/<8 o 13 cifre>.json?fields=…` | `lookupBarcode` (etichetta, solo con rete) |

- Intestazioni: solo `User-Agent: Vinoozy/<versione> (<OFF_CONTACT>)`. Nessun redirect seguito (3xx = guasto), scadenza unica 5 s, corpo ≤ 1 MB.
- Esiti: `OffFound` (HTTP 200 con almeno un vino), `OffNotFound` (404, `status: 0`, non vino, nessun risultato; si mette in cache come lista vuota), `OffFailed` (`timeout`, `network`, `http_<codice>`, `too_large`, `invalid_json`; mai in cache).
- Mappatura (`mapProduct`): solo prodotti con `en:wines` in `categories_tags`; `name` = `product_name` ≤ 120; `producer` = primo marchio di `brands` ≤ 80; `wineType` dalle categorie inglesi (frizzante e dolce prevalgono sul colore); `region` = `origins` ≤ 60; `denomination` = `recognizeDenomination(name)` ≤ 60; `barcode` = `code` normalizzato. Caratteri di controllo tolti.
- Limiti lato app: 8 ricerche e 60 prodotti per finestra mobile di 60 s; dopo 3 guasti di seguito sospensione di 5 minuti.
- Acceso solo con `OFF_CONTACT` non vuoto (`--dart-define`, in produzione da `config/firebase_prod.json`).
- Non usati: API v2 di ricerca, altri campi (per esempio nome generico, quantità, immagini), esportazioni o dump.

### Canale `com.vinoozy.app/label`

| Metodo | Direzione | Argomenti → risposta |
|---|---|---|
| `prepare` | Dart → nativo | `{path}` (file di image_picker dentro `cacheDir`) → `{path: <cacheDir/label/uuid.jpg>}` o `{rejected: scheme|type|size|format|decode}` |
| `pendingShare` | Dart → nativo | — → `{multiple: bool}` o `null` |
| `readShare` | Dart → nativo | — → come `prepare`, oppure `null` se nessuna condivisione |
| `discardShare` | Dart → nativo | — → `null` |
| `openSettings` | Dart → nativo | — → `bool` |
| `shareArrived` | nativo → Dart | `{multiple: bool}` |

Il lavoro di `prepare` e `readShare` gira su un esecutore a thread singolo; le risposte tornano sul thread principale.

### Documento del vino `cellars/{id}/wines/{wineId}` (C3)

Campi ammessi dalle regole (`firestore.rules`, `wineFields()`): `name`, `producer`, `vintage`, `wineType`, `region`, `denomination`, `quantity`, `window`, `pairings`, `createdAt`, `updatedAt`, `updatedBy`, `matchKey`, `baseWindow`, `windowAdjustment` e, dall'intent ux-redesign, `country` (codice ISO 3166-1 alpha-2 opzionale, `validCountry`). L'elenco resta chiuso: un nuovo campo (per esempio un codice a barre) è rifiutato finché regole e test delle regole non lo ammettono. `producer`, `region` e `denomination` sono testi opzionali di al massimo 120 caratteri. I nomi dei campi lato app sono in `WineFields` (`lib/cellar/domain/wine.dart`). Le regole con `country` vanno pubblicate prima della build che lo scrive (`docs/release-checklist.md` §1-octies).

## API interne principali

### `WineCatalog` (contratto C1, `lib/catalog/core/wine_catalog.dart`)

Tabella della scansione label-recognition (u6). Il contratto attuale, con `matchLabel` al posto di `matchLabelText`, `searchOnline`, la fonte `offline` e il paese del candidato, è in [`WineCatalog` attuale](#winecatalog-attuale-intent-261108-label-autofill-windows).

| Operazione | Firma | Comportamento |
|---|---|---|
| `suggestWines` | `SuggestResult suggestWines(String query, {CatalogLocale locale, List<CellarWineRef>? cellarWines})` | Sincrona, solo interna: vini della cantina, poi denominazioni; ≤ 10 |
| `suggestExternal` | `Future<SuggestResult> suggestExternal(String query, {CatalogLocale locale})` | Solo OFF (cache o budget); vuota se OFF spento, sospeso o fuori budget |
| `matchLabelText` | `Future<LabelMatch> matchLabelText(String text, {CatalogLocale locale})` | Testo ≤ 2000 (altrimenti `textTooLong`); OFF con ≤ 6 parole, primo risultato con la stessa denominazione; altrimenti denominazione interna; altrimenti `LabelMatch.none()` |
| `getWineProfile` | `Future<WineProfileResult> getWineProfile(String name, {String? producer, int? vintage})` | Mai OFF; `found` sempre `false`; tipo, regione e denominazione da suggerimenti in cache o denominazione |
| `lookupBarcode` | `Future<WineCandidate?> lookupBarcode(String code)` | 8, 12 o 13 cifre (altrimenti `invalidBarcode`); OFF prodotto via cache |

- `WineCandidate{name, source, producer, vintage, wineType, region, denomination, barcode}`; `source` ∈ `cellar`, `internal`, `openFoodFacts` (le proposte OFF vanno mostrate con l'attribuzione ODbL, testo `offAttribution`); nessun campo paese (il paese si deduce con `WineOrigins.guess`).
- `CatalogLocale` `it`, `en`, `ptBR` (OFF riceve `it`, `en`, `pt`).
- Unica eccezione: `CatalogArgumentError(code)` con `queryTooShort`, `queryTooLong`, `textTooLong`, `invalidBarcode`; messaggio fisso, mai il valore.
- Implementazione: `CatalogCoordinator`, esposta da `catalogProvider` (legato all'uid: al cambio utente la cache del precedente si cancella).

### Etichetta (`lib/label/`)

Descrizione della scansione label-recognition (u6); le firme cambiate sono in [Etichetta attuale](#etichetta-attuale-intent-261108-label-autofill-windows).

- `abstract interface class LabelReader { Future<LabelReading> read(String imagePath); Future<void> close(); }` — una sola immagine per chiamata.
- `LabelReading({List<ReadBarcode> barcodes, String text})`, `LabelReading.maxTextLength = 2000`.
- `abstract interface class ImageSource { Future<PickOutcome> pick(PhotoOrigin origin); Future<void> discardLostData(); }`.
- `LabelLookupFlow({catalog, currentYear, onFailure, barcodes, vintages, lines}).run(LabelReading, {required bool online, required CatalogLocale locale}) → Future<LookupOutcome>`; `retryBarcode(String, {online})`.
- `LabelSessionController` (`labelSessionProvider(token)`): `start(LabelInput, {locale})`, `cancel()`, `retryBarcode()`. `LabelInput`: `PickedLabelInput(path)`, `SharedLabelInput()`, `DeniedLabelInput(origin)`, `CameraUnavailableLabelInput()`, `FailedPickLabelInput(error, stack)`.
- `LabelState`: `LabelIdle`, `LabelReadingState(readId)`, `LabelProposalState(candidate, offline)`, `LabelIncompleteState(name, vintage)`, `LabelUnreadableState`, `LabelBarcodeOnlyState(barcode, needsNetwork)`, `LabelPermissionDeniedState(origin)`, `LabelCameraUnavailableState`, `LabelCancelledState`.
- `LabelCaptureFlow.run(context, ref, LabelTarget, PhotoOrigin)`, `LabelCaptureFlow.openForm(context, LabelTarget, {AddWineInitialValues? initialValues})`.
- Motivi d'errore verso Crashlytics: `label_read_failed`, `label_pick_failed`, `label_lookup_failed`, `label_cleanup_failed` (solo il tipo dell'eccezione).
- Chiavi: `add-choice-screen`, `add-choice-photo`, `add-choice-import`, `add-choice-write`, `label-reading-screen`, `label-reading`, `label-cancel`, `label-proposal`, `label-proposal-name`, `label-proposal-origin`, `label-offline-notice`, `label-confirm`, `label-correct`, `label-save-failed`, `label-unreadable`, `label-barcode-only`, `label-retry`, `label-retry-online`, `label-write-by-hand`, `label-permission-denied`, `label-camera-unavailable`, `label-open-settings`, `label-import`, `label-message`, `label-replace-dialog`, `label-replace-keep`, `label-replace-read`, `label-added-snackbar`.

### Origine del vino (`lib/cellar/domain/wine_origins.dart`, intent ux-redesign)

- `WineOrigins.guess({String? region, String? denomination, String? name}) → OriginGuess{country, region}`: denominazione italiana (IT + regione canonica), poi denominazione estera della tabella interna, poi testo `region` diviso su `, ; / | ( )` (paese per nome o alias; regione elencata; altrimenti testo libero).
- `guessOrigin(WineCandidate)` in `add_wine_screen.dart` la chiama con `region`, `denomination`, `name` del candidato.
- Altre: `country(code)`, `isCountryCode`, `flagEmoji`, `searchCountries`, `regionsOf(country)`, `findRegion`, `canonicalRegion`, `effectiveCountry` (regione italiana senza paese ⇒ `IT`), `regionDisplayName`, `countryNamed`; `wineCountryCodes` (21), `rareWineCountryCodes` (16).

### Form "Aggiungi vino" (`lib/cellar/ui/add_wine_screen.dart`, riverificato)

- `AddWineScreen({user, cellarId, initialName, cellar, prefill, cellarWines, initialValues})`.
- `AddWineInitialValues({name, producer, vintage, noVintage, quantity, wineType, region, denomination, country, notice})` e `AddWineInitialValues.fromCandidate(WineCandidate, {quantity, notice})` (paese e regione da `guessOrigin`).
- `OriginGuess guessOrigin(WineCandidate)`, `String? wineFamilyOf(CatalogWineType?)`, `WineTypeField({value, onChanged})`.
- Campi nell'ordine: avviso (se `notice`), nome con proposte, produttore con proposte, `CountryPicker`, `RegionPicker`, annata, "Senza annata", tipologia, quantità; "Salva" fisso in basso.
- Chiavi: `add-wine-screen`, `add-wine-notice`, `add-wine-name-field`, `add-wine-suggestions`, `add-wine-suggestion-<i>`, `add-wine-producer`, `add-wine-producers`, `add-wine-producer-option-<i>`, `add-wine-new-producer`, `add-wine-vintage-field`, `add-wine-no-vintage-switch`, `add-wine-type`, `quantity-stepper`, `add-wine-save-failed`, `add-wine-save-button` (più le chiavi dei selettori di `origin_pickers.dart`, non lette).

### Validazione del vino (`lib/cellar/domain/wine_validator.dart`, riverificato)

- `WineInput({id, name, vintage, noVintage, quantity, producer = '', wineType, region, denomination, country})`.
- `WineValidator.validate(WineInput, {required int currentYear, int minQuantity = 1})` → `WineValidation{draft, nameError, producerError, vintageError, quantityError, regionError, countryError}`. Regione: ≤ 120 code point dopo `trim`, salvata col nome canonico se elencata; paese: `null` o codice ISO valido; regione italiana senza paese ⇒ `IT`. La denominazione non è validata.

### Le API della bevuta e della sincronizzazione

Descritte alla scansione pending-banner-fix e ux-redesign; i file sono cambiati dopo (modifiche non committate) e non sono stati riletti in questa scansione.

#### `DrinkingRecordRepository` (`lib/cellar/data/drinking_record_repository.dart`)

| Metodo | Ritorno | Effetto |
|---|---|---|
| `drink({cellarId, user, wine, today})` | `DrinkOutcome` (`DrinkAccepted(recordId)` / `DrinkFailed`) | Batch: `quantity` −1 + nuovo documento in `drinkingRecords` |
| `undo({cellarId, user, wine, recordId})` | `UndoResult` (`undone`, `nothingToUndo`, `failed`) | Lettura dalla cache, poi batch: delete bevuta + `quantity` +1 |
| `updateRecord({...})` | `SaveOutcome` | Batch: voto, note, data, condizione |
| `pageHistory(cellarId, {after, limit=30})` | `HistoryPage` | Lettura a pagine |
| `recordsOfWine(cellarId, wineId, {source})` | `WineRecords` | Server entro 1 s o cache |

#### `CellarActions`

- `drink`, `undoDrink`, `removeBottle`, `addBottles`, `saveNewWine` (doppioni + stima) — `saveNewWine` e `addBottles` sono usate anche dalla "Conferma" dell'etichetta.

#### Flusso UI della bevuta (`lib/cellar/ui/`)

- `drinkWithUndo(BuildContext, WidgetRef, {user, cellar, wine})`; `DrinkSnackBar.durationFor(context)` → 6 s o 10 s.
- Chiavi: `wine-tile-drink-<id>`, `wine-drink`, `drink-snackbar`, `drink-undo`, `drink-add-notes`, `drink-failed`, `nothing-to-undo`.

#### `PendingWritesProbe`, `SyncStatusTracker`, provider

- `PendingWritesProbe({waitForPendingWrites, onPendingChanged, reporter, startupGrace = 300 ms})`, `trackWrite()`, `checkAtStartup()`, `isPending`.
- `SyncStatusTracker`: `state`, `onSnapshot`, `setPending`, `forget`; `SyncSource { cellar, wines, drinkingRecords }`.
- `drinkingRecordsPendingProvider`, `syncStatusProvider(cellarId)`.

### Tema (`lib/app/theme.dart`)

- `ThemeData buildAppTheme(Brightness)`; `AppColors`; `StatusColors` (`ThemeExtension`). Descrizione della scansione ux-redesign.

### `estimation` (contratto C2, `packages/estimation/lib/estimation.dart`)

`estimateWindow`, `statusOf`, `pairingsFor`, `needsRefinement`, più le funzioni di catalogo usate da catalogo ed etichetta: `denominationCatalog`, `recognizeDenomination` (riconosce una denominazione italiana in un testo; `DenominationInfo{key, displayName, aliases, wineType, region}`), `normalizeWineText`; errori `EstimationArgumentError`. Dettaglio verificato dall'intent 261108-label-autofill-windows in [`estimation` in dettaglio](#estimation-in-dettaglio-intent-261108-label-autofill-windows).

## Aggiornamento dell'intent 261108-label-autofill-windows

### `estimation` in dettaglio (intent 261108-label-autofill-windows)

| Funzione | Firma | Comportamento |
|---|---|---|
| `estimateWindow` | `DrinkingWindow estimateWindow(WineFacts wine, [ExternalProfile? external])` | Finestra del catalogo se `external` ha i tre anni validi e ordinati; altrimenti anno base + `YearOffsets` della riga risolta. Fiducia `medium` solo con denominazione **e** annata, altrimenti `low`; `source: internalRules` |
| `statusOf` | `WineStatus statusOf(DrinkingWindow window, DateTime today)` | `waiting` prima dell'inizio, `pastWindow` dopo la fine, `drinkSoon` negli ultimi mesi (25% della durata, tra 3 e 12), altrimenti `ready` |
| `pairingsFor` | `Pairings pairingsFor(WineFacts wine, [ExternalProfile? external])` | Testi del catalogo (≤ 5) o 3-5 categorie della riga |
| `needsRefinement` | `bool needsRefinement(DrinkingWindow window)` | `true` per `internalRules` |
| `recognizeDenomination` | `RecognizedDenomination? recognizeDenomination(String text)` | Alias più lungo a parole intere su tutto il testo; `key`, `displayName` (es. "Barolo DOCG"), `wineType`, `region` italiana, `qualifier` |
| `normalizeWineText` | `String normalizeWineText(String text)` | Minuscole, accenti Latin-1 tolti, punteggiatura e apostrofi come spazi |
| `denominationCatalog` | `List<DenominationInfo>` | Le 47 righe in ordine di tabella |

- `WineFacts{name, producer, vintage, wineType, region, denomination, referenceYear}`: `producer` e `region` non sono usati dal calcolo; nessun campo paese, livello o fine manuale.
- `DrinkingWindow{startYear, peakYear, endYear, confidence, source, basis, qualifier}`; `warningCode` = `GENERIC_ESTIMATE` per `basis: generic`.
- Precedenze di `resolveWine`: (1) denominazione dell'utente riconosciuta; (2) con un tipo (utente, poi catalogo) la denominazione del catalogo o del nome solo se ha lo stesso tipo, altrimenti la riga del tipo; (3) senza tipo, denominazione del catalogo, poi del nome; (4) riga generica. Il qualificatore conta solo se la riga ha scostamenti propri per esso.
- Errori: solo `EstimationArgumentError` con `emptyName`, `vintageOutOfRange`, `referenceYearOutOfRange`, `missingReferenceYear`, `invalidWindow`; `WineEstimator` li trasforma in "da stimare".

### Forma della finestra nel documento del vino (vincoli delle regole)

`window` e `baseWindow` (`validWindow`, `firestore.rules:271-283`): solo le chiavi `startYear`, `peakYear`, `endYear`, `confidence`, `source`, `basis`, `qualifier`; anni interi tra 1900 e 2200, ordinati; `confidence` tra `high`, `medium`, `low`; `source` tra `catalog`, `internalRules`; `basis` tra `catalog`, `denomination`, `wineType`, `generic`; `qualifier` tra `riserva`, `superiore`, `granSelezione`. `windowAdjustment`: `kind` tra `tooYoung`, `justRight`, `pastPeak`, più `year` e `recordId`. Un livello, una fine manuale o un nuovo valore di questi elenchi sono rifiutati finché `wineFields()`, i validatori, `test/rules/u4.rules.test.mjs`, una nuova versione di `test/rules/compat/app-writes.json` (con `requiresRules`) e `RULES_FEATURES` di `.github/workflows/promote.yml` (oggi `sharing cellar account origin`) non li ammettono. `wineType` non è validato dalle regole.

### `WineCatalog` attuale (intent 261108-label-autofill-windows)

| Operazione | Firma | Comportamento |
|---|---|---|
| `suggestWines` | come prima | Interna e sincrona |
| `suggestExternal` | come prima | Solo OFF |
| `matchLabel` | `Future<LabelMatchResult> matchLabel(String text, {String? barcode, CatalogLocale locale})` | Testo unito ≤ 4000 (altrimenti `textTooLong`); ordine: codice nella base offline (sicuro) → testo nella base offline (sicuro con punteggio ≥ 0,85, distacco ≥ 0,15, almeno 2 parole distintive) → denominazione interna (candidato 0,70) → con rete e OFF: codice, poi testo → candidati (≥ 0,45, ≤ 10) o niente |
| `searchOnline` | `Future<OnlineSearchResult> searchOnline(String query, {CatalogLocale locale})` | Query 1-120; base offline prima, poi OFF; stato `ok`, `offline`, `rateLimited`, `unavailable` |
| `getWineProfile` | come prima | `found` sempre `false`; tipo, regione, denominazione dai suggerimenti in cache o dalla denominazione riconosciuta nel nome |
| `lookupBarcode` | come prima | Base offline prima, poi OFF |

- `WineCandidate` ha ora `country` (ISO, dalla base offline); `CandidateSource` ha `offline` (rango 1, dopo la cantina); `LabelMatchResult` con `kind` (`sure`, `candidates`, `none`), `candidate`, `candidates`, `step`; `LabelMatchStep` tra `offlineBarcode`, `offlineText`, `internalDenomination`, `onlineBarcode`, `onlineText`, `none`.
- `CatalogWineType` resta a 5 valori (`red`, `white`, `rose`, `sparkling`, `sweet`): rosso leggero e strutturato, dolce e fortificato non si distinguono.

### Etichetta attuale (intent 261108-label-autofill-windows)

- `MergedReading mergeLabelReadings({LabelReading? front, LabelReading? back, bool backTaken, BarcodeFilter barcodes})`.
- `LabelLookupFlow({catalog, currentYear, onFailure, vintages, lines}).run(MergedReading, {required CatalogLocale locale})` restituisce `Future<LookupOutcome>`; esiti `LookupSure(candidate, step, alternatives, notFound)`, `LookupCandidates(candidates, step, notFound)`, `LookupNotFound(kind, name, vintage, query)`; `LabelLookupFlow.searchQueryOf(text, {vintage, barcode})`.
- `LabelCaptureFlow.openForm(context, target, {initialValues})` e `openCandidateForm(context, target, candidate)`; "Scrivi a mano" da "Non trovato" passa `AddWineInitialValues(name, vintage, notice)`.
- `LensLauncher.open(path)` restituisce `LensRoute`; canale `vinoozy/lens`, metodo `open({path})` con risposta `direct`, `chooser` o `failed`. Nessun metodo restituisce testo all'app.
- Ingressi di testo dall'esterno: nessuno (niente lettura degli appunti in `lib/`, nessun intent filter `text/plain`; il manifest dichiara `<queries>` per `PROCESS_TEXT` solo per il motore Flutter).
