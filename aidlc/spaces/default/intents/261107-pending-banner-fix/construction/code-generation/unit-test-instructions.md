# Istruzioni dei test di unità — pending-banner-fix

## Framework e configurazione

- `flutter test` (Flutter 3.47.9), nessuna configurazione nuova. Preparazione, una volta: `flutter pub get`.
- Finti già esistenti:
  - `test/cellar/cellar_harness.dart` (`BatchRecorder`, `RecordingBatch`): `commitWith` decide quando finisce ogni commit;
  - `test/helpers/fakes.dart` (`RecordingErrorSink`, `recordingReporter`);
  - `mocktail` per `FirebaseFirestore`.
- Nessun test usa Firebase reale né la rete.

## Come eseguire i test di questa correzione

Comando principale, eseguibile prima e dopo le modifiche:

```bash
flutter test test/cellar/data/pending_writes_probe_test.dart test/cellar/data/drinking_record_repository_test.dart
```

Test della fascia che devono restare verdi senza modifiche (comando a sé):

```bash
flutter test test/u1/sync/sync_status_test.dart test/cellar/cellar_providers_test.dart
```

## Obiettivi di copertura

- **Progetto:** almeno l'80% delle righe senza esclusioni (team.md). Lo verifica Build and Test sulla suite completa, con la copertura del pacchetto di stima unita.
- **`lib/cellar/`:** almeno l'80% (u4-cellar NFR7.1, già in `ci.yml`). Lo verifica Build and Test con `tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/` dopo `flutter test --coverage`.
- **Sonda:** ogni ramo di `trackWrite`, cioè completamento, errore e scritture sovrapposte in entrambi gli ordini, ha un test.

## Mock e stub

- **Sonda:** `trackWrite` riceve un `Completer<void>().future` per ogni scrittura; il test decide quando completarlo o farlo fallire. `waitForPendingWrites` è un `Completer` registrato, per verificare che `trackWrite` non lo chiami. Le prove di `checkAtStartup` restano quelle di oggi, con il tempo finto di `testWidgets`.
- **Repository, regressione dell'ordine inverso:**
  - `BatchRecorder(db, commitWith: (i, result) => commits.add(result))` tiene aperto il commit;
  - la sonda è costruita con `waitForPendingWrites: () async {}`, cioè completata subito, come quando l'attesa arriva al SDK prima della scrittura;
  - dopo `drink`, `undo` o `updateRecord` il test verifica che `probe.isPending` sia vero, completa `commits.single` e verifica che diventi falso.
  - Per `undo` serve la lettura dalla cache della bevuta esistente, come nei test attuali.

## Dati di test

- Utente finto `AppUser` e vino finto dei test esistenti del repository (`@example.com`).
- Gli ID delle regole e dei requisiti sono nel nome dei test (`FR1.1`, `FR1.2`, `FR1.3`, `FR2`, `NFR6.6`).
