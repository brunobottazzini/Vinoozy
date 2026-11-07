# Security Requirements — u8-account

Fonti: `requirements.md` (NFR3, NFR4, NFR6, NFR8), `functional-spec.md` e `rules.md` di U8 (BR1.5–BR1.13 e chiarimenti), `contract-summary.md` (C3, C4), riepilogo confermato in `nfr-requirements-questions.md`. Come nelle altre unità, il file raccoglie anche accessibilità e affidabilità.

## Regole del cloud (NFR4)

| ID | Requisito | Verifica |
|---|---|---|
| NFR4.1 | **`users/{uid}`, cancellazione:** solo con `uid == userId`. | Test delle regole: utente stesso sì; altro utente, non autenticato no. |
| NFR4.2 | **`deletionStartedAt`:** scritto solo dall'utente, solo se assente, con valore `request.time`, poi immutabile; ammesso anche alla creazione del profilo con lo stesso vincolo. | Test: prima scrittura sì; seconda, valore diverso da `request.time`, rimozione, altro utente no. |
| NFR4.3 | **`cellars/{id}`, cancellazione:** solo il proprietario, e solo con `memberSlots == 0` (o campo assente) **oppure** con `deletionStartedAt` presente nel suo profilo. La seconda condizione è il percorso di recupero se il contatore si è sfasato: a quel punto il runner ha già cancellato tutti i documenti `members`. | Test: proprietario con inviti chiusi sì; con un invito aperto e senza `deletionStartedAt` no; con contatore sfasato e `deletionStartedAt` sì; persona invitata no. |
| NFR4.4 | **Sequenza completa** della cancellazione permessa dalle regole: attivazione e uscita da una cantina altrui, cancellazione dei propri `members` chiusi, revoca e cancellazione degli inviti propri, bevute, vini, cantina, profilo. | Test delle regole che esegue l'intera sequenza su dati di prova. |
| NFR4.5 | **Non regressione e compatibilità:**<br>• `u1`, `u4`, `u7` e `compat/` restano verdi;<br>• `test/rules/u8.rules.test.mjs` si aggiunge allo script `test:rules` di `package.json`;<br>• le scritture nuove (cancellazione di `users` e `cellars`, `deletionStartedAt`) entrano in `app-writes.json` come nuova versione `u8-account` con `requiresRules: "account"`;<br>• `RULES_FEATURES` in `promote.yml` diventa `sharing cellar account`;<br>• ordine obbligato del rilascio: prima regole con `firebase-deploy.yml`, poi l'app. | Job `rules`; test "ogni `requiresRules` è protetto"; controllo delle regole in `promote.yml`. |
| NFR4.7 | **Web:**<br>• il dominio di GitHub Pages va aggiunto ai domini autorizzati di Firebase Auth;<br>• App Check per il web va attivato con reCAPTCHA (gratuito), così le regole che richiedono App Check valgono anche per la pagina;<br>• sono azioni del proprietario nella console, elencate nella checklist;<br>• le versioni della libreria Firebase nel browser sono fissate, con controllo d'integrità (SRI). | Voce della checklist; controllo di script sulle versioni fissate. |
| NFR4.6 | **Riautenticazione** con lo stesso account Google prima di cancellare; un account diverso annulla tutto. Anche la **ripresa** di una cancellazione (BR1.8) chiede la riautenticazione prima di eseguire il primo passo, senza ripetere la parola di conferma: vale sullo stesso telefono e su un altro telefono che vede `deletionStartedAt`. | Test con servizio di accesso finto: ripresa con riautenticazione riuscita, annullata, con altro account. |

## Privacy (NFR8)

