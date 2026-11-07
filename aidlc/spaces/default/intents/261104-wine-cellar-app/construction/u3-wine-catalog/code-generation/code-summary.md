# Code Summary — u3-wine-catalog

U3 è il catalogo dei vini dentro l'app, in `lib/catalog/`: un nucleo puro (`lib/catalog/core/`, solo Dart, `package:http` ed `estimation`) e una parte di piattaforma (`lib/catalog/platform/`). Implementa il contratto C1 come interfaccia Dart `WineCatalog`, con il catalogo interno sempre disponibile e Open Food Facts (OFF) solo nelle build che hanno il contatto. Le funzioni di catalogo di C2 sono state aggiunte al pacchetto `packages/estimation` di U2 come modifica compatibile. Nessun test chiama il vero OFF e nessun file tocca il progetto Firebase reale.

## File creati

**Nucleo `lib/catalog/core/`**
- `wine_catalog.dart`: interfaccia `WineCatalog` (5 operazioni: `suggestWines`, `suggestExternal`, `matchLabelText`, `getWineProfile`, `lookupBarcode`), tipi `WineCandidate` (con `source` e `barcode`), `CellarWineRef`, `SuggestResult`, `LabelMatch`, `WineProfileResult`, `ProfileWindow`, `CatalogLocale`, e `CatalogArgumentError` con solo il codice e un messaggio fisso.
- `catalog_coordinator.dart`: `CatalogCoordinator` (validazione, ordine delle fonti, BR1.2–BR1.5, BR3.1, epoca delle risposte in volo, attesa di `clear()`, sessione per utente con `startSession`).
- `internal_catalog.dart`: indice delle 47 denominazioni costruito una volta, ricerca per inizio di parola (BR1.1), vini della cantina (fino a 500, normalizzati una volta per lista), `mergeCandidates` (BR1.4).
- `catalog_cache_store.dart`: cache (200 voci × 10 proposte) e indice dei profili (500), scadenza 30 giorni, proprietario = hash, epoca, salvataggi raggruppati ogni 2 s e serializzati, scrittura `.tmp` poi rinomina tramite l'interfaccia `CacheFile`.
- `off/open_food_facts_source.dart`: adattatore C5 (host fisso, `Uri.https`, `followRedirects = false`, una scadenza di 5 s su invio e corpo con annullamento della lettura, lettura a flusso fino a 1 MB, esiti `OffFound` / `OffNotFound` / `OffFailed`, mappatura BR4.1, pulizia e troncamento), `normalizeBarcode`.
- `request_budget.dart` (BR2.3), `off_circuit_breaker.dart` (BR2.2, `CatalogHealth`), `catalog_event_logger.dart` (interfaccia con soli enum e numeri, `ConsoleCatalogEventLogger` con `debugLogging`), `catalog_config.dart` (`OFF_CONTACT` da `--dart-define`, host, link della licenza ODbL, User-Agent).

**Piattaforma `lib/catalog/platform/`**
- `file_cache_file.dart`: `catalog_cache.json` nella cartella di supporto (`path_provider`).
- `crashlytics_catalog_event_logger.dart`: un solo errore non fatale `off_suspended` con le chiavi `off_last_failure`, `off_ok`, `off_failed`, `cache_hit_ratio`, `cache_resets`.
- `catalog_providers.dart`: `catalogProvider`, `catalogSessionProvider` (a ogni cambio di uid di U1 cancella la cache del precedente prima di servire il nuovo), `catalogCoordinatorProvider`, versione da `package_info_plus`, hash SHA-256 dell'uid con `crypto`.

**Altro creato**
- `packages/estimation/lib/src/catalog.dart`: `normalizeWineText`, `recognizeDenomination`, `denominationCatalog`, con `displayName` e `region` per ognuna delle 47 denominazioni.
- `benchmark/catalog_benchmark.dart`, `tool/check_off_config.sh` (eseguibile).
- Test: `packages/estimation/test/catalog_functions_test.dart` e 13 file in `test/catalog/` più le risposte registrate in `test/catalog/fixtures/` (7 file).

