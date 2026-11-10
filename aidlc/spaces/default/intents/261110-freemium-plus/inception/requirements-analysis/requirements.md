# Requisiti — Freemium e Plus

Intent: `261110-freemium-plus`. Scope `express`, profondità Minimal.

## Sources

- Initial description: «Implementare freemium e Plus secondo docs/vinoozy-studio-monetizzazione.md» [desc]
- Workflow-selected scope: `express` [scope]
- Lo studio `docs/vinoozy-studio-monetizzazione.md`, sezioni 4, 5, 7, 8 e 9, indicato dalla richiesta come specifica. Qui sotto è citato come «studio §n». [desc]
- La mappa del codice `aidlc/spaces/default/codekb/Vinoozy/`, aggiornata il 2026-11-10.
- Le risposte in `requirements-analysis-questions.md` (Q1–Q9), citate come [Q<n>].

## Analisi dell'intento

L'obiettivo è far sostenere i costi di Vinoozy senza peggiorare l'uso leggero gratuito. Il piano gratuito resta completo per la gestione quotidiana, ma ha un tetto di capacità e, oltre una soglia d'uso del cloud, annunci occasionali. Plus toglie gli annunci e il tetto. Il proprietario vuole anche:

- regalare Plus a persone scelte [Q6];
- avere strumenti nascosti per provare tutti gli stati senza pagare [Q3, Q6];
- non spendere nulla per l'infrastruttura [Q8, Q9].

Il proprietario ha deciso di **passare a Blaze con delle protezioni** [Q9], per poter verificare i pagamenti sul server. La previsione di spesa è 0 €. Il rischio residuo di pochi centesimi è accettato in modo esplicito [Q9].

Il lavoro è **brownfield** e parte da zero: oggi non esistono diritti, contatori, Billing, annunci o backend (codekb `business-overview.md`). L'ambito di questo giro è **tutto lo studio** [Q1, Q4, Q9]:

- diritti e piani;
- limite di capacità;
- acquisto di Plus con verifica sul server;
- Plus in regalo tramite script;
- strumenti sviluppatore;
- misuratore d'uso;
- modulo annunci;
- protezioni di spesa.

I due interruttori di prodotto partono **spenti**, come chiede lo studio §7.1: `capacityLimitEnabled=false` e `adsEnabled=false`.

## Requisiti funzionali

### FR1 — Diritti e piani

- **FR1.1** L'app legge il piano dell'utente da un unico repository dei diritti, che si basa su `entitlements/{uid}`. Il documento contiene: `plan` (`plus`), `source` (`play_purchase` | `manual_grant`), `status` (`active` | `grace` | `on_hold` | `paused` | `expired` | `revoked`), `expiresAt` (che può mancare solo per un `manual_grant` senza scadenza), `reason` (`gift` | `owner_test` | assente) e `updatedAt`. Il client può solo leggere il proprio documento. [desc] (studio §5.5, §9.1)
  - *Accettazione:* Dato un utente senza documento, il piano risolto è `free`. Dato `status=active` con `expiresAt` futuro, il piano risolto è `plus`. Se un client prova a scrivere `entitlements/{uid}`, le regole rifiutano.
- **FR1.2** Un'unica risoluzione delle capacità, usata da schermate, azioni e regole, ricava dal piano le capacità `unlimitedActiveWines` e `adFree`. Plus è valido quando `status` è `active` o `grace` e `expiresAt` è successivo all'ora del server, oppure assente per un `manual_grant`. [desc] (studio §9.1)
  - *Accettazione:* Nei casi `expired`, `revoked`, `on_hold` e `paused`, e con `expiresAt` passato, il piano risolto è `free`. Con `grace` valido il piano è `plus`.
- **FR1.3** Il Profilo mostra il piano in vigore: «Gratuito», «Plus», «Plus in regalo» (per `manual_grant`) oppure l'indicatore di test della FR5.4. Non mostra mai rinnovi o addebiti per un regalo. [desc] (studio §9.4)
  - *Accettazione:* Dato un `manual_grant` con `reason=gift`, il Profilo mostra «Plus in regalo» senza date di rinnovo.
