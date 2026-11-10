# Requirements Analysis — domande

Richiesta: "Implementare freemium e Plus secondo docs/vinoozy-studio-monetizzazione.md".

La mappa del codice dice che oggi non esiste ancora nulla di diritti, contatori, Billing, annunci o backend, e che il progetto Firebase è su Spark, con budget di 0 €. Lo studio (sezione 7.10) prevede cinque fasi: misurazione, validazione, capacità e Plus, annunci, riesame. Diverse parti richiedono un backend su Cloud Functions, e quindi il piano Blaze: verifica degli acquisti, contatori aggregati per account, prenotazione degli slot pubblicitari, grant omaggio.

## Q1. [Proprietario del prodotto] Fin dove arriviamo in questo giro?

Da questa risposta dipendono tutti gli altri requisiti. Lo studio chiede di partire con `adsEnabled=false` e `capacityLimitEnabled=false`.

A. **Fondamenta e menu nascosto**. Comprende: il repository unico dei diritti (`entitlements/{uid}`, che il client può solo leggere), la risoluzione delle capacità (gratis o Plus), il limite di 15 schede attive con migrazione legacy e interruttore inizialmente spento, il menu «Strumenti sviluppatore» con 7 tocchi (sezione 9), il misuratore `CloudUsageMeter` con contatori solo locali e i testi in it, en e pt-BR. Niente Billing, backend né annunci. Funziona su Spark.
B. A, più il **Billing lato app**: il plugin di acquisto, una schermata Plus con i prezzi letti da Google Play, il ripristino degli acquisti e il link per gestire l'abbonamento. Senza la verifica sul server, però, l'acquisto non sblocca ancora Plus.
C. A e B, più il **backend su Cloud Functions**: verifica degli acquisti e RTDN, contatori aggregati, grant omaggio. Va provato solo negli emulatori; per pubblicarlo serve passare a Blaze, e quella decisione resta tua.
D. Tutto quello di C, più il **modulo annunci**: AdMob con ID di test, consenso CMP e banner nella Dashboard, sempre con `adsEnabled=false`.
X. Other (please specify)

[Answer]: X. Non voglio passare a blaze per il momento ma in un futuro si. QDirei di fare tutto il resto

## Q2. [Sviluppatore] Come facciamo rispettare il limite di 15 schede anche lato server?

Lo studio (7.1) chiede un vincolo atomico sul server per tutti i percorsi che aumentano le schede attive: aggiunta, aumento di quantità da 0, Annulla di una bevuta, riattivazione dall'archivio. Disabilitare il pulsante non basta. Le regole dei vini sono già vicine al limite di 1000 espressioni.

A. **Contatore nel documento della cantina, verificato dalle regole Firestore.** Ogni scrittura che cambia lo stato attivo di una scheda aggiorna nello stesso batch il campo `activeWineCount`. Le regole controllano il valore finale con `getAfter` rispetto al limite effettivo, cioè `legacyActiveWineLimit` oppure Plus. Funziona su Spark e offline: la scrittura rifiutata torna come bozza da recuperare.
B. **Per ora solo nel client.** Il limite viene applicato nell'app e il vincolo sul server arriva in un giro successivo. È più semplice, ma un client modificato può aggirarlo.
C. **Con una Cloud Function.** Le scritture che aumentano le schede passano dal backend. Richiede Blaze e non funziona offline.
X. Other (please specify)

[Answer]: A

## Q3. [Proprietario del prodotto] Come ottieni Plus gratis sul tuo telefono collegato al Firebase reale?

Lo studio (9.4) vuole un «Plus omaggio» assegnato solo dal lato amministrativo, con origine `manual_grant`, motivo `owner_test` e una scadenza esplicita, mai attivabile dall'app.

A. **Script amministrativo locale** (Node con `firebase-admin`), che lanci tu dal Mac con le credenziali di servizio. Le credenziali non entrano nel repository. Lo script scrive `entitlements/{tuoUid}` e permette anche la revoca. Funziona su Spark.
B. **Rimandato**: per ora usi il menu nascosto solo sulle build di sviluppo con gli emulatori.
X. Other (please specify)

[Answer]: X. Farei qualche tasti nascosti in interfaccia che se premuti in certa combinzaione si sblocchi tutto Tipo premo due volte su cruscostto dentro logo bottazzini e poi premo cantina cantina catina e storico storico storico e poi cantina storico cruscotto e lì si sblocca

## Q4. [Proprietario del prodotto] Che cosa vuol dire «tutto il resto» senza Blaze?

