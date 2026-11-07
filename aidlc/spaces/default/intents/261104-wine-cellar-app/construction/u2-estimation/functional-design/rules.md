# Business Rules — u2-estimation

Fonti: `requirements.md` (FR4.1–FR4.7, FR7.2, A1, A3), `contract-summary.md` (C2 v1), `stories.md` (US4.1, US4.2, US7.1), risposte in `functional-design-questions.md`.

Le scelte enologiche (tabelle, scostamenti, abbinamenti, livelli di fiducia) sono decise dal progettista come da regola del progetto (`project.md`, Corrections): sono motivate qui sotto e correggibili in qualsiasi momento senza cambiare l'API.

```yaml
rules:
  - id: BR1.1
    statement: Denominazione, qualifica e tipologia si ricavano dal nome quando l'utente non le indica
    category: calculation
    applies_to: WineFacts
    trigger: estimateWindow o pairingsFor senza denomination o wineType
    logic: si normalizza il nome (minuscole, senza accenti; apostrofi e punteggiatura diventano spazi) e lo si divide in parole; un alias (normalizzato allo stesso modo) è trovato solo se compare come sequenza di parole intere, quindi "castiglione" non contiene "asti"; IF più alias sono trovati THEN vince quello con più parole, a parità il primo nel nome; la tipologia è quella della denominazione; IF il nome contiene le parole "riserva", "superiore" o "gran selezione" e la denominazione ha scostamenti per quella qualifica THEN qualifier corrispondente, altrimenti la qualifica si ignora e si usa la riga base
    violation: nessun alias trovato -> denominazione sconosciuta; la tipologia resta quella indicata dall'utente o sconosciuta
    source: FR4.2; Q1
  - id: BR1.2
    statement: La tipologia e la denominazione indicate dall'utente hanno precedenza su tutto ciò che è ricavato dal nome
    category: policy
    applies_to: WineFacts
    trigger: WineFacts.wineType o WineFacts.denomination presenti, o tipologia da C1
    logic: (1) IF denomination indicata ed è nella tabella THEN si usa quella e il nome non viene analizzato per la denominazione. (2) ELSE IF wineType indicata THEN la denominazione ricavata dal nome si usa solo se ha la stessa tipologia; se la tipologia è diversa, il riconoscimento dal nome è considerato sbagliato e si usa la tabella per tipologia con la tipologia indicata (BR2.2). (3) ELSE IF C1 indica una tipologia THEN si applica la stessa regola del passo 2 con la tipologia di C1 (mappata da BR1.7). (4) ELSE vale BR1.1. In questo modo la tipologia inserita a mano, o quella della base dati, corregge sempre un riconoscimento sbagliato
    violation: denomination indicata ma sconosciuta -> si procede come senza denominazione indicata (passi 2 e 3)
    source: FR4.2; richiesta di modifica del proprietario (tipologia a mano)
  - id: BR1.3
    statement: Senza annata gli anni si contano dall'anno di riferimento
    category: calculation
    applies_to: DrinkingWindow
    trigger: WineFacts.vintage assente
    logic: anno base = referenceYear - 1 per i vini fermi e dolci, referenceYear per gli spumanti (sparklingClassic, sparklingTank) e per la stima generica; la fiducia è sempre low (BR3.1). referenceYear viene dal chiamante (createdAt di C3), mai dall'orologio
    violation: vintage e referenceYear entrambi assenti -> ingresso non valido (BR4.5)
    source: C2 rule "senza annata"; FR4.3
  - id: BR1.4
    statement: La base dati esterna ha precedenza sulle regole interne
    category: policy
    applies_to: DrinkingWindow, Pairings
    trigger: estimateWindow o pairingsFor con ExternalProfile valido
    logic: IF ExternalProfile ha una finestra valida THEN finestra = anni di ExternalProfile, source = catalog, basis = catalog, fiducia secondo BR3.1; abbinamenti dalla fonte se presenti
    violation: profilo non valido -> BR1.6
    source: FR4.2, FR7.2; C2 estimateWindow
  - id: BR1.5
    statement: Una stima da regole interne va ricalcolata alla prima connessione
    category: policy
    applies_to: DrinkingWindow
    trigger: needsRefinement
    logic: needsRefinement = (source = internalRules)
    violation: nessuna
    source: FR4.7; C2 needsRefinement
  - id: BR1.6
    statement: Un profilo esterno incoerente viene ignorato
    category: validation
    applies_to: ExternalProfile
    trigger: ExternalProfile ricevuto
    logic: IF window assente OR NOT (startYear <= peakYear <= endYear) OR un anno fuori da 1900..2200 THEN la finestra del profilo si ignora e si usano le regole interne; wineType e denomination del profilo restano utilizzabili da BR1.7
    violation: si usano le regole interne, la stima resta da ricalcolare (BR1.5)
    source: FR4.2; NFR6 (robustezza)
  - id: BR1.7
    statement: Mappatura delle tipologie tra contratti
    category: calculation
    applies_to: WineFacts, ExternalProfile
    trigger: tipologia in arrivo da C1 o letta da C3 come stringa
    logic: nomi dell'enum di WineFacts accettati così come sono; valori di C1 -> red: redStructured, white: white, rose: rose, sparkling: sparklingClassic, sweet: sweet; ogni altro valore -> tipologia assente. Ordine di precedenza della tipologia: utente (WineFacts.wineType), poi C1, poi denominazione riconosciuta. Lo stesso vale per la denominazione: utente, poi C1 (se nella tabella), poi nome
    violation: valore sconosciuto -> trattato come assente, nessun errore
    source: C1 v1-getWineProfile, C3; FR4.2
  - id: BR2.1
    statement: Con una denominazione nota la finestra si calcola dalla tabella delle denominazioni
    category: calculation
    applies_to: DrinkingWindow
    trigger: denominazione riconosciuta (BR1.1 o BR1.2) e nessun profilo esterno valido
    logic: anno base = vintage (o BR1.3); IF qualifier ha scostamenti propri THEN si usano quelli; startYear = base + startOffset; peakYear = base + peakOffset; endYear = base + endOffset; basis = denomination; source = internalRules
    violation: nessuna
    source: FR4.1, FR4.2
  - id: BR2.2
    statement: Senza denominazione nota la finestra si calcola dalla tabella per tipologia, o da quella generica
    category: calculation
    applies_to: DrinkingWindow
    trigger: nessuna denominazione e nessun profilo esterno valido
    logic: IF tipologia nota THEN TypeProfile della tipologia, basis = wineType ELSE TypeProfile generic, basis = generic; anni come in BR2.1
    violation: nessuna; con basis = generic l'app mostra l'avviso (BR4.3)
    source: FR4.1, FR4.2; Q2
  - id: BR3.1
    statement: Livello di fiducia
    category: calculation
    applies_to: DrinkingWindow
    trigger: ogni stima
    logic: catalog -> la confidence di C1 se presente, altrimenti high; IF il profilo è stato chiesto senza annata (ExternalProfile.vintage assente e WineFacts.vintage assente) THEN al massimo low (regola C2 "senza annata"); se ExternalProfile.vintage manca ma WineFacts.vintage c'è, vale l'annata di WineFacts; denomination con annata -> medium; denomination senza annata -> low; wineType -> low; generic -> low
    violation: nessuna
    source: FR4.3; C2 rule "senza annata"
  - id: BR3.2
    statement: Stato del vino rispetto alla data di oggi
    category: calculation
    applies_to: WineStatus
    trigger: statusOf
    logic: IF today < 1 gennaio di startYear THEN waiting; IF today > 31 dicembre di endYear THEN pastWindow; ELSE ready, oppure drinkSoon secondo BR3.3
    violation: nessuna
    source: FR4.5
  - id: BR3.3
    statement: Da bere presto
    category: calculation
    applies_to: WineStatus
    trigger: stato ready
    logic: today è una data di calendario locale senza ora, passata dal chiamante; durata = (endYear - startYear + 1) x 12 mesi; preavviso = round(25% della durata) limitato tra 3 e 12; mesi mancanti = mesi di calendario dal primo giorno del mese di today al 1 gennaio di endYear + 1, cioè (endYear + 1 - anno di today) x 12 - (mese di today - 1) (il 1 gennaio dell'ultimo anno dà 12, il 1 settembre dà 4); IF mesi mancanti <= preavviso THEN drinkSoon
    violation: nessuna
    source: FR4.6; A3; AC4.2.1 (15 anni, 11 mesi -> drinkSoon), AC4.2.2 (1 anno, 4 mesi -> ready)
  - id: BR4.1
    statement: Abbinamenti da regole interne
    category: calculation
    applies_to: Pairings
    trigger: pairingsFor senza abbinamenti della fonte esterna
    logic: IF la denominazione ha pairingCategories THEN quelle ELSE quelle della tipologia (o generiche); categoryKeys da 3 a 5 chiavi; items vuota; source = internalRules
    violation: nessuna
    source: FR7.2; Q3
  - id: BR4.2
    statement: Abbinamenti della fonte esterna
    category: policy
    applies_to: Pairings
    trigger: ExternalProfile con almeno un abbinamento
    logic: items = primi 5 abbinamenti della fonte (almeno 1); categoryKeys vuota; source = catalog
    violation: lista vuota -> BR4.1
    source: FR7.2; AC7.1.1
  - id: BR4.3
    statement: La stima generica si dichiara come tale
    category: policy
    applies_to: DrinkingWindow
    trigger: basis = generic
    logic: U2 espone basis = generic con il codice di avviso GENERIC_ESTIMATE; U4 mostra l'avviso "stima non precisa: manca la tipologia" con un'azione per indicare la tipologia a mano, che poi passa come WineFacts.wineType (BR1.2). La progettazione di U4 deve avere un criterio di accettazione che rimanda a BR4.3
    violation: nessuna
    source: Q2 e richiesta di modifica del proprietario
  - id: BR4.4
    statement: Le funzioni sono pure e deterministiche
    category: constraint
    applies_to: tutte le funzioni di C2
    trigger: sempre
    logic: stesso ingresso (compreso today) -> stessa uscita; nessun accesso a rete, disco, orologio o Firebase; today è sempre passato dal chiamante
    violation: nessuna
    source: unit-of-work U2 (nessuna dipendenza da Flutter o Firebase); NFR7
  - id: BR4.5
    statement: Ingressi non validi
    category: validation
    applies_to: WineFacts
    trigger: estimateWindow o pairingsFor
    logic: IF name vuoto dopo la pulizia THEN errore di argomento; IF vintage o referenceYear fuori da 1900..2200 THEN errore di argomento (il limite "anno corrente + 1" di C3 resta un controllo di U1/U4 all'inserimento, perché U2 non legge l'orologio); IF vintage e referenceYear entrambi assenti THEN errore di argomento; tipologie e denominazioni sconosciute non sono errori (BR1.7)
    violation: errore di argomento al chiamante (U4), che non salva una stima; nessuna eccezione per dati semplicemente sconosciuti
    source: C3 (validazioni del vino); NFR6
```

