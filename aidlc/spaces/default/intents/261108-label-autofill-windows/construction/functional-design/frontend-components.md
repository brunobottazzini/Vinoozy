# Componenti dell'interfaccia

## Fonti

- `inception/refined-mockups/` (`design-system-mapping.md`, `interaction-spec.md`, `accessibility-checklist.md`, `autofill-mockups.html`).
- `rules.md` e `functional-spec.md` di questa fase.

| Componente | Proprietà | Stato | Regole |
|---|---|---|---|
| `AutofillToolbar` | `onClear`, `onSearchOnline`, `onLens` (nullable) | nessuno | BR2.7, F1 |
| `FilledFromTextBadge` | `visible` | nessuno | FR1.3, A1, A13 |
| `PasteFromLensCard` | `onPaste`, `onOpenLens` | nessuno | F2, F3 |
| `ClearFormDialog` | `onConfirm` | nessuno | BR2.7, A8, A11 |
| `WineLevelSelector` | `value` (nullable), `suggested`, `suggestedReason`, `onChanged` | nessuno | FR4.1–FR4.3, A3, A10 |
| `LevelPreview` | finestra prima e dopo | nessuno | FR4.2 |
| `CorrectedBadge` | — | nessuno | FR5.2 |
| `CorrectEndYearSheet` | `startYear`, `peakYear`, `currentEnd`, `onSave` | anno scelto | BR4.6, FR5.1 |
| `RestoreEstimateDialog` | `estimatedEnd`, `onConfirm` | nessuno | FR5.4 |
| `EstimateSourceLine` | `basis`, `denominationKey`, `qualifier` | nessuno | interaction-spec "Origine della stima" |
| `LensInstructionsSheet` | — | nessuno | BR2.5, A14 |
| `AddChoiceScreen` (cambiato) | quattro scelte, compreso "Da Google Lens" | nessuno | FR2.6 |
| `AddWineScreen` (cambiato) | `initialFields`, `filledKeys`, `suggestedLevel`, `lensSession` | campi compilati, livello toccato, sporco | F1–F4 |
| `IdealMomentCard` (cambiato) | finestra effettiva, `override`, `baseWindow` | nessuno | FR5, BR4.7 |

## Validazione

- **Anno di "Correggi":** da `startYear` a `startYear + 60` (BR4.6).
- **Livello:** uno dei tre valori, oppure nessuno.
- **Campi compilati dal testo:** la validazione di oggi (BR1.9).

## Integrazione

- **Canale `vinoozy/lens`:** `openLensCamera()` e `clipTimestamp()`, più `open(path)` di oggi.
- **Ricevitore di condivisione:** gestisce anche `kind: 'text'`.
- **Pacchetto `estimation`:** `extractLabelFields` (lettore di BR1, invariato), `analyzeLabelText` (vista compilata e candidati, D7, D9) ed `effectiveWindow`.
- **Testi:** tutti nei 3 file ARB, con il prefisso `autofill*`, `level*`, `override*` o `guide*`.

## Conferma guidata e attesa (FR2.8, FR7)

Aggiunti con la riapertura da Build and Test. Fonti:
- schermate G0–G5 di `inception/refined-mockups/` (`mockups.md`, `interaction-spec.md`, A15–A22 di `accessibility-checklist.md`);
- BR7 di `rules.md`, D9–D12 di `functional-spec.md`, ENT-007…ENT-014 di `entities.md`.

