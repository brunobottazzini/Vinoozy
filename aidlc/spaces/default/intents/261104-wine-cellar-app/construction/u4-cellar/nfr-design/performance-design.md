# Performance Design — u4-cellar

Fonti: `performance-requirements.md` (NFR1.1–NFR1.3, NFR2.1–NFR2.4, NFR5.1–NFR5.5), `tech-stack-decisions.md`, `functional-spec.md` di U4, `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`.

Per un'unità di interfaccia non esistono `scalability-requirements.md`, `reliability-requirements.md` e `observability-requirements.md` separati:
- la scala è quella dei requisiti: 500 vini presenti, 1.000 finiti, 2.000 bevute;
- l'affidabilità è in `security-design.md` §4;
- l'osservabilità sta nel design dell'infrastruttura.

## 1. Inserimento (NFR1.1–NFR1.3)

- `AddWineScreen` apre il campo nome con `autofocus` e la tastiera già aperta.
- **Suggerimenti:** `wineSuggestionsProvider` aspetta 250 ms dall'ultima battuta. Chiama `suggestWines` di U3, che restituisce subito i suggerimenti interni e quelli dei vini caricati (`cellarWines`), e aggiunge quelli esterni quando arrivano.
- **Salvataggio:**
  - controllo dei doppioni con `findByMatchKey`: una query con `Source.serverAndCache` e un tempo massimo di 1 s, poi solo la cache;
  - scrittura locale e ritorno immediato all'elenco;
  - la stima interna si calcola **prima** della scrittura, in qualche millisecondo;
  - il catalogo viene chiesto dopo, dalla coda di `EstimateRefresher`.
- Un test dei widget conta i passi minimi: tocco su "Aggiungi", proposta, "Salva".

## 2. Elenco, ricerca e filtri (NFR2.1, NFR2.3)

- `winesStreamProvider` fornisce l'elenco già ordinato. `CellarFilter` lavora in memoria sulla lista: nessuna query nuova per ricerca e filtri.
- `ListView.builder` con elementi di altezza fissa (`itemExtent`). Lo stato del giorno è precalcolato una volta per lista con `statusOf`, non a ogni riga ricostruita.
- **Benchmark `benchmark/cellar_benchmark.dart`**, nel job `unit`:
  - misura "filtri": ricerca più due filtri su 500 vini, soglia 20 ms;
  - misura "finestra effettiva": `WindowAdjuster.effective` su 500 vini, soglia 5 ms;
  - per entrambe: mediana di 10 giri dopo 3 di riscaldamento, una ripetizione, `exit(1)`.

## 3. Dettaglio e Storico (NFR2.2, NFR2.3)

- **Dettaglio:**
  - per un vino presente usa il documento già nell'elenco, senza leggere;
  - per un vino finito, `wineProvider` legge un solo documento;
  - le ultime bevute del dettaglio sono le 3 più recenti, prese da `recordsOfWine` della cache.
- **Storico:**
  - `historyPagerProvider` carica 30 bevute per pagina, con un cursore su `drankOn` e `createdAt`;
  - la pagina successiva si carica quando mancano 5 righe alla fine;
  - `ListView.builder`.

## 4. Costo (NFR5.1–NFR5.5)

| Operazione | Letture |
|---|---|
| Elenco | Ascolto con `quantity > 0`: solo i vini presenti |
| Storico | 30 bevute per pagina |
| Doppione | 1 query, di solito 0 o 1 documento |
| Backfill | Una volta per cantina, poi mai più |
| Miglioramento delle stime | Al più 20 vini per ritorno della rete, uno per volta, nei limiti di U3 |
| Eliminazione | 1 query sulle bevute del vino |

## 5. Qualità e CI (NFR7.1–NFR7.5)

| Requisito | Collegamento |
|---|---|
| NFR7.1 copertura | Job `unit`: nuovo passo `tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/`, come per il catalogo, il Cruscotto e la condivisione. |
| NFR7.2 ID delle regole nei test | Job `analyze`: `tool/check_rule_ids.sh BR1. 20 test/cellar test/rules/u4.rules.test.mjs` e il suo test `tool/check_rule_ids_test.sh`, con le cartelle di prova `tool/fixtures/rule_ids/ok/` e `missing_br1_1/` (contiene `BR1.10` ma non `BR1.1`). |
| NFR7.3 schermate nelle tre lingue | `flutter test` nel job `unit`. |
| NFR7.4 end-to-end | Job `e2e`: `flutter test integration_test` raccoglie da solo `cellar_test.dart` e `concurrent_drink_test.dart`; nessun passo nuovo. `integration_test_perf/cellar_perf_test.dart` resta fuori dalla CI. |
| NFR7.5 non regressione | Suite completa; i test del repository di U1 cambiano per `watchCellarWines`. |
| Benchmark | Job `unit`: `dart run benchmark/cellar_benchmark.dart`, accanto agli altri benchmark. Il file importa solo moduli senza Flutter: `lib/cellar/domain/` (compresi `wine.dart` e `quantity.dart`) e `package:estimation`, come fa il benchmark del Cruscotto. |

## 6. Misure

| Misura | Dove | Soglia |
|---|---|---|
| Inserimento | Telefono, 10 prove, checklist §1-quinquies | mediana < 30 s |
| Salvataggio fino all'elenco | Telefono, checklist | ≤ 300 ms |
| Filtri su 500 vini | `cellar_benchmark.dart` in CI | ≤ 20 ms su `ubuntu-latest` |
| Finestra effettiva su 500 vini | `cellar_benchmark.dart` in CI | ≤ 5 ms su `ubuntu-latest` |
| Dettaglio | Test dei widget e telefono | ≤ 500 ms |
| Scorrimento | `integration_test_perf/cellar_perf_test.dart` | 99° percentile sotto il periodo dello schermo |
