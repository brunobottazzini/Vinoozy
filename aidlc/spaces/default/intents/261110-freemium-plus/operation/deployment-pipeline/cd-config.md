# Configurazione CD — Freemium e Plus

La pipeline esistente resta quella decisa in team.md. Questo lavoro aggiunge le Cloud Functions e aggiorna i controlli di compatibilità delle regole.

## Workflow

| Workflow | Quando | Cosa fa | Approvazione |
|---|---|---|---|
| `ci.yml` | A ogni push e PR | Formattazione, analisi, test, copertura 80%, regole, **funzioni (`test:functions`)**, **script (`test:admin`)**, E2E (compreso `tool/e2e_freemium.sh`), controllo della release | Gate obbligatorio prima del merge |
| `release.yml` | Dopo ogni merge in `main` con CI verde | AAB firmato sul **test interno** di Play. Passa il segreto `ADMOB_APP_ID`; senza segreto usa l'ID di test | Nessuna, perché il test interno è lo staging |
| `firebase-deploy.yml` | Manuale (`workflow_dispatch`), ref `v*` o commit di `main` | Test delle regole e degli indici, poi `firebase deploy --only firestore:rules,firestore:indexes` | Ambiente `firebase-prod` |
| **`functions-deploy.yml`** (nuovo) | Manuale (`workflow_dispatch`), ref `v*` o commit di `main` | `npm run test:functions`, poi `firebase deploy --only functions --force` (regione `europe-west8`, pulizia delle immagini) | Ambiente `firebase-prod` |
| `promote.yml` | Manuale | Produzione con rilascio graduale, dopo il controllo «le regole della build sono quelle pubblicate» | Ambiente `play-production` |

Il deploy delle funzioni sta in un workflow separato [Q1]. Il motivo è che `promote.yml` legge l'ultima esecuzione riuscita di `firebase-deploy.yml` come quella delle regole in produzione: una pubblicazione delle sole funzioni in quel workflow falserebbe il controllo.

## Modifiche di questa fase

- `.github/workflows/functions-deploy.yml`: nuovo.
- `.github/workflows/promote.yml`: `RULES_FEATURES` comprende ora `freemium`. Una build con il contatore delle schede attive non va in produzione finché le regole nuove non sono pubblicate.
- `test/rules/compat/app-writes.json`: aggiunta la versione `freemium-plus`, con creazione di un vino più contatore e ultima bottiglia bevuta più contatore, entrambe con `requiresRules: freemium`. `npm run test:rules` dà 288 test: 286 passati e 2 saltati, come prima.
- `docs/blaze-switch.md`: pubblicazioni successive con `functions-deploy.yml` e ruoli dell'account di servizio del deploy.

## Prerequisiti manuali del proprietario

- Passaggio a Blaze con le protezioni (`docs/blaze-switch.md`).
- Prima pubblicazione delle funzioni dal Mac, che attiva le API.
- Ruoli dell'account di servizio del deploy, elencati in `docs/blaze-switch.md`.
- Segreto `ADMOB_APP_ID` in GitHub, facoltativo finché gli annunci sono spenti.
- Play Console e scheda dello store (`docs/plus-setup.md`, `docs/release-checklist.md` §2).
