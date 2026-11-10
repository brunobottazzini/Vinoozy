# Riepilogo della generazione del codice — Freemium e Plus

Intent `261110-freemium-plus`, scope `express`, zero Unit, progetto brownfield. Piano: `code-generation-plan.md` (Step 1–21, tutti spuntati). Istruzioni dei test: `unit-test-instructions.md`. Base e deviazioni passo per passo: `baseline.md`.

Metodo di test seguito (Testing Contract del piano): **test-after, strato per strato**. Ogni strato è stato prima implementato, poi testato, e si è passati al successivo solo con i test verdi.

Nessun commit, nessuna pubblicazione su progetti Firebase, Google Cloud o Google Play reali. Tutti i test girano sugli emulatori `demo-vinoozy`.

## File creati e modificati, per area

### Dominio, dati e logica dell'app (Flutter)

- **Nuovi:** `lib/plan/` (diritti, policy, risoluzione del piano, guardia del limite, sessione, provider, wiring, avvisi, billing, schermate), `lib/usage/` (misuratore, costo intero, uploader, client `reportUsage`), `lib/ads/` (idoneità, gateway AdMob, slot del Cruscotto, client degli slot), `lib/dev/` (strumenti sviluppatore, sequenza segreta, fixture dell'emulatore, pannello), `lib/cellar/data/active_wine_counter.dart`, `lib/sync/capacity_rejection.dart`, `lib/firebase/functions_config.dart`.
- **Modificati:** `lib/cellar/data/wine_repository.dart`, `cellar_repository.dart`, `drinking_record_repository.dart`, `server_or_cache.dart`, `lib/cellar/domain/cellar.dart`, `lib/cellar/cellar_providers.dart`, schermate della cantina (aggiunta, modifica, dettaglio, bevuta), `lib/app/bootstrap.dart`, `providers.dart`, `home_shell.dart`, `ui/brand_footer.dart`, `vinoozy_app.dart`, `lib/account/` (profilo, reset), `lib/dashboard/ui/dashboard_screen.dart`, `lib/sharing/data/sharing_repository.dart`, `lib/sync/` (ledger, bus degli errori, avviso di rifiuto), `lib/l10n/app_{it,en,pt_BR}.arb` e file generati, `pubspec.yaml` (`in_app_purchase`, `google_mobile_ads`, `cloud_functions`).
- **In questo passaggio (Step 18–21):** `lib/plan/billing/purchase_verifier.dart` e `lib/plan/ui/plan_labels.dart` (nome del pacchetto Play, vedi Deviazioni).

### Regole Firestore

- `firestore.rules`: raccolte `entitlements`, `config`, `usage`, `adSlots`, `purchases`; contatore `activeWineCount`/`activeOpWineId` e limite sulle scritture dei vini.
- `test/rules/freemium.rules.test.mjs` (nuovo), `package.json` (`test:rules` con `style_profiles` e `freemium`, `test:functions`, `test:admin`).

### Backend (Cloud Functions) e script amministrativi

- `functions/` (nuovo): `src/` (9 funzioni in `europe-west8`, client Play e Billing iniettati), `test/` (mocha sugli emulatori), `README.md`, `firebase.json` (sezione `functions` ed emulatore).
- `tool/admin/` (nuovo): `grant_plus.mjs`, `set_policy.mjs`, `migrate_capacity.mjs`, `lib/admin_context.mjs`; `test/admin/` (nuovo); `.gitignore` (chiavi degli account di servizio).
- **In questo passaggio:** `functions/src/config.ts`, `functions/README.md`, `functions/test/play_rtdn.test.ts`, `functions/test/domain.test.ts` (nome del pacchetto Play e test di regressione).

### End-to-end (Step 18)

- `integration_test/freemium_test.dart` (nuovo): 3 test.
  - Plus in regalo scritto da `grant_plus.mjs --emulator` mentre l'app è sul Profilo, che mostra «Plus in regalo» senza azioni dell'utente (FR4.1, FR4.3).
  - Limite acceso via fixture con 15 schede attive: «Aggiungi» apre la spiegazione e non scrive nulla; sequenza segreta (logo ×2, Cantina ×3, Storico ×3, Cantina, Storico, Cruscotto), «Sblocca tutto», conferma dell'emulatore; la sedicesima scheda viene salvata, passa le regole e porta `activeWineCount` a 16 nell'emulatore (FR2.4, FR2.5, FR5.2, FR5.3, FR5.6).
  - `reportUsage` chiamata attraverso l'emulatore delle funzioni con il provider di debug di App Check di una build demo (FR6.3; verifica del rischio App Check di `baseline.md`).
- `tool/e2e_freemium.sh` (nuovo): avvia in background `grant_plus.mjs grant --email gift@example.com --no-expiry --reason gift --emulator`, ritentato ogni 2 s finché l'account esiste nell'emulatore Auth, poi `flutter test integration_test/freemium_test.dart` con `ENABLE_DEV_CHEATS=true`. Fallisce se i test falliscono o se il regalo non è mai stato scritto.
- Nell'esecuzione normale `flutter test integration_test` (senza flag) i 3 test risultano saltati: girano solo tramite lo script.

### Build e CI (Step 19)

- `.github/workflows/ci.yml`:
  - job `unit`: nuovo passo `flutter test --dart-define=ENABLE_DEV_CHEATS=true test/dev/ui`; timeout da 30 a 40 minuti per la terza build di `check_release_build.sh`;
  - job `rules`: `npm ci --prefix functions`, `npm run test:functions`, `npm ci --prefix tool/admin`, `npm run test:admin`; timeout da 15 a 25 minuti;
  - job `e2e`: `npm ci` e build di `functions/`, `npm ci --prefix tool/admin`, emulatori con anche Functions (attesa su «All emulators ready»), `tool/e2e_freemium.sh` dopo `tool/e2e_force_stop.sh` in entrambi i tentativi; timeout da 45 a 60 minuti.
  - Copertura all'80% invariata. Nessun workflow pubblica le funzioni (`firebase-deploy.yml` resta `--only firestore:rules,firestore:indexes`).
- `.github/workflows/release.yml`: `ADMOB_APP_ID: ${{ secrets.ADMOB_APP_ID }}` nella build firmata; senza segreto `android/app/build.gradle.kts` usa l'App ID di test di Google.
- `tool/check_release_build.sh`: marker `VINOOZY_DEV_CHEATS_PANEL` assente nella release normale **e** nella release costruita per errore con `ENABLE_DEV_CHEATS=true`; controllo positivo in una build `--profile` con il flag; nel manifest unito della release `com.android.vending.BILLING`, `com.google.android.gms.permission.AD_ID` e il meta-data `APPLICATION_ID` di AdMob attesi.
- `android/app/build.gradle.kts` e `AndroidManifest.xml`: placeholder `admobAppId` (fatto allo Step 1/16, verificato qui).

### Documentazione (Step 20)

- **Nuovi:** `docs/blaze-switch.md` (Spark → Blaze: budget di 1 €, topic `budget-alerts`, Cloud Billing API e ruolo Project Billing Manager all'account delle funzioni, pulizia di Artifact Registry con le ultime 2 immagini, deploy in `europe-west8`, prova del budget sotto soglia, accensione di `purchasesEnabled`); `docs/plus-setup.md` (prodotto `vinoozy_plus` con piani `monthly`/`annual`, tester di licenza, Play Developer API all'account delle funzioni, topic `play-rtdn` e RTDN, App Check, interruttori di `config/policy` con `set_policy.mjs`, credenziali degli script, esempi di `grant_plus.mjs` per regalo e revoca, `migrate_capacity.mjs` subito prima di `capacityLimitEnabled` con la questione della versione minima, annunci e dichiarazioni Play, dati alla cancellazione).
- **Aggiunte** (senza toccare le modifiche non committate del proprietario): `docs/privacy/index.html`, `docs/privacy/en/index.html`, `docs/privacy/pt-BR/index.html` (paragrafo su Plus, misurazione e annunci, conservazione e cancellazione); `docs/account-deletion/index.html`, `en/`, `pt-BR/` (piano, contatori e registro degli annunci cancellati; record minimo d'acquisto; l'abbonamento si annulla in Google Play); `docs/release-checklist.md` §2 (righe della scheda «Sicurezza dei dati» e voci di controllo per Freemium e Plus); `docs/firebase-setup.md` (rimando a `blaze-switch.md`).

## Decisioni principali

- D1–D7 del piano applicate come scritte, con le deviazioni sotto.
- E2E del regalo con lo script vero: l'unico modo di usare `grant_plus.mjs` da un test che gira sul telefono è eseguirlo sull'host. Lo script ritenta finché l'account esiste, così l'app riceve il regalo dal listener mentre è sul Profilo.
- E2E sul limite con fixture REST dell'emulatore (`config/policy` e 15 schede scritti come amministratore), come gli altri E2E del progetto: il test verifica l'interfaccia, le regole e il contatore, non la migrazione (coperta da `test:admin`).
- Il controllo del marker in una release con `ENABLE_DEV_CHEATS=true` usa la build di controllo già esistente (E2E+PERF), così le build restano due più quella di profilo.

## Deviazioni

Tutte le deviazioni degli Step 1–17 sono in `baseline.md`, sezione «Deviazioni», e restano valide: segnale «cantina non migrata» su `legacyActiveWineLimit`; parametro `storedQuantity` di `incrementQuantity`; unione in due batch; uscite dal filtro contate come letture; motivo del rifiuto dopo un riavvio; `test:functions` che compila prima degli emulatori e nuovo `test:admin`; `onUserDeleted` di 1ª generazione; token d'acquisto in `purchases/{sha256}`; raccolte server `playEvents` e `billingEvents`; RTDN su token mai verificato; guardia sul diritto; riconciliazione sui `purchases`; `TOO_FREQUENT` in `reportUsage`; callable `recordAdOutcome`; dipendenza `cloud_functions`; App Check di debug nelle build demo; `PERIOD_CLOSED`; client allineati a `functions/README.md`; contatori d'uso conservati al logout; base plan letto in modo dinamico; sequenza segreta testata con il flag; spiegazione della soglia solo con gli annunci accesi.

Nuove in questo passaggio:

- **Nome del pacchetto Play corretto da `com.vinoozy.vinoozy` a `com.vinoozy.app`.** Il piano (Step 12 e 16) indicava `com.vinoozy.vinoozy`, che però è il namespace Kotlin. Il pacchetto di Google Play è l'`applicationId` `com.vinoozy.app` (`android/app/build.gradle.kts`, `release.yml`, `docs/vinoozy-pubblicazione-checklist.md`). Con il valore del piano ogni acquisto sarebbe fallito: l'app inviava `packageName` sbagliato, il server interrogava Play con un pacchetto inesistente e tutte le RTDN venivano scartate come `ignored-package`. Corretti `functions/src/config.ts`, `lib/plan/billing/purchase_verifier.dart`, il link di gestione in `lib/plan/ui/plan_labels.dart`, `functions/README.md` e i test; aggiunti due test di regressione (Dart e TypeScript) che leggono l'`applicationId` da `build.gradle.kts`.
- **E2E in uno script dedicato.** Il piano chiedeva di aggiungere l'E2E al job esistente: lo è, ma come terza riga dello script dell'emulatore (`tool/e2e_freemium.sh`), perché serve una build con `ENABLE_DEV_CHEATS=true` e un processo sull'host. Il job E2E avvia ora anche l'emulatore Functions, quindi tutti gli E2E raggiungono le callable vere invece di una connessione rifiutata.
- **Terzo test E2E su `reportUsage`**, non previsto dal piano, chiesto dal conductor per verificare il rischio App Check.
- **Timeout dei job CI alzati** (`unit` 40, `rules` 25, `e2e` 60 minuti) per le build e le suite in più. Nessuna soglia di qualità è cambiata.

## Risultati dei test

### Base prima delle modifiche (Step 2, da `baseline.md`)

| Comando | Test | Passati | Falliti | Saltati |
|---|---|---|---|---|
| `flutter test` | 2645 | 2645 | 0 | 0 |
| `npm run test:rules` | 217 | 215 | 0 | 2 |

La copertura prima delle modifiche non era stata registrata nella base.

### Dopo gli Step 1–21 (eseguiti il 2026-11-10)

| Comando | Test | Passati | Falliti | Saltati |
|---|---|---|---|---|
| `dart format --output=none --set-exit-if-changed .` | — | 534 file, 0 cambiati | — | — |
| `flutter analyze --fatal-infos` | — | nessun problema | — | — |
| `flutter test --coverage` (suite completa) | 2878 | 2875 | 0 | 3 |
| `flutter test --dart-define=ENABLE_DEV_CHEATS=true test/dev/ui` | 12 | 12 | 0 | 0 |
| `dart test` di `packages/estimation` | 2011 | 2011 | 0 | 0 |
| `npm run test:rules` | 287 | 285 | 0 | 2 |
| `npm run test:functions` | 70 | 70 | 0 | 0 |
| `npm run test:admin` | 13 | 13 | 0 | 0 |
| `tool/e2e_freemium.sh` (emulatore Android, Emulator Suite con Functions) | 3 | 3 | 0 | 0 |
| `tool/check_release_build.sh` | — | tutti i controlli ok | — | — |

Copertura delle righe (`tool/check_coverage.sh`, soglia 80% invariata, nessuna esclusione):

| Ambito | Copertura |
|---|---|
| **Progetto** (app + `packages/estimation`, `coverage/merged.lcov.info`) | **88,11%** (19217/21810), soglia 80%: superata |
| `lib/catalog/` | 99,19% |
| `lib/dashboard/` | 98,82% |
| `lib/sharing/` | 98,45% |
| `lib/cellar/` | 94,53% |
| `lib/label/` | 96,99% |
| `lib/account/` | 97,47% |
| `lib/plan/` (nuovo, senza soglia propria in CI) | 79,75% (693/869) |
| `lib/usage/` (nuovo, senza soglia propria in CI) | 86,65% (409/472) |
| `lib/ads/` (nuovo, senza soglia propria in CI) | 74,03% (191/258) |
| `lib/dev/` (nuovo, senza soglia propria in CI) | 89,81% (141/157) |

- Suite Flutter: 2875 passati contro i 2645 della base (+230, tutti di questo lavoro) e contro i 2874 dopo lo Step 17 (+1, regressione sul pacchetto Play in `test/plan/billing/callable_contracts_test.dart`).
- I 3 test saltati della suite Flutter sono quelli della sequenza segreta nella `HomeShell`: esistono solo con `ENABLE_DEV_CHEATS=true` e girano nella riga dedicata (12/12), ora anche in CI.
- `npm run test:functions`: 70 test, uno in più dei 69 dello Step 14 (regressione sul pacchetto Play).
- I 2 test saltati di `test:rules` si saltano per scelta del test stesso, come nella base.

### Misure della build

- `tool/check_release_build.sh` (eseguito in locale, circa 3 minuti, tre AAB arm64): marker E2E, PERF e locale assenti nella release e presenti nel controllo positivo; `VINOOZY_DEV_CHEATS_PANEL` assente nella release normale e in quella con il flag, presente nella build di profilo con il flag; nel manifest unito `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE` assenti, `BILLING`, `AD_ID` e `APPLICATION_ID` di AdMob presenti, filtri di condivisione invariati.
- `tool/check_app_size.sh`: **non può confrontare**, perché `tool/app_size_baseline.txt` è ancora `UNSET` (dal 2026-11-06 la dimensione non è un gate della CI per decisione del proprietario). Misure con `--measure` (dimensione massima di download, arm64): AAB release attuale **23.523.909 byte**; AAB di riferimento pre-U6 (`android/captures/pre-u6-app-release.aab`) **11.147.589 byte**. Crescita **12.376.320 byte (11,8 MiB)**, sotto i 15 MiB ammessi dallo script rispetto a quel riferimento. Non esiste un AAB precedente a Freemium, quindi la parte dovuta ai soli plugin nuovi non è misurata. Soglia non modificata.

## Test scritti ma non eseguiti

- **La suite E2E completa** (`flutter test integration_test` più `tool/e2e_force_stop.sh`) non è stata rieseguita in questo passaggio: richiede circa 30 minuti sull'emulatore. Questo passaggio ha cambiato nel codice dell'app solo due costanti (pacchetto Play), coperte dai test unitari. In CI la suite gira ora con l'emulatore Functions acceso.
- Nessun test è stato saltato per mancanza di strumenti: l'E2E di Freemium è stato **eseguito** in locale sull'AVD `Medium_Phone_API_36.1` (emulator-5554, API 36) con `firebase emulators:exec --only auth,firestore,functions`: 3/3 verdi.

## Esito del rischio App Check (da `baseline.md`)

**Il rischio non si è presentato nell'emulatore.** Con il provider di debug attivato in `bootstrap.dart`, la callable `reportUsage` chiamata da una build demo sull'emulatore Android risponde `accepted: true`; il log dell'emulatore Functions riporta `"verifications":{"app":"VALID","auth":"VALID"}` e «Callable request verification passed». Resta da verificare sul telefono reale con il progetto vero, dove servono Play Integrity (release) o un token di debug registrato (debug), come scritto in `docs/plus-setup.md` §4.

## Punti aperti per il proprietario

1. **Pacchetto Play:** verifica di essere d'accordo con la correzione a `com.vinoozy.app` (è il pacchetto della scheda Play); il prodotto `vinoozy_plus` va creato su quell'app.
2. **Versione minima prima di `migrate_capacity.mjs`:** dopo la migrazione la versione già pubblicata non può più creare vini né finire o riattivare una scheda. Prima di migrare, controlla in Play Console che quasi tutte le installazioni (anche degli invitati) abbiano la versione con Freemium (`docs/plus-setup.md` §8).
3. **Dichiarazioni Play:** il manifest ora dichiara `AD_ID` e `BILLING`; la dichiarazione «ID pubblicità» e la scheda «Sicurezza dei dati» vanno aggiornate prima di pubblicare questa versione (`docs/release-checklist.md` §2).
4. **Testi legali:** i paragrafi aggiunti all'informativa e alla pagina di cancellazione (it, en, pt-BR) vanno riletti, e prima di vendere fatti verificare da un professionista. La frase già presente «Nella versione descritta non sono integrati pubblicità o pagamenti» è rimasta com'era: il nuovo paragrafo dice «dalla versione con il piano Plus»; puoi riformularla quando pubblichi.
5. **Regali prima delle funzioni:** finché le funzioni non sono pubblicate, `onUserDeleted` non esiste e un regalo fatto con `grant_plus.mjs` a un account poi eliminato resta in `entitlements/{uid}` (da cancellare a mano, `docs/plus-setup.md` §10).
6. **Copertura dei nuovi moduli:** `lib/plan/` (79,75%) e `lib/ads/` (74,03%) sono sotto l'80% se presi da soli. La soglia del progetto è rispettata e la CI non ha soglie per cartella su questi moduli; le righe scoperte sono soprattutto gli adattatori dei plugin (`InAppPurchaseBillingClient`, `GoogleMobileAdsGateway`), che non girano senza piattaforma. Decidi se aggiungere soglie per cartella.
7. **Dimensione dell'app:** `tool/app_size_baseline.txt` è ancora `UNSET`; le misure sono sopra.
8. **Scala dei caratteri dell'AVD locale:** l'emulatore `Medium_Phone_API_36.1` ha `font_scale` 2.0. Gli helper E2E esistenti (`addWine`) non scorrono fino ai pulsanti con caratteri così grandi: per eseguire l'E2E l'ho portata temporaneamente a 1.0 e poi rimessa a 2.0. In CI la scala è quella predefinita.
9. **Branch protection:** i nuovi passi stanno nei job già obbligatori (`unit`, `rules`, `e2e`); non serve aggiungere controlli richiesti.
10. Dipendenze npm: restano le vulnerabilità moderate transitive segnalate allo Step 14 (`functions/` 30, `tool/admin/` 8), da valutare in Build and Test.