| ID | Requisito | Verifica |
|---|---|---|
| NFR8.1 | **Dati cancellati** subito dall'app; per le richieste via email entro 30 giorni dalla console, con la procedura della checklist.<br>**Residui dichiarati** nelle cantine altrui, per scelta (Q3 = A): l'uid nei campi `recordedBy` e `updatedBy`, e nelle bevute scritte lì il nome del vino e le note, che fanno parte dello Storico del proprietario di quella cantina.<br>**Caso limite** (BR1.8): con un'app reinstallata tra la cancellazione del profilo e `deleteUser`, l'utente in Authentication con l'email resta; si rimuove ripetendo "Cancella account" o con la procedura via email. | Test end-to-end: dopo la cancellazione nessun documento contiene l'email; l'uid compare solo nei campi `recordedBy` e `updatedBy` di cantine altrui; nessun documento `users`, `cellars` o `members` dell'utente. |
| NFR8.2 | **Report degli errori:** solo `account_delete_failed`, `account_signout_failed`, `account_reauth_failed`. Per non passare dal messaggio dell'eccezione (che `ErrorReporter` invierebbe ripulito ma intero), U8 segnala un errore tipizzato proprio, `AccountOperationError(reason, step)`, con solo il motivo, il passo e il nome del tipo dell'eccezione originale; mai email, nomi, uid, percorsi o messaggi. `account_signout_failed` è il motivo del report; lo stato esistente `SignOutFailed` del gate resta com'è. | Test con valori marcatore e `ErrorSink` finto: nessun marcatore nel report. |
| NFR8.3 | **Telefono pulito** dopo la cancellazione: azzeramento di U1, file temporanei di U6, segnale locale tolto dopo l'azzeramento. | Test del runner con dipendenze finte. |
| NFR8.4 | **Scheda "Sicurezza dei dati" e informativa:** cancellazione disponibile nell'app e dalla pagina web; elenco dei codici tecnici che restano nelle cantine altrui (`recordedBy`, `updatedBy`). | Voce della checklist. |
| NFR8.6 | **Richieste via email (solo ultima strada, decisione del proprietario 2026-11-06).** Per chi non può più accedere a Google. Procedura della checklist:<br>1. data della richiesta;<br>2. risposta all'indirizzo dell'account con la domanda di conferma;<br>3. cancellazione dalla console solo dopo il "Sì" da quell'indirizzo, entro 30 giorni;<br>4. chiusura senza cancellare dopo 14 giorni senza risposta.<br>Non si controllano firme o intestazioni: la risposta dall'indirizzo dell'account basta a dimostrare che la richiesta è del titolare. | Voce della checklist. |
| NFR8.5 | **Pagina web con accesso Google (decisione del proprietario 2026-11-06).** In `docs/account-deletion/` (it, en, pt-BR), su GitHub Pages:<br>• accesso con Google tramite Firebase Auth nel browser;<br>• cancellazione con gli stessi passi e le stesse regole dell'app;<br>• indirizzo `bottazzinibruno@gmail.com` visibile solo come ultima strada;<br>• nessun modulo che raccolga dati;<br>• nessuna chiave privata nella pagina: la configurazione web di Firebase è pubblica per natura e protetta da regole e App Check. | Test della logica di cancellazione web contro la Firebase Emulator Suite; controllo di script che la pagina esista nelle tre lingue. |

## Accessibilità (NFR3)

| ID | Requisito | Verifica |
|---|---|---|
| NFR3.1 | Aree di tocco ≥ 48 dp, contrasto ≥ 4,5:1, testo al 200% senza tagli, tre lingue. | Test dei widget. |
| NFR3.2 | Avanzamento della cancellazione annunciato a TalkBack a ogni passo; pagina della presentazione annunciata ("Pagina N di 3"). | Test dei widget sulla semantica. |

## Affidabilità (NFR6)

| ID | Requisito | Verifica |
|---|---|---|
| NFR6.1 | **Passi ripetibili:** ogni passo rieseguito dopo un successo parziale non fallisce e non lascia dati. | Test del runner: interruzione dopo ogni passo e ripresa. |
| NFR6.2 | **Ripresa** solo con un segnale esplicito (locale o `deletionStartedAt`); un account nuovo senza profilo non viene mai cancellato. | Test del gate: profilo assente senza segnale → apertura normale. |
| NFR6.3 | **Uscita con modifiche in coda:** "Esci comunque" non perde le modifiche se rientra lo stesso account. | Test end-to-end sugli emulatori. |
| NFR6.4 | **Ogni errore ha "Riprova"** e nessuno stato bloccato. | Test dei widget per ogni ramo. |
