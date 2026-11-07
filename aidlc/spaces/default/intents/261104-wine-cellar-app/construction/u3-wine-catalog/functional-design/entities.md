# Entities — u3-wine-catalog

Fonti: `components.md` (WineCatalog, aggiornato il 2026-11-05), `unit-of-work.md` (U3), `contract-summary.md` (C1 v1 come interfaccia Dart, C2 con le funzioni di catalogo, C5), `requirements.md` (FR2.1, FR2.2, FR4.2, FR4.7, FR7.2, A1), risposte in `functional-design-questions.md` (Q1: catalogo interno e Open Food Facts insieme; Q2: dentro l'app).

U3 è un modulo Dart dentro l'app (`lib/catalog/`), non una funzione cloud. Implementa C1 come interfaccia Dart `WineCatalog`, con le stesse tre operazioni e gli stessi tipi, più le aggiunte compatibili scritte in `contract-summary.md`. Dietro l'interfaccia ci sono due fonti: il catalogo interno, sempre disponibile, e Open Food Facts (OFF), quando c'è rete. Il formato di OFF non esce mai da U3 (C5).

Per normalizzazione, riconoscimento delle denominazioni ed elenco delle denominazioni U3 usa le funzioni di catalogo di C2 (`normalizeWineText`, `recognizeDenomination`, `denominationCatalog`), aggiunte compatibili al pacchetto di U2. La dipendenza va solo da U3 a U2. U2 resta una libreria pura e non chiama U3: i dati esterni arrivano alla stima tramite U4.

```yaml
entities:
  - name: WineCandidate
    description: Un vino proposto all'utente (C1 WineCandidate). Nessun dato personale.
    attributes:
      - { name: name, type: string, required: true, constraints: "1-120 caratteri" }
      - { name: producer, type: string, required: false }
      - { name: vintage, type: integer, required: false }
      - { name: wineType, type: enum, required: false, allowed: [red, white, rose, sparkling, sweet], constraints: "valori di C1; U2 li mappa con la sua regola di mappatura delle tipologie" }
      - { name: region, type: string, required: false }
      - { name: denomination, type: string, required: false, constraints: "displayName della denominazione di U2 quando riconosciuta" }
      - { name: source, type: enum, required: true, allowed: [internal, cellar, openFoodFacts], constraints: "aggiunta compatibile a C1; serve all'attribuzione ODbL (BR5.2)" }
      - { name: barcode, type: string, required: false, constraints: "aggiunta compatibile; 13 cifre (BR1.5); solo per source = openFoodFacts" }

  - name: CellarWineRef
    description: Vino già presente nella cantina, passato da U4 a suggestWines (parametro facoltativo cellarWines, aggiunta compatibile a C1).
    attributes:
      - { name: name, type: string, required: true }
      - { name: producer, type: string, required: false }
      - { name: vintage, type: integer, required: false }
      - { name: wineType, type: enum, required: false, allowed: [red, white, rose, sparkling, sweet], constraints: "U4 converte la tipologia salvata nei valori di C1" }
    constraints: "U3 non legge Firestore né la cantina: usa solo ciò che U4 passa; al massimo 500 voci"

  - name: SuggestResult
    description: Risposta di suggestWines (C1).
    attributes:
      - { name: suggestions, type: "list of WineCandidate", required: true, constraints: "al massimo 10, senza doppioni (BR1.4)" }
      - { name: externalIncluded, type: boolean, required: true, constraints: "vero se ci sono risultati di OFF; aggiunta compatibile" }

  - name: LabelMatch
    description: Risposta di matchLabelText (C1).
    attributes:
      - { name: matched, type: boolean, required: true }
      - { name: candidate, type: WineCandidate, required: false, constraints: "presente se matched = true" }

  - name: WineProfileResult
    description: Risposta di getWineProfile (C1), consumata da U4 e passata a U2 come ExternalProfile.
    attributes:
      - { name: found, type: boolean, required: true, constraints: "vero solo se c'è una finestra; con le fonti attuali è sempre falso (BR3.1)" }
      - { name: window, type: object, required: false, constraints: "sempre assente con le fonti attuali" }
      - { name: confidence, type: enum, required: false, allowed: [high, medium, low] }
      - { name: pairings, type: "list of string", required: true, constraints: "vuota con le fonti attuali" }
      - { name: wineType, type: enum, required: false, allowed: [red, white, rose, sparkling, sweet] }
      - { name: region, type: string, required: false }
      - { name: denomination, type: string, required: false }

  - name: CatalogEntry
    description: Voce del catalogo interno, costruita da denominationCatalog di C2.
    attributes:
      - { name: displayName, type: string, required: true, constraints: "es. 'Barolo DOCG'" }
      - { name: denominationKey, type: string, required: true }
      - { name: searchTerms, type: "list of string", required: true, constraints: "displayName e alias normalizzati: sono le varianti dei nomi (es. 'Moscato d'Asti', 'Nebbiolo d'Alba')" }
      - { name: wineType, type: string, required: true }
      - { name: region, type: string, required: false }

  - name: CachedResponse
    description: Risposta riuscita di OFF conservata sul telefono (C5, 30 giorni).
    attributes:
      - { name: key, type: string, required: true, constraints: "'search:' + query normalizzata, oppure 'product:' + codice a 13 cifre" }
      - { name: payload, type: "list of WineCandidate", required: true, constraints: "già nel formato di U3, mai quello di OFF; lista vuota = nessun risultato" }
      - { name: storedAt, type: datetime, required: true }
    constraints: "scade dopo 30 giorni; al massimo 200 voci con al massimo 10 proposte ciascuna (NFR2.3), si eliminano le più vecchie; gli errori non si salvano (BR2.1)"

  - name: ProfileHint
    description: Indice dei dati utili alla stima ricavati dalle risposte di OFF, per getWineProfile (BR3.1).
    attributes:
      - { name: key, type: string, required: true, constraints: "nome normalizzato del vino (normalizeWineText)" }
      - { name: wineType, type: string, required: false }
      - { name: region, type: string, required: false }
      - { name: denomination, type: string, required: false }
    constraints: "si aggiorna a ogni risposta di OFF salvata in cache; stessa scadenza e stesso limite della cache"

  - name: RequestBudget
    description: Richieste a OFF negli ultimi 60 secondi, finestra mobile (BR2.3).
    attributes:
      - { name: searchTimestamps, type: "list of datetime", required: true, constraints: "al massimo 8" }
      - { name: productTimestamps, type: "list of datetime", required: true, constraints: "al massimo 60" }
```

## Riepilogo

- **Interfaccia:** `WineCatalog` con `suggestWines`, `matchLabelText`, `getWineProfile` (C1) e `lookupBarcode` (aggiunta compatibile, per U6). Errori solo `CatalogArgumentError` (C1).
- **Fonti:** catalogo interno (denominazioni di C2 con le varianti dei nomi, più i vini della cantina passati da U4) e OFF.
- **Dati salvati:** solo cache, indice dei profili e budget sul telefono. Nulla nel cloud.
