# Units of Work — Vinoozy

Fonti: `components.md` e `decisions.md` (Domain Design), `requirements.md`, `stories.md`, risposte in `units-generation-questions.md` (8 unità, piano approvato). Distribuzione: una sola app Android in Flutter, le regole di sicurezza Firebase e (dal 2026-11-05) nessuna funzione nel cloud: WineCatalog sta dentro l'app. Il walking skeleton è attivo (team-practices), quindi U1 è la fetta funzionante più piccola.

## Elenco

| Unit ID | Directory | Kind | Componenti | Complessità | Distribuzione |
|---------|-----------|------|------------|-------------|---------------|
| U1 | u1-skeleton | ui | Account (accesso), Cellar (aggiunta minima), Sync, Sharing (regole di base) | M | dentro l'app |
| U2 | u2-estimation | library | Estimation | M | pacchetto Dart usato dall'app |
| U3 | u3-wine-catalog | service | WineCatalog | M | modulo dentro l'app (aggiornato 2026-11-05) |
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

- **Descrizione**: modulo dentro l'app che offre suggerimenti di nomi, riconoscimento di un vino da un testo o da un codice a barre e i dati esterni per la stima, da un catalogo interno e da Open Food Facts.
- **Responsabilità**: limite di richieste verso Open Food Facts, timeout, cache, nessun dato personale verso la fonte esterna, attribuzione ODbL.
- **Note**: aggiornato il 2026-11-05 dopo la scelta del proprietario in Functional Design di U3 (Q1: catalogo interno e Open Food Facts; Q2: dentro l'app). In origine era una funzione cloud con la chiave di un fornitore; Open Food Facts non ha chiavi, quindi la funzione cloud non serve. Dipende da U2 per il riconoscimento dei nomi.

## U4 — u4-cellar

- **Descrizione**: gestione completa della cantina.
- **Responsabilità**: suggerimenti durante la scrittura, doppioni, validazioni, elenco con ricerca e filtri, modifica, eliminazione, + e - con quantità mai sotto 0, dettaglio con finestra, fiducia, fonte e abbinamenti, bevuta con conferma e annulla, storico, ricalcolo delle stime al ritorno della rete, unione delle quantità come variazioni (ADR-004).
- **Decisione del proprietario (2026-11-06, durante u7-sharing):** archivio dei vini finiti. L'elenco di tutti i giorni, cioè l'ascolto della cantina usato anche dal Cruscotto, carica solo i vini con bottiglie presenti (quantità maggiore di 0). I vini finiti vanno in un archivio "Bevuti", letto solo quando lo si apre. Lo storico delle bevute resta. Lo scopo è ridurre le letture di Firestore e restare nella quota gratuita. I dettagli, come la query e il passaggio tra elenco e archivio, si progettano nel design funzionale di U4.

## U5 — u5-dashboard

- **Descrizione**: cruscotto all'apertura.
- **Responsabilità**: lista "da bere presto", grafici per stato, anno di picco e tipologia, descrizioni per il lettore schermo, stato vuoto.

## U6 — u6-label-recognition

- **Descrizione**: aggiunta di un vino dalla foto dell'etichetta.
- **Responsabilità**: fotocamera e permesso, lettura del testo sul telefono, proposta tramite U3, quantità, conferma o correzione.

## U7 — u7-sharing

- **Descrizione**: condivisione della cantina.
- **Responsabilità**: inviti fino a 2 persone (da 5 a 2 il 2026-11-06), permessi, revoca, accesso della persona invitata e scelta tra più cantine, regole di sicurezza cloud dei permessi.

## U8 — u8-account

- **Descrizione**: ciclo di vita dell'account.
- **Responsabilità**: presentazione al primo avvio, uscita con avviso sulle modifiche non sincronizzate, cancellazione dell'account con eliminazione dei dati e revoca delle condivisioni.
