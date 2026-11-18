# Istruzioni dei test di questo lavoro

## Strumenti

| Area | Strumento | Configurazione |
|---|---|---|
| Script bash | bash 3.2+ (macOS) / 5 (runner), `jq`, `base64` | test autonomi sullo schema di `tool/check_*_test.sh`; nessuna rete |
| Workflow | `actionlint` (solo locale, `brew install actionlint`; in CI lo scarica il job `format`) | stesse opzioni della CI: `-shellcheck= -pyflakes=` |
| App | `flutter test` (Flutter 3.47.9), `flutter_riverpod` | `analysis_options.yaml`; nessuna configurazione nuova |
| E2E | `integration_test` su emulatore Android + Firebase Emulator Suite (`demo-vinoozy`) | come il job `e2e` di `.github/workflows/ci.yml` |

## Comandi, solo per questo lavoro

Dalla radice del repository:

```bash
# Strato 1: script di consegna
bash tool/check_release_inputs_test.sh
bash tool/play_api_test.sh

# Strato 2: workflow
actionlint -shellcheck= -pyflakes= .github/workflows/release.yml .github/workflows/promote.yml .github/workflows/ci.yml

# Strato 3: app (regressione e provider di condivisione)
flutter test test/sharing/active_cellar_build_test.dart
flutter test test/sharing/
```

E2E sul Mac (Step 9 e 12), con gli emulatori avviati come nel job `e2e`:

```bash
npm --prefix functions run build
npx firebase emulators:start --only auth,firestore,functions --project demo-vinoozy
# in un altro terminale, con l'emulatore Android acceso:
flutter test integration_test/u1_skeleton_test.dart --plain-name "8. after a restart" --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true
flutter test integration_test --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true
```

## Test previsti (strategia Minimal: uno per requisito)

| Test | Requisiti |
|---|---|
| `tool/check_release_inputs_test.sh`: valido; due segreti mancanti elencati insieme; variabile mancante; Base64 non valido; vuoto dopo la decodifica; JSON non valido; `type` sbagliato; package diverso; define mancante; profilo production valido e mancante; nessun valore delle fixture nell'output | FR1.1, FR1.2, FR1.3, FR1.4, FR3.2, FR3.3, FR4.1, NFR1 |
| `tool/play_api_test.sh`: variabile assente; file assente; file vuoto; JSON non valido; tipo sbagliato; autenticazione fallita; token fallito; API HTTP 403; riuscita con stdout uguale a `42`; frazione non valida | FR2.1, FR2.2, FR2.3, FR2.4, FR3.1, FR3.3, NFR1 |
| `actionlint` sui tre workflow | NFR2, FR1.5, FR4.2 |
| `test/sharing/active_cellar_build_test.dart`: cambio degli inviti durante la build senza eccezione; la cantina attiva arriva comunque al valore nuovo | FR7.2, FR7.3 |
| Test 8 E2E ripetuto 10 volte + suite completa | FR7.1, FR7.4 |

## Copertura

La soglia del progetto (80% delle righe, totale senza esclusioni e per
cartella su `lib/sharing/`) la misura Build and Test sull'intera suite con
`flutter test --coverage` e `tool/check_coverage.sh`. I comandi sopra, limitati
a questo lavoro, non la giudicano. Gli script bash non rientrano nella
copertura Dart.

## Stub e dati di test

- `tool/fixtures/play_api/bin/gcloud` e `curl`: script finti che leggono
  variabili d'ambiente (`FAKE_GCLOUD_AUTH`, `FAKE_GCLOUD_TOKEN`,
  `FAKE_CURL_STATUS`, `FAKE_CURL_BODY`) e non fanno mai chiamate di rete; il
  test li mette in testa al `PATH`.
- `tool/fixtures/release_inputs/`: account di servizio, `google-services.json`
  e defines **finti**, con valori riconoscibili (`FAKE`, `fake-project`); il
  test genera il Base64 al volo.
- Nessuna credenziale reale, nessun accesso a `config/firebase_prod.json`.
- Test di widget: `ProviderScope` con override di `myMembershipsProvider`
  (stream comandato dal test) e di `sharingPreferencesProvider` (preferenze
  in memoria), come gli altri test di `test/sharing/`.
