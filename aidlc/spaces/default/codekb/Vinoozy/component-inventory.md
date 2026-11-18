# Component Inventory

Un componente per riga logica del sistema. Le dipendenze tra pacchetti e le versioni sono in `dependencies.md` e `technology-stack.md`; i punti toccati dalle lingue sono in `code-structure.md`.

## Application Components

### App Shell
- **Percorso**: `lib/main.dart`, `lib/app/`, `lib/core/`
- **Responsabilità**: avvio (`AppBootstrap`), collegamento dei servizi, `VinoozyApp` (`MaterialApp`, tema, lingua), guscio con le schede, ascolto degli eventi di sincronizzazione alla radice, schermata delle informazioni, apertura di link esterni, segnalazione degli errori.
- **Dipende da**: tutti i moduli dell'app, Localization, Firebase Bootstrap.

### Localization
- **Percorso**: `lib/l10n/`, `l10n.yaml`, `lib/app/locale_resolution.dart`
- **Responsabilità**: testi dell'interfaccia in ARB, codice generato `AppLocalizations`, elenco delle lingue offerte, scelta della lingua dalla lista del telefono, ripiego sull'inglese.
- **Dipende da**: `flutter_localizations`, `intl`.
- **Usato da**: ogni schermata; `AppBootstrap` per il nome della cantina predefinita.

### Account
- **Percorso**: `lib/account/`
- **Responsabilità**: accesso con Google, stato della sessione (`AccountGate`), blocco e cambio account, onboarding, profilo, cancellazione dell'account in passi ripetibili.
- **Dipende da**: Sync, Cellar (repository delle cantine), Firebase Auth.

### Cellar
- **Percorso**: `lib/cellar/`
- **Responsabilità**: modello del vino e della bevuta, repository Firestore, stima salvata e suo aggiornamento, filtri, origini (`WineOrigins`: paesi, regioni, bandiere), schermate di cantina, dettaglio, aggiunta, modifica, storico, conferma guidata.
- **Dipende da**: Estimation Package, Catalog, Sync, Usage, Localization.

### Catalog
- **Percorso**: `lib/catalog/`
- **Responsabilità**: contratto C1; ordine e fusione delle fonti (cantina, database offline dei vini, catalogo interno, Open Food Facts), cache su file, interruttore di circuito, budget di richieste.
- **Dipende da**: Estimation Package (normalizzazione e denominazioni), `http`, `assets/wine_db/`.

### Label
- **Percorso**: `lib/label/`
- **Responsabilità**: acquisizione della foto, lettura di testo e codice a barre sul telefono, sessione di lettura, ricerca online, Google Lens, immagini e testi condivisi, file temporanei.
- **Dipende da**: Catalog, Estimation Package, Android Host, ML Kit.

### Dashboard
- **Percorso**: `lib/dashboard/`
- **Responsabilità**: riepilogo calcolato in un solo passaggio, grafici a barre, elenco "da bere presto", vini da confermare. Sola lettura.
- **Dipende da**: Cellar (modello e origini), Estimation Package. Plan e Ads forniscono gli avvisi e l'annuncio mostrati nel Cruscotto.

### Sharing
- **Percorso**: `lib/sharing/`
- **Responsabilità**: inviti per email, appartenenze, cambio della cantina attiva, avvisi di accesso concesso o perso.
- **Dipende da**: Cellar, Account, Usage.

### Sync
- **Percorso**: `lib/sync/`
- **Responsabilità**: registro locale delle scritture in attesa, verifica in background, bus degli errori, stato di sincronizzazione, banner offline, avviso del vino rifiutato.
- **Dipende da**: `shared_preferences`, Firestore.

### Plan
- **Percorso**: `lib/plan/`
- **Responsabilità**: diritti Plus, politica del piano, risoluzione delle capacità, limite di capienza, acquisto su Google Play e sua verifica, schermata Plus.
- **Dipende da**: Cloud Functions, Usage, Dev Tools (sovrascritture di sviluppo).

### Ads
- **Percorso**: `lib/ads/`
- **Responsabilità**: idoneità, consenso, riserva dello slot e caricamento dell'annuncio giornaliero del Cruscotto.
- **Dipende da**: Cloud Functions, `google_mobile_ads`, Plan.

