# Domande — Requirements Analysis (pending-banner-fix)

Contesto: Reverse Engineering ha confermato la causa. La scrittura delle bevute (`batch.commit()`) e `waitForPendingWrites()` girano su thread diversi del plugin Android e possono arrivare a Firestore in ordine inverso. Così la fascia "modifiche in attesa" si spegne anche offline (u4-cellar NFR6.6). La correzione tiene "in attesa" fino al completamento della stessa scrittura. Vale per bevuta, annulla e modifica di voto e note, che passano tutte da `_commit`.

## Q1. [Sviluppo] Ampiezza della correzione

Lo sviluppatore ha visto tre punti vicini al bug:
1. `SyncWatcher._drain` (`lib/sync/sync_watcher.dart`) si basa sullo stesso presupposto d'ordine.
2. La cancellazione dei vini (`WineRepository._deleteBatches`) non usa la sonda, anche se il suo commento lo dice.
3. `drinkingRecordsPendingProvider` è globale e non si azzera quando si riaprono gli ascoltatori di Firestore.

Cosa includiamo in questa correzione?

A) Solo la fascia dopo le scritture delle bevute (NFR6.6). Gli altri tre punti restano annotati come lavoro separato. Correzione piccola e a basso rischio (consigliata)
B) La fascia delle bevute più il punto 1 (`SyncWatcher`), che ha la stessa causa
C) Tutti e quattro: fascia, `SyncWatcher`, cancellazione dei vini con la sonda, azzeramento dello stato globale
X. Other (please specify)

[Answer]: A
