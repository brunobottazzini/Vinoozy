# Requirements — Vinoozy (prima versione)

Fonti: `intent-statement.md` (Intent Capture), `scope-document.md` e `intent-backlog.md` (Scope Definition), `feasibility-assessment.md` e `constraint-register.md` (Feasibility), `wireframes.md` (Rough Mockups), `team-practices.md` (Practices Discovery), risposte in `requirements-analysis-questions.md`.

## Intent analysis

Il proprietario di una cantina personale (meno di 100 bottiglie) vuole **non perdere nessuna bottiglia** oltre il suo momento ideale e avere l'inventario **allineato alla cantina reale**, aggiungendo una bottiglia in **meno di 30 secondi** (intent-statement). L'app stima da sola il momento ideale (intent-statement, Q10), mostra cosa è pronto con grafici e suggerisce gli abbinamenti; la cantina si può gestire in più persone (scope-document). Tipo di lavoro: nuovo prodotto, più componenti (app, sincronizzazione cloud, stima), complessità standard.

## Functional requirements

### FR1 — Accesso e account
- **FR1.1** Il sistema consente l'accesso con un account Google. *(scope-document)*
  - Given l'app al primo avvio con rete, When tocco "Continua con Google" e completo l'accesso, Then vedo il Cruscotto.
  - Given l'accesso annullato o fallito, When torno all'app, Then vedo "Accesso non riuscito" con "Riprova" e nessun dato viene creato.
- **FR1.2** La sessione resta attiva tra un avvio e l'altro, anche senza rete, finché l'utente non esce. *(constraint-register C3)*
- **FR1.3** L'utente può uscire dall'account dal profilo.
- **FR1.4** L'utente può cancellare il proprio account dall'app; la cancellazione elimina la sua cantina, lo storico e le condivisioni che ha concesso, dopo una conferma che nomina cosa verrà eliminato. *(obbligo Google Play per app con account; feasibility-assessment)* *(2026-11-06, u6: tolte le foto, che non si conservano più)*

### FR2 — Inserimento di un vino
- **FR2.1** L'utente aggiunge un vino scrivendone il nome (es. "Barolo 2016"); il sistema propone vini corrispondenti mentre scrive. *(intent-statement)*
- **FR2.2** L'utente aggiunge un vino fotografando l'etichetta; il sistema legge il testo sul telefono e propone il vino riconosciuto. *(intent-statement, scope-document)*
  - *(2026-11-06, richiesta del proprietario in u6)* La foto può anche essere importata dalla galleria, o condivisa dalla galleria verso l'app, per aggiungere più tardi un vino fotografato in giro.
  - Given un'etichetta illeggibile, When scatto la foto, Then vedo "Non riesco a leggere l'etichetta" e il pulsante "Scrivi a mano" con il campo già aperto.
  - Given il permesso fotocamera negato, When tocco "Scatta foto", Then vedo una spiegazione e il collegamento alle impostazioni.
- **FR2.3** Nessun vino viene salvato senza la conferma esplicita dell'utente, in entrambi i percorsi; "Correggi" apre l'inserimento scritto già compilato con la proposta. *(feasibility-assessment; revisione mockup R-01)*
- **FR2.4** In entrambi i percorsi l'utente indica la quantità (da 1 a 99, predefinita 1). *(Q2; revisione mockup R-01)*
- **FR2.5** Un vino è identificato da nome, produttore (se noto) e annata; aggiungere un vino già presente aumenta la quantità della voce esistente invece di crearne una nuova, dopo averlo mostrato all'utente. *(Q2)*
- **FR2.6** Validazione: nome obbligatorio (non vuoto, massimo 120 caratteri); annata tra 1900 e l'anno corrente oppure "senza annata"; quantità intera tra 1 e 99. Un errore indica il campo e conserva quanto scritto.
- **FR2.7** Si gestiscono solo bottiglie standard da 0,75 L. *(Q3)*

### FR3 — Inventario
- **FR3.1** La sezione Cantina elenca ogni vino con nome, annata, quantità, stato e livello di fiducia della stima. *(wireframes S3)*
- **FR3.2** L'utente cerca per nome e filtra per stato e tipologia; senza risultati vede "Nessun vino con questi filtri" e "Azzera filtri".
- **FR3.3** L'utente modifica nome, produttore, annata e quantità di un vino; la stima si ricalcola.
- **FR3.4** L'utente elimina un vino dopo una conferma che ne riporta il nome; l'eliminazione non crea voci nello storico.

