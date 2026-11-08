# Strategia di rilascio — pending-banner-fix

## Fonti

- `team.md` → Deployment; `cd-config.md` di questa fase; `construction/build-and-test/build-and-test-summary.md`.

## Strategia

- **Staging:** canale di test interno di Google Play, automatico a ogni merge in `main`.
- **Produzione:** rilascio graduale con `promote.yml`, prima al 20% e poi al 100%, sempre con la tua approvazione.
- **Flag di funzionalità:** nessuno. La correzione cambia solo quando si spegne la fascia "in attesa", e non serve accenderla o spegnerla a distanza.
- **Versione:** dentro `v0.1.0` (Q1 = A).

## Matrice di promozione

| Ambiente | Ingresso | Verifica per passare oltre |
|---|---|---|
| Locale / CI | push, pull request | 7 controlli di `ci.yml` verdi |
| Test interno (staging) | merge in `main` | **smoke test** di `docs/release-checklist.md`, più questa prova specifica: in modalità aereo bevi l'ultima bottiglia di un vino → la fascia "Senza rete" resta visibile → riattivi la rete → la fascia sparisce dopo la sincronizzazione |
| Produzione 20% | `promote.yml`, tua approvazione | nessun aumento di errori `cellar_*` in Crashlytics per 24 ore |
| Produzione 100% | `promote.yml`, tua approvazione | — |

## Criteri per fermare il rilascio

- La fascia "in attesa" resta accesa dopo la sincronizzazione: è il rischio R-01, per esempio dopo un cambio di account.
- La fascia non compare dopo una bevuta offline.
- Aumentano gli errori `cellar_drink_failed` e `cellar_undo_failed` in Crashlytics.

In tutti questi casi si ferma il rilascio graduale e si applica `rollback-runbook.md`.
