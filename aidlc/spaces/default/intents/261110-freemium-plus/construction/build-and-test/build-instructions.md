# Istruzioni di build — Freemium e Plus

## Dipendenze

```bash
flutter pub get
(cd packages/estimation && dart pub get)
npm ci                      # firebase-tools, test delle regole
npm ci --prefix functions   # Cloud Functions (TypeScript)
npm ci --prefix tool/admin  # script amministrativi
```

Servono Node 22 o superiore (`.nvmrc`) e la versione di Flutter indicata in `.flutter-version`. Per l'end-to-end servono anche l'Android SDK e un AVD, per esempio `Medium_Phone_API_36.1`.

## Ambiente

- **Build demo**, la predefinita: emulatori Firebase `demo-vinoozy`. Auth gira sulla porta 9099, Firestore sulla 8080, Functions sulla 5001.
- **Strumenti sviluppatore**: si attivano con `--dart-define=ENABLE_DEV_CHEATS=true`, solo nelle build non release collegate agli emulatori.
- **Build di produzione**: `--dart-define=FIREBASE_ENV=prod` e le opzioni da `config/firebase_prod.json`.
  - AdMob: senza `ADMOB_APP_ID` (variabile d'ambiente o proprietà Gradle) la build usa l'App ID di test di Google.
  - Le credenziali degli script amministrativi si passano con `--credentials <file fuori dal repo>` oppure con `GOOGLE_APPLICATION_CREDENTIALS`.

## Build

```bash
npm --prefix functions run build      # tsc → functions/lib
flutter build appbundle --release     # AAB (in CI: firmato, release.yml)
```

## Verifica della build

```bash
tool/check_release_build.sh
```

Lo script controlla i marker di test e quello degli strumenti sviluppatore `VINOOZY_DEV_CHEATS_PANEL`, che devono mancare nella release. Controlla anche i permessi del manifest: `BILLING` e `AD_ID` attesi, `CAMERA` assente.

## Problemi comuni

- **E2E che non trovano i pulsanti.** Succede se nell'AVD la scala dei caratteri è a 2.0. Riportala a 1.0 con `adb shell settings put system font_scale 1.0` prima dell'end-to-end.
- **`test:functions` fallisce su `lib/`.** Esegui prima `npm --prefix functions run build` (lo script lo fa già).
- **Callable che rispondono `unauthenticated` nell'emulatore.** Controlla che la build demo attivi il provider di debug di App Check (`lib/app/bootstrap.dart`).
