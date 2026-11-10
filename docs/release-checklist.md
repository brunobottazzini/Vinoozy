# Checklist di rilascio

Si usa prima di ogni promozione in produzione (`cicd-pipeline.md` §5). La build da provare è quella del canale **Test interno**, pubblicata da `release.yml` dopo il merge in `main`.

Per la **prima pubblicazione**, partire dallo [stato operativo](pubblicazione-stato-operativo.md) e dall'[audit di pubblicazione](vinoozy-pubblicazione-checklist.md): la presenza del workflow non prova che esistano già una build interna, una scheda Play o pagine pubbliche funzionanti.

## 1. Smoke test sul telefono reale

- [ ] Installa la build dal canale Test interno (`versionCode`: ______).
- [ ] Avvio a freddo: la prima schermata (il Cruscotto, da u5-dashboard) compare in circa **2 s** (NFR2.1). Tempo misurato: ______.
- [ ] Salvataggio di un vino: dal tocco su "Salva" alla riga nella lista in meno di **300 ms** (NFR1.1), con questa build di rilascio. Tempo misurato: ______. I test end-to-end usano 2 s solo come limite provvisorio di non regressione (build di debug sull'emulatore): NFR1.1 e NFR2.1 restano aperti finché queste due misure non sono fatte qui.
- [ ] Accesso con Google con il selettore di account vero (non coperto dai test automatici).
- [ ] Aggiungi un vino con la rete.
- [ ] Attiva la **modalità aereo**, aggiungi un secondo vino, verifica la fascia "Offline - sincronizzazione in attesa".
- [ ] Riattiva la rete: entrambi i vini compaiono nella Console Firestore e la fascia scompare.
- [ ] Crashlytics: nessun crash nuovo per questa versione.
- [ ] App Check: le richieste di questa versione risultano verificate.
- [ ] Profilo di prestazioni in modalità profile con 500 vini: meno del 5% di fotogrammi oltre 16 ms (NFR2.2).
- [ ] Velocità della stima sul telefono collegato (u2-estimation, NFR2.1 b): `flutter drive --profile --driver=test_driver/perf_driver.dart --target=integration_test_perf/estimation_perf_test.dart`. La mediana stampata deve essere al massimo **25 ms**, altrimenti la versione non va in produzione. Mediana misurata: ______ ms (versione ______).
- [ ] Velocità del catalogo dei vini sul telefono (u3-wine-catalog, NFR1.1 e NFR1.2), nello stesso comando: `suggestWines` con 500 vini al massimo **25 ms** e `matchLabel` (era `matchLabelText`, label-recognition) su 2000 caratteri al massimo **50 ms**. Mediane misurate: `suggestWines` ______ ms, `matchLabel` ______ ms.

## 1-bis. Catalogo dei vini e Open Food Facts (u3-wine-catalog, BR5.3, NFR8.2)

- [ ] `OFF_CONTACT` presente nel segreto di produzione `FIREBASE_PROD_DEFINES_JSON_B64` dell'ambiente `play-internal` (`docs/firebase-setup.md` §9), **oppure** scelta consapevole di pubblicare con Open Food Facts spento (solo catalogo interno). Scelta: ______.
- [ ] Informativa privacy aggiornata: il testo cercato, le parole lette sull'etichetta e i codici a barre vengono inviati a Open Food Facts, insieme all'indirizzo IP del telefono. Nessun altro dato (email, uid, posizione, foto, vini della cantina).
- [ ] Scheda "Sicurezza dei dati" di Google Play aggiornata con lo stesso invio a Open Food Facts (tabella del §2).
- [ ] Voce fissa di attribuzione a Open Food Facts nella schermata delle informazioni, con il testo `offAttribution` e il link alla licenza ODbL (BR5.2).
- [ ] **Foto dell'etichetta** (u6-label-recognition, NFR4.1, NFR8.3): con la rete, il codice a barre letto dalla foto e alcune parole del testo letto vanno a Open Food Facts come per i suggerimenti, insieme all'indirizzo IP del telefono. Mai il testo intero, mai l'immagine. Informativa e scheda "Sicurezza dei dati" lo dicono.

## 1-ter. Cruscotto (u5-dashboard, NFR2.1, NFR2.2, NFR2.4)

Sul telefono, con la build del canale Test interno:

- [ ] Dopo l'accesso compare il **Cruscotto**, con la lista "Da bere presto", i tre grafici (stato, anno del picco, tipologia o regione) e il selettore Tipologia/Regione.
- [ ] Un tocco su una barra dello stato porta alla scheda **Cantina**. Lo stesso fa un tocco su una riga di "Da bere presto".
- [ ] Il selettore Tipologia/Regione ricorda la scelta dopo la chiusura dell'app.

Misure, una volta per versione, su entrambi i telefoni. Servono gli emulatori Firebase avviati su questo computer, mai il progetto di produzione:

- [ ] Avvio a freddo fino al Cruscotto, con 500 vini e senza rete (NFR2.1): `tool/perf_cold_start.sh 2000` sul telefono di riferimento, `tool/perf_cold_start.sh 1000` sul telefono del proprietario. Mediana di 5 avvii: telefono di riferimento ______ ms (soglia **2000 ms**), telefono del proprietario ______ ms (soglia **1000 ms**).
- [ ] Scorrimento e calcolo (NFR2.4, NFR2.2), dopo `tool/perf_cold_start.sh`, che lascia sul telefono i 500 vini:

  ```
  flutter drive --profile --driver=test_driver/perf_driver.dart --target=integration_test_perf/dashboard_perf_test.dart --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true --dart-define=PERF=true --dart-define=EMULATOR_HOST=127.0.0.1
  ```

  Prima di lanciarlo, riaprire le porte con `adb reverse tcp:9099 tcp:9099` e `adb reverse tcp:8080 tcp:8080`. I valori da annotare:
  - 99° percentile dei frame sotto il periodo dello schermo (8,3 ms a 120 Hz, 16,7 ms a 60 Hz): costruzione ______ ms, disegno ______ ms;
  - mediana di `compute` su 500 vini al massimo **25 ms**: ______ ms.
- [ ] Se una misura supera la soglia, la versione non va in produzione finché non rientra, oppure il proprietario accetta lo scostamento per iscritto qui: ______.

## 1-quater. Condivisione (u7-sharing, NFR2.1–NFR2.3, NFR4.7)

Prima della prova, le regole e l'indice della build devono essere già pubblicati (§3): senza l'indice la ricerca degli inviti fallisce e nessuna cantina condivisa compare.

Prova con **due telefoni** e due account Google, entrambi con la build del canale Test interno. Il telefono A è il proprietario, il telefono B la persona invitata.

- [ ] **Invito e messaggio di Android:** su A, Cantina → menu → "Persone" → email di B, "Solo lettura" → "Invita". Si apre la condivisione di Android con il messaggio pronto: chi invita, nome della cantina, link a Google Play e indirizzo Google da usare. B compare come "invitata" e il contatore mostra 1/2.
- [ ] **Comparsa della cantina:** su B, accesso con l'account invitato. Compare l'avviso "… ti ha condiviso la sua cantina" e il selettore in alto. Tempo dall'accesso alla comparsa (3 prove, soglia **5 s**): ______ s, ______ s, ______ s.
- [ ] **Cambio di permesso:** su A, "Persone" → permesso di B → "Può modificare". Su B, nella cantina condivisa, compare "Aggiungi" senza riavviare. Riportando a "Solo lettura" il comando sparisce.
- [ ] **Revoca:** su A, "Revoca" e conferma scrivendo il nome di B. Su B la cantina sparisce dal selettore, si torna alla cantina personale e compare "Non hai più accesso alla cantina di …". Tempo (3 prove, soglia **5 s**): ______ s, ______ s, ______ s.
- [ ] **Uscita volontaria:** reinvitare B; su B, "Persone" → "Esci da questa cantina" → "Esci". Si torna alla cantina personale **senza** l'avviso di accesso perso; su A, B compare in "Accessi chiusi" come "uscita".
- [ ] **Limite di 2 persone:** con 2 persone invitate o attive, il terzo invito è rifiutato con "Hai raggiunto il limite di 2 persone" e "Invita" è disattivato.
- [ ] **Tempi delle operazioni** (NFR2.1), 5 prove per operazione, dal tocco all'esito, con rete. Mediana (soglia **3 s**; massimo nel codice 10 s): invito ______ s, cambio di permesso ______ s, revoca ______ s, uscita ______ s.
- [ ] Se una misura supera la soglia, la versione non va in produzione finché non rientra, oppure il proprietario accetta lo scostamento per iscritto qui: ______.

## 1-quinquies. Cantina (u4-cellar, NFR1.1, NFR1.3, NFR2.2, NFR2.3, NFR6.6)

Prima della prova, le regole e l'indice dello Storico devono essere già pubblicati e "Abilitati" (§3): senza l'indice lo Storico mostra "Impossibile caricare lo Storico" con "Riprova", il resto funziona.

Sul telefono di riferimento, con la build del canale Test interno:

- [ ] **Inserimento dai suggerimenti** (NFR1.1): dal tocco su "Aggiungi" al salvataggio di un vino scelto tra le proposte, 10 prove. Mediana (soglia **< 30 s**): ______ s.
- [ ] **Salvataggio fino all'elenco** (NFR1.3): dal tocco su "Salva" alla riga nella Cantina (soglia **≤ 300 ms**): ______ ms.
- [ ] **Dettaglio** (NFR2.2): dal tocco su una riga al dettaglio con la finestra (soglia **≤ 500 ms**): ______ ms; per un vino finito, aperto dallo Storico: ______ ms.
- [ ] **Scorrimento** (NFR2.3) con 500 vini e 2.000 bevute, dati di prova negli emulatori di questo computer, mai il progetto di produzione:

  ```
  flutter drive --profile --driver=test_driver/perf_driver.dart --target=integration_test_perf/cellar_perf_test.dart --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true --dart-define=PERF=true --dart-define=EMULATOR_HOST=127.0.0.1
  ```

  Dopo `adb reverse tcp:9099 tcp:9099` e `adb reverse tcp:8080 tcp:8080`. 99° percentile sotto il periodo dello schermo: Cantina costruzione ______ ms, disegno ______ ms; Storico costruzione ______ ms, disegno ______ ms.
- [ ] **Doppione:** aggiungi di nuovo un vino già in cantina: compare "Già in cantina" con la quantità attuale; "Aggiungi N bottiglie" aggiorna la stessa voce. Con due voci uguali (una aggiunta senza rete), il dettaglio mostra "Possibile doppione" e "Unisci" (solo il proprietario).
- [ ] **Bevuta:** "Bevuta" con "Annulla" (la bottiglia torna) e con "Aggiungi voto e note" (voto, note, data, "Com'era?"). La bevuta compare nello **Storico**; da lì "Aggiungi di nuovo" riapre l'inserimento compilato.
- [ ] **Senza rete:** in modalità aereo bevi l'ultima bottiglia di un vino: il vino esce dalla Cantina e la fascia "Offline - sincronizzazione in attesa" resta finché, tornata la rete, la bevuta arriva su Firestore.
- [ ] **Riscontro:** segna una bevuta come "Al punto giusto" dopo la fine della finestra: la finestra si allunga, la fonte diventa "stima corretta dalle tue bevute" e l'avviso "Stima indicativa…" resta visibile.
- [ ] Se una misura supera la soglia, la versione non va in produzione finché non rientra, oppure il proprietario accetta lo scostamento per iscritto qui: ______.

## 1-sexies. Foto dell'etichetta (u6-label-recognition, NFR1.1–NFR1.3, NFR2.1, NFR2.3, NFR4.4, NFR8.1)

Sul telefono di riferimento, con la build del canale Test interno:

- [ ] **Dalla foto alla proposta** (NFR1.1): 10 prove con la rete, dal ritorno dalla fotocamera alla proposta (o al messaggio, o al modulo). Mediana (soglia **≤ 3 s**): ______ s. 10 prove in modalità aereo (soglia **≤ 2 s**): ______ s.
- [ ] **Lettura sul telefono** (NFR1.2, soglia **≤ 1,5 s** per foto): ______ s.
- [ ] **Aggiunta con la foto** (NFR1.3): da "Aggiungi" a "Conferma" su vini riconosciuti, 10 prove. Mediana (soglia **< 30 s**): ______ s.
- [ ] **Riconoscimento** (NFR2.1): 20 etichette reali di vini italiani (fronte). Con la rete nome giusto in almeno **14 su 20**: ______ / 20. Senza rete denominazione giusta in almeno **14 su 20** (tra quelle con una denominazione riconosciuta): ______ / ______. Elenco delle bottiglie: ______.
- [ ] **Importa una foto** dalla galleria e **Condividi → Vinoozy** da un'altra app, anche ad app chiusa (si apre l'accesso se serve, poi la lettura); con più foto condivise compare "Ho usato solo la prima foto".
- [ ] **Casi difficili:** etichetta illeggibile ("Non riesco a leggere l'etichetta"), solo codice a barre senza risultato, fotocamera chiusa senza scatto (si torna ad "Aggiungi" senza messaggi).
- [ ] **Nessun file rimasto** (NFR8.1): dopo una lettura, `adb shell run-as com.vinoozy.app ls cache/label` è vuoto (o la cartella non esiste).
- [ ] **Dimensione dell'app** (NFR2.3): `bundletool get-size total` sull'AAB firmato, confrontato con la versione precedente (soglia **+15 MB**). Prima: ______ byte; dopo: ______ byte. In CI lo controlla `tool/check_app_size.sh` con il valore di `tool/app_size_baseline.txt`.
- [ ] **Limite noto:** sui telefoni con Android più vecchio della versione 9 le foto HEIC non si leggono ("Non riesco a leggere l'etichetta"); le fotocamere di quei telefoni salvano in JPEG.
- [ ] **Prima build iPhone** (NFR4.3, quando si aggiungerà la cartella `ios/`): `NSCameraUsageDescription` e `NSPhotoLibraryUsageDescription` presenti in `Info.plist` e tradotti in it, en e pt-BR; si aggiunge il test di script che lo verifica.

