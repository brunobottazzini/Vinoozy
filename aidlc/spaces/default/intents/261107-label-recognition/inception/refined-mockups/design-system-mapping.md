# Mappatura sul design system — riconoscimento delle etichette

## Fonti

- `aidlc/spaces/default/intents/261107-ux-redesign/inception/refined-mockups/design-system-mapping.md`: palette, `WineCard`, `CountryFlag`, `StateChip`. Tutto riusato, senza colori nuovi.
- `mockups.md` e `interaction-spec.md` di questa fase.

## Componenti

| Componente | Base | Stato |
|---|---|---|
| `BackPhotoPrompt` ("Ora il retro") | pulsanti principali e secondari della UX | nuovo |
| `ReadingProgress` (fronte, retro, codice, base) | `StateChip` | nuovo |
| Proposta sicura | `WineCard` + pulsanti | cambia `LabelProposalSheet` |
| `CandidateList` | `WineCard` con chip "offline"/"online" | nuovo, riusa la lista dei suggerimenti del modulo |
| `NotFoundView` con "Cerca online", "Scrivi a mano", "Apri in Google Lens" | pulsanti principali e secondari; Lens come pulsante neutro | cambia le viste "non leggibile" e "solo codice" |
| `OnlineSearchScreen` | campo di ricerca, `CandidateList`, avviso colore `wait` | nuovo |
| `LensConfirmSheet` | pannello dal basso come `DrinkConfirmSheet` | nuovo |
| `AboutScreen` (Informazioni) | `tile` della Dashboard | nuovo |
| Attribuzione OFF | testo piccolo `onSurfaceVariant` | riusa quella dei suggerimenti |

## Colori e testo

- Palette e serif dei titoli della UX.
- Chip "offline" e "online" con testo (non solo colore).
- Avvisi nel colore `wait` (sfondo e testo con contrasto ≥ 4,5:1, già verificato).
