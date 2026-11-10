# Stack tecnologico

## Linguaggi e runtime

| Elemento | Versione | Fonte |
|---|---|---|
| Dart SDK | `^3.13.7` (lock: `>=3.13.7 <4.0.0`) | `pubspec.yaml`, `pubspec.lock` |
| Flutter | 3.47.9 (canale stable; lock `>=3.47.0`) | `.flutter-version` |
| Kotlin / Java | JVM target 17 | `android/app/build.gradle.kts` |
| Android | `minSdk 24`, `compileSdk`/`targetSdk` da Flutter, `applicationId com.vinoozy.app` | `android/app/build.gradle.kts` |
| Node.js | 22 (`engines >=22`) | `.nvmrc`, `package.json` |
| Python | 3, solo `tool/convert_study.py` (strumento una tantum) | `tool/` |

## Dipendenze dell'app (`pubspec.yaml`, versioni bloccate in `pubspec.lock`)

| Pacchetto | Versione | Uso |
|---|---|---|
| flutter_riverpod | 3.4.3 | Stato e DI |
| cloud_firestore | 7.1.0 | Dati offline-first |
| firebase_core | 5.1.0 | Inizializzazione |
| firebase_auth | 7.0.1 | Accesso |
| firebase_app_check | 0.5.1 | Play Integrity |
| firebase_crashlytics | 6.0.1 | Errori in produzione |
| google_sign_in | 7.2.0 | Accesso Google |
| google_mlkit_text_recognition | 1.0.0 | Testo etichetta sul telefono |
| google_mlkit_barcode_scanning | 1.0.0 | Codici a barre sul telefono |
| shared_preferences | 2.5.6 | Ledger, flag, preferenze |
| connectivity_plus | 7.3.2 | Stato rete |
| http | 1.6.0 | Open Food Facts |
| image_picker | 1.2.4 | Fotocamera e galleria senza permessi |
| share_plus | 13.3.1 | Messaggio d'invito |
| package_info_plus | 10.2.2 | Versione app |
| path_provider | 2.1.6 | Cache del catalogo |
| intl | 0.20.3 | Date e numeri |
| crypto | 3.0.8 | Hash del file di cache |
| flutter_localizations | SDK | it, en, pt_BR |
| estimation | path `packages/estimation` | Stima (nessuna dipendenza di produzione) |

Dev: `flutter_test`, `integration_test`, `flutter_driver` (SDK),
`flutter_lints` 6.0.0, `mocktail` 1.0.5. Pacchetto `estimation` dev:
`benchmark_harness` ^2.4.0, `coverage` ^1.16.0, `lints` ^6.1.0, `test` ^1.33.0.

**Assenti e richiesti dall'intent**: nessun plugin di Billing
(`in_app_purchase` o equivalente), nessun SDK pubblicitario
(`google_mobile_ads`), nessun CMP, nessun `cloud_functions`.

## Android nativo

| Libreria | Versione |
|---|---|
| androidx.exifinterface | 1.4.2 |
| JUnit | 4.13.2 (test) |
| Robolectric | 4.17 (test) |
| androidx.test:core | 1.7.0 (test) |
| JaCoCo | 0.8.14 |

## Strumenti Node (`package.json`, lock in `package-lock.json`)

| Pacchetto | Versione | Uso |
|---|---|---|
| firebase-tools | 14.27.0 | Emulator Suite, deploy regole (bloccato per JDK 17) |
| @firebase/rules-unit-testing | 6.0.0 | Test delle regole |
| firebase | 13.2.0 | Web SDK della pagina di cancellazione |
| esbuild | 0.28.2 | Bundle della pagina web |
| c8 | 12.0.0 | Copertura JS |
| playwright | 1.65.0 | Test della pagina nel browser |

## Servizi esterni

- Firebase: Auth (Google), Firestore, App Check (Play Integrity), Crashlytics;
  progetto demo `demo-vinoozy` per emulatori e un solo progetto di produzione
  (`.firebaserc`). Piano attuale Spark.
- Google Play (canale interno come staging, produzione con rilascio graduale),
  Play Developer API (`tool/play_api.sh`).
- GitHub Actions e GitHub Pages (privacy e cancellazione account).
- Open Food Facts (catalogo e base dati offline derivata, licenza ODbL).
- Google Lens (app esterna, tramite intent).

## Configurazione di qualità

`analysis_options.yaml` include `package:flutter_lints/flutter.yaml` senza
regole aggiuntive ed esclude `build/**`, `android/**`, `packages/**`,
`tool/fixtures/**`. Formattazione `dart format`. Dettagli dei gate in
`code-quality-assessment.md`.
