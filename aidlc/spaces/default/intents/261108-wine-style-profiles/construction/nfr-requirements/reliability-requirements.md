# Requisiti di affidabilità — profili di stile

## Fonti

- `inception/requirements-analysis/requirements.md` (NFR1–NFR6, FR1–FR4).
- `construction/functional-design/` (BR1–BR11, D1–D9, ENT-101–ENT-112).
- NFR dei lavori precedenti (`261108-label-autofill-windows/construction/nfr-requirements/`), che restano validi.

## Requisiti

| ID | Requisito | Verifica |
|---|---|---|
| NFR4.4 (FR4) | Migrazione: ogni vino si aggiorna in una transazione che controlla `updatedAt`; un vino cambiato nel frattempo si salta e si riprende al prossimo avvio; i campi scelti dall'utente, le correzioni dalle bevute e "Consigliato fino al" non cambiano (Barolo con "Buono" salvato resta 8/15/30) | test con Firestore emulator: online, offline, interruzione, scrittura concorrente |
| NFR4.9 (FR4) | **Offline**: la migrazione non parte senza rete (le transazioni Firestore richiedono il server); i vini restano con la stima di oggi, che resta valida, e la migrazione parte al primo avvio con rete. **Integrità**: dopo la migrazione il numero di vini è invariato e ogni campo con provenienza `user`, ogni `windowOverride` e ogni `windowAdjustment` è identico a prima | test con Firestore emulator offline e confronto campo per campo prima/dopo |
| NFR4.6 (FR4.2) | Se la migrazione si interrompe riprende al prossimo avvio senza rifare i vini già con `migrationVersion` aggiornato; con regole vecchie ancora in produzione si ferma per la sessione con un solo evento | test con interruzione e con permesso negato |
| NFR4.7 (FR1.4) | Uno stile mancante non blocca mai la stima: vale la stima indicativa o "Da stimare" (Madeira), mai un errore | test su ogni profilo UNKNOWN/FORT_UNKNOWN |
| NFR4.8 (FR3.3) | Data di sboccatura o imbottigliamento non valida (futuro, prima dell'annata, mese senza anno) rifiutata dal modulo con un messaggio; il salvataggio non parte | test del widget |
