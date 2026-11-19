# Code Quality Assessment

Valutazione da sola lettura: nessun test, build o misura di copertura è stato eseguito. Le percentuali reali di copertura non sono note qui; sono note le soglie. Le sezioni sulle aree di questo intent sono state aggiunte il 2026-11-19; le altre vengono dallo store precedente.

## Test Coverage

### Suites

| Suite | Dove | Strumento |
|---|---|---|
| Unit e widget dell'app | `test/` (per modulo) | `flutter test --coverage`, `mocktail` |
| Stima | `packages/estimation/test/` | `dart test` |
| Regole Firestore | `test/rules/` | `@firebase/rules-unit-testing` su emulatore |
| Cloud Functions | `functions/test/` | mocha su emulatori |
| Script del proprietario | `test/admin/` | `node --test` |
| Pagina web | `test/web/` | `node --test`, Playwright, c8 |
| Kotlin | `android/app/src/test/` | Robolectric, JaCoCo |
| End-to-end | `integration_test/` | `integration_test` su emulatore Android API 34 con emulatori Firebase |
| Prestazioni | `integration_test_perf/`, `benchmark/`, `packages/estimation/benchmark/` | Soglie di tempo |
| Script di CI | `tool/*_test.sh` | Ogni controllo ha il suo test su casi buoni e cattivi |

### Thresholds

| Ambito | Soglia | Controllo |
|---|---|---|
| App più `estimation`, tutte le righe, nessuna esclusione | 80% | `tool/check_coverage.sh 80 coverage/merged.lcov.info` |
| `lib/catalog/`, `lib/dashboard/`, `lib/sharing/`, `lib/cellar/`, `lib/label/`, `lib/account/`, ciascuno | 80% | `tool/check_coverage.sh 80 coverage/lcov.info <prefisso>` |
| `packages/estimation/lib` | 90% | Job `estimation` |
| `docs/account-deletion/account-deletion.js` | 80% | c8 |
| Codice Kotlin dell'etichetta | 80% | JaCoCo |

`tool/gen_coverage_helper.dart` importa ogni file di `lib/`, così un file senza test conta 0% invece di sparire dal rapporto. `lib/l10n/` non ha una soglia propria ma entra nella soglia totale; lo copre `test/l10n/l10n_exercise_test.dart`, generato.

### Tests for Onboarding, Profile and Links

Elenco dei file trovati per nome e ricerca, non letti a fondo.

| Area | Test |
|---|---|
| Presentazione, login, profilo | `test/account/account_ui_test.dart`, `test/account/account_data_test.dart`, `test/u1/domain/user_profile_test.dart` |
| Indirizzo della privacy per lingua | `test/account/privacy_url_languages_test.dart` |
| Piano nel profilo | `test/plan/ui/profile_plan_and_plus_screen_test.dart` |
| Guscio e schede | `test/app/home_shell_test.dart`, `test/account/account_gate_home_shell_test.dart` |
| Informazioni | `test/app/about_screen_test.dart` |
| Link esterni | `test/app/external_links_test.dart` |
| Condivisione (invito) | `test/sharing/sharing_screen_test.dart` |
| Allineamento delle lingue | `test/app/language_consistency_test.dart`, `test/app/locale_resolution_languages_test.dart`, `test/l10n/l10n_exercise_test.dart` |
| End-to-end | `integration_test/account_test.dart` (mostra e salta la presentazione), `integration_test/e2e_helpers.dart` (scrive `onboarding.seen` per saltarla), `integration_test/u1_skeleton_test.dart` (campo `onboardingSeen` del profilo) |

### Localization Testing

- `test/helpers/ui_harness.dart` offre `pumpScreen` (lingua predefinita italiana) e `accessibilityMatrix`: per lingua, scala del testo 1.0 e 2.0, tema chiaro e scuro, verifica assenza di overflow, contrasto, dimensione dei bersagli e presenza di etichette. `testLocales` vale `it`, `en`, `pt-BR`, con un elenco esteso che aggiunge francese, spagnolo e tedesco.
- `test/l10n/l10n_exercise_test.dart` chiama ogni messaggio di ogni lingua; va rigenerato con `tool/gen_l10n_exercise.dart` quando cambia `app_en.arb`.
- `test/app/language_consistency_test.dart` confronta `appLocales` con `locales_config.xml`, `languages.json`, le cartelle dello store e gli ARB.
- I test end-to-end cercano testi italiani e girano con la lingua forzata.

## Linting and Static Analysis

| Controllo | Configurazione |
|---|---|
| `dart format --set-exit-if-changed .` | Job `format` |
| `flutter analyze --fatal-infos` | `analysis_options.yaml` (`flutter_lints`); esclude `build/`, `android/`, `packages/`, `tool/fixtures/` |
| `dart analyze --fatal-infos` nel pacchetto | `packages/estimation/analysis_options.yaml` |
| `tsc` strict | `functions/tsconfig.json` |
| actionlint | Job `format` |
| gitleaks su tutta la cronologia | Job `secrets`, eccezioni in `.gitleaksignore` |

