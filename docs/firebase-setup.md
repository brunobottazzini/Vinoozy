# Configurazione di Firebase, Google Play e GitHub (una volta sola)

Checklist versionata delle impostazioni che le API non coprono bene (`infrastructure-specification.md`, colonna IaC). Si applica a mano una sola volta, nell'ordine indicato. Per sviluppare e testare **non serve nulla di tutto questo**: emulatori e progetto `demo-vinoozy` funzionano senza account.

Spunta ogni voce quando è fatta e annota la data.

## 1. Progetto Firebase di produzione

- [x] Crea il progetto Firebase (un solo progetto reale, `team.md` Q9): `vinoozy-d6f45`, creato il 2026-11-05 sul piano gratuito Spark per le prove via cavo.
- [ ] **Prima della prima pubblicazione su Google Play** (anche test interno): passa al piano **Blaze** e crea il budget mensile di 1 € con avvisi al 50%, 90% e 100% (NFR5.3, NFR5.4).
  - Per le funzioni di Freemium e Plus (scollegamento automatico della fatturazione oltre 1 €, pulizia di Artifact Registry, pubblicazione in `europe-west8`) segui `docs/blaze-switch.md`, poi `docs/plus-setup.md`.
- [ ] Firestore in modalità nativa, database `(default)`, località **`europe-west8` (Milano)**. La località è definitiva.
- [ ] Authentication: attiva **solo il provider Google**. Accesso anonimo ed email/password restano disattivati (NFR4.1).
- [ ] Registra l'app Android `com.vinoozy.app`. Dalla console scarica `google-services.json` e scrivi `config/firebase_prod.json` con i valori `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET` (presi da `google-services.json`), **senza** committarli: vanno solo nei segreti (§5). L'app li riceve con `--dart-define-from-file=config/firebase_prod.json`.
- [ ] Prendi l'**OAuth web client id** del progetto (Authentication → Google → Web SDK configuration) e salvalo come variabile GitHub `GOOGLE_SERVER_CLIENT_ID` (è pubblico, non è un segreto).

## 2. App Check e Play Integrity (NFR4.6)

- [ ] In Play Console collega l'app al progetto Google Cloud e attiva l'API Play Integrity.
- [x] In Firebase → App Check registrata l'app Android con **Play Integrity**, con le tre SHA-256 delle firme effettive Play (deployment, hybrid classical, hybrid PQC). Registrate anche le corrispondenti SHA-1 nelle impostazioni Android Firebase. Play Integrity collegato al progetto Cloud **Vinoozy**, numero **742143174654**, quota giornaliera 10.000. App Check Android risulta **Registrata**, TTL token un'ora; Firestore e Authentication risultano **Non applicato**. Configurazione eseguita dopo autorizzazione e accettazione Termini del titolare, 2026-11-09.
- [ ] Lascia Firestore in **modalità di controllo**. Rendi App Check obbligatorio solo quando, per 7 giorni di test interno, almeno il **99%** delle richieste risulta verificato.
- [ ] Il token di debug (solo build di debug su telefono reale) resta sul tuo computer: mai nel repository né nei segreti.

## 3. Budget (NFR5.3, NFR5.4)

- [ ] Google Cloud Billing → Budget mensile di **1 €** sul progetto, avvisi email al 50%, 90% e 100%. L'avviso informa ma non blocca la spesa (rischio accettato).

## 4. Federazione d'identità (WIF): deploy delle regole e simboli di Crashlytics

Nessuna chiave JSON: GitHub Actions ottiene token a breve scadenza. Il collegamento delle regole è stato configurato il 2026-11-10, dopo il consenso esplicito del proprietario. I simboli di Crashlytics restano facoltativi e richiedono un provider separato.

- [x] Pool `github-actions`, provider OIDC `vinoozy-rules`, emittente `https://token.actions.githubusercontent.com`, pubblico predefinito. Mapping `google.subject=assertion.sub`, `attribute.environment=assertion.environment`. Condizione salvata:

  ```text
  assertion.repository_id == '1445706433' && assertion.repository_owner_id == '4460234' && assertion.repository == 'brunobottazzini/Vinoozy' && assertion.environment == 'firebase-prod' && assertion.event_name == 'workflow_dispatch' && (assertion.ref == 'refs/heads/main' || assertion.ref.startsWith('refs/tags/v')) && assertion.workflow_ref.startsWith('brunobottazzini/Vinoozy/.github/workflows/firebase-deploy.yml@')
  ```

