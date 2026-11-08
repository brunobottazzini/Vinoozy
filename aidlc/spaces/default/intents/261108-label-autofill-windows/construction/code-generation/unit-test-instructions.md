# Istruzioni dei test — compilazione dall'etichetta e finestre per tutto il mondo

## Strumenti

- `dart test` nel pacchetto `packages/estimation`, con la copertura del pacchetto (≥ 90%) e il benchmark esistente.
- `flutter test` per l'app: unità e widget.
- `npm run test:rules` per le regole Firestore e la compatibilità, con l'emulatore Firestore.
- `./gradlew :app:testDebugUnitTest` per il codice nativo (Robolectric).
- Script `tool/*_test.sh`.

## Comandi di questo lavoro

```bash
# Pacchetto estimation: tabelle, estrattore, finestra effettiva, strumento
(cd packages/estimation && dart test)
(cd packages/estimation && dart test --coverage=coverage && dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib)
dart run packages/estimation/benchmark/estimation_benchmark.dart

# Strumento della tabella delle denominazioni
flutter test test/tool/build_appellations_test.dart

# App: modello, repository, migrazione, canale, interfaccia
flutter test test/cellar/ test/label/ test/app/

# Regole Firestore e compatibilità
npm run test:rules

# Codice nativo
(cd android && ./gradlew :app:testDebugUnitTest)

# Manifesto
tool/check_lens_manifest_test.sh
```

End-to-end, sull'emulatore Android con testo al 100% e densità di default:

```bash
flutter test integration_test/autofill_test.dart integration_test/override_test.dart -d <emulatore> --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true
```

## Riapertura: conferma guidata e risposta entro 2 secondi (FR2.8, FR7)

```bash
# Pacchetto: candidati, certezza, insieme di riferimento (BR7.9), parole
(cd packages/estimation && dart test test/label_analysis_test.dart test/label_words_test.dart)
# Benchmark: analyzeLabelText su 4000 caratteri <= 100 ms (NFR4.19, NFR5.9)
dart run packages/estimation/benchmark/estimation_benchmark.dart

# App: macchina a stati, flusso con l'analisi, controller
flutter test test/label/core/guided_session_test.dart \
  test/label/core/text_autofill_analysis_test.dart \
  test/cellar/ui/guided_confirm_controller_test.dart
# App: scheda, parole, ruota, barra e attesa nella matrice di accessibilità
flutter test test/cellar/ui/guided_confirm_test.dart

# End-to-end: guida completa, i 2 secondi con la base reale a freddo
flutter test integration_test/autofill_test.dart integration_test/label_test.dart \
  -d <emulatore> --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true
```

- **Insieme di riferimento:** `packages/estimation/test/fixtures/label_reference_set.json` (69 testi, D13). Il test controlla le percentuali di BR7.9, non il rango di ogni testo. Pesi e soglie si cambiano solo in `label_scoring.dart`, con l'insieme intero verde.
- **Tempo:** il timer di 2 secondi dell'avviso si prova con `tester.pump`; nessun orologio reale.
- **Interruzioni:** rotazione con `tester.view.physicalSize`, secondo piano con `handleAppLifecycleStateChanged`, Indietro con `handlePopRoute`, chiusura da parte di Android ricreando il modulo senza stato.
- **Regole Firestore:** la guida non salva nulla di nuovo; `test:rules` resta com'è. Con la porta 8080 già occupata da un emulatore avviato: `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm --prefix test/rules test -- u1.rules.test.mjs u7.rules.test.mjs u4.rules.test.mjs u8.rules.test.mjs label_autofill.rules.test.mjs compat/`.

## Copertura

Build and Test la controlla sulla suite completa. I limiti non si abbassano mai.
- **Progetto:** `tool/check_coverage.sh 80`, senza esclusioni.
- **Pacchetto `estimation`:** ≥ 90%, file generato compreso.
- **Cartelle:** come oggi, `tool/check_coverage.sh 80 coverage/lcov.info lib/label/` e `lib/catalog/`, più `lib/cellar/`.

## Finti e dati di prova

- **Testi delle etichette:** fixture `packages/estimation/test/fixtures/label_texts.json` (30 o più casi, risultati attesi campo per campo).
- **eAmbrosia:** `tool/fixtures/eambrosia_sample.csv`. Mai il registro reale nei test.
- **Appunti e Lens:** canale `vinoozy/lens` finto (`TestDefaultBinaryMessengerBinding`), orologio finto.
- **Firestore:** emulatore per regole, migrazione ed e2e; repository finti per i test di unità.
- **Open Food Facts e Google:** mai reali.

## Volume previsto

Strategia Standard, circa 150 test nuovi.
- **Tabelle:** un test per ogni riga dedicata e per ogni modello.
- **Estrattore:** un test per ogni testo dell'insieme di riferimento.
- **Componenti:** da 5 a 8 test per ciascuno.
- **End-to-end:** 2.
