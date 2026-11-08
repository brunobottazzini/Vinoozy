# Mockup — nuova UX di Vinoozy

**Mockup visivi (pagina con le schermate del telefono):** https://claude.ai/artifact/9eQbXQaRuCowMnZH2qdakd
Il file sorgente è `vinoozy-mockups.html`, in questa cartella.

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR3, NFR1–NFR5) e le scelte Q1 = A, Q2 = A, Q3 = A.
- `codekb/Vinoozy/` e `inception/reverse-engineering/developer-scan.md`: schermate e componenti di oggi.
- Mockup della prima versione: `aidlc/spaces/default/intents/261104-wine-cellar-app/inception/refined-mockups/`. La struttura delle schermate e la navigazione restano quelle.

Questo lavoro salta i mockup grezzi (wireframe e user flow) per scelta del piano: si parte dalle schermate esistenti.

## Schermate

| # | Schermata | Stato mostrato | Requisiti |
|---|---|---|---|
| 1 | Cantina, lista dei vini | con vini, filtri, schede con bandiera, tipo, stato e "Ho bevuto"; "Aggiungi" flottante | FR1.4, FR2.1, FR3.2 |
| 2 | Nuovo vino, scelta di paese e regione | paese del Nuovo Mondo (Argentina) scelto, regioni di Mendoza | FR1.1, FR1.2 |
| 3 | Nuovo vino riconosciuto dal catalogo | Italia e Piemonte compilati da soli; tutte le 20 regioni italiane; tipo con colore e nome | FR1.2, FR1.3 |
| 4 | Pannello "Ho bevuto" | conferma con bottiglie 2 → 1 e voto facoltativo | FR2.2, FR2.3 |
| 5 | Dettaglio del vino | bandiera grande, regione, finestra di consumo, "Ho bevuto una bottiglia", "Togli una bottiglia senza bevuta" | FR1.4, FR2.1, FR2.4 |
| 6 | Dashboard | totale, "Da bere presto", grafici per regione (con bandiere) e per tipo | FR3.3 |
| 7 | Cantina in tema scuro e senza rete | palette scura, fascia "Senza rete", vini di Cile, Brasile e Australia | FR3.1, NFR1 |

## Stati che il codice deve coprire anche se non disegnati

Seguono gli stessi componenti delle schermate sopra:
- Cantina vuota: invito ad aggiungere il primo vino.
- Errore di caricamento con "Riprova": comportamento invariato.
- Pannello "Ho bevuto" senza rete: la bevuta si registra sul telefono e compare la fascia "Senza rete".
- Vino senza paese: nessuna bandiera.
- Paese senza emoji di bandiera: sigla del paese in un riquadro.
- "Altro paese" con la ricerca su tutti i paesi.
- Storico e lettura dell'etichetta con le nuove schede e i colori.
