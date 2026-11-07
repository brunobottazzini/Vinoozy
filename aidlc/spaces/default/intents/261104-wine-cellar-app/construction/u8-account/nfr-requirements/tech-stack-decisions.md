# Tech Stack Decisions — u8-account

Fonti: `functional-spec.md` di U8, `team.md` (Code Style, Testing Posture), riepilogo confermato in `nfr-requirements-questions.md`.

## Dipendenze

Nessuna dipendenza nuova nell'app. Per la pagina web: Firebase JS SDK caricato a versione fissata (decisione del proprietario 2026-11-06).

| Uso | Strumento già presente | Alternative scartate |
|---|---|---|
| Riautenticazione e `deleteUser` | `firebase_auth`, `google_sign_in` (U1) | Funzione nel cloud con Admin SDK: richiede il piano a consumo, fuori budget |
| Cancellazione dei dati | `cloud_firestore` con batch da 400 e lettura dal server | `recursiveDelete` dell'Admin SDK: solo lato server |
| Segnali locali (`onboarding.seen`, `account.deletion.<uid>`) | `shared_preferences` | Salvarli nel cloud: illeggibili prima dell'accesso |
| Pagina web | HTML statico in `docs/account-deletion/` su GitHub Pages, con Firebase JS SDK (Auth e Firestore) a versione fissata e un piccolo modulo JavaScript `account-deletion.js` con la stessa sequenza di BR1.7 | Sito con generatore: inutile; server o funzioni nel cloud: fuori budget |

## Requisiti di qualità

| ID | Requisito | Verifica |
|---|---|---|
| NFR7.1 | Copertura ≥ 80% delle righe di `lib/account/` e del progetto, senza esclusioni. | `tool/check_coverage.sh 80 coverage/lcov.info lib/account/` nel job `unit`. |
| NFR7.2 | Ogni regola BR1.1–BR1.13 ha almeno un test con l'ID nel nome. | `tool/check_rule_ids.sh BR1. 13 test/account test/rules/u8.rules.test.mjs` nel job `analyze`. |
| NFR7.3 | Test dei widget di presentazione, profilo, uscita e cancellazione nelle tre lingue, con il testo al 200%. | `flutter test`. |
| NFR7.4 | Due test end-to-end nel job `e2e`: uscita con modifiche in coda; cancellazione completa con una cantina condivisa e verifica che nel cloud non resti nulla. | Job `e2e`. |
| NFR7.6 | La logica di cancellazione della pagina web ha test automatici contro la Firebase Emulator Suite (Node, nel job `rules`): sequenza completa, ripresa, account diverso rifiutato. | Job `rules`. |
| NFR7.5 | I test di U1, U4, U5, U6 e U7 restano verdi, comprese le modifiche ad `AccountGate`. | Suite completa in CI. |
