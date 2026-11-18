# Business Overview

## Business Domain

Vinoozy è un'app Android per chi tiene una cantina di vini in casa. Il suo motto è "la tua cantina, al momento giusto": per ogni vino stima quando conviene berlo e avvisa quando quel momento si avvicina o è passato.

## Purpose

- Tenere l'inventario delle bottiglie, anche senza rete, con sincronizzazione sul cloud al ritorno della connessione.
- Stimare per ogni vino la finestra di consumo (inizio, apice, fine), con un indice di fiducia e l'origine della stima.
- Ridurre la fatica di inserimento: foto dell'etichetta, codice a barre, testo incollato o condiviso da Google Lens.
- Condividere una cantina con altre persone.

## Key Functionality

| Area | Cosa fa per la persona |
|---|---|
| Account | Accesso con Google, onboarding, profilo, uscita, cancellazione dell'account dall'app e da una pagina web pubblica |
| Cantina | Aggiunta, modifica, archiviazione dei vini; quantità; filtro per stato e tipo; paese e regione d'origine |
| Momento ideale | Finestra di consumo per denominazione, vitigno, tipo o stile; livello del vino; correzione manuale; correzione dalle bevute registrate |
| Bevute e storico | Registrazione di una bevuta con giudizio e stelle; storico delle bottiglie bevute |
| Etichetta | Lettura sul telefono di testo e codice a barre, proposte dal database offline dei vini e da Open Food Facts, conferma guidata dei campi |
| Cruscotto | Totale bottiglie, vini da bere presto, grafici per stato, tipo e regione, vini da confermare |
| Condivisione | Invito per email, permessi degli invitati, cambio di cantina attiva |
| Piano Plus | Limite di capienza del piano senza costi, acquisto Plus su Google Play, un annuncio al giorno nel Cruscotto per il piano senza costi |
| Abbinamenti | Categorie di cibo suggerite per il vino |

## Users and Markets

- Un solo tipo di utente: la persona che possiede o condivide una cantina. Il proprietario del progetto è anche l'unico sviluppatore.
- Lingue dell'interfaccia oggi: italiano, inglese, portoghese del Brasile. La lingua segue quella del telefono; ogni altra lingua riceve l'inglese. Non esiste un selettore di lingua nell'app.
- Scheda Google Play preparata in tre lingue (it-IT predefinita, en-US, pt-BR). Versione corrente `0.2.1+3`, distribuita sul canale di test interno; la produzione richiede l'approvazione manuale del proprietario.
- Pagine pubbliche di privacy e cancellazione dell'account nelle stesse tre lingue.

## Domain Knowledge in the Code

- Le conoscenze enologiche (finestre di consumo, soglie, abbinamenti, elenchi di regioni) sono decise nel codice e motivate nei commenti, come chiede la regola di progetto del 2026-11-04.
- Paesi (249, ISO 3166-1) e regioni vinicole di 21 paesi hanno nomi in italiano, inglese e portoghese; il valore salvato è il codice del paese o il nome canonico della regione, mai la traduzione.
- Denominazioni e vitigni vengono da tabelle scritte a mano e da tabelle generate dai registri pubblici (eAmbrosia e registri extra UE). I termini di legge del vino (Riserva, Grand Cru, Spätlese) restano uguali in ogni lingua.

## Constraints Visible in the Repository

- Budget cloud di 0 €/mese: emulatori Firebase per sviluppo e test, un solo progetto di produzione, le Cloud Functions non sono mai distribuite dalla CI.
- Le foto delle etichette non lasciano il telefono, salvo l'apertura esplicita in Google Lens.
- Nessun segreto nel repository: configurazione di produzione e chiavi di firma arrivano dai segreti di GitHub Actions.

Dettagli tecnici: vedi `architecture.md` e `component-inventory.md`.
