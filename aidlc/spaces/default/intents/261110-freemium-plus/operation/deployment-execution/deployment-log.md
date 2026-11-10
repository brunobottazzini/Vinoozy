# Registro della pubblicazione — Freemium e Plus

Data: 2026-11-10. Decisioni: Q1 = A (test interno), Q2 = B (due commit), Q3 = A (rebase and merge, eccezione allo squash di team.md solo per questa volta).

## Controlli prima della pubblicazione

| Controllo | Esito |
|---|---|
| Build and Test | Verde: unit e widget, regole, funzioni, script, end-to-end di freemium, controllo della release, copertura all'88,11% |
| Migrazioni di dati | Nessuna adesso. `migrate_capacity.mjs` serve solo prima di accendere il limite (deployment-strategy.md, passo 5) |
| Servizi esterni | Firebase su Spark, senza funzioni pubblicate: atteso, perché le funzioni arrivano dopo Blaze |
| Finestra | Non serve: il test interno non raggiunge gli utenti in produzione |

## Eseguito

| Passo | Dettaglio |
|---|---|
| Ramo | `freemium-plus`, creato da `main` (`ee114e3`) |
| Commit 1 | `1baf1a0`, «Publication preparation: store assets, external links, history and drink fixes». Contiene le modifiche precedenti del proprietario nei file che toccano solo quelle (60 file) |
| Commit 2 | `1248449`, «Freemium and Plus: entitlements, 15-wine limit, Play Billing, gifts, usage meter, ads module». Contiene Freemium e Plus più i file misti (`ci.yml`, `release.yml`, `promote.yml`, `.gitignore`, file di traduzione, pagine privacy e di cancellazione, `docs/firebase-setup.md`, `docs/release-checklist.md`, `package.json`, `profile_screen.dart`) |
| Escluso | `.swp`, file di scambio di Vim, lasciato non committato |
| Push | `origin/freemium-plus`. Pagina per aprire la PR: https://github.com/brunobottazzini/Vinoozy/pull/new/freemium-plus |

Il primo commit da solo non si compila (usa testi che arrivano col secondo). Per questo i due commit vanno uniti nella stessa PR.

## Piano iniziale, prima dell'aggiornamento di main

Su questo Mac non c'è la CLI `gh`, quindi PR e merge non sono eseguibili da qui.

