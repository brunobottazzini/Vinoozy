# Inventario dei componenti

Ogni titolo di terzo livello è il nome del componente usato nel blocco
`## Scope of Analysis` di `reverse-engineering-timestamp.md`. Le dipendenze
esterne con versione sono in `technology-stack.md`; il grafo tra moduli è in
`dependencies.md`.

## Avvio e configurazione

### AppBootstrap
- **File**: `lib/app/bootstrap.dart`, `lib/main.dart`
- **Responsabilità**: ordine di avvio (Firebase, App Check, Crashlytics e
  ledger in parallelo, emulatori in demo, completamento reset pendente),
  creazione e collegamento di tutti i servizi, override dei provider.
- **Dipende da**: FirebaseEnvConfig, FirestoreBootstrap, AccountGate,
  WineRepository, DrinkingRecordRepository, SharingRepository, LocalLedger,
  SyncWatcher, ErrorReporter.

### FirebaseEnvConfig
- **File**: `lib/firebase/firebase_env.dart`, `options_demo.dart`, `options_prod.dart`
- **Responsabilità**: ambiente da `FIREBASE_ENV` (default `demo`),
  `usesEmulators`, host emulatori, opzioni Firebase; costanti `kIsE2EBuild` e
  `kIsPerfBuild`; `demoProjectId = 'demo-vinoozy'`;
  `MissingProductionOptionsError` per build prod incomplete.
- **Rilevanza intent**: punto previsto per `devCheatsAvailable` e
  `ENABLE_DEV_CHEATS` (studio §9.3), oggi assenti.

### FirestoreBootstrap
- **File**: `lib/firebase/firestore_bootstrap.dart`
- **Responsabilità**: persistenza offline con cache illimitata, emulatore in
  demo, reset in-process (`terminate` + `clearPersistence`) e piano B.

### ErrorReporter
- **File**: `lib/app/error_reporter.dart`, `crashlytics_sink.dart`, `app_event_logger.dart`
- **Responsabilità**: report con ragione fissa e valori sensibili oscurati;
  Crashlytics solo in release produzione; `ConsoleAppEventLogger` solo log
  locale (lo studio vieta di usarlo come misuratore remoto).

## Account

### AccountGate
- **File**: `lib/account/account_gate.dart`, `gate_state.dart`
- **Responsabilità**: macchina a stati dell'accesso (`GateSignIn`,
  `GateBlocked`, `GateEnsureCellar`, `GateCellar`, `GateDeleting`...),
  controllo del proprietario del ledger, profilo e cantina personale, uscita,
  scritture pendenti, eliminazione account.
- **Rilevanza intent**: punto naturale per azzerare un override di diritti al
  cambio di account/uscita (studio §9.2).

### AuthService
- **File**: `lib/account/auth_service.dart`, `google_auth_service.dart`, `lib/e2e/emulator_google_auth_service.dart`
- **Responsabilità**: accesso Google, riautenticazione, `photoUrl`,
  cancellazione utente; implementazione emulata compilata solo con `E2E`.

### UserRepository
- **File**: `lib/account/data/user_repository.dart`
- **Responsabilità**: `users/{uid}` (crea o aggiorna nome/email in
  transazione, `deletionStartedAt`, cancellazione del profilo).

### AccountDeletionRunner
- **File**: `lib/account/deletion/*.dart`
- **Responsabilità**: eliminazione account in passi ripetibili (uscita dalle
  cantine altrui, chiusura inviti, cancellazione vini e bevute a pagine,
  cantina, profilo, utente Auth, pulizia del telefono).
- **Rilevanza intent**: dovrà includere eventuali nuovi documenti per utente
  (`usage`, contatori) o lasciarli al backend.

### ProfileScreen
- **File**: `lib/account/ui/profile_screen.dart`
- **Responsabilità**: foto, nome, email, "Esci" con avviso scritture
  pendenti, "Elimina account", dialogo privacy (apri/copia link; "apri" è una
  modifica non committata).
- **Rilevanza intent**: sede dell'indicatore "DEV · Plus di test" e dello
  stato del piano.

## App e navigazione

### HomeShell
- **File**: `lib/app/home_shell.dart`
- **Responsabilità**: tre tab (Dashboard, Cantina, Storico) in un
  `IndexedStack`, condivisione dei listener, manutenzione della cantina,
  immagini e testi condivisi, apertura dell'aggiunta.

### AboutScreen
- **File**: `lib/app/ui/about_screen.dart`
- **Responsabilità**: schermata "Informazioni" aperta dal menu della Cantina;
  tile `about-version` (versione da `catalogAppVersionProvider`), base dati
  offline, licenze, denominazioni, privacy della foto.
- **Rilevanza intent**: la riga `about-version` è il trigger dei 7 tocchi in 5
  secondi; oggi è un `_Tile` senza gesti.

