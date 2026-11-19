# Code Structure

## Repository Layout

| Percorso | Contenuto |
|---|---|
| `lib/` | App Flutter, un modulo per funzione |
| `packages/estimation/` | Libreria Dart pura della stima (contratto C2), con test e benchmark propri |
| `functions/` | Cloud Functions in TypeScript (`src/`, `test/`) |
| `android/` | Progetto Gradle, manifest, quattro classi Kotlin e i loro test |
| `test/` | Test unitari e dei widget per modulo; `test/rules/`, `test/admin/`, `test/web/` sono test Node |
| `integration_test/`, `integration_test_perf/`, `test_driver/` | Test end-to-end e di prestazioni su emulatore Android |
| `benchmark/` | Soglie di velocità eseguite in CI |
| `tool/` | Script di controllo per la CI, generatori di dati, script di rilascio, `tool/admin/` |
| `docs/` | Guide operative; `docs/privacy/` e `docs/account-deletion/` sono le pagine pubbliche |
| `distribution/google-play/` | Testi della scheda per 25 schede, note di rilascio, catture, grafica (dettaglio sotto) |
| `assets/` | `wine_db/` (database offline dei vini), `branding/`, `icon/` |
| `.github/workflows/` | Sei workflow; vedi `code-quality-assessment.md` |
| Radice | `pubspec.yaml`, `l10n.yaml`, `analysis_options.yaml`, `firebase.json`, `firestore.rules`, `firestore.indexes.json`, `package.json` |

Cartelle generate o installate, non analizzate: `build/`, `coverage/`, `.dart_tool/`, `node_modules/`, `functions/lib/`, `.idea/`, `.cache/`, `android/.gradle/`.

## Module Organization in `lib/`

| Modulo | Strati | Ruolo |
|---|---|---|
| `main.dart`, `app/` | radice, `ui/` | Avvio, collegamento dei servizi, `MaterialApp`, tema, guscio con le schede, risoluzione della lingua, link esterni, Informazioni, piè di pagina |
| `l10n/` | ARB e generato | Testi dell'interfaccia in 25 lingue |
| `account/` | radice, `data/`, `deletion/`, `ui/` | Sessione, cambio account, presentazione al primo avvio, profilo, cancellazione |
| `cellar/` | `domain/`, `data/`, `ui/` | Vini, bevute, origini, stime salvate, schermate della cantina, menu della Cantina |
| `catalog/` | `core/` (Dart puro), `platform/` | Contratto C1: database offline, catalogo interno, Open Food Facts |
| `label/` | `core/`, `platform/`, `ui/` | Foto, lettura, sessione guidata, Lens, testo condiviso |
| `dashboard/` | `domain/` (Dart puro), `ui/` | Riepilogo e grafici, sola lettura |
| `sharing/` | `domain/`, `data/`, `ui/` | Inviti e appartenenze; `ui/share_launcher.dart` avvolge `share_plus` |
| `sync/` | `ledger/`, `ui/` | Registro locale, verifica delle scritture, stato e avvisi di sincronizzazione |
| `plan/` | `domain/`, `data/`, `billing/`, `ui/` | Diritti Plus, politica del piano, limite di capienza |
| `ads/` | `ui/` | Annuncio giornaliero del Cruscotto |
| `usage/` | radice, `domain/` | Contatori d'uso di Firestore e invio |
| `firebase/` | — | Ambiente demo o prod, opzioni, avvio di Firestore |
| `dev/` | `ui/` | Strumenti di sviluppo, compilati solo con `ENABLE_DEV_CHEATS` |
| `e2e/` | — | Ganci delle build E2E (lingua forzata, accesso con emulatore, controllo rete) |
| `core/` | — | `Clock`, `IdGenerator` |

### Files Relevant to Onboarding, Settings and Outbound Links

Dalla scansione del 2026-11-19. Il comportamento è descritto in `architecture.md`, "Onboarding, Profile and Outbound Links".

| File | Classificazione | Contenuto |
|---|---|---|
| `lib/account/onboarding_flag.dart` | Repository/DAO | `OnboardingFlag`, chiave `onboarding.seen` |
| `lib/account/account_providers.dart` | Configuration | `onboardingFlagProvider`, `onboardingSeenProvider`, `privacyPolicyUrlFor` |
| `lib/account/ui/account_gate_view.dart` | Controller/Handler | `AccountGateView`, `_SignInOrOnboarding` |
| `lib/account/ui/onboarding_screen.dart` | Controller/Handler | `OnboardingScreen` (3 pagine, `pageCount`) |
| `lib/account/ui/profile_screen.dart` | Controller/Handler | `ProfileScreen`, dialoghi di uscita, dialogo della privacy |
| `lib/app/home_shell.dart` | Controller/Handler | `HomeShell`, tre schede |
| `lib/app/ui/about_screen.dart` | Controller/Handler | `AboutScreen` |
| `lib/app/ui/brand_footer.dart` | Controller/Handler | `BrandFooter`, `appVersionLabelProvider` |
| `lib/app/external_links.dart` | Utility/Helper | `openExternalLink`, `externalLinkOpenerProvider` |
| `lib/sharing/ui/share_launcher.dart` | Utility/Helper | `ShareLauncher`, `SharePlusLauncher`, `shareLauncherProvider`, `playStoreLink` |
| `lib/cellar/ui/cellar_screen.dart` | Controller/Handler | `_CellarMenu` (Profilo, Persone, Bevuti, Informazioni) |