1. **Aprire la PR** da `freemium-plus` verso `main` (link sopra).
2. **Attendere la CI verde.** Controlli obbligatori: `unit`, `rules` (ora con funzioni e script) ed `e2e` (ora anche con l'emulatore Functions e `tool/e2e_freemium.sh`).
3. **Unire con «Rebase and merge»**, non con «Squash and merge». È l'eccezione scelta in Q3. Se la protezione del ramo consente solo lo squash, abilita temporaneamente «Allow rebase merging» nelle impostazioni del repository.
4. **`release.yml`** partirà da solo dopo il merge e caricherà l'AAB sul **test interno**.
5. **Pubblicare le regole** con `firebase-deploy.yml`, usando il commit di merge o un tag `v*`, e approvare in `firebase-prod`. Va fatto prima di qualsiasi promozione: `promote.yml` la blocca finché le regole della build non sono quelle pubblicate (`RULES_FEATURES` ora comprende `freemium`).
6. **Smoke test** sul telefono con la build del test interno (smoke-test-results.md).
7. Produzione (`promote.yml`), Blaze, funzioni e Play Console: più avanti, secondo deployment-strategy.md.

## Verifica operativa del 2026-11-10

Questo aggiornamento supera lo stato del piano iniziale sopra.

| Passo | Stato verificato |
|---|---|
| Codice su main | `906cdde337fe08efa6023583ebe9cd3479702331`, con entrambi i commit sopra e le correzioni successive ai test web e ad App Check. Le regole e gli indici sono identici a quelli di `105c0ba432ad39d1fc05814c3150ab6a3ac80504`, riferimento del deploy avviato |
| CI su main | [Run 42831459774](https://github.com/brunobottazzini/Vinoozy/actions/runs/42831459774) sul commit `906cdde`: fallito in `secrets`, `rules` (suite `test:functions`) ed `e2e`; `format`, `analyze`, `unit` ed `estimation` riusciti. La validazione locale verde non equivale alla CI verde |
| Ambiente firebase-prod | Creato, perché mancava. Revisore obbligatorio `brunobottazzini`; bypass amministrativo disabilitato; distribuzione limitata al ramo `main` e ai tag `v*` |
| Progetto Firebase | Variabile di ambiente `FIREBASE_PROD_PROJECT_ID=vinoozy-d6f45` salvata |
| Workflow delle regole | [Run 42829140441](https://github.com/brunobottazzini/Vinoozy/actions/runs/42829140441), avviato manualmente da `main` con `ref=105c0ba432ad39d1fc05814c3150ab6a3ac80504`: tutti e tre i job (`verify-ref`, `rules`, `deploy`) riusciti. Il proprietario ha approvato; regole e indici distribuiti il 2026-11-10 alle 15:39 (Europe/Rome) |
| Autenticazione del deploy | Collegamento WIF e account dedicato creati dopo il consenso esplicito del proprietario. Verificati i quattro ruoli del progetto, il collegamento del pool all'account con filtro `attribute.environment="firebase-prod"` e tutte e tre le variabili dell'ambiente GitHub. Autenticazione effettiva riuscita nel job `deploy` |
| Build interna e produzione | [Release 42835840627](https://github.com/brunobottazzini/Vinoozy/actions/runs/42835840627) saltata dopo la CI fallita. Nessuna nuova build interna verificata. Smoke test sul telefono ancora da eseguire; nessuna promozione avviata |

Il job `deploy` è riuscito dopo l'approvazione del proprietario. I log confermano la compilazione di `firestore.rules`, la distribuzione degli indici di `(default)`, la pubblicazione delle regole su `vinoozy-d6f45` e «Deploy complete!». Lo stato «Abilitato» degli indici nella console resta da verificare prima della promozione: il workflow può finire prima che siano costruiti. Restano inoltre la CI verde, la build interna con gli smoke test, le dichiarazioni Play Console e la revisione dei testi privacy/cancellazione. Blaze, funzioni, acquisti, limite e annunci non sono stati attivati.

### Accesso configurato e verificato

- Progetto: `vinoozy-d6f45` (`742143174654`).
- Account dedicato: `github-firestore-deployer@vinoozy-d6f45.iam.gserviceaccount.com`, senza chiavi JSON.
- Ruoli sul solo progetto: `roles/firebaserules.admin`, `roles/datastore.indexAdmin`, `roles/serviceusage.serviceUsageConsumer` e `projects/vinoozy-d6f45/roles/firestoreDeployMetadataViewer` (solo `firebase.projects.get`). Il ruolo ampio `roles/firebase.viewer` non è stato concesso: avrebbe aggiunto la lettura dei dati. Il proprietario ha autorizzato separatamente la creazione e l'assegnazione del ruolo ristretto.
- Pool: `github-actions`; provider OIDC: `vinoozy-rules`, emittente `https://token.actions.githubusercontent.com`, pubblico predefinito del provider.
- Mapping: `google.subject=assertion.sub`, `attribute.environment=assertion.environment`.
- Condizione salvata: repository `brunobottazzini/Vinoozy`, ID immutabile `1445706433`, proprietario ID `4460234`, ambiente `firebase-prod`, evento `workflow_dispatch`, ramo `main` o tag `v*`, solo workflow `.github/workflows/firebase-deploy.yml`.
- `roles/iam.workloadIdentityUser` concesso sul solo account dedicato al principale `principalSet://iam.googleapis.com/projects/742143174654/locations/global/workloadIdentityPools/github-actions/attribute.environment/firebase-prod`.
- Variabili GitHub salvate: `WIF_PROVIDER=projects/742143174654/locations/global/workloadIdentityPools/github-actions/providers/vinoozy-rules`, `WIF_SERVICE_ACCOUNT=github-firestore-deployer@vinoozy-d6f45.iam.gserviceaccount.com`.

Configurazione e primo deploy verificati con successo dopo l'approvazione del proprietario. Per le funzioni, il provider dovrà essere rivalutato separatamente: quello configurato ora accetta solo il workflow delle regole.

## Rollback

Vedi `../deployment-pipeline/rollback-runbook.md`. Finché il merge non è fatto, basta chiudere la PR. Dopo il merge sul test interno, si corregge con una nuova versione.
