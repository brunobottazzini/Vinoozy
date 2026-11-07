# NFR Design — u4-cellar — Domande

Contesto:
- requisiti non funzionali di U4 approvati (`performance-requirements.md`, `security-requirements.md`, `tech-stack-decisions.md`);
- design funzionale di U4 (`functional-spec.md`, `rules.md`, `frontend-components.md`);
- `contract-summary.md`;
- codice esistente di U1, U3, U5 e U7 (`lib/cellar/`, `lib/catalog/`, `lib/dashboard/`, `lib/sharing/`, `firestore.rules`).

Non ci sono domande aperte: le scelte di questo passo sono tecniche e derivano dai requisiti approvati. Le riassumo qui sotto per conferma.

## Consolidated Summary Confirmation

- **Struttura del codice (`lib/cellar/`):**
  - un nucleo senza Flutter con:
    - validazione;
    - chiave dei doppioni;
    - correzione della finestra dal riscontro;
    - correzione delle quantità negative;
    - filtri;
  - due repository: vini, esteso, e bevute, nuovo;
  - i provider: elenco, vino singolo, Storico a pagine, suggerimenti;
  - le schermate.
- **Integrazione:**
  - il flusso dei vini usa l'elenco con le sole bottiglie presenti, e lo usano anche Cruscotto e condivisione;
  - le azioni del Cruscotto aprono il dettaglio, la Cantina filtrata e l'inserimento completo;
  - la shell aggiunge la terza scheda, Storico.
- **Stime:**
  - calcolate subito sul telefono;
  - il miglioramento dal catalogo passa da una coda che tratta un vino per volta, al massimo 20 per ritorno della rete;
  - le scrive solo chi può modificare.
- **Regole del cloud:**
  - campi nuovi dei vini validati, compresa la forma della finestra;
  - aggiornamento della sola chiave dei doppioni;
  - bevute modificabili da chi le ha registrate o dal proprietario;
  - "Annulla" entro 10 minuti;
  - segno di preparazione della cantina;
  - indice dello Storico.
  
  Tutto con test sugli emulatori e controllo degli indici.
- **Prestazioni:**
  - ricerca e filtri calcolati in memoria su un elenco già caricato;
  - suggerimenti con un'attesa di 250 ms;
  - salvataggio locale senza attese;
  - benchmark in CI con due misure.
- **Affidabilità:**
  - correzione dei valori negativi in un punto solo del repository;
  - "Annulla" che controlla la bevuta prima di cancellarla;
  - backfill a blocchi, ripetibile;
  - al ritorno della rete, ripresa delle operazioni lasciate a metà offline.
- **Privacy:** errori con motivi fissi tramite l'uscita unica, con nome del vino, produttore e note tolti.
- **Accessibilità:** messaggio della bevuta più lungo con TalkBack, stelle con etichetta, stato con icona e testo.
- **Test:**
  - logica, repository con finti, schermate nelle tre lingue;
  - regole cloud;
  - test end-to-end (cantina, offline, bevute contemporanee);
  - controllo degli ID delle regole nei nomi dei test.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