Seguito di Q1. Hai detto di non voler passare a Blaze per ora ma di farlo in futuro, e di fare «tutto il resto». Il backend su Cloud Functions si può scrivere e provare adesso negli emulatori, gratis, anche senza Blaze: solo la pubblicazione richiede Blaze. Senza backend, però, un acquisto Plus non può essere verificato e quindi non sblocca nulla. Gli annunci, inoltre, hanno bisogno del backend per prenotare lo slot giornaliero.

A. **Costruiamo tutto adesso, backend compreso.** Le Cloud Functions vengono provate solo negli emulatori e non pubblicate. In produzione resta tutto spento (Plus non acquistabile, `adsEnabled=false`) finché non passi a Blaze e pubblichi.
B. **Solo ciò che funziona davvero su Spark**: fondamenta, menu nascosto, Billing lato app e modulo annunci spento. Il backend si scrive in un giro successivo, quando passerai a Blaze.
X. Other (please specify)

[Answer]: X. Ah scusami volevo restare SPark senza spending

## Q5. [Sviluppatore] Combinazione segreta sul telefono reale: come la rendiamo sicura?

Seguito di Q3. La sequenza che proponi è: due tocchi sul logo Bottazzini nel Cruscotto, poi Cantina ×3, Storico ×3, Cantina, Storico, Cruscotto. Il gesto si può fare. Il problema è la sicurezza: lo studio (9.3, 9.4) vieta che un gesto nell'app sblocchi Plus nella versione pubblicata. Chiunque legga il codice dell'APK troverebbe la sequenza e avrebbe Plus gratis, e il limite di 15 schede sul server (Q2) lo bloccherebbe comunque, perché le regole non si fidano dell'app.

A. **Gesto più controllo del tuo UID nelle regole.** La sequenza apre il pannello, che chiede di scrivere `entitlements/{uid}` con origine `manual_grant`. Le regole Firestore lo permettono solo al tuo account, identificato dall'UID nelle regole sul server e non nell'APK. Per chiunque altro il pannello dà «non autorizzato». Funziona su Spark e senza script.
B. **Gesto solo nelle build di sviluppo e script per il telefono reale.** La tua sequenza sostituisce i 7 tocchi sulla versione e apre il pannello solo con gli emulatori. Sul telefono reale usi lo script amministrativo dal Mac (Q3, opzione A).
C. **Gesto che sblocca solo la grafica sul telefono reale.** Mostra le funzioni Plus nell'app, ma il server continua ad applicare i limiti gratuiti. È lo sblocco meno utile.
X. Other (please specify)

[Answer]: Superata da Q6. Invece di scegliere un'opzione hai chiesto: «Voglio poter regalare l'app a delle persone come faccio?»

## Q6. [Proprietario del prodotto] Come sblocchi e regali Plus restando su Spark?

Seguito di Q3, Q5 e della domanda sul regalo. Restando su Spark non c'è backend, quindi l'unica autorità per Plus sono le regole Firestore. Gli inviti alla cantina funzionano già per email, tramite `request.auth.token.email`, e il regalo può seguire lo stesso schema.

A. **Pannello del proprietario aperto dalla tua sequenza segreta.** La sequenza (due tocchi sul logo Bottazzini nel Cruscotto, poi Cantina ×3, Storico ×3, Cantina, Storico, Cruscotto) apre un pannello. Lì scrivi l'email Google di una persona, tua compresa, e la durata: per esempio 1 anno o senza scadenza. Le regole permettono di scrivere i regali soltanto al tuo account: il tuo UID sta nelle regole sul server, non nell'APK. La persona riceve «Plus in regalo» al login successivo. Puoi anche revocarlo. Per chiunque altro la sequenza non apre nulla di utile. Nelle build di sviluppo lo stesso pannello offre anche i comandi di simulazione della sezione 9.2.
B. **Come A, ma con i regali gestiti da uno script sul Mac** invece che dal pannello nell'app. Nell'app la sequenza resta solo per le build di sviluppo.
X. Other (please specify)

[Answer]: B. Se  lo script eseguo passando una mail registrata e si sblocca tutto senza fare nulla allor facciamo lo script

## Q7. [Proprietario del prodotto] Plus si può comprare già adesso?

Su Spark non c'è un server che verifichi gli acquisti presso Google Play. Fidarsi di quello che dice l'app permetterebbe a chiunque di attivarsi Plus da solo, e lo studio lo vieta (sezione 5). Il pagamento vero quindi richiede un backend.

