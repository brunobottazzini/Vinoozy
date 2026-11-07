## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** 2026-11-06
**Iteration:** 1
**Verdict Dictated:** no

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Minor | lib/catalog/core/off/open_food_facts_source.dart > `_fetch` (scadenza di 5 s) | Alla scadenza la richiesta resta aperta: il `Completer` si chiude e la lettura del corpo viene annullata se è già iniziata. Se invece la risposta non è ancora arrivata, la connessione sottostante non viene interrotta e resta fino a quando il server risponde o cade. L'esito e il budget sono corretti, ma il socket non viene liberato. | Usare una richiesta annullabile (`http.AbortableRequest` con `abortTrigger` legato alla scadenza) oppure registrare il limite come accettato nel riepilogo. | New |
| R-02 | Minor | lib/catalog/core/catalog_cache_store.dart > `_readEntries` / `_readHints` | Leggendo `catalog_cache.json` il codice limita solo il numero di proposte per voce. Le lunghezze dei campi (120, 80, 60) non vengono riapplicate. Il file sta nella cartella privata ed è escluso dal backup, quindi il rischio è basso, ma un file danneggiato può superare il tetto di 3 MB di NFR2.3. | Applicare gli stessi troncamenti anche in lettura, oppure scartare il file se supera una dimensione massima. | New |
| R-03 | Minor | lib/catalog/core/catalog_coordinator.dart > `_external` (chiavi `search:`) | La chiave di cache è `search:<query>` senza la lingua. Una risposta ottenuta con `lc=it` viene servita anche con `lc=en`. Il design (BR2.1) prescrive proprio questa chiave, quindi non è un difetto del codice. Significa che l'ordine dei risultati può dipendere dalla lingua usata nella prima richiesta. | Nessuna azione obbligatoria. Valutare se aggiungere la lingua alla chiave nella progettazione di U4. | New |

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| `flutter test test/catalog` | PASS, 120 test verdi | Coincide con code-summary. I test controllano comportamenti reali: `followRedirects` falso, User-Agent, annullamento della lettura alla scadenza, `too_large` con `onCancel`, risposta scartata dopo il cambio utente, nessun testo utente nel logger. Non ho trovato test sempre verdi. |
| `flutter analyze` | PASS, nessun problema | Nessuna regressione nell'app. |
| `tool/check_off_config.sh` | PASS (581 file) | Nessun contatto OFF committato né nominato nei workflow. Nessuna email in `lib/`. Nessun Firestore nel catalogo. Nessun import di Flutter, `path_provider` o Firebase in `lib/catalog/core/`. |
| `dart test` in packages/estimation | PASS, 321 test | Coincide con code-summary. |
| `tool/check_estimation_purity.sh` | PASS (10 file) | Il pacchetto resta puro dopo le aggiunte (`catalog.dart`, estrazione di `tokenizeAll` e `recognizeWords` in `recognizer.dart`). |

### Summary

Il codice di U3 rispetta le regole da BR1.1 a BR5.3. Ho verificato in particolare: host fisso con `Uri.https`, nessun redirect, un'unica scadenza di 5 s con annullamento del flusso, tetto di 1 MB in lettura a flusso, distinzione tra non trovato (404, `status: 0`, non vino, zero risultati) e fallimento, circuit breaker a 3 errori e 5 minuti, budget a finestra mobile (8 ricerche e 60 letture, la cache non conta), OFF spento senza contatto, e solo enum e numeri nei registratori. Anche la cache è corretta: hash del proprietario, epoca incrementata da `clear()`, `deleteAll` che include il `.tmp`, risposte in volo scartate dopo il cambio utente, salvataggi serializzati con `.tmp` e rinomina, e limiti di 200 voci, 10 proposte, 500 indici e 30 giorni. Restano solo tre rilievi minori. Le modifiche a `ci.yml` aggiungono passi senza alterare quelli esistenti. Non ho potuto eseguire in locale il job GitHub Actions, perché riproduce comandi già verificati.
