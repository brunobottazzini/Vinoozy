# Configurazione di Plus, del limite e degli strumenti amministrativi

Procedura per il proprietario (intent `261110-freemium-plus`: FR2.3, FR3.1–FR3.5, FR4.1–FR4.4, NFR1, NFR6). Si fa **dopo** `docs/blaze-switch.md` §1–§5, cioè con il progetto su Blaze e le funzioni pubblicate in `europe-west8`, e **prima** di accendere `purchasesEnabled` (`docs/blaze-switch.md` §6).

Identificativi fissi (costanti in `functions/src/config.ts` e `lib/plan/billing/purchase_verifier.dart`):

| Cosa | Valore |
|---|---|
| Pacchetto Google Play | `com.vinoozy.app` (l'`applicationId`; `com.vinoozy.vinoozy` è solo il namespace del codice) |
| Prodotto in abbonamento | `vinoozy_plus` |
| Piani base | `monthly` (1,99 €/mese) e `annual` (14,99 €/anno) |
| Progetto Firebase | `vinoozy-d6f45` (numero 742143174654) |
| Account di servizio delle funzioni | `742143174654-compute@developer.gserviceaccount.com` |
| Argomento Pub/Sub delle notifiche Play | `play-rtdn` |

Spunta ogni voce quando è fatta e annota la data.

## 1. Prodotto e piani base in Play Console

- [ ] Play Console → **Configurazione** → **Profilo pagamenti**: il profilo commerciante è attivo (senza, Play non permette prodotti a pagamento).
- [ ] Sul canale di test interno c'è già una build che contiene questa versione (il manifest dichiara `com.android.vending.BILLING`, controllato da `tool/check_release_build.sh`). Play Console non permette di creare abbonamenti prima.
- [ ] **Monetizza con Play** → **Prodotti** → **Abbonamenti** → **Crea abbonamento**:
  - ID prodotto: **`vinoozy_plus`** (non si può cambiare dopo);
  - nome: «Vinoozy Plus», con i vantaggi presi dai testi dello studio §7.8.
- [ ] Dentro `vinoozy_plus` → **Aggiungi piano base**:
  - ID **`monthly`**, rinnovo automatico, periodo **1 mese**, prezzo **1,99 €** (Play converte gli altri paesi);
  - ID **`annual`**, rinnovo automatico, periodo **1 anno**, prezzo **14,99 €**.
  - Attiva entrambi i piani base. Nessuna offerta di prova per ora.
- [ ] **Impostazioni** → **Test delle licenze**: aggiungi il tuo account Google e quelli dei tester. Con questi account gli acquisti sono di prova, senza addebito, e gli abbonamenti si rinnovano ogni pochi minuti.

Un acquisto di un altro prodotto o di un altro piano base viene rifiutato dal server con `WRONG_PRODUCT`.

## 2. Collegamento della Play Developer API all'account delle funzioni

La funzione `verifyPurchase` e le notifiche leggono lo stato degli abbonamenti con la Google Play Developer API, usando **solo** l'account di servizio delle funzioni: nessuna chiave nel repository né nell'app (NFR1).

- [ ] Google Cloud Console, progetto `vinoozy-d6f45` → **API e servizi** → **Libreria** → attiva **Google Play Android Developer API**.
- [ ] Play Console → **Utenti e autorizzazioni** → **Invita nuovi utenti**:
  - email: `742143174654-compute@developer.gserviceaccount.com`;
  - **Autorizzazioni app** → Vinoozy, solo queste:
    - «Visualizzare le informazioni sull'app e scaricare report collettivi (sola lettura)»;
    - «Visualizzare dati finanziari, ordini e risposte al sondaggio sulla cancellazione»;
    - «Gestire ordini e abbonamenti».
  - Nessuna autorizzazione a livello di account.
- [ ] Google indica che il permesso può richiedere fino a 24–36 ore per valere. Prima di allora `verifyPurchase` risponde `PLAY_UNAVAILABLE` o `PURCHASE_NOT_FOUND` e l'app riprova più tardi.

## 3. Notifiche in tempo reale di Play (RTDN) sul topic `play-rtdn`

- [ ] Google Cloud Console → **Pub/Sub** → **Argomenti** → **Crea argomento**: ID **`play-rtdn`**, senza abbonamento predefinito (la funzione `onPlayRtdn` crea il proprio).
- [ ] Nell'argomento `play-rtdn` → **Autorizzazioni** → **Aggiungi entità**: `google-play-developer-notifications@system.gserviceaccount.com` con il ruolo **Publisher Pub/Sub** (`roles/pubsub.publisher`). Solo su questo argomento.
- [ ] Play Console → **Monetizza con Play** → **Configurazione della monetizzazione** → **Notifiche in tempo reale per lo sviluppatore**:
  - attiva le notifiche;
  - nome dell'argomento: `projects/vinoozy-d6f45/topics/play-rtdn`;
  - contenuto: abbonamenti **e** acquisti annullati (i rimborsi diventano `revoked`);
  - **Invia notifica di prova**.
- [ ] Nei log della funzione `onPlayRtdn` la notifica di prova risulta ignorata come test (`ignored-test`), senza errori.

Cosa fa il server con le notifiche: scarta i duplicati, rilegge sempre lo stato da Play (non si fida del messaggio), ignora gli eventi fuori ordine. Una notifica per un acquisto che l'app non ha ancora inviato a `verifyPurchase` viene ignorata (`ignored-unknown-token`): Plus nasce quando l'app verifica l'acquisto, anche con «Ripristina acquisti». Il job giornaliero `reconcileEntitlements` (03:00 UTC) rilegge gli acquisti che possono ancora cambiare e ritenta le conferme mancate.

## 4. App Check per le funzioni

Le quattro funzioni chiamate dall'app (`verifyPurchase`, `reportUsage`, `reserveAdSlot`, `recordAdOutcome`) richiedono **sempre** App Check (`enforceAppCheck: true` nel codice): non c'è un interruttore in console.

- [ ] Firebase Console → **App Check**: l'app Android è registrata con **Play Integrity** (fatto il 2026-11-09, `docs/firebase-setup.md` §2). Niente da cambiare per le build di Google Play.
- [ ] Per una build di debug su un **telefono reale** collegato al progetto vero: avvia l'app, copia dal log il token di debug di App Check e aggiungilo in App Check → app Android → **Gestisci token di debug**. Il token resta sul tuo computer: mai nel repository né nei segreti.
- [ ] Le build demo (emulatori, progetto `demo-vinoozy`) non hanno bisogno di nulla: l'emulatore delle funzioni accetta il token del provider di debug. Verificato dall'end-to-end `integration_test/freemium_test.dart` il 2026-11-10 («Callable request verification passed», app `VALID`).
- [ ] Dopo l'accensione di Plus guarda per qualche giorno App Check → **Metriche** → Cloud Functions: un telefono che non supera Play Integrity non può verificare acquisti né inviare la misurazione. L'app non si blocca, ma Plus resta in attesa fino a «Ripristina acquisti» da un telefono valido.

## 5. Interruttori di `config/policy` (`set_policy.mjs`)

`config/policy` contiene gli interruttori del prodotto. Se il documento manca, l'app e le regole usano i valori sicuri: tutto spento, limite di 15, budget `0.005` €.

| Campo | Opzione dello script | Effetto |
|---|---|---|
| `purchasesEnabled` | `--purchases-enabled true\|false` | Pulsante d'acquisto nella schermata Plus (`docs/blaze-switch.md` §6). |
| `capacityLimitEnabled` | `--capacity-limit-enabled true\|false` | Limite di schede attive del piano gratuito (§8). |
| `adsEnabled` | `--ads-enabled true\|false` | Annunci nel solo Cruscotto (§9). Spenti al lancio. |
| `freeActiveWineLimit` | `--free-active-wine-limit 15` | Schede attive del piano gratuito. |
| `usageBudgetEuro` | `--usage-budget-euro 0.005` | Soglia del costo stimato oltre la quale un utente gratuito può vedere annunci. |
| `policyVersion` | `--policy-version freemium-v1` | Versione delle regole d'uso inviata con la misurazione. |

Esempi (credenziali come al §6; lo script cambia solo i campi passati e stampa il documento risultante):

```bash
node tool/admin/set_policy.mjs --project vinoozy-d6f45 --credentials ~/Documents/chiavi-vinoozy/vinoozy-admin.json --purchases-enabled true
node tool/admin/set_policy.mjs --project vinoozy-d6f45 --credentials ~/Documents/chiavi-vinoozy/vinoozy-admin.json --ads-enabled false
```

Per provare prima sugli emulatori (`npm run emulators` in un altro terminale), sostituisci `--project … --credentials …` con `--emulator`.

## 6. Credenziali degli script amministrativi

Gli script di `tool/admin/` (`grant_plus.mjs`, `set_policy.mjs`, `migrate_capacity.mjs`) girano solo sul tuo Mac.

- [ ] Google Cloud Console → **IAM e amministrazione** → **Account di servizio** → **Crea account di servizio**: nome `vinoozy-admin`, con **solo** questi ruoli sul progetto:
  - **Visualizzatore Firebase Authentication** (`roles/firebaseauth.viewer`), per trovare l'account dall'email;
  - **Utente Cloud Datastore** (`roles/datastore.user`), per scrivere `entitlements`, `config/policy` e le cantine.
- [ ] **Chiavi** → **Aggiungi chiave** → JSON. Salva il file **fuori dal repository**, per esempio in `~/Documents/chiavi-vinoozy/vinoozy-admin.json`. Gli script rifiutano un file dentro il repository, controllano che `project_id` della chiave sia uguale a `--project` e stampano il progetto prima di scrivere. Il `.gitignore` copre comunque `*service-account*.json` e `tool/admin/*.key.json`.
- [ ] In alternativa a `--credentials` puoi impostare `GOOGLE_APPLICATION_CREDENTIALS` con lo stesso percorso.
- [ ] Quando non ti serve più, elimina la chiave dalla console: se ne crea un'altra in un minuto.
- [ ] Se la console impedisce di creare chiavi (criterio dell'organizzazione `iam.disableServiceAccountKeyCreation`), il progetto appartiene a un'organizzazione: chiedi di disattivare il criterio per questo progetto, oppure non usare gli script sul progetto reale.

## 7. Regalare e revocare Plus (`grant_plus.mjs`)

Plus in regalo è un diritto `manual_grant` in `entitlements/{uid}`: nessun token, nessun pagamento, nessun rinnovo. La persona deve avere fatto **almeno un accesso** a Vinoozy con quell'email. L'app lo mostra da sola come «Plus in regalo», senza azioni dell'utente (FR4.3).

Regalo fino a una data (Plus vale per tutto il giorno UTC indicato):

```bash
node tool/admin/grant_plus.mjs grant --email amica@example.com --until 2027-06-30 --reason gift \
  --project vinoozy-d6f45 --credentials ~/Documents/chiavi-vinoozy/vinoozy-admin.json
```

Regalo senza scadenza, per esempio per il tuo account di prova:

```bash
node tool/admin/grant_plus.mjs grant --email bottazzinibruno@gmail.com --no-expiry --reason owner_test \
  --project vinoozy-d6f45 --credentials ~/Documents/chiavi-vinoozy/vinoozy-admin.json
```

Lo script stampa il progetto, poi `Granted Plus (gift) to …`, l'uid e la scadenza (`never` senza scadenza). Si ferma senza scrivere nulla se:

- l'email non corrisponde a nessun account («No registered account with email …»);
- mancano o ci sono insieme `--until` e `--no-expiry`, o la data è già passata;
- l'account ha un abbonamento Play valido: il regalo lo nasconderebbe. Aggiungi `--force` solo se è proprio quello che vuoi.

Revoca di un regalo (i dati della cantina restano tutti; oltre il limite gratuito le schede restano modificabili e bevibili, ma non se ne aggiungono di nuove):

```bash
node tool/admin/grant_plus.mjs revoke --email amica@example.com \
  --project vinoozy-d6f45 --credentials ~/Documents/chiavi-vinoozy/vinoozy-admin.json
```

La revoca rifiuta un abbonamento comprato su Play: quello si gestisce solo da Google Play (rimborso o annullamento in Play Console → **Ordini**).

Sugli emulatori, per provare, usa `--emulator` al posto di `--project … --credentials …`.

## 8. Accensione del limite: prima `migrate_capacity.mjs`, poi `capacityLimitEnabled`

Il limite di 15 schede attive (FR2.4) si accende **solo dopo** la migrazione, che conta le schede attive di ogni cantina e scrive `activeWineCount` e, una volta sola, `legacyActiveWineLimit = max(15, schede attive)`. Chi oggi ha più di 15 schede attive le conserva tutte e non può superare quel numero (FR2.3).

Versione minima dell'app (da decidere prima della migrazione):

- dopo la migrazione le regole **pretendono il contatore** in ogni scrittura che cambia lo stato attivo di una scheda (nuovo vino, ultima bottiglia bevuta, bottiglie aggiunte a un vino finito), **anche con il limite spento**;
- la versione già pubblicata prima di Freemium non scrive il contatore: dopo la migrazione queste sue scritture vengono **rifiutate** dal server (le altre, come modifiche e bevute che non finiscono il vino, continuano a passare);
- Vinoozy non ha un aggiornamento obbligatorio. Prima di migrare controlla in Play Console → **Statistiche** → **Versioni dell'app** che quasi tutte le installazioni attive, comprese quelle delle persone invitate nelle cantine condivise, abbiano la versione con Freemium. Se qualcuno resta indietro, chiedigli di aggiornare.

Procedura, nello stesso momento:

- [ ] Prova senza scrivere:

  ```bash
  node tool/admin/migrate_capacity.mjs --dry-run --project vinoozy-d6f45 --credentials ~/Documents/chiavi-vinoozy/vinoozy-admin.json
  ```

- [ ] Migrazione vera, **subito prima** di accendere il limite:

  ```bash
  node tool/admin/migrate_capacity.mjs --project vinoozy-d6f45 --credentials ~/Documents/chiavi-vinoozy/vinoozy-admin.json
  ```

- [ ] Accensione del limite:

  ```bash
  node tool/admin/set_policy.mjs --project vinoozy-d6f45 --credentials ~/Documents/chiavi-vinoozy/vinoozy-admin.json --capacity-limit-enabled true
  ```

- [ ] Sul telefono: con 15 schede attive, «Aggiungi» mostra la spiegazione con «Scopri Plus» e non scrive nulla; la presentazione del piano gratuito compare una volta nel Cruscotto.

Rieseguire la migrazione è sicuro: ricalcola `activeWineCount` e lascia `legacyActiveWineLimit` com'era. Per tornare indietro: `--capacity-limit-enabled false` (il contatore resta obbligatorio nelle cantine migrate).

## 9. Annunci (spenti al lancio)

- [ ] L'App ID reale di AdMob va nel segreto GitHub **`ADMOB_APP_ID`** (ambiente `play-internal`, usato da `release.yml`). Senza il segreto la build usa l'App ID di test di Google; l'SDK degli annunci non parte mai finché `adsEnabled` è `false` (FR7.1).
- [ ] Play Console → **Contenuti dell'app** → **ID pubblicità**: il manifest dichiara ora `com.google.android.gms.permission.AD_ID` (dall'SDK degli annunci), quindi la dichiarazione va compilata in modo coerente prima di pubblicare questa versione.
- [ ] Prima di `--ads-enabled true`: aggiorna in Play Console la voce **Annunci** («L'app contiene annunci»), la scheda **Sicurezza dei dati** (`docs/release-checklist.md` §2) e configura in AdMob il messaggio di consenso (UMP) per lo Spazio economico europeo.

## 10. Dati e cancellazione dell'account

- Con l'eliminazione dell'account la funzione `onUserDeleted` cancella `entitlements/{uid}`, `usage/{uid}/**` e `adSlots/{uid}/**`. Degli acquisti Play resta solo `purchases/{hash del token}` con il token e lo stato, senza più l'uid, per rimborsi e contestazioni; lo stesso abbonamento si può ripristinare su un nuovo account.
- Un abbonamento attivo non si annulla eliminando l'account: la persona lo annulla in Google Play (la pagina di cancellazione e l'informativa lo dicono).
- **Prima della pubblicazione delle funzioni** `onUserDeleted` non esiste: un regalo fatto con `grant_plus.mjs` a un account poi eliminato resta in `entitlements/{uid}`. Finché le funzioni non sono pubblicate, per un account eliminato cancella a mano quel documento dalla console Firestore.
- I dettagli della misurazione (mesi d'uso, giorni degli slot pubblicitari, id delle notifiche Play) si cancellano dopo 90 giorni con `purgeOldUsage` (04:00 UTC).
