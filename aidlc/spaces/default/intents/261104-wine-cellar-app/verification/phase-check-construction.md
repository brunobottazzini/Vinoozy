# Phase Check — Construction → Operation

**Verdetto: NON SUPERATO, con eccezioni accettate dal proprietario.**

Nel piano non c'è una fase Operation da eseguire (tutte le fasi di Operation sono saltate), quindi questo controllo non blocca nessuna transizione. Registra cosa resta aperto alla fine della prima versione.

Fonti:
- `construction/build-and-test/cross-unit-traceability.md`;
- `construction/build-and-test/build-and-test-summary.md`, `test-results.md`;
- `construction/*/code-generation/traceability.json` (8 unità, tutti presenti);
- `construction/ci-pipeline/quality-gates.md`.

## Unità costruite e testate

| Unità | Elementi in Code Generation | OK | N/A | Deferred | Test in Build and Test |
|---|---|---|---|---|---|
| u1-skeleton | 66 | 59 | 3 | 4 | unità e regole verdi; E2E: scenario 8 instabile, misura provvisoria del salvataggio al limite |
| u2-estimation | 33 | 32 | 1 | 0 | verdi, copertura 100% |
| u3-wine-catalog | 40 | 38 | 2 | 0 | verdi |
| u4-cellar | 79 | 79 | 0 | 0 | unità verdi; **E2E `cellar_test` fallisce 3 volte su 5 (NFR6.6 `Not Met`)** |
| u5-dashboard | 30 | 30 | 0 | 0 | verdi |
| u6-label-recognition | 43 | 42 | 1 | 0 | verdi, compreso `label_test` dopo la correzione del disegnatore EAN-13 |
| u7-sharing | 50 | 50 | 0 | 0 | verdi |
| u8-account | 42 | 42 | 0 | 0 | verdi, compresa la pagina web in Chromium |

I 4 `Deferred` di U1 non sono risultati non risolti: due sono parti consegnate da u4-cellar (AC2.1.1, AC2.1.4), due sono le misure sul telefono (NFR1.1, NFR2.1).

## Controllo FR/NFR/AC tra le unità

- FR: 44 su 44 coperti.
- AC: 56 su 56 costruiti.
- NFR: 6 su 8 gruppi coperti. **NFR1 e NFR2** sono scoperti solo per `u1-skeleton: NFR1.1` (salvataggio ≤ 300 ms) e `u1-skeleton: NFR2.1` (avvio ≤ 2 s), che si misurano sul telefono di riferimento con build release.

## Controlli della CI rispetto ai comandi di Build and Test

Tutti i comandi eseguiti in Build and Test sono controlli bloccanti di `ci.yml`, con le stesse soglie (`quality-gates.md`):
- format, analyze e controlli del repository;
- test e copertura (80% progetto e per unità, 90% stima);
- benchmark;
- nativo con JaCoCo 80%;
- build di rilascio;
- regole, pagina web, indici;
- end-to-end con riavvio forzato.

In più c'è il nuovo controllo dei segreti (gitleaks). Nessuna soglia è stata abbassata.

## Punti aperti (eccezioni accettate)

1. **u4-cellar NFR6.6 `Not Met`.** Il proprietario ha scelto "Accept failure" il 2026-11-07, senza riaprire Code Generation. La correzione è pianificata nel Loop-Back Log di `test-results.md` ed è il primo lavoro dopo la prima versione. Finché non è fatta, il job `e2e` fermerà spesso i merge.
2. **u1-skeleton scenario 8 E2E instabile.** Causa non trovata; da osservare nella CI.
3. **37 obiettivi `Unverified`:** misure sul telefono e impostazioni della console Firebase, di Google Play e di GitHub. Da chiudere con `docs/release-checklist.md` e `docs/firebase-setup.md` prima della produzione.
4. **CI mai eseguita su GitHub.** Nessun commit è stato ancora inviato. La prima corsa di `ci.yml`, compreso il nuovo job `secrets`, va controllata.

- [ ] Approvazione umana (al gate di CI Pipeline)