## 1-septies. Account (u8-account, BR1.1–BR1.13, NFR1.1–NFR1.3, NFR8)

Sul telefono di riferimento, con la build del canale Test interno e un **account di prova** (mai il proprio):

- [ ] **Presentazione al primo avvio** (BR1.1): dopo aver cancellato i dati dell'app compaiono le tre pagine con "Salta" e, all'ultima, "Inizia"; entrambe portano all'accesso. Dopo un'uscita la presentazione non torna. Con un aggiornamento dell'app (sessione già salvata) non compare.
- [ ] **Profilo** (BR1.2): Cantina → menu → "Profilo" mostra foto (o iniziale), nome ed email; il link all'informativa si copia. Tempo di apertura (soglia **≤ 300 ms**, NFR1.1): ______ ms.
- [ ] **Uscita senza modifiche in coda** (BR1.3): "Esci" → "Vuoi uscire?" → "Esci" riporta all'accesso.
- [ ] **Uscita con modifiche in coda** (BR1.4): in modalità aereo aggiungi un vino, poi "Esci": compare "Hai 1 modifica non ancora salvata…". "Resta e sincronizza" con la rete tornata mostra "Tutto salvato". Ripeti con "Esci comunque" e rientra con lo stesso account: il vino arriva nel cloud.
- [ ] **Cancellazione completa** (BR1.5–BR1.7): con l'account di prova che possiede una cantina condivisa con un secondo account e ha un invito in una cantina altrui. Senza rete compare "Collegati a Internet per cancellare l'account". Con la rete: elenco, parola di conferma della lingua del telefono, accesso di nuovo con Google, avanzamento, "Account cancellato". Nella console Firestore non restano `users/{uid}`, la cantina, i suoi vini, bevute e inviti, né l'invito nella cantina altrui; in Authentication l'utente non c'è più.
- [ ] **Tempo della cancellazione nel caso peggiore** (NFR1.2), una volta per versione che tocca la cancellazione: 500 vini presenti, 1.000 finiti, 2.000 bevute (dati di prova). Soglia **≤ 60 s**: ______ s.
- [ ] **Ripresa** (BR1.8): avvia una cancellazione e chiudi l'app a metà (dal multitasking). Al riavvio compare solo l'avanzamento con "Continua"; dopo l'accesso con Google la cancellazione finisce.
- [ ] **Pagina web** (BR1.11): da un browser, `https://brunobottazzini.github.io/Vinoozy/account-deletion/` (e `en/`, `pt-BR/`): accesso con Google, parola di conferma, cancellazione completa di un secondo account di prova; nella console del browser nessun errore di Content Security Policy.
- [ ] **Caso limite dichiarato** (BR1.8): se l'app viene reinstallata dopo la cancellazione del profilo ma prima della cancellazione dell'utente di Authentication, l'account torna come nuovo con profilo e cantina vuoti; i dati sono già cancellati e basta ripetere "Cancella account" (oppure la procedura via email qui sotto).

