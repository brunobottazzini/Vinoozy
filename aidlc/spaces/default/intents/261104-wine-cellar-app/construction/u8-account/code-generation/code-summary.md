# Code Summary — u8-account

U8 completa il ciclo di vita dell'account (US1.2, US1.3; AC1.2.1, AC1.2.2, AC1.3.1, AC1.3.2; BR1.1–BR1.13):
- presentazione al primo avvio, prima dell'accesso, decisa dal segnale locale `onboarding.seen`;
- profilo dal menu della Cantina: foto o iniziale, nome, email, "Esci", "Cancella account", informativa;
- uscita con conferma, o con l'avviso sulle N modifiche in coda ("Resta e sincronizza" / "Esci comunque");
- cancellazione dell'account fatta dall'app, senza funzioni nel cloud: passi 0–7 di BR1.7, ripresa da un segnale esplicito (locale o `deletionStartedAt`), riautenticazione con lo stesso account;
- regole del cloud per `users` e `cellars`;
- pagina web su GitHub Pages (it, en, pt-BR) con accesso Google e gli stessi passi 1–6, pubblicata da `pages.yml` dopo le regole.

Metodo: test-after, strato per strato (modello, accesso ai dati, logica, interfaccia), ogni strato con i suoi test verdi prima del successivo.

## File creati

**Modello** (`lib/account/`):
- `deletion/deletion_plan.dart`: i passi 0–7 come dati (`DeletionStep`, `DeletionPlan.resumeFrom`, pagine di 400, attesa di 30 s).
- `deletion/deletion_signal.dart`: segnale locale `account.deletion.<uid>` in `shared_preferences`.
- `onboarding_flag.dart`: `onboarding.seen`.
- `account_operation_error.dart`: errore tipizzato con motivo fisso, passo e tipo dell'eccezione; `toString` senza il messaggio originale (NFR8.2).

**Accesso ai dati:**
- `deletion/deletion_backend.dart`: interfaccia delle operazioni nel cloud, ognuna ripetibile.
- `deletion/firestore_deletion_backend.dart`: implementazione Firestore con letture dal server, batch confermati, limite di 30 s per lettura e `commit`.
- `deletion/deletion_device.dart`: lato telefono (fermo di `SyncWatcher` e ascolti, `waitForPendingWrites`, azzeramento del registro, `ResetCoordinator`, `TempLabelStore`).
- `deletion/account_deletion_runner.dart`: esegue i passi in ordine, si ferma al primo errore, aggiorna il segnale, classifica gli errori.

**Logica e interfaccia:**
- `account_providers.dart`: `onboardingFlagProvider`, `onboardingSeenProvider`, `privacyPolicyUrlProvider`.
- `ui/onboarding_screen.dart`, `ui/profile_screen.dart` (con `SignOutConfirmDialog` e `SignOutWarningDialog`), `ui/delete_account_screen.dart` (con `DeletionProgressView`).

