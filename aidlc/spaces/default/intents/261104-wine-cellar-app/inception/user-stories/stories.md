# User Stories — Vinoozy

Fonti: `requirements.md`, `personas.md`, `team-practices.md`. Personas: P1 Proprietario, P2 Persona invitata. Storie raggruppate per percorso, ognuna realizzabile in 1–3 giorni (`user-stories-questions.md` Q2, Q3). Priorità MoSCoW; il confine dell'MVP lo decide Delivery Planning.

Ogni storia è indipendente e verificabile da sola: dove serve un dato di partenza (es. un vino in cantina) i criteri lo indicano come precondizione "Given".

## US1 — Accesso

### US1.1 — Accedere con Google *(Must; FR1.1, FR1.2)*
Come **Proprietario**, voglio accedere con il mio account Google, così da ritrovare la mia cantina senza creare un'altra password.
- **AC1.1.1** Given l'app al primo avvio con rete, When tocco "Continua con Google" e completo l'accesso, Then vedo il Cruscotto.
- **AC1.1.2** Given l'accesso annullato o fallito, When torno all'app, Then vedo "Accesso non riuscito" con "Riprova" e non viene creato nessun dato.
- **AC1.1.3** Given ho già effettuato l'accesso, When riapro l'app senza rete, Then entro direttamente nel Cruscotto.

### US1.2 — Uscire dall'account *(Should; FR1.3)*
Come **Proprietario**, voglio uscire dall'account dal profilo, così da poter lasciare il telefono a un'altra persona.
- **AC1.2.1** Given ho effettuato l'accesso, When tocco "Esci" nel profilo e confermo, Then torno alla schermata di accesso.
- **AC1.2.2** Given ho modifiche non sincronizzate, When tocco "Esci", Then l'app me lo segnala prima di uscire.

### US1.3 — Cancellare l'account *(Must; FR1.4, NFR8)*
Come **Proprietario**, voglio cancellare il mio account dall'app, così da eliminare tutti i miei dati quando non uso più il servizio.
- **AC1.3.1** Given ho effettuato l'accesso, When scelgo "Cancella account", Then vedo una conferma che elenca cantina, storico, foto e condivisioni che verranno eliminati.
- **AC1.3.2** Given confermo la cancellazione, When l'operazione termina, Then torno alla schermata di accesso e i miei dati non sono più visibili a nessuno.

## US2 — Aggiungere un vino

### US2.1 — Aggiungere un vino scrivendolo *(Must; FR2.1, FR2.4, FR2.6, FR2.7, NFR1)*
Come **Proprietario**, voglio aggiungere un vino scrivendone il nome e la quantità, così da registrarlo in meno di 30 secondi.
- **AC2.1.1** Given la schermata Scrivi, When digito "Barolo 2016", Then vedo i vini corrispondenti tra i suggerimenti.
- **AC2.1.2** Given ho scelto un suggerimento e quantità 3, When tocco "Salva", Then il vino appare in Cantina con quantità 3.
- **AC2.1.3** Given il campo nome vuoto o un'annata fuori dall'intervallo 1900–anno corrente, When tocco "Salva", Then vedo l'errore sotto il campo e quanto ho scritto resta.
- **AC2.1.4** Given un vino presente nei suggerimenti, When misuro 10 inserimenti dal tocco su "Aggiungi" al salvataggio, Then la mediana è inferiore a 30 secondi.

### US2.2 — Aggiungere un vino da foto *(Should; FR2.2, FR2.3, FR2.4)*
Come **Proprietario**, voglio fotografare l'etichetta, così da non dover scrivere il nome del vino.
- **AC2.2.1** Given un'etichetta leggibile, When scatto la foto, Then vedo il vino proposto con il campo quantità (predefinito 1) e i pulsanti "Conferma" e "Correggi".
- **AC2.2.2** Given la proposta, When tocco "Correggi", Then si apre l'inserimento scritto già compilato.
- **AC2.2.3** Given un'etichetta illeggibile, When scatto la foto, Then vedo "Non riesco a leggere l'etichetta" e il pulsante "Scrivi a mano".
- **AC2.2.4** Given il permesso fotocamera negato, When tocco "Scatta foto", Then vedo una spiegazione e il collegamento alle impostazioni.

### US2.3 — Non creare doppioni *(Should; FR2.5)*
Come **Proprietario**, voglio che aggiungere un vino già presente ne aumenti la quantità, così da non avere doppioni in cantina.
- **AC2.3.1** Given "Barolo 2016" con quantità 2 in cantina, When aggiungo "Barolo 2016" con quantità 1, Then l'app mi mostra la voce esistente e, confermando, la quantità diventa 3.

## US3 — Consultare e gestire la cantina

### US3.1 — Vedere l'inventario *(Must; FR3.1)*
Come **Proprietario**, voglio vedere tutti i miei vini con quantità e stato, così da sapere cosa ho in cantina.
- **AC3.1.1** Given vini in cantina, When apro Cantina, Then ogni riga mostra nome, annata, quantità, stato e livello di fiducia.
- **AC3.1.2** Given la cantina vuota, When apro Cantina, Then vedo l'invito ad aggiungere il primo vino.

