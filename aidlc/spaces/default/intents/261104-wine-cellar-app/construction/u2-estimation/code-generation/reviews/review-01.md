## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** 2026-11-05
**Iteration:** 1
**Verdict Dictated:** no

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Minor | tool/check_estimation_purity.sh > controllo 4 (stato globale mutabile) | Il controllo blocca solo dichiarazioni a colonna 0 che iniziano con `var ` o `late ` e i campi `static` non const/final. Una variabile globale con tipo esplicito (per esempio `int counter = 0;` o una lista modificabile dichiarata `final` a livello di file) non viene rilevata, anche se l'intestazione dello script e code-summary.md parlano di "stato globale". La garanzia di purezza (BR4.4) è quindi più debole di come è descritta. | Estendere il controllo ai campi di primo livello non `const`/`final`, oppure dichiarare nell'intestazione dello script e in code-summary.md che copre solo `var`, `late` e `static` modificabili. | New |
| R-02 | Minor | packages/estimation/lib/src/validation.dart > validateWineFacts, controllo del nome | BR4.5 dice "name vuoto dopo la pulizia". Il codice controlla solo `name.trim().isEmpty`. Un nome fatto di sola punteggiatura (per esempio `---`) passa la validazione e produce una stima generica, mentre `tokenize` lo riduce a zero parole (recognizer_test.dart lo conferma). Non c'è un test che fissi il comportamento voluto. | Decidere se "pulizia" significa solo trim, come in C3, e scriverlo nella regola. In alternativa rifiutare i nomi senza parole con `emptyName`. In ogni caso aggiungere un test. | New |
| R-03 | Minor | .github/workflows/release.yml > retention-days del bundle (30 -> 7) | La modifica compare nel diff dell'area di lavoro ma `release.yml` non è tra i file scritti di source-manifest.json e cicd-pipeline.md §4 dice che il rilascio resta quello di U1. Non è chiaro a quale unità appartenga la modifica. | Confermare che la modifica appartiene a U1. Se è di U2, aggiungerla al manifest e alla descrizione. Altrimenti lasciarla fuori dal commit di U2. | New |

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| `dart analyze` in packages/estimation | PASS, "No issues found!" | Pulito, anche con le regole `lints/recommended`. |
| `dart test` in packages/estimation | PASS, 308 test | Include AC4.2.1 (15 anni, 11 mesi mancanti: drinkSoon) e AC4.2.2 (1 anno, 4 mesi mancanti: ready), "Castiglione" non riconosciuto come Asti, le precedenze di BR1.2 e BR1.7 e gli errori di BR4.5. Nessun test sempre verde: le uniche asserzioni deboli sono `isNotNull` in api_test.dart:196, accanto ad altre asserzioni. |
| Copertura (`format_coverage` + `tool/check_coverage.sh 90`) | PASS, 100% (293/293 righe) | Sopra la soglia di 90% del pacchetto. Il file `coverage_helper_test.dart` impedisce che un file di `lib/` sparisca dal conteggio. |
| `dart format --set-exit-if-changed` | PASS, 0 file cambiati | Il job `estimation` del CI passerà il controllo di formato. |
| `tool/check_estimation_purity.sh` | PASS, 9 file in `lib/` | Vedi il primo finding sul controllo 4. Dipendenze vuote, import ammessi e parole vietate sono verificati correttamente. |
| `dart run benchmark/estimation_benchmark.dart` | PASS, exit 0 | recognize 1,6 ms (soglia 4 ms), stima+stato+abbinamenti 3,0 ms (soglia 10 ms), secondo blocco +0,0% (soglia +10%), stima/build indice 0,009 (soglia 0,1). Le soglie sono quelle di logical-components.md. Una misura fuori soglia viene ripetuta una volta e alla seconda violazione lo script esce con `exit(1)`. |
| Confronto automatico tabella denominazioni, codice contro rules.md | PASS, 47 righe su 47 | Tipologia, offset, offset delle qualifiche, abbinamenti e alias coincidono con rules.md. Controllo fatto con uno script di sola lettura. La tabella per tipologia (8 righe più la generica) è stata confrontata a mano e coincide. |

### Esito per area

- **Riconoscimento (BR1.1, BR1.2, BR1.7):** per parole intere, con normalizzazione e limite di 60 caratteri. Vince l'alias con più parole e a parità il primo nel nome. Le precedenze utente, C1 e nome sono implementate in `resolveWine`. Una tipologia in conflitto scarta la denominazione ricavata dal nome o da C1. Le qualifiche usano la più specifica che ha offset propri, altrimenti la riga base.
- **Anno base e fiducia (BR1.3, BR3.1):** senza annata si usa `referenceYear - 1` per fermi e dolci e `referenceYear` per spumanti e stima generica. Il catalogo senza annata è al massimo `low`. La denominazione con annata è `medium`, tutto il resto `low`.
- **statusOf (BR3.2, BR3.3):** aritmetica solo su interi. Preavviso = `(mesi * 25 + 50) ~/ 100` limitato tra 3 e 12. Mesi mancanti = `(endYear + 1 - anno) * 12 - (mese - 1)`. Dà 12 al 1 gennaio dell'ultimo anno e 4 al 1 settembre, come in rules.md. Le finestre non ordinate lanciano `invalidWindow`.
- **Errori (BR4.5, BR1.6):** i cinque codici di `EstimationErrorCode` coprono nome vuoto, annata e anno di riferimento fuori da 1900..2200, anno di riferimento mancante e finestra incoerente. Un profilo esterno incoerente viene ignorato senza errore. Tipologie e denominazioni sconosciute non sono errori.
- **CI:** il job `estimation` è indipendente dagli altri. Il job `unit` accoda l'lcov del pacchetto a quello dell'app e `check_coverage.sh` somma solo `LF` e `LH`, quindi l'unione è valida. L'`analysis_options.yaml` di root esclude `packages/**`, quindi `flutter analyze` della root non vede dipendenze mancanti. `coverage/` del pacchetto è nel `.gitignore`. Nessun job esistente risulta rotto. Resta da fare a mano, fuori dal codice, l'aggiunta del sesto controllo `estimation` ai controlli obbligatori di `main`.

### Summary

L'implementazione corrisponde alle regole BR1.1-BR4.5 e a rules.md: 47 denominazioni su 47 coincidono e AC4.2.1 e AC4.2.2 sono coperti da test. Tutti i controlli rieseguiti sono verdi (analisi, 308 test, copertura 100%, formato, purezza, benchmark). Restano solo tre rilievi minori, non bloccanti: lo script di purezza è più debole di come è descritto, il caso del nome fatto di sola punteggiatura non è definito, e la modifica a `release.yml` non ha un'unità di appartenenza chiara.
