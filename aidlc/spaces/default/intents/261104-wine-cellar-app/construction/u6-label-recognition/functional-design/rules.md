# Business Rules — u6-label-recognition

Fonti: `requirements.md` (FR2.2 con l'importazione del 2026-11-06, FR2.3, FR2.4, NFR8 aggiornato), `stories.md` (US2.2, AC2.2.1–AC2.2.5), `contract-summary.md` (C1), risposte in `functional-design-questions.md`. Il testo completo delle regole e i flussi sono in `functional-spec.md`.

```yaml
rules:
  - id: BR1.1
    statement: Tre ingressi per aggiungere un vino
    category: workflow
    applies_to: AddChoiceScreen
    trigger: tocco su "Aggiungi"
    logic: pulsanti "Scatta foto", "Importa una foto", "Scrivi"; solo con canEdit sulla cantina attiva
    violation: senza canEdit "Aggiungi" non compare (U7)
    source: FR2.2; AC2.2.5
  - id: BR1.2
    statement: Scatto con la fotocamera di sistema
    category: workflow
    applies_to: LabelCaptureFlow
    trigger: "Scatta foto"
    logic: apre la fotocamera di sistema; l'immagine scattata va alla lettura
    violation: ritorno senza scatto -> "Aggiungi", nessun messaggio
    source: FR2.2; AC2.2.1; AC2.2.4; Q2
  - id: BR1.3
    statement: Importazione di una foto dalla galleria
    category: workflow
    applies_to: LabelCaptureFlow
    trigger: "Importa una foto"
    logic: galleria di sistema, una sola immagine, poi lo stesso percorso dello scatto
    violation: scelta annullata -> "Aggiungi", nessun messaggio
    source: FR2.2 (2026-11-06); AC2.2.5
  - id: BR1.4
    statement: Foto condivisa verso l'app
    category: workflow
    applies_to: SharedImageHandler
    trigger: "Condividi" -> Vinoozy con un'immagine
    logic: apre la lettura; con più immagini usa la prima e lo dice; una nuova condivisione sostituisce la lettura in corso
    violation: senza accesso -> accesso, immagine ignorata; senza canEdit -> "Non puoi aggiungere vini a questa cantina"
    source: FR2.2 (2026-11-06); AC2.2.5
  - id: BR1.5
    statement: Permesso negato
    category: validation
    applies_to: PermissionDeniedView
    trigger: il sistema nega fotocamera o foto
    logic: spiegazione, "Apri impostazioni", "Scrivi a mano"
    violation: nessuna lettura
    source: AC2.2.4
  - id: BR1.6
    statement: La foto non si conserva
    category: constraint
    applies_to: LabelReadingScreen
    trigger: fine della lettura, errore, annullamento o chiusura
    logic: si cancella la copia temporanea; le copie rimaste si cancellano all'avvio; l'originale nella galleria non si tocca; nulla va nel cloud
    violation: nessuna (la cancellazione non deve mai fallire in silenzio, l'errore va nei report con motivo fisso)
    source: Q1; NFR8 (2026-11-06); FR1.4 (2026-11-06); AC2.2.5
  - id: BR1.7
    statement: Lettura di codice e testo sul telefono
    category: computation
    applies_to: LabelReadingScreen
    trigger: immagine disponibile
    logic: ML Kit legge codici EAN-13, EAN-8, UPC-A (normalizeBarcode di U3) e testo, al più 2.000 caratteri; senza rete
    violation: immagine danneggiata -> BR1.11
    source: FR2.2; AC2.2.1
  - id: BR1.8
    statement: Ordine di ricerca del vino
    category: workflow
    applies_to: LabelReadingScreen
    trigger: lettura completata con qualcosa di leggibile
    logic: codice valido e rete -> lookupBarcode; altrimenti o senza risultato -> matchLabelText; annata dal testo (1900..anno corrente)
    violation: errore del catalogo -> passo successivo, poi BR1.11
    source: FR2.2; AC2.2.1; Q3; C1
  - id: BR1.9
    statement: Proposta con quantità
    category: workflow
    applies_to: LabelProposalSheet
    trigger: vino trovato
    logic: "Ho riconosciuto:" nome, produttore, annata; quantità 1..99 da 1; senza rete avviso "solo la denominazione"
    violation: quantità fuori 1..99 non selezionabile
    source: FR2.4; AC2.2.1
  - id: BR1.10
    statement: Conferma o correzione esplicita
    category: workflow
    applies_to: LabelProposalSheet
    trigger: "Conferma" o "Correggi"
    logic: Conferma -> salvataggio di U4 con doppioni, stima e abbinamenti; Correggi -> modulo di U4 compilato
    violation: nessun salvataggio senza Conferma o Salva
    source: FR2.3; AC2.2.2
  - id: BR1.11
    statement: Etichetta illeggibile o vino non trovato
    category: validation
    applies_to: LabelUnreadableView
    trigger: niente di leggibile, errore di lettura, o nessun vino trovato
    logic: illeggibile -> messaggio, "Riprova", "Scrivi a mano"; non trovato -> modulo di U4 con nome dalla riga più significativa
    violation: nessuna scrittura
    source: AC2.2.3
  - id: BR1.12
    statement: Riga più significativa
    category: computation
    applies_to: LabelReadingScreen
    trigger: testo letto senza vino trovato
    logic: prima riga con una denominazione riconosciuta; altrimenti la più lunga con almeno 3 lettere, senza numeri soli, "ml", "% vol", "contiene solfiti"; al più 120 caratteri
    violation: nessuna riga valida -> nome vuoto
    source: AC2.2.3
  - id: BR1.13
    statement: Attesa annullabile
    category: workflow
    applies_to: LabelReadingScreen
    trigger: lettura o ricerca in corso
    logic: "Leggo l'etichetta…" con "Annulla"; i tempi massimi del catalogo sono quelli di U3
    violation: Annulla -> copia cancellata, ritorno ad "Aggiungi"
    source: AC2.2.3; NFR1
  - id: BR1.14
    statement: Nessun dato letto nei report
    category: constraint
    applies_to: LabelRecognition
    trigger: qualsiasi errore
    logic: solo motivi fissi label_read_failed, label_pick_failed, label_lookup_failed, label_cleanup_failed; mai testo, codice o immagine
    violation: nessuna
    source: NFR8; AC2.2.1
  - id: BR1.15
    statement: Integrazione con il modulo e il salvataggio di U4
    category: workflow
    applies_to: LabelProposalSheet, AddWineScreen (U4)
    trigger: "Conferma", "Correggi", proposta incompleta, "Scrivi a mano"
    logic: AddWineScreen accetta AddWineInitialValues (nome, produttore, annata, quantità 1..99, tipologia convertita dalla famiglia del catalogo, regione, denominazione, avviso); DuplicateDialog di U4 diventa pubblico; Conferma usa CellarActions.saveNewWine e, con AddDuplicate, la finestra dei doppioni
    violation: errore di salvataggio -> messaggio di U4, si resta sulla proposta con la quantità scelta
    source: FR2.3; FR2.4; AC2.2.1; AC2.2.2
```

Chiarimenti dopo la revisione (codice senza risultato, annata, modelli inclusi, permessi, casi della condivisione): `functional-spec.md`, sezione "Chiarimenti dopo la revisione".
