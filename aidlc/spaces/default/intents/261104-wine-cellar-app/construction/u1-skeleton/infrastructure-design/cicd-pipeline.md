# CI/CD Pipeline — u1-skeleton

Fonti: `team.md` (Way of Working, Testing Posture, Deployment), `tech-stack-decisions.md` (NFR7.1–NFR7.3), `security-design.md` §7, `infrastructure-specification.md`, risposte in `infrastructure-design-questions.md` (Q2: repository pubblico).

Tutti i workflow stanno in `.github/workflows/`, con `permissions: contents: read` come predefinito e le azioni fissate per SHA del commit.

## 1. `ci.yml`: controlli a ogni push e a ogni richiesta di merge

Eventi: `push` su qualunque ramo e `pull_request` verso `main`. La concorrenza è `group: ci-${{ github.ref }}`, con `cancel-in-progress: ${{ github.ref != 'refs/heads/main' }}`. Un nuovo push annulla l'esecuzione precedente solo sui rami di lavoro; su `main` ogni merge completa la propria CI, così nessun merge viene saltato dal rilascio. Nessun job usa segreti, quindi gira uguale anche per le richieste da fork. `firebase-tools` ha una versione fissa in `package.json`; gli emulatori ascoltano su `127.0.0.1` (`firebase.json`) e l'emulatore Android li raggiunge con `10.0.2.2`, che punta al loopback del runner.

| Job | Passi | Controllo richiesto per il merge |
|-----|-------|----------------------------------|
| `format` | `dart format --output=none --set-exit-if-changed .` | Sì |
| `analyze` | `flutter pub get`, generazione delle traduzioni, `flutter analyze --fatal-infos` | Sì |
| `unit` | Genera `test/coverage_helper_test.dart` (importa ogni file di `lib/`); `flutter test --coverage`; script `tool/check_coverage.sh 80` che legge `coverage/lcov.info` e fallisce sotto l'80% delle righe | Sì (NFR7.1) |
| `rules` | Node LTS; `firebase emulators:exec --only firestore --project demo-vinoozy "npm --prefix test/rules test"` con `@firebase/rules-unit-testing` | Sì (NFR7.2) |
| `e2e` | `ubuntu-latest` con KVM attivo; avvia la Emulator Suite (Auth + Firestore, `demo-vinoozy`) in background; emulatore Android API 34 x86_64; `flutter test integration_test --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true`. Timeout del job 30 minuti; una sola ripetizione automatica se l'emulatore Android non si avvia (errore dell'infrastruttura, non del test) | Sì (NFR7.3) |

`e2e` comprende i test dello scheletro:

- accesso;
- aggiunta di un vino offline;
- sincronizzazione al ritorno della rete;
- un secondo utente non vede i vini del primo;
- cambio di account bloccato;
- reset con conferma;
- avvio entro 4 s.

Il comando di verifica dello scheletro, da scegliere in Code Generation, eseguirà in locale gli stessi passi di `rules` ed `e2e`.

**Come girano i test `e2e` (NFR7.3):**

| Aspetto | Meccanismo | Limite e copertura |
|---------|------------|--------------------|
| Accesso Google | Con `E2E=true` l'app usa `EmulatorGoogleAuthService`, un'implementazione di `AuthService` presente solo in quella build. Chiama `signInWithCredential(GoogleAuthProvider.credential(idToken: <JSON non firmato con sub ed email>))`: l'Auth Emulator accetta questi token e crea un utente con `sign_in_provider = google.com`, quindi le regole vere vengono applicate. | Il selettore di account di Google vero non è nei test automatici: si prova a mano nello smoke test (§5). La build di rilascio non contiene `EmulatorGoogleAuthService`; un test di build controlla che non ci sia. |
| Rete assente e riattivata | `TestNetworkControl` (solo con `E2E=true`) chiama `FirebaseFirestore.instance.disableNetwork()` e `enableNetwork()`. L'SDK si comporta come offline: le scritture restano in coda e gli snapshot arrivano con `isFromCache = true` e `hasPendingWrites`. La connessione del telefono verso `10.0.2.2` resta attiva, quindi gli emulatori sono sempre raggiungibili. | La perdita di rete reale del telefono si prova a mano con la modalità aereo nello smoke test (§5). |
| Riavvio dell'app | Il test chiama `FirebaseFirestore.instance.terminate()` e rilancia `main()`. In più un passo separato del job usa `adb shell am force-stop` e `adb shell am start` e verifica che le modifiche in coda ci siano ancora. | Copre NFR6.1 e NFR6.3. |
| Secondo utente | Secondo token dell'emulatore con un altro `sub`, nello stesso test | Copre NFR4.2–NFR4.4 e NFR4.9. |
| Tempo di avvio | Mediana di 5 avvii a freddo dopo un avvio di riscaldamento escluso; soglia 4 s | Il valore di 2 s sul telefono di riferimento si misura nello smoke test. |

