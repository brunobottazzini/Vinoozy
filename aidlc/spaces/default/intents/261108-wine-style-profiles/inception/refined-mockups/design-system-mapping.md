# Corrispondenza con il design system

## Fonti

- `style-mockups.html`; componenti esistenti in `lib/cellar/ui/`.

| Elemento | Componente | Note |
|---|---|---|
| Segno "✦ suggerito" | stesso stile di "✦ dal testo" (`secondaryContainer` / `onSecondaryContainer`) | accanto all'etichetta del campo |
| Selettore Stile | `ChoiceChip` del tema in un `Wrap`, come la Tipologia | gruppo a scelta singola |
| Mese e anno | due `DropdownButtonFormField` affiancati | stesso stile dei campi del modulo |
| Finestra in mesi | `IdealMomentCard` esistente con etichette mese/anno | stessa barra |
| Avviso "Stile da confermare" | contenitore `wait` (giallo) già usato per gli stati | |
| Riquadro "Da confermare" nel cruscotto | `DashboardCard` esistente | |

Nessun colore o font nuovo; il tema scuro usa gli stessi token.
