# NFR Design — u8-account — Domande

Contesto:
- requisiti non funzionali di U8 approvati (`performance-requirements.md`, `security-requirements.md` con la pagina web con accesso Google, `tech-stack-decisions.md`);
- `functional-spec.md` di U8 (BR1.1–BR1.13, i chiarimenti delle due revisioni, la decisione sulla pagina web);
- codice esistente: `lib/account/` (U1), `lib/sharing/` (U7), `lib/cellar/` (U4), `lib/sync/`, `firestore.rules`, `test/rules/`.

Non ci sono domande aperte: sono scelte tecniche che derivano dai requisiti. Le riassumo qui sotto per conferma.

## Consolidated Summary Confirmation

- **Un solo cuore della cancellazione, descritto come dati.** La sequenza dei passi (BR1.7) è una lista di operazioni sul database, uguale per app e pagina web.
  - Nell'app: `AccountDeletionRunner` in Dart.
  - Nella pagina: `account-deletion.js`.
  - Gli stessi test di sequenza girano contro la Firebase Emulator Suite per entrambi, così le due versioni non si separano.
- **Nell'app (`lib/account/`):**
  - `OnboardingScreen` e il segnale `onboarding.seen`;
  - `ProfileScreen` con i dialoghi di uscita, che leggono il numero di modifiche in coda dal registro di U1;
  - `AccountDeletionRunner`: passi 0–7, segnale locale aggiornato a ogni passo, errore tipizzato `AccountOperationError` con solo motivo e passo;
  - `AccountGate` esteso con il controllo della cancellazione prima di profilo e cantina, e gli stati `GateDeleting` e `GateDeleted`;
  - `UserRepository` con creazione o aggiornamento di `deletionStartedAt`, e `AuthService` con `reauthenticate` e `deleteUser`.
- **Regole del cloud:**
  - `users`: `delete` dell'utente; `deletionStartedAt` alla creazione o una volta sola in aggiornamento, uguale a `request.time`;
  - `cellars`: `delete` del proprietario con `memberSlots == 0`, oppure con `deletionStartedAt` nel suo profilo;
  - test in `test/rules/u8.rules.test.mjs`, versione `u8-account` in `app-writes.json`, `RULES_FEATURES` = `sharing cellar account`.
- **Pagina web (`docs/account-deletion/`):**
  - tre file HTML (it, en, pt-BR) e `account-deletion.js`;
  - Firebase JS SDK caricato da CDN a versione fissata con controllo d'integrità;
  - configurazione web di Firebase pubblica;
  - App Check con reCAPTCHA;
  - nessun dato raccolto oltre all'accesso Google.
- **Velocità:**
  - letture dal server a pagine di 400 e batch da 400 confermati uno alla volta;
  - con ≈ 200 bottiglie la cancellazione dura pochi secondi; il caso peggiore resta sotto i 60 s.
- **Privacy e affidabilità:**
  - segnale locale tolto solo dopo l'azzeramento;
  - ripresa con riautenticazione anche da un altro telefono o dalla pagina web;
  - nessun messaggio d'errore nei report.
- **Controlli automatici:**
  - copertura dell'80% su `lib/account/`;
  - ID delle regole BR1.1–BR1.13;
  - test dei widget nelle tre lingue;
  - due end-to-end sugli emulatori;
  - test della pagina web con Node contro gli emulatori nel job `rules`;
  - controllo delle versioni fissate della libreria web.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
