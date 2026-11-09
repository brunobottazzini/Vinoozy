# Scansione del codice — intent 261108-wine-style-profiles

Scansione mirata (focused) del repository Vinoozy, profondità Standard, commit `baba94713f99e2430ecbabec23237b61652a288e` con le modifiche non committate del working tree. Lo sviluppatore lavora da solo (collaboratori spenti): questa consegna è anche la base della sintesi dei nove artefatti.

## Developer Code Scan Results

### Scan Coverage
- **Analyzed deeply**:
  - packages/estimation/lib/
  - lib/cellar/domain/wine.dart
  - lib/cellar/domain/wine_draft.dart
  - lib/cellar/domain/wine_validator.dart
  - lib/cellar/domain/window_adjuster.dart
  - lib/cellar/domain/window_override.dart
  - lib/cellar/domain/wine_estimate.dart
  - lib/cellar/data/wine_repository.dart
  - lib/cellar/data/firestore_codec.dart
  - lib/cellar/estimates_migration.dart
  - lib/cellar/estimate_refresher.dart
  - lib/cellar/wine_estimator.dart
  - lib/cellar/cellar_actions.dart
  - lib/cellar/ui/add_wine_screen.dart
  - lib/cellar/ui/edit_wine_screen.dart
  - lib/cellar/ui/wine_level_selector.dart
  - lib/cellar/ui/level_section.dart
  - lib/cellar/ui/ideal_moment_card.dart
  - lib/cellar/ui/window_override_widgets.dart
  - lib/cellar/ui/wine_card.dart
  - lib/cellar/ui/cellar_screen.dart
  - lib/cellar/ui/wine_labels.dart
  - lib/cellar/ui/wine_badges.dart
  - lib/cellar/ui/autofill_widgets.dart
  - lib/cellar/ui/wine_detail_screen.dart
  - lib/cellar/ui/window_card.dart
  - lib/dashboard/domain/dashboard_calculator.dart
  - lib/catalog/core/offline/
  - lib/catalog/platform/wine_db_loader.dart
  - lib/label/core/text_autofill.dart
  - lib/label/core/label_merge.dart
  - assets/wine_db/manifest.json
  - assets/wine_db/README.md
  - tool/build_wine_db.dart
  - tool/build_appellations.dart
  - firestore.rules
- **Skimmed only**:
  - lib/cellar/domain/wine_origins.dart (solo `guess` e `_denominationOrigin`)
  - lib/cellar/domain/cellar_filter.dart (solo `TypeFilter`)
  - lib/cellar/cellar_providers.dart (solo il cablaggio di `EstimatesMigration`)
  - lib/catalog/core/internal_catalog.dart (solo `catalogTypeOf`)
  - lib/catalog/core/wine_catalog.dart (solo `CatalogWineType`)
  - packages/estimation/test/ e test/cellar/, test/tool/, test/catalog/offline/ (solo nomi dei file e numero dei test)
  - tool/data/appellations/ (solo i nomi dei CSV)
  - assets/wine_db/wines.jsonl.gz (conteggio dei campi presenti, nessuna modifica)
- **Left out**:
  - build/, .dart_tool/, android/.gradle/ (output di compilazione e cache)
  - .claude/, aidlc/ (installazione di AI-DLC)
  - config/firebase_prod.json, android/app/google-services.json (esclusi per istruzione)

### Packages Found
- `estimation` — pacchetto Dart puro — Dart — stima della finestra, tabelle delle denominazioni, vitigni, livello, analisi del testo dell'etichetta
- `vinoozy` (app) — app Flutter — Dart — cantina, form, catalogo, dashboard, migrazione delle stime
- `tool/` — script Dart di generazione — Dart — `build_appellations.dart` (tabella generata), `build_wine_db.dart` (DB offline)

### Build System
- **Type**: Flutter/Dart pub (pacchetto locale `packages/estimation` per path)
- **Config Files**: pubspec.yaml, packages/estimation/pubspec.yaml, analysis_options.yaml, firebase.json, firestore.rules
- **Build Dependencies**: app → estimation; tool/build_appellations.dart → estimation + `WineOrigins` dell'app; tool/build_wine_db.dart → estimation (`recognizeDenomination`) + `WineDbRecord` dell'app

