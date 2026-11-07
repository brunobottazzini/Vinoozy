# NFR Design — u3-wine-catalog — Domande

Contesto: requisiti non funzionali di U3 approvati (`performance-`, `security-`, `scalability-`, `reliability-`, `observability-requirements.md`, `tech-stack-decisions.md`), `functional-spec.md` e `rules.md` di U3, `contract-summary.md` (C1, C2, C5).

Nessuna domanda aperta: le scelte di questo passo sono tecniche e derivano dai requisiti approvati. Le decisioni prese sono riassunte qui sotto per conferma.

## Consolidated Summary Confirmation

- **Organizzazione del codice** in `lib/catalog/`:
  - l'interfaccia `WineCatalog`;
  - un'implementazione che coordina le fonti;
  - il catalogo interno;
  - l'adattatore di Open Food Facts;
  - la cache su file;
  - il controllo dei limiti delle richieste;
  - un interruttore che sospende Open Food Facts dopo gli errori.

  Ogni parte riceve dall'esterno orologio, client HTTP e registratore degli eventi, così è testabile da sola.
- **Velocità:** il catalogo interno si costruisce una volta per sessione. Le ricerche usano parole già normalizzate. Una cache in memoria evita letture ripetute dal file.
- **Cache:** sta nel file `catalog_cache.json`. Si scrive in modo sicuro, prima su un file temporaneo e poi con una rinomina, al massimo ogni 2 secondi. Si cancella all'uscita dall'account ed è esclusa dal backup.
- **Open Food Facts:** si legge la risposta a flusso, fino a 1 MB, senza redirect e con un limite di 5 secondi. "Non trovato" è distinto dagli errori, e dopo 3 errori Open Food Facts si sospende per 5 minuti.
- **Controlli automatici:** il benchmark del catalogo si aggiunge al job `unit` della CI. Un controllo verifica che nessun file committato contenga il contatto per Open Food Facts.
- **Eventi:** solo `off_suspended` va a Crashlytics, con il tipo di errore e mai il testo dell'utente.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
