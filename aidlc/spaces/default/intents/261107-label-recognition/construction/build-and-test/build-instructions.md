# Istruzioni di build — riconoscimento delle etichette

## Prerequisiti

- Flutter come in `.flutter-version`, Node 22 come in `.nvmrc`, Java 17, Android SDK.
- Firebase CLI del progetto: `node_modules/.bin/firebase`, dopo `npm ci`.
- `jq`, usato da `tool/check_wine_db_release.sh`.

## Build locali

```bash
flutter pub get
flutter gen-l10n
# build di sviluppo con gli emulatori
flutter build apk --debug --dart-define=FIREBASE_ENV=demo
# build per il telefono del proprietario con il progetto reale
flutter build apk --debug --dart-define-from-file=config/firebase_prod.json --dart-define=OFF_CONTACT=bottazzinibruno@gmail.com
adb -s <id-telefono> install -r build/app/outputs/flutter-apk/app-debug.apk
```

- `config/firebase_prod.json` è escluso da git e resta sul computer del proprietario.
- `OFF_CONTACT` accende "Cerca online" su Open Food Facts. Per le build ufficiali il proprietario lo aggiunge a `config/firebase_prod.json` e al segreto `FIREBASE_PROD_DEFINES_JSON_B64` di GitHub (`docs/firebase-setup.md` §9).

## Base offline dei vini

L'app contiene oggi la base di prova: 45 vini, `"source": "sample"`. Per generare la base reale:

```bash
# 1. scaricare a mano l'export CSV di Open Food Facts (file pubblico, gratuito)
# 2. generare la base
dart run tool/build_wine_db.dart --input <export.csv.gz> --output assets/wine_db/
# 3. controllo di rilascio
tool/check_wine_db_release.sh assets/wine_db/manifest.json
```

Lo strumento si ferma con errore e non scrive la base se:
- i vini sono meno di 5000;
- ci sono codici duplicati;
- l'export ha più di 180 giorni;
- il file compresso supera 3 MB;
- i dati non compressi superano **30 MB** (limite posto dal proprietario).

`promote.yml` blocca la promozione in produzione con una base di prova.

## Regole Firestore

Questo lavoro non cambia `firestore.rules`. Le regole della UX (campo `country`) sono state pubblicate su `vinoozy-d6f45` il 2026-11-07 con l'OK del proprietario (messaggio 58da8dd7).
