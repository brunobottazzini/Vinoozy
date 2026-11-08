# Istruzioni dei test di unità — nuova UX

## Framework e configurazione

- `flutter test` (Flutter 3.47.9) per unità e widget; i test delle regole girano con `@firebase/rules-unit-testing` sull'emulatore di Firestore (`npm run test:rules`).
- Preparazione, una volta: `flutter pub get`, `npm ci` e `flutter gen-l10n` dopo ogni modifica agli ARB.
- Finti già esistenti:
  - `test/cellar/cellar_harness.dart`, con `BatchRecorder` e `commitWith`;
  - `test/helpers/ui_harness.dart`, con la matrice di 3 lingue × testo 1,0/2,0 × tema chiaro/scuro;
  - `test/helpers/fakes.dart`.
- Nessun test usa Firebase reale né la rete.

## Come eseguire i test di questa modifica

Ogni comando gira da solo.

1. Dominio e dati della Cantina:

   ```bash
   flutter test test/cellar
   ```

2. Dashboard, tema e componenti condivisi:

   ```bash
   flutter test test/dashboard test/app
   ```

3. Regole di Firestore, compresa la compatibilità con la versione di oggi:

   ```bash
   npm run test:rules
   ```

4. Copertura di `lib/cellar/` e `lib/dashboard/`:

   ```bash
   flutter test --coverage test/cellar test/dashboard test/app && tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/
   ```

## Obiettivi di copertura

- **Progetto:** almeno l'80% delle righe senza esclusioni (team.md). Lo verifica Build and Test sulla suite completa, con la copertura del pacchetto di stima unita.
- **`lib/cellar/` e `lib/dashboard/`:** almeno l'80% ciascuna, come già controllato in `ci.yml`.
- **Nuovi file:** `wine_origins.dart` e ogni widget nuovo hanno almeno un test per caso descritto nel piano.

## Mock e stub

- **Pannello "Ho bevuto":** `CellarActions` finto che registra le chiamate a `drink` (con o senza `rating`). Il test verifica che non ci sia nessuna chiamata prima di "Sì, l'ho bevuta".
- **Repository:** `BatchRecorder` verifica che bevuta e voto stiano nello stesso batch e che l'offline (commit aperto) tenga la fascia accesa.
- **Origini:** funzioni pure, senza finti.

## Dati di test

- Vini d'esempio di Italia (Barolo, Piemonte), Francia (Chablis, Bourgogne), Argentina (Malbec, Mendoza), Brasile (Serra Gaúcha) e Isole Marianne Settentrionali (MP, senza regioni).
- Un vino vecchio con `region: "piemonte"` e senza `country`, per la regola "regione italiana → Italia".
- Una regione libera di 100 caratteri, per verificare il limite di 120.
- Account finti con indirizzi `@example.com`.
