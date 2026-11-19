# Developer Code Scan — Vinoozy (intent `261119-tester-feedback`)

Scansione focalizzata, profondità Minimal, commit `375a581d45c96d9a0a4935e36e025c2d27bb7086` più le modifiche non ancora committate del working tree. Sola lettura: nessun test, build o programma eseguito.

## Developer Code Scan Results

### Scan Coverage
- **Analyzed deeply**:
  - `lib/app/home_shell.dart`
  - `lib/app/external_links.dart`
  - `lib/app/locale_resolution.dart`
  - `lib/app/ui/about_screen.dart`
  - `lib/app/ui/brand_footer.dart`
  - `lib/account/onboarding_flag.dart`
  - `lib/account/account_providers.dart`
  - `lib/account/ui/onboarding_screen.dart`
  - `lib/account/ui/profile_screen.dart`
  - `lib/account/ui/account_gate_view.dart`
  - `lib/sharing/ui/share_launcher.dart`
  - `lib/l10n/app_en.arb`
  - `l10n.yaml`
  - `pubspec.yaml`
  - `android/app/src/main/AndroidManifest.xml`
  - `android/app/src/main/res/xml/locales_config.xml`
  - `distribution/google-play/README.md`
  - `distribution/google-play/languages.json`
  - `distribution/google-play/release-notes.txt`
  - `distribution/google-play/it-IT/`
  - `distribution/google-play/en-US/`