### APIs Discovered
- API Dart C2 — packages/estimation/lib/estimation.dart — `estimateWindow`, `needsRefinement`, `statusOf`, `pairingsFor`, `effectiveWindow`, `extractLabelFields`/`analyzeLabelText`, `appellations`/`findAppellation`/`appellationOf`, `WineType.tryParse`, `WineLevel.tryParse`, `estimationTablesVersion`
- Documento Firestore C3 — `cellars/{cellarId}/wines/{wineId}` — 18 campi ammessi da `wineFields()` in firestore.rules
- `WineRepository` — `addWine`, `updateWine`, `setEstimate`, `setOverride`, `clearOverride`

### Frameworks & Libraries
- Flutter / Dart 3 (pattern `?` nelle mappe e `case final x?`) — UI e logica
- cloud_firestore — persistenza del vino
- shared_preferences — contatore dei tentativi della migrazione (`estimates.migration.v<n>`)
- flutter_riverpod — cablaggio (`estimatesMigrationProvider`)

### Test Coverage
- **Test Directories**: packages/estimation/test/, test/cellar/, test/cellar/ui/, test/cellar/data/, test/catalog/offline/, test/tool/
- **Test Frameworks**: package:test, flutter_test
- **Coverage Config**: presente (tool/check_coverage.sh, soglia 80% senza esclusioni da team.md)
- Numero di test vicini all'intent: tables 19, window 28, world_estimate 33, appellations 11, label_fields 32, recognizer 25, models 19 (pacchetto); estimates_migration 17, estimate_refresher 6, level_override 15, level_override_screens 14, level_choice 6, wine_repository_level 7, build_wine_db 17, wine_db_record 12 (app), più build_appellations_test.dart

### Code Quality Indicators
- **Linting**: flutter_lints in analysis_options.yaml; tool/check_estimation_purity.sh (pacchetto senza Flutter)
- **CI/CD**: .github/workflows/ (non riaperti), tool/check_appellations_release.sh, tool/check_wine_db_release.sh
- **Documentation**: commenti di riga ricchi di riferimenti a BR/FR/NFR; motivazioni enologiche accanto a ogni tabella

### Technical Debt Signals
- La mappatura famiglia ↔ tipo è ripetuta in tre punti (`TypeFilter.of`, `DashboardCalculator.familyOf`, `WineTypeFamily.of`) più `catalogTypeOf` al contrario.
- Il passaggio dal tipo a 8 valori al `CatalogWineType` a 5 famiglie e ritorno (`wineFamilyOf` → `WineType.tryParse`) perde informazione: rosso → `redStructured`, spumante → `sparklingClassic`, fortificato → `sweet`.
- Il default del generatore per il rosso è `redLight`, quello di `WineType.tryParse('red')` è `redStructured`: due default opposti.
- 1582 righe generate su 1700 hanno i tipi di ripiego `redLight,white,rose` (nessuna informazione dal registro né dal nome).
- La stima ha sempre un ripiego (`generic`): oggi non esiste "nessuna stima se lo stile non è chiaro".
- La finestra è in anni interi (regole: `startYear`/`endYear` interi 1900..2200), senza mesi né data di sboccatura o imbottigliamento.

## Handoff Summary
- **Intent-relevant finding**: il tipo salvato (`wineType`, stringa libera non controllata dalle regole) è deciso solo nel form (selettore `WineTypeField`, analisi dell'etichetta `_type`/`typeFor` in `label_fields.dart`/`label_candidates.dart`, proposta del catalogo via `wineFamilyOf`), mai dalla denominazione scritta a mano; la stima invece deduce il tipo internamente (`resolveWine`, `ResolvedWine.effectiveType`) senza salvarlo. Il livello è suggerito solo come `aging` da un qualificativo (`agingQualifiers`, `LevelChoice.suggestionFor`); `everyday` non viene mai suggerito. La migrazione (`EstimatesMigration`, innescata alzando `estimationTablesVersion`, oggi 2) ricalcola solo le finestre `internalRules` e non riscrive mai `wineType` né `level`.
- **Risks / follow-up**: ogni nuovo campo del vino (stile, data di sboccatura o imbottigliamento, mesi) va aggiunto a `wineFields()` e ai validatori di firestore.rules e distribuito prima della build, altrimenti la migrazione si ferma con `permissionDenied` (3 avvii al massimo per versione). Il DB offline (15.616 vini) ha tipo nel 47% dei record, denominazione nell'8%, nessun vitigno, nessun livello, nessuna regione.