### FR4 — Stima del momento ideale
- **FR4.1** Per ogni vino il sistema calcola una finestra ideale (anno di inizio, anno di picco, anno di fine). *(intent-statement, Q10)*
- **FR4.2** La stima usa prima una base dati di vini esterna; se il vino non si trova, usa regole interne per tipologia, denominazione e annata. *(constraint-register C4)*
- **FR4.3** Ogni stima ha un livello di fiducia: alta, media o bassa. *(Q5)*
- **FR4.4** Il dettaglio del vino indica la fonte della stima ("base dati vini" o "stima per tipologia"). *(wireframes S5)*
- **FR4.5** Ogni vino ha uno stato derivato dalla data odierna: "da aspettare" (prima dell'inizio), "pronto" (dentro la finestra), "da bere presto" (sottoinsieme di "pronto", vedi FR4.6), "oltre la finestra" (dopo la fine). Lo stato è sempre mostrato con icona e testo, mai solo con il colore. *(revisione mockup R-05; NFR3)*
- **FR4.6** Un vino è "da bere presto" quando alla fine della finestra manca il 25% o meno della sua durata, con un preavviso minimo di 3 mesi e massimo di 12 mesi. *(Q1)*
  - Given una finestra 2025–2027 (2 anni) e oggi 1 luglio 2027, Then lo stato è "da bere presto" (mancano 6 mesi = 25%).
  - Given una finestra 2020–2035 (15 anni) e oggi 1 febbraio 2035, Then lo stato è "da bere presto" (mancano 11 mesi; il preavviso massimo è 12).
  - Given una finestra di 1 anno e mancano 4 mesi alla fine, Then lo stato è "pronto" (preavviso: 25% = 3 mesi, cioè già il minimo); con 3 mesi mancanti diventa "da bere presto" (bordi in A3).
- **FR4.7** Senza rete la stima con regole interne funziona comunque; la ricerca nella base dati esterna avviene alla prima connessione e può aggiornare la stima e la fiducia.

### FR5 — Cruscotto
- **FR5.1** All'apertura l'app mostra il Cruscotto. *(wireframes S2)*
- **FR5.2** La sezione "Da bere presto" elenca i vini in quello stato, ordinati per data di fine finestra crescente; se vuota mostra "Nessuna bottiglia in scadenza". *(scope Q1)*
- **FR5.3** Grafico dello stato: numero di bottiglie da aspettare, pronte e oltre la finestra.
- **FR5.4** Grafico dei picchi: numero di bottiglie che raggiungono il picco per anno.
- **FR5.5** Grafico per tipologia o regione.
- **FR5.6** Ogni grafico riporta i numeri e ha una descrizione testuale per il lettore schermo; con cantina vuota il Cruscotto invita ad aggiungere il primo vino.

### FR6 — Bottiglia bevuta e storico
- **FR6.1** "Segna come bevuta" riduce di 1 la quantità del vino. *(scope Q4)*
- **FR6.2** L'utente può aggiungere voto (da 1 a 5), note (massimo 1000 caratteri) e data (predefinita oggi); tutti facoltativi.
- **FR6.3** Lo Storico elenca le bottiglie bevute dalla più recente.
- **FR6.4** Quando la quantità arriva a 0 il vino esce dalla Cantina e resta solo nello Storico.

### FR7 — Abbinamenti
- **FR7.1** Il dettaglio del vino mostra suggerimenti di cibo da abbinare. *(intent-statement)*
- **FR7.2** Gli abbinamenti vengono dalla stessa fonte della stima; se non disponibili si mostrano abbinamenti per tipologia, indicandolo.

### FR8 — Condivisione
- **FR8.1** Il proprietario invita fino a 2 persone tramite l'email del loro account Google. *(Q4; limite portato da 5 a 2 dal proprietario il 2026-11-06, durante il design di u7-sharing, per restare largamente nella quota gratuita)*
- **FR8.2** Per ogni persona sceglie il permesso: "solo lettura" o "può modificare". *(intent-statement Q11)*
- **FR8.3** Il proprietario revoca l'accesso dopo una conferma con il nome della persona; la revoca ha effetto alla successiva sincronizzazione della persona.
- **FR8.4** Chi ha "solo lettura" non vede i comandi di modifica e il sistema rifiuta comunque le sue modifiche lato cloud.

### FR9 — Offline e sincronizzazione
- **FR9.1** Inserimento, modifica, bevuta e consultazione funzionano senza rete. *(constraint-register C3)*
- **FR9.2** Le modifiche fatte offline si sincronizzano da sole al ritorno della rete, senza perdere dati.
- **FR9.3** Quando ci sono modifiche non sincronizzate, l'app mostra "Offline - sincronizzazione in attesa". *(revisione mockup R-03)*
- **FR9.4** Se due persone modificano lo stesso vino offline, le variazioni di quantità si sommano; per gli altri campi vale l'ultima modifica.

### FR10 — Lingua e aspetto
- **FR10.1** L'interfaccia è in italiano, inglese e portoghese brasiliano, secondo la lingua del telefono; per altre lingue si usa l'inglese. *(rough-mockups Q7)*
- **FR10.2** Tema chiaro e scuro secondo l'impostazione del telefono. *(rough-mockups Q5)*

## Non-functional requirements

- **NFR1 — Velocità di inserimento**: aggiungere una bottiglia scrivendola richiede meno di 30 secondi dal tocco su "Aggiungi" al salvataggio, nella mediana di 10 prove su un vino presente nei suggerimenti. *(intent-statement)*
- **NFR2 — Prestazioni**: con 500 bottiglie il Cruscotto si mostra entro 2 secondi dall'apertura su un telefono Android di fascia media, anche offline.
- **NFR3 — Accessibilità**: WCAG 2.1 AA: contrasto minimo 4.5:1, testi ridimensionabili fino al 200% senza perdita di contenuto, aree toccabili di almeno 48x48 dp, ogni elemento etichettato per TalkBack. *(rough-mockups Q6)*
- **NFR4 — Sicurezza e accesso**: ogni lettura e scrittura nel cloud è permessa solo al proprietario e alle persone invitate, secondo i loro permessi; le connessioni sono cifrate; chiavi e credenziali non stanno mai nel repository. *(team-practices Deployment)*
- **NFR5 — Costo**: il servizio cloud resta a 0 €/mese per l'uso previsto, con avviso di spesa a 1 €. *(constraint-register C6)*
- **NFR6 — Durabilità**: nessuna modifica confermata dall'utente va persa, anche se l'app si chiude prima della sincronizzazione.
- **NFR7 — Qualità del codice**: copertura dei test almeno 80% delle righe senza esclusioni; formattazione, analisi, test e test da capo a fondo passano in CI prima di ogni merge. *(team-practices Testing Posture)*
- **NFR8 — Privacy**: la cancellazione dell'account (FR1.4) rimuove i dati dal cloud entro 30 giorni; solo i dati necessari vengono raccolti (email e nome dell'account, cantina). *(2026-11-06, u6 Q1: le foto delle etichette servono solo a leggere il testo sul telefono e non si conservano)*

