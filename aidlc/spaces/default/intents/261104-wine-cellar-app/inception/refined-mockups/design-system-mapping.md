# Design System Mapping — Vinoozy

Fonti: `mockups.md`, `interaction-spec.md`, `wireframes.md` (palette bordeaux), `team-practices.md` (Flutter), `requirements.md` (NFR3, FR10.2).

Base: **Material 3** di Flutter, personalizzato con i token sotto. Nessuna libreria di componenti esterna.

## Token di colore

| Token | Chiaro | Scuro | Uso |
|-------|--------|-------|-----|
| primary | #7B1E3A (bordeaux) | #E8A0B4 | pulsanti principali, voce attiva |
| onPrimary | #FFFFFF | #3E0A1C | testo su primary |
| surface | #FFF8F3 (crema) | #1E1A1B | sfondo |
| onSurface | #2B2224 | #EDE0E2 | testo |
| statusWaiting | #5B6B8C | #A9B8D8 | ⏳ da aspettare |
| statusReady | #2E7D4F | #8FD3A8 | ✓ pronto |
| statusDrinkSoon | #B35C00 | #FFB870 | ⚠ da bere presto |
| statusPast | #8E3B3B | #E6A0A0 | ✕ oltre la finestra |
| error | #B3261E | #F2B8B5 | errori |

Ogni coppia testo/sfondo va verificata a 4.5:1 in Construction; i colori di stato sono sempre accompagnati da icona e testo.

## Tipografia e spaziatura

- Tipografia Material 3 predefinita (Roboto), scale `titleLarge` per i titoli, `bodyLarge` per le righe; tutto in `sp` per seguire la dimensione di sistema.
- Spaziatura a multipli di 4 dp (4, 8, 16, 24, 32); aree toccabili minime 48x48 dp.

## Mappatura componenti

| Elemento dei mockup | Componente Material 3 / Flutter | Note |
|---------------------|---------------------------------|------|
| Barra in basso | `NavigationBar` | 4 `NavigationDestination` con etichetta sempre visibile |
| Barra superiore | `AppBar` | avatar profilo come `IconButton` |
| Fascia offline | `MaterialBanner` | testo + icona nuvola barrata |
| Riga vino | `ListTile` personalizzato (WineListTile) | |
| Stato | `Chip` di sola lettura (StatusBadge) | |
| - / + | `IconButton` x2 (QuantityStepper) | |
| Aggiungi: due scelte | `FilledButton.tonal` x2 | stessa dimensione |
| Conferme | `AlertDialog` (ConfirmDialog) | |
| Annulla bevuta | `SnackBar` con `SnackBarAction` | durata 6 s |
| Dettagli bevuta | `showModalBottomSheet` | |
| Grafici | Barre orizzontali disegnate con widget Flutter | numeri sempre visibili; libreria di grafici da scegliere in progettazione |
| Presentazione | `PageView` + indicatore a punti | |
| Campi | `TextFormField` con etichetta sopra | |

## Temi e lingue

- `ThemeMode.system` per chiaro/scuro (FR10.2).
- Testi in file di localizzazione `arb` per it, en, pt-BR; inglese come lingua di riserva (FR10.1, team-practices Code Style).