### US3.2 — Cercare e filtrare *(Should; FR3.2)*
Come **Proprietario**, voglio cercare per nome e filtrare per stato e tipologia, così da trovare subito un vino.
- **AC3.2.1** Given vini in cantina, When cerco "barolo", Then vedo solo i vini il cui nome lo contiene.
- **AC3.2.2** Given filtri senza risultati, When li applico, Then vedo "Nessun vino con questi filtri" e "Azzera filtri".

### US3.3 — Modificare un vino *(Should; FR3.3)*
Come **Proprietario**, voglio correggere nome, produttore, annata e quantità, così da tenere i dati giusti.
- **AC3.3.1** Given un vino in cantina, When cambio l'annata e salvo, Then la stima e lo stato si ricalcolano.

### US3.4 — Eliminare un vino *(Should; FR3.4)*
Come **Proprietario**, voglio eliminare un vino inserito per errore, così che l'inventario resti corretto.
- **AC3.4.1** Given un vino in cantina, When scelgo "Elimina", Then vedo una conferma con il nome del vino.
- **AC3.4.2** Given confermo l'eliminazione, Then il vino sparisce dalla Cantina e non compare nello Storico.

## US4 — Sapere quando bere

### US4.1 — Vedere la finestra ideale *(Must; FR4.1, FR4.2, FR4.3, FR4.4, FR4.7)*
Come **Proprietario**, voglio vedere per ogni vino quando è pronto, il picco e fino a quando berlo, così da non doverlo stimare io.
- **AC4.1.1** Given un vino presente nella base dati vini, When apro il dettaglio, Then vedo inizio, picco e fine della finestra, la fonte "base dati vini" e un livello di fiducia tra alta, media e bassa.
- **AC4.1.2** Given un vino non presente nella base dati, When apro il dettaglio, Then vedo la stima con fonte "stima per tipologia".
- **AC4.1.3** Given nessuna rete, When aggiungo un vino, Then vedo subito una stima per tipologia, aggiornata alla prima connessione se la base dati la migliora.

### US4.2 — Sapere cosa bere presto *(Must; FR4.5, FR4.6)*
Come **Proprietario**, voglio che l'app segnali i vini vicini alla fine della finestra, così da berli in tempo.
- **AC4.2.1** Given un vino con una finestra di 15 anni a cui mancano 11 mesi alla fine, When apro l'app, Then il suo stato è "da bere presto".
- **AC4.2.2** Given un vino con una finestra di 1 anno a cui mancano 4 mesi alla fine, Then il suo stato è "pronto".
- **AC4.2.3** Given qualsiasi stato, When lo vedo, Then è mostrato con icona e testo, mai solo con il colore.

## US5 — Cruscotto

### US5.1 — Vedere subito cosa bere *(Must; FR5.1, FR5.2)*
Come **Proprietario**, voglio aprire l'app sulla lista dei vini da bere presto, così da agire senza cercarli.
- **AC5.1.1** Given vini "da bere presto", When apro l'app, Then il Cruscotto li elenca dal più vicino alla fine della finestra.
- **AC5.1.2** Given nessun vino in quello stato, When apro l'app, Then vedo "Nessuna bottiglia in scadenza".

### US5.2 — Vedere i grafici *(Must; FR5.3, FR5.4, FR5.5, FR5.6, NFR2)*
Come **Proprietario**, voglio grafici sullo stato, sui picchi per anno e per tipologia o regione, così da capire a colpo d'occhio la mia cantina.
- **AC5.2.1** Given vini in cantina, When apro il Cruscotto, Then vedo i tre grafici con i numeri su ogni barra.
- **AC5.2.2** Given TalkBack attivo, When raggiungo un grafico, Then sento una descrizione testuale dei suoi valori.
- **AC5.2.3** Given 500 bottiglie e nessuna rete, When apro l'app, Then il Cruscotto appare entro 2 secondi.

## US6 — Bere e ricordare

### US6.1 — Segnare una bottiglia come bevuta *(Must; FR6.1, FR6.2, FR6.4)*
Come **Proprietario**, voglio segnare una bottiglia come bevuta con voto e note, così da tenere l'inventario allineato e ricordare com'era.
- **AC6.1.1** Given un vino con quantità 2, When segno una bottiglia come bevuta con voto 4, Then la quantità diventa 1 e lo Storico contiene la bevuta con voto 4.
- **AC6.1.2** Given un vino con quantità 1, When la segno come bevuta, Then il vino esce dalla Cantina e resta nello Storico.

### US6.2 — Consultare lo storico *(Should; FR6.3)*
Come **Proprietario**, voglio rivedere le bottiglie bevute, così da ricordare quali mi sono piaciute.
- **AC6.2.1** Given bevute registrate, When apro Storico, Then le vedo dalla più recente con data, voto e note.
- **AC6.2.2** Given nessuna bevuta, When apro Storico, Then vedo "Qui troverai le bottiglie che hai bevuto".

## US7 — Abbinamenti

