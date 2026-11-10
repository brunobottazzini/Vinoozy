# Istruzioni per i test — Freemium e Plus

Lavoro senza Unit (scope `express`): questi comandi riguardano soltanto i file di test aggiunti o modificati da questo lavoro.

## Framework e configurazione

- **Flutter**: `flutter test`, con le dipendenze di test già presenti in `pubspec.yaml` (`flutter_test`, `mocktail`). Non serve configurazione aggiuntiva.
- **Regole Firestore**: `@firebase/rules-unit-testing` in `test/rules/`, eseguito dentro `firebase emulators:exec` (`package.json` → `test:rules`).
- **Cloud Functions**: `functions/` con il proprio `package.json` e lo script `test` (mocha o jest con `firebase-functions-test`). Gira dentro `firebase emulators:exec --only firestore,auth,functions --project demo-vinoozy`.
- **Script amministrativi**: `node --test` su `test/admin/*.test.mjs`, con l'emulatore Firestore e Auth e l'opzione `--emulator` degli script.
- **End-to-end**: `integration_test/freemium_test.dart` su emulatore Android collegato alla Firebase Emulator Suite, come gli E2E esistenti.

## Comandi (solo i test di questo lavoro)

Controllo che il runner sia pronto, da eseguire prima del primo passo di test:

```bash
flutter test test/plan/capability_resolver_test.dart
```

Strato dati:

```bash
flutter test test/plan/data test/usage/cloud_usage_meter_test.dart test/cellar/data/active_counter_test.dart
```

Logica:

```bash
flutter test test/plan/capability_resolver_test.dart test/plan/capacity_guard_test.dart test/usage/usage_cost_test.dart test/usage/usage_uploader_test.dart test/ads/ad_eligibility_test.dart test/dev/dev_cheats_test.dart
```

Interfaccia:

```bash
flutter test test/plan/ui test/ads/ui test/dev/ui
```

Regole Firestore (eseguono il nuovo file e quello oggi escluso dalla CI, insieme agli esistenti richiesti dallo script):

```bash
npm run test:rules
```

Backend:

```bash
npm run test:functions
```

Script amministrativi:

```bash
firebase emulators:exec --only firestore,auth --project demo-vinoozy "node --test test/admin/grant_plus.test.mjs"
```

End-to-end, su emulatore Android con la Emulator Suite avviata (`npm run emulators`):

```bash
flutter test integration_test/freemium_test.dart --dart-define=E2E=true --dart-define=ENABLE_DEV_CHEATS=true
```

## Copertura attesa

- La soglia è l'**80% delle righe su tutto il codice**, senza esclusioni (team.md). È una soglia dell'intero progetto: la controlla Build and Test sulla suite completa con `flutter test --coverage` e `tool/check_coverage.sh`. I comandi qui sopra, limitati ai test di questo lavoro, non la giudicano.
- Strategia Minimal: almeno un test per requisito e almeno un test del percorso principale per ogni componente nuovo (resolver, guard, costo, uploader, meter, idoneità annunci, strumenti sviluppatore, repository, billing service, schermate). Il totale è di circa 60 test, perché i requisiti sono 50.
- I confini numerici della FR6.2 vanno testati tutti, come elencato nello studio §7.11.

## Mock e stub

- **Firestore lato client**: `fake_cloud_firestore` se è già fra le dipendenze di test. Altrimenti si usano i mock `mocktail` sui repository, come nei test di `test/cellar/data/`.
- **Play Billing**: un'interfaccia `BillingClient` iniettata nel `BillingService`, con un'implementazione finta che restituisce `ProductDetails` e `PurchaseDetails` costruiti nei test. Nessuna chiamata allo store.
- **AdMob**: un'interfaccia `AdsGateway` (inizializza, carica, rimuove), finta nei test, che registra le chiamate per verificare che con `adsEnabled=false` non ci sia alcuna inizializzazione.
- **Play Developer API e Cloud Billing nelle funzioni**: client iniettati, con implementazioni finte per gli stati `ACTIVE`, `PENDING`, `CANCELED`, `IN_GRACE_PERIOD`, `ON_HOLD`, `PAUSED`, `EXPIRED` e `REVOKED`.
- **Orologio**: si usa `lib/core/clock.dart`, già presente, per le scadenze, il periodo UTC e la finestra di 20 secondi della sequenza.

## Dati di test

- Gli utenti e i progetti sono solo quelli dell'emulatore `demo-vinoozy`. Nessun dato o progetto di produzione.
- I diritti di prova si creano con l'ambiente dell'emulatore che salta le regole (`withSecurityRulesDisabled` nelle regole, `Bearer owner` per la fixture REST).
- I vini per il limite si generano in un ciclo nei test, per esempio 15 schede con `quantity` 1 più una a 0 per la riattivazione.
