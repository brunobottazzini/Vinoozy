## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** 2026-11-06
**Iteration:** 1
**Verdict Dictated:** no

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | lib/sharing/sharing_providers.dart > myMembershipsProvider, insieme locale `activating` | L'id della cantina viene tolto da `activating` solo quando l'attivazione fallisce. Dopo un'attivazione riuscita resta nell'insieme per tutta la vita del provider. Se il proprietario revoca la persona e la reinvita mentre l'app è aperta, o la persona esce e viene reinvitata, il documento torna `invited` ma non viene mai riattivato. La persona resta senza accesso e senza avviso fino al riavvio dell'app. BR1.4 chiede di attivare ogni invito `invited` e BR1.2 prevede il reinvito. L'unico test vicino (`sharing_providers_test.dart` riga 183) copre solo il nuovo tentativo dopo un fallimento. Verificato leggendo il codice, non eseguito. | Togliere il cellarId da `activating` anche dopo un'attivazione riuscita, oppure quando l'invito esce da `invited`. Aggiungere un test: invito attivo, poi revoca, poi di nuovo `invited` con lista confermata dal server, che deve produrre una seconda `activate`. | New |
| R-02 | Minor | lib/sharing/data/sharing_repository.dart > `_translate` e `_run` | Il secondo controllo dopo un `permission-denied` (cantina con `memberSlots >= 2` dà `limitReached`) vale per tutte le operazioni, non solo per `invite`. Una revoca, un cambio di permesso o un'uscita rifiutati per una gara (per esempio doppio tocco o invito già chiuso) in una cantina con 2 persone mostrano "Hai raggiunto il limite di 2 persone", che è fuorviante. | Applicare la rilettura `limitReached`/`alreadyInvited` solo a `invite`; per le altre operazioni tradurre un `permission-denied` in `notOwner` o in un errore generico, con un test. | New |
| R-03 | Minor | lib/sync/sync_error_bus.dart > `reportWriteRejected` e lib/sharing/sharing_providers.dart > `_onSyncEvent` | Ogni `permission-denied` su una scrittura in coda in una cantina condivisa pubblica `CellarAccessLost` e riporta la persona alla cantina personale. Lo stesso errore arriva però anche per un declassamento da `edit` a `read` con scritture in coda, o per una validazione dei campi rifiutata dalle regole. In quei casi la persona ha ancora la lettura, ma vede "Non hai più accesso" e viene spostata. È ciò che chiede il design (`security-design.md` §4, sorgente 3), quindi è una scelta accettata del design, non un difetto di implementazione. | Valutare di distinguere i casi: prima di dichiarare l'accesso perso, controllare che l'invito sia davvero `revoked` o sparito. In alternativa, accettare il rischio e annotarlo come limite noto. | New |
| R-04 | Minor | .github/workflows/promote.yml > passo "The rules of the build are the deployed ones" e .github/workflows/firebase-deploy.yml > input `ref` | Il passo risolve il ref letto dal titolo dell'ultima esecuzione con `git rev-parse` al momento della promozione. `firebase-deploy.yml` accetta anche un nome di ramo o un hash abbreviato come "commit contenuto in main". Se il ref è un ramo (per esempio `main`) e il ramo si è spostato dopo la pubblicazione, il controllo confronta con la punta attuale e non con ciò che è stato pubblicato. Può dare un falso esito positivo. Con un tag `v*` o un hash completo il rischio non c'è. | In `firebase-deploy.yml` accettare solo un tag `v*` o un hash completo di 40 caratteri. In alternativa, scrivere nel run-name l'hash risolto (non possibile direttamente) o confrontare i blob anche con il tag. | New |
| R-05 | Minor | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u7-sharing/code-generation/code-summary.md > "Test scritti ma non eseguiti" | Non sono mai stati eseguiti: `integration_test/sharing_test.dart` (nessun emulatore Android), la direzione 2 di `compat/` (nessun tag `v*`) e il passo nuovo di `promote.yml` (`gh api`, tag `build-*`). Sono dichiarati con onestà, ma il percorso a due utenti, che è quello che prova batch e regole insieme, non ha ancora un'esecuzione. | Non bloccante. Eseguire il job `e2e` in CI prima di unire e provare `promote.yml` alla prima promozione, come indicato nella checklist di rilascio. | New |

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| `npm run test:rules` (Java 17 locale) | 133 test: 132 verdi, 1 saltato (direzione 2 di `compat/`, nessun tag `v*`), 0 falliti | Conferma il dato dichiarato. Coprono matrice 6×9, transizioni, contatore, `memberOpKey`, `drinkingRecords` e la query sul gruppo di collezioni. |
| `flutter analyze --fatal-infos` | Nessun problema | Conferma il dato dichiarato. |
| `flutter test test/sharing test/u1` | 541 test verdi | Nessuna regressione di U1 nella parte rieseguita. Non ho rieseguito l'intera suite da 815 test né la copertura (98,41% su `lib/sharing/`, 90,06% di progetto), che restano il dato dichiarato dallo sviluppatore. |

### Summary

Le regole di Firestore sono fedeli al design e sicure. Il legame tra `memberOpKey` e `memberSlots` impedisce due inviti con un solo +1 e un terzo invito. Gli stati `invited` e `revoked` non danno accesso, l'invitato non può cambiare permesso né rientrare da `revoked`, la lettura sul gruppo di collezioni è limitata alla propria email verificata e non perde indirizzi. L'integrazione con U1 e U5 non regredisce, e le modifiche ai workflow sono corrette e chiudono in modo sicuro. Il difetto principale è nel codice dell'app: dopo un'attivazione riuscita l'invito non viene mai riattivato in caso di reinvito nella stessa sessione (Major). Un solo Major, quindi READY. Il Major va corretto prima di considerare chiusa l'unità; gli altri punti sono miglioramenti.
