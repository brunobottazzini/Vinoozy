# Risultati di build e test (11/11/2026)

Repository `Vinoozy`, albero di lavoro con le modifiche di Code Generation
(non ancora committate). Eseguito sul Mac del proprietario.

## Build

| Comando | Uscita | Esito |
|---|---|---|
| `flutter build apk --debug --dart-define=FIREBASE_ENV=demo` | 0 | `✓ Built build/app/outputs/flutter-apk/app-debug.apk` |
| `flutter analyze --fatal-infos` | 0 | No issues found |
| `dart format --output=none --set-exit-if-changed .` | 0 | 535 file, 0 da cambiare |

## Test di questo lavoro (`unit-test-instructions.md`, ciascuno una volta)

| Comando | Uscita | Totale | Passati | Falliti | Saltati |
|---|---|---|---|---|---|
| `bash tool/check_release_inputs_test.sh` | 0 | 15 | 15 | 0 | 0 |
| `bash tool/play_api_test.sh` | 0 | 13 | 13 | 0 | 0 |
| `actionlint -shellcheck= -pyflakes= release.yml promote.yml ci.yml` | 0 | — | — | — | — |
| `flutter test test/sharing/active_cellar_build_test.dart` | 0 | 5 | 5 | 0 | 0 |
| `flutter test test/sharing/` | 0 | 204 | 204 | 0 | 0 |

## Suite completa e copertura

| Comando | Uscita | Esito |
|---|---|---|
| `dart run tool/gen_coverage_helper.dart && flutter test --coverage` | 0 | 2880 passati, 3 saltati, 0 falliti |
| `cd packages/estimation && dart test --coverage=coverage` + `format_coverage` | 0 | verde |
| `tool/check_coverage.sh 80 coverage/merged.lcov.info` | 0 | **88,12%** (19228/21821 righe), minimo 80% |
| `tool/check_coverage.sh 80 coverage/lcov.info lib/sharing/` | 0 | **98,46%** (894/908) |

Report: `coverage/lcov.info`, `packages/estimation/coverage/lcov.info`,
`coverage/merged.lcov.info` (ignorati da git).

## Verifiche non eseguite qui

| Verifica | Motivo | Fase che la possiede |
|---|---|---|
| Test 8 E2E ripetuto 10 volte e suite E2E completa (FR7.4) | Sul Mac l'unico emulatore è API 36.1, su cui il modulo "Aggiungi vino" non si apre in nessun test E2E (8/11 rossi allo stesso punto, già prima della correzione); il proprietario ha scelto di non installare l'immagine API 34. Si verifica nel job `e2e` di GitHub Actions dopo il push | `deployment-execution` |
| Release reale sul canale interno (FR6.1, FR6.2) | Richiede i segreti che il proprietario configura con `docs/github-actions-setup.md` e un push su `main` con il suo consenso | `deployment-execution` |

## Evidenza del difetto E2E prima della correzione

`flutter test test/sharing/active_cellar_build_test.dart` sul codice di
`abe4fc0`: 3 test del provider rossi (lo stesso elenco di cantine notificava
a ogni ricalcolo: `Actual: [2, 2, 1]` invece di `[2, 1]`), coerenti con lo
stack della CI 15 (`ProviderElement._maybeRebuildDependencies` →
`_notifyListeners` → `CellarSwitcher.markNeedsBuild` durante
`CellarScreen.build`). Dopo la correzione: 5/5 verdi.

## Esito della gestione dei fallimenti

FR7.4 e FR6.1 sono `Unverified`, e per la regola della fase ciò rende la fase
non riuscita. Diagnosi: non c'è un difetto da correggere nel codice. Mancano
un ambiente (CI su `main`, segreti del proprietario) e un emulatore API 34 che
il proprietario ha scelto di non installare. Nessuna correzione praticabile
dalla generazione del codice; loop-back usati 0/3. Il proprietario ha scelto
**Accept failure** l'11/11/2026: le due verifiche passano a Deployment
Execution.

## Target Verification Matrix (finale)

Vedi `build-and-test-summary.md`.
