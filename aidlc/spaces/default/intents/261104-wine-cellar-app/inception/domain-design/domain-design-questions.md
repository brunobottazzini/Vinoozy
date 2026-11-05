# Domain Design — Domande

Contesto: `requirements.md`, `stories.md`, `team-practices.md`. Qui decido i "mattoni" logici del codice (componenti) e chi possiede quali dati; tecnologia e distribuzione vengono dopo.

## Q1. [Sviluppo] Come dividere l'app in componenti

A. Per area di responsabilità (consigliata): Accesso/Account, Cantina (vini, quantità, bevute e storico), Stima (finestra ideale, stato, abbinamenti), Cruscotto (statistiche per i grafici), Condivisione (inviti e permessi), Sincronizzazione (lavoro offline e invio al cloud), Riconoscimento etichetta
B. Più granulare: come A, ma con Storico e Abbinamenti come componenti separati
C. Più compatta: Cantina e Stima insieme in un solo componente
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q2. [Sviluppo] Dove gira la consultazione della base dati vini esterna

Riguarda sicurezza e costo: se la base dati richiede una chiave d'accesso, metterla nell'app la espone a chiunque la scarichi.

A. Una piccola funzione nel cloud fa da intermediario e custodisce la chiave; il telefono usa le regole interne quando è offline (consigliata)
B. Il telefono chiama direttamente la base dati esterna
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Consolidated Summary Confirmation

- Componenti (Q1): divisione per area di responsabilità: Accesso/Account, Cantina (vini, quantità, bevute e storico), Stima (finestra ideale, stato, abbinamenti), Cruscotto, Condivisione, Sincronizzazione, Riconoscimento etichetta.
- Base dati esterna (Q2): una piccola funzione nel cloud fa da intermediario e custodisce la chiave; offline il telefono usa le regole interne.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