### Usage
- **Percorso**: `lib/usage/`
- **Responsabilità**: conteggio delle operazioni Firestore per account, distinto tra uso personale e di sistema, stima del costo, invio periodico.
- **Dipende da**: Cloud Functions, `shared_preferences`.

### Firebase Bootstrap
- **Percorso**: `lib/firebase/`
- **Responsabilità**: scelta dell'ambiente (`demo` con emulatori, `prod`), opzioni Firebase da `--dart-define`, configurazione e reset di Firestore.

### Dev Tools
- **Percorso**: `lib/dev/`
- **Responsabilità**: pannello di sviluppo nascosto, presente solo nelle build non di rilascio con `ENABLE_DEV_CHEATS` ed emulatori.

### E2E Hooks
- **Percorso**: `lib/e2e/`
- **Responsabilità**: lingua italiana forzata, accesso Google simulato con l'emulatore, controllo della rete per i test end-to-end. Assenti dalle build di rilascio (`tool/check_release_build.sh`).

## Libraries and Services

### Estimation Package
- **Percorso**: `packages/estimation/`
- **Responsabilità**: contratto C2; finestre di consumo, stato, abbinamenti, profili di stile, livello, tabelle di denominazioni (Italia, Francia, Europa, Nuovo Mondo, generate dai registri) e vitigni, estrazione dei campi dal testo d'etichetta, nomi dei paesi sulle etichette.
- **Dipende da**: nulla in produzione.

### Cloud Functions
- **Percorso**: `functions/`
- **Responsabilità**: verifica degli acquisti, notifiche Play, misura d'uso, slot annunci, guardia del budget, pulizia dopo la cancellazione di un account.
- **Dipende da**: `firebase-functions`, `firebase-admin`, `googleapis`, `@google-cloud/billing`.

### Firestore Rules
- **Percorso**: `firestore.rules`, `firestore.indexes.json`, `test/rules/`
- **Responsabilità**: autorizzazione e validazione dei documenti, indici; test su emulatore, compresa la compatibilità con le versioni già distribuite.

### Android Host
- **Percorso**: `android/`
- **Responsabilità**: `MainActivity` e canali di piattaforma, `LabelImagePreparer`, `LensIntentLauncher`, `SharedImageReceiver`, manifest e permessi, firma e configurazione di build.

### Account Deletion Web
- **Percorso**: `docs/account-deletion/`, `docs/privacy/`, `test/web/`
- **Responsabilità**: pagine pubbliche di cancellazione dell'account e di privacy in it, en, pt-BR.

## Delivery Components

### Store Listing
- **Percorso**: `distribution/google-play/`
- **Responsabilità**: titolo, descrizione breve ed estesa per `it-IT`, `en-US`, `pt-BR`; note di rilascio; catture per lingua; icona e feature graphic; dichiarazioni sulla sicurezza dei dati; istruzioni per revisori e tester.

### Tooling
- **Percorso**: `tool/`, `benchmark/`, `package.json`
- **Responsabilità**: controlli di CI con il rispettivo test, copertura, generatori (`build_wine_db.dart`, `build_appellations.dart`, `build_profile_map.dart`, `gen_coverage_helper.dart`), script Play, script del proprietario in `tool/admin/`, soglie di velocità.

### CI/CD Workflows
- **Percorso**: `.github/workflows/`, `.github/dependabot.yml`
- **Responsabilità**: controlli prima del merge, rilascio sul canale di test interno, promozione in produzione, distribuzione di regole, Functions e pagine web.

### Test Suites
- **Percorso**: `test/`, `integration_test/`, `integration_test_perf/`, `test_driver/`, `packages/estimation/test/`, `functions/test/`, `android/app/src/test/`
- **Responsabilità**: test unitari, dei widget (con matrice di accessibilità per lingua), delle regole, end-to-end e di prestazioni.

## Component Counts

| Tipo | Numero |
|---|---|
| Componenti dell'applicazione | 15 |
| Librerie e servizi | 5 |
| Componenti di consegna | 4 |
| Totale | 24 |
