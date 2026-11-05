# Contract Design — Domande

Contesto: `unit-of-work.md`, `unit-of-work-dependency.md`, `components.md`, `requirements.md`. Un "contratto" è l'accordo su quali dati passano tra due unità, in che forma e cosa succede in caso di errore. Contratti previsti: funzione cloud (U3) verso l'app (U4, U6); libreria di stima (U2) verso U4 e U5; modello dati Firestore condiviso (U1) verso U4–U8; revoca condivisioni (U7) verso U8; funzione cloud verso la base dati vini esterna.

## Q1. [Sviluppo] Come l'app chiama la funzione cloud WineCatalog

A. Funzioni "callable" di Firebase: l'accesso dell'utente viene verificato in automatico (consigliata)
B. Normali chiamate HTTPS con il token dell'utente inviato a mano
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q2. [Sviluppo] Come gestire le modifiche ai contratti nel tempo

C'è un solo client (l'app), ma versioni vecchie dell'app restano installate sui telefoni.

A. Versione nel nome della funzione e nel modello dati (es. `v1`); solo aggiunte compatibili, un cambiamento incompatibile crea una nuova versione (consigliata)
B. Nessuna versione: si aggiorna tutto insieme
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Consolidated Summary Confirmation

- Chiamata alla funzione cloud (Q1): funzioni "callable" di Firebase, con verifica automatica dell'accesso.
- Versioni (Q2): versione `v1` nel nome delle funzioni e nel modello dati; solo aggiunte compatibili, un cambiamento incompatibile crea una nuova versione.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
