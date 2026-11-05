# Bolt Plan — Vinoozy

Fonti: `unit-of-work.md`, `unit-of-work-dependency.md`, `unit-of-work-story-map.md` (Units Generation), `requirements.md`, `stories.md`, `mockups.md`, `components.md`, `contract-summary.md`, `team-practices.md`, risposte in `delivery-planning-questions.md`.

Un **Bolt** è un passaggio di costruzione su una parte del lavoro che termina con qualcosa di funzionante e verificato. Qui ogni Bolt contiene una sola unità (Q2) e i Bolt si costruiscono uno dopo l'altro (Q3). Il **walking skeleton** è la versione minima che funziona da capo a fondo, costruita per prima per dimostrare che i pezzi si collegano.

Ramo e unione (team-practices, Way of Working): ogni Bolt su un ramo breve da `main`, unito con un solo commit (squash) che porta il nome del Bolt.

| # | Bolt | Unità | Walking skeleton | Dipende da |
|---|------|-------|------------------|------------|
| B1 | b1-skeleton | U1 u1-skeleton | Sì | — |
| B2 | b2-estimation | U2 u2-estimation | No | — |
| B3 | b3-wine-catalog | U3 u3-wine-catalog | No | — |
| B4 | b4-cellar | U4 u4-cellar | No | B1, B2, B3 |
| B5 | b5-dashboard | U5 u5-dashboard | No | B1, B2 |
| B6 | b6-label-recognition | U6 u6-label-recognition | No | B1, B3 |
| B7 | b7-sharing | U7 u7-sharing | No | B1 |
| B8 | b8-account | U8 u8-account | No | B1, B7 |

L'ordine rispetta il grafo delle dipendenze (ogni Bolt arriva dopo quelli da cui dipende).

## B1 — b1-skeleton (walking skeleton)

- **Prova**: app Android Flutter, accesso Google, aggiunta di un vino scritto, salvataggio sul telefono, sincronizzazione Firebase, regole di sicurezza del proprietario, CI su GitHub Actions.
- **Definition of Done**: un vino aggiunto senza rete compare su Firebase (emulatore) al ritorno della connessione; un secondo utente non lo vede; formattazione, analisi, test, copertura ≥ 80% e test da capo a fondo su emulatore Android passano in CI.
- **Ipotesi di fiducia**: "Flutter + Firestore offline + accesso Google funzionano insieme su Android e in CI gratuita, e il ciclo offline → online non perde dati."
- **Demo attesa**: in modalità aereo aggiungo "Barolo 2016 x2", riattivo la rete e il vino appare nella console dell'emulatore Firebase.
- **Controllo reale**: il comando di verifica scelto per l'intento (vedi sotto) esegue l'intera suite, compreso il test da capo a fondo dello scheletro.

## B2 — b2-estimation

- **Definition of Done**: stima con regole interne, stati (da aspettare, pronto, da bere presto, oltre la finestra), fiducia e abbinamenti per tipologia; tutti i casi limite di FR4.6 coperti da test; copertura ≥ 80%.
- **Ipotesi di fiducia**: "Le regole interne danno finestre credibili per i vini tipici della cantina (es. Barolo, Barbera, bianchi giovani) con fiducia dichiarata in modo onesto."
- **Demo attesa**: tabella di 10 vini reali con finestra, stato e fiducia calcolati.

## B3 — b3-wine-catalog

- **Definition of Done**: fornitore della base dati vini scelto e provato; tre funzioni callable `v1` funzionanti nell'emulatore con autenticazione, limite di richieste e timeout; "non trovato" gestito; costo previsto 0 €.
- **Ipotesi di fiducia**: "Esiste una fonte dati utilizzabile gratuitamente che migliora la stima di B2 per la maggior parte dei vini della cantina; se no, lo sappiamo subito e restiamo sulle regole interne."
- **Demo attesa**: ricerca "Barolo 2016" con suggerimenti e profilo dalla fonte esterna.

## B4 — b4-cellar

- **Definition of Done**: storie US2.1 (suggerimenti), US2.3, US3.1–US3.4, US4.1, US4.2, US6.1, US6.2, US7.1, US9.2 soddisfatte; inserimento sotto i 30 secondi misurato.
- **Ipotesi di fiducia**: "La cantina si gestisce interamente dall'app: inventario sempre allineato e stima visibile per ogni vino."
- **Demo attesa**: aggiungo, modifico, bevo con voto e annullo una bevuta.

## B5 — b5-dashboard

- **Definition of Done**: US5.1, US5.2; cruscotto entro 2 secondi con 500 bottiglie; descrizioni per TalkBack.
- **Ipotesi di fiducia**: "Aprendo l'app capisco subito cosa bere e nessuna bottiglia scade senza che me ne accorga."
- **Demo attesa**: cruscotto con lista "da bere presto" e tre grafici su dati di prova.

## B6 — b6-label-recognition

- **Definition of Done**: US2.2; proposta da foto con quantità, conferma o correzione.
- **Ipotesi di fiducia**: "Fotografare l'etichetta è più veloce che scrivere per la maggior parte delle bottiglie."
- **Demo attesa**: foto di un'etichetta reale e vino proposto correttamente.

## B7 — b7-sharing

- **Definition of Done**: US8.1–US8.4; regole cloud dei permessi verificate nell'emulatore (lettura sola, modifica, revoca).
- **Ipotesi di fiducia**: "Due persone gestiscono la stessa cantina senza perdere aggiornamenti e senza accessi non autorizzati."
- **Demo attesa**: invito un secondo account, che vede la cantina e, con il permesso di modifica, segna una bevuta.

## B8 — b8-account

- **Definition of Done**: US1.2, US1.3; presentazione al primo avvio; cancellazione account che elimina i dati e revoca le condivisioni.
- **Ipotesi di fiducia**: "L'app rispetta le regole di Google Play sulla cancellazione dell'account."
- **Demo attesa**: cancello un account di prova e verifico che i dati non siano più presenti.

## Impostazioni della costruzione

- **Ordine di costruzione**: un'unità alla volta attraverso tutte le sue fasi (`unit-major`), eseguite una dopo l'altra (`serial`), con approvazione a ogni unità completata (Q3).
- **Comando di verifica**: progetto nuovo senza codice; la scelta del comando viene rimandata al primo controllo dello scheletro, quando esisterà il progetto Flutter (proposta: uno script `tool/verify.sh` che esegue formattazione, analisi, test con copertura ≥ 80%, emulatore Firebase e test da capo a fondo).
