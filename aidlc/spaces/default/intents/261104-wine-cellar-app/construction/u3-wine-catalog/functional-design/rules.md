# Business Rules — u3-wine-catalog

Fonti: `requirements.md` (FR2.1, FR2.2, FR4.2, FR4.7, FR7.2, A1, NFR5, NFR8), `contract-summary.md` (C1, C2 funzioni di catalogo, C5, aggiornati il 2026-11-05), `stories.md` (US4.1, US7.1), risposte in `functional-design-questions.md` (Q1, Q2). Documentazione di Open Food Facts: limite di 100 letture al minuto per prodotto, limite più basso per la ricerca, identificativo `AppName/Version (contatto)` obbligatorio, blocco per chi supera i limiti, dati con licenza ODbL.

```yaml
rules:
  - id: BR1.1
    statement: I suggerimenti mentre si scrive vengono subito dal catalogo interno
    category: calculation
    applies_to: SuggestResult
    trigger: suggestWines(query, locale, cellarWines?)
    logic: query e voci si normalizzano con normalizeWineText di C2; una voce corrisponde se ogni parola della query è l'inizio di una parola dei suoi searchTerms (per i vini della cantina - nome e produttore); le parole di 4 cifre tra 1900 e 2200 non si confrontano e diventano l'annata della proposta; ordine - prima i vini della cantina, poi le denominazioni; a parità, più parole della query che coincidono per intero, poi ordine alfabetico del nome mostrato; per le denominazioni il nome mostrato è il displayName di C2
    violation: query normalizzata più corta di 2 caratteri -> CatalogArgumentError queryTooShort; query di oltre 120 caratteri -> queryTooLong
    source: FR2.1; Q1-A
  - id: BR1.2
    statement: I risultati di Open Food Facts si aggiungono dopo una pausa nella scrittura
    category: policy
    applies_to: SuggestResult
    trigger: suggestExternal(query, locale) (aggiunta compatibile a C1), chiamata da U4 quando c'è rete, la query normalizzata ha almeno 3 caratteri e l'utente non scrive da 600 ms; suggestWines resta solo interno e immediato
    logic: IF la cache ha 'search:' + query THEN si usa la cache; ELSE IF il budget di BR2.3 lo permette THEN ricerca su OFF nella categoria vini, con lingua preferita = locale (it, en, pt-BR), al massimo 10 risultati; U4 unisce le proposte di OFF dopo quelle interne con BR1.4; una risposta che arriva quando la query nel campo è cambiata si ignora
    violation: budget esaurito, OFF sospeso (BR2.2), nessuna rete, errore o tempo oltre 5 secondi -> solo risultati interni, externalIncluded = false, nessun errore all'utente
    source: FR2.1; Q1-B; C5
  - id: BR1.3
    statement: Riconoscimento del testo dell'etichetta
    category: calculation
    applies_to: LabelMatch
    trigger: matchLabelText(text), testo di al massimo 2000 caratteri
    logic: (1) recognizeDenomination di C2 sul testo e prima parola di 4 cifre tra 1900 e 2200 come annata; (2) IF c'è rete e budget THEN ricerca su OFF con le 6 parole normalizzate più lunghe di almeno 3 lettere, senza numeri, a parità di lunghezza la prima nel testo; si sceglie il primo risultato in cui recognizeDenomination sul nome del prodotto dà la stessa chiave di denominazione del passo 1, oppure il primo risultato se al passo 1 non c'è denominazione; (3) la proposta prende nome e produttore da OFF, denominazione e tipologia dal passo 1 (o da OFF se il passo 1 non le ha) e l'annata dal testo; (4) matched = true se c'è una denominazione o un risultato di OFF scelto
    violation: testo vuoto o senza nulla di riconosciuto -> matched = false; testo oltre 2000 caratteri -> CatalogArgumentError textTooLong
    source: FR2.2; Q1
  - id: BR1.4
    statement: Niente doppioni nei suggerimenti
    category: validation
    applies_to: SuggestResult
    trigger: unione dei risultati di cantina, catalogo interno e OFF
    logic: due proposte sono la stessa se nome normalizzato, produttore normalizzato e annata coincidono; si tiene quella con la fonte più alta (cantina, poi interno, poi OFF)
    violation: nessuna
    source: FR2.5
  - id: BR1.5
    statement: Ricerca per codice a barre
    category: calculation
    applies_to: WineCandidate
    trigger: lookupBarcode(code) (aggiunta compatibile a C1, per U6)
    logic: solo cifre, lunghe 8, 12 o 13; i codici da 12 cifre (UPC-A) si portano a 13 con uno zero davanti, quelli da 8 (EAN-8) restano così; IF cache 'product:' + codice THEN cache ELSE lettura del prodotto su OFF nei limiti di BR2.3; IF il prodotto non è nella categoria vini THEN null
    violation: codice con altri caratteri o di altra lunghezza -> CatalogArgumentError invalidBarcode; prodotto non trovato, non vino, OFF non disponibile -> null
    source: FR2.2; Q1-B
  - id: BR2.1
    statement: Le risposte riuscite di OFF si conservano sul telefono
    category: policy
    applies_to: CachedResponse, ProfileHint
    trigger: risposta di OFF valida
    logic: si salva il risultato già trasformato, con chiave 'search:' + query normalizzata o 'product:' + codice; anche una lista vuota (nessun risultato) si salva; gli errori non si salvano; vale 30 giorni; al massimo 200 voci di cache e 500 voci di indice (NFR2.3), si eliminano le più vecchie; per ogni proposta si aggiorna ProfileHint con il nome normalizzato; cache e indice stanno in un file proprio del catalogo (`catalog_cache.json`) nella cartella di supporto privata dell'app, escluso dal backup di Android (NFR8.1) e si cancellano all'uscita dall'account e alla cancellazione dell'account (U8)
    violation: cache illeggibile -> si svuota e si continua senza cache
    source: C5
  - id: BR2.2
    statement: Open Food Facts è un aiuto, mai un blocco
    category: policy
    applies_to: WineCatalog
    trigger: ogni chiamata a OFF
    logic: timeout 5 secondi (C5); nessun nuovo tentativo; "non trovato" (HTTP 404, prodotto assente, zero risultati) non è un errore ed è una risposta riuscita; sono errori - timeout, rete non raggiungibile, HTTP 429, HTTP 5xx, ogni altro codice diverso da 200 e 404, redirect, risposta oltre 1 MB, risposta non leggibile come JSON atteso (dettaglio in NFR6.2); dopo 3 errori di fila OFF si sospende per 5 minuti; una risposta riuscita azzera il conteggio
    violation: l'utente vede sempre i risultati interni e mai un errore dovuto a OFF
    source: C5; FR4.7; NFR6
  - id: BR2.3
    statement: Limiti delle richieste verso OFF
    category: constraint
    applies_to: RequestBudget
    trigger: prima di ogni richiesta a OFF
    logic: finestra mobile di 60 secondi; al massimo 8 ricerche (BR1.2, BR1.3) e 60 letture di prodotto (BR1.5); oltre il limite la richiesta non parte; le risposte dalla cache non contano
    violation: richiesta saltata, risultati solo interni
    source: documentazione OFF (100 letture al minuto, ricerca più limitata, blocco per abuso); C5
  - id: BR3.1
    statement: Profilo del vino senza finestre esterne
    category: policy
    applies_to: WineProfileResult
    trigger: getWineProfile(name, producer, vintage) (C1)
    logic: found = false, window assente e pairings vuota, perché nessuna fonte attuale ha finestre né abbinamenti; wineType, region e denomination si riempiono da ProfileHint con il nome normalizzato, oppure da recognizeDenomination di C2 sul nome; con found = false U4 non passa ExternalProfile a estimateWindow (in C2 è riservato a found = true) e copia wineType, region e denomination in WineFacts dove sono vuoti, così U2 li usa per riconoscere il vino; nessuna chiamata a OFF da questa operazione
    violation: nessuna
    source: FR4.2, FR7.2, A1; Q1; conferma del proprietario nel riepilogo ("la finestra resta quella delle regole interne")
  - id: BR4.1
    statement: Mappatura delle categorie di OFF
    category: calculation
    applies_to: WineCandidate
    trigger: prodotto di OFF trasformato in proposta
    logic: categorie di OFF (tag in inglese) -> wineType di C1 - red-wines: red; white-wines: white; rose-wines: rose; sparkling-wines e champagnes: sparkling; sweet-wines, dessert-wines e fortified-wines: sweet; altrimenti assente; il prodotto è un vino se ha il tag wines; denominazione con recognizeDenomination di C2 sul nome del prodotto; produttore dal campo brands (primo valore); region dal campo origins se presente; nome dal campo product_name, troncato a 120 caratteri
    violation: campi mancanti -> restano assenti; senza nome il prodotto si scarta
    source: C5 (il formato di OFF non esce da U3)
  - id: BR5.1
    statement: Nessun dato personale verso OFF
    category: constraint
    applies_to: WineCatalog
    trigger: ogni richiesta a OFF
    logic: si inviano solo il testo cercato (o le parole scelte dall'etichetta) e il codice a barre; mai email, uid, posizione, foto, nomi delle cantine o vini della cantina; l'identificativo della richiesta è `Vinoozy/<versione> (<contatto>)` con il contatto preso dalla configurazione della build, mai scritto nel codice; l'indirizzo IP del telefono arriva comunque a OFF, come per ogni sito
    violation: contatto non configurato -> OFF non si usa e restano i risultati interni
    source: C1 (nessun dato personale al fornitore); NFR8; documentazione OFF
  - id: BR5.2
    statement: Attribuzione dei dati di OFF
    category: policy
    applies_to: WineCandidate
    trigger: dati di OFF mostrati all'utente
    logic: U4 e U6 mostrano "Dati da Open Food Facts (ODbL)" accanto alle proposte con source = openFoodFacts; l'app ha nella schermata delle informazioni una voce fissa di attribuzione a Open Food Facts con il link alla licenza ODbL, che copre anche i vini salvati in cantina a partire da una proposta di OFF; i dati di OFF si usano solo in lettura
    violation: nessuna
    source: licenza ODbL di OFF; Q1-B
  - id: BR5.3
    statement: Informativa e controlli prima della pubblicazione
    category: policy
    applies_to: WineCatalog
    trigger: prima di pubblicare una versione che usa OFF
    logic: l'informativa privacy e la scheda "Sicurezza dei dati" di Google Play dichiarano che il testo cercato e i codici a barre vengono inviati a Open Food Facts (con l'indirizzo IP); la checklist di rilascio controlla che il contatto per OFF sia configurato
    violation: senza questi punti la versione non si promuove in produzione
    source: NFR8; documentazione OFF; regole di Google Play
```

## Riepilogo delle regole

| ID | Regola | Tipo |
|---|---|---|
| BR1.1 | Suggerimenti subito dal catalogo interno | calculation |
| BR1.2 | OFF dopo una pausa nella scrittura | policy |
| BR1.3 | Riconoscimento del testo dell'etichetta | calculation |
| BR1.4 | Niente doppioni | validation |
| BR1.5 | Ricerca per codice a barre | calculation |
| BR2.1 | Cache e indice dei profili sul telefono | policy |
| BR2.2 | OFF non blocca mai | policy |
| BR2.3 | Limiti delle richieste verso OFF | constraint |
| BR3.1 | Profilo senza finestre esterne | policy |
| BR4.1 | Mappatura delle categorie di OFF | calculation |
| BR5.1 | Nessun dato personale verso OFF | constraint |
| BR5.2 | Attribuzione ODbL | policy |
| BR5.3 | Informativa e controlli prima della pubblicazione | policy |
