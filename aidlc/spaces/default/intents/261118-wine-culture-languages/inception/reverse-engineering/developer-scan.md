## Developer Code Scan Results

Scansione completa del repository `Vinoozy` (commit `6f76475a278e6351ce63454b719aeca5a37b0cfd`), ampiezza "Full rescan", profondità Minimal. Solo lettura: nessun test, build o programma del progetto è stato eseguito. La rilevazione iniziale del workspace ("Languages: Unknown, Build System: npm") è sbagliata: il progetto è un'app Flutter/Dart per Android con Firebase; npm serve solo agli strumenti (emulatori, test delle regole, pagina web) e alle Cloud Functions.

### Scan Coverage
- **Analyzed deeply**:
  - `lib/l10n/` (quattro ARB, quattro file generati: struttura, chiavi, plurali, delegate, lookup)
  - `l10n.yaml`
  - `lib/app/locale_resolution.dart`
  - `lib/app/vinoozy_app.dart`
  - `lib/app/bootstrap.dart`
  - `lib/app/external_links.dart`
  - `lib/app/ui/country_flag.dart`
  - `lib/main.dart`
  - `lib/e2e/e2e_locale.dart`
  - `lib/cellar/domain/wine_origins.dart`
  - `lib/cellar/ui/wine_labels.dart`
  - `lib/catalog/core/wine_catalog.dart` (tipi del contratto C1, `CatalogLocale`)
  - `packages/estimation/lib/estimation.dart`
  - `packages/estimation/lib/src/country_names.dart`
  - `functions/src/index.ts`
  - `test/helpers/ui_harness.dart`
  - `test/app/e2e_locale_test.dart`
  - `tool/gen_coverage_helper.dart`
  - `tool/check_coverage.sh`
  - `tool/check_publication.mjs`
  - `.github/workflows/ci.yml`
  - `distribution/google-play/README.md`
  - `pubspec.yaml`, `packages/estimation/pubspec.yaml`, `package.json`, `functions/package.json`, `firebase.json`, `analysis_options.yaml`, `dart_test.yaml`, `README.md`, `.gitignore`, `.flutter-version`, `.nvmrc`
- **Skimmed only** (elenco dei file, commenti di testata, ricerche mirate su lingua, formati e testi):
  - `lib/account/`, `lib/ads/`, `lib/app/` (resto), `lib/catalog/` (resto), `lib/cellar/` (resto), `lib/core/`, `lib/dashboard/`, `lib/dev/`, `lib/firebase/`, `lib/label/`, `lib/plan/`, `lib/sharing/`, `lib/sync/`, `lib/usage/`
  - `packages/estimation/lib/src/` (resto), `packages/estimation/test/`, `packages/estimation/benchmark/`
  - `functions/src/` (resto), `functions/test/`
  - `android/` (Gradle, manifest, sorgenti Kotlin e relativi test)
  - `test/`, `integration_test/`, `integration_test_perf/`, `test_driver/`, `benchmark/`
  - `tool/` (resto, compresi `tool/admin/`, `tool/data/`, `tool/fixtures/`)
  - `docs/` (guide e pagine web statiche `privacy/`, `account-deletion/`)
  - `distribution/google-play/` (testi per lingua, note di rilascio, catture)
  - `assets/`
  - `firestore.rules`, `firestore.indexes.json`
  - `.github/workflows/` (`release.yml`, `promote.yml`, `pages.yml`, `firebase-deploy.yml`, `functions-deploy.yml`), `.github/dependabot.yml`
  - `pubspec.lock`
- **Left out**:
  - `build/`
  - `coverage/`, `packages/estimation/coverage/`
  - `.dart_tool/`, `packages/estimation/.dart_tool/`
  - `node_modules/`, `functions/node_modules/`, `tool/admin/node_modules/`
  - `functions/lib/` (output di `tsc`)
  - `.idea/`, `.cache/`
  - `android/.gradle/`, `android/.kotlin/`, `android/captures/`
  - file ignorati da `.gitignore` e non aperti: `config/firebase_prod.json`, `android/app/google-services.json`, `android/local.properties`, `firestore-debug.log`, `.flutter-plugins-dependencies`, `*.iml`, `.DS_Store`
  - `package-lock.json`, `functions/package-lock.json`, `tool/admin/package-lock.json` (lockfile, non aperti)
  - installazione di AI-DLC (`.claude/`, workspace `aidlc/`, `aidlc.settings*.json`, `.mcp.json`, blocco AI-DLC di `.gitignore`)

