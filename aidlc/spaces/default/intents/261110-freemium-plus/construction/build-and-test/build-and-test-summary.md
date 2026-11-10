# Riepilogo Build and Test — Freemium e Plus

## Stato

- **Build:** riuscita, con formattazione, analisi statica, compilazione delle funzioni e controllo della release.
- **Test:** tutti verdi, cioè unit e widget Flutter, `packages/estimation`, regole Firestore, Cloud Functions, script amministrativi ed end-to-end di freemium sull'emulatore Android.

I dettagli sono in `test-results.md`.

## Tipi di test

- Unit e widget Flutter, compresi quelli nelle tre lingue e quelli con il flag degli strumenti sviluppatore.
- Regole Firestore sull'emulatore.
- Cloud Functions sull'emulatore, con client Play e Billing finti.
- Script amministrativi sugli emulatori Auth e Firestore.
- End-to-end sull'emulatore Android collegato alla Emulator Suite.

Con la strategia Minimal non servono istruzioni aggiuntive per test di integrazione, prestazioni o sicurezza.

## Copertura attesa

È fissata all'80% delle righe su tutto il progetto (team.md), senza soglie per singola Unit perché il lavoro non ha Unit.

## Target Verification Matrix

| Target ID | Source | Expected | Actual | Evidence | Owning Stage | Verdict |
|---|---|---|---|---|---|---|
| TC-coverage | `code-generation-plan.md` Testing Contract; team.md Testing Posture | ≥ 80% delle righe, progetto completo senza esclusioni | 88,11% (19217/21810) | `tool/check_coverage.sh 80 coverage/merged.lcov.info`, exit 0 | build-and-test | Met |
| TC-estimation-coverage | `.github/workflows/ci.yml` (soglia del pacchetto) | ≥ 90% | 98,10% | `tool/check_coverage.sh 90` in `packages/estimation` | build-and-test | Met |
| TC-folder-coverage | `.github/workflows/ci.yml` (soglie per cartella: catalog, dashboard, sharing, cellar, label, account) | ≥ 80% ciascuna | da 94,53% a 99,19% | `tool/check_coverage.sh 80 coverage/lcov.info <cartella>` | build-and-test | Met |
| TC-existing-green | Testing Contract, scope_floor | La suite esistente resta verde | 0 falliti in tutte le suite | `test-results.md` | build-and-test | Met |
| TC-requirement-tests | Testing Contract, strategy_volume Minimal | Almeno un test per requisito, percorso principale per componente | 50/50 ID tracciati; test nuovi in Flutter, regole, funzioni, script ed E2E | `cross-unit-traceability.md`, `code-summary.md` | build-and-test | Met |
| TC-format-analyze | team.md Code Style | `dart format` e `flutter analyze` puliti | 0 file cambiati, nessun problema | comandi in `test-results.md` | build-and-test | Met |
| TC-e2e-android | team.md Testing Posture (end-to-end su emulatore Android) | E2E del lavoro verdi sull'emulatore Android | `tool/e2e_freemium.sh` 3/3 | `test-results.md` | build-and-test | Met |
| TC-release-markers | Requisito FR5.7 | Marker degli strumenti sviluppatore assente nella release | Tutti i controlli ok | `tool/check_release_build.sh`, eseguito in Code Generation il 2026-11-10, codice dell'app invariato da allora | build-and-test | Met |
| TC-ci-before-merge | team.md Testing Posture, «Gate prima del merge» in GitHub Actions | I controlli girano in CI prima del merge | — | — | ci-pipeline | N/A — the plan runs no CI Pipeline |

## Prontezza

- **Pronto per la build:** sì.
- **Pronto per i test:** sì.
- **Pronto per il rilascio:** con riserva. Il codice è pronto, ma tutte le funzioni nuove sono spente, come previsto. Per accenderle servono passi manuali del proprietario:
  - passaggio a Blaze con le protezioni (`docs/blaze-switch.md`);
  - pubblicazione delle funzioni;
  - configurazione di Play Console (`docs/plus-setup.md`);
  - dichiarazioni «ID pubblicità» e «Sicurezza dei dati»;
  - revisione dei testi legali.

## Limiti e punti aperti

- La suite E2E completa (circa 30 minuti) non è stata rieseguita in locale. È rieseguito solo l'end-to-end di freemium.
- `lib/plan` (79,75%) e `lib/ads` (74,03%) sono sotto l'80% se presi da soli. Le righe scoperte sono soprattutto gli adattatori dei plugin. Per queste cartelle non c'è una soglia per cartella.
- Vulnerabilità npm moderate nelle dipendenze transitive di `functions/` e `tool/admin/`. Non sono state corrette.
- `tool/app_size_baseline.txt` è `UNSET`. L'AAB release pesa 23,5 MB.
