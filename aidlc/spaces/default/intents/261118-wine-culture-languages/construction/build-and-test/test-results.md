# Risultati di Build and Test — Lingue dei paesi del vino

Data: 2026-11-18. Macchina: Mac del proprietario (Flutter 3.47.9). Comandi uguali al job `unit` di `.github/workflows/ci.yml`.

## Build

| Comando | Esito |
|---|---|
| `flutter pub get`, `dart run tool/gen_coverage_helper.dart` (267 file), `dart run tool/gen_l10n_exercise.dart` (670 messaggi, 745 chiamate per lingua) | Riuscito |
| `dart format --output=none --set-exit-if-changed .` | 572 file, 0 cambiati |
| `flutter analyze --fatal-infos` | Nessun problema |
| `tool/check_release_build.sh` | Riuscito: build di rilascio, controlli del manifest, build E2E e profile di controllo; 369 s |
| Manifest unito della build di rilascio | Contiene `android:localeConfig="@xml/locales_config"`; `locales_config.xml` con 25 lingue nelle risorse impacchettate |
| `flutter build apk --debug` (configurazione Firebase reale, per il telefono) | Riuscito |

## Test

| Comando | Esito |
|---|---|
| `flutter test --coverage` (intera suite) | 4990 superati, 3 saltati (già prima di questo lavoro), 0 falliti; 224 s |
| `flutter test --dart-define=ENABLE_DEV_CHEATS=true test/dev/ui` | 12 superati |
| `dart test --coverage=coverage` in `packages/estimation` | 2011 superati |
| `cd android && ./gradlew :app:testDebugUnitTest :app:jacocoLabelReport` | Uscita 0 (soglia JaCoCo 80% rispettata) |
| `dart run benchmark/catalog_benchmark.dart`, `dashboard_benchmark.dart`, `cellar_benchmark.dart` | Tutte le misure entro le soglie (es. Dashboard 2,9 ms su 10 ms) |
| `node tool/check_publication.mjs --draft` | 25 cartelle e 25 blocchi di note di rilascio entro i limiti |
| Comandi di `unit-test-instructions.md` | Compresi nella suite completa (eseguita una volta, non ripetuta) |

## Copertura (soglia 80%, nessuna esclusione, codice generato compreso)

| Ambito | Copertura | Comando |
|---|---|---|
| Progetto (app + pacchetto di stima) | **97,29%** (38.882/39.964 righe) | `tool/check_coverage.sh 80 coverage/merged.lcov.info`, uscita 0 |
| `lib/catalog/` | 99,21% | `tool/check_coverage.sh 80 coverage/lcov.info lib/catalog/` |
| `lib/dashboard/` | 98,82% | idem con `lib/dashboard/` |
| `lib/sharing/` | 98,48% | idem con `lib/sharing/` |
| `lib/cellar/` | 94,75% | idem con `lib/cellar/` |
| `lib/label/` | 96,99% | idem con `lib/label/` |
| `lib/account/` | 97,49% | idem con `lib/account/` |
| `lib/l10n/` (traduzioni generate) | 100,00% (21.397/21.398) | idem con `lib/l10n/` |
| `packages/estimation` (soglia 90%) | 98,10% | `../../tool/check_coverage.sh 90 coverage/lcov.info` |

Rapporto: `coverage/lcov.info`, `coverage/merged.lcov.info` (non versionati).

## Test end-to-end (emulatore Android locale + Firebase Emulator Suite)

Eseguiti su emulatore `Medium_Phone_API_36.1` (Android 16), diverso dall'emulatore della CI (API 34, x86_64, 4 core).

| Codice | Superati | Falliti | Saltati |
|---|---|---|---|
| Questo lavoro | 17 | 14 | 3 |
| Codice di prima (`6f76475`, copia separata) | 15 | 16 | 3 |

