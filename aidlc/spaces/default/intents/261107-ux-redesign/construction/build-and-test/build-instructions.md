# Istruzioni di build — nuova UX

## Fonti

- `construction/code-generation/code-generation-plan.md` (code-generation-plan) e `unit-test-instructions.md` (unit-test-instructions).
- `construction/code-generation/code-summary.md` (code-summary).
- Le istruzioni della prima versione: `aidlc/spaces/default/intents/261104-wine-cellar-app/construction/build-and-test/build-instructions.md`, che restano valide.

## Cosa cambia per la build

- **Nessuna dipendenza nuova:** `pubspec.yaml` invariato. I titoli usano il serif di sistema e le bandiere sono emoji.
- **Testi:** dopo ogni modifica agli ARB si esegue `flutter gen-l10n`.
- **Copertura:** si rigenera `test/coverage_helper_test.dart` con `dart run tool/gen_coverage_helper.dart`, come in CI.
- **Regole di Firestore:**
  - `firestore.rules` accetta il nuovo campo `country` e il voto alla creazione della bevuta;
  - `promote.yml` richiede la funzione `origin` delle regole pubblicate;
  - **prima** di installare la build sul telefono, le regole vanno pubblicate su `vinoozy-d6f45` con il via del proprietario.
- **Test delle regole:** `npm run test:rules` e `npm run test:web` avviano da soli i loro emulatori. Richiedono che le porte 8080 e 9099 siano libere, quindi nessun `firebase emulators:start` acceso.

## Comandi

Stessi comandi di `ci.yml`:

```bash
flutter pub get && flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
dart run tool/gen_coverage_helper.dart && flutter test --coverage
npm run test:rules && npm run test:web
tool/check_release_build.sh
```
