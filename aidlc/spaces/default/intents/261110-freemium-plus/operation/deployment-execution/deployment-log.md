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
| Codice su main | `105c0ba432ad39d1fc05814c3150ab6a3ac80504`, con entrambi i commit sopra e una correzione al test web. Nessuna PR del ramo trovata; il metodo di integrazione non è attestato da questa verifica |
| CI su main | [Run 42828170872](https://github.com/brunobottazzini/Vinoozy/actions/runs/42828170872): `rules`, `estimation` e `format` riusciti; `secrets` e `analyze` falliti; `unit` ed `e2e` ancora in corso al controllo. La validazione locale verde non equivale alla CI verde |
| Ambiente firebase-prod | Creato, perché mancava. Revisore obbligatorio `brunobottazzini`; bypass amministrativo disabilitato; distribuzione limitata al ramo `main` e ai tag `v*` |
| Progetto Firebase | Variabile di ambiente `FIREBASE_PROD_PROJECT_ID=vinoozy-d6f45` salvata |
| Workflow delle regole | [Run 42829140441](https://github.com/brunobottazzini/Vinoozy/actions/runs/42829140441), avviato manualmente da `main` con `ref=105c0ba432ad39d1fc05814c3150ab6a3ac80504`; `verify-ref` e `rules` riusciti; job `deploy` in attesa della revisione di `firebase-prod` |
| Autenticazione del deploy | Mancano `WIF_PROVIDER` e `WIF_SERVICE_ACCOUNT` sia nell'ambiente sia nelle variabili del repository. Controllata anche Google Cloud con l'account proprietario: nessun pool Workload Identity configurato e nessun account dedicato al deploy; presente solo l'account Firebase Admin SDK. Configurazione preparata nei moduli della console, non salvata, in attesa del consenso ai nuovi accessi |
| Build interna e produzione | Nessuna nuova build interna verificata. Smoke test sul telefono ancora da eseguire; nessuna promozione avviata |

La configurazione WIF deve essere completata prima che il proprietario approvi il job `deploy` di `firebase-prod`. L'avvio del workflow non attesta che le regole siano pubblicate: serve l'esito positivo del job `deploy`. Le dichiarazioni Play Console e la revisione dei testi privacy/cancellazione restano da completare prima della produzione. Blaze, funzioni, acquisti, limite e annunci non sono stati attivati.

### Accesso proposto, da approvare prima della creazione

- Progetto: `vinoozy-d6f45` (`742143174654`).
- Account dedicato: `github-firestore-deployer@vinoozy-d6f45.iam.gserviceaccount.com`, senza chiavi JSON.
- Ruoli sul solo progetto: `roles/firebaserules.admin`, `roles/datastore.indexAdmin`, `roles/firebase.viewer`, `roles/serviceusage.serviceUsageConsumer`, come da `docs/firebase-setup.md` §4.
- Pool: `github-actions`; provider OIDC: `vinoozy-rules`, emittente `https://token.actions.githubusercontent.com`, pubblico predefinito del provider.
- Mapping: `google.subject=assertion.sub`, `attribute.environment=assertion.environment`.
- Condizione preparata: repository `brunobottazzini/Vinoozy`, ID immutabile `1445706433`, proprietario ID `4460234`, ambiente `firebase-prod`, evento `workflow_dispatch`, ramo `main` o tag `v*`, solo workflow `.github/workflows/firebase-deploy.yml`.
- Il ruolo `roles/iam.workloadIdentityUser` va concesso sul solo account dedicato al principale `principalSet://iam.googleapis.com/projects/742143174654/locations/global/workloadIdentityPools/github-actions/attribute.environment/firebase-prod`.
- Variabili GitHub da salvare dopo la creazione: `WIF_PROVIDER=projects/742143174654/locations/global/workloadIdentityPools/github-actions/providers/vinoozy-rules`, `WIF_SERVICE_ACCOUNT=github-firestore-deployer@vinoozy-d6f45.iam.gserviceaccount.com`.

I moduli di creazione dell'account e del provider sono compilati, ma i pulsanti di creazione/salvataggio non sono stati premuti. Il consenso richiesto riguarda questi nuovi accessi; l'approvazione del deploy delle regole resta un passaggio successivo e distinto. Per le funzioni, il provider dovrà essere rivalutato separatamente: quello proposto ora accetta solo il workflow delle regole.

## Rollback

Vedi `../deployment-pipeline/rollback-runbook.md`. Finché il merge non è fatto, basta chiudere la PR. Dopo il merge sul test interno, si corregge con una nuova versione.
