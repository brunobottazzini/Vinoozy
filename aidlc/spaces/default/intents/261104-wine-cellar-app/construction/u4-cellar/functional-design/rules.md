# Business Rules — u4-cellar

Fonti: `requirements.md` (FR2, FR3, FR4, FR6, FR7, FR9.4, NFR1), `stories.md` (US2.1, US2.3, US3.1–US3.4, US4.1, US4.2, US6.1, US6.2, US7.1, US9.2), `contract-summary.md` (C1, C2, C3, C4, ADR-004), risposte in `functional-design-questions.md`. I flussi sono in `functional-spec.md`.

```yaml
rules:
  - id: BR1.1
    statement: Suggerimenti mentre si scrive
    category: workflow
    applies_to: AddWineScreen
    trigger: nome con almeno 3 caratteri
    logic: suggestWines di U3 con i vini della cantina attiva; con rete anche Open Food Facts; scegliendo una proposta si compilano nome, produttore, annata, tipologia, denominazione e regione
    violation: catalogo non disponibile -> solo suggerimenti interni e della cantina, senza errore
    source: FR2.1; AC2.1.1; C1
  - id: BR1.2
    statement: Produttore nuovo
    category: workflow
    applies_to: ProducerField
    trigger: scrittura nel campo produttore
    logic: proposte dal catalogo e dai vini caricati; ultima voce sempre "Aggiungi «testo» come nuovo produttore"; il testo si salva così com'è e compare tra le proposte successive
    violation: nessuna
    source: richiesta del proprietario 2026-11-06
  - id: BR1.3
    statement: Validazione del vino
    category: validation
    applies_to: AddWineScreen, EditWineScreen
    trigger: Salva
    logic: nome 1-120 caratteri dopo il trim; produttore al più 120; annata 1900-anno corrente o senza annata; quantità intera 1-99 (default 1); solo 0,75 L
    violation: errore sotto il campo, il resto resta
    source: FR2.4, FR2.6, FR2.7; AC2.1.3
  - id: BR1.4
    statement: Nessun doppione
    category: validation
    applies_to: AddWineScreen
    trigger: Salva
    logic: query where matchKey == chiave nella cantina attiva (server con rete, cache illimitata senza), finiti compresi; se esiste, si mostra la voce e, confermando, si aggiungono le bottiglie (BR1.15); nessuna voce nuova; backfill una tantum di matchKey sui vini di U1 (matchKeyBackfill sulla cantina); limite accettato offline per vini mai visti, con "Possibile doppione" e "Unisci"
    violation: annulla -> torna al modulo
    source: FR2.5; AC2.3.1
  - id: BR1.5
    statement: Stima al salvataggio
    category: calculation
    applies_to: WineEstimator
    trigger: salvataggio di un vino nuovo o modificato
    logic: estimateWindow e pairingsFor con regole interne, senza rete, in baseWindow; window = baseWindow con il riscontro (BR1.12); se needsRefinement e rete, getWineProfile di U3 e, se migliora, baseWindow, window e pairings; fonte da window.source e basis di C2
    violation: errore di stima -> vino salvato senza finestra ("da stimare")
    source: FR4.1-FR4.4, FR4.7, FR7.2; AC4.1.1-AC4.1.3; C1, C2
  - id: BR1.6
    statement: Ricalcolo al ritorno della rete
    category: calculation
    applies_to: EstimateRefresher
    trigger: ritorno della rete
    logic: vini con baseWindow.source internalRules e needsRefinement, uno per volta nei limiti di U3; si riapplica il riscontro
    violation: catalogo sospeso -> si riprova al ritorno successivo
    source: FR4.7; AC4.1.3
  - id: BR1.7
    statement: Elenco della cantina con archivio
    category: policy
    applies_to: CellarScreen
    trigger: apertura della Cantina
    logic: watchCellarWines con where quantity > 0 al posto di watchWines di U1, usato da winesStreamProvider (Cantina, Cruscotto, U7); valori negativi esclusi (finiti); archivio letto solo per id; riga con nome, annata, quantità, stato con icona e testo, fiducia; ordine per nome e annata; cantina vuota (non solo cache) -> invito al primo vino
    violation: nessuna
    source: FR3.1, FR4.5, FR6.4; AC3.1.1, AC3.1.2, AC4.2.3; unit-of-work.md U4 (archivio)
  - id: BR1.8
    statement: Ricerca e filtri
    category: workflow
    applies_to: CellarScreen
    trigger: testo di ricerca o filtri
    logic: ricerca su nome e produttore senza maiuscole e accenti; filtri per stato (4 stati + da stimare) e tipologia (5 famiglie + non indicata), combinabili; filtro di stato dal Cruscotto
    violation: nessun risultato -> "Nessun vino con questi filtri" e "Azzera filtri"
    source: FR3.2; AC3.2.1, AC3.2.2
  - id: BR1.9
    statement: Dettaglio con stima e abbinamenti
    category: policy
    applies_to: WineDetailScreen
    trigger: apertura del dettaglio
    logic: finestra, stato, fiducia, fonte (base dati vini, stima per tipologia, stima corretta dalle tue bevute), avviso fisso "Stima indicativa", abbinamenti con l'indicazione della tipologia, comandi secondo il permesso
    violation: vino senza finestra -> "Stima non disponibile" e "da stimare"
    source: FR4.1-FR4.5, FR7.1, FR7.2; AC4.1.1, AC4.1.2, AC4.2.1-AC4.2.3, AC7.1.1, AC7.1.2
  - id: BR1.10
    statement: Bevuta con annulla
    category: workflow
    applies_to: DrinkAction
    trigger: tocco su Bevuta
    logic: un batch con quantity -1 (increment) e un drinkingRecord con data di oggi; disattivata a quantità mostrata 0; messaggio di 6 secondi con Annulla (se la bevuta esiste ancora: la elimina e +1 con BR1.15, poi BR1.12; altrimenti "Non c'è più nulla da annullare") e Aggiungi voto e note; a 0 il vino esce dalla Cantina
    violation: solo lettura -> comando assente; regole -> percorso di U1/U7
    source: FR6.1, FR6.2, FR6.4; AC6.1.1, AC6.1.2; Q2
  - id: BR1.11
    statement: Voto, note, data e riscontro
    category: validation
    applies_to: DrinkingRecordSheet
    trigger: Aggiungi voto e note, oppure modifica dallo Storico
    logic: voto 1-5, note fino a 1000 caratteri, data non futura e non prima dell'annata, condition tooYoung/justRight/pastPeak facoltativa; li cambia chi ha registrato la bevuta o il proprietario
    violation: errore sotto il campo
    source: FR6.2; AC6.1.1; Q1
  - id: BR1.12
    statement: Riscontro sulla finestra
    category: calculation
    applies_to: WindowAdjuster
    trigger: riscontro salvato, ricalcolo della stima
    logic: riscontro della bevuta con condition più recente (drankOn, poi createdAt) salvato in windowAdjustment con recordId, applicato a baseWindow -> window; justRight con Y > fine -> fine = Y+1; pastPeak con inizio <= Y < fine -> fine = Y e picco <= fine; pastPeak con Y < inizio -> tutto - (fine-Y); tooYoung con Y >= inizio -> tutto + (Y+1-inizio); altrimenti window = baseWindow; fonte "stima corretta dalle tue bevute" e fiducia un livello più bassa (minimo bassa); a ogni cambio o annullamento si rilegge where wineId e si riapplica il più recente, o window = baseWindow
    violation: vino senza finestra -> riscontro conservato, nessun effetto
    source: Q1 (decisione di enologia motivata in functional-spec.md)
  - id: BR1.13
    statement: Modifica del vino
    category: workflow
    applies_to: EditWineScreen
    trigger: Salva nella modifica
    logic: nome, produttore, annata, tipologia, quantità (variazione, mai sotto 0); ricalcolo di matchKey, stima e abbinamenti
    violation: matchKey uguale a un altro vino -> avviso, nessun salvataggio
    source: FR3.3; AC3.3.1
  - id: BR1.14
    statement: Eliminazione con conferma
    category: authorization
    applies_to: WineDetailScreen
    trigger: Elimina
    logic: conferma con il nome; un batch (diviso oltre 400 operazioni) cancella il vino e tutte le sue bevute (where wineId), il vino per ultimo; nulla resta nello Storico; solo il proprietario
    violation: non proprietario -> comando assente
    source: FR3.4; AC3.4.1, AC3.4.2; u7 (eliminazione del proprietario)
  - id: BR1.15
    statement: Quantità come variazioni
    category: calculation
    applies_to: WineRepository
    trigger: ogni cambio di quantità
    logic: FieldValue.increment(delta); con valore salvato s < 0 e aumento +n si scrive increment(n - s) (risultato n); diminuzioni vietate a valore mostrato 0; altri campi: ultima modifica vince
    violation: nessuna
    source: FR9.4; AC9.2.1; ADR-004
  - id: BR1.16
    statement: Storico
    category: policy
    applies_to: HistoryScreen
    trigger: apertura della scheda Storico
    logic: bevute della cantina attiva ordinate per drankOn e createdAt decrescenti, a pagine di 30 con cursore (indice composto); tocco -> vino anche finito con Aggiungi di nuovo
    violation: nessuna bevuta -> "Qui troverai le bottiglie che hai bevuto"
    source: FR6.3; AC6.2.1, AC6.2.2; Q3
  - id: BR1.17
    statement: Collegamenti con il Cruscotto
    category: workflow
    applies_to: HomeShell
    trigger: azioni del Cruscotto
    logic: onOpenWine -> dettaglio; onOpenStatus -> Cantina filtrata; onAddFirstWine -> inserimento completo
    violation: nessuna
    source: FR5.2, FR5.3 (u5); unit-of-work.md U4
  - id: BR1.18
    statement: Velocità di inserimento
    category: policy
    applies_to: AddWineScreen
    trigger: Aggiungi
    logic: nome attivo all'apertura; salvataggio locale senza attese di rete; ritorno immediato alla Cantina
    violation: nessuna
    source: NFR1; AC2.1.2, AC2.1.4
  - id: BR1.19
    statement: Stime automatiche solo con permesso di modifica
    category: authorization
    applies_to: WineEstimator, EstimateRefresher, WindowAdjuster, MatchKeyBackfill
    trigger: ogni scrittura automatica di stima, riscontro o matchKey
    logic: solo con canEdit sulla cantina attiva; con solo lettura la finestra mancante si calcola in memoria e non si scrive
    violation: nessuna scrittura, quindi nessun falso accesso perso
    source: u7 BR1.6, BR1.14; FR8.4
  - id: BR1.20
    statement: Unisci un possibile doppione
    category: workflow
    applies_to: DuplicateBanner
    trigger: due vini con lo stesso matchKey nella stessa cantina
    logic: avviso Possibile doppione; Unisci solo per il proprietario e solo se la voce più recente non ha bevute: un batch con increment sulla voce più vecchia e delete della più recente
    violation: voce più recente con bevute -> solo avviso con Elimina questa voce se è un doppione
    source: FR2.5; BR1.4
```

