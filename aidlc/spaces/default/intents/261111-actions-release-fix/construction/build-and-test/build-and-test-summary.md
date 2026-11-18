# Riepilogo di Build and Test

## Stato

- **Build**: riuscita (APK di debug, analisi e formattazione pulite).
- **Test**: tutti verdi (28 casi degli script, 5 di regressione, 2880 della
  suite Flutter, copertura totale 88,12%).
- **Tipi di test**: unit e widget (Flutter), test degli script bash con stub e
  fixture finte, lint dei workflow. Strategia Minimal: nessun file di
  istruzioni aggiuntivo.

## Copertura attesa

| Ambito | Soglia | Fonte | Misurata |
|---|---|---|---|
| Totale app + estimation, senza esclusioni | 80% righe | `team.md`, Testing Posture | 88,12% |
| `lib/sharing/` | 80% righe | `ci.yml` (soglia per cartella) | 98,46% |
| Script bash | — | nessuna soglia definita | — |

## Target Verification Matrix

| Target ID | Source | Expected | Actual | Evidence | Owning Stage | Verdict |
|---|---|---|---|---|---|---|
| TC-COV-TOTAL | `team.md` Testing Posture; Testing Contract | ≥ 80% righe, nessuna esclusione | 88,12% | `tool/check_coverage.sh 80 coverage/merged.lcov.info` (uscita 0) | build-and-test | Met |
| TC-COV-SHARING | `.github/workflows/ci.yml` job `unit` | ≥ 80% righe su `lib/sharing/` | 98,46% | `tool/check_coverage.sh 80 coverage/lcov.info lib/sharing/` | build-and-test | Met |
| TC-SUITE-GREEN | Testing Contract `scope_floor` | suite esistente verde | 2880 passati, 0 falliti | `flutter test --coverage` | build-and-test | Met |
| TC-CI-BEFORE-MERGE | `team.md` Testing Posture (gate prima del merge) | test in CI prima del merge | — | — | — (`ci-pipeline` SKIP) | N/A: the plan runs no CI Pipeline |
| NFR1 | `requirements.md` | nessun valore di credenziale nell'output | nessun valore delle fixture nell'output | `tool/check_release_inputs_test.sh`, `tool/play_api_test.sh` (controlli di fuga) | build-and-test | Met |
| NFR2 | `requirements.md` | `actionlint` pulito | 0 errori | `actionlint -shellcheck= -pyflakes=` | build-and-test | Met |
| NFR3 | `requirements.md` | verifica prima di scrittura file e build | step subito dopo il checkout, prima di Java e Flutter | `.github/workflows/release.yml`; caso "nothing configured" del test (uscita 1 con 8 nomi) | build-and-test | Met |
| NFR4 | `requirements.md` | controlli verdi, soglie invariate | analisi, formato, test, copertura verdi; nessuna soglia cambiata | comandi sopra; `git diff` senza modifiche a soglie | build-and-test | Met |
| NFR5 | `requirements.md` | script compatibili con runner e macOS | test verdi su macOS bash 3.2 senza `gcloud` | `tool/play_api_test.sh` | build-and-test | Met |
| NFR6 | `requirements.md`, `team.md` Code Style | codice in inglese, documenti in italiano | rispettato | revisione dei file | build-and-test | Met |
| FR7.4 | `requirements.md` | test 8 verde 10 volte + suite E2E verde | non eseguito | emulatore locale API 36.1 non adatto; API 34 non installata per scelta del proprietario | deployment-execution | Unverified |
| FR6.1 | `requirements.md` | release reale: versionCode, AAB firmato, canale interno, tag | non eseguita | servono i segreti del proprietario e il push su `main` | deployment-execution | Unverified |

## Prontezza

- **Build-ready**: sì.
- **Test-ready**: sì per tutto ciò che si esegue in locale.
- **Deployment-ready**: il codice sì; la release automatica dipende dalla
  configurazione dei segreti (`docs/github-actions-setup.md`).

## Limiti e punti aperti

- FR7.4 e FR6.1 restano `Unverified` fino a Deployment Execution.
- Fuori ambito, da indagare a parte: sull'emulatore Android 16 (API 36.1) il
  modulo "Aggiungi vino" non si apre nei test E2E.
- `firestore-debug.log` e `android/local.properties` sono stati riscritti
  dagli strumenti locali (emulatore Firestore, Flutter): non vanno committati
  con questo lavoro.