## File Classification

| Categoria | Dove |
|---|---|
| Model/Entity | `lib/*/domain/`, `packages/estimation/lib/src/models.dart`, `functions/src/domain/` |
| Service/UseCase | `lib/account/account_gate.dart`, `lib/cellar/wine_estimator.dart`, `lib/catalog/core/catalog_coordinator.dart`, `lib/label/core/`, `lib/plan/plan_session.dart`, `packages/estimation/lib/src/` |
| Repository/DAO | `lib/*/data/`, `lib/sync/sync_gateway.dart`, `lib/catalog/core/off/`, `lib/account/onboarding_flag.dart` |
| Controller/Handler | `lib/*/ui/` (schermate e controller), `functions/src/handlers/` |
| Configuration | `lib/app/bootstrap.dart`, `lib/*/*_providers.dart`, `lib/firebase/`, `functions/src/config.ts`, `functions/src/deps.ts` |
| Utility/Helper | `lib/core/`, `lib/app/external_links.dart`, `lib/cellar/ui/wine_labels.dart`, `lib/*/ui/*_labels.dart` |
| Static/Asset | `lib/l10n/*.arb`, `assets/`, `docs/privacy/`, `distribution/google-play/` |
| Generated | `lib/l10n/app_localizations*.dart`, `packages/estimation/lib/src/generated/*.g.dart`, `test/l10n/l10n_exercise_test.dart` (da `tool/gen_l10n_exercise.dart`), `test/coverage_helper_test.dart` (ignorato da git) |
| Test | `test/`, `integration_test/`, `packages/estimation/test/`, `functions/test/`, `android/app/src/test/` |

## Code Patterns

- **Riverpod** per stato e dipendenze: un file `*_providers.dart` per modulo; il contenitore è creato in `AppBootstrap` e passato con `UncontrolledProviderScope`. I servizi di piattaforma (link, condivisione, flag) sono dietro un `Provider` con valore predefinito o `null`, sovrascritto all'avvio o nei test.
- **Dipendenze passate dal costruttore**: repository e servizi ricevono database, orologio, misuratore e reporter; i test usano finti e `mocktail`.
- **Strati puri verificati in CI**: `lib/catalog/core/`, `lib/dashboard/domain/`, `lib/cellar/domain/wine_origins.dart` e tutto `packages/estimation` non importano Flutter né Firebase.
- **Tipi sigillati ed enum con `switch` esaustivi** per stati ed eventi (`GateState`, `SyncEvent`, `TextAutofill`).
- **Etichette tradotte in funzioni dedicate**: un enum di dominio diventa testo solo in `*_labels.dart`, con uno `switch` verso le chiavi di `AppLocalizations`.
- **Navigazione imperativa**: ogni schermata espone un `static Future<void> open(BuildContext, ...)` che fa `Navigator.push` con `MaterialPageRoute` (`ProfileScreen.open`, `AboutScreen.open`).
- **Commenti che citano le regole** (`BR`, `NFR`, `FR`) in testa a quasi ogni file; controlli di CI verificano che ogni regola compaia nel nome di un test.
- **Chiavi dei widget stabili** (`Key('profile-privacy')`, `Key('onboarding-skip')`, `Key('cellar-menu-about')`) usate dai test unitari ed E2E.
- **Nomi**: file in `snake_case`, tipi in `UpperCamelCase`, codice e commenti in inglese.

## Localization Touchpoints

Elenco dei punti in cui l'insieme delle lingue è scritto nel codice o nei dati. Righe 1-5, 17, 19, 22, 23 riverificate il 2026-11-19; le altre vengono dallo store precedente (tre lingue) e non sono state riverificate.

