# Functional Design — u1-skeleton — Domande

Contesto: `unit-of-work.md` (U1: prima versione funzionante), `unit-of-work-story-map.md` (US1.1, US2.1, US9.1, US9.2, US10.1), `stories.md`, `requirements.md`, `components.md`, `contract-summary.md` (C3). Quasi tutto è già deciso; resta una scelta che cambia come funziona l'app senza rete.

## Q1. [Sviluppo] Come conservare i dati sul telefono quando non c'è rete

A. Usare la memoria offline integrata di Firestore: le modifiche restano sul telefono e partono da sole al ritorno della rete (consigliato: meno codice, già pensata per questo)
B. Un database locale separato sul telefono più una sincronizzazione scritta da noi (più controllo, molto più lavoro e più rischi di errori)
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Consolidated Summary Confirmation

- Dati offline (Q1): memoria offline integrata di Firestore; le modifiche restano sul telefono e partono da sole al ritorno della rete.
- Già deciso nelle fasi precedenti e applicato a U1: accesso Google (sessione mantenuta offline), aggiunta di un vino scritto (nome, annata o "senza annata", quantità 1–99), elenco semplice della cantina, indicatore "Offline - sincronizzazione in attesa", ogni utente vede solo la propria cantina, lingue it/en/pt-BR, tema chiaro/scuro.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