### Packages Found
- `vinoozy` (radice, `lib/`) — applicazione — Dart/Flutter — app Android della cantina: account, cantina, catalogo, etichetta, cruscotto, condivisione, sincronizzazione, piano Plus, annunci, misura d'uso
- `estimation` (`packages/estimation/`) — libreria — Dart puro, nessuna dipendenza di produzione — stima della finestra di consumo, stato, abbinamenti, tabelle di denominazioni e vitigni, lettura dei testi d'etichetta (contratto C2)
- `vinoozy-functions` (`functions/`) — servizio — TypeScript, Node 22 — Cloud Functions 2nd gen in `europe-west8`: acquisti Plus, notifiche Play, misura d'uso, slot annunci, guardia del budget, pulizia account
- `vinoozy-tooling` (`package.json` radice) — strumenti — Node 22 — emulatori Firebase, test delle regole, test e bundle della pagina di cancellazione account
- `tool/admin/` — strumenti — Node (`.mjs`) — script del proprietario: `grant_plus`, `set_policy`, `migrate_capacity`
- `android/` — host nativo — Kotlin, Gradle Kotlin DSL — `MainActivity`, preparazione immagini etichetta, lancio di Google Lens, ricezione di immagini e testi condivisi
- `docs/account-deletion/`, `docs/privacy/` — web statico — HTML/JS — pagine pubbliche in it, en, pt-BR (GitHub Pages)

### Build System
- **Type**: Flutter/pub per l'app; `dart` per il pacchetto `estimation`; Gradle (Kotlin DSL) per Android; npm per strumenti e Functions (`tsc`).
- **Config Files**: `pubspec.yaml`, `pubspec.lock`, `l10n.yaml`, `analysis_options.yaml`, `dart_test.yaml`, `.flutter-version` (3.47.9), `.nvmrc` (22), `packages/estimation/pubspec.yaml`, `packages/estimation/analysis_options.yaml`, `android/build.gradle.kts`, `android/settings.gradle.kts`, `android/app/build.gradle.kts`, `package.json`, `functions/package.json`, `functions/tsconfig.json`, `tool/admin/package.json`, `test/rules/package.json`, `firebase.json`, `.firebaserc`, `firestore.rules`, `firestore.indexes.json`.
- **Build Dependencies**: `vinoozy` → `estimation` (dipendenza `path`); `vinoozy` → `functions` solo a runtime (callable); `functions` e `tool/admin` sono pacchetti npm separati; i test delle regole (`test/rules/`) hanno il loro `package.json`.

### APIs Discovered
- Cloud Functions callable — `functions/src/index.ts` — 4 (`verifyPurchase`, `reportUsage`, `reserveAdSlot`, `recordAdOutcome`), tutte con App Check obbligatorio
- Cloud Functions a evento — `functions/src/index.ts` — 5 (`onPlayRtdn`, `onBudgetAlert` su Pub/Sub; `reconcileEntitlements`, `purgeOldUsage` pianificate; `onUserDeleted` su Auth)
- Firestore (contratto C3) — `firestore.rules` — 7 percorsi di primo livello (`users`, `entitlements`, `config`, `usage`, `adSlots`, `purchases`, `cellars`) più `cellars/{id}/wines`, `drinkingRecords`, `members` e il collection group `members`
- HTTP esterno — `lib/catalog/core/off/open_food_facts_source.dart` — Open Food Facts, con il parametro di lingua `lc`
- Contratto interno C1 `WineCatalog` — `lib/catalog/core/wine_catalog.dart`
- Contratto interno C2 — `packages/estimation/lib/estimation.dart` (unico punto di esportazione del pacchetto)
- Canali di piattaforma Flutter↔Kotlin — `lib/app/external_links.dart` (`com.vinoozy.app/links`), `lib/label/platform/` (immagini condivise, Lens)
- Google Play Developer API — `tool/play_api.sh` — 4 comandi (`next-version-code`, `promote`, `complete`, `halt`); nessun comando carica le schede dello store