### Procedura per le richieste di cancellazione via email (BR1.12, NFR8.6)

Solo per chi non può più accedere al proprio account Google; tutti gli altri usano l'app o la pagina web. Indirizzo pubblicato sulla pagina: **bottazzinibruno@gmail.com**.

1. Annota la data della richiesta nel registro qui sotto.
2. Rispondi **all'indirizzo dell'account Vinoozy indicato** (non a un altro indirizzo da cui è arrivata la richiesta), chiedendo conferma: "Rispondi Sì per confermare la cancellazione del tuo account Vinoozy". Non serve controllare firme o intestazioni.
3. Solo dopo il "Sì" arrivato da quell'indirizzo, cancella dalla console Firebase, **entro 30 giorni dalla richiesta**:
   - in Authentication trova l'utente per email e annota il suo uid;
   - le sotto-raccolte `wines`, `drinkingRecords` e `members` di `cellars/{uid}`;
   - il documento `cellars/{uid}`;
   - i documenti `members` dell'utente nelle cantine altrui: Firestore → query sul gruppo di collezioni `members` con `inviteeEmail` uguale all'email in minuscolo; cancella ciascun documento (le bevute registrate lì restano, con il solo uid tecnico);
   - `users/{uid}`;
   - l'utente in Authentication.
4. Rispondi che la cancellazione è fatta e annota la data.
5. Senza risposta entro **14 giorni**, chiudi la richiesta senza cancellare e annotalo.

Registro (data richiesta · conferma · data cancellazione o chiusura): ______.

## 1-octies. Nuova UX (ux-redesign, FR1–FR3, NFR1, NFR4)

**Prima di installare la build:** le regole nuove (campo `country`) devono essere già pubblicate su `vinoozy-d6f45` con `firebase-deploy.yml`, e solo con il via del proprietario (R-01, NFR4). Con le regole vecchie ogni vino salvato con un paese viene rifiutato dal server e compare l'avviso "non salvato". Regole pubblicate il: ______ (versione ______).

Sul telefono del proprietario, con la build del canale Test interno, in tema chiaro e scuro:

- [ ] **Bandiere:** nel modulo "Aggiungi" la griglia mostra le 21 bandiere a colori (non le sigle) e "Altro paese…". "Altro paese…" apre tutti i paesi; cercando "marian" compaiono le Isole Marianne Settentrionali con la loro bandiera. Paesi senza bandiera visibile (sigla in un riquadro): ______.
- [ ] **Regioni:** scelta l'Italia compaiono le 20 regioni; scelta l'Argentina, Mendoza e le altre; "Altra regione" accetta testo libero.
- [ ] **Compilazione automatica:** scrivendo "Barolo" e scegliendo la proposta, Italia e Piemonte sono già scelti e modificabili.
- [ ] **Scheda della Cantina:** bandiera, fascia del colore del tipo, nome del tipo, stato e "Ho bevuto" ben leggibili; il pulsante "Aggiungi" resta visibile anche con il messaggio "Bevuta segnata" aperto.
- [ ] **Pannello "Ho bevuto":** il tocco non registra nulla; "Annulla" e il gesto indietro chiudono senza effetto; "Sì, l'ho bevuta" con 4 stelle registra la bevuta con il voto (nello Storico compare "Voto 4 su 5"). Con TalkBack le stelle sono lette come "4 stelle su 5".
- [ ] **Dettaglio:** "Consigliato fino al …" e "Al meglio dal … al …" corrispondono alla finestra; la barra ha il segno di oggi; l'avviso "⚠︎ Indicativo…" è sempre visibile; "Togli una bottiglia senza bevuta" chiede conferma.
- [ ] **Titoli con le grazie:** i titoli delle schermate e il numero grande del Cruscotto usano il serif di sistema (Noto Serif).
- [ ] **Vini già salvati:** un vino di prima con regione italiana mostra la bandiera italiana; modificato e salvato, nella Console Firestore ha `country: "IT"`.

