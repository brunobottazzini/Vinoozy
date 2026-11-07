# Business Rules — u5-dashboard

Fonti: `requirements.md` (FR5.1–FR5.6, FR4.5), `stories.md` (US5.1, US5.2), `contract-summary.md` (C2, C3, ADR-004), risposte in `functional-design-questions.md` (Q1, Q2). I flussi sono in `functional-spec.md`.

```yaml
rules:
  - id: BR1.1
    statement: Si contano le bottiglie, non le righe
    category: calculation
    applies_to: DashboardSummary
    trigger: ogni calcolo del cruscotto
    logic: ogni vino conta per quantity; quantity 0 escluso da lista e grafici; quantity negativa letta da C3 vale 0
    violation: nessuna
    source: FR5.3–FR5.5; C3 ADR-004
  - id: BR1.2
    statement: Lo stato si calcola con la data di oggi
    category: calculation
    applies_to: DashboardSummary
    trigger: apertura, cambio dei vini, cambio del giorno
    logic: statusOf(window, oggi) di C2, oggi = data locale senza ora; non si salva
    violation: vino senza window o con window non valida (statusOf lancia un errore di argomento) -> nessuno stato, contato come "da stimare"; l'errore si registra una volta in Crashlytics senza dati del vino; il resto del cruscotto continua
    source: FR4.5; C2
  - id: BR1.3
    statement: Lista "da bere presto"
    category: calculation
    applies_to: DrinkSoonItem
    trigger: ogni calcolo
    logic: vini con stato drinkSoon, ordinati per window.endYear crescente, poi nome normalizzato, poi annata; al massimo 10 righe, oltre compare "Vedi tutti (N)"
    violation: nessun vino -> "Nessuna bottiglia in scadenza"
    source: FR5.2; AC5.1.1, AC5.1.2
  - id: BR1.4
    statement: Grafico dello stato a quattro barre
    category: calculation
    applies_to: StatusCounts
    trigger: ogni calcolo
    logic: barre waiting, ready, drinkSoon, pastWindow in quest'ordine con il numero di bottiglie; vini senza window esclusi e mostrati come "N bottiglie da stimare" se N > 0
    violation: nessuna
    source: FR5.3; Q1
  - id: BR1.5
    statement: Grafico dei picchi
    category: calculation
    applies_to: PeakYearCounts
    trigger: ogni calcolo
    logic: colonne "picco passato" (peakYear < anno in corso), una per ogni anno da anno in corso a +10, "oltre"; colonne vuote con 0; vini senza window esclusi e mostrati come "N bottiglie da stimare" se N > 0
    violation: nessuna
    source: FR5.4
  - id: BR1.6
    statement: Terzo grafico per tipologia o regione
    category: calculation
    applies_to: BreakdownCounts
    trigger: ogni calcolo e cambio del selettore
    logic: selettore Tipologia/Regione, parte da Tipologia e ricorda la scelta sul telefono; tipologia con WineType.tryParse di C2 nelle cinque famiglie (rosso = redLight, redStructured; bianco = white; rosato = rose; spumante = sparklingClassic, sparklingTank; dolce = sweet, fortified), valore assente o sconosciuto = "non indicata"; regione = region del vino, altrimenti recognizeDenomination(denomination) di C2, altrimenti "non indicata"; confronto senza maiuscole né accenti, forma mostrata = la più frequente (a parità, alfabetica); "non indicata" fuori dalla classifica; prime 8 regioni per bottiglie (a parità alfabetico), poi "altre", poi "non indicata"
    violation: nessuna
    source: FR5.5; Q2
  - id: BR1.7
    statement: Numeri visibili e descrizione per il lettore schermo
    category: policy
    applies_to: grafici
    trigger: sempre
    logic: ogni barra riporta il numero e, nel grafico dello stato, la stessa icona dello stato usata nella lista (FR4.5); contrasto delle barre almeno 3:1 rispetto allo sfondo e del testo almeno 4,5:1; ogni grafico ha una descrizione testuale con titolo e coppie etichetta-valore nell'ordine mostrato, con il plurale corretto nelle tre lingue; il colore non è l'unico segnale
    violation: nessuna
    source: FR5.6; FR4.5; NFR3; AC5.2.1, AC5.2.2
  - id: BR1.8
    statement: Cantina vuota
    category: policy
    applies_to: DashboardScreen
    trigger: somma delle bottiglie = 0 e elenco non solo dalla cache locale (fromCacheOnly falso)
    logic: al posto di lista e grafici, invito "La tua cantina è vuota" con il pulsante "Aggiungi il primo vino" (U4)
    violation: nessuna
    source: FR5.6
  - id: BR1.9
    statement: Aggiornamento automatico e lavoro senza rete
    category: policy
    applies_to: DashboardScreen
    trigger: cambio dei vini locali o del giorno
    logic: il cruscotto legge i dati locali di U1 (winesStreamProvider; fromCacheOnly = WinesSnapshot.meta.isFromCache; campi producer, wineType, region, denomination, window letti da C3 con un'estensione in sola lettura del modello Wine di U1) e si ricalcola da solo; al cambio di giorno con un timer alla mezzanotte locale e al ritorno in primo piano; funziona senza rete; un solo passaggio sui vini per tutti i conteggi; con 0 bottiglie solo dalla cache mostra "Sincronizzazione della cantina…"
    violation: errore di lettura locale -> messaggio con "Riprova"
    source: FR5.1; NFR2; AC5.2.3
```

## Riepilogo

| ID | Regola | Tipo |
|---|---|---|
| BR1.1 | Bottiglie, non righe | calculation |
| BR1.2 | Stato con la data di oggi | calculation |
| BR1.3 | Lista "da bere presto" | calculation |
| BR1.4 | Grafico dello stato a quattro barre | calculation |
| BR1.5 | Grafico dei picchi | calculation |
| BR1.6 | Tipologia o regione | calculation |
| BR1.7 | Numeri e lettore schermo | policy |
| BR1.8 | Cantina vuota | policy |
| BR1.9 | Aggiornamento e lavoro senza rete | policy |