| Componente | Proprietà | Stati | Regole |
|---|---|---|---|
| `PasteFromLensCard` (cambiato) | `onPaste`, `onOpenLens`, `busy` | normale; `busy`: "Leggo il testo…" con indicatore, pulsante non attivo | BR7.24, A15, G0 |
| `AutofillToolbar` (cambiato) | in più `onGuide` (nullable) | "🧭 Conferma guidata" visibile solo con `onGuide` non null | BR7.17, G4 |
| `GuidedConfirmController` | `memory` (`GuidedMemory`), `onApply` (scrive un campo nel modulo), `onFinished` | nessuna guida, guida aperta | D11, BR7.10–BR7.21 |
| `GuidedConfirmSheet` | `controller`, `fieldLabel` per campo, `returnFocus` (`FocusNode`) | `question`, `compose`, `edit`, `yearWheel`; con o senza `notice` | FR7.4, FR7.6, D10 |
| `GuidedQuestionView` | `field`, `proposal` (nullable), `otherYears`, `onYes`, `onNo`, `onEdit`, `onSkip` | con proposta; senza proposta (Sì e No non attivi) | BR7.12 |
| `GuidedEditField` | `field`, `initial`, `error`, `onConfirm`, `onCancel` | valido, errore | BR7.12, FR1.5 |
| `WordPicker` | `words` (`List<LabelWord>`), `selected`, `usedBy` (`Map<int, KeyField>`: id usati da un altro campo, solo per il segno), `onToggle` | parola libera, scelta (con numero d'ordine), usata da un altro campo (segno, ma selezionabile), disattivata (solo oltre i limiti) | BR7.15, BR7.14, A17, A21 |
| `ComposePreview` | `value`, `tableMatch` (nome e sigla, nullable), `error`, `onConfirm`, `onCancel` | vuota (Conferma non attivo), con valore, con "✓ DOCG", con errore | BR7.15, BR7.16 |
| `VintageWheel` | `initialYear`, `minYear` = 1900, `maxYear` = anno corrente + 1, `markedYears`, `onConfirm(int)`, `onNoVintage`, `onSkip` | scorrimento; tastiera numerica aperta; errore dell'anno scritto | BR7.13, A22 |

### Dettagli di comportamento

**`PasteFromLensCard.busy`**
- Il pulsante mostra `CircularProgressIndicator` (18 dp) e `autofillReading`.
- `onPressed` è null mentre è occupato, quindi un secondo tocco non fa niente.
- `Semantics(liveRegion: true)` sull'etichetta annuncia "Leggo il testo". L'esito lo annuncia il modulo con lo SnackBar di oggi oppure con il fuoco sulla domanda.

**`GuidedConfirmSheet`**
- **Disposizione.** Livello in fondo allo `Stack` del modulo (D10). Il contenuto scorre con testo 2,0: testata in alto, risposte subito sotto la domanda, parole o ruota dopo.
- **Testata.** `guideProgress(n, total)`, poi una barra a segmenti (T segmenti, i primi N pieni), poi il pulsante "Chiudi ✕" di almeno 48×48 dp.
- **Domanda.** Il valore in `headlineSmall` con il colore primario del tema (bordeaux), poi la frase del campo (`guideIsDenomination`…).
  - Per l'annata, se ci sono altri candidati: una riga piccola `guideOtherYears`.
  - `Semantics(focused: true)` all'apertura e a ogni nuova domanda, con la frase intera `guideAsk*`.
- **Risposte.** Griglia 2×2 alta almeno 48 dp per riga: "Sì" pieno, "No, un'altra", "Modifica", "Salta" testo. Con testo 2,0 la griglia diventa una colonna.
- **Avviso** (`notice`). SnackBar dentro la scheda, oppure una riga sopra la domanda, per 2 secondi: `guideRejected(value)` o `guideNoMore`. Il lettore di schermo annuncia `guideProposalAnnounce(value)` (A20).
- **Indietro** con `PopScope`. In `compose` ed `edit` torna alla domanda; altrimenti chiude la scheda. La scheda si chiude prima del modulo (A19).
- **Barriera.** Il tocco fuori chiude solo in `question` e `yearWheel`. La barriera dice `guideClose` al lettore di schermo.
- **Fuoco alla chiusura.** Va a `returnFocus`: il pulsante "Conferma guidata", "Incolla da Lens" o il primo campo compilato (A16).
- **Movimento ridotto.** Il passaggio orizzontale tra domande (200 ms) diventa immediato con `MediaQuery.disableAnimations`.

**`WordPicker`**
- **Gruppi per riga.** Un gruppo per riga del testo, in un `Wrap`. Ogni gruppo ha `Semantics(label: guideLine(n, total))`, così il lettore di schermo non legge 120 pulsanti di fila (A21).
- **Ogni parola** è un `FilterChip` o un pulsante con il bordo, alto almeno 48 dp.
  - **Scelta:** è piena e porta un badge con il numero d'ordine nel testo (1, 2, 3…), non nell'ordine dei tocchi.
  - **Usata da un altro campo:** resta attiva, con un segno (sottolineatura tratteggiata e una piccola etichetta del campo) e la semantica `guideWordUsedFor(word, field)` (BR7.15). Si può scegliere per il nome anche se è già nella denominazione o nel produttore.
  - **Oltre i limiti:** non è attiva, con la semantica `guideWordUnavailable(word)`.
- **Semantica di una parola scelta:** `guideWordSelected(word, order)`, con `selected: true`.
- **Primo tocco.** Il primo tocco su una parola fa passare la scheda in `compose`.

**`ComposePreview`**
- L'anteprima è una regione live (`Semantics(liveRegion: true)`) e si legge a ogni cambio (A17).
- **Con una riga di tabella:** mostra il nome della tabella e un segno "✓ <sigla>" (DOCG, AOC, DO…), con la semantica `guideTableMatchSemantics(name)`.
- **Limiti superati:** mostra `guideComposeLimit`.
- **Valore non valido:** l'errore della validazione del campo compare sotto l'anteprima, con lo stesso testo del modulo.

**`VintageWheel`**
- **Ruota.** `ListWheelScrollView.useDelegate` con `itemExtent` di 48 dp, scalato con il testo. Anni in ordine decrescente.
- **Anni del testo.** Hanno il segno "•" oltre al colore.
- **Accessibilità.** `Semantics(slider: true, value: '<anno>', increasedValue, decreasedValue, onIncrease, onDecrease)`: scorrere su e giù cambia di un anno e annuncia il nuovo anno (A22).
- **Anno al centro.** Un tocco apre un `TextField` numerico di 4 cifre con la tastiera numerica.
  - **Conferma valida:** la ruota va a quell'anno e la tastiera si chiude.
  - **Errore:** il messaggio di validazione dell'annata di oggi; la tastiera resta aperta e la ruota non si muove.
  - **Indietro con la tastiera aperta:** chiude solo la tastiera e torna alla ruota (`keyboardOpen`, ENT-012).
- **Pulsanti sotto la ruota:**
  - `guideWheelConfirm(year)`, pieno;
  - `guideNoVintage`;
  - `guideSkip`, testo.

### Chiavi ARB nuove

I testi tra parentesi graffe sono segnaposto. Le chiavi esistenti si riusano dove già dicono la cosa giusta:
- `autofillFromText` per il segno "✦ dal testo";
- le etichette dei campi del modulo per `GuidedEditField`;
- i messaggi di validazione di oggi per gli errori.

| Chiave | it | en | pt-BR |
|---|---|---|---|
| `autofillReading` | Leggo il testo… | Reading the text… | Lendo o texto… |
| `guideChip` | Conferma guidata | Guided check | Confirmação guiada |
| `guideProgress(n, total)` | Domanda {n} di {total} | Question {n} of {total} | Pergunta {n} de {total} |
| `guideClose` | Chiudi | Close | Fechar |
| `guideIsDenomination` | è la denominazione? | is it the appellation? | é a denominação? |
| `guideIsProducer` | è il produttore? | is it the producer? | é o produtor? |
| `guideIsName` | è il nome del vino? | is it the wine name? | é o nome do vinho? |
| `guideIsVintage` | Annata | Vintage | Safra |
| `guideAskDenomination(value)` | {value} è la denominazione? | Is {value} the appellation? | {value} é a denominação? |
| `guideAskProducer(value)` | {value} è il produttore? | Is {value} the producer? | {value} é o produtor? |
| `guideAskName(value)` | {value} è il nome del vino? | Is {value} the wine name? | {value} é o nome do vinho? |
| `guideAskVintage` | Qual è l'annata? | What is the vintage? | Qual é a safra? |
| `guideQuestionSemantics(n, total, question)` | Domanda {n} di {total}: {question} | Question {n} of {total}: {question} | Pergunta {n} de {total}: {question} |
| `guideNoProposal` | Non l'ho trovato nel testo | I couldn't find it in the text | Não encontrei no texto |
| `guideYes` | Sì | Yes | Sim |
| `guideNo` | No, un'altra | No, another | Não, outra |
| `guideEdit` | Modifica | Edit | Editar |
| `guideSkip` | Salta | Skip | Pular |
| `guideConfirm` | Conferma | Confirm | Confirmar |
| `guideCancel` | Annulla | Cancel | Cancelar |
| `guideRejected(value)` | "{value}" no: ti propongo il prossimo | Not "{value}": here's the next one | "{value}" não: aqui está o próximo |
| `guideNoMore` | Nessun'altra proposta: puoi comporla o saltare | No other suggestion: compose it or skip | Nenhuma outra sugestão: componha ou pule |
| `guideProposalAnnounce(value)` | Proposta: {value} | Suggestion: {value} | Sugestão: {value} |
| `guideComposeLabel` | Oppure componila toccando le parole del testo | Or build it by tapping words of the text | Ou monte tocando as palavras do texto |
| `guideComposePreview` | Anteprima | Preview | Prévia |
| `guideComposeEmpty` | Tocca una o più parole | Tap one or more words | Toque em uma ou mais palavras |
| `guideComposeLimit` | Massimo 8 parole e 80 caratteri | Up to 8 words and 80 characters | No máximo 8 palavras e 80 caracteres |
| `guideTableMatchSemantics(name)` | corrisponde a {name} | matches {name} | corresponde a {name} |
| `guideLine(n, total)` | Riga {n} di {total} | Line {n} of {total} | Linha {n} de {total} |
| `guideWordSelected(word, order)` | {word}, selezionata, {order} | {word}, selected, {order} | {word}, selecionada, {order} |
| `guideWordUnavailable(word)` | {word}, non disponibile | {word}, unavailable | {word}, indisponível |
| `guideWordUsedFor(word, field)` | ICU `select` sul campo: {word}, usata per la denominazione / il produttore / il nome | {word}, used for the appellation / producer / name | {word}, usada na denominação / no produtor / no nome |
| `guideOtherYears(years)` | Nel testo anche: {years} | Also in the text: {years} | Também no texto: {years} |
| `guideWheelFromText` | anno trovato nel testo | year found in the text | ano encontrado no texto |
| `guideWheelTypeYear` | Scrivi l'anno | Type the year | Digite o ano |
| `guideWheelConfirm(year)` | Conferma {year} | Confirm {year} | Confirmar {year} |
| `guideNoVintage` | Senza annata | No vintage | Sem safra |
| `guideSkippedNotice(field)` | ICU `select`: Denominazione saltata / Produttore saltato / Nome saltato / Annata saltata, poi ": puoi scriverlo o riprendere la guida" | Appellation / Producer / Name / Vintage skipped: type it or resume the guide | Denominação pulada / Produtor pulado / Nome pulado / Safra pulada: digite ou retome o guia |
| `guideSkippedMany(count)` | {count} campi saltati: puoi scriverli o riprendere la guida | {count} fields skipped: type them or resume the guide | {count} campos pulados: digite-os ou retome o guia |

**Note sulle chiavi:**
- `guideSkippedNotice` usa un `select` ICU sul campo (`denomination`, `producer`, `name`, `vintage`), così l'accordo di genere è giusto in italiano e in portoghese.
- In inglese le frasi `guideAsk*` mettono il valore in mezzo, per questo la semantica usa la frase intera e non "valore + frase del campo".
- Gli anni in `guideOtherYears` e `guideWheelConfirm` sono scritti senza separatore delle migliaia (A9).

### Validazione nella guida

- **"Modifica" e "Componi":** la validazione di oggi del campo (FR1.5, BR1.9). Il nome e il produttore hanno le loro lunghezze; la denominazione ha la validazione del campo denominazione.
- **Ruota e anno scritto:** da 1900 all'anno corrente + 1, con `WineRules.validateVintage`.
- **Composizione:** al massimo 8 parole e 80 caratteri (BR7.15).

### Integrazione

- **`TextAutofillFlow.run`** restituisce `TextFields(fields, analysis: …)` (D9). `AddWineInitialValues` riceve `analysis` dalla foto.
- **`AddWineScreen`.** Tiene `GuidedConfirmController`, apre la guida dopo `_applyText` o dopo il primo fotogramma quando arriva `initialValues.analysis`. Chiude la guida in `_applyText` (nuovo testo) e in `_clear`.
- **Campi scritti a mano a guida chiusa.** Passano a `GuidedMemory.manual` tramite `_edited`.
- **Qualifica e Livello.** `_level.textQualifier` si imposta da `analysis.qualifier` a ogni testo, non solo quando si riempie il nome (BR7.8 c).
- **Campi con risposta.** `_fillEmpty` salta i campi in `GuidedMemory.answers`, anche se vuoti (BR7.18).
- **Tipo, paese e regione dopo la denominazione.** Il controller li ricalcola alla conferma e sostituisce solo i valori con il segno "✦ dal testo" mai toccati (BR7.20).
