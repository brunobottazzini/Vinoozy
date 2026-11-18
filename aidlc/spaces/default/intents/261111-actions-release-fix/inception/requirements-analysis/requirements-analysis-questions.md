# Domande sui requisiti: correzione del rilascio GitHub Actions

Contesto: `docs/github-actions-handoff.md` descrive tre gruppi di lavoro: la
release sul canale interno è bloccata dai segreti mancanti nell'ambiente
`play-internal`; `release.yml` e `tool/play_api.sh` non spiegano quale
credenziale manca; un test E2E (riavvio con scritture offline) fallisce in
modo intermittente. Le correzioni al codice posso farle io; i valori delle
credenziali invece non devono mai passare da questa conversazione né finire
nel repository.

## Q1. [Proprietario] Chi configura i segreti e la variabile dell'ambiente `play-internal`?

Servono sette segreti (account di servizio Play, keystore di caricamento con
password e alias, `google-services.json` e dart-defines di produzione) e la
variabile `GOOGLE_SERVER_CLIENT_ID`. Senza di essi la release non può
funzionare, qualunque correzione faccia al codice.

A. Li configuri tu dalla pagina Settings → Environments di GitHub; io preparo una guida passo per passo con i nomi esatti e i controlli da fare dopo
B. Li carico io con `gh secret set` leggendo i file che hai già sul Mac (per esempio `config/firebase_prod.json`), senza mai stamparne il contenuto; tu mi indichi i percorsi dei file
C. Per ora solo le correzioni al codice; la configurazione la fai più avanti, separatamente
X. Other (please specify)

[Answer]: A

## Q2. [Proprietario] L'ambiente `play-production` (promozione in produzione) rientra in questo lavoro?

L'ambiente non esiste e `promote.yml` non può partire. Il primo rilascio in
produzione (0.2.1+3) è previsto con upload manuale da Play Console.

A. No, resta fuori: la promozione rimane manuale per ora
B. Sì, ma solo l'ambiente con la tua approvazione obbligatoria e la sola rimozione automatica dei segreti; il segreto `PLAY_PRODUCTION_SA_JSON` lo aggiungi tu più avanti
C. Sì, completo: ambiente, protezioni e segreto `PLAY_PRODUCTION_SA_JSON`, con le stesse verifiche di `release.yml` anche in `promote.yml`
X. Other (please specify)

[Answer]: C

## Q3. [Sviluppatore] Il test E2E intermittente (test 8 di `u1_skeleton_test.dart`) va corretto in questo lavoro?

Il manuale dice di trattarlo separatamente, ma tra i criteri di completamento
chiede una riproduzione e una correzione verificata, non un singolo passaggio
verde. Il percorso sospetto è la cantina attiva che cambia mentre la schermata
della cantina è in costruzione.

A. Sì, in questo lavoro: riproduzione, correzione e verifica ripetuta della suite E2E
B. No, in un lavoro separato subito dopo questo
C. Sì, ma solo la correzione difensiva del codice (cambio di cantina attiva rinviato fuori dalla build) con un test di widget che riproduce il caso, senza riproduzione sull'emulatore
X. Other (please specify)

[Answer]: A

## Q4. [Sviluppatore] Dove posso eseguire i test E2E per riprodurre e verificare la correzione?

Il job `e2e` usa Android API 34 con gli emulatori Firebase Auth, Firestore e
Functions. Una sola esecuzione in GitHub Actions dura circa 30-60 minuti.

A. Sul tuo Mac: è installato un emulatore Android e posso avviare gli emulatori Firebase
B. Solo in GitHub Actions: pubblico un ramo e faccio girare la CI più volte
C. Entrambi: riproduzione locale, poi conferma con più esecuzioni in GitHub Actions
X. Other (please specify)

[Answer]: A

## Q5. [Proprietario] Chi crea l'ambiente `play-production` e le sue protezioni?

In Q1 hai scelto di inserire tu i valori dei segreti; in Q2 hai chiesto la
configurazione completa di `play-production`. L'ambiente e le sue protezioni
(approvazione obbligatoria tua, solo il ramo `main`) non contengono
credenziali e posso crearli io con `gh api`.

A. Creo io l'ambiente e le protezioni con `gh api`; tu aggiungi solo il valore di `PLAY_PRODUCTION_SA_JSON`
B. Fai tutto tu dalla pagina di GitHub, seguendo la guida che preparo
X. Other (please specify)

[Answer]: B
