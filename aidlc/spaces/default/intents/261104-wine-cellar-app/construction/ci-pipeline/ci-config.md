# Configurazione della CI — Vinoozy

Strumento: **GitHub Actions**, piano gratuito, runner `ubuntu-latest`. Rami: trunk-based su `main`, rami brevi con squash merge, tag di versione `v*` (team.md). Tutte le action sono fissate per SHA. Dependabot le aggiorna ogni settimana insieme ai pacchetti Dart e npm.

## Fonti

- `construction/<unità>/code-generation/code-summary.md` (code-summary) delle 8 unità: job e controlli aggiunti da ciascuna.
- `construction/build-and-test/build-and-test-summary.md` (build-and-test-summary): matrice degli obiettivi e prontezza.
- `construction/build-and-test/test-results.md` (build-test-results): comandi eseguiti, emulatore a 1 core, difetto di U4.

## Workflow

| File | Quando parte | Cosa fa | Segreti e ambienti |
|---|---|---|---|
| `.github/workflows/ci.yml` | ogni push, ogni pull request verso `main` | i 7 controlli bloccanti (sotto) | nessun segreto: anche le pull request da fork girano uguali |
| `.github/workflows/release.yml` | quando `ci` finisce **con successo** su un push a `main` | AAB firmato, numero di build da GitHub Actions, pubblicazione sul **canale di test interno** di Google Play; simboli per Crashlytics | ambienti `play-internal` e `crashlytics-symbols`; segreti `ANDROID_UPLOAD_*`, `FIREBASE_PROD_*`, `PLAY_INTERNAL_SA_JSON`; variabili `WIF_PROVIDER`, `CRASHLYTICS_WIF_SERVICE_ACCOUNT`, `FIREBASE_ANDROID_APP_ID`, `GOOGLE_SERVER_CLIENT_ID` |
| `.github/workflows/promote.yml` | a mano | promozione in **produzione** con rilascio graduale, tag `v*` | ambiente `play-production` con la **tua approvazione**; segreto `PLAY_PRODUCTION_SA_JSON` |
| `.github/workflows/firebase-deploy.yml` | a mano | regole e indici di Firestore sul progetto reale, solo da un commit di `main` | ambiente `firebase-prod` con la tua approvazione; identità federata (`WIF_*`), nessuna chiave |
| `.github/workflows/pages.yml` | a mano | pubblica o riporta indietro la pagina di cancellazione dell'account su GitHub Pages, dopo aver controllato che le regole pubblicate siano quelle del commit | ambiente `github-pages-publish` con la tua approvazione |
| `.github/dependabot.yml` | ogni settimana | aggiornamenti di action, `pub` (radice e **`packages/estimation`**, aggiunto in questa fase), `npm` | — |

Ordine di un rilascio: merge in `main` con `ci` verde → `release.yml` (test interno) → prova sul telefono → `firebase-deploy.yml` se cambiano le regole → `pages.yml` se cambia la pagina → `promote.yml`.

## Job di `ci.yml`

| Job | Timeout | Passi principali |
|---|---|---|
| `format` | 10 min | `flutter pub get`, `dart format --output=none --set-exit-if-changed .` |
| `secrets` (**nuovo**) | 10 min | checkout con tutta la storia; gitleaks 8.30.1 scaricato dal rilascio ufficiale e verificato con SHA-256; `gitleaks git --redact --exit-code 1 .` |
| `analyze` | 10 min | `flutter gen-l10n`, `flutter analyze --fatal-infos`, `tool/check_off_config.sh`, `check_dashboard_readonly.sh` (+ test), `check_rule_ids.sh` per U4, U6 e U8 (+ test), `check_label_imports.sh` (+ test), `npm ci`, `check_web_pins.sh` (+ test), `check_web_config_test.sh`, nessuna configurazione di produzione o keystore nel repository |
| `unit` | 15 min | `gen_coverage_helper.dart`, `flutter test --coverage`, copertura del pacchetto di stima, copertura unita ≥ 80%, copertura ≥ 80% di `lib/catalog/`, `lib/dashboard/`, `lib/sharing/`, `lib/cellar/`, `lib/label/`, `lib/account/`; benchmark di catalogo, Dashboard e Cantina; test nativi Robolectric + JaCoCo 80%; `tool/check_release_build.sh` |
| `estimation` | 10 min | in `packages/estimation`: format, `dart analyze --fatal-infos`, `check_estimation_purity.sh`, `dart test --coverage`, copertura ≥ 90%, benchmark |
| `rules` | 15 min | Java 21, Node da `.nvmrc`, `npm ci`, `npm run test:rules`, Chromium di Playwright, `npm run test:web`, `check_firestore_indexes.sh` (+ test) |
| `e2e` | 45 min | KVM, Flutter, `npm ci`, emulatori Firebase (Auth + Firestore, `demo-vinoozy`), emulatore Android API 34 x86_64 **con 4 core e 4 GB** (cambiato in questa fase), `flutter test integration_test --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true`, `tool/e2e_force_stop.sh`; un solo nuovo tentativo **solo se l'emulatore non si è avviato**, mai per un test fallito |

`concurrency`: sui rami di lavoro una corsa nuova annulla la precedente; su `main` ogni corsa arriva in fondo, così `release.yml` non salta nessun merge.

## Cambiamenti di questa fase

1. `ci.yml`, job `e2e`: `cores: 4` e `ram-size: 4096M` in entrambi i passi `reactivecircus/android-emulator-runner` (Q1).
2. `ci.yml`: nuovo job `secrets` con gitleaks (Q3); commento di testa aggiornato a 7 controlli.
3. `dependabot.yml`: `pub` per `/packages/estimation` (Q4).
4. `docs/firebase-setup.md`: i controlli richiesti dal ruleset di `main` diventano i 7 job (prima ne elencava 5, mancavano `estimation` e il nuovo `secrets`).

Il job `e2e` resta bloccante senza riprove sui test (Q2). Finché U4 NFR6.6 non è corretto, `cellar_test.dart` fallirà spesso e fermerà i merge. La correzione è il primo lavoro dopo la prima versione.

## Costi

- Repository **pubblico**: minuti illimitati sui runner standard.
- Finché è privato, 2.000 minuti al mese. Una corsa completa di `ci.yml` usa circa 25–40 minuti di runner, soprattutto per `e2e` (stima da verificare alla prima corsa), quindi circa 50–80 push al mese.
- Costo: 0 €.

## Da fare a mano (proprietario)

- Ruleset su `main` con i 7 controlli richiesti (`docs/firebase-setup.md`).
- Segreti e variabili sopra, negli ambienti indicati, con te come revisore richiesto per `play-production`, `firebase-prod` e `github-pages-publish`.
- Prima di rendere pubblico il repository: gitleaks su tutta la storia (`docs/firebase-setup.md`). Non ho potuto eseguirlo io in questa fase: lo scaricamento ed esecuzione locale non era consentito. La prima corsa del job `secrets` lo farà comunque.
- Prima corsa reale della CI: niente è stato ancora inviato a GitHub. I workflow sono verificati come YAML validi, ma non sono mai stati eseguiti su GitHub.