A. **Per ora solo Plus in regalo.** Scriviamo il codice di acquisto (plugin, schermata Plus con i prezzi di Play, ripristino) ma lo teniamo spento con un interruttore, `purchasesEnabled=false`. La schermata dice «Plus arriverà presto». Lo accendiamo quando passerai a Blaze e aggiungeremo la verifica.
B. **Non scriviamo nulla di acquisti in questo giro.** Solo il piano gratuito e Plus in regalo; il Billing arriva tutto insieme al passaggio a Blaze.
C. **Verifica su un servizio gratuito esterno** (per esempio Cloudflare Workers, piano gratis). Fa la verifica presso Play e scrive il diritto in Firestore. Plus diventa acquistabile subito restando su Spark, ma aggiunge un servizio da gestire e le relative credenziali.
X. Other (please specify)

[Answer]: Superata da Q8. Invece di scegliere un'opzione hai chiesto: «ahh ecco per questo che devo passare a Blaze? Non posso chiedere abbonamento?»

## Q8. [Proprietario del prodotto] Che cosa facciamo con l'abbonamento Plus?

Seguito di Q7. L'abbonamento si può vendere: Google Play incassa il pagamento. Quello che manca su Spark è un server che confermi che il pagamento è vero prima di sbloccare Plus. Passare a Blaze non vuol dire pagare: le quote gratuite restano, e le Cloud Functions includono 2 milioni di chiamate gratuite al mese, per cui con l'uso attuale la fattura sarebbe con ogni probabilità 0 €. Va però collegata una carta, e per Firestore non esiste un tetto di spesa garantito: gli avvisi segnalano la spesa, non la fermano (sezione 8.7 dello studio).

A. **Codice degli acquisti pronto ma spento.** Plugin, schermata Plus con i prezzi di Play e ripristino ci sono, ma restano spenti (`purchasesEnabled=false`, con la scritta «Plus arriverà presto»). In questo giro si regala Plus con lo script; il pagamento si accende con Blaze in un giro successivo.
B. **Niente acquisti in questo giro.** Solo il piano gratuito e Plus in regalo con lo script.
C. **Verifica su un servizio gratuito esterno** (Cloudflare Workers, gratis e senza carta). Plus diventa acquistabile subito restando su Spark, ma c'è un servizio in più da gestire, con le sue credenziali.
D. **Passo a Blaze adesso.** Facciamo anche il backend su Cloud Functions, con un avviso di spesa a 1 €, e Plus diventa acquistabile in questo giro.
X. Other (please specify)

[Answer]: X. Passiamo con Blaze solo SE NON SPENDO NIENTE per il passaggio e per uso. Abbiamo stessa soglia gratis di spark?

## Q9. [Proprietario del prodotto] Pagamento di Plus con la condizione «non spendo niente»

Seguito di Q8. Il passaggio a Blaze costa 0 € e le quote gratuite di Firestore restano le stesse di Spark: 50.000 letture, 20.000 scritture e 20.000 cancellazioni al giorno, 1 GiB di storage, 10 GiB/mese di traffico. Il backend userebbe servizi con una propria quota gratuita: Cloud Functions (2 milioni di chiamate al mese), Pub/Sub, Secret Manager, Cloud Build e 0,5 GB di Artifact Registry. Con l'uso attuale la previsione è 0 €. Però **0 € garantito non è possibile su Blaze**: serve una carta e Firestore non ha un tetto di spesa. Una spesa di pochi centesimi può comparire, per esempio per le immagini del backend in Artifact Registry oltre 0,5 GB o per un picco di traffico. Le protezioni possibili sono un avviso a 1 €, lo spegnimento automatico della fatturazione al superamento del budget (con un certo ritardo) e la pulizia automatica delle immagini. L'unica via davvero a costo zero e senza carta è la verifica su Cloudflare Workers gratis.

A. **Resto su Spark: codice degli acquisti pronto ma spento.** Plus si regala con lo script; il pagamento si accende più avanti.
B. **Verifica su Cloudflare Workers gratis.** Niente carta e niente costi possibili: se il piano gratuito si esaurisce, il servizio si ferma ma non addebita nulla. Plus diventa acquistabile restando su Spark, con un servizio in più da gestire.
C. **Blaze con le protezioni.** Avviso a 1 €, spegnimento automatico della fatturazione e pulizia delle immagini. Previsione 0 €, ma accetti il rischio residuo di pochi centesimi.
X. Other (please specify)

[Answer]: C
