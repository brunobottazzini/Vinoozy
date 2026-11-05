# Units of Work — Vinoozy

Fonti: `components.md` e `decisions.md` (Domain Design), `requirements.md`, `stories.md`, risposte in `units-generation-questions.md` (8 unità, piano approvato). Distribuzione: una sola app Android in Flutter, una funzione nel cloud (WineCatalog) e le regole di sicurezza Firebase. Il walking skeleton è attivo (team-practices), quindi U1 è la fetta funzionante più piccola.

## Elenco

| Unit ID | Directory | Kind | Componenti | Complessità | Distribuzione |
|---------|-----------|------|------------|-------------|---------------|
| U1 | u1-skeleton | ui | Account (accesso), Cellar (aggiunta minima), Sync, Sharing (regole di base) | M | dentro l'app |
| U2 | u2-estimation | library | Estimation | M | pacchetto Dart usato dall'app |
| U3 | u3-wine-catalog | service | WineCatalog | M | funzione cloud separata |
| U4 | u4-cellar | ui | Cellar (completo), uso di Estimation e WineCatalog | L | dentro l'app |
| U5 | u5-dashboard | ui | Dashboard | M | dentro l'app |
| U6 | u6-label-recognition | ui | LabelRecognition | S | dentro l'app |
| U7 | u7-sharing | ui | Sharing (completo) | M | dentro l'app + regole cloud |
| U8 | u8-account | ui | Account (ciclo di vita completo) | S | dentro l'app + pulizia nel cloud |

## U1 — u1-skeleton (fetta funzionante)

- **Descrizione**: l'app Android parte, l'utente accede con Google, scrive un vino (nome, annata, quantità), lo vede in un elenco semplice, anche senza rete, e il vino arriva su Firebase al ritorno della connessione.
- **Responsabilità**: struttura del progetto Flutter; tema chiaro/scuro e file di traduzione it/en/pt-BR; accesso Google e sessione; modello Cellar/Wine minimo; salvataggio locale e sincronizzazione (Sync) con indicatore offline; regole di sicurezza di base (ogni utente vede solo le proprie cantine); pipeline di build e test.
- **Note**: è l'unità verificata da capo a fondo prima delle altre; la stima non c'è ancora (il vino mostra "stima in arrivo").

## U2 — u2-estimation

- **Descrizione**: logica pura della stima: regole interne per tipologia, denominazione e annata; stato derivato; regola "da bere presto"; fiducia; abbinamenti per tipologia.
- **Responsabilità**: FR4.1–FR4.7 (parte di calcolo), FR7.2 (abbinamenti di riserva); interfaccia per ricevere dati esterni opzionali.
- **Note**: nessuna dipendenza da Flutter o Firebase, così si testa da sola fino all'80% e oltre.

## U3 — u3-wine-catalog

- **Descrizione**: funzione nel cloud che custodisce la chiave della base dati vini e offre suggerimenti di nomi, riconoscimento di un vino da un testo, finestre e abbinamenti.
- **Responsabilità**: autenticazione obbligatoria, limite di richieste per utente, timeout, nessun dato personale verso il fornitore.
- **Note**: la scelta del fornitore esterno avviene nella progettazione di questa unità; se non ce n'è uno adatto, la funzione risponde "non trovato" e l'app usa U2.

## U4 — u4-cellar

- **Descrizione**: gestione completa della cantina.
- **Responsabilità**: suggerimenti durante la scrittura, doppioni, validazioni, elenco con ricerca e filtri, modifica, eliminazione, + e - con quantità mai sotto 0, dettaglio con finestra, fiducia, fonte e abbinamenti, bevuta con conferma e annulla, storico, ricalcolo delle stime al ritorno della rete, unione delle quantità come variazioni (ADR-004).

## U5 — u5-dashboard

- **Descrizione**: cruscotto all'apertura.
- **Responsabilità**: lista "da bere presto", grafici per stato, anno di picco e tipologia, descrizioni per il lettore schermo, stato vuoto.

## U6 — u6-label-recognition

- **Descrizione**: aggiunta di un vino dalla foto dell'etichetta.
- **Responsabilità**: fotocamera e permesso, lettura del testo sul telefono, proposta tramite U3, quantità, conferma o correzione.

## U7 — u7-sharing

- **Descrizione**: condivisione della cantina.
- **Responsabilità**: inviti fino a 5 persone, permessi, revoca, accesso della persona invitata e scelta tra più cantine, regole di sicurezza cloud dei permessi.

## U8 — u8-account

- **Descrizione**: ciclo di vita dell'account.
- **Responsabilità**: presentazione al primo avvio, uscita con avviso sulle modifiche non sincronizzate, cancellazione dell'account con eliminazione dei dati e revoca delle condivisioni.
