# Infrastructure Design — u4-cellar — Domande

Contesto:
- design non funzionale di U4 approvato: `logical-components.md`, `security-design.md`, `performance-design.md`;
- `functional-spec.md` di U4, `components.md`, `contract-summary.md`;
- infrastruttura esistente:
  - `firebase.json`, `firestore.rules`, `firestore.indexes.json`;
  - `ci.yml`, con i job `format`, `analyze`, `unit`, `estimation`, `rules` ed `e2e`;
  - `release.yml`;
  - `firebase-deploy.yml`, manuale, con un tag `v*` o un hash completo e l'approvazione di `firebase-prod`;
  - `promote.yml`, che confronta le regole della build con l'ultima pubblicazione riuscita e usa `RULES_FEATURES`;
  - `docs/release-checklist.md`.

Non ci sono domande aperte: le scelte seguono quelle di U7 e il design approvato. Le decisioni sono riassunte qui sotto per conferma.

## Consolidated Summary Confirmation

- **Infrastruttura:**
  - nessuna risorsa nuova e nessun servizio a pagamento;
  - cambiano solo due file già gestiti:
    - `firestore.rules`: campi nuovi dei vini, aggiornamento ed eliminazione delle bevute, flag del backfill;
    - `firestore.indexes.json`: nuovo indice composito su `drinkingRecords` (`drankOn` e `createdAt` decrescenti) per lo Storico;
  - costo 0 €.
- **Costo nella quota gratuita:**
  - l'elenco legge solo i vini presenti (`quantity > 0`);
  - lo Storico legge 30 bevute per pagina;
  - il backfill della chiave dei doppioni scrive al più 500 vini una volta sola per cantina, molto sotto le 20.000 scritture al giorno;
  - restano validi l'avviso a 35.000 letture al giorno e il budget di 1 €.
- **Pubblicazione, in quest'ordine (come U7):**
  1. merge su `main` con tutti i controlli verdi;
  2. pubblicazione di regole e indice con `firebase-deploy.yml`, con la tua approvazione;
  3. indice "Abilitato" nella console;
  4. promozione dell'app.
  
  Le regole nuove accettano ancora tutte le scritture dell'app attuale, che non manda i campi nuovi. Pubblicarle prima quindi non disturba nessuno.
- **Blocco automatico dell'ordine:**
  - in `promote.yml`, `RULES_FEATURES` passa da `sharing` a `sharing cellar`;
  - le scritture nuove dell'app, compresa ogni creazione di vino perché ora porta `matchKey`, sono segnate `requiresRules: "cellar"`;
  - la promozione si ferma se le regole della build non sono quelle pubblicate.
- **Controlli automatici in `ci.yml`, nessun job nuovo:**
  - `rules`: `test:rules` aggiunge `u4.rules.test.mjs`; il controllo degli indici verifica anche quello dello Storico, con la cartella di prova `missing_history.json`;
  - `analyze`: `tool/check_rule_ids.sh` e il suo test, per avere ogni regola BR1.x citata nei test;
  - `unit`: copertura dell'80% anche su `lib/cellar/` e il benchmark `cellar_benchmark.dart` (filtri ≤ 20 ms, finestra effettiva ≤ 5 ms);
  - `e2e`: `cellar_test.dart` e `concurrent_drink_test.dart`, raccolti in automatico.
  
  `firebase-deploy.yml` usa già `npm run test:rules`, quindi esegue anche i test di U4 prima della pubblicazione.
- **Monitoraggio:**
  - nessun avviso nuovo;
  - i motivi di errore della Cantina (`cellar_*`, `estimate_refresh_failed`, `match_key_backfill_failed`, `pending_probe_failed`) arrivano in Crashlytics senza email e senza nomi, produttori o note;
  - l'avviso esistente sui rifiuti delle regole resta;
  - nella checklist mensile si guarda anche se il backfill è finito (nessun errore `match_key_backfill_failed` ripetuto).
- **Checklist di rilascio, nuova sezione §1-quinquies "Cantina":**
  - misure sul telefono: inserimento < 30 s, salvataggio ≤ 300 ms, dettaglio ≤ 500 ms, scorrimento;
  - prova offline: bevuta dell'ultima bottiglia, banner "in attesa", sincronizzazione;
  - Annulla, Storico, unione dei doppioni;
  - verifica che note e voti rientrino già nella scheda "Sicurezza dei dati";
  - ordine: prima le regole, poi l'app.
- **Rollback:**
  - **app:** si ferma il rilascio graduale e si pubblica una correzione;
  - **regole:** `firebase-deploy.yml` con il tag precedente. L'app nuova vedrebbe rifiutate le creazioni dei vini con `matchKey` e le modifiche delle bevute. Per questo il rollback delle regole va fatto **insieme** allo stop del rilascio dell'app. I dati restano intatti;
  - **indice:** si lascia com'è.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