- **FR1.4** Il diritto resta valido offline usando una copia locale, con la data dell'ultima verifica. La copia resta valida al massimo 7 giorni oltre la sua ultima conferma, e mai oltre `expiresAt`. [desc] (studio §5.7)
  - *Accettazione:* Con Plus verificato e l'app offline per 3 giorni, il piano resta `plus`. Con la copia confermata più di 7 giorni fa, l'app non mostra più nuove funzioni Plus finché non torna online. Nessun dato viene nascosto.
- **FR1.5** Quando Plus scade o viene revocato, l'app torna al piano gratuito senza cancellare né nascondere dati. Vale anche per i vini aggiunti durante Plus. [desc] (studio §7.1)
  - *Accettazione:* Con 30 schede attive create durante Plus, dopo la scadenza tutte restano visibili e modificabili. Se il limite è attivo, aggiungere una nuova scheda viene rifiutato.

### FR2 — Limite di capacità del piano gratuito

- **FR2.1** Una «scheda attiva» è un vino della cantina personale con `quantity > 0`. Una scheda con `quantity <= 0` non è attiva, perché per gli incrementi concorrenti la quantità sul server può scendere sotto zero (codekb `architecture.md`, ADR-004). Le cantine condivise da altri non occupano posti della propria. [desc] (studio §7.1)
  - *Accettazione:* Sei bottiglie della stessa scheda occupano un posto. Una scheda a quantità 0 o −1 non ne occupa.
- **FR2.2** Il documento `cellars/{ownerUid}` tiene il contatore `activeWineCount`. Ogni batch che cambia lo stato attivo di una scheda aggiorna il contatore di +1 o −1 nella stessa scrittura atomica. Le regole Firestore controllano con `getAfter` che la variazione corrisponda al cambio di stato della scheda. Il controllo vale per tutti i percorsi: creazione, aggiunta di bottiglie a una scheda a 0, Annulla di una bevuta, modifica della quantità, bevuta dell'ultima bottiglia e cancellazione, anche quando la scrittura arriva da un membro invitato. [Q2] (studio §7.1)
  - *Accettazione:* Se un batch porta una scheda da 0 a 2 e non aggiorna il contatore, le regole rifiutano. Se un batch la porta da 0 a 2 aggiornando il contatore di +1, le regole accettano. Lo stesso vale per un membro con permesso `edit`.
- **FR2.3** Una migrazione amministrativa, eseguita dal server o da uno script di amministrazione e mai dal client, scrive per ogni cantina esistente `activeWineCount` e `legacyActiveWineLimit = max(15, schede attive esistenti)`. Il client non può scrivere `legacyActiveWineLimit`. [desc] (studio §7.1)
  - *Accettazione:* Una cantina con 22 schede attive riceve `legacyActiveWineLimit=22`. Una con 4 riceve 15. Se il client prova a scrivere il campo, le regole rifiutano.
- **FR2.4** Quando `capacityLimitEnabled` è vero nella configurazione `config/policy`, le regole rifiutano ogni scrittura che porterebbe `activeWineCount` oltre il limite effettivo, salvo che il proprietario della cantina abbia un Plus valido in `entitlements/{ownerUid}`. Il limite effettivo è `legacyActiveWineLimit`, oppure 15 se il campo manca. Il limite non blocca mai lettura, modifica di schede esistenti, riduzione, aumento di quantità su schede già attive, archivio, cancellazione ed esportazione. [desc] (studio §7.1, §5.6)
  - *Accettazione:* Con 15 schede attive su 15, la sedicesima viene rifiutata. Aggiungere bottiglie a una scheda già attiva è accettato. Riattivare una scheda archiviata viene rifiutato. Con Plus valido del proprietario, la sedicesima è accettata. Con `capacityLimitEnabled=false`, la sedicesima è accettata.
