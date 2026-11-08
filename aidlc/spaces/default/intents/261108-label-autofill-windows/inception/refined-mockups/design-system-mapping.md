# Corrispondenza con il design system

## Fonti

- `mockups.md` e `interaction-spec.md` di questa cartella.
- Design system della UX approvata: tema in `lib/app/theme.dart`, componenti in `lib/app/ui/` e `lib/cellar/ui/`.

| Elemento dei mockup | Componente esistente o nuovo | Note |
|---|---|---|
| Campo con "✦ dal testo" | `TextFormField` di `AddWineScreen` più un nuovo `FilledFromTextBadge` sotto il campo, al posto dell'`helperText`, mai sopra il valore | `onSecondaryContainer` su `secondaryContainer`, testo di almeno 12 sp; etichetta semantica |
| Barra Pulisci / Cerca online / Lens | nuovo `AutofillToolbar` con `ActionChip` del tema | altezza minima 48 dp |
| "Incolla da Lens" | nuovo `PasteFromLensCard` (`Card` più `FilledButton.tonal`) | testi negli ARB |
| Dialogo "Pulisci" | `AlertDialog` del tema | |
| Messaggi | `SnackBar` del tema, come "Bevuta segnata" | |
| Scelta del Livello | nuovo `WineLevelSelector`, sui `SegmentedButton` del tema | bordo tratteggiato per il suggerito, con un `CustomPainter` piccolo |
| Anteprima della finestra | testo in `IdealMomentCard` | |
| "corretto da te" | nuovo `CorrectedBadge`: `Chip` del tema con `secondaryContainer` (lo `StateChip` di oggi accetta solo `StatusFilter`) | |
| Pannello "Correggi" | `showModalBottomSheet` come `DrinkConfirmSheet`, griglia di `ChoiceChip` | |
| Riga "Stima dalla …" | `Text` con `bodySmall` sotto `IdealMomentCard` | |
| Foglio "Condividi" di Android | di sistema | Vinoozy compare con l'icona dell'app |

Nessun colore o font nuovo. Il tema scuro usa gli stessi token della UX approvata.

## Conferma guidata e attesa (FR2.8, FR7)

| Elemento | Componente | Note |
|---|---|---|
| Pulsante in attesa | `ActionChip`/`FilledButton.tonal` esistente con `CircularProgressIndicator` piccolo | disattivato durante l'attesa |
| Scheda della guida | nuovo `GuidedConfirmSheet` con `showModalBottomSheet` (`isScrollControlled`), come `DrinkConfirmSheet` | |
| Progresso | `Row` di barre con `colorScheme.primary` / `outlineVariant` | |
| Risposte | `FilledButton` (Sì), `OutlinedButton` (No, Modifica), `TextButton` (Salta) | griglia 2 × 2 |
| Parole | `FilterChip` del tema in un `Wrap` per riga, dentro un riquadro scorrevole `surfaceContainerHigh` | numero d'ordine nel chip scelto |
| Anteprima | `Container` con bordo `secondary`, sigla con `CorrectedBadge` | |
| "Conferma guidata" nella barra | `ActionChip` come "Pulisci" | |

Nessun colore o font nuovo.
