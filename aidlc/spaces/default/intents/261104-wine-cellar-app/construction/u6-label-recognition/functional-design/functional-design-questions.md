# Functional Design — u6-label-recognition — Domande

Contesto:
- `unit-of-work.md` (U6: aggiunta di un vino dalla foto dell'etichetta);
- `requirements.md` (FR2.2, FR2.3, FR2.4; NFR8 sulla privacy, che cita le foto delle etichette tra i dati raccolti, e FR1.4, che le cancella con l'account);
- `stories.md` (US2.2, AC2.2.1–AC2.2.4);
- `components.md` (LabelRecognition: legge il testo sul telefono senza inviare la foto);
- contratto C1 (`WineCatalog.matchLabelText`, già costruito in U3);
- mockup M4a ("Scatta foto" → proposta con quantità, "Correggi", "Conferma");
- unità già costruite: U1, U2, U3, U4, U5, U7. Il modulo di inserimento scritto di U4 è quello che "Correggi" apre già compilato.

La lettura del testo usa ML Kit sul telefono: è gratuita, funziona anche senza rete e la foto non lascia il telefono. Restano tre scelte di prodotto.

## Q1. [Prodotto] Che cosa succede alla foto dopo la lettura

NFR8 e FR1.4 citano le foto delle etichette tra i dati conservati. Conservarle nel cloud richiede Firebase Storage, che per i progetti nuovi è disponibile solo con il piano a consumo (Blaze). Il budget è 0 €.

A. La foto serve solo a leggere il testo e poi si cancella dal telefono. Non si conserva da nessuna parte, quindi non c'è nulla da cancellare con l'account e la privacy è più semplice (consigliato). NFR8 e FR1.4 si aggiornano togliendo le foto dai dati raccolti.
B. La foto resta solo sul telefono, nella memoria dell'app, e si vede nel dettaglio del vino. Non si sincronizza: sugli altri telefoni e per le persone invitate non compare. Si cancella con il vino e con l'account.
C. La foto va nel cloud (Firebase Storage) e si vede ovunque. Serve il piano Blaze; con poche foto compresse il costo resta di solito sotto 1 €/mese, ma non è più 0 €.
X. Other (please specify)

[Answer]: A

## Q2. [Prodotto] Come si scatta la foto

A. Si apre la fotocamera di sistema del telefono. Dopo lo scatto l'app legge il testo e mostra la proposta. C'è anche "Scegli dalla galleria" per un'etichetta già fotografata. È il percorso più semplice e affidabile, e su Android non richiede il permesso della fotocamera all'app (consigliato).
B. La fotocamera è dentro l'app, con l'anteprima e il pulsante di scatto come nel mockup M4a. Richiede il permesso della fotocamera (AC2.2.4) e più lavoro, ma si resta sempre nell'app.
X. Other (please specify)

[Answer]: A

## Q3. [Prodotto] Leggere anche il codice a barre

Molte bottiglie hanno il codice a barre sulla retroetichetta. Open Food Facts lo riconosce in modo più preciso del testo.

A. Sì: se nella foto c'è un codice a barre, l'app lo legge sul telefono (ML Kit, gratuito) e cerca prima per codice; se non trova nulla, usa il testo. Si può fotografare il fronte o il retro (consigliato).
B. No: solo il testo dell'etichetta, come nei requisiti.
X. Other (please specify)

[Answer]: A

## Analisi delle risposte

- **Q1 = A:** la foto non si conserva. Cambiano due requisiti, da aggiornare con una nota datata:
  - NFR8 toglie "foto delle etichette" dai dati raccolti;
  - FR1.4 toglie "le foto" da ciò che la cancellazione dell'account rimuove.
- **Q2 = A:** fotocamera di sistema e galleria. AC2.2.4 (permesso negato) resta valido dove il sistema chiede un permesso: su iPhone e quando si sceglie dalla galleria su versioni di Android che lo richiedono.
- **Q3 = A:** codice a barre prima del testo. Il catalogo di U3 ha già `lookupBarcode`, quindi non serve una nuova operazione nel contratto C1.
- Nessuna contraddizione tra le risposte.

## Consolidated Summary Confirmation

- **Dove si trova:** "Aggiungi" mostra tre pulsanti: "Scatta foto", "Importa una foto" e "Scrivi" (mockup M4, con il pulsante di importazione aggiunto). "Scrivi" è il modulo di U4. Chi ha solo "può vedere" una cantina condivisa non vede "Aggiungi" (U7).
- **Scatto:** "Scatta foto" apre la fotocamera di sistema.
- **Importare una foto fatta prima (richiesta del proprietario, 2026-11-06):** per chi fotografa un'etichetta in giro e la aggiunge più tardi.
  - "Aggiungi" ha un terzo pulsante, **"Importa una foto"**, che apre la galleria del telefono. Si sceglie una foto, poi il percorso è lo stesso dello scatto.
  - Dalla galleria o dall'app Foto si può anche usare **"Condividi" → Vinoozy**: l'app si apre direttamente sulla lettura di quella foto. Se l'utente non ha fatto l'accesso, la foto viene ignorata e si apre l'accesso. Se ha solo "può vedere" sulla cantina attiva, compare un messaggio e non si legge nulla.
  - Si importa una foto alla volta.
  - **La foto originale nella galleria non si tocca mai:** è dell'utente. L'app lavora su una copia temporanea e cancella solo quella.
  - Se l'utente chiude la fotocamera senza scattare, si torna ad "Aggiungi" senza messaggi.
  - Se il sistema nega il permesso, compare una spiegazione con il collegamento alle impostazioni (AC2.2.4).
- **Lettura, tutta sul telefono:** sulla stessa foto l'app legge il codice a barre e il testo con ML Kit. Funziona anche senza rete.
- **Ricerca del vino, in quest'ordine:**
  1. se c'è un codice a barre e c'è rete, si cerca il prodotto per codice su Open Food Facts;
  2. altrimenti, o se il codice non dà risultati, si cerca con il testo letto (`matchLabelText` di U3). Con la rete usa anche Open Food Facts; senza rete riconosce solo la denominazione, per esempio "Barolo DOCG";
  3. l'annata viene dal testo, se c'è un anno plausibile.
- **Proposta (AC2.2.1):** "Ho riconosciuto:" con nome, produttore e annata. Sotto ci sono la quantità (1–99, già a 1), "Correggi" e "Conferma".
  - **"Conferma"** salva come l'inserimento scritto di U4: controllo dei doppioni (se il vino c'è già, propone di aggiungere le bottiglie), stima e abbinamenti sul telefono, ritorno alla Cantina con il messaggio di conferma.
  - **"Correggi"** apre il modulo di U4 già compilato con nome, produttore, annata e quantità (AC2.2.2, FR2.3).
  - Nessun vino si salva senza "Conferma" o "Salva" (FR2.3).
- **Casi difficili:**
  - **nessun testo leggibile e nessun codice:** "Non riesco a leggere l'etichetta", con "Riprova" e "Scrivi a mano", che apre il modulo vuoto con il nome già attivo (AC2.2.3);
  - **testo letto ma nessun vino trovato:** proposta incompleta. Si apre direttamente il modulo di U4 con il nome compilato dalla riga più significativa del testo letto, da correggere;
  - **senza rete:** la proposta dice "Senza rete riconosco solo la denominazione: controlla i dati", e il vino si migliora dal catalogo quando torna la rete, come in U4.
- **La foto:** la copia usata dall'app si cancella subito dopo la lettura, anche in caso di errore; una foto importata resta nella galleria dell'utente. Non va nel cloud e non si conserva da nessuna parte. NFR8 e FR1.4 si aggiornano di conseguenza.
- **Privacy:** il testo letto e il codice non finiscono nei report degli errori; si registrano solo motivi fissi, come "lettura non riuscita".
- **Tempi:** dallo scatto alla proposta, al più qualche secondo. I limiti precisi si fissano nei requisiti non funzionali.
- **Costo:** 0 €. ML Kit è gratuito e gira sul telefono; Open Food Facts è già usato da U3 con i suoi limiti.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
