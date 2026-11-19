# Risultati di build e test — tentativo 3 (2026-11-19, dopo il Loop-back 2)

| Comando | Esito |
|---|---|
| `tool/check_off_config.sh` | OK (1311 file) — era il controllo fallito in CI |
| Altri controlli del job `analyze` di `ci.yml` (dashboard, rule ids, label imports, lens manifest, wine db, appellations, release inputs, play api, web pins, web config, `check_publication.mjs --draft`) | tutti OK |
| `dart format --output=none --set-exit-if-changed .` | OK, 0 file cambiati |
| `flutter analyze --fatal-infos` | OK, "No issues found!" |
| `flutter test --coverage` (suite completa) | 5186 superati, 3 saltati, 0 falliti |
| Copertura `tool/check_coverage.sh 80` | **97,40%** (40674/41760) |
| `./gradlew :app:testDebugUnitTest --tests '*LinksChannelHandlerTest*'` | 6/6 |
| `flutter clean && flutter pub get && tool/check_release_build.sh` | OK (uscita 0) |

Gli E2E non sono stati ripetuti: il cambiamento tocca solo il dialogo di ripiego del feedback, che gli E2E non percorrono; girano comunque in CI al push.

---

# Risultati di build e test — tentativo 2 (2026-11-19, dopo il Loop-back 1)

## Build

| Comando | Esito |
|---|---|
| `dart format --output=none --set-exit-if-changed .` | OK, 598 file, 0 cambiati |
| `flutter analyze --fatal-infos` | OK, "No issues found!" |
| `flutter clean && flutter pub get && tool/check_release_build.sh` | OK (uscita 0) |

## Test

| Comando | Totale | Superati | Saltati | Falliti |
|---|---|---|---|---|
| `flutter test --coverage` (suite completa, con i 10 test nuovi del loop-back) | 5190 | 5187 | 3 | 0 |
| `tool/e2e_force_stop.sh` (emulatore riavviato) | — | passo 1 (`force_stop_queue.dart`): "All tests passed" | — | passo 4 non eseguibile: `INSTALL_FAILED_INSUFFICIENT_STORAGE` (AVD locale con ~700 MB liberi, APK di debug 263 MB) |

Il proprietario ha scelto di lasciare la verifica completa di `e2e_force_stop` al job `e2e` di GitHub Actions su emulatore pulito (decisione 6e6ccd8e). Gli E2E `integration_test`, `e2e_freemium` e `check_release_launch` del tentativo 1 non toccano il codice cambiato dal loop-back (solo giro guidato e richiesta di recensione, entrambi spenti con `E2E=true`) e non sono stati ripetuti.

## Copertura (`tool/check_coverage.sh 80`)

- Progetto: **97,40%** (40653/41739), minimo 80%.
- `lib/catalog/` 99,21%, `lib/dashboard/` 98,82%, `lib/sharing/` 98,48%, `lib/cellar/` 94,77%, `lib/label/` 96,99%, `lib/account/` 97,49%.

## Prova sul telefono (OnePlus CPH2581, build di debug collegata a produzione)

- Il giro guidato parte da solo al primo avvio e il riquadro del passo "Aggiungi" è centrato sul pulsante (confermato dal proprietario e da screenshot del 2026-11-19).
- "Rivedi la guida" riavvia il giro con il riquadro centrato.

---

# Risultati di build e test — tentativo 1 (2026-11-19)

## Build

| Comando | Esito |
|---|---|
| `flutter clean && flutter pub get && flutter gen-l10n` | OK |
| `dart format --output=none --set-exit-if-changed .` | OK, nessun file cambiato |
| `flutter analyze --fatal-infos` | OK, "No issues found!" |
| `node tool/check_publication.mjs --draft` | OK, "Publication files OK" (note di rilascio 179–228/500) |
| `tool/check_release_build.sh` (dopo `flutter clean`) | OK: marcatori assenti dalla release, controlli positivi presenti, manifest senza permessi nuovi; `build/check_release/app-release.aab` creato |
| `tool/check_release_launch.sh` (emulatore) | OK, "release build started without crashing" |

## Test

