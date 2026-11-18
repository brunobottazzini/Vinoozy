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
| `distribution/google-play/` | Testi della scheda per lingua, note di rilascio, catture, grafica |
| `assets/` | `wine_db/` (database offline dei vini), `branding/`, `icon/` |
| `.github/workflows/` | Sei workflow; vedi `code-quality-assessment.md` |
| Radice | `pubspec.yaml`, `l10n.yaml`, `analysis_options.yaml`, `firebase.json`, `firestore.rules`, `firestore.indexes.json`, `package.json` |

Cartelle generate o installate, non analizzate: `build/`, `coverage/`, `.dart_tool/`, `node_modules/`, `functions/lib/`, `.idea/`, `.cache/`, `android/.gradle/`.

## Module Organization in `lib/`

| Modulo | Strati | Ruolo |
|---|---|---|
| `main.dart`, `app/` | radice, `ui/` | Avvio, collegamento dei servizi, `MaterialApp`, tema, guscio con le schede, risoluzione della lingua |
| `l10n/` | ARB e generato | Testi dell'interfaccia |
| `account/` | `data/`, `deletion/`, `ui/` | Sessione, cambio account, onboarding, profilo, cancellazione |
| `cellar/` | `domain/`, `data/`, `ui/` | Vini, bevute, origini, stime salvate, schermate della cantina |
| `catalog/` | `core/` (Dart puro), `platform/` | Contratto C1: database offline, catalogo interno, Open Food Facts |
| `label/` | `core/`, `platform/`, `ui/` | Foto, lettura, sessione guidata, Lens, testo condiviso |
| `dashboard/` | `domain/` (Dart puro), `ui/` | Riepilogo e grafici, sola lettura |
| `sharing/` | `domain/`, `data/`, `ui/` | Inviti e appartenenze |
| `sync/` | `ledger/`, `ui/` | Registro locale, verifica delle scritture, stato e avvisi di sincronizzazione |
| `plan/` | `domain/`, `data/`, `billing/`, `ui/` | Diritti Plus, politica del piano, limite di capienza |
| `ads/` | `ui/` | Annuncio giornaliero del Cruscotto |
| `usage/` | `domain/` | Contatori d'uso di Firestore e invio |
| `firebase/` | — | Ambiente demo o prod, opzioni, avvio di Firestore |
| `dev/` | `ui/` | Strumenti di sviluppo, compilati solo con `ENABLE_DEV_CHEATS` |
| `e2e/` | — | Ganci delle build E2E (lingua forzata, accesso con emulatore, controllo rete) |
| `core/` | — | `Clock`, `IdGenerator` |

## File Classification

| Categoria | Dove |
|---|---|
| Model/Entity | `lib/*/domain/`, `packages/estimation/lib/src/models.dart`, `functions/src/domain/` |
| Service/UseCase | `lib/account/account_gate.dart`, `lib/cellar/wine_estimator.dart`, `lib/catalog/core/catalog_coordinator.dart`, `lib/label/core/`, `lib/plan/plan_session.dart`, `packages/estimation/lib/src/` |
| Repository/DAO | `lib/*/data/`, `lib/sync/sync_gateway.dart`, `lib/catalog/core/off/` |
| Controller/Handler | `lib/*/ui/` (schermate e controller), `functions/src/handlers/` |
| Configuration | `lib/app/bootstrap.dart`, `lib/*/*_providers.dart`, `lib/firebase/`, `functions/src/config.ts`, `functions/src/deps.ts` |
| Utility/Helper | `lib/core/`, `lib/cellar/ui/wine_labels.dart`, `lib/*/ui/*_labels.dart` |
| Static/Asset | `lib/l10n/*.arb`, `assets/`, `docs/privacy/`, `distribution/google-play/` |
| Generated | `lib/l10n/app_localizations*.dart`, `packages/estimation/lib/src/generated/*.g.dart`, `test/coverage_helper_test.dart` (ignorato da git) |
| Test | `test/`, `integration_test/`, `packages/estimation/test/`, `functions/test/`, `android/app/src/test/` |

## Code Patterns

- **Riverpod** per stato e dipendenze: un file `*_providers.dart` per modulo; il contenitore è creato in `AppBootstrap` e passato con `UncontrolledProviderScope`.
- **Dipendenze passate dal costruttore**: repository e servizi ricevono database, orologio, misuratore e reporter; i test usano finti e `mocktail`.
- **Strati puri verificati in CI**: `lib/catalog/core/`, `lib/dashboard/domain/`, `lib/cellar/domain/wine_origins.dart` e tutto `packages/estimation` non importano Flutter né Firebase.
- **Tipi sigillati ed enum con `switch` esaustivi** per stati ed eventi (`SyncEvent`, `TextAutofill`): aggiungere un caso obbliga il compilatore a segnalare ogni punto da aggiornare.
- **Etichette tradotte in funzioni dedicate**: un enum di dominio diventa testo solo in `*_labels.dart`, con uno `switch` verso le chiavi di `AppLocalizations`.
- **Commenti che citano le regole** (`BR`, `NFR`, `FR`) in testa a quasi ogni file; controlli di CI verificano che ogni regola compaia nel nome di un test.
- **Chiavi dei widget stabili** (`Key('privacy-open')`) usate dai test.
- **Nomi**: file in `snake_case`, tipi in `UpperCamelCase`, codice e commenti in inglese.