## 1-nonies. Riconoscimento delle etichette migliorato (label-recognition, FR1–FR5, NFR1–NFR3, NFR5)

### Base dei vini sul telefono (FR2.1, FR2.2, NFR1.2, NFR5.8)

Oggi `assets/wine_db/` contiene la base costruita in Build and Test (2026-11-08) dall'**export reale** di Open Food Facts del 2026-11-07: 15.616 vini, `wines.jsonl.gz` di 339.982 byte (1.254.545 byte non compressi), `source` uguale a `Open Food Facts`. Prima di ogni rilascio successivo va ricostruita da un export recente (al massimo 180 giorni).

- [ ] **Scarica a mano** l'export CSV completo di Open Food Facts, dal file pubblicato per i download completi (mai l'API pagina per pagina; al massimo una volta per rilascio; nessun job di CI lo scarica). Data dell'export: ______.
- [ ] **Costruisci la base** dalla radice del progetto: `dart run tool/build_wine_db.dart --input <export.csv.gz> --output assets/wine_db/ --export-date <AAAA-MM-GG>`. Lo strumento esce con errore e lascia la base precedente se ci sono meno di 5000 vini, codici doppi, un export più vecchio di 180 giorni, un file compresso oltre **3 MB** o dati non compressi oltre **30 MB** (limite deciso dal proprietario).
- [ ] **Controllo automatico**: `tool/check_wine_db_release.sh` deve dare OK. Lo stesso controllo gira in `promote.yml` sul manifesto della build da promuovere e blocca la produzione se ci sono meno di 5000 vini o se `source` è `sample` (l'estratto di prova, costruito con `--allow-small-sample`).
- [ ] **Controlla il manifesto** `assets/wine_db/manifest.json`: `source` uguale a `Open Food Facts`, data dell'export ______, numero di vini ______ (atteso: qualche migliaio, l'export di novembre 2026 ha circa 17.000 prodotti nella categoria vini prima dei filtri). Aggiorna la riga "Contenuto attuale" di `assets/wine_db/README.md`.
- [ ] **Informazioni** (Cantina → menu → "Informazioni"): numero di vini e data dell'export corrispondono al manifesto (NFR6.7).
- [ ] **Dimensione** (NFR1.1): `tool/check_app_size.sh` sul nuovo AAB rispetto alla versione `0d99791` (soglia **+15 MB**; oltre 40 MB si chiede al proprietario). Prima: ______ byte; dopo: ______ byte.

### Prove sul telefono (OnePlus CPH2581, build release, mediana di 5 prove)

- [ ] **Fronte e retro** (FR1.1, FR1.2): dopo la foto del fronte compare "Ora il retro" con "Scatta il retro", "Scegli dalla galleria" e "Salta", anche con "Condividi → Vinoozy". Un vino con il codice a barre solo sul retro viene proposto con certezza.
- [ ] **Candidati e "Non è questo"** (FR2.4, FR3.2, FR3.3): un'etichetta simile a più vini mostra la lista; un candidato apre il modulo compilato; "indietro" torna alla lista.
- [ ] **Cerca online** (FR3.1–FR3.4): in modalità aereo compare "Senza rete: cerco solo nella base sul telefono"; con la rete compaiono anche i risultati "online" con l'attribuzione.
- [ ] **Google Lens** (FR4, BR5.2): "Apri in Google Lens" chiede conferma a ogni tocco; dopo "Apri Google Lens" l'**app Google apre Lens con la foto del fronte**. Esito: ______. Senza l'app Google (o disattivata) si apre il menu "Condividi". Tornando in Vinoozy l'esito è ancora aperto.
- [ ] **Nessun file rimasto** (FR1.3, NFR3.4): dopo l'uscita dall'esito, e dopo aver chiuso Vinoozy dal multitasking mentre si è in Google Lens e averlo riaperto, `adb shell run-as com.vinoozy.app ls cache/label` è vuoto.
- [ ] **Velocità** (NFR2.1–NFR2.3, NFR2.5), con la base reale: ricerca per codice ______ ms (soglia **50 ms**); confronto del testo ______ ms (soglia **300 ms**); apertura della base, dall'evento `wine_db_opened` in console, ______ ms (soglia **1,5 s**); memoria in più con `adb shell dumpsys meminfo com.vinoozy.app` ______ MB (soglia **40 MB**). Le misure si scrivono anche in `construction/build-and-test/` dell'intent.
- [ ] **Senza rete nessun falso guasto** (FR5): 10 letture in modalità aereo, poi in Crashlytics nessun `off_suspended` nuovo per questo telefono.

### Pubblicazione della base e del repository (NFR3.10, NFR5.7)

- [ ] **Prima di rendere pubblico il repository** (Q1 = A, azione del proprietario), tutte e quattro:
  - [ ] (a) il job `secrets` della CI (gitleaks su tutta la storia, `fetch-depth: 0`) è verde sull'ultimo commit di `main`;
  - [ ] (b) `git log --all -- config/firebase_prod.json android/app/google-services.json` non restituisce nulla (questi file non sono mai entrati in un commit). Esito: ______;
  - [ ] (c) il contatto `offContact` è un indirizzo che il proprietario accetta di rendere pubblico (sta già nel User-Agent dell'APK);
  - [ ] (d) `firebase-config.js` contiene solo i segnaposto TODO.
- [ ] **Repository pubblico prima della pubblicazione sullo store** (NFR5.7): la base derivata (`assets/wine_db/`, licenza ODbL) e lo strumento che la genera sono disponibili a tutti, come dice la schermata Informazioni.

## 1-decies. Modulo compilato dall'etichetta e finestre per tutto il mondo (label-autofill-windows, FR1–FR6, NFR3.6, NFR5.6, NFR5.7, BR6)

### Tabelle da generare prima della pubblicazione (BR3.6, BR6.3, NFR5.6)

Oggi la tabella generata delle denominazioni (`packages/estimation/lib/src/generated/appellations.g.dart`) è costruita in Build and Test (2026-11-08) dall'**export reale** di eAmbrosia del 2026-11-08 e dai file non UE verificati: `"source": "eAmbrosia and official national registers"`, 2424 denominazioni in tutto (724 dedicate, 1700 generate). Anche la base dei vini è quella dell'export reale (§1-nonies). Prima di ogni rilascio successivo si rigenerano entrambe da export recenti.

- [ ] **Scarica a mano l'export di eAmbrosia** (registro pubblico dell'UE, DOP e IGP dei vini) in `.cache/eambrosia/`, che non entra nel repository: il JSON dell'API pubblica, `curl -o .cache/eambrosia/eambrosia-<AAAA-MM-GG>.json https://webgate.ec.europa.eu/eambrosia-api/api/geographical-indications` (lo strumento legge anche un export CSV). Una volta per rilascio, mai da un job di CI. Data dell'export: ______.
- [ ] **Controlla i file non UE** di `tool/data/appellations/` (AVA, GI australiane e neozelandesi, Wine of Origin, DO sudamericane, AOC svizzere) con le liste ufficiali indicate nell'intestazione di ciascun file; aggiorna la data nell'intestazione.
- [ ] **Genera la tabella** dalla radice del progetto: `dart run tool/build_appellations.dart --eambrosia .cache/eambrosia/<export>.json --export-date <AAAA-MM-GG>`. Lo strumento esce con errore e lascia la tabella precedente se le denominazioni sono meno di **1500**, se ci sono chiavi doppie o se un modello non esiste.
- [ ] **Controllo automatico**: `tool/check_appellations_release.sh` deve dare OK. Lo stesso controllo gira in `promote.yml` e blocca la produzione se `source` è `sample`, se le denominazioni sono meno di 1500 o se il manifesto non descrive il file `.g.dart` della build (fonte in `generatedAppellationsSource` e numero di righe generate). Numero di denominazioni: ______ (dedicate 724, generate ______).
- [ ] **Base dei vini di Open Food Facts**: scarica e genera la base come al §1-nonies (`dart run tool/build_wine_db.dart`, poi `tool/check_wine_db_release.sh`).
- [ ] Dopo la generazione: `(cd packages/estimation && dart test)` e `flutter test` verdi, con la copertura del pacchetto **≥ 90%** (file generato compreso) e del progetto **≥ 80%**, poi commit della tabella e del manifesto.
- [ ] **Informazioni** (Cantina → menu → "Informazioni"): la voce delle denominazioni mostra la fonte e la data dell'export, senza la nota dell'estratto di prova (NFR5.7).

