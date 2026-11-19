# Build and Test — Riepilogo

Intent: `261119-tester-feedback` (express, strategia di test Minimal). Tre tentativi: il primo ha trovato sul telefono il riquadro del giro guidato fuori posto, corretto con il Loop-back 1 (Step 18–20 di Code Generation, più R-02 e R-04); il secondo ha rieseguito i controlli; dopo il push la CI ha fermato `tool/check_off_config.sh` (indirizzo email nel Dart), corretto con il Loop-back 2 (Step 21), e il terzo ha rieseguito suite, copertura, build di rilascio e tutti i controlli del job `analyze`. Dettagli in `test-results.md`, comandi in `build-instructions.md`, copertura dei requisiti in `cross-unit-traceability.md`.

## Target Verification Matrix

| Target ID | Source | Expected | Actual | Evidence | Owning Stage | Verdict |
|---|---|---|---|---|---|---|
| T1 Formattazione | `team.md` Code Style | `dart format` senza file cambiati | 0 file cambiati | `test-results.md` tentativo 3 | code-generation | PASS |
| T2 Analisi statica | `team.md` Code Style | `flutter analyze --fatal-infos` senza problemi | "No issues found!" | `test-results.md` tentativo 3 | code-generation | PASS |
| T3 Suite di test | `org.md` Testing Posture (express: i test esistenti restano verdi) | 0 falliti | 5186 superati, 3 saltati, 0 falliti | `test-results.md` tentativo 3 | code-generation | PASS |
| T4 Test dei requisiti | strategia Minimal | almeno un test per requisito | 34/34 requisiti coperti | `cross-unit-traceability.md` | code-generation | PASS |
| T5 Copertura righe | `team.md` Testing Posture | ≥ 80% progetto e cartelle controllate | 97,40% (tentativo 3); cartelle 94,77–99,21% (tentativo 2) | `test-results.md` tentativi 2 e 3 | code-generation | PASS |
| T6 Build di rilascio | `build-instructions.md` | `check_release_build.sh` uscita 0, nessun permesso nuovo | uscita 0 | `test-results.md` tentativi 1, 2 e 3 | code-generation | PASS |
| T7 Avvio release | `build-instructions.md` | `check_release_launch.sh` senza crash | "release build started without crashing" | `test-results.md` tentativo 1 | code-generation | PASS |
| T8 E2E `integration_test` | `team.md` Testing Posture | tutti verdi | 30 superati, 3 saltati, 1 fallito (preesistente, fallisce anche su `375a581`, solo AVD locale) | `test-results.md` tentativo 1 | code-generation | PASS (con limite) |
| T9 E2E freemium | `team.md` Testing Posture | verdi | 3/3 | `test-results.md` tentativo 1 | code-generation | PASS |
| T10 E2E chiusura forzata | `team.md` Testing Posture | script completo | passo 1 verde; passo 4 bloccato dallo spazio dell'AVD locale; delegato alla CI (decisione 6e6ccd8e) | `test-results.md` tentativo 2 | code-generation | PASS (con limite) |
| T11 Pubblicazione store | `build-instructions.md` | `check_publication.mjs` OK | "Publication files OK" | `test-results.md` tentativo 1 | code-generation | PASS |
| T12 Prova sul telefono | Loop-back 1 | giro guidato con riquadro centrato | confermato dal proprietario e da screenshot | `test-results.md` tentativo 2 | code-generation | PASS |
| T14 Controlli del job `analyze` | `.github/workflows/ci.yml` | tutti i passi OK, compreso `check_off_config.sh` | tutti OK | `test-results.md` tentativo 3 | code-generation | PASS |
| T13 Pipeline CI | ci-pipeline | — | N/A: the plan runs no CI Pipeline; i controlli girano nel workflow GitHub Actions esistente al push | — | ci-pipeline (SKIP) | N/A |

## Pronto per il rilascio

Sì, per il canale di test interno. Il codice è pronto per commit e push; al push GitHub Actions rieseguirà tutti i controlli, E2E compresi, e pubblicherà la 0.4.0 (+build) sul canale interno.

## Limiti

- **E2E `cellar_test` "add again"**: fallisce sull'AVD locale perché il messaggio "Bevuto" copre "Scrivi"; fallisce anche sulla versione committata, in CI passa. Non è una regressione di questo lavoro.
- **E2E chiusura forzata**: verificato completo solo in CI, per lo spazio dell'emulatore locale.
- **In-App Review**: la finestra di recensione di Google Play compare solo con l'app installata da Play; va provata sul telefono dalla build del canale interno.
- **Rischi accettati** di Code Generation ancora aperti: R-01 (feedback via email senza app di posta), R-03, R-05, R-06; testi in 23 lingue senza rilettura madrelingua.
