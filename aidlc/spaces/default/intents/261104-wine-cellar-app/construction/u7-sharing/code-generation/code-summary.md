# Code Summary — u7-sharing

U7 aggiunge la condivisione della cantina con al massimo **2 persone invitate** (FR8.1–FR8.4, storie US8.1–US8.4). È composta da:
- le regole di sicurezza di Firestore e l'indice sul gruppo di collezioni `members`;
- il modulo `lib/sharing/`: dominio puro, repository, provider, schermate;
- l'integrazione con U1 e U5, che passano dalla cantina personale alla **cantina attiva**.

Tutto funziona sul piano gratuito di Firebase, senza funzioni nel cloud: l'app scrive con un `WriteBatch` per operazione e le regole fanno rispettare permessi, transizioni e limite. Nessun test e nessuno strumento usa il progetto Firebase reale; nessuna regola è stata pubblicata; niente commit e niente push.

## File creati

**Dominio `lib/sharing/domain/`** (solo Dart, nessuna dipendenza da Flutter)
- `sharing_error.dart`: `SharingError` (`invalidEmail`, `selfInvite`, `alreadyInvited`, `limitReached`, `notOwner`, `notFound`, `offline`, `timeout`, `failed`) e `SharingException`.
- `membership.dart`:
  - `MemberFields`, `MemberStatus`, `MemberPermission`, `ClosedBy`;
  - `Membership` con un mapper che non lancia mai: uno stato sconosciuto vale `revoked` (nessun accesso), un permesso sconosciuto vale `read`;
  - `displayNameOrFallback(name, email)`: nome senza spazi ai lati, oppure la parte dell'email prima della `@`, al massimo 100 unità UTF-16 senza spezzare le emoji, mai vuoto;
  - `CellarRole` e `AccessibleCellar` (`isPersonal`, `canEdit`, `isOwner`).
- `invite_validator.dart`: `InviteValidator` con normalizzazione (trim, minuscolo), formato `x@y.z` con al più 254 caratteri e senza `/`, e i controlli `invalidEmail` → `selfInvite` → `alreadyInvited` → `limitReached` (limite 2, sul maggiore tra il contatore e gli inviti aperti). `usedPlaces` dà il valore "x/2".
- `membership_tracker.dart`: `MembershipTracker`, che confronta le liste successive dei propri inviti. È accesso perso un invito `active` che passa a `revoked` dal proprietario, oppure che sparisce; l'uscita volontaria no.

**Dati `lib/sharing/data/sharing_repository.dart`**
- Le 7 operazioni: `invite`, `changePermission`, `revoke`, `leave`, `activate`, `deleteClosed`, `revokeAllForUser`.
- Ogni operazione è un solo `WriteBatch`: il documento `members` e, quando cambiano gli inviti aperti, la cantina con `memberSlots: FieldValue.increment(±1)` e `memberOpKey`.
- `commit().timeout(10 s)`; prima di ogni operazione di gestione, `hasNetwork()`. Senza rete l'esito è `offline`, senza conferma entro 10 s `timeout`.
- `invite` fa i controlli locali, poi legge il documento `members` per scegliere tra invito nuovo e reinvito di un accesso chiuso (`closedBy` rimosso con `FieldValue.delete()`).
- Traduzione degli errori (`security-design.md` §4): per un `permission-denied` c'è una seconda lettura, per cui la cantina piena dà `limitReached`, un invito aperto dà `alreadyInvited` e ogni altro caso dà `notOwner`. Poi `not-found` → `notFound`, `unavailable`/`deadline-exceeded`/tempo scaduto → `timeout`, il resto → `failed`.
- Ogni errore inatteso passa da `ErrorReporter` con un `reason` fisso (`sharing_invite_failed`, `sharing_permission_failed`, `sharing_revoke_failed`, `sharing_leave_failed`, `sharing_activate_failed`, `sharing_delete_failed`, `sharing_revoke_all_failed`) e con uid, email e nomi tra i valori sensibili.
- `watchMyMemberships(email)`: query sul gruppo di collezioni filtrata solo su `inviteeEmail`, con `isFromCache`. `watchCellarMembers(cellarId)`: gli inviti di una cantina.

**Logica `lib/sharing/sharing_providers.dart`**
- `myMembershipsProvider(user)`: l'unico ascolto dei propri inviti.
  - Attiva gli inviti `invited` solo su una lista confermata dal server, una volta per cantina; se l'attivazione fallisce riprova alla lista successiva.
  - Dopo un'attivazione riuscita pubblica l'avviso "Mario ti ha condiviso la sua cantina".
  - Pubblica `CellarAccessLost` per le revoche del proprietario e per i documenti spariti.
