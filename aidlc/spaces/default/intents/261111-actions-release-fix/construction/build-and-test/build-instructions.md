# Istruzioni di build

## Prerequisiti

| Strumento | Versione | Note |
|---|---|---|
| Flutter | 3.47.9 (`.flutter-version`) | Dart `^3.13.7` |
| JDK | 17 | build Android |
| Node.js | 22 (`.nvmrc`) | emulatori Firebase e test Node |
| bash, `jq`, `base64` | bash 3.2+ / 5 | script di `tool/` |
| `actionlint` | 1.7.12 | solo per il controllo locale dei workflow (`brew install actionlint`); in CI lo scarica il job `format` |

Nessuna variabile d'ambiente né file di configurazione di produzione servono
per build e test: senza `FIREBASE_ENV=prod` l'app usa il progetto demo
`demo-vinoozy`. `config/firebase_prod.json` e `android/app/google-services.json`
restano ignorati da git.

## Installazione delle dipendenze

```bash
flutter pub get
(cd packages/estimation && dart pub get)
npm ci
```

## Build

```bash
flutter gen-l10n
flutter analyze --fatal-infos
dart format --output=none --set-exit-if-changed .
flutter build apk --debug --dart-define=FIREBASE_ENV=demo
```

Build firmata di produzione: solo in `release.yml` (job `internal`), dopo lo
step `Check the play-internal configuration`.

## Verifica della build

- `✓ Built build/app/outputs/flutter-apk/app-debug.apk`, uscita 0.
- `flutter analyze`: "No issues found!".

## Problemi comuni

| Sintomo | Causa | Rimedio |
|---|---|---|
| `tool/check_release_inputs.sh` elenca segreti mancanti in CI | segreti non configurati nell'ambiente | `docs/github-actions-setup.md` §1-§2 |
| `play_api: ... exit 3/4/5` | chiave assente o non valida / autenticazione / Play API | il messaggio su stderr nomina il caso; vedi la guida §3 |
| `actionlint: command not found` sul Mac | non installato | `brew install actionlint` |
