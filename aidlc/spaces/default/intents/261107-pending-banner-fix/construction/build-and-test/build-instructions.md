# Istruzioni di build — pending-banner-fix

La correzione non cambia la build: valgono le istruzioni della prima versione (`aidlc/spaces/default/intents/261104-wine-cellar-app/construction/build-and-test/build-instructions.md`). Le stesse versioni:
- Flutter 3.47.9 (`.flutter-version`);
- Node 22;
- Java 17;
- Firebase Emulator Suite su `demo-vinoozy`;
- un emulatore Android con **4 core e 4 GB**, come nel job `e2e` di `ci.yml`.

## Fonti

- `construction/code-generation/code-generation-plan.md` (code-generation-plan): passi 6 e 7, cioè suite, copertura ed end-to-end.
- `construction/code-generation/unit-test-instructions.md` (unit-test-instructions): comandi di unità della correzione.
- `construction/code-generation/code-summary.md` (code-summary): file cambiati.

## Comandi

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test --coverage
(cd packages/estimation && dart test --coverage=coverage && dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib)
cat coverage/lcov.info packages/estimation/coverage/lcov.info > coverage/merged.lcov.info && tool/check_coverage.sh 80 coverage/merged.lcov.info
tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/
```

## Verifica

- Nessuna dipendenza, regola Firestore, indice o workflow cambiato (NFR3). Cambiano solo `lib/cellar/data/pending_writes_probe.dart`, una riga di `lib/cellar/data/drinking_record_repository.dart` e i loro test.
- Formattazione e analisi pulite.
