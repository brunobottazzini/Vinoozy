# Unit Test Instructions — u7-sharing

## Framework e configurazione

- `flutter test` per `lib/sharing/` (dominio, repository, provider, schermate) e per le modifiche a U1 e U5.
- **Test delle regole** con `@firebase/rules-unit-testing` sull'emulatore di Firestore, tramite `npm run test:rules`. Richiedono Node (versione in `.nvmrc`) e Java 21 per l'emulatore.
- **Finti:**
  - `mocktail` (già in `pubspec.yaml`) per il repository e Firestore;
  - flussi finti per i provider di U1;
  - `SharedPreferences.setMockInitialValues`;
  - `ErrorSink` finto;
  - rete finta con `onChanged`.
- Nessun test usa il progetto Firebase reale. I test end-to-end usano solo la Firebase Emulator Suite e l'emulatore Android.
- Preparazione, una volta: `flutter pub get` e `npm ci` alla radice.

## Come eseguire i test di questa unità

1. Test della condivisione (comando principale, eseguibile dal primo test in poi):

   ```bash
   flutter test test/sharing
   ```

2. Test delle regole cloud, comprese U1 e la compatibilità (comando a sé):

   ```bash
   npm run test:rules
   ```

3. Test di U1 e U5 toccati dall'integrazione (comando a sé):

   ```bash
   flutter test test/u1 test/dashboard test/app test/account test/cellar
   ```

4. Copertura della sola condivisione (comando a sé, perché la soglia può far fallire l'uscita):

   ```bash
   flutter test --coverage test/sharing && tool/check_coverage.sh 80 coverage/lcov.info lib/sharing/
   ```

5. Controllo dell'indice e il suo test (comandi a sé):

   ```bash
   tool/check_firestore_indexes.sh
   ```

   ```bash
   tool/check_firestore_indexes_test.sh
   ```

## Obiettivi di copertura

- **Condivisione:** almeno l'80% delle righe di `lib/sharing/`, controllato dal comando 4.
- **Progetto:** almeno l'80% su tutto il codice senza esclusioni (team.md). Lo verifica Build and Test sulla suite completa, unendo app e pacchetto `estimation`.
- **Regole:** ogni cella della matrice 6×9 e ogni transizione hanno un'asserzione esplicita (NFR4.1, NFR4.2).

## Mock e stub

- **Firestore** nell'app: il repository è iniettato tramite provider e sostituito con `mocktail`. I test del repository verificano il contenuto del `WriteBatch` con un batch finto.
- **Tempo:** il tempo massimo di 10 s si prova con `fakeAsync`, mai con attese vere.
- **Rete:** `NetworkStatus` finto con `hasNetwork()` e `onChanged` controllabili.
- **Crashlytics:** `ErrorSink` finto. I test con un'email marcatore verificano che non arrivi.
- **Condivisione di Android:** `share_plus` dietro un'interfaccia iniettata (`ShareLauncher`), sostituita nei test.

## Dati di test

- Ogni regola da BR1.1 a BR1.14 ha almeno un test con l'ID nel nome, nei test di Dart o in quelli delle regole.
- Le schermate si provano in it, en e pt-BR, con `textScaler` 1.0 e 2.0.
- Utenti finti con email `@example.com`; nessun dato personale reale.