- **FR2.5** Prima di scrivere, l'app controlla il limite. Se un'azione supererebbe il limite, non la invia e mostra una spiegazione con «Scopri Plus». Se una scrittura fatta offline viene poi rifiutata dal server, l'app la conserva come bozza recuperabile, spiega perché non è stata sincronizzata e non la mostra mai come sincronizzata. [desc] (studio §7.1)
  - *Accettazione:* Con 15 su 15, il pulsante Aggiungi apre la spiegazione e non scrive nulla. Un'aggiunta fatta offline e rifiutata al ritorno della rete compare come bozza da recuperare, con il motivo indicato.
- **FR2.6** Le regole devono continuare ad accettare le scritture della versione dell'app già pubblicata finché `capacityLimitEnabled=false`. [desc] (codekb `api-documentation.md`, `test/rules/compat/`)
  - *Accettazione:* I test `test/rules/compat/` restano verdi con il limite spento.

### FR3 — Acquisto di Plus su Google Play

- **FR3.1** L'app integra un plugin Flutter di Play Billing mantenuto. Usa il prodotto in abbonamento Plus con i piani base mensile (1,99 €) e annuale (14,99 €), mostrando i prezzi letti dallo store e mai scritti nel codice. [desc] (studio §5.1, §7.1)
  - *Accettazione:* La schermata Plus mostra i prezzi restituiti da Play nella valuta locale. Se lo store non risponde, mostra un errore comprensibile e non mostra prezzi inventati.
- **FR3.2** La schermata Plus presenta: i benefici reali (niente annunci, niente limite di schede), il prezzo con il rinnovo, i termini, «Ripristina acquisti» e il collegamento per gestire o annullare l'abbonamento su Play. Non elenca funzioni Plus non ancora sviluppate. [desc] (studio §5.1, §9.1)
  - *Accettazione:* La schermata ha i tre testi nelle lingue it, en e pt-BR e i due collegamenti. Non mostra la condivisione a 5 persone né più cantine.
- **FR3.3** Dopo un acquisto, l'app invia il `purchaseToken` a un endpoint del backend autenticato e protetto da App Check (`verifyPurchase`). Il backend:
  - verifica package, prodotto e stato presso la Play Developer API;
  - lega il token a un solo UID, in una raccolta privata del server, rifiutando il riuso su un altro account;
  - scrive `entitlements/{uid}` solo se il pagamento è verificato;
  - conferma (acknowledge) l'acquisto in modo idempotente.

  Gli acquisti `PENDING` non sbloccano nulla. [desc] (studio §5.2, §5.3)
  - *Accettazione:* Un token falso, un token di un altro package o prodotto, lo stesso token usato su un secondo UID e un acquisto `PENDING` non creano diritti. Un token valido crea `status=active` con `expiresAt` uguale a quello letto da Play. Un secondo invio dello stesso token non crea duplicati.
- **FR3.4** Un gestore delle notifiche Play (RTDN, via Pub/Sub):
  - autentica la sorgente;
  - scarta i duplicati;
  - rilegge sempre lo stato presso la Play API;
  - aggiorna il diritto per rinnovo, annullamento (diritto fino alla scadenza), grace period, account hold, pausa, scadenza, rimborso e revoca.

  Un job giornaliero riconcilia i diritti attivi. [desc] (studio §5.4)
  - *Accettazione:* Una notifica di annullamento lascia `active` fino a `expiresAt`. Un rimborso porta subito a `revoked`. Una notifica fuori ordine non riporta uno stato più vecchio.
- **FR3.5** Con l'interruttore `purchasesEnabled=false` in `config/policy`, la schermata Plus mostra «Plus arriverà presto» e nessun pulsante d'acquisto. L'interruttore parte spento e il proprietario lo accende dopo:
  - il passaggio a Blaze;
  - la configurazione del prodotto in Play Console;
  - la pubblicazione delle funzioni.

  [Q7, Q9] (studio §7.8)
  - *Accettazione:* Con `purchasesEnabled=false` nessun flusso di pagamento si apre. Con `true` il flusso si apre.