**Pagina web** (`docs/account-deletion/`): `index.html` (it), `en/index.html`, `pt-BR/index.html`, `style.css`, `account-deletion.js` (`createAccountDeletion(sdk, db, auth)`), `page.js` (punto d'ingresso), `firebase-config.js` (valori `TODO`), `app.bundle.js` (generato).

**Test:**
- `test/account/`: `account_harness.dart` (finti), `deletion_model_test.dart`, `account_data_test.dart`, `google_auth_service_test.dart`, `deletion_device_test.dart`, `account_deletion_runner_test.dart`, `account_gate_deletion_test.dart`, `account_ui_test.dart`, `account_docs_test.dart`.
- `test/rules/u8.rules.test.mjs`.
- `test/web/`: `helpers.mjs`, `account-deletion.test.mjs` (Node, emulatori), `browser.test.mjs` (Playwright, Chromium headless).
- `integration_test/account_test.dart`.

**Strumenti e workflow:** `tool/build_web_bundle.sh`, `tool/check_web_pins.sh`, `tool/check_web_pins_test.sh`, `tool/fixtures/web_csp_allowed.txt`, `tool/fixtures/web_pins/bad/`, `.github/workflows/pages.yml`.

## File modificati

- `firestore.rules`: `users` delete solo con `deletionStartedAt`; `deletionStartedAt` alla creazione e in aggiornamento, solo se assente e uguale a `request.time`; `cellars` delete solo dal proprietario con `deletionStartedAt` nel profilo; tabella degli accessi aggiornata.
- `lib/account/account_gate.dart`: controllo della cancellazione all'inizio di `_openCellar` (dopo i controlli di `_admit`, prima di `ensureProfile` ed `ensurePersonalCellar`); `deleteAccount`, `resumeDeletion`, `cancelDeletion`, `signOut`, `pendingChanges`, `syncNow`; pulizia del passo 7 all'avvio senza sessione; segna la presentazione come vista con una sessione salvata. I nuovi parametri sono facoltativi: senza di essi il gate si comporta come in U1.
- `lib/account/gate_state.dart`: `GateDeleting(step, …)`, `GateDeleted`, `DeletionNotice`, `SignInNotice.accountDeleted`.
- `lib/account/auth_service.dart`, `google_auth_service.dart`, `lib/e2e/emulator_google_auth_service.dart`: `photoUrl`, `reauthenticate` con controllo dell'uid (`user-mismatch` → altro account, uscita da Google), `deleteUser` con `requires-recent-login`.
- `lib/account/data/user_repository.dart`: `markDeletionStarted` (crea o aggiorna), `isDeletionStarted`, `deleteProfile`.
- `lib/account/reset_coordinator.dart`: `reset(uid, openCellar: false)`; `lib/sync/ledger/local_ledger.dart`: `reset(String?)`, così dopo la cancellazione nessun account resta come ultimo utente.
- `lib/account/ui/account_gate_view.dart`, `sign_in_screen.dart`: presentazione prima dell'accesso, avanzamento, "Account cancellato".
- `lib/app/bootstrap.dart`: collegamento di runner, backend, lato telefono, segnale, rete e presentazione.
- `lib/cellar/ui/cellar_screen.dart`: voce "Profilo" nel menu della Cantina.
- `lib/l10n/app_en.arb`, `app_it.arb`, `app_pt_BR.arb` e i file generati da `flutter gen-l10n`: 55 testi nuovi (`signOutFailed` è pronto ma non ancora mostrato: un'uscita fallita torna comunque all'accesso, come in U1).
- `test/rules/compat/app-writes.json`: versione `u8-account` con `requiresRules: "account"`.
- `package.json`, `package-lock.json`: `c8` 12.0.0, `esbuild` 0.28.2, `playwright` 1.65.0 (con `firebase` 13.2.0 già fissato); `test:rules` con `u8.rules.test.mjs`; nuovi `test:web` e `build:web`.
- `.github/workflows/ci.yml`: `analyze` (ID BR1.1–BR1.13, `check_web_pins` e il suo test, con Node e `npm ci`), `unit` (copertura di `lib/account/`), `rules` (Chromium di Playwright e `npm run test:web`). `promote.yml`: `RULES_FEATURES: sharing cellar account`.
- `integration_test/e2e_helpers.dart`: `clearPhone` imposta `onboarding.seen`, così gli altri end-to-end partono dall'accesso; `showOnboarding` per il test della presentazione.
- `test/u1/account/reset_coordinator_test.dart` (caso `openCellar: false`), `test/catalog/catalog_providers_test.dart` (il finto `AuthService` implementa i nuovi metodi), `test/sharing/permissions_screens_test.dart` (voce "Profilo" nel menu).
- `docs/release-checklist.md`: nuovo §1-septies Account con la procedura per le richieste via email, §2 (scheda "Sicurezza dei dati", informativa con i residui, chiavi locali), §3 (ordine regole, pagina, app), §4 (rollback della pagina e di App Check), §5 (errori `account_*`, richieste via email, App Check).
- `docs/firebase-setup.md`: §6 ambiente `github-pages-publish`; nuovo §10 (repository pubblico dopo il controllo dei segreti, app web, domini, reCAPTCHA, App Check web e obbligo al 99% per 7 giorni, GitHub Pages da `gh-pages`).

## Decisioni di implementazione

- **Il runner parla con interfacce dell'app** (`DeletionBackend`, `DeletionDevice`, `AuthService`): i test lo interrompono dopo ogni passo con un Firestore finto che registra letture e batch. L'adattatore Firestore è provato a parte con i doppi di mocktail.
- **Niente `SharingRepository` nella cancellazione.** Il backend scrive gli stessi batch di C4 (attivazione, uscita, revoca, cancellazione), ma così i report contengono solo `account_delete_failed`, come chiede NFR8.2.
- **Segnale locale = prossimo passo.** Vale 0 prima del passo 0 e avanza dopo ogni passo riuscito. Se l'attesa delle scritture in coda fallisce, il segnale si toglie: la cancellazione non è iniziata, e oltre a "Riprova" c'è "Annulla", che riapre l'app. Dopo `deleteUser` il segnale vale 7. Se il passo 7 non si completa, all'avvio senza sessione il gate lo ripete e mostra "Account cancellato".
- **Passi 3–5 saltati senza cantina.** Un account nuovo può non avere `cellars/{uid}`, e le regole rifiuterebbero la lettura di `members` e delle sotto-raccolte. Il runner legge prima l'esistenza della cantina.
- **Riautenticazione:** richiesta prima del passo 0, a ogni ripresa all'accesso e dopo `requires-recent-login`. Un "Riprova" nella stessa sessione dopo un errore di rete non la richiede.
- **Piano B dell'azzeramento** (`restartRequired`): conta come completato. Il segnale si toglie e compare "Riavvia l'app"; al riavvio `completePendingReset` pulisce Firestore.
- **Presentazione:** senza `onboardingFlagProvider` (cioè nei test delle altre unità) conta come già vista. In produzione la inietta `bootstrap.dart`.
- **Informativa sulla privacy:** l'app non ha `url_launcher`, e U8 non aggiunge dipendenze. Il profilo mostra l'indirizzo con "Copia il link". Indirizzo predefinito: la pagina di cancellazione, che ha una sezione "Privacy" con i residui. Si cambia con `--dart-define=PRIVACY_POLICY_URL=…`.
- **Pagina web:**
  - `firebase-config.js` resta fuori dal bundle (`--external`), così il proprietario lo compila senza ricostruire `app.bundle.js`.
  - Tutti i testi stanno nei tre HTML. La CSS è in un file, perché la CSP vieta gli stili in linea.
  - Con valori `TODO` la pagina dice che non è configurata e non fa accedere nessuno. Lo stesso controllo blocca `pages.yml`.
- **Scelte enologiche:** nessuna in questa unità.

## Risultati

Prima delle modifiche, sull'albero invariato: `flutter test` **1.348 superati**.

| Controllo | Risultato |
|---|---|
| `flutter test` (suite completa, con `coverage_helper_test.dart` generato) | **1.522 superati**, 0 falliti |
| `flutter test test/account` (comando 1) | **176 superati** |
| `flutter test test/u1 test/app` (comando 4), incluso in `test/account test/u1` | verdi (413 superati con `test/account` allo Step 6) |
| Copertura della sola U8: `flutter test --coverage test/account && tool/check_coverage.sh 80 coverage/lcov.info lib/account/` (comando 5) | **82,37%** (925/1.123) |
| Copertura di `lib/account/` sulla suite completa (job `unit`) | **97,60%** (1.096/1.123) |
| Copertura del progetto (lcov dell'app + pacchetto `estimation`, come in CI) | **89,16%** (8.994/10.087), soglia 80% |
| Altre cartelle | `lib/cellar/` 95,34%, `lib/sharing/` 98,42%, `lib/label/` 98,62%, `lib/catalog/` 99,48%, `lib/dashboard/` 99,04% |
| `npm run test:rules` (comando 2) | **192 test**: 191 superati, 0 falliti, 1 saltato (il confronto con il tag `v*` più recente: nessun tag ancora) |
| `npm run test:web` (comando 3) | **16 superati** (11 in Node contro gli emulatori, 5 in Chromium headless), `c8`: **100% delle righe** di `account-deletion.js` (rami 92,63%) |
| `tool/check_rule_ids.sh BR1. 13 test/account test/rules/u8.rules.test.mjs` (comando 6) | OK (BR1.1–BR1.13 in 10 file); quelli di U4 e U6 restano OK |
| `tool/check_web_pins.sh` e `tool/check_web_pins_test.sh` | OK; la prova `bad/` riporta tutti i 10 problemi attesi |
| `tool/check_rule_ids_test.sh`, `tool/check_firestore_indexes.sh` | OK |
| `dart format --output=none --set-exit-if-changed .` | 0 file cambiati |
| `flutter analyze --fatal-infos` | nessun problema |
| `integration_test/account_test.dart` sull'emulatore Android (API 36.1 locale) con la Firebase Emulator Suite | **2 superati**, ripetuto due volte. La cancellazione di 50 vini e 100 bevute in pochi secondi, sotto i 60 s |

Chromium di Playwright è stato installato con `npx playwright install chromium`. Il download non è stato bloccato.

## Test scritti ma non eseguiti, o eseguiti con riserva

- **Gli altri end-to-end** (`u1_skeleton_test`, `cellar_test`, `concurrent_drink_test`, `label_test`, `dashboard_500_test`, `sharing_test`):
  - sono stati eseguiti una volta con tutta la cartella sull'emulatore locale e **9 test sono falliti**;
  - l'emulatore locale è in `en-US`, mentre quei test cercano testi italiani ("Cantina di user-a · Solo lettura", righe dei vini) e un limite di 2 s superato su questa macchina (3,7 s);
  - non è stato possibile mettere l'emulatore in italiano: `setprop persist.sys.locale` è rifiutato su questa immagine senza root;
  - gli accessi di quei test (che passano dal nuovo `clearPhone` con `onboarding.seen`) sono riusciti;
  - questa prima analisi è superata: vedi "Correzioni dopo la revisione" per la lingua fissata nelle build E2E e i risultati delle nuove esecuzioni complete.
  - Anche `account_test.dart` era fallito nell'esecuzione completa: l'avviso "user-b ti ha condiviso la sua cantina" copriva i pulsanti. Il test ora lo chiude, ed è passato due volte da solo.
- **`pages.yml`** non è mai stato eseguito: richiede GitHub, il repository pubblico e un'esecuzione riuscita di `firebase-deploy.yml`. La sintassi YAML è stata controllata.
- **Prova sul telefono reale** della checklist §1-septies e misura del caso peggiore (NFR1.2): manuali.
- **Accesso Google vero nel browser:** lo coprono i test Node con l'emulatore di Auth. Il test in Chromium verifica solo l'avvio, la CSP e il pulsante di accesso.

## Scostamenti dal piano

- **Voce "Profilo" nel menu della Cantina** (`lib/cellar/ui/cellar_screen.dart`, file di U4 non elencato nel piano): è l'unico menu dell'app, e `HomeShell` non ha una barra con azioni.
- **File in più:**
  - `lib/account/account_providers.dart`, `deletion/deletion_backend.dart`, `deletion/firestore_deletion_backend.dart`, `deletion/deletion_device.dart`, per separare il runner da Firebase;
  - `lib/sync/ledger/local_ledger.dart` (`reset` accetta `null`);
  - `lib/e2e/emulator_google_auth_service.dart` (implementa i nuovi metodi);
  - `docs/account-deletion/page.js` e `style.css`;
  - `test/web/helpers.mjs`;
  - `tool/fixtures/web_pins/bad/`, la prova di `check_web_pins_test.sh`;
  - `test/account/account_docs_test.dart`, unico test con BR1.12 nel nome, che è una procedura della checklist.
- **Modifiche a test esistenti:** `test/catalog/catalog_providers_test.dart` (finto `AuthService`), `test/sharing/permissions_screens_test.dart` (voce di menu), `test/u1/account/reset_coordinator_test.dart`, `integration_test/e2e_helpers.dart` (`clearPhone`).
- **Test dei widget di U1 in `test/u1`:** non è servito cambiarli. I parametri nuovi del gate sono facoltativi, e la presentazione senza flag conta come vista.
- **Comando di `test:web`:** usa `test/web/*.test.mjs` invece di `test/web/`, perché Node 22 non accetta una cartella come argomento di `--test`.
- **`check_web_pins.sh` non esegue `npm ci` da solo.** Il job `analyze` e `pages.yml` lo eseguono prima. Lo script controlla che `firebase` installato sia quello di `package.json`.
- **Nell'end-to-end della cancellazione** l'invito di Mario nella cantina altrui viene attivato dall'app prima della cancellazione (comportamento di U7), quindi l'end-to-end prova un invito attivo. Il caso "in attesa" è provato nelle regole (`u8.rules.test.mjs`) e nei test della pagina.
- **Nota di processo:** una correzione di `test/account/account_data_test.dart` (`Timestamp.fromMillis` → `fromMillisecondsSinceEpoch`) è stata fatta con `perl -pi` invece che con lo strumento di modifica dei file. Il contenuto è quello voluto.

## Correzioni dopo la revisione

Revisione `reviews/review-01.md` (READY, iterazione 1; un finding Major e tre Minor).

- **R-01 (maggiore): lingua degli end-to-end.**
  - Nuovo `lib/e2e/e2e_locale.dart`: nelle sole build con `--dart-define=E2E=true` l'app è sempre in italiano (`MaterialApp.locale` e nome della cantina predefinita), qualunque sia la lingua dell'emulatore. In tutte le altre build l'override vale `null` e decide `resolveAppLocale` come prima (BR5.1, provato da `test/app/e2e_locale_test.dart`).
  - `tool/check_release_build.sh` cerca il nuovo marcatore `VINOOZY_E2E_LOCALE`: **assente** nella build di rilascio, **presente** nella build di controllo E2E+PERF. Eseguito: OK su entrambe.
  - `integration_test/account_test.dart` chiude l'avviso "user-b ti ha condiviso la sua cantina" (dialogo di U7) prima di aprire il profilo. Era la dipendenza dall'ordine: nella corsa completa l'avviso arrivava mentre il test toccava "Cancella per sempre".
  - Corsa completa di `integration_test/` sull'AVD locale `Medium_Phone_API_36.1` (API 36, en-US), due volte:
    - **1ª corsa** (densità dello schermo forzata dal proprietario a 540, schermo logico di 320 dp): 13 superati, 7 falliti. Superati `firestore_restart_probe_test`, 9 degli 11 test di `u1_skeleton_test`, `sharing_test` e i 2 di `account_test`; falliti `concurrent_drink_test`, `u1_skeleton_test` 3b e 6, `label_test`, `dashboard_500_test`, `cellar_test` (2). Nei due fallimenti di U1, su uno schermo largo 320 dp, il pulsante "Elimina le modifiche" era coperto da una `SnackBar` e la riga del secondo vino non compariva entro 20 s; con la densità fisica entrambi passano.
    - **2ª corsa** (densità riportata temporaneamente a quella fisica 420, poi ripristinata a 540): 14 superati, 6 falliti. Superati: `firestore_restart_probe_test`, gli 11 test di `u1_skeleton_test`, i 2 di `account_test`. Falliti: `concurrent_drink_test` (tocco sul selettore delle cantine coperto dal dialogo "… ti ha condiviso la sua cantina"), `sharing_test` (stessa causa; nella 1ª corsa era passato), `label_test` (`backToShell`: nessun `home-shell` nell'albero), `dashboard_500_test` (manca la barra `chart-status-…` di uno stato: `ensureVisible` senza elemento), `cellar_test` ×2 (tocco su "Aggiungi" coperto da una `SnackBar`; "Bevuta segnata: Dolcetto di Dogliani" ancora visibile conta come secondo testo).
    - Nessuno di questi fallimenti passa dal codice di U8: sono test e flussi di U4–U7, con dialoghi e `SnackBar` che coprono i tocchi o restano a schermo. Un confronto con l'albero senza U8 non è possibile: il codice di U1–U7 non è committato e non si può ripristinare l'albero.
  - **Tempo di 3,7 s contro 2 s** (prima corsa della revisione precedente): è l'asserzione `saveToList < provisionalSaveToListLimit` del test `u1_skeleton_test.dart` "2-3. offline add" (riga 88), misurata da `addWine` dal tocco su "Salva" alla riga nella lista, in una build di debug. Nelle due corse nuove la stessa misura è stata **611 ms** e **702 ms**. Il valore di 3,7 s veniva dalla prima corsa subito dopo l'avvio dell'emulatore (JIT e emulatore a freddo): è un effetto dell'ambiente, non una lentezza dell'app. Il limite non è stato toccato.
- **R-02 (minore):** in `_afterDeletion`, con `DeletionStopped` e la sessione ancora presente, `_deletionCompleting` torna `false`; una revoca successiva porta di nuovo ad "Accesso scaduto". Test nuovo in `account_gate_deletion_test.dart`.
- **R-03 (minore):** "Annulla" vale per tutto il passo 0 (`canCancel`: passo 0 e nulla in esecuzione), anche alla ripresa senza rete. `cancelDeletion` chiama `AccountDeletionRunner.abandonBeforeStart`, che toglie il segnale locale solo se non è andato oltre il passo 0 (nulla cancellato nel cloud), poi apre l'app. Due test nuovi: ripresa al passo 0 senza rete e annullamento; segnale oltre il passo 0 mai tolto.
- **R-04 (minore):** nuovo `tool/check_web_config.mjs`, usato da `pages.yml`. Rifiuta `TODO` con qualsiasi virgolette, un valore vuoto, `recaptchaSiteKey` vuota ed `emulators` diverso da `null`. Il suo test `tool/check_web_config_test.sh` (fixture in `tool/fixtures/web_config/`, e il `firebase-config.js` del repository, che deve fallire) è nel job `analyze`.

Risultati dopo le correzioni: `dart format` pulito; `flutter analyze --fatal-infos` senza problemi; `flutter test --coverage` **1.528 superati**; copertura del progetto **89,13%** (9.005/10.103, con l'lcov del pacchetto `estimation` dell'esecuzione precedente: il pacchetto non è cambiato), `lib/account/` **97,44%** sulla suite completa e **82,70%** con i soli test di `test/account` (179 superati); `npm run test:rules` 192 test (191 superati, 1 saltato); `npm run test:web` 16 superati, 100% delle righe di `account-deletion.js`; `check_web_pins.sh`, il suo test e `check_web_config_test.sh` OK; `check_rule_ids` BR1.1–BR1.13 OK; `tool/check_release_build.sh` OK.

## Da fare dal proprietario

1. **Compilare `docs/account-deletion/firebase-config.js`.** Va fatto dopo aver registrato l'app web (punto 2), sostituendo i `TODO_…` con `apiKey`, `authDomain` (`vinoozy-d6f45.firebaseapp.com`), `projectId`, `appId` e la chiave del sito reCAPTCHA v3. Sono valori pubblici. Il bundle non va ricostruito. Finché resta un `TODO`, `pages.yml` si ferma.
2. **Registrare l'app web** nella console Firebase (Impostazioni progetto → Le tue app → Web).
3. **Dominio autorizzato:** in Authentication → Impostazioni → Domini autorizzati aggiungere `brunobottazzini.github.io`.
4. **Sito reCAPTCHA v3** con il dominio `brunobottazzini.github.io`. La chiave del sito va in `firebase-config.js`, la chiave segreta solo nella console di App Check.
5. **App Check per il web:** registrare l'app web con il provider reCAPTCHA v3. L'**obbligo su Firestore** si attiva solo dopo **7 giorni consecutivi con almeno il 99%** di richieste verificate, Android e web insieme. Fino ad allora Firestore resta in modalità di controllo.
6. **Rendere pubblico il repository**, solo dopo il controllo dei segreti:
   - `config/firebase_prod.json` e `google-services.json` mai committati;
   - `gitleaks detect --source . --log-opts="--all"` su tutta la cronologia;
   - ogni segreto trovato si revoca prima.
7. **GitHub Pages:**
   - creare l'ambiente `github-pages-publish` con approvazione obbligatoria;
   - dopo la prima esecuzione di `pages.yml`, che crea `gh-pages`: Settings → Pages → "Deploy from a branch" → `gh-pages`, cartella `/ (root)`.
8. **Ordine di pubblicazione:**
   - merge;
   - `firebase-deploy.yml` (le regole di U8: senza di esse la cancellazione è rifiutata);
   - **poi `pages.yml`** con `mode: publish` e lo stesso `ref`;
   - prova §1-septies;
   - `promote.yml`.
9. **Scheda "Sicurezza dei dati"** di Google Play con l'URL `https://brunobottazzini.github.io/Vinoozy/account-deletion/`, e informativa con i residui `recordedBy` e `updatedBy` (checklist §2).
10. **End-to-end in CI.** Il job `e2e` di `ci.yml` **non** imposta la lingua dell'emulatore: resta en-US. Dopo la revisione le build E2E mostrano l'app sempre in italiano (vedi "Correzioni dopo la revisione"), quindi i test che cercano testi italiani non dipendono più dalla lingua dell'emulatore. Restano da valutare i fallimenti delle altre unità elencati sotto.

## Comandi

```bash
flutter test test/account
npm run test:rules
npm run test:web
flutter test test/u1 test/app
flutter test --coverage test/account && tool/check_coverage.sh 80 coverage/lcov.info lib/account/
tool/check_rule_ids.sh BR1. 13 test/account test/rules/u8.rules.test.mjs
tool/check_web_pins.sh
tool/check_web_pins_test.sh
npm run build:web
npx firebase emulators:exec --only auth,firestore --project demo-vinoozy "flutter test integration_test/account_test.dart --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
```