### BrandFooter
- **File**: `lib/app/ui/brand_footer.dart`
- **Responsabilità**: footer in fondo alla Dashboard con logo, studio e
  versione (`appVersionLabelProvider`, `brand-footer-version`); un tocco apre
  AboutScreen. Lo studio vieta di usarlo come trigger del cheat.

## Cantina

### CellarRepository
- **File**: `lib/cellar/data/cellar_repository.dart`, `lib/cellar/domain/cellar.dart`
- **Responsabilità**: `ensurePersonalCellar`, `isCached`, `watchCellar`;
  modello `Cellar` con `memberSlots`.

### WineRepository
- **File**: `lib/cellar/data/wine_repository.dart`
- **Responsabilità**: tutte le scritture e letture dei vini (vedi
  `api-documentation.md` §5); ledger prima, batch dopo; classificazione degli
  errori (`rejected`, `unauthenticated`, `transient`).
- **Rilevanza intent**: i percorsi che aumentano le schede attive sono
  `create`, `addWine`, `addBottles` su una scheda con `quantity <= 0`,
  `updateWine` con `targetQuantity > 0` da 0, `undo` della bevuta; `mergeInto`
  e `deleteWineWithRecords` le riducono.

### DrinkingRecordRepository
- **File**: `lib/cellar/data/drinking_record_repository.dart`, `lib/cellar/domain/drinking_record.dart`
- **Responsabilità**: "Bevuto" (quantità −1 + bevuta in un batch),
  "Annulla", aggiornamento voto/note/condizione, pagine dello storico, bevute
  di un vino da server/cache.

### readServerOrCache
- **File**: `lib/cellar/data/server_or_cache.dart`
- **Responsabilità**: lettura dal server con timeout, poi dalla cache;
  restituisce `fromServer`. Lo studio chiede di contare la richiesta server
  prima del timeout.

### CellarActions
- **File**: `lib/cellar/cellar_actions.dart`
- **Responsabilità**: operazioni dietro le schermate, con controllo dei
  permessi (`canEdit`, `isOwner`), stima, duplicati, unione, coda di recupero.
- **Rilevanza intent**: punto unico lato client per il controllo di capacità
  prima di `saveNewWine`, `addBottles`, `saveEdit`, `merge`.

### CellarMaintenance
- **File**: `lib/cellar/cellar_maintenance.dart`, `match_key_backfill.dart`, `estimates_migration.dart`, `estimate_refresher.dart`
- **Responsabilità**: backfill `matchKey`, migrazioni di stima/stile,
  raffinamento da catalogo, all'apertura della cantina e al ritorno della rete.
  Lo studio attribuisce questi consumi al contatore di sistema.

### RecordReconciler
- **File**: `lib/cellar/data/record_reconciler.dart`
- **Responsabilità**: coda persistente per utente (`purgeRecords`,
  `reapplyAdjustment`) da completare al ritorno della rete.

### QuantityDelta
- **File**: `lib/cellar/domain/quantity_delta.dart`, `quantity.dart`
- **Responsabilità**: regole pure degli incrementi (`forIncrease`,
  `forEdit`, `canIncrease`, `canDecrease`), tetto 99, `displayQuantity` =
  `max(0, stored)`.

### CellarScreen
- **File**: `lib/cellar/ui/cellar_screen.dart` e le altre schermate in `lib/cellar/ui/`
- **Responsabilità**: elenco, menu (Profilo, Persone, Archivio, Informazioni),
  pulsante "Aggiungi" solo con `canEdit`, banner offline e vini rifiutati;
  `AddWineScreen`, `EditWineScreen`, `WineDetailScreen`,
  `ArchivedWinesScreen`, `HistoryScreen`, flussi "Bevuto".

## Sincronizzazione

### LocalLedger
- **File**: `lib/sync/ledger/local_ledger.dart`, `ledger_state.dart`, `key_value_store.dart`
- **Responsabilità**: JSON `ledger.v1` in SharedPreferences con coda seriale;
  proprietario delle scritture pendenti, `seq`, `generation`, journal delle
  creazioni (`open`/`rejected`), `lastUid`, `resetPending`.

### SyncWatcher
- **File**: `lib/sync/sync_watcher.dart`
- **Responsabilità**: verifica in background delle creazioni (drain 30 s,
  controllo server 10 s), rilascio del proprietario del ledger, nessun loop.

### FirestoreSyncGateway
- **File**: `lib/sync/sync_gateway.dart`
- **Responsabilità**: `waitForPendingWrites`, `checkWine` (server),
  `checkLocal` (cache) dietro l'interfaccia `SyncGateway`.

