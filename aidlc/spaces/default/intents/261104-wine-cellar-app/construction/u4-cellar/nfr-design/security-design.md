# Security Design — u4-cellar

Fonti: `security-requirements.md` (NFR4.1–NFR4.9, NFR8.1–NFR8.3, NFR3.1–NFR3.4, NFR6.1–NFR6.6), `tech-stack-decisions.md`, `functional-spec.md`, `logical-components.md`, `firestore.rules` attuale (U1 e U7), riepilogo confermato in `nfr-design-questions.md`. Come nei requisiti, il file raccoglie anche accessibilità e affidabilità.

## 1. Regole cloud

### Vini

- `wineFields()` aggiunge `matchKey`, `baseWindow` e `windowAdjustment`.
- Nuove funzioni:

```text
function validWindow(w) {
  return w == null || (w is map
    && w.keys().hasOnly(['startYear','peakYear','endYear','confidence','source','basis','qualifier'])
    && w.keys().hasAll(['startYear','peakYear','endYear','confidence','source'])
    && w.startYear is int && w.peakYear is int && w.endYear is int
    && w.startYear >= 1900 && w.endYear <= 2200
    && w.startYear <= w.peakYear && w.peakYear <= w.endYear
    && w.confidence in ['high','medium','low']
    && w.source in ['catalog','internalRules']
    && (!('basis' in w) || w.basis in ['catalog','denomination','wineType','generic'])
    && (!('qualifier' in w) || w.qualifier in ['riserva','superiore','granSelezione']));
}
function validAdjustment(a) {
  return a == null || (a is map && a.keys().hasOnly(['kind','year','recordId'])
    && a.kind in ['tooYoung','justRight','pastPeak']
    && a.year is int && a.year >= 1900 && a.year <= 2200
    && a.recordId is string && a.recordId.size() >= 1 && a.recordId.size() <= 128);
}
function validMatchKey(k) { return k == null || (k is string && k.size() <= 400); }
```

- `validWineCreate` e `validWineUpdate` aggiungono `validWindow(window)`, `validWindow(baseWindow)`, `validAdjustment(windowAdjustment)` e `validMatchKey(matchKey)`. Nell'update, solo se il campo è tra quelli cambiati.
- **Backfill (NFR4.2):** un nuovo caso di update: `canEditCellar && changed.hasOnly(['matchKey']) && validMatchKey(data.matchKey)`, senza `updatedBy` e `updatedAt`.
- L'eliminazione resta `isOwner` (U7).

### Bevute

- **Create:** `fields` aggiunge `condition` e `updatedAt`. `condition` deve essere `tooYoung`, `justRight` o `pastPeak`, oppure assente. `updatedAt` può mancare oppure essere uguale a `request.time`.
- **Update (NFR4.3):**

```text
allow update: if signedIn() && canEditCellar(cellarId)
  && (resource.data.recordedBy == uid() || isOwner(cellarId))
  && incoming().diff(existing()).affectedKeys().hasOnly(['rating','notes','drankOn','condition','updatedAt'])
  && incoming().updatedAt == request.time
  && validRating(incoming().get('rating', null))
  && validNotes(incoming().get('notes', null))
  && validDrankOn(incoming().drankOn)
  && validCondition(incoming().get('condition', null));
```

- **Delete (NFR4.4):** `isOwner(cellarId) || (canEditCellar(cellarId) && resource.data.recordedBy == uid() && request.time < resource.data.createdAt + duration.value(10, 'm'))`.

### Cantina (NFR4.9)

Un nuovo caso di update: chi ha `canEditCellar`, con `changed.hasOnly(['matchKeyBackfill'])`, da `matchKeyBackfill` assente o `false` a `incoming().matchKeyBackfill == true`.

### Accessi

La tabella in testa a `firestore.rules` resta valida: nessun percorso nuovo supera 2 accessi.

### Indici (NFR4.8)

- **`firestore.indexes.json`:** composito su `drinkingRecords` (`drankOn` DESCENDING, `createdAt` DESCENDING, ambito `COLLECTION`).
- **`tool/check_firestore_indexes.sh`:** controlla anche questo indice, con un messaggio diverso per ogni indice mancante.
- **Test dello script:** `ok.json` aggiornato e `missing_history.json` nuovo.

