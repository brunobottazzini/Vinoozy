# Security Design — u8-account

Fonti: `security-requirements.md` (NFR4.1–NFR4.7, NFR8.1–NFR8.6, NFR3.1–NFR3.2, NFR6.1–NFR6.4), `tech-stack-decisions.md`, `functional-spec.md`, `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`. Come nei requisiti, il file raccoglie anche accessibilità e affidabilità.

## 1. Regole del cloud (NFR4.1–NFR4.5)

```text
match /users/{userId} {
  allow get: if signedIn() && userId == uid();
  allow create: if signedIn() && userId == uid() && validUserCreate()
    && (!('deletionStartedAt' in incoming()) || incoming().deletionStartedAt == request.time);
  allow update: if signedIn() && userId == uid()
    && (validUserUpdate()
        || (!('deletionStartedAt' in existing())
            && onlyChanged(['deletionStartedAt'])
            && incoming().deletionStartedAt == request.time));
  allow delete: if signedIn() && userId == uid();
}
// cellars/{cellarId}
allow delete: if signedIn() && isOwner(cellarId)
  && (existing().get('memberSlots', 0) == 0
      || get(/databases/$(database)/documents/users/$(uid())).data.get('deletionStartedAt', null) != null);
```

- `validUserCreate` ammette il campo facoltativo `deletionStartedAt`. `validUserUpdate` resta invariata e non lo ammette, quindi una volta scritto il campo non si cambia né si toglie.
- **Accessi alle regole:** la cancellazione della cantina fa al più un `get` in più (il profilo); la tabella in testa al file si aggiorna.
- **Test (`test/rules/u8.rules.test.mjs`):**
  - ogni caso permesso e vietato di NFR4.1–NFR4.3;
  - la sequenza completa di NFR4.4 su dati di prova (cantina propria con 2 inviti, invito in attesa e invito chiuso in cantine altrui).
- **Collegamenti:**
  - `package.json` `test:rules` aggiunge `u8.rules.test.mjs`;
  - `app-writes.json` riceve la versione `u8-account` con `requiresRules: "account"`;
  - `RULES_FEATURES` in `promote.yml` diventa `sharing cellar account`.

## 2. Riautenticazione (NFR4.6)

- `AuthService.reauthenticate()` apre l'accesso Google e verifica che l'uid ottenuto sia uguale a quello corrente. Se è diverso, esce dall'account appena usato e restituisce `differentAccount`.
- Il runner chiede la riautenticazione prima del passo 1 e prima di ogni ripresa, anche su un altro telefono e sulla pagina web.
- `deleteUser` che risponde `requires-recent-login` porta a una nuova riautenticazione e alla ripetizione del passo 6.

## 3. Pagina web (NFR4.7, NFR8.5)

- **Struttura:** `docs/account-deletion/index.html` (italiano, predefinita), `en/index.html`, `pt-BR/index.html`, un solo `account-deletion.js` condiviso.
- **Libreria:** Firebase JS SDK (moduli `app`, `auth`, `firestore`, `app-check`) caricato da `https://www.gstatic.com/firebasejs/<versione fissata>/…` con attributo `integrity` (SRI) e `crossorigin`. Uno script (`tool/check_web_pins.sh`, nel job `analyze`) verifica che ogni `<script>` esterno abbia versione fissata e `integrity`.
- **Configurazione:** la configurazione web di Firebase (chiave API web, id del progetto) è pubblica per natura e non è un segreto. Sta in `docs/account-deletion/firebase-config.js`, che contiene solo questi valori. Non è un file di configurazione dell'app Android e non contiene credenziali di servizio.
- **App Check:** provider reCAPTCHA v3 per il web, con la chiave del sito pubblica.
- **Azioni del proprietario nella console** (checklist): aggiungere `<utente>.github.io` ai domini autorizzati di Auth; registrare l'app web e il sito reCAPTCHA in App Check.
- **Contenuto:** nessun modulo, nessun cookie di terze parti oltre a quelli dell'accesso Google e di reCAPTCHA. La pagina mostra `bottazzinibruno@gmail.com` solo nella sezione "Non riesci ad accedere?".

## 4. Privacy (NFR8.1–NFR8.4, NFR8.6)

- **Motivi fissi:** `account_delete_failed`, `account_signout_failed`, `account_reauth_failed`, inviati come `AccountOperationError(reason, step, causeType)`. `ErrorReporter` riceve questo oggetto, il cui `toString()` non contiene il messaggio originale.
- **Telefono pulito:** il passo 7 chiama `ResetCoordinator.reset(deletedUid, openCellar: false)`, svuota la cartella di `TempLabelStore` e solo dopo toglie `DeletionSignal`.
- **Test end-to-end:** dopo la cancellazione:
  - nessun documento contiene l'email;
  - l'uid compare solo in `recordedBy` e `updatedBy` di cantine altrui;
  - non esistono `users/{uid}`, la cantina, né documenti `members` dell'utente.
- **Checklist:**
  - §2: scheda "Sicurezza dei dati" e informativa con i residui dichiarati;
  - procedura per le richieste via email con la conferma tramite risposta (NFR8.6).

