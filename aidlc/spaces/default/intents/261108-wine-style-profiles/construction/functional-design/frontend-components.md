# Componenti di interfaccia — profili di stile

**Collaborator:** aidlc-architect-agent

## Fonti

- `inception/refined-mockups/mockups.md` (S1–S6), `interaction-spec.md` (con le precisazioni R-01…R-08), `accessibility-checklist.md`.
- `codekb/Vinoozy/component-inventory.md`: `WineTypeField`, `LevelSection`, `WineLevelSelector`, `IdealMomentCard`, `window_override_widgets.dart`, `DashboardCalculator`.
- `lib/l10n/app_it.arb`: convenzioni delle chiavi (`level*`, `estimate*`, `override*`, `window*`).
- `rules.md` BR4–BR8, `entities.md`.
- `reviews/review-01.md` e decisioni del proprietario del 2026-11-09 (Livello assoluto, Sherry senza stile).

Testi in `app_it.arb`, `app_en.arb`, `app_pt_BR.arb` (team.md). Ogni area toccabile ≥ 48 dp; matrice di accessibilità esistente valida per i componenti nuovi (NFR5).

## Gerarchia

```
AddWineScreen / EditWineScreen
├── WineTypeField                  (esistente) + SuggestedMark + RestoreSuggestionLink
├── StyleField                     (nuovo)     chip a scelta singola, BR5.1–BR5.3
├── AgingStartField                (nuovo)     mese + anno con YearWheel, BR8
├── LevelSection                   (esistente) + SuggestedMark + RestoreSuggestionLink
└── EstimatePreview                (esistente) con formato in mesi
WineDetailScreen
├── StyleToConfirmBanner           (nuovo)     S4
├── TypeChooser                    (nuovo)     "Scegli la tipologia" se manca, R-01
├── StyleField                     (riuso)     sotto l'avviso, salva subito
└── IdealMomentCard                (esistente) mesi, picco e fine null, origine del profilo
CellarScreen / WineCard            (esistente) "entro mar 2027", "pronto"
DashboardScreen
├── ToConfirmCard                  (nuovo)     S6
├── DrinkSoonSection               (esistente) mese
└── PeakYearsChart                 (esistente) esclude i picchi null
```

## Componenti

### SuggestedMark
- **Props**: `visible` (bool).
- **Aspetto**: "✦ suggerito" accanto all'etichetta del campo, stessa coppia di colori del segno "✦ dal testo". Un solo segno per campo (R-07): il chip scelto è evidenziato come ogni chip.
- **Semantica**: unito all'etichetta del campo ("Tipologia, Rosso strutturato, suggerito").

### RestoreSuggestionLink
- **Props**: `field`, `suggestedValue`, `onRestore`.
- **Visibile** solo se il campo è `user` e il suggerimento esiste ed è diverso (BR7.3). Testo "Ripristina suggerimento"; il tocco imposta il valore e `source = auto`; annuncio "Suggerimento ripristinato".

### StyleField
- **Props**: `wineType`, `options` (BR5.2), `selected`, `suggested`, `source`, `onChanged`, `saveImmediately` (true nel dettaglio).
- **Stato**: nessuno locale; il form tiene `style` e `styleSource`.
- **Sherry senza parola di stile** (BR2.8): nessun chip preselezionato, avviso "Stile da confermare" fino alla scelta.
- **Visibilità**: BR5.1. Con Tipologia vuota non c'è; compare appena si sceglie la Tipologia.
- **Interazione**: tocco su un chip → scelta, `source = user` (anche sul chip suggerito); se il livello è `auto` si ricalcola (BR4.6); la stima si aggiorna e il lettore di schermo annuncia "Stima aggiornata: {testo}" (R-08).
- **Semantica**: gruppo a scelta singola "Stile, Fresco, 1 di 2, suggerito"; chip alti 48 dp.