### Test e collegamenti

- `test/rules/u4.rules.test.mjs` copre i casi di NFR4.1–NFR4.9. Le bevute con `createdAt` nel passato si preparano con `withSecurityRulesDisabled`.
- Lo script `test:rules` di `package.json` include il nuovo file.
- In `compat/app-writes.json`, le scritture nuove portano `requiresRules: "cellar"`. Tra queste c'è **ogni creazione di vino**: la nuova app scrive `matchKey`, che le regole in produzione oggi non ammettono.
- `compat.rules.test.mjs` legge le funzioni ammesse da `RULES_FEATURES` in `.github/workflows/promote.yml`. Quel valore passa da `sharing` a `sharing cellar`. Così il test "ogni `requiresRules` è protetto" resta verde, e il controllo di promozione blocca l'app nuova finché regole e indici di U4 non sono pubblicati.

### Funzioni complete (correzione dopo la revisione)

```text
function validRating(r)    { return r == null || (r is int && r >= 1 && r <= 5); }
function validNotes(n)     { return n == null || (n is string && n.size() <= 1000); }
function validDrankOn(d)   { return d is string && d.matches('^[0-9]{4}-[0-9]{2}-[0-9]{2}$'); }
function validCondition(c) { return c == null || c in ['tooYoung','justRight','pastPeak']; }

function validDrinkingRecord() {          // sostituisce quella di U7
  let data = incoming();
  return data.keys().hasOnly(['wineId','wineName','vintage','drankOn','rating','notes',
                              'condition','recordedBy','createdAt','updatedAt'])
    && data.keys().hasAll(['wineId','wineName','drankOn','recordedBy','createdAt'])
    && data.wineId is string && data.wineId.size() >= 1 && data.wineId.size() <= 128
    && data.wineName is string && data.wineName.size() >= 1 && data.wineName.size() <= 120
    && (data.get('vintage', null) == null
        || (data.vintage is int && data.vintage >= 1900 && data.vintage <= 2100))
    && validDrankOn(data.drankOn)
    && validRating(data.get('rating', null))
    && validNotes(data.get('notes', null))
    && validCondition(data.get('condition', null))
    && data.recordedBy == uid()
    && data.createdAt == request.time
    && (data.get('updatedAt', null) == null || data.updatedAt == request.time);
}
```

- **Campi facoltativi:** nelle regole dei vini si passano sempre come `data.get('window', null)`, `data.get('baseWindow', null)`, `data.get('windowAdjustment', null)` e `data.get('matchKey', null)`.
- **Cantina:** il caso del backfill usa `resource.data.get('matchKeyBackfill', false) == false && incoming().matchKeyBackfill == true`.
- **Eliminazione di una bevuta:** anche per il proprietario richiede `resource != null`. Una cancellazione di un documento già cancellato viene così **rifiutata**, e con lei tutto il batch dell'"Annulla", compreso il +1. Due "Annulla" dello stesso proprietario da due telefoni non danno quindi +2.

## 2. Privacy (NFR8)

- **Motivi fissi:** `cellar_save_failed`, `cellar_drink_failed`, `cellar_undo_failed`, `cellar_record_update_failed`, `cellar_delete_failed`, `cellar_merge_failed`, `estimate_refresh_failed`, `match_key_backfill_failed`, `cellar_reconcile_failed`, `pending_probe_failed`.
- **Valori sensibili tolti dai report:** nome del vino, produttore, denominazione e note.
- **Test:** con valori marcatore, nessun marcatore arriva all'`ErrorSink` finto.

## 3. Accessibilità (NFR3)

- `DrinkSnackBar`: durata di 6 s, oppure di 10 s se `MediaQuery.of(context).accessibleNavigation` o `disableAnimations` sono veri. In quel caso l'azione "Annulla" resta raggiungibile da TalkBack.
- Stelle del voto: `Semantics(button: true, selected: …, label: 'Voto N su 5')`.
- Stato di ogni vino: icona più testo (la mappa `statusIcons` di U5), fiducia e fonte come testo.
- Guideline di contrasto e tocchi, testo al 200%, nelle tre lingue.

