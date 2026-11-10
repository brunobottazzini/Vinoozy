# Reverse Engineering Timestamp

## Run Record

- Date: 2026-11-10
- Commit: ee114e34ecdb2ec0dff873d20ad23d0004996947
- Tipo di scansione: completa (`./`), richiesta per l'intent `261110-freemium-plus` (scope express, profondità Minimal); sostituisce interamente il negozio precedente.
- Albero di lavoro: con molte modifiche non committate rispetto al commit (36 file modificati, tra cui workflow CI, `lib/account/ui/profile_screen.dart`, `lib/account/account_providers.dart`, `lib/cellar/cellar_providers.dart`, `MainActivity.kt`, l10n e test; file nuovi come `lib/app/external_links.dart`, `docs/privacy/`, `distribution/`, `tool/check_publication.mjs`). Gli artefatti descrivono i file come sono su disco.
- Profondità: lettura riga per riga delle superfici dell'intent (configurazione, avvio, account, profilo, Informazioni, repository dei vini e delle bevute, sync, condivisione, Dashboard, regole, controllo di rilascio, CI); passaggio strutturale (dichiarazioni, firme, confini) sul resto del codice scritto a mano. Nessun test, build o programma eseguito.
- Lasciati fuori senza aprirli: `build/`, `.dart_tool/`, `coverage/`, `node_modules/`, `.idea/`, `.cache/`, `android/.gradle/`, binari e immagini, `assets/wine_db/wines.jsonl.gz`, `firestore-debug.log`, `docs/account-deletion/app.bundle.js`, l'installazione AI-DLC.

## Scope of Analysis

```yaml
scope_version: 1
kind: full
intent: 261110-freemium-plus
fingerprint: 4c1a19544e93ad44a6724c590177e7950c678796
analyzed:
  paths:
    - ./
  components:
    - AppBootstrap
    - FirebaseEnvConfig
    - FirestoreBootstrap
    - ErrorReporter
    - AccountGate
    - AuthService
    - UserRepository
    - AccountDeletionRunner
    - ProfileScreen
    - HomeShell
    - AboutScreen
    - BrandFooter
    - CellarRepository
    - WineRepository
    - DrinkingRecordRepository
    - readServerOrCache
    - CellarActions
    - CellarMaintenance
    - RecordReconciler
    - QuantityDelta
    - CellarScreen
    - LocalLedger
    - SyncWatcher
    - FirestoreSyncGateway
    - SyncErrorBus
    - SharingRepository
    - InviteValidator
    - AccessibleCellar
    - DashboardScreen
    - DashboardCalculator
    - LabelSessionController
    - WineCatalog
    - estimation
    - AppLocalizations
    - MainActivity
    - firestore.rules
    - check_release_build.sh
    - CI workflows
    - AccountDeletionWebPage
shallow:
  paths:
    - lib/label/
    - lib/catalog/
    - lib/l10n/
    - packages/estimation/lib/src/
    - packages/estimation/test/
    - test/
    - integration_test/
    - integration_test_perf/
    - benchmark/
    - tool/fixtures/
    - tool/data/
    - android/app/src/main/res/
    - docs/
    - distribution/
```
