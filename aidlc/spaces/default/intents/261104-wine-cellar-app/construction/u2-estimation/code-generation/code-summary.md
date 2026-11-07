# Code Summary — u2-estimation

U2 è il pacchetto Dart puro `packages/estimation`, che implementa il contratto C2 v1 con le aggiunte compatibili di `entities.md`. Nessuna dipendenza di produzione, nessun accesso a rete, disco, orologio o Firebase. L'app lo usa con una dipendenza `path`.

## Cosa è stato costruito

- **API pubblica** (`lib/estimation.dart`): esporta solo le quattro funzioni di C2 (`estimateWindow`, `statusOf`, `pairingsFor`, `needsRefinement`), i tipi di valore, `EstimationArgumentError` con `EstimationErrorCode` e la costante `genericEstimateWarningCode` (`GENERIC_ESTIMATE`). Tutto il resto di `lib/src/` non è esportato.
- **Modello dei dati** (`lib/src/models.dart`, `lib/src/errors.dart`, `lib/src/tables.dart`): tipi immutabili con uguaglianza per valore; `WineType.tryParse` accetta i nomi dell'enum e i valori di C1 (BR1.7); `EstimationBasis.resolveStoredBasis` per le finestre salvate senza `basis` (W4); `DrinkingWindow.warningCode`; finestra di `ExternalProfile` facoltativa (BR1.6). Le tabelle di `rules.md` sono `const`: 47 righe di denominazioni (una per riga della tabella, con le righe doppie come "Langhe Nebbiolo, Nebbiolo d'Alba" in una sola voce con più alias), 8 tipologie e la riga generica.
- **Logica**:
  - `validation.dart`: BR4.5 per `estimateWindow` e `pairingsFor` (anni ammessi 1900–2200), finestra incoerente per `statusOf`, profilo esterno utilizzabile (BR1.6).
  - `recognizer.dart`: normalizzazione (minuscole, senza accenti, apostrofi e punteggiatura come separatori, al massimo 60 caratteri), indice degli alias costruito una sola volta (`final aliasIndex = buildAliasIndex();`), ricerca per parole intere con l'alias più lungo e a parità il primo nel nome, qualifiche solo se la denominazione ha scostamenti propri (cercate nel nome e nella denominazione indicata dall'utente), risoluzione con le precedenze di BR1.2 e BR1.7.
  - `window.dart`: `estimateWindow` (W1, BR1.3, BR1.4, BR2.1, BR2.2, BR3.1) e `needsRefinement` (BR1.5, non lancia mai).
  - `status.dart`: `statusOf` con aritmetica intera sui mesi (BR3.2, BR3.3).
  - `pairings.dart`: `pairingsFor` (BR4.1, BR4.2): i primi 5 abbinamenti della fonte in una lista non modificabile, altrimenti le categorie `const` restituite senza copia.
- **Strumenti**: `tool/check_estimation_purity.sh` (dipendenze, import, parole vietate, stato globale, esattamente 2 occorrenze di `buildAliasIndex(`), `benchmark/estimation_benchmark.dart` (soglie di `logical-components.md`, una ripetizione se una misura sfora, `exit(1)` alla seconda), misura sul telefono `integration_test_perf/estimation_perf_test.dart` con `test_driver/perf_driver.dart`.

## Decisioni di implementazione

