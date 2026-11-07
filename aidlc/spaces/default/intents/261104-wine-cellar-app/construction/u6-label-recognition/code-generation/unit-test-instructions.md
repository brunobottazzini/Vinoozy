# Unit Test Instructions — u6-label-recognition

## Framework e configurazione

- `flutter test` per `lib/label/` (logica, adattatori, provider, schermate) e per le estensioni di U4 e della shell.
- **Test Kotlin** con JUnit e Robolectric per `LabelImagePreparer` e `SharedImageReceiver`, con JaCoCo. Richiedono Java 17 (come gli altri passi Android della CI).
- **Finti:**
  - `LabelReader`, `ImageSource`, canale delle condivisioni e `TempLabelStore` (file system in memoria) iniettati tramite provider;
  - `WineCatalog` finto: nessuna chiamata a Open Food Facts reale;
  - `ErrorSink` finto e rete finta con `onChanged`;
  - `activeCellarProvider` finto per i permessi.
- Nessun test usa il progetto Firebase reale. L'end-to-end usa solo la Firebase Emulator Suite e l'emulatore Android.
- Preparazione, una volta: `flutter pub get`.

## Come eseguire i test di questa unità

1. Test di U6 (comando principale, eseguibile dal primo test in poi):

   ```bash
   flutter test test/label
   ```

2. Test Kotlin del codice nativo, con la soglia JaCoCo (comando a sé, perché la soglia può far fallire l'uscita):

   ```bash
   cd android && ./gradlew :app:testDebugUnitTest :app:jacocoLabelReport
   ```

3. Test di U4 e della shell toccati dall'integrazione (comando a sé):

   ```bash
   flutter test test/cellar test/app
   ```

4. Copertura della sola U6 (comando a sé):

   ```bash
   flutter test --coverage test/label && tool/check_coverage.sh 80 coverage/lcov.info lib/label/
   ```

5. Controlli degli strumenti (comandi a sé):

   ```bash
   tool/check_rule_ids.sh BR1. 15 test/label
   ```

   ```bash
   tool/check_label_imports.sh
   ```

   ```bash
   tool/check_label_imports_test.sh
   ```

## Obiettivi di copertura

- **U6 in Dart:** almeno l'80% delle righe di `lib/label/`, controllato dal comando 4.
- **Codice nativo:** almeno l'80% delle righe di `LabelImagePreparer` e `SharedImageReceiver`, controllato da JaCoCo nel comando 2.
- **Progetto:** almeno l'80% su tutto il codice Dart senza esclusioni (team.md). Lo verifica Build and Test sulla suite completa.
- **Regole di business:** ogni regola da BR1.1 a BR1.15 è citata in almeno un test (comando 5).

## Mock e stub

- **ML Kit:** sostituito da `LabelReader` finto, che restituisce codici e testo scelti dal test; il vero ML Kit si usa solo nell'end-to-end.
- **Selettore e fotocamera:** `ImageSource` finto con esiti scelti (foto, annullato, permesso negato, fotocamera assente).
- **Tempo:** attese, scadenza dei 60 s, limite dei 10 minuti e Annulla entro 300 ms si provano con l'orologio finto di `testWidgets` o un orologio iniettato, mai con attese vere.
- **Kotlin:** Robolectric con `ContentResolver` finto per gli URI `content://`, file generati nel test (JPEG, PNG, HEIC finto, byte casuali, flusso infinito), `ShadowBitmapFactory` per dimensioni e OOM simulato.

## Dati di test

- Ogni regola ha almeno un test con l'ID nel nome.
- Le schermate si provano in it, en e pt-BR, con `textScaler` 1.0 e 2.0.
- Testi di etichetta inventati ("Barolo DOCG 2016", "Dolcetto d'Alba 2024"), codici EAN-13 di prova validi; nessuna foto di etichette reali nel repository.
