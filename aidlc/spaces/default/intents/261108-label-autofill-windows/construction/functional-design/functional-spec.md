# Specifica funzionale — compilazione dall'etichetta e finestre per tutto il mondo

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR6, NFR1–NFR6).
- `inception/refined-mockups/` (`autofill-mockups.html`, `interaction-spec.md`, revisioni 01–03).
- `codekb/Vinoozy/`.
- `entities.md`, `rules.md` e `world-tables.md` di questa fase.
- Riapertura da Build and Test: FR2.8, FR7.1–FR7.9, NFR5.8, NFR5.9 e le schermate G0–G5. Codice di oggi: `label_fields.dart`, `recognizer.dart`, `text_autofill.dart` (`lookupBudget`), `add_wine_screen.dart` (`didChangeAppLifecycleState`), `autofill_widgets.dart`, `AndroidManifest.xml` (`configChanges`).

## Decisioni di progettazione

### D1 — Estrattore dei campi puro, nel pacchetto `estimation`

**Decisione.** La funzione pura `extractLabelFields(String text, {required int currentYear})` restituisce `LabelFields` (BR1) e sta in `packages/estimation`.
- **Dipendenze dall'app.** Si spostano nel pacchetto `VintageParser` e `LabelLinePicker`, che sono codice Dart puro di `lib/label/core`: `lib/label` li importa dal pacchetto. Il riconoscimento della denominazione per paese e regione legge la tabella del pacchetto. `WineOrigins._denominations` diventa una vista su quella tabella, così la fonte è una sola (BR3.5). Per BR1.7 basta una mappa dei nomi dei paesi in più lingue, esportata dal pacchetto; `WineOrigins` la usa.
- **Perché nel pacchetto.** Così il pacchetto non dipende da Flutter né da `lib/`, e il controllo di purezza resta verde.

**Alternative scartate:**
- **Estrattore in `lib/label`:** duplicherebbe gli alias.
- **Modello di linguaggio sul telefono:** non è deterministico e non si può provare con soglie.
- **Servizio in cloud:** ha un costo e manda il testo fuori dal telefono.

### D2 — Tabella delle denominazioni generata dai registri ufficiali più valori dedicati

**Contesto.** Il proprietario vuole la copertura più completa possibile (messaggio 03977a27).

**Decisione.**
- **Righe generate.** `tool/build_appellations.dart` (BR3.6) genera le righe dai registri ufficiali: eAmbrosia per l'UE e i file CSV non UE in `tool/data/appellations/`. Le scrive in un file Dart generato, versionato nel repository.
- **Finestre delle righe generate.** Vengono dai modelli per paese e stile (BR3.7).
- **Righe con valori dedicati.** Le 47 italiane di oggi, le 79 estere di `world-tables.md` e quelle aggiunte in Code Generation fino ad almeno 200 hanno la precedenza sulle generate.
- **Vitigni.** Sono una tabella a parte, scritta a mano.

**Alternative scartate:**
- **Scrivere a mano 1500 righe:** troppo lento e soggetto a errori.
- **Scaricare il registro dal telefono:** richiede la rete e il registro può cambiare formato.

**Conseguenze.**
- Ogni modello e ogni riga dedicata ha il suo test.
- Le righe generate hanno test di struttura: numero, unicità, modello esistente, regione valida.
- Il file generato pesa qualche centinaio di KB.

### D3 — Livello dentro la stima, correzione dopo l'adeguamento

**Decisione.**
- **Livello.** `estimateWindow(wine, external, {WineLevel? level})` applica il livello sugli scarti, prima di sommarli all'anno base (BR4.1). `baseWindow` quindi contiene già il livello, e un cambio di livello ricalcola la stima in locale.
- **Finestra effettiva.** `effectiveWindow(baseWindow, adjustment, override)` applica `windowAdjustment` come oggi e poi la correzione (BR4.4).
- **Chi le usa.** Tutte e due si usano in tutti i punti di BR4.5.

**Alternativa scartata.** Applicare il livello dopo, sulla finestra assoluta. Si dovrebbe conoscere di nuovo l'anno base, che senza annata dipende da `referenceYear` e dal tipo (revisione R-02).

