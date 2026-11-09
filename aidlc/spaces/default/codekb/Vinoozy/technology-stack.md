# Stack tecnologico — Vinoozy

## Linguaggi e runtime

| Elemento | Versione | Fonte |
|---|---|---|
| Flutter | 3.47.9 | `.flutter-version` |
| Dart SDK | ^3.13.7 | `pubspec.yaml` |
| Kotlin (Android) | JVM target 17 | `android/app/build.gradle.kts` |
| Android | `minSdk 24`, `targetSdk` di Flutter | `android/app/build.gradle.kts` |
| Node.js | >= 22 (22) | `package.json`, `.nvmrc` |
| JavaScript (pagina web) | ES modules, bundle esbuild | `docs/account-deletion/` |

## Framework e librerie dell'app

| Libreria | Vincolo (lock) | Uso |
|---|---|---|
| flutter_riverpod | ^3.4.3 | Stato e iniezione |
| cloud_firestore | ^7.1.0 (7.1.0) | Dati con cache offline |
| firebase_core | ^5.1.0 | Base Firebase |
| firebase_auth | ^7.0.1 | Autenticazione |
| google_sign_in | ^7.2.0 | Accesso Google |
| firebase_app_check | ^0.5.1 | App Check |
| firebase_crashlytics | ^6.0.1 | Segnalazione errori (anche `off_suspended` e i motivi `label_*`) |
| connectivity_plus | ^7.3.2 | Stato della rete (`NetworkStatus`, usato anche dalla lettura dell'etichetta) |
| shared_preferences | ^2.5.6 (2.5.6) | Ledger e preferenze locali; non usato da etichetta e catalogo |
| path_provider | ^2.1.6 (2.1.6) | `cache/label/` e `catalog_cache.json` |
| http | ^1.6.0 (1.6.0) | Open Food Facts (`http.Client` unico per sessione) |
| crypto | ^3.0.8 | Hash SHA-256 dell'uid come proprietario della cache |
| google_mlkit_text_recognition | ^1.0.0 (1.0.0) | Testo latino on-device, modello incluso (`com.google.mlkit:text-recognition`), mai Cloud Vision |
| google_mlkit_barcode_scanning | ^1.0.0 (1.0.0) | EAN-13/EAN-8/UPC-A on-device, modello incluso (`com.google.mlkit:barcode-scanning`) |
| google_mlkit_commons | 1.0.0 (transitiva) | `InputImage` |
| image_picker | ^1.2.4 (1.2.4) | Fotocamera di sistema e selettore di foto Android, senza permessi |
| share_plus | ^13.3.1 | Invito alla condivisione |
| package_info_plus | ^10.2.2 | Versione per lo User-Agent di Open Food Facts |
| intl, flutter_localizations | ^0.20.3 / SDK | Localizzazione it, en, pt-BR |
| estimation | path | Stima e denominazioni (Dart puro) |

Dipendenze Android dirette (Gradle): `androidx.exifinterface:exifinterface:1.4.2`; test `junit:junit:4.13.2`, `org.robolectric:robolectric:4.17`, `androidx.test:core:1.7.0`.

**Assenti** (rilevante per l'intent 261107-label-recognition): nessun motore di database locale (sqflite, drift, isar, hive, objectbox), nessun `url_launcher` diretto (solo varianti di piattaforma transitive), nessun pacchetto per avviare intent verso altre app, nessun servizio di riconoscimento in cloud o a pagamento.

## Test e strumenti

| Strumento | Versione |
|---|---|
| flutter_test, integration_test, flutter_driver | SDK |
| mocktail | ^1.0.5 |
| `MockClient` di `http` | (con http 1.6.0) per i test di Open Food Facts |
| flutter_lints | ^6.0.0 |
| JUnit 4 + Robolectric | 4.13.2 / 4.17 (test Kotlin di preparatore e ricevitore) |
| bundletool | 1.18.3 (scaricato con SHA-256 da `tool/check_app_size.sh`) |
| estimation dev: test ^1.33.0, lints ^6.1.0, coverage ^1.16.0, benchmark_harness ^2.4.0 | — |
| firebase-tools | 14.27.0 |
| firebase (JS) | 13.2.0 |
| @firebase/rules-unit-testing | 6.0.0 |
| c8 | 12.0.0 |
| esbuild | 0.28.2 |
| playwright | 1.65.0 |

## Piattaforma

Firebase: Auth, Firestore, App Check, Crashlytics; Firebase Emulator Suite (`demo-vinoozy`, auth 9099, firestore 8080) per test locali e CI; un solo progetto di produzione. GitHub Actions per CI/CD, Google Play (canale di test interno e produzione), GitHub Pages. Open Food Facts (`world.openfoodfacts.org`, gratuito, dati ODbL) solo con `OFF_CONTACT` nella build di produzione.

## Configurazione di compilazione

- `FIREBASE_ENV` (`demo`/`prod`), `E2E`, `EMULATOR_HOST`, `PERF` come `--dart-define`.
- `OFF_CONTACT`: contatto per Open Food Facts, solo in `config/firebase_prod.json` (mai versionato; in CI ricostruito dal segreto `FIREBASE_PROD_DEFINES_JSON_B64` e passato con `--dart-define-from-file`). Senza di esso OFF è spento: build demo, test, e2e e CI non chiamano mai il servizio reale.

## Localizzazione

- `l10n.yaml`: `arb-dir: lib/l10n`, modello `app_en.arb`, classe `AppLocalizations`, `nullable-getter: false`.
- ARB: `app_en.arb`, `app_it.arb`, `app_pt_BR.arb`, `app_pt.arb` (solo `@@locale`). I file generati sono versionati e CI esegue `flutter gen-l10n`.
- Lingue: `appLocales` = en, it, pt-BR; build e2e sempre in italiano.
- Chiavi dell'etichetta: `addChoiceTitle`, `addChoicePhoto`, `addChoiceImport`, `addChoiceWrite`, `labelReading`, `labelRecognized`, `labelCorrect`, `labelConfirm`, `labelOfflineNotice`, `labelUnreadable`, `labelWriteByHand`, `labelNotFound`, `labelCameraDenied`, `labelPhotosDenied`, `labelOpenSettings`, `labelCameraUnavailable`, `labelBarcodeNotFound`, `labelBarcodeFrontHint`, `labelBarcodeNeedsNetwork`, `labelRetryOnline`, `labelSharedNotAllowed`, `labelSharedFirstOnly`, `labelSharedExpired`, `labelReplaceTitle`, `labelReplaceRead`, `labelReplaceKeep`, `labelWineAdded`; attribuzione `offAttribution` ("Dati da Open Food Facts (ODbL)"). Nessuna chiave per "Cerca online" o "Google Lens".
- Nomi dei paesi in it/en/pt nel codice (`wine_origins.dart`), non negli ARB.

## Risorse grafiche e tema

- **Tema**: Material 3, `ThemeMode.system`, token in `AppColors` e `StatusColors` (descrizione della scansione ux-redesign; quell'intent ha poi cambiato colori e titoli, per esempio titoli in serif di sistema secondo `docs/release-checklist.md` §1-octies).
- **Icone**: `Icons.*` di Material; le viste dell'etichetta usano `photo_camera_outlined`, `photo_library_outlined`, `edit_outlined`, `image_not_supported_outlined`, `qr_code_2_outlined`, `lock_outline`, `no_photography_outlined`.
- **Immagini e asset**: solo l'icona dell'app in `assets/icon/`; `pubspec.yaml` non ha una sezione `flutter: assets:`. Nessun file di dati incluso nell'app.
- **Bandiere**: dall'intent ux-redesign emoji di bandiera dai codici ISO (`WineOrigins.flagEmoji`) e widget `CountryFlag`.
- **Grafici**: widget disegnati a mano, nessuna libreria di grafici.

## Dimensione dell'app

- Controllo `tool/check_app_size.sh` (job `unit`): `bundletool get-size total` sull'AAB di rilascio (solo arm64, `FIREBASE_ENV=demo`) può crescere al massimo di **15 MB** sul valore di `tool/app_size_baseline.txt`.
- Il valore è ancora `UNSET`: la misura non è mai stata fatta; l'AAB precedente a u6 (24.634.405 byte) è conservato fuori da git in `android/captures/`. I modelli ML Kit inclusi sono la crescita attesa di u6.
- Nessuna misura registrata dell'APK o dell'AAB attuali.

## Aggiornamento dell'intent 261108-label-autofill-windows

- **Asset di dati**: dal working tree `pubspec.yaml` dichiara `assets: - assets/wine_db/` (`wines.jsonl.gz`, `manifest.json` con 45 vini `source: sample`, `LICENSE`, `README.md`). La frase "nessun file di dati incluso nell'app" più sopra descrive la scansione label-recognition.
- **Android**: `androidx.core.content.FileProvider` dichiarato nel manifest (`<applicationId>.labelfiles`, non esportato) per "Apri in Google Lens"; `<queries>` aggiunge il pacchetto `com.google.android.googlequicksearchbox` e `SEND` di `image/*`. Nessun intent filter per testo in ingresso.
- **Pacchetto `estimation`**: `publish_to: none`, versione 1.0.0, SDK ^3.13.7, sezione `dependencies:` vuota per contratto; sviluppo con `test` ^1.33.0, `lints` ^6.1.0, `coverage` ^1.16.0, `benchmark_harness` ^2.4.0. Il README indica una soglia di copertura del 90% per il pacchetto (oltre all'80% sull'app).
- **Lettura del testo incollato**: nessuna dipendenza in uso; `flutter/services.dart` (`Clipboard`) è usato solo in scrittura dal profilo (`Clipboard.setData`).
- **Localizzazione**: le chiavi dell'etichetta attuale comprendono `labelBack*`, `labelStep*`, `labelSource*`, `labelNotThis`, `labelCandidates*`, `labelNoMatch`, `labelReadText`, `labelSearchOnline`, `labelOpenLens`, `labelLens*`; la finestra usa `uxIdealUntil` ("Consigliato fino al {year}"), `uxIdealUntilPast`, `uxIdealBest`, `windowStartLabel`, `windowPeakLabel`, `windowEndLabel`, `estimateSource*`, `drinkSoonUntil`. Nessuna chiave per "Incolla", "Livello" o correzione manuale della fine.

## Aggiornamento dell'intent 261108-wine-style-profiles

- **Dati inclusi nell'app**: `assets/wine_db/wines.jsonl.gz` (15.616 vini da Open Food Facts, export 2026-11-07, ODbL, 339.982 byte compressi, 1.254.545 non compressi) al posto del campione di 45; tabelle delle denominazioni come costanti Dart nel pacchetto `estimation` (2424 denominazioni, di cui 1700 generate in `appellations.g.dart`, più 46 vitigni).
- **Generatori offline**: `tool/build_wine_db.dart` (export CSV di Open Food Facts, circa 1 GB, scaricato a mano, mai in CI) e `tool/build_appellations.dart` (eAmbrosia e CSV di `tool/data/appellations/`); entrambi importano il pacchetto `estimation` e il codice dell'app (`package:vinoozy/...`). Controlli di rilascio: `tool/check_wine_db_release.sh`, `tool/check_appellations_release.sh` (rifiutano `source: sample`).
- **Persistenza locale**: `shared_preferences` conserva i tentativi della migrazione delle stime (`estimates.migration.v<n>`).
- **Localizzazione**: le chiavi di tipo (`typeRedLight` … `typeFortified`), famiglia (`uxFamily*`, `family*`), livello (`levelLabel`, `levelEveryday`, `levelGood`, `levelAging`, `levelNone`, `levelSuggested*`), origine della stima (`estimateFrom*`) e correzione (`overrideCorrectedByYou`, …) esistono in it, en e pt-BR. Un nuovo stile o un nuovo tipo richiede chiavi nuove nei tre file ARB.

Dipendenze dettagliate e relazioni in [dependencies.md](dependencies.md).
