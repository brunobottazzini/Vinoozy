# Istruzioni dei test — riconoscimento delle etichette

## Strumenti

- `flutter test` per i test di unità e dei widget, già configurato. Nessuna configurazione nuova.
- `dart test` per i test dello strumento in `tool/`.
- Script shell esistenti in `tool/` per i controlli statici.
- I test dei widget usano le utilità di prova già presenti (`test/label/ui/label_ui_harness.dart`, `test/label/label_harness.dart`, `test/catalog/catalog_test_helpers.dart`).

## Comandi di questo lavoro

Ogni comando riguarda solo questo lavoro.

```bash
# Base offline, punteggio, benchmark
flutter test test/catalog/offline/

# Caricatore, rete, eventi, coordinatore, ricerca online, Open Food Facts
flutter test test/catalog/wine_db_loader_test.dart test/catalog/connectivity_network_status_test.dart test/catalog/crashlytics_catalog_event_logger_test.dart test/catalog/catalog_coordinator_test.dart test/catalog/online_search_test.dart test/catalog/open_food_facts_source_test.dart

# Fronte e retro, sessione, file temporanei, canale Lens, EXIF
flutter test test/label/core/ test/label/platform/

# Interfaccia (matrice lingue × testo × tema)
flutter test test/label/ui/ test/app/about_screen_test.dart

# Strumento di costruzione della base
flutter test test/tool/build_wine_db_test.dart

# Controllo del manifest
tool/check_lens_manifest_test.sh
```

L'end-to-end gira come gli altri, sull'emulatore Android con 4 core e la Firebase Emulator Suite:

```bash
flutter test integration_test/label_test.dart -d <emulatore>
```

## Copertura

La soglia è l'80% delle righe sul progetto intero, senza esclusioni (`team.md`). La controlla Build and Test sulla suite completa:

```bash
tool/check_coverage.sh 80
```

Per NFR4.1 si controllano anche le cartelle prese da sole. Ogni comando è a sé:

```bash
tool/check_coverage.sh 80 coverage/lcov.info lib/label/
tool/check_coverage.sh 80 coverage/lcov.info lib/catalog/
```

Le soglie non si abbassano mai.

## Finti e dati di prova

- **Open Food Facts:** client HTTP finto (`MockClient` di `package:http/testing.dart`), mai la rete vera (NFR4.4).
- **Rete:** `NetworkStatus` finto con stato impostabile.
- **Base offline:** base costruita in memoria dai test, oppure dall'estratto `tool/fixtures/off_wines_sample.csv.gz`.
- **Benchmark:** base sintetica di 20.000 e di 50.000 vini generata nel test con un seme fisso.
- **Isolate:** `runInBackground` iniettato che registra le chiamate.
- **Lens:** canale `vinoozy/lens` finto con `TestDefaultBinaryMessengerBinding`; mai Google vero.
- **Foto:** sorgente finta esistente. Per il test EXIF, un JPEG di prova con EXIF e GPS generato nel test.
- **Orologio:** l'orologio finto esistente, per `RequestBudget` e `TempLabelStore`.

## Volume previsto

Strategia Standard: da 5 a 8 test per componente. In tutto circa 90 test nuovi: unità per base, punteggio, strumento, caricatore, coordinatore, unione e sessione; widget per le 6 viste e la schermata Informazioni; 2 benchmark e 5 scenari end-to-end.
