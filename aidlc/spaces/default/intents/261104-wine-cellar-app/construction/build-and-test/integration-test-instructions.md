# Istruzioni dei test di integrazione — Vinoozy

Strategia di test: **Standard**. Questo file copre i confini tra le unità e con i servizi esterni. I test di unità di ogni Unit restano nei rispettivi `code-generation/unit-test-instructions.md`.

## Ambiente

- **Firebase Emulator Suite** (Auth e Firestore) sul progetto finto `demo-vinoozy`: nessun test usa il progetto di produzione `vinoozy-d6f45`, né Google, né Open Food Facts reali.
- **Emulatore Android** (API 34 in CI; in locale un AVD qualsiasi) per i test `integration_test/`. Le build E2E usano `--dart-define=E2E=true`, che attiva l'accesso Google finto verso l'emulatore di Auth e forza la lingua italiana (`lib/e2e/e2e_locale.dart`).
- **Chromium** (Playwright) per la pagina web di cancellazione.
- Dati: account `user-a@example.com`, `user-b@example.com` e quelli dei singoli test; ogni test svuota gli emulatori (`clearEmulators`) e i dati del telefono (`clearPhone`) prima di iniziare.

## Confini verificati

| Confine | Unità coinvolte | Dove si prova | Dove gira |
|---|---|---|---|
| App ↔ regole di Firestore (permessi, validazione, compatibilità con la versione precedente) | U1, U4, U7, U8 | `test/rules/*.rules.test.mjs`, `test/rules/compat/` | Node + emulatore di Firestore |
| Pagina web ↔ Auth e Firestore (accesso Google, cancellazione con le stesse regole) | U8 | `test/web/*.test.mjs` (Node) e prova in Chromium | Node + emulatori; **Chromium vero** con Playwright |
| Accesso, cantina offline e sincronizzazione | U1 | `integration_test/u1_skeleton_test.dart`, `tool/e2e_force_stop.sh` | emulatore Android + emulatori Firebase |
| Riavvio di Firestore e lettura dal server | U1 | `integration_test/firestore_restart_probe_test.dart` | emulatore Android |
| Catalogo, stima del momento ideale e cantina (aggiunta, bevuta, annulla, storico) | U2, U3, U4 | `integration_test/cellar_test.dart`, `concurrent_drink_test.dart` | emulatore Android |
| Dashboard su 500 vini | U2, U4, U5 | `integration_test/dashboard_500_test.dart` | emulatore Android |
| Condivisione della cantina tra due account | U4, U7 | `integration_test/sharing_test.dart` | emulatore Android |
| Foto dell'etichetta → riconoscimento → salvataggio in cantina | U3, U4, U6 | `integration_test/label_test.dart` (immagine finta, ML Kit sul dispositivo) | emulatore Android |
| Profilo, uscita con modifiche in coda, cancellazione dell'account con una cantina condivisa | U1, U7, U8 | `integration_test/account_test.dart` | emulatore Android |
| Codice nativo dell'etichetta (preparazione dell'immagine, condivisione verso Vinoozy) | U6 | `android/app/src/test/` (Robolectric, JaCoCo 80%) | JVM |

## Come eseguire

1. Una volta: `flutter pub get`, `npm ci`, `npx playwright install chromium`.

2. Regole di Firestore (avvia e chiude da solo l'emulatore):

   ```bash
   npm run test:rules
   ```

3. Pagina web, con soglia `c8` all'80% e la prova in Chromium:

   ```bash
   npm run test:web
   ```

4. Test nativi dell'etichetta:

   ```bash
   cd android && ./gradlew :app:testDebugUnitTest :app:jacocoLabelReport
   ```

5. End-to-end sull'emulatore Android. Avviare un AVD, poi gli emulatori Firebase, poi i test e la prova del riavvio forzato:

   ```bash
   npx firebase emulators:start --only auth,firestore --project demo-vinoozy &
   flutter test integration_test --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true
   tool/e2e_force_stop.sh
   ```

   Un singolo file: `flutter test integration_test/<file>.dart --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true`.

## Obiettivi

- Tutti i test passano: nessun test viene saltato per farlo passare, a parte quello che confronta le regole con l'ultimo tag `v*` finché non esiste un tag.
- Limiti di tempo nei test E2E: salvataggio-lista entro 2 s (limite provvisorio di non regressione su emulatore, `provisionalSaveToListLimit`); avvio a freddo con la lista entro 4 s in CI. I valori di riferimento sul telefono (300 ms, 2 s) si misurano con la build di rilascio, come dice `docs/release-checklist.md`.
- Copertura: pagina web almeno 80% delle righe di `account-deletion.js`; codice nativo dell'etichetta almeno 80% (JaCoCo).

## Gestione dei dati di test

- Tutti i dati vivono negli emulatori e vengono cancellati all'inizio di ogni test.
- Le immagini delle etichette sono generate nel test (`integration_test/support/ean13_painter.dart`, `fake_image_source.dart`).
- Nessun dato personale vero: solo indirizzi `@example.com`.
