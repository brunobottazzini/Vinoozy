# Controllo di salute — Freemium e Plus

**Stato: pubblicazione delle regole avviata, non ancora completata.** Il codice è presente su `main` nel commit `105c0ba432ad39d1fc05814c3150ab6a3ac80504`. Il workflow delle regole è [42829140441](https://github.com/brunobottazzini/Vinoozy/actions/runs/42829140441); mancano ancora le variabili WIF e l'approvazione del proprietario in `firebase-prod`. Nessuna promozione Play è stata avviata. Dettagli nel [registro della pubblicazione](deployment-log.md).

## Da controllare dopo il merge e la pubblicazione delle regole

| Segnale | Dove | Soglia | Esito |
|---|---|---|---|
| CI di main | [Run 42828170872](https://github.com/brunobottazzini/Vinoozy/actions/runs/42828170872), tutti i job obbligatori | Tutti verdi | Non soddisfatto: `secrets` e `analyze` falliti; `unit` ed `e2e` ancora in corso al controllo |
| Build sul test interno | `release.yml` | Riuscita, AAB caricato | ______ |
| Pubblicazione delle regole | [firebase-deploy.yml, run 42829140441](https://github.com/brunobottazzini/Vinoozy/actions/runs/42829140441) | Riuscita | `verify-ref` e `rules` verdi; `deploy` in attesa della revisione di `firebase-prod`, regole non ancora pubblicate |
| Errori `permission-denied` | Crashlytics, le prime 24 h dopo le regole | Nessun aumento rispetto alla settimana precedente | ______ |
| Crash | Crashlytics, test interno | Nessun crash nuovo legato a Plus, annunci o misuratore | ______ |
| Quote Firestore | Firebase Console → Utilizzo | Letture e scritture giornaliere sotto il 70% delle quote (studio §8.7) | ______ |

Se un segnale non va bene, segui `../deployment-pipeline/rollback-runbook.md`.
