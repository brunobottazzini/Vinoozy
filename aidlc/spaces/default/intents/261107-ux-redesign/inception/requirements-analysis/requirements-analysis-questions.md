# Domande — Requirements Analysis (ux-redesign)

Contesto (Reverse Engineering):
- il modulo di aggiunta non ha campi per regione, denominazione o paese;
- il paese non esiste nel modello del vino;
- "Bevuta" salva subito, con solo "Annulla" per 6 secondi;
- il tema è piatto, con 5 colori, nessun font e nessuna immagine.

Le bandiere saranno emoji: nessuna dipendenza nuova, funzionano offline e su Android sono a colori. Lo decido io, con la possibilità di correggerlo.

## Q1. [Prodotto] Paesi e regioni

Come si scelgono paese e regione nel modulo?

A) Elenco dei principali paesi del vino con la bandiera (Italia, Francia, Spagna, Portogallo, Germania, Austria, Stati Uniti, Argentina, Cile, Australia, Nuova Zelanda, Sudafrica e altri), con le loro regioni vinicole principali da scegliere toccando. Per l'Italia ci sono tutte le 20 regioni. C'è sempre anche "Altra regione" da scrivere a mano. Paese e regione si compilano da soli quando il vino viene riconosciuto (consigliata)
B) Solo il paese con la bandiera; la regione si scrive a mano
C) Tutti i paesi del mondo con bandiera, regioni solo per i principali
X. Other (please specify)

[Answer]: A — "Reccomended non dimenticate il mondo nuovo come Brasile Cile Argentina Australia ed ecc"

## Q2. [Prodotto] Conferma della bevuta

Come deve funzionare "Bevuto"?

A) Pulsante chiaro con il verbo ("Ho bevuto"). Al tocco si apre un pannello dal basso con il vino (bandiera, annata, bottiglie rimaste), "Sì, l'ho bevuta" e "Annulla", e la possibilità di dare subito il voto con le stelle (consigliata)
B) Una semplice finestra di conferma "Hai bevuto una bottiglia di …?" con Sì e No
C) Si tiene premuto il pulsante per un attimo, senza finestra
X. Other (please specify)

[Answer]: A

## Q3. [Design] Quanto grafica

Quanto cambiamo l'aspetto?

A) Nuova identità visiva: palette del vino (bordeaux, oro, crema), schede con il colore del tipo di vino (rosso, bianco, rosato, bollicine, dolce), icone per tipo, bandiere ovunque, Dashboard con grafici più ricchi. La navigazione resta quella di oggi (consigliata)
B) Ritocco leggero: colori e bandiere, schermate quasi uguali
C) Riprogettazione completa, compresa la navigazione
X. Other (please specify)

[Answer]: A