### US7.1 — Sapere con cosa abbinare un vino *(Should; FR7.1, FR7.2)*
Come **Proprietario**, voglio vedere i cibi da abbinare a un vino, così da scegliere la bottiglia giusta per la cena.
- **AC7.1.1** Given un vino con abbinamenti nella fonte dati, When apro il dettaglio, Then vedo i cibi suggeriti.
- **AC7.1.2** Given un vino senza abbinamenti nella fonte dati, When apro il dettaglio, Then vedo abbinamenti per tipologia, indicati come tali.

## US8 — Condividere la cantina

### US8.1 — Invitare una persona *(Should; FR8.1, FR8.2)*
Come **Proprietario**, voglio invitare fino a 5 persone scegliendo per ognuna "solo lettura" o "può modificare", così da gestire la cantina insieme.
- **AC8.1.1** Given meno di 5 persone invitate, When inserisco un'email valida e scelgo il permesso, Then la persona compare nell'elenco con quel permesso.
- **AC8.1.2** Given 5 persone già invitate, When provo a invitarne un'altra, Then vedo che il limite è raggiunto.
- **AC8.1.3** Given un'email non valida, When tocco "Invita", Then vedo l'errore sotto il campo.

### US8.2 — Revocare l'accesso *(Should; FR8.3)*
Come **Proprietario**, voglio togliere l'accesso a una persona, così da decidere sempre chi vede la mia cantina.
- **AC8.2.1** Given una persona invitata, When scelgo "Revoca" e confermo il suo nome, Then la persona sparisce dall'elenco e alla sua prossima sincronizzazione non vede più la cantina.

### US8.3 — Consultare una cantina condivisa *(Should; FR8.4, NFR4)*
Come **Persona invitata** con "solo lettura", voglio vedere la cantina, le stime e il cruscotto, così da sapere cosa è pronto senza rischiare di cambiare nulla.
- **AC8.3.1** Given ho "solo lettura", When apro la cantina condivisa, Then non vedo i comandi di aggiunta, modifica, eliminazione e bevuta.
- **AC8.3.2** Given ho "solo lettura", When una modifica arriva comunque al cloud, Then viene rifiutata.

### US8.4 — Aiutare a gestire una cantina condivisa *(Should; FR8.2, NFR4)*
Come **Persona invitata** con "può modificare", voglio aggiungere vini e segnare bottiglie bevute, così da aiutare il Proprietario.
- **AC8.4.1** Given ho "può modificare", When segno una bottiglia come bevuta, Then il Proprietario vede la quantità aggiornata dopo la sincronizzazione.
- **AC8.4.2** Given ho "può modificare", When apro il profilo, Then non vedo i comandi per invitare o revocare altre persone.

## US9 — Usare l'app senza rete

### US9.1 — Lavorare offline *(Must; FR9.1, FR9.2, FR9.3, NFR6)*
Come **Proprietario**, voglio aggiungere, modificare e segnare bottiglie anche senza rete, così da usare l'app in cantina.
- **AC9.1.1** Given nessuna rete, When aggiungo un vino, Then viene salvato e vedo "Offline - sincronizzazione in attesa".
- **AC9.1.2** Given modifiche in attesa, When la rete torna, Then si sincronizzano da sole e l'indicatore scompare.
- **AC9.1.3** Given modifiche in attesa, When chiudo e riapro l'app, Then le modifiche sono ancora presenti.

### US9.2 — Modifiche contemporanee *(Should; FR9.4)*
Come **Persona invitata** con "può modificare", voglio che le mie bevute offline si sommino a quelle del Proprietario, così da non perdere nessun aggiornamento.
- **AC9.2.1** Given quantità 4 e due persone offline che segnano ciascuna una bevuta, When entrambe si sincronizzano, Then la quantità è 2.

## US10 — Lingua e aspetto

### US10.1 — Usare l'app nella mia lingua e con il mio tema *(Must; FR10.1, FR10.2, NFR3)*
Come **Persona invitata**, voglio l'app nella lingua e nel tema del mio telefono e leggibile con TalkBack, così da usarla senza difficoltà.
- **AC10.1.1** Given il telefono in portoghese brasiliano, When apro l'app, Then l'interfaccia è in portoghese brasiliano; con una lingua non supportata è in inglese.
- **AC10.1.2** Given il tema scuro sul telefono, When apro l'app, Then vedo il tema scuro.
- **AC10.1.3** Given il testo di sistema al 200%, When apro Cantina e Cruscotto, Then nessun contenuto è tagliato e il contrasto rispetta WCAG AA.

## Dipendenze e note INVEST

- US2.x, US3.x, US4.x e US6.x presuppongono un utente con accesso (US1.1), indicato come precondizione nei criteri: si verificano anche con un utente di test già autenticato.
- US8.3 e US8.4 presuppongono un invito (US8.1), indicato come precondizione.
- Il walking skeleton (team-practices) corrisponde a US1.1 + US2.1 (testo) + US9.1.
- NFR5 (costo 0 €) e NFR7 (qualità del codice) non sono comportamenti visibili all'utente: sono coperti nelle fasi di progettazione e di build (vedi `traceability.json`).