## Tabella delle denominazioni (BR2.1)

Gli anni si contano dall'annata: per esempio "8 / 15 / 30" significa inizio annata + 8, picco + 15, fine + 30. Motivazione: affinamento minimo previsto dal disciplinare, più l'evoluzione tipica in bottiglia per un'annata media. Le annate eccezionali le tratterà la base dati esterna (U3).

| Denominazione | Tipologia | Inizio / Picco / Fine | Qualifiche | Abbinamenti |
|---|---|---|---|---|
| Barolo | redStructured | 8 / 15 / 30 | Riserva 10 / 18 / 35 | braisedRedMeat, game, mushroomsTruffle, agedCheese |
| Barbaresco | redStructured | 6 / 12 / 25 | Riserva 8 / 15 / 30 | braisedRedMeat, game, mushroomsTruffle, agedCheese |
| Brunello di Montalcino | redStructured | 8 / 15 / 30 | Riserva 10 / 18 / 35 | grilledRedMeat, game, agedCheese, mushroomsTruffle |
| Rosso di Montalcino | redLight | 2 / 4 / 8 | — | pastaMeatSauce, roastPoultry, curedMeats |
| Amarone della Valpolicella | redStructured | 6 / 12 / 25 | Riserva 8 / 15 / 30 | braisedRedMeat, game, agedCheese |
| Valpolicella Ripasso | redStructured | 3 / 5 / 10 | Superiore 3 / 6 / 12 | pastaMeatSauce, grilledRedMeat, agedCheese |
| Valpolicella | redLight | 1 / 2 / 5 | Superiore 2 / 4 / 8 | curedMeats, pastaMeatSauce, poultry |
| Chianti Classico | redStructured | 3 / 6 / 12 | Riserva 5 / 8 / 15; Gran Selezione 6 / 10 / 20 | grilledRedMeat, pastaMeatSauce, agedCheese |
| Chianti | redLight | 1 / 3 / 6 | Riserva 3 / 5 / 10 | pastaMeatSauce, curedMeats, pizza |
| Vino Nobile di Montepulciano | redStructured | 4 / 8 / 15 | Riserva 5 / 10 / 20 | grilledRedMeat, game, agedCheese |
| Bolgheri | redStructured | 4 / 8 / 15 | Superiore 6 / 12 / 25 | grilledRedMeat, game, agedCheese |
| Taurasi | redStructured | 6 / 12 / 25 | Riserva 8 / 15 / 30 | braisedRedMeat, game, agedCheese |
| Aglianico del Vulture | redStructured | 5 / 10 / 20 | Superiore 6 / 12 / 25 | braisedRedMeat, game, agedCheese |
| Sagrantino di Montefalco | redStructured | 6 / 12 / 25 | — | braisedRedMeat, game, agedCheese |
| Etna Rosso | redStructured | 3 / 7 / 15 | Riserva 5 / 10 / 20 | grilledRedMeat, mushroomsTruffle, agedCheese |
| Langhe Nebbiolo, Nebbiolo d'Alba | redStructured | 3 / 6 / 12 | Superiore 4 / 8 / 15 | pastaMeatSauce, mushroomsTruffle, roastPoultry |
| Gattinara, Ghemme | redStructured | 6 / 12 / 25 | Riserva 8 / 15 / 30 | braisedRedMeat, game, agedCheese |
| Valtellina Superiore | redStructured | 4 / 8 / 15 | Riserva 5 / 10 / 20 | game, agedCheese, mushroomsTruffle |
| Sforzato di Valtellina | redStructured | 5 / 10 / 20 | — | braisedRedMeat, game, agedCheese |
| Barbera d'Asti | redLight | 2 / 4 / 8 | Superiore 3 / 6 / 12 | pastaMeatSauce, curedMeats, pizza |
| Nizza | redStructured | 4 / 7 / 14 | Riserva 5 / 9 / 18 | grilledRedMeat, pastaMeatSauce, agedCheese |
| Barbera d'Alba | redLight | 2 / 4 / 8 | Superiore 3 / 6 / 12 | pastaMeatSauce, curedMeats, pizza |
| Dolcetto | redLight | 1 / 2 / 4 | Superiore 1 / 3 / 6 | curedMeats, pastaMeatSauce, pizza |
| Montepulciano d'Abruzzo | redLight | 2 / 4 / 8 | Riserva 4 / 7 / 14 | pastaMeatSauce, grilledRedMeat, pizza |
| Primitivo di Manduria | redStructured | 2 / 4 / 8 | Riserva 3 / 6 / 12 | grilledRedMeat, spicyDishes, agedCheese |
| Cannonau di Sardegna | redStructured | 2 / 5 / 10 | Riserva 4 / 7 / 14 | grilledRedMeat, game, agedCheese |
| Teroldego Rotaliano | redStructured | 2 / 5 / 10 | Riserva 3 / 7 / 14 | grilledRedMeat, game, curedMeats |
| Lagrein | redLight | 2 / 4 / 8 | Riserva 3 / 6 / 12 | pork, curedMeats, agedCheese |
| Lambrusco | redLight | 0 / 1 / 2 | — | curedMeats, pizza, pastaMeatSauce |
| Soave | white | 1 / 2 / 5 | Superiore 2 / 4 / 8 | fish, vegetables, risotto |
| Verdicchio dei Castelli di Jesi | white | 1 / 3 / 8 | Riserva 3 / 6 / 12 | fish, seafood, risotto |
| Fiano di Avellino | white | 2 / 5 / 10 | Riserva 3 / 6 / 12 | fish, seafood, freshCheese |
| Greco di Tufo | white | 1 / 3 / 7 | Riserva 2 / 5 / 10 | seafood, fish, vegetables |
| Vermentino di Gallura | white | 1 / 2 / 4 | Superiore 1 / 3 / 6 | seafood, fish, vegetables |
| Gavi | white | 1 / 2 / 4 | Riserva 2 / 4 / 8 | fish, seafood, aperitif |
| Lugana | white | 1 / 2 / 5 | Superiore 2 / 4 / 8; Riserva 3 / 5 / 10 | fish, risotto, freshCheese |
| Etna Bianco | white | 2 / 4 / 10 | Superiore 2 / 5 / 12 | seafood, fish, risotto |
| Trebbiano d'Abruzzo | white | 1 / 3 / 8 | Superiore 2 / 4 / 10 | fish, vegetables, freshCheese |
| Derthona, Timorasso | white | 3 / 6 / 12 | — | fish, risotto, agedCheese |
| Franciacorta | sparklingClassic | 1 / 3 / 6 | Riserva 3 / 7 / 12 | aperitif, rawSeafood, friedFood, risotto |
| Trento | sparklingClassic | 1 / 3 / 6 | Riserva 3 / 7 / 12 | aperitif, rawSeafood, friedFood |
| Prosecco | sparklingTank | 0 / 1 / 2 | Superiore 0 / 1 / 3 | aperitif, friedFood, seafood |
| Asti, Moscato d'Asti | sweet | 0 / 1 / 2 | — | pastries, dryBiscuits, aperitif |
| Recioto della Valpolicella | sweet | 4 / 10 / 25 | — | blueCheese, chocolate, pastries |
| Passito di Pantelleria | sweet | 2 / 8 / 20 | — | blueCheese, pastries, driedFruit |
| Vin Santo | sweet | 5 / 10 / 30 | Riserva 8 / 15 / 40 | dryBiscuits, blueCheese, driedFruit |
| Marsala | fortified | 3 / 10 / 30 | Superiore 5 / 12 / 40; Riserva 8 / 15 / 50 | agedCheese, chocolate, driedFruit |

