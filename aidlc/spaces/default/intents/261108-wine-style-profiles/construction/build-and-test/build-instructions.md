# Istruzioni di build — profili di stile e classificazione automatica

## Fonti

- `construction/code-generation/code-generation-plan.md`
- `construction/code-generation/unit-test-instructions.md`
- `construction/code-generation/code-summary.md`
- `docs/release-checklist.md` (§1-undecies)

## Prerequisiti

- Flutter della versione in `.flutter-version`, Node della versione in `.nvmrc`, Java 17, Android SDK.
- Firebase CLI: `node_modules/.bin/firebase` (dopo `npm ci`).
- Python 3 solo per riconvertire lo studio (`tool/convert_study.py`, solo libreria standard); non serve alla build.

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

## Dati generati di questo lavoro

- **Lo studio**: `tool/data/study/study_db.json` è la fonte della verità ("Excel + correzioni", messaggio 141399c1). Si rigenera dall'Excel solo se lo studio cambia: `python3 -I tool/convert_study.py <percorso dell'xlsx> tool/data/study/study_db.json`.
- **La mappa dei profili**: `dart run tool/build_profile_map.dart` scrive `packages/estimation/lib/src/generated/profile_map.g.dart`; `test/tool/build_profile_map_test.dart` fallisce se il file nel repository non è quello che il generatore scrive oggi.
- **La base offline classificata**: `dart run tool/build_wine_db.dart` dall'export in `.cache/off/` (ignorata da git) scrive `assets/wine_db/` in formato 2 con `classifiedTypeShare` nel manifest. Dura circa 3 min 30 s, quasi tutto per leggere l'export compresso.

## Regole Firestore

`firestore.rules` è cambiato in questo lavoro. Prima di installare una build nuova sul telefono si pubblica, **solo con l'OK del proprietario**:

```bash
node_modules/.bin/firebase deploy --only firestore:rules --project vinoozy-d6f45
```

Prima di ogni modifica alle regole rieseguire i test "expression budget" di `test/rules/style_profiles.rules.test.mjs`: il margine sotto il limite di 1000 espressioni è stretto (10–40 termini).

## Build per il telefono del proprietario (debug, progetto reale)

```bash
flutter build apk --debug --dart-define-from-file=config/firebase_prod.json --dart-define=OFF_CONTACT=<email di contatto>
adb -s <id del telefono> install -r -t build/app/outputs/flutter-apk/app-debug.apk
```

`config/firebase_prod.json` non è nel repository e non si legge né si modifica.

## Build di rilascio

La fa GitHub Actions a ogni merge in `main` (AAB firmato verso il canale di test interno), con chiave e credenziali solo nei segreti. `promote.yml` controlla che le regole pubblicate includano `style-profiles`.

## Problemi noti

- Il caricamento dei test d'integrazione fallisce in questo ambiente con `WebSocketChannelException: Connection closed before full header was received` (collegamento al servizio VM attraverso adb). Fuori da questo ambiente i test partono normalmente: vedi `integration-test-instructions.md`.
- `npm run test:rules` avvia un suo emulatore sulla porta 8080: se è già occupata usare `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm --prefix test/rules test -- <file>`.
