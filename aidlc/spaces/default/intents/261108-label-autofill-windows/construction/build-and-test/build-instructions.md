# Istruzioni di build

## Fonti

- `construction/code-generation/unit-test-instructions.md`
- `docs/release-checklist.md`

## Prerequisiti

- Flutter della versione in `.flutter-version`, Node della versione in `.nvmrc`, Java 17, Android SDK.
- Firebase CLI: `node_modules/.bin/firebase` (dopo `npm ci`).

## Comandi

```bash
flutter pub get
dart run tool/gen_coverage_helper.dart
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
(cd packages/estimation && dart analyze --fatal-infos && dart test --coverage=coverage)
flutter test --coverage
bash tool/check_appellations_release.sh
bash tool/check_wine_db_release.sh
```

## Build per il telefono del proprietario (debug, progetto reale)

```bash
flutter build apk --debug --dart-define-from-file=config/firebase_prod.json --dart-define=OFF_CONTACT=<email di contatto>
adb -s <id del telefono> install -r -t build/app/outputs/flutter-apk/app-debug.apk
```

`config/firebase_prod.json` non è nel repository e non si legge né si modifica. Questa parte del lavoro non cambia le regole Firestore: non serve pubblicarle prima dell'installazione.

## Build di rilascio

La fa GitHub Actions a ogni merge in `main` (AAB firmato verso il canale di test interno), con chiave e credenziali solo nei segreti.

## Dati scaricati

Gli export di eAmbrosia e Open Food Facts stanno in `.cache/` (ignorata da git). Entrano nel repository solo la tabella generata, la base generata, i manifesti e le licenze.
