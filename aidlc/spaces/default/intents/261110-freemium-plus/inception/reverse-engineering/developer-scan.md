# Scansione del codice — Vinoozy (intent 261110-freemium-plus)

Scansione completa del repository alla radice del workspace (`./`), commit di
riferimento `ee114e34ecdb2ec0dff873d20ad23d0004996947`, con un albero di lavoro
che contiene molte modifiche non ancora committate (36 file modificati, tra cui
`lib/account/ui/profile_screen.dart`, `lib/account/account_providers.dart`,
`lib/cellar/cellar_providers.dart`, `MainActivity.kt`, i workflow CI, l10n e
test; più file nuovi come `lib/app/external_links.dart`, `docs/privacy/`,
`distribution/`, `tool/check_publication.mjs`). La scansione legge i file così
come sono su disco. Nessun test, build o programma del progetto è stato
eseguito.

## Developer Code Scan Results

### Scan Coverage
- **Analyzed deeply**:
  - `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`, `dart_test.yaml`, `firebase.json`, `firestore.indexes.json`, `package.json`, `.gitignore`, `README.md`
  - `firestore.rules` (struttura completa: funzioni comuni, `users`, `cellars`, `wines`, `drinkingRecords`, `members`, collection group)
  - `lib/main.dart`
  - `lib/firebase/` (`firebase_env.dart`, `options_demo.dart`, `options_prod.dart`, `firestore_bootstrap.dart`)
  - `lib/app/` (`bootstrap.dart`, `providers.dart`, `home_shell.dart`, `ui/about_screen.dart`, `ui/brand_footer.dart`, `external_links.dart`)
  - `lib/account/` (`account_gate.dart`, `account_providers.dart`, `data/user_repository.dart`, `ui/profile_screen.dart`, deletion: firme pubbliche)
  - `lib/cellar/data/` (`wine_repository.dart`, `drinking_record_repository.dart`, `server_or_cache.dart`, `firestore_codec.dart`, firme di `cellar_repository.dart`, `record_reconciler.dart`, `match_key_backfill.dart`, `pending_writes_probe.dart`)
  - `lib/cellar/cellar_actions.dart`, `lib/cellar/cellar_providers.dart`, `lib/cellar/domain/quantity.dart`, `lib/cellar/domain/quantity_delta.dart`, `lib/cellar/domain/wine.dart` (campi), `lib/cellar/ui/cellar_screen.dart` (menu e FAB)
  - `lib/sync/` (`sync_gateway.dart`, `sync_watcher.dart`, `ledger/local_ledger.dart`, firme di `sync_error_bus.dart`, `sync_status.dart`)
  - `lib/sharing/` (`data/sharing_repository.dart` invito e listener, `domain/membership.dart` `AccessibleCellar`/`CellarRole`, `domain/invite_validator.dart` limiti)
  - `lib/dashboard/` (`dashboard_providers.dart`, `ui/dashboard_screen.dart`)
  - `tool/check_release_build.sh`, `tool/verify_skeleton.sh`, intestazioni di tutti gli script in `tool/`
  - `.github/workflows/ci.yml`, `release.yml` (intero), schema di `promote.yml`, `pages.yml`, `firebase-deploy.yml`
  - `test/rules/run-tests.mjs`, `test/rules/package.json`
  - `packages/estimation/pubspec.yaml`, `packages/estimation/lib/estimation.dart` (API esportata)
  - `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml` (permessi, filtri), canali di `MainActivity.kt`
  - `docs/vinoozy-studio-monetizzazione.md` sezioni 4, 5, 7, 9 (specifica dell'intent)
- **Skimmed only**:
  - `lib/label/` e `lib/catalog/` (solo dichiarazioni di classi, provider e confini)
  - `lib/cellar/ui/`, `lib/cellar/domain/` (escluso quanto sopra), `lib/cellar/estimate_refresher.dart`, `lib/cellar/estimates_migration.dart`, `lib/cellar/wine_estimator.dart`
  - `lib/account/deletion/`, `lib/account/ui/` (escluso `profile_screen.dart`), `lib/sharing/ui/`, `lib/sync/ui/`, `lib/dashboard/domain/`, `lib/dashboard/ui/` (escluso `dashboard_screen.dart`), `lib/e2e/`, `lib/core/`
  - `lib/l10n/` (ARB: 611 chiavi per it/en/pt_BR; file `app_localizations*.dart` generati)
  - `packages/estimation/lib/src/`, `packages/estimation/test/`, `packages/estimation/benchmark/`
  - `test/`, `integration_test/`, `integration_test_perf/`, `test_driver/`, `benchmark/`
  - `tool/*.dart`, `tool/*.mjs`, `tool/convert_study.py`, `tool/data/`, `tool/fixtures/`
  - `android/app/src/main/kotlin/`, `android/app/src/test/`, `android/app/src/main/res/`
  - `docs/` (titoli), `distribution/google-play/` (elenco), `.github/dependabot.yml`
- **Left out**:
  - `build/`
  - `.dart_tool/`
  - `coverage/`
  - `node_modules/`
  - `.idea/`, `vinoozy.iml`, `.DS_Store`, `.swp`
  - `.cache/`
  - `android/.gradle/`, `android/gradle/wrapper/gradle-wrapper.jar`
  - `assets/wine_db/wines.jsonl.gz` e le immagini binarie in `assets/`, `distribution/`, `android/app/src/main/res/mipmap-*`
  - `firestore-debug.log`
  - `.flutter-plugins-dependencies`
  - `docs/account-deletion/app.bundle.js` (bundle generato da `tool/build_web_bundle.sh`)
  - installazione AI-DLC: `.claude/`, `aidlc/`, `aidlc.settings*.json`, sezione AI-DLC di `.gitignore`, `.mcp.json`

### Packages Found
- `vinoozy` — app Flutter (Android) — Dart 3.13 — cantina personale e condivisa, offline-first su Firestore
- `estimation` (`packages/estimation/`) — libreria Dart pura (path dependency) — Dart — finestre di consumo, stato, abbinamenti, classificazione, analisi testo etichetta; nessuna dipendenza di produzione
- `vinoozy-tooling` (`package.json`) — strumenti Node pinnati — JavaScript — Firebase Emulator Suite, test delle regole, pagina web di cancellazione account, controllo di pubblicazione
- `vinoozy-rules-tests` (`test/rules/package.json`) — runner dei test delle regole — JavaScript (`node --test`)
- App Android nativa (`android/app/src/main/kotlin/com/vinoozy/vinoozy/`) — Kotlin — preparazione foto etichetta, condivisione immagini/testo, Google Lens, apertura link

### Build System
- **Type**: Flutter (pub) + Gradle Kotlin DSL per Android; npm per gli strumenti Node
- **Config Files**: `pubspec.yaml`, `pubspec.lock`, `l10n.yaml`, `analysis_options.yaml`, `dart_test.yaml`, `android/app/build.gradle.kts`, `android/build.gradle.kts`, `android/settings.gradle.kts`, `android/gradle.properties`, `package.json`, `package-lock.json`, `firebase.json`, `.firebaserc`, `.flutter-version` (3.47.9), `.nvmrc` (22)
- **Build Dependencies**: `vinoozy` → `estimation` (path); `vinoozy` → plugin FlutterFire; build Android → Flutter Gradle Plugin + JaCoCo (copertura classi native label); `tool/check_release_build.sh` → `flutter build appbundle` con `--dart-define`

### APIs Discovered
- Firestore (client SDK, nessun backend) — `firestore.rules` — collezioni `users/{uid}`, `cellars/{cellarId}`, `cellars/{id}/wines/{wineId}`, `cellars/{id}/drinkingRecords/{recordId}`, `cellars/{id}/members/{email}`, collection group `members`; ~30 funzioni di validazione
- Firebase Auth — `lib/account/google_auth_service.dart` — solo provider `google.com`
- Firebase App Check — `lib/app/bootstrap.dart` — Play Integrity in release, debug provider in debug, disattivato su emulatori
- Open Food Facts HTTP — `lib/catalog/core/off/open_food_facts_source.dart` — ricerca e prodotto, con budget e circuit breaker
- Method channel Android — `com.vinoozy.app/label`, `vinoozy/lens`, `com.vinoozy.app/links` (nuovo, non committato)
- Provider Riverpod come API interna: ~70 provider (`lib/app/providers.dart`, `lib/cellar/cellar_providers.dart`, `lib/sharing/sharing_providers.dart`, `lib/dashboard/dashboard_providers.dart`, `lib/label/*_providers.dart`, `lib/catalog/platform/catalog_providers.dart`)
- Nessuna Cloud Function, nessun endpoint server, nessun SDK di Billing o pubblicità

### Frameworks & Libraries
- Flutter — 3.47.9 (`.flutter-version`) — UI
- flutter_riverpod — 3.4.3 — stato e iniezione delle dipendenze
- cloud_firestore — 7.1.0 — persistenza offline e sincronizzazione
- firebase_core 5.1.0, firebase_auth 7.0.1, firebase_app_check 0.5.1, firebase_crashlytics 6.0.1 — piattaforma Firebase
- google_sign_in — 7.2.0 — login Google
- google_mlkit_text_recognition 1.0.0, google_mlkit_barcode_scanning 1.0.0 — lettura etichetta sul telefono
- shared_preferences 2.5.6 — ledger locale, flag e preferenze
- connectivity_plus 7.3.2, http 1.6.0, image_picker 1.2.4, share_plus 13.3.1, package_info_plus 10.2.2, path_provider 2.1.6, intl 0.20.3, crypto 3.0.8
- Dev: flutter_test, integration_test, flutter_driver, flutter_lints 6.0.0, mocktail 1.0.5
- Node dev: firebase-tools 14.27.0, @firebase/rules-unit-testing 6.0.0, firebase 13.2.0, c8 12.0.0, esbuild 0.28.2, playwright 1.65.0
- Android: exifinterface 1.4.2, Robolectric 4.17, JUnit 4.13.2, JaCoCo 0.8.14

### Test Coverage
- **Test Directories**: `test/` (154 file `_test.dart`, per modulo: `account`, `app`, `catalog`, `cellar`, `dashboard`, `label`, `sharing`, `tool`, `u1`, `helpers`), `test/rules/` (test regole `.mjs`), `test/web/` (pagina cancellazione), `integration_test/` (13 test E2E su emulatore Android + Firebase Emulator Suite), `integration_test_perf/`, `test_driver/`, `packages/estimation/test/` (22 file), `android/app/src/test/` (Robolectric)
- **Test Frameworks**: flutter_test + mocktail; integration_test; `node --test` + @firebase/rules-unit-testing; c8; playwright; package:test (estimation); JUnit + Robolectric
- **Coverage Config**: presente — `tool/gen_coverage_helper.dart` + `tool/check_coverage.sh 80` (totale e per cartella `lib/catalog/`, `lib/dashboard/`, `lib/sharing/`, `lib/cellar/`, `lib/label/`, `lib/account/`), JaCoCo 80% per due classi native, c8 80% per `account-deletion.js`

### Code Quality Indicators
- **Linting**: `flutter_lints` via `analysis_options.yaml`, `flutter analyze --fatal-infos`, `dart format --set-exit-if-changed`; `packages/estimation/analysis_options.yaml`
- **CI/CD**: `.github/workflows/ci.yml` (format, secrets/gitleaks, analyze + gate script, unit + coverage + benchmark + Gradle + `check_release_build.sh`, estimation, rules + web, e2e), `release.yml` (AAB firmato su canale interno dopo CI verde su `main`), `promote.yml` (produzione manuale), `pages.yml` (GitHub Pages manuale), `firebase-deploy.yml` (regole e indici con approvazione); `dependabot.yml`
- **Documentation**: `README.md` in italiano; commenti di codice in inglese densi e tracciati a ID di requisito (BR/NFR/FR); `docs/firebase-setup.md`, `docs/release-checklist.md`, checklist di pubblicazione, studio di monetizzazione

### Technical Debt Signals
- `test/rules/style_profiles.rules.test.mjs` esiste ma non compare nell'elenco esplicito di `npm run test:rules` (`package.json`), unico elenco usato da `ci.yml` e `firebase-deploy.yml`: in CI non gira.
- `tool/check_release_build.sh` conosce solo i marker `EmulatorGoogleAuthService`, `VINOOZY_DASHBOARD_READY`, `VINOOZY_E2E_LOCALE`; non esiste ancora un perimetro per i cheat di sviluppo richiesto dalla sezione 9.5 dello studio.
- File molto lunghi: `lib/cellar/ui/add_wine_screen.dart` (1697 righe), `lib/cellar/ui/guided_confirm_sheet.dart` (1130), `lib/cellar/data/wine_repository.dart` (1051), `packages/estimation/lib/src/label_candidates.dart` (2220).
- La quantità dei vini accetta valori negativi sul server per gli incrementi concorrenti (ADR-004 citato in `firestore.rules`): qualunque contatore di "schede attive" deve trattare `quantity <= 0` come scheda non attiva.
- `firestore.rules` è vicino al budget di 1000 espressioni (commenti in `validWineUpdate` e split delle update in `WineRepository.updateWine`): aggiungere controlli di capacità nelle regole dei vini è rischioso.
- Nessun TODO/FIXME nel codice applicativo; una sola soppressione lint (`packages/estimation/lib/src/label_candidates.dart:250`).
- `README.md` documenta `minSdk 24` e `firebase-tools` bloccato a 14.27.0 per JDK 17.
- Molte modifiche non committate nell'albero (vedi intestazione): lo stato documentato non coincide con `ee114e3`.

## Handoff Summary
- **Intent-relevant finding**: Il codice non contiene ancora nulla di freemium, Plus, diritti, misuratore d'uso, Billing o pubblicità (nessuna dipendenza `in_app_purchase`/`google_mobile_ads`, nessun backend o Cloud Function, nessuna collezione `entitlements`/`usage`/`adSlots` in `firestore.rules`). I punti di aggancio indicati dallo studio esistono: `lib/firebase/firebase_env.dart` (`FirebaseEnvConfig.usesEmulators`, `kIsE2EBuild`, `kIsPerfBuild`, `demoProjectId = 'demo-vinoozy'` in `options_demo.dart`); la riga versione con chiave `about-version` in `lib/app/ui/about_screen.dart:67`, oggi un `_Tile` statico senza gesti; il `BrandFooter` della Dashboard (`lib/app/ui/brand_footer.dart:42`) apre la stessa schermata Informazioni e non va usato come trigger; tutte le creazioni di vini passano da `WineRepository.addWine`/`create` (`lib/cellar/data/wine_repository.dart:175`, `:363`), la riattivazione di una scheda archiviata da `addBottles` (`:419`, incremento che porta `quantity` da <=0 a >0), le unioni da `mergeInto` (`:676`), l'archivio è `quantity <= 0` (`fetchArchived`, `:341`) e il listener condiviso `watchCellarWines` filtra `quantity > 0` (`:308`), quindi il numero di schede attive è già calcolabile dal solo listener esistente. La condivisione limita gli invitati a 2 con `InviteValidator.maxInvitees` (`lib/sharing/domain/invite_validator.dart:10`) e `memberSlots <= 2` in `firestore.rules:219`. `AccessibleCellar.isPersonal` distingue la cantina personale dalle condivise. Il controllo di rilascio da estendere è `tool/check_release_build.sh` (marker nell'AOT `libapp.so`, controllo positivo con `E2E=true PERF=true`).
- **Risks / follow-up**: (1) Le scritture sono offline-first (ledger poi batch non atteso): un rifiuto per limite arriva solo come `WriteRejected` su `SyncErrorBus` e marca `rejected` nel ledger solo per le creazioni con `JournalEntry`; la regola 7.1 "conservare la bozza e spiegarne la mancata sincronizzazione" si appoggia a questo canale (`RejectedWineNotices`). (2) I membri `edit` scrivono nella cantina del proprietario (`canEditCellar`), quindi un'invariante di capacità deve valere anche per loro. (3) Ogni modifica di `firestore.rules` deve continuare ad accettare le scritture della versione in produzione (`test/rules/compat/app-writes.json`) e restare sotto il budget di espressioni. (4) Un backend di verifica acquisti/contatori richiede Blaze; oggi il progetto è Spark e il budget è 0 €/mese. (5) `test/rules/style_profiles.rules.test.mjs` non è eseguito in CI. (6) Lo stato non committato va considerato la base reale di partenza.