- Ogni test fallito con questo lavoro fallisce anche sul codice di prima. Questo lavoro non introduce errori end-to-end; due test che fallivano prima (`concurrent_drink_test`, cancellazione dell'account) qui sono passati.
- Causa comune osservata: su questo emulatore il tocco su "Scrivi a mano" (`add-choice-write`) non apre il modulo, e i test che lavorano senza rete scadono. Sono problemi dell'ambiente locale: l'ultima CI su `6f76475` ha superato il job `e2e`.
- Verdetto: **non verificato** finché i test end-to-end non girano in GitHub Actions su questo codice.

## Prova sul telefono del proprietario (OnePlus CPH2581, Android 16)

Build di prova installata dopo la disinstallazione della versione Google Play, con il consenso del proprietario.

- Lingua cambiata con il sistema per-app di Android (`cmd locale set-app-locales`, lo stesso delle impostazioni): francese, greco, georgiano e ucraino mostrati subito, senza riavvio. Nomi di regione tradotti (Τοσκάνη, ტოსკანა), date locali (έως: Νοε 2029), plurali ucraini corretti (6 пляшок). Nessun testo fuori dai margini.
- Impostazioni di Android → Lingue dell'app → Vinoozy: l'elenco mostra **23 voci invece di 25**.
  - **Manca il serbo** (`sr` dichiarato, "Српски" non compare).
  - **Un solo "Português"**: `pt-BR` e `pt` sono fusi in una voce senza paese.
  - Le altre 22 lingue sono presenti.
- Verdetto FR2.2: **non raggiunto**.

## Failure Details

1. **FR2.2, elenco delle lingue nelle impostazioni di Android** — causa in `android/app/src/main/res/xml/locales_config.xml` (codice di Code Generation): `sr` senza scrittura e `pt` senza paese non sono mostrati da Android come voci distinte. Correzione candidata: dichiarare `pt-BR` e `pt-PT` e il serbo con scrittura esplicita (`sr-Cyrl` / `b+sr+Cyrl`), allineare `appLocales` e il test di coerenza, poi riprovare sul telefono.
2. **Test end-to-end** — non verificati in un ambiente equivalente alla CI (vedi sopra); nessuna regressione rispetto al codice di prima.
3. **NFR2, durata del job `unit` in CI (limite 40 minuti)** — non misurabile in locale. Ultima CI (`6f76475`): job `unit` 22 min 41 s, di cui `flutter test --coverage` 6 min 4 s. La prova completa delle schermate passa da 12 a 40 esecuzioni per schermata: stima del job tra 28 e 35 minuti, entro il limite ma da misurare alla prima esecuzione in GitHub Actions.

## Loop-Back Log

### Loop-back 1 — 2026-11-18T13:44:57Z

- **Diagnosis**: nelle impostazioni di Android (Lingue dell'app) Vinoozy mostra 23 voci su 25. Il serbo (`sr`) non compare; `pt-BR` e `pt` sono fusi in un solo "Português" senza paese. Verificato sul telefono del proprietario (CPH2581, Android 16).
- **Root-cause stage**: code-generation (`android/app/src/main/res/xml/locales_config.xml` e l'elenco `appLocales`).
- **Planned fix**: dichiarare `pt-BR` e `pt-PT` come voci distinte e il serbo con scrittura cirillica esplicita; allineare `appLocales`, la risoluzione della lingua (un `pt-PT` e un `sr-Cyrl` scelti dalle impostazioni devono dare il portoghese europeo e il serbo), `test/app/language_consistency_test.dart` e i test di risoluzione; rifare i controlli e riprovare l'elenco sul telefono.
- **Estimated impact**: sforzo basso (un file di configurazione, un elenco, due test); costo zero; rischio basso. Incertezza: il serbo potrebbe restare nascosto se il sistema del telefono non lo supporta.
- **Authorized by**: scelta "Retry with fix" del proprietario (messaggio b5f90143).

## Riesecuzione dopo il Loop-back 1 (2026-11-18)

- Code Generation passo 23: `locales_config.xml` dichiara `pt-BR`, `pt-PT`, `sr-Cyrl`; mappa `androidLocaleTagOf` con test. Suite completa: 4998 superati, 3 saltati, 0 falliti (168 s); `tool/check_release_build.sh` uscita 0; `flutter analyze` e `dart format` puliti.
- Pacchetto installato sul telefono: `aapt2 dump xmltree` conferma `pt-BR`, `pt-PT`, `sr-Cyrl` nel `locales_config.xml`.
- API per-app di Android: `cmd locale set-app-locales --locales pt-PT` e `--locales sr-Cyrl` vengono accettati e l'app li applica.
- Menu Impostazioni → Lingue dell'app del telefono (OxygenOS `CPH2581_16.0.10.601(EX01)`): ancora 23 voci, un solo "Português" e nessun serbo.
  - Scegliendo "Português" il menu imposta `pt-IT` (lingua più regione del telefono): il menu di OxygenOS mostra una voce per lingua e aggiunge la regione del sistema. Con `pt-IT` l'app mostra il portoghese europeo; un telefono con regione Brasile otterrebbe `pt-BR` e il brasiliano.
  - Il sistema supporta `sr-Cyrl-RS` (risorse `supported_locales` del firmware), ma il menu non mostra il serbo né con `sr-Cyrl` né, in una prova, con `sr-Cyrl-RS`. La prova è stata annullata e il file è tornato a `sr-Cyrl`.
- **Decisione del proprietario (messaggio a98e4e44): "Accept failure".** Il limite del menu di OxygenOS (FR2.2) e i controlli da confermare in GitHub Actions (end-to-end, durata del job `unit`) sono accettati e registrati qui.
- Conclusione: l'app dichiara correttamente le 25 lingue secondo la documentazione Android, e Android le applica. Le due voci mancanti dipendono dal menu di OxygenOS: in questo lavoro non esiste una correzione lato app. Su questo telefono il serbo resta raggiungibile impostando il telefono in serbo, oppure con l'API per-app.
