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
| Account | Accesso con Google, presentazione al primo avvio (3 pagine, "Salta"), profilo, uscita, cancellazione dell'account dall'app e da una pagina web pubblica |
| Cantina | Aggiunta, modifica, archiviazione dei vini; quantità; filtro per stato e tipo; paese e regione d'origine |
| Momento ideale | Finestra di consumo per denominazione, vitigno, tipo o stile; livello del vino; correzione manuale; correzione dalle bevute registrate |
| Bevute e storico | Registrazione di una bevuta con giudizio e stelle; storico delle bottiglie bevute |
| Etichetta | Lettura sul telefono di testo e codice a barre, proposte dal database offline dei vini e da Open Food Facts, conferma guidata dei campi |
| Cruscotto | Totale bottiglie, vini da bere presto, grafici per stato, tipo e regione, vini da confermare |
| Condivisione | Invito per email, permessi degli invitati, cambio di cantina attiva |
| Piano Plus | Limite di capienza del piano senza costi, acquisto Plus su Google Play, un annuncio al giorno nel Cruscotto per il piano senza costi |
| Abbinamenti | Categorie di cibo suggerite per il vino |
| Informazioni | Versione, database dei vini, licenze, fonte delle denominazioni, nota sulla privacy delle foto |

## Engagement and Support Today

Rilevato dalla scansione focalizzata del 2026-11-19 (intent `tester-feedback`):

- **Primo avvio**: una presentazione di 3 pagine prima del login, con "Salta", "Avanti" e "Inizia"; non torna più dopo essere stata vista sul telefono. Non esistono suggerimenti contestuali dentro l'app.
- **Impostazioni**: non esiste una schermata con questo nome. Le voci personali stanno nel Profilo (piano, uscita, cancellazione, privacy), aperto dal menu della Cantina.
- **Condividere l'app**: non esiste una voce dedicata. Il link a Google Play compare solo nel messaggio d'invito a una cantina condivisa.
- **Valutare l'app**: nessuna richiesta di recensione nell'app.
- **Feedback e FAQ**: nessun canale nell'app; l'email di supporto è solo nella scheda dello store.

Dettagli tecnici: `architecture.md`, sezione "Onboarding, Profile and Outbound Links".

## Users and Markets

- Un solo tipo di utente: la persona che possiede o condivide una cantina. Il proprietario del progetto è anche l'unico sviluppatore.
- Lingue dell'interfaccia: 25 (dalla versione 0.3.0), tra cui italiano, inglese, portoghese del Brasile e d'Europa, francese, spagnolo, tedesco, greco, georgiano e le lingue nordiche e dell'Europa centrale e orientale. La lingua segue quella del telefono; da Android 13 si può scegliere nelle impostazioni di sistema dell'app; ogni lingua non offerta riceve l'inglese.
- Scheda Google Play preparata in 25 schede (it-IT predefinita). Versione in `pubspec.yaml`: `0.3.0+3`; distribuita sul canale di test interno, la produzione richiede l'approvazione manuale del proprietario.
- Pagine pubbliche di privacy e cancellazione dell'account in italiano, inglese e portoghese del Brasile; le altre lingue ricevono la pagina inglese.

## Domain Knowledge in the Code

- Le conoscenze enologiche (finestre di consumo, soglie, abbinamenti, elenchi di regioni) sono decise nel codice e motivate nei commenti, come chiede la regola di progetto del 2026-11-04.
- Paesi (249, ISO 3166-1) e regioni vinicole di 21 paesi hanno nomi tradotti; il valore salvato è il codice del paese o il nome canonico della regione, mai la traduzione.
- Denominazioni e vitigni vengono da tabelle scritte a mano e da tabelle generate dai registri pubblici (eAmbrosia e registri extra UE). I termini di legge del vino (Riserva, Grand Cru, Spätlese) restano uguali in ogni lingua.

## Constraints Visible in the Repository

- Budget cloud di 0 €/mese: emulatori Firebase per sviluppo e test, un solo progetto di produzione, le Cloud Functions non sono mai distribuite dalla CI.
- Le foto delle etichette non lasciano il telefono, salvo l'apertura esplicita in Google Lens.
- Nessun segreto nel repository: configurazione di produzione e chiavi di firma arrivano dai segreti di GitHub Actions.
- Ogni testo dell'interfaccia va fornito in 25 lingue.

Dettagli tecnici: vedi `architecture.md` e `component-inventory.md`.
