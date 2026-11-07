# NFR Design — u7-sharing — Domande

Contesto:
- requisiti non funzionali di U7 approvati (`security-requirements.md`, `performance-requirements.md`, `tech-stack-decisions.md`);
- design funzionale di U7 (`functional-spec.md`);
- `contract-summary.md` (C3, C4);
- codice di U1 (`firestore.rules`, `lib/app/providers.dart`, `lib/sync/`, `lib/account/`).

Non ci sono domande aperte. Le scelte di questo passo sono tecniche e derivano dai requisiti approvati. Le riassumo qui sotto per conferma.

## Consolidated Summary Confirmation

- **Regole del cloud, in un solo file `firestore.rules`:**
  - funzioni comuni piccole: proprietario, mio invito, posso leggere, posso modificare;
  - un blocco per gli inviti, con la tabella delle transizioni scritta come condizioni separate (una per riga della tabella);
  - un blocco sul gruppo di collezioni per trovare i propri inviti;
  - i due nuovi casi di modifica del contatore sulla cantina;
  - il blocco delle bevute.
  
  In testa al file c'è una tabella in commento con gli accessi di ogni percorso, al massimo 3. Le regole di U1 per il proprietario restano identiche.
- **Codice nell'app (`lib/sharing/`):**
  - un nucleo senza Flutter, con la validazione dell'invito, gli errori di C4 e i modelli;
  - un repository che fa ogni operazione in un solo blocco atomico, con il limite di 10 secondi e la traduzione degli errori del cloud in messaggi;
  - i provider: i miei inviti (un solo ascolto), le cantine accessibili e la cantina attiva (ricordata sul telefono e controllata contro l'elenco);
  - le schermate.
- **Integrazione con l'app esistente:**
  - Cantina, Cruscotto, banner offline e "Riprova" usano la cantina attiva;
  - l'uscita dall'account chiude anche l'ascolto degli inviti;
  - un nuovo evento "accesso perso" con un solo avviso per cantina;
  - lo stato della rete diventa osservabile, così i pulsanti si riattivano da soli.
- **Costo:**
  - un ascolto sugli inviti più quelli della sola cantina attiva;
  - nessun ascolto tenuto aperto in più: con l'uso previsto non serve, e si potrà aggiungere se il monitoraggio mostra letture alte.
- **Privacy:** gli errori passano dall'uscita unica di U1, che toglie le email; i messaggi d'errore sono testi fissi.
- **Test:**
  - test delle regole con la matrice 6 ruoli × 9 operazioni e ogni transizione;
  - test della logica, dei provider e delle schermate in tre lingue;
  - test end-to-end con il proprietario che agisce tramite il suo vero accesso;
  - i nuovi test vengono collegati alla CI.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
