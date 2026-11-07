# Frontend Components — u5-dashboard

Fonti: `functional-spec.md` di U5 (BR1.1–BR1.9), `requirements.md` (FR5.1–FR5.6, NFR3), `stories.md` (US5.1, US5.2), riepilogo confermato in `functional-design-questions.md`. Tutti i testi stanno nei file di traduzione (it, en, pt-BR), mai nel codice. Ogni elemento interattivo ha una chiave di test (`Key`) per l'automazione.

## Gerarchia

```text
DashboardScreen
├── DashboardEmptyState            (solo se 0 bottiglie, BR1.8)
└── DashboardContent (scorrevole)
    ├── DrinkSoonSection           (BR1.3)
    │   └── DrinkSoonTile × n
    ├── StatusChartCard            (BR1.4)
    ├── PeakYearChartCard          (BR1.5)
    └── BreakdownChartCard         (BR1.6)
        └── BreakdownToggle (Tipologia | Regione)
```

## Componenti

| Componente | Responsabilità | Dati | Interazioni | Chiave di test |
|---|---|---|---|---|
| `DashboardScreen` | Prima schermata dopo l'accesso (FR5.1); sceglie tra caricamento, sincronizzazione in corso, stato vuoto, errore e contenuto | `DashboardSummary` dal provider; azioni iniettate `onOpenWine`, `onOpenStatus`, `onAddFirstWine` | — | `dashboard-screen` |
| `DashboardEmptyState` | Invito con testo e pulsante (BR1.8) | — | Pulsante "Aggiungi il primo vino" chiama `onAddFirstWine` | `dashboard-empty-add` |
| `DrinkSoonSection` | Titolo "Da bere presto" e lista, oppure "Nessuna bottiglia in scadenza" (BR1.3) | `List<DrinkSoonItem>` | — | `dashboard-drink-soon` |
| `DrinkSoonTile` | Nome, annata, produttore, quantità, "entro <anno>" | `DrinkSoonItem` | Tocco chiama `onOpenWine`; massimo 10 righe, poi "Vedi tutti (N)" chiama `onOpenStatus` | `drink-soon-<wineId>`, `drink-soon-all` |
| `StatusChartCard` | Quattro barre con numeri, nota "N da stimare" (BR1.4, BR1.7) | `StatusCounts` | Tocco su una barra chiama `onOpenStatus` | `chart-status`, `chart-status-<stato>` |
| `PeakYearChartCard` | Colonne "picco passato", anno corrente…+10, "oltre" con numeri (BR1.5, BR1.7) | `PeakYearCounts` | Scorrimento orizzontale se lo schermo è stretto | `chart-peak` |
| `BreakdownChartCard` | Barre per tipologia o regione con numeri (BR1.6, BR1.7) | `BreakdownCounts` | — | `chart-breakdown` |
| `BreakdownToggle` | Selettore a due voci, scelta ricordata sul telefono | `BreakdownMode` | Tocco cambia vista | `breakdown-type`, `breakdown-region` |

## Modelli di vista

- `DashboardSummary`: `totalBottles`, `drinkSoon` (lista ordinata), `status` (quattro conteggi più `unestimated`), `peaks` (conteggi per colonna), `byType` e `byRegion` (liste etichetta–conteggio già ordinate).
- `DrinkSoonItem`: `wineId`, `name`, `vintage?`, `producer?`, `quantity`, `endYear`.
- I conteggi sono già pronti: i widget non contano e non ordinano.

## Accessibilità (FR5.6, NFR3)

- Ogni grafico è un contenitore `Semantics(container: true)` con la descrizione testuale di BR1.7 come etichetta. Dentro, ogni barra interattiva del grafico dello stato è un nodo figlio raggiungibile da solo, con etichetta "<stato>: <numero> bottiglie" e suggerimento "Apri l'elenco". TalkBack legge prima la descrizione e poi le singole barre.
- I numeri sono scritti sopra o dentro le barre con contrasto almeno 4,5:1, e le barre hanno contrasto almeno 3:1 rispetto allo sfondo. Le barre dello stato hanno la stessa icona dello stato usata nella lista (FR4.5), quindi il colore non è mai l'unico segnale.
- Bersagli di tocco di almeno 48 dp (barre, righe, selettore). Testo scalabile fino al 200% senza tagli: i grafici diventano scorrevoli in orizzontale.
- Le descrizioni sono tradotte nelle tre lingue con il plurale corretto ("1 bottiglia", "2 bottiglie").

## Stati di caricamento ed errore

- **Sincronizzazione in corso:** con 0 bottiglie lette solo dalla cache locale compare "Sincronizzazione della cantina…" al posto dello stato vuoto (BR1.8, BR1.9).
- **Primo caricamento:** scheletro grigio dei tre riquadri, senza indicatore che gira all'infinito. I dati locali arrivano in genere in meno di un secondo.
- **Errore di lettura locale:** messaggio "Impossibile preparare la cantina" con il pulsante "Riprova", lo stesso testo e modello di U1. (Nota del 2026-11-06: allineato a `security-design.md` §4; prima c'era "Impossibile leggere la cantina".)