### SyncErrorBus
- **File**: `lib/sync/sync_error_bus.dart`, `sync_status.dart`, `lib/sync/ui/*`
- **Responsabilità**: eventi `WriteRejected`, `WriteFailed`,
  `SessionExpired`, `CellarAccessLost`, `CellarNotice`; stato del banner
  (`SyncStatusTracker`); avviso dei vini rifiutati.

## Condivisione

### SharingRepository
- **File**: `lib/sharing/data/sharing_repository.dart`, `lib/sharing/sharing_providers.dart`
- **Responsabilità**: inviti e transizioni con contatore `memberSlots`
  accoppiato, listener degli inviti propri (collection group) e dei membri,
  cantina attiva (`activeCellarProvider`), cantine accessibili.

### InviteValidator
- **File**: `lib/sharing/domain/invite_validator.dart`
- **Responsabilità**: `maxInvitees = 2`, email normalizzata, posti usati =
  max(contatore, inviti aperti). Lo studio prevede fino a 5 con Plus.

### AccessibleCellar
- **File**: `lib/sharing/domain/membership.dart`
- **Responsabilità**: cantina apribile con `CellarRole` (`owner`, `edit`,
  `read`); `isPersonal`, `canEdit`, `isOwner`.

## Dashboard

### DashboardScreen
- **File**: `lib/dashboard/ui/*.dart`, `lib/dashboard/dashboard_providers.dart`
- **Responsabilità**: stati (skeleton, errore, syncing, vuoto, contenuto),
  `DashboardContent` con riepilogo, "da bere presto", grafici e `BrandFooter`;
  sola lettura (gate `tool/check_dashboard_readonly.sh`).
- **Rilevanza intent**: sede prevista del banner pubblicitario e della
  spiegazione al superamento della soglia.

### DashboardCalculator
- **File**: `lib/dashboard/domain/*.dart`, `today_provider.dart`
- **Responsabilità**: calcolo puro del riepilogo dalle schede attive.

## Etichetta e catalogo

### LabelSessionController
- **File**: `lib/label/**`
- **Responsabilità**: foto fronte/retro, ML Kit sul telefono, codici a barre,
  Google Lens, testo condiviso, conferma guidata; nessun import cloud (gate
  `tool/check_label_imports.sh`). Nessun costo Firestore.

### WineCatalog
- **File**: `lib/catalog/**`
- **Responsabilità**: catalogo interno, base offline `assets/wine_db/`, Open
  Food Facts con budget e circuit breaker, cache su file.

### estimation
- **File**: `packages/estimation/`
- **Responsabilità**: libreria pura di stima (finestre, stato, abbinamenti,
  stili, classificazione, analisi testo etichetta); nessuna dipendenza.

## Localizzazione

### AppLocalizations
- **File**: `lib/l10n/app_en.arb` (template), `app_it.arb`, `app_pt_BR.arb`, `app_pt.arb` (solo `@@locale`), classi generate
- **Responsabilità**: 611 chiavi per lingua; `nullable-getter: false`; i
  testi UI dello studio §7.8 andranno aggiunti nelle tre lingue.

## Piattaforma Android e sicurezza dati

### MainActivity
- **File**: `android/app/src/main/kotlin/com/vinoozy/vinoozy/*.kt`, `AndroidManifest.xml`
- **Responsabilità**: canali `com.vinoozy.app/label`, `vinoozy/lens`,
  `com.vinoozy.app/links`; filtri `SEND`/`SEND_MULTIPLE` `image/*` e `SEND`
  `text/plain`; permessi `CAMERA` e lettura media rimossi.

### firestore.rules
- **File**: `firestore.rules`, `firestore.indexes.json`, `test/rules/`
- **Responsabilità**: autorizzazione e validazione di tutti i documenti
  (dettaglio in `api-documentation.md` §1); compatibilità con la versione in
  produzione.

## Strumenti e consegna

### check_release_build.sh
- **File**: `tool/check_release_build.sh`
- **Responsabilità**: due build AAB arm64 (normale e `E2E=true PERF=true`);
  marker `EmulatorGoogleAuthService`, `VINOOZY_DASHBOARD_READY`,
  `VINOOZY_E2E_LOCALE` assenti nella prima e presenti nella seconda; controllo
  del manifest unito. Da estendere con il perimetro dei cheat (studio §9.5).

### CI workflows
- **File**: `.github/workflows/ci.yml`, `release.yml`, `promote.yml`, `pages.yml`, `firebase-deploy.yml`
- **Responsabilità**: gate prima del merge e consegna (dettaglio in
  `code-quality-assessment.md`).

### AccountDeletionWebPage
- **File**: `docs/account-deletion/`, `tool/build_web_bundle.sh`, `test/web/`
- **Responsabilità**: pagina pubblica di cancellazione dell'account con
  Firebase web SDK, pubblicata da `pages.yml`; `docs/privacy/` è l'informativa.