- **Precedenze (BR1.2, BR1.7):** denominazione dell'utente se è nella tabella; altrimenti la tipologia (dell'utente, poi di C1) decide: la denominazione di C1 e poi quella del nome restano solo se hanno la stessa tipologia, altrimenti si usa la tabella per tipologia; senza tipologia vale la denominazione di C1, poi quella del nome, poi la riga generica.
- **Più qualifiche nello stesso nome** (per esempio "Marsala Superiore Riserva"): vince la più specifica che ha scostamenti propri, nell'ordine Gran Selezione, Riserva, Superiore. Le parole che fanno parte dell'alias riconosciuto (per esempio "Superiore" in "Valtellina Superiore") non contano come qualifica. È una scelta enologica presa in autonomia come da `project.md` (Corrections) e si può correggere senza cambiare l'API.
- **Alias:** oltre ai nomi della tabella, alias brevi o d'uso comune (`brunello`, `amarone`, `ripasso`, `nebbiolo d alba`, `ghemme`, `timorasso`, `moscato d asti`, `sfursat`, `trentodoc`, `valdobbiadene`, `vin santo del chianti` e simili). Nessun alias ambiguo da solo (per esempio "barbera" o "valtellina" non sono alias, perché esistono denominazioni diverse con quel nome). Ogni alias appartiene a una sola denominazione (verificato dai test).
- **Normalizzazione:** si esaminano i primi 60 caratteri del nome dopo la pulizia degli spazi; le lettere accentate latine si riducono alla lettera base, ogni altro carattere che non è lettera o cifra separa le parole.
- **Errori:** `EstimationArgumentError` porta `code`, il nome dell'argomento e il valore rifiutato; il messaggio è il nome del codice, in inglese, solo per i log.
- **Script di purezza:** le righe con `static` sono ammesse senza `const`/`final` solo se dichiarano un metodo o un getter (serve per `WineType.tryParse` ed `EstimationBasis.resolveStoredBasis`, richiesti dal brief); un campo `static` modificabile viene comunque bloccato. Verificato con un file di prova temporaneo in `lib/` (poi rimosso), che ha fatto scattare tutti e cinque i controlli.

## File

**Creati**

- `packages/estimation/pubspec.yaml`, `packages/estimation/pubspec.lock`, `packages/estimation/analysis_options.yaml`, `packages/estimation/README.md`
- `packages/estimation/lib/estimation.dart`
- `packages/estimation/lib/src/errors.dart`, `models.dart`, `tables.dart`, `validation.dart`, `recognizer.dart`, `window.dart`, `status.dart`, `pairings.dart`
- `packages/estimation/test/models_test.dart`, `tables_test.dart`, `recognizer_test.dart`, `window_test.dart`, `status_test.dart`, `pairings_test.dart`, `api_test.dart`, `coverage_helper_test.dart`
- `packages/estimation/benchmark/estimation_benchmark.dart`
- `tool/check_estimation_purity.sh` (eseguibile)
- `integration_test_perf/estimation_perf_test.dart`, `test_driver/perf_driver.dart`

**Modificati (file del progetto, come previsto dal piano)**

- `pubspec.yaml` dell'app: dipendenza `estimation: path: packages/estimation`; di conseguenza `pubspec.lock` (+7 righe) dopo `flutter pub get`.
- `analysis_options.yaml`: `packages/**` negli `exclude`.
- `.gitignore`: `packages/estimation/coverage/`. `packages/estimation/.dart_tool/` è già escluso dalla regola esistente `.dart_tool/`, quindi non è stata aggiunta una riga apposta.
- `.github/workflows/ci.yml`: nuovo job `estimation` (stesse azioni fissate per hash, passi di `cicd-pipeline.md` §1, `working-directory: packages/estimation`, artefatto `estimation-coverage` di 14 giorni); nel job `unit` test e copertura del pacchetto, unione con `cat coverage/lcov.info packages/estimation/coverage/lcov.info > coverage/merged.lcov.info` e `tool/check_coverage.sh 80 coverage/merged.lcov.info` al posto del controllo precedente; commento in testa "five" → "six".
- `docs/release-checklist.md`: riga della misura sul telefono (≤ 25 ms, con spazio per la mediana e la versione).

## Come eseguire

Dal pacchetto (`cd packages/estimation`), dopo `dart pub get`:

```bash
dart test
dart test --coverage=coverage && dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib && ../../tool/check_coverage.sh 90 coverage/lcov.info
../../tool/check_estimation_purity.sh
dart run benchmark/estimation_benchmark.dart
```

Sul telefono collegato, dalla radice dell'app:

```bash
flutter drive --profile --driver=test_driver/perf_driver.dart --target=integration_test_perf/estimation_perf_test.dart
```

