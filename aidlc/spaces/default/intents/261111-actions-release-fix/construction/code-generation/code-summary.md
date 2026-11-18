# Riepilogo del codice: rilascio automatico e E2E stabile

## File creati

| File | Scopo | Requisiti |
|---|---|---|
| `tool/check_release_inputs.sh` | verifica degli input di `play-internal` (7 segreti + variabile) e `play-production`; elenca tutti i problemi insieme, con nome e ambiente, senza stampare valori | FR1.1-FR1.4, FR4.1, NFR1, NFR5 |
| `tool/check_release_inputs_test.sh` | 15 casi su fixture finte | FR3.2, FR3.3 |
| `tool/play_api_test.sh` | 13 casi con stub di `gcloud` e `curl` | FR3.1, FR3.3 |
| `tool/fixtures/release_inputs/*.json` | account di servizio, `google-services.json` e defines **finti** | FR3.3 |
| `tool/fixtures/play_api/bin/{gcloud,curl}` | stub senza rete | FR3.1 |
| `docs/github-actions-setup.md` | guida per il proprietario: segreti e variabile di `play-internal`, creazione di `play-production`, controllo con `gh`, prima release, promozione | FR5.1-FR5.3 |
| `test/sharing/active_cellar_build_test.dart` | regressione del difetto E2E: 3 test sul provider, 2 sulle schermate | FR7.1-FR7.3 |

## File modificati

| File | Modifica | Requisiti |
|---|---|---|
| `tool/play_api.sh` | controllo del file della chiave (uscita 3), motivo di `gcloud` ripulito su stderr (uscita 4), errore API con metodo, percorso e stato HTTP (uscita 5); stdout solo il valore | FR2.1-FR2.4 |
| `.github/workflows/release.yml` | step `Check the play-internal configuration` subito dopo il checkout, prima di Java, Flutter e della scrittura dei file; pulizia `if: always()` invariata | FR1.1, FR1.5, NFR3 |
| `.github/workflows/promote.yml` | step `Check the play-production configuration` prima di scrivere la credenziale | FR4.1, FR4.2 |
| `.github/workflows/ci.yml` | i due test degli script nel job `analyze` | FR3.4 |
| `lib/sharing/sharing_providers.dart` | `accessibleCellarsProvider` restituisce `AccessibleCellarList`, lista in sola lettura uguale per contenuto | FR7.2 |
| `docs/firebase-setup.md` §5, §6; `docs/play-console-handoff.md` §3 | una riga di rimando alla guida; le modifiche locali del proprietario negli altri punti sono intatte | FR5.4 |

## Decisioni chiave

- **Causa del difetto E2E**, ricavata dallo stack completo del log della CI 15
  (`gh run view --log`, sola lettura). `CellarScreen.build` osserva
  `activeCellarProvider`, e Riverpod svuota prima la sua dipendenza in
  sospeso `accessibleCellarsProvider` (`_maybeRebuildDependencies`). Il
  ricalcolo restituisce una nuova `List`, mai `==` alla precedente, e
  Riverpod avvisa gli ascoltatori, tra cui il `CellarSwitcher` della
  Dashboard, che sta in un altro ramo dell'albero: Flutter segnala
  "markNeedsBuild() called during build". Nel test 8 la lista contiene solo
  la cantina personale, prima e dopo. Con l'uguaglianza per contenuto non
  parte nessun avviso.
- **Correzione scelta**: uguaglianza per contenuto, invece di rinviare i
  cambi di `ActiveCellarNotifier` con un microtask (ipotesi del piano, Step
  11). Il notifier non era nel percorso dell'avviso. La correzione elimina
  solo gli avvisi senza cambiamento e non tocca il comportamento visibile.
- **Base64 rigido** in `check_release_inputs.sh`: un'espressione regolare
  rende uguale il risultato su GNU (runner) e BSD (macOS).
- `call()` di `play_api.sh` usa `return` e non `exit`, così la
  cancellazione dell'edit, già tollerata con `|| true`, non interrompe lo
  script.

## Test eseguiti

| Comando | Esito |
|---|---|
| `bash tool/check_release_inputs_test.sh` | 15/15 verdi |
| `bash tool/play_api_test.sh` | 13/13 verdi |
| `actionlint -shellcheck= -pyflakes= .github/workflows/*.yml` | nessun errore (installato sul Mac con il consenso del proprietario) |
| `flutter test test/sharing/active_cellar_build_test.dart` sul codice **prima** della correzione | 3 test sul provider rossi (atteso), 2 sulle schermate verdi |
| `flutter test test/sharing/` dopo la correzione | 204/204 verdi |
| `flutter test --coverage` (intera suite) | 2880 verdi, 3 saltati |
| `tool/check_coverage.sh 80 coverage/lcov.info lib/sharing/` | 98,46% |
| `flutter analyze --fatal-infos`, `dart format --set-exit-if-changed .` | puliti |

## Test non eseguiti in questa fase, con il motivo

- **E2E sull'emulatore (FR7.4, Step 12)**: sul Mac l'unico emulatore è API
  36.1, e lì il modulo "Aggiungi vino" non si apre in nessun test (8 test su
  11 di `u1_skeleton_test.dart` falliscono allo stesso punto, prima della
  correzione). Il proprietario ha scelto di non installare l'immagine API 34:
  il test 8 e la suite E2E completa si verificano in GitHub Actions dopo il
  push (Build and Test).
- **Release reale (FR6)**: richiede i segreti, che il proprietario configura
  con la guida, e un push su `main` fatto con il suo consenso.

## Deviazioni dal piano

- Step 9: la riproduzione locale non è stata possibile (vedi sopra). La
  causa è dimostrata dallo stack della CI e dai test del provider, che falliscono
  sul codice di prima (FR7.1, ramo "test deterministico").
- Step 10-11: il meccanismo reale (dipendenza svuotata durante la build) ha
  portato a correggere `accessibleCellarsProvider` e non `ActiveCellarNotifier`.
- Step 12: E2E sul Mac non eseguito; resta aperto per Build and Test.
- Problema emerso, fuori ambito: sull'emulatore API 36.1 il modulo
  "Aggiungi vino" non si apre nei test E2E. Va indagato a parte, se il
  telefono o i tester usano Android 16.