## Constraints

- App Android, un solo codice Flutter riutilizzabile per iPhone in futuro. *(constraint-register C1; team-practices)*
- Cloud su Firebase, budget 0 €/mese. *(constraint-register C2, C6)*
- Codice, identificatori e commenti sempre in inglese. *(project.md Mandated)*
- Nessun account Apple Developer per ora: niente iPhone né login Apple. *(constraint-register C7)*
- Nessuna scadenza. *(constraint-register C8)*

## Assumptions

- **A1** — Esiste almeno una fonte di dati sui vini utilizzabile gratuitamente; se non esiste, FR4.2 e FR7.2 usano solo le regole interne. *(feasibility R1)*
- **A2** — La versione minima supportata è Android 8.0; è un valore comune per le app nuove e va confermato in progettazione.
- **A3** — Bordi di FR4.6: il preavviso è il 25% della durata della finestra, portato a 3 mesi se più corto e a 12 mesi se più lungo; un vino è "da bere presto" quando i mesi mancanti alla fine sono minori o uguali al preavviso. Esempio con finestra di 1 anno: preavviso 3 mesi, quindi con 4 mesi mancanti è ancora "pronto".
- **A4** — Le date si calcolano nel fuso orario del telefono; inizio, picco e fine sono anni interi (dal 1 gennaio al 31 dicembre).

## Out of scope

- Valore economico e prezzi; pubblicazione per altri appassionati; iPhone e login Apple; notifiche sul telefono; posizione in cantina; formati diversi da 0,75 L; esportazione dell'inventario. *(scope-document; Q3; Q6)*

## Open questions

- La fonte esterna per finestre e abbinamenti va scelta e verificata in progettazione (A1).
- I minuti gratuiti di GitHub Actions per i test su emulatore vanno verificati in Construction. *(team-practices)*
