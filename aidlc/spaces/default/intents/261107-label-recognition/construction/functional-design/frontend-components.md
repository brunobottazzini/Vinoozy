# Componenti dell'interfaccia — riconoscimento delle etichette

## Fonti

- `inception/refined-mockups/design-system-mapping.md`, `interaction-spec.md` e `label-mockups.html`.
- `rules.md` e `functional-spec.md` di questa fase.

| Componente | Proprietà | Stato | Regole |
|---|---|---|---|
| `BackPhotoPrompt` | `onTake`, `onPick`, `onSkip` | nessuno | BR1.1, BR1.6 |
| `ReadingProgress` | passi (fronte, retro, codice, base) con stato; `onCancel` | annunci al lettore di schermo | F1, BR1.6 |
| `LabelProposalSheet` (cambiato) | candidato sicuro, quantità, fonte | salvataggio, errore | BR3.5, BR6.2 |
| `CandidateList` | candidati (massimo 10), `onPick`, `onNone` | nessuno | BR3.2, BR3.3, BR6.2 |
| `NotFoundView` | tipo (`unreadable`, `barcodeNotFound`, `noMatch`), testo letto, `photosAvailable` | nessuno | BR3.4, BR5.3 |
| `OnlineSearchScreen` | query iniziale | `idle`, `loading`, `results`, `empty`, `offline`, `rateLimited` | BR4.1–BR4.3 |
| `LensConfirmSheet` | `onConfirm`, `onCancel` | nessuno | BR5.1 |
| `AboutScreen` | versione, numero di vini, data della base | nessuno | BR6.3 |

## Validazione

Il campo "Cerca online" accetta da 1 a 120 caratteri, senza gli spazi esterni. Con il campo vuoto "Cerca" è disattivato.

## Integrazione

- Lettura: `LabelReader`, nativo.
- Ricerca: `CatalogCoordinator`, con la nuova fonte offline e la rete.
- Lens: un nuovo canale nativo, `vinoozy/lens`.
- Il modulo di aggiunta riceve `AddWineInitialValues`, compresi paese e regione della UX.