- [x] Account del **deploy delle regole**: `github-firestore-deployer@vinoozy-d6f45.iam.gserviceaccount.com`, senza chiavi, con `roles/firebaserules.admin`, `roles/datastore.indexAdmin`, `roles/serviceusage.serviceUsageConsumer` e il ruolo personalizzato `projects/vinoozy-d6f45/roles/firestoreDeployMetadataViewer` (solo `firebase.projects.get`). Ruoli verificati nella console IAM.
  Il ruolo ampio `roles/firebase.viewer` previsto inizialmente non è stato concesso: comprende anche lettura di documenti e utenti Authentication ([riferimento Google](https://docs.cloud.google.com/iam/docs/roles-permissions/firebase#firebase.viewer)). Il ruolo personalizzato fornisce il permesso di metadati richiesto dalla CLI Firebase senza quegli accessi.
- [x] `roles/iam.workloadIdentityUser` sull'account dedicato solo per `principalSet://iam.googleapis.com/projects/742143174654/locations/global/workloadIdentityPools/github-actions/attribute.environment/firebase-prod`. Verificata nella console del pool l'associazione all'account con `attribute.environment="firebase-prod"`.
- [ ] Facoltativo, account di servizio dei **simboli di Crashlytics** (job `crashlytics-symbols` di `release.yml`) con **solo** `roles/firebasecrashlytics.admin` e `roles/serviceusage.serviceUsageConsumer` sul progetto di produzione.
  Concedi `roles/iam.workloadIdentityUser` su questo account **solo** al principale `principalSet://iam.googleapis.com/<pool>/attribute.environment/crashlytics-symbols`.
- [x] Variabili dell'ambiente GitHub `firebase-prod`, salvate e verificate il 2026-11-10: `WIF_PROVIDER=projects/742143174654/locations/global/workloadIdentityPools/github-actions/providers/vinoozy-rules`, `WIF_SERVICE_ACCOUNT=github-firestore-deployer@vinoozy-d6f45.iam.gserviceaccount.com`, `FIREBASE_PROD_PROJECT_ID=vinoozy-d6f45`. Revisore obbligatorio `brunobottazzini`, bypass amministrativo disabilitato, distribuzione limitata a `main` e ai tag `v*`. Autenticazione effettiva e deploy riusciti nel [run 42829140441](https://github.com/brunobottazzini/Vinoozy/actions/runs/42829140441), dopo l'approvazione del proprietario, il 2026-11-10 alle 15:39 (Europe/Rome).
- [ ] Variabile dell'ambiente GitHub `crashlytics-symbols`: `WIF_PROVIDER`. Variabili **del repository** (non dell'ambiente): `CRASHLYTICS_WIF_SERVICE_ACCOUNT` e `FIREBASE_ANDROID_APP_ID` (identificativi pubblici, non segreti). Devono stare a livello di repository perché la condizione `if` del job `crashlytics-symbols` viene valutata prima che il job entri nel suo ambiente e non vede le variabili d'ambiente. Finché mancano, `release.yml` salta solo il job dei simboli.

## 5. Google Play: app e i due account di servizio

Nomi esatti, formati, comandi per copiare i valori senza mostrarli e controlli
finali dei segreti di `play-internal` e `play-production`: `docs/github-actions-setup.md`.

- [ ] Crea l'app in Play Console con il pacchetto **`com.vinoozy.app`** e attiva **Play App Signing**. Il primo AAB va caricato a mano, poi `release.yml` fa il resto.
- [ ] Verifica se il tuo account sviluppatore deve fare un test chiuso con 12 tester per 14 giorni prima della produzione.
- [ ] Account di servizio **`play-internal-publisher`**: in Play Console, sulla sola app Vinoozy, solo il permesso "Rilascia nei canali di test". La chiave JSON va nel segreto `PLAY_INTERNAL_SA_JSON` dell'ambiente `play-internal`.
- [ ] Account di servizio **`play-production-publisher`**: sulla sola app Vinoozy, permesso "Rilascia in produzione". La chiave va nel segreto `PLAY_PRODUCTION_SA_JSON` dell'ambiente `play-production`.
- [ ] Chiave di caricamento (upload key): segreti `ANDROID_UPLOAD_KEYSTORE_B64`, `ANDROID_UPLOAD_KEYSTORE_PASSWORD`, `ANDROID_UPLOAD_KEY_ALIAS`, `ANDROID_UPLOAD_KEY_PASSWORD` nell'ambiente `play-internal`. Se va persa o è esposta, chiedi a Google Play di sostituirla.
- [ ] Configurazione di produzione: segreti `FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64` e `FIREBASE_PROD_DEFINES_JSON_B64` (file del §1 in Base64) nell'ambiente `play-internal`.
- [ ] I simboli di Crashlytics **non** usano chiavi né segreti: vedi §4 (WIF, ambiente `crashlytics-symbols`). Se in passato hai creato il segreto `FIREBASE_SYMBOLS_SA_JSON`, cancellalo e revoca la chiave in Google Cloud.

## 6. Repository GitHub (pubblico) e ambienti

- [ ] Ruleset sul ramo **`main`**: solo squash merge, storia lineare, nessun push diretto (anche per l'amministratore), controlli richiesti (tutti i 7 job di `ci.yml`): `format`, `secrets`, `analyze`, `unit`, `estimation`, `rules`, `e2e`.
- [ ] Ruleset sui tag **`v*`** e **`build-*`**: creazione solo dai workflow (GitHub Actions come unico bypass), nessuna modifica né cancellazione. Così i tag di promozione `v<versionName>+<versionCode>` e di build non si possono spostare.
- [ ] **Secret scanning** e **push protection** attivi.
- [ ] Actions → "Require approval for first-time contributors". I workflow usano solo `pull_request`, mai `pull_request_target`.
- [ ] Ambienti:
  - `play-internal`: limitato a `main`;
  - `play-production`: limitato a `main`, approvazione obbligatoria del proprietario (creazione passo per passo in `docs/github-actions-setup.md` §2);
  - `firebase-prod`: limitato a `main` e ai tag `v*`, approvazione obbligatoria del proprietario;
  - `crashlytics-symbols`: limitato a `main`, senza approvazione (carica solo i simboli di debug, nessun segreto);
  - `github-pages-publish` (u8-account): approvazione obbligatoria del proprietario, per `pages.yml` (§10).

## 7. Alert (`monitoring-design.md`)

- [ ] Crashlytics: notifiche email per nuovi problemi, regressioni e **nuovi problemi non fatali** (evento `SyncRejected`).
- [ ] Crashlytics → Impostazioni → **velocity alert** con soglia all'**1% degli utenti in 1 ora**.
- [ ] Cloud Monitoring: alert sui rifiuti delle regole Firestore con esito negato **> 50 in 1 ora**, email al proprietario. Prima di crearlo **verifica nel Metrics Explorer il nome esatto della metrica e delle etichette** (cerca le valutazioni delle regole di Firestore), perché il nome non è stato confermato in progettazione. Annota qui il nome usato: `______________________`.
- [ ] GitHub: notifiche email per i workflow falliti su `main`.
- [ ] Cloud Monitoring → Avvisi → Crea criterio: **avviso sulle letture giornaliere di Firestore** (u7-sharing, NFR5.3, `monitoring-design.md` di U7 §3), email al proprietario.
  - Metrica: probabilmente `firestore.googleapis.com/document/read_count`, risorsa `firestore_instance`, database `(default)`. Prima di crearlo **verifica il nome esatto nel Metrics Explorer** e annotalo qui: `______________________`.
  - **Condizione principale:** somma mobile su **24 ore** (finestra della condizione di 1 giorno, il massimo per gli avvisi a soglia) sopra **35.000** letture, il 70% della quota gratuita di 50.000 al giorno.
  - **Condizione di riserva**, se la finestra di 24 ore non è accettata: somma su **1 ora** sopra **3.000**, mantenuta per **3 ore**. È un ritmo che porterebbe oltre la quota in meno di un giorno.
  - Condizione usata: ______.
  - **Limite noto:** la somma mobile non coincide con il giorno della quota di Firestore, che si azzera a mezzanotte, ora del Pacifico. È un avviso precoce, non il conteggio esatto: il valore esatto si legge nella pagina "Utilizzo" della console Firebase durante il controllo mensile (`docs/release-checklist.md` §5).
- [ ] **Indice degli inviti (u7-sharing, NFR4.7):** `firebase deploy --only firestore:indexes`, eseguito dal workflow senza `--force`, in modo non interattivo non cancella gli indici del progetto assenti dal file. Al primo rollback di prova in un progetto di test verifica questo comportamento e annota qui il risultato: ______.

## 8. Prima distribuzione delle regole

- [x] Prima distribuzione riuscita il 2026-11-10 alle 15:39 (Europe/Rome), dopo l'approvazione del proprietario in `firebase-prod`: [firebase-deploy, run 42829140441](https://github.com/brunobottazzini/Vinoozy/actions/runs/42829140441), `ref=105c0ba432ad39d1fc05814c3150ab6a3ac80504`. I log confermano compilazione delle regole, distribuzione degli indici del database `(default)` e pubblicazione di `firestore.rules` su `vinoozy-d6f45`. Per i deploy successivi usare ancora l'hash completo di un commit di `main` o un tag `v*`. Prima della promozione verificare anche lo stato «Abilitato» degli indici nella console, come da `docs/release-checklist.md` §3.

## 9. Contatto per Open Food Facts (`OFF_CONTACT`, catalogo dei vini U3)

Open Food Facts chiede a ogni app un identificativo `Vinoozy/<versione> (<contatto>)`. Il catalogo lo usa solo se la build ha il contatto; senza, Open Food Facts resta spento e restano i suggerimenti interni (BR5.1). Sviluppo, test, end-to-end e CI non lo hanno mai, quindi non chiamano mai il vero Open Food Facts.

- [ ] Scegli un indirizzo di contatto dedicato all'app (un'email o la pagina del progetto). Non è un segreto, ma **non va mai nel repository**: `tool/check_off_config.sh` nel job `analyze` blocca il merge se un file lo contiene, e nei workflow il nome della chiave non deve comparire.
- [ ] Aggiungi la chiave `OFF_CONTACT` al file `config/firebase_prod.json` del §1, accanto alle chiavi `FIREBASE_*`, con il contatto come valore.
- [ ] Codifica di nuovo il file in Base64 e sostituisci il segreto `FIREBASE_PROD_DEFINES_JSON_B64` dell'**ambiente `play-internal`** (Settings → Environments → `play-internal`). Un segreto con lo stesso nome a livello di repository non conta: quello dell'ambiente lo sovrascrive.
- [ ] L'effetto arriva con la **versione successiva** dell'app (`release.yml` ricostruisce la configurazione a ogni build).
- [ ] **Spegnere Open Food Facts** (servizio cambiato, risposte sbagliate, blocchi): togli la chiave dal JSON, aggiorna il segreto nello stesso modo e pubblica una nuova versione (basta un push su `main`, anche solo della checklist di rilascio). Non è un interruttore remoto: i telefoni già aggiornati usano Open Food Facts finché non installano la nuova versione; nel frattempo il circuit breaker ne limita l'effetto.
- [ ] Prima di pubblicare una versione con Open Food Facts acceso, completa le voci "Catalogo dei vini" della checklist di rilascio (informativa privacy, scheda "Sicurezza dei dati", attribuzione).

## 10. Pagina web di cancellazione dell'account (u8-account, BR1.11, NFR4.7, NFR8.5)

La pagina automatica `docs/account-deletion/` (it, en, pt-BR) cancella l'account dal browser con l'accesso Google, senza server né funzioni nel cloud. Si pubblica sul ramo `gh-pages` con `pages.yml`, dopo le regole e la prova reale del flusso. Indirizzo: `https://brunobottazzini.github.io/Vinoozy/account-deletion/`.

**Prima pubblicazione statica (2026-11-09):** per rendere disponibili privacy e richiesta di cancellazione senza attendere la configurazione dell'applicazione web, `node tool/prepare_static_pages.mjs` esporta tre informative e tre pagine con richiesta via email. L'export non include Firebase, login o moduli automatici. Con autorizzazione pubblica esplicita del titolare, caricato sul nuovo ramo `gh-pages`, commit `9c086d3e65e3ef7f2eb9763a1501851eaaae467d`. Hosting sul ramo verificato, HTTPS obbligatorio, otto risorse pubbliche verificate HTTP 200 e SHA-256 corrispondente all'export. Questo bootstrap non soddisfa i controlli della futura pagina automatica descritti sotto.

**Repository pubblico** (GitHub Pages gratuito lo richiede), prima della prima pubblicazione:

- [ ] Controlla che nel repository non ci siano segreti: `config/firebase_prod.json` e `google-services.json` sono in `.gitignore` e mai committati (`git log --all -- config/firebase_prod.json '**/google-services.json'` non mostra nulla).
- [ ] Controlla tutta la cronologia con uno strumento di ricerca dei segreti, per esempio `gitleaks detect --source . --log-opts="--all"`. Ogni segreto trovato si revoca e si sostituisce **prima** di rendere pubblico il repository (riscrivere la cronologia non basta: chi l'ha già vista lo conosce).
- [ ] Solo dopo, Settings → General → Danger Zone → "Change visibility" → **Public**. Data: ______.

**Console Firebase, una volta:**

- [x] Registrata **Vinoozy Web** il 2026-11-09 nel progetto `vinoozy-d6f45` (app ID `1:742143174654:web:815bb282e4a519d0e042af`). Copiati dalla Console `apiKey`, `authDomain` (`vinoozy-d6f45.firebaseapp.com`), `projectId` e `appId` in `docs/account-deletion/firebase-config.js`. Sono valori pubblici per natura, non segreti. Hosting non configurato durante la registrazione; piano Spark invariato. Il bundle non va ricostruito: il file si carica a parte.
- [x] Authentication → Impostazioni → **Domini autorizzati**: aggiunto `brunobottazzini.github.io` il 2026-11-10 (Identity Toolkit Admin API; domini ora: `localhost`, `vinoozy-d6f45.firebaseapp.com`, `vinoozy-d6f45.web.app`, `brunobottazzini.github.io`).
- [x] **reCAPTCHA Enterprise**: API abilitata e chiave web di tipo `SCORE` **Vinoozy Web - App Check Enterprise** creata il 2026-11-10, limitata a `brunobottazzini.github.io`, con verifica del dominio attiva. Chiave pubblica in `recaptchaSiteKey` di `firebase-config.js`; provider `ReCaptchaEnterpriseProvider` e bundle aggiornati. La registrazione v3 inizialmente prevista è stata rifiutata dall'API App Check perché non più disponibile per nuove configurazioni; riutilizzata la stessa chiave score-based con Enterprise. Nessun segreto nel codice.
- [x] App Check → Applicazioni → **Vinoozy Web** registrata con **reCAPTCHA Enterprise**, TTL un'ora e soglia minima `0.5`, verificati tramite API il 2026-11-10. Firestore e Authentication restano `UNENFORCED` (modalità di controllo); fatturazione non collegata, piano Spark invariato. Configurazione locale pronta per la pubblicazione tramite il workflow previsto; il sito statico attuale non usa ancora Firebase.
- [x] Chiave API Firebase web limitata ai referrer `https://brunobottazzini.github.io/*` e `https://vinoozy-d6f45.firebaseapp.com/*` (gestore del popup Google), e alle sole API Identity Toolkit, Token Service, Cloud Firestore e Firebase App Check. Verificati HTTP 200 per entrambi i referrer, HTTP 403 per altri domini e richieste senza referrer, il 2026-11-10. Chiave Android invariata.
- [ ] **Obbligo di App Check su Firestore** (vale per l'app Android e per la pagina): resta in modalità di controllo. Attivalo solo quando, nelle metriche di App Check, le richieste verificate sono almeno il **99% per 7 giorni consecutivi**, contando insieme Android e web (stesso criterio del §2). Prima verifica che le versioni dell'app in produzione abbiano App Check (attivo dall'inizio in `lib/app/bootstrap.dart`). Data di attivazione: ______.

**GitHub, una volta:**

- [ ] Ambiente **`github-pages-publish`**: approvazione obbligatoria del proprietario, limitato a `main` (il workflow si avvia da `main`). Nessun segreto: `pages.yml` usa il `GITHUB_TOKEN` con `contents: write` e `actions: read`.
- [x] Ramo `gh-pages` creato con l'export statico iniziale: verificato Settings → Pages → "Deploy from a branch" → ramo **`gh-pages`**, con hosting e URL HTTPS operativi. Questo non certifica il flusso automatico Firebase.
- [ ] Ruleset sul ramo `gh-pages`: aggiornamento solo da GitHub Actions.

**Ogni pubblicazione:** merge, `firebase-deploy.yml`, poi `pages.yml` con `mode: publish` e lo stesso `ref` (si ferma con "Pubblica prima le regole con firebase-deploy.yml" se le regole pubblicate sono diverse, e se `firebase-config.js` ha ancora valori `TODO`), poi `promote.yml`. Rollback della pagina: `pages.yml` con `mode: rollback`.
