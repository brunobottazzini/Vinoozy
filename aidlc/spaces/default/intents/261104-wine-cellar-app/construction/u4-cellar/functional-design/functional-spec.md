# Functional Specification — u4-cellar

Fonti:
- `unit-of-work.md` (U4, con la decisione del 2026-11-06 sull'archivio dei vini finiti);
- `requirements.md` (FR2.1, FR2.3–FR2.7, FR3.1–FR3.4, FR4.1–FR4.7, FR6.1–FR6.4, FR7.1–FR7.2, FR9.1–FR9.4, NFR1);
- `stories.md` (US2.1, US2.3, US3.1–US3.4, US4.1, US4.2, US6.1, US6.2, US7.1, US9.2);
- `components.md` (Cellar);
- `contract-summary.md` (C1 catalogo di U3, C2 stima di U2, C3 dati, C4 condivisione di U7);
- risposte in `functional-design-questions.md`: Q1 riscontro sulla bevuta invece della modifica a mano, Q2 = A, Q3 = A, produttore nuovo, riepilogo confermato.

U4 completa la gestione della cantina:
- inserimento con suggerimenti;
- doppioni;
- elenco con ricerca e filtri;
- dettaglio con stima, fiducia, fonte e abbinamenti;
- modifica ed eliminazione;
- bevuta con annulla, voto, note e riscontro;
- Storico.

Lavora sulla **cantina attiva** di U7 e rispetta i permessi (`canEdit`, eliminazione solo del proprietario).

## Interfacce usate

- **U1 (C3):** `WineRepository`, `cellarStreamProvider(cellarId)`, `winesStreamProvider(cellarId)`, `SyncErrorBus` e `reportWriteRejected` (u7), `AddWineScreen` di U1, che U4 sostituisce con la versione completa.
- **U2 (C2):** `estimateWindow`, `statusOf`, `pairingsFor`, `needsRefinement`, `WineType.tryParse`, `recognizeDenomination`.
- **U3 (C1):** `catalogProvider` con `suggestWines` (con `cellarWines`), `suggestExternal`, `getWineProfile`. Lo si usa con `ref.watch`, come stabilito in u3.
- **U5:** le tre azioni iniettate `onOpenWine`, `onOpenStatus` e `onAddFirstWine` vengono ricollegate al dettaglio, all'elenco filtrato e all'inserimento completo.
- **U7 (C4):** `activeCellarProvider` (cantina attiva, `canEdit`, proprietario), con le funzioni delle regole `canReadCellar` e `canEditCellar`.

## Aggiunte compatibili al modello dati (C3 v1)

Sono tutti campi facoltativi, che i consumatori ignorano se non li conoscono.

| Documento | Campo | Significato |
|---|---|---|
| `wines` | `matchKey` | Chiave per i doppioni: nome normalizzato, produttore normalizzato e annata (`normalizeWineText` di C2), separati da `|`. Si calcola a ogni scrittura. |
| `wines` | `baseWindow` | La stima di base (`DrinkingWindow` di C2, da catalogo o regole interne), senza riscontri. `window` resta la finestra **effettiva**, quella che leggono Cantina e Cruscotto. Con `baseWindow` il riscontro si riapplica anche offline. |
| `wines` | `windowAdjustment` | Riscontro applicato: `{ kind: tooYoung | justRight | pastPeak, year: int, recordId: string }`, dove `recordId` è la bevuta da cui viene. |
| `drinkingRecords` | `condition` | Risposta a "Com'era?": `tooYoung` | `justRight` | `pastPeak`. |
| `drinkingRecords` | `updatedAt` | Data dell'ultima modifica di voto, note, data o riscontro. |

**Regole cloud:** U4 estende il blocco `drinkingRecords` scritto da U7 (BR1.10, BR1.11) e la validazione dei vini di U1 con i campi nuovi. È un'estensione dichiarata, perché U7 prevedeva che U4 potesse solo restringere:
- **`drinkingRecords`, update:** consentito con `canEditCellar` se `recordedBy == uid` o se è il proprietario. Possono cambiare solo `rating` (intero 1–5 o assente), `notes` (≤ 1.000 caratteri o assente), `drankOn` (data `YYYY-MM-DD`), `condition` (`tooYoung`, `justRight`, `pastPeak` o assente) e `updatedAt` (`== request.time`). Non cambiano mai `wineId`, `wineName`, `vintage`, `recordedBy` e `createdAt`.
- **`drinkingRecords`, delete:** il proprietario sempre, come in U7. Chi l'ha registrata solo entro 10 minuti da `createdAt`, per "Annulla".
- **`drinkingRecords`, create:** `condition` e `updatedAt` facoltativi si aggiungono ai campi ammessi.
- **`wines`:** `matchKey` (stringa ≤ 400), `baseWindow` (stessa forma di `window`) e `windowAdjustment` (mappa con `kind` tra i valori ammessi, `year` intero 1900–2200, `recordId` stringa) si aggiungono ai campi ammessi in creazione e aggiornamento.
- **`cellars`:** `matchKeyBackfill` (booleano) diventa modificabile dal proprietario o da chi ha `edit`, insieme alle regole di U1 e U7.

Le aggiunte vanno riportate nel contratto C3 durante la generazione del codice.

## Regole della cantina

L'elenco completo con trigger e violazioni è in `rules.md`.

| ID | Regola |
|---|---|
| BR1.1 | **Suggerimenti mentre scrivi (FR2.1).** Dal terzo carattere del nome, `suggestWines` di U3 propone i vini del catalogo interno, quelli già presenti nella cantina attiva e, con la rete, quelli di Open Food Facts. Scegliendo una proposta si compilano nome, produttore, annata (se nota), tipologia, denominazione e regione. |
| BR1.2 | **Produttore nuovo (richiesta del proprietario).** Il campo produttore propone i produttori del catalogo e quelli dei vini caricati nelle cantine accessibili. L'ultima voce è sempre "Aggiungi «testo» come nuovo produttore", con il testo così come è scritto. Un vino non trovato si salva con i dati scritti a mano. |
| BR1.3 | **Validazione (FR2.4, FR2.6, FR2.7).** Nome obbligatorio, da 1 a 120 caratteri dopo gli spazi tolti ai lati. Produttore facoltativo, al più 120 caratteri. Annata tra 1900 e l'anno corrente, oppure "senza annata". Quantità intera da 1 a 99, già impostata a 1. Solo bottiglie da 0,75 L. Un errore compare sotto il campo e quanto scritto resta. |
| BR1.4 | **Doppioni (FR2.5).** Prima di salvare, l'app cerca nella cantina attiva un vino con lo stesso `matchKey`, **compresi i vini finiti**, con una query `where matchKey == …` (dal server con la rete, dalla cache senza). La cache di Firestore è illimitata (NFR6.1 di U1), quindi contiene ogni vino che il telefono ha già visto, anche quelli finiti in seguito. Se il vino esiste, l'app mostra la voce esistente con la quantità attuale. Confermando, aggiunge le bottiglie (BR1.15) e il vino finito torna nella Cantina; annullando, torna al modulo. **Vini senza `matchKey`** (creati da U1): alla prima apertura della cantina dopo l'aggiornamento, il proprietario o chi ha `edit` legge una sola volta tutta la raccolta e scrive `matchKey` sui vini che non ce l'hanno; poi segna `matchKeyBackfill: true` sul documento della cantina, campo compatibile. **Limite accettato:** un vino finito che questo telefono non ha mai visto, aggiunto di nuovo senza rete, crea una seconda voce. È un caso raro, e quando il telefono vede entrambe le voci il dettaglio mostra "Possibile doppione" con "Unisci", che sposta le bottiglie nella voce più vecchia. |
| BR1.5 | **Stima al salvataggio (FR4.1–FR4.4, FR4.7).** Al salvataggio l'app calcola sul telefono `estimateWindow` e `pairingsFor` con le regole interne, senza rete. Il risultato va in `baseWindow`, e in `window` dopo aver applicato il riscontro (BR1.12). Se `needsRefinement` è vero e c'è rete, l'app chiede `getWineProfile` a U3; se il profilo migliora la stima, aggiorna `baseWindow`, `window` e `pairings`. La fonte è quella di C2 (`window.source` = `catalog` o `internalRules`, più `basis`), senza un campo in più. Il vino è subito visibile con la stima interna. |
| BR1.6 | **Ricalcolo al ritorno della rete (FR4.7).** I vini con `baseWindow.source == internalRules` e `needsRefinement` vero vengono riprovati al ritorno della rete, uno per volta, nel rispetto dei limiti di U3. Il ricalcolo riapplica il riscontro (BR1.12). |
| BR1.7 | **Elenco della Cantina (FR3.1, archivio).** `WineRepository.watchWines(cellarId)` di U1 cambia in `watchCellarWines(cellarId)` con `where quantity > 0`, e `winesStreamProvider` lo usa. È quindi un cambio per **tutti** i suoi utenti: Cantina, Cruscotto (U5) e accesso perso (U7), che contano comunque solo le bottiglie presenti. I loro test con flussi finti non cambiano; cambiano i test del repository di U1. Un valore salvato negativo, mostrato come 0, è escluso: per l'app quel vino è finito. Ogni riga mostra nome, annata o "senza annata", quantità, stato con icona e testo (FR4.5) e fiducia. Ordine per nome, poi annata. Con 0 vini e dati non solo dalla cache compare l'invito ad aggiungere il primo vino. **Archivio:** un vino finito si legge solo con `wineProvider(cellarId, wineId)`, un documento, dallo Storico o da un doppione. |
| BR1.8 | **Ricerca e filtri (FR3.2).** La ricerca cerca nel nome e nel produttore, senza distinguere maiuscole e accenti. I filtri sono per stato (i quattro stati più "da stimare") e per tipologia (le cinque famiglie più "non indicata"), combinabili. Senza risultati compare "Nessun vino con questi filtri" con "Azzera filtri". Dal Cruscotto si arriva con il filtro di stato già impostato. |
| BR1.9 | **Dettaglio (FR4.1–FR4.5, FR7.1, FR7.2).** Il dettaglio mostra la finestra (inizio, picco, fine), lo stato, la fiducia e la fonte: "base dati vini", "stima per tipologia" o "stima corretta dalle tue bevute". C'è sempre l'avviso **"Stima indicativa: dipende anche da come è stata conservata la bottiglia"**. Mostra anche gli abbinamenti, con "abbinamenti generici per la tipologia" quando vengono dalla tipologia, la quantità con + e −, "Bevuta", "Modifica", "Elimina" (solo il proprietario) e le ultime bevute. |
| BR1.10 | **Bevuta (FR6.1, FR6.2, FR6.4, Q2 = A).** Un tocco su "Bevuta" fa, in un solo batch, quantità −1 (BR1.15) e la creazione di un `drinkingRecord` con la data di oggi. Per 6 secondi compare un messaggio con "Annulla" e "Aggiungi voto e note". **Annulla:**<br>• legge la bevuta dalla cache;<br>• se esiste ancora, elimina la bevuta e aggiunge una bottiglia (BR1.15) in un batch;<br>• se è già stata cancellata, mostra "Non c'è più nulla da annullare";<br>• se la bevuta aveva dato il riscontro attivo, ricalcola la finestra (BR1.12).<br>"Bevuta" e "−" sono disattivati quando la quantità mostrata è 0. A quantità 0 il vino esce dalla Cantina e resta nello Storico. Con "solo lettura" il comando non c'è. |
| BR1.11 | **Voto, note, data e riscontro.** Si impostano dal messaggio o più tardi dallo Storico: voto da 1 a 5, note fino a 1.000 caratteri, data non futura e non prima dell'annata, riscontro "Com'era?" facoltativo. Li cambia chi ha registrato la bevuta o il proprietario. |
| BR1.12 | **Riscontro e finestra (Q1, regola di enologia decisa da U4).** La finestra non si modifica a mano.<br>**Quale riscontro vale:** quello della bevuta con `condition` più recente del vino, ordinando per `drankOn` e poi `createdAt`, entrambi decrescenti. L'app lo salva come `windowAdjustment` con `recordId`.<br>**Come si applica:** con *Y* l'anno della bevuta, il riscontro modifica `baseWindow` e il risultato va in `window`:<br>• **`justRight` con *Y* > fine:** la fine diventa *Y* + 1; il picco resta;<br>• **`pastPeak` con *Y* < fine:** se *Y* ≥ inizio, la fine diventa *Y* e il picco non supera la fine; se *Y* < inizio, l'intera finestra slitta indietro di (fine − *Y*) anni, così la fine cade in *Y* e la durata resta uguale;<br>• **`tooYoung` con *Y* ≥ inizio** (bevuto nell'anno di inizio o dopo): inizio, picco e fine slittano in avanti di (*Y* + 1 − inizio) anni;<br>• **negli altri casi** la finestra resta quella di base.<br>Con un riscontro applicato la fonte è "stima corretta dalle tue bevute" e la fiducia scende di un livello, al minimo "bassa", perché un solo assaggio è un dato debole. Questo dettaglio va confermato con il proprietario all'approvazione.<br>**Quando cambia:** se un riscontro viene tolto o cambiato, o la sua bevuta annullata o cancellata, l'app rilegge le bevute del vino con `condition` (query `where wineId == … `, dal server o dalla cache) e applica la più recente. Se non ce ne sono, `window = baseWindow` e `windowAdjustment` viene tolto. |
| BR1.13 | **Modifica (FR3.3).** Si modificano nome, produttore, annata, tipologia e quantità. Il cambio di quantità è una variazione, con il risultato mai sotto 0. Si ricalcolano `matchKey`, stima e abbinamenti. Se il nuovo `matchKey` coincide con quello di un altro vino, l'app lo segnala e non salva. |
| BR1.14 | **Eliminazione (FR3.4, AC3.4.2, riepilogo confermato).** "Elimina" chiede conferma con il nome del vino. In un solo batch cancella il vino **e tutte le sue bevute** (query `where wineId == …`, dal server o dalla cache), così il vino non compare più nello Storico. L'eliminazione non crea voci nello Storico. Il comando c'è solo per il proprietario (u7), che può eliminare tutte le bevute della cantina. Se le bevute sono più di 400, il batch si divide in più parti e il vino si cancella per ultimo. |
| BR1.15 | **Quantità come variazioni (FR9.4, US9.2, ADR-004).** Ogni cambio di quantità è `FieldValue.increment(δ)`. **Correzione dei valori negativi:** se il valore salvato letto *s* è negativo e la variazione voluta è +*n*, l'app scrive `increment(n − s)`, così il risultato è *n* e non *n* − \|*s*\|. La stessa correzione vale per "Aggiungi N" dei doppioni, per "Annulla" della bevuta e per "+". Le diminuzioni ("Bevuta", "−") non si fanno quando il valore mostrato è 0. Due correzioni contemporanee possono lasciare un valore più alto del dovuto; è un caso raro, e la quantità resta visibile e correggibile con "−". Gli altri campi seguono "l'ultima modifica vince". |
| BR1.16 | **Storico (FR6.3, Q3 = A).** Terza scheda in basso. Mostra le bevute della cantina attiva ordinate per `drankOn` e poi `createdAt`, entrambi decrescenti, a pagine di 30 con un cursore su quei due campi. Serve un indice composto in `firestore.indexes.json`. Ogni riga ha nome, annata, data, voto, note e riscontro. Toccando una bevuta si apre il vino, anche se finito (una sola lettura del documento), con "Aggiungi di nuovo", che riapre l'inserimento già compilato. Senza bevute compare "Qui troverai le bottiglie che hai bevuto". |
| BR1.17 | **Collegamenti con il Cruscotto (u5).** `onOpenWine` apre il dettaglio, `onOpenStatus` apre la Cantina filtrata per quello stato, `onAddFirstWine` apre l'inserimento completo. Gli avvisi di TalkBack del Cruscotto tornano "Apri l'elenco". |
| BR1.18 | **Velocità di inserimento (NFR1).** Il modulo apre il nome già attivo. Il salvataggio non aspetta la rete e torna subito alla Cantina con il vino visibile. La mediana di 10 prove resta sotto i 30 secondi. |

