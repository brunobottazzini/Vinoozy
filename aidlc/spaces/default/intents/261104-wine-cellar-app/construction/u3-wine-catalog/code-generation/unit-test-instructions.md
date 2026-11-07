# Unit Test Instructions — u3-wine-catalog

## Framework e configurazione

- `flutter test` per il modulo `lib/catalog/` (nucleo e piattaforma), con `package:http/testing.dart` (`MockClient`) al posto di Open Food Facts. Nessun test chiama il vero Open Food Facts: senza `OFF_CONTACT` il catalogo lo spegne comunque.
- `dart test` nel pacchetto `packages/estimation` per le nuove funzioni di catalogo di C2.
- Preparazione, una volta: `flutter pub get` alla radice e `cd packages/estimation && dart pub get`.

## Come eseguire i test di questa unità

1. Test del catalogo (comando principale, eseguibile dal primo test in poi):

   ```bash
   flutter test test/catalog
   ```

2. Test delle funzioni di catalogo nel pacchetto di U2:

   ```bash
   cd packages/estimation && dart test test/catalog_functions_test.dart
   ```

3. Copertura del solo catalogo (comando a sé, perché la soglia può far fallire l'uscita):

   ```bash
   flutter test --coverage test/catalog && tool/check_coverage.sh 80 coverage/lcov.info lib/catalog/
   ```

4. Controlli di configurazione (comando a sé):

   ```bash
   tool/check_off_config.sh
   ```

5. Benchmark (comando a sé):

   ```bash
   dart run benchmark/catalog_benchmark.dart
   ```

## Obiettivi di copertura

- **Catalogo:** almeno l'80% delle righe di `lib/catalog/` (NFR7.1), controllato dal comando 3.
- **Pacchetto `estimation`:** resta almeno al 90% con le nuove funzioni (comando del job `estimation`).
- **Progetto:** almeno l'80% su tutto il codice senza esclusioni (team.md). Lo verifica Build and Test sulla suite completa, unendo app e pacchetto.

## Mock e stub

- Open Food Facts: `MockClient` con risposte registrate in `test/catalog/fixtures/` (200, 404, `status: 0`, 429, 503, 301, corpo enorme, JSON non valido, lentezza).
- Tempo: orologio iniettato e simulato (budget, sospensione, scadenze, timeout); mai l'orologio reale né attese vere.
- Crashlytics: registratore finto che conserva gli eventi; i test con valori marcatori verificano che nessun testo dell'utente arrivi al registratore.
- File: `CacheFile` in memoria per il nucleo; cartella temporanea per `FileCacheFile`.

## Dati di test

- Ogni regola da BR1.1 a BR5.3 ha almeno un test con l'ID nel nome (NFR7.2).
- Vini della cantina sintetici (fino a 500) e nomi di etichette realistici, senza dati personali.
