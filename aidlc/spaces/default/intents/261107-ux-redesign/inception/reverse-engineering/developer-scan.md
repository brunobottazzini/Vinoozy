# Scansione del codice (sviluppatore) — Vinoozy, intent 261107-ux-redesign

Scansione mirata, profondità Minimal, su archivio CURRENT (intent precedente 261107-pending-banner-fix). Commit di riferimento: `0d99791d02005b8a90a78d17ec57cc994c820cf2`. Nessun test, build o programma eseguito. Lo sviluppatore lavora da solo: questa scansione è anche la base della sintesi dei 9 artefatti nella cartella di staging.

## Developer Code Scan Results

### Scan Coverage
- **Analyzed deeply**:
  - lib/cellar/ui/add_wine_screen.dart
  - lib/cellar/ui/edit_wine_screen.dart
  - lib/cellar/ui/drink_flow.dart
  - lib/cellar/ui/drink_snack_bar.dart
  - lib/cellar/ui/wine_list_tile.dart
  - lib/cellar/ui/wine_detail_screen.dart
  - lib/cellar/ui/wine_labels.dart
  - lib/cellar/ui/quantity_stepper.dart
  - lib/cellar/domain/wine_draft.dart
  - lib/cellar/domain/wine_validator.dart
  - lib/cellar/domain/wine.dart
  - lib/app/theme.dart
  - lib/app/locale_resolution.dart
  - lib/dashboard/ui/status_icons.dart
  - lib/catalog/core/internal_catalog.dart
  - lib/label/ui/label_proposal_sheet.dart
  - (più i 10 percorsi già verificati dall'archivio: lib/sync/sync_status.dart, lib/cellar/data/drinking_record_repository.dart, lib/cellar/data/pending_writes_probe.dart, lib/app/providers.dart, lib/app/bootstrap.dart e i 5 test collegati, non rianalizzati in questa esecuzione)
- **Skimmed only**:
  - lib/cellar/ui/ (cellar_screen.dart righe 360-410, cellar_dialogs.dart, gli altri file solo per elenco)
  - lib/cellar/domain/ (file non elencati sopra)
  - lib/app/ (vinoozy_app.dart, home_shell.dart)
  - lib/l10n/ (chiavi cercate nei 3 ARB; file generati solo contati)
  - lib/catalog/core/ (wine_catalog.dart righe 1-100; open_food_facts_source.dart righe 230-245; catalog_coordinator.dart e catalog_cache_store.dart per ricerca testuale)
  - lib/dashboard/ui/ (struttura e chiavi)
  - lib/label/ui/ (label_reading_screen.dart righe 95-200, label_capture_flow.dart righe 70-100)
  - packages/estimation/lib/src/catalog.dart (fuori dallo snapshot: solo fonte delle regioni)
  - firestore.rules (righe 252-370, elenco campi del vino)
  - pubspec.yaml, assets/
  - test/, integration_test/ (solo nomi e ricerche di chiavi)
- **Left out**:
  - build/, .dart_tool/, android/.gradle/ (output di build e cache)
  - node_modules/
  - config/firebase_prod.json, android/app/google-services.json (vietati dal brief)

### Packages Found
- vinoozy — app Flutter — Dart — app Android della cantina (moduli `lib/<modulo>/{domain,data,ui}`)
- estimation — pacchetto path — Dart puro — stima e catalogo delle 47 denominazioni (C2)

### Build System
- **Type**: Flutter/Dart pub (+ Gradle Android, npm solo per strumenti)
- **Config Files**: pubspec.yaml, l10n.yaml, analysis_options.yaml, package.json
- **Build Dependencies**: vinoozy → estimation (path); `flutter: generate: true` produce `lib/l10n/app_localizations*.dart` (file generati e versionati; CI esegue `flutter gen-l10n`)

### APIs Discovered
- API interne Dart — `lib/cellar/` — `CellarActions.drink` / `undoDrink`, `WineValidator.validate`, `WineDraft.withDetails`, `drinkWithUndo`, `DrinkSnackBar.show/showWith`
- Firestore — `firestore.rules` `wineFields()` — elenco chiuso dei campi del vino: un campo `country` richiederebbe una modifica delle regole

### Frameworks & Libraries
- Flutter 3.47.9 / Dart ^3.13.7 — Material 3 (`useMaterial3: true`)
- flutter_riverpod ^3.4.3 — stato
- intl ^0.20.3, flutter_localizations — it, en, pt-BR
- Nessuna libreria di bandiere, icone extra, font personalizzati o grafici: i grafici del cruscotto sono widget scritti a mano (`lib/dashboard/ui/bar_chart.dart`)

### Test Coverage
- **Test Directories**: test/ (per modulo), integration_test/
- **Test Frameworks**: flutter_test, mocktail, integration_test
- **Coverage Config**: presente (`tool/check_coverage.sh 80`, `test/coverage_helper_test.dart` generato da `tool/gen_coverage_helper.dart`, rigenerato in CI)

### Code Quality Indicators
- **Linting**: flutter_lints (`analysis_options.yaml`), `dart format`
- **CI/CD**: `.github/workflows/ci.yml` (format, analyze, unit, e2e …)
- **Documentation**: commenti di classe legati ai requisiti (BRx, NFRx)

### Technical Debt Signals
- `add_wine_screen.dart:139-141, 177-178, 187-188, 251-252`: `_region` e `_denomination` sono stato del form senza alcun campo di input; si impostano solo da proposta del catalogo, "Aggiungi di nuovo" o etichetta.
- `edit_wine_screen.dart:73-74`: la modifica ricopia regione e denominazione del vino senza poterle cambiare.
- `theme.dart:120-151`: `ColorScheme` piatto (secondary, tertiary, container e tutte le superfici uguali a primary/surface): nessuna gerarchia visiva disponibile ai widget.
- `drink_flow.dart:38`: la bevuta si salva al tocco, senza conferma; l'unica rete di sicurezza è "Annulla" nello SnackBar (6 s / 10 s).
- Stessa icona `Icons.wine_bar` per la scheda "Cantina" (`home_shell.dart:255-256`) e per l'azione "Bevuta" (`wine_list_tile.dart:72`, `wine_detail_screen.dart:252`).

## Handoff Summary
- **Intent-relevant finding**:
  1. Regione: il modello (`Wine.region`, `WineInput.region`, `WineDraft.region`, `WineFields.region`, regole Firestore `validOptionalText` ≤ 120) la prevede come testo libero opzionale, ma il form `AddWineScreen` non ha alcun campo regione né denominazione (`add_wine_screen.dart:376-481`): si imposta solo scegliendo una proposta della denominazione interna (`internal_catalog.dart:147-162`, 47 denominazioni, 13 regioni tutte italiane) o di Open Food Facts (`origins`), mai dalle proposte "dalla cantina" (`internal_catalog.dart:136-143` non copia la regione). Il paese non esiste da nessuna parte nel modello né nelle regole (`firestore.rules:257-260`).
  2. Bevuta: `WineListTile` (icona `wine_bar`, chiave `wine-tile-drink-<id>`) e `WineDetailScreen._QuantityRow` (`FilledButton.icon` "Bevuta", chiave `wine-drink`) chiamano `drinkWithUndo` (`drink_flow.dart:19`), che salva subito (`CellarActions.drink`) e poi mostra `DrinkSnackBar` con "Annulla" e "Aggiungi voto e note". In italiano l'etichetta è il sostantivo "Bevuta"; accanto c'è il "−" (`wine-minus`) che toglie una bottiglia senza registrare la bevuta.
  3. Grafica: tema da soli 5 token per tema (`AppColors`) più `StatusColors`; nessuna risorsa grafica oltre all'icona dell'app (`assets/icon/`, non dichiarata in `pubspec.yaml`), nessun font, nessuna dipendenza per bandiere.
- **Risks / follow-up**:
  - Un campo `country` strutturato tocca dominio, repository, `firestore.rules` (lista `wineFields()` e validazione), test delle regole, stima (`WineFactsInput`), cruscotto (grafico per regione su testo normalizzato) e catalogo.
  - Chiavi di test da preservare o aggiornare: `add-wine-*`, `wine-drink`, `wine-tile-drink-<id>`, `drink-snackbar`, `drink-undo`, `drink-add-notes`; l'e2e `integration_test/cellar_test.dart:28-31` trova "Bevuta" per `Icons.wine_bar`.
  - Ogni schermata ha una matrice di accessibilità (3 lingue × testo 1.0/2.0 × chiaro/scuro) con contrasto, aree di tocco ed etichette: un'interfaccia più grafica deve continuare a passarla; `test/app/status_colors_test.dart` verifica i contrasti dei token.
  - Ogni nuovo testo va nei 3 ARB (316 chiavi ciascuno); nuovi file in `lib/` richiedono di rigenerare `test/coverage_helper_test.dart`; la copertura dell'80% conta anche i file generati.
  - Il working tree contiene modifiche non committate dell'intent 261107-pending-banner-fix su `drinking_record_repository.dart` e `pending_writes_probe.dart` (non toccate da questa scansione).
