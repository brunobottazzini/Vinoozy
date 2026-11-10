# Controllo di salute — Freemium e Plus

**Stato: regole Firestore pubblicate con successo.** Il proprietario ha approvato il workflow [42829140441](https://github.com/brunobottazzini/Vinoozy/actions/runs/42829140441); autenticazione WIF e tutti i job riusciti, regole e indici distribuiti il 2026-11-10 alle 15:39 (Europe/Rome). Il codice è presente su `main` nel commit `906cdde337fe08efa6023583ebe9cd3479702331`; le sue regole e gli indici sono identici a quelli di `105c0ba432ad39d1fc05814c3150ab6a3ac80504`, riferimento pubblicato. La CI dell'app è fallita e la release interna è stata saltata. Nessuna promozione Play è stata avviata. Dettagli nel [registro della pubblicazione](deployment-log.md).

## Da controllare dopo il merge e la pubblicazione delle regole

| Segnale | Dove | Soglia | Esito |
|---|---|---|---|
| CI di main | [Run 42831459774](https://github.com/brunobottazzini/Vinoozy/actions/runs/42831459774) su `906cdde`, tutti i job obbligatori | Tutti verdi | Falliti `secrets`, `rules` (suite `test:functions`) ed `e2e`; gli altri quattro job riusciti |
| Build sul test interno | [release.yml, run 42835840627](https://github.com/brunobottazzini/Vinoozy/actions/runs/42835840627) | Riuscita, AAB caricato | Saltata dopo la CI fallita |
| Pubblicazione delle regole | [firebase-deploy.yml, run 42829140441](https://github.com/brunobottazzini/Vinoozy/actions/runs/42829140441) | Riuscita | OK: tutti i job verdi, regole e indici distribuiti alle 15:39 del 2026-11-10 (Europe/Rome) |
| Prontezza degli indici | Console Firestore, indici degli inviti e dello Storico (`docs/release-checklist.md` §3) | Stato «Abilitato» prima della promozione | Da verificare nella console; la riuscita del deploy non attesta la fine della costruzione |
| Errori `permission-denied` | Crashlytics, le prime 24 h dopo le regole | Nessun aumento rispetto alla settimana precedente | ______ |
| Crash | Crashlytics, test interno | Nessun crash nuovo legato a Plus, annunci o misuratore | ______ |
| Quote Firestore | Firebase Console → Utilizzo | Letture e scritture giornaliere sotto il 70% delle quote (studio §8.7) | ______ |

Se un segnale non va bene, segui `../deployment-pipeline/rollback-runbook.md`.