## Tabella per tipologia (BR2.2)

| Tipologia | Inizio / Picco / Fine | Abbinamenti | Motivo |
|---|---|---|---|
| redLight (rosso leggero) | 1 / 2 / 4 | curedMeats, pastaMeatSauce, poultry, pizza | rossi giovani e fruttati, poco tannino |
| redStructured (rosso strutturato) | 3 / 7 / 15 | braisedRedMeat, grilledRedMeat, game, agedCheese | tannino e acidità che reggono l'affinamento |
| white (bianco) | 0 / 2 / 4 | fish, seafood, vegetables, freshCheese | la maggior parte dei bianchi si beve giovane |
| rose (rosato) | 0 / 1 / 2 | aperitif, fish, pizza, vegetables | freschezza da bere entro due anni |
| sparklingClassic (metodo classico) | 1 / 3 / 6 | aperitif, rawSeafood, friedFood, risotto | dal momento dell'acquisto, dopo la sboccatura |
| sparklingTank (charmat) | 0 / 1 / 2 | aperitif, friedFood, seafood | aromi primari che svaniscono presto |
| sweet (dolce o passito) | 2 / 8 / 20 | blueCheese, pastries, dryBiscuits | zucchero e acidità conservano a lungo |
| fortified (fortificato) | 3 / 10 / 30 | agedCheese, chocolate, driedFruit | alcol e ossidazione controllata |
| generic (sconosciuta) | 1 / 3 / 6 | agedCheese, curedMeats, pastaMeatSauce | valore prudente a metà tra bianchi e rossi; fiducia bassa e avviso (BR4.3) |

## Riepilogo delle regole

| ID | Regola | Tipo |
|---|---|---|
| BR1.1 | Denominazione, qualifica e tipologia ricavate dal nome | calculation |
| BR1.2 | Tipologia e denominazione dell'utente hanno precedenza | policy |
| BR1.3 | Senza annata si conta dall'anno di riferimento | calculation |
| BR1.4 | La base dati esterna ha precedenza | policy |
| BR1.5 | Le stime interne vanno ricalcolate alla prima connessione | policy |
| BR1.6 | Profilo esterno incoerente ignorato | validation |
| BR2.1 | Finestra dalla tabella delle denominazioni | calculation |
| BR2.2 | Finestra dalla tabella per tipologia o generica | calculation |
| BR3.1 | Livello di fiducia | calculation |
| BR3.2 | Stato rispetto a oggi | calculation |
| BR3.3 | Da bere presto | calculation |
| BR4.1 | Abbinamenti interni | calculation |
| BR4.2 | Abbinamenti della fonte esterna | policy |
| BR4.3 | La stima generica si dichiara come tale | policy |
| BR4.4 | Funzioni pure e deterministiche | constraint |
| BR1.7 | Mappatura delle tipologie tra contratti | calculation |
| BR4.5 | Ingressi non validi | validation |
