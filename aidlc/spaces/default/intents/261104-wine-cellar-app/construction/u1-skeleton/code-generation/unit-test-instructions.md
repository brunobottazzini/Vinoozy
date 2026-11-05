# Unit Test Instructions — u1-skeleton

Strategia: **Standard**, cioè 5–8 test per componente, più test di integrazione ai confini (regole Firestore) e test end-to-end. Metodologia: **test-after**, strato per strato, come da Testing Contract.

## Setup

- Flutter alla versione di `.flutter-version`; `flutter pub get`.
- Node alla versione di `.nvmrc`; `npm ci` installa `firebase-tools` e `@firebase/rules-unit-testing` in versione fissata.
- Nessuna credenziale: tutti i test usano il progetto `demo-vinoozy` e gli emulatori locali (Auth `127.0.0.1:9099`, Firestore `127.0.0.1:8080`).
- I test end-to-end richiedono un emulatore Android API 34 avviato (`flutter emulators --launch <id>`).

## Comandi (solo test di U1)

Il primo comando funziona già dopo lo Step 2 del piano, prima dei primi test di strato:

```
flutter test test/u1/
```

Test delle regole di sicurezza:

```
npx firebase emulators:exec --only firestore --project demo-vinoozy "npm --prefix test/rules test -- u1.rules.test.mjs compat/"
```

Prova di riavvio di Firestore (Step 9), con l'emulatore Android acceso e gli emulatori Firebase avviati:

```
npx firebase emulators:exec --only auth,firestore --project demo-vinoozy "flutter test integration_test/firestore_restart_probe_test.dart --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
```

Test end-to-end dello scheletro:

```
npx firebase emulators:exec --only auth,firestore --project demo-vinoozy "flutter test integration_test/u1_skeleton_test.dart --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
```

Riavvio reale dell'app con `adb` (Revisione 1, R-02; `cicd-pipeline.md` §1): vino aggiunto offline, `adb shell am force-stop`, `adb shell am start`, poi il vino deve essere ancora sullo schermo e arrivare al cloud. Usa `flutter drive --keep-app-running` con `integration_test/force_stop_queue.dart` e `test_driver/integration_test.dart`:

```
npx firebase emulators:exec --only auth,firestore --project demo-vinoozy "tool/e2e_force_stop.sh"
```

`tool/verify_skeleton.sh` esegue in fila regole, prova di riavvio, end-to-end e questo passo.

Copertura di U1 in un comando a parte. La soglia del progetto **non** si controlla qui:

```
flutter test test/u1/ --coverage --coverage-path=coverage/u1.lcov.info
```

## Expected coverage targets

- **Soglia del progetto:** 80% delle righe su tutto `lib/`, senza esclusioni, compresi i file di traduzione generati (team.md, NFR7.1). La controlla **Build and Test** sulla suite completa, con `tool/gen_coverage_helper.dart`, `flutter test --coverage` e `tool/check_coverage.sh 80`. Un'esecuzione dei soli test di U1 non la giudica, e la soglia non si abbassa mai per far passare un passo.
- **Obiettivo di U1:** i file di `lib/sync/`, `lib/account/` e `lib/cellar/` creati da U1 restano sopra l'80% con i soli test di `test/u1/`. Si controlla leggendo `coverage/u1.lcov.info` nel riepilogo dei risultati.
- **Regole:** ogni regola di `firestore.rules` ha almeno un caso consentito e uno negato (NFR7.2).

## Volume per componente

| Componente | Cartella dei test | Numero |
|------------|-------------------|--------|
| Modello (`WineDraft`, `Wine`, `Cellar`, `UserProfile`) | `test/u1/domain/` | 6–8 per tipo |
| `LocalLedger` | `test/u1/sync/local_ledger_test.dart` | 8 |
| `CellarRepository`, `UserRepository`, `WineRepository` | `test/u1/data/` | 6–8 ciascuno |
| `SyncStatus`, `SyncWatcher`, `AccountGate`, `ErrorReporter` | `test/u1/sync/`, `test/u1/account/` | 5–8 ciascuno; `SyncWatcher` ne ha di più dalla Revisione 1 (voci aggiunte durante il drain, secondo drain prima di `missing`, riconciliazione dei `rejected`) |
| Schermate (`SignInScreen`, `BlockedAccountScreen`, `CellarScreen`, `AddWineScreen`, `OfflineBanner`, `RejectedWineNotice`) | `test/u1/ui/` | 5–8 ciascuna, più le varianti di lingua e scala del testo |
| Regole Firestore | `test/rules/` | circa 25 |
| End-to-end | `integration_test/` | 10 scenari (con il 3b della Revisione 1: due vini offline), più la prova di riavvio e il passo `adb force-stop` |

Ogni file di test copre il caso normale e almeno due casi d'errore o limite. Nessun test passa a prescindere dall'implementazione.

## Mock e stub

- **Firestore e Auth nei unit test:** si usano interfacce proprie (`AuthService`, `CellarRepository`, `WineRepository`, `KeyValueStore`, `Clock`, `IdGenerator`) con `mocktail`. Gli SDK Firebase compaiono solo negli adattatori, che si testano contro l'emulatore.
- **Tempo:** `Clock` finto per l'anno corrente e le attese (timeout, tentativi), quindi nessun `sleep` reale.
- **Rete negli end-to-end:** `TestNetworkControl` (`disableNetwork` e `enableNetwork`). Accesso con `EmulatorGoogleAuthService`, che usa token non firmati accettati dall'Auth Emulator.

## Dati di test

- Utenti di prova: `user-a@example.com` (sub `user-a`) e `user-b@example.com` (sub `user-b`), creati dal test.
- Vini di esempio: "Barolo 2016 x2", "Barbera d'Asti Superiore DOCG" senza annata, nomi di 120 e 121 caratteri.
- Ogni test delle regole e ogni test end-to-end svuota l'emulatore prima di iniziare (`clearFirestore` e l'endpoint di reset dell'Auth Emulator), così i test non dipendono dall'ordine di esecuzione.
