# Performance Requirements — u7-sharing

Fonti: `requirements.md` (NFR2, NFR5), `functional-spec.md` di U7 (BR1.4, BR1.11, BR1.14, "Meccanismi senza funzioni nel cloud"), requisiti di costo di U1 (NFR5.1, NFR5.2), riepilogo confermato in `nfr-requirements-questions.md`.

**Scala di riferimento:**
- una cantina con fino a 500 vini;
- al massimo 2 persone invitate per cantina (limite portato da 5 a 2 il 2026-11-06);
- una persona che vede fino a 6 cantine (la propria più 5 condivise da altri). È un valore di prova, non un limite di prodotto sulle cantine ricevute.
- **Uso previsto dal proprietario (2026-11-06):** occasionale, cioè aperture durante pranzi e cene, spesso la domenica. Le stime con "uso intenso" qui sotto sono quindi un caso peggiore.

## Tempi

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR2.1 | Con rete, invito, cambio di permesso, revoca e uscita danno l'esito con una **mediana di 3 secondi o meno**. Il tempo massimo è **10 secondi**, poi "non riuscito, riprova" (BR1.11). | Il tempo massimo si prova con un test del servizio e un orologio finto. La mediana si misura a mano: 5 prove per operazione sul telefono di riferimento con il progetto di produzione, una volta per versione, con il risultato nella checklist di rilascio. |
| NFR2.2 | Una cantina condivisa compare nel selettore **entro 5 secondi** dall'accesso con rete (ricerca degli inviti e attivazione, BR1.4). | **Sul telefono:** misura manuale, 3 prove per versione, nella checklist. **In CI:** il test end-to-end attende al massimo **15 secondi** (margine per l'emulatore, più lento) e fallisce oltre. |
| NFR2.3 | Con l'app aperta e online, una revoca o un cambio di permesso si vede sull'app dell'altra persona **entro 5 secondi** (ascolto dei propri inviti, BR1.14). | **Sul telefono:** misura manuale con due telefoni, 3 prove per versione. **In CI:** stesso limite di 15 secondi (vedi sotto come si esegue). |
| NFR2.4 | Il cambio di cantina nel selettore mostra la cantina scelta dalla cache **entro 1 secondo** se è già stata aperta. Altrimenti mostra lo stato di caricamento esistente di U1 e U5. | Test dei widget con flussi finti. |

**Come il test end-to-end prova NFR2.2 e NFR2.3 con una sola app.**
- L'app sull'emulatore Android è la persona invitata (`userB`).
- Il proprietario (`userA`) agisce dal test via REST sugli emulatori, con **il proprio token di accesso**, ottenuto dall'emulatore di Auth, e non come amministratore. Così ogni sua scrittura passa dalle regole vere.
- Sequenza: il proprietario invita B → l'app di B accede e mostra la cantina (NFR2.2) → il proprietario cambia permesso e poi revoca → l'app di B, ancora connessa, aggiorna i comandi e poi toglie la cantina (NFR2.3).

## Costo e quote (NFR5)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR5.1 | **Ascolti.** Per utente sono aperti l'ascolto dei propri inviti (gruppo di collezioni) e quelli della sola cantina attiva, una per volta. Le cantine non attive non hanno ascolti aperti. | Test del provider che conta gli ascolti aperti al cambio di cantina. |
| NFR5.2 | **Accessi ai documenti nelle regole.** Ogni percorso valutato usa al più **3 accessi** tra `get`, `exists` e `getAfter`. Per le letture e le scritture dei vini sono 2 (cantina e `members`). Per le scritture di gestione sono 3 (cantina prima e dopo, e `members`). Così si resta molto sotto i limiti di Firestore (10 accessi per richiesta, 20 per batch). | Una tabella "percorso → accessi" in un commento all'inizio di `firestore.rules`, controllata nella revisione del codice. I test delle regole provano i batch di gestione più grandi, che falliscono se si supera il limite di Firestore. Lo strumento di test delle regole non conta gli accessi, quindi non si chiede un conteggio automatico. |
| NFR5.3 | **Stima d'uso** (calcolo in `tech-stack-decisions.md`): ogni persona che apre una cantina di 500 vini **resta sotto 2.000 letture al giorno**; una cantina con il proprietario e 2 persone attive **sotto 6.000 al giorno** sulla cantina condivisa, e circa 9.700 contando anche le cantine personali piene delle 3 persone. La quota gratuita di 50.000 letture al giorno vale per **tutto il progetto**, quindi copre circa 5 gruppi di questo tipo, pieni e molto usati, nello stesso giorno. Con l'uso occasionale previsto, il consumo reale è una piccola frazione di questi valori. L'archivio dei vini finiti, deciso per U4, riduce ancora le letture. | Calcolo documentato. Controllo mensile dell'uso nella console Firebase (checklist di U1), più un avviso quando l'uso giornaliero supera **35.000 letture** (70% della quota), configurato nel monitoraggio di U7 (design dell'infrastruttura). |
