# NFR Requirements — u3-wine-catalog — Domande

Contesto: `functional-spec.md` e `rules.md` di U3 (approvati): catalogo dentro l'app, con il catalogo interno e Open Food Facts (OFF). `requirements.md` (NFR1–NFR8), `contract-summary.md` (C1, C2, C5), `team.md` (Testing Posture, Code Style).

Nessuna domanda aperta. Le scelte di questo passo sono tecniche e derivano dal design approvato e dalle regole del team. Sono riassunte qui sotto per conferma.

## Consolidated Summary Confirmation

- **Velocità:**
  - I suggerimenti interni arrivano in meno di 50 ms sul telefono di riferimento, con 500 vini in cantina, così compaiono mentre scrivi (NFR1).
  - Il riconoscimento del testo di un'etichetta richiede meno di 100 ms, senza contare OFF.
  - OFF ha sempre un limite di 5 secondi.
- **Affidabilità:**
  - OFF non blocca mai l'app.
  - Dopo 3 errori di fila OFF si sospende per 5 minuti.
  - Una cache rovinata si svuota da sola.
  - Senza rete funziona tutto, tranne i risultati di OFF.
- **Sicurezza e privacy:**
  - Verso OFF solo collegamenti HTTPS.
  - Si inviano solo il testo cercato e il codice a barre.
  - Le risposte di OFF si controllano prima dell'uso: campi troppo lunghi o strani si scartano.
  - Il contatto per OFF arriva dalla configurazione della build, mai dal codice.
  - Cache e indice si cancellano all'uscita dall'account.
- **Costo:** 0 €. Nessun servizio cloud nostro, e OFF è gratuito.
- **Qualità e test:**
  - I test non chiamano mai il vero OFF: in CI si usa un server finto con risposte registrate, compresi errori, lentezza e risposte non valide.
  - Copertura del modulo del catalogo almeno 80%, dentro la soglia di progetto.
  - I test verificano limiti, cache, sospensione, nessun dato personale e mappatura delle categorie.
- **Licenza:** attribuzione ODbL accanto alle proposte e nella schermata delle informazioni.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
