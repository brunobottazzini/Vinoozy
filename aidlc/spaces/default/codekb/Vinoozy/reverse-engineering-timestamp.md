# Reverse Engineering Timestamp

## Run Record

- Date: 2026-11-18
- Commit: 6f76475a278e6351ce63454b719aeca5a37b0cfd

## Run Notes

- Ampiezza: scansione completa del repository; i nove artefatti sostituiscono per intero quelli precedenti.
- Profondità: Minimal.
- Sola lettura: nessun test, build o programma del progetto è stato eseguito.
- L'area della localizzazione è stata letta file per file. Gli altri moduli sono stati letti a livello di struttura, commenti di testata e ricerche mirate; sono elencati sotto `shallow.paths`.
- Cartelle generate o installate (`build/`, `coverage/`, `.dart_tool/`, `node_modules/`, `functions/lib/`, `.idea/`, `.cache/`, `android/.gradle/`) non sono state aperte.

## Scope of Analysis

```yaml
scope_version: 1
kind: full
intent: wine-culture-languages
fingerprint: b9afe3c0c75b43fb8b2720bbbff5b0f9f06a023c
analyzed:
  paths:
    - ./
  components:
    - App Shell
    - Localization
    - Account
    - Cellar
    - Catalog
    - Label
    - Dashboard
    - Sharing
    - Sync
    - Plan
    - Ads
    - Usage
    - Firebase Bootstrap
    - Dev Tools
    - E2E Hooks
    - Estimation Package
    - Cloud Functions
    - Firestore Rules
    - Android Host
    - Account Deletion Web
    - Store Listing
    - Tooling
    - CI/CD Workflows
    - Test Suites
shallow:
  paths:
    - lib/account/
    - lib/ads/
    - lib/catalog/
    - lib/cellar/data/
    - lib/cellar/ui/
    - lib/dashboard/
    - lib/dev/
    - lib/firebase/
    - lib/label/
    - lib/plan/
    - lib/sharing/
    - lib/sync/
    - lib/usage/
    - packages/estimation/lib/src/
    - packages/estimation/test/
    - functions/src/handlers/
    - functions/src/domain/
    - functions/src/clients/
    - functions/test/
    - android/
    - test/
    - integration_test/
    - integration_test_perf/
    - benchmark/
    - tool/
    - docs/
    - distribution/google-play/
    - assets/
    - firestore.rules
    - firestore.indexes.json
```
