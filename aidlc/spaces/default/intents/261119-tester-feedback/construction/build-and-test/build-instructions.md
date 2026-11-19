# Istruzioni di build — Miglioramenti dal report dei tester (0.4.0)

## Prerequisiti

- Flutter **3.47.9** (lo stesso di `.flutter-version` e di GitHub Actions).
- Java 17 per Gradle (build Android e test Robolectric); Java 21 e Node (`.nvmrc`) per i Firebase Emulator.
- Android SDK con un AVD (in locale: `Medium_Phone_API_36.1`) per i test end-to-end.
- Nessuna variabile segreta serve per build e test locali: le build E2E usano `--dart-define=FIREBASE_ENV=demo` e il progetto `demo-vinoozy` degli emulatori.

## Dipendenze

```bash
flutter clean            # obbligatorio dopo un'esecuzione Gradle diretta: toglie integration_test da GeneratedPluginRegistrant
flutter pub get          # scarica anche in_app_review ^2.0.12, nuovo in questa versione
flutter gen-l10n         # 25 lingue, 716 messaggi ciascuna
npm ci                   # strumenti Node (emulatori, controlli di pubblicazione)
```

## Build e controlli statici

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
node tool/check_publication.mjs --draft     # schede dello store e note di rilascio entro i limiti
tool/check_release_build.sh                 # build di rilascio senza codice di test, manifest senza permessi nuovi
```

## Verifica della build

- `tool/check_release_build.sh` termina con codice 0: nella build di rilascio non ci sono i marcatori E2E/PERF/dev e il manifest unito non dichiara CAMERA, READ_MEDIA_IMAGES, READ_EXTERNAL_STORAGE né AD_ID.
- Il bundle resta in `build/check_release/app-release.aab`.

## Problemi noti

- **`compileReleaseJavaWithJavac` fallisce su `integration_test`**: il `GeneratedPluginRegistrant.java` locale è rimasto dalla build di debug o dai test Gradle. Eseguire `flutter clean` e `flutter pub get`, poi rilanciare.
- **Testi mancanti dopo una modifica agli ARB**: rieseguire `flutter gen-l10n` e `dart run tool/gen_l10n_exercise.dart`.
- **La finestra di In-App Review non compare** in build installate fuori da Google Play: è il comportamento previsto di Play, non un errore; si prova dalla build del canale di test interno.