- `accessibleCellarsProvider(user)` e `accessibleCellarsOf`: la cantina personale prima, poi quelle condivise per nome del proprietario. Se la query degli inviti fallisce, resta la sola cantina personale. `canReadCellar` e `canEditCellar` implementano `canRead` e `canEdit` di C4.
- `activeCellarProvider(user)` (`ActiveCellarNotifier`):
  - ricorda la scelta in `shared_preferences` con la chiave `sharing.activeCellar.<uid>`;
  - torna alla cantina personale se la scelta non è più accessibile, con un avviso se era una revoca;
  - con una cantina condivisa attiva osserva gli ascolti della cantina e dei vini: un `permission-denied` dà l'avviso e il ritorno alla personale, salvo durante l'uscita (`leavingCellarIdsProvider`);
  - `leaveActive()` gestisce l'uscita.
- `cellarMembersProvider(cellarId)` (`autoDispose`), aperto solo nella schermata "Persone".
- `sharingOnlineProvider`: lo stato della rete, poi ogni cambio (`NetworkStatus.onChanged`).
- `clearActiveCellarChoices` e `invalidateSharingListeners`.

**Interfaccia `lib/sharing/ui/`**
- `sharing_screen.dart`: `SharingScreen`.
  - Vista del proprietario: `InviteForm`, elenco delle persone invitate e attive, sezione "Accessi chiusi" con reinvito ed eliminazione definitiva.
  - Vista della persona invitata: proprietario, permesso proprio, "Esci da questa cantina".
  - Indicatore sulle operazioni in corso, messaggi d'errore fissi, comandi disattivati senza rete con la spiegazione.
