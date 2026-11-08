# Mappatura sul design system — nuova UX

## Fonti

- `lib/app/theme.dart` e `StatusColors` (da `codekb/Vinoozy/component-inventory.md`).
- `mockups.md`, `vinoozy-mockups.html` e `interaction-spec.md`.

## Token di colore

Material 3 `ColorScheme`, definiti in `lib/app/theme.dart`. Il contrasto del testo dev'essere ≥ 4,5:1.

| Token | Chiaro | Scuro | Uso |
|---|---|---|---|
| `primary` | bordeaux `#7A1F32` | rosa vino `#D9768A` | pulsanti principali, titoli, FAB |
| `onPrimary` | `#FFFFFF` | `#2A1015` | testo sui pulsanti |
| `secondary` | oro `#9A6B12` | oro chiaro `#E3B95C` | accenti, stelle, bordo di "Ho bevuto" |
| `secondaryContainer` | `#F3E3BF` | `#4A3A1C` | sfondo di "Ho bevuto" |
| `surface` | crema `#FBF6EE` | `#1D1517` | sfondo delle schermate |
| `surfaceContainer` | `#FFFFFF` | `#2A1F22` | schede |
| `surfaceContainerHigh` | `#F3EBE1` | `#33262A` | elemento scelto |
| `outline` | `#D8CCC6` | `#3A2C30` | bordi |
| `onSurface` / `onSurfaceVariant` | `#2A1D20` / `#6B5A5D` | `#F2E8E4` / `#BFAEAE` | testo |

`StatusColors` resta per gli stati, con i nuovi colori (sfondo e testo):

| Stato | Chiaro | Scuro |
|---|---|---|
| Da bere ora | `#DCEFDC` / `#2F6B3A` | `#1F3A24` / `#A9DCAE` |
| Aspettare | `#F6E7C4` / `#7A5A0F` | `#46391A` / `#F0D48A` |
| Oltre il picco | `#F7DADA` / `#8E2B2B` | `#4A2223` / `#F3B2B2` |

Nuovo `WineTypeColors`, come `ThemeExtension`: rosso `#8E1B2C`, bianco `#C9A227`, rosato `#D4687C`, bollicine `#7F8F3A`, dolce `#A8642A`. Nel tema scuro gli stessi colori sono schiariti. Si usano solo come fascia o pallino, sempre accanto al nome del tipo.

## Tipografia

Roboto di sistema, nessun font nuovo (NFR3). I titoli delle schermate usano il `titleLarge` in bordeaux. Il numero grande della Dashboard usa `displaySmall`.

## Forme e spazi

- Schede: raggio 14 dp, bordo `outline` di 1 dp, nessuna ombra.
- FAB: raggio 16 dp.
- Pannello dal basso: raggio 22 dp.
- Chip: raggio pieno.
- Spaziatura base 4 dp: 8, 12, 16.

## Componenti nuovi o cambiati

| Componente | File (previsto) | Stato |
|---|---|---|
| `CountryFlag`, con la sigla di riserva | `lib/app/ui/country_flag.dart` | nuovo |
| `CountryPicker`, `RegionPicker` | `lib/cellar/ui/origin_pickers.dart` | nuovo |
| Elenco di paesi e regioni con i nomi canonici e localizzati | `lib/cellar/domain/wine_origins.dart` | nuovo |
| `WineCard` | sostituisce `lib/cellar/ui/wine_list_tile.dart` | cambiato |
| `StateChip`, `WineTypeBadge` | `lib/cellar/ui/wine_badges.dart` | nuovo |
| `DrinkConfirmSheet` | `lib/cellar/ui/drink_confirm_sheet.dart` | nuovo |
| `drink_flow.dart` | apre il pannello prima della scrittura | cambiato |
| `BarChart` | aggiunge icona o bandiera per riga | cambiato |
| `AddWineScreen`, `EditWineScreen`, dettaglio, Dashboard, Storico | usano i componenti sopra | cambiati |

## Navigazione

Invariata. Le icone delle schede diventano distinte: Dashboard 📊, Cantina con l'icona della bottiglia, Storico 📖. "Ho bevuto" usa i calici 🥂.