I file di localizzazione generati portano `// ignore_for_file: type=lint`.

## CI/CD

| Workflow | Innesco | Cosa fa |
|---|---|---|
| `ci.yml` | Ogni push e ogni pull request verso `main` | Sette job obbligatori: `format`, `secrets`, `analyze`, `unit` (limite 40 minuti), `estimation`, `rules`, `e2e` (limite 75 minuti) |
| `release.yml` | CI riuscita su `main` | AAB firmato sul canale di test interno |
| `promote.yml` | Manuale, con approvazione | Produzione con rilascio graduale; `halt` come rientro |
| `firebase-deploy.yml` | Manuale | Regole e indici Firestore |
| `functions-deploy.yml` | Manuale | Cloud Functions |
| `pages.yml` | Manuale | Pagine di privacy e cancellazione account |

Punti forti: azioni fissate per SHA, versione di Flutter fissata e verificata, nessun segreto nei job di CI, autenticazione senza chiavi verso Firebase, controlli che la build di rilascio non contenga i ganci E2E né gli strumenti di sviluppo.

## Documentation Quality

- `README.md` breve e corretto, con i comandi di sviluppo e le deviazioni dal piano.
- Guide operative in `docs/` (Firebase, GitHub Actions, Play Console, rilascio, passaggio a Blaze, Plus, lingue dello store).
- `distribution/google-play/README.md` riassume i valori di Play Console; parla ancora di "prima scheda" e di catture in tre lingue.
- Commenti di testata che spiegano il perché e citano le regole di origine.
- I messaggi del modello ARB portano una descrizione con la regola d'origine, utile a chi traduce.

## Quick Assessment

| Aspetto | Giudizio | Evidenza |
|---|---|---|
| Chiarezza dei nomi | Buono | Nomi descrittivi e coerenti tra moduli |
| Dimensione dei file | Discreto | Alcuni file oltre 40 KB |
| Gestione degli errori | Buono | Link e flag restituiscono `false` invece di lanciare; avvio con schermata di errore |
| Presenza di test | Buono | Suite per ogni strato e soglie bloccanti; chiavi dei widget stabili |
| Duplicazione | Buono | Elenco delle lingue ora da una sola fonte verificata da un test |
| Codice morto | Discreto | Campo cloud `onboardingSeen` scritto ma non usato dall'interfaccia letta |

## Technical Debt

| # | Debito | Dove | Effetto |
|---|---|---|---|
| 1 | Nessuna schermata Impostazioni; voci personali nel Profilo, aperto da un menu della Cantina | `lib/account/ui/profile_screen.dart`, `lib/cellar/ui/cellar_screen.dart` | Nuove voci (condividi, valuta, feedback) non hanno una sede ovvia |
| 2 | Numero di pagine della presentazione scritto nel testo | `onboardingPageOf` in 25 ARB, `OnboardingScreen.pageCount` | Cambiare le pagine richiede di toccare 25 traduzioni |
| 3 | Due stati di onboarding (flag locale e campo cloud) | `lib/account/onboarding_flag.dart`, `lib/cellar/domain/user_profile.dart` | Ambiguità su quale decide |
| 4 | `playStoreLink` dentro Sharing | `lib/sharing/ui/share_launcher.dart` | Dipendenza da Sharing per chi vuole il link dell'app |
| 5 | Link esterni solo `https` | `lib/app/external_links.dart`, `MainActivity.kt` | Nessun `market://`; la pagina Play si apre per `https` |
| 6 | Ogni messaggio nuovo moltiplicato per 25 lingue | `lib/l10n/` | Lavoro di traduzione e righe generate che pesano sulla copertura |
| 7 | Catture dello store solo in 3 lingue | `distribution/google-play/assets/screenshots/` | Le altre 22 schede mostrano catture non nella loro lingua |
| 8 | Schede dello store caricate a mano | `distribution/google-play/`, `tool/play_api.sh` | Lavoro manuale proporzionale al numero di lingue |
| 9 | File generati versionati senza controllo di allineamento (dallo store precedente) | `lib/l10n/`, job `analyze` | Un ARB modificato senza rigenerare può passare inosservato |
| 10 | File grandi (dallo store precedente) | `lib/cellar/ui/add_wine_screen.dart`, `lib/cellar/data/wine_repository.dart` | Più difficili da modificare in sicurezza |
| 11 | `firebase-tools` fermo alla 14 | `package.json`, `README.md` | Debito dichiarato, legato a Java 17 |

## Risks for This Intent's Area

- **Copertura**: nuovi messaggi in 25 ARB aggiungono righe generate; restano coperti solo se `l10n_exercise_test.dart` viene rigenerato.
- **Nuove dipendenze Android**: una libreria di recensione aggiunge codice nativo; `tool/check_release_build.sh` blocca permessi indesiderati nel manifest unito.
- **E2E**: la presentazione è saltata scrivendo `onboarding.seen`; cambiarne chiave o flusso tocca `integration_test/e2e_helpers.dart` e `integration_test/account_test.dart`.
- **Lunghezza dei testi**: i test della matrice di accessibilità falliscono su un overflow a scala 2.0.
