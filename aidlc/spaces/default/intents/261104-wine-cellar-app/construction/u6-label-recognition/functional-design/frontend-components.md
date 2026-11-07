# Frontend Components — u6-label-recognition

Fonti: `functional-spec.md` di U6, mockup M4 e M4a, `interaction-spec.md`, `frontend-components.md` di U4 (modulo di inserimento), riepilogo confermato in `functional-design-questions.md`.

## Gerarchia

```text
HomeShell (U1/U4)
└── AddChoiceScreen            "Aggiungi": Scatta foto · Importa una foto · Scrivi
    ├── LabelCaptureFlow       avvia fotocamera o galleria, gestisce annullamento e permessi
    │   └── LabelReadingScreen "Leggo l'etichetta…" con Annulla
    │       ├── LabelProposalSheet   proposta, quantità, Correggi, Conferma
    │       ├── LabelUnreadableView  "Non riesco a leggere l'etichetta", Riprova, Scrivi a mano
    │       └── PermissionDeniedView spiegazione, Apri impostazioni, Scrivi a mano
    └── AddWineScreen (U4)     modulo, anche già compilato
SharedImageHandler             riceve "Condividi → Vinoozy" e apre LabelReadingScreen
```

Testo equivalente: "Aggiungi" porta a tre scelte. Le due con la foto passano dalla schermata di lettura, che finisce in una proposta, in un messaggio di etichetta illeggibile, o nel modulo di U4 già compilato. Una foto condivisa da un'altra app entra direttamente nella lettura.

## Componenti

| Componente | Contenuto | Regole |
|---|---|---|
| `AddChoiceScreen` | Tre pulsanti grandi, uno sotto l'altro, con icona e testo: "Scatta foto", "Importa una foto", "Scrivi" | BR1.1 |
| `LabelCaptureFlow` | Apre la fotocamera o la galleria di sistema; ignora l'annullamento; con un rifiuto apre `PermissionDeniedView` | BR1.2, BR1.3, BR1.5 |
| `LabelReadingScreen` | Indicatore di avanzamento, "Leggo l'etichetta…", "Annulla"; esegue lettura e ricerca e cancella la copia in ogni caso | BR1.6–BR1.8, BR1.13 |
| `LabelProposalSheet` | "Ho riconosciuto:", nome, produttore, annata, `QuantityStepper` di U4 (1–99, da 1), "Correggi", "Conferma"; avviso senza rete | BR1.9, BR1.10 |
| `LabelUnreadableView` | Messaggio, "Riprova", "Scrivi a mano" | BR1.11 |
| `PermissionDeniedView` | Spiegazione per fotocamera o foto, "Apri impostazioni", "Scrivi a mano" | BR1.5 |
| `SharedImageHandler` | Riceve l'immagine condivisa; controlla accesso e `canEdit`; apre la lettura | BR1.4 |
| `AddWineScreen` (U4) | `AddWineInitialValues`: nome, produttore, annata, quantità, tipologia, regione, denominazione; avviso facoltativo in alto | BR1.10, BR1.11, BR1.15 |
| `DuplicateDialog` (U4, reso pubblico) | "Hai già … Aggiungere N bottiglie?", usato anche dalla proposta | BR1.15 |
| `BarcodeOnlyView` | Codice letto senza risultato o senza rete: messaggio, "Riprova", "Scrivi a mano", "Riprova quando torna la rete" | Chiarimenti dopo la revisione |

## Stati

| Schermata | Caricamento | Vuoto | Errore | Parziale |
|---|---|---|---|---|
| Lettura | "Leggo l'etichetta…" | — | Etichetta illeggibile, permesso negato | Senza rete: solo la denominazione |
| Proposta | — | — | Salvataggio come in U4 | Senza produttore o senza annata: il campo mostra "—" |
| Modulo dopo la foto | — | — | Come in U4 | "Non ho trovato il vino: controlla i dati" |

## Accessibilità

- I tre pulsanti di "Aggiungi" hanno un'etichetta per TalkBack uguale al testo, e un'area di tocco di almeno 48 dp.
- "Leggo l'etichetta…" è annunciato come stato di avanzamento. Proposta ed errori sono annunciati quando compaiono.
- Testo al 200% senza troncamenti: la proposta va a capo e scorre.
- Tutti i testi stanno nei file di traduzione (it, en, pt-BR).
- Chiavi di prova (`Key`) su ogni elemento interattivo: `add-choice-photo`, `add-choice-import`, `add-choice-write`, `label-cancel`, `label-confirm`, `label-correct`, `label-retry`, `label-write-by-hand`, `label-open-settings`.
