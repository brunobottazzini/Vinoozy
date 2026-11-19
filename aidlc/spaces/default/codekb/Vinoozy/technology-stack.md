# Technology Stack

Le versioni dell'app sono i vincoli di `pubspec.yaml` (il lockfile `pubspec.lock` è versionato); quelle Node sono fissate esatte nei rispettivi `package.json`. `pubspec.yaml` riverificato il 2026-11-19; le altre tabelle vengono dallo store precedente.

## Languages

| Linguaggio | Dove | Versione |
|---|---|---|
| Dart | `lib/`, `packages/estimation/`, `test/`, `tool/*.dart`, `benchmark/` | SDK `^3.13.7` |
| Kotlin | `android/app/src/` | Dal plugin Gradle di Flutter |
| TypeScript | `functions/` | 5.9.3, `tsc` strict |
| JavaScript (ESM) | `tool/*.mjs`, `tool/admin/`, `test/rules/`, `test/admin/`, `test/web/`, `docs/account-deletion/` | Node 22 (`.nvmrc`) |
| Bash | `tool/*.sh` | — |
| Python | `tool/convert_study.py` | Script occasionale |
| HTML/CSS | `docs/privacy/`, `docs/account-deletion/` | — |

## Frameworks and Runtime

| Tecnologia | Versione | Uso |
|---|---|---|
| Flutter | 3.47.9 (`.flutter-version`, fissata in ogni workflow) | Framework dell'app |
| Android | `minSdk` 24; `compileSdk` e `targetSdk` da Flutter; `applicationId` `com.vinoozy.app` | Unica piattaforma |
| Firebase | Auth, Firestore, App Check (Play Integrity), Crashlytics, Functions 2nd gen in `europe-west8` | Backend |
| Node.js | 22 | Functions e strumenti |
| JDK | 17 per la build Android; 21 nei job `rules` ed `e2e` | Build e emulatori |

## App Libraries (`pubspec.yaml`, versione app `0.3.0+3`)

| Pacchetto | Vincolo | Uso |
|---|---|---|
| `flutter_localizations` | SDK | Localizzazioni Material, Cupertino, Widgets |
| `intl` | ^0.20.3 | Date, numeri, plurali |
| `flutter_riverpod` | ^3.4.3 | Stato e dipendenze |
| `cloud_firestore` | ^7.1.0 | Dati |
| `firebase_core` | ^5.1.0 | Avvio di Firebase |
| `firebase_auth` | ^7.0.1 | Autenticazione |
| `firebase_app_check` | ^0.5.1 | Attestazione |
| `firebase_crashlytics` | ^6.0.1 | Errori in produzione |
| `cloud_functions` | ^7.0.1 | Callable |
| `google_sign_in` | ^7.2.0 | Accesso con Google |
| `google_mlkit_text_recognition` | ^1.0.0 | Testo dell'etichetta, modello latino incluso nell'app |
| `google_mlkit_barcode_scanning` | ^1.0.0 | Codici EAN-13, EAN-8, UPC-A |
| `in_app_purchase` | ^3.3.1 | Acquisto Plus |
| `google_mobile_ads` | ^9.2.0 | Annuncio del Cruscotto |
| `http` | ^1.6.0 | Open Food Facts |
| `connectivity_plus` | ^7.3.2 | Stato della rete |
| `shared_preferences` | ^2.5.6 | Registro locale, preferenze, flag `onboarding.seen` |
| `path_provider` | ^2.1.6 | Cache del catalogo |
| `package_info_plus` | ^10.2.2 | Versione dell'app |
| `share_plus` | ^13.3.1 | Foglio di condivisione (messaggio d'invito) |
| `image_picker` | ^1.2.4 | Fotocamera e selettore foto di sistema |
| `crypto` | ^3.0.8 | Hash del proprietario della cache |
| `estimation` | path `packages/estimation` | Stima |

Assenti: `in_app_review` (recensione nell'app) e `url_launcher` (i link passano dal canale `com.vinoozy.app/links`).

Sviluppo: `flutter_test`, `integration_test`, `flutter_driver` (SDK), `flutter_lints` ^6.0.0, `mocktail` ^1.0.5. Pacchetto `estimation`: `test` ^1.33.0, `coverage` ^1.16.0, `lints` ^6.1.0, `benchmark_harness` ^2.4.0.

## Functions Libraries (`functions/package.json`)

| Pacchetto | Versione |
|---|---|
| `firebase-functions` | 7.4.0 |
| `firebase-admin` | 13.10.0 |
| `googleapis` | 189.0.0 |
| `@google-cloud/billing` | 6.2.0 |
| `mocha` | 12.0.3 |
| `firebase-functions-test` | 3.5.0 |

## Tooling (`package.json`)

| Strumento | Versione | Uso |
|---|---|---|
| `firebase-tools` | 14.27.0 | Emulatori e distribuzione; la 15 richiede Java 21 |
| `@firebase/rules-unit-testing` | 6.0.0 | Test delle regole |
| `firebase` (SDK web) | 13.2.0 | Pagina di cancellazione account |
| `esbuild` | 0.28.2 | Bundle della pagina |
| `playwright` | 1.65.0 | Prova del bundle in Chromium |
| `c8` | 12.0.0 | Copertura del codice web |
| actionlint | 1.7.12 | Validazione dei workflow |
| gitleaks | 8.30.1 | Ricerca di segreti nella cronologia |
| JaCoCo, Robolectric | Da Gradle | Test e copertura Kotlin |

## Localization Toolchain

| Elemento | Valore |
|---|---|
| Generatore | `flutter gen-l10n`, attivato da `generate: true` e configurato in `l10n.yaml` |
| Formato dei testi | ARB con sintassi ICU (`plural`, `select`, segnaposto tipizzati) |
| Modello | `lib/l10n/app_en.arb` (670 messaggi) |
| Uscita | `lib/l10n/app_localizations*.dart`, versionati, classe `AppLocalizations`, `nullable-getter: false` |
| Messaggi non tradotti | `l10n_untranslated.json` alla radice, ignorato da git (oggi `{}`) |
| Test generato | `test/l10n/l10n_exercise_test.dart` da `tool/gen_l10n_exercise.dart`: chiama ogni messaggio di ogni lingua |
| Formati | `intl` 0.20.x con `intlLocaleNameOf` e `MaterialLocalizations` |
| Lingue | 25: en (modello e ripiego), it, pt-BR, pt (europeo), fr, es, de, ca, el, ro, hu, hr, sl, cs, sk, bg, sr, ka, nl, pl, uk, da, sv, nb, fi |

## Hosting and Delivery

| Servizio | Uso |
|---|---|
| GitHub e GitHub Actions | Repository e CI/CD nel piano gratuito |
| Google Play | Canale di test interno a ogni merge, produzione con approvazione manuale e rilascio graduale; package `com.vinoozy.app` |
| GitHub Pages | Pagine di privacy e cancellazione account |
| Firebase Emulator Suite | Sviluppo e test, progetto `demo-vinoozy` |
