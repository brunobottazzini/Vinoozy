# Riepilogo di Build and Test — pending-banner-fix

## Stato complessivo

- **Build:** riuscita, con formattazione e analisi pulite.
- **Test di unità:** 1.533 superati. I 3 di regressione falliscono sul codice vecchio e passano con la correzione. Copertura 89,12% (progetto) e 95,27% (`lib/cellar/`).
- **End-to-end:** la fascia "in attesa" non è più fallita. `cellar_test.dart` però non arriva a 5 corse su 5 per un doppione nello Storico, un altro difetto di U4 che preesisteva. Suite completa: 19 su 20, con l'unico fallimento dovuto a un timeout di rete dell'ambiente. Il riavvio forzato è superato.
- **Esito: non superato** (NFR2 `Not Met`).

## Tipi di test

Strategia Minimal, scope bugfix: test di unità per requisito, la regressione mirata e l'end-to-end esistente come richiesto da NFR2. Nessun file di istruzioni per integrazione, prestazioni o sicurezza, perché la strategia Minimal non li prevede e la correzione non tocca confini nuovi.

## Copertura

| Ambito | Soglia | Misurata |
|---|---|---|
| Progetto (app + stima), senza esclusioni | 80% | 89,12% |
| `lib/cellar/` (u4-cellar NFR7.1) | 80% | 95,27% |

## Target Verification Matrix

| Target ID | Source | Expected | Actual | Evidence | Owning Stage | Verdict |
|---|---|---|---|---|---|---|
| NFR1-regression | requirements.md NFR1 | almeno un test di unità riproduce l'ordine inverso e fallisce con il codice di oggi | 3 test di regressione: 3/3 falliti su `HEAD`, 3/3 superati con la correzione | test-results.md §2 | build-and-test | Met |
| NFR1-suite | requirements.md NFR1 | tutta la suite resta verde | 1.533 superati, 0 falliti; stima verde | test-results.md §2 | build-and-test | Met |
| NFR1-coverage-project | team.md Copertura; requirements.md NFR1 | ≥ 80% delle righe, senza esclusioni | 89,12% | test-results.md §2 `tool/check_coverage.sh 80` | build-and-test | Met |
| NFR1-coverage-cellar | u4-cellar NFR7.1; requirements.md NFR1 | ≥ 80% su `lib/cellar/` | 95,27% | test-results.md §2 | build-and-test | Met |
| NFR2-cellar-5of5 | requirements.md NFR2 | `cellar_test.dart` superato in 5 corse consecutive su 5 | prima serie 3/5; seconda serie 6/9. Nessun fallimento alla riga 95 (fascia); fallimenti alla riga 135 (doppione nello Storico) | test-results.md §3 | build-and-test | Not Met |
| NFR2-full-suite | requirements.md NFR2 | suite `integration_test` completa + `tool/e2e_force_stop.sh` superata almeno una volta | 19/20 (1 timeout di rete in `clearEmulators`); riavvio forzato superato | test-results.md §3 | build-and-test | Not Met |
| NFR3-no-cost | requirements.md NFR3 | nessuna dipendenza, regola, indice o lettura in più | solo 2 file di `lib/` e i loro test cambiati | `git diff --stat`; code-summary.md | build-and-test | Met |
| NFR4-style | requirements.md NFR4 | format e analyze puliti, codice in inglese | uscita 0 / 0 | test-results.md §1 | build-and-test | Met |
| CI-before-merge | Testing Contract (scope bugfix, CI di team.md) | i test girano in CI prima del merge | — | — | ci-pipeline | N/A — the plan runs no CI Pipeline; `ci.yml` della prima versione esegue già questi test prima di ogni merge |

## Prontezza

| Aspetto | Stato |
|---|---|
| Build | pronta |
| Test | in parte: unità verdi; end-to-end bloccato dal doppione nello Storico |
| Rilascio | la correzione è pronta per il merge, ma il job `e2e` della CI fallirà circa 1 volta su 3 finché lo Storico non sarà corretto |

## Limiti noti

1. Doppione nello Storico (U4, BR1.16), causa non individuata: va fatto come lavoro separato.
2. R-01 accettato: fascia accesa dopo un cambio di account con bevute in coda; correzione proposta, non applicata.
3. Timeout di rete occasionale verso gli emulatori Firebase in locale.
