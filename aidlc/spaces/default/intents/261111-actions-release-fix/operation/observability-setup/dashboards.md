# Viste di controllo

Nessuna dashboard nuova da costruire: le viste esistono già nelle piattaforme
usate. Questa è la mappa di dove guardare.

| Domanda | Dove | Cosa guardare |
|---|---|---|
| L'ultimo push è sano? | GitHub → Actions → `ci`, filtro ramo `main` | 7 job verdi; per l'E2E, i test ❌ e la riga "On screen" |
| L'ultima build è arrivata ai tester? | GitHub → Actions → `release` | job `internal` verde; versione nello step `Versions` |
| Quale codice c'è in una build? | GitHub → Tags `build-N` (e `v<nome>+N` per la produzione) | commit del tag |
| Cosa hanno i tester? | Play Console → Test → Test interno | versione e stato della release |
| Cosa hanno gli utenti? | Play Console → Produzione | versione, percentuale di rilascio, stato `halted` |
| L'app si comporta bene? | Firebase → Crashlytics | utenti senza crash per versione, nuovi problemi |
| Firestore è nei limiti? | Firebase → Utilizzo; Cloud Monitoring | letture/scritture rispetto alla quota gratuita |

Comandi utili dal Mac (solo stato, nessun valore segreto):

```sh
gh run list --repo brunobottazzini/Vinoozy --workflow ci --branch main --limit 10
gh run list --repo brunobottazzini/Vinoozy --workflow release --limit 5
git fetch --tags && git tag -l 'build-*' --sort=-v:refname | head -5
```