### Frameworks & Libraries
- Flutter — 3.47.9 (`.flutter-version`) — framework dell'app; Dart SDK `^3.13.7`
- flutter_localizations — SDK — localizzazioni Material/Cupertino/Widgets
- intl — ^0.20.3 — formati di date e numeri, plurali dei messaggi generati
- flutter_riverpod — ^3.4.3 — stato e iniezione delle dipendenze
- cloud_firestore — ^7.1.0 — dati e coda offline
- firebase_core ^5.1.0, firebase_auth ^7.0.1, firebase_app_check ^0.5.1, firebase_crashlytics ^6.0.1, cloud_functions ^7.0.1 — Firebase
- google_sign_in — ^7.2.0 — accesso con Google
- google_mlkit_text_recognition ^1.0.0, google_mlkit_barcode_scanning ^1.0.0 — lettura dell'etichetta sul telefono (solo scrittura latina)
- in_app_purchase ^3.3.1, google_mobile_ads ^9.2.0 — piano Plus e annunci
- http ^1.6.0, connectivity_plus ^7.3.2, shared_preferences ^2.5.6, path_provider ^2.1.6, package_info_plus ^10.2.2, share_plus ^13.3.1, image_picker ^1.2.4, crypto ^3.0.8 — servizi di supporto
- flutter_test, integration_test, flutter_driver, mocktail ^1.0.5, flutter_lints ^6.0.0 — test e analisi
- firebase-functions 7.4.0, firebase-admin 13.10.0, googleapis 189.0.0, @google-cloud/billing 6.2.0, typescript 5.9.3, mocha 12.0.3 — Functions
- firebase-tools 14.27.0, @firebase/rules-unit-testing 6.0.0, playwright 1.65.0, c8 12.0.0, esbuild 0.28.2 — strumenti Node

### Test Coverage
- **Test Directories**: `test/` (unit e widget, per modulo), `integration_test/` (end-to-end su emulatore Android), `integration_test_perf/`, `test_driver/`, `benchmark/`, `packages/estimation/test/`, `functions/test/`, `test/rules/`, `test/admin/`, `test/web/`, `android/app/src/test/kotlin/`, più i test degli script (`tool/*_test.sh`, `tool/render_store_screenshots_test.dart`).
- **Test Frameworks**: `flutter_test`, `integration_test`, `mocktail`, `package:test` (estimation), mocha (Functions), `node --test` con `@firebase/rules-unit-testing`, Playwright e c8 (web), Robolectric con JaCoCo (Kotlin).
- **Coverage Config**: presente. `tool/gen_coverage_helper.dart` importa ogni file di `lib/` (traduzioni generate comprese) così i file senza test contano 0%; `tool/check_coverage.sh 80` sull'lcov unito app + estimation, poi 80% per ciascuno di `lib/catalog/`, `lib/dashboard/`, `lib/sharing/`, `lib/cellar/`, `lib/label/`, `lib/account/`; 90% per `packages/estimation`; 80% per `account-deletion.js` e per il codice Kotlin dell'etichetta. Nessuna esclusione.

### Code Quality Indicators
- **Linting**: `analysis_options.yaml` (`flutter_lints`, `flutter analyze --fatal-infos`), `packages/estimation/analysis_options.yaml` (`lints`), `dart format --set-exit-if-changed`, `tsc` strict per le Functions, actionlint per i workflow.
- **CI/CD**: `.github/workflows/ci.yml` (sette job obbligatori: `format`, `secrets`, `analyze`, `unit`, `estimation`, `rules`, `e2e`), `release.yml` (AAB firmato sul canale di test interno), `promote.yml` (produzione, approvazione manuale), `firebase-deploy.yml`, `functions-deploy.yml`, `pages.yml`; `.github/dependabot.yml`.
- **Documentation**: `README.md` presente; guide operative in `docs/`; commenti di testata ricchi che citano le regole (BR, NFR, FR) in quasi ogni file; `functions/README.md`, `assets/wine_db/README.md`, `distribution/google-play/README.md`.

