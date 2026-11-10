# Vinoozy — preparazione operativa del 9 novembre 2026

Base: commit `ee114e34ecdb2ec0dff873d20ad23d0004996947` e modifiche locali
di questa sessione. L'audit iniziale rimane in
[vinoozy-pubblicazione-checklist.md](vinoozy-pubblicazione-checklist.md).
Questo documento registra la preparazione, non attesta una pubblicazione.

## Modifiche preparate nel progetto

| Area | Risultato |
|---|---|
| CI nativa | Dai log del job `129086514109`: `./gradlew: No such file or directory`. Rimossi gli ignore del wrapper: includere nel commit `android/gradlew`, `gradlew.bat` e `gradle/wrapper/gradle-wrapper.jar`. Eseguiti localmente test nativi e JaCoCo. |
| Workflow release/promote | `runner.temp` non è disponibile in `jobs.<job_id>.env`. Percorsi temporanei impostati negli step tramite `GITHUB_ENV`; file credenziali scritti con `umask 077`. Actionlint locale verde; stessa verifica aggiunta alla CI con versione e checksum fissate. Il timeout del job unit è 30 minuti per includere test nativi e due build su runner pulito. |
| Aspettative E2E | Profilo Barolo aggiornato a livello/stile automatici e tabelle versione 3; lettura del picco dal widget Text stesso, dopo il caricamento. Il dataset sintetico Cruscotto usa stili confermati e versione corrente per evitare migrazioni durante le aspettative dei grafici; scorrimento seleziona l'asse verticale. Modifiche da confermare con una nuova esecuzione E2E completa. |
| Prima promozione | Il valore predefinito passa a `1.0`; `0.2` è esplicitamente riservato agli aggiornamenti. Verificare comunque il percorso del primo rilascio in Console. |
| Annulla | Il messaggio della bevuta usava il messenger locale della Cantina e spariva cambiando scheda. Usa ora quello dello Scaffold esterno; messaggio flottante con spazio per il pulsante Aggiungi. Test di regressione Cantina→Storico→Annulla passato, anche i test con Cantina isolata restano verdi. |
| Storico | La paginazione mantiene una riga per ID anche se una registrazione compare in due pagine; regressione con pagine sovrapposte passata. Non certifica da sola il bug storico su telefono, che resta da riprovare. |
| Privacy nell'app | URL predefinito dedicato `/privacy/`; apertura HTTPS nel browser di sistema, copia del link e recupero dall'errore disponibili. Test del contratto Android e widget passati. |
| Pagine pubbliche | Informativa HTML in it/en/pt-BR, ricavata dall'appendice A. Testi di cancellazione allineati all'appendice B, senza promesse di anonimizzazione o cancellazione totale istantanea. `pages.yml` include ora `docs/privacy/`. Nessuna pagina distribuita in questa sessione. |
| Scheda store | Titolo, descrizione breve ed estesa in `distribution/google-play/{it-IT,en-US,pt-BR}/`; bozza inglese per i reviewer e lista della grafica necessaria. |
| Controllo materiale | `npm run check:publication`; `--draft` valida la struttura lasciando espliciti i blocchi. La pubblicazione Pages usa il controllo rigoroso `--web-only`. Il controllo non certifica le console o la conformità complessiva. |
| Barra della finestra di consumo | Individuati durante la preparazione delle catture i segmenti colorati ad altezza zero. La Row ora estende i segmenti all'altezza disponibile; regressione sulle dimensioni dei segmenti nelle tre lingue. I 76 test di `ux_redesign_test.dart` passano. |
| Catture store | Dodici PNG 1080×1920 ottenuti dai widget Flutter effettivi con tema Android e dati fittizi: Cantina, Cruscotto, dettaglio, Storico nelle tre lingue. Comando esplicito `tool/render_store_screenshots_test.dart`, 3 test passati; font e provenienza documentati nel README del materiale store. Queste catture non sostituiscono il collaudo della build firmata. |

## Verifiche locali

- Analisi Flutter: **nessun problema**.
- Suite Flutter completa: **2.645 test passati**.
- Android nativo: **48 test passati**, nessun errore; JaCoCo etichette:
  **157/172 righe, 91,28%**, soglia 80% rispettata.
