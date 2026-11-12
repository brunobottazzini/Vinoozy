# Configurazione degli ambienti GitHub per il rilascio su Google Play

Questa guida serve a far funzionare da soli i due workflow di consegna:

- `release.yml`: dopo ogni CI verde su `main` costruisce l'AAB firmato e lo
  carica sul canale di **test interno** (ambiente `play-internal`);
- `promote.yml`: su avvio manuale promuove una build in **produzione**
  (ambiente `play-production`, con la tua approvazione).

Le credenziali stanno **solo** nei segreti degli ambienti GitHub: mai nel
repository, mai in un messaggio, mai in un log. I comandi qui sotto copiano
ogni valore negli appunti del Mac (`pbcopy`) senza mostrarlo a schermo; tu lo
incolli nella pagina di GitHub. Dopo ogni incolla, svuota gli appunti con
`pbcopy < /dev/null`.

Se un valore manca o è sbagliato, il primo step del job lo dice per nome,
insieme all'ambiente da sistemare, prima di scrivere file o avviare la build
(`tool/check_release_inputs.sh`).

## 1. Ambiente `play-internal`

Su GitHub: **Settings → Environments → play-internal**. L'ambiente esiste già
ed è limitato al ramo `main`.

### 1.1 Segreti (Environment secrets → Add environment secret)

| Nome | Contenuto | Formato | Come copiarlo sul Mac |
|---|---|---|---|
| `PLAY_INTERNAL_SA_JSON` | chiave JSON dell'account di servizio `play-internal-publisher` (Play Console, solo l'app Vinoozy, permesso "Rilascia nei canali di test") | JSON **in chiaro**, non Base64 | `pbcopy < <percorso>/play-internal-publisher.json` |
| `ANDROID_UPLOAD_KEYSTORE_B64` | keystore della **chiave di caricamento** già associata all'app in Play Console | Base64 | `base64 -i <percorso>/upload-keystore.jks \| pbcopy` |
| `ANDROID_UPLOAD_KEYSTORE_PASSWORD` | password del keystore | testo | scrivila a mano nel campo |
| `ANDROID_UPLOAD_KEY_ALIAS` | alias della chiave di caricamento | testo | scrivilo a mano nel campo |
| `ANDROID_UPLOAD_KEY_PASSWORD` | password della chiave | testo | scrivila a mano nel campo |
| `FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64` | `google-services.json` di produzione (lo stesso di `android/app/google-services.json` sul Mac, ignorato da git) | Base64 | `base64 -i android/app/google-services.json \| pbcopy` |
| `FIREBASE_PROD_DEFINES_JSON_B64` | dart-defines di produzione (lo stesso di `config/firebase_prod.json` sul Mac, ignorato da git) | Base64 | `base64 -i config/firebase_prod.json \| pbcopy` |

Facoltativo: `ADMOB_APP_ID` (senza, la build usa l'ID di test pubblico di
Google; gli annunci restano spenti finché `config/policy.adsEnabled` è falso).

Il keystore deve essere quello della chiave di caricamento che Play Console
conosce (Configurazione → Integrità dell'app → Firma dell'app). Se l'hai persa
o pensi che sia stata esposta, chiedi a Google Play di sostituirla prima di
continuare.

### 1.2 Variabile (Environment variables → Add environment variable)

| Nome | Contenuto |
|---|---|
| `GOOGLE_SERVER_CLIENT_ID` | OAuth **web** client ID del progetto di produzione (Firebase → Authentication → Google → Web SDK configuration). È pubblico, non è un segreto. Senza, l'accesso con Google della build di produzione non funziona: per questo la verifica lo rende obbligatorio. |

## 2. Ambiente `play-production`

Oggi non esiste. Crealo da **Settings → Environments → New environment**:

1. Nome: `play-production`.
2. **Required reviewers**: aggiungi te stesso. Lascia attivo "Prevent
   self-review" solo se vuoi che nessuno, nemmeno tu, approvi le proprie
   esecuzioni: con un solo proprietario va **disattivato**, altrimenti
   nessuno può approvare.
3. **Deployment branches and tags**: "Selected branches and tags", aggiungi
   solo `main`.
4. Segreto `PLAY_PRODUCTION_SA_JSON`: chiave JSON dell'account di servizio
   `play-production-publisher` (Play Console, solo l'app Vinoozy, permesso
   "Rilascia in produzione"), **in chiaro**:
   `pbcopy < <percorso>/play-production-publisher.json`.

`promote.yml` controlla anche che le regole Firestore distribuite siano
quelle della build: prima della prima promozione serve un `firebase-deploy`
riuscito con le regole di quel commit.

## 3. Controllo senza leggere i valori

Dal Mac, con GitHub CLI autenticato:

```sh
gh secret list --repo brunobottazzini/Vinoozy --env play-internal
gh variable list --repo brunobottazzini/Vinoozy --env play-internal
gh secret list --repo brunobottazzini/Vinoozy --env play-production
```

Mostrano solo nomi e date. Devono comparire i sette segreti e la variabile di
§1 e il segreto di §2.

## 4. Prima release dopo la configurazione

1. **Configurazione cambiata, codice no**: la release fallita più recente si
   può rilanciare da Actions → release → "Re-run jobs". Attenzione: un rerun
   rifà il checkout del commit della CI originaria, quindi usa il codice di
   allora.
2. **Codice cambiato** (per esempio dopo il merge di questa correzione): serve
   una nuova CI su `main`; quando è verde, `release.yml` parte da sola.
3. Controlla nel job `internal`:
   - lo step **Check the play-internal configuration** dice "The
     play-internal configuration is complete.";
   - lo step **Versions** stampa `versionName ..., versionCode N` con N
     maggiore dell'ultimo caricato a mano;
   - l'AAB compare tra gli artefatti, la build compare in Play Console nel
     canale di test interno e su GitHub esiste il tag `build-N`.
4. Installa la build dal canale interno e fai lo smoke test
   (`docs/release-checklist.md`) prima di qualsiasi promozione.

Il job `crashlytics-symbols` resta saltato finché non configuri la
federazione d'identità del §4 di `docs/firebase-setup.md`: non blocca la
release.

## 5. Promozione in produzione

Actions → promote → "Run workflow": `versionCode` della build già sul canale
interno, `fraction` `1.0` per la prima pubblicazione (`0.2` solo per gli
aggiornamenti successivi), `action` `promote`. Il job aspetta la tua
approvazione; prima di approvare ricontrolla lo smoke test. `halt` ferma un
rilascio graduale (rollback), `complete` lo porta al 100%.
