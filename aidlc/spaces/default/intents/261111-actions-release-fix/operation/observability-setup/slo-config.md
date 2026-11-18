# Obiettivi di servizio della catena di consegna

Ambito: la consegna automatica corretta in questo lavoro. Gli obiettivi
dell'app in produzione restano quelli di `monitoring-design.md` dei lavori
precedenti e di `docs/firebase-setup.md` §7.

| SLI | Definizione | SLO | Finestra | Fonte |
|---|---|---|---|---|
| Successo della CI su `main` | run `ci` concluse `success` / run concluse (escluse quelle annullate) | ≥ 90% | ultime 20 run su `main` | `gh run list --workflow ci --branch main` |
| Successo della release dopo CI verde | run `release` del job `internal` concluse `success` / run `release` non saltate | ≥ 95% | ultime 10 release | `gh run list --workflow release` |
| Stabilità dell'E2E | run del job `e2e` verdi al primo tentativo / run del job `e2e` | ≥ 95% | ultime 20 run | log del job `e2e` |
| Tempo da push a build sul canale interno | dal push alla fine del job `internal` | ≤ 90 minuti nel 95% dei casi | ultime 10 release | durata delle run `ci` + `release` |

## Budget d'errore e cosa fare

- **CI su `main` sotto il 90%** o **E2E sotto il 95%**: prima di nuove
  funzioni si stabilizzano i test che falliscono a intermittenza. Ogni
  fallimento di `waitFor` riporta ora l'elenco "On screen", da cui partire.
- **Release sotto il 95%**: si legge lo step fallito. I messaggi di
  `tool/check_release_inputs.sh` e `tool/play_api.sh` dicono cosa sistemare
  (vedi `operation/deployment-pipeline/rollback-runbook.md` §5).

## Valori di partenza (12/11/2026)

- CI: storico misto (Flutter non fissato fino a `4cc0024`, E2E di
  cancellazione intermittente fino a `6f76475`); da misurare da `6f76475` in poi.
- Release: 1 successo su 1 dopo la configurazione dei segreti (tentativo 2
  di `43207310918`).