- Actionlint 1.7.12: tutti i workflow validi, ShellCheck/Pyflakes esclusi.
- Bundle web riproducibile, script locali e CSP: passato.
- Catalogo: **15.490 vini**; denominazioni: **2.424**, manifest coerente;
  indici Firestore: passati.
- Materiale store: it **23/78/1778**, en **25/68/1663**, pt-BR
  **18/79/1754** caratteri, entro 30/80/4000.
- E2E: **non completati**. L'emulatore Android locale installa l'APK ma
  non restituisce il VM Service dopo `am start`; anche la cattura schermo
  scade. Tentativi interrotti. Non è una prova di successo e non chiude il
  collaudo dei quattro fallimenti remoti.
- `tool/check_release_build.sh`: **passato**, entrambe le build demo arm64.
  E2E/PERF e lingua forzata assenti dal bundle normale e presenti nel
  controllo positivo; permessi e filtri del manifest verificati. Il bundle
  normale è conservato in `build/check_release/app-release.aab`: è un
  artefatto demo di verifica, non il bundle firmato da caricare su Play.
- Sul bundle demo normale: 10 librerie ELF a 64 bit controllate, nessun
  segmento `PT_LOAD` con allineamento inferiore a 16 KB. Manifest release
  unificato: package `com.vinoozy.app`, minSdk **24**, targetSdk **36**.
  Questi controlli parziali non sostituiscono Bundle Explorer o la verifica
  di APK/pagine memoria della futura build firmata. SHA-256 del bundle demo:
  `3218e6e918c5216e496ebcfdff14560c430683df5df38651d97159df26b2c8a1`.
- Controllo del controllo di pubblicazione, su copia temporanea: bozza
  incompleta rifiutata in modalità rigorosa, accettata come bozza esplicita;
  fixture completata accettata; link locale rotto rifiutato in entrambi i modi.

I test locali non equivalgono a una CI remota verde o a una prova Play.
Un AAB candidato firmato è stato generato successivamente, come descritto
sotto; il collaudo sul dispositivo resta da completare. I log temporanei
della sessione sono in `/tmp/vinoozy-*`.

## Chiave di caricamento e primo AAB candidato

Il titolare ha autorizzato esplicitamente la creazione di una nuova chiave
dedicata a Vinoozy. Creata il 9 novembre 2026 e verificata:

- cartella privata: `~/Library/Application Support/Vinoozy/Signing`, permessi
  `0700`; file `0600`;
- keystore `vinoozy-upload.p12`, formato PKCS12, alias `vinoozy-upload`,
  RSA 4096, firma SHA256withRSA, validità fino al 27 marzo 2054;
- password casuale custodita nel Portachiavi macOS: servizio
  **Vinoozy Android Upload**, account **vinoozy-upload**;
- certificato pubblico `vinoozy-upload-certificate.pem`; metadati e note
  di backup in `upload-key-info.json` e `README.txt` nella stessa cartella;
- SHA-1: `81:7C:4B:3A:0C:56:E9:79:18:E2:86:26:FB:6A:1E:71:D4:C6:A3:7E`;
- SHA-256: `48:94:6B:74:41:4A:2D:5C:A7:08:87:B9:0C:84:A5:C9:30:DB:A9:30:19:18:7A:78:A8:3B:F7:A2:F9:FD:D8:64`.

La password non è stata inserita nel repository, nei log o nella chat;
la build la recupera privatamente dal Portachiavi e la passa tramite le
variabili di ambiente già previste da Gradle. Aggiunto `*.p12` agli ignore.
Non esiste ancora un backup esterno: conservare una copia cifrata della
cartella e un metodo sicuro per recuperare la password.

**Questa è la upload key, non la app signing key di Google Play.** Le
impronte Firebase/OAuth/App Check per le installazioni Play dovranno essere
quelle effettive di Play App Signing, quando disponibili.

AAB candidato conservato in
`build/publication/0.1.0+1/vinoozy-0.1.0+1-prod-candidate.aab`, ignorato da Git:

