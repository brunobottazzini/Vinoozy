# Scansione del codice (sviluppatore) — 261107-pending-banner-fix

Profondità Minimal, ambito bugfix. Commit di partenza: `0d99791d02005b8a90a78d17ec57cc994c820cf2`. La scansione legge soltanto: non ha eseguito test, build o programmi e non ha modificato codice sorgente. Non sono stati aperti `config/firebase_prod.json` né `android/app/google-services.json`.

## Developer Code Scan Results

### Scan Coverage
- **Analyzed deeply**:
  - lib/sync/sync_status.dart
  - lib/cellar/data/drinking_record_repository.dart
  - lib/cellar/data/pending_writes_probe.dart
  - lib/app/providers.dart
  - lib/app/bootstrap.dart
  - test/cellar/data/pending_writes_probe_test.dart
  - test/cellar/data/drinking_record_repository_test.dart
  - test/u1/sync/sync_status_test.dart
  - test/cellar/cellar_providers_test.dart
  - integration_test/cellar_test.dart
- **Skimmed only** (lettura mirata di alcune righe o solo dell'elenco dei file): `lib/cellar/cellar_actions.dart`, `lib/cellar/ui/drink_flow.dart`, `lib/cellar/ui/drinking_record_sheet.dart`, `lib/sync/ui/offline_banner.dart`, `lib/sync/sync_watcher.dart`, `lib/cellar/data/wine_repository.dart`, `test/cellar/cellar_harness.dart`, `lib/` (resto), `test/` (resto), `integration_test/` (resto), `packages/estimation/`, `docs/account-deletion/`, `test/rules/`, `.github/workflows/`, `tool/`, `pubspec.yaml`, `package.json`, `analysis_options.yaml`, `firebase.json`, `android/` (solo elenco). Fonte esterna consultata in sola lettura: il plugin Android `cloud_firestore-7.1.0` nella cache di pub (`FlutterFirebaseFirestorePlugin.java`) e `firebase_core-5.1.0` (`FlutterFirebasePlugin.java`).
- **Left out**:
  - .dart_tool/
  - build/
  - coverage/
  - packages/estimation/coverage/
  - node_modules/
  - android/.gradle/
  - android/app/.cxx/
  - .claude/ e aidlc/ (installazione e spazio di lavoro AI-DLC, non codice del progetto)
  - config/firebase_prod.json, android/app/google-services.json (segreti, esclusi per istruzione)

### Packages Found
- `vinoozy` — app Flutter (Android) — Dart — l'app della cantina (`lib/`, `test/`, `integration_test/`)
- `estimation` — pacchetto Dart puro, dipendenza `path` — Dart — finestre di consumo, stato, abbinamenti (contratto C2), nessuna dipendenza di produzione
- `vinoozy-tooling` — strumenti Node privati — JavaScript — Firebase Emulator Suite, test delle regole Firestore, pagina web di cancellazione dell'account
- `test/rules` — pacchetto Node dei test delle regole — JavaScript — `@firebase/rules-unit-testing`

### Build System
- **Type**: Flutter/pub (Flutter 3.47.9, Dart SDK ^3.13.7) + Gradle Android; npm (Node 22) per gli strumenti
- **Config Files**: `pubspec.yaml`, `pubspec.lock`, `packages/estimation/pubspec.yaml`, `l10n.yaml`, `analysis_options.yaml`, `package.json`, `package-lock.json`, `test/rules/package.json`, `firebase.json`, `firestore.rules`, `firestore.indexes.json`, `.flutter-version`, `.nvmrc`, `android/` (Gradle)
- **Build Dependencies**: `vinoozy` → `estimation` (path); `docs/account-deletion/app.bundle.js` ← `tool/build_web_bundle.sh` (esbuild)

### APIs Discovered
- Firestore (SDK, nessun backend proprio) — `lib/*/data/` — collezioni `users`, `cellars/{id}`, `cellars/{id}/wines`, `cellars/{id}/drinkingRecords`, `cellars/{id}/members`; regole in `firestore.rules`
- Open Food Facts HTTP — `lib/catalog/core/off/` — ricerca prodotti e codice a barre
- Platform channel — `lib/label/platform/shared_image_channel.dart` — immagine condivisa da altre app
- API interne Dart: `WineCatalog` (C1, 5 operazioni), `estimation` (C2, 4 funzioni pubbliche), repository di `lib/cellar/data/`, `lib/sharing/data/`, `lib/account/`

### Frameworks & Libraries
- flutter_riverpod — ^3.4.3 — stato e iniezione delle dipendenze
- cloud_firestore — ^7.1.0 (bloccato a 7.1.0) — dati con cache offline
- firebase_auth ^7.0.1, google_sign_in ^7.2.0 — accesso Google
- firebase_core ^5.1.0, firebase_app_check ^0.5.1, firebase_crashlytics ^6.0.1
- connectivity_plus ^7.3.2, shared_preferences ^2.5.6, path_provider ^2.1.6, http ^1.6.0, crypto ^3.0.8
- google_mlkit_barcode_scanning ^1.0.0, google_mlkit_text_recognition ^1.0.0, image_picker ^1.2.4
- share_plus ^13.3.1, package_info_plus ^10.2.2, intl ^0.20.3
- test: flutter_test, integration_test, flutter_driver, mocktail ^1.0.5, flutter_lints ^6.0.0
- Node: firebase-tools 14.27.0, firebase 13.2.0, @firebase/rules-unit-testing 6.0.0, c8 12.0.0, esbuild 0.28.2, playwright 1.65.0

### Test Coverage
- **Test Directories**: `test/` (per unità: `u1/`, `cellar/`, `catalog/`, `label/`, `sharing/`, `account/`, `dashboard/`, `app/`, `helpers/`, `web/`, `rules/`), `integration_test/` (e2e su emulatore Android), `packages/estimation/test/`, `test_driver/`
- **Test Frameworks**: flutter_test + mocktail, integration_test, dart test (estimation), node:test + c8 (web), @firebase/rules-unit-testing (regole)
- **Coverage Config**: presente — `flutter test --coverage` + `tool/check_coverage.sh 80` sul lcov unito con `packages/estimation` (job `unit` di `ci.yml`); c8 80% per `docs/account-deletion/account-deletion.js`

### Code Quality Indicators
- **Linting**: `flutter_lints` in `analysis_options.yaml` (escluse `build/`, `android/`, `packages/`, `tool/fixtures/`); `lints` nel pacchetto estimation; `dart format` in CI
- **CI/CD**: `.github/workflows/ci.yml` (job `format`, `secrets`, `analyze`, `unit`, `estimation`, `rules`, `e2e` su emulatore API 34), `release.yml`, `promote.yml`, `firebase-deploy.yml`, `pages.yml`; molti controlli in `tool/check_*.sh` con i propri test
- **Documentation**: `README.md`; commenti di documentazione ricchi e legati ai requisiti (BRx, NFRx, sezioni dei documenti di design)

### Technical Debt Signals
- **Difetto di ordinamento (oggetto di questo intent)**: `DrinkingRecordRepository._commit` (`lib/cellar/data/drinking_record_repository.dart:316`) avvia `batch.commit()` senza attenderlo e alla riga 335 chiama `unawaited(_probe.trackWrite())`, che chiama subito `FirebaseFirestore.waitForPendingWrites()` (`lib/cellar/data/pending_writes_probe.dart:37,55`). Su Android il plugin `cloud_firestore` 7.1.0 esegue `writeBatchCommit` e `waitForPendingWrites` ciascuno con `cachedThreadPool.execute(...)` (pool di thread condiviso `Executors.newCachedThreadPool()` di `firebase_core`): due thread diversi, nessun ordine garantito. Se `waitForPendingWrites()` arriva al SDK nativo prima del batch, trova la coda vuota e si chiude subito, anche offline: la sonda torna a `pending=false` e la fascia sparisce (o non viene mai disegnata).
- I test di unità non possono vedere l'ordine inverso: in `drinking_record_repository_test.dart` il commit del `BatchRecorder` si chiude subito e l'attesa della sonda è un `Completer` indipendente (`queueConfirmed`), quindi lo scenario "attesa chiusa prima che il commit sia in coda" non è modellato.
- Il commento della classe `PendingWritesProbe` (riga 32) cita anche "delete", ma l'eliminazione di un vino con le sue bevute (`WineRepository._deleteBatches`, `lib/cellar/data/wine_repository.dart:592-616`) non passa dalla sonda. Fuori ambito, solo annotato.
- `drinkingRecordsPendingProvider` non è `autoDispose` e `invalidateFirestoreListeners` (`lib/app/providers.dart:156-170`) non lo invalida: lo stato "in attesa" è globale e non legato alla cantina attiva. Fuori ambito, solo annotato.

## Percorso dello stato di sincronizzazione (dettaglio per il bug NFR6.6)

1. **Interfaccia**: `OfflineBanner` (`lib/sync/ui/offline_banner.dart:21`) osserva `syncStatusProvider(cellarId)`; nulla è mostrato con `SyncState.synced`.
2. **Provider**: `syncStatusProvider` (`lib/app/providers.dart:101-102`) è un `NotifierProvider.autoDispose.family` → `SyncStatusNotifier`, che possiede un `SyncStatusTracker` e in `build()` ascolta `cellarStreamProvider`, `winesStreamProvider` e (righe 124-127) `drinkingRecordsPendingProvider` con `fireImmediately: true`, chiamando `_tracker.setPending(SyncSource.drinkingRecords, pending)`.
3. **Stato "in attesa" delle bevute**: `drinkingRecordsPendingProvider` (`lib/app/providers.dart:83-91`), `Notifier<bool>` con `set(bool)`; non apre listener.
4. **Calcolo**: `SyncStatusTracker` (`lib/sync/sync_status.dart:45-88`). `state` = `synced` se né `_pendingOnly` né alcun `SnapshotMeta.hasPendingWrites`; altrimenti `offline` se un listener (non al primo snapshot) è `isFromCache`, altrimenti `syncing`. `setPending` (righe 72-79) modifica solo `_pendingOnly`; non conta mai come ritorno in rete.
5. **Sonda**: `PendingWritesProbe` (`lib/cellar/data/pending_writes_probe.dart`). `trackWrite()` (34-38): nuovo token, `_set(true)` sincrono, poi `_waitFor(token)`; `_waitFor` (53-66) attende `waitForPendingWrites()` e, se il token è ancora l'ultimo, `_set(false)`; in caso di errore `_set(false)` e segnalazione `pending_probe_failed`. `checkAtStartup()` (42-51) mostra la fascia solo se l'attesa supera 300 ms.
6. **Cablaggio**: `lib/app/bootstrap.dart:253-258` crea la sonda con `waitForPendingWrites: () => db().waitForPendingWrites()` e `onPendingChanged: → container.read(drinkingRecordsPendingProvider.notifier).set(pending)`; righe 259-267 la passano a `DrinkingRecordRepository` con `onWriteStarted: watcher.trigger`; riga 295 `unawaited(probe.checkAtStartup())`.
7. **Scrittura**: `DrinkingRecordRepository._commit` (`lib/cellar/data/drinking_record_repository.dart:297-338`): ledger `beginWrite` (attesa), `_db.batch()` + `build(batch)` + `write = batch.commit()` (non attesa, 316), gestione errori in `unawaited(write.then(...))` (321-334), poi `unawaited(_probe.trackWrite())` (335) e `_onWriteStarted?.call()` (336).
8. **Chiamanti di `_commit`** (unici tre): `drink` (136), `undo` (181), `updateRecord` (212). Loro chiamanti: `CellarActions.drink` (`lib/cellar/cellar_actions.dart:221`) ← `drink_flow.dart:38`; `CellarActions.undoDrink` (236) ← `drink_flow.dart:60`; `CellarActions.updateRecord` (261) ← `drinking_record_sheet.dart:112`.
9. **Chiamanti della sonda**: solo `_commit` (`trackWrite`) e `bootstrap.dart:295` (`checkAtStartup`). Altri usi di `waitForPendingWrites()` indipendenti dalla sonda: `SyncWatcher._drain` via `FirestoreSyncGateway` (`lib/sync/sync_watcher.dart:215`, con lo stesso presupposto d'ordine documentato alle righe 111-114) e `AppDeletionDevice` (`bootstrap.dart:216`).

**Perché il caso dell'e2e è il più esposto**: l'ultima bottiglia bevuta offline porta `quantity` a 0, quindi il vino esce dalla query `quantity > 0` di `winesStreamProvider`; lo snapshot successivo non contiene più il documento modificato e non riporta `hasPendingWrites`. La cantina non è toccata dalla bevuta. L'unica fonte di "in attesa" è quindi la sonda: se si chiude subito, `state` torna `synced`.

**Dato utile per la correzione**: su Android `writeBatchCommit` esegue `Tasks.await(batch.commit())` (plugin, riga 981): il `Future` Dart di `batch.commit()` si completa solo quando il server conferma la scrittura (offline resta aperto fino al ritorno della rete) o quando fallisce. Il `Future` `write` già presente in `_commit` è quindi il segnale esatto "questa stessa scrittura è confermata", senza dipendere dall'ordine con `waitForPendingWrites()`.

### Test esistenti sul percorso
- `test/cellar/data/pending_writes_probe_test.dart`: 5 test (in attesa fino alla conferma; solo l'ultima attesa pulisce; errore pulisce e segnala; avvio sotto 300 ms; avvio oltre 300 ms). L'attesa è un `Completer` per chiamata.
- `test/cellar/data/drinking_record_repository_test.dart`: setup (righe 34-58) con sonda su `queueConfirmed.future`; il test `BR1.10 one batch` (65-92) verifica `pendingChanges` `[true]` poi `[true, false]`. `BatchRecorder` (`test/cellar/cellar_harness.dart:236-262`) permette di tenere aperto il commit con `commitWith`, ma nessun test lo combina con la sonda. Nessun test su undo/updateRecord verifica la sonda.
- `test/u1/sync/sync_status_test.dart:84-129`: gruppo `u4-cellar setPending (NFR6.6)`, 4 test sul tracker.
- `test/cellar/cellar_providers_test.dart:378-390`: `NFR6.6 pending drinks keep the sync state "syncing"`.
- `integration_test/cellar_test.dart:90-102`: `disableNetwork()` (riga 92), "Bevuto" sull'ultima bottiglia, attesa di `cellar-empty`, poi `waitFor(offline-banner)` (riga 95) — è qui che il test diventa instabile —, `enableNetwork()`, attesa della scomparsa della fascia e `cloudDrinkCount == 2`. Gira nel job `e2e` di `ci.yml` (emulatore API 34, Firebase Emulator Suite `demo-vinoozy`).

## Handoff Summary
- **Intent-relevant finding**: `lib/cellar/data/drinking_record_repository.dart:316` (`write = batch.commit()`, non atteso) e `:335` (`unawaited(_probe.trackWrite())` → `pending_writes_probe.dart:55` `await _wait()` = `FirebaseFirestore.waitForPendingWrites()`): sul plugin Android 7.1.0 le due chiamate partono su thread diversi del `cachedThreadPool`, quindi `waitForPendingWrites` può raggiungere il SDK prima del batch, chiudersi su coda vuota e riportare la fascia a "sincronizzato" mentre la bevuta è ancora solo sul telefono. Il `Future` `write` si completa solo alla conferma del server, quindi è il segnale corretto per tenere "in attesa".
- **Risks / follow-up**: (1) la regola "solo l'ultimo token pulisce" deve restare valida anche se la sonda attende il commit (più scritture offline in coda); (2) un commit rifiutato o fallito deve comunque pulire lo stato, come oggi fa l'errore di `waitForPendingWrites`; (3) `checkAtStartup` non è coinvolto e deve restare invariato; (4) il test di regressione può usare `BatchRecorder.commitWith` per tenere aperto il commit mentre l'attesa finta si chiude subito; (5) lo stesso presupposto d'ordine esiste in `SyncWatcher._drain`, fuori ambito ma da annotare; (6) nessuna nuova dipendenza è necessaria.