## 5. Accessibilità (NFR3)

- `OnboardingScreen`: `Semantics(label: 'Pagina N di 3')` sull'indicatore.
- `DeletionProgressView`: `Semantics(liveRegion: true)` per il passo in corso.
- Testo al 200% in `SingleChildScrollView`; pulsanti di almeno 48 dp; tre lingue.
- Pagina web: `lang` corretto per pagina, etichette sui pulsanti, contrasto ≥ 4,5:1.

## 6. Affidabilità (NFR6)

- **Passi ripetibili:** ogni passo verifica prima lo stato. Per esempio:
  - un invito già chiuso non si chiude di nuovo;
  - un documento assente non si cancella;
  - `deletionStartedAt` presente non si riscrive.
- **Esecutori in parallelo** (app e pagina web insieme): i passi idempotenti e le regole rendono innocuo il doppio tentativo; il secondo esecutore trova lo stato già avanzato.
- **Ripresa:** solo con il segnale locale o con `deletionStartedAt`; il test del gate verifica che un profilo assente senza segnale apra l'app normalmente.
- **Uscita con modifiche in coda:** `signOut` non azzera il registro; l'azzeramento avviene solo se entra un altro account (U1).

## 7. Correzioni dopo la revisione (2026-11-06)

Dove differiscono, questi punti sostituiscono §1 e §3.

- **Regole, versione completa:**
  - `users`: `allow list: if false;` resta. `allow delete: if signedIn() && userId == uid() && existing().get('deletionStartedAt', null) != null;`, quindi il profilo si cancella solo durante una cancellazione dell'account.
  - `validUserCreate`: la lista dei campi ammessi (`hasOnly`) aggiunge `deletionStartedAt`; la lista dei campi obbligatori (`hasAll`) resta quella di U1, separata; se il campo c'è, deve valere `request.time`.
  - `cellars` delete: **solo** il proprietario **e solo** con `deletionStartedAt` presente nel suo profilo. Niente più alternativa con `memberSlots == 0`: fuori dalla cancellazione dell'account il proprietario non può cancellare la cantina, così non restano vini e bevute orfani che riapparirebbero con una cantina ricreata. Lo stesso vincolo copre anche il contatore sfasato.
- **App Check:** nessuna regola usa `request.app_check`. La protezione viene dall'**applicazione obbligatoria di App Check su Firestore nella console**, attivata dal proprietario, che vale per l'app Android e per la pagina web registrata con reCAPTCHA v3. La checklist lo elenca. La frase di §3 sulle "regole che richiedono App Check" è superata.
- **Libreria Firebase della pagina, copiata nel repository (vendoring):**
  - i moduli ES di Firebase (`app`, `auth`, `firestore`, `app-check`) si copiano in `docs/account-deletion/vendor/firebase/<versione>/` dal pacchetto npm `firebase` alla **stessa versione** fissata in `package.json` e usata dai test;
  - lo fa lo script `tool/vendor_firebase_web.sh`;
  - la pagina importa solo file locali, senza URL esterni, quindi nessun file importato sfugge al controllo;
  - `tool/check_web_pins.sh` verifica che la cartella `vendor/` corrisponda byte per byte ai file del pacchetto npm installato alla versione di `package.json`, e che la pagina non carichi script esterni.
- **Interfaccia di `account-deletion.js`:**
  - è un modulo ES che esporta `createAccountDeletion(sdk, db, auth)`, dove `sdk` è un oggetto con le funzioni Firebase usate (`getDocs`, `writeBatch`, `deleteUser`, `reauthenticateWithPopup` e simili);
  - la pagina passa le funzioni importate da `vendor/`;
  - i test passano le stesse funzioni dal pacchetto npm `firebase` in Node, senza URL https.
- **Test della pagina, script a sé:**
  - nuovo `npm run test:web`: `firebase emulators:exec --only firestore,auth --project demo-vinoozy "node --test test/web/"`;
  - prima dei test carica esplicitamente `firestore.rules` nell'emulatore (`initializeTestEnvironment` con il contenuto del file), per non dipendere da regole caricate da altri test;
  - accesso Google simulato con l'emulatore di Auth: `signInWithCredential` con `GoogleAuthProvider.credential` e un id token finto (JSON con `sub` ed `email`), che l'emulatore accetta e che produce `sign_in_provider == 'google.com'`;
  - casi: sequenza completa, ripresa, riautenticazione con un altro account rifiutata, `deleteUser`;
  - il job `rules` di `ci.yml` aggiunge il passo `npm run test:web`.
- **Ordine di pubblicazione della pagina:**
  - la pagina non si pubblica da `main`, ma dal ramo `gh-pages`, aggiornato solo dal nuovo workflow manuale `pages.yml`;
  - `pages.yml` controlla, come `promote.yml`, che l'ultima esecuzione riuscita di `firebase-deploy.yml` abbia pubblicato regole uguali a quelle del commit;
  - se non è così si ferma con "Pubblica prima le regole con firebase-deploy.yml".
  
  Ordine: merge, regole, poi pagina e app.