### AgingStartField
- **Props**: `label` (Sboccatura o Imbottigliamento, BR8.1), `month`, `year`, `vintage`, `onChanged`.
- **Visibile** solo con un profilo in mesi.
- **Parti**: menu del mese (gennaio–dicembre, nomi della lingua dell'app) e anno con la ruota già usata per l'annata, con tocco per scriverlo (R-08); intervallo 1950..anno corrente.
- **Validazione** (BR8.2): "Indica mese e anno" se manca una delle due parti; "La data non può essere nel futuro"; "Non può essere prima dell'annata". Errore sotto il campo, salvataggio bloccato.
- **Nota** sotto i campi: "Di solito è sull'etichetta posteriore."

### LevelSection (modificato)
- Opzioni di oggi (Quotidiano, Buono, Da invecchiamento, Nessuno); in più segno "✦ suggerito" e "Ripristina suggerimento".
- Moltiplicatore assoluto come oggi (D5): l'anteprima "con e senza livello" resta quella di oggi; per i profili in mesi o senza fine: testo "Il livello non cambia questa stima".

### StyleToConfirmBanner
- **Condizione**: BR5.4.
- **Testo**: "⚠︎ Stile da confermare: la stima è indicativa"; colori del banner di avviso esistente, contrasto AA in tema chiaro e scuro.
- Sotto: `TypeChooser` (se la Tipologia manca) o `StyleField` con salvataggio immediato.

### IdealMomentCard (modificato)
- Finestra in mesi: "Da bere da marzo 2026", "Al meglio marzo 2027", "Consigliato fino a marzo 2029".
- Picco null: niente riga "Al meglio", niente segno nella barra. Fine null: "Pronto, nessuna fine stimata", barra aperta a destra.
- Origine: "Stima dal profilo {stile} ({denominazione})" (BR5.5); con data mancante: "Dalla data di inserimento: aggiungi la sboccatura per una stima migliore" (o "l'imbottigliamento").
- "Consigliato fino al": foglio con mese e anno per i profili in mesi (BR6.8).

### ToConfirmCard (cruscotto)
- Conteggio e lista dei vini con avviso e dei vini "Da stimare" (BR6.7); tocco → dettaglio. Nascosto se vuoto.

### Formattazione dei mesi
- `formatMonthLong(year, month, locale)` → "marzo 2027" / "March 2027" / "março de 2027" (`DateFormat.yMMMM`).
- `formatMonthShort` → "mar 2027" / "Mar 2027" / "mar. de 2027" (`DateFormat.yMMM`).
- Lettore di schermo: sempre la forma lunga.

## Chiavi ARB

| Chiave | it | en | pt-BR |
|---|---|---|---|
| `suggestedMark` | ✦ suggerito | ✦ suggested | ✦ sugerido |
| `suggestedSemantics` | {field}, {value}, suggerito | {field}, {value}, suggested | {field}, {value}, sugerido |
| `restoreSuggestion` | Ripristina suggerimento | Restore suggestion | Restaurar sugestão |
| `restoreSuggestionDone` | Suggerimento ripristinato | Suggestion restored | Sugestão restaurada |
| `styleLabel` | Stile | Style | Estilo |
| `styleGroupSemantics` | Stile, {value}, {index} di {count} | Style, {value}, {index} of {count} | Estilo, {value}, {index} de {count} |
| `styleRedFresh` | Fresco | Fresh | Fresco |
| `styleRedMedium` | Medio | Medium | Médio |
| `styleRedAge` | Da evoluzione | For ageing | Para envelhecer |
| `styleRedLong` | Di lunga evoluzione | Long ageing | Longa guarda |
| `styleWhiteFresh` | Fresco | Fresh | Fresco |
| `styleWhiteMedium` | Medio | Medium | Médio |
| `styleWhiteAge` | Da evoluzione | For ageing | Para envelhecer |
| `styleClassicFresh` | Fresco | Fresh | Fresco |
| `styleClassicAge` | Da evoluzione | For ageing | Para envelhecer |
| `styleTankFresh` | Fresco | Fresh | Fresco |
| `styleLambrusco` | Lambrusco | Lambrusco | Lambrusco |
| `styleSweetAromatic` | Aromatico | Aromatic | Aromático |
| `styleSweetPassito` | Passito | Dried-grape | Passito |
| `styleSweetBotrytis` | Botritizzato | Botrytised | Botritizado |
| `stylePortVintage` | Porto Vintage | Vintage Port | Porto Vintage |
| `stylePortLbv` | Porto LBV/Ruby | LBV/Ruby Port | Porto LBV/Ruby |
| `stylePortTawny` | Porto Tawny/Colheita | Tawny/Colheita Port | Porto Tawny/Colheita |
| `styleSherryFino` | Fino/Manzanilla | Fino/Manzanilla | Fino/Manzanilla |
| `styleSherryAmontillado` | Amontillado | Amontillado | Amontillado |
| `styleSherryOloroso` | Oloroso/Cream | Oloroso/Cream | Oloroso/Cream |
| `styleSherryPx` | Pedro Ximénez | Pedro Ximénez | Pedro Ximénez |
| `styleMadeira` | Madeira | Madeira | Madeira |
| `styleFortifiedOther` | Altro | Other | Outro |
| `profileName_R_FRESH` | Rosso orientato al frutto | Fruit-forward red | Tinto frutado |
| `profileName_R_MEDIUM` | Rosso di struttura media | Medium-bodied red | Tinto de corpo médio |
| `profileName_R_AGE` | Rosso da evoluzione | Red for ageing | Tinto para envelhecer |
| `profileName_R_LONG` | Rosso di lunga evoluzione | Long-ageing red | Tinto de longa guarda |
| `profileName_W_FRESH` | Bianco fresco e aromatico | Fresh aromatic white | Branco fresco e aromático |
| `profileName_W_MEDIUM` | Bianco di struttura media | Medium-bodied white | Branco de corpo médio |
| `profileName_W_AGE` | Bianco da evoluzione | White for ageing | Branco para envelhecer |
| `profileName_ROSE_FRESH` | Rosato fresco | Fresh rosé | Rosé fresco |
| `profileName_SP_TANK` | Spumante Charmat fresco | Fresh tank-method sparkling | Espumante Charmat fresco |
| `profileName_LAM_FRESH` | Lambrusco fresco | Fresh Lambrusco | Lambrusco fresco |
| `profileName_SP_CLASSIC` | Metodo classico fresco | Fresh traditional-method sparkling | Método tradicional fresco |
| `profileName_SP_CLASSIC_AGE` | Metodo classico da evoluzione | Traditional-method sparkling for ageing | Método tradicional para envelhecer |
| `profileName_SW_AROMATIC` | Dolce aromatico giovane | Young aromatic sweet wine | Doce aromático jovem |
| `profileName_SW_PASSITO` | Passito da evoluzione | Dried-grape sweet wine | Passito para envelhecer |
| `profileName_SW_BOTRYTIS` | Dolce botritizzato | Botrytised sweet wine | Doce botritizado |
| `profileName_PORT_VINTAGE` | Porto Vintage | Vintage Port | Porto Vintage |
| `profileName_PORT_LBV` | Porto LBV/Ruby | LBV/Ruby Port | Porto LBV/Ruby |
| `profileName_PORT_OX` | Porto Tawny/Colheita | Tawny/Colheita Port | Porto Tawny/Colheita |
| `profileName_SH_FINO` | Fino/Manzanilla | Fino/Manzanilla | Fino/Manzanilla |
| `profileName_SH_AMONT` | Amontillado/Medium | Amontillado/Medium | Amontillado/Medium |
| `profileName_SH_OLOROSO` | Oloroso/Cream | Oloroso/Cream | Oloroso/Cream |
| `profileName_SH_PX` | Sherry Pedro Ximénez | Pedro Ximénez Sherry | Xerez Pedro Ximénez |
| `profileName_FORT_UNKNOWN` | Liquoroso da distinguere | Fortified, style unknown | Fortificado a definir |
| `profileName_UNKNOWN` | Stile non identificato | Style not identified | Estilo não identificado |
| `estimateFromProfile` | Stima dal profilo {profile} ({denomination}) | Estimate from the {profile} profile ({denomination}) | Estimativa pelo perfil {profile} ({denomination}) |
| `estimateFromProfileType` | Stima dal profilo {profile}, dal tipo | Estimate from the {profile} profile, by type | Estimativa pelo perfil {profile}, pelo tipo |
| `estimateFromEntryDateDisgorgement` | Dalla data di inserimento: aggiungi la sboccatura per una stima migliore | From the date added: add the disgorgement date for a better estimate | Pela data de inclusão: adicione o dégorgement para uma estimativa melhor |
| `estimateFromEntryDateBottling` | Dalla data di inserimento: aggiungi l'imbottigliamento per una stima migliore | From the date added: add the bottling date for a better estimate | Pela data de inclusão: adicione o engarrafamento para uma estimativa melhor |
| `styleToConfirmBanner` | ⚠︎ Stile da confermare: la stima è indicativa | ⚠︎ Style to confirm: the estimate is indicative | ⚠︎ Estilo a confirmar: a estimativa é indicativa |
| `chooseTypePrompt` | Scegli la tipologia | Choose the type | Escolha o tipo |
| `estimateUpdatedAnnouncement` | Stima aggiornata: {summary} | Estimate updated: {summary} | Estimativa atualizada: {summary} |
| `agingStartDisgorgement` | Sboccatura | Disgorgement | Dégorgement |
| `agingStartBottling` | Imbottigliamento | Bottling | Engarrafamento |
| `agingStartMonth` | Mese | Month | Mês |
| `agingStartYear` | Anno | Year | Ano |
| `agingStartHint` | Di solito è sull'etichetta posteriore. | It is usually on the back label. | Geralmente está no rótulo de trás. |
| `agingStartIncomplete` | Indica mese e anno | Enter month and year | Informe mês e ano |
| `agingStartFuture` | La data non può essere nel futuro | The date cannot be in the future | A data não pode estar no futuro |
| `agingStartBeforeVintage` | Non può essere prima dell'annata | It cannot be before the vintage | Não pode ser anterior à safra |
| `windowNoEnd` | Pronto, nessuna fine stimata | Ready, no end estimated | Pronto, sem fim estimado |
| `windowNoEndShort` | nessuna fine stimata | no end estimated | sem fim estimado |
| `windowDrinkWithin` | entro {date} | by {date} | até {date} |
| `levelNoEffect` | Il livello non cambia questa stima | The level does not change this estimate | O nível não altera esta estimativa |
| `dashboardToConfirmTitle` | Da confermare | To confirm | A confirmar |
| `dashboardToConfirmCount` | {count, plural, =1{1 vino} other{{count} vini}} | {count, plural, =1{1 wine} other{{count} wines}} | {count, plural, =1{1 vinho} other{{count} vinhos}} |

Le chiavi `profileName_*` usano il trattino basso per seguire gli ID dello studio; se il generatore di `flutter gen-l10n` del progetto lo rifiuta, si usano `profileNameRFresh` ecc. senza cambiare i testi.

Le chiavi esistenti del Livello (`levelNone` compresa) restano invariate.