### FR4 — Plus in regalo tramite script

- **FR4.1** Uno script di amministrazione Node (`firebase-admin`), eseguito dal proprietario dal proprio Mac, assegna Plus a un account registrato a partire dalla sua email. Lo script:
  - trova l'UID con Firebase Auth;
  - scrive `entitlements/{uid}` con `source=manual_grant`, `reason` (`gift` o `owner_test`), la data di inizio e una scadenza esplicita oppure «senza scadenza»;
  - non scrive mai un `purchaseToken`.

  [Q6] (studio §9.4)
  - *Accettazione:* Con l'email di un account registrato, il documento viene scritto e lo script stampa UID e scadenza. Con un'email non registrata, lo script si ferma con un errore e non scrive nulla.
- **FR4.2** Lo stesso script revoca un regalo: porta `status` a `revoked` e conserva i dati della cantina. [Q6] (studio §9.4)
  - *Accettazione:* Dopo la revoca il piano risolto è `free` e tutti i vini restano.
- **FR4.3** L'app applica il regalo da sola, senza azioni della persona: al successivo avvio o in tempo reale tramite il listener del proprio diritto. [Q6]
  - *Accettazione:* Con l'app aperta, entro pochi secondi dalla scrittura dello script il Profilo mostra «Plus in regalo» e gli annunci spariscono.
- **FR4.4** Lo script legge le credenziali di servizio da un file indicato fuori dal repository oppure da una variabile d'ambiente. Prima di scrivere, mostra e verifica l'ID del progetto. Le credenziali non entrano mai nel repository né nell'APK. [Q6] (team.md Deployment)
  - *Accettazione:* Senza credenziali, lo script spiega cosa manca e si ferma. `git status` non mostra file di credenziali.

### FR5 — Strumenti sviluppatore nascosti

- **FR5.1** Gli strumenti esistono solo quando valgono tutte queste condizioni: `NOT kReleaseMode`, `ENABLE_DEV_CHEATS == true` (un `--dart-define` che di default è falso), `FirebaseEnvConfig.usesEmulators` e `projectId == "demo-vinoozy"`. In ogni altro caso non esiste nessun pannello, percorso, deep link o gestore. [desc] (studio §9.3)
  - *Accettazione:* Una build release, anche con il flag vero, e una build collegata al progetto reale non hanno pannello né sequenza attiva.
- **FR5.2** Il pannello si apre con la sequenza scelta dal proprietario, che sostituisce i 7 tocchi sulla versione:
  - due tocchi sul logo Bottazzini in fondo al Cruscotto;
  - poi, nella barra di navigazione: Cantina, Cantina, Cantina, Storico, Storico, Storico, Cantina, Storico, Cruscotto.

  La sequenza va completata entro 20 secondi dal primo tocco. Si azzera con un passo sbagliato, alla scadenza del tempo o uscendo dall'app. Un tocco singolo sul logo apre ancora Informazioni. [Q3, Q6]
  - *Accettazione:* La sequenza completa entro 20 s apre «Strumenti sviluppatore». Un passo sbagliato, la sequenza oltre 20 s o una sequenza incompleta non aprono nulla.
- **FR5.3** Il pannello offre quattro comandi:
  - «Sblocca tutto — Plus di test»: tutte le capacità Plus, niente limite, niente annunci;
  - «Simula piano gratuito»;
  - «Simula Plus scaduto»;
  - «Ripristina stato normale».

  Nessun comando apre dialoghi di pagamento o genera token o ricevute. [desc] (studio §9.2)
  - *Accettazione:* Passando da Plus di test a gratuito, poi a scaduto e infine allo stato normale, non si perde nessun dato, e limiti e annunci restano coerenti con ogni scenario.
- **FR5.4** Con un override attivo, il pannello e il Profilo mostrano «DEV · Plus di test» oppure lo stato simulato. [desc] (studio §9.2)
  - *Accettazione:* Con l'override attivo l'indicatore è visibile. Dopo «Ripristina» scompare.