### Technical Debt Signals
- Tre lingue cablate in più punti, senza una sola fonte: `lib/app/locale_resolution.dart` (lista e `switch`), `lib/cellar/domain/wine_origins.dart` (campi `it`/`en`/`pt` di 249 paesi e delle regioni), `lib/catalog/core/wine_catalog.dart` (`CatalogLocale`), `test/helpers/ui_harness.dart` (`testLocales` e `supportedLocales`), `tool/render_store_screenshots_test.dart`, `tool/check_publication.mjs`, `tool/check_web_pins.sh`, `tool/prepare_static_pages.mjs`, `.github/workflows/pages.yml`.
- `lib/l10n/app_pt.arb` contiene solo `@@locale`: `AppLocalizationsPt` (circa 2.440 righe) ripete i testi inglesi, resta in gran parte non coperto dai test e conta nella soglia dell'80% (`README.md`, tabella delle scelte tecniche).
- I file generati `lib/l10n/app_localizations*.dart` sono versionati; il job `analyze` esegue `flutter gen-l10n` ma nessun controllo fallisce se i file versionati differiscono da quelli rigenerati.
- File molto grandi: `lib/cellar/domain/wine_origins.dart` (1.221 righe, dati e logica insieme), `lib/cellar/ui/add_wine_screen.dart`, `lib/cellar/data/wine_repository.dart`, `packages/estimation/lib/src/label_candidates.dart` (ciascuno oltre 40 KB).
- `foldOriginText` e la mappa `_folding` di `wine_origins.dart` conoscono solo lettere latine; il lettore d'etichetta usa `TextRecognitionScript.latin` (`lib/label/platform/mlkit_label_reader.dart:15`).
- Nessun marcatore `TODO`/`FIXME`/`HACK` nei sorgenti di `lib/`, `packages/estimation/lib/`, `functions/src/` e Kotlin.
- Testi fissi nel codice, voluti: `qualifierDisplayName` (termini di legge del vino, `lib/cellar/ui/wine_labels.dart:78`), `title: 'Vinoozy'` (`lib/app/ui/about_screen.dart:68`), `android:label="Vinoozy"`.
- Le schede dello store e le catture non sono caricate da alcun workflow: si compilano a mano in Play Console.

### Localization Findings

Rilevazioni puntuali per l'intent (aggiunta di lingue):

- **File ARB**: `lib/l10n/app_en.arb` è il modello (1.490 righe, 670 messaggi con descrizione `@`); `app_it.arb` e `app_pt_BR.arb` hanno 670 messaggi ciascuno, senza metadati; `app_pt.arb` ha il solo `@@locale`.
- **Configurazione**: `l10n.yaml` (`arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-class: AppLocalizations`, `nullable-getter: false`); `pubspec.yaml` ha `generate: true`. Non è configurato `untranslated-messages-file`: un messaggio mancante in una lingua ricade in silenzio sul testo inglese.
- **Codice generato** (versionato in `lib/l10n/`): `app_localizations.dart` 4.176 righe, `app_localizations_en.dart` 2.449, `app_localizations_it.dart` 2.462, `app_localizations_pt.dart` 4.900 (classe base `AppLocalizationsPt` in inglese più `AppLocalizationsPtBr`). `AppLocalizations.supportedLocales` generato elenca `en`, `it`, `pt`, `pt_BR`.
- **Lingue offerte dall'app**: non si usa la lista generata. `lib/app/locale_resolution.dart` definisce `appLocales` (`en`, `it`, `pt_BR`), `fallbackLocale` (`en`) e `resolveAppLocale`, che riconosce solo `it`, `en` e `pt` con paese `BR`; il portoghese di altri paesi riceve l'inglese. `VinoozyApp` passa `supportedLocales: appLocales` e `localeListResolutionCallback`.
- **Scelta della lingua**: nessun selettore e nessuna impostazione nell'app; decide la lingua del telefono. Le build E2E forzano l'italiano (`lib/e2e/e2e_locale.dart`), e i test end-to-end cercano testi italiani.
- **Uso fuori dall'albero dei widget**: `lib/app/bootstrap.dart:278` chiama `lookupAppLocalizations` per il nome della cantina predefinita, che viene salvato nella lingua del telefono al primo accesso.
- **Plurali e select**: almeno 17 messaggi con `plural`, tutti con le sole forme `=0`/`=1`/`other`; tre messaggi con `select` (`guideWordUsedFor`, `guideUsedMark`, `guideSkippedNotice`) che inseriscono un nome di campo dentro una frase. Le lingue con più categorie di plurale (per esempio slave) richiedono forme `few`/`many` nei rispettivi ARB.
- **Date e numeri**: nessun segnaposto `DateTime` negli ARB (gli anni passano come `String`). Il codice formatta con `DateFormat.yMMMM`/`yMMM` (`lib/cellar/ui/wine_labels.dart:170,174`), `DateFormat.yMMMMd` (`lib/app/ui/about_screen.dart:44`, `lib/plan/ui/dashboard_plan_notices.dart:158`), `NumberFormat.decimalPatternDigits` (`about_screen.dart:49`) e `MaterialLocalizations.formatMediumDate` (`wine_labels.dart:289`), sempre con la lingua del contesto. Molti numeri sono interpolati senza formato (`'$year'`, `'${bar.value}'`).
- **Dati di dominio con chiave di lingua**: `OriginCountry(code, it, en, pt)` per 249 paesi e `WineRegion(canonical, it, en, pt, aliases)` per le regioni di 21 paesi (`lib/cellar/domain/wine_origins.dart`); `nameIn` conosce `it` e `pt`, tutto il resto è inglese. Undici punti dell'interfaccia, in otto file, leggono `Localizations.localeOf(context).languageCode` per queste funzioni. Il valore salvato è sempre il codice ISO o il nome canonico, mai la traduzione.
- **Dati di dominio indipendenti dalla lingua dell'interfaccia**: `wineCountryNames` in `packages/estimation/lib/src/country_names.dart` (nomi dei paesi sulle etichette in italiano, inglese, francese, spagnolo, portoghese, tedesco e lingua nativa); tabelle di denominazioni, vitigni e parole di stile del pacchetto `estimation`; nomi di stili, profili, livelli e abbinamenti sono invece chiavi tradotte negli ARB.
- **Catalogo**: `CatalogLocale` ha tre valori (`it`, `en`, `ptBR`) e passa a Open Food Facts il codice `lc`; ogni altra lingua diventa inglese.
- **Test per lingua**: `test/helpers/ui_harness.dart` definisce `testLocales` (tre lingue) e `accessibilityMatrix`, che genera un test per ogni combinazione lingua × scala del testo (1.0, 2.0) × tema (chiaro, scuro): 12 test per schermata oggi. Dodici file di test iterano su `testLocales`; molti altri usano `lookupAppLocalizations(const Locale('it'))`.
- **Store**: `distribution/google-play/{it-IT,en-US,pt-BR}/` con `title.txt`, `short-description.txt`, `full-description.txt` (limiti 30/80/4000 verificati da `tool/check_publication.mjs`); `release-notes.txt` con tre blocchi di lingua; catture in `assets/screenshots/{it,en,pt-BR}/` prodotte da `tool/render_store_screenshots_test.dart`; una sola feature graphic, italiana.
- **Web**: pagine `docs/privacy/` e `docs/account-deletion/` in it, en, pt-BR; l'app apre sempre l'indirizzo italiano della privacy (`lib/account/account_providers.dart:41`).
- **Android**: nessun `resConfigs`/`resourceConfigurations` e nessun `locales_config` nel manifest o in Gradle; l'attività gestisce `locale` e `layoutDirection` in `configChanges`.

