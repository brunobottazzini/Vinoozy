# Risultati dei test — Freemium e Plus

Data: 2026-11-10T13:14:55Z. Tutti i comandi sono stati eseguiti di nuovo in questa fase sull'albero di lavoro attuale. Strategia Minimal, Testing Contract test-after.

## Build

| Comando | Esito |
|---|---|
| `dart format --output=none --set-exit-if-changed .` | 534 file, 0 cambiati (exit 0) |
| `flutter analyze --fatal-infos` | Nessun problema |
| `npm --prefix functions run build` | Pulito (incluso in `test:functions`) |

## Test

| Comando | Totale | Passati | Falliti | Saltati |
|---|---:|---:|---:|---:|
| `flutter test --coverage` (suite completa, exit 0) | 2878 | 2875 | 0 | 3 |
| `flutter test --dart-define=ENABLE_DEV_CHEATS=true test/dev/ui` | 12 | 12 | 0 | 0 |
| `dart test --coverage=coverage` in `packages/estimation` | 2011 | 2011 | 0 | 0 |
| `npm run test:rules` | 287 | 285 | 0 | 2 |
| `npm run test:functions` | 70 | 70 | 0 | 0 |
| `npm run test:admin` | 13 | 13 | 0 | 0 |
| `firebase emulators:exec --only auth,firestore,functions --project demo-vinoozy "tool/e2e_freemium.sh"`, su AVD `Medium_Phone_API_36.1` | 3 | 3 | 0 | 0 |

- **Test saltati nella suite Flutter (3).** Sono i test della sequenza segreta nella `HomeShell`. Esistono solo con `ENABLE_DEV_CHEATS=true` e girano nella riga dedicata, che è verde.
- **Test saltati nelle regole (2).** Sono saltati per scelta del test stesso, come nella base.
- **End-to-end di freemium.** Durante l'esecuzione la scala dei caratteri dell'AVD è stata portata da 2.0 a 1.0 e poi rimessa a 2.0. L'esecuzione ha controllato:
  - il regalo scritto da `grant_plus.mjs` e applicato senza azioni dell'utente;
  - il limite a 15 schede, con la sedicesima scheda sbloccata dal pannello sviluppatore;
  - la chiamata a `reportUsage` attraverso l'emulatore delle funzioni.
- **Suite E2E completa non rieseguita** (`flutter test integration_test`, circa 30 minuti). Questo lavoro tocca le schermate e i repository usati da quei test. In CI la suite gira nel job `e2e` già esistente, ma in questo piano non è prevista una fase CI Pipeline.

## Copertura

Il comando è lo stesso della CI: `format_coverage` e merge con `packages/estimation`, poi `tool/check_coverage.sh`. Il fornitore è il `coverage` di Dart; non c'è nessun pragma di esclusione.

| Ambito | Copertura | Soglia |
|---|---|---|
| Progetto (`coverage/merged.lcov.info`) | **88,11%** (19217/21810) | 80% — superata |
| `packages/estimation` | 98,10% (2730/2783) | 90% — superata |
| `lib/catalog/` | 99,19% | 80% — superata |
| `lib/dashboard/` | 98,82% | 80% — superata |
| `lib/sharing/` | 98,45% | 80% — superata |
| `lib/cellar/` | 94,53% | 80% — superata |
| `lib/label/` | 96,99% | 80% — superata |
| `lib/account/` | 97,47% | 80% — superata |
| `lib/plan/` (nuovo) | 79,75% | nessuna soglia per cartella |
| `lib/usage/` (nuovo) | 86,65% | nessuna soglia per cartella |
| `lib/ads/` (nuovo) | 74,03% | nessuna soglia per cartella |
| `lib/dev/` (nuovo) | 89,81% | nessuna soglia per cartella |

Report: `coverage/lcov.info` e `coverage/merged.lcov.info`.

## Dipendenze

`npm audit --omit=dev` in `functions/` e `tool/admin/` segnala vulnerabilità moderate nelle dipendenze transitive (30 e 8, già annotate in Code Generation). L'unica correzione proposta da npm è `npm audit fix --force`, con cambi di versione incompatibili. Non è stata applicata.

## Errori

Nessuno.