- **FR5.5** L'override è salvato solo in locale, legato a UID e progetto demo. Logout, cambio di account o di ambiente e «Ripristina» lo cancellano. Resiste ai riavvii. [desc] (studio §9.2)
  - *Accettazione:* Dopo un cambio di account l'override non è più attivo. Riavviando con lo stesso account resta attivo.
- **FR5.6** Per gli scenari che toccano le regole sul server, lo strumento di sviluppo scrive il diritto corrispondente **solo nell'emulatore Firestore**, dopo aver verificato host e progetto `demo-vinoozy`. Se non ci riesce, il pannello dice che la simulazione è incompleta e non presenta mai come riuscita una scrittura rifiutata. [desc] (studio §9.3)
  - *Accettazione:* Con l'emulatore attivo, «Sblocca tutto» permette la sedicesima scheda anche con il limite attivo. Senza emulatore raggiungibile, il pannello mostra «simulazione incompleta».
- **FR5.7** `tool/check_release_build.sh` verifica che il marker `VINOOZY_DEV_CHEATS_PANEL` manchi nell'artefatto pubblicabile. Il controllo positivo, cioè che il marker sia presente in una build di sviluppo con il flag attivo, deve risultare rilevabile. [desc] (studio §9.5)
  - *Accettazione:* Il controllo fallisce se il marker compare nell'AAB release e passa quando manca.

### FR6 — Misuratore d'uso del cloud

- **FR6.1** Un servizio `CloudUsageMeter`, testabile senza rete, conta letture, scritture confermate e byte ricevuti per account e mese UTC nei punti indicati dallo studio §7.5:
  - listener dei vini (incluso quello condiviso, contato una sola volta);
  - storico;
  - `server_or_cache`;
  - scritture confermate;
  - condivisione;
  - profilo e sync.

  Gli eventi solo cache o solo metadata non contano. [desc] (studio §7.5)
  - *Accettazione:* Lo stesso listener usato da Cantina e Cruscotto conta una volta. Una modifica solo in coda offline non conta finché non è confermata. Una query vuota conta 1 lettura e 0 byte.
- **FR6.2** Il costo stimato è `C_hat = R·0,035/100000 + W·0,104/100000 + B·0,12/GiB` (fx = 1), calcolato con aritmetica decimale esatta. La soglia `usageBudgetEuro = 0,005` si supera **strettamente**. [desc] (studio §7.3)
  - *Accettazione:* Valgono i confini dello studio §7.11: 14.285 letture sono sotto la soglia e 14.286 sopra; 4.807 scritture sotto e 4.808 sopra; 14.256 letture più 10 scritture valgono esattamente la soglia e non la superano; 479 o 480 caricamenti; 427 o 428 cicli.
- **FR6.3** Il dispositivo conserva in locale i contatori cumulativi per account, installazione e mese, e li invia a un endpoint del backend (`reportUsage`, autenticato e con App Check):
  - a fine sessione;
  - ogni 15 minuti durante le sessioni lunghe;
  - al primo superamento locale della soglia.

  Il backend applica solo il delta rispetto all'ultimo cumulativo accettato per quel dispositivo, rifiuta sequenze ripetute con valori diversi e cumulativi in diminuzione, e restituisce totale, policy, ora del server e prossimo reset. [desc] (studio §7.6)
  - *Accettazione:* Rinvii identici sono idempotenti, una sequenza vecchia non aggiunge nulla, due dispositivi si sommano e una reinstallazione non azzera l'account.
- **FR6.4** Non entrano nella soglia personale le operazioni di sistema: cancellazioni, eliminazione dell'account, esportazione, migrazioni, aggiornamenti automatici delle stime, recuperi da errori, traffico del misuratore stesso e del backend. [desc] (studio §7.3)
  - *Accettazione:* La migrazione delle stime e l'eliminazione dell'account non incrementano i contatori personali.
