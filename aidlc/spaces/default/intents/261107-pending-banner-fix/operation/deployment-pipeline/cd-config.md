# Configurazione del rilascio — pending-banner-fix

## Fonti

- `.github/workflows/ci.yml`, `release.yml`, `promote.yml`: i workflow della prima versione, con i 7 controlli e il rilascio.
- `aidlc/spaces/default/intents/261104-wine-cellar-app/construction/ci-pipeline/ci-config.md` e `quality-gates.md`.
- `aidlc/spaces/default/codekb/Vinoozy/` e `construction/build-and-test/` di questo lavoro.

Questo lavoro (scope `bugfix`) non ha CI Pipeline né Infrastructure Design propri, per scelta del percorso. La correzione usa i workflow esistenti **senza cambiarli**: nessun file in `.github/` è modificato.

## Percorso

| Passo | Dove | Condizione | Chi |
|---|---|---|---|
| 1. Ramo breve dalla `main` con la correzione | git | — | proprietario |
| 2. Controlli `format`, `secrets`, `analyze`, `unit`, `estimation`, `rules`, `e2e` | `ci.yml`, su push e pull request | tutti verdi | automatico |
| 3. Squash merge in `main` | GitHub, ruleset di `main` | i 7 controlli verdi | proprietario |
| 4. AAB firmato sul canale di **test interno** | `release.yml` (`workflow_run` su `ci` riuscito in `main`) | segreti di firma, Play e Firebase presenti | automatico |
| 5. Smoke test sul telefono | `docs/release-checklist.md` | — | proprietario |
| 6. Produzione con rilascio graduale e tag `v0.1.0` | `promote.yml`, ambiente `play-production` | approvazione | proprietario |

**Versione (Q1 = A):** la correzione entra nella prima versione `v0.1.0`, senza un numero a parte.

## Note sul passo 2

Il job `e2e` fallirà circa 1 volta su 3 su `cellar_test.dart` per il doppione nello Storico, un difetto accettato in Build and Test e da correggere a parte. Le regole del team non permettono di aggirare un controllo rosso. Le strade sono due:
- correggere prima lo Storico;
- ripetere la corsa intera di `ci.yml`. Una nuova corsa non cambia né aggira il controllo, ma un risultato verde ottenuto così nasconde un difetto noto.

**Consiglio:** correggere prima lo Storico, poi fare il merge.

Regole, indici e pagina web non cambiano: `firebase-deploy.yml` e `pages.yml` non servono per questa correzione.
