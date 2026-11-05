# Configurazione di Firebase, Google Play e GitHub (una volta sola)

Checklist versionata delle impostazioni che le API non coprono bene (`infrastructure-specification.md`, colonna IaC). Si applica a mano una sola volta, nell'ordine indicato. Per sviluppare e testare **non serve nulla di tutto questo**: emulatori e progetto `demo-vinoozy` funzionano senza account.

Spunta ogni voce quando è fatta e annota la data.

## 1. Progetto Firebase di produzione

- [ ] Crea il progetto Firebase (un solo progetto reale, `team.md` Q9) e passa al piano **Blaze**.
- [ ] Firestore in modalità nativa, database `(default)`, località **`europe-west8` (Milano)**. La località è definitiva.
- [ ] Authentication: attiva **solo il provider Google**. Accesso anonimo ed email/password restano disattivati (NFR4.1).
- [ ] Registra l'app Android `com.vinoozy.app`. Dalla console scarica `google-services.json` e scrivi `config/firebase_prod.json` con i valori `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET` (presi da `google-services.json`), **senza** committarli: vanno solo nei segreti (§5). L'app li riceve con `--dart-define-from-file=config/firebase_prod.json`.
- [ ] Prendi l'**OAuth web client id** del progetto (Authentication → Google → Web SDK configuration) e salvalo come variabile GitHub `GOOGLE_SERVER_CLIENT_ID` (è pubblico, non è un segreto).

## 2. App Check e Play Integrity (NFR4.6)

- [ ] In Play Console collega l'app al progetto Google Cloud e attiva l'API Play Integrity.
- [ ] In Firebase → App Check registra l'app Android con il provider **Play Integrity**, con l'impronta SHA-256 della **chiave di firma di Google Play** (Play Console → Integrità dell'app).
- [ ] Lascia Firestore in **modalità di controllo**. Rendi App Check obbligatorio solo quando, per 7 giorni di test interno, almeno il **99%** delle richieste risulta verificato.
- [ ] Il token di debug (solo build di debug su telefono reale) resta sul tuo computer: mai nel repository né nei segreti.

## 3. Budget (NFR5.3, NFR5.4)

- [ ] Google Cloud Billing → Budget mensile di **1 €** sul progetto, avvisi email al 50%, 90% e 100%. L'avviso informa ma non blocca la spesa (rischio accettato).

## 4. Federazione d'identità (WIF): deploy delle regole e simboli di Crashlytics

Nessuna chiave JSON: GitHub Actions ottiene token a breve scadenza. Un solo pool e un solo provider servono due ambienti GitHub, ognuno legato al proprio account di servizio con il ruolo minimo.

- [ ] Crea un Workload Identity Pool e un provider OIDC per GitHub, con la mappatura `attribute.environment = assertion.environment` e questa condizione sugli attributi:
  `assertion.repository == 'brunobottazzini/Vinoozy' && assertion.environment in ['firebase-prod', 'crashlytics-symbols']`.
- [ ] Account di servizio del **deploy delle regole** (`firebase-deploy.yml`) con **solo** questi ruoli sul progetto di produzione: `roles/firebaserules.admin`, `roles/datastore.indexAdmin`, `roles/firebase.viewer`, `roles/serviceusage.serviceUsageConsumer`.
  Concedi `roles/iam.workloadIdentityUser` su questo account **solo** al principale `principalSet://iam.googleapis.com/<pool>/attribute.environment/firebase-prod`.
- [ ] Facoltativo, account di servizio dei **simboli di Crashlytics** (job `crashlytics-symbols` di `release.yml`) con **solo** `roles/firebasecrashlytics.admin` e `roles/serviceusage.serviceUsageConsumer` sul progetto di produzione.
  Concedi `roles/iam.workloadIdentityUser` su questo account **solo** al principale `principalSet://iam.googleapis.com/<pool>/attribute.environment/crashlytics-symbols`.
- [ ] Variabili dell'ambiente GitHub `firebase-prod`: `WIF_PROVIDER`, `WIF_SERVICE_ACCOUNT`, `FIREBASE_PROD_PROJECT_ID`.
- [ ] Variabile dell'ambiente GitHub `crashlytics-symbols`: `WIF_PROVIDER`. Variabili **del repository** (non dell'ambiente): `CRASHLYTICS_WIF_SERVICE_ACCOUNT` e `FIREBASE_ANDROID_APP_ID` (identificativi pubblici, non segreti). Devono stare a livello di repository perché la condizione `if` del job `crashlytics-symbols` viene valutata prima che il job entri nel suo ambiente e non vede le variabili d'ambiente. Finché mancano, `release.yml` salta solo il job dei simboli.

