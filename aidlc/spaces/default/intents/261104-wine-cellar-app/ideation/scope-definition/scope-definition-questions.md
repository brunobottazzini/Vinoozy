# Scope Definition — Domande

Contesto: `intent-statement.md`, `feasibility-assessment.md`, `constraint-register.md`. Già deciso: login Google, inserimento da testo, stima del momento ideale con indice di fiducia, grafici dei vini pronti, funzionamento offline, solo Android, budget 0 €, nessuna scadenza.

## Q1. [Prodotto] Come vuoi essere avvisato quando una bottiglia si avvicina alla fine della finestra ideale

È il cuore dell'obiettivo "non perdere il vino".

A. Notifica sul telefono
B. Solo evidenziata nell'app (cruscotto)
C. Notifica + riepilogo periodico (es. mensile) dei vini da bere
D. Not yet defined
X. Other (please specify)

[Answer]: B

## Q2. [Prodotto] Quali grafici vuoi nel cruscotto (select all that apply)

A. Stato delle bottiglie: da aspettare / pronte / oltre il picco
B. Linea del tempo: quante bottiglie raggiungono il picco per anno
C. Distribuzione per tipologia o regione
D. Not yet defined
X. Other (please specify)

[Answer]: A, B, C

## Q3. [Prodotto] Vuoi registrare dove si trova la bottiglia in cantina

Utile per trovarla subito, aggiunge un campo all'inserimento.

A. Sì: posizione (es. scaffale e ripiano)
B. No
C. Facoltativa: la inserisco solo se voglio
D. Not yet defined
X. Other (please specify)

[Answer]: B

## Q4. [Prodotto] Cosa succede quando bevi una bottiglia

A. La segno come bevuta e resta nello storico, con voto e note
B. La segno come bevuta e resta nello storico, senza voto né note
C. Viene semplicemente tolta dall'inventario
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q5. [Prodotto] In che ordine costruire le funzioni

A. Valore prima: inventario e stime utilizzabili il prima possibile
B. Rischio prima: verificare subito la base dati vini esterna
C. Dipendenze prima: fondamenta tecniche (login, sincronizzazione) e poi le funzioni
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q6. [Prodotto] Oltre al nucleo, cosa deve esserci già nel primo rilascio che userai (select all that apply)

Il nucleo è: login Google, inserimento da testo, inventario, stima del momento ideale, grafici, offline. Il resto lo mettiamo comunque nella prima versione, ma dopo il nucleo.

A. Inserimento da foto dell'etichetta
B. Abbinamento cibo-vino
C. Condivisione della cantina con permessi
D. Avvisi (vedi Q1)
E. None: prima solo il nucleo
X. Other (please specify)

[Answer]: A, B, C, D

## Consolidated Summary Confirmation

- Avvisi (Q1): nessuna notifica; le bottiglie vicine alla fine della finestra sono evidenziate nel cruscotto dell'app.
- Grafici (Q2): stato delle bottiglie (da aspettare / pronte / oltre il picco), linea del tempo dei picchi per anno, distribuzione per tipologia o regione.
- Posizione in cantina (Q3): non registrata.
- Bottiglia bevuta (Q4): segnata come bevuta, resta nello storico con voto e note.
- Ordine di costruzione (Q5): valore prima, cioè inventario e stime utilizzabili il prima possibile.
- Primo rilascio (Q6): nucleo (login Google, inserimento da testo, inventario, stima del momento ideale, grafici, offline) più inserimento da foto, abbinamento cibo-vino, condivisione con permessi e avvisi nell'app.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
