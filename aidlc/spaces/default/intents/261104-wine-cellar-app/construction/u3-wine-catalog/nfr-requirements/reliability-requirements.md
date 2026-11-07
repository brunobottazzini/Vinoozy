# Reliability Requirements — u3-wine-catalog

Fonti: `requirements.md` (NFR6, FR4.7), `rules.md` di U3 (BR2.1, BR2.2, BR2.3), `contract-summary.md` (C1 errori, C5), riepilogo confermato in `nfr-requirements-questions.md`.

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR6.1 | Senza rete funzionano suggerimenti interni, riconoscimento dell'etichetta interno e profilo. Le operazioni non lanciano errori di rete (FR4.7). | Test con il client finto che lancia un errore di rete a ogni chiamata. |
| NFR6.2 | Un guasto di OFF non diventa mai un errore per l'utente. "Non trovato" non è un errore: HTTP 404, oppure 200 con prodotto assente (`status: 0`), oppure ricerca con zero risultati. Questi esiti sono risposte riuscite: si salvano in cache come lista vuota e azzerano il conteggio degli errori. Sono errori: timeout di 5 secondi, rete non raggiungibile, HTTP 429, HTTP 5xx, ogni altro codice diverso da 200 e 404, redirect, JSON non valido, risposta oltre 1 MB. Dopo 3 errori di fila OFF si sospende per 5 minuti (BR2.2). | Test: 3 codici a barre non trovati (404) non sospendono OFF; 3 errori 503 sì; dopo 5 minuti (tempo simulato) una nuova richiesta parte. |
| NFR6.3 | Nessun nuovo tentativo automatico verso OFF, per non aggravare un problema e non consumare il budget. | Test: un solo tentativo per chiamata. |
| NFR6.4 | Cache illeggibile o rovinata: si svuota e si continua senza errori (BR2.1). Una scrittura della cache che fallisce non interrompe l'operazione. | Test con contenuto della cache non valido e con la scrittura che lancia un errore. |

Nota: lo scarto delle risposte arrivate quando la query nel campo è già cambiata (F1) è compito di U4, che confronta la query inviata con quella attuale. U3 non ha uno stato della schermata.