- package `com.vinoozy.app`, versione `0.1.0`, versionCode **1**;
- dimensione **88.794.175 byte**, SHA-256
  `9ff1bef1eb3c9a6cbd79b3624ea6846719c5bd346e1eb44ce4cb6b8a6f37dd7b`;
- build release con `config/firebase_prod.json`, ambiente `prod`, progetto
  `vinoozy-d6f45`, ricerca OFF online disabilitata;
- firma JAR verificata e impronta del firmatario corrispondente alla nuova
  upload key. I normali avvisi di certificato autofirmato sono conservati
  nel rapporto; non indicano un certificato debug;
- `bundletool` ufficiale **1.18.3**, scaricato dal repository Google e
  verificato con il checksum fissato dal progetto: validazione passata;
- ABI `armeabi-v7a`, `arm64-v8a`, `x86_64`; segnali E2E/PERF/lingua forzata
  assenti da tutti i `libapp.so`; minSdk **24**, targetSdk **36**;
- dodici librerie ELF a 64 bit: tutti i segmenti `PT_LOAD` allineati ad almeno
  16 KB; configurazione bundle `PAGE_ALIGNMENT_16K`. Restano la verifica
  degli APK generati da Play e la prova su dispositivo;
- nessun permesso fotocamera, lettura immagini/archivio o ID pubblicità
  nel manifest release verificato; app non debuggable;
- rapporti, manifest e certificato del firmatario salvati nella stessa
  cartella del candidato (`verification.json`, `jarsigner-verification.txt`,
  `signer-certificate.txt`, `bundletool-validation.txt`, `bundle-config.json`,
  `bundle-manifest.xml`).

Il candidato deriva dal commit base indicato sopra **più le modifiche locali
non ancora committate**. Caricato e accettato da Play nella bozza di test
interno dopo autorizzazione esplicita del titolare; successivamente il
titolare ha attivato la distribuzione interna, verificata nella Console.
Non sostituisce CI remota, E2E e prova dell'accesso Google dopo Play App Signing. Verificato
anche il dubbio sull'ID Crashlytics: il plugin Flutter installato dichiara
`com.crashlytics.RequireBuildId=false`; l'assenza del plugin Gradle dedicato
non costituisce da sola prova di un crash all'avvio.

## Play Console: stato osservato

Account Google selezionato: **bottazzinibruno@gmail.com**. Account sviluppatore:
**Bottazzini Softworks**, tipo **personale**, con un'altra app già in produzione.
La data di creazione dell'account non è ancora verificata. I requisiti
specifici di Vinoozy sono ora visibili nella dashboard della nuova app:
**test chiuso con almeno 12 tester aderenti per gli ultimi 14 giorni
consecutivi**, poi domanda di accesso alla produzione. Al momento della
creazione risultano **0 tester**. L'altra app già pubblicata non esenta
Vinoozy da questo percorso.

**App creata in Play Console il 9 novembre 2026**, dopo conferma esplicita
del proprietario sulle dichiarazioni relative alle norme del programma e
alle leggi USA sull'esportazione, inclusi eventuali requisiti sulla crittografia:

- nome **Vinoozy: la tua cantina**;
- package **`com.vinoozy.app`**;
- lingua **Italiano — it-IT**;
- **App**, **senza costi**.

