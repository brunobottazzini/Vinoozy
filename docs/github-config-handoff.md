# Handoff: configurazione GitHub per il rilascio automatico su Google Play

Destinatario: l'agente incaricato della configurazione. Data: 12 novembre 2026.
Repository `brunobottazzini/Vinoozy` (pubblico), ramo `main`, proprietario
GitHub `brunobottazzini` (id `4460234`). Guida per il proprietario, con lo
stesso contenuto spiegato passo per passo: `docs/github-actions-setup.md`.

## Correzione della chiave di firma (12 novembre 2026, ore 14:14 Europe/Rome)

La [release 43207310918](https://github.com/brunobottazzini/Vinoozy/actions/runs/43207310918),
commit `6f76475a278e6351ce63454b719aeca5a37b0cfd`, ha superato autenticazione,
verifica degli input e build, ma Play ha rifiutato il bundle: il precedente
keystore `~/Documents/keystore_apk` firmava con SHA-1
`7E:B0:37:E7:A0:09:FD:4A:60:6D:58:84:75:11:7C:C7:75:BD:EB:A9`, diversa
dalla chiave di caricamento registrata. Il test di accesso a `key0` non
dimostrava la corrispondenza con la chiave Play.

**Individuato e verificato il keystore corretto:**
`~/Library/Application Support/Vinoozy/Signing/vinoozy-upload.p12`, già
documentato in `docs/pubblicazione-stato-operativo.md`, sezione «Chiave di
caricamento e primo AAB candidato». La password dedicata è custodita nella
voce «Vinoozy Android Upload» del Portachiavi macOS e non è stata mostrata.

- SHA-1 del certificato letto dal keystore sbloccato:
  `81:7C:4B:3A:0C:56:E9:79:18:E2:86:26:FB:6A:1E:71:D4:C6:A3:7E`.
  Coincide con quella richiesta da Play, con il certificato pubblico
  scaricato da Play e con i firmatari degli AAB locali `0.2.0 (2)` e `0.2.1 (3)`.
- Prova di firma con la chiave privata riuscita. Controllo locale
  `tool/check_release_inputs.sh --profile internal` superato con i file,
  l'alias e le password reali corretti, senza segnaposto.
- Aggiornati via stdin tutti e quattro i segreti di firma di `play-internal`:
  `ANDROID_UPLOAD_KEYSTORE_B64`, `ANDROID_UPLOAD_KEYSTORE_PASSWORD`,
  `ANDROID_UPLOAD_KEY_ALIAS`, `ANDROID_UPLOAD_KEY_PASSWORD`.
  Nomi e orari di aggiornamento verificati su GitHub: 13:14:29–13:14:32 UTC.
- Non serve una reimpostazione della chiave di caricamento in Play Console.
  Nessun codice modificato, commit, push o workflow avviato per questa
  correzione. La release è ancora al tentativo 1 fallito: il proprietario
  può rilanciare la stessa esecuzione e verificare upload interno e tag.

## Esito dell'esecuzione (12 novembre 2026)

- `play-internal`: verificata la presenza di tutti i 7 segreti elencati al
  §4 e della variabile `GOOGLE_SERVER_CLIENT_ID`; accesso limitato a `main`.
- `play-production`: presente `PLAY_PRODUCTION_SA_JSON`; accesso limitato a
  `main`, revisore `brunobottazzini`, `prevent_self_review: false`.
- Creati `play-internal-publisher` e `play-production-publisher` senza ruoli
  Cloud, con accesso alla sola app Vinoozy e i rispettivi permessi di rilascio
  nei test e in produzione. Abilitata Google Play Android Developer API.
- Nella prima configurazione le verifiche dei file sono passate con
  segnaposto per password e alias. Il proprietario ha inserito le tre voci,
  ma la successiva release ha dimostrato che il keystore era sbagliato.
  La correzione e le verifiche reali sono descritte nella sezione sopra.
- Ricontrollata la chiave browser della pagina di cancellazione account:
  impronta coincidente con il file della pagina, restrizione ai due referrer
  e alle quattro API del §3. Nelle metriche dell'8–12 novembre, filtrate su
  questa chiave: Identity Toolkit 12 richieste, di cui 5 risposte `403`;
  App Check 1 richiesta senza errori; nessun dato per Firestore e Token Service.
  L'origine dei cinque `403` non è stata chiarita.
- Il proprietario ha chiuso personalmente l'alert #1 come falso positivo,
  senza rotazione. Verificato via API GitHub: `state: resolved`,
  `resolution: false_positive`, segnalazioni aperte: **0**. La chiusura è una
  decisione del proprietario, distinta dalla verifica delle metriche sopra.
- Nessun commit, push o avvio di workflow eseguito da questo agente.
  Il codice è stato successivamente pubblicato dal proprietario o dalla
  sessione che segue la release; la configurazione della firma è ora corretta.

## Obiettivo

1. Ambiente `play-internal`: 7 segreti e 1 variabile.
2. Ambiente `play-production`: creazione, protezioni e 1 segreto.
3. Segnalazione di secret scanning #1: verifica e chiusura senza rotazione.

Il controllo introdotto nel commit `38d19b6` è già pubblicato:
`release.yml` e `promote.yml` verificano gli input con
`tool/check_release_inputs.sh` prima di qualsiasi build.

## Regole non negoziabili

- **Mai stampare un valore** di credenziale: niente `cat`, `echo` o `jq` verso
  il terminale sui file delle credenziali, niente valori negli argomenti
  (`--body`). I valori passano solo per pipe (stdin) a `gh secret set`.
- **Mai scrivere credenziali nel repository**, nei log, in questo documento o
  in file temporanei. `config/firebase_prod.json` e
  `android/app/google-services.json` sono ignorati da git e devono restarlo.
- **Non fare commit né push** e non avviare workflow: al termine riferisci al
  proprietario, che segue il rilancio della release indicata sopra.
- Le password e l'alias del keystore li inserisce **il proprietario** nel
  proprio terminale (prompt nascosto); tu gli dai il comando.
- Chiedi al proprietario i percorsi che non conosci: chiave JSON
  `play-internal-publisher`, chiave JSON `play-production-publisher`,
  keystore della chiave di caricamento. Non cercarli sul disco.

## Stato iniziale dell'handoff (12/11/2026, solo nomi)

- `play-internal`: esiste, limitato a `main`; **nessun segreto, nessuna variabile**.
- Ambienti presenti: `firebase-prod`, `github-pages`, `github-pages-publish`,
  `play-internal`. **`play-production` non esiste.**
- Nessun ruleset sul repository.
- Secret scanning: una segnalazione aperta, **#1 Google API Key**.

## 1. Ambiente `play-internal`

### 1.1 Verifica locale prima di caricare (consigliata)

Lo stesso controllo della CI, sui file locali, senza stampare valori. Esegui
dalla radice del repository, con i percorsi forniti dal proprietario:

```sh
PLAY_INTERNAL_SA_JSON="$(cat '<percorso>/play-internal-publisher.json')" \
ANDROID_UPLOAD_KEYSTORE_B64="$(base64 -i '<percorso>/upload-keystore.jks')" \
ANDROID_UPLOAD_KEYSTORE_PASSWORD=placeholder \
ANDROID_UPLOAD_KEY_ALIAS=placeholder \
ANDROID_UPLOAD_KEY_PASSWORD=placeholder \
FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64="$(base64 -i android/app/google-services.json)" \
FIREBASE_PROD_DEFINES_JSON_B64="$(base64 -i config/firebase_prod.json)" \
GOOGLE_SERVER_CLIENT_ID="$(jq -r .GOOGLE_SERVER_CLIENT_ID config/firebase_prod.json)" \
tool/check_release_inputs.sh --profile internal
```

Atteso: `The play-internal configuration is complete.` Le password qui sono
segnaposto: il controllo verifica solo che non siano vuote. Se fallisce, il
messaggio nomina il file da correggere; non proseguire finché non passa.

### 1.2 Segreti da file (li carichi tu, via stdin)

```sh
R=brunobottazzini/Vinoozy
gh secret set PLAY_INTERNAL_SA_JSON --repo "$R" --env play-internal < '<percorso>/play-internal-publisher.json'
base64 -i '<percorso>/upload-keystore.jks' | gh secret set ANDROID_UPLOAD_KEYSTORE_B64 --repo "$R" --env play-internal
base64 -i android/app/google-services.json | gh secret set FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64 --repo "$R" --env play-internal
base64 -i config/firebase_prod.json | gh secret set FIREBASE_PROD_DEFINES_JSON_B64 --repo "$R" --env play-internal
```

`PLAY_INTERNAL_SA_JSON` va **in chiaro** (non Base64). Il keystore deve
essere quello della chiave di caricamento registrata in Play Console
(Integrità dell'app → Firma dell'app); se il proprietario non ne è sicuro,
fermati e chiedi.

### 1.3 Segreti digitati dal proprietario

Dagli questi comandi da lanciare nel suo terminale (ognuno chiede il valore
con un prompt nascosto):

```sh
gh secret set ANDROID_UPLOAD_KEYSTORE_PASSWORD --repo brunobottazzini/Vinoozy --env play-internal
gh secret set ANDROID_UPLOAD_KEY_ALIAS --repo brunobottazzini/Vinoozy --env play-internal
gh secret set ANDROID_UPLOAD_KEY_PASSWORD --repo brunobottazzini/Vinoozy --env play-internal
```

### 1.4 Variabile

`GOOGLE_SERVER_CLIENT_ID` è l'OAuth **web** client ID del progetto
`vinoozy-d6f45` (pubblico, non segreto). Il file di produzione locale lo
contiene già; chiedi al proprietario di confermare che sia il client web
(Firebase → Authentication → Google → Web SDK configuration), poi:

```sh
jq -r .GOOGLE_SERVER_CLIENT_ID config/firebase_prod.json | gh variable set GOOGLE_SERVER_CLIENT_ID --repo brunobottazzini/Vinoozy --env play-internal
```

Facoltativo, **non** richiesto: `ADMOB_APP_ID` (gli annunci sono spenti).

## 2. Ambiente `play-production`

### 2.1 Creazione con approvazione e solo `main`

```sh
gh api -X PUT repos/brunobottazzini/Vinoozy/environments/play-production --input - <<'JSON'
{
  "reviewers": [{ "type": "User", "id": 4460234 }],
  "prevent_self_review": false,
  "deployment_branch_policy": { "protected_branches": false, "custom_branch_policies": true }
}
JSON
gh api -X POST repos/brunobottazzini/Vinoozy/environments/play-production/deployment-branch-policies -f name=main -f type=branch
```

`prevent_self_review` deve restare `false`: il proprietario è l'unico
revisore, altrimenti nessuno potrebbe approvare.

### 2.2 Segreto

```sh
gh secret set PLAY_PRODUCTION_SA_JSON --repo brunobottazzini/Vinoozy --env play-production < '<percorso>/play-production-publisher.json'
```

Chiave dell'account `play-production-publisher` (permesso "Rilascia in
produzione" sulla sola app Vinoozy), in chiaro. Verifica locale facoltativa:

```sh
PLAY_PRODUCTION_SA_JSON="$(cat '<percorso>/play-production-publisher.json')" tool/check_release_inputs.sh --profile production
```

Se il proprietario non ha ancora questo account di servizio, crea comunque
l'ambiente (§2.1) e segnala che il segreto manca: blocca solo `promote.yml`,
non la release sul canale interno.

## 3. Segnalazione secret scanning #1 (decisione: non ruotare)

Chiave web Firebase della pagina di cancellazione account
(`docs/account-deletion/firebase-config.js`): pubblica per natura (la pagina
pubblicata deve contenerla), già limitata il 10/11/2026 (vedi
`docs/firebase-setup.md` §10 e `.gitleaksignore`). Il proprietario ha deciso
di **non** ruotarla.

1. **Verifica (proprietario, Google Cloud Console → API e servizi →
   Credenziali)**: la chiave del browser della pagina ha ancora
   - restrizione per referrer HTTP: `https://brunobottazzini.github.io/*` e
     `https://vinoozy-d6f45.firebaseapp.com/*`;
   - restrizione API: Identity Toolkit, Token Service, Cloud Firestore,
     Firebase App Check.
   E in API e servizi → Metriche non ci sono picchi di richieste o di errori
   anomali dal 9/11/2026. Se una delle due verifiche non torna, **fermati**:
   in quel caso va ruotata, decide il proprietario.
2. **Chiusura** (solo dopo la conferma del proprietario sul punto 1):

```sh
gh api -X PATCH repos/brunobottazzini/Vinoozy/secret-scanning/alerts/1 \
  -f state=resolved -f resolution=false_positive \
  -f resolution_comment='Public Firebase web key of the account deletion page, restricted to the referrers brunobottazzini.github.io and vinoozy-d6f45.firebaseapp.com and to 4 APIs; access enforced by Firestore rules and App Check. See docs/firebase-setup.md §10.'
```

## 4. Verifica finale (solo nomi)

```sh
gh secret list --repo brunobottazzini/Vinoozy --env play-internal
gh variable list --repo brunobottazzini/Vinoozy --env play-internal
gh secret list --repo brunobottazzini/Vinoozy --env play-production
gh api repos/brunobottazzini/Vinoozy/environments/play-production --jq '{reviewers: [.protection_rules[]?.reviewers[]?.reviewer.login], branches: .deployment_branch_policy}'
gh api 'repos/brunobottazzini/Vinoozy/secret-scanning/alerts?state=open' --jq 'length'
```

Atteso:

- `play-internal`: `PLAY_INTERNAL_SA_JSON`, `ANDROID_UPLOAD_KEYSTORE_B64`,
  `ANDROID_UPLOAD_KEYSTORE_PASSWORD`, `ANDROID_UPLOAD_KEY_ALIAS`,
  `ANDROID_UPLOAD_KEY_PASSWORD`, `FIREBASE_PROD_GOOGLE_SERVICES_JSON_B64`,
  `FIREBASE_PROD_DEFINES_JSON_B64`; variabile `GOOGLE_SERVER_CLIENT_ID`.
- `play-production`: `PLAY_PRODUCTION_SA_JSON`; revisore `brunobottazzini`;
  policy dei rami personalizzata con `main`.
- Segnalazioni aperte: `0`.

## Rapporto da restituire al proprietario

- Elenco dei nomi configurati per ambiente (output di §4, senza valori).
- Esito della verifica locale di §1.1 (e di §2.2 se eseguita).
- Cosa manca e perché (per esempio la chiave di produzione non ancora creata).
- Conferma che non sono stati fatti commit, push o avvii di workflow.

Dopo la correzione dei segreti non serve una modifica al codice: il
proprietario può rilanciare la release `43207310918`, che usa lo stesso
commit già costruito, e verificare l'upload sul canale interno e il tag
`build-<versionCode>`. Il controllo degli input è già passato nella prima
esecuzione; il problema corretto era la corrispondenza della chiave di firma.
