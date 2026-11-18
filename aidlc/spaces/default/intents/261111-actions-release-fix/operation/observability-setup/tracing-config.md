# Tracciamento

Nessun tracciamento distribuito da configurare: l'app parla direttamente con
Firebase e le Cloud Functions non sono distribuite (nessun servizio AWS, niente
X-Ray). La tracciabilità utile qui è quella **della consegna**:

| Da | A | Collegamento |
|---|---|---|
| Build sul telefono (versionCode N) | commit | tag `build-N` (creato da `release.yml`) |
| Release in produzione | commit | tag `v<versionName>+N` (creato da `promote.yml`) |
| Commit | run della CI | `gh run list --commit <sha>` |
| Run di release | run della CI che l'ha avviata | `workflow_run`, stesso `head_sha` |
| Crash in Crashlytics | build | versione e versionCode del report |

I simboli per leggere gli stack trace (`crashlytics-symbols` in `release.yml`)
restano non configurati: il job viene saltato. Si attiva con la federazione
d'identità descritta in `docs/firebase-setup.md` §4.