| # | Punto | File | Stato |
|---|---|---|---|
| 1 | Testi | `lib/l10n/app_<lingua>.arb`, modello `app_en.arb` | 25 ARB (più `app_pt.arb` per il portoghese europeo), 670 messaggi ciascuno |
| 2 | Configurazione del generatore | `l10n.yaml`, `pubspec.yaml` (`generate: true`) | `untranslated-messages-file: l10n_untranslated.json` (ignorato da git) |
| 3 | Codice generato versionato | `lib/l10n/app_localizations*.dart` | Circa 2.460 righe per lingua; `app_localizations.dart` 4.284 righe |
| 4 | Lingue offerte e ripiego | `lib/app/locale_resolution.dart` | `appLocales` (25), alias `no`/`nn` → `nb`, `androidLocaleTagOf`, `intlLocaleNameOf` |
| 5 | Collegamento a `MaterialApp` | `lib/app/vinoozy_app.dart` | Usa `appLocales` |
| 6 | Lingua forzata nelle build E2E | `lib/e2e/e2e_locale.dart`, `tool/check_release_build.sh` | Italiano |
| 7 | Testo usato fuori dai widget | `lib/app/bootstrap.dart` (nome della cantina predefinita) | Salvato nella lingua del primo accesso |
| 8 | Nomi di paesi e regioni | `lib/cellar/domain/wine_origins.dart` | Non riverificato dopo la 0.3.0 |
| 9 | Lettura della lingua per i nomi d'origine | Schermate di Cellar, Dashboard, Label, `lib/app/ui/country_flag.dart` | Non riverificato |
| 10 | Lingua del catalogo | `lib/catalog/core/wine_catalog.dart`, `open_food_facts_source.dart` | Non riverificato |
| 11 | Date e numeri | `lib/cellar/ui/wine_labels.dart`, `lib/app/ui/about_screen.dart`, `lib/plan/ui/dashboard_plan_notices.dart` | `intl` con `intlLocaleNameOf` |
| 12 | Plurali e select | `lib/l10n/app_en.arb` | Non riverificato |
| 13 | Harness dei test | `test/helpers/ui_harness.dart` (`testLocales`) | `it`, `en`, `pt-BR` più un elenco esteso con francese, spagnolo e tedesco |
| 14 | Test che iterano sulle lingue | File sotto `test/` | Non riverificato |
| 15 | Copertura | `tool/gen_coverage_helper.dart`, `tool/check_coverage.sh` | Tutto `lib/`, generato compreso |
| 16 | Catture dello store | `tool/render_store_screenshots_test.dart`, `distribution/google-play/assets/screenshots/` | Solo `it`, `en`, `pt-BR` |
| 17 | Testi dello store | `distribution/google-play/<scheda>/`, `languages.json`, `release-notes.txt`, `tool/check_publication.mjs` | 25 schede; `nb` → `no-NO`, `pt` → `pt-PT` |
| 18 | Pagine web | `docs/privacy/`, `docs/account-deletion/` | it, en, pt-BR |
| 19 | Indirizzo della privacy nell'app | `lib/account/account_providers.dart` (`privacyPolicyUrlFor`) | it, pt-BR, altrimenti en |
| 20 | Lettura dell'etichetta | `lib/label/platform/mlkit_label_reader.dart` | Non riverificato |
| 21 | Nomi dei paesi sulle etichette | `packages/estimation/lib/src/country_names.dart` | Non riverificato |
| 22 | Android | `android/app/src/main/AndroidManifest.xml` (`android:localeConfig`), `res/xml/locales_config.xml` | 25 tag BCP 47 (`pt-PT`, `sr-Cyrl`) |
| 23 | Test di allineamento | `test/app/language_consistency_test.dart`, `test/l10n/l10n_exercise_test.dart` (generato) | `appLocales` contro Android, store, ARB; ogni messaggio in ogni lingua |

Testi fissi voluti, non da tradurre: `qualifierDisplayName` in `lib/cellar/ui/wine_labels.dart` e il nome `Vinoozy`.

## Store Listing Layout (`distribution/google-play/`)

| Elemento | Contenuto |
|---|---|
| `<scheda>/title.txt`, `short-description.txt`, `full-description.txt` | Uno per ciascuna delle 25 schede; limiti 30/80/4000 caratteri. `it-IT` (predefinita): circa 1.780 caratteri; `en-US`: circa 1.650 |
| `languages.json` | Lingua dell'interfaccia → cartella della scheda e tag del blocco in `release-notes.txt`; `defaultListing: it-IT` |
| `release-notes.txt` | Un blocco `<scheda>…</scheda>` per lingua |
| `assets/` | Icona 512, feature graphic italiana, catture per `it`, `en`, `pt-BR` |
| `README.md` | Valori di Play Console: package `com.vinoozy.app`, categoria, email di supporto, URL di privacy e cancellazione |
| `data-safety.csv`, `data-safety.json`, `beta-tester-instructions.txt`, `reviewer-instructions.txt` | Dichiarazioni e istruzioni (non lette in questo giro) |
