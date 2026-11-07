# Controlli di qualità — Vinoozy

Ogni controllo qui sotto è **bloccante**:
- un job rosso di `ci.yml` blocca il merge in `main` tramite il ruleset;
- blocca anche la pubblicazione sul test interno, perché `release.yml` parte solo quando `ci` finisce con successo.

Regola del team: un controllo rosso non si aggira e una soglia non si abbassa.

## Controlli prima del merge

| Controllo | Job | Comando | Soglia | Verificato in Build and Test |
|---|---|---|---|---|
| Formattazione | `format` | `dart format --output=none --set-exit-if-changed .` | nessuna differenza | sì, uscita 0 |
| Segreti nella storia | `secrets` | `gitleaks git --redact --exit-code 1 .` | nessun segreto trovato | no: job nuovo, prima corsa su GitHub |
| Analisi statica | `analyze` | `flutter analyze --fatal-infos` | 0 problemi, anche informativi | sì, 0 problemi |
| Controlli del repository | `analyze` | `check_off_config.sh`, `check_dashboard_readonly.sh`, `check_rule_ids.sh` (U4 20, U6 15, U8 13 regole), `check_label_imports.sh`, `check_web_pins.sh`, `check_web_config_test.sh` e i loro test | uscita 0 | sì, tutti 0 |
| Niente configurazione di produzione | `analyze` | `git ls-files` senza `google-services.json`, `config/firebase_prod.json`, `*.jks`, `*.keystore` | nessun file | sì |
| Test di unità e widget | `unit` | `flutter test --coverage` | tutti verdi | sì, 1.528 superati |
| Copertura del progetto | `unit` | `tool/check_coverage.sh 80 coverage/merged.lcov.info` | ≥ 80% delle righe, senza esclusioni | sì, 89,13% |
| Copertura per unità | `unit` | `tool/check_coverage.sh 80 coverage/lcov.info lib/<unità>/` per catalog, dashboard, sharing, cellar, label, account | ≥ 80% ciascuna | sì, 95–99% |
| Velocità della logica | `unit` | `benchmark/catalog_benchmark.dart`, `dashboard_benchmark.dart`, `cellar_benchmark.dart` | soglie nei benchmark (es. 10 ms per la Dashboard su 500 vini), una ripetizione solo se oltre soglia | sì, tutte sotto |
| Codice nativo | `unit` | `./gradlew :app:testDebugUnitTest :app:jacocoLabelReport` | tutti verdi, JaCoCo ≥ 80% | sì, 31 test, 90,45% |
| Build di rilascio pulita | `unit` | `tool/check_release_build.sh` | niente codice di test né permessi foto/fotocamera nel rilascio | sì |
| Pacchetto di stima | `estimation` | format, analyze, purezza, `dart test --coverage`, `check_coverage.sh 90`, benchmark | tutti verdi, ≥ 90% | sì, 100% |
| Regole di Firestore | `rules` | `npm run test:rules` | tutti verdi (1 saltato finché non esiste un tag `v*`) | sì, 191 + 1 saltato |
| Pagina di cancellazione | `rules` | `npm run test:web` (Node + Chromium) | tutti verdi, `c8` ≥ 80% | sì, 16/16, 100% |
| Indici di Firestore | `rules` | `tool/check_firestore_indexes.sh` (+ test) | indici richiesti presenti | sì |
| End-to-end | `e2e` | `flutter test integration_test …` + `tool/e2e_force_stop.sh` | tutti verdi, limiti di tempo dei test invariati | **no**: 17 su 20 nell'ultima corsa completa, `label_test` sistemato dopo. Restano aperti `cellar_test` (U4 NFR6.6, fallimento accettato) e lo scenario 8 di U1 (instabile) |

## Controlli dopo il merge

| Controllo | Dove | Chi decide |
|---|---|---|
| Build firmata sul test interno | `release.yml` | automatico, solo dopo `ci` verde su `main` |
| Prova sul telefono (avvio, accesso Google, sincronizzazione) | `docs/release-checklist.md` | tu |
| Regole e indici in produzione | `firebase-deploy.yml`, ambiente `firebase-prod` | tua approvazione |
| Pagina web | `pages.yml`, ambiente `github-pages-publish` | tua approvazione |
| Produzione con rilascio graduale | `promote.yml`, ambiente `play-production` | tua approvazione |

## Cosa non è un controllo

- **Dimensione dell'app:** non blocca il merge (decisione del 2026-11-06). `tool/check_app_size.sh` resta per una misura a mano.
- **Misure sul telefono** (300 ms per il salvataggio, 2 s per l'avvio, lettura delle etichette): si fanno a mano con la build release, seguendo `docs/release-checklist.md`.
- **Riprove:** nessun job ripete un test fallito. Solo `e2e` riprova una volta, e solo se l'emulatore Android non si è avviato.
