# Reverse Engineering Timestamp

## Run Record

- Date: 2026-11-19
- Commit: 375a581d45c96d9a0a4935e36e025c2d27bb7086

## Run Notes

- Ampiezza: scansione focalizzata (intent `tester-feedback`) su presentazione al primo avvio, profilo, Informazioni, link esterni, condivisione, localizzazione, manifest Android e schede dello store. Unita allo store precedente: la prosa fuori da quest'area è conservata.
- Lo store precedente (scansione completa del 2026-11-18, commit `6f76475`) risultava non aggiornato: la sua copertura profonda (`./`) è stata spostata sotto `shallow.paths`.
- Profondità: Minimal.
- Sola lettura: nessun test, build o programma del progetto è stato eseguito. Il fingerprint comprende le modifiche non committate del working tree.
- Cartelle generate o installate (`build/`, `coverage/`, `.dart_tool/`, `node_modules/`, `android/.gradle/`) non sono state aperte.

## Scope of Analysis

```yaml
scope_version: 1
kind: partial
intent: tester-feedback
fingerprint: ff0d8dbc65487cb7b45feb0635c80667d9ae514a
analyzed:
  paths:
    - lib/app/home_shell.dart
    - lib/app/external_links.dart
    - lib/app/locale_resolution.dart
    - lib/app/ui/about_screen.dart
    - lib/app/ui/brand_footer.dart
    - lib/account/onboarding_flag.dart
    - lib/account/account_providers.dart
    - lib/account/ui/onboarding_screen.dart
    - lib/account/ui/profile_screen.dart
    - lib/account/ui/account_gate_view.dart
    - lib/sharing/ui/share_launcher.dart
    - lib/l10n/app_en.arb
    - l10n.yaml
    - pubspec.yaml
    - android/app/src/main/AndroidManifest.xml
    - android/app/src/main/res/xml/locales_config.xml
    - distribution/google-play/README.md
    - distribution/google-play/languages.json
    - distribution/google-play/release-notes.txt
    - distribution/google-play/it-IT/
    - distribution/google-play/en-US/
  components:
    - App Shell
    - Localization
    - Account
    - Store Listing
shallow:
  paths:
    - ./
    - lib/app/
    - lib/account/
    - lib/sharing/
    - lib/usage/
    - lib/l10n/
    - lib/cellar/ui/cellar_screen.dart
    - lib/ads/
    - lib/catalog/
    - lib/cellar/data/
    - lib/cellar/ui/
    - lib/dashboard/
    - lib/dev/
    - lib/firebase/
    - lib/label/
    - lib/plan/
    - lib/sync/
    - packages/estimation/lib/src/
    - packages/estimation/test/
    - functions/src/handlers/
    - functions/src/domain/
    - functions/src/clients/
    - functions/test/
    - android/
    - android/app/src/main/kotlin/
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