### Regole prima della build (BR4.3, BR4.6)

- [ ] **Prima le regole**: le regole di questa versione accettano `level`, `windowOverride` e i campi nuovi della finestra (`denominationKey`, `tablesVersion`, base `grape`, qualifiche nuove). Pubblicale con `firebase-deploy.yml` (§3) **prima** di caricare la build sul Test interno: con le regole vecchie il salvataggio di un vino con un livello o una correzione viene rifiutato. `promote.yml` controlla la funzione `level-override` in `RULES_FEATURES`.

### Prove sul telefono (FR1, FR2, FR4, FR5)

- [ ] **Da Google Lens** (FR2.6, BR2.5): "Aggiungi" → "Da Google Lens" apre prima il modulo vuoto e subito dopo Lens. Esito con l'app Lens: ______. Con Lens solo dentro l'app Google: ______. Senza nessuna delle due (app Google disattivata) compaiono i tre passi e "Ho capito".
- [ ] **Incolla automatico** (FR2.7, BR2.6, Android 8.0 o più recente): in Lens seleziona il testo dell'etichetta, "Copia", torna in Vinoozy entro 5 minuti. Il modulo si compila da solo, TalkBack legge "Modulo compilato dal testo di Lens" e Android 12+ mostra il suo avviso di lettura degli appunti **una sola volta**. Un secondo ritorno senza copiare nulla non incolla di nuovo. Esito: ______.
- [ ] **Condividi → Vinoozy** dal testo di Lens (FR2.1, BR2.4): ad app chiusa si apre il modulo compilato; con un modulo già modificato compare "Usare il testo per i campi vuoti?".
- [ ] **Foto senza vino trovato** (FR1.2, BR2.1): un'etichetta non in catalogo apre il modulo compilato con i segni "✦ dal testo"; "Pulisci" svuota, "indietro" torna a "Non trovato".
- [ ] **Livello e correzione** (FR4, FR5): un "Riserva" propone "Da invecchiamento"; nel dettaglio "Correggi" e poi "Ripristina stima" funzionano anche in modalità aereo e si sincronizzano al ritorno della rete.
- [ ] **Stime dei vini già in cantina** (BR3.9, NFR4.8a): dopo l'aggiornamento, i vini salvati con la versione precedente hanno la stima ricalcolata una volta (in console Firestore `window.tablesVersion` = 2), con livello e correzione rispettati.
- [ ] **Risposta entro 2 secondi** (FR2.8, NFR4.17, BR7.23, BR7.24): app appena aperta (base offline ancora chiusa), "Incolla da Lens" con il testo di un'etichetta copiato da Lens. Il pulsante mostra subito "Leggo il testo…" e un secondo tocco non fa nulla; entro 2 secondi compare il modulo compilato, la proposta del vino o la prima domanda della guida. Ripeti 5 volte, anche con la rete mobile lenta. Tempi: ______.
- [ ] **Conferma guidata** (FR7, NFR4.20, NFR4.22): con il testo di Cascina Castlet ("CASCINA CASTLET" / "Barbera d'Asti Superiore", senza annata) la guida chiede "Domanda 1 di 3": prova "Sì", "No, un'altra", "Modifica", "Salta", la composizione toccando le parole e la ruota dell'annata (anche il tocco sull'anno al centro). Poi: "Indietro" chiude la scheda prima del modulo; "Conferma guidata" la riapre; rotazione e ritorno dal secondo piano riprendono alla stessa domanda; TalkBack legge "Domanda N di T: …" e le parole come pulsanti. Nessun salto di fotogrammi visibile tra una domanda e l'altra. Esito: ______.

## 1-undecies. Profili di stile e classificazione automatica (wine-style-profiles, FR1–FR4, NFR2–NFR6, BR10.3)

### Studio, mappa e base da rigenerare (D1, D9, FR2.5)

