# Istruzioni di build — Vinoozy

Queste istruzioni valgono per l'app Android (Flutter), per il pacchetto Dart `packages/estimation`, per le regole di Firestore e per la pagina web di cancellazione dell'account (`docs/account-deletion/`). I comandi sono gli stessi che gira `.github/workflows/ci.yml`.

## Prerequisiti

| Strumento | Versione | Da dove |
|---|---|---|
| Flutter (canale stable) | `3.47.9` | `.flutter-version` |
| Dart | quella inclusa in Flutter | — |
| Node.js | 22 o più recente | `.nvmrc`, `package.json` → `engines` |
| Java | 17 (Gradle, Robolectric); quella richiesta da `firebase-tools` per gli emulatori | `ci.yml` |
| Android SDK | API 34 per la CI, un AVD x86_64/arm64 in locale | `ci.yml`, job `e2e` |
| Chromium per Playwright | installato da `npx playwright install chromium` | `package.json` |

Tutti gli strumenti Node (`firebase-tools`, `@firebase/rules-unit-testing`, `c8`, `esbuild`, `playwright`) sono fissati in `package.json` e si installano con `npm ci` alla radice: nessuna installazione globale.

## Preparazione dell'ambiente

1. Dipendenze Dart e Flutter:

   ```bash
   flutter pub get
   (cd packages/estimation && dart pub get)
   ```

2. Dipendenze Node:

   ```bash
   npm ci
   ```

3. Testi tradotti (it, en, pt-BR):

   ```bash
   flutter gen-l10n
   ```

4. **Configurazione Firebase.**
   - Test e build di prova usano il progetto finto `demo-vinoozy` sulla Firebase Emulator Suite (`--dart-define=FIREBASE_ENV=demo`). Non serve nessuna chiave.
   - La build di produzione legge i valori da `config/firebase_prod.json` con `--dart-define-from-file`. Quel file e `google-services.json` restano **fuori dal repository** e in CI arrivano solo dai segreti di GitHub Actions (vedi `docs/firebase-setup.md`).
   - `docs/account-deletion/firebase-config.js` contiene solo segnaposto `TODO`. I valori veri li inserisce il proprietario prima della pubblicazione su GitHub Pages.

## Comandi di build

| Cosa | Comando |
|---|---|
| Formattazione | `dart format --output=none --set-exit-if-changed .` |
| Analisi statica | `flutter analyze --fatal-infos` |
| Analisi del pacchetto di stima | `cd packages/estimation && dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && ../../tool/check_estimation_purity.sh` |
| Bundle della pagina web | `npm run build:web` (esbuild, scrive `docs/account-deletion/app.bundle.js`) |
| APK di debug | `flutter build apk --debug --dart-define=FIREBASE_ENV=demo` |
| Build di rilascio di prova (senza codice di test, manifest controllato) | `tool/check_release_build.sh` |
| AAB firmato di produzione | solo in `.github/workflows/release.yml`, con i segreti di firma e `config/firebase_prod.json` ricostruito dai segreti |

## Verifica della build

- `flutter analyze --fatal-infos` e `dart format` escono con 0.
- I controlli del repository escono con 0: `tool/check_off_config.sh`, `tool/check_dashboard_readonly.sh`, `tool/check_label_imports.sh`, `tool/check_web_pins.sh`, `tool/check_firestore_indexes.sh` e i loro `_test.sh`.
- `tool/check_release_build.sh` conferma che la build di rilascio non contiene `EmulatorGoogleAuthService`, i segnali `PERF` e le permission della fotocamera o delle foto, e che il filtro di condivisione accetta solo `image/*`.
- Nessun file di produzione nel repository: il passo "No production config or keystores committed" di `ci.yml`.

## Problemi comuni

| Sintomo | Causa probabile | Soluzione |
|---|---|---|
| `dart format` fallisce su file generati | `flutter gen-l10n` non eseguito dopo un cambio degli `.arb` | rigenerare e riformattare |
| Gli emulatori Firebase non partono | Java troppo vecchio per `firebase-tools`, porte 8080/9099 occupate | aggiornare Java, chiudere l'altro processo |
| `flutter test integration_test` non trova un dispositivo | nessun AVD avviato | `emulator -avd <nome>` e attendere `adb devices` |
| Il test E2E non raggiunge gli emulatori | l'emulatore Android vede il computer come `10.0.2.2` | lasciare gli emulatori su `127.0.0.1`, il codice E2E usa già `10.0.2.2` |
| Copertura sotto soglia dopo un nuovo file | il file non ha test (conta come 0%) | scrivere i test; la soglia non si abbassa e nessun file si esclude |
| `tool/check_release_build.sh` segnala codice di test nel rilascio | un import di `lib/e2e/` fuori dai punti ammessi | togliere l'import dal percorso di rilascio |
