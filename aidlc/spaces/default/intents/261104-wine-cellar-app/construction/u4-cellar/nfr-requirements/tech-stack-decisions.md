# Tech Stack Decisions — u4-cellar

Fonti: `functional-spec.md`, `rules.md` e `frontend-components.md` di U4; `contract-summary.md`; `team.md` (Testing Posture, Code Style); codice esistente (`lib/cellar/`, `lib/catalog/`, `lib/sharing/`, `packages/estimation`); riepilogo confermato in `nfr-requirements-questions.md`.

| Area | Scelta | Motivo | Alternative scartate |
|------|--------|--------|----------------------|
| Posizione | `lib/cellar/` esteso: `domain/` (validazione, `matchKey`, `WindowAdjuster`, correzione delle quantità, filtri), `data/` (`WineRepository` esteso, `DrinkingRecordRepository` nuovo), `cellar_providers.dart`, `ui/` (Cantina, aggiunta, dettaglio, modifica, Storico, componenti) | Continuità con U1; logica testabile senza Flutter | Modulo nuovo separato (duplicherebbe il modello `Wine`) |
| Stima | Pacchetto `estimation` (U2) per finestra, stato, abbinamenti, `needsRefinement`; catalogo `catalogProvider` (U3) con `ref.watch` | Contratti C1 e C2 | — |
| Riscontro | `WindowAdjuster` puro in `lib/cellar/domain/`, non nel pacchetto `estimation` | È una regola dell'app sopra la stima di base; il pacchetto resta la sola stima | Estendere C2 (cambio di contratto non necessario) |
| Stato | Riverpod, già usato | Coerenza | — |
| Dati | Firestore con persistenza offline di U1; `FieldValue.increment` per le quantità | ADR-004 | Transazioni (non funzionano offline) |
| Dipendenze | **Nessuna nuova** | Bastano Flutter, Riverpod, Firestore, `estimation` e il catalogo | Librerie di stelle o di snackbar (inutili) |
| Test delle regole | `test/rules/u4.rules.test.mjs`, aggiunto a `npm run test:rules`; `requiresRules: "cellar"` in `compat/app-writes.json` | Strumenti già in uso | — |
| Benchmark | `benchmark/cellar_benchmark.dart` con `dart run` nel job `unit` (due misure: filtri e finestra effettiva) | Stesso modello dei benchmark esistenti | — |
| Test end-to-end | `integration_test/cellar_test.dart` (aggiunta, bevuta, annulla, Storico, doppione di un vino finito) e `integration_test/concurrent_drink_test.dart` (due bevute offline con `ownerRestClient()` di U7 e l'app) | Regole del team | — |

## Requisiti di qualità

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR7.1 | Copertura ≥ 80% delle righe di `lib/cellar/` e del progetto, senza esclusioni. | `tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/` nel job `unit`. |
| NFR7.2 | Ogni regola BR1.1–BR1.20 ha almeno un test con l'ID nel nome. | Script nuovo `tool/check_rule_ids.sh <prefisso> <max> <percorsi…>`, nel job `analyze` con `BR1. 20 test/cellar test/rules/u4.rules.test.mjs`:<br>• cerca ogni ID da BR1.1 a BR1.20 come parola intera (regex `\bBR1\.N\b`, così `BR1.1` non è trovato da `BR1.10`);<br>• considera solo il primo argomento stringa di `test(`, `testWidgets(` e `group(` in Dart e di `test(`/`it(` in JavaScript;<br>• fallisce elencando gli ID mancanti.<br>Il suo test `tool/check_rule_ids_test.sh` usa due cartelle di prova: una completa e una senza `BR1.1`, ma con `BR1.10`, che deve fallire. |
| NFR7.3 | Test dei widget delle schermate nelle tre lingue, con il testo al 200%. | `flutter test`. |
| NFR7.4 | Test end-to-end di U4 nel job `e2e`; il merge è bloccato se falliscono. | Job `e2e`. |
| NFR7.5 | I test di U1, U3, U5 e U7 restano verdi. In particolare il cambio di `watchWines` in `watchCellarWines` aggiorna i test del repository di U1; i finti dei flussi di U5 e U7 non cambiano. | Suite completa. |