## Riepilogo

| ID | Regola | Categoria |
|---|---|---|
| BR1.1 | Suggerimenti mentre si scrive | workflow |
| BR1.2 | Produttore nuovo | workflow |
| BR1.3 | Validazione del vino | validation |
| BR1.4 | Nessun doppione | validation |
| BR1.5 | Stima al salvataggio | calculation |
| BR1.6 | Ricalcolo al ritorno della rete | calculation |
| BR1.7 | Elenco della cantina con archivio | policy |
| BR1.8 | Ricerca e filtri | workflow |
| BR1.9 | Dettaglio con stima e abbinamenti | policy |
| BR1.10 | Bevuta con annulla | workflow |
| BR1.11 | Voto, note, data e riscontro | validation |
| BR1.12 | Riscontro sulla finestra | calculation |
| BR1.13 | Modifica del vino | workflow |
| BR1.14 | Eliminazione con conferma | authorization |
| BR1.15 | Quantità come variazioni | calculation |
| BR1.16 | Storico | policy |
| BR1.17 | Collegamenti con il Cruscotto | workflow |
| BR1.18 | Velocità di inserimento | policy |
| BR1.19 | Stime automatiche solo con permesso di modifica | authorization |
| BR1.20 | Unisci un possibile doppione | workflow |
