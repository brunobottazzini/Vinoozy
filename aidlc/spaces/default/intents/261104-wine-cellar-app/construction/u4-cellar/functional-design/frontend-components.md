# Frontend Components — u4-cellar

Fonti: `functional-spec.md` e `rules.md` di U4 (BR1.1–BR1.18), `requirements.md` (FR2, FR3, FR4, FR6, FR7), `stories.md`, riepilogo confermato in `functional-design-questions.md`. Tutti i testi stanno nei file di traduzione (it, en, pt-BR). Ogni elemento interattivo ha una chiave di test.

## Gerarchia

```text
HomeShell (U1 + U5 + U7)
├── Cruscotto (U5)                 azioni collegate da U4 (BR1.17)
├── Cantina: CellarScreen          (BR1.7, BR1.8)
│   ├── CellarSearchBar
│   ├── CellarFilters (stato, tipologia)
│   ├── WineListTile × n
│   └── FAB "Aggiungi" → AddWineScreen
├── Storico: HistoryScreen         (BR1.16)
│   └── DrinkingRecordTile × n
└── (pagine)
    ├── AddWineScreen              (BR1.1–BR1.5, BR1.18)
    │   ├── WineNameField + SuggestionList
    │   ├── ProducerField + "Aggiungi come nuovo produttore"
    │   ├── VintageField (con "senza annata"), WineTypeField, QuantityStepper
    │   └── DuplicateDialog
    ├── WineDetailScreen           (BR1.9, BR1.10, BR1.14)
    │   ├── WindowCard (finestra, stato, fiducia, fonte, avviso fisso)
    │   ├── PairingsCard
    │   ├── QuantityStepper, DrinkButton, azioni
    │   └── RecentDrinks
    ├── EditWineScreen             (BR1.13)
    └── DrinkingRecordSheet        (BR1.11, BR1.12)
```

## Componenti

| Componente | Responsabilità | Dati | Interazioni | Chiave di test |
|---|---|---|---|---|
| `CellarScreen` | Elenco dei vini presenti, ricerca, filtri, stati vuoti (BR1.7, BR1.8) | vini con quantity > 0 della cantina attiva | Tocco su riga → dettaglio; "Azzera filtri"; FAB solo con `canEdit` | `cellar-screen`, `cellar-search`, `cellar-filter-status-<s>`, `cellar-filter-type-<t>`, `cellar-clear-filters` |
| `WineListTile` | Nome, annata, quantità, stato (icona + testo), fiducia | `Wine` + stato del giorno | Tocco → dettaglio; con `canEdit`, azione rapida "Bevuta" | `wine-tile-<id>`, `wine-tile-drink-<id>` |
| `AddWineScreen` | Inserimento completo (BR1.1–BR1.5) | catalogo U3, vini caricati | Proposta → compila; "Salva" → controllo dei doppioni | `add-wine-name`, `add-wine-suggestion-<i>`, `add-wine-producer`, `add-wine-new-producer`, `add-wine-vintage`, `add-wine-no-vintage`, `add-wine-type`, `add-wine-quantity`, `add-wine-save` |
| `DuplicateDialog` | Mostra il vino esistente e la quantità; conferma l'aggiunta di bottiglie (BR1.4) | vino esistente | "Aggiungi N bottiglie", "Annulla" | `duplicate-confirm`, `duplicate-cancel` |
| `WineDetailScreen` | Dettaglio (BR1.9); comandi secondo il permesso | `Wine`, ultime bevute | "Bevuta", +/−, "Modifica", "Elimina" (solo proprietario), "Aggiungi di nuovo" se finito | `wine-detail`, `wine-drink`, `wine-plus`, `wine-minus`, `wine-edit`, `wine-delete`, `wine-add-again` |
| `WindowCard` | Inizio, picco, fine, stato, fiducia, fonte e avviso fisso "Stima indicativa…" | finestra effettiva | — | `window-card`, `window-disclaimer` |
| `PairingsCard` | Abbinamenti; nota "abbinamenti generici per la tipologia" | `Pairings` | — | `pairings-card` |
| `DrinkSnackBar` | Messaggio dopo la bevuta: "Annulla" e "Aggiungi voto e note", 6 s (BR1.10) | bevuta appena creata | Annulla → elimina e +1; Aggiungi → `DrinkingRecordSheet` | `drink-undo`, `drink-add-notes` |
| `DrinkingRecordSheet` | Voto (5 stelle), note, data, "Com'era?" (BR1.11) | bevuta | "Salva" | `record-rating-<n>`, `record-notes`, `record-date`, `record-condition-<k>`, `record-save` |
| `EditWineScreen` | Modifica (BR1.13) | `Wine` | "Salva" | `edit-wine-save` |
| `DuplicateBanner` | Avviso "Possibile doppione" nel dettaglio; "Unisci" solo per il proprietario e senza bevute sulla voce più recente (BR1.20) | le due voci con lo stesso `matchKey` | "Unisci" → conferma | `duplicate-banner`, `duplicate-merge` |
| `DeleteWineDialog` | Conferma con il nome (BR1.14) | nome del vino | "Elimina", "Annulla" | `delete-confirm` |
| `HistoryScreen` | Bevute dalla più recente, a pagine (BR1.16) | `drinkingRecords` | Tocco → dettaglio del vino; modifica voto e note | `history-screen`, `history-tile-<id>` |

## Stati

- **Caricamento:** scheletri delle righe.
- **Vuoto:** Cantina con l'invito al primo vino; Storico con "Qui troverai le bottiglie che hai bevuto"; filtri senza risultati.
- **Offline:** banner di U1; tutto funziona tranne i suggerimenti esterni.
- **Solo lettura:** nessun FAB, nessuna "Bevuta", +/−, modifica o eliminazione; Storico consultabile.
- **Errore di salvataggio:** percorso di U1 (`SyncErrorBus`).

## Accessibilità

- Stato sempre con icona e testo (FR4.5).
- Le stelle del voto hanno etichette ("Voto 4 su 5").
- Il messaggio della bevuta resta finché TalkBack non l'ha letto: durata più lunga quando le animazioni sono ridotte.
- Aree di tocco di almeno 48×48 dp; testo al 200% senza tagli; contrasto ≥ 4,5:1.
