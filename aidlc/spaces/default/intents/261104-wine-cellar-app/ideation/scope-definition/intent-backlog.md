# Intent Backlog — Vinoozy

Fonti: `intent-statement.md`, `feasibility-assessment.md`, `constraint-register.md`, `scope-document.md`. Prioritizzazione MoSCoW, ordine "valore prima" (Q5): prima il nucleo, poi le altre capacità del primo rilascio (Q6).

## Backlog prioritizzato

| # | Elemento (proto-unità) | MoSCoW | Dipende da | Note |
|---|------------------------|--------|------------|------|
| B1 | Accesso con Google e cantina personale salvata nel cloud, utilizzabile offline | Must | — | Fondamenta minime per non perdere dati |
| B2 | Aggiunta di un vino da testo e inventario delle bottiglie | Must | B1 | Obiettivo: meno di 30 secondi per bottiglia |
| B3 | Stima del momento ideale con indice di fiducia (base dati esterna, poi regole interne) | Must | B2 | Rischio principale (feasibility R1) |
| B4 | Cruscotto: grafici e bottiglie vicine alla fine della finestra evidenziate | Must | B3 | Rende visibile l'obiettivo "non perdere il vino" |
| B5 | Bottiglia bevuta: storico con voto e note | Must | B2 | Tiene l'inventario allineato |
| B6 | Inserimento da foto dell'etichetta | Should | B2 | Velocizza l'inserimento; conferma sempre dell'utente |
| B7 | Abbinamento cibo-vino | Should | B2 | Stessa fonte dati della stima, se disponibile |
| B8 | Condivisione della cantina con permessi | Should | B1 | Richiede regole per modifiche contemporanee (feasibility R4) |
| B9 | Versione iPhone e login Apple | Won't (questa volta) | B1 | Con l'account Apple Developer |
| B10 | Notifiche, posizione in cantina, prezzi | Won't (questa volta) | — | Escluse in scope-document |

## Flusso di valore

Accesso (B1) → aggiungo una bottiglia (B2, B6) → l'app stima quando berla (B3) → vedo cosa è pronto (B4) e con cosa abbinarlo (B7) → la bevo e la registro (B5); la cantina può essere gestita anche in due (B8).

## Assumptions & Open Questions

None.
