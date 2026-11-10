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

## Da fare, a cura del proprietario

Su questo Mac non c'è la CLI `gh`, quindi PR e merge non sono eseguibili da qui.

1. **Aprire la PR** da `freemium-plus` verso `main` (link sopra).
2. **Attendere la CI verde.** Controlli obbligatori: `unit`, `rules` (ora con funzioni e script) ed `e2e` (ora anche con l'emulatore Functions e `tool/e2e_freemium.sh`).
3. **Unire con «Rebase and merge»**, non con «Squash and merge». È l'eccezione scelta in Q3. Se la protezione del ramo consente solo lo squash, abilita temporaneamente «Allow rebase merging» nelle impostazioni del repository.
4. **`release.yml`** partirà da solo dopo il merge e caricherà l'AAB sul **test interno**.
5. **Pubblicare le regole** con `firebase-deploy.yml`, usando il commit di merge o un tag `v*`, e approvare in `firebase-prod`. Va fatto prima di qualsiasi promozione: `promote.yml` la blocca finché le regole della build non sono quelle pubblicate (`RULES_FEATURES` ora comprende `freemium`).
6. **Smoke test** sul telefono con la build del test interno (smoke-test-results.md).
7. Produzione (`promote.yml`), Blaze, funzioni e Play Console: più avanti, secondo deployment-strategy.md.

## Rollback

Vedi `../deployment-pipeline/rollback-runbook.md`. Finché il merge non è fatto, basta chiudere la PR. Dopo il merge sul test interno, si corregge con una nuova versione.