- **FR6.5** I documenti `usage/{uid}/periods/{YYYY-MM}` e i relativi dispositivi sono scritti solo dal backend. Il client legge solo i propri. Il periodo usa l'ora del server; al nuovo mese UTC i contatori ripartono senza cancellare quelli vecchi. [desc] (studio §7.6)
  - *Accettazione:* Un client che scrive `usage/...` viene rifiutato. Un upload tardivo del mese precedente aggiorna quel mese e non quello corrente.

### FR7 — Modulo annunci (spento)

- **FR7.1** Con `adsEnabled=false` in `config/policy`, l'SDK pubblicitario non viene inizializzato e non parte nessuna richiesta. L'interruttore spegne subito nuovi caricamenti e rimuove eventuali banner attivi. [desc] (studio §7.1, §7.7)
  - *Accettazione:* Con `adsEnabled=false` non c'è nessuna inizializzazione dell'SDK. Passando a `false` mentre un banner è visibile, il banner viene rimosso.
- **FR7.2** Un utente è idoneo agli annunci solo quando valgono tutte queste condizioni: `adsEnabled`, stato verificato, nessun Plus valido e `C_hat` del mese oltre la soglia. Il tentativo avviene solo quando, in più:
  - la Dashboard è visibile;
  - il consenso (CMP) lo consente;
  - c'è rete;
  - non è in corso nessuna operazione sensibile;
  - il backend (`reserveAdSlot`) ha concesso la prenotazione per l'account e il giorno UTC.

  La prenotazione è una sola per account e giorno UTC, condivisa tra dispositivi, e consuma il tentativo anche se l'annuncio non arriva o va in errore. [desc] (studio §7.7)
  - *Accettazione:* Se due dispositivi chiedono insieme, uno solo ottiene lo slot. Dopo un mancato riempimento, quel giorno non parte un secondo tentativo. Con Plus attivo nessun tentativo parte.
- **FR7.3** C'è un solo banner, in fondo alla Dashboard, senza aggiornamento automatico. Viene rimosso e distrutto quando si esce dalla Dashboard o l'app va in background, e non si ricarica nello stesso giorno. Non ci sono interstitial né annunci con premio. Nessun annuncio compare in scanner, moduli, conferme di salvataggio, esportazione o eliminazione dell'account. Durante lo sviluppo si usano solo ID pubblicitari di test. [desc] (studio §7.7)
  - *Accettazione:* Tornando alla Dashboard nello stesso giorno, non parte una nuova richiesta. Nessun banner compare fuori dalla Dashboard.
- **FR7.4** Quando arriva un acquisto Plus verificato o un regalo, l'app rimuove il banner e annulla i caricamenti in corso prima di mostrare il contenuto. [desc] (studio §7.7, §9.5)
  - *Accettazione:* Se Plus si attiva mentre un banner è in caricamento, il banner non viene mostrato.
- **FR7.5** Al primo superamento della soglia, la Dashboard mostra una sola volta per periodo e account la spiegazione dello studio §7.8, con l'ora locale del prossimo reset e i collegamenti «Come funziona» e «Scopri Plus». La spiegazione non compare mai durante un salvataggio. [desc] (studio §7.7, §7.8)
  - *Accettazione:* La spiegazione compare una volta per mese e per account, e l'orario di reset è mostrato nel fuso del dispositivo.
- **FR7.6** Registro separatamente richiesta, caricamento, impression e ricavo stimato, deduplicati con la prenotazione. `onAdLoaded` non vale come impression. [desc] (studio §7.7)
  - *Accettazione:* Un caricamento senza impression non conta come impression.

### FR8 — Testi e informazioni del piano

- **FR8.1** I testi dello studio §7.8 (presentazione del piano gratuito, superamento della soglia, «Nessuna pubblicità nella versione di lancio» quando gli annunci sono spenti) e quelli di Plus, regalo, limite e strumenti sviluppatore stanno nei file di localizzazione it, en e pt-BR. [desc] (team.md Code Style)
  - *Accettazione:* Nessun testo dell'interfaccia è scritto nel codice. I test dei widget passano nelle tre lingue.