## 5. Google Play: app e i due account di servizio

- [ ] Crea l'app in Play Console con il pacchetto **`com.vinoozy.app`** e attiva **Play App Signing**. Il primo AAB va caricato a mano, poi `release.yml` fa il resto.
- [ ] Verifica se il tuo account sviluppatore deve fare un test chiuso con 12 tester per 14 giorni prima della produzione.
- [ ] Account di servizio **`play-internal-publisher`**: in Play Console, sulla sola app Vinoozy, solo il permesso "Rilascia nei canali di test". La chiave JSON va nel segreto `PLAY_INTERNAL_SA_JSON` dell'ambiente `play-internal`.
- [ ] Account di servizio **`play-production-publisher`**: sulla sola app Vinoozy, permesso "Rilascia in produzione". La chiave va nel segreto `PLAY_PRODUCTION_SA_JSON` dell'ambiente `play-production`.
- [ ] Chiave di caricamento (upload key): segreti `ANDROID_UPLOAD_KEYSTORE_B64`, `ANDROID_UPLOAD_KEYSTORE_PASSWORD`, `ANDROID_UPLOAD_KEY_ALIAS`, `ANDROID_UPLOAD_KEY_PASSWORD` nell'ambiente `play-internal`. Se va persa o è esposta, chiedi a Google Play di sostituirla.
- [ ] Configurazione di produzione: segreti `FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64` e `FIREBASE_PROD_DEFINES_JSON_B64` (file del §1 in Base64) nell'ambiente `play-internal`.
- [ ] I simboli di Crashlytics **non** usano chiavi né segreti: vedi §4 (WIF, ambiente `crashlytics-symbols`). Se in passato hai creato il segreto `FIREBASE_SYMBOLS_SA_JSON`, cancellalo e revoca la chiave in Google Cloud.

## 6. Repository GitHub (pubblico) e ambienti

- [ ] Ruleset sul ramo **`main`**: solo squash merge, storia lineare, nessun push diretto (anche per l'amministratore), controlli richiesti `format`, `analyze`, `unit`, `rules`, `e2e`.
- [ ] Ruleset sui tag **`v*`** e **`build-*`**: creazione solo dai workflow (GitHub Actions come unico bypass), nessuna modifica né cancellazione. Così i tag di promozione `v<versionName>+<versionCode>` e di build non si possono spostare.
- [ ] **Secret scanning** e **push protection** attivi.
- [ ] Actions → "Require approval for first-time contributors". I workflow usano solo `pull_request`, mai `pull_request_target`.
- [ ] Ambienti:
  - `play-internal`: limitato a `main`;
  - `play-production`: limitato a `main`, approvazione obbligatoria del proprietario;
  - `firebase-prod`: limitato a `main` e ai tag `v*`, approvazione obbligatoria del proprietario;
  - `crashlytics-symbols`: limitato a `main`, senza approvazione (carica solo i simboli di debug, nessun segreto).

## 7. Alert (`monitoring-design.md`)

- [ ] Crashlytics: notifiche email per nuovi problemi, regressioni e **nuovi problemi non fatali** (evento `SyncRejected`).
- [ ] Crashlytics → Impostazioni → **velocity alert** con soglia all'**1% degli utenti in 1 ora**.
- [ ] Cloud Monitoring: alert sui rifiuti delle regole Firestore con esito negato **> 50 in 1 ora**, email al proprietario. Prima di crearlo **verifica nel Metrics Explorer il nome esatto della metrica e delle etichette** (cerca le valutazioni delle regole di Firestore), perché il nome non è stato confermato in progettazione. Annota qui il nome usato: `______________________`.
- [ ] GitHub: notifiche email per i workflow falliti su `main`.

## 8. Prima distribuzione delle regole

- [ ] Dopo il primo merge, esegui `firebase-deploy.yml` con `ref` uguale a `main` (o al primo tag `v*`) e approva l'ambiente `firebase-prod`.
