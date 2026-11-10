# SLO e SLI — Freemium e Plus

Vinoozy è un'app Android offline-first. I segnali che contano per l'utente sono quattro: l'app non va in crash, salva i dati, Plus si attiva quando deve, e gli annunci non disturbano. I valori sono di partenza e vanno rivisti dopo 4 settimane di dati reali.

| SLI | Misura | SLO | Finestra | Fonte |
|---|---|---|---|---|
| Utenti senza crash | Utenti senza crash / utenti attivi | ≥ 99,5% | 28 giorni mobili | Crashlytics, Play Console → Android vitals |
| Verifica degli acquisti | Chiamate `verifyPurchase` riuscite (stato pagato o `pending` legittimo) / chiamate totali, esclusi `INVALID_TOKEN` e `WRONG_*` | ≥ 99% | 30 giorni mobili | Log di Cloud Functions (`verifyPurchase`) |
| Tempo di attivazione di Plus | Acquisti verificati entro 60 s dall'acquisto / acquisti verificati | ≥ 95% | 30 giorni mobili | Log `verifyPurchase` (orari di acquisto e di concessione) |
| Notifiche Play elaborate | Esecuzioni `onPlayRtdn` senza errore / esecuzioni | ≥ 99% | 30 giorni mobili | Log di Cloud Functions |
| Caricamento dei contatori d'uso | `reportUsage` con `accepted: true` o rifiuto atteso (`STALE_SEQUENCE`, `TOO_FREQUENT`) / chiamate | ≥ 99% | 30 giorni mobili | Log di Cloud Functions |
| Spesa | Costo mensile del progetto | ≤ 1 € (obiettivo 0 €) | Mese di fatturazione | Cloud Billing, budget `vinoozy-budget` |

## Error budget

Con il 99,5% senza crash, l'error budget è lo 0,5% di utenti con almeno un crash in 28 giorni. Come si usa:

- **Budget sotto il 50%:** niente nuove promozioni in produzione finché i crash non sono capiti.
- **Budget esaurito:** si ferma il rilascio graduale (`promote.yml` con `halt`) e si correggono i crash.

Il budget di spesa non ha margine: oltre 1 € la fatturazione si scollega da sola (`onBudgetAlert`).

## Quando si misura

- Prima che le funzioni siano pubblicate, contano solo «utenti senza crash» e «spesa».
- Gli SLI delle funzioni partono dalla prima pubblicazione su Blaze.