## Handoff Summary
- **Intent-relevant finding**: aggiungere lingue non è solo aggiungere file ARB. L'elenco delle lingue è cablato in `lib/app/locale_resolution.dart:4-27` (lista e `switch`), nei dati dei paesi e delle regioni (`lib/cellar/domain/wine_origins.dart:12-26`, `38-58`, `816-1221`), in `CatalogLocale` (`lib/catalog/core/wine_catalog.dart:38-57`), nell'harness dei test (`test/helpers/ui_harness.dart:10-14`, `40-44`) e negli strumenti dello store e del web. Ogni lingua nuova aggiunge inoltre un file generato di circa 2.450 righe che conta nella soglia dell'80% senza esclusioni (`tool/gen_coverage_helper.dart:1-5`, `.github/workflows/ci.yml:188-204`), mentre oggi `app_localizations_pt.dart` è già in gran parte non coperto (`README.md:30`).
- **Risks / follow-up**:
  - Copertura: con venti o più lingue il codice generato può abbassare la copertura totale sotto l'80%; la soglia non si può ridurre né si possono escludere file (team.md). Serve una strategia di test che eserciti i messaggi di ogni lingua.
  - Tempo di CI: `accessibilityMatrix` moltiplica i test per il numero di lingue; il job `unit` ha un limite di 40 minuti.
  - Lingue con più forme di plurale, lingue non latine e lingue da destra a sinistra: i plurali attuali hanno solo `=1`/`other`, la ricerca dei paesi ripiega solo lettere latine, la lettura dell'etichetta è solo latina; nessuna prova di layout da destra a sinistra è stata trovata (non verificato in profondità).
  - Varianti regionali: la regola di oggi distingue `pt-BR` da `pt`; francese, spagnolo e tedesco hanno varianti (Canada, America Latina, Austria, Svizzera) da decidere allo stesso modo.
  - Il nome della cantina predefinita è salvato nella lingua del primo accesso.
  - Le regole di team.md citano "tre lingue (it, en, pt-BR)" per i test dei widget e per i file di localizzazione: vanno aggiornate dal proprietario se l'intent cambia l'elenco.
  - Limite della scansione: fuori dall'area di localizzazione i moduli sono stati letti a livello di struttura, testate e ricerche mirate, non file per file.
