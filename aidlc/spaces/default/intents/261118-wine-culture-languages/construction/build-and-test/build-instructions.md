# Istruzioni di build — Lingue dei paesi del vino

Questo lavoro non aggiunge dipendenze né cambia il modo di costruire l'app. Le istruzioni seguono il job `unit` di `.github/workflows/ci.yml`, che è il controllo che blocca il merge in `main`.

## Prerequisiti

- Flutter 3.47.9 (`.flutter-version`), canale stable.
- Java 17 per Gradle; Android SDK con l'emulatore per i test end-to-end.
- Node secondo `.nvmrc`, per `tool/check_publication.mjs` e per gli emulatori Firebase (`npx firebase`).
- Nessun segreto in locale: le build di rilascio firmate e la configurazione di produzione arrivano solo dai segreti di GitHub Actions.

## Dipendenze

```bash
flutter pub get
npm ci                        # strumenti Node del repository
npm ci --prefix functions     # solo per gli emulatori Firebase
npm ci --prefix tool/admin    # solo per tool/e2e_freemium.sh
```

## Codice generato

```bash
flutter gen-l10n                        # testi delle 25 lingue; lib/l10n/l10n_untranslated.json deve valere {}
dart run tool/gen_coverage_helper.dart  # ogni file di lib/ conta nella copertura
dart run tool/gen_l10n_exercise.dart    # test che richiama ogni messaggio in ogni lingua
```

`node tool/gen_origin_names.mjs` rigenera `lib/cellar/domain/origin_country_names.g.dart` dai dati CLDR; serve solo quando cambia l'elenco delle lingue o dei paesi.

## Build

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
tool/check_release_build.sh   # build di rilascio, controlli del manifest, build di controllo E2E e profile
```

## Verifica della build

- `tool/check_release_build.sh` termina senza errori.
- Il manifest unito della build di rilascio (`build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml`) contiene `android:localeConfig="@xml/locales_config"`, e `locales_config.xml` elenca 25 lingue.
- `node tool/check_publication.mjs --draft` controlla i testi delle 25 schede di Google Play e le note di rilascio.

## Problemi noti

- L'avviso di Gradle sui plugin che applicano il Kotlin Gradle Plugin (Firebase) c'era già prima di questo lavoro e non blocca la build.
- Se `flutter gen-l10n` segnala messaggi non tradotti, `lib/l10n/l10n_untranslated.json` elenca lingua e chiave: completare il file ARB indicato.
- Se la copertura risulta più bassa del previsto, controllare di aver generato i due test (`gen_coverage_helper`, `gen_l10n_exercise`) prima di `flutter test --coverage`.
