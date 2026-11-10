# Controllo di salute — Freemium e Plus

**Stato: in attesa del merge.** In produzione non è cambiato nulla: niente è stato unito su `main` né pubblicato su Firebase o Play. Il ramo `freemium-plus` è su GitHub.

## Da controllare dopo il merge e la pubblicazione delle regole

| Segnale | Dove | Soglia | Esito |
|---|---|---|---|
| CI della PR | GitHub Actions, job `unit`, `rules`, `e2e` | Tutti verdi | ______ |
| Build sul test interno | `release.yml` | Riuscita, AAB caricato | ______ |
| Pubblicazione delle regole | `firebase-deploy.yml` | Riuscita | ______ |
| Errori `permission-denied` | Crashlytics, le prime 24 h dopo le regole | Nessun aumento rispetto alla settimana precedente | ______ |
| Crash | Crashlytics, test interno | Nessun crash nuovo legato a Plus, annunci o misuratore | ______ |
| Quote Firestore | Firebase Console → Utilizzo | Letture e scritture giornaliere sotto il 70% delle quote (studio §8.7) | ______ |

Se un segnale non va bene, segui `../deployment-pipeline/rollback-runbook.md`.
