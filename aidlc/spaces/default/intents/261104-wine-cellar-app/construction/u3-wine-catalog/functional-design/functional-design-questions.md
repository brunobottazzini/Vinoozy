# Functional Design — u3-wine-catalog — Domande

Contesto: `unit-of-work.md` (U3: funzione nel cloud con la chiave della base dati vini; "se non c'è un fornitore adatto, la funzione risponde non trovato e l'app usa U2"), `contract-summary.md` (C1 con le tre operazioni `suggestWines`, `matchLabelText`, `getWineProfile`; C5, cioè la scelta del fornitore, è ancora aperta), `requirements.md` (FR2.1, FR2.2, FR4.2, FR7.2), budget di 0 €/mese con avviso a 1 € (team.md).

Due fatti che pesano sulla scelta:
- Le funzioni cloud di Firebase richiedono il piano Blaze, quello a consumo che chiede una carta. Oggi il progetto è sul piano Spark, quello gratuito. Il passaggio a Blaze era comunque previsto prima della prima pubblicazione su Play.
- Non esiste una base dati di vini gratuita che dia finestre di consumo e abbinamenti. Quelle che li danno sono a pagamento. Quelle gratuite, come Open Food Facts, hanno solo nome, produttore e codice a barre, con dati incompleti.

## Q1. [Prodotto] Da dove arrivano suggerimenti, riconoscimento dell'etichetta e profili dei vini

A. Nessun fornitore esterno per ora (consigliato). Suggerimenti e riconoscimento usano un catalogo interno: le denominazioni della stima (U2), le varianti dei nomi più comuni e i vini già presenti nella tua cantina. Il profilo risponde "non trovato", quindi la finestra viene dalle regole interne. Costo zero e nessuna licenza da rispettare. Un fornitore si può aggiungere dopo cambiando solo l'adattatore (C5).
B. Open Food Facts: dati aperti e gratuiti, con molte bottiglie, nome e produttore. Non ha finestre né abbinamenti, i dati sono incompleti e la fonte va citata nell'app. Le finestre restano quelle delle regole interne.
C. Un fornitore a pagamento con finestre e punteggi (per esempio Wine-Searcher o Global Wine Score). Costa ogni mese, quindi è fuori dal budget di 0 €.
D. Not yet defined
X. Other (please specify)

[Answer]: X. Io farei A e B amico già subito

## Q2. [Prodotto] Dove gira il catalogo

A. Dentro l'app (consigliato se in Q1 scegli A). Senza un fornitore non c'è nessuna chiave da proteggere, quindi non serve una funzione cloud. Il catalogo funziona anche senza rete, è più veloce, non costa nulla e il passaggio a Blaze non serve per questa unità. Il contratto C1 resta come interfaccia nell'app: quando arriverà un fornitore con chiave, l'interfaccia sarà servita da una funzione cloud, senza cambiare il resto dell'app.
B. In una funzione cloud, come previsto all'inizio. Serve il piano Blaze con l'avviso di spesa a 1 €. Il costo atteso è 0 € entro la quota gratuita, ma senza rete i suggerimenti non funzionano.
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Analisi delle risposte

- Q1 vuol dire A e B insieme: catalogo interno sempre disponibile, più Open Food Facts quando c'è rete. Non ci sono ambiguità.
- Q1 e Q2 sono coerenti: Open Food Facts non richiede una chiave, quindi l'app può interrogarlo direttamente e non serve una funzione cloud.
- I limiti di Open Food Facts sono 100 letture al minuto per prodotto e, per la ricerca, un limite più basso non documentato con precisione (circa 10 al minuto secondo fonti terze). Chi li supera viene bloccato. Ne segue che i suggerimenti mentre scrivi vengono dal catalogo interno, e Open Food Facts entra solo con un ritardo, con pochi caratteri minimi e un limite lato app. È una scelta tecnica, decisa qui senza chiedere.

## Consolidated Summary Confirmation

- Catalogo dentro l'app, senza funzione cloud né piano Blaze per questa unità. Il contratto C1 resta come interfaccia Dart (`WineCatalog`) con le tre operazioni: suggerimenti, riconoscimento del testo dell'etichetta e profilo.
- Due fonti dietro l'interfaccia:
  - il catalogo interno, sempre disponibile anche offline, fatto delle denominazioni della stima (U2), delle varianti dei nomi e dei vini già nella tua cantina;
  - Open Food Facts quando c'è rete, per nome e produttore dei vini in commercio e per la ricerca tramite codice a barre.
- Suggerimenti mentre scrivi: arrivano subito dal catalogo interno. I risultati di Open Food Facts si aggiungono solo dopo una pausa nella scrittura, con almeno 3 caratteri e al massimo 8 ricerche al minuto. Le risposte si conservano sul telefono per 30 giorni (C5).
- Profilo del vino: Open Food Facts non ha finestre né abbinamenti, quindi la finestra resta quella delle regole interne di U2. Tipologia, regione e denominazione, quando Open Food Facts le ha, aiutano U2 a riconoscere il vino.
- Licenza: dove compaiono dati di Open Food Facts, l'app mostra "Dati da Open Food Facts (ODbL)". Usiamo i dati solo in lettura.
- Privacy: verso Open Food Facts partono solo il testo cercato o il codice a barre, mai email, uid o posizione. Le richieste portano l'identificativo `Vinoozy/<versione>` con un indirizzo di contatto messo nella configurazione e non nel codice. L'indirizzo lo scegli tu prima della pubblicazione.
- Senza rete, oppure con Open Food Facts lento (oltre 5 secondi) o non disponibile, si usa solo il catalogo interno, senza errori per l'utente.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
