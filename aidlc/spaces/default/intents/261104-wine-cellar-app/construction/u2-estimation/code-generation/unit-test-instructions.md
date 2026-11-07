# Unit Test Instructions — u2-estimation

## Framework e configurazione

- Pacchetto Dart puro `packages/estimation`, test con `package:test` (nessun Flutter).
- Dipendenze di sviluppo: `test`, `lints`, `benchmark_harness`, `coverage` (`packages/estimation/pubspec.yaml`).
- Preparazione, una volta: `cd packages/estimation && dart pub get`.

## Come eseguire i test di questa unità

Tutti i comandi lavorano solo sul pacchetto di U2.

1. Test (comando principale, eseguibile dal primo test in poi):

   ```bash
   cd packages/estimation && dart test
   ```

2. Test di un solo strato (usati durante la costruzione):

   ```bash
   cd packages/estimation && dart test test/models_test.dart test/tables_test.dart
   cd packages/estimation && dart test test/recognizer_test.dart test/window_test.dart test/status_test.dart test/pairings_test.dart test/api_test.dart
   ```

3. Copertura del pacchetto (comando a sé, perché la soglia può far fallire l'uscita):

   ```bash
   cd packages/estimation && dart test --coverage=coverage && dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib && ../../tool/check_coverage.sh 90 coverage/lcov.info
   ```

4. Purezza (comando a sé):

   ```bash
   cd packages/estimation && ../../tool/check_estimation_purity.sh
   ```

5. Benchmark (comando a sé):

   ```bash
   cd packages/estimation && dart run benchmark/estimation_benchmark.dart
   ```

## Obiettivi di copertura

- **Pacchetto:** almeno il 90% delle righe di `lib/`, tabelle comprese, misurato da solo (NFR7.1). È un obiettivo di questa unità e si controlla con il comando 3.
- **Progetto:** almeno l'80% delle righe su tutto il codice, senza esclusioni (team.md). Lo verifica Build and Test sulla suite completa del progetto, unendo la copertura dell'app e del pacchetto; non si giudica dai soli test di U2.

## Mock e stub

- Nessun mock: le funzioni sono pure. Gli ingressi sono costruiti direttamente (`WineFacts`, `ExternalProfile`, `DrinkingWindow`, `today` fissato).
- `today` è sempre una data fissa nei test (per esempio `DateTime(2026, 9, 1)`), mai l'orologio.

## Dati di test

- Test a tabella generati dalle costanti di `tables.dart` (una verifica per riga, NFR7.2).
- Esempi di `functional-spec.md` e criteri AC4.2.1 e AC4.2.2 come test con nome dell'ID (NFR7.3).
- Ingressi casuali con seme fisso `Random(42)`, 1000 casi per funzione, solo nei test (NFR4.2, NFR4.4).
