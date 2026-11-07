# Infrastructure Design — u7-sharing — Domande

Contesto:
- design non funzionale di U7 approvato (`logical-components.md`, `security-design.md`, `performance-design.md`), `functional-spec.md`, `contract-summary.md`;
- infrastruttura esistente: `firebase.json` già punta a `firestore.rules` e `firestore.indexes.json`; il workflow `firebase-deploy.yml` pubblica regole e indici in produzione solo su avvio manuale e con approvazione dell'ambiente `firebase-prod`;
- `ci.yml`, `release.yml`, `docs/firebase-setup.md`, `docs/release-checklist.md`.

Non ci sono domande aperte. Le decisioni sono riassunte qui sotto per conferma.

## Consolidated Summary Confirmation

- **Infrastruttura:** nessuna risorsa nuova e nessun servizio a pagamento. Cambiano solo due file già gestiti: le regole (`firestore.rules`) e gli indici (`firestore.indexes.json`, con il nuovo indice per trovare gli inviti). Costo 0 €.
- **Pubblicazione, in quest'ordine:**
  1. merge su `main` con tutti i controlli verdi;
  2. pubblicazione delle regole e dell'indice con il workflow manuale già esistente (`firebase-deploy.yml`), con la tua approvazione;
  3. attesa che l'indice risulti "pronto" nella console Firebase (di solito pochi minuti);
  4. solo dopo, promozione della versione dell'app con la condivisione.
  
  Le regole nuove sono compatibili con l'app attuale, quindi pubblicarle prima non disturba chi usa la versione vecchia.
- **Controlli automatici in `ci.yml`:**
  - job `rules`: tutti i test delle regole tramite `npm run test:rules` (compresi quelli nuovi della condivisione), il controllo dell'indice e il test di quel controllo;
  - job `unit`: copertura dell'80% anche su `lib/sharing/`;
  - job `e2e`: il test con due utenti (invito, comparsa della cantina, permesso, revoca).
- **Monitoraggio:**
  - nuovo avviso via email quando le letture del giorno superano **35.000** (70% della quota gratuita);
  - l'avviso esistente sui rifiuti delle regole resta, con una nota: dopo una revoca qualche rifiuto è normale;
  - gli errori della condivisione arrivano in Crashlytics senza email;
  - controllo mensile dell'uso nella checklist.
- **Checklist di rilascio:**
  - prova con due telefoni: invito, comparsa, cambio di permesso, revoca, uscita;
  - misura dei tempi;
  - aggiornamento della scheda "Sicurezza dei dati" di Google Play (l'app conserva l'email delle persone invitate);
  - ordine di pubblicazione: prima le regole, poi l'app.
- **Rollback:**
  - **app:** si ferma il rilascio graduale e si pubblica una correzione;
  - **regole:** si ripubblicano quelle della versione precedente con lo stesso workflow manuale, indicando il tag precedente. Le regole vecchie non conoscono la condivisione, quindi le persone invitate perdono l'accesso finché non si corregge, ma i dati restano intatti;
  - **indice:** si lascia com'è, perché un indice in più non fa danni.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
