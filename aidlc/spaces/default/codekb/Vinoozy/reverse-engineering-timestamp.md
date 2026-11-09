# Reverse Engineering Timestamp

## Run Record

- Date: 2026-11-08
- Commit: baba94713f99e2430ecbabec23237b61652a288e

Prima scansione (intent 261107-pending-banner-fix): profondità Minimal, mirata al percorso dello stato di sincronizzazione delle bevute (u4-cellar NFR6.6).

Seconda scansione (intent 261107-ux-redesign, stessa data e commit): profondità Minimal, mirata alla superficie dell'interfaccia (form di aggiunta e modifica, regione e denominazione, flusso "Bevuta", tema, localizzazione).

Terza scansione (intent 261107-label-recognition, 2026-11-07, stesso commit, working tree con le modifiche non committate di pending-banner-fix e ux-redesign): profondità Standard, mirata alla superficie del riconoscimento dell'etichetta e del catalogo.

Quarta scansione (intent 261108-label-autofill-windows, 2026-11-08, commit `0d99791d02005b8a90a78d17ec57cc994c820cf2`, working tree con le modifiche non committate di ux-redesign e label-recognition): profondità Standard, mirata alla stima della finestra di consumo (`packages/estimation/lib/`), ai campi del vino e al loro percorso di salvataggio e stima in `lib/cellar/` (modello, bozza, validatore, origini, riscontro delle bevute, stimatore, aggiornamento col catalogo, azioni, repository, form di aggiunta e modifica, "Momento ideale"), alla sezione dei vini di `firestore.rules`, e al flusso dal testo dell'etichetta al form (`label_merge`, `label_lookup_flow`, `label_line_picker`, `vintage_parser`, contratto `WineCatalog` e `matchLabel`, Google Lens). Al momento di questa scansione l'archivio precedente risultava superato (i file dell'etichetta e del catalogo erano cambiati con le modifiche non committate di label-recognition): la prosa precedente è conservata, corretta o segnata come storica dove il codice attuale la smentisce; le coperture profonde della terza scansione sono registrate come superficiali.

Quinta scansione (intent 261108-wine-style-profiles, 2026-11-08, commit `baba94713f99e2430ecbabec23237b61652a288e`, working tree con le modifiche non committate del marchio, cioè splash, piè di pagina e localizzazione, fuori dall'area analizzata): profondità Standard, mirata a dove si decidono, si salvano e si mostrano tipo, livello, stile e finestra di consumo. Comprende il motore e le tabelle di `packages/estimation/lib/` (tabelle italiane, del mondo e generate, modelli, vitigni, livello, qualificativi, stato, finestra effettiva, analisi del testo dell'etichetta), il modello del vino e la sua forma in Firestore (`wine.dart`, `wine_draft.dart`, `wine_validator.dart`, `window_adjuster.dart`, `window_override.dart`, `wine_estimate.dart`, `wine_repository.dart`, `firestore_codec.dart`, `firestore.rules`), la migrazione e il ricalcolo delle stime (`estimates_migration.dart`, `estimate_refresher.dart`, `wine_estimator.dart`, `cellar_actions.dart`), l'interfaccia che mostra o modifica tipo, livello e finestra (form, selettore e sezione del livello, "Momento ideale", correzione, scheda, lista, badge, dettaglio, calcolo del cruscotto), la base dei vini sul telefono (`lib/catalog/core/offline/`, il caricatore, manifest e README di `assets/wine_db/`, `tool/build_wine_db.dart`) e il generatore delle denominazioni (`tool/build_appellations.dart`). L'archivio precedente risultava superato (i file della stima, dei campi del vino, dell'etichetta e del catalogo erano cambiati con il commit `baba947`): la prosa precedente è conservata e, dove il codice attuale la smentisce, segnata come storica; le coperture profonde della quarta scansione che questa non ha riletto sono registrate come superficiali.

## Scope of Analysis

```yaml
scope_version: 1
kind: partial
intent: wine-style-profiles
fingerprint: 3f66d6ae8b714b145433ed2ebd57934284fcb81e
analyzed:
  paths:
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
  components:
    - estimateWindow
    - resolveWine
    - denominationTable
    - typeTable
    - Wine
    - WineDraft
    - WineValidator
    - WindowAdjuster
    - WineEstimate
    - WineEstimator
    - EstimateRefresher
    - CellarActions
    - WineRepository
    - AddWineScreen
    - WineTypeField
    - EditWineScreen
    - WineDetailScreen
    - IdealMomentCard
    - WineSecurityRules
    - OfflineWineDb
    - WineType
    - WineLevel
    - agingQualifiers
    - grapeTable
    - appellationTemplates
    - extractLabelFields
    - LevelChoice
    - LevelSection
    - WineLevelSelector
    - WineTypeFamily
    - DashboardCalculator
    - EstimatesMigration
    - WineDbRecord
    - buildWineDb
    - buildAppellations
shallow:
  paths:
    - packages/estimation/pubspec.yaml
    - lib/cellar/domain/wine_origins.dart
    - lib/label/core/label_lookup_flow.dart
    - lib/label/core/label_line_picker.dart
    - lib/label/core/vintage_parser.dart
    - lib/label/core/label_reading.dart
    - lib/label/core/lens_launcher.dart
    - lib/label/ui/label_capture_flow.dart
    - lib/catalog/core/wine_catalog.dart
    - lib/catalog/core/catalog_coordinator.dart
    - android/app/src/main/kotlin/com/vinoozy/vinoozy/LensIntentLauncher.kt
    - tool/check_off_config.sh
    - lib/label/
    - lib/catalog/
    - android/app/src/main/kotlin/
    - test/label/
    - test/catalog/
    - integration_test/label_test.dart
    - lib/label/ui/label_reading_screen.dart
    - lib/label/ui/not_found_view.dart
    - lib/label/ui/add_choice_screen.dart
    - lib/label/ui/label_proposal_sheet.dart
    - lib/label/ui/online_search_screen.dart
    - lib/label/label_providers.dart
    - lib/label/core/label_session.dart
    - lib/catalog/core/internal_catalog.dart
    - android/app/src/main/kotlin/com/vinoozy/vinoozy/MainActivity.kt
    - packages/estimation/test/
    - packages/estimation/README.md
    - test/rules/
    - test/cellar/
    - assets/wine_db/
    - lib/l10n/
    - lib/dashboard/
    - lib/sync/sync_status.dart
    - lib/cellar/data/drinking_record_repository.dart
    - lib/cellar/data/pending_writes_probe.dart
    - lib/app/providers.dart
    - lib/app/bootstrap.dart
    - test/cellar/data/pending_writes_probe_test.dart
    - test/cellar/data/drinking_record_repository_test.dart
    - test/u1/sync/sync_status_test.dart
    - test/cellar/cellar_providers_test.dart
    - integration_test/cellar_test.dart
    - lib/cellar/ui/drink_flow.dart
    - lib/cellar/ui/drink_snack_bar.dart
    - lib/cellar/ui/wine_list_tile.dart
    - lib/cellar/ui/quantity_stepper.dart
    - lib/app/theme.dart
    - lib/app/locale_resolution.dart
    - lib/dashboard/ui/status_icons.dart
    - lib/
    - lib/cellar/ui/
    - lib/cellar/domain/
    - lib/cellar/cellar_providers.dart
    - lib/app/
    - lib/dashboard/ui/
    - test/
    - integration_test/
    - integration_test/support/
    - packages/estimation/
    - docs/account-deletion/
    - docs/release-checklist.md
    - docs/firebase-setup.md
    - .github/workflows/
    - tool/
    - android/
    - android/app/src/main/AndroidManifest.xml
    - android/app/build.gradle.kts
    - android/app/src/test/kotlin/
    - assets/
    - pubspec.yaml
    - pubspec.lock
    - package.json
    - analysis_options.yaml
    - firebase.json
    - lib/cellar/domain/cellar_filter.dart
    - test/tool/
    - test/catalog/offline/
    - tool/data/appellations/
    - assets/wine_db/wines.jsonl.gz
```