- **Skimmed only**:
  - `lib/app/bootstrap.dart` (iniezione dei provider, righe 280-345), `lib/app/providers.dart`, `lib/app/vinoozy_app.dart`
  - `lib/account/` (resto: `account_gate.dart`, `data/`, `deletion/`, altre schermate in `ui/`)
  - `lib/sharing/` (resto; in `ui/sharing_screen.dart` solo il messaggio d'invito, righe 190-215)
  - `lib/usage/` (solo `usage_providers.dart` e la struttura di `cloud_usage_meter.dart`)
  - `lib/l10n/` (altri 24 ARB: solo numero di chiavi; file generati: solo dimensione)
  - `lib/cellar/ui/cellar_screen.dart` (solo il menu `_CellarMenu`, fuori dai percorsi del brief)
  - `android/app/src/main/kotlin/com/vinoozy/vinoozy/MainActivity.kt` (solo il canale `links`)
  - `android/app/build.gradle.kts` (solo `applicationId`, `namespace`, `minSdk`; fuori dai percorsi del brief)
  - `distribution/google-play/` (altre 23 cartelle di scheda, `assets/`, `data-safety.*`, istruzioni per tester e revisori: solo elenco)
  - `test/app/`, `test/account/`, `test/sharing/`, `test/usage/`, `test/l10n/`, `integration_test/` (solo nomi dei file e ricerche mirate)
- **Left out**:
  - `build/`
  - `.dart_tool/`
  - `coverage/`
  - `node_modules/`
  - `android/.gradle/`
  - `l10n_untranslated.json` (ignorato da git; visto solo il contenuto `{}`)
  - installazione di AI-DLC (`.claude/`, `aidlc/` e simili)

### Packages Found
- `vinoozy` — app — Dart/Flutter — app Android della cantina (`pubspec.yaml`, versione `0.3.0+3`)
- `estimation` — libreria path — Dart — stima (non analizzata in questo giro)

### Build System
- **Type**: Flutter (pub) + Gradle Kotlin DSL per Android
- **Config Files**: `pubspec.yaml`, `l10n.yaml`, `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`
- **Build Dependencies**: `vinoozy → estimation (path)`; `flutter: generate: true` → `flutter gen-l10n` da `l10n.yaml`

### APIs Discovered
- Canale di piattaforma — `lib/app/external_links.dart` ↔ `MainActivity.kt` — `com.vinoozy.app/links`, metodo `open` (solo `https` con host; `Intent.ACTION_VIEW` + `CATEGORY_BROWSABLE`)
- Interfaccia interna — `lib/sharing/ui/share_launcher.dart` — `ShareLauncher.share({text, subject})`, `shareLauncherProvider`, costante `playStoreLink`
- Provider interni — `lib/account/account_providers.dart` — `onboardingFlagProvider`, `onboardingSeenProvider` (`markSeen()`), `privacyPolicyUrlProvider`
- Nessuna API di recensione o di valutazione dell'app.

### Frameworks & Libraries
- Flutter — 3.47.9 (`.flutter-version`, dallo store precedente) — framework
- `flutter_riverpod` — ^3.4.3 — stato e dipendenze
- `share_plus` — ^13.3.1 — foglio di condivisione Android (già usato per gli inviti)
- `shared_preferences` — ^2.5.6 — flag `onboarding.seen`
- `package_info_plus` — ^10.2.2 — versione mostrata nel piè di pagina e in "Informazioni"
- `intl` ^0.20.3, `flutter_localizations` (SDK) — localizzazione
- **Assenti**: `in_app_review`, `url_launcher` (nessuna occorrenza in `pubspec.yaml`)

### Test Coverage
- **Test Directories**: `test/app/` (`home_shell_test.dart`, `external_links_test.dart`, `about_screen_test.dart`, `language_consistency_test.dart`, `locale_resolution_languages_test.dart`), `test/account/` (`account_ui_test.dart`, `privacy_url_languages_test.dart`, …), `test/sharing/` (`sharing_screen_test.dart`, …), `test/plan/ui/profile_plan_and_plus_screen_test.dart`, `test/l10n/l10n_exercise_test.dart`, `integration_test/account_test.dart` (salta l'onboarding con `onboarding-skip`), `integration_test/e2e_helpers.dart` (scrive `onboarding.seen` per saltarlo)
- **Test Frameworks**: `flutter_test`, `mocktail`, `integration_test`
- **Coverage Config**: presente (soglia 80% su tutto `lib/`, generato compreso; vedi store, `code-quality-assessment.md`)

### Code Quality Indicators
- **Linting**: `flutter_lints` in `analysis_options.yaml` (dallo store)
- **CI/CD**: `.github/workflows/` (non riletti in questo giro); `tool/check_publication.mjs` controlla le schede in `distribution/`
- **Documentation**: commenti di testata con riferimenti alle regole (BR/FR/NFR); `distribution/google-play/README.md` in italiano

### Technical Debt Signals
- Non esiste una schermata "Impostazioni": le voci di account stanno in `ProfileScreen` (`lib/account/ui/profile_screen.dart`), aperta dal menu a tendina della Cantina (`_CellarMenu` in `lib/cellar/ui/cellar_screen.dart`, righe 223-275), insieme a "Persone", "Bevuti" e "Informazioni".
- `onboardingPageOf` = `"Page {page} of 3"` in `lib/l10n/app_en.arb` (riga 548): il numero di pagine è scritto nel testo in 25 lingue, oltre che in `OnboardingScreen.pageCount = 3`.
- Doppio stato di onboarding: flag locale `onboarding.seen` (decide la presentazione) e campo cloud `onboardingSeen` del profilo (`lib/cellar/domain/user_profile.dart`), che parte `false` e non decide nulla nell'interfaccia letta.
- `openExternalLink` accetta solo `https`: un link `market://` verrebbe rifiutato.
- `playStoreLink` vive nel modulo Sharing (`lib/sharing/ui/share_launcher.dart`), non in un punto condiviso dell'App Shell.
- Le catture dello store esistono solo per `it`, `en`, `pt-BR`, mentre le schede testuali sono 25.

## Handoff Summary
- **Intent-relevant finding**: (1) Onboarding: `OnboardingScreen` a 3 pagine con "Salta"/"Avanti"/"Inizia", mostrata prima del login da `_SignInOrOnboarding` (`lib/account/ui/account_gate_view.dart:74-88`) finché `onboarding.seen` in `SharedPreferences` è falso (`lib/account/onboarding_flag.dart`); nessun meccanismo di suggerimenti contestuali esiste. (2) Impostazioni: nessuna schermata dedicata; il punto naturale è `ProfileScreen` o il menu `_CellarMenu`. (3) Condivisione: `share_plus` ^13.3.1 già presente, con `ShareLauncher`/`shareLauncherProvider` sostituibili nei test e `playStoreLink = https://play.google.com/store/apps/details?id=com.vinoozy.app` (`lib/sharing/ui/share_launcher.dart:25`). (4) Valutazione: `in_app_review` e `url_launcher` assenti; i link esterni passano dal canale `com.vinoozy.app/links` (solo https). (5) Localizzazione: 25 ARB da 670 messaggi, modello `app_en.arb`, `l10n_untranslated.json` (ignorato, oggi `{}`), file generati versionati, test generato `test/l10n/l10n_exercise_test.dart` da `tool/gen_l10n_exercise.dart`. (6) Store: `distribution/google-play/<scheda>/{title,short-description,full-description}.txt` per 25 schede (limiti 30/80/4000), `languages.json`, `release-notes.txt` con un blocco per scheda; package `com.vinoozy.app`.
- **Risks / follow-up**: ogni nuovo testo va aggiunto in 25 ARB e rigenerato (codice generato e test di esercizio) per non abbassare la copertura all'80% senza esclusioni; una nuova dipendenza Android (`in_app_review`) va verificata contro i controlli del manifest di rilascio (`tool/check_release_build.sh`, permessi rimossi); `language_consistency_test.dart` lega `appLocales`, `locales_config.xml`, `languages.json` e cartelle dello store; i test E2E saltano l'onboarding scrivendo la chiave `onboarding.seen`, quindi cambiare la chiave o il flusso tocca `integration_test/e2e_helpers.dart` e `integration_test/account_test.dart`.