## Chiarimenti dopo la seconda revisione (2026-11-06)

| ID | Regola |
|---|---|
| BR1.19 | **Chi scrive le stime automatiche.** Le scritture automatiche, cioè stima al salvataggio, miglioramento dal catalogo (BR1.5, BR1.6), riapplicazione del riscontro (BR1.12) e backfill di `matchKey` (BR1.4), le fa **solo** chi ha `canEdit` sulla cantina attiva. Chi ha "solo lettura" vede la finestra salvata. Se una finestra manca, la calcola in memoria per mostrarla, senza scriverla. Così un lettore non provoca mai rifiuti, e quindi nessun falso "accesso perso" di U7. |
| BR1.20 | **Unisci un possibile doppione.** "Possibile doppione" compare nel dettaglio quando due vini della stessa cantina hanno lo stesso `matchKey`. "Unisci" c'è **solo per il proprietario** (l'unico che può eliminare vini) e solo se la voce più recente **non ha bevute**. In un batch aggiunge alla voce più vecchia le bottiglie della più recente (BR1.15) ed elimina la più recente. Se la voce più recente ha bevute, compare solo l'avviso con l'indicazione "Elimina questa voce se è un doppione": le bevute di un vino non si spostano, perché `wineId` è immutabile. Nuovo componente: `DuplicateBanner` nel dettaglio. |

