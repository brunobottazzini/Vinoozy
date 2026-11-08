# Scansione del codice — Vinoozy (intent 261108-label-autofill-windows)

Scansione mirata, profondità Standard, sul working tree al commit `0d99791d02005b8a90a78d17ec57cc994c820cf2` con le modifiche non committate (riprogettazione UX e riconoscimento dell'etichetta). Nessun test né build eseguiti. Non letti: `config/firebase_prod.json`, `android/app/google-services.json`, l'installazione di AI-DLC.

## Developer Code Scan Results

### Scan Coverage
- **Analyzed deeply**:
  - `packages/estimation/lib/` (tutti i file di `src/` e `estimation.dart`; di `tables.dart` lette struttura, scostamenti di tutte le 47 righe, righe per tipo e riga generica)
  - `packages/estimation/pubspec.yaml`
  - `lib/cellar/domain/wine.dart`
  - `lib/cellar/domain/wine_draft.dart`
  - `lib/cellar/domain/wine_validator.dart`
  - `lib/cellar/domain/wine_origins.dart` (logica completa; tabelle di paesi e regioni lette per struttura)
  - `lib/cellar/domain/window_adjuster.dart`
  - `lib/cellar/domain/wine_estimate.dart`
  - `lib/cellar/wine_estimator.dart`
  - `lib/cellar/estimate_refresher.dart`
  - `lib/cellar/cellar_actions.dart` (percorsi di salvataggio, modifica, bevuta e stima; eliminazione e unione solo per firma)
  - `lib/cellar/data/wine_repository.dart` (scritture dei campi del vino: `addWine`, `updateWine`, `setEstimate`, `_updateWine`, `_commit`; il resto per firma)
  - `lib/cellar/ui/add_wine_screen.dart`
  - `lib/cellar/ui/edit_wine_screen.dart`
  - `lib/cellar/ui/ideal_moment_card.dart`
  - `firestore.rules` (sezione `cellars/{id}/wines/{wineId}`)
  - `lib/label/core/label_merge.dart`
  - `lib/label/core/label_lookup_flow.dart`
  - `lib/label/core/label_line_picker.dart`
  - `lib/label/core/vintage_parser.dart`
  - `lib/label/core/label_reading.dart`
  - `lib/label/core/lens_launcher.dart`
  - `lib/label/ui/label_capture_flow.dart`
  - `lib/catalog/core/wine_catalog.dart`
  - `lib/catalog/core/catalog_coordinator.dart` (percorso `matchLabel` e deduplicazione)
  - `android/app/src/main/kotlin/com/vinoozy/vinoozy/LensIntentLauncher.kt`
  - `tool/check_off_config.sh`
- **Skimmed only**:
  - `lib/label/ui/label_reading_screen.dart`, `lib/label/ui/not_found_view.dart`, `lib/label/ui/add_choice_screen.dart`, `lib/label/ui/label_proposal_sheet.dart`, `lib/label/ui/online_search_screen.dart`, `lib/label/label_providers.dart`, `lib/label/core/label_session.dart`
  - `lib/catalog/core/offline/`, `lib/catalog/core/internal_catalog.dart`, `lib/catalog/platform/wine_db_loader.dart`
  - `lib/cellar/ui/wine_detail_screen.dart`, `lib/cellar/ui/wine_card.dart`, `lib/cellar/ui/window_card.dart`
  - `android/app/src/main/kotlin/com/vinoozy/vinoozy/MainActivity.kt`
  - `packages/estimation/test/`, `packages/estimation/README.md`
  - `test/rules/` (numero di test, `compat/app-writes.json`, casi `country`), `test/label/`, `test/catalog/` (numero di test per file), `integration_test/label_test.dart` (scenari)
  - Fuori dall'insieme della fotografia, solo per contesto: `android/app/src/main/AndroidManifest.xml`, `assets/wine_db/`, `lib/l10n/app_it.arb` (chiavi), `.github/workflows/promote.yml` (`RULES_FEATURES`), `test/cellar/` (nomi dei file), `lib/dashboard/` (uso di `wine.window`)
- **Left out**:
  - `packages/estimation/coverage/` (output di copertura, ignorato da `.gitignore`)
  - `.dart_tool/`, `build/`, `android/.gradle/`, `node_modules/`

### Packages Found
- `estimation` — pacchetto Dart locale (path) — Dart puro, nessuna dipendenza di produzione — stima della finestra di consumo, stato, abbinamenti; tabelle delle denominazioni; riconoscimento della denominazione nel testo
- `vinoozy` (app) — app Flutter — Dart + Kotlin — moduli `lib/cellar/` (dominio del vino, stima applicata, form), `lib/label/` (foto, lettura, ricerca), `lib/catalog/` (contratto C1, base offline, Open Food Facts)

### Build System
- **Type**: Flutter/pub (app), Dart pub (`packages/estimation`), Gradle Kotlin DSL (Android)
- **Config Files**: `pubspec.yaml` (asset `assets/wine_db/`), `packages/estimation/pubspec.yaml` (sezione `dependencies:` vuota per contratto, verificata da `tool/check_estimation_purity.sh`), `android/app/build.gradle.kts`
- **Build Dependencies**: app → `estimation` (path); `lib/cellar` → `estimation`, `lib/catalog`; `lib/label` → `lib/catalog`, `lib/cellar`; `lib/catalog` → `estimation`

### APIs Discovered
- API Dart C2 (`packages/estimation/lib/estimation.dart`) — 4 funzioni di stima (`estimateWindow`, `statusOf`, `pairingsFor`, `needsRefinement`) + 3 di catalogo (`normalizeWineText`, `recognizeDenomination`, `denominationCatalog`)
- API Dart C1 (`lib/catalog/core/wine_catalog.dart`) — 6 operazioni: `suggestWines`, `suggestExternal`, `matchLabel`, `searchOnline`, `getWineProfile`, `lookupBarcode`
- Documento Firestore `cellars/{id}/wines/{wineId}` — 16 campi ammessi (`wineFields()`), forma di `window`/`baseWindow` chiusa
- Platform channel `vinoozy/lens` — 1 metodo (`open`, risposta `direct`/`chooser`/`failed`); `com.vinoozy.app/label` invariato (6 metodi)

### Frameworks & Libraries
- Flutter — 3.47.9 — interfaccia
- Dart SDK — ^3.13.7 — linguaggio
- flutter_riverpod — ^3.4.3 — stato e iniezione
- cloud_firestore — 7.1.0 — dati del vino
- google_mlkit_text_recognition / google_mlkit_barcode_scanning — 1.0.0 — lettura on-device
- androidx.core `FileProvider` — (dal manifest) — passaggio della foto a Google Lens
- test — ^1.33.0 — test del pacchetto `estimation`

### Test Coverage
- **Test Directories**: `packages/estimation/test/` (9 file, circa 130 test: `window_test` 28, `recognizer_test` 25, `models_test` 19, `catalog_functions_test` 13, `pairings_test` 12, `status_test` 11, `tables_test` 11 generati per riga, `api_test` 10), `test/label/` (25 file), `test/catalog/` (19 file, di cui 4 in `offline/`), `test/rules/` (u4 45 test, compat), `test/cellar/domain/` (`window_adjuster_test`, `wine_validator_test`, `wine_origins_test`), `test/cellar/ui/` (`add_wine_screen_test`, `edit_wine_screen_test`, `wine_detail_screen_test`), `test/cellar/estimate_refresher_test.dart`, `integration_test/label_test.dart` (5 scenari)
- **Test Frameworks**: `package:test`, `flutter_test`, `integration_test`, `@firebase/rules-unit-testing`
- **Coverage Config**: presente (80% sull'app senza esclusioni; il README di `estimation` usa 90% sul pacchetto)

### Code Quality Indicators
- **Linting**: `flutter_lints` (`analysis_options.yaml`), `lints` nel pacchetto `estimation`
- **CI/CD**: `.github/workflows/ci.yml`, `promote.yml` (`RULES_FEATURES: sharing cellar account origin`), `release.yml`, `firebase-deploy.yml`
- **Documentation**: commenti di classe legati a requisiti (BRx, FRx, NFRx) in ogni file letto; README del pacchetto `estimation`; `assets/wine_db/README.md`

### Technical Debt Signals
- Tabelle di stima solo italiane: `denominationTable` ha 47 righe, tutte italiane; nessuna denominazione estera, nessun vitigno (`packages/estimation/lib/src/tables.dart`). Le 47 denominazioni estere di `WineOrigins._denominations` (`lib/cellar/domain/wine_origins.dart:448-496`) danno solo paese e regione, mai una finestra.
- `WineFacts.region` è passato ma ignorato da `resolveWine` (`packages/estimation/lib/src/recognizer.dart:211-243`); il paese non arriva mai alla stima (`WineFactsInput` non ha `country`, `lib/cellar/wine_estimator.dart:9-49`).
- Il riconoscimento esamina solo i primi 60 caratteri del nome (`maxNameLength = 60`, `recognizer.dart:10`), mentre il nome del vino ne ammette 120 (`WineRules.maxNameLength`).
- Tre punti ricalcolano la finestra dai fatti e sovrascrivono `baseWindow`/`window`: `CellarActions.saveEdit` (`cellar_actions.dart:185-216`), `EstimateRefresher._refreshOne` (`estimate_refresher.dart:93-128`, solo per finestre `internalRules`), `CellarActions.ensureEstimates`. Un valore manuale verrebbe perso senza un campo e una regola dedicati.
- Le regole limitano `window.source` a `catalog`/`internalRules` e `basis` a `catalog`/`denomination`/`wineType`/`generic`; `qualifier` a `riserva`/`superiore`/`granSelezione` (`firestore.rules:271-283`). Un campo "Livello", una fonte "manuale" o un nuovo `basis` richiedono regole, test, una nuova versione in `test/rules/compat/app-writes.json` con `requiresRules` e una voce in `RULES_FEATURES` di `promote.yml`.
- `wineType` non è validato dalle regole (né in creazione né in modifica); `denomination` non è validata dall'app (solo ≤ 120 dalle regole).
- La denominazione non è un campo del form: arriva nascosta da una proposta (`_pick`, `add_wine_screen.dart:290-315`) o dall'etichetta e resta anche se il nome viene poi cambiato; in modifica è copiata da `widget.wine.denomination` (`edit_wine_screen.dart:83`) e non si può correggere.
- Mappatura dei tipi a grana grossa: `CatalogWineType` ha 5 valori; `red` → `redStructured`, `sweet`/`fortified` → `sweet` (`internal_catalog.dart:17-24`, `models.dart:41-47`).
- Base dei vini offline di prova: `assets/wine_db/manifest.json` dice `"wineCount": 45`, `"source": "sample"`.

## Handoff Summary
- **Intent-relevant finding**: dal testo dell'etichetta oggi si ricavano solo **nome** (riga più significativa, `LabelLinePicker.pick`) e **annata** (`VintageParser.parse`); produttore, denominazione, tipo, paese e regione arrivano solo se un candidato del catalogo viene trovato (`LabelLookupFlow.run`, `lib/label/core/label_lookup_flow.dart:108-150`; "Scrivi a mano" passa solo `name` e `vintage`, `lib/label/ui/label_reading_screen.dart:172-184`). Non esiste un analizzatore che estragga i campi strutturati dal testo libero, né un ingresso di testo incollato: nessun uso di `Clipboard.getData` in `lib/`, nessun intent filter `text/plain` (il manifest accetta solo `image/*`), e Google Lens è solo in uscita (`LensIntentLauncher`, "nulla torna indietro"). La stima della finestra conosce solo 47 denominazioni italiane, 8 tipi e una riga generica; tipo e denominazione si risolvono in `resolveWine` con precedenza denominazione dell'utente → tipo (utente, poi catalogo) con denominazione compatibile → denominazione del nome → tipo → generica; il qualificatore (riserva, superiore, gran selezione) cambia gli scostamenti solo se la riga lo prevede. "Consigliato fino al" è `window.endYear` mostrato da `IdealMomentCard` (`uxIdealUntil`) e letto anche dal cruscotto (`DrinkSoonRow.endYear`).
- **Risks / follow-up**: (1) un "Livello" e un "Consigliato fino al" manuale devono sopravvivere a `saveEdit`, `EstimateRefresher` e `recomputeAdjustment`, che riscrivono `baseWindow`/`window`; (2) ogni nuovo campo del documento vino va aggiunto a `WineFields`, `wineFields()`, ai validatori delle regole, ai test `u4.rules.test.mjs`, a una nuova versione di `compat/app-writes.json` e a `RULES_FEATURES`, e le regole vanno pubblicate prima della build; (3) il pacchetto `estimation` deve restare senza dipendenze e con tabelle `const` coperte da `tables_test.dart` (un test per riga); le nuove righe estere o per vitigno passano dal riconoscitore a parole intere (alias normalizzati, prefisso esaminato di 60 caratteri); (4) le scelte enologiche (finestre, scostamenti del livello) si decidono in autonomia con motivazione, secondo la correzione di `project.md`; (5) i testi nuovi vanno negli ARB it, en, pt-BR; (6) la parte "etichetta e catalogo" della base di conoscenza precedente descriveva u6 (una foto, `matchLabelText`): il working tree ha già fronte e retro, base offline, "Cerca online" e Google Lens, ora descritti negli artefatti aggiornati.
