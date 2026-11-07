# CI/CD Pipeline — u8-account

Fonti: `security-design.md` (§1, §7), `performance-design.md` (§4) e `logical-components.md` di U8; `functional-spec.md` di U8 e `components.md`; `.github/workflows/ci.yml`, `release.yml`, `promote.yml`, `firebase-deploy.yml`; `package.json`; riepilogo confermato in `infrastructure-design-questions.md`.

U8 non aggiunge job a `ci.yml`. Aggiunge passi, un workflow manuale (`pages.yml`) e cambia `RULES_FEATURES` in `promote.yml`. Tutti i controlli restano obbligatori prima del merge (team.md).

## 1. Modifiche a `ci.yml`

| Job | Passo | Cosa verifica | Requisito |
|---|---|---|---|
| `analyze` | `tool/check_rule_ids.sh BR1. 13 test/account test/rules/u8.rules.test.mjs` | Ogni regola citata in un test | NFR7.2 |
| `analyze` | Nuovi `tool/check_web_pins.sh` e il suo test | Bundle riproducibile, script solo locali, CSP con le sole origini ammesse (vedi "Seconda correzione" nella specifica) | NFR4.7 |
| `unit` | `tool/check_coverage.sh 80 coverage/lcov.info lib/account/` | Copertura di U8 | NFR7.1 |
| `rules` | `npm run test:rules` con `u8.rules.test.mjs` aggiunto allo script; versione `u8-account` in `app-writes.json` | Regole di `users` e `cellars`, sequenza completa, compatibilità | NFR4.1–NFR4.5 |
| `rules` | Nuovo `npm run test:web` (emulatori di Firestore e Auth) | Logica della pagina: sequenza completa, ripresa, riautenticazione con altro account rifiutata, `deleteUser` | NFR7.6 |
| `e2e` | Nessun passo nuovo: raccoglie `account_test.dart` | Uscita con modifiche in coda; cancellazione completa e cloud vuoto | NFR7.4, NFR8.1 |

Il job `rules` richiede ora anche l'emulatore di Auth (già incluso nel pacchetto `firebase-tools`). Tempo stimato in più: 1–2 minuti, da misurare.

## 2. Nuovo workflow `pages.yml`

- **Avvio:** manuale (`workflow_dispatch`), con un tag `v*` o un hash completo, come `firebase-deploy.yml`.
- **Controllo delle regole:** come `promote.yml`, legge l'ultima esecuzione riuscita di `firebase-deploy.yml` e confronta `firestore.rules` con quello del commit. Se sono diversi, si ferma con "Pubblica prima le regole con firebase-deploy.yml".
- **Controllo della libreria:** esegue `tool/check_web_pins.sh`.
- **Pubblicazione:** copia `docs/account-deletion/` nel ramo `gh-pages` con un commit firmato dal bot di GitHub Actions, usando `GITHUB_TOKEN` con `contents: write`, senza segreti nuovi.
- **Impostazione una volta, azione del proprietario:** GitHub Pages dal ramo `gh-pages` nelle impostazioni del repository.

## 3. Pubblicazione completa

1. Merge su `main`: `release.yml` pubblica l'app sul test interno.
2. `firebase-deploy.yml` con l'approvazione di `firebase-prod`.
3. Console Firebase, una volta: app web, dominio, App Check.
4. `pages.yml`.
5. Prova della checklist §1-septies.
6. `promote.yml` (`RULES_FEATURES: sharing cellar account`).

## 4. Segreti

Nessun segreto nuovo. La configurazione web di Firebase e la chiave del sito reCAPTCHA sono pubbliche per natura.

## 5. Rollback

- **App:** fermare il rilascio graduale e pubblicare una correzione.
- **Pagina:** `pages.yml` con `mode: rollback`.
- **Regole:** prima della promozione, `firebase-deploy.yml` con il tag precedente; dopo, correzione in avanti.
- **Controllo di CI rotto per un motivo esterno:** si corregge in un blocco nuovo, senza togliere controlli né abbassare soglie.

## 6. Correzioni dopo la revisione (2026-11-06)

- `analyze`: `tool/check_web_pins.sh` ricostruisce `app.bundle.js` con `esbuild` e lo confronta con quello nel repository; nessun import esterno (vedi `infrastructure-specification.md`, "Correzioni dopo la revisione").
- `rules`: `npm run test:web` con `c8 --check-coverage --lines 80` su `account-deletion.js`.
- `pages.yml`: `contents: write` e `actions: read`, ambiente `github-pages-publish` con approvazione, `mode: publish | rollback`; il rollback non passa dal controllo delle regole; prima pubblicazione e rollback senza versione precedente definiti in `infrastructure-specification.md`, "Seconda correzione".
- `rules`: `npm run test:web` include anche la prova del bundle in Chromium headless con Playwright (CSP e avvio).
- `analyze`: criterio esatto di `check_web_pins.sh` in `infrastructure-specification.md`, "Seconda correzione".
- Prerequisito del proprietario: repository pubblico dopo il controllo dei segreti nella cronologia.

