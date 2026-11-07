# NFR Design — u1-skeleton — Domande

Contesto: `performance-requirements.md`, `security-requirements.md`, `tech-stack-decisions.md` (NFR Requirements di U1, approvati), `functional-spec.md`, `contract-summary.md`, revisione 2 delle NFR Requirements (1 punto importante e 3 minori da chiudere qui).

Nessuna domanda aperta: le scelte di questo passo sono tecniche e derivano dai requisiti approvati. Le decisioni prese sono riassunte qui sotto per conferma.

## Consolidated Summary Confirmation

- Cambio di account (punto importante della revisione): il controllo avviene a ogni avvio, non solo all'accesso. Se l'account con la sessione aperta è diverso da quello del registro delle modifiche in attesa, l'app non apre alcun dato e mostra la schermata di blocco. Da lì si sceglie "Accedi con <email>", che disconnette l'account attuale, oppure "Elimina le modifiche", con conferma. Il registro si cancella solo quando le modifiche sono arrivate nel cloud e l'account è lo stesso che le ha fatte.
- Avvisi dei vini rifiutati: ogni voce del giornale si chiude quando il vino risulta nel cloud, quando l'utente sceglie "Aggiungi di nuovo" o "Ignora", oppure dopo 3 avvisi. Il reset per cambio di account verifica il giornale prima di cancellarlo.
- Regole di sicurezza: in creazione si controllano anche `createdAt` (ora del server) e `name` (1–60 caratteri). Negli aggiornamenti dei vini sono ammessi solo i campi di C3, con `updatedBy` e `updatedAt` obbligatori.
- Riavvio di Firebase dopo la pulizia dei dati: come primo passo del codice si fa una piccola prova; se il riuso dell'istanza non funziona, l'app si riavvia da sola.
- Aggiornato dopo la prova sul telefono (2026-11-05): la configurazione di produzione arriva con `--dart-define-from-file=config/firebase_prod.json` (file mai committato) invece di un file Dart generato; "Riprova" sulla cantina riapre gli ascolti di cantina e vini, anche dopo un errore d'ascolto.
- Organizzazione del codice: componenti separati per accesso, cantina, sincronizzazione e registro locale, con un unico punto per gli errori e un unico ascoltatore per lo stato della rete.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