### D4 — Incolla e condivisione

**Decisione.**
- **Condivisione.** Il ricevitore nativo delle immagini condivise si estende a `text/plain`: c'è un nuovo filtro nel manifest, e il canale di oggi passa `{kind: 'text', text}` alla `HomeShell`.
- **Appunti.** Si usa `Clipboard.getData` di Flutter. Per leggere l'ora di copia (BR2.6) serve un piccolo metodo nativo `clipTimestamp()` sul canale di Lens, che legge `ClipDescription.getTimestamp()` senza toccare il contenuto (solo da Android 8.0, API 26: il minimo dell'app è 24, quindi sotto l'API 26 l'incolla automatico non c'è. Il controllo si ripete al primo `onWindowFocusChanged(true)`, perché da Android 10 gli appunti si leggono solo con il focus).

**Alternativa scartata.** Leggere gli appunti a ogni ritorno in primo piano: viola NFR3.1.

### D5 — "Da Google Lens"

**Decisione.** Il canale nativo `vinoozy/lens` di oggi aggiunge `openLensCamera()` (BR2.5):
- prima un `Intent` di avvio del pacchetto `com.google.ar.lens`;
- poi l'azione Lens dell'app Google;
- il risultato è `lensApp`, `googleApp` oppure `unavailable`.

Il manifest aggiunge `com.google.ar.lens` a `<queries>`.

**Conseguenze.** Che il telefono del proprietario apra Lens va verificato a mano in Build and Test (FR2.6).

### D6 — Regole Firestore

Vedi BR5.1. Le regole nuove si pubblicano prima della build, con l'OK del proprietario, e `RULES_FEATURES` aggiunge `level-override` (BR5.3).

## Decisioni della riapertura (FR2.8, FR7)

Il proprietario ha riaperto il lavoro da Build and Test (messaggi 4e9809bc, c19931c2, 595f45dc, c40106d0). D1–D6 restano come sono; le decisioni nuove partono da D7.

### D7 — L'analisi sta nel pacchetto `estimation`, accanto a `label_fields.dart`

**Contesto.** I candidati usano le stesse righe, parole, alias e regole di `extractLabelFields` (BR1). Oggi quelle strutture (`_Line`, `_Reader`) sono private in `label_fields.dart`.