- **FR8.2** La presentazione del piano gratuito compare una sola volta, quando il limite di capacità viene attivato. Non promette Plus acquistabile mentre `purchasesEnabled=false`. [desc] (studio §7.8)
  - *Accettazione:* Con `purchasesEnabled=false` la presentazione dice «Plus arriverà presto».

### FR9 — Passaggio a Blaze con protezioni di spesa

- **FR9.1** Una procedura scritta (`docs/`) guida il proprietario nel passaggio del progetto `vinoozy-d6f45` a Blaze, in quest'ordine: budget con avviso a 1 €, spegnimento automatico della fatturazione, criteri di pulizia delle immagini, pubblicazione delle funzioni. Il passaggio lo esegue il proprietario dalla console: il codice non lo fa. [Q9] (studio §8.7)
  - *Accettazione:* La procedura elenca ogni passo, con la verifica che il budget e l'avviso a 1 € siano attivi.
- **FR9.2** Una funzione ascolta le notifiche del budget (Pub/Sub). Quando la spesa supera il budget, scollega la fatturazione dal progetto e registra l'evento. Il ritardo dell'intervento è documentato. [Q9] (studio §8.7)
  - *Accettazione:* Nei test, una notifica con costo superiore al budget porta alla chiamata di scollegamento. Una notifica sotto il budget non fa nulla.
- **FR9.3** Le funzioni girano nella stessa regione di Firestore, `europe-west8` (docs/firebase-setup.md). L'Artifact Registry ha un criterio di pulizia che tiene solo le immagini più recenti, per restare sotto 0,5 GB. [Q9]
  - *Accettazione:* La configurazione di deploy indica `europe-west8` e il criterio di pulizia.

## Requisiti non funzionali

- **NFR1 — Sicurezza.** Il client non può scrivere `entitlements`, `usage`, `adSlots`, `config`, `legacyActiveWineLimit` né la raccolta privata degli acquisti. Il diritto Plus nasce solo da una verifica sul server o da un grant amministrativo. Nessuna eccezione nelle regole per gesti, PIN, flag del client o build di debug. I segreti (Play Developer API, credenziali di servizio) stanno solo nei segreti del backend o di GitHub Actions. [desc] (studio §5, §9.3)
  - *Accettazione:* I test delle regole nell'emulatore coprono per ogni raccolta il tentativo di scrittura da parte del client e lo vedono rifiutato.
- **NFR2 — Regole Firestore.** Le regole restano entro i limiti del servizio, cioè 1000 espressioni per richiesta valutata e i limiti di `get`/`getAfter`, e passano tutti i test esistenti più i nuovi. [desc] (codekb `code-quality-assessment.md`)
  - *Accettazione:* `npm run test:rules` è verde e include anche `style_profiles.rules.test.mjs`, che oggi manca dall'elenco.
- **NFR3 — Costo.** L'uso normale resta entro le quote gratuite: previsione 0 €/mese. Il misuratore fa al massimo un upload ogni 15 minuti per sessione e mai una scrittura per ogni lettura. [Q9] (studio §7.6)
  - *Accettazione:* In una sessione di 1 ora l'app esegue al massimo 5 upload del misuratore.
- **NFR4 — Nessuna perdita di dati.** Né il limite, né la scadenza di Plus, né il misuratore, né gli annunci bloccano l'accesso ai propri dati, l'esportazione o l'eliminazione dell'account. Uno stato incerto, perché non verificabile, non porta mai ad annunci e lascia l'app utilizzabile. [desc] (studio §7.6)
  - *Accettazione:* Senza rete e con il backend irraggiungibile, l'app funziona, non mostra annunci e non nasconde vini.
