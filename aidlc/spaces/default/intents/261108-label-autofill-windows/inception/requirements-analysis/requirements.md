# Requisiti — compilazione dall'etichetta e finestre di consumo per tutto il mondo (label-autofill-windows)

## Fonti

- Richiesta del proprietario (2026-11-07/08, messaggi f0867261, 2367b7fb, eb2f63eb): Lens legge bene, ma il testo non arriva nell'app; la base offline è un campione; serve un modo più semplice per registrare i nomi; la stima deve valere per tutti i vini del mondo, con "Livello" e correzione manuale.
- Richieste del proprietario al gate dei mockup (2026-11-08, messaggi 171e8ee1 e a1260ab6): usare Google Lens senza fare prima la foto in Vinoozy (FR2.6) e includere in questo lavoro il download di Open Food Facts e la base reale (FR6).
- Prova sul telefono in Build and Test (2026-11-08, messaggi 4e9809bc, c19931c2, 2089e55b 595f45dc e c40106d0): "Incolla da Lens" non mostrava niente (FR2.8); il proprietario chiede una conferma guidata dei campi incerti (FR7), di comporre un valore toccando più parole (FR7.5) e di scegliere l'annata con una ruota (FR7.4).
- `requirements-analysis-questions.md`: Q1 = A, Q2 = A più il pulsante "Pulisci", Q3 = A, Q4 = A, Q5 = A, Q6 = A.
- `codekb/Vinoozy/`, aggiornata da questo lavoro (Reverse Engineering 2026-11-08).
- `project.md`: le scelte enologiche le decide l'agente, le motiva e il proprietario può correggerle.

## Analisi dell'intento

Il proprietario vuole registrare la cantina in fretta partendo dall'etichetta, anche quando il vino non è in nessuna base. Ha visto che Google Lens legge il testo molto bene, ma il risultato resta in Google.

Obiettivi:
1. **Dall'etichetta al modulo compilato.** Dal testo letto dalla foto, oppure copiato o condiviso da Lens, Vinoozy ricava i campi e compila il modulo. Il proprietario controlla e salva.
2. **Stima valida per ogni vino del mondo.** Oggi la finestra di consumo è affidabile solo per 47 denominazioni italiane. Deve coprire le principali denominazioni del mondo e, come rete di sicurezza, i vitigni.
3. **La qualità conta.** Il nuovo "Livello" distingue un vino quotidiano da uno da invecchiamento con la stessa denominazione.
4. **L'ultima parola è del proprietario.** Il proprietario può correggere "Consigliato fino al", e la correzione non si perde.

## Requisiti funzionali

### FR1 — Compilazione dal testo dell'etichetta

