# Architecture Decision Records — Domain Design

Fonti: `requirements.md`, `stories.md`, `team-practices.md`, `components.md`, risposte in `domain-design-questions.md`.

## ADR-001: Componenti divisi per area di responsabilità

## Status: Accepted

- **Context** — Un solo sviluppatore, 10 aree funzionali (FR1–FR10), test con copertura dell'80% (team-practices). Servono confini chiari ma pochi.
- **Decision** — Otto componenti: Account, Cellar, Estimation, WineCatalog, LabelRecognition, Sharing, Sync, Dashboard (Q1). Lo storico delle bevute sta in Cellar, gli abbinamenti in Estimation.
- **Consequences** — Positive: Estimation è logica pura e testabile da sola; ogni dato ha un solo proprietario. Negative: Cellar è il componente più grande; Dashboard dipende da due componenti.
- **Alternatives Rejected** — Più granulare (Storico e Abbinamenti separati): più confini da mantenere senza un ritmo di cambiamento diverso. Più compatta (Cantina + Stima): mescola dati e regole enologiche che cambiano spesso.
- **Security** — Il confine di Sharing concentra in un punto le regole di accesso, riducendo il rischio di controlli dimenticati.

## ADR-002: Intermediario cloud per la base dati vini esterna

## Status: Accepted

- **Context** — La base dati vini esterna può richiedere una chiave d'accesso; un'app pubblicata può essere decompilata (NFR4). Budget 0 €/mese (NFR5).
- **Decision** — Un componente WineCatalog nel cloud custodisce la chiave e risponde solo a utenti autenticati, con limite di richieste per utente; offline il telefono usa le regole interne di Estimation (Q2).
- **Consequences** — Positive: la chiave non lascia mai il cloud; si può cambiare fornitore senza aggiornare l'app. Negative: richiede il piano a consumo di Firebase (già accettato, avviso a 1 €) e aggiunge un salto di rete ai suggerimenti.
- **Alternatives Rejected** — Chiamata diretta dal telefono: chiave esposta e fornitore legato alla versione dell'app.
- **Security** — Autenticazione obbligatoria, limite di richieste, timeout; nessun dato personale inviato al fornitore esterno (solo nomi di vini).

## ADR-003: Stato del vino calcolato, non salvato

## Status: Accepted

- **Context** — Lo stato (da aspettare, pronto, da bere presto, oltre la finestra) dipende dalla data di oggi (FR4.5, FR4.6).
- **Decision** — Estimation salva solo la finestra (inizio, picco, fine) e calcola lo stato al momento della lettura.
- **Consequences** — Positive: nessuno stato vecchio da aggiornare, funziona offline. Negative: il calcolo si ripete a ogni apertura (trascurabile con meno di 500 bottiglie, NFR2).
- **Alternatives Rejected** — Stato salvato e aggiornato da un processo periodico: richiede un servizio sempre attivo e può mostrare dati vecchi offline.
- **Security** — Nessun impatto.

## ADR-004: Quantità sincronizzate come variazioni, mai sotto zero

## Status: Accepted

- **Context** — Fino a 6 persone possono modificare la stessa cantina offline (FR8.1, FR9.4); due bevute contemporanee non devono perdersi né portare la quantità sotto 0 (revisione di User Stories, R-02).
- **Decision** — Sync invia le variazioni di quantità come incrementi (es. -1) che si sommano nel cloud; Cellar limita il risultato a 0 e registra comunque ogni bevuta nello storico. Per gli altri campi vale l'ultima modifica.
- **Consequences** — Positive: nessuna bevuta persa; regola semplice da spiegare. Negative: se due persone bevono "l'ultima" bottiglia, lo storico avrà due voci e la quantità 0, da mostrare come possibile errore.
- **Alternatives Rejected** — Ultima modifica vince anche sulla quantità: perde aggiornamenti. Blocco della modifica senza rete: contrario a FR9.1.
- **Security** — Le regole del cloud rifiutano incrementi da chi ha solo lettura (Sharing).
