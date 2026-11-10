# Passaggio da Spark a Blaze e pubblicazione delle funzioni

Procedura per il proprietario, da seguire **una volta sola** e **in quest'ordine** (intent `261110-freemium-plus`, FR9.1, FR9.2, FR9.3). Serve solo quando vuoi accendere Plus o la misurazione dell'uso sul server: finché le funzioni non sono pubblicate l'app funziona come oggi, perché `config/policy` lascia spenti acquisti, limite e annunci.

Nessun workflow di GitHub Actions pubblica le funzioni: lo fai tu dal tuo Mac, con i comandi qui sotto. Il budget del progetto è **0 €/mese**, con un avviso a **1 €** (`team.md`, vincolo C6). Le protezioni di questa pagina servono a restare lì.

Dati del progetto:

- progetto Firebase: `vinoozy-d6f45`, numero **742143174654**;
- regione di Firestore e delle funzioni: **`europe-west8` (Milano)**;
- account di servizio con cui girano le funzioni di 2ª generazione: `742143174654-compute@developer.gserviceaccount.com` (account predefinito di Compute Engine);
- account di servizio della funzione di 1ª generazione `onUserDeleted`: `vinoozy-d6f45@appspot.gserviceaccount.com` (account predefinito di App Engine).

Controlla i due indirizzi in Google Cloud Console → IAM e amministrazione → Account di servizio: se il numero del progetto fosse diverso, usa quelli che vedi lì.

Spunta ogni voce quando è fatta e annota la data.

## 0. Prima di iniziare

- [ ] Sul Mac: Node 22 (`.nvmrc`) e le dipendenze del repository, installate senza strumenti globali:

  ```bash
  npm ci
  npm ci --prefix functions
  npm ci --prefix tool/admin
  ```

- [ ] I test passano in locale: `npm run test:functions` e `npm run test:admin` (girano solo sugli emulatori `demo-vinoozy`, non toccano il progetto reale).
- [ ] Accesso alla CLI di Firebase con il tuo account Google (non con un account di servizio): `npx firebase login`.

## 1. Passaggio a Blaze con un budget di 1 €

- [ ] Firebase Console → progetto `vinoozy-d6f45` → **Utilizzo e fatturazione** → **Dettagli e impostazioni** → **Modifica piano** → **Blaze**. Scegli o crea il conto di fatturazione Cloud.
- [ ] Durante il passaggio Firebase propone un budget: imposta **1 €**. Se non lo propone, crealo al passo 2.

Da questo momento il progetto può spendere. Il passo 2 va fatto subito, prima di pubblicare qualsiasi cosa.

## 2. Budget con avviso a 1 € e topic Pub/Sub `budget-alerts`

- [ ] Google Cloud Console → **Fatturazione** → **Budget e avvisi** → **Crea budget**:
  - nome: `vinoozy-1-euro`;
  - ambito: solo il progetto `vinoozy-d6f45`, tutti i servizi;
  - tipo: importo specificato, **1 EUR** al mese;
  - soglie: **50%, 90% e 100%** della spesa effettiva, con email agli amministratori del conto.
- [ ] Nella stessa pagina, in **Gestisci notifiche**, attiva **Collega un argomento Pub/Sub a questo budget** e crea l'argomento **`budget-alerts`** nel progetto `vinoozy-d6f45`. È il nome che la funzione `onBudgetAlert` ascolta (si può cambiare solo con `functions/.env`, variabile `BUDGET_ALERT_TOPIC`).

Cosa fa `onBudgetAlert`: riceve le notifiche del budget (Google le manda più volte al giorno) e, **solo quando la spesa supera strettamente il budget** (`costAmount > budgetAmount`), scollega il conto di fatturazione dal progetto e registra l'evento in `billingEvents/{messageId}`.

Limiti da conoscere:

