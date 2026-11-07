# NFR Requirements — u4-cellar — Domande

Contesto:
- design funzionale di U4 approvato (`functional-spec.md`, `rules.md`, `frontend-components.md`);
- `requirements.md`: NFR1 velocità di inserimento, NFR2 prestazioni, NFR3 accessibilità, NFR4 sicurezza, NFR5 costo, NFR6 offline, NFR7 qualità, NFR8 privacy;
- `contract-summary.md` (C1–C4 con le aggiunte del 2026-11-06);
- `team.md` (Testing Posture, Deployment);
- strumenti già presenti: test delle regole, emulatori, job `e2e`, benchmark.

Non ci sono domande aperte. Le scelte di questo passo sono tecniche e derivano dal design e dalle regole del team. Le riassumo qui sotto per conferma.

## Consolidated Summary Confirmation

- **Velocità:**
  - aggiungere un vino presente nei suggerimenti richiede meno di 30 secondi nella mediana di 10 prove (NFR1);
  - i suggerimenti interni compaiono entro 300 ms da quando smetti di scrivere;
  - il salvataggio torna all'elenco entro 300 ms sul telefono di riferimento, senza aspettare la rete;
  - ricerca e filtri su 500 vini rispondono entro 100 ms;
  - il dettaglio si apre entro 500 ms;
  - lo scorrimento della Cantina e dello Storico resta fluido.
- **Costo:**
  - l'elenco legge solo le bottiglie presenti;
  - lo Storico legge 30 bevute per volta;
  - il controllo dei doppioni costa una lettura;
  - il backfill delle chiavi avviene una volta sola;
  - il miglioramento delle stime dal catalogo è limitato a un vino per volta.
  
  Nessun servizio a pagamento e nessuna dipendenza nuova.
- **Sicurezza (regole del cloud):** test sugli emulatori per tutte le estensioni:
  - aggiornamento di voto, note, data e riscontro solo da chi ha registrato la bevuta o dal proprietario, senza toccare i campi fissi;
  - annullamento entro 10 minuti;
  - eliminazione di vini e bevute solo dal proprietario;
  - campi nuovi dei vini validati;
  - aggiornamento della sola chiave dei doppioni.
  
  Tutti i test esistenti delle regole restano verdi.
- **Privacy:** note e voti sono dati dell'utente nel cloud, visibili solo a chi vede la cantina. Non finiscono mai nei report degli errori. La scheda "Sicurezza dei dati" li include già come dati della cantina.
- **Senza rete:** inserimento, bevuta, annulla, voto, modifica e consultazione funzionano tutti senza rete. Le stime migliori arrivano al ritorno della rete. Le quantità si sommano correttamente anche con due persone offline, e i valori negativi si correggono come deciso.
- **Accessibilità:**
  - stato sempre con icona e testo;
  - stelle del voto con etichette;
  - il messaggio dopo una bevuta resta abbastanza a lungo per TalkBack;
  - aree di tocco da 48 dp e testo al 200%;
  - tutto nelle tre lingue.
- **Qualità e test:**
  - test della logica: riscontro e finestra, doppioni, correzione delle quantità, validazione;
  - test delle schermate in it, en e pt-BR;
  - copertura almeno 80%;
  - test end-to-end: aggiungere, bere, annullare, vedere lo Storico, ritrovare un vino finito come doppione, e due bevute offline che si sommano.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