## 4. Affidabilità (NFR6)

- **Quantità:** ogni scrittura che cambia la quantità passa da `QuantityDelta`:
  - un aumento usa `forIncrease`;
  - una diminuzione richiede `canDecrease` e usa `increment(-1)`.
  
  I test coprono i valori salvati −2, 0 e 3.
- **Annulla:** `DrinkingRecordRepository.undo` legge la bevuta dalla cache (`Source.cache`):
  - se esiste, fa un batch con `delete` e `addBottles(1)`;
  - poi, se `windowAdjustment.recordId` era quello della bevuta, ricalcola (BR1.12);
  - se non esiste, restituisce `UndoResult.nothingToUndo`.
- **Stime:** `estimateWindow` e il catalogo sono in try/catch per vino. Un errore lascia il vino senza finestra e lo rimette in coda.
- **Recupero dopo la rete (NFR6.6):** all'evento `onChanged(true)` di `NetworkStatus` riparte `EstimateRefresher`, e `RecordReconciler` (`logical-components.md`) riprende le operazioni lasciate a metà offline.
- **Annulla rifiutato:** l'annullamento in coda può arrivare al server dopo più di 10 minuti, oppure dopo che la bevuta è stata cancellata. In quel caso il rifiuto lo gestisce `DrinkingRecordRepository` con il motivo `cellar_undo_failed` e il messaggio "Annulla non riuscito: la bottiglia resta segnata come bevuta". **Non** passa da `reportWriteRejected`, così non diventa un falso "accesso perso" di U7.
- **Riscontro cambiato dallo Storico:** `updateRecord` che cambia `condition` o `drankOn` fa ripartire il ricalcolo di BR1.12, come l'"Annulla".
- **Ledger e sincronizzazione di U1:**
  - le scritture dei vini (aggiunta, modifica, bottiglie, stima, unione, eliminazione) passano dal `LocalLedger` di U1 come oggi;
  - per le bevute si aggiunge `SyncSource.drinkingRecords`, così il banner "Offline - sincronizzazione in attesa" conta anche bevute, voti e note in coda. Nessun ascolto aperto copre tutte le bevute: lo Storico legge a pagine, e un vino finito esce dall'elenco con `quantity > 0`. Perciò questa fonte **non** viene da uno snapshot ma da `PendingWritesProbe` (`logical-components.md`):
    - dopo ogni scrittura di una bevuta (`drink`, `undo`, `updateRecord`, eliminazione) segna la fonte come "in attesa" con `SyncStatusTracker.setPending(SyncSource.drinkingRecords, true)`;
    - poi aspetta `FirebaseFirestore.waitForPendingWrites()` e, quando si chiude, la rimette a `false`;
    - all'avvio dell'app fa la stessa attesa una volta, così le scritture rimaste in coda da una sessione precedente contano anche loro; se l'attesa si chiude entro 300 ms il banner non cambia;
    - se l'attesa fallisce (per esempio all'uscita dall'account) la fonte torna a `false` e il caso è registrato con il motivo `pending_probe_failed`;
    - `setPending` cambia solo lo stato "in attesa": non conta come passaggio da cache a server, quindi non fa partire `SyncWatcher`.
    - Test: un vino bevuto fino all'ultima bottiglia offline lascia il banner "in attesa" finché la scrittura non è confermata.
  - i rifiuti delle scritture dei vini e delle bevute vanno in `SyncErrorBus` con `reportWriteRejected`, tranne l'"Annulla" (sopra).
- **Eliminazione:** a parti di 400 operazioni, con il vino per ultimo. Se una parte fallisce, si ferma e lo segnala, e il vino resta.
  - Una parte può essere rifiutata perché una delle bevute era già stata cancellata nel frattempo (`resource != null`, §1), per esempio da un "Annulla" su un altro telefono. In quel caso il repository rilegge `where wineId` dal server e riprova **una volta** con le sole bevute rimaste.
  - Se anche il secondo tentativo fallisce, oppure se si è offline, l'eliminazione aggiunge una voce `purgeRecords` a `RecordReconciler`, che la completa al ritorno della rete. Il vino si elimina solo quando non restano bevute.