- `invite_form.dart`: `InviteForm` con email, i due permessi con spiegazione, "x/2", limite raggiunto e doppio tocco ignorato.
- `member_tile.dart`: `MemberTile` letto da TalkBack come "nome, permesso, stato", e `PermissionMenu`.
- `sharing_dialogs.dart`: `RevokeDialog` (conferma con il nome o l'email, senza contare maiuscole e spazi ai lati; il pulsante disattivato spiega il motivo) e `LeaveCellarDialog`.
- `cellar_switcher.dart`: `CellarSwitcher` con l'etichetta "Cantina di Mario, Può modificare. Tocca per cambiare cantina". Con la sola cantina personale non mostra nulla.
- `shared_cellar_notice.dart`: `SharedCellarNotice`, il dialogo con "OK".
- `share_launcher.dart`: l'interfaccia `ShareLauncher`, `SharePlusLauncher` su `share_plus` e il link di Google Play.
- `sharing_labels.dart`: testi tradotti di permessi, ruoli, stati ed errori.

**Regole, indice, strumenti, test**
- `test/rules/u7.rules.test.mjs` (101 test):
  - la matrice 6 ruoli × 9 operazioni generata da una tabella (54 celle);
  - le transizioni consentite e quelle vietate;
  - il contatore: due inviti riusciti e il terzo rifiutato, +2, contatore senza `members`, due inviti con un solo +1, `memberOpKey` di un altro invito, doppio invito e doppia revoca;
  - i campi al limite e `unverifiedGoogleUser()`;
  - l'email in maiuscolo nel token, il nome di ripiego e la query sul gruppo di collezioni;
  - `drinkingRecords` e l'eliminazione del proprio invito `revoked`.
- `tool/check_firestore_indexes.sh`, `tool/check_firestore_indexes_test.sh`, `tool/fixtures/firestore_indexes/ok.json` e `missing.json`.
- `integration_test/sharing_test.dart`: test con due utenti; il proprietario agisce via REST con `ownerRestClient()`, attese al massimo di 15 s.
- `test/sharing/`: 10 file, 195 test. Sono `sharing_harness.dart`, `invite_validator_test.dart`, `membership_test.dart`, `display_name_test.dart`, `sharing_repository_test.dart`, `sharing_providers_test.dart`, `sharing_screen_test.dart`, `cellar_switcher_test.dart`, `dialogs_test.dart` e `permissions_screens_test.dart`.

## File modificati

- `firestore.rules`:
  - tabella degli accessi in commento in testa al file;
  - funzioni comuni `email()`, `verified()`, `memberPath()`, `isOwner()`, `isActiveMember()`, `canReadCellar()`, `canEditCellar()`;
  - `get` della cantina per la persona invitata;
  - `update` del contatore legato a `memberOpKey` (0–2), con le funzioni `opAdds`/`opRemoves`;
  - blocco `members` con le transizioni di BR1.13 e `pairedOp`;
  - regola sul gruppo di collezioni;
  - `wines` con `canReadCellar`/`canEditCellar` ed eliminazione del solo proprietario;
  - `drinkingRecords` con `validDrinkingRecord()`.
  Le regole del proprietario di U1 restano equivalenti.
- `firestore.indexes.json`: `fieldOverride` su `members.inviteeEmail`, `COLLECTION_GROUP`, crescente.
- `package.json`: `test:rules` con `u7.rules.test.mjs`.
- `pubspec.yaml`, `pubspec.lock`: `share_plus: ^13.3.1`, ultima stabile, installata con `flutter pub add`.
- `test/rules/helpers.mjs`: `googleUser()` con `email_verified: true`, nuovo `unverifiedGoogleUser()`.
- `test/rules/compat/compat.rules.test.mjs` e `app-writes.json`:
  - nuova versione `u7-sharing` con le scritture della condivisione;
  - campo `requiresRules: "sharing"`, per cui la direzione 2 salta quelle scritture e lo scrive nel log;
  - un test verifica che ogni `requiresRules` compaia in `RULES_FEATURES` di `promote.yml`;
  - il replay supporta `as: "invitee"`, i batch, `delete` e `$deleteField`.
- `test/rules/u1.rules.test.mjs`: il test "delete is denied in U1" diventa "il proprietario elimina, un altro utente no" (vedi Scostamenti).
- `lib/cellar/domain/cellar.dart`: `memberSlots` (0 se manca o negativo) e `memberOpKey?`, letti senza mai lanciare.
- `lib/cellar/data/cellar_repository.dart`: `watchCellar(cellarId)`.
- `lib/cellar/data/wine_repository.dart`: `_onWriteError` riceve `cellarId` e `uid` e chiama `reportWriteRejected`.
- `lib/sync/sync_error_bus.dart`: evento `CellarAccessLost(cellarId, ownerName?, fromQueuedWrite)` e funzione `reportWriteRejected`, che pubblica `WriteRejected` come prima e, per un `permission-denied` su una cantina non personale, anche `CellarAccessLost`.
- `lib/account/network_status.dart`: `Stream<bool> get onChanged`, implementato con `connectivity_plus`.
- `lib/account/account_gate.dart`: callback facoltativo `clearSharingChoice`, eseguito prima del reset e all'uscita dall'account. `retryCellar` riapre anche gli ascolti della condivisione tramite `reopenCellarListeners`.
- `lib/app/providers.dart`: `cellarStreamProvider` e `syncStatusProvider` indicizzati per `cellarId`. `reopenCellarListeners` e `invalidateFirestoreListeners` invalidano anche i provider della condivisione.
- `lib/app/bootstrap.dart`: crea `SharingRepository` e collega `clearSharingChoice`.
- `lib/app/vinoozy_app.dart`: l'ascoltatore alla radice mostra "Non hai più accesso alla cantina di …" e "Alcune modifiche … non sono state salvate …" una volta per cantina e sessione, più "… ti ha condiviso la sua cantina".
- `lib/app/home_shell.dart`: "Aggiungi il primo vino" scrive nella cantina attiva.
- `lib/cellar/ui/cellar_screen.dart`:
  - cantina attiva e selettore;
  - menu della cantina con "Persone";
  - "Aggiungi" nascosto con `read`;
  - `OfflineBanner(cellarId)`.
- `lib/dashboard/dashboard_providers.dart` (U5): provider indicizzati per `cellarId`.
- `lib/dashboard/ui/dashboard_screen.dart` (U5): cantina attiva, selettore, "Aggiungi il primo vino" nascosto con `read`.
- `lib/sync/ui/offline_banner.dart`: `OfflineBanner(cellarId)`.
- `lib/l10n/app_en.arb`, `app_it.arb`, `app_pt_BR.arb`: 49 chiavi nuove; i file `app_localizations*.dart` sono rigenerati con `flutter gen-l10n`.
- Test di U1 e U5:
  - `test/u1/domain/cellar_test.dart`: campi nuovi;
  - `test/u1/data/wine_repository_test.dart`: rifiuti in una cantina condivisa e `reportWriteRejected`;
  - `test/u1/account/account_gate_test.dart`: reset, uscita e "Riprova";
  - `test/u1/ui/sign_in_screen_test.dart`: `FakeNetwork` con `onChanged`;
  - `test/u1/ui/offline_banner_test.dart`: `cellarId`;
  - `test/u1/ui/cellar_screen_test.dart`, `test/u1/ui/cellar_retry_test.dart`, `test/dashboard/dashboard_harness.dart`: `noSharingOverrides()`.
- `integration_test/e2e_helpers.dart`: `emulatorRequest(..., bearer:)` e `ownerRestClient()`/`OwnerRestClient`, con `signInWithIdp` sull'emulatore di Auth, `idToken` e `localId`, e `documents:commit` con `REQUEST_TIME`.
- `.github/workflows/ci.yml`:
  - job `rules`: `npm run test:rules`, `tool/check_firestore_indexes.sh` e il suo test;
  - job `unit`: `tool/check_coverage.sh 80 coverage/lcov.info lib/sharing/`.
- `.github/workflows/firebase-deploy.yml`: `run-name` con il ref pubblicato; il job `rules` usa `npm run test:rules` e i due script.
- `.github/workflows/promote.yml`: passo "The rules of the build are the deployed ones", con `RULES_FEATURES: sharing`, che non gira per `halt`.
- `docs/release-checklist.md`: §1-quater Condivisione, §2 Data Safety, §3 ordine di pubblicazione, §5 controllo mensile.
- `docs/firebase-setup.md` §7: avviso sulle letture con la condizione principale e quella di riserva, più la nota sul rollback dell'indice.

Non toccati: `.gitignore`, `.mcp.json`, `release.yml`, `firebase.json`, `android/`.

## Decisioni di implementazione

- **Cantina attiva con `ref.listen`.** In Riverpod 3 un `Notifier` viene ricreato a ogni ricostruzione, quindi `ActiveCellarNotifier` non usa `ref.watch`: osserva con `ref.listen` e tiene la scelta nei propri campi. `build()` riparte dalla scelta salvata solo alla creazione e dopo un'invalidazione (reset, "Riprova").
- **Ordine del reset.** La scelta salvata si cancella **prima** che il reset invalidi gli ascolti, così una cantina attiva ricostruita non può rileggerla.
- **Avviso della cantina nuova.** Compare quando è questo telefono ad attivare l'invito (`invited` → `active`), quindi una volta per cantina senza dati nuovi sul telefono. Un secondo telefono della stessa persona non lo mostra.
- **Due testi di accesso perso.** `CellarAccessLost.fromQueuedWrite` distingue "Non hai più accesso alla cantina di Mario" da "Alcune modifiche alla cantina di Mario non sono state salvate perché non hai più accesso" (functional-spec.md). Ognuno compare una volta per cantina e sessione. Il nome viene dall'invito oppure dall'ultimo visto (`knownCellarOwnersProvider`); se manca, "qualcuno".
- **Revoca avvenuta ad app chiusa.** Se la cantina ricordata non è più nell'elenco quando gli inviti sono noti, la scelta si dimentica. Se l'invito è stato revocato dal proprietario, o è sparito, c'è anche l'avviso.
- **Selettore.** Compare come barra sotto la barra in alto del Cruscotto e della Cantina solo con più di una cantina, così senza condivisioni le schermate di U1 e U5 restano identiche (NFR7.5).
- **Regole: identità robusta.** `email()` e `verified()` leggono il token con `get(…, default)`: un token senza email o senza `email_verified` non dà accesso, invece di generare un errore di valutazione. Nella creazione dell'invito le regole rifiutano anche l'email del proprietario stesso; `memberOpKey` deve essere una stringa di al più 254 caratteri.
- **Contatore con `FieldValue.increment`.** L'app non legge `memberSlots` per scriverlo: l'incremento lato server dà `slotsBefore() ± 1` nelle regole, anche se la copia in cache è vecchia.
- **Ordine degli inviti.** Elenco principale e accessi chiusi sono ordinati per nome, o per email se il nome manca, senza maiuscole.
- **Permessi nelle schermate.** Con `read`, "Aggiungi" della Cantina sparisce del tutto (non solo disattivato). Il Cruscotto mostra il messaggio dello stato vuoto senza il pulsante. Non esistono ancora comandi di eliminazione, modifica o bevuta (arrivano con U4).

## Risultati delle verifiche (eseguite il 2026-11-06)

| Verifica | Risultato |
|---|---|
| `flutter test` prima delle modifiche (riferimento) | 610 test verdi |
| `npm run test:rules` prima delle modifiche (riferimento) | 30 test: 29 verdi, 1 saltato (nessun tag `v*`) |
| `flutter test test/sharing test/u1` (modello dei dati) | 371 test verdi |
| `flutter test test/sharing test/u1` (accesso ai dati) | 399 test verdi |
| `flutter test` (logica) | 704 test verdi |
| `flutter test` (interfaccia) | 815 test verdi |
| `flutter test test/sharing` | 195 test verdi |
| `flutter test test/u1 test/dashboard test/app test/account test/cellar` | 500 test verdi |
| `npm run test:rules` (emulatore Firestore con Java 17 locale; la CI usa Java 21) | 133 test: 132 verdi, 1 saltato (direzione 2 della compatibilità, nessun tag `v*`). Comprendono U1 (27), U7 (101, di cui 54 celle della matrice) e `compat/` (5) |
| `flutter test --coverage` (suite completa dell'app, dopo `dart run tool/gen_coverage_helper.dart`) | 815 test verdi (+205), nessuna regressione |
| Copertura di `lib/sharing/` | **98,41%** (868/882 righe), soglia 80% |
| Copertura dell'app (`coverage/lcov.info`) | 89,32% (4133/4627 righe), soglia 80% |
| Copertura di progetto (app più `estimation`, come in `ci.yml`) | **90,06%** (4476/4970 righe), soglia 80%, calcolata dai due lcov |
| Copertura di `lib/dashboard/` e `lib/catalog/` | 99,04% (621/627) e 99,35% (765/770) |
| `cd packages/estimation && dart test --coverage` | 321 test verdi; copertura 100,00% (343/343), soglia 90% |
| `tool/check_firestore_indexes.sh` | OK |
| `tool/check_firestore_indexes_test.sh` | OK: `ok.json` passa, `missing.json` fallisce con exit 1, un file assente è rifiutato |
| `tool/check_dashboard_readonly.sh` e il suo test, `tool/check_off_config.sh` | OK |
| `dart format --output=none --set-exit-if-changed .` | nessun file da formattare |
| `flutter analyze --fatal-infos` | nessun problema |

Ogni regola da BR1.1 a BR1.14 ha almeno un test con l'ID nel nome, nei test di Dart o in quelli delle regole. Le schermate nuove (vista del proprietario, vista della persona invitata, selettore, dialoghi di revoca e di uscita) sono provate:
- in it, en e pt-BR;
- con `textScaler` 1.0 e 2.0;
- in tema chiaro e scuro;
- con `textContrastGuideline`, `androidTapTargetGuideline` e `labeledTapTargetGuideline`.

## Test scritti ma non eseguiti in questa fase

- `integration_test/sharing_test.dart` e `ownerRestClient()` richiedono l'emulatore Android e la Firebase Emulator Suite: `adb devices` è vuoto su questo computer. Il file è analizzato da `flutter analyze --fatal-infos`. Gira nel job `e2e` di GitHub Actions o in Build and Test.
- La direzione 2 di `compat/`, cioè le regole dell'ultimo tag `v*` contro le scritture correnti con il salto di `requiresRules`, è saltata perché non esiste ancora un tag `v*`. Il controllo che ogni `requiresRules` compaia in `RULES_FEATURES` di `promote.yml` invece è eseguito ed è verde.
- I passi nuovi di `ci.yml`, `firebase-deploy.yml` e `promote.yml` girano solo in GitHub Actions. Qui sono stati eseguiti in locale gli stessi comandi di `ci.yml`. Il passo di `promote.yml`, che usa `gh api` e i tag `build-*`, non è eseguibile in locale e va verificato alla prima promozione.
- Le misure sul telefono (tempi delle operazioni, comparsa e revoca con due telefoni) e l'avviso di Cloud Monitoring si fanno a mano, come indicato in `docs/release-checklist.md` §1-quater e `docs/firebase-setup.md` §7.

## Scostamenti dal piano

- **Controllo delle regole pubblicate in `promote.yml`.** Il design leggeva il commit dall'API *deployments* dell'ambiente `firebase-prod`. Per un `workflow_dispatch`, però, GitHub registra la deployment sul commit del ramo da cui parte il workflow, non sul `ref` pubblicato. Il passo legge invece l'ultima esecuzione riuscita di `firebase-deploy.yml`, il cui nome (`run-name: firebase-deploy <ref>`, aggiunto) contiene il ref pubblicato. Poi confronta i blob di `firestore.rules` e `firestore.indexes.json` con quelli di `build-<versionCode>`. La garanzia resta la stessa: una versione non va in produzione con regole o indici diversi da quelli pubblicati. Il job ha il permesso `actions: read` invece di `deployments: read`.
- **`test/rules/u1.rules.test.mjs`** non era nominato nel piano. Il suo test "delete is denied in U1" avrebbe fallito, perché `security-design.md` §1 apre l'eliminazione dei vini al proprietario. Ora verifica che il proprietario possa eliminare e che un altro utente no. Gli altri test di U1 sono invariati e verdi.
- **Firme del repository.** `invite` riceve la `Cellar` (per `memberSlots` e il nome usato nel messaggio) e gli inviti già mostrati. `leave` e `activate` ricevono `AppUser`. Anche `revokeAllForUser` riceve `AppUser`, perché per gli inviti ricevuti serve l'email, non solo l'uid di C4. `canRead`/`canEdit` sono funzioni sull'elenco delle cantine accessibili.
- **Eccezione `leavingCellarIds`.** L'id esce dall'insieme quando la cantina riceve un nuovo invito, invece che quando sparisce dall'elenco. Così un `permission-denied` arrivato dopo il cambio dell'invito non mostra mai "Non hai più accesso" per un'uscita volontaria.
- **Motivi di errore in più.** Oltre ai quattro di `monitoring-design.md` ci sono `sharing_permission_failed`, `sharing_delete_failed` e `sharing_revoke_all_failed`, già elencati nel controllo mensile della checklist.
- **"Rinomina" non è nel menu della cantina.** L'app non ha ancora un comando di rinomina, quindi il menu ha solo "Persone", visibile a tutti. "Persone" è nel menu della Cantina e non nel Cruscotto, che non ha un menu della cantina.
- **Tempo massimo provato con `testWidgets`.** Le istruzioni dicevano `fakeAsync`, ma `fake_async` non è una dipendenza diretta e il piano non ne prevede l'aggiunta. Il test usa quindi il tempo finto di `testWidgets` (`tester.pump(9 s)`, poi `2 s`), senza attese vere.
- **Override nei test di U1 e U5.** `noSharingOverrides()` di `sharing_harness.dart` è stato aggiunto a `CellarFixture`, `DashboardStreams` e `cellar_retry_test.dart`, così quei test non dipendono dal servizio iniettato.
- **Permessi degli script.** `tool/check_firestore_indexes.sh` e `tool/check_firestore_indexes_test.sh` sono stati resi eseguibili con `chmod +x`, come gli altri script di `tool/`, perché la CI li lancia direttamente.
- Nessuna soglia di copertura è stata cambiata.

## Correzioni dopo la revisione (2026-11-06)

- **Major, riattivazione dopo un nuovo invito:** in `myMembershipsProvider` un id esce dall'insieme `activating` appena il suo invito non è più `invited` (attivato, revocato o uscito). Un reinvito con l'app aperta viene quindi riattivato. Nuovo test in `sharing_providers_test.dart`: invited → active → revoked → invited produce due `activate`.
- **Minor, traduzione degli errori:** `limitReached` e `alreadyInvited` si cercano solo per l'invito (`isInvite`). Una revoca o un cambio di permesso rifiutati danno `notOwner` anche con la cantina piena. Nuovo test in `sharing_repository_test.dart`.
- **Minor, ref di `firebase-deploy.yml`:** il workflow accetta solo un tag `v*` o un hash completo di 40 caratteri contenuto in `main`, così il ref letto da `promote.yml` non può spostarsi. Aggiornati la descrizione dell'input, `docs/firebase-setup.md` §8 e `docs/release-checklist.md` §3.
- **Minor accettato, limite del design:** ogni `permission-denied` su una scrittura in coda in una cantina condivisa produce `CellarAccessLost`, anche dopo un declassamento da `edit` a `read`. Il messaggio resta corretto ("alcune modifiche non sono state salvate"); un raffinamento è rimandato.
- **Da provare in seguito:** `integration_test/sharing_test.dart`, la direzione 2 di `compat/` e il passo `gh api` di `promote.yml`, rispettivamente in CI e alla prima promozione.
- **Dopo le correzioni:** `dart format`, `flutter analyze --fatal-infos` e `flutter test` sono verdi, con 817 test.
