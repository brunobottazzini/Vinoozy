# Infrastructure Specification — u1-skeleton

Fonti: `security-design.md`, `performance-design.md`, `logical-components.md` (NFR Design di U1), `components.md`, `functional-spec.md`, `contract-summary.md`, `team.md` (Deployment), risposte in `infrastructure-design-questions.md` (Q1 Milano, Q2 repository pubblico esistente).

## Deployment

| Facet | Choice | Rationale |
|-------|--------|-----------|
| Modello di calcolo | App Android (Flutter) con servizi gestiti Firebase; nessun server nostro in U1 | Costo 0 €, nessuna manutenzione; le funzioni cloud arrivano con u3 |
| Rete | L'app parla solo con le API Firebase/Google via HTTPS; nessuna VPC | Servizi gestiti; TLS dagli SDK (NFR4.8) |
| Dati | Firestore in modalità nativa, database `(default)`, località `europe-west8` (Milano), definitiva (Q1) | Vicinanza agli utenti, dati in Italia, quota gratuita del database predefinito |
| Ambienti | **Locale/CI**: Firebase Emulator Suite con progetto `demo-vinoozy`. **Test interno**: Google Play internal track + progetto Firebase di produzione. **Produzione**: Google Play produzione + stesso progetto Firebase | Un solo progetto reale (team.md, Q9); gli emulatori non costano nulla |
| IaC | Nel repository: `firebase.json`, `.firebaserc`, `firestore.rules`, `firestore.indexes.json`. Le impostazioni che le API Firebase non coprono bene sono in una checklist versionata, `docs/firebase-setup.md`, applicata a mano una volta: provider di accesso, App Check, budget, collegamento Play Integrity, account di servizio Google Play, WIF e alert di `monitoring-design.md` | Terraform per un solo progetto costerebbe più manutenzione di quanta ne risparmia; la checklist rende la configurazione ripetibile |
| Dimensionamento | Nessun dimensionamento: Firestore scala da solo. Stima di NFR5.2: meno di 1.000 letture e 100 scritture al giorno | Molto sotto la quota gratuita |
| Repository | `github.com/brunobottazzini/Vinoozy`, **pubblico** (Q2) | Minuti di GitHub Actions illimitati; richiede le protezioni della sezione "Repository pubblico" |

## Infrastructure Services

| Service | Role | Configuration | Notes |
|---------|------|---------------|-------|
| Firebase Authentication | identità | Solo provider Google; accesso anonimo ed email/password disattivati; domini autorizzati di default | NFR4.1 |
| Cloud Firestore | database | `(default)`, `europe-west8`, modalità nativa; regole da `firestore.rules`; nessun indice composto in U1 | NFR4.2–NFR4.5, NFR6.1 |
| Firebase App Check | protezione | Provider Play Integrity collegato all'app Android; impronta SHA-256 della chiave di firma di Google Play registrata; Firestore in modalità di controllo, poi obbligatorio (99% per 7 giorni) | NFR4.6 |
| Firebase Crashlytics | crash | Attivo solo in release; nessun identificatore utente | NFR8.2 |
| Fatturazione Cloud | costo | Piano Blaze; budget mensile di 1 € con avvisi email al 50%, 90% e 100% | NFR5.3, NFR5.4 |
| Firebase Emulator Suite | test | Auth `9099`, Firestore `8080`, UI disattivata in CI; progetto `demo-vinoozy` | NFR4.7, team.md |
| Google Play Console | distribuzione | App `com.vinoozy.app` (nome del pacchetto definitivo), firma gestita da Google Play (Play App Signing), canali "Test interno" e "Produzione" | team.md Deployment |
| GitHub Actions | CI/CD | Vedi `cicd-pipeline.md`; ambienti GitHub `play-internal`, `play-production`, `firebase-prod` | team.md Way of Working |

## Repository pubblico: protezioni

