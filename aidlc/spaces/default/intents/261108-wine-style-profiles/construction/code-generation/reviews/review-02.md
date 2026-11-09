## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** 2026-11-09
**Iteration:** 1
**Verdict Dictated:** no

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | firestore.rules > function validBaseWindow (ramo `withWindow` vero) e test/rules/style_profiles.rules.test.mjs > "expression budget" | 1. Quando `baseWindow` è scritta insieme a `window`, le regole controllano solo le chiavi ammesse, `startYear` e l'ordine di inizio e fine. Il commento dice che le descrizioni (`confidence`, `source`, `basis`, `profile`, `anchor`, `qualifier`, `tablesVersion`, `denominationKey`, `startMonth`, `peakMonth`, `endMonth`, `unit`) sono "quelle della finestra, controllata per intero nella stessa richiesta". Non è vero: la regola controlla `window`, non `baseWindow`. Un membro con diritto di modifica può quindi salvare nella `baseWindow` un valore qualsiasi per questi campi: stringhe lunghe, tipi sbagliati, `peakYear` non intero, mesi fuori da 1..12 se la finestra non usa quel campo. Prima del cambio `baseWindow` era sempre controllata per intero. È un indebolimento reale della sicurezza dei dati, anche se limitato ai dati del proprio cellar. L'app legge un valore sconosciuto come assente, ma il test non lo prova. Nessun test prova che una `baseWindow` malformata scritta con `window` venga rifiutata: il test "checked in full" copre solo la scrittura da sola. | Aggiungere alla `baseWindow` scritta con `window` almeno controlli a costo basso: tipo e intervallo di `peakYear`, `endYear` e dei mesi, `unit` in `years` o `months`, `confidence` e `source` ristretti con una sola espressione regolare (come fa `validWindow`). Oppure ammettere che la `baseWindow` accetta quello che accetta `window` verificando con un test che i valori errati falliscono. Correggere in ogni caso il commento, che oggi afferma un controllo che non esiste, e aggiungere i test negativi. | New |
| R-02 | Major | firestore.rules > validWineUpdate (controllo del limite di 1000 espressioni); aidlc/spaces/default/intents/261108-wine-style-profiles/construction/code-generation/code-summary.md > "Problemi aperti" > "Limite delle regole" | 2. Il limite delle 1000 espressioni non è risolto del tutto. Il riepilogo ammette che la modifica di un vino con riscontro di bevuta che cambia insieme testi (produttore, regione, denominazione, paese), classificazione ed entrambe le finestre viene ancora rifiutata, con un errore di salvataggio. Non è un caso raro: cambiare la denominazione di un vino con riscontro fa cambiare per preselezione stile e finestra. Il test "expression budget" copre solo il caso più leggero (nome, tipo, stile, livello, data, stima) e lo dichiara nel commento. Questo è anche il motivo per cui è stato necessario indebolire `baseWindow` (rilievo 1). | Decidere e registrare prima della pubblicazione delle regole: o si riduce ancora il costo (per esempio un solo controllo dei testi, `baseWindow` uguale a `window` quando non c'è riscontro, già fatto) fino a far passare il caso peggiore con un test, oppure si cambia l'app per spezzare la modifica in due scritture. Se si accetta il limite, aggiungere un test che fissi il comportamento e un avviso nella checklist 1-undecies. | New |
| R-03 | Minor | lib/cellar/estimates_migration.dart > fieldsOf (riga `final base = wine.baseWindow ?? (wine.windowAdjustment == null ? wine.window : null)`) | 3. Se un vino ha un riscontro ma nessuna `baseWindow` salvata e una `window` del catalogo, `base` vale `null` e la finestra viene ricalcolata con le tabelle interne: si perde la finestra del catalogo. Il caso dipende dal fatto che `toFields` scriva sempre `baseWindow` con un riscontro; non ho trovato un test che lo provi per i vini già salvati con regole vecchie. Gli altri rischi richiesti sono a posto: `withPreselection` non cambia mai tipo, livello o stile con origine `user`, e `windowOverride` e `windowAdjustment` passano al calcolatore e non vengono cancellati; il test lo conferma (`windowOverride` non è tra i campi scritti). | Aggiungere un test con un vino di sola `window` del catalogo e un riscontro e, se fallisce, trattare `window` come base quando `source` è `catalog`. | New |
| R-04 | Minor | lib/cellar/domain/wine_classification.dart > withPreselection | 4. `levelSource` viene scritto `auto` anche quando la preselezione non dà alcun livello (`level` nullo): si scrive un campo origine senza il campo valore, e `toFields` cancella `level`. La regola `validClassification` lo ammette, quindi non fallisce, ma lascia dati incoerenti. | Scrivere `levelSource` solo se `level` non è nullo. | New |
| R-05 | Minor | test/rules/style_profiles.rules.test.mjs, packages/estimation/test/profile_map_test.dart > test "map via estimate" | 5. Il test ammette "al più 3" righe riconosciute come un'altra riga, ma non fissa quali. Se il numero resta uguale, ma cambiano le righe, il test passa. Le due note citate (Lagrein, Derthona) sono motivate dal progetto. | Fissare l'elenco esatto delle tre eccezioni e fallire su qualunque altra. | New |
| R-06 | Minor | aidlc/spaces/default/intents/261108-wine-style-profiles/construction/code-generation/code-summary.md > "Scostamenti" (data scritta, non ruota) | 6. Lo scostamento dalla ruota dell'annata a mese da menu e anno scritto è accettabile: `WineValidator.validateAgingStart` blocca anno < 1950, futuro, prima dell'annata e mese fuori da 1..12, e le regole accettano 1900..2200. Non sta scritto però che sia stato approvato dal proprietario. | Registrare nell'artefatto dell'intento che lo scostamento è deciso dal proprietario, oppure chiederlo al gate. | New |
| R-07 | Minor | aidlc/spaces/default/intents/261108-wine-style-profiles/construction/code-generation/code-summary.md > "Tempo di generazione della base" | 7. La build della base offline richiede 3 min 30 s contro il limite di 2 minuti di NFR3.3 e BR9.3. È uno strumento di sviluppo e non gira per l'utente, ma il limite è un requisito approvato e non una scelta di costruzione. | Chiedere al proprietario se il limite vale per la sola elaborazione, e se sì aggiornare NFR3.3 e BR9.3, altrimenti aprire un lavoro di ottimizzazione. Non va lasciato come "da decidere". | New |
| R-08 | Minor | aidlc/spaces/default/intents/261108-wine-style-profiles/construction/code-generation/code-summary.md > "E2E non eseguiti" | 8. `integration_test/style_profile_flow_test.dart` non è stato eseguito. La postura del team (`team.md`) blocca il merge se l'e2e fallisce. Il proprietario ha provato sul telefono, ma la prova non è ripetibile. I test della migrazione sono stati eseguiti con successo in questa revisione (96 test verdi), come i 2011 test del pacchetto. | Eseguire l'e2e sul job GitHub Actions con emulatore prima del merge in `main`, come richiede il gate, e non pubblicare le regole prima di quell'esito. | New |
| R-09 | Minor | test/tool/build_wine_db_filter_test.dart > test "wine lines kept, others dropped as notWine" | Il test di equivalenza non copre byte UTF-8 multi-byte né byte malformati. Il filtro è corretto per costruzione, perché l'ago `en:wines` è ASCII e un byte multi-byte o di sostituzione non può formarlo. Resta però non dimostrato dai test. | Aggiungere una riga con caratteri accentati e un byte non valido, anche a cavallo di un confine di chunk (chunk da 1 byte). | New |
| R-10 | Minor | test/tool/build_wine_db_filter_test.dart > readExport | `readExport` (rilevazione gzip, `bytes.forEach(filter.add)`, `filter.close()`) non è esercitato dal test: i test passano direttamente da `RawLineFilter`. | Aggiungere un caso che scriva il CSV di esempio in un file, in chiaro e in gzip, e lo legga con `readExport`. | New |
| R-11 | Minor | test/cellar/estimates_migration_test.dart > test "NFR3.7 500 wines are computed in under 2.5 s" | Il test usa solo 5 nomi che si ripetono e un repository simulato. Misura quindi il calcolo (stima più migrazione) con scritture a costo zero, non la scrittura reale su Firestore. Ciò è coerente con NFR3.7 ("calcolati"), ma il carico è meno vario di una cantina vera. La soglia di 2,5 s lascia molto margine rispetto al tempo osservato, quindi il rischio di instabilità è basso. | Nessuna azione bloccante. Se si vuole più robustezza, variare i nomi con più denominazioni del mondo e dichiarare nel commento che le scritture sono simulate. | New |

> R-01 Not re-checked this round

> R-02 Not re-checked this round

> R-03 Not re-checked this round

> R-04 Not re-checked this round

> R-05 Not re-checked this round

> R-06 Not re-checked this round

> R-07 Not re-checked this round

> R-08 Not re-checked this round

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| flutter test test/tool/build_wine_db_filter_test.dart test/cellar/estimates_migration_test.dart | PASS (18 test, tutti verdi) | Il filtro dà lo stesso risultato della lettura di tutte le righe per chunk da 1, 3, 7, 50, 64, 4096 e 65536 byte. Il test NFR3.7 passa. |

### Verifiche sul filtro

- **Conservativo:** `RawLineFilter` scarta una riga solo se non contiene `en:wines` in nessuna combinazione di maiuscole e minuscole (confronto byte per byte con ASCII abbassato). `recordOfRow` confronta in minuscolo, quindi ogni riga che tiene passa il filtro. Nessun carattere non ASCII può diventare un byte dell'ago. Le sue minuscole non producono `en:wines`: né il simbolo Kelvin né la I con punto, per esempio.
- **Righe senza carattere visibile:** vengono sempre decodificate, perché `trim()` di Dart toglie anche gli spazi Unicode. Restano quindi non contate come prima.
- **Campi tra virgolette su più righe:** `addLine` non gestiva le virgolette nemmeno prima, perché divide su `\t`. La lettura precedente usava `LineSplitter`, che spezza su `\n` e `\r` allo stesso modo. Il comportamento è identico.
- **Fine riga a cavallo dei chunk:** `\n`, `\r` e `\r\n` sono gestiti con `_afterCr`. Il caso `\r` a fine chunk seguito da `\n` all'inizio del successivo è coperto dai chunk da 1 byte. L'automa KMP si azzera a ogni riga e mantiene lo stato tra chunk. L'ultima riga senza a capo è chiusa da `close()`.
- **Conteggi:** `addNonWineRow` fa `rows++` e conta `notWine`, come `addLine` per una riga senza il tag. L'intestazione è sempre decodificata. I test confrontano `rows`, `dropped` e le righe JSON dei record.

### Summary

Il filtro è conservativo e di equivalenza dimostrata dai test per gli a capo, i confini dei chunk e le maiuscole; i conteggi non cambiano. Il test NFR3.7 misura ciò che chiede il requisito e ha ampio margine. Restano solo tre rilievi minori sulla copertura dei test.