**Altri chiarimenti:**
- **Vini senza stima** (creati da U1, senza `window` né `baseWindow`): BR1.6 li considera insieme ai vini con `baseWindow.source == internalRules`. Alla prima apertura chi ha `canEdit` calcola la stima interna e poi, con la rete, prova il catalogo.
- **Fonte mostrata:** "stima corretta dalle tue bevute" compare quando c'è `windowAdjustment` e `window` è diversa da `baseWindow`. Altrimenti la fonte è quella di `baseWindow.source`, cioè "base dati vini" o "stima per tipologia". Un riscontro che non cambia la finestra viene salvato ma non cambia l'etichetta.
- **Limite senza rete:** le query `where wineId` di BR1.12 e BR1.14 senza rete leggono solo la cache. Il riscontro scelto può quindi non essere il più recente, e l'eliminazione può lasciare bevute non ancora scaricate su quel telefono. Al ritorno della rete l'app ripete la query dal server: riapplica il riscontro e, per un vino eliminato, cancella le bevute rimaste che ha il permesso di cancellare.
- **Backfill di `matchKey`:** la scrittura cambia **solo** `matchKey`. Le regole permettono un update con `onlyChanged(['matchKey'])` a chi ha `canEdit`, senza toccare `updatedBy` e `updatedAt`. Dopo il backfill, ogni vino caricato nell'elenco a cui manca `matchKey`, per esempio creato da una versione vecchia dell'app ancora installata da qualcuno, riceve la chiave senza letture in più. Un vino finito creato da una versione vecchia senza chiave non viene trovato come doppione; è un limite accettato.
- **Nome nello Storico:** una bevuta mostra il nome e l'annata salvati al momento della bevuta (`wineName`, `vintage` immutabili). Dopo una rinomina, lo Storico mostra il nome di allora, come uno scontrino. Il dettaglio aperto dalla bevuta mostra il nome attuale.
- **Contratto C3:** le aggiunte di U4 sono riportate in `contract-summary.md` nella stessa data.

