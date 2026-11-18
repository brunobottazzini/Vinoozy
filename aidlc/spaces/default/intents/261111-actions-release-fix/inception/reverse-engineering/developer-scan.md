# Scansione del codice (sviluppatore)

## Developer Code Scan Results

Scansione completa del repository `Vinoozy` al commit
`abe4fc0ebfd37dc2dc61ab1b415ba34471fc3a96` (albero di lavoro con modifiche
del proprietario solo in documenti e distribuzione: `docs/`,
`distribution/google-play/`). Eseguita in questa conversazione, senza
avviare test, build o programmi.

### Scan Coverage

- **Analizzati a fondo** (lettura riga per riga): `.github/workflows/release.yml`,
  `.github/workflows/promote.yml`, il job `e2e` di `.github/workflows/ci.yml`,
  `tool/play_api.sh`, `lib/sharing/sharing_providers.dart`
  (`accessibleCellarsProvider`, `ActiveCellarNotifier`),
  `lib/sharing/ui/cellar_switcher.dart`, `lib/cellar/ui/cellar_screen.dart`
  (metodo `build`), `integration_test/u1_skeleton_test.dart` (test 8 e 10),
  `functions/src/index.ts`, `functions/package.json`, `package.json`
  (script di test), `docs/github-actions-handoff.md`.
- **Passaggio strutturale** (dichiarazioni, firme, confini): `lib/plan/`,
  `lib/usage/`, `lib/ads/`, `lib/dev/`, `lib/firebase/`, `lib/sync/`,
  `functions/src/`, gli altri job di `ci.yml`, `firebase-deploy.yml`,
  `functions-deploy.yml`, `pages.yml`, `firestore.rules` (percorsi),
  `pubspec.yaml`, `tool/` (elenco degli script e delle fixture).
- **Ripresi dalla mappa precedente dopo verifica degli invarianti**
  (struttura a moduli, repository, ledger, stima): `lib/account/`,
  `lib/cellar/`, `lib/dashboard/`, `lib/label/`, `lib/catalog/`,
  `packages/estimation/`, `android/`, `docs/account-deletion/`.
- **Lasciati fuori senza aprirli**: `build/`, `.dart_tool/`, `coverage/`,
  `node_modules/`, `functions/node_modules/`, `functions/lib/`,
  `tool/admin/node_modules/`, `.idea/`, `android/.gradle/`, binari e immagini,
  `assets/wine_db/wines.jsonl.gz`, `docs/account-deletion/app.bundle.js`,
  l'installazione AI-DLC (`.claude/`, `aidlc/`).

### Packages Found

- App Flutter `lib/` (242 file Dart): moduli `account`, `ads`, `app`,
  `catalog`, `cellar`, `core`, `dashboard`, `dev`, `e2e`, `firebase`,
  `label`, `l10n`, `plan`, `sharing`, `sync`, `usage`.
- `packages/estimation/`: libreria Dart pura di stima.
- `functions/`: Cloud Functions TypeScript (2ª gen., `europe-west8`).
- `tool/admin/`: script Node del proprietario (`grant_plus`, `set_policy`,
  `migrate_capacity`).
- `android/`: progetto Gradle con Kotlin nativo.

### Build System

Flutter 3.47.9 (`.flutter-version`), Gradle Kotlin DSL, npm (radice,
`functions/`, `tool/admin/`), `tsc` per le Functions.

### APIs Discovered

Nessuna API HTTP propria lato app; callable Firebase (`verifyPurchase`,
`reportUsage`, `reserveAdSlot`, `recordAdOutcome`), funzioni Pub/Sub e
pianificate; Play Developer API usata da `tool/play_api.sh`.

### Frameworks & Libraries

Riverpod 3, Firebase (Auth, Firestore, App Check, Crashlytics, Functions),
`in_app_purchase`, `google_mobile_ads`, ML Kit; lato Node `firebase-functions`
7.4.0, `firebase-admin` 13.10.0, `googleapis`.

### Test Coverage

215 file in `test/`, 18 in `integration_test/`, test Mocha delle Functions,
test Node delle regole, degli script admin e della pagina web. Gli script di
`tool/` hanno i propri `*_test.sh` con fixture in `tool/fixtures/`, ma
**`tool/play_api.sh` non ne ha**.

### Code Quality Indicators

Gate di CI estesi (format, actionlint, gitleaks, analyze, copertura 80%,
E2E). Commenti tracciati agli ID dei requisiti.

### Technical Debt Signals

- `release.yml` scrive i file dei segreti senza verificare che i segreti
  esistano: con segreti mancanti crea file vuoti e fallisce più avanti.
- `tool/play_api.sh` scarta stdout e stderr di `gcloud auth
  activate-service-account`: un'autenticazione fallita esce con codice 1
  senza messaggio.
- `ActiveCellarNotifier.build` registra `ref.listen` su provider che
  possono notificare in modo sincrono e `_refresh` assegna `state`
  direttamente: percorso coerente con l'eccezione "setState() called during
  build" della CI 15.

## Handoff Summary

La mappa completa è nei nove documenti della cartella di staging. Le aree di
questo lavoro sono descritte in `component-inventory.md` (ReleaseWorkflow,
PlayApiScript, ActiveCellarNotifier, CellarSwitcher, E2E suite) e in
`code-quality-assessment.md` (debito tecnico 1-4).
