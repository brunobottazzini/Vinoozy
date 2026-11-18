# Interrogazioni dei log

I log dei workflow sono su GitHub Actions; si leggono con `gh` senza
scaricare segreti (GitHub li maschera comunque).

| Domanda | Comando |
|---|---|
| Job e step falliti di una run | `gh run view <run> --repo brunobottazzini/Vinoozy --log-failed` |
| Test E2E falliti e cosa c'era a schermo | `gh run view <run> --repo brunobottazzini/Vinoozy --log \| grep -E '❌\|Timed out\|On screen'` |
| Esito della verifica dei segreti | `gh run view <run> --repo brunobottazzini/Vinoozy --log \| grep -E 'configuration is (complete\|incomplete)' -A10` |
| Versione calcolata da Play | `gh run view <run> --repo brunobottazzini/Vinoozy --log \| grep 'versionName'` |
| Errori di `play_api.sh` | `gh run view <run> --repo brunobottazzini/Vinoozy --log \| grep 'play_api:'` |
| Rifiuti di Google Play all'upload | `gh run view <run> --repo brunobottazzini/Vinoozy --log \| grep '##\[error\]'` |
| Versione di Flutter usata da un job | `gh run view <run> --repo brunobottazzini/Vinoozy --log \| grep -m1 'key: flutter-linux'` |

Conservazione: log e artefatti di GitHub Actions secondo il default del
repository (90 giorni per i log; 7 giorni per l'AAB e i simboli, impostato in
`release.yml`). Gli errori dell'app restano in Crashlytics.