- [ ] **Studio come base di dati**: se lo studio Excel cambia, riconvertilo una volta con `python3 -I tool/convert_study.py <studio.xlsx>` (scrive `tool/data/study/study_db.json`), poi rigenera la mappa con `dart run tool/build_profile_map.dart`. `test/tool/build_profile_map_test.dart` verifica che la tabella generata coincida con la fixture del Functional Design.
- [ ] **Base offline classificata** (formato 2): `dart run tool/build_wine_db.dart --input .cache/off/<export>.csv.gz --output assets/wine_db/ --export-date <data>`; il manifest registra `classifiedTypeShare` (obiettivo 90%, accettato dal proprietario a partire dall'84%). `tool/check_wine_db_release.sh` deve passare.

### Regole prima della build (BR10.3)

- [ ] **Prima le regole**: le regole di questa versione accettano `style`, `typeSource`, `levelSource`, `styleSource`, `agingStartMonth`, `migrationVersion` e le finestre in mesi. Ordine: test delle regole nell'emulatore → **OK del proprietario** → pubblicazione con `firebase-deploy.yml` (§3) → build sul Test interno. Con le regole vecchie la migrazione una tantum viene rifiutata (3 tentativi, poi attende) e i nuovi vini non si salvano. `promote.yml` controlla la funzione `style-profiles` in `RULES_FEATURES`.
- [ ] **Limite di 1000 espressioni**: le regole di un vino sono vicine al limite di Firestore (l'app scrive in due update la modifica di un vino con riscontro); dopo ogni modifica di `firestore.rules` esegui i test "expression budget" di `test/rules/style_profiles.rules.test.mjs`.

### Prove sul telefono

- [ ] Uno Champagne scritto a mano propone Tipologia e Stile "✦ suggerito"; con "Da evoluzione" e la sboccatura di marzo 2024 il dettaglio mostra "marzo 2027". Esito: ______.
- [ ] Dopo l'aggiornamento i vini già in cantina hanno lo stile "✦ suggerito", la Tipologia e il Livello salvati restano, un Barolo "Buono" resta 8/15/30. Esito: ______.
- [ ] Un vino "Stile da confermare": l'avviso compare nel dettaglio e nel cruscotto ("Da confermare"); scelto lo stile, sparisce. Esito: ______.

## 2. Data Safety in Play Console (NFR8.1–NFR8.3)

Da aggiornare se cambiano i dati raccolti. Per U1 la dichiarazione è:

| Dato | Raccolto | Condiviso con terzi | Scopo |
|------|----------|---------------------|-------|
| Email e nome dell'account Google | Sì | No | Account (accesso e profilo `users/{uid}`) |
| Cantina e vini | Sì | No | Funzionalità dell'app (`cellars/{uid}` e `wines`) |
| Rapporti di crash (Crashlytics, anonimi) | Sì | No | Analisi dei crash. Nessun identificatore utente, nessuna email, nessun nome di vino o percorso di documento |
| Testo cercato, parole dell'etichetta e codici a barre (solo con Open Food Facts acceso) | No, non li conserviamo noi | Sì, con Open Food Facts, insieme all'indirizzo IP | Funzionalità dell'app: suggerimenti di vini e riconoscimento dell'etichetta |
| Indirizzi email di altre persone forniti dall'utente (u7-sharing, NFR8.4) | Sì | No | Funzionalità dell'app: condivisione della cantina (`cellars/{id}/members`). Cancellabili: "Elimina definitivamente" del proprietario, e la persona invitata può eliminare il proprio invito chiuso |
| Bevute: data, voto, note e "Com'era?" (u4-cellar, NFR8.1, NFR8.3) | Sì | No | Funzionalità dell'app: Storico e riscontro sulla stima (`cellars/{id}/drinkingRecords`). Visibili solo a chi vede la cantina; mai nei rapporti di crash |
| Cronologia acquisti: abbonamento Plus, token d'acquisto di Google Play e stato (freemium-plus, FR3.3, NFR6) | Sì | No (il pagamento lo gestisce Google Play) | Funzionalità dell'app: attivare Plus (`entitlements/{uid}`; token e stato in `purchases/{hash}`, solo lato server). Dopo la cancellazione dell'account resta solo il record d'acquisto senza uid |
| Interazioni con l'app: contatori mensili di letture, scritture e byte, identificativo casuale dell'installazione (freemium-plus, FR6.3, NFR6) | Sì | No | Funzionalità dell'app e prevenzione degli abusi: misura del costo del piano gratuito (`usage/{uid}`). Solo numeri, dettagli cancellati dopo 90 giorni e con l'account |
| ID pubblicità, IP e dati tecnici degli annunci (freemium-plus, FR7; **solo con `adsEnabled` acceso**) | Sì, dall'SDK di Google AdMob | Sì, con Google AdMob | Pubblicità. Registro dei tentativi in `adSlots/{uid}` (cancellato dopo 90 giorni e con l'account). Da dichiarare **prima** di accendere gli annunci |

- [ ] **Note e voti delle bevute** (u4-cellar, NFR8.3): rientrano nella voce "Cantina e vini" già dichiarata, o nella riga delle bevute sopra. Verificato: ______.
- [ ] **Foto delle etichette** (u6-label-recognition, NFR8.3): **non** si dichiarano come raccolte. Si leggono solo sul telefono con ML Kit, non si conservano e non vanno nel cloud; la copia di lavoro sta in `cache/label/` e si cancella appena la lettura finisce (al più 10 minuti, e al successivo avvio dopo una chiusura improvvisa). Il codice a barre e le parole verso Open Food Facts sono nella riga di Open Food Facts sopra.
- [ ] **ML Kit** (NFR8.3): ML Kit può inviare a Google dati diagnostici e di utilizzo anonimi. Verificata la guida di Google sulla divulgazione dei dati di ML Kit per la scheda "Sicurezza dei dati", e dichiarato di conseguenza. Pagina controllata e data: ______.
- [ ] **Informativa privacy** (u6): le foto delle etichette si leggono sul telefono e non si conservano; con la rete il codice a barre e alcune parole lette servono a cercare il vino su Open Food Facts.
- [ ] **Foto condivisa con Google Lens** (label-recognition, NFR3.1, NFR3.6): solo quando l'utente tocca "Apri in Google Lens" **e** conferma, la foto del fronte (copia preparata, senza metadati EXIF) passa all'app Google sul telefono, o all'app scelta nel menu "Condividi", che può conservarne una copia secondo le sue regole. Vinoozy non riceve i risultati. Informativa privacy e scheda "Sicurezza dei dati" aggiornate con questa condivisione su richiesta dell'utente (azione del proprietario). Verificato: ______.
- [ ] **Cerca online** (label-recognition, NFR3.8): le parole del campo "Cerca online" (o il codice a barre) vanno a Open Food Facts come per i suggerimenti: rientrano nella riga di Open Food Facts sopra.
- [ ] **Base dei vini sul telefono** (label-recognition, NFR3.7, NFR3.9): contiene solo dati pubblici dei prodotti, nessun dato personale; l'evento `wine_db_unavailable` rientra nei "Rapporti di crash (Crashlytics, anonimi)" già dichiarati, nessun tipo di dato nuovo.
- [ ] **Cancellazione dell'account** (u8-account, NFR8.4): nella scheda "Sicurezza dei dati" la richiesta di cancellazione è disponibile nell'app e all'URL `https://brunobottazzini.github.io/Vinoozy/account-deletion/`; i dati si cancellano subito dall'app o dalla pagina, entro 30 giorni con la richiesta via email.
- [ ] **Informativa privacy** (u8-account, NFR8.1, NFR8.4): dichiara che, dopo una cancellazione, nelle cantine di altre persone restano le bevute registrate lì (nome del vino e note, parte del loro Storico) con i soli codici tecnici casuali `recordedBy` e `updatedBy`, senza email né nome. Il testo è anche nella sezione "Privacy" della pagina di cancellazione, che è l'indirizzo predefinito del link "Informativa sulla privacy" del profilo (`PRIVACY_POLICY_URL` lo cambia).

L'account (u8-account) conserva sul telefono, in `shared_preferences`, `onboarding.seen` (la presentazione è stata vista) e, solo durante una cancellazione, `account.deletion.<uid>` con il passo raggiunto; quest'ultimo si toglie appena il telefono è pulito.

La Cantina (u4-cellar, NFR6.6) conserva sul telefono, in `shared_preferences`, la chiave `cellar.pending.<uid>`: al più 50 operazioni da completare al ritorno della rete (`reapplyAdjustment`, `purgeRecords`), ognuna con cantina, ID del vino e data, mai nomi o note; scadono dopo 7 giorni.

La condivisione conserva sul telefono, in `shared_preferences`, solo la chiave `sharing.activeCellar.<uid>`, cioè la cantina scelta nel selettore. Si cancella all'uscita dall'account e con il reset dei dati locali (u7 NFR6.4). L'app non legge la rubrica: l'email si scrive a mano e il manifest non chiede `READ_CONTACTS` (test in `test/sharing/permissions_screens_test.dart`).

Il catalogo conserva sul telefono, nel file `catalog_cache.json` della cartella di supporto dell'app (escluso dal backup), solo le risposte di Open Food Facts già trasformate, per 30 giorni, con l'hash SHA-256 dell'uid come proprietario. Il file si cancella all'uscita e al cambio di account.

Dati che restano solo sul telefono, fuori da Firestore, nel valore `ledger.v1` di `shared_preferences`. Servono a non perdere modifiche e si cancellano con il reset dei dati locali (NFR4.10):

| Campo di `ledger.v1` | Contenuto |
|----------------------|-----------|
| `lastUid` | uid dell'ultimo utente che ha usato il telefono |
| `generation` | contatore dei reset |
| `owner.uid`, `owner.email`, `owner.seq` | account a cui appartengono le modifiche in coda e contatore delle scritture |
| `journal[].wineId`, `journal[].cellarId`, `journal[].name`, `journal[].ownerUid`, `journal[].state`, `journal[].notices` | giornale delle creazioni non ancora confermate: ID, cantina, nome del vino, proprietario, stato (`open`/`rejected`) e numero di avvisi mostrati |
| `resetPending` | reset dei dati locali in corso |

Freemium e Plus (intent `261110-freemium-plus`, NFR6; procedura in `docs/plus-setup.md` e `docs/blaze-switch.md`):

- [ ] **Acquisti e misurazione** dichiarati nella scheda "Sicurezza dei dati" con le righe della tabella sopra, prima di pubblicare la versione con Plus. Verificato: ______.
- [ ] **ID pubblicità**: il manifest dichiara `com.google.android.gms.permission.AD_ID` (SDK degli annunci, controllato da `tool/check_release_build.sh`). Dichiarazione "ID pubblicità" in Contenuti dell'app compilata. Verificato: ______.
- [ ] **Annunci**: finché `config/policy.adsEnabled` è `false` l'SDK non parte. Prima di accenderli: voce "Annunci" di Play Console, riga degli annunci nella scheda "Sicurezza dei dati" e messaggio di consenso UMP in AdMob. Verificato: ______.
- [ ] **Informativa privacy e pagina di cancellazione** (it, en, pt-BR) con il paragrafo su Plus, misurazione e annunci e la nota "un abbonamento attivo si annulla in Google Play". Testi da far rivedere a un professionista prima di vendere (studio di monetizzazione, "Diritti del consumatore e privacy"). Verificato: ______.
- [ ] **Cancellazione dell'account**: con le funzioni pubblicate, `onUserDeleted` cancella `entitlements`, `usage` e `adSlots`; del record d'acquisto resta il token senza uid. Provato con un account di test: ______.
- [ ] **Smoke test di Plus** sul test interno, con un account tester di licenza: acquisto, Profilo "Plus", "Ripristina acquisti" su un secondo telefono, annullamento in Google Play e Plus attivo fino alla scadenza. Esito: ______.

- [ ] Backup automatico disattivato (`allowBackup=false` e regole di estrazione dei dati, NFR8.4): verificato nel manifest dell'AAB.
- [ ] Dichiarazione Data Safety coerente con le tabelle sopra.

## 3. Promozione e tag

Ordine obbligatorio quando la versione cambia le regole o gli indici (u7-sharing, NFR4.7):

- [ ] **Prima le regole e l'indice:** esegui `firebase-deploy.yml` con l'hash completo (40 caratteri) del commit di `main` della build (o il tag `v*`; un nome di ramo viene rifiutato) e approva l'ambiente `firebase-prod`.
- [ ] **Indice pronto:** nella console Firebase, Firestore → Indici → Esenzioni a campo singolo, lo stato dell'indice su `members.inviteeEmail` (ambito gruppo di collezioni) è **"Abilitato"**. Di solito bastano pochi minuti.
- [ ] **Indice dello Storico pronto** (u4-cellar, NFR4.8): Firestore → Indici → Compositi, l'indice di `drinkingRecords` (`drankOn` decrescente, `createdAt` decrescente, ambito collezione) è **"Abilitato"**. Passo manuale: nessun workflow lo verifica, perché `firebase deploy` finisce prima che l'indice sia costruito.
- [ ] Prova con due telefoni (§1-quater) e prova della Cantina (§1-quinquies).
- [ ] **Pagina di cancellazione** (u8-account): dopo le regole, esegui `pages.yml` con `mode: publish` e lo stesso `ref`; approva l'ambiente `github-pages-publish`. Il workflow si ferma con "Pubblica prima le regole con firebase-deploy.yml" se le regole pubblicate non sono quelle del commit. Poi la prova dell'account (§1-septies). Ordine: merge, regole, pagina, app.
- [ ] Poi la promozione. `promote.yml` si ferma da solo con "deploy the rules first with firebase-deploy.yml" se `firestore.rules` o `firestore.indexes.json` del commit `build-<versionCode>` sono diversi da quelli dell'ultima pubblicazione riuscita di `firebase-deploy.yml`.

- [ ] Esegui `promote.yml` con `action: promote`, `fraction: 0.2` e il `versionCode` provato; approva l'ambiente `play-production`.
- [ ] Controlla Crashlytics e Android vitals per almeno 24 ore.
- [ ] Esegui `promote.yml` con `action: complete`. Il workflow crea il tag **`v<versionName>+<versionCode>`** sul commit del tag `build-<versionCode>`.

## 4. Se qualcosa va storto (rollback)

- [ ] `promote.yml` con `action: halt` ferma il rilascio graduale alla percentuale a cui è arrivato (la legge dalla traccia di produzione, non la impone), oppure fermalo dalla Console di Play.
- [ ] La correzione esce come nuova versione e ripassa dal Test interno: Google Play non permette di tornare a una build già pubblicata.
- [ ] Regole di sicurezza: `firebase-deploy.yml` con il `ref` del tag `v*` precedente, **solo prima** della promozione dell'app che le usa. Dopo l'inizio della promozione di una versione con le regole di u4-cellar non si torna alle regole vecchie: chi ha già l'app nuova vedrebbe rifiutate le creazioni dei vini (`matchKey`), le modifiche e le cancellazioni delle bevute e il backfill. Si ferma il rilascio graduale e si corregge in avanti, con nuove regole o una nuova versione; i dati restano intatti.
- [ ] Problema di Open Food Facts: spegnilo togliendo `OFF_CONTACT` dal segreto e pubblicando una nuova versione (`docs/firebase-setup.md` §9).
- [ ] Pagina di cancellazione (u8-account): `pages.yml` con `mode: rollback` ripubblica la versione precedente del ramo `gh-pages` (si ferma con "Non c'è una versione precedente da ripristinare" se ce n'è una sola).
- [ ] Obbligo di App Check su Firestore che blocca utenti legittimi: toglilo dalla console (App Check → Firestore → "Non applicare") e torna al solo controllo.

## 5. Controllo mensile

- [ ] Crashlytics, ultimi 7 giorni: eventi `off_suspended` (u3-wine-catalog, NFR6.8). Se sono **più di 20** oppure riguardano **più di 3 utenti**, valuta la fonte o i limiti di Open Food Facts (stato del servizio, cambi di formato, ed eventualmente spegnimento). Guarda anche la chiave `cache_resets` di quegli eventi: se è diversa da 0 su più utenti, indaga sul file di cache.
- [ ] Crashlytics, ultimi 7 giorni: crash con `lib/catalog/` nello stack. Ogni crash si corregge con una nuova versione.
- [ ] Crashlytics, ultimi 7 giorni: errori non fatali `dashboard_invalid_window` (u5-dashboard, NFR8.1); si trovano cercando `dashboard_invalid_window` tra i non fatali. Se sono **più di 10** oppure riguardano **più di 3 utenti**, cerca la causa nelle finestre salvate da U2/U4, che producono `window` incoerenti, e correggi chi le scrive. Nel frattempo il Cruscotto continua a funzionare e conta quei vini come "da stimare".
- [ ] Crashlytics, ultimi 7 giorni: crash con `lib/dashboard/` nello stack. Se riguardano la produzione, ferma il rilascio graduale e correggi con una nuova versione.
- [ ] Console Firebase → Utilizzo: **massimo giornaliero delle letture** di Firestore nel mese (u7-sharing, NFR5.3). Se si avvicina a 35.000, prima misura: tenere aperto per 30 minuti l'ascolto della cantina appena lasciata (`performance-design.md` di U7 §4); se non basta, decidere con il proprietario il pagamento a consumo.
- [ ] Crashlytics, ultimi 7 giorni: errori non fatali `sharing_invite_failed`, `sharing_permission_failed`, `sharing_revoke_failed`, `sharing_leave_failed`, `sharing_activate_failed`, `sharing_delete_failed`, `sharing_revoke_all_failed` (u7-sharing). Se sono **più di 10** oppure riguardano **più di 3 utenti**, controlla la traduzione degli errori e le regole, poi correggi con una nuova versione.
- [ ] Crashlytics, ultimi 7 giorni: errori non fatali della Cantina (u4-cellar, monitoring-design.md §1), cercando `cellar_` tra i non fatali: `cellar_save_failed`, `cellar_drink_failed`, `cellar_undo_failed`, `cellar_record_update_failed`, `cellar_delete_failed`, `cellar_merge_failed`, `cellar_reconcile_failed`, `cellar_history_failed`, più `estimate_refresh_failed`, `match_key_backfill_failed` e `pending_probe_failed`. Se sono **più di 10** oppure riguardano **più di 3 utenti**, indaga e correggi con una nuova versione. `match_key_backfill_failed` ripetuto per lo stesso utente indica un backfill che non finisce: la cantina funziona comunque. Alcuni rifiuti delle regole sono attesi ("Annulla" arrivato dopo 10 minuti, parti di un'eliminazione con una bevuta già cancellata) e non contano come accesso perso.
- [ ] Crashlytics, ultimi 7 giorni: errori non fatali della foto dell'etichetta (u6-label-recognition, monitoring-design.md §1), cercando `label_` tra i non fatali: `label_read_failed`, `label_pick_failed`, `label_lookup_failed`, `label_cleanup_failed`. Se sono **più di 10** oppure riguardano **più di 3 utenti**, indaga; un aumento di `label_read_failed` dopo un aggiornamento di ML Kit si confronta con la misura delle 20 etichette (§1-sexies). Ogni crash nuovo con ML Kit o `LabelImagePreparer` nello stack si corregge con una nuova versione.
- [ ] Crashlytics, ultimi 7 giorni: errori non fatali `wine_db_unavailable` (label-recognition, NFR3.9, NFR4.15), con le chiavi `wine_db_reason` e `wine_db_skipped_rows`. Se sono **più di 10** oppure riguardano **più di 3 utenti**, controlla il file della base nella build (`assets/wine_db/` dell'AAB) e correggi con una nuova versione; nel frattempo il riconoscimento continua con il catalogo interno e Open Food Facts.
- [ ] Crashlytics, ultimi 7 giorni: errori non fatali `estimates_migration_failed` (label-autofill-windows, BR3.9, NFR4.8a), con il motivo `permissionDenied` o `localWriteFailed`. Se sono **più di 5** in 7 giorni (NFR3.6), controlla che le regole pubblicate siano quelle di questa versione (§1-decies) e correggi con una nuova versione; nel frattempo i vini restano con la stima precedente e l'app riprova al massimo 3 volte. Guarda anche `appellations_index_failed`: ogni evento si corregge con una nuova versione della tabella.
- [ ] Crashlytics, ultimi 30 giorni: errori non fatali dell'account (u8-account, monitoring-design.md §1) `account_delete_failed`, `account_signout_failed`, `account_reauth_failed`, con il passo. Se sono **più di 3**, indaga: una cancellazione bloccata è un problema di privacy. Obiettivo: nessun utente con `account_delete_failed` senza una cancellazione completata dopo.
- [ ] Richieste di cancellazione via email (BR1.12): nessuna richiesta aperta oltre 30 giorni nel registro del §1-septies; tutte chiuse entro 30 giorni.
- [ ] App Check (console Firebase → App Check → metriche): percentuale di richieste verificate, Android e web insieme. L'obbligo su Firestore si attiva solo dopo **7 giorni consecutivi ≥ 99%** (`docs/firebase-setup.md` §2).
- Eventi `account_*`: ______. Richieste via email aperte: ______. App Check verificate: ______ %.
- Eventi `label_*`: ______. Utenti coinvolti: ______.
- Eventi `wine_db_unavailable`: ______. Utenti coinvolti: ______.
- Eventi `estimates_migration_failed`: ______. Utenti coinvolti: ______. Eventi `appellations_index_failed`: ______.
- Data del controllo: ______. Eventi `off_suspended`: ______. Utenti coinvolti: ______. Eventi `dashboard_invalid_window`: ______. Utenti coinvolti: ______. Letture giornaliere massime: ______. Eventi `sharing_*_failed`: ______. Utenti coinvolti: ______. Eventi `cellar_*`, `estimate_refresh_failed`, `match_key_backfill_failed`, `pending_probe_failed`: ______. Utenti coinvolti: ______.
