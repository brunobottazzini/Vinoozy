# Valutazione della qualità del codice

## Test

| Livello | Dove | Strumento | Note |
|---|---|---|---|
| Unit e widget | `test/` (154 file) per modulo: `account`, `app`, `catalog`, `cellar`, `dashboard`, `label`, `sharing`, `tool`, `u1`; helper in `test/helpers/` e harness per modulo (`*_harness.dart`) | flutter_test, mocktail | Widget test nelle tre lingue; `test/app/about_screen_test.dart` copre già Informazioni |
| Pacchetto stima | `packages/estimation/test/` (22 file) + fixture JSON | package:test | Copertura separata, unita a quella dell'app in CI |
| Regole Firestore | `test/rules/*.rules.test.mjs`, `test/rules/compat/` (`app-writes.json`) | node --test, @firebase/rules-unit-testing, emulatore | Compatibilità con la versione in produzione |
| Pagina web | `test/web/*.test.mjs` | node --test, c8 80%, playwright | Contro emulatori Auth e Firestore |
| End-to-end | `integration_test/` (account, autofill, cellar, drink concorrente, dashboard 500, restart probe, label, override, sharing, style profile, skeleton U1) | integration_test su emulatore Android + Emulator Suite | Build con `E2E=true`; `tool/e2e_force_stop.sh` |
| Prestazioni | `integration_test_perf/`, `benchmark/`, `packages/estimation/benchmark/` | flutter_driver, benchmark Dart | Build con `PERF=true` sul telefono |
| Nativo Android | `android/app/src/test/` | JUnit + Robolectric, JaCoCo 80% | Due classi della foto etichetta |

Copertura: `tool/check_coverage.sh 80` sul totale unito (app + estimation,
senza esclusioni, file generati compresi grazie a
`tool/gen_coverage_helper.dart`) e per cartella su `lib/catalog/`,
`lib/dashboard/`, `lib/sharing/`, `lib/cellar/`, `lib/label/`,
`lib/account/`. Nessun dato di copertura misurato in questa scansione (nessun
test eseguito).

## Analisi statica e stile

- `flutter analyze --fatal-infos` con `flutter_lints`; `dart analyze
  --fatal-infos` per `estimation`; `dart format --set-exit-if-changed`.
- Codice, identificatori e commenti in inglese; testi UI solo nei file ARB.
- Gate specifici in CI: `check_off_config.sh`, `check_dashboard_readonly.sh`,
  `check_rule_ids.sh` (BR con test nominati, per cantina, etichetta, account),
  `check_label_imports.sh`, `check_lens_manifest.sh`,
  `check_estimation_purity.sh`, `check_web_pins.sh`, `check_web_config.mjs`,
  `check_publication.mjs --draft`, `check_firestore_indexes.sh`,
  `check_release_build.sh`, `check_app_size.sh`; quasi ognuno ha il proprio
  `*_test.sh` con fixture in `tool/fixtures/`.
- Ricerca segreti con gitleaks (job `secrets`).

## CI/CD

| Workflow | Trigger | Job / effetto |
|---|---|---|
| `ci.yml` | push, pull_request | `format`, `secrets`, `analyze` (+ gate), `unit` (test, copertura, benchmark, test Gradle, `check_release_build.sh`), `estimation`, `rules` (+ web, indici), `e2e` (emulatore Android) |
| `release.yml` | `workflow_run` di `ci` riuscito su push a `main` | AAB firmato, `versionCode` da Play, canale interno, tag `build-<code>`; simboli Crashlytics in job separato |
| `promote.yml` | manuale | Promozione in produzione (ambiente `play-production`) e tag |
| `pages.yml` | manuale | Pubblicazione di privacy e cancellazione account su GitHub Pages |
| `firebase-deploy.yml` | manuale | Test delle regole e indici, poi deploy in produzione (ambiente `firebase-prod`) |

Azioni di terze parti fissate per SHA. Dependabot attivo.

## Documentazione

Buona: `README.md` (in italiano) con comandi e deviazioni dal piano;
`docs/firebase-setup.md`, `docs/release-checklist.md` per unità/intent;
checklist di pubblicazione; studio di monetizzazione. Commenti nel codice
fitti e tracciati agli ID dei requisiti.

## Valutazione rapida

| Criterio | Voto | Evidenza |
|---|---|---|
| Chiarezza dei nomi | buona | Nomi espliciti, chiavi di widget stabili |
| Dimensione delle funzioni | discreta | Repository e schermate lunghe (vedi sotto) |
| Gestione degli errori | buona | Classificazione `rejected`/`unauthenticated`/`transient`, ragioni fisse, valori sensibili oscurati, nessun errore silenzioso |
| Presenza di test | buona | Ogni modulo ha test unit/widget, regole ed E2E |
| Duplicazione | discreta | Schema ledger→batch ripetuto in `WineRepository` e `DrinkingRecordRepository` |
| Codice morto | buona | Nessun TODO/FIXME; una sola soppressione lint |

## Debito tecnico e rischi

1. **Test delle regole non eseguito in CI**: `test/rules/style_profiles.rules.test.mjs` non è nell'elenco di `npm run test:rules` in `package.json`, unico elenco usato da `ci.yml` e `firebase-deploy.yml`.
2. **File molto grandi**: `lib/cellar/ui/add_wine_screen.dart` (1697 righe), `lib/cellar/ui/guided_confirm_sheet.dart` (1130), `lib/cellar/data/wine_repository.dart` (1051), `lib/label/core/guided_session.dart` (878), `packages/estimation/lib/src/label_candidates.dart` (2220).
3. **Budget di espressioni delle regole**: `validWineUpdate` è già raggruppato per stare sotto 1000 espressioni e `WineRepository.updateWine` divide alcune modifiche in due update; nuove validazioni sui vini (capacità, diritti) vanno pesate con attenzione.
4. **Nessuna invariante server sul numero di schede**: oggi nulla limita il numero di vini per cantina; la quantità può essere negativa (ADR-004), quindi "attiva" va definita come `quantity > 0` anche lato server.
5. **Nessun backend**: le verifiche di acquisto, i contatori d'uso e le prenotazioni pubblicitarie dello studio richiedono un componente server inesistente (e Blaze).
6. **Perimetro dei marker di rilascio**: `check_release_build.sh` non conosce ancora marker di cheat; il controllo positivo usa una build release con `E2E`/`PERF`, mentre lo studio richiede il controllo positivo dei cheat in modalità non release.
7. **Albero di lavoro non committato**: 36 file modificati e diversi nuovi rispetto a `ee114e3` (workflow, profilo, link esterni, privacy, distribuzione Play); la base reale dell'intent è l'albero attuale.
8. **`app_pt.arb` vuoto**: richiesto da `flutter gen-l10n`; il portoghese europeo riceve l'inglese; il file generato `app_localizations_pt.dart` pesa sulla copertura.
