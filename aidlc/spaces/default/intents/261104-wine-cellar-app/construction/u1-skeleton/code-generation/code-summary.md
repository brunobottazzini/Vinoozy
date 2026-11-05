# Code Summary — u1-skeleton

Scheletro funzionante di Vinoozy (Flutter + Firebase, Android): accesso Google, cantina personale `cellars/{uid}`, aggiunta di un vino scritto, uso offline con sincronizzazione, registro locale `ledger.v1` per il cambio di account, regole di sicurezza Firestore, pipeline GitHub Actions. Tutti i 16 step del piano sono stati eseguiti con il Testing Contract **test-after, strato per strato**.

## Ambiente usato

Flutter 3.47.9 (Dart 3.13.7), JDK 17, Node 22, emulatore Android `Medium_Phone_API_36.1` avviato senza finestra, Firebase Emulator Suite con il progetto `demo-vinoozy`. Nessun account Firebase o Google Play.

## Risultati dei comandi (prima esecuzione, prima della Revisione 1)

I risultati aggiornati dopo le correzioni sono nella sezione **Revisione 1** in fondo.

| Comando | Esito |
|---------|-------|
| `flutter test test/u1/` | **302 test passati, 0 falliti** |
| `npx firebase emulators:exec --only firestore --project demo-vinoozy "npm --prefix test/rules test -- u1.rules.test.mjs compat/"` | **30 test: 29 passati, 0 falliti, 1 saltato** (compatibilità con le regole del tag `v*` più recente: nessun tag esiste ancora) |
| Prova di riavvio (`integration_test/firestore_restart_probe_test.dart`, comando di `unit-test-instructions.md`) | **1/1 passato** |
| End-to-end (`integration_test/u1_skeleton_test.dart`, comando di `unit-test-instructions.md`) | **8/8 passati** (scenari 1–9; il 2 e il 3 sono nello stesso test) |
| `tool/verify_skeleton.sh` (comando proposto per la verifica dello scheletro: regole + prova + e2e) | **riuscito**: regole 29 + 1 saltato, prova 1/1, e2e 8/8 |
| `flutter test test/u1/ --coverage --coverage-path=coverage/u1.lcov.info` | 302 passati; copertura 82,17% (1383/1683 righe) |
| `dart run tool/gen_coverage_helper.dart`, `flutter test --coverage`, `tool/check_coverage.sh 80` (controllo della soglia) | **82,03% (1383/1686 righe) su tutto `lib/`, senza esclusioni**, soglia 80% rispettata |
| `tool/check_release_build.sh` (test di build dello Step 13) | **riuscito**: la build release non contiene `EmulatorGoogleAuthService`; la build `E2E=true` la contiene (controllo positivo) |
| `dart format --output=none --set-exit-if-changed .` | 0 file da riformattare |
| `flutter analyze --fatal-infos` | nessun problema |

## Copertura

- Tutto `lib/`: **82,03%**. Obiettivo di U1 (`unit-test-instructions.md`), solo con `test/u1/`: `lib/sync/` 98,3%, `lib/account/` 85,6%, `lib/cellar/` 97,9%.
- A 0% nei unit test restano solo gli adattatori che chiamano gli SDK Firebase reali e l'avvio: `lib/app/bootstrap.dart`, `lib/account/google_auth_service.dart`, `lib/app/crashlytics_sink.dart`, `lib/account/network_status.dart`, `lib/account/firebase_user_mapping.dart`, `lib/e2e/*`. Sono esercitati dagli end-to-end, che non producono copertura.
- `lib/l10n/app_localizations_pt.dart` è al 33,6%: contiene anche la classe di riserva `pt` (vedi deviazioni), mai usata per scelta di BR5.1.

## Prova di riavvio di Firestore (Step 9, NFR4.10)

