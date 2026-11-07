# Unit Test Instructions — u8-account

## Framework e configurazione

- `flutter test` per `lib/account/` (presentazione, profilo, runner della cancellazione, gate) e per le modifiche a U1.
- **Test delle regole** con `@firebase/rules-unit-testing` sull'emulatore di Firestore (`npm run test:rules`).
- **Test della pagina web** in Node (`node --test`) contro gli emulatori di Firestore e Auth, con copertura `c8`, più una prova in Chromium headless con Playwright (`npm run test:web`). Richiedono Node (versione in `.nvmrc`) e Java 21 per gli emulatori; Playwright installa Chromium con `npx playwright install chromium`.
- **Finti:** `AuthService`, `UserRepository`, Firestore, `LocalLedger`, `ResetCoordinator`, `ErrorSink`, rete, `shared_preferences` e orologio, tutti iniettati tramite provider.
- Nessun test usa il progetto Firebase reale né servizi Google reali.
- Preparazione, una volta: `flutter pub get` e `npm ci` alla radice.

## Come eseguire i test di questa unità

1. Test dell'account (comando principale):

   ```bash
   flutter test test/account
   ```

2. Test delle regole, comprese U1, U4, U7 e la compatibilità (comando a sé):

   ```bash
   npm run test:rules
   ```

3. Test della pagina web, con la soglia di copertura (comando a sé):

   ```bash
   npm run test:web
   ```

4. Test di U1 toccati dal gate (comando a sé):

   ```bash
   flutter test test/u1 test/app
   ```

5. Copertura della sola U8 (comando a sé):

   ```bash
   flutter test --coverage test/account && tool/check_coverage.sh 80 coverage/lcov.info lib/account/
   ```

6. Controlli degli strumenti (comandi a sé):

   ```bash
   tool/check_rule_ids.sh BR1. 13 test/account test/rules/u8.rules.test.mjs
   ```

   ```bash
   tool/check_web_pins.sh
   ```

## Obiettivi di copertura

- **Account in Dart:** almeno l'80% delle righe di `lib/account/`, controllato dal comando 5.
- **Pagina web:** almeno l'80% delle righe di `docs/account-deletion/account-deletion.js`, controllato da `c8` nel comando 3.
- **Progetto:** almeno l'80% su tutto il codice senza esclusioni (team.md), verificato da Build and Test sulla suite completa.
- **Regole di business:** ogni regola BR1.1–BR1.13 citata in almeno un test (comando 6).

## Mock e stub

- **Cancellazione:** il runner usa un Firestore finto che registra batch e letture, con la possibilità di interrompere dopo un passo qualsiasi.
- **Riautenticazione:** `AuthService` finto che restituisce lo stesso uid, un altro uid o un annullamento.
- **Pagina web:** l'emulatore di Auth accetta un id token Google finto (`GoogleAuthProvider.credential` con JSON di `sub` ed `email`).
- **Tempo:** l'attesa di 30 s e i tempi del gate si provano con l'orologio finto, mai con attese vere.

## Dati di test

- Account finti con email `@example.com`.
- Una cantina con 2 inviti, un invito in attesa e uno chiuso in cantine altrui, 50 vini e 100 bevute per il test di sequenza.
- Ogni regola ha almeno un test con l'ID nel nome; schermate in it, en e pt-BR con `textScaler` 1.0 e 2.0.