## File modificati fuori da `lib/catalog/`

- `pubspec.yaml`, `pubspec.lock`: `http` 1.6.0, `path_provider` 2.1.6, `package_info_plus` 10.2.2, `crypto` 3.0.8 (ultime stabili compatibili con Flutter 3.47.9, scelte da `flutter pub add`).
- `packages/estimation/lib/estimation.dart` (export delle funzioni di catalogo), `packages/estimation/lib/src/recognizer.dart` (`tokenizeAll` e `recognizeWords` estratti senza cambiare il comportamento di `tokenize` e `recognize`), `packages/estimation/test/coverage_helper_test.dart` (nuovo file nell'elenco).
- `lib/l10n/app_en.arb`, `app_it.arb`, `app_pt_BR.arb` (chiave `offAttribution`) e i file generati da `flutter gen-l10n`.
- `tool/check_coverage.sh`: terzo argomento facoltativo per il prefisso; senza, il comportamento è identico. Nessuna soglia cambiata.
- `.github/workflows/ci.yml`: `tool/check_off_config.sh` nel job `analyze`; copertura di `lib/catalog/` all'80% e benchmark del catalogo nel job `unit`.
- `integration_test_perf/estimation_perf_test.dart`: misure sul telefono di `suggestWines` (25 ms) e `matchLabelText` (50 ms).
- `docs/release-checklist.md` (righe del catalogo, dati inviati a OFF, controllo mensile), `docs/firebase-setup.md` (§9 `OFF_CONTACT` nell'ambiente `play-internal`).

Non toccati: `AndroidManifest.xml`, `data_extraction_rules.xml` (solo verificati da un test), `release.yml`, `lib/app/providers.dart`, `.gitignore`, `.mcp.json`.

## Decisioni di implementazione

- **Nomi e regioni delle denominazioni** (scelta enologica presa in autonomia, correggibile in `catalog.dart`): il nome mostrato è quello in etichetta con la classificazione più alta coperta dalla riga (per esempio "Barbera d'Asti DOCG", "Langhe Nebbiolo DOC"); la regione è quella di produzione.
- **Tipologia da OFF quando ci sono più tag**: lo stile vince sul colore (spumante, poi dolce, poi rosato, bianco, rosso), perché decide invecchiamento e abbinamenti: un rosato spumante è `sparkling`, un rosso fortificato è `sweet`.
- **Corrispondenza BR1.1**: ogni parola della query deve essere l'inizio di una parola qualsiasi dei `searchTerms` della voce; una query fatta solo di annate non dà proposte. Per i vini della cantina l'annata della query si copia solo se il vino non ne ha una.
- **`suggestWines` è sincrona** (risposta immediata); le altre quattro operazioni sono asincrone. Gli errori di ingresso delle operazioni asincrone arrivano come `Future` fallito con `CatalogArgumentError`.
- **`matchLabelText` e `suggestExternal`** hanno un parametro facoltativo `locale` (default `en`), usato solo per `lc` di OFF.
- **Il codice dell'utente non viene troncato**: `normalizeWineText` e `recognizeDenomination` leggono tutto il testo (serve per l'etichetta di 2000 caratteri), mentre `tokenize` della stima resta limitato a 60 caratteri.
- **Il nucleo non usa `crypto`**: l'hash del proprietario lo calcola la piattaforma e lo passa a `startSession`, così il nucleo dipende solo da quanto previsto in `logical-components.md`.
- **Tempo simulato**: scadenza di 5 s e salvataggi usano un `CatalogTimerFactory` iniettato (`Timer.new` in produzione, timer finti nei test); budget, sospensione e scadenze usano il `Clock` di U1. Nessun test attende tempo reale.
- **Riverpod 3 mette in pausa i provider senza ascoltatori**: U4 e U6 devono usare `catalogProvider` con `ref.watch` (non solo `read`), altrimenti l'ascolto dell'uid si ferma. È scritto in testa a `catalog_providers.dart`; è un criterio da riportare nella progettazione di U4.
- **Registratore**: in release Crashlytics, in debug la console (`debugPrint`), scelto con `kReleaseMode` come fa U1 per i suoi errori.

## Risultati delle verifiche (eseguite il 2026-11-06)

| Verifica | Risultato |
|---|---|
| `cd packages/estimation && dart test` | 321 test verdi (308 prima, +13) |
| Copertura del pacchetto `estimation` | 100,00% (343/343 righe), soglia 90% |
| `tool/check_estimation_purity.sh` | OK (10 file in `lib/`) |
| `dart run benchmark/estimation_benchmark.dart` | OK: riconoscimento 1,617 ms (≤ 4), stima completa 2,982 ms (≤ 10), secondo blocco −0,6% (≤ +10%), rapporto 0,008 (≤ 1/10) |
| `flutter test test/catalog` | 120 test verdi |
| `flutter test --coverage` (suite completa dell'app) | 453 test verdi (336 prima della modifica, tutti ancora verdi) |
| Copertura di progetto (lcov dell'app unito a quello del pacchetto, come in `ci.yml`) | 89,26% (2561/2869 righe), soglia 80% |
| Copertura di `lib/catalog/` | 99,22% (764/770 righe), soglia 80% |
| `dart run benchmark/catalog_benchmark.dart` | OK: `suggestWines` query più lenta 0,910 ms (≤ 5), `matchLabelText` 2000 caratteri 0,422 ms (≤ 10), lettura dalla cache 0,001 ms (≤ 1), `InternalCatalog.build` 0,500 ms (≤ 20) |
| `tool/check_off_config.sh` | OK; verificato anche che fallisce (4 controlli su 4) con file sonda temporanei, poi rimossi |
| `flutter analyze --fatal-infos` | nessun problema |
| `dart format --set-exit-if-changed` (app e pacchetto) | nessun file da formattare |

Ogni regola da BR1.1 a BR5.3 ha almeno un test con l'ID nel nome (NFR7.2). Il caso peggiore della cache (250 risposte con tutti i campi al limite e caratteri da 4 byte, più 500 voci di indice) resta sotto 3 MB in UTF-8 (NFR2.3).

## Test scritti ma non eseguiti in questa fase

- `integration_test_perf/estimation_perf_test.dart`, nuovo test "catalog: suggestWines within 25 ms, matchLabelText within 50 ms": richiede il telefono del proprietario collegato (`flutter drive --profile`), come quello di U2. È nella checklist di rilascio; analizzato ma non eseguito.
- I passi nuovi di `ci.yml` girano solo in GitHub Actions; qui sono stati eseguiti gli stessi comandi in locale.

## Scostamenti dal piano

- **Test in più**: `test/catalog/crashlytics_catalog_event_logger_test.dart` (registratore di produzione) e `test/catalog/release_docs_test.dart` (BR5.3 e NFR6.8 vivono nella checklist: il test fallisce se le righe vengono tolte).
- **`packages/estimation/test/coverage_helper_test.dart`** aggiornato con il nuovo file `src/catalog.dart`: il suo controllo lo richiede, ed è ciò che tiene il nuovo file nella copertura al 90%.
- **`packages/estimation/lib/src/recognizer.dart`** modificato (rifattorizzazione senza cambi di comportamento) per riusare la stessa normalizzazione e lo stesso indice degli alias: `buildAliasIndex(` resta presente esattamente due volte, come vuole lo script di purezza.
- **`CatalogTimerFactory`** in `catalog_config.dart`: non previsto dal piano, serve a simulare la scadenza di 5 s e il timer dei salvataggi senza aggiungere `fake_async` alle dipendenze.
- Nessuna soglia di copertura o di velocità è stata cambiata.