| Protezione | Configurazione | Motivo |
|------------|----------------|--------|
| Nessun segreto nel codice | `google-services.json` e `options_prod.dart` in `.gitignore`; generati dal job di build | NFR4.7 |
| Scansione dei segreti | GitHub secret scanning e push protection attivi | Blocca un push che contiene una chiave |
| Ramo `main` protetto | Solo squash merge, storia lineare, tutti i controlli richiesti verdi, nessun push diretto (anche per l'amministratore) | team.md Way of Working |
| Fork | I workflow usano `pull_request` (mai `pull_request_target`); le richieste da fork non ricevono segreti né pubblicano build; i workflow dei nuovi contributori richiedono approvazione | Evita che codice esterno legga i segreti |
| Permessi dei workflow | `permissions: contents: read` predefinito; permessi in più solo nel job che li usa | Minimo privilegio |
| Azioni di terze parti | Fissate per SHA del commit; aggiornate da Dependabot | Protezione da modifiche malevole alle azioni |
| Ambienti con approvazione | `play-production` e `firebase-prod` richiedono l'approvazione del proprietario; tutti gli ambienti sono limitati a `main` (e `firebase-prod` anche ai tag `v*`) | team.md: produzione e regole solo con approvazione manuale |

## Identità per la CI

| Identità | Usata da | Permessi | Dove sta |
|----------|----------|----------|----------|
| Federazione d'identità (Workload Identity Federation) GitHub → Google Cloud | `firebase-deploy.yml` | `roles/firebaserules.admin`, `roles/datastore.indexAdmin`, `roles/firebase.viewer`, `roles/serviceusage.serviceUsageConsumer` sul solo progetto di produzione; accettata solo dal repository `brunobottazzini/Vinoozy` e dall'ambiente `firebase-prod` | Nessuna chiave: token a breve scadenza |
| Account di servizio Google Play `play-internal-publisher` | `release.yml` | Sulla sola app Vinoozy: solo "Rilascia nei canali di test" (niente produzione) | Segreto `PLAY_INTERNAL_SA_JSON` nel solo ambiente `play-internal` |
| Account di servizio Google Play `play-production-publisher` | `promote.yml` | Sulla sola app Vinoozy: "Rilascia in produzione" | Segreto `PLAY_PRODUCTION_SA_JSON` nel solo ambiente `play-production`, con approvazione |
| Chiave di caricamento Android (upload key) | `release.yml` | Firma il bundle prima del caricamento; la chiave di firma finale la custodisce Google Play | Segreti `ANDROID_UPLOAD_KEYSTORE_B64`, `ANDROID_UPLOAD_KEYSTORE_PASSWORD`, `ANDROID_UPLOAD_KEY_ALIAS`, `ANDROID_UPLOAD_KEY_PASSWORD` nell'ambiente `play-internal` |
| Configurazione Firebase di produzione | `release.yml` | Non è una credenziale, ma resta fuori dal repository (NFR4.7) | Segreti `FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64`, `FIREBASE_PROD_OPTIONS_DART_B64` |

Se la chiave di caricamento viene persa o esposta, si chiede a Google Play di sostituirla; la chiave di firma finale non è mai uscita da Google.

## Shared Infrastructure

| Shared Resource | Owner Unit | Consumer Units | Access Boundary |
|-----------------|------------|----------------|-----------------|
| Progetto Firebase di produzione | u1-skeleton | tutte | Ogni unità aggiunge solo le proprie regole e i propri servizi |
| `firestore.rules` | u1-skeleton (funzioni comuni, users, cantina del proprietario) | u4-cellar (delete dei vini), u7-sharing (persone invitate) | Una modifica alle regole richiede i test delle regole verdi |
| Workflow di CI/CD | u1-skeleton | tutte | Le unità aggiungono passi di test, non cambiano i controlli richiesti |
| `europe-west8` | u1-skeleton | u3-wine-catalog, u6-label-recognition (funzioni e Storage nella stessa regione) | Decisione definitiva (Q1) |