## Flussi

1. **Aggiungere:** "Aggiungi" → nome con suggerimenti → (proposta scelta oppure produttore e altri campi a mano) → quantità → "Salva" → controllo dei doppioni → salvataggio con la stima interna → (con rete) miglioramento dal catalogo.
2. **Bere:** riga o dettaglio → "Bevuta" → messaggio con "Annulla" e "Aggiungi voto e note" → (facoltativo) voto, note, data, "Com'era?" → eventuale nuova finestra.
3. **Consultare:** Cantina → ricerca e filtri → dettaglio. Oppure Cruscotto → stato → Cantina filtrata.
4. **Storico:** scheda Storico → bevuta → vino (anche finito) → "Aggiungi di nuovo" → inserimento compilato → doppione confermato → il vino torna nella Cantina.

## Errori e casi limite

| Caso | Comportamento |
|---|---|
| Nome vuoto o troppo lungo, annata fuori intervallo, quantità fuori da 1–99 | Errore sotto il campo; il resto resta (AC2.1.3). |
| Nessuna rete all'aggiunta | Salvataggio locale, stima interna, banner "Offline - sincronizzazione in attesa" di U1 (AC4.1.3). |
| Catalogo non disponibile o sospeso | Solo suggerimenti interni e della cantina; nessun errore mostrato. |
| Due persone segnano una bevuta offline | Le variazioni si sommano (AC9.2.1). |
| "Annulla" dopo la sincronizzazione | Funziona lo stesso: la bevuta si cancella e la quantità torna +1. |
| Riscontro su un vino senza finestra | Si salva sulla bevuta, ma non cambia nulla finché il vino non ha una stima. |
| Persona con "solo lettura" | Nessun comando di aggiunta, modifica, bevuta o eliminazione; Storico in sola lettura. |
| Scrittura rifiutata dalle regole | Percorso di U1 e U7 (`reportWriteRejected`). |

## Fuori ambito

- Aggiunta dalla foto dell'etichetta (u6).
- Modifica a mano della finestra (Q1).
- Bottiglie di formato diverso da 0,75 L (FR2.7).
- Cancellazione dell'account (u8).