- **NFR5 — Test.** Secondo `team.md`:
  - test dopo il codice, strato per strato;
  - copertura delle righe almeno all'80% su tutto il codice;
  - test delle regole e delle funzioni nella Firebase Emulator Suite;
  - test dei widget nelle tre lingue;
  - test end-to-end su emulatore Android per il limite e per il cambio di piano.

  [desc] (team.md Testing Posture)
  - *Accettazione:* La CI è verde su formattazione, analisi, test, copertura ed end-to-end.
- **NFR6 — Privacy.** I contatori conservano solo numeri, versioni, date e identificatori, mai nomi di vini, foto, note o token. I dettagli di misurazione si conservano per 90 giorni. Nessun token d'acquisto nei log né in Crashlytics. Informativa privacy, Data safety ed eliminazione dell'account vengono aggiornate per diritti, acquisti, misurazione e annunci. [desc] (studio §5.8, §7.6)
  - *Accettazione:* Eliminando l'account si eliminano anche `entitlements/{uid}`, `usage/{uid}` e `adSlots/{uid}`. Dei dati d'acquisto resta solo la conservazione minima documentata.
- **NFR7 — Codice.** Il codice, gli identificatori e i commenti sono in inglese. I testi dell'interfaccia stanno nei file di localizzazione. [desc] (project.md Mandated)
  - *Accettazione:* `flutter analyze` e `dart format` sono puliti.

## Vincoli

- Il passaggio a Blaze si fa solo con le protezioni della FR9. Finché il proprietario non lo esegue, le funzioni non vengono pubblicate e `purchasesEnabled`, `adsEnabled` e `capacityLimitEnabled` restano spenti. [Q9]
- Il budget è 0 €/mese, con l'avviso a 1 € (team.md Deployment).
- Le regole e la configurazione Firestore vanno in produzione solo con l'approvazione manuale del proprietario (team.md Deployment).
- Firestore è in `europe-west8`, scelta definitiva (docs/firebase-setup.md).

## Assumptions & Open Questions

- [assumption] «Fare tutto il resto» [Q1], con Blaze accettato [Q9], comprende anche il modulo annunci, costruito e spento (`adsEnabled=false`, solo ID di test).
- [assumption] La sequenza segreta del proprietario [Q3] sostituisce i 7 tocchi sulla riga della versione come ingresso agli strumenti sviluppatore, e vale solo nelle build di sviluppo [Q6]. Il tempo massimo è 20 secondi, al posto dei 5 dello studio, perché la sequenza ha 11 passi.
- [assumption] La migrazione `legacyActiveWineLimit` gira come funzione o script amministrativo prima dell'accensione del limite. Fino a quel momento il contatore viene mantenuto ma non applicato.
- [assumption] La configurazione `config/policy` (`adsEnabled`, `capacityLimitEnabled`, `purchasesEnabled`, `policyVersion=freemium-v1`, `usageBudgetEuro`) si cambia solo con un comando amministrativo. Tutti i client possono leggerla.
- Domanda aperta: la creazione del prodotto in abbonamento in Play Console, il conto AdMob, il collegamento della Play Developer API al service account e l'attivazione di RTDN sono passi manuali del proprietario. Vengono documentati, non automatizzati.
- Domanda aperta: con quale versione minima dell'app si può accendere `capacityLimitEnabled`, perché le versioni vecchie non aggiornano il contatore. La decisione arriva al momento dell'attivazione, dopo la misurazione (studio §7.10).

## Fuori ambito

- Estensioni di Plus non ancora sviluppate: più cantine, condivisione fino a 5 persone, statistiche e report avanzati, notifiche, esportazione in PDF (studio §4).
- Acquisto una tantum da 19,99 € (studio, Raccomandazione).
- Interstitial e annunci con premio (studio §7.7).
- L'accensione in produzione di annunci, limite e acquisti: sono decisioni del proprietario dopo la misurazione (studio §7.10).
- Analytics di prodotto e telemetria aggiuntiva (studio §4).
- Lo spegnimento della fatturazione come garanzia assoluta di 0 €: è una protezione con un ritardo [Q9].
