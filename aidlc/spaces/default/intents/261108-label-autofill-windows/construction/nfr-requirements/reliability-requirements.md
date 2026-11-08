# Requisiti di affidabilità

## Fonti

- `construction/functional-design/`: BR2.4–BR2.6, BR3.6, BR3.9, BR4.4–BR4.6.
- `inception/requirements-analysis/requirements.md`: FR2, FR5, FR6.

| ID | Requisito | Verifica |
|---|---|---|
| NFR4.8a (derivato da NFR1) | Migrazione una tantum (BR3.9), percorso preciso:<br>- usa la scrittura **un vino alla volta** di `ensureEstimates`, solo per chi ha `canEdit`, e non batch nuovi; per i membri in sola lettura la finestra si calcola solo per la vista (`WineEstimator.displayed`);<br>- **offline:** le scritture restano in coda come oggi; la migrazione non aspetta il server e riprende al prossimo avvio per i vini con `tablesVersion` vecchia;<br>- **regole vecchie ancora in produzione:** un rifiuto di permesso ferma la migrazione per la sessione, con un solo evento `estimates_migration_failed` (`permissionDenied`) e al massimo 3 tentativi in 3 avvii diversi; poi si ferma fino alla prossima versione delle tabelle;<br>- **scritture concorrenti** (proprietario ed editor): ogni scrittura è un `update` del solo `baseWindow`/`window`/`tablesVersion`; vince l'ultima, e il risultato è lo stesso perché il calcolo è deterministico;<br>- **versione vecchia** che riscrive la finestra: `tablesVersion` sparisce o resta vecchia e la versione nuova la ricalcola. | test con Firestore emulator: online, offline, permesso negato, due utenti |
| NFR4.8 | Se il ricalcolo una tantum (BR3.9) si interrompe (app chiusa o rete assente), riprende al prossimo avvio. I vini già ricalcolati non si toccano di nuovo, perché ricordano la versione delle tabelle (`tablesVersion`). | test con interruzione a metà |
| NFR4.9 | Se Lens non si apre, compaiono le istruzioni (BR2.5) e il modulo resta aperto. | test con canale finto: `unavailable` ed eccezione |
| NFR4.10 | Se gli appunti non si possono leggere (eccezione, API sotto 26, permesso negato dal sistema), non compare nessun errore e resta il pulsante. | test con canale finto |
| NFR4.11 | Correzione e livello non si perdono in nessuno dei 6 punti di BR4.5. | un test per ogni punto, con un vino che ha `level` e `windowOverride` |
| NFR4.12 | `build_appellations` non sovrascrive la tabella se i controlli di BR3.6 falliscono:<br>- meno di 1500 righe;<br>- chiavi duplicate;<br>- modello assente;<br>- regione non valida.<br>In questi casi esce con errore. | test dello strumento |
| NFR4.13 | Ogni riga e ogni tipo producono una finestra valida (BR3.9). Se una riga generata non ha né tipo né modello, lo strumento la scarta e la conta nel rapporto. | test su tutte le righe |
| NFR4.14 | Il salvataggio della correzione è un solo `update` con `window` e `windowOverride`, quindi o vanno a buon fine tutti e due o nessuno. Offline resta in attesa come le altre scritture. | test del repository |
| NFR4.21 (FR2.8) | Allo scadere dei 1,5 secondi il modulo si compila dal testo; la ricerca che continua in sottofondo non cambia il modulo, e un suo errore successivo si registra senza essere lanciato. | test unitario con catalogo lento e con errore tardivo |
| NFR4.22 (FR7.7) | Interruzioni della guida: rotazione e ritorno dal secondo piano riprendono alla stessa domanda; un nuovo testo chiude la guida tenendo i campi confermati; "Pulisci" chiude la guida e svuota le risposte; se Android chiude l'app la guida si perde senza errori. Chiudi, Indietro e tocco fuori chiudono la scheda tenendo i campi confermati, e "Conferma guidata" ricompare finché resta un campo incerto senza risposta. | test del widget per ogni caso; la chiusura da parte di Android si prova ricreando il widget del modulo senza stato; e2e con Indietro e nuovo testo a guida aperta (NFR5.8) |
