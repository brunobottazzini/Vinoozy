# Istruzioni dei test di unità — wine-style-profiles

## Strumenti

- Pacchetto `estimation`: `dart test --coverage=coverage`, poi `dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib` e `../../tool/check_coverage.sh 90 coverage/lcov.info`.
- App: `dart run tool/gen_coverage_helper.dart`, `flutter test --coverage`, poi la copertura unita come in CI: `cat coverage/lcov.info packages/estimation/coverage/lcov.info > coverage/merged.lcov.info` e `tool/check_coverage.sh 80 coverage/merged.lcov.info` (senza esclusioni).
- Regole Firestore: emulator sulla porta 8080; se è già avviato da un'altra sessione, `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm --prefix test/rules test -- <file> compat/` (non avviarne un altro, non fermarlo).
- End-to-end: emulatore Android (`emulator-5554`) e Firebase Emulator Suite: `flutter test integration_test/style_profile_flow_test.dart -d emulator-5554 --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true`. Prima di lanciarlo, esegui un file di test delle regole correnti (per esempio `style_profiles.rules.test.mjs`): i test delle regole caricano le loro regole nello stesso progetto `demo-vinoozy` e `compat/` vi lascia quelle di produzione.

## Comandi di questo lavoro

```bash
(cd packages/estimation && dart test test/profiles_test.dart test/profile_map_test.dart test/classifier_test.dart test/month_window_test.dart test/revision60_test.dart test/classification_sample_test.dart)
flutter test test/cellar/style_migration_test.dart test/cellar/estimates_migration_test.dart test/cellar/data/wine_repository_style_test.dart test/cellar/ui/style_widgets_test.dart test/cellar/ui/autofill_form_test.dart test/dashboard/style_dashboard_test.dart test/tool/build_profile_map_test.dart test/tool/build_wine_db_classify_test.dart
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm --prefix test/rules test -- style_profiles.rules.test.mjs compat/
(cd packages/estimation && dart run benchmark/estimation_benchmark.dart)
```

Il comando eseguito prima del primo test (Step 2) è stato `(cd packages/estimation && dart test)` sul codice di partenza: 1886 test verdi; app `flutter test`: 2501 test verdi.

## Obiettivi

- Pacchetto ≥ 90%, progetto ≥ 80% senza esclusioni.
- Strategia Standard: 5–8 test per componente, più la fixture della mappa (5946 casi) e il campione di 100 vini.
- Soglie bloccanti del campione (NFR4.3): Tipologia ≥ 95% e Livello ≥ 85% sui vini preselezionati, Livello sopra "sempre Buono", nessuna Tipologia ai vini senza indizi.
- Base spedita (FR2.1, BR9.5): la quota ricalcolata coincide con `classifiedTypeShare` del manifest ed è almeno 84% (accettato dal proprietario); il 90% è l'obiettivo e viene stampato.

## Mock e dati

- Fixture `packages/estimation/test/fixtures/profile-map.json` e `classification-sample.json`, copiate dal Functional Design.
- La base di dati dello studio `tool/data/study/study_db.json` (convertita una volta dall'Excel con `tool/convert_study.py`) è la fonte del generatore `tool/build_profile_map.dart`: `test/tool/build_profile_map_test.dart` verifica 24 profili e 5946 combinazioni, che la mappa costruita coincida con la fixture campo per campo (codici di scarto compresi) e che `generated/profile_map.g.dart` sia quello che il generatore scrive oggi.
- La migrazione si prova con un doppio di `WineRepository.migrateWine` (giri, rifiuti, ripresa, fuori rete) e la transazione con i mock di Firestore (`MockTransaction`); il percorso reale con le regole è nell'e2e su emulatore.
- Firestore solo su emulator; nessuna chiamata reale a Open Food Facts o Google (la base offline dei test è quella spedita, letta da file).
