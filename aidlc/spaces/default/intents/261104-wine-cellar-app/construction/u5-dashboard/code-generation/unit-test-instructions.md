# Unit Test Instructions — u5-dashboard

## Framework e configurazione

- `flutter test` per il modulo `lib/dashboard/` (nucleo, provider e widget) e per le modifiche a U1 (`Wine`, gate, shell, tema).
- I test usano `ProviderContainer` e `ProviderScope` con gli override dei provider di U1: flussi finti per `winesStreamProvider` e `cellarStreamProvider`, orologio finto per `clockProvider`, `ErrorSink` finto per `errorReporterProvider`. Le preferenze usano `SharedPreferences.setMockInitialValues`.
- Nessun test usa Firebase reale. I test end-to-end usano solo la Firebase Emulator Suite e l'emulatore Android.
- Preparazione, una volta: `flutter pub get` alla radice.

## Come eseguire i test di questa unità

1. Test del Cruscotto (comando principale, eseguibile dal primo test in poi):

   ```bash
   flutter test test/dashboard
   ```

2. Test delle parti di U1 toccate (modello `Wine`, gate, shell, tema):

   ```bash
   flutter test test/cellar test/account test/app
   ```

3. Copertura del solo Cruscotto (comando a sé, perché la soglia può far fallire l'uscita):

   ```bash
   flutter test --coverage test/dashboard && tool/check_coverage.sh 80 coverage/lcov.info lib/dashboard/
   ```

4. Controllo di sola lettura e il suo test (comandi a sé):

   ```bash
   tool/check_dashboard_readonly.sh
   ```

   ```bash
   tool/check_dashboard_readonly_test.sh
   ```

5. Benchmark (comando a sé):

   ```bash
   dart run benchmark/dashboard_benchmark.dart
   ```

## Obiettivi di copertura

- **Cruscotto:** almeno l'80% delle righe di `lib/dashboard/`, controllato dal comando 3.
- **Progetto:** almeno l'80% su tutto il codice senza esclusioni (team.md). Lo verifica Build and Test sulla suite completa, unendo app e pacchetto `estimation`.

## Mock e stub

- Vini: liste sintetiche generate in `test/dashboard/fixtures.dart`, fino a 500, con `WinesSnapshot` sia dalla cache sia dal server.
- Tempo: orologio iniettato con giorni del cambio dell'ora legale in Europa/Roma; il timer si fa avanzare con `fakeAsync`, mai con attese vere.
- Crashlytics: `ErrorSink` finto che conserva le chiamate; i test con anni e nome marcatori verificano che nessun dato del vino arrivi.
- Calcolatore: versione finta che conta le chiamate, per NFR2.3.

## Dati di test

- Ogni regola da BR1.1 a BR1.9 ha almeno un test con l'ID nel nome.
- I widget si provano in it, en e pt-BR, con `textScaler` 1.0 e 2.0 e con il tema chiaro e scuro.
- Nessun dato personale: nomi di vini realistici e utenti fittizi.
