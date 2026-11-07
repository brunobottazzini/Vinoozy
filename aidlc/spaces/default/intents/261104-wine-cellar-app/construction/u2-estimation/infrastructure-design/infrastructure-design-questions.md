# Infrastructure Design — u2-estimation — Domande

Contesto: `security-design.md` e `logical-components.md` (NFR Design di U2, approvati), `components.md`, `functional-spec.md`, `contract-summary.md` (C2), workflow `ci.yml` e `release.yml` definiti da U1.

Nessuna domanda aperta. U2 è una libreria Dart dentro l'app: non ha server, risorse cloud, costi o rilasci propri. L'unica infrastruttura che la riguarda sono i controlli automatici in GitHub Actions, già esistenti, a cui si aggiunge un job. Le decisioni prese sono riassunte qui sotto per conferma.

## Consolidated Summary Confirmation

- Nuovo job `estimation` in `ci.yml`, in parallelo agli altri e senza emulatori: formattazione e analisi del pacchetto, script di purezza, test con copertura almeno 90% del solo pacchetto, benchmark con le soglie del design. Se uno di questi fallisce, il merge in `main` è bloccato, come per gli altri job.
- Copertura di progetto: il job `unit` dell'app unisce la copertura del pacchetto alla sua e controlla l'80% su tutto, senza esclusioni.
- Nessun cambiamento al rilascio: il pacchetto entra nell'app come dipendenza locale e viaggia con lo stesso bundle firmato verso il test interno di Google Play. Una correzione delle tabelle esce con una nuova versione dell'app.
- La misura della velocità sul tuo telefono (25 ms) entra nella checklist prima di approvare la produzione.
- Nessun segreto, nessuna risorsa Firebase, costo zero.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
