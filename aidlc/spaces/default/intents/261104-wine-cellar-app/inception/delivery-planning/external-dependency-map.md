# External Dependency Map — Vinoozy

Fonti: `bolt-plan.md`, `contract-summary.md`, `requirements.md`, `team-practices.md`, `components.md`.

Un **Bolt** è un passaggio di costruzione su una parte del lavoro che termina con qualcosa di funzionante. Qui sono elencate le cose esterne al progetto che un Bolt aspetta.

| Dipendenza | Proprietario | Tempo di attesa | Bolt bloccato | Se ritarda |
|------------|--------------|-----------------|---------------|------------|
| Progetto Firebase (piano a consumo, avviso di spesa a 1 €) | Proprietario | Minuti | B1 (solo per la produzione; lo sviluppo usa l'emulatore) | Si sviluppa e si testa con l'emulatore |
| Configurazione accesso Google (impronta SHA dell'app nel progetto Firebase) | Proprietario | Minuti | B1 | L'accesso funziona solo nell'emulatore |
| Repository GitHub e GitHub Actions | Proprietario | Minuti | B1 | Controlli solo in locale |
| Chiave di firma Android e account Google Play (già esistente) | Proprietario | Ore | Pubblicazione dopo B1 | Si prova con build di debug |
| Base dati vini esterna (scelta, chiave, licenza) | Fornitore esterno | Giorni | B3 | Si resta sulle regole interne di B2 |
| Scheda dell'app su Google Play (privacy policy, sicurezza dei dati) | Proprietario | Ore–giorni (revisione Google) | Rilascio in produzione dopo B8 | Si resta sul canale di test interno |
