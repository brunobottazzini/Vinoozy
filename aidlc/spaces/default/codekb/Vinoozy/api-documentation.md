# Documentazione delle API

L'app non espone endpoint propri e non ha backend. Le sue superfici sono: il
modello dati Firestore protetto da `firestore.rules`, i servizi Firebase, le
richieste HTTP a Open Food Facts, i canali nativi Android e le API interne
(provider Riverpod e classi di servizio Dart).

## 1. Modello dati Firestore e regole (`firestore.rules`)

Funzioni comuni: `signedIn()` (solo `sign_in_provider == 'google.com'`),
`uid()`, `incoming()`, `existing()`, `onlyChanged(fields)`,
`cellarOwner(id)`, `email()`, `verified()`, `memberPath(id)`, `isOwner(id)`,
`isActiveMember(id)`, `canReadCellar(id)`, `canEditCellar(id)`,
`deletingAccount()`.

| Percorso | get/list | create | update | delete |
|---|---|---|---|---|
| `users/{userId}` | get: solo se stesso; list: mai | se stesso, `validUserCreate` (`displayName`, `email`, `onboardingSeen=false`, `createdAt`, `schemaVersion=1`, opz. `deletionStartedAt`) | `validUserUpdate` (`displayName`, `email`, `onboardingSeen`) oppure `validDeletionStart` | se stesso e solo con `deletionStartedAt` |
| `cellars/{cellarId}` | get: proprietario, `cellarId == uid` o membro attivo; list: `ownerId == uid` | `cellarId == uid`, `validCellarCreate` (`ownerId`, `name` 1-60, `createdAt`, `schemaVersion=1`) | proprietario rinomina; `validSlotsUpdate` (`memberSlots` 0..2 accoppiato a `memberOpKey`); flag `matchKeyBackfill` false→true | proprietario durante `deletingAccount()` |
| `cellars/{id}/wines/{wineId}` | `canReadCellar` | `canEditCellar` + `validWineCreate` (`quantity` 1..99, `updatedBy == uid`, timestamp server) | `canEditCellar` + `validWineUpdate` (controlli a gruppi, `quantity <= 99` se cambia, nessun limite inferiore) o `validMatchKeyBackfill` | solo `isOwner` |
| `cellars/{id}/drinkingRecords/{id}` | `canReadCellar` | `canEditCellar` + `validDrinkingRecord` | autore o proprietario, `validDrinkingRecordUpdate` | proprietario sempre; autore entro 10 minuti ("Annulla") |
| `cellars/{id}/members/{email}` | get: proprietario o se stesso; list: proprietario | proprietario, `validInviteNew` + `pairedOp(1)` | proprietario: `validReinvite`, `validPermissionChange`, `validOwnerRevoke`; invitato: `validActivate`, `validLeave` | solo `revoked`, proprietario o se stesso |
| collection group `members` | se `inviteeEmail == email()` verificata | — | — | — |

Campi ammessi di una scheda (`wineFields()`): `name`, `producer`, `vintage`,
`wineType`, `region`, `denomination`, `quantity`, `window`, `pairings`,
`createdAt`, `updatedAt`, `updatedBy`, `matchKey`, `baseWindow`,
`windowAdjustment`, `country`, `level`, `windowOverride`, `style`,
`typeSource`, `levelSource`, `styleSource`, `agingStartMonth`,
`migrationVersion`. Un campo nuovo (es. un marcatore di capacità) va aggiunto
qui e nei test di compatibilità.

Accessi a documenti dipendenti per richiesta (tabella in testa al file):
proprietario 1 (cantina), invitato 2 (cantina, members), aggiornamento
`memberSlots` 2, `members` 2, `users` 0, delete cantina 1. Il file ricorda il
limite di 1000 espressioni: le validazioni dei vini sono raggruppate.

**Assenti oggi**: `entitlements/{uid}`, `usage/{uid}/periods/...`,
`adSlots/{uid}/days/...`, contatori di schede attive, qualsiasi campo di piano.

Indici (`firestore.indexes.json`): `drinkingRecords` (`drankOn` desc,
`createdAt` desc); override collection group `members.inviteeEmail`.

## 2. Servizi Firebase

| Servizio | Uso | Configurazione |
|---|---|---|
| Firebase Auth | Accesso Google (`GoogleAuthService`; `EmulatorGoogleAuthService` solo con `E2E`) | Emulatore `EMULATOR_HOST:9099` in demo; `GOOGLE_SERVER_CLIENT_ID` in prod |
| Cloud Firestore | Persistenza offline illimitata, listener e batch | Emulatore `:8080` in demo (`FirestoreBootstrap.configure`) |
| App Check | Play Integrity in release, debug provider in debug | Non attivato con gli emulatori |
| Crashlytics | Errori sanitizzati | Solo release + produzione |

## 3. HTTP esterno