| Comando | Totale | Superati | Saltati | Falliti |
|---|---|---|---|---|
| 14 file di `unit-test-instructions.md` | 217 | 217 | 0 | 0 |
| `flutter test test/cellar test/account test/sharing` | 2329 | 2329 | 0 | 0 |
| `flutter test --coverage` (suite completa) | 5180 | 5177 | 3 | 0 |
| `flutter test --dart-define=ENABLE_DEV_CHEATS=true test/dev/ui` | 12 | 12 | 0 | 0 |
| `packages/estimation`: `dart test --coverage` | 2011 | 2011 | 0 | 0 |
| `./gradlew :app:testDebugUnitTest :app:jacocoLabelReport` | 53 | 53 | 0 | 0 |
| `flutter test integration_test` (emulatore, demo) | 34 | 30 | 3 | 1 |
| `tool/e2e_freemium.sh` | 3 | 3 | 0 | 0 |
| `tool/e2e_force_stop.sh` | — | — | — | non eseguito: memoria dell'emulatore piena, poi due dispositivi collegati |

## Copertura (`tool/check_coverage.sh 80`)

- Progetto (app + `packages/estimation`): **97,40%** (40627/41712), minimo 80%.
- `lib/catalog/` 99,21%, `lib/dashboard/` 98,82%, `lib/sharing/` 98,48%, `lib/cellar/` 94,77%, `lib/label/` 96,99%, `lib/account/` 97,49%: tutte sopra l'80%.

## Errori

- **E2E `cellar_test.dart` "add, duplicate, drink and undo, History, last bottle offline, add again"**: `add-choice-write` non raggiungibile con il tocco (il messaggio "Bevuto" lo copre sullo schermo dell'AVD locale `Medium_Phone_API_36.1`). Fallisce **anche sulla versione committata `375a581`** (verificato in un worktree separato): non è una regressione di questo lavoro; in CI (API 34) lo stesso test passa.
- **Primo giro E2E**: 9 errori dovuti alla densità dell'emulatore forzata a 540 (schermo di 320 dp, pulsante "Scrivi" fuori schermo). Riportata la densità a 420, rieseguito.
- **Prova sul telefono (OnePlus CPH2581, build di debug collegata a produzione)**: nel giro guidato il riquadro del passo "Aggiungi" è spostato in alto a sinistra rispetto al pulsante (screenshot del 2026-11-19 13:35). Il resto (Rivedi la guida, Impostazioni, Feedback, FAQ) funziona.

## Loop-Back Log

### Loop-back 1 — 2026-11-19T12:40:00Z

- **Diagnosis**: `lib/guide/ui/guide_tour.dart` calcola il rettangolo del comando una sola volta per passo (`rectOf` in `build`). All'apertura del giro il pulsante "Aggiungi" (FloatingActionButton) è ancora in movimento, quindi il buco nella velatura resta nella posizione iniziale, spostato rispetto al pulsante. Su richiesta del proprietario (messaggio 453206ce) la correzione comprende anche R-02 e R-04 della revisione di Code Generation.
- **Root-cause stage**: code-generation.
- **Planned fix**: (1) il giro ricalcola il rettangolo a ogni fotogramma con un `Ticker` e ridisegna solo quando cambia; test con un comando che si sposta dopo l'apertura. (2) R-02: `maybeAskForReview` chiede la recensione solo se `markPrompted` restituisce `true`; test con archivio che rifiuta la scrittura. (3) R-04: test che legge `LinksChannelHandler.kt` e confronta `SUPPORT_EMAIL` con `supportEmail`.
- **Estimated impact**: 3 file di codice e 3 di test, circa 30 minuti; nessuna dipendenza nuova, nessun costo, rischio basso (solo interfaccia del giro e richiesta di recensione).

### Loop-back 2 — 2026-11-19T14:55:00Z

- **Diagnosis**: dopo il push di `7830428` il job `analyze` di GitHub Actions fallisce in `tool/check_off_config.sh` (controllo 2: nessun indirizzo email nei file Dart di `lib/`, a protezione del contatto Open Food Facts): `lib/app/store_links.dart:16` contiene `supportEmail = 'bottazzinibruno@gmail.com'`. Il controllo non era tra quelli eseguiti in locale in Build and Test. La release è stata saltata, nulla è arrivato al canale interno.
- **Root-cause stage**: code-generation.
- **Planned fix**: Step 21 del piano: l'indirizzo resta solo in `LinksChannelHandler.kt` e Dart lo legge dal canale (`supportEmail`); test aggiornati; `check_off_config.sh` e tutti i controlli del job `analyze` di `ci.yml` aggiunti alle verifiche locali.
- **Estimated impact**: 4 file di codice e 3–4 di test, circa 20 minuti; nessuna dipendenza nuova, rischio basso (solo il dialogo di ripiego del feedback).