- i dati di costo arrivano a Google con ore di ritardo: la spesa reale può superare 1 € di qualche centesimo prima che la notifica arrivi;
- con la fatturazione scollegata **si fermano le funzioni**, mentre l'app continua a leggere e scrivere la cantina entro le quote gratuite. Per riattivare devi ricollegare a mano il conto (Fatturazione → Gestione account → Modifica fatturazione) dopo aver capito la causa;
- Google indica che, se un progetto resta a lungo senza fatturazione, alcune risorse a pagamento possono essere eliminate. Leggi la pagina [Disattivare la fatturazione con le notifiche](https://cloud.google.com/billing/docs/how-to/disable-billing-with-notifications) prima di confermare.

## 3. Permesso di scollegare la fatturazione

La funzione `onBudgetAlert` gira con l'account di servizio delle funzioni di 2ª generazione e deve poter scollegare la fatturazione del solo progetto Vinoozy.

- [ ] Google Cloud Console → **API e servizi** → **Libreria** → attiva **Cloud Billing API** (`cloudbilling.googleapis.com`) nel progetto `vinoozy-d6f45`.
- [ ] **IAM e amministrazione** → **IAM** → **Concedi accesso**: entità `742143174654-compute@developer.gserviceaccount.com`, ruolo **Project Billing Manager** (`roles/billing.projectManager`), sul **progetto** `vinoozy-d6f45`. Non dare ruoli sul conto di fatturazione: il ruolo sul progetto basta a scollegarlo.

## 4. Pulizia di Artifact Registry (ultime 2 immagini)

Ogni pubblicazione delle funzioni lascia un'immagine container in Artifact Registry, che occupa spazio a pagamento. Teniamo solo le ultime 2.

- [ ] Alla prima pubblicazione (passo 5) la CLI di Firebase chiede quanti giorni tenere le immagini: rispondi **1**. Crea così una regola di pulizia sul repository `gcf-artifacts` di `europe-west8`.
- [ ] Poi Google Cloud Console → **Artifact Registry** → repository **`gcf-artifacts`** (regione `europe-west8`) → **Modifica** → **Criteri di pulizia**:
  - aggiungi un criterio **Mantieni le versioni più recenti** con **2** versioni;
  - lascia il criterio di eliminazione creato dalla CLI;
  - disattiva **Dry run** e salva.
- [ ] Dopo una settimana controlla che il repository abbia al massimo 2 versioni per funzione.

## 5. Pubblicazione delle funzioni in `europe-west8`

Le funzioni sono quelle di `functions/README.md`: `verifyPurchase`, `reportUsage`, `reserveAdSlot`, `recordAdOutcome`, `onPlayRtdn`, `reconcileEntitlements`, `onBudgetAlert`, `onUserDeleted` e `purgeOldUsage`. La regione è nel codice (`functions/src/config.ts`), non va scelta.

- [ ] Prima delle funzioni, l'argomento Pub/Sub delle notifiche di Play `play-rtdn` deve esistere: crealo come indicato in `docs/plus-setup.md` §3 (anche se Plus non è ancora in vendita).
- [ ] Le **regole Firestore** di questa versione (raccolte `entitlements`, `config`, `usage`, `adSlots`, `purchases` e contatore `activeWineCount`) sono pubblicate con `firebase-deploy.yml` e la tua approvazione, come sempre.
- [ ] Pubblica le funzioni dalla cartella del repository:

  ```bash
  npx firebase deploy --only functions --project vinoozy-d6f45
  ```

  La CLI compila `functions/` (`predeploy` di `firebase.json`) e attiva da sola le API che servono (Cloud Functions, Cloud Build, Artifact Registry, Cloud Run, Eventarc, Pub/Sub, Cloud Scheduler). Alla domanda sulla pulizia delle immagini rispondi come al passo 4.
- [ ] **Pubblicazioni successive con `functions-deploy.yml`.** La prima pubblicazione falla dal Mac come sopra, perché attiva le API e imposta la pulizia delle immagini. Le successive passano da GitHub Actions: avvia `functions-deploy` con un tag `v*` o con un commit di `main`. Il workflow esegue i test del backend e poi aspetta la tua approvazione nell'ambiente `firebase-prod`, come per le regole.
  - Prima della prima esecuzione, dai all'account di servizio del deploy (`vars.WIF_SERVICE_ACCOUNT`) questi ruoli sul progetto:
    - **Cloud Functions Admin** (`roles/cloudfunctions.admin`);
    - **Service Account User** (`roles/iam.serviceAccountUser`) sull'account `742143174654-compute@developer.gserviceaccount.com`;
    - **Artifact Registry Writer** (`roles/artifactregistry.writer`);
    - **Cloud Scheduler Admin** (`roles/cloudscheduler.admin`);
    - **Pub/Sub Editor** (`roles/pubsub.editor`).
  - Non dare ruoli di proprietario né ruoli sulla fatturazione.
  - Il workflow è separato da `firebase-deploy.yml` di proposito: la promozione in produzione legge l'ultima esecuzione di `firebase-deploy.yml` per sapere quali regole sono pubblicate.
- [ ] Firebase Console → **Functions**: le 9 funzioni risultano in `europe-west8`, senza errori.
- [ ] Prova del budget senza spendere: Google Cloud Console → **Pub/Sub** → argomento `budget-alerts` → **Messaggi** → **Pubblica messaggio** con questo corpo, dove la spesa è **sotto** il budget:

  ```json
  {"budgetDisplayName":"prova","costAmount":0.10,"budgetAmount":1.00,"currencyCode":"EUR"}
  ```

  Nei log (Firebase Console → Functions → Log) `onBudgetAlert` risulta eseguita senza errori, la fatturazione resta collegata e in Firestore non nasce nessun documento in `billingEvents`. Un messaggio senza `costAmount` o `budgetAmount` compare invece come «Malformed budget notification». Non pubblicare mai a mano un messaggio sopra il budget: scollegherebbe davvero la fatturazione.

## 6. Accensione degli acquisti (`purchasesEnabled`)

Solo dopo aver completato `docs/plus-setup.md` (prodotto in Play Console, Play Developer API, notifiche RTDN, App Check):

- [ ] Accendi gli acquisti (credenziali come in `docs/plus-setup.md` §6):

  ```bash
  node tool/admin/set_policy.mjs --project vinoozy-d6f45 --credentials <percorso fuori dal repository> --purchases-enabled true
  ```

  Lo script stampa e verifica l'ID del progetto e mostra `config/policy` dopo la modifica.
- [ ] Sul telefono, con la build del test interno: Profilo → **Scopri Plus** mostra i prezzi presi da Google Play e il pulsante d'acquisto. Fai un acquisto di prova con un account tester di licenza (`docs/plus-setup.md` §1): il Profilo passa a «Plus».

Per tornare indietro in qualsiasi momento: `--purchases-enabled false`. Chi ha già Plus lo conserva fino alla scadenza.

## Riepilogo dell'ordine

1. Blaze con budget di 1 €.
2. Budget con avvisi e argomento `budget-alerts`.
3. Cloud Billing API e ruolo Project Billing Manager all'account delle funzioni.
4. Pulizia di Artifact Registry (ultime 2 immagini).
5. Regole Firestore, poi funzioni in `europe-west8`, poi prova del budget sotto soglia.
6. `docs/plus-setup.md`, poi `purchasesEnabled`.