**Esito: riuscita, piano A.** `terminate()`, `clearPersistence()` e `configure()` funzionano nello stesso processo: dopo il reset la lettura dal server (`Source.server`) riesce, le impostazioni (persistenza, cache illimitata, emulatore) sono quelle giuste e la scrittura messa in coda offline prima del reset è sparita dalla cache e non arriva mai al server. **Il piano B non è servito**: `kInProcessFirestoreReset = true` in `lib/firebase/firestore_bootstrap.dart`. Il codice del piano B (`resetPending`, schermata "Riavvia l'app per completare", `completePendingReset` all'avvio) è comunque presente e testato con unit test, perché `resetPending` fa parte di `ledger.v1`. Lo scenario e2e 6 (B elimina le modifiche di A) esercita lo stesso reset dall'interfaccia.

Nota: alla seconda esecuzione la prova è fallita una volta in un controllo preliminare (lettura dalla cache subito dopo un `set()` non atteso). Ho sostituito la singola lettura con un'attesa con nuovi tentativi; il reset in sé non era in causa. Da allora è passata.

## Misure degli end-to-end (emulatore locale, build di debug)

- **NFR1.1** (dal tocco su Salva alla riga nell'elenco, offline): **495 ms e 759 ms** in due esecuzioni (482 ms nella Revisione 1). È **sopra l'obiettivo di 300 ms**, misurato però su una build di debug in un emulatore. Il test usa 2 s solo come **limite provvisorio di non regressione** (`provisionalSaveToListLimit` in `integration_test/e2e_helpers.dart`), non come soglia del requisito. **NFR1.1 resta aperto** (`Deferred` in `traceability.json`) finché non è misurato sul telefono di riferimento con una build release (`docs/release-checklist.md` §1).
- **NFR2.1**: mediana **248–256 ms** su 5 avvii dopo un riscaldamento (260 ms nella Revisione 1), soglia 4 s. **Attenzione:** è un riavvio dentro lo stesso processo (`terminate()` di Firestore e nuovo `main()`), non un avvio a freddo del processo Android. **NFR2.1 resta aperto** (`Deferred` in `traceability.json`): l'avvio a freddo reale va misurato sul telefono con una build release (`docs/release-checklist.md` §1).

## Test scritti ma non eseguiti in questo stage

- **Workflow GitHub Actions** (`ci.yml`, `release.yml`, `promote.yml`, `firebase-deploy.yml`): non eseguiti, perché il repository non è ancora su GitHub e non ci sono account Firebase/Play. In particolare il job `e2e` su API 34 in CI, `release.yml` e `tool/play_api.sh` non sono mai girati.
- **Compatibilità con le regole precedenti** (`test/rules/compat/`, secondo test): saltato, nessun tag `v*` esiste ancora.
- ~~Riavvio con `adb shell am force-stop`~~: mancava nella prima esecuzione; **aggiunto ed eseguito nella Revisione 1** (R-02).
- **NFR2.2** (500 vini, fotogrammi) e smoke test su telefono reale: manuali, in `docs/release-checklist.md`.
- Test d'integrazione di `ensureProfile` con `onboardingSeen` già `true` sull'emulatore (verifica di NFR4.11): coperto solo da unit test con mock e dai test delle regole.

## Decisioni di implementazione principali

- **Isolamento:** solo repository, gateway, bootstrap e servizi di accesso importano gli SDK Firebase. `AccountGate`, `SyncWatcher`, `SyncStatusTracker`, `LocalLedger` e la UI lavorano su interfacce proprie (`AuthService`, `SyncGateway`, `KeyValueStore`, `Clock`, `IdGenerator`), testate con fake e `mocktail`.
- **`LocalLedger`:** un solo valore `ledger.v1`, coda seriale `_mutate` (catena di Future), scrittura su disco prima dell'aggiornamento in memoria; JSON corrotto rimesso a vuoto con `LedgerCorrupted` su `ErrorReporter`. `dismiss` e `noticeShown` rilasciano il proprietario nella stessa mutazione; `reset` conserva `resetPending`.
- **`WineRepository.create`:** attende `beginWrite`, poi `set()` non atteso; il callback confronta la `generation`; errori sincroni → `SaveFailure` con rimozione della voce del giornale, così il modulo può riprovare con lo stesso ID.
- **`SyncStatusTracker`:** ignora solo il primo snapshot di ogni ascoltatore (sempre dalla cache), poi segue subito `isFromCache` (fix della revisione 2 delle NFR Design, niente attesa di 2 s). Il passaggio da cache a server innesca `SyncWatcher`.
- **`SyncWatcher`:** una sola esecuzione alla volta, `waitForPendingWrites` con timeout di 30 s, verifica `Source.server` con timeout di 10 s, al massimo 3 ripetizioni immediate quando `seq` cambia. Dalla Revisione 1 verifica solo le voci presenti all'inizio del drain, rifà il drain prima di dichiarare `missing` e riconcilia le voci `rejected` (vedi R-01).
- **`AccountGate`:** controllo del registro a ogni avvio e dopo ogni accesso, prima di aprire qualsiasi ascoltatore; con la cantina già in cache la Cantina si apre subito e la transazione gira in background.
- **Avvio:** `Firebase.initializeApp`, poi App Check (solo progetto reale: Play Integrity in release, debug altrimenti), poi Crashlytics (solo release del progetto reale) e lettura del registro in parallelo.
- **Configurazione senza segreti:** `options_demo.dart` nel repository; `options_prod.dart` scelto con un import condizionale (`--dart-define=vinoozy.prod_options=true`, usato da `release.yml`); in sua assenza lo stub fa fallire subito l'avvio in prod.
- **Build release senza hook E2E:** `EmulatorGoogleAuthService` è referenziato solo dietro la costante `kIsE2EBuild` e viene eliminato dal tree shaking (verificato).
- **Test d'interfaccia:** ogni schermata è provata in it, en e pt-BR, con `textScaler` 1.0 e 2.0, tema chiaro e scuro, con le guide di contrasto, aree toccabili ed etichette e senza overflow.

## Difetti trovati dai test e corretti

- `ErrorReporter.sanitize` cancellava anche etichette lunghe come `LocalCacheWriteFailed` (filtro degli ID troppo largo): ora un token è un ID solo se mescola lettere e cifre.
- `StartupErrorApp` (schermata d'errore all'avvio) andava in errore perché il bus degli eventi non aveva un valore predefinito: ora `syncErrorBusProvider` ne crea uno.

## Deviazioni dal piano

| Punto del piano | Cosa è stato fatto | Motivo |
|-----------------|--------------------|--------|
| Step 1: `minSdk` 23 | `minSdk` **24** | FlutterFire 7 / Firebase Android BoM 35 richiede minSdk 24 (changelog di `firebase_core` 5.0.0). |
| Step 1: ultime versioni stabili | `firebase-tools` **14.27.0** invece di 15.35.0 | La 15 rifiuta Java < 21; il piano prevede JDK 17 e non ho installato altro. In CI i job `rules`/`e2e` usano comunque Java 21. |
| Step 1: `package.json` con due pacchetti | aggiunto anche `firebase` 13.2.0 | È la dipendenza peer obbligatoria di `@firebase/rules-unit-testing` 6. |
| Step 1: ARB it, en, pt-BR | aggiunto `app_pt.arb` con il solo `@@locale` | `flutter gen-l10n` rifiuta `pt_BR` senza un file base `pt`. I testi restano in `app_pt_BR.arb`; un telefono in pt-PT riceve l'inglese (BR5.1). Costa circa 80 righe non coperte. |
| Step 3: `schemaVersion` 1 per `Wine` | `schemaVersion` solo su `users` e `cellars` | C3 e le regole (`validWineCreate`: solo i campi di C3) non prevedono `schemaVersion` nei vini. |
| Step 5/8: `ErrorReporter` allo Step 8 | scritto allo Step 5 | Serve al registro per segnalare il JSON corrotto. |
| Step 11: `firestore.rules` | scritto prima dello Step 9 | La prova di riavvio scrive sull'emulatore, che applica le regole. I test delle regole sono allo Step 11 come da piano. |
| performance-design: `itemExtent` fisso / `prototypeItem` | `ListView.builder` senza altezza fissa | Con nomi fino a 120 caratteri e testo al 200% un'altezza fissa taglierebbe il testo (NFR3.4). L'elenco resta pigro. |
| performance-design: `flutter_native_splash` | non aggiunto | Non è in `tech-stack-decisions.md` né nel piano; resta la splash nativa predefinita di Android (`launch_background`). |
| Step 14: scenario 8 con `adb force-stop` | scenario 8 nello stesso processo **più** il passo separato `tool/e2e_force_stop.sh` (Revisione 1) | Il riavvio reale non si può fare dentro `flutter test`: il test girerebbe nel processo che viene ucciso. Vedi R-02. |
| Step 14: "avvio a freddo misurato" | riavvio nello stesso processo | Vedi "Misure". |
| Step 15: `release.yml` | simboli di Crashlytics in un job separato `crashlytics-symbols`, senza chiavi (WIF) e con `firebase-tools` dal lockfile (Revisione 1, R-04) | `infrastructure-specification.md` non prevede un'identità per caricare i simboli: è un'estensione dell'uso di WIF già previsto per `firebase-deploy.yml`, documentata in `docs/firebase-setup.md` §4. La riga della specifica va aggiunta (vedi R-04). |
| Step 15: versionCode da Play | `tool/play_api.sh` (curl + `gcloud`) | Nessuna azione esistente dà il versionCode più alto tra i canali. |
| Test di build | `tool/check_release_build.sh` esegue `flutter clean` | Dopo una build `integration_test` nella stessa cartella, la build release non compila (registro dei plugin con il plugin di sviluppo). |

Altre note:
- Durante la prima build Gradle ha scaricato da solo **Android SDK Platform 35** e **CMake 3.22.1** in `~/Library/Android/sdk`.
- `flutter test` sul dispositivo prova a disinstallare `com.vinoozy.vinoozy` (il namespace) invece di `com.vinoozy.app`: fallisce senza effetti, ma i dati dell'app restano sull'emulatore tra un'esecuzione e l'altra. Gli e2e puliscono comunque telefono ed emulatori all'inizio di ogni test.
- Nel solo harness dei test dei widget `InkSparkle` è sostituito da `InkRipple`, perché il backend dei test non ha lo shader; i colori non cambiano.
- In `test/helpers/firestore_mocks.dart` è soppresso `subtype_of_sealed_class` (mock dei tipi `@sealed` dell'SDK), con la motivazione nel file.
- `.mcp.json` non è stato toccato; `.gitignore` ha solo righe aggiunte dopo il blocco AI-DLC.
- Il file d'esempio `test/widget_test.dart` creato da `flutter create` è stato cancellato.

## File creati o modificati

L'elenco completo è in `source-manifest.json`. In sintesi:

- **Configurazione:** `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `l10n.yaml`, `.flutter-version`, `.nvmrc`, `.gitignore` (righe aggiunte), `package.json`, `package-lock.json`, `firebase.json`, `.firebaserc`, `firestore.indexes.json`, `firestore.rules`.
- **Android** (da `flutter create`, poi modificati): `android/app/build.gradle.kts` (applicationId, minSdk, firma da variabili d'ambiente), manifest principale e di debug, `network_security_config.xml` (solo debug), `data_extraction_rules.xml`.
- **`lib/`:** `core/`, `firebase/`, `cellar/{domain,data,ui}/`, `account/{,data,ui}/`, `sync/{,ledger,ui}/`, `app/`, `e2e/`, `l10n/` (ARB e file generati), `main.dart`.
- **Test:** `test/helpers/`, `test/u1/{domain,data,sync,account,ui}/`, `test/u1/smoke_test.dart`, `test/rules/` (regole e compatibilità), `integration_test/` (prova di riavvio, e2e, helper).
- **Strumenti:** `tool/gen_coverage_helper.dart`, `tool/check_coverage.sh`, `tool/check_release_build.sh`, `tool/verify_skeleton.sh`, `tool/play_api.sh`.
- **CI/CD:** `.github/workflows/{ci,release,promote,firebase-deploy}.yml`, `.github/dependabot.yml`.
- **Documentazione:** `docs/firebase-setup.md`, `docs/release-checklist.md`.

## Punti aperti per le revisioni e per Build and Test

1. NFR1.1 e NFR2.1 aperti (`Deferred`): misure in debug sull'emulatore; si chiudono con le misure in release sul telefono di riferimento (`docs/release-checklist.md` §1). Il proprietario ne registra l'accettazione al gate.
2. ~~Scenario `adb force-stop` non implementato~~: fatto nella Revisione 1.
3. Workflow CI/CD mai eseguiti: vanno fatti girare al primo push (SHA delle azioni ora verificati, vedi R-06), prima di fidarsi dei gate. L'identità WIF per i simboli di Crashlytics va riportata in `infrastructure-specification.md`.
4. Il comando di verifica proposto è `tool/verify_skeleton.sh` (ora con la prova `adb force-stop`); va scelto e autorizzato dal proprietario.

## Revisione 1

Il proprietario ha scelto **Request Changes** ("Vai con le correzioni") sulla revisione `review-01.md`: corretti i due Major e tutti i Minor. Nessun commit, nessun ramo.

### R-01 (Major) — `SyncWatcher` poteva marcare `rejected` un vino ancora in volo

**Correzione** (`lib/sync/sync_watcher.dart`):
- Ogni passaggio legge il registro **prima** del drain e verifica solo le voci presenti in quel momento: le loro scritture sono state avviate prima di `waitForPendingWrites()`, quindi il drain le copre. Una voce aggiunta durante il drain resta `open`; la scrittura nuova sposta `seq`, quindi il passaggio successivo parte subito e la verifica dopo il proprio drain.
- Una voce `open` trovata `missing` non diventa subito `rejected`: il watcher rifà il drain e rilegge il server; solo se manca ancora viene rifiutata (con `SyncRejected`). Se il secondo drain va in timeout la voce resta `open`.
- Le voci `rejected` vengono rilette a ogni passaggio: se il vino è arrivato sul server la voce è confermata e l'avviso sparisce; altrimenti restano come sono, senza un nuovo evento.
- "Aggiungi di nuovo" non crea più doppioni: prima di aprire il modulo `RejectedWineNotices` chiama `SyncWatcher.reconcileRejected`. Se il vino è nella cache del telefono già confermato, o è sul server, la voce è confermata e il modulo non si apre; se è ancora in coda sul telefono la voce torna `open` (nuovo `LocalLedger.reopen`, avvisi azzerati) e parte una verifica. Solo se il vino non c'è né sul telefono né sul server la voce viene tolta e si apre il modulo. Per leggere la cache offline `SyncGateway` ha il nuovo metodo `checkLocal` (`Source.cache`, risultato `absent`/`pending`/`synced`).

**Test:**
- `test/u1/sync/sync_watcher_test.dart`: `FakeGateway` può rispondere `missing` per un ID in volo e leggere la cache (`localResults`). Nuovi test: voce aggiunta durante il drain con `missing` (non rifiutata, confermata al passaggio dopo); `missing` al primo controllo ed `exists` dopo il secondo drain; `missing` anche dopo il secondo drain (rifiutata una volta); timeout del secondo drain (resta `open`); voce `rejected` poi trovata sul server (confermata); voce `rejected` ancora assente (nessun nuovo evento); sei test di `reconcileRejected`. **Prova che falliscono sul codice vecchio:** rimessa temporaneamente la logica precedente di `_runOnce`/`_apply`, **5 dei 6 test del gruppo dei passaggi falliscono** (passa solo "rejected ancora assente", che descrive un comportamento già corretto prima); poi ripristinato il codice nuovo.
- `test/u1/sync/sync_gateway_test.dart`: 4 test di `checkLocal`.
- `test/u1/ui/rejected_wine_notice_test.dart`: "Aggiungi di nuovo" su un vino non perso non apre il modulo e non crea doppioni.
- E2E `3b` in `integration_test/u1_skeleton_test.dart`: due vini aggiunti offline, poi la rete torna; entrambi arrivano al cloud, il registro `ledger.v1` sul telefono torna vuoto (proprietario rilasciato) e non compare nessun avviso. Passato. Non l'ho fatto girare sul codice vecchio: la prova di regressione sono i unit test sopra.

### R-02 (Major) — riavvio con `adb force-stop` segnato come fatto ma assente

**Correzione:** implementato come in `cicd-pipeline.md` §1, come passo separato.
- `tool/e2e_force_stop.sh`: (1) `flutter drive --keep-app-running` esegue `integration_test/force_stop_queue.dart` (accesso, rete spenta, vino "Sangiovese" aggiunto, voce del registro scritta su disco) e lascia l'app in esecuzione con la scrittura in coda; (2) controlla che il cloud non abbia il vino e che il processo sia vivo; (3) `adb shell am force-stop com.vinoozy.app` e controllo che il processo sia morto e che il cloud non abbia ancora il vino; (4) installa sopra l'app vera (`lib/main.dart`, build `E2E=true`) con `adb install -r`, che conserva i dati, e la avvia con `adb shell am start`; (5) verifica che il vino sia sullo schermo (`uiautomator dump`) e che arrivi all'emulatore Firestore.
- `flutter drive` (con `test_driver/integration_test.dart` e la dipendenza di sviluppo `flutter_driver` dell'SDK) serve perché `flutter test` non lascia l'app in esecuzione. Il file della fase 1 non finisce in `_test.dart`, così `flutter test integration_test` non lo esegue.
- Collegato al job `e2e` di `ci.yml` (in entrambi i tentativi, dopo `flutter test integration_test`; timeout del job portato da 30 a 45 minuti) e a `tool/verify_skeleton.sh`.
- **Eseguito in locale** su `Medium_Phone_API_36.1` senza finestra con gli emulatori Firebase: riuscito due volte (da solo e dentro `tool/verify_skeleton.sh`). La voce 8 dello Step 14 del piano ora descrive il riavvio nello stesso processo e il passo con `adb` è una voce a sé, spuntata perché esiste ed è stato eseguito.

### R-03 (Minor) — NFR1.1 e NFR2.1 dichiarati `OK`

`traceability.json`: NFR1.1 e NFR2.1 ora `Deferred` (aperti), con riferimento a `docs/release-checklist.md` §1. Nell'e2e la soglia di 2 s è la costante `provisionalSaveToListLimit`, commentata come limite provvisorio di non regressione e non come obiettivo del requisito. Nella checklist di rilascio è stata aggiunta la misura di NFR1.1 (300 ms, build release sul telefono). L'accettazione al gate spetta al proprietario.

### R-04 (Minor) — chiave a lunga durata e `npx --yes` nel job con i segreti di firma

`release.yml`: tolto il passo dei simboli dal job `internal` insieme al segreto `FIREBASE_SYMBOLS_SA_JSON`. Nuovo job `crashlytics-symbols` (`needs: internal`), che non ha i segreti di firma, di Play né la configurazione di produzione: ambiente GitHub `crashlytics-symbols`, `permissions: contents: read, id-token: write`, accesso senza chiavi con WIF (`google-github-actions/auth`, stesso pool e provider di `firebase-deploy.yml`, account di servizio dedicato con solo `roles/firebasecrashlytics.admin` e `roles/serviceusage.serviceUsageConsumer`), `npm ci` e `npx firebase` dalla versione bloccata in `package-lock.json`, simboli presi dall'artifact della build (`actions/download-artifact` fissato per SHA, v8.0.2). Il job si salta finché mancano `FIREBASE_ANDROID_APP_ID` e `CRASHLYTICS_WIF_SERVICE_ACCOUNT`. `docs/firebase-setup.md` §4 descrive pool, condizione (`assertion.environment in ['firebase-prod', 'crashlytics-symbols']`), i due account con i loro ruoli e il legame `workloadIdentityUser` limitato al singolo ambiente; §5 dice di cancellare il vecchio segreto se esiste; §6 aggiunge l'ambiente. Nota: lo strumento di upload di Crashlytics scarica un suo componente Java quando parte; ora succede in un job senza segreti di firma o di Play.
**Da fare fuori dal codice:** `infrastructure-specification.md` (design già approvato) non è stato modificato da questo stage; la riga dell'identità WIF per i simboli va aggiunta lì alla prossima revisione del design, oppure registrata dal proprietario come estensione accettata.

### R-05 (Minor) — token di scrittura nella configurazione git per tutta la build

`release.yml`: `actions/checkout` con `persist-credentials: false` (anche nel nuovo job). Il token arriva solo al passo del tag, come variabile d'ambiente, e viene passato a `git push` con un header valido per quel solo comando, senza scriverlo in `.git/config`.

### R-06 (Minor) — workflow mai eseguiti, `halt` con 0.2 fisso

- `tool/play_api.sh halt`: non impone più `userFraction` 0.2. Legge la traccia di produzione, mette in `halted` solo la release `inProgress` di quel `versionCode` e riscrive tutto il resto invariato (la frazione a cui era arrivata e la release completata precedente). Se non c'è un rilascio graduale in corso esce con errore senza cambiare nulla. Provato in locale con `jq` su due tracce d'esempio (con e senza rilascio in corso); l'API di Play non è stata chiamata. Aggiornata la riga in `docs/release-checklist.md` §4.
- SHA delle azioni: **verificati** con `git ls-remote` sui repository delle azioni: tutti i 9 SHA usati corrispondono al tag indicato nel commento.
- I workflow restano mai eseguiti su GitHub (il repository non è ancora su GitHub): vanno fatti girare al primo push, `e2e` e `release` fino all'upload compresi.

### R-07 (Minor) — deviazioni da documentare

minSdk 24, `firebase-tools` 14.27.0 (la 15 richiede Java 21) e `app_pt.arb` minimo sono documentati nel `README.md` (sezione "Scelte tecniche che si discostano dal piano", che sostituisce il README d'esempio di `flutter create`) e restano nella tabella delle deviazioni qui sopra. `tech-stack-decisions.md` (design approvato) non è stato modificato.

### Risultati dopo la Revisione 1 (eseguiti il 2026-11-05)

| Comando | Esito |
|---------|-------|
| `dart format --output=none --set-exit-if-changed .` | 0 file da riformattare (93 file) |
| `flutter analyze --fatal-infos` | nessun problema |
| `flutter test test/u1/` | **319 test passati, 0 falliti** (erano 302; +17) |
| `dart run tool/gen_coverage_helper.dart`, `flutter test --coverage`, `tool/check_coverage.sh 80` | **82,53% (1431/1734 righe) su tutto `lib/`, senza esclusioni**; soglia 80% rispettata. `sync_watcher.dart` 99/101, `sync_gateway.dart` 19/19, `rejected_wine_notice.dart` 45/45, `local_ledger.dart` 103/104 |
| Regole Firestore (dentro `tool/verify_skeleton.sh`) | **30 test: 29 passati, 0 falliti, 1 saltato** (compatibilità con un tag `v*` che non esiste ancora) |
| Prova di riavvio di Firestore | **1/1 passato** |
| E2E `integration_test/u1_skeleton_test.dart` | **9/9 passati** (scenari 1, 2-3, 3b nuovo, 4–9); NFR1.1 482 ms, NFR2.1 mediana 260 ms (misure in debug, requisiti aperti) |
| `tool/e2e_force_stop.sh` (nuovo) | **riuscito**: "Sangiovese" sopravvissuto a `am force-stop`, ricomparso dopo `am start` e arrivato al cloud |
| `tool/verify_skeleton.sh` | **riuscito**: regole, prova, e2e 9/9, force-stop |
| `tool/check_release_build.sh` | **riuscito**: build release senza `EmulatorGoogleAuthService`, build `E2E=true` con (controllo positivo) |

Emulatore Android `Medium_Phone_API_36.1` avviato senza finestra per le prove e spento alla fine.

### File toccati nella Revisione 1

- Codice: `lib/sync/sync_watcher.dart`, `lib/sync/sync_gateway.dart`, `lib/sync/ledger/local_ledger.dart`, `lib/sync/ui/rejected_wine_notice.dart`.
- Test: `test/u1/sync/sync_watcher_test.dart`, `test/u1/sync/sync_gateway_test.dart`, `test/u1/ui/rejected_wine_notice_test.dart`, `test/u1/ui/cellar_screen_test.dart` (stub del nuovo metodo nella fixture), `integration_test/u1_skeleton_test.dart`, `integration_test/e2e_helpers.dart`, nuovi `integration_test/force_stop_queue.dart` e `test_driver/integration_test.dart`.
- Strumenti e CI: nuovo `tool/e2e_force_stop.sh`, `tool/verify_skeleton.sh`, `tool/play_api.sh`, `.github/workflows/ci.yml`, `.github/workflows/release.yml`, `pubspec.yaml` e `pubspec.lock` (`flutter_driver` di sviluppo, dall'SDK).
- Documentazione: `README.md`, `docs/firebase-setup.md`, `docs/release-checklist.md`.
- Registro: `code-generation-plan.md` (Step 14), `traceability.json`, `source-manifest.json` (aggiunto `test_driver/`), questo file.

## Revisione 2 (dopo la seconda revisione)

- **Permesso di esecuzione di `tool/play_api.sh`** (Major): ripristinato con `chmod +x`. Al primo commit va aggiunto con il bit eseguibile (`git add --chmod=+x tool/play_api.sh` se serve).
- **Variabili del job `crashlytics-symbols`** (Minor): `docs/firebase-setup.md` §4 ora indica `CRASHLYTICS_WIF_SERVICE_ACCOUNT` e `FIREBASE_ANDROID_APP_ID` come variabili del repository, perché la condizione `if` del job viene valutata prima che il job entri nel suo ambiente. `release.yml` non cambia.
- **Nuova identità WIF per i simboli di Crashlytics** (Minor): resta un'estensione della specifica infrastrutturale, da accettare esplicitamente dal proprietario al gate. Finché le variabili non sono impostate, il job resta saltato.
