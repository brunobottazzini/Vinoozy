# Functional Design — u5-dashboard — Domande

Contesto: `unit-of-work.md` (U5: lista "da bere presto", grafici per stato, anno di picco e tipologia, descrizioni per il lettore schermo, stato vuoto), `requirements.md` (FR5.1–FR5.6, NFR2: cruscotto entro 2 secondi con 500 bottiglie), `stories.md` (US5.1, US5.2), contratto C2 della stima (stati `waiting`, `ready`, `drinkSoon`, `pastWindow`).

## Q1. [Prodotto] Quali barre nel grafico dello stato

FR5.3 nomina tre gruppi: da aspettare, pronte, oltre la finestra. La stima però ha quattro stati, perché distingue anche "da bere presto".

A. Quattro barre: da aspettare, pronte, da bere presto, oltre la finestra (consigliato). Si vede subito quante bottiglie sono urgenti, con lo stesso colore usato nella lista.
B. Tre barre come in FR5.3: "da bere presto" conta tra le pronte.
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q2. [Prodotto] Il terzo grafico: tipologia o regione

FR5.5 dice "per tipologia o regione".

A. Uno solo con un selettore per passare da tipologia a regione (consigliato). Parte da tipologia, e la scelta resta salvata sul telefono.
B. Solo per tipologia (rosso, bianco, rosato, spumante, dolce).
C. Solo per regione.
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Analisi delle risposte

Nessuna ambiguità: Q1 sceglie quattro barre, Q2 un solo grafico con selettore.

## Consolidated Summary Confirmation

- **Apertura:** l'app si apre sul Cruscotto (FR5.1), che legge la cantina salvata sul telefono, quindi funziona anche senza rete.
- **Da bere presto:** la lista dei vini in quello stato, dal più vicino alla fine della finestra; a parità, in ordine di nome. Se è vuota compare "Nessuna bottiglia in scadenza" (FR5.2).
- **Grafico dello stato:** quattro barre (Q1): da aspettare, pronte, da bere presto, oltre la finestra.
- **Grafico dei picchi:** bottiglie per anno di picco, dall'anno in corso ai 10 successivi, più due colonne "picco passato" e "oltre".
- **Terzo grafico:** un selettore passa da tipologia a regione (Q2). Parte da tipologia e ricorda la scelta. Ci sono le cinque tipologie più "non indicata". Per la regione si usano le prime 8 regioni più "altre".
- **Conteggi:** si contano le bottiglie, cioè la quantità di ogni vino, non le righe. I vini con quantità 0 non compaiono. Lo stato si calcola ogni volta con la data di oggi.
- **Accessibilità:** ogni barra mostra il suo numero, e ogni grafico ha una descrizione testuale letta da TalkBack (FR5.6).
- **Cantina vuota:** al posto dei grafici c'è un invito ad aggiungere il primo vino.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
