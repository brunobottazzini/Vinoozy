# Unit Test Instructions — u4-cellar

## Framework e configurazione

- `flutter test` per `lib/cellar/` (dominio, repository, provider, schermate) e per le modifiche a U1, U5 e `lib/sync/`.
- **Test delle regole** con `@firebase/rules-unit-testing` sull'emulatore di Firestore, tramite `npm run test:rules`. Richiedono Node (versione in `.nvmrc`) e Java 21 per l'emulatore.
- **Finti:**
  - `mocktail` per i repository e Firestore;
  - `WineCatalog` finto: nessuna chiamata a Open Food Facts reale;
  - flussi finti per i provider di U1 e U7 (`activeCellarProvider`);
  - `SharedPreferences.setMockInitialValues`;
  - `ErrorSink` finto;
  - rete finta con `onChanged`.
- Nessun test usa il progetto Firebase reale. I test end-to-end usano solo la Firebase Emulator Suite e l'emulatore Android.
- Preparazione, una volta: `flutter pub get` e `npm ci` alla radice.

## Come eseguire i test di questa unità

1. Test della Cantina (comando principale, eseguibile dal primo test in poi):

   ```bash
   flutter test test/cellar
   ```

2. Test delle regole cloud, comprese U1, U7 e la compatibilità (comando a sé):

   ```bash
   npm run test:rules
   ```

3. Test di U1, U5, U7 e della sincronizzazione toccati dall'integrazione (comando a sé):

   ```bash
   flutter test test/u1 test/dashboard test/sharing test/app
   ```

4. Copertura della sola Cantina (comando a sé, perché la soglia può far fallire l'uscita):

   ```bash
   flutter test --coverage test/cellar && tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/
   ```

5. Controlli degli strumenti (comandi a sé):

   ```bash
   tool/check_firestore_indexes.sh
   ```

   ```bash
   tool/check_firestore_indexes_test.sh
   ```

   ```bash
   tool/check_rule_ids.sh BR1. 20 test/cellar test/rules/u4.rules.test.mjs
   ```

   ```bash
   tool/check_rule_ids_test.sh
   ```

6. Benchmark (comando a sé):

   ```bash
   dart run benchmark/cellar_benchmark.dart
   ```

## Obiettivi di copertura

- **Cantina:** almeno l'80% delle righe di `lib/cellar/`, controllato dal comando 4.
- **Progetto:** almeno l'80% su tutto il codice senza esclusioni (team.md). Lo verifica Build and Test sulla suite completa, unendo app e pacchetto `estimation`.
- **Regole di business:** ogni regola da BR1.1 a BR1.20 è citata in almeno un test (comando 5, `check_rule_ids.sh`).
- **Benchmark:** filtri ≤ 20 ms e finestra effettiva ≤ 5 ms su 500 vini.

## Mock e stub

- **Firestore nell'app:** i repository sono iniettati tramite provider e sostituiti con `mocktail`. I test dei repository verificano il contenuto dei batch con un batch finto e i valori di `FieldValue.increment`.
- **Tempo:** l'attesa dei suggerimenti (250 ms), il tempo massimo della ricerca dei doppioni (1 s), il messaggio di 6 o 10 s, i 10 minuti dell'Annulla e i 7 giorni della riconciliazione si provano con `fakeAsync` o con un orologio iniettato, mai con attese vere.
- **Scritture in coda:** `waitForPendingWrites` dietro un'interfaccia iniettata, con un completer controllabile.
- **Crashlytics:** `ErrorSink` finto. I test con nome, produttore e note marcatore verificano che non arrivino.

## Dati di test

- Ogni regola ha almeno un test con l'ID nel nome, nei test di Dart o in quelli delle regole.
- Le schermate si provano in it, en e pt-BR, con `textScaler` 1.0 e 2.0.
- Vini di prova generati da una fabbrica, fino a 500 per il benchmark; utenti finti con email `@example.com`; nessun dato personale reale.
