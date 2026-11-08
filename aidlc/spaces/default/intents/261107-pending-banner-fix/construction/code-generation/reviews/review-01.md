## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** 2026-11-07T10:08:20Z
**Iteration:** 1
**Verdict Dictated:** no

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | lib/cellar/data/pending_writes_probe.dart > trackWrite (con lib/firebase/firestore_bootstrap.dart > resetPersistence e lib/account/reset_coordinator.dart > reset) | Il contatore `_openWrites` vive quanto il processo (la sonda è creata una sola volta in bootstrap.dart e `drinkingRecordsPendingProvider` non viene invalidato al cambio account). Scenario concreto: l'utente A beve offline, esce con "Esci comunque", entra l'utente B (altro account); `ResetCoordinator.reset` esegue `terminate()` + `clearPersistence()`. Il batch accodato di A viene scartato dalla cache locale, ma nel Firestore SDK nativo il callback di un `batch.commit()` non viene completato né fallito da `terminate()` o da `clearPersistence()` (a user change l'SDK fallisce solo i task di `waitForPendingWrites`, non i commit delle mutazioni; non ho potuto verificarlo sul sorgente Android perché in ~/.pub-cache c'è solo il plugin Dart/piattaforma). Prima della correzione era proprio `waitForPendingWrites` a essere annullato ("due to User change") e a spegnere la fascia; ora quel percorso di uscita non esiste più per le scritture. Se il future resta aperto, `_openWrites` non torna a 0 e la fascia "in attesa" resta accesa per B per tutto il processo (nuova regressione, di segno opposto al bug corretto). Nessun test copre il caso. Gli altri casi sono sicuri: un cambio utente senza reset fa fallire il commit con permission-denied (il future si chiude), e `_onUserChanged` per sessione scaduta lascia le scritture in coda e quindi la fascia accesa è corretta. | Aggiungere un modo per azzerare la sonda nel reset (ad esempio `PendingWritesProbe.reset()` con un numero di generazione, così che il `finally` di un `trackWrite` vecchio non decrementi il contatore nuovo), chiamato da `ResetCoordinator.reset` o da `resetPersistence` dopo `clearPersistence()`, più un test con un `write` che non si completa mai e un reset. In alternativa, documentare nel piano il rischio come accettato e verificarlo sull'emulatore (offline, esci, entra con altro account, controlla la fascia). | New |
| R-02 | Minor | lib/cellar/data/pending_writes_probe.dart > checkAtStartup | `checkAtStartup` ora usa `_startupPending` indipendente dal contatore, quindi lo spegnimento al timeout o all'errore non può spegnere la fascia mentre una scrittura è aperta: corretto. Resta una nota: il commento "Called once, at app start" non è imposto; una seconda chiamata creerebbe un secondo timer e `_endStartup` del primo spegnerebbe il flag mentre il secondo attende. Oggi viene chiamato una sola volta, quindi non è un difetto attuale. | Facoltativo: proteggere con un controllo o un assert, oppure lasciare il commento come contratto. | New |
| R-03 | Minor | test/cellar/data/pending_writes_probe_test.dart e test/cellar/data/drinking_record_repository_test.dart > nuovi test FR1.x | I test sono significativi: l'orchestratore ha verificato che 3 su 3 falliscono con i file lib di HEAD e che 24 su 24 passano con la correzione; coprono ordine inverso, due scritture aperte (FR1.2) e fallimento della prima con la seconda aperta (FR1.3). Manca un test sul punto della finding Major (scrittura che non si completa mai insieme a un reset) e sul caso in cui il `write` lancia in modo sincrono dentro `trackWrite`. | Aggiungere il test di reset quando si risolve la finding Major. | New |

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| Confronto `git diff HEAD` dei due file lib | Eseguito: modifica minima (una riga nel repository, riscrittura della sonda) | Contatore: `_openWrites++` precede il `try` e il `finally` decrementa sempre, quindi non può andare negativo né perdere un conteggio in caso di eccezione; il `catch (_)` evita doppio report perché `_commit` riporta già l'errore una volta (`write.then(onError)`), e il report di `pendingProbeFailed` resta solo in `checkAtStartup` (invariato nel comportamento). |
| Test (verifica dell'orchestratore, non rieseguita) | 3/3 nuovi falliscono su HEAD, 24/24 passano con la correzione | Conferma che le regressioni FR1.1 sono vere; non copre il reset. |

### Summary

La correzione risolve la causa (ordine tra `waitForPendingWrites` e commit) con un contatore corretto, senza fughe né doppi report, e i test sono validi. Il rischio principale è un commit che non si completa dopo `terminate()`/`clearPersistence()` nel reset tra account: la fascia potrebbe restare accesa per il nuovo utente, ed è consigliato azzerare la sonda nel reset prima del merge. Una sola finding Major non blocca, quindi READY.
