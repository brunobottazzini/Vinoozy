# NFR Requirements — u2-estimation — Domande

Contesto: U2 è una libreria Dart pura, senza rete, disco né Firebase (`unit-of-work.md`, `functional-spec.md`, BR4.4). Molte categorie non si applicano: nessun accesso al cloud (NFR4), nessun costo (NFR5), nessun dato salvato (NFR6, NFR8). Restano velocità del calcolo (NFR2), qualità del codice (NFR7) e una scelta su come si aggiornano le tabelle enologiche.

Decisioni tecniche prese senza chiedere, perché non cambiano cosa vedi:
- **Velocità del calcolo:** stima, stato e abbinamenti di 500 vini in meno di 50 ms su un telefono di fascia media, così il cruscotto (NFR2, 2 s) ha margine.
- **Pacchetto:** `packages/estimation` nello stesso repository, con i propri test.
- **Copertura:** almeno il 90% delle righe del pacchetto, oltre la soglia dell'80% del progetto.
- **Test:** basati su tabelle, con tutte le 48 denominazioni e i casi limite.

## Q1. [Prodotto] Come si aggiornano le tabelle enologiche

Le tabelle di denominazioni, finestre e abbinamenti si possono correggere nel tempo (regola del progetto: le scelte enologiche restano correggibili).

A. Dentro l'app: una correzione esce con un nuovo aggiornamento dell'app dal Play Store (consigliato: semplice, funziona sempre senza rete, costo zero e tutto testato in CI)
B. Scaricate dal cloud: le tabelle stanno in Firestore e si aggiornano senza nuova versione dell'app (più flessibile, ma serve una versione di riserva dentro l'app, controlli sui dati scaricati e qualche lettura in più)
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Consolidated Summary Confirmation

- Tabelle enologiche (Q1): dentro l'app; una correzione esce con un aggiornamento dal Play Store.
- Velocità: stima, stato e abbinamenti di 500 vini in meno di 50 ms su un telefono di fascia media (margine per i 2 s del cruscotto, NFR2).
- Qualità: pacchetto Dart puro `packages/estimation`, copertura almeno 90% delle righe del pacchetto (soglia di progetto 80%, NFR7), test a tabella su tutte le 48 denominazioni e sui casi limite; nessun accesso a rete, disco, orologio o Firebase.
- Non applicabili a U2: sicurezza del cloud (NFR4), costo (NFR5), durabilità (NFR6), privacy (NFR8), accessibilità (NFR3, a carico di U4/U5), velocità di inserimento (NFR1, a carico di U4).

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
