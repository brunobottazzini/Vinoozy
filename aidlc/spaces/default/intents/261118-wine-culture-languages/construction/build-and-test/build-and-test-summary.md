# Riepilogo di Build and Test — Lingue dei paesi del vino

## Stato

- **Build**: riuscita (build di rilascio, manifest, build di controllo).
- **Test unitari e dei widget**: 4990 superati, 0 falliti.
- **Copertura**: 97,29% sul progetto, sopra l'80% in ogni modulo controllato.
- **Esito della fase**: **non superata**, per due motivi.
  - L'elenco delle lingue nelle impostazioni di Android mostra 23 voci su 25 (FR2.2).
  - Test end-to-end e durata in CI non sono verificabili in locale.

Prerequisiti e comandi: `build-instructions.md`. Dettaglio dei risultati: `test-results.md`. Tracciabilità: `cross-unit-traceability.md`.

## Tipi di test

Strategia Minimal: nessun file di istruzioni aggiuntivo. I test sono quelli di Code Generation (unitari e dei widget, test generato dei messaggi) più la suite esistente, i test nativi Android, i test end-to-end e una prova manuale sul telefono.

## Copertura attesa

Almeno l'80% delle righe su tutto il codice, senza esclusioni, codice generato compreso (`team.md`), più l'80% per modulo controllato in CI e il 90% per `packages/estimation`. Lavoro senza Unit: nessun obiettivo per Unit.

## Target Verification Matrix

| Target ID | Source | Expected | Actual | Evidence | Owning Stage | Verdict |
|---|---|---|---|---|---|---|
| TC-COV | `team.md` Testing Posture; `code-generation-plan.md` Testing Contract | ≥ 80% righe, progetto, nessuna esclusione | 97,29% | `tool/check_coverage.sh 80 coverage/merged.lcov.info`, uscita 0 | build-and-test | Met |
| TC-COV-MOD | `.github/workflows/ci.yml` (catalog, dashboard, sharing, cellar, label, account) | ≥ 80% per modulo | 94,75%–99,21% | `tool/check_coverage.sh 80 coverage/lcov.info <modulo>` | build-and-test | Met |
| TC-COV-EST | `.github/workflows/ci.yml` job `estimation` | ≥ 90% | 98,10% | `packages/estimation`: `check_coverage.sh 90` | build-and-test | Met |
| NFR1 | `requirements.md` NFR1 | Codice generato delle lingue nuove coperto, soglia invariata | `lib/l10n/` 100,00% | `tool/check_coverage.sh 80 coverage/lcov.info lib/l10n/` | build-and-test | Met |
| NFR2 | `requirements.md` NFR2 | Job `unit` in GitHub Actions ≤ 40 min | Non misurabile in locale; stima 28–35 min (ultima CI 22 min 41 s) | `gh run view 43202895608`; `test-results.md` | build-and-test | Unverified |
| NFR3 | `requirements.md` NFR3 | Prova completa in 10 lingue senza errori di impaginazione | 10 lingue in `matrixLocales`, tutte verdi | `flutter test --coverage`, 0 falliti | build-and-test | Met |
| NFR4 | `requirements.md` NFR4 | Messaggi completi e mostrati nelle altre 15 lingue | `languages_test.dart` e `l10n_exercise_test.dart` verdi; `l10n_untranslated.json` = `{}` | `flutter test --coverage` | build-and-test | Met |
| NFR5 | `requirements.md` NFR5 | Un solo elenco delle lingue | `language_consistency_test.dart` verde | `flutter test --coverage` | build-and-test | Met |
| NFR6 | `requirements.md` NFR6 | Glossario nel repository, uso coerente | `docs/l10n-glossary.md` con 25 colonne | Lettura del file | build-and-test | Met |
| FR2.2 | `requirements.md` FR2.2 | Le 25 lingue nelle impostazioni di Android 13+ e scelta funzionante | App: 25 lingue dichiarate (`pt-BR`, `pt-PT`, `sr-Cyrl`) e applicate. Menu di OxygenOS: 23 voci (un "Português" con regione del telefono, nessun serbo), anche dopo la correzione | Telefono CPH2581, OxygenOS 16; `aapt2 dump`; `cmd locale`; `test-results.md` | build-and-test | Not Met (limite del menu di OxygenOS, nessuna correzione lato app) |
| TC-STATIC | `team.md` Code Style | Formattazione e analisi pulite | 0 file da formattare; nessun problema | `dart format`, `flutter analyze --fatal-infos` | build-and-test | Met |
| TC-NATIVE | `.github/workflows/ci.yml` job `unit` | Test Robolectric verdi, JaCoCo ≥ 80% | Uscita 0 | `./gradlew :app:testDebugUnitTest :app:jacocoLabelReport` | build-and-test | Met |
| TC-RELEASE | `.github/workflows/ci.yml` job `unit` | `tool/check_release_build.sh` superato | Superato; `localeConfig` nel manifest di rilascio | `tool/check_release_build.sh` | build-and-test | Met |
| TC-BENCH | `.github/workflows/ci.yml` job `unit` | Benchmark entro le soglie | Tutti entro le soglie | `dart run benchmark/*_benchmark.dart` | build-and-test | Met |
| TC-STORE | `requirements.md` FR4.1 | Testi dello store entro i limiti in 25 lingue | Superato | `node tool/check_publication.mjs --draft` | build-and-test | Met |
| TC-E2E | `team.md` Testing Posture (End-to-end) | Test end-to-end verdi su emulatore Android con Firebase Emulator Suite | Locale: 14 falliti, tutti già falliti sul codice di prima (16); ambiente diverso dalla CI | `flutter test integration_test`; `test-results.md` | build-and-test | Unverified |
| TC-CI | `code-generation-plan.md` Testing Contract (CI execution before merge) | Test eseguiti in CI prima del merge | — | Il piano non esegue CI Pipeline (`ci-pipeline` = SKIP) | — | N/A (the plan runs no CI Pipeline) |

## Esito accettato dal proprietario

Il 2026-11-18 il proprietario ha scelto "Accept failure" (messaggio a98e4e44) per i tre target non chiusi:
- FR2.2: limite del menu di OxygenOS, nessuna correzione lato app dopo il Loop-back 1;
- TC-E2E: nessuna regressione in locale rispetto al codice di prima;
- NFR2: stima tra 28 e 35 minuti su 40.

TC-E2E e NFR2 si confermano alla prima esecuzione in GitHub Actions.

## Prontezza

- **Build-ready**: sì.
- **Test-ready**: sì per unit, widget, nativi e copertura; no per end-to-end.
- **Deployment-ready**: sì, con riserva. FR2.2 è accettato con il limite di OxygenOS. End-to-end e durata vanno confermati verdi in GitHub Actions prima del merge in `main`: è il controllo di CI che blocca il merge.

## Limiti e punti aperti

- Traduzioni senza revisione di un madrelingua (assunzione dei requisiti).
- `overrideSheetHint` cita in en, it e pt-BR un'etichetta che non esiste con quelle parole (già prima di questo lavoro).
- Sul telefono resta installata la build di prova; per tornare alla versione di Google Play va disinstallata.