## 2. `release.yml`: build verso il test interno a ogni merge su `main`

- **Evento:** `workflow_run` di `ci.yml`. Il job parte solo se valgono tutte queste condizioni:
  - `github.event.workflow_run.conclusion == 'success'`;
  - `github.event.workflow_run.event == 'push'`;
  - `github.event.workflow_run.head_branch == 'main'`;
  - `github.event.workflow_run.head_repository.full_name == github.repository`.

  Una richiesta di merge o un fork non arrivano mai qui.
- **Ambiente GitHub:** `play-internal`, limitato al ramo `main`. Contiene i segreti di firma e l'account Google Play `play-internal-publisher`, che ha **solo** il permesso "Rilascia nei canali di test" e non può pubblicare in produzione (Major R-01).
- **Permessi:** `contents: write` solo in questo job, per il tag della build.
- **Concorrenza:** `concurrency: release`, senza annullare l'esecuzione in corso, così due merge ravvicinati escono in ordine.

Passi:

1. Checkout del commit esatto che ha passato la CI (`head_sha` dell'evento).
2. Ricostruzione dei file segreti dai segreti Base64 nei loro percorsi dentro i sorgenti (`android/app/google-services.json`, `config/firebase_prod.json`, entrambi in `.gitignore`; il secondo è passato alla build con `--dart-define-from-file`). La build Android non applica il plugin Gradle `google-services`: Firebase si inizializza dal codice Dart con i valori di `config/firebase_prod.json`. Per questo le build di CI senza segreti (`unit`, `e2e`, usate con `demo-vinoozy`) compilano senza `google-services.json`, che resta solo un riferimento per la Console. Il keystore di caricamento va in `$RUNNER_TEMP`. Tutti vengono cancellati alla fine, anche se il job fallisce (`if: always()`).
3. Calcolo delle versioni:
   - `versionName` è letto da `pubspec.yaml` (semver);
   - `versionCode` è il più alto tra tutti i canali di Google Play (letto con l'API di Play) **+ 1**. Resta crescente anche se il workflow viene ricreato o rieseguito.
4. `flutter build appbundle --release --dart-define=FIREBASE_ENV=prod --dart-define-from-file=config/firebase_prod.json --build-name=<versionName> --build-number=<versionCode>`.
5. Firma con la chiave di caricamento. Il bundle (AAB) e i simboli di debug per Crashlytics vengono salvati come artifact del workflow, conservati 7 giorni (repository pubblico).
6. Caricamento sul canale **Test interno** di Google Play con l'account di servizio (stato `completed`).
7. Caricamento dei simboli su Crashlytics in un job separato, `crashlytics-symbols` (ambiente GitHub `crashlytics-symbols`, limitato a `main`), che riceve i simboli come artifact e accede con WIF senza chiavi. I suoi unici permessi sono `contents: read` e `id-token: write`; non ha segreti di firma, Play o configurazione.
8. Tag leggero `build-<versionCode>` sul commit esatto, per sapere sempre da quale commit nasce ogni build.

**Prerequisiti, una volta sola:**
- Il primo AAB va caricato a mano dalla Console di Play per creare l'app e abilitare Play App Signing.
- Se l'account sviluppatore è personale e creato dopo novembre 2023, Google Play chiede un test chiuso con almeno 12 tester per 14 giorni prima della produzione. Siccome hai già un'app pubblicata, va verificato in Console se l'obbligo vale ancora per il tuo account.

Se un passo fallisce, il job si ferma e GitHub manda un'email al proprietario. Sul canale resta la build precedente.

## 3. `promote.yml`: promozione in produzione (manuale)

- **Evento:** `workflow_dispatch` con gli input `versionCode`, `fraction` (`0.2` o `1.0`) e `action` (`promote`, `complete` oppure `halt`).
- **Ambiente GitHub:** `play-production`, limitato al ramo `main`, con approvazione obbligatoria del proprietario. Il proprietario approva solo dopo lo smoke test (§5). Contiene l'account Google Play `play-production-publisher` con il permesso "Rilascia in produzione". Anche `halt` passa dall'approvazione: il proprietario è l'unico approvatore e può approvare subito, oppure fermare il rilascio direttamente dalla Console di Play.
- **Permessi:** `contents: write` solo nel job che crea il tag.

Azioni:

| Azione | Cosa fa |
|--------|---------|
| `promote` | Promuove il `versionCode` dal Test interno alla Produzione con rilascio graduale al 20% (`fraction 0.2`) |
| `complete` | Porta il rilascio in corso al 100% |
| `halt` | Ferma il rilascio graduale (rollback, §6) |

Dopo un `complete` riuscito, il workflow crea il tag `v<versionName>` sul commit indicato dal tag `build-<versionCode>`, quindi non ci sono ambiguità.

## 4. `firebase-deploy.yml`: regole e indici in produzione (manuale)

- **Evento:** `workflow_dispatch` con l'input `ref`. Il primo passo verifica che `ref` sia un tag `v*` oppure un commit contenuto in `main` (`git merge-base --is-ancestor`); altrimenti si ferma.
- **Ambiente GitHub:** `firebase-prod`, limitato a `main` e ai tag `v*`, con approvazione obbligatoria del proprietario.
- **Identità:** federazione d'identità (WIF) con i ruoli `roles/firebaserules.admin`, `roles/datastore.indexAdmin`, `roles/firebase.viewer` e `roles/serviceusage.serviceUsageConsumer` sul solo progetto di produzione (Major R-02).
- **Autenticazione:** `google-github-actions/auth` con federazione d'identità, senza chiavi (`permissions: id-token: write` solo in questo job).

Passi:

1. Esegue di nuovo i test delle regole (job `rules`) sul `ref` scelto.
2. Deploy: `firebase deploy --only firestore:rules,firestore:indexes --project <prod>`.

Le regole non si distribuiscono mai da sole con un merge. La sequenza per una modifica che cambia le regole è: merge, poi deploy delle regole, poi promozione dell'app. Per questo ogni nuova versione delle regole deve accettare anche le scritture della versione dell'app ancora in produzione. Il job `rules` lo verifica con i test della versione precedente, tenuti in `test/rules/compat/`.

## 5. Smoke test prima della produzione

Checklist in `docs/release-checklist.md`, eseguita sul telefono reale con la build del Test interno:

0. Solo la prima volta: il progetto Firebase è passato a Blaze con il budget di 1 € e gli avvisi (NFR5.3, NFR5.4; `docs/firebase-setup.md` §1).
1. Installare la build dal Test interno.
2. Avvio a freddo: la Cantina compare in circa 2 s.
3. Accesso con Google.
4. Aggiungere un vino con la rete, poi un vino in modalità aereo, poi riattivare la rete: entrambi arrivano nel cloud (Console Firestore).
5. Crashlytics: nessun crash nuovo per la versione.
6. App Check: le richieste della versione risultano verificate.
7. Data Safety aggiornata, se sono cambiati i dati raccolti (NFR8.3).

## 6. Rollback

| Cosa | Come si torna indietro |
|------|------------------------|
| App in produzione | `promote.yml` con `action: halt` ferma il rilascio graduale. Google Play non permette di tornare a una build già pubblicata, quindi la correzione esce come nuova versione e ripassa dal Test interno (team.md). |
| Test interno | Il merge successivo con la correzione sostituisce la build; nessuno è in produzione. |
| Regole di sicurezza | `firebase-deploy.yml` con il `ref` del tag precedente ridistribuisce le regole precedenti. |
| Commit su `main` | Revert con una nuova richiesta di merge; nessun push forzato. |

## 7. Manutenzione

- **Dependabot:** settimanale per `github-actions`, `pub` e `npm` (test delle regole).
- **Versioni nella CI:** Flutter fissata in `.flutter-version` e letta dalla CI; Node LTS fissato in `.nvmrc`.
- **Cache:** pub, Gradle e AVD dell'emulatore sono in cache per accorciare `e2e`.

## Mappa stage → controllo

| Stadio | Controllo | Blocca |
|--------|-----------|--------|
| Push / richiesta di merge | `format`, `analyze`, `unit` (≥ 80%), `rules`, `e2e` | Il merge su `main` |
| Merge su `main` | `ci.yml` riuscito su `main`, poi `release.yml` | La disponibilità sul Test interno |
| Produzione | Approvazione del proprietario nell'ambiente `play-production` dopo lo smoke test | La promozione |
| Regole | Approvazione del proprietario in `firebase-prod` e test delle regole verdi | Il deploy delle regole |
