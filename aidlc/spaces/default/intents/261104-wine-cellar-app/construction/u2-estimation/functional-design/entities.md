# Entities — u2-estimation

Fonti: `components.md` (componente Estimation), `unit-of-work.md` (U2), `contract-summary.md` (C2 v1), `requirements.md` (FR4.1–FR4.7, FR7.2), risposte in `functional-design-questions.md` (Q1–Q3 e modifica richiesta).

U2 è una libreria pura: non salva nulla. Le entità sono valori in ingresso e in uscita delle funzioni di C2. Le tabelle interne (denominazioni, tipologie, abbinamenti) sono dati statici dentro la libreria, descritti in `rules.md`.

Aggiunte compatibili a C2 v1 decise qui (nessun campo esistente cambia significato): `WineFacts.referenceYear`, `DrinkingWindow.basis` (facoltativo in lettura), `DrinkingWindow.qualifier`, `Pairings.categoryKeys`. `Pairings.items` resta testo leggibile come in C2 v1. Nessuna versione pubblicata dell'app salva ancora finestre o abbinamenti (U1 non li gestisce), quindi non esistono dati vecchi da migrare; le regole di lettura sotto valgono comunque per robustezza.

```yaml
entities:
  - name: WineFacts
    description: Dati del vino passati alla stima (C2). Nessun dato personale.
    attributes:
      - { name: name, type: string, required: true, constraints: "1-60 caratteri dopo la pulizia degli spazi (C3)" }
      - { name: producer, type: string, required: false }
      - { name: vintage, type: integer, required: false, min: 1900, max: "anno corrente + 1", constraints: "assente = senza annata" }
      - { name: wineType, type: enum, required: false, allowed: [redLight, redStructured, white, rose, sparklingClassic, sparklingTank, sweet, fortified], constraints: "indicata dall'utente; ha precedenza su tutto ciò che è ricavato dal nome (BR1.2). In C3 è salvata come stringa: si accettano i nomi dell'enum e i valori di C1 mappati da BR1.7; altri valori = assente" }
      - { name: region, type: string, required: false }
      - { name: denomination, type: string, required: false, constraints: "indicata dall'utente o da C1; ha precedenza su quella ricavata dal nome" }
      - { name: referenceYear, type: integer, required: false, constraints: "anno in cui il vino è entrato in cantina (da createdAt di C3); obbligatorio quando vintage manca, altrimenti la stima è rifiutata come ingresso non valido (BR4.5). Così la stima non dipende mai dall'orologio (BR4.4)" }
    relationships: []

  - name: ExternalProfile
    description: Risposta di C1 getWineProfile con found = true (FR4.2).
    attributes:
      - { name: startYear, type: integer, required: true, constraints: "da window di C1" }
      - { name: peakYear, type: integer, required: true }
      - { name: endYear, type: integer, required: true }
      - { name: confidence, type: enum, required: false, allowed: [high, medium, low], constraints: "da C1; usata da BR3.1" }
      - { name: vintage, type: integer, required: false, constraints: "annata con cui è stato chiesto il profilo a C1; assente = senza annata" }
      - { name: pairings, type: "list of string", required: false }
      - { name: wineType, type: enum, required: false, allowed: [red, white, rose, sparkling, sweet], constraints: "da C1, mappata da BR1.7" }
      - { name: region, type: string, required: false }
      - { name: denomination, type: string, required: false }
    constraints: "usato per la finestra solo se window presente e startYear <= peakYear <= endYear; altrimenti la finestra viene dalle regole interne (BR1.6); wineType e denomination di C1 aiutano comunque il riconoscimento (BR1.7)"

  - name: RecognizedWine
    description: Risultato interno del riconoscimento dal nome (BR1.1), non esposto da C2.
    attributes:
      - { name: denominationKey, type: string, required: false, references: DenominationProfile }
      - { name: qualifier, type: enum, required: false, allowed: [riserva, superiore, granSelezione] }
      - { name: wineType, type: enum, required: false }

  - name: DenominationProfile
    description: Riga della tabella interna delle denominazioni (BR2.1). Dato statico.
    attributes:
      - { name: key, type: string, required: true, unique: true }
      - { name: aliases, type: "list of string", required: true, constraints: "confronto senza maiuscole, accenti e apostrofi" }
      - { name: wineType, type: enum, required: true }
      - { name: startOffset, type: integer, required: true, min: 0 }
      - { name: peakOffset, type: integer, required: true }
      - { name: endOffset, type: integer, required: true }
      - { name: qualifierOffsets, type: "map qualifier -> (start, peak, end)", required: false }
      - { name: pairingCategories, type: "list of PairingCategory", required: false }
    constraints: "startOffset <= peakOffset <= endOffset"

  - name: TypeProfile
    description: Riga della tabella interna per tipologia, più la riga generica (BR2.2). Dato statico.
    attributes:
      - { name: wineType, type: enum, required: true, allowed: [redLight, redStructured, white, rose, sparklingClassic, sparklingTank, sweet, fortified, generic] }
      - { name: startOffset, type: integer, required: true }
      - { name: peakOffset, type: integer, required: true }
      - { name: endOffset, type: integer, required: true }
      - { name: pairingCategories, type: "list of PairingCategory", required: true, constraints: "da 3 a 5" }

  - name: DrinkingWindow
    description: Finestra ideale stimata (C2; FR4.1, FR4.3).
    attributes:
      - { name: startYear, type: integer, required: true }
      - { name: peakYear, type: integer, required: true }
      - { name: endYear, type: integer, required: true }
      - { name: confidence, type: enum, required: true, allowed: [high, medium, low] }
      - { name: source, type: enum, required: true, allowed: [catalog, internalRules] }
      - { name: basis, type: enum, required: true, allowed: [catalog, denomination, wineType, generic], constraints: "aggiunta a C2; sempre prodotto da U2. In lettura di un dato salvato senza basis: catalog se source = catalog, altrimenti wineType (nessun avviso). generic fa mostrare l'avviso di stima non precisa" }
      - { name: qualifier, type: enum, required: false, allowed: [riserva, superiore, granSelezione] }
    constraints: "startYear <= peakYear <= endYear; basis = catalog se e solo se source = catalog"

  - name: WineStatus
    description: Stato derivato dalla data (FR4.5). Valore, non entità salvata.
    attributes:
      - { name: value, type: enum, required: true, allowed: [waiting, ready, drinkSoon, pastWindow] }

  - name: PairingCategory
    description: Categoria di cibi (Q3), chiave stabile tradotta dall'app nelle tre lingue.
    attributes:
      - { name: key, type: enum, required: true, allowed: [braisedRedMeat, grilledRedMeat, game, roastPoultry, poultry, pork, curedMeats, pastaMeatSauce, mushroomsTruffle, agedCheese, freshCheese, blueCheese, fish, seafood, rawSeafood, friedFood, vegetables, risotto, pizza, aperitif, pastries, dryBiscuits, chocolate, driedFruit, spicyDishes] }

  - name: Pairings
    description: Abbinamenti (C2; FR7.2).
    attributes:
      - { name: items, type: "list of string", required: true, constraints: "testi leggibili come in C2 v1: da 1 a 5 testi della fonte se source = catalog; vuota se source = internalRules" }
      - { name: categoryKeys, type: "list of PairingCategory", required: true, constraints: "aggiunta a C2: da 3 a 5 chiavi se source = internalRules, vuota se source = catalog; l'app le traduce" }
      - { name: source, type: enum, required: true, allowed: [catalog, internalRules] }
```

## Riepilogo

- **In ingresso:** `WineFacts`, più facoltativamente `ExternalProfile` dalla base dati esterna (U3, contratto C1).
- **In uscita:** `DrinkingWindow`, `WineStatus` e `Pairings`.
- **Dati statici:** `DenominationProfile` e `TypeProfile` sono le tabelle interne. Gli anni sono scostamenti dall'annata o dall'anno di riferimento.
- **Riconoscimento:** `RecognizedWine` è un passaggio interno, il riconoscimento dal nome.
- **Avviso:** `basis` dice su cosa si basa la stima. Con `generic` U4 mostra l'avviso "stima non precisa: manca la tipologia" e offre di indicarla a mano. Il codice da usare in U4 è `GENERIC_ESTIMATE` (BR4.3).
