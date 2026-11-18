# Requisiti: rilascio automatico funzionante e E2E stabile

## Sources

- `Initial description:` [desc] `docs/github-actions-handoff.md` (verifica dell'11/11/2026), richiesta "vai".
- `Workflow-selected scope:` [scope] express, profondità Minimal, strategia di test Minimal.
- Risposte del proprietario: [Q1] li configura il proprietario; [Q2] `play-production` completo; [Q3] E2E corretto in questo lavoro con riproduzione; [Q4] esecuzione E2E sul Mac; [Q5] ambiente `play-production` creato dal proprietario.
- Mappa del codice: `aidlc/spaces/default/codekb/Vinoozy/` (scansione completa dell'11/11/2026).
- Regole del team: `team.md` (Deployment, Testing Posture, Code Style).

## Analisi dell'intento

Il proprietario vuole che ogni merge su `main` arrivi da solo sul canale di
test interno di Google Play, come previsto da `team.md` (Deployment), e che la
promozione in produzione funzioni con la sua approvazione. Oggi la release
fallisce senza dire perché: i segreti non esistono e il workflow non se ne
accorge finché `tool/play_api.sh` esce con codice 1 senza messaggio [desc].
Il lavoro ha tre parti:

1. il codice dei workflow e dello script deve fermarsi subito e dire
   **quale** segreto manca o è sbagliato e **in quale ambiente**;
2. il proprietario configura le credenziali seguendo una guida precisa [Q1],
   [Q5], e poi una release reale viene verificata;
3. il test E2E intermittente viene riprodotto e corretto [Q3].

Tipo: correzione e irrobustimento della consegna più correzione di un difetto
dell'app. Ampiezza: più componenti (workflow, script, documentazione, un
provider dell'app). Complessità: standard.

## Requisiti funzionali

### FR1. Verifica iniziale degli input di `release.yml`

- **FR1.1** Il job `internal` deve verificare i sette segreti obbligatori
  (`PLAY_INTERNAL_SA_JSON`, `ANDROID_UPLOAD_KEYSTORE_B64`,
  `ANDROID_UPLOAD_KEYSTORE_PASSWORD`, `ANDROID_UPLOAD_KEY_ALIAS`,
  `ANDROID_UPLOAD_KEY_PASSWORD`, `FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64`,
  `FIREBASE_PROD_DEFINES_JSON_B64`) e la variabile `GOOGLE_SERVER_CLIENT_ID`
  in uno step che precede ogni scrittura di file e ogni build.
  - *Given* uno o più input vuoti, *When* il job parte, *Then* lo step fallisce
    ed elenca in un solo messaggio **tutti** i nomi mancanti, ciascuno con il
    suo tipo (segreto o variabile) e l'ambiente `play-internal`.
  - *Given* tutti gli input presenti e validi, *Then* lo step passa e il job
    prosegue come oggi.
- **FR1.2** I tre input Base64 devono decodificarsi senza errori e produrre
  contenuto non vuoto; altrimenti l'errore nomina il segreto e dice
  "Base64 non valido" o "vuoto dopo la decodifica".
- **FR1.3** La struttura essenziale dei JSON deve essere verificata:
  - `PLAY_INTERNAL_SA_JSON`: JSON valido con `type` uguale a
    `service_account`, `client_email` e `private_key` non vuoti;
  - `google-services.json` decodificato: JSON valido con `project_info` e
    almeno un `client` il cui package è `com.vinoozy.app`;
  - dart-defines decodificati: oggetto JSON con `FIREBASE_API_KEY`,
    `FIREBASE_APP_ID`, `FIREBASE_PROJECT_ID` non vuoti.
  Un errore nomina il segreto e la regola violata, mai il valore.
- **FR1.4** La logica di verifica deve stare in uno script del repository
  (sullo schema dei `tool/check_*.sh`), così da poterla provare senza GitHub.
- **FR1.5** Lo step finale `Remove secret files` resta con `if: always()` e
  rimuove tutti i file scritti, anche quando la verifica fallisce.

### FR2. Messaggi chiari in `tool/play_api.sh`

- **FR2.1** Prima di autenticare, lo script deve controllare che il file
  indicato da `PLAY_SA_JSON_FILE` esista, sia leggibile, non sia vuoto e sia un
  JSON con `type` `service_account`, `client_email` e `private_key`. Ogni caso
  ha un messaggio distinto su stderr che nomina la variabile e il problema, e
  un codice d'uscita diverso da 0.
- **FR2.2** Se `gcloud auth activate-service-account` o la richiesta del token
  falliscono, lo script deve scrivere su stderr che l'autenticazione Play è
  fallita, con il motivo riportato da `gcloud` ripulito da qualsiasi chiave o
  token, e uscire con codice diverso da 0.
- **FR2.3** Se una chiamata alla Play Developer API fallisce, lo script deve
  scrivere su stderr il metodo, il percorso dell'API e lo stato HTTP, senza il
  token.
- **FR2.4** Con `next-version-code`, stdout deve contenere solo il numero e
  nient'altro; ogni diagnostica va su stderr. I comandi `promote`, `complete`
  e `halt` mantengono il comportamento attuale.

### FR3. Test della gestione degli errori senza credenziali reali

- **FR3.1** Un test di `tool/play_api.sh` con uno stub di `gcloud` (e di
  `curl`) deve coprire: variabile assente, file assente, file vuoto, JSON non
  valido, tipo diverso da `service_account`, autenticazione fallita, chiamata
  API fallita e caso riuscito (stdout uguale al solo numero atteso).
- **FR3.2** Un test dello script di verifica di FR1.4 deve coprire: input
  assente (più di uno insieme), Base64 non valido, contenuto vuoto dopo la
  decodifica, JSON non valido, campi obbligatori mancanti e caso valido.
- **FR3.3** Le fixture usano solo valori finti, riconoscibili come tali, e non
  fanno chiamate di rete.
- **FR3.4** I due test girano nel job `analyze` di `ci.yml`, accanto agli
  altri `tool/check_*_test.sh`.

### FR4. Promozione in produzione

- **FR4.1** `promote.yml` deve verificare `PLAY_PRODUCTION_SA_JSON` con le
  stesse regole di FR1.1 e FR1.3 prima di scrivere il file; l'errore nomina il
  segreto e l'ambiente `play-production`.
- **FR4.2** Il file della credenziale resta rimosso con `if: always()`.

### FR5. Guida di configurazione per il proprietario

- **FR5.1** Una guida in `docs/` deve elencare, per `play-internal`, i sette
  segreti e la variabile con nome esatto, contenuto atteso, formato (JSON in
  chiaro o Base64) e da quale file o pagina si ottiene ciascuno, con comandi
  macOS che copiano il valore negli appunti senza mostrarlo a schermo.
- **FR5.2** La guida deve spiegare come creare l'ambiente `play-production`
  con approvazione obbligatoria del proprietario e rilasci limitati al ramo
  `main`, e come aggiungere `PLAY_PRODUCTION_SA_JSON` [Q2], [Q5].
- **FR5.3** La guida deve indicare come controllare la configurazione senza
  leggere i valori (`gh secret list` e `gh variable list` per ambiente, solo
  i nomi) e come avviare la prima release dopo la configurazione.
- **FR5.4** `docs/firebase-setup.md` §5 e `docs/play-console-handoff.md` §3
  rimandano alla guida invece di duplicarla.

### FR6. Validazione della release reale

- **FR6.1** Dopo che il proprietario ha configurato `play-internal`, una
  release del commit validato dalla CI deve: calcolare il `versionCode` da
  Play, costruire l'AAB firmato, caricarlo sul canale interno e creare il tag
  `build-<versionCode>`. Il job `crashlytics-symbols` può restare saltato.
- **FR6.2** Push su `main` e avvio della release avvengono solo con il
  consenso esplicito del proprietario.

### FR7. Correzione del test E2E intermittente

- **FR7.1** Il fallimento del test 8 di `integration_test/u1_skeleton_test.dart`
  ("setState() or markNeedsBuild() called during build", `CellarSwitcher`
  durante la build di `CellarScreen`) deve essere riprodotto sul Mac [Q4], con
  il test singolo ripetuto e con la suite completa. Se non si riproduce
  sull'emulatore dopo almeno 10 esecuzioni del test, la causa va dimostrata
  con un test di widget deterministico che produce la stessa eccezione.
- **FR7.2** La correzione deve impedire che un cambio della cantina attiva
  segni da ricostruire un widget mentre un altro widget è in build, senza
  cambiare il comportamento visibile (cantina personale, scelta salvata,
  ritorno alla personale quando l'accesso si perde).
- **FR7.3** Un test di regressione deve fallire sul codice attuale e passare
  dopo la correzione.
- **FR7.4** Dopo la correzione, il test 8 deve passare in 10 esecuzioni
  consecutive sul Mac e la suite E2E completa deve passare sul Mac e nella CI.

## Requisiti non funzionali

- **NFR1** Nessun valore di credenziale nel repository, nei log, nei messaggi
  d'errore, nella guida o nelle fixture: solo nomi di segreti e variabili. Il
  job `secrets` (gitleaks) resta verde.
- **NFR2** `actionlint` passa su tutti i workflow modificati, in locale prima
  del commit e nel job `format` della CI.
- **NFR3** Fallire presto: con un input mancante il job `internal` termina
  nello step di verifica, prima di `Write secret files`, del setup di Flutter
  e di `flutter build`.
- **NFR4** Tutti i controlli della CI restano verdi: formattazione, analisi,
  test unit e widget con copertura dell'80% senza esclusioni, regole, E2E.
  Nessuna soglia viene abbassata (`team.md`, Testing Posture).
- **NFR5** Gli script restano compatibili con i runner `ubuntu-latest`
  (bash, `jq`, `base64`, `gcloud` preinstallati) e i test girano anche su
  macOS senza `gcloud` installato.
- **NFR6** Codice, identificatori, commenti e messaggi degli script in
  inglese; documentazione per il proprietario in italiano (`team.md`, Code
  Style; `project.md`).

## Vincoli

- Le credenziali stanno solo nei segreti degli ambienti GitHub e le inserisce
  il proprietario [Q1]; l'ambiente `play-production` lo crea il proprietario
  [Q5].
- Un rerun di una vecchia release rifà il checkout del commit della CI
  originaria: le modifiche al codice richiedono una nuova CI su `main` [desc].
- Repository pubblico su GitHub, piano gratuito: le protezioni degli ambienti
  (approvazione obbligatoria) sono disponibili.
- Trunk-based con squash merge su `main`; commit e push solo su richiesta del
  proprietario.
- Le modifiche locali del proprietario non committate
  (`distribution/google-play/data-safety.csv`, `docs/play-console-handoff.md`,
  `docs/release-checklist.md`, file non tracciati) vanno preservate.

## Assumptions & Open Questions

- [assumption] In `release.yml` `--dart-define=GOOGLE_SERVER_CLIENT_ID` viene
  dopo `--dart-define-from-file`, e anche il file di produzione locale
  contiene quella chiave: si assume che il define esplicito vinca, quindi una
  variabile vuota svuoterebbe il client ID. Per questo FR1.1 rende la
  variabile obbligatoria.
- [assumption] L'emulatore Android del Mac è API 36.1, mentre la CI usa API
  34: la riproduzione locale può non coincidere con la CI. Se serve, si crea
  un AVD API 34 (FR7.1 prevede comunque il test di widget deterministico).
- [assumption] `actionlint` e `shellcheck` non sono installati sul Mac;
  per NFR2 si installa `actionlint` in locale o si usa la stessa versione
  scaricata dalla CI.
- Aperta: il package del `client` in `google-services.json` di produzione si
  assume `com.vinoozy.app`; va confermato dal file reale durante la
  costruzione, senza stamparne il contenuto.

## Fuori ambito

- Inserire i valori delle credenziali (lo fa il proprietario).
- Configurare il job `crashlytics-symbols` (WIF e variabili facoltative).
- Eseguire una promozione in produzione: si prepara solo la configurazione.
- I vecchi fallimenti E2E della CI 9 (data dello Champagne, Cruscotto con 500
  vini, cancellazione account) se non ricompaiono.
- Il deploy delle Cloud Functions e il passaggio a Blaze.