La creazione è confermata dalla
[dashboard di Vinoozy](https://play.google.com/console/u/1/developers/7355456641864294998/app/4974010218208182861/app-dashboard),
lasciata aperta in Chrome. ID app Play: `4974010218208182861`.
La scheda è nella configurazione iniziale: caricato il primo AAB nella
bozza del test interno, poi distribuito internamente dal titolare. Il canale
interno risulta attivo; nessun rilascio in produzione effettuato.
Restano da completare i punti
dell'audit sotto. La Console mostra anche la notifica sullo stato di
commerciante da dichiarare entro il **1 febbraio 2027**.

Configurazione salvata nella Console durante la preparazione:

- categoria **Cibi e bevande** ed email pubblica di supporto confermata;
- dichiarazione **nessun annuncio**, salvata e pronta da inviare per review;
- dichiarazioni **app non governativa**, **nessuna funzionalità finanziaria**
  e **nessuna funzionalità relativa alla salute**,
  salvate e pronte da inviare per review;
- dichiarazione **nessun utilizzo dell'ID pubblicità**, coerente con codice,
  dipendenze e manifest release controllati; salvata per review;
- titolo e descrizioni **it-IT, en-US e pt-BR**, ciascuna entro i limiti;
- icona ufficiale 512×512 e feature graphic 1024×500;
- quattro catture smartphone per lingua, dodici immagini totali;
- dichiarazione AI selezionata per la sola feature graphic, tramite
  il passaggio di revisione della scheda. Le immagini sono state etichettate
  e salvate; dopo il salvataggio finale la Console mostra **Pronta per
  essere inviata per la revisione**. La scheda resta da inviare per review
  dalla panoramica di pubblicazione quando gli altri requisiti saranno pronti.

La grafica di primo piano predefinita contiene la frase italiana; le altre
due lingue usano questa grafica come fallback, con schermate proprie.

Ultimo conteggio osservato nella dashboard: **7 di 11 attività completate**,
inclusa la classificazione IARC (vedi il dettaglio sotto). La dichiarazione separata
sull'ID pubblicità è completata anch'essa. Restano privacy, Dettagli di
accesso, pubblico e Sicurezza dei dati. Il modulo dell'account demo è
stato preparato con titolo e istruzioni in inglese e poi **annullato** su
correzione del titolare: l'account disponibile è personale, non dedicato
ai revisori. La sezione Dettagli di accesso resta incompleta. Il percorso
dei tester con il proprio Google account è distinto dall'accesso richiesto
al team di revisione; nessun account demo va dichiarato pronto finché non
esiste ed è stato verificato.

**Test interno preparato:** creato e selezionato l'elenco **Vinoozy — test
interno**, con un solo indirizzo, quello del proprietario già confermato.
Canale `4700072401178803318`, una attività su tre completata. I tester
aderiscono con il proprio account Google; questo non richiede di fornire
la password in Dettagli di accesso. Il titolare ha successivamente confermato
la pubblicazione interna; verificati nella pagina del canale gli stati
**Attivo** e **Disponibile per i tester interni**. Questa disponibilità non
costituisce una prova di funzionamento del login o una pubblicazione in produzione.
Il bundle demo già generato resta escluso dal caricamento.

**Primo upload completato:** dopo consenso esplicito del titolare alla
lettura dei dati Vinoozy, alle relative schermate e al caricamento/registrazione
del certificato pubblico, caricato l'AAB candidato firmato indicato sopra.
Play ha terminato l'ottimizzazione e mostrato **1 app bundle caricato**:
versione **1 (0.1.0)**, API **24 e successive**, target **36**, **3 ABI**.
La prima bozza interna (`releases/1/prepare`) contiene il nome
**0.1.0 (1) — primo test interno** e note per **3 lingue su 3**, allineate a
`distribution/google-play/release-notes.txt`. Premuto **Salva come bozza**;
esito osservato **Modifiche salvate. Ora puoi visualizzare l'anteprima della
release prima di pubblicarla.** L'agente si è fermato alla bozza autorizzata;
il passaggio finale di distribuzione interna è stato poi eseguito dal titolare
e verificato come indicato sopra.
Prova finale limitata alla pagina Vinoozy:
`/tmp/vinoozy-bozza-aab-salvata.png`.

La Console mostra già la firma gestita da Google Play. Scaricati i tre
certificati pubblici effettivi (`deployment_cert.der`,
`hybrid_classical_cert.der`, `hybrid_pqc_cert.der`), con impronte e metadati in
`build/publication/0.1.0+1/play-signing-certificates/fingerprints.json`.
Il certificato della upload key scaricato separatamente da Play corrisponde
esattamente alla nuova chiave locale autorizzata. Non confondere upload key
e firma effettiva dell'app.

Per le nuove app Play usa automaticamente una firma ibrida per Android 17+
e una firma classica separata per i sistemi precedenti. La guida Play richiede
la registrazione delle nuove impronte anche presso i fornitori API:
<https://support.google.com/googleplay/android-developer/answer/9842756?hl=en-GB>.
Impronte SHA-1 effettive osservate:

- deployment classica: `36:7A:9F:F7:E8:20:B9:3E:BA:E4:EA:1A:6D:E8:82:83:E0:4C:A4:B3`;
- ibrida classica: `7A:1C:22:28:76:08:FB:66:CF:F3:C1:93:C0:67:11:71:74:19:1F:0E`;
- ibrida PQC: `15:C6:53:6B:36:41:F3:B5:0D:81:4A:58:3C:77:18:2D:32:4C:E0:E2`.

Il titolare ha poi autorizzato esplicitamente l'aggiunta delle impronte Play,
la configurazione di App Check/Play Integrity in monitoraggio e accettato
i relativi Termini. **Registrate e verificate tutte e sei le SHA-1/SHA-256**
dei tre certificati di firma effettivi nell'app Android Firebase. Conservata
anche la SHA-1 di test esistente
`77:3F:33:4E:FD:5B:E8:43:2F:F5:F8:8A:BB:85:65:4A:F3:05:0E:7A`:
sette righe nella tabella, nessuna impronta Play mancante. Prova:
`/tmp/vinoozy-firebase-firme-play-registrate.png`.
App Check Android ora risulta **Registrata**, provider **Play Integrity**,
tre SHA-256 precompilate correttamente da Firebase e TTL token predefinito
di un'ora. Accettati i Termini autorizzati e salvato il provider. Nella
scheda API, **Cloud Firestore** e **Authentication** risultano **Non
applicato**, quindi senza enforcement. Web non registrata e ancora esclusa
dal flusso automatico. In Play Integrity collegato il progetto Cloud
**Vinoozy**, numero **742143174654**, quota **10.000 richieste/giorno**.
Prove: `/tmp/vinoozy-app-check-registrata.png`,
`/tmp/vinoozy-app-check-monitoraggio.png`,
`/tmp/vinoozy-play-integrity-collegato.png`.

L'account Google di prova non è stato finalizzato: durante il blocco del Mac
il flusso è passato a `accounts.google.com/info/sessionexpired`. Il titolare
ha ora autorizzato l'accettazione finale dei Termini Google/YouTube e le
schermate pertinenti; la registrazione va ripresa senza leggere o generare
password tramite il controllo browser.

## Stato delle decisioni e attività rimanenti

### Completamento delle quattro attività della scheda

Il titolare ha chiesto di completare privacy, accesso revisori, pubblico e
Sicurezza dei dati. Stato della preparazione successiva:

- **Pagine statiche:** creato `tool/prepare_static_pages.mjs`, che esporta
  esclusivamente HTML/CSS senza login, SDK Firebase o moduli automatici.
  Tre informative e tre pagine per richiedere via email la cancellazione
  dell'account e dei dati, più indice e stile. Collegamenti locali validati,
  nessun TODO/script; rimossa una nota editoriale interna dall'informativa pt-BR.
- **Pubblicazione autorizzata:** dopo un primo rifiuto automatico sulla
  divulgazione pubblica di nome/contatto, il titolare ha autorizzato
  esplicitamente il caricamento sul repository pubblico e sul sito GitHub
  Pages. Il connettore GitHub non disponeva del permesso `git/trees` (403),
  quindi usato l'accesso SSH già configurato, senza nuovi token. Creato
  soltanto il ramo `gh-pages`, commit
  `9c086d3e65e3ef7f2eb9763a1501851eaaae467d`, con nove file dell'export
  statico. Nessun push su main o pubblicazione delle altre modifiche locali.
  Hosting Pages osservato attivo sul ramo `gh-pages`, HTTPS obbligatorio.
  Verificate otto risorse HTTPS con risposta 200 e SHA-256 identico
  all'export locale, incluse tutte e sei le pagine nelle tre lingue.
  Rapporto: `build/publication-web/publish-result.json`.
- **Privacy in Play completata:** salvato
  `https://brunobottazzini.github.io/Vinoozy/privacy/`; esito Console
  **Modifica salvata. Inviala per la revisione nella pagina Panoramica della
  pubblicazione.** Non è un invio per revisione né un rilascio pubblico dell'app.
- **Cancellazione web iniziale:** richiesta via email al contatto confermato,
  ammessa dalla guida Play; non viene esposto il modulo automatico con
  reCAPTCHA ancora mancante. La pubblicazione del flusso automatico continua
  a richiedere i controlli completi di `pages.yml`, configurazione Firebase,
  regole compatibili e prova reale. Questo export non cambia le regole backend.
- **Sicurezza dei dati:** proposta dettagliata in
  `distribution/google-play/data-safety.json`, riferita all'AAB codice 1 con
  OFF disabilitato. Include SDK transitivi, identificativi tecnici, relazioni
  di invito e foto profilo. Esportato il modello ufficiale della Console
  (782 righe), preparato `distribution/google-play/data-safety.csv` e
  importato con successo. Dieci tipi di dati completati; crittografia in
  transito, OAuth e URL di richiesta cancellazione verificati nell'anteprima.
  Salvata la bozza: **Modifica salvata. Inviala per la revisione nella pagina
  Panoramica della pubblicazione.** Il salvataggio finale è disabilitato
  finché non si completa **Pubblico di destinazione e contenuti**, a sua
  volta bloccato dai Dettagli di accesso. Domanda facoltativa sulla rimozione
  di dati senza eliminare l'account lasciata senza risposta; nessun badge
  MASA/UPI o conformità Famiglie dichiarato. Nessun invio per review.
- **Dettagli di accesso:** selezionato correttamente **Sì** alla domanda
  sulle limitazioni (Google login); preparati nome e istruzioni inglesi da
  425/500 caratteri. Email, password e attestazione di accesso completo
  ancora da inserire/confermare dopo la creazione e verifica dell'account.
- **Account revisori:** su richiesta del titolare, avviato in Chrome un
  nuovo account Google con nome Vinoozy Review e indirizzo proposto da Google
  `vinoozyreview@gmail.com`. Password/verifiche/Termini lasciati al titolare.
  La prima conferma del titolare è arrivata mentre Google mostrava ancora
  le scelte di personalizzazione: richiesto di completare il flusso fino alla
  pagina dell'account. Su richiesta di aiuto, selezionato il percorso in un
  passaggio, **Rifiuta tutto** e confermate le preferenze di personalizzazione.
  Arrivati a **Privacy e termini**, pulsante **Accetto**: chiesta conferma
  specifica ai Termini Google/YouTube prima del clic finale. Il titolare ha
  poi autorizzato il completamento, ma nel frattempo la sessione era scaduta
  durante il blocco del Mac. Riavviata la creazione, compilati nome/cognome
  Vinoozy Review e lasciato al titolare l'inserimento diretto di data di
  nascita, indirizzo Gmail e password. Gli è stato chiesto di fermarsi alla
  schermata **Scegli le tue impostazioni**, da cui l'agente può completare
  preferenze e Termini già autorizzati. Il secondo tentativo ha richiesto
  una verifica del dispositivo/telefono tramite QR prima della creazione.
  Su richiesta esplicita del titolare, riavviata una volta la registrazione
  dall'URL ufficiale `https://accounts.google.com/signup`, nella stessa
  scheda Chrome: nome Vinoozy Review inserito e schermata **Informazioni
  di base** verificata. Il titolare ha poi autorizzato una data adulta
  qualunque per l'account di prova: inserito **1 gennaio 1990**, genere
  **Preferisco non dirlo**. Selezionato di nuovo l'indirizzo proposto da
  Google `vinoozyreview@gmail.com`; verificata la schermata **Crea una
  password sicura** e lasciati al titolare inserimento, conferma e invio
  della password. Il riavvio non garantisce che Google rinunci alla
  verifica; non aggirare eventuali controlli antiabuso. Non dichiarare
  l'account pronto prima della verifica finale.
  Dopo l'inserimento della password il titolare ha segnalato un errore:
  al controllo, Chrome mostrava nuovamente il modulo iniziale del nome,
  senza il messaggio precedente. Verificato l'indirizzo tramite il normale
  accesso Google (**Aggiungi un altro account**, sola email): risposta
  **Impossibile trovare questo account** per `vinoozyreview@gmail.com`.
  L'account non risulta creato; causa dell'errore iniziale non determinata.
  Nessuna password letta o inserita dall'agente, nessun recupero avviato.

Ultima dashboard verificata dopo il salvataggio della privacy e della bozza
dati: **8 di 11**. Sono ancora aperti Dettagli di accesso, Pubblico di
destinazione e Sicurezza dei dati (bozza). Le conferme ai Termini Google/
YouTube e al collegamento delle firme Play/Firebase sono state ricevute;
Firebase e Play Integrity sono stati configurati e verificati come sopra.
Il controllo automatico aveva rifiutato un'ulteriore schermata della
registrazione Google: l'autorizzazione alle schermate Play non era stata
considerata sufficiente per quel flusso. Ricevuto ora anche il consenso
specifico per documentare la conferma dei Termini e la creazione dell'account,
escludendo password e data di nascita.

**Interruzione operativa risolta:** durante la cattura della dashboard 8/11
il Mac si era bloccato; il titolare l'ha sbloccato. Ripresa e verificata la
vista normale di Chrome. Il modulo App access con solo titolo/istruzioni
resta aperto in un'altra scheda; la registrazione Google è stata riavviata
dopo la scadenza. L'agente attende soltanto i nuovi dati inseriti direttamente
dal titolare nella pagina Google, senza leggere o memorizzare la password.

1. **Contatto privacy.** Bruno Bottazzini ed email confermati dall'utente;
   il 9 novembre l'utente ha indicato nuovamente `bottazzinibruno@gmail.com`
   come contatto pubblico. Tolto dalle pagine il placeholder dell'indirizzo
   postale: era una scelta editoriale della bozza, non un requisito
   esplicito della sezione privacy della policy Play, che richiede identità
   dello sviluppatore e un punto di contatto privacy. Questa modifica non
   certifica la conformità GDPR complessiva; verificare separatamente i dati
   richiesti per account sviluppatore e stato di commerciante.
2. **Firebase web.** Registrata **Vinoozy Web** nel progetto `vinoozy-d6f45`,
   senza configurare Hosting né cambiare il piano Spark. App ID
   `1:742143174654:web:815bb282e4a519d0e042af`. Copiati dalla Console i quattro
   valori pubblici apiKey, authDomain, projectId e appId in
   `docs/account-deletion/firebase-config.js`. Mancano ancora chiave pubblica
   reCAPTCHA e registrazione del provider App Check. Verificati i domini Auth:
   risultano soltanto `localhost`, `vinoozy-d6f45.firebaseapp.com` e
   `vinoozy-d6f45.web.app`; `brunobottazzini.github.io` non è autorizzato.
   Nessun dominio OAuth aggiunto durante questa preparazione.
   Il codice della pagina non inizializza Analytics, anche se lo snippet
   proposto dalla Console includeva quell'SDK. Seguire
   `docs/firebase-setup.md` §10 per i passaggi restanti.
3. **Trasparenza e condivisione.** Chiudere le decisioni dell'audit su dati
   residui, conservazione, inviti e informazione ex art. 14, UGC/termini,
   segnalazioni e licenze delle fonti. I testi rimangono bozze da confermare.
4. **Credenziali e firma.** Verificati in GitHub il 9 novembre: il repository
   è pubblico e non presenta ambienti né segreti Actions configurati.
   Il workflow non può ancora firmare/pubblicare la build. Creata e verificata
   sul Mac la nuova upload key autorizzata e generato il candidato firmato
   descritto sopra. Restano Play App Signing, relative SHA-1 e SHA-256,
   OAuth, App Check, service account e ambienti GitHub. Non inserire
   chiavi private nel repository o nei testi dei reviewer.
5. **OFF.** Il JSON locale di produzione non contiene il contatto OFF; la
   presenza nel segreto GitHub non è stata verificata. Scegliere contatto
   dedicato oppure distribuzione con ricerca OFF disattivata; la base vini
   offline resta disponibile. Verificare la build effettiva.
6. **Reviewer e collaudo finale.** Icona, feature graphic e catture dei widget
   correnti disponibili in `distribution/google-play/assets/`. Preparare
   account dimostrativi funzionanti, compilare App access e verificare
   nuovamente grafica/comportamento sulla futura build firmata.
   La Console blocca il questionario sul pubblico finché non viene
   completata la sezione Dettagli di accesso. Servono credenziali demo Google
   funzionanti e riutilizzabili anche da altri paesi; la sola indicazione
   di accedere con un account proprio del reviewer non è accettata dalla
   schermata. Inserire le credenziali direttamente nella Console.
7. **IARC completata il 9 novembre 2026, ore 14:25.** Accettati i Termini
   dopo consenso esplicito del titolare; questionario compilato e salvato.
   Stato Console **Ordine completato**. Europa **PEGI 16**, Brasile **14**,
   Nord America **17+**, Germania **USK per tutti**, IARC Generic/Russia/Corea
   del Sud **16**. ID certificato attualmente mostrato come `-`.
   Questi sono gli esiti regionali generati dal questionario; il pubblico
   di destinazione proposto per il prodotto rimane **18+**.

   Risposte: app utility, riferimenti frequenti ad alcolici; imprecazioni
   moderate e a sfondo sessuale **rare**, presenti in sei nomi/produttori
   del catalogo offline OFF (15.490 record, export 2026-11-07), fra cui
   “Le Vin de Merde”, “Fat Bastard”, “Just fucking good wine” e “Sweet Bitch”.
   Nessuna violenza, paura, sessualità rappresentata, gioco d'azzardo o
   umorismo corporeo. Condivisione nativa presente, circoscrivibile agli
   invitati; non è un feed pubblico di contenuti altrui. Nessuna funzione
   dichiarata di blocco, segnalazione o moderazione chat.

   **Perimetro tecnico:** configurazione locale attuale con `OFF_CONTACT`
   assente/vuoto e quindi ricerca OFF online disabilitata da `offEnabled`.
   Nessun altro catalogo online promosso nell'app; dati privati sincronizzati
   degli utenti esclusi da questa specifica domanda secondo la guida IARC.
   Prima dell'AAB verificare gli effettivi define della build e i segreti CI:
   attivare OFF o modificare catalogo/funzioni può richiedere un nuovo
   questionario. Non trattare il rating corrente come convalida preventiva
   di qualsiasi futura configurazione online.

## Ordine dei prossimi passaggi

1. Completare dati privacy e configurazione web, quindi le attività di
   configurazione della scheda Vinoozy già creata in Play Console.
2. Includere i nuovi file nel commit, far passare la CI remota, ripetere gli
   E2E su un emulatore funzionante e i bug noti sul telefono. Il caso di
   molte centinaia di vini con stile ancora da confermare richiede anche
   una prova del Cruscotto: la relativa lista attuale mostra tutte le righe.
3. Pubblicare regole/indici e pagine tramite i workflow predisposti; provare
   privacy e cancellazione web senza app installata, con account di prova.
4. Creare l'AAB firmato iniziale con `versionCode` maggiore di quelli già
   utilizzati. Il bootstrap può richiedere il primo upload manuale, prima
   che `next-version-code`/upload API siano operativi. Annotare commit,
   versionCode e SHA-256 dell'AAB. Verificare API target, 64 bit e pagine
   memoria 16 KB sull'artefatto effettivo e nel Bundle Explorer.
5. Configurare Play App Signing/OAuth/App Check con le impronte corrette;
   installare dal test interno e completare `docs/release-checklist.md`.
6. Completare Data safety, IARC, pubblico/paesi, accesso reviewer e grafica.
   Eseguire il test chiuso richiesto dalla dashboard: almeno 12 tester
   aderenti per 14 giorni consecutivi, quindi richiedere l'accesso alla
   produzione. Nessun invio per review eseguito in questa sessione.

Riferimento per l'errore dei workflow:
[contesti GitHub Actions](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts).
Evidenza del job nativo e dei quattro E2E:
[CI del commit di partenza](https://github.com/brunobottazzini/Vinoozy/actions/runs/42595346078).
