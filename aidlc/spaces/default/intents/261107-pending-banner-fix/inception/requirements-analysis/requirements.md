# Requisiti — correzione della fascia "modifiche in attesa" (pending-banner-fix)

## Analisi dell'intento

Il proprietario vuole che, dopo una bevuta fatta senza rete, l'app mostri **sempre** la fascia "modifiche in attesa" finché il server non ha ricevuto la bevuta. Oggi la fascia a volte non compare. Sembra che tutto sia sincronizzato quando non lo è, e il job `e2e` della CI fallisce circa 3 volte su 5 su `integration_test/cellar_test.dart`, bloccando i merge in `main`.

Il difetto è stato accettato in Build and Test della prima versione (2026-11-07, u4-cellar NFR6.6 `Not Met`, come lo cita `security-design.md` §4 di u4-cellar). La causa è confermata da Reverse Engineering (`codekb/Vinoozy/code-quality-assessment.md`):
- in `lib/cellar/data/drinking_record_repository.dart` (`_commit`) `batch.commit()` non viene atteso;
- `PendingWritesProbe.trackWrite()` chiama `waitForPendingWrites()`;
- nel plugin Android le due chiamate girano su thread diversi. Se l'attesa arriva prima della scrittura, finisce subito e la sonda spegne la fascia.

Obiettivo: lo stato "in attesa" delle bevute deve dipendere dalla **stessa scrittura** che lo ha acceso, non dall'ordine delle chiamate.

## Requisiti funzionali

- **FR1 — Fascia accesa finché la scrittura delle bevute non è confermata.** Dopo ogni scrittura che passa da `DrinkingRecordRepository._commit` (bevuta, annulla, modifica di voto e note), lo stato "in attesa" delle bevute resta acceso finché quella scrittura non si completa sul server.
  - **FR1.1** — Con la rete assente, dopo una bevuta la fascia è visibile ("Senza rete" o "In sincronizzazione") e resta visibile finché la rete non torna e il server conferma. Questo vale anche quando la bevuta finisce l'ultima bottiglia e il vino esce dalla lista. Criterio: in un test di unità che simula l'ordine inverso (attesa finita prima che la scrittura sia confermata), lo stato resta "in attesa" fino al completamento della scrittura.
  - **FR1.2** — Con più scritture in coda, la fascia si spegne solo quando si completa l'**ultima** iniziata; il completamento di una scrittura precedente non la spegne. Criterio: test di unità con due scritture aperte, la prima completata per prima.
  - **FR1.3** — Se la scrittura fallisce o il server la rifiuta, lo stato "in attesa" si spegne (la fascia non resta accesa per sempre). L'errore continua a essere gestito e segnalato come oggi (`onError`, sessione scaduta, report con motivo fisso). Criterio: test di unità con scrittura che fallisce.
- **FR2 — Controllo all'avvio invariato.** All'avvio dell'app le scritture rimaste in coda da una sessione precedente continuano a essere rilevate con `waitForPendingWrites()` e il margine di 300 ms (`PendingWritesProbe.checkAtStartup`), senza cambiamenti di comportamento. Criterio: i test esistenti di `checkAtStartup` restano verdi senza modifiche.

## Requisiti non funzionali

- **NFR1 — Regressione mirata e suite verde** (posture `bugfix` di `org.md`): almeno un test di unità riproduce l'ordine inverso e fallisce con il codice di oggi. Tutta la suite esistente resta verde (`flutter test`, regole, web, nativi, benchmark). La copertura del progetto resta almeno all'80% senza esclusioni e quella di `lib/cellar/` almeno all'80% (team.md).
- **NFR2 — End-to-end stabile:** `integration_test/cellar_test.dart` passa in **5 corse consecutive su 5** sull'emulatore Android a 4 core con la Firebase Emulator Suite, senza cambiare limiti di tempo, senza riprove e senza toccare il test. Anche la suite `integration_test` completa più `tool/e2e_force_stop.sh` passa almeno una volta, salvo lo scenario 8 di U1, già instabile e fuori da questo lavoro, che va riportato se fallisce.
- **NFR3 — Nessun nuovo costo né dipendenza:** nessuna lettura o scrittura Firestore in più, nessun pacchetto nuovo, nessuna modifica alle regole o agli indici di Firestore.
- **NFR4 — Stile:** codice e commenti in inglese, `dart format` e `flutter analyze --fatal-infos` puliti.

## Vincoli

- Si cambia solo il codice dell'app in `lib/cellar/data/` (sonda e repository delle bevute) e i relativi test. Nessun deploy, niente regole Firestore, nessun accesso al progetto reale `vinoozy-d6f45`.
- Trunk-based: il lavoro arriva in `main` con uno squash merge, solo quando tutti i 7 controlli di `ci.yml` sono verdi.
- I commit portano solo il nome del proprietario.

## Assunzioni

- Il `Future` di `batch.commit()` del plugin `cloud_firestore` 7.1.0 si completa solo quando il server conferma la scrittura, oppure con un errore; offline resta aperto. Verificato nel codice del plugin da Reverse Engineering (`Tasks.await(batch.commit())`).
- Le scritture delle bevute passano tutte da `_commit`: `drink`, `undo`, `updateRecord`.

## Fuori ambito (scelta Q1 = A)

Annotati come lavoro separato:
- `SyncWatcher._drain` (`lib/sync/sync_watcher.dart`), che si basa sullo stesso presupposto d'ordine;
- la cancellazione dei vini (`WineRepository._deleteBatches`) senza la sonda;
- l'azzeramento di `drinkingRecordsPendingProvider` quando si riaprono gli ascoltatori di Firestore.

Fuori ambito anche:
- lo scenario 8 instabile di U1;
- la SnackBar che copre "Aggiungi";
- il miglioramento del riconoscimento delle etichette (prossimo lavoro).

## Domande aperte

Nessuna.