## Risultati reali (macOS arm64, Dart 3.13.7, Flutter 3.47.9)

| Controllo | Risultato |
|---|---|
| `dart test` del pacchetto | 308 test, tutti verdi |
| Copertura del pacchetto (`lib/`, tabelle comprese) | **100,00%** (293/293 righe), soglia 90% |
| `dart format --set-exit-if-changed .` nel pacchetto | nessun file da formattare |
| `dart analyze --fatal-infos` nel pacchetto | nessuna segnalazione |
| Script di purezza | OK (9 file in `lib/`) |
| Benchmark: riconoscimento di 500 nomi da 60 caratteri | 1,599–1,652 ms (soglia ≤ 4 ms) |
| Benchmark: stima + stato + abbinamenti di 500 vini | 3,004–3,035 ms (soglia ≤ 10 ms) |
| Benchmark: secondo blocco di 500 stime rispetto al primo | da −0,2% a −0,8% (soglia ≤ +10%) |
| Benchmark: una stima rispetto a una costruzione dell'indice | 2,7 µs contro circa 300 µs, rapporto 0,009 (soglia ≤ 0,1) |
| App: `flutter pub get`, `dart format --set-exit-if-changed .` alla radice | OK, nessun file da formattare |
| App: `flutter analyze --fatal-infos` | nessuna segnalazione |
| App: `dart run tool/gen_coverage_helper.dart` poi `flutter test --coverage` | 336 test, tutti verdi; copertura dell'app 82,76% (1450/1752) |
| Copertura di progetto (app + pacchetto, somma delle righe dei due lcov) | 85,23% (1743/2045), soglia 80% |

I numeri del benchmark vengono da due esecuzioni locali su un Mac, non dal runner `ubuntu-latest` della CI, dove le soglie saranno verificate dal job `estimation`.

## Test scritti ma non eseguiti in questo stage

- `integration_test_perf/estimation_perf_test.dart` (misura sul telefono, NFR2.1 b): richiede il telefono del proprietario collegato e una build `--profile`; non gira in CI per scelta di `cicd-pipeline.md` §5. È analizzato da `flutter analyze` (nessuna segnalazione) ma non è stato eseguito. Va eseguito dal proprietario prima di approvare la produzione, come da `docs/release-checklist.md`.
- I job `estimation` e `unit` modificati di `ci.yml` non sono stati eseguiti su GitHub Actions: i loro comandi sono stati eseguiti in locale uno per uno. Il comando di unione `cat ... > coverage/merged.lcov.info` non è stato eseguito in locale; la percentuale unita qui sopra è stata calcolata sommando le righe `LF`/`LH` dei due file, che è esattamente ciò che fa `tool/check_coverage.sh`.

## Scostamenti dal piano

- **Test di riconoscimento degli alias in `tables_test.dart`:** il piano lo mette nello Step 4 (strato del modello), ma richiede il riconoscitore, che nasce nello Step 5. Allo Step 4 `tables_test.dart` ha verificato che ogni alias sia già normalizzato e unico; il gruppo "ogni alias riconosciuto come questa denominazione" è stato aggiunto allo stesso file nello Step 6, dopo il riconoscitore, ed è verde.
- **Test di avvio dello Step 2:** `test/bootstrap_test.dart` è stato creato per provare il runner e poi cancellato allo Step 4, come previsto ("sostituito dagli step successivi").
- **I test del modello importano `src/`:** allo Step 4 l'API pubblica non era ancora compilabile (esporta le funzioni dello Step 5), quindi `models_test.dart` e `tables_test.dart` importano direttamente `package:estimation/src/...`.
- **Numero di righe della tabella:** `logical-components.md` parla di 48 denominazioni; la tabella di `rules.md` ha 47 righe e il codice ne ha una per riga. I test non contano le righe: verificano ognuna di quelle definite.
- **`logical-components.md` indica il bersaglio `integration_test/estimation_perf_test.dart`:** si è seguito `cicd-pipeline.md` §5 e il brief (`integration_test_perf/`), così il job `e2e` non lo esegue.