- **FR1.1** Dal testo letto (fronte, retro o testo incollato) Vinoozy ricava, quando li trova:
  - nome;
  - produttore;
  - denominazione;
  - annata;
  - tipo di vino;
  - paese;
  - regione.

  I campi non trovati restano vuoti. "Nessun campo inventato" significa che ogni valore compilato deve comparire nel testo, oppure derivare da una tabella a partire da una parola che compare nel testo (per esempio paese e regione da "Rioja", tipo da "Rosso"). Criteri verificabili:
  - **Insieme di riferimento.** In Functional Design si fissano almeno 30 testi di etichette, in italiano, francese, spagnolo, inglese, tedesco e portoghese, tra cui testi copiati da Lens con righe spezzate e rumore. Per ognuno si scrive il risultato atteso campo per campo.
  - **Soglie.** Su quell'insieme:
    - nessun campo è sbagliato quando è compilato (precisione 100% sui campi compilati);
    - nome e annata sono compilati in almeno il 90% dei testi che li contengono;
    - la denominazione è compilata in almeno l'80% dei testi che contengono una denominazione presente nelle tabelle.
  - **Annata ambigua.** Con più anni plausibili (per esempio un anno di fondazione e un'annata), vale la regola di oggi del lettore dell'annata. Se resta il dubbio, l'annata si lascia vuota.
- **FR1.2** Quando la lettura della foto non trova il vino in nessuna base (offline, catalogo interno, Open Food Facts), si apre subito il modulo di aggiunta compilato con i campi di FR1.1, al posto della schermata "Non trovato" (Q2 = A). "Cerca online" e "Apri in Google Lens" restano raggiungibili dal modulo. Se il testo è illeggibile (nessuna riga utile), resta la schermata "Non trovato" di oggi.
- **FR1.3** Il modulo compilato mostra quali campi sono stati riempiti dal testo, con un segno visivo che il lettore di schermo annuncia. Tutti i campi restano modificabili.
- **FR1.4** Il modulo ha un pulsante **"Pulisci"** (Q2, richiesta del proprietario), presente quando almeno un campo è stato compilato dal testo.
  - **Cosa svuota.** Svuota **tutti i campi descrittivi**: nome, produttore, denominazione, annata, tipo, paese, regione e "Livello", che torna "non scelto". Toglie anche i segni di FR1.3.
  - **Cosa lascia.** Quantità, posizione e note restano come sono.
  - **Conferma.** Se l'utente ha scritto a mano in almeno uno dei campi da svuotare, l'app chiede conferma ("Svuotare anche i campi scritti da te?"). Altrimenti svuota subito.
  - **Dopo.** Il modulo resta aperto, vuoto e pronto per scrivere a mano o per incollare di nuovo.
- **FR1.5** Ogni campo ricavato da FR1.1 passa la stessa validazione del modulo di oggi: lunghezze, annata tra 1900 e l'anno corrente più 1, paese e regione validi.
- **FR1.6** Quando il testo contiene una denominazione presente anche nella base offline o nel catalogo, il flusso di oggi non cambia: la proposta sicura e i candidati vengono prima. FR1.2 interviene solo quando il risultato è "non trovato".

### FR2 — "Incolla da Lens"

- **FR2.1** In Lens il proprietario tocca "Condividi" e sceglie Vinoozy. Vinoozy riceve il testo e apre il modulo compilato con FR1.1 (Q1 = A).
  - **App chiusa o in secondo piano.** Si apre la Cantina e poi il modulo, come per le immagini condivise di oggi.
  - **Senza accesso.** Prima l'accesso, poi il modulo con il testo, che resta in memoria e non su disco.
  - **Modulo aperto con dati non salvati.** Si chiede se sostituire i campi vuoti (FR2.4) o ignorare il testo condiviso.
  - **Testo vuoto o solo spazi.** Messaggio "Nessun testo ricevuto" e nessun modulo.
  - **Testo lungo.** Si tronca a 4000 caratteri (FR2.3).
  - **Filtro Android.** Si aggiunge a quello per le immagini condivise, che continua a funzionare come oggi.
- **FR2.2** Nel modulo di aggiunta c'è **un solo** pulsante **"Incolla da Lens"**. Con un tocco legge tutto il testo copiato e Vinoozy riconosce da solo nome, produttore, denominazione, annata, tipo, paese, regione e Livello suggerito, poi compila tutti i campi insieme (FR1.1). L'utente non incolla campo per campo. Se il testo porta a un vino certo nella base, si propone quel vino (FR2.5). Se gli appunti sono vuoti o non contengono testo, compare un messaggio e il modulo non cambia (richiesta del proprietario, messaggio 8abc29f0).
- **FR2.7** **Incolla automatico al ritorno da Lens.** Il proprietario ha chiesto di ridurre al minimo il lavoro, quindi quando l'utente è partito da "Da Google Lens" (FR2.6) e torna in Vinoozy entro 5 minuti, Vinoozy legge gli appunti **una volta da sola** e compila il modulo come FR2.2, senza nessun tocco.
  - **Avviso di Android.** Su Android 12 e successivi il sistema mostra un avviso del tipo "Vinoozy ha incollato dagli appunti". È previsto e va bene.
  - **Appunti vuoti o senza testo.** Non succede niente e resta il pulsante "Incolla da Lens".
  - **Non funziona al tocco.** Se il sistema non lascia leggere gli appunti senza un tocco, resta il pulsante. Si verifica sul telefono in Build and Test.
  - **Testo già usato.** Il testo di Lens usato una volta non si incolla di nuovo da solo.
  - **Solo testo nuovo.** L'incolla automatico scatta solo se gli appunti sono stati copiati **dopo** l'apertura di Lens. Lo si verifica con l'ora di copia che Android associa agli appunti (`ClipDescription.getTimestamp()`), senza leggere il contenuto. Il testo che c'era prima di aprire Lens non si legge mai da solo.
  - **I 5 minuti.** Partono da quando Vinoozy apre Lens.
  - **Annuncio.** A modulo compilato, il lettore di schermo annuncia "Modulo compilato dal testo di Lens".
- La via con zero tocchi in Vinoozy è "Condividi" → Vinoozy da Lens (FR2.1).
- **FR2.3** Il testo ricevuto o incollato serve solo a compilare il modulo e si tronca a 4000 caratteri, come il testo unito dell'etichetta. Non finisce:
  - su disco;
  - in Firestore;
  - nei servizi esterni;
  - in Crashlytics;
  - nella console;
  - in `CatalogEventLogger`;
  - nei messaggi di errore.

  Gli eventi possono contenere solo conteggi e tipi, come oggi. Fa eccezione la ricerca su Open Food Facts (FR2.5): parte solo con rete e con la stessa regola di "Cerca online", cioè manda solo le parole della query.
- **FR2.4** Se il modulo ha già dei campi compilati, incollare o condividere sostituisce solo i campi vuoti. Per sostituire tutto si usa prima "Pulisci" (FR1.4).
- **FR2.5** Prima di cercare nella base, il testo incollato passa dagli stessi gradini della lettura della foto (FR1.6). Se il vino viene trovato con certezza, si propone il vino trovato. Altrimenti si compila con FR1.1.

- **FR2.6** **"Da Google Lens"** è un ingresso diretto, senza scattare la foto in Vinoozy (richiesta del proprietario al gate dei mockup, messaggio a1260ab6). Si trova nella schermata di scelta "Aggiungi vino" e nel modulo vuoto.
  - **Cosa apre.** Apre subito Google Lens: l'app Lens se c'è, altrimenti Lens dentro l'app Google.
  - **Senza Lens.** Se sul telefono non si può aprire nessuna delle due, compare un pannello con l'istruzione "Apri Google Lens, inquadra l'etichetta, seleziona il testo e tocca Condividi → Vinoozy".
  - **Ritorno in Vinoozy.** Il testo torna con FR2.1 (Condividi) o con FR2.2 (Copia e "Incolla da Lens").
  - **Verifica.** Che Lens si apra sul telefono del proprietario si verifica in Build and Test.

- **FR2.8** **Risposta entro 2 secondi** (difetto trovato sul telefono, messaggio 4e9809bc).
  - **Da quando a quando.** Il tempo va dal tocco su "Incolla da Lens", o dalla lettura degli appunti nell'incolla automatico, al primo fotogramma che mostra uno di questi risultati: il modulo compilato, la proposta di un vino certo, la prima domanda della guida (FR7) o un messaggio. Per il testo condiviso il tempo parte quando il modulo è visibile. Avvio dell'app e accesso non sono compresi (FR2.1).
  - **Attesa visibile.** Dal tocco fino al risultato, il pulsante mostra un indicatore di attesa e non accetta un secondo tocco.
  - **Ricerca a tempo.** La ricerca nella base offline, nel catalogo e su Open Food Facts ha al massimo 1,5 secondi, **compresa** l'apertura della base se è ancora chiusa. Se il tempo scade, il modulo si compila dal testo. La ricerca finisce in sottofondo e prepara solo i dati per il prossimo incolla, senza cambiare il modulo.
  - **Il resto del tempo.** I 500 ms restanti coprono lettura degli appunti, estrazione dei campi (NFR4, al massimo 200 ms), calcolo dei candidati di FR7 (al massimo 100 ms nel benchmark) e disegno.
  - **Base già aperta.** Mentre l'utente è in Lens, Vinoozy apre la base offline in anticipo.
  - **Verifica.** Un e2e in CI misura i 2 secondi con la base reale aperta a freddo e Open Food Facts che non risponde (NFR5.9). Sul telefono del proprietario si ripete la prova che aveva mostrato il difetto, e il risultato si riporta in Build and Test.

### FR3 — Finestre di consumo per i vini di tutto il mondo

- **FR3.1** La tabella delle denominazioni è **la più completa possibile** (richiesta del proprietario, messaggio 03977a27). Per arrivarci:
  - **Unione europea.** Tutte le denominazioni del vino (DOP/IGP: DOCG, DOC, IGT, AOC, IGP, DO, DOCa e simili) del registro pubblico UE **eAmbrosia**.
  - **Fuori dall'UE.** Le zone ufficiali di Stati Uniti (AVA), Australia, Nuova Zelanda, Sudafrica, Argentina, Cile, Brasile, Uruguay e Svizzera.
  - **Quantità.** In tutto **almeno 1500 denominazioni**.
  - **Contenuto di ogni riga.** Paese, regione quando si può collegare a `WineOrigins`, uno o più tipi e una finestra per ciascun tipo. Le principali (almeno 200) hanno qualifiche e valori decisi una per una; le altre hanno la finestra da un modello per paese, regione e stile.
- **FR3.2** Una nuova tabella dei **vitigni** (almeno 40 vitigni rossi e bianchi internazionali e autoctoni principali) dà la finestra quando la denominazione non è riconosciuta. Ordine di precedenza:
  1. denominazione;
  2. vitigno;
  3. tipo scelto;
  4. riga generica di oggi.
- **FR3.3** I valori enologici li decide l'agente, con una motivazione per ogni riga, nei file di progetto. Il proprietario può chiedere di correggerli. Ogni riga ha il suo test.
- **FR3.4** I nomi delle denominazioni e dei vitigni si riconoscono nel nome del vino, nel campo denominazione e nel testo dell'etichetta, con la stessa normalizzazione di oggi (minuscole, senza accenti, parole intere). Riconoscere una denominazione estera compila anche paese e regione, in modo coerente con l'elenco delle origini di oggi.

  Precedenze e conflitti:
  - **Denominazione e vitigno insieme.** Vince la denominazione (per esempio "Barolo" più "Nebbiolo" dà Barolo).
  - **Più denominazioni nello stesso testo.** Vince la più lunga e specifica (per esempio "Chianti Classico" prima di "Chianti").
  - **Paese scelto e paese ricavato.** Il paese scelto dall'utente vince sempre. Una denominazione di un altro paese non lo cambia: si usa solo per la stima.
  - **Nomi ambigui.** Un nome che è insieme denominazione e vitigno (per esempio "Barbera", "Primitivo", "Rioja" contro "Tempranillo") vale come denominazione solo se la tabella delle denominazioni lo contiene con quella grafia, altrimenti come vitigno.

  Le due tabelle (stima e origini) usano la stessa normalizzazione e restano coerenti: un test controlla che ogni denominazione estera della stima abbia il paese nell'elenco delle origini.
- **FR3.5** Le stime dei vini già in cantina si aggiornano con le nuove tabelle al prossimo aggiornamento della stima, come oggi. Non si aggiorna un vino con correzione manuale (FR5).

### FR4 — Campo "Livello"

- **FR4.1** Nuovo campo facoltativo del vino, "Livello", con tre valori, ognuno con esempi nel modulo (richiesta del proprietario, messaggio 8abc29f0):
  - **Quotidiano (economico)**, per esempio vino sfuso o della casa, Lambrusco, Prosecco base, Bardolino, un Vinho Verde;
  - **Buono**, per esempio Chianti Classico, Barbera d'Asti Superiore, Rioja Crianza, un Côtes du Rhône;
  - **Da invecchiamento**, per esempio Barolo, Brunello di Montalcino, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.

  Gli esempi aiutano a scegliere e non cambiano il calcolo. Se non è scelto vale "Buono", cioè la stima di oggi senza cambiamenti (Q3 = A).
- **FR4.2** Il livello sposta la finestra calcolata da FR3:
  - "Quotidiano" la accorcia;
  - "Da invecchiamento" la allunga.

  I fattori li decide l'agente in Functional Design, con motivazione. Le date restano coerenti: pronto ≤ al massimo ≤ declino, e mai prima dell'annata.
- **FR4.3** L'app propone il livello "Da invecchiamento" quando il nome, la denominazione o il testo contengono qualifiche come Riserva, Gran Selezione, Gran Reserva, Grand Cru, Premier Cru o Auslese. Il proprietario può sempre cambiarlo.
  - **Livello scelto a mano.** Dal momento in cui l'utente tocca un valore, compreso "Buono", il livello è "scelto": la proposta non lo cambia più, nemmeno se il nome viene modificato.
  - **Livello non ancora scelto.** La proposta si ricalcola a ogni modifica del nome o della denominazione.
  - **Dati salvati.** Si salva solo un livello scelto o accettato. "Non scelto" non si salva e vale "Buono" (FR4.1).
- **FR4.4** Il livello compare nel modulo di aggiunta, nel modulo di modifica e nel dettaglio del vino.

### FR5 — Correzione manuale di "Consigliato fino al"

- **FR5.1** Nel dettaglio del vino il proprietario può correggere "Consigliato fino al", cioè l'**anno di fine finestra** (`endYear`), scegliendo un anno (Q4 = A).
  - **Limiti.** Il nuovo anno deve essere almeno l'anno di "Pronto da" (`startYear`) e al massimo `startYear` più 60.
  - **Anno del massimo.** Se l'anno corretto cade prima dell'anno del massimo (`peakYear`), l'anno del massimo si abbassa allo stesso anno, così pronto ≤ al massimo ≤ fine resta vero. "Pronto da" non cambia mai.
- **FR5.6** La correzione manuale e l'adeguamento dopo le bevute (`windowAdjustment`, quando il proprietario dice "era pronto prima o dopo") lavorano così:
  - **Prevalenza sulla fine.** L'anno di fine corretto a mano **prevale sempre**.
  - **Pronto e massimo.** L'adeguamento può ancora spostarli, ma senza superare l'anno corretto.
  - **Fine.** Un nuovo adeguamento non cambia la fine finché la correzione c'è.
  - **"Ripristina stima".** Toglie solo la correzione. L'adeguamento dalle bevute resta valido.
- **FR5.2** Un vino con correzione manuale mostra "Consigliato fino al <anno> (corretto da te)" al posto di "⚠︎ Indicativo".
- **FR5.3** La correzione resta valida quando si modifica il vino, quando la stima si aggiorna e quando si ricalcola dopo una bevuta: nessuno dei tre punti che oggi sovrascrivono la finestra la cancella.
- **FR5.4** "Ripristina stima" toglie la correzione e torna alla finestra calcolata dall'app.
- **FR5.5** Gli stati del vino (da bere, al massimo, oltre il momento) e la Dashboard usano la data corretta quando c'è.

### FR6 — Base reale dei vini da Open Food Facts

- **FR6.1** In Build and Test, con l'OK del proprietario (messaggio a1260ab6), si scarica l'export pubblico e gratuito di Open Food Facts. Si genera la base reale con `tool/build_wine_db.dart` e si sostituisce la base di prova di 45 vini in `assets/wine_db/`.
- **FR6.2** La base reale rispetta i controlli che esistono già:
  - almeno 5000 vini, nessun doppione, export di al massimo 180 giorni;
  - al massimo 3 MB compressa e **30 MB di dati** (limite del proprietario);
  - il manifesto ha `source` = Open Food Facts e passa `tool/check_wine_db_release.sh`.
- **FR6.3** Con la base reale si misurano sul telefono del proprietario:
  - dimensione dell'app;
  - apertura della base;
  - memoria.

  Sono i requisiti rimasti aperti nel lavoro precedente (NFR1.1, NFR2.3, NFR2.5 di label-recognition), e i risultati si riportano in Build and Test.
- **FR6.4** L'export scaricato non entra nel repository. Entrano solo la base generata, il manifesto, il `README` e la licenza ODbL.

### FR7 — Conferma guidata dei campi incerti

Richiesta del proprietario dopo la prova sul telefono (messaggi 4e9809bc, c19931c2, 595f45dc): quando Vinoozy non capisce con certezza un campo dal testo, lo chiede con una domanda semplice, una alla volta, con il minimo lavoro.

- **FR7.1** **Quando parte** (Q5 = A). La guida parte da sola, solo se almeno uno dei campi chiave è **incerto**, dopo:
  - "Incolla da Lens" (FR2.2);
  - il testo condiviso (FR2.1);
  - il modulo compilato dalla foto (FR1.2);
  - l'incolla automatico (FR2.7). Q5 nomina gli altri tre; l'incolla automatico è lo stesso incolla senza tocco, quindi segue la stessa regola.

  Non parte quando:
  - tutti i campi chiave sono certi: il modulo si compila come oggi, senza domande;
  - il testo porta a un vino certo nella base (FR2.5): vale la proposta di quel vino.
- **FR7.2** **Campi chiave** (Q6 = A): denominazione, produttore, nome e annata, chiesti in quest'ordine. Tipo, paese e regione non si chiedono: seguono dalla denominazione confermata, come in FR1.1. Un campo già scritto a mano dall'utente non si chiede (FR2.4).
- **FR7.3** **Campo certo e campo incerto.** L'estrattore di FR1.1 dà per ogni campo chiave una lista ordinata di candidati, ognuno con un punteggio da 0 a 1. Il campo è **certo** quando c'è un primo candidato con punteggio pari o superiore alla soglia di certezza e un distacco minimo dal secondo; altrimenti è **incerto**. Soglia e distacco si fissano in Functional Design.
  - **Senza guida.** Un campo certo si compila; un campo incerto resta vuoto. Le soglie di FR1.1 valgono sui soli campi certi: precisione 100%, nome e annata almeno 90%, denominazione almeno 80%. La regola dell'annata ambigua di FR1.1 vale ancora: un'annata ambigua è incerta e va nella guida.
  - **Insieme di riferimento.** Si porta a **almeno 60 testi**. Per ogni campo chiave, almeno 15 testi lo hanno incerto, e almeno 10 in tutto non hanno il valore giusto tra i candidati. L'insieme scrive, campo per campo, il valore giusto e se ci si aspetta che il campo sia certo o incerto.
  - **Criteri.** Sull'insieme:
    - nessun campo certo è sbagliato;
    - nei campi incerti che hanno il valore giusto tra i candidati, il valore giusto è al primo posto in almeno il 70% dei casi e tra i primi 3 in almeno il 90%;
    - in media al massimo 2 campi incerti per testo, e mai più di 4, cioè tutti i campi chiave.
  - **Campo assente** (decisione del proprietario al gate di Functional Design, messaggio 83b451cf). Denominazione, produttore o nome senza nessun candidato né indizio nel testo sono **assenti**: restano vuoti e non si chiedono. L'annata non è mai assente: senza anni plausibili si chiede con la ruota.
  - **Soglie di FR1.1** (stessa decisione). Si misurano sui campi attesi certi dell'insieme di riferimento; sui campi certi la precisione resta 100%.
  - **Testo breve** (stessa decisione). In un testo di al massimo 3 righe utili, una denominazione delle tabelle in testa a una riga conta come certa anche senza DOC/AOC (BR7 in Functional Design).
  - **Composti a mano.** I valori scritti con "Modifica" o composti toccando le parole (FR7.5) sono scelte dell'utente e non contano in queste soglie.
- **FR7.4** **La domanda.** Ogni domanda mostra il campo e il valore proposto, per esempio "Cascina Castlet: è il produttore?". Sotto ci sono le parole del testo da toccare (FR7.5), tranne per l'annata, che ha la ruota degli anni (vedi sotto). Le scelte sono:
  - **Sì**: compila il campo con il segno di FR1.3 e passa alla domanda successiva;
  - **No**: propone il candidato successivo per lo stesso campo. Quando i candidati finiscono, la domanda resta aperta con l'avviso "Nessun'altra proposta": restano parole, Modifica e Salta, e il campo resta vuoto solo con Salta o alla chiusura. Un valore rifiutato non torna più;
  - **Modifica**: apre il campo da scrivere a mano, già riempito con il valore proposto. "Conferma" compila il campo; con il valore vuoto lascia il campo vuoto; un valore non valido mostra l'errore della validazione (FR1.5) e la domanda resta aperta;
  - **Salta**: lascia il campo vuoto e passa alla domanda successiva.

  **Annata** (richiesta del proprietario, messaggio c40106d0). Per l'annata, al posto delle parole del testo c'è una **ruota degli anni**:
  - parte dall'anno trovato nel testo, se c'è; altrimenti dall'anno corrente meno 2 (nel 2026, il 2024);
  - va dal 1900 all'anno corrente più 1, come la validazione di FR1.5;
  - gli altri anni trovati nel testo sono segnati nella ruota per sceglierli in fretta;
  - con più anni plausibili parte dal candidato con il punteggio più alto (FR7.3); gli altri sono segnati;
  - un tocco sull'anno al centro apre la tastiera numerica per scrivere un anno lontano senza scorrere;
  - "Conferma" compila l'annata; "Senza annata" la lascia vuota e **conta come risposta**: la guida non la richiede più, nemmeno con un nuovo testo per lo stesso modulo; "Salta" la lascia vuota senza risposta;
  - per l'annata non ci sono "No" e "Modifica": la ruota li sostituisce, e i candidati di FR7.5 sono gli anni segnati.

  Quando nel testo non c'è nessun anno plausibile l'annata è incerta (FR7.3), quindi la guida chiede l'annata con la ruota anche se gli altri campi sono certi.

  Ogni campo ha al massimo 5 candidati, quindi al massimo 5 "No". In tutto la guida chiede al massimo 4 domande, una per campo chiave; i "No" non aggiungono domande.
- **FR7.5** **Comporre il valore toccando le parole** (richiesta del proprietario, messaggio 595f45dc). Sotto la domanda ci sono le parole del testo letto, come pulsanti.
  - **Come funziona.** L'utente tocca una o più parole, per esempio "Barbera" e poi "d'Asti". Un'anteprima mostra il valore composto ("Barbera d'Asti"). Un secondo tocco su una parola scelta la toglie. "Conferma" compila il campo con l'anteprima, come "Sì". Con nessuna parola scelta, "Conferma" non è attivo.
  - **Ordine.** Il valore segue l'**ordine del testo**, non quello dei tocchi: "d'Asti" toccato prima di "Barbera" dà comunque "Barbera d'Asti". Si possono scegliere anche parole non vicine, per esempio dal produttore su una riga e dal nome su un'altra. Tra due parole c'è sempre uno spazio.
  - **Che cos'è una parola.** Una parola è un gruppo di caratteri tra spazi. Apostrofi e trattini restano dentro la parola: "d'Asti" e "Saint-Émilion" sono una parola sola. Punteggiatura iniziale e finale (virgole, punti, due punti) si toglie.
  - **Quali parole si vedono.** Si vedono le parole di tutte le righe nell'ordine del testo, una riga sotto l'altra, scorrevoli, al massimo 120. Si tolgono le parole di una sola lettera, i numeri che non sono anni plausibili, e le righe che sono solo gradi, volume o indirizzi web. Le parole già confermate per un altro campo restano selezionabili, con il segno "usata per …" (decisione del proprietario, messaggio 83b451cf).
  - **Limiti.** Al massimo 8 parole e 80 caratteri per valore; oltre, le altre parole sono disattivate. Il valore passa la validazione del campo (FR1.5).
  - **Denominazione.** Se il valore composto è uguale, senza maiuscole e accenti, a un nome o a un alias delle tabelle di FR3.1, l'anteprima mostra il nome della tabella (per esempio "Barbera d'Asti DOCG"), e il campo prende quello. Con più corrispondenze vale la stessa regola di scelta della stima (BR1 in Functional Design), e la scelta resta modificabile. Altrimenti il campo prende il valore come è composto.
- **FR7.6** **Forma.** È una scheda in basso sopra il modulo, con il progresso: "Domanda 2 di 3", dove il totale è il numero dei campi incerti, fissato all'inizio. Il progresso non cambia con i "No". Alla fine la scheda si chiude e resta il modulo, modificabile, con "Salva". Niente si salva senza "Salva".
- **FR7.7** **Interruzioni e casi limite.**
  - **Chiusura.** La scheda si chiude in ogni momento con "Chiudi", con il tasto Indietro o toccando fuori. I campi già confermati restano; quelli non ancora chiesti restano vuoti. Si può riaprire con il pulsante "Conferma guidata", che compare nel modulo finché resta almeno un campo incerto non risposto.
  - **Nuovo testo.** Se arriva un nuovo testo (incolla, condivisione o incolla automatico) mentre la guida è aperta, la guida in corso si chiude tenendo i campi confermati. Il nuovo testo segue FR2.4: riempie solo i campi vuoti e, se servono, apre una nuova guida.
  - **Modifica del modulo.** Il modulo sotto la scheda resta coperto. Un campo scritto a mano mentre la guida è chiusa non si chiede più.
  - **Rotazione e secondo piano.** Con la rotazione o il ritorno dal secondo piano la guida riprende alla stessa domanda. Se Android chiude l'app, la guida e il testo si perdono (FR2.3): il modulo riparte com'era nell'ultimo stato salvato da Android, senza guida.
  - **Dopo la denominazione.** Una denominazione confermata ricava tipo, paese e regione come in FR1.1 e ricalcola il "Livello" suggerito (FR4), se l'utente non l'ha scelto a mano.
  - **Pulisci.** "Pulisci" (FR1.4) chiude la guida e svuota anche le risposte date.
- **FR7.8** **Accessibilità e lingue.**
  - Scheda, pulsanti e parole sono nelle 3 lingue e annunciati dal lettore di schermo: "Domanda 2 di 3: Cascina Castlet è il produttore?", ogni parola come pulsante selezionabile, e l'anteprima letta a ogni cambio.
  - Pulsanti e parole sono di almeno 48 dp e restano utilizzabili con testo 2,0.
  - Vale la matrice di NFR6.
- **FR7.9** **Privacy.** Candidati e parole restano solo in memoria, come il testo (FR2.3), e non finiscono in log, eventi o Firestore.

## Requisiti non funzionali

- **NFR1 Compatibilità dei dati.**
  - **NFR1.1** I vini già salvati senza "Livello" e senza correzione restano validi e si comportano come oggi.
  - **NFR1.2** Le nuove regole Firestore accettano:
    - il campo `level`, facoltativo, con i valori `everyday`, `good`, `aging`;
    - la correzione manuale, facoltativa, che contiene solo l'anno di fine corretto e la data della correzione;
    - i nuovi valori di `basis` della finestra: `grape` per la stima da vitigno, insieme a quelli di oggi;
    - le nuove `qualifier` delle denominazioni estere.

    I nomi esatti dei campi si fissano in Functional Design.
  - **NFR1.3** Le nuove regole accettano anche le scritture della versione attuale dell'app, che non conosce i campi nuovi: lo verificano i test di compatibilità in `test/rules/compat/`.
  - **NFR1.4** Una versione vecchia dell'app, ancora installata, che modifica un vino con "Livello" o con correzione non deve cancellarli né fallire. Lo verifica un test di compatibilità. Se le regole non lo garantiscono, la versione vecchia vede l'errore di salvataggio di oggi e il dato resta intatto.
  - **NFR1.5** Le regole nuove si pubblicano prima di installare la nuova build, con l'OK del proprietario. Se una build nuova scrive campi nuovi con le regole vecchie, il salvataggio fallisce con il messaggio di oggi e nessun dato va perso. Una voce in `RULES_FEATURES` di `promote.yml` impedisce di promuovere la build prima delle regole.
- **NFR2 Offline e nessun costo.**
  - Compilazione dal testo, "Incolla da Lens" e stima funzionano senza rete.
  - Nessun servizio a pagamento né pacchetto nuovo a pagamento.
  - Le tabelle sono costanti nel codice, come oggi.
- **NFR3 Privacy.**
  - **NFR3.1** Gli appunti si leggono solo in due casi: al tocco di "Incolla da Lens", oppure una volta da soli al ritorno da "Da Google Lens" entro 5 minuti (FR2.7). Mai all'avvio dell'app né in altri momenti.
  - **NFR3.2** Il testo condiviso o incollato segue FR2.3: nessuna copia su disco, in Firestore, in Crashlytics, nei log o nei messaggi di errore.
  - **NFR3.3** Nessun permesso Android nuovo. Servono due dichiarazioni nel manifest:
    - un filtro di intent `ACTION_SEND` `text/plain` per ricevere il testo, accanto a quello per le immagini;
    - la voce `<queries>` per il pacchetto `com.google.ar.lens`, per aprire Lens (FR2.6).
- **NFR4 Velocità.** La compilazione dal testo (4000 caratteri) richiede al massimo 200 ms nel benchmark della CI, che è il criterio di superamento. Sul telefono del proprietario si misura e si riporta in Build and Test, con un obiettivo di 100 ms. La stima con le nuove tabelle resta entro i limiti del benchmark di oggi.
- **NFR5 Test.**
  - **NFR5.1** Copertura ≥ 80% delle righe sul progetto senza esclusioni, e ≥ 90% sul pacchetto `estimation`, come oggi.
  - **NFR5.2** Un test per ogni riga delle nuove tabelle, più l'insieme di riferimento di FR1.1.
  - **NFR5.3** Test delle regole per i nuovi campi e test di compatibilità (NFR1.2–NFR1.4).
  - **NFR5.4** Un e2e per "Incolla da Lens" o "Condividi" e uno per la correzione manuale, con dati finti e senza Google.
  - **NFR5.5** Suite esistente verde.
  - **NFR5.8** Per la guida:
    - test unitari dei candidati e della certezza sull'insieme di riferimento di FR7.3;
    - test unitari della composizione toccando le parole (FR7.5): ordine, apostrofi, limiti, corrispondenza con le tabelle;
    - test dei widget della scheda nella matrice di accessibilità di NFR6;
    - un e2e della guida con Sì, No, Modifica, Salta, composizione, Indietro e un nuovo testo a guida aperta.
  - **NFR5.9** Un e2e misura i 2 secondi di FR2.8 con la base reale aperta a freddo e Open Food Facts che non risponde. Un benchmark misura il calcolo dei candidati (al massimo 100 ms per 4000 caratteri).
- **NFR6 Stile e lingue.**
  - Codice e commenti in inglese.
  - Testi nei 3 file ARB.
  - La matrice di accessibilità esistente (3 lingue × testo 1,0/2,0 × chiaro/scuro) vale anche per i componenti nuovi.

## Vincoli

- Si lavora sul codice non committato di oggi (UX e riconoscimento delle etichette). Non si cambia il comportamento approvato salvo FR1.2, che sostituisce "Non trovato" quando ci sono campi.
- Le regole Firestore del progetto reale `vinoozy-d6f45` si pubblicano solo con l'OK del proprietario.
- Nessuna chiamata reale a Google o Open Food Facts nei test.

## Assunzioni

- Google Lens permette di condividere il testo selezionato con altre app, con un'intent `ACTION_SEND` `text/plain`. Si verifica sul telefono del proprietario in Build and Test.
- Un vino con un solo livello e una sola correzione basta: non servono livelli per annata o per bottiglia.

## Fuori ambito

- Lettura dei risultati di Google Lens senza un'azione del proprietario: non è possibile.
- Il doppione dello Storico e "Annulla" (lavoro dedicato).
- Correzione di "Pronto da" (Q4 = A).

## Domande aperte

Nessuna per il proprietario. Fattori del Livello, contenuto delle tabelle e regole di estrazione dei campi si decidono in Functional Design.
