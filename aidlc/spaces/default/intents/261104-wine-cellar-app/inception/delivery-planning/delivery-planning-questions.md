# Delivery Planning — Domande

Contesto: `unit-of-work.md` (8 unità), `unit-of-work-dependency.md`, `contract-summary.md`, `team-practices.md`. Un **Bolt** è un passaggio di costruzione su una parte del lavoro (una o più unità) che termina con qualcosa di funzionante. La prima unità, u1-skeleton, è già decisa come **walking skeleton**: la versione minima che funziona da capo a fondo.

## Q1. [Prodotto] Dopo la prima fetta funzionante, cosa costruiamo prima

A. Il rischio prima: la stima e la base dati vini esterna (U2, U3), poi il resto
B. Il valore prima: cantina completa e cruscotto (U4, U5), poi il resto
C. Un misto: prima la stima con regole interne (U2, rischio basso e alto valore), poi la funzione cloud (U3, rischio fornitore), poi cantina e cruscotto, infine foto, condivisione e account (consigliato)
D. Not yet defined
X. Other (please specify)

[Answer]: C

## Q2. [Sviluppo] Quanto grande ogni Bolt

A. Un Bolt per unità (8 Bolt), così ognuno si prova da solo
B. Bolt che raggruppano più unità collegate (meno Bolt, più grandi)
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q3. [Sviluppo] I Bolt si costruiscono uno dopo l'altro o in parallelo

A. Uno dopo l'altro, con la tua approvazione a ogni unità completata (consigliato per un progetto personale)
B. In parallelo dove le dipendenze lo permettono
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q4. [Prodotto] Cosa ti preoccupa di più di questa costruzione

Serve ad affrontarlo presto.

A. Che la stima del momento ideale non sia affidabile (fonte dati)
B. Che il funzionamento offline e la sincronizzazione diano problemi
C. Il tempo complessivo: vedere qualcosa di usabile presto
D. Niente in particolare
X. Other (please specify)

[Answer]: A

## Consolidated Summary Confirmation

- Ordine (Q1): prima la fetta funzionante (U1), poi la stima con regole interne (U2), la funzione cloud della base dati vini (U3), la cantina completa (U4) e il cruscotto (U5), infine foto (U6), condivisione (U7) e account (U8).
- Dimensione (Q2): un Bolt per unità, 8 Bolt.
- Esecuzione (Q3): uno dopo l'altro, con la tua approvazione a ogni unità completata.
- Preoccupazione principale (Q4): l'affidabilità della stima del momento ideale, quindi U2 e U3 arrivano subito dopo la fetta funzionante e U3 parte con la scelta e la prova della fonte dati.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