Open Food Facts (`lib/catalog/core/off/open_food_facts_source.dart`): ricerca
e prodotto con `RequestBudget` (8 ricerche, 60 prodotti), `OffCircuitBreaker`,
corpo massimo 1 MiB, User-Agent con versione app e contatto `OFF_CONTACT`.

## 4. Canali nativi Android (`MainActivity.kt`)

| Canale | Lato Dart | Scopo |
|---|---|---|
| `com.vinoozy.app/label` | `lib/label/platform/shared_image_channel.dart` | Immagini e testo condivisi, preparazione foto |
| `vinoozy/lens` | `lib/label/platform/lens_channel.dart` | Apertura Google Lens, fotocamera Lens |
| `com.vinoozy.app/links` | `lib/app/external_links.dart` | Apertura di un URL `https` nel browser (modifica non committata) |

## 5. API interne principali (Dart)

| Classe | Metodi pubblici rilevanti |
|---|---|
| `WineRepository` | `create`, `incrementQuantity`, `watchCellarWines` (`quantity > 0`), `watchWine`, `fetchArchived` (`quantity <= 0`), `findByMatchKey`, `addWine`, `addBottles`, `removeBottle`, `updateWine`, `updateClassification`, `migrateWine`, `setEstimate`, `setOverride`, `clearOverride`, `mergeInto`, `deleteWineWithRecords`, `purgeRecords` |
| `DrinkingRecordRepository` | `drink`, `undo`, `updateRecord`, `pageHistory`, `recordsOfWine(source: serverOrCache/cache/server)` |
| `readServerOrCache(query, timeout)` | Lettura server con timeout, poi cache; ritorna `QueryRead(snapshot, fromServer)` |
| `CellarActions` | `duplicatesOf`, `entriesLike`, `saveNewWine`, `addBottles`, `removeBottle`, `saveEdit`, `drink`, `undoDrink`, `updateRecord`, `recomputeAdjustment`, `ensureEstimates`, `setOverride`, `chooseStyle`, `restoreEstimate`, `deleteWine`, `merge`, `hasDrinks` |
| `SharingRepository` | `watchMyMemberships`, `watchCellarMembers`, `invite`, `changePermission`, `revoke`, `deleteClosed`, `activate`, `leave`, `revokeAllForUser` |
| `SyncGateway` / `FirestoreSyncGateway` | `waitForPendingWrites`, `checkWine` (server), `checkLocal` (cache) |
| `LocalLedger` | `watch`, `read`, `beginWrite`, `markConfirmed`, `markRejected`, `reopen`, `noticeShown`, `dismiss`, `tryReleaseOwner`, `reset`, `setLastUid`, `setResetPending`, `generation` |
| `AccountGate` | `state`, `start`, `signIn`, `signOut`, `pendingChanges`, `syncNow`, `deleteAccount`, `resumeDeletion`, `cancelDeletion`, `retryCheck`, `retryCellar` |
| `UserRepository` | `ensureProfile`, `markDeletionStarted`, `isDeletionStarted`, `deleteProfile` |
| `FirebaseEnvConfig` | `fromEnvironment`, `env`, `isE2E`, `emulatorHost`, `usesEmulators`, `options` |
| `estimation` (pacchetto) | `estimateWindow`, `statusOf`, `pairingsFor`, `classifyWine`, `resolveStyle`, `extractLabelFields`, `effectiveWindow`, `recognizeDenomination` e tipi correlati (vedi `packages/estimation/lib/estimation.dart`) |

Provider Riverpod di riferimento: `winesStreamProvider(cellarId)`,
`cellarStreamProvider(cellarId)`, `wineProvider`, `archivedWinesProvider`,
`historyPagerProvider`, `activeCellarProvider(user)`,
`myMembershipsProvider(user)`, `accessibleCellarsProvider`,
`dashboardSummaryProvider(cellarId)`, `syncStatusProvider(cellarId)`,
`cellarActionsProvider`, `catalogAppVersionProvider`,
`appVersionLabelProvider`, `privacyPolicyUrlProvider`.

## 6. Define di compilazione (`--dart-define`)

| Nome | Default | Effetto |
|---|---|---|
| `FIREBASE_ENV` | `demo` | `prod` usa le opzioni di produzione; tutto il resto usa `demo-vinoozy` sugli emulatori |
| `EMULATOR_HOST` | `10.0.2.2` | Host degli emulatori |
| `E2E` | false | Compila i ganci E2E (auth emulata, locale forzata) |
| `PERF` | false | Segnale "ready" della Dashboard |
| `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET` | vuoti | Opzioni prod (da `config/firebase_prod.json`, mai committato) |
| `GOOGLE_SERVER_CLIENT_ID` | vuoto | Client OAuth web per Google Sign-In |
| `PRIVACY_POLICY_URL` | `https://brunobottazzini.github.io/Vinoozy/privacy/` | Link privacy nel profilo |
| `OFF_CONTACT` | — | Contatto per Open Food Facts |

`ENABLE_DEV_CHEATS` (studio §9.3) **non esiste ancora**.