**Decisione.**
- **Funzione.** Nuova funzione pura `analyzeLabelText(String text, {required int currentYear}) → LabelAnalysis` (ENT-010), esportata dal pacchetto.
- **`extractLabelFields` non cambia** (correzione dopo la revisione, R-12). Resta il lettore di BR1, con la sua API e i suoi test (`label_fields_test.dart`, `label_texts.json`, BR1.10). Il modulo invece non lo usa più: compila `analyzeLabelText(...).certainFields` (BR7.8). Le due funzioni condividono righe, parole, rumore e alias (`label_lines.dart`), quindi non sono due lettori indipendenti; differiscono solo nella scelta finale del valore (BR1 sceglie sempre, l'analisi compila solo i campi certi).
- **File.** `label_fields.dart` si divide in file di `lib/src/` non esportati:
  - `label_lines.dart`: righe, parole, rumore (BR1.1, BR7.2);
  - `label_candidates.dart`: fonti e punteggi (BR7.3–BR7.6);
  - `label_scoring.dart`: pesi, soglia T e distacco M, tutti insieme (BR7.7);
  - `label_words.dart`: parole di FR7.5, composizione e confronto con le tabelle (BR7.14–BR7.16).

  `label_fields.dart` tiene `LabelFields`, `sanitizeLabelText` e l'API di oggi.
- **Perché nel pacchetto.**
  - È Dart puro: il controllo di purezza resta verde.
  - Vale la soglia di copertura del 90% del pacchetto (NFR5.1).
  - L'insieme di riferimento si prova con `dart test`, senza Flutter.

**Alternative considerate:**
- **Analisi nell'app (`lib/label/core`)** sopra `LabelFields`. Scartata: dovrebbe rileggere il testo e rifare righe e alias, con due letture che possono divergere. In più la copertura del pacchetto non coprirebbe le regole più delicate.
- **`extractLabelFields` = vista dei soli campi certi** (la prima versione di questa decisione). Scartata dopo la revisione: rompe in silenzio i test di oggi che leggono `extractLabelFields` e cambia il significato di BR1.10, che misurava i valori compilati da BR1.
- **Seconda funzione con righe e alias propri.** Scartata: due lettori con righe diverse darebbero valori diversi per lo stesso campo. Con `label_lines.dart` in comune la differenza resta solo nella scelta finale, che è voluta.
- **Modello statistico addestrato** (regressione o rete piccola). Scartato per ora: con 60–100 testi non c'è abbastanza materiale, il risultato non si spiega al proprietario e non si corregge una riga alla volta.

**Conseguenze.**
- **Precisione di BR1.10.** Il test di oggi su `label_texts.json` resta com'è e resta verde su `extractLabelFields`. Un test nuovo legge gli stessi 39 testi con `analyzeLabelText` e controlla che nessun campo della vista compilata (`certainFields`) sia diverso dal valore atteso (BR7.9): la precisione 100% vale anche per ciò che il modulo compila davvero.
- **Benchmark della CI:** estrazione ≤ 200 ms (NFR4) e candidati con le parole ≤ 100 ms (NFR5.9), misurati separatamente su 4000 caratteri, con obiettivi interni di 150 e 80 ms (BR7.23).

**Test di oggi e cosa succede con il progetto** (NFR5.5, suite esistente verde). Ho controllato i testi che i test passano al modulo:

| Test | Testo | Con BR7 | Cambia l'attesa? |
|---|---|---|---|
| `packages/estimation/test/label_fields_test.dart` (tutti i casi) | vari | `extractLabelFields` non cambia | No |
| `label_fields_test.dart`, insieme di `label_texts.json` | 39 testi | idem, più il test nuovo sulla vista compilata | No (test aggiunto) |
| `test/cellar/ui/autofill_form_test.dart`, "a tap reads once and fills every empty field" e gli altri con `baroloText` | "Barolo Vietti\n2019" | testo breve: denominazione 0,55 + 0,25 = 0,80 certa; nome NB 0,85 certo; annata 1,00; produttore assente, quindi nessuna domanda. Si compilano 6 campi, evento `autofill paste filled 6` | No |
| `autofill_form_test.dart`, "every useful field already full" | `baroloText` due volte | il secondo incolla non ha campi vuoti né domande: messaggio di oggi | No |
| `autofill_form_test.dart`, testo vuoto e "750 ml\n13% vol" | rumore | nessun campo e nessun candidato: niente guida (BR7.10), messaggi di oggi | No |
| `autofill_form_test.dart`, `AddWineInitialValues.fromLabelFields(extractLabelFields(baroloText))` e la matrice di accessibilità | `baroloText` | `extractLabelFields` non cambia; senza `analysis` la guida non si apre | No |
| `test/label/ui/autofill_entry_test.dart` (foto e condivisione) | `baroloText`, "750 ml\n13% vol", "   " | come sopra; la query di "Cerca online" resta "Barolo Vietti Barolo DOCG 2019" | No |
| `integration_test/autofill_test.dart`, "Incolla da Lens" | "Barolo Vietti\n2019" | come sopra | No |
| `integration_test/autofill_test.dart`, incolla automatico | "Chianti Classico Riserva\n2018" | testo breve: denominazione 0,90 certa; nome NG 0,45 + 0,35 = 0,80 certo; il Livello riceve la qualifica dall'analisi (BR7.8 c) | No |
| `test/label/ui/shell_share_test.dart` | "Cantina del Lago" | produttore PB 0,95 certo: il modulo si apre compilato | No |
| `test/label/label_session_controller_test.dart`, `label_scope_test.dart` | "Barolo", "Cantina del Lago"… | provano il controller prima del modulo: non leggono la vista compilata | No |

Se in Code Generation un test di questa tabella cambia comunque, il cambio va motivato nel piano e approvato: non si cambia un'attesa di oggi per far passare un peso.

### D8 — Punteggio a segnali sommati, soglia più distacco

**Decisione.** Ogni candidato riceve la somma dei pesi dei suoi segnali (BR7.3–BR7.6). La certezza è "primo ≥ 0,80 e distacco ≥ 0,25" (BR7.7). I pesi sono costanti con un nome, tarate sull'insieme di riferimento. Pesi e punteggi sono interi in centesimi (BR7.1), così i casi esattamente a 0,80 e a 0,25 non dipendono dagli arrotondamenti dei `double`.

**Alternative considerate (aritmetica):** `double` arrotondato a due decimali prima del confronto. Scartata: funziona, ma basta dimenticare l'arrotondamento in un punto per far cambiare stato a un campo.

**Alternative considerate (modello):**
- **Regole sì/no senza punteggio**, cioè certo se vale la regola di BR1. Scartata: non dà una lista ordinata per i "No" (FR7.4) né un modo per misurare il rango.
- **Solo soglia, senza distacco.** Scartata: due candidati forti, per esempio due righe "Château …" o due anni soli, sarebbero "certi" e il primo sarebbe giusto solo per caso.
- **Probabilità calibrate** (punteggi trasformati in probabilità con una curva). Rimandata: servono più testi veri, raccolti dall'uso. I pesi sommati si possono sostituire dopo senza cambiare l'API: `score` resta tra 0 e 1.

**Conseguenze.**
- Il comportamento si spiega con una tabella (`rules.md`, tabelle dei pesi).
- Il proprietario può chiedere di cambiare un peso.
- Un test controlla le invarianti di ENT-009.

### D9 — `TextAutofillFlow` restituisce anche l'analisi

**Decisione.**
- **`TextFields`.** Diventa `TextFields(LabelFields fields, {LabelAnalysis analysis = LabelAnalysis.empty})`, con `fields == analysis.certainFields`.
- **Chi decide la guida.** Il modulo legge `analysis.uncertainFields` e decide se aprire la guida (BR7.10).
- **`TextSureMatch`.** Non cambia: con una proposta sicura non c'è guida (FR7.1).
- **Foto.** `LabelLookupFlow._fieldsOf` usa `analyzeLabelText`. `AddWineInitialValues` riceve `analysis` in memoria, così anche il modulo dalla foto apre la guida (FR1.2, FR7.1).
- **Errori.** Un errore del lettore dà `LabelAnalysis.empty` e si riporta come oggi, senza testo (`ExtractFailureSink`).

**Alternative considerate:**
- **Nuova variante `TextNeedsGuide` della classe sigillata.** Scartata: lo stesso testo può insieme compilare campi certi e aprire domande, quindi le varianti si sovrapporrebbero. Ogni `switch` esistente andrebbe toccato senza guadagno.
- **Il modulo ricalcola l'analisi da sé** dopo `TextFields`. Scartata: il modulo dovrebbe tenere il testo più a lungo (FR2.3) e leggerlo due volte, il che costa tempo dentro i 2 secondi di FR2.8.

### D10 — La scheda è un livello dentro il modulo, non una rotta

**Decisione.**
- **Livello.** `GuidedConfirmSheet` è un livello in uno `Stack` sopra il corpo di `AddWineScreen`, con una barriera oscurata (`ModalBarrier`) e un `PopScope` che gestisce Indietro.
- **Animazione.** Entra dal basso con `AnimatedSlide`.
- **Movimento ridotto.** Con `MediaQuery.disableAnimations` la scheda appare subito.
- **Chi guida.** Il modulo apre e chiude la scheda in modo sincrono tramite il controller (D11).

**Alternative considerate:**
- **`showModalBottomSheet`.** Scartata per tre motivi:
  - `isDismissible` è fisso per tutta la rotta, mentre in Componi e in Modifica il tocco fuori non deve chiudere (BR7.17);
  - chiuderla quando arriva un nuovo testo richiede un `Navigator.pop` che può incrociare altre rotte, per esempio il dialogo "Usare il testo per i campi vuoti?";
  - il fuoco di ritorno (A16) è più difficile da controllare.
- **Schermata a tutta pagina.** Scartata: i mockup G1–G5 chiedono la scheda sopra il modulo, che resta visibile sotto. Una schermata nuova perderebbe il contesto.
- **Domande dentro il modulo, accanto a ogni campo.** Scartata: non dà "una domanda alla volta" (FR7 preambolo) né il progresso di FR7.6.

### D11 — Stato della guida in memoria nel modulo, senza ripristino di Android

**Decisione.**
- **Macchina a stati.** `GuidedSession` e `GuidedMemory` (ENT-012, ENT-014) sono Dart puro in `lib/label/core/guided_session.dart`, provato con unit test. Le transizioni sono funzioni pure: stato + azione → stato nuovo.
- **Controller.** `GuidedConfirmController`, un `ChangeNotifier` nel `State` di `AddWineScreen`, tiene la memoria e la sessione e applica le risposte ai campi del modulo.
- **Rotazione.** `MainActivity` dichiara già `configChanges` per orientamento, dimensione, densità e tema (`AndroidManifest.xml`), quindi Android non ricrea l'Activity. Il `State` del modulo resta, e con lui la guida, alla stessa domanda (BR7.19).
- **Secondo piano.** Lo stato resta in memoria finché vive il processo.
- **Processo chiuso da Android.** Guida e testo si perdono, come vuole FR7.7.

**Alternative considerate:**
- **`RestorationMixin` / `RestorationBucket`.** Scartata: Android scrive il bundle di ripristino su disco, quindi candidati e parole finirebbero su disco, contro FR2.3 e FR7.9.
- **Provider Riverpod `keepAlive`.** Scartata: vivrebbe oltre il modulo e potrebbe passare a un altro modulo aperto dopo. Il modulo dovrebbe anche ripulirlo a mano in ogni uscita.
- **Stato dentro il widget della scheda.** Scartata: la scheda si ricostruisce. Un nuovo testo e "Pulisci", che arrivano dal modulo, non potrebbero chiuderla e svuotarla in modo sincrono.

**Conseguenze.** Un test dei widget ruota lo schermo (`tester.view.physicalSize`) e controlla che domanda, modalità e parole scelte restino. Un altro manda il modulo in secondo piano e lo riporta in primo piano.

### D12 — FR2.8: tempo limitato per la ricerca, base aperta in anticipo, attesa visibile

**Contesto.** Sul telefono "Incolla da Lens" non mostrava niente: la prima ricerca apriva la base offline (circa 2 secondi) e poteva aspettare Open Food Facts fino a 5 secondi.

**Decisione.** Tre misure, le prime due già nel codice e qui documentate come progettate:
1. **Tempo limitato per la ricerca.** `TextAutofillFlow.lookupBudget` vale `defaultLookupBudget` = 1500 ms e comprende l'apertura della base. Allo scadere vale "nessun vino" e si usa il testo. La ricerca continua in sottofondo e scalda base e cache, senza toccare il modulo (BR7.23). Lo scadere non è un errore e non si riporta.
2. **Base aperta in anticipo.** `AddWineScreen.didChangeAppLifecycleState` apre la base offline con `wineDbLoaderProvider.open()` quando il modulo va in `AppLifecycleState.hidden`, cioè mentre l'utente è in Lens.
3. **Attesa visibile** (da fare in Code Generation). `PasteFromLensCard` riceve `busy`: pulsante "Leggo il testo…" con indicatore, un solo tocco, stato occupato per il lettore di schermo (BR7.24, A15).

**Bilancio dei 2 secondi:**
- ricerca: 1500 ms;
- estrazione: obiettivo 150 ms (limite CI 200 ms, NFR4);
- candidati e parole: obiettivo 80 ms (limite CI 100 ms, NFR5.9);
- appunti e disegno: circa 150 ms;
- margine per il telefono: circa 120 ms.

Per il testo condiviso il tempo parte quando il modulo è visibile (BR7.23).

**Alternative considerate:**
- **Saltare la ricerca nell'incolla.** Scartata: FR2.5 chiede di proporre un vino certo trovato nella base.
- **Ricerca ed estrazione in parallelo, compilando prima dal testo e poi sostituendo con il vino trovato.** Scartata: il modulo cambierebbe sotto gli occhi dell'utente, anche a guida aperta, e FR2.8 vieta di cambiare il modulo dopo il risultato.
- **Estrazione in un `Isolate`.** Non serve: 200 + 100 ms stanno nel bilancio, e avviare un isolate costa decine di millisecondi.

**Verifica.** Le verifiche di NFR5.9:
- un e2e in CI con la base reale aperta a freddo e Open Food Facts che non risponde: dal tocco al primo fotogramma del risultato al massimo 2 s;
- i benchmark di estrazione e candidati;
- la prova sul telefono del proprietario, riportata in Build and Test.

### D13 — Insieme di riferimento in Markdown, fixture JSON in Code Generation

**Decisione.**
- **Testi.** L'insieme di FR7.3 si scrive in `label-reference-set.md`: 69 testi, il valore giusto e lo stato atteso per campo chiave.
- **Fixture.** In Code Generation diventa `packages/estimation/test/fixtures/label_reference_set.json`, con la chiave della riga al posto del nome mostrato della denominazione e con `currentYear: 2026`. Lo usa un test di BR7.9.
- **Taratura.** Si cambiano pesi e soglie finché il test è verde. I valori attesi dei testi non si cambiano per far passare il test: si cambiano solo se sono sbagliati come vino, con il motivo nel file.

**Alternative considerate:**
- **Scrivere subito il JSON.** Scartata: in questa fase il proprietario deve poter leggere e correggere i casi, e il JSON non si legge bene in revisione.
- **Allargare `label_texts.json`.** Scartata: quel file controlla anche tipo, paese, regione e livello con regole di BR1.10. Mischiare i due criteri renderebbe confuso cosa fallisce.

## Scarti dai requisiti da confermare con il proprietario

Il progetto si allontana dalla lettera dei requisiti in cinque punti (il quinto, sugli anni, è nato in Code Generation). Ognuno ha un motivo e va confermato al gate; `traceability.json` li annota.

| Requisito | Lettera | Progetto | Motivo |
|---|---|---|---|
| FR7.3 | un campo è certo o incerto | terzo stato **assente** per denominazione, produttore e nome senza candidati né indizi: non si chiede (BR7.8) | il minimo lavoro (preambolo di FR7); chiedere un campo senza nessun indizio costa un "Salta" a ogni testo. Limite noto: un produttore senza parole chiave (ES10) resta da scrivere a mano |
| FR1.1 e FR7.3 | nome e annata compilati in almeno il 90% dei testi che li contengono | le soglie si misurano sui campi attesi certi, cioè sui testi che li contengono senza ambiguità, come BR1.10 (BR7.9) | con almeno 15 nomi incerti su 60 i nomi certi sono al massimo il 75%: la lettera è impossibile. La percentuale di campi compilati senza guida si riporta per campo nel riepilogo dell'insieme |
| FR7.4 | dopo l'ultimo "No" il campo resta vuoto e si passa avanti | la domanda resta aperta senza proposta; il campo resta vuoto con "Salta" o alla chiusura (BR7.12) | precisazione già approvata in `interaction-spec.md` (revisione dei mockup) |
| FR7.4, BR7.1, BR7.6, BR7.13 (Code Generation, dopo la revisione del codice) | la ruota e gli anni plausibili vanno fino all'anno corrente + 1 | la ruota, i candidati dell'annata e le parole vanno fino all'**anno corrente** (`rules.md`, nota BR7.6-N1) | la validazione del modulo al salvataggio (`WineRules.validateVintage`) accetta solo fino all'anno corrente: con +1 la guida potrebbe dare un'annata che poi fallisce su "Salva" |
| FR7.5 | le parole già confermate per un altro campo sono disattivate | restano selezionabili con un segno "usata per …"; una parola non entra due volte nello stesso valore (BR7.15) | il nome contiene spesso le parole della denominazione o del produttore ("Barbera d'Asti Superiore", "Champagne Brut Réserve", "Château …"); disattivarle bloccherebbe la composizione proprio nei casi più comuni |

**Testi da aggiornare fuori da questa fase** (non sono file di questa fase, quindi non li ho cambiati):
- `requirements.md`, FR7.3: aggiungere lo stato assente e la misura delle soglie sui campi attesi certi.
- `requirements.md`, FR7.4: "Quando i candidati finiscono, la domanda resta aperta senza proposta; il campo resta vuoto con Salta o alla chiusura".
- `requirements.md`, FR7.5, e `interaction-spec.md` ("Le parole già confermate per un altro campo sono barrate e non si toccano"): "restano selezionabili con un segno; una parola non entra due volte nello stesso valore".
- `interaction-spec.md`, tabella delle risposte, riga "No, un'altra": "Senza altri candidati il campo resta vuoto e si passa avanti" va allineata alla precisazione della stessa pagina.

## Flussi

### F1 — Dalla foto al modulo

Lettura della foto con fronte e retro, come oggi. Poi:
- **vino non trovato:** `analyzeLabelText(testo unito)` (D9; prima della riapertura `extractLabelFields`);
- **almeno un campo certo o una domanda** (BR7.10): `AddWineScreen(initialFields, filledKeys, suggestedLevel, analysis)`; con domande la guida si apre (F7);
- **nessun campo e nessuna domanda:** "Non trovato".

### F2 — "Incolla da Lens"

Tocco su "Incolla da Lens" → `Clipboard.getData`.
- **Senza testo:** messaggio.
- **Con testo:** si cerca nella base. Con una proposta sicura compare il pannello della proposta; altrimenti si compilano solo i campi vuoti con i campi certi di `analyzeLabelText` (D9, BR7.8) e, se ci sono domande, si apre la guida (F7, BR7.10).
- **Nessun campo nuovo e nessuna domanda:** "Nel testo non ho trovato dati da aggiungere".

### F3 — "Da Google Lens" e incolla automatico

1. Dalla scelta "Aggiungi vino" si apre il modulo vuoto.
2. `openLensCamera()` apre Lens e crea `LensSession(openedAt)`.
3. Al ritorno (`AppLifecycleState.resumed`) il modulo controlla `clipTimestamp()` con BR2.6. Se la condizione vale, applica F2 senza tocco e annuncia "Modulo compilato dal testo di Lens".

### F4 — "Condividi" da Lens

1. Il testo condiviso arriva alla `HomeShell`.
2. Con l'accesso fatto si apre il modulo; senza accesso, prima l'accesso.
3. Il modulo si compila con F2.

### F5 — Correzione

"Correggi" → anno → `windowOverride = {endYear, setAt}`. Poi `window = effectiveWindow(...)` e si scrive in un solo `update`. "Ripristina stima" fa `windowOverride: delete` e ricalcola `window`.

### F6 — Base reale (Build and Test)

1. Si scarica l'export in `.cache/off/`, che è in `.gitignore`.
2. `dart run tool/build_wine_db.dart --input .cache/off/<export>.csv.gz --output assets/wine_db/`.
3. `tool/check_wine_db_release.sh`.
4. Build e misure sul telefono (BR6).

### F7 — Testo con campi incerti: la conferma guidata

1. **Testo.** Arriva da "Incolla da Lens", da "Condividi", dall'incolla automatico o dalla foto. Per l'incolla il pulsante passa subito in attesa (BR7.24).
2. **Ricerca e analisi.** `TextAutofillFlow.run` fa la ricerca entro 1,5 s, poi `analyzeLabelText` (D9). Per la foto l'analisi arriva con `AddWineInitialValues.analysis`.
3. **Proposta sicura.** Compare il pannello di oggi e la guida non si apre.
4. **Campi certi.** Riempiono solo i campi vuoti, con "✦ dal testo" (FR2.4).
5. **Domande.** Se ce ne sono (BR7.10), il controller crea `GuidedSession` con l'elenco fissato e la scheda sale. Il fuoco va alla domanda.
6. **Ogni risposta** applica BR7.12 o BR7.13 e aggiorna il modulo sotto. Una denominazione confermata compila tipo, paese, regione e Livello suggerito (BR7.20).
7. **Fine o chiusura.** La scheda si chiude e resta il modulo con "Salva". "Conferma guidata" resta nella barra finché ci sono domande senza risposta (BR7.17).

### F8 — Nuovo testo a guida aperta

1. Il nuovo testo chiude la sessione in corso: i campi confermati restano e la vecchia analisi si scarta.
2. Il testo segue F7 dal punto 1, con la memoria del modulo: le risposte e i rifiutati restano (BR7.18).

## Esempi dell'insieme di riferimento (estratto)

| Testo (riassunto) | Attesi |
|---|---|
| "CHÂTEAU MEYNEY / SAINT-ESTÈPHE / 2016 / Appellation Saint-Estèphe Contrôlée / Mis en bouteille au château" | nome Château Meyney, denominazione Saint-Estèphe, annata 2016, rS, FR / Bordeaux |
| "La Rioja Alta S.A. / Gran Reserva 904 / Rioja / Denominación de Origen Calificada / 2015" | nome Gran Reserva 904, produttore La Rioja Alta S.A., denominazione Rioja, annata 2015, rS, ES / Rioja, livello suggerito aging |
| "Barolo / Denominazione di Origine Controllata e Garantita / Ravera / Vietti / 2016 / 14,5% vol" | nome Barolo Ravera, produttore Vietti, denominazione Barolo, annata 2016, rS, IT / Piemonte |
| "Catena / Malbec / Mendoza Argentina / 2020 / Product of Argentina" | nome Catena Malbec, denominazione Mendoza, annata 2020, rS, AR / Mendoza |
| "Dönnhoff / Riesling Spätlese / Nahe / 2019 / Gutsabfüllung" | produttore Dönnhoff, denominazione Nahe, annata 2019, B, DE / Nahe, livello suggerito aging |
| "Cantina fondata nel 1898 / Barbera d'Asti Superiore / 2021" | annata 2021 (non 1898), denominazione Barbera d'Asti |
| "Vinícola Aurora / Tannat / Serra Gaúcha / safra 2023" | denominazione Serra Gaúcha, annata 2023, BR / Serra Gaúcha |
| "Contiene solfiti 750 ml 12% vol" | nessun campo, quindi "Non trovato" |
| "Brut / Méthode Traditionnelle / Crémant d'Alsace" | denominazione Alsace, tipo SpC, FR / Alsace |
| "Grande Vino Rosso d'Italia 2018 2019" | annata vuota (ambigua), tipo rL, nessuna denominazione |

L'insieme completo ha almeno 30 testi e si scrive in Code Generation (BR1.10). Per la conferma guidata c'è un secondo insieme, già scritto in questa fase: `label-reference-set.md` (FR7.3, BR7.9, D13).

## Componenti che cambiano

- **`packages/estimation`:**
  - tabelle mondiali e vitigni;
  - `extractLabelFields`;
  - `effectiveWindow`;
  - `WineLevel`;
  - basis `grape`;
  - qualifiche nuove;
  - `analyzeLabelText`, `LabelAnalysis`, `FieldCandidate`, `LabelWord`, con `label_lines.dart`, `label_candidates.dart`, `label_scoring.dart`, `label_words.dart` (D7, D8);
  - fixture `label_reference_set.json` e benchmark dei candidati (D13, NFR5.9).
- **`lib/cellar`:**
  - `Wine` con `level` e `windowOverride`;
  - repository e i tre punti di ricalcolo;
  - `AddWineScreen` ed `EditWineScreen` (Livello, barra, Pulisci, Incolla);
  - `IdealMomentCard` (correzione, origine della stima).
- **`lib/label`:**
  - F1 verso il modulo compilato;
  - `LensSession`;
  - scelta "Da Google Lens";
  - `TextFields` con `analysis` e `LabelLookupFlow` con `analyzeLabelText` (D9);
  - `guided_session.dart`: `GuidedSession`, `GuidedMemory`, `GuidedAnswer` (D11).
- **`lib/cellar/ui`:** `GuidedConfirmSheet`, `WordPicker`, `VintageWheel`, `GuidedConfirmController`, il pulsante "Conferma guidata" nella barra e lo stato di attesa di `PasteFromLensCard` (D10, D12, `frontend-components.md`).
- **File ARB:** le chiavi `guide*` e `autofillReading` nelle 3 lingue.
- **`lib/app/home_shell.dart`:** testo condiviso.
- **Android:**
  - filtro `text/plain`;
  - `<queries>` per `com.google.ar.lens`;
  - `openLensCamera` e `clipTimestamp` nel canale `vinoozy/lens`.
- **`firestore.rules`, `test/rules/`, `test/rules/compat/` e `promote.yml`.**
- **Base reale in `assets/wine_db/`** (Build and Test).