## Localization Touchpoints

Elenco dei punti in cui l'insieme delle lingue è scritto nel codice o nei dati. Chi aggiunge una lingua li incontra tutti.

| # | Punto | File | Oggi |
|---|---|---|---|
| 1 | Testi | `lib/l10n/app_en.arb` (modello, 670 messaggi), `app_it.arb`, `app_pt_BR.arb`, `app_pt.arb` (solo `@@locale`) | 3 lingue |
| 2 | Configurazione del generatore | `l10n.yaml`, `pubspec.yaml` (`generate: true`) | Nessun file dei messaggi non tradotti |
| 3 | Codice generato versionato | `lib/l10n/app_localizations.dart`, `_en.dart`, `_it.dart`, `_pt.dart` | Circa 2.450 righe per lingua |
| 4 | Lingue offerte e ripiego | `lib/app/locale_resolution.dart` | Lista e `switch` scritti a mano |
| 5 | Collegamento a `MaterialApp` | `lib/app/vinoozy_app.dart` | Usa `appLocales`, non la lista generata |
| 6 | Lingua forzata nelle build E2E | `lib/e2e/e2e_locale.dart`, `tool/check_release_build.sh` | Italiano |
| 7 | Testo usato fuori dai widget | `lib/app/bootstrap.dart` (nome della cantina predefinita) | Salvato nella lingua del primo accesso |
| 8 | Nomi di paesi e regioni | `lib/cellar/domain/wine_origins.dart` (`OriginCountry`, `WineRegion`, `nameIn`, `searchCountries`, `foldOriginText`) | Campi `it`, `en`, `pt`; ripiegamento solo di lettere latine |
| 9 | Lettura della lingua per i nomi d'origine | `lib/app/ui/country_flag.dart`, `lib/cellar/ui/origin_pickers.dart`, `wine_card.dart`, `wine_detail_screen.dart`, `drink_confirm_sheet.dart`, `lib/dashboard/ui/chart_cards.dart`, `lib/label/ui/candidate_list.dart`, `label_proposal_sheet.dart` | 11 letture di `languageCode` |
| 10 | Lingua del catalogo | `lib/catalog/core/wine_catalog.dart` (`CatalogLocale`), `lib/catalog/core/off/open_food_facts_source.dart` (`lc`) | `it`, `en`, `pt` |
| 11 | Date e numeri | `lib/cellar/ui/wine_labels.dart`, `lib/app/ui/about_screen.dart`, `lib/plan/ui/dashboard_plan_notices.dart` | `intl` con la lingua del contesto |
| 12 | Plurali e select | `lib/l10n/app_en.arb` | Almeno 17 plurali con `=0`/`=1`/`other`; 3 select |
| 13 | Harness dei test | `test/helpers/ui_harness.dart` (`testLocales`, `supportedLocales`, `accessibilityMatrix`) | 3 lingue × 2 scale × 2 temi |
| 14 | Test che iterano sulle lingue | 12 file sotto `test/` | Usano `testLocales` |
| 15 | Copertura | `tool/gen_coverage_helper.dart`, `tool/check_coverage.sh` | Tutto `lib/`, generato compreso |
| 16 | Catture dello store | `tool/render_store_screenshots_test.dart` | 3 lingue, note per lingua in uno `switch` |
| 17 | Testi dello store | `distribution/google-play/{it-IT,en-US,pt-BR}/`, `release-notes.txt`, `tool/check_publication.mjs` | 3 lingue, caricamento manuale |
| 18 | Pagine web | `docs/privacy/`, `docs/account-deletion/`, `tool/prepare_static_pages.mjs`, `tool/check_web_pins.sh`, `.github/workflows/pages.yml` | it, en, pt-BR |
| 19 | Indirizzo della privacy nell'app | `lib/account/account_providers.dart` | Solo la pagina italiana |
| 20 | Lettura dell'etichetta | `lib/label/platform/mlkit_label_reader.dart` | Solo scrittura latina |
| 21 | Nomi dei paesi sulle etichette | `packages/estimation/lib/src/country_names.dart` | 7 lingue d'etichetta, indipendenti dall'interfaccia |
| 22 | Android | `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts` | Nessuna dichiarazione delle lingue |

Testi fissi voluti, non da tradurre: `qualifierDisplayName` in `lib/cellar/ui/wine_labels.dart` e il nome `Vinoozy`.
