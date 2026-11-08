# Regole — compilazione dall'etichetta e finestre per tutto il mondo

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR6, NFR1–NFR6), FR3.1 aggiornato con la copertura completa (messaggio 03977a27).
- `inception/refined-mockups/interaction-spec.md` e le sue revisioni.
- `reviews/review-01.md` di questa fase: i punti R-01…R-11 sono risolti qui.
- `entities.md` e `world-tables.md` di questa fase.
- Riapertura da Build and Test (2026-11-08): FR2.8 e FR7.1–FR7.9 di `requirements.md`, schermate G0–G5 di `inception/refined-mockups/` (`mockups.md`, `interaction-spec.md`, A15–A22 di `accessibility-checklist.md`). Le regole BR7 e l'insieme `label-reference-set.md` nascono da qui.
- Codice di oggi su cui si progetta BR7: `packages/estimation/lib/src/label_fields.dart`, `recognizer.dart`, `vintage_parser.dart`, `lib/label/core/text_autofill.dart` (`lookupBudget`), `lib/cellar/ui/add_wine_screen.dart` (apertura anticipata della base), `lib/cellar/ui/autofill_widgets.dart`, `packages/estimation/test/fixtures/label_texts.json`.
- `codekb/Vinoozy/`: `recognizer.dart` (`resolveWine`), `window.dart`, `vintage_parser.dart`, `label_line_picker.dart`, `wine_origins.dart`, `cellar_actions.dart`, `wine_estimator.dart`, `estimate_refresher.dart`, `window_adjuster.dart`.

```yaml
rules:
  # BR1 — estrazione dei campi dal testo (FR1.1, FR1.5)
  - id: BR1.1
    statement: "Il testo si divide in righe (a capo, '·', '|') e si normalizza come oggi (tokenizeAll: minuscole, senza accenti, punteggiatura come separatore, parole intere). Si scartano le righe di servizio: volume (cl, ml, l), grado (% vol), 'contiene solfiti / contains sulfites / contient des sulfites / contiene sulfitos', codici a barre (8-14 cifre), indirizzi web, lotti ('L.' + cifre)."
    category: computation
  - id: BR1.2
    statement: "Denominazione: si cerca con findAlias (alias più lungo, parole intere) su tutte le righe utili. Gli alias marcati 'deboli' in world-tables.md (parole comuni come toro, salta, port, cava, baden, napa, rioja da sola in testi spagnoli) valgono solo se nella stessa riga o in quella vicina c'è un indicatore (doc, docg, aoc, aop, do, doca, dop, igp, igt, ava, 'appellation', 'denominazione', 'denominacion', 'denominacao', 'wine of origin') o il nome del paese. Una X fuori dalle tabelle non diventa mai denominazione. Questa regola sugli alias deboli vale solo per il testo letto dall'etichetta: nel nome scritto a mano dall'utente un alias debole conta sempre (decisione del proprietario, messaggio 0b738ea2)."
    category: computation
  - id: BR1.3
    statement: "Annata: VintageParser spostato nel pacchetto con una nuova opzione 'ambiguousAsNull'. Si cercano gli anni 1900..anno corrente+1 come parole intere. Si scartano gli anni preceduti entro 3 parole da 'dal/since/depuis/desde/seit/fondata/founded/fondee/fundada/gegrundet'. Se resta un solo anno, è l'annata; se ne restano più, vince quello entro 3 parole da 'vendemmia/millesime/cosecha/vintage/jahrgang/colheita/safra/annata'; altrimenti l'annata è nulla (FR1.1). L'uso di oggi nella lettura delle foto (U6) resta invariato con ambiguousAsNull=false."
    category: computation
  - id: BR1.4
    statement: "Produttore: il testo dopo una delle frasi di imbottigliamento (imbottigliato da/all'origine da, prodotto e imbottigliato da, mis en bouteille par/au/a la propriete par, embotellado por, engarrafado por, abgefullt von/durch, gutsabfullung von, produced and bottled by, vinified and bottled by, estate bottled by) fino a virgola o fine riga; altrimenti la prima riga che contiene come parola intera chateau, domaine, clos, tenuta, cantina, cantine, azienda agricola, bodega, bodegas, quinta, weingut, winery, estate, vineyards, cave, caves e che non è la denominazione. Massimo 80 caratteri, testo originale (con accenti) della riga."
    category: computation
  - id: BR1.5
    statement: "Nome: LabelLinePicker (spostato nel pacchetto) sulle righe utili tolte denominazione, annata, produttore e parole di colore; se il produttore inizia con chateau/domaine/clos/quinta e non resta altra riga significativa, il nome è il produttore. Se resta una riga e la denominazione è italiana, il nome è 'Denominazione + riga' (es. 'Barolo Ravera'). Massimo 60 caratteri, testo originale."
    category: computation
  - id: BR1.6
    statement: "Tipo, in ordine: (1) parole di colore e stile come parole intere (rosso/red/rouge/tinto/rot/vermelho/tinto; bianco/white/blanc/blanco/weiss/branco; rosato/rose/rosado; spumante/brut/sekt/espumante/cremant/cava/champagne/franciacorta + 'metodo classico/methode traditionnelle/traditional method' → sparklingClassic, altrimenti sparklingTank; passito/dolce/sweet/moelleux/liquoreux/dulce/suss → sweet; porto/port/sherry/jerez/madeira/marsala → fortified); (2) l'unico tipo della denominazione se ne ha uno solo; (3) il tipo del vitigno. Un rosso è redStructured se la riga contiene una qualifica di invecchiamento (BR1.8), altrimenti il tipo della denominazione o del vitigno decide tra redLight e redStructured, e senza questi redLight."
    category: computation
  - id: BR1.7
    statement: "Paese e regione: da paese e regione della denominazione; altrimenti dalle frasi 'prodotto in X / product of X / produit de X / producto de X / produto de X / wein aus X / wine of X' con X riconosciuto da WineOrigins.findCountry; altrimenti vuoti. Il vitigno non dà mai paese o regione."
    category: computation
  - id: BR1.8
    statement: "Parole di qualifica, come parole intere e in questo ordine di priorità: gran selezione → granSelezione; gran reserva → granReserva; grand cru / grand cru classe → grandCru; premier cru / 1er cru / premier grand cru classe → premierCru; riserva → riserva; reserva / reserve → reserva; crianza → crianza; superiore → superiore; trockenbeerenauslese / beerenauslese / auslese → auslese; spatlese → spatlese; kabinett → kabinett; late bottled vintage / lbv → lbv; colheita → colheita; vintage → vintage solo se la denominazione ha la qualifica 'vintage' (porto, champagne). Livello suggerito 'aging' per: granSelezione, granReserva, grandCru, premierCru, riserva, reserva, auslese, spatlese, vintage, colheita."
    category: computation
  - id: BR1.9
    statement: "Ogni valore compilato passa la validazione di oggi (WineValidator); un valore che non la passa resta vuoto."
    category: validation
  - id: BR1.10
    statement: "L'insieme di riferimento (test fixture, almeno 30 testi in 6 lingue, testi copiati da Lens compresi) è scritto in coerenza con BR1.1–BR1.8; superato se 0 campi compilati errati, nome e annata compilati in ≥ 90% dei testi che li contengono senza ambiguità, denominazione in ≥ 80% dei testi con una denominazione delle tabelle."
    category: validation

  # BR2 — ingresso del testo (FR1.2, FR2)
  - id: BR2.1
    statement: "La lettura della foto senza vino trovato apre AddWineScreen con LabelFields se BR1 ha compilato almeno un campo; altrimenti 'Non trovato'. Con la conferma guidata la condizione diventa quella di BR7.10: almeno un campo certo o almeno una domanda, e il modulo riceve anche l'analisi."
    category: workflow
  - id: BR2.2
    statement: "Testo incollato, condiviso o automatico: prima i gradini di ricerca di oggi (base offline, catalogo interno, Open Food Facts solo con rete); con una proposta sicura si mostra quella; altrimenti BR1 compila solo i campi vuoti (FR2.4). Nessun campo nuovo → 'Nel testo non ho trovato dati da aggiungere'. Con la conferma guidata si compilano solo i campi certi dell'analisi (BR7.8) e il messaggio compare solo se non c'è nessun campo nuovo e nessuna domanda (BR7.10)."
    category: workflow
  - id: BR2.3
    statement: "Il testo si tronca a 4000 caratteri e vive solo in memoria; non va in log, Crashlytics, CatalogEventLogger, Firestore o disco. Gli eventi contano solo l'esito."
    category: constraint
  - id: BR2.4
    statement: "Condivisione ACTION_SEND text/plain: app chiusa o senza accesso → il testo resta in memoria fino al modulo; modulo aperto e modificato → 'Usare il testo per i campi vuoti?'; testo vuoto → 'Nessun testo ricevuto'."
    category: workflow
  - id: BR2.5
    statement: "'Da Google Lens' apre prima il modulo vuoto e poi Lens: getLaunchIntentForPackage('com.google.ar.lens'); se null o ActivityNotFoundException, l'intent Lens dell'app Google (pacchetto com.google.android.googlequicksearchbox); se anche questo fallisce, LensInstructionsSheet. Alla riuscita si crea LensSession(openedAt = System.currentTimeMillis() lato nativo)."
    category: workflow
  - id: BR2.6
    statement: "Incolla automatico (solo Android 8.0+, API 26): al ritorno in primo piano e di nuovo al primo onWindowFocusChanged(true) (su Android 10+ gli appunti si leggono solo con il focus), se c'è una LensSession con openedAt da meno di 5 minuti e clipTimestamp() > openedAt, ≠ consumedClipTimestamp e con MIME text/*, si legge il testo una volta, si applica BR2.2 e si annuncia 'Modulo compilato dal testo di Lens'. clipTimestamp() restituisce {timestamp, mime} senza leggere il contenuto. Sotto API 26 l'incolla automatico non c'è e resta il pulsante."
    category: constraint
  - id: BR2.7
    statement: "Pulisci svuota nome, produttore, denominazione, annata, tipo, paese, regione e livello (torna 'non scelto'), toglie i segni ✦; quantità, posizione e note restano. Conferma se un campo descrittivo è stato scritto o modificato a mano o il livello è stato toccato."
    category: workflow

  # BR3 — stima per tutto il mondo (FR3)
  - id: BR3.1
    statement: "Precedenza (coerente con resolveWine di oggi): catalogo esterno > denominazione del campo denominazione dell'utente > denominazione dal catalogo o dal nome compatibile con il tipo scelto > vitigno compatibile con il tipo scelto > tipo scelto > generica. Una denominazione con più tipi (Bordeaux, Napa, Mendoza, Alsace…) usa la finestra del tipo scelto o ricavato; se il tipo non è tra i suoi, la denominazione si salta."
    category: computation
  - id: BR3.2
    statement: "Un nome che è sia denominazione sia vitigno vale come denominazione solo se la tabella delle denominazioni lo contiene con quella grafia; un alias di vitigno non compare mai tra gli alias di una denominazione."
    category: computation
  - id: BR3.3
    statement: "Il paese scelto dall'utente non viene mai cambiato dalla stima; la denominazione di un altro paese si usa solo per la finestra."
    category: computation
  - id: BR3.4
    statement: "Confidenza: denominazione scelta a mano o con valori dedicati + annata → medium; denominazione con finestra da modello → low; vitigno → low; il livello non cambia la confidenza; la correzione manuale mostra 'corretto da te' al posto dell'avviso."
    category: computation
  - id: BR3.5
    statement: "Coerenza: ogni regione delle righe è una regione di WineOrigins del suo paese oppure nulla; i suggerimenti di origine di WineOrigins per le denominazioni (_denominations) si leggono dalla tabella del pacchetto, che diventa la sola fonte. Un test controlla ogni riga."
    category: validation
  - id: BR3.6
    statement: "Tabella generata: tool/build_appellations.dart legge l'export eAmbrosia (vino, DOP/IGP, scaricato a mano dal registro pubblico UE) e i file CSV non UE in tool/data/appellations/ (AVA, GI australiane e neozelandesi, Wine of Origin sudafricane, DO argentine/cilene/brasiliane/uruguaiane, AOC svizzere) e scrive packages/estimation/lib/src/generated/appellations.g.dart: chiave, alias, paese, regione (solo se collegata a WineOrigins), tipi ammessi, chiave del modello. Le righe con valori dedicati (world-tables.md) hanno la precedenza sulle generate. Controlli: ≥ 1500 righe, nessuna chiave duplicata, ogni modello esiste; altrimenti nessuna scrittura."
    category: workflow
  - id: BR3.7
    statement: "Modelli: una finestra per (paese, stile) dove stile è uno degli 8 tipi più la variante del paese (es. IT-redStructured, FR-white-Loire); le righe generate senza tipo nel registro ammettono i tipi del modello di paese 'IGP' (rosso leggero, bianco, rosato). Ogni modello ha la sua motivazione in world-tables.md."
    category: computation
  - id: BR3.8
    statement: "L'aggiornamento della stima (FR3.5) riscrive baseWindow per tutti i vini, ma la finestra effettiva di un vino con windowOverride mantiene l'anno di fine corretto (BR4.4)."
    category: computation

  - id: BR3.9
    statement: "Stima per tutte le denominazioni (richiesta del proprietario, messaggio edf3e015). Ogni riga della tabella, dedicata o generata, e ogni tipo che ammette dà una finestra valida: un test le scorre tutte e verifica 0 ≤ start ≤ peak ≤ end, end ≥ start + 1 e nessuna riga senza finestra. Dopo l'aggiornamento dell'app, ensureEstimates ricalcola una volta la stima di tutti i vini già in cantina con le tabelle nuove (versione delle tabelle salvata nel vino come window.tablesVersion), rispettando livello e correzione (BR3.8, BR4.4)."
    category: computation

  # BR4 — livello e finestra effettiva (FR4, FR5)
  - id: BR4.1
    statement: "Il livello si applica dentro estimateWindow sugli scarti in anni della riga usata, prima di sommarli all'anno base: everyday → start ×0,5, peak ×0,6, end ×0,6; good → ×1; aging → start ×1,25, peak ×1,3, end ×1,4; arrotondamento all'intero più vicino (0,5 per eccesso), poi start ≤ peak ≤ end e end ≥ start + 1. baseWindow contiene quindi già il livello; cambiare livello ricalcola la stima in locale."
    category: computation
  - id: BR4.2
    statement: "Con una qualifica già usata, aging non moltiplica di nuovo; everyday sì. Il livello non tocca una finestra del catalogo esterno."
    category: computation
  - id: BR4.3
    statement: "Il livello si salva solo se scelto o accettato (Salva con il suggerimento visibile = accettato); 'non scelto' e 'Nessuno' non scrivono il campo; un livello salvato non è mai sostituito da un suggerimento, anche nel modulo di modifica (FR4.3)."
    category: workflow
  - id: BR4.4
    statement: "Finestra effettiva = baseWindow (con livello) → windowAdjustment (come oggi) → windowOverride: endYear = override.endYear; se l'adeguamento avesse portato peakYear o startYear oltre endYear, si fermano a endYear (FR5.6). Senza adeguamento startYear non cambia mai (FR5.1), perché BR4.6 garantisce endYear ≥ startYear."
    category: computation
  - id: BR4.5
    statement: "Tutti i punti che scrivono o mostrano la finestra passano level e windowOverride e calcolano la finestra effettiva con la stessa funzione: saveNewWine, saveEdit, ensureEstimates, EstimateRefresher, recomputeAdjustment, WineEstimator.displayed. estimate/refine ricevono level; withAdjustment applica poi windowOverride."
    category: constraint
  - id: BR4.6
    statement: "windowOverride.endYear tra startYear della finestra senza correzione e startYear + 60. 'Ripristina stima' cancella windowOverride (FieldValue.delete) e lascia windowAdjustment."
    category: validation
  - id: BR4.7
    statement: "Stati e Dashboard leggono la finestra effettiva salvata in window. L'etichetta dell'origine (WindowAdjuster.labelOf) ha priorità: 'corretto da te' > 'corretta dalle bevute' > origine della stima."
    category: workflow

  # BR5 — regole Firestore e compatibilità (NFR1)
  - id: BR5.1
    statement: "firestore.rules: wineFields() aggiunge 'level' e 'windowOverride'. In creazione e, in aggiornamento, solo se changed.hasAny(['level']) / changed.hasAny(['windowOverride']): level null o in ['everyday','good','aging']; windowOverride null o mappa con soli 'endYear' (int 1900..2200) e 'setAt' == request.time. validWindow: basis in ['catalog','denomination','grape','wineType','generic']; qualifier in ['riserva','superiore','granSelezione','crianza','reserva','granReserva','premierCru','grandCru','kabinett','spatlese','auslese','vintage','lbv','colheita']; 'denominationKey' stringa 1..60 facoltativa; 'tablesVersion' intero facoltativo (BR3.9)."
    category: validation
  - id: BR5.2
    statement: "Compatibilità (test/rules/compat/): le scritture della versione attuale (senza campi nuovi) passano; un update parziale della versione attuale su un vino con level e windowOverride passa e i due campi restano. Una versione vecchia che riscrive window ignorando livello e correzione lascia una finestra non coerente: la versione nuova la ricalcola in ensureEstimates all'apertura della Cantina."
    category: validation
  - id: BR5.3
    statement: "promote.yml: RULES_FEATURES aggiunge 'level-override' (NFR1.5)."
    category: constraint

  # BR6 — base reale di Open Food Facts (FR6)
  - id: BR6.1
    statement: "In Build and Test, con l'OK del proprietario (a1260ab6), si scarica l'export pubblico di Open Food Facts in .cache/off/ (in .gitignore), si esegue tool/build_wine_db.dart senza --allow-small-sample e si sostituisce assets/wine_db/. I controlli di oggi devono passare; con meno di 5000 vini si ferma e si chiede al proprietario."
    category: workflow
  - id: BR6.2
    statement: "Misure sul telefono del proprietario con la base reale: aumento dell'AAB, apertura della base, memoria; risultati in Build and Test."
    category: validation
  - id: BR6.3
    statement: "Allo stesso modo si scarica l'export eAmbrosia dei vini (pubblico, riuso consentito dalla Commissione UE) in .cache/eambrosia/ e si genera la tabella delle denominazioni (BR3.6); in Code Generation si usa un estratto di prova nel repository per i test."
    category: workflow

  # BR7 — candidati, certezza e conferma guidata (FR7, FR2.8; riaperto da Build and Test)
  # Pesi e soglie sono riassunti nelle tabelle sotto il blocco YAML.
  - id: BR7.1
    statement: "Analisi del testo (analyzeLabelText, D7). Per ognuno dei 4 campi chiave (denominazione, produttore, nome, annata) l'analisi dà una lista ordinata di al massimo 5 candidati, ognuno con un punteggio da 0 a 1 e gli id delle parole del testo da cui viene (BR7.14). I candidati vengono solo dal testo (FR1.1, FR7.5): produttore, nome e annata sono testo dell'etichetta, con il maiuscolo/minuscolo di oggi (una riga tutta maiuscola diventa 'Iniziali Maiuscole'); la denominazione è sempre il nome di una riga delle tabelle di FR3.1 trovata da parole del testo (findAliasMatches). Due candidati uguali dopo tokenizeAll si fondono e tengono il punteggio più alto. Ogni candidato passa la validazione di BR1.9 (lunghezze, annata 1900..anno corrente + 1); un candidato non valido si scarta prima di contare i 5. Ordine: punteggio decrescente; a parità, per la denominazione l'alias con più parole; poi la posizione nel testo (riga, poi parola). Aritmetica: punteggi e pesi sono interi in centesimi (0,55 = 55); si sommano come interi, si limitano a 0..100 e si confrontano come interi con T e M (BR7.7). Nessun numero in virgola mobile entra nel calcolo, così 70 + 10 è esattamente 80; il valore 0..1 si mostra solo diviso per 100."
    category: computation
  - id: BR7.2
    statement: "Segnali comuni. Le righe sono quelle di BR1.1; p è la posizione della riga tra le righe utili (0 = prima). Riga maiuscola = almeno 3 lettere, tutte maiuscole. Testo breve = al massimo 3 righe dopo aver tolto le righe di servizio e le righe (b)-(f) qui sotto: è il caso di un nome scritto a mano o di un testo incollato corto ('Barolo Vietti' a capo '2019'). Rumore: (a) una riga di servizio di BR1.1 (gradi, volume, solfiti, codici a barre, URL, lotti) si scarta intera se ha al massimo 8 parole; se ne ha di più (testo di Lens incollato senza a capo) si toglie solo il pezzo di servizio e il resto resta; (b) righe di indirizzo (BR1.1); (c) righe di origine: contengono il nome di un paese (wineCountryNames) e non sono la prima riga; (d) righe di premi (medaglia, medal, medaille, medalla, medalha, concorso, concours, concurso, wettbewerb, award, punti, points) e di anniversari (anni, years, ans, anos, jahre, anniversario, anniversary, anniversaire); (e) righe di prosa: più di 6 parole e più parole minuscole che con l'iniziale maiuscola, oppure che finiscono con un punto; (f) righe numeriche: meno parole di almeno 2 lettere che numeri (A.P.Nr., codici di lotto, numeri sparsi). Le righe (b)-(f) non danno mai candidati per produttore e nome, tranne la frase di imbottigliamento di BR7.4; le righe (b) e (d) danno anni solo con la penalità di BR7.6. Il punteggio è la somma dei segnali della sua tabella, limitata a [0, 1]."
    category: computation
  - id: BR7.3
    statement: "Denominazione: un candidato per ogni riga di tabella trovata nelle righe utili, con la sua occorrenza migliore. Base 0,55 per un alias forte; 0,25 per un alias debole (BR1.2), che diventa 0,55 se un indicatore è nella stessa riga o in una vicina, o c'è il nome del suo paese. Segnali: indicatore (BR1.2: DOC, DOCG, AOC, DO, DOCa, IGT, IGP, AVA, DAC, 'Appellation … Contrôlée', 'Denominazione/Denominación/Denominação/Denominació', 'Indicazione/Indicação', 'Wine of Origin', 'Vinho Regional', 'Jatorri Deitura', Qualitätswein, Prädikatswein) nella stessa riga o in quella vicina +0,30, a 2 righe +0,20, altrove nel testo +0,10; alias di almeno 2 parole +0,10; nome del paese della riga nel testo +0,05 se il paese è nell'UE, +0,25 fuori dall'UE (dove gli indicatori non si stampano di solito); alias contenuto in un alias più lungo trovato nel testo (Chianti dentro Chianti Classico, Asti dentro Barbera d'Asti) -0,30; alias in una riga del produttore (parola di BR1.4 o forma societaria) -0,25; alias uguale a un vitigno (Barbera, Primitivo) senza indicatore vicino -0,20; in un testo breve (BR7.2), alias forte all'inizio della sua riga o da solo nella riga +0,25 (testa del testo breve: 'Barolo Vietti / 2019' dà Barolo 0,80, certo). Conseguenza voluta: in un testo lungo di Lens una denominazione dell'UE senza indicatore non arriva mai a 0,80 ed è incerta; in un testo breve, che di solito è un nome scritto o copiato apposta, la denominazione in testa a una riga è certa come oggi."
    category: computation
  - id: BR7.4
    statement: "Produttore, fonti e punteggi (per ogni valore si tiene la fonte migliore): (PA) testo dopo una frase di imbottigliamento di BR1.4, estesa con 'élaboré par', 'elaborado por', 'hergestellt von', 'elaborado e engarrafado por', fino a virgola, punto e virgola, ' - ' o fine riga, senza punteggiatura iniziale: 0,90; (PA') verbo di imbottigliamento, fino a 4 parole e poi da/par/por/by/von ('Imbottigliato nel 2022 da …'): 0,75; (PB) riga di al massimo 6 parole con una parola forte o una forma societaria: 0,70, +0,15 se p ≤ 1. Parole forti: tutte quelle di _producerWords in label_fields.dart, che resta la lista di riferimento (chateau, domaine, clos, tenuta, cantina, cantine, bodega, bodegas, quinta, weingut, winery, estate, vineyards, cave, caves, fattoria, podere, vinicola, vinicole, adega, herdade, kellerei, weinbau, maison, vignobles, vignoble, vigneron, vignerons, viticoltori, vignaioli, winegrowers, marchesi, marchese, negociant, proprietaire, recoltant, eleveur), più quelle nuove: cooperativa, cooperative, cantina sociale, domane, schlossgut, sektkellerei, winzergenossenschaft, weinmanufaktur, winzerkeller, cellars, wines; forme societarie: S.A., S.L., S.r.l., S.p.A., S.a.s., GmbH, Ltd, Inc, Lda, SARL, EARL, GAEC, SAS, eG, azienda agricola, società agricola, az. agr., soc. agr.; (PC) riga con una parola debole (cascina, castello, masseria, villa, casa, mas, pazo, finca, pago, senorio, schloss, famiglia, familia, family, fratelli, hermanos, irmaos): 0,45, +0,15 se p ≤ 1; (PD) frase 'imbottigliato all'origine / estate bottled / mis en bouteille au château…' senza nome, più la prima riga semplice: 0,55; (PG) in una riga di più di 6 parole, una parola forte seguita da al massimo 4 parole con l'iniziale maiuscola o articoli: 0,50; (PH) in una riga di indirizzo, il testo prima della prima virgola o del codice postale se contiene una parola forte o una forma societaria: 0,55; (PE) riga semplice a p = 0, di al massimo 3 parole, che non è denominazione, vitigno, stile o anno: 0,35. Segnali: unico candidato di tipo PB, PC, PG o PH (PE e PA non contano) +0,10; lo stesso produttore da due fonti diverse (parole dell'uno contenute nell'altro) +0,10, e si tiene il testo più lungo; riga con un anno o una parola di fondazione (dal, since, depuis, desde, seit, fondata, founded, fundada, gegrundet, est.): il valore si taglia prima dell'anno o della parola, -0,15; valore fatto solo di parole forti, deboli o forme societarie, senza un nome proprio ('Weingut', 'Az. Agr. Podere', 'Cascina' su una riga spezzata da Lens): -0,50. Una riga con indicatore o con parole di imbottigliamento non è mai un candidato PB/PC/PE."
    category: computation
  - id: BR7.5
    statement: "Nome, fonti e punteggi. Riga di marca = riga utile che può essere un nome (BR1.5: senza parole di imbottigliamento, fondazione, origine) con residuo non vuoto, non solo vitigno, che non è una riga PA, PB o PC del produttore e non ha solo parole del produttore; le righe PE restano righe di marca; una riga PC vale come marca solo per NC ('Pazo de Lourido Albariño'), mai per NA, NB o ND. Riga di vitigno = residuo coperto dai vitigni. (NA) denominazione italiana o francese dedicata + l'unica riga di marca di al massimo 3 parole ('Barolo Ravera', BR1.5): 0,85 con denominazione certa, 0,60 se incerta; (NB) unica riga di marca, al massimo 3 parole e p ≤ 2: 0,85; altrimenti 0,70; (NC) unica riga di marca di al massimo 3 parole + riga di vitigno ('Catena Malbec'): 0,70, e in questo caso la marca da sola vale 0,55 e il vitigno da solo 0,40; (ND) due o più righe di marca: 0,50 ciascuna, +0,10 la più lunga (LabelLinePicker); (NE) riga che inizia con chateau, domaine, clos, quinta, herdade e nessuna riga di marca né di vitigno: 0,85; (NF) riga di vitigno: 0,55 senza righe di marca, 0,40 con righe di marca; (NI) denominazione + riga di vitigno senza marca ('Alsace Riesling'): 0,60; (NG) testo della riga della denominazione senza gli indicatori ('Rosso Toscana' da 'Rosso Toscana IGT'), seguito dalla prima riga fatta solo di qualifiche (Riserva, Crianza, Reserva, Superiore, Classico) e dalla prima riga fatta solo di parole di stile (Brut, Extra Dry; non le frasi del metodo classico), al massimo 2 righe (una riga mista di qualifiche e stile, come 'Brut Réserve', conta come riga di qualifica): 0,50 se aggiunge una riga, 0,45 altrimenti; in una riga di più di 6 parole NG usa solo il testo dell'alias; in un testo breve senza righe di marca né di vitigno, con l'alias all'inizio di una riga di al massimo 6 parole, NG +0,35 ('Chianti Classico Riserva' a capo '2018' dà il nome certo, come oggi); (NH) solo l'alias della denominazione, se diverso da NG: 0,30; (NJ) il produttore come nome: 0,30; il produttore + la riga di vitigno: 0,50, e se il produttore viene da una frase di imbottigliamento e una riga in testa ne contiene una parte ('HOLLOW OAK' di 'Hollow Oak Cellars'), si usa quella riga. NG e NH ci sono sempre quando c'è una denominazione. Penalità Q: una riga di marca maiuscola di 1 o 2 parole a p ≤ 1 quando nessun produttore arriva a 0,80 (probabilmente è il produttore, come 'VIETTI') toglie 0,30 a ogni candidato costruito su quella riga. Un anno dopo cuvée, cuvee, bin, no, n., nr resta nel nome ('Cuvée 2000'); gli altri anni si tolgono (BR1.5); un '’24' o ''24' è rumore. 'Grand vin' e 'vendanges tardives', 'sélection de grains nobles' sono parole di stile, non di marca."
    category: computation
  - id: BR7.6
    statement: "Annata: un candidato per ogni anno da 1900 all'anno corrente + 1 scritto come parola intera di 4 cifre (regola di VintageParser; '2022er' vale 2022), in tutte le righe tranne quelle di servizio. Base 0,50. Segnali: parola di annata (vendemmia, annata, vintage, harvest, millésime, millesimo, cosecha, añada, collita, verema, jahrgang, colheita, safra) entro 3 parole nella stessa riga, oppure sola nella riga precedente ('Colheita' a capo '2018'): +0,40; anno solo nella sua riga: +0,20; unico candidato senza segnali negativi, e senza segnali negativi esso stesso: +0,30 (un anno con un segnale negativo non riceve mai questo segnale); parola di fondazione entro 3 parole prima: -0,45; entro 5 parole dopo una parola di imbottigliamento (imbottigliato, bottled, mis en bouteille, embotellado, engarrafado, abgefüllt): -0,40; riga di premi o anniversari, riga di indirizzo o intervallo 'AAAA - AAAA': -0,35; anno dopo cuvée, cuvee, bin, no, n., nr: -0,30. Con lo stesso punteggio viene prima l'anno che compare prima nel testo. Un anno scritto male da Lens ('2O19', '20' e '19' su due righe) non è un candidato."
    category: computation
  - id: BR7.7
    statement: "Regola di certezza (FR7.3), uguale per i 4 campi: un campo è certo se il primo candidato ha punteggio ≥ 0,80 (soglia T = 80 centesimi) e supera il secondo di almeno 0,25 (distacco M = 25 centesimi; senza secondo candidato il distacco è il punteggio stesso). I confronti sono tra interi in centesimi (BR7.1); un test prova i casi esattamente a 80 e a 25. Motivazione: T = 0,80 richiede almeno due prove indipendenti (per esempio alias + indicatore, riga in testa + parola forte, anno solo + unico), quindi un solo indizio non basta mai; M = 0,25 è appena più di un segnale medio (+0,20/+0,30): se due candidati distano meno di un segnale, la scelta tra loro dipende da un dettaglio del testo ed è giusto chiedere. T, M e i pesi di BR7.3-BR7.6 sono costanti in un solo file del pacchetto (label_scoring.dart) e si tarano sull'insieme di riferimento (label-reference-set.md): in Code Generation si possono cambiare solo se l'insieme resta verde su tutti i criteri di BR7.9, e il cambio si scrive nel file con il motivo."
    category: computation
  - id: BR7.8
    statement: "Stato del campo: certo, incerto o assente. Assente = nessun candidato e nessun indizio che il campo ci sia: per la denominazione nessun indicatore nel testo; per il produttore nessuna frase di imbottigliamento e nessuna parola di BR7.4; per il nome nessuna riga utile. L'annata non è mai assente: senza anni è incerta (FR7.4). Un campo assente non si chiede (FR7 preambolo: il minimo lavoro) e resta vuoto; lo stato assente è uno scarto da FR7.3, che il proprietario deve confermare (functional-spec.md, 'Scarti dai requisiti'). Senza guida (FR7.3) il modulo usa LabelAnalysis.certainFields: un campo chiave certo si compila, un campo incerto o assente resta vuoto. Campi di contorno: (a) paese e regione della denominazione si compilano solo con la denominazione certa o confermata; il paese dalle frasi 'product of' (BR1.7) non dipende dalla denominazione; (b) il tipo, con la denominazione incerta, si calcola con BR1.6 senza la denominazione: parole di colore e di stile, qualifica di invecchiamento (rosso → redStructured), vitigno trovato fuori dall'alias della denominazione; se resta da scegliere tra redLight e redStructured senza un vitigno, il tipo resta vuoto e non si indovina; con la denominazione certa vale BR1.6 intero; (c) la qualifica dell'analisi (BR1.8) va sempre al Livello suggerito, anche se il nome è incerto o vuoto (oggi _fillEmpty la passa solo insieme al nome). extractLabelFields non cambia: resta il lettore di BR1 con i suoi test (label_fields_test.dart, label_texts.json, BR1.10) e l'API di oggi; analyzeLabelText usa le stesse righe, parole e alias (label_lines.dart) e il modulo non legge più extractLabelFields (D7)."
    category: computation
  - id: BR7.9
    statement: "Insieme di riferimento (FR7.3, NFR5.8): label-reference-set.md, almeno 60 testi in it, fr, es, en, de, pt; per ogni campo chiave valore giusto e stato atteso (C certo, I incerto, A assente); almeno 15 I per campo; almeno 10 testi con un valore giusto fuori dai candidati. Il test è superato se: (1) nessun campo certo è sbagliato (precisione 100%); un campo atteso I che risulta certo con il valore giusto è ammesso, ma questi casi sono al massimo il 10% dei campi attesi I, altrimenti la regola è troppo larga; (2) le soglie di FR1.1 si misurano sui testi che contengono il campo senza ambiguità, cioè sui campi attesi C (come BR1.10): risultano certi con il valore giusto almeno nel 90% per nome e annata e nell'80% per la denominazione; (3) nei campi I con il valore giusto tra i candidati, il valore giusto è primo in almeno il 70% e tra i primi 3 in almeno il 90%; (4) in media al massimo 2 campi incerti per testo e mai più di 4. Il rango atteso scritto nell'insieme è informativo: il test controlla le percentuali, non il rango di ogni testo. I 'valori giusti fuori dai candidati' contano solo se il valore è scritto nel testo (un'annata che il testo non riporta non conta). Misura riportata, non bloccante: la percentuale di campi compilati senza guida per campo su tutti i testi, scritta nel riepilogo dell'insieme come conseguenza accettata di FR7.3. label_texts.json (BR1.10) resta com'è e il suo test resta verde su extractLabelFields; in più un test nuovo legge gli stessi testi con analyzeLabelText e verifica sulla vista compilata (certainFields) che nessun campo compilato, chiave o di contorno, sia diverso dal valore atteso: così la precisione 100% di BR1.10 vale anche per i valori che il modulo compila davvero."
    category: validation
  - id: BR7.10
    statement: "Quando parte la guida (FR7.1). Dopo 'Incolla da Lens', il testo condiviso, l'incolla automatico e il modulo compilato dalla foto, la guida si apre da sola se c'è almeno una domanda: un campo chiave incerto, vuoto nel modulo, non scritto a mano (FR2.4) e senza risposta in questo modulo (BR7.17). Un testo senza righe utili, o che non dà nessun campo certo e nessun candidato per denominazione, produttore e nome, non apre la guida (non si chiede la sola annata a un testo come '750 ml / 13% vol'): valgono 'Non trovato' e i messaggi di oggi. Non si apre con una proposta sicura (FR2.5, TextSureMatch) né quando tutti i campi chiave sono certi o assenti. Il messaggio 'Nel testo non ho trovato dati da aggiungere' compare solo se il testo non compila nessun campo e non apre nessuna domanda. La lettura della foto apre il modulo (BR2.1) se c'è almeno un campo certo o almeno una domanda."
    category: workflow
  - id: BR7.11
    statement: "Domande e progresso (FR7.2, FR7.6). Ordine fisso: denominazione, produttore, nome, annata, solo per i campi di BR7.10. Il totale T è il numero delle domande all'apertura e non cambia. N è la posizione della domanda in corso (1..T) e cresce solo passando alla domanda successiva; un 'No' non cambia N. Alla riapertura (BR7.17) T si ricalcola sui campi rimasti senza risposta. Al massimo 4 domande e al massimo 5 candidati per domanda."
    category: workflow
  - id: BR7.12
    statement: "Risposte (FR7.4), tranne l'annata. Apertura di una domanda: con candidati si propone il primo non rifiutato; senza nessun candidato (campo incerto con indizio ma senza valori, come IT12) la domanda si apre senza proposta con 'Non l'ho trovato nel testo', non con l'avviso dell'ultimo No. Sì: è sempre ammesso, anche se il candidato ha parole già usate da un altro campo (BR7.15); compila il campo con il candidato proposto, lo segna '✦ dal testo' (FR1.3), segna le sue parole come usate da quel campo e passa avanti. No: il candidato va nei rifiutati del modulo e non torna più, nemmeno con un nuovo testo; si propone il candidato successivo non rifiutato e il lettore di schermo annuncia la proposta. Dopo l'ultimo candidato (precisazione approvata di interaction-spec, scarto dalla lettera di FR7.4): per 2 secondi 'Nessun'altra proposta: puoi comporla o saltare', poi l'avviso sparisce con l'azione noticeExpired (ENT-012); la domanda resta senza proposta, Sì e No si disattivano, restano Modifica, le parole e Salta; il campo resta vuoto solo con Salta o alla chiusura. Modifica: campo di testo con il valore proposto (vuoto se non c'è proposta) e tastiera aperta; Conferma con valore valido compila il campo (risposta data, segno '✦ dal testo' solo se il valore è uguale al candidato) e passa avanti; con valore vuoto lascia il campo vuoto, conta come risposta e passa avanti; con valore non valido mostra l'errore della validazione del modulo (FR1.5) e resta; Annulla torna alla domanda. Salta: campo vuoto, nessuna risposta, passa avanti. Dopo l'ultima domanda la scheda si chiude da sola; se un campo è stato saltato compare il messaggio del campo saltato."
    category: workflow
  - id: BR7.13
    statement: "Annata con la ruota (FR7.4). Anni dal 1900 all'anno corrente + 1, dal più recente in alto. Parte dal candidato con il punteggio più alto; senza candidati dall'anno corrente - 2. I candidati sono segnati con un punto e con il colore (non solo colore). Un tocco sull'anno al centro apre la tastiera numerica (keyboardOpen, ENT-012): 4 cifre nell'intervallo e 'OK' spostano la ruota su quell'anno e chiudono la tastiera; un valore fuori intervallo mostra l'errore della validazione dell'annata, la tastiera resta aperta e la ruota non si muove; Indietro con la tastiera aperta chiude solo la tastiera e torna alla ruota, senza chiudere la scheda. 'Conferma <anno>' compila l'annata (segno '✦ dal testo' se l'anno è un candidato) e passa avanti. 'Senza annata' spunta 'Senza annata' nel modulo, conta come risposta e la guida non chiede più l'annata in questo modulo, nemmeno con un nuovo testo. 'Salta' lascia il campo vuoto senza risposta. Non ci sono No né Modifica; non ci sono le parole del testo."
    category: workflow
  - id: BR7.14
    statement: "Parole del testo per FR7.5 (LabelWord). Si parte dal testo pulito (sanitizeLabelText, 4000 caratteri) e dalle righe di BR1.1 senza le righe di servizio (con la regola delle righe lunghe di BR7.2(a)). Una parola è un gruppo di caratteri tra spazi; si tolgono all'inizio e alla fine . , ; : ! ? ( ) [ ] { } \" « » “ ” „ * / e i trattini isolati; apostrofi (' e ’) e trattini dentro la parola restano ('d'Asti', 'Saint-Émilion'). Si scartano: le parole di una sola lettera; i gruppi con cifre che non sono un anno plausibile (1900..anno corrente + 1) e non hanno lettere ('904', '75cl' si scartano; 'Bisol1542' resta); le parole delle righe fatte solo di gradi, volume o indirizzi web. Le parole restano nell'ordine del testo (riga, poi posizione) con il testo originale, e si tengono le prime 120. Ogni parola ha un id stabile (il suo indice), la riga e il testo piegato (tokenizeAll) per i confronti."
    category: computation
  - id: BR7.15
    statement: "Composizione (FR7.5). Il primo tocco su una parola passa alla modalità Componi. Un tocco su una parola libera la aggiunge, un secondo tocco la toglie. Il valore è l'unione delle parole scelte nell'ordine del testo (id crescente), separate da un solo spazio, qualunque sia l'ordine dei tocchi; se è tutto maiuscolo diventa 'Iniziali Maiuscole' come i valori estratti (BR7.1). Limiti: al massimo 8 parole e 80 caratteri del valore; una parola libera che li supererebbe è disattivata. Parole usate: una parola usata da un altro campo confermato (Sì o Componi) resta selezionabile, con un segno e la semantica 'usata per la denominazione' (o il produttore, il nome), perché il nome contiene spesso le parole della denominazione o del produttore ('Barbera d'Asti Superiore', 'Champagne Brut Réserve', 'Château …'); una parola non può entrare due volte nello stesso valore (il secondo tocco la toglie). È uno scarto dalla lettera di FR7.5 ('le parole già confermate per un altro campo sono disattivate'), da far confermare (functional-spec.md, 'Scarti dai requisiti'). Conferma è attivo con almeno una parola; compila il campo come Sì (segno '✦ dal testo') se il valore passa la validazione del campo (FR1.5), altrimenti l'errore sotto l'anteprima e si resta. Annulla svuota la scelta e torna alla domanda. Per l'annata non c'è composizione."
    category: computation
  - id: BR7.16
    statement: "Denominazione composta (FR7.5). Il valore composto, piegato con tokenizeAll (minuscole, senza accenti, apostrofi e trattini come separatori) e senza gli indicatori e le qualifiche in coda (DOC, DOCG, AOC, Superiore, Riserva…), si confronta con tutti i nomi e gli alias delle righe di FR3.1 (formsOf), deboli compresi. Se è uguale a uno o più, l'anteprima mostra il nome della riga con la sua sigla e il campo prende quel nome. Con più righe vale la scelta della stima (BR3.1): prima la riga compatibile con il tipo già nel modulo, poi la riga dedicata, poi quella del paese nel modulo, poi la prima della tabella; la scelta resta modificabile nel modulo. Senza corrispondenza il campo prende il valore come è composto."
    category: computation
  - id: BR7.17
    statement: "Chiusura e ripresa (FR7.7). 'Chiudi', il tasto Indietro o un tocco fuori chiudono la scheda tenendo i campi confermati; in Componi e in Modifica il tocco fuori non chiude e Indietro torna prima alla domanda. Una risposta data (Sì, Componi, Modifica, Conferma della ruota, Senza annata) resta nella memoria del modulo; Salta e la chiusura no. Il pulsante 'Conferma guidata' compare nella barra finché resta almeno un campo incerto (non assente, BR7.8), vuoto, non scritto a mano e senza risposta, cioè finché GuidedMemory.pendingQuestions (ENT-014) non è vuota; riapre la guida dal primo di questi campi, con T ricalcolato (BR7.11)."
    category: workflow
  - id: BR7.18
    statement: "Nuovo testo a guida aperta (FR7.7). Incolla, condivisione o incolla automatico chiudono subito la guida in corso tenendo i campi confermati; la vecchia analisi si scarta. Il nuovo testo segue BR2.2 e FR2.4: riempie solo i campi vuoti con i campi certi, poi, se ci sono domande (BR7.10), apre una nuova guida con la nuova analisi. I rifiutati e le risposte del modulo restano (BR7.12, BR7.13). Un campo con una risposta non si riempie mai da solo, nemmeno se è vuoto: 'Modifica' confermato vuoto (emptiedByEdit) e 'Senza annata' (noVintage) sono scelte dell'utente e un campo certo del nuovo testo non le sostituisce."
    category: workflow
  - id: BR7.19
    statement: "Modifiche, rotazione e secondo piano (FR7.7). Un campo scritto a mano mentre la guida è chiusa diventa 'scritto a mano' e non si chiede più. Con la guida aperta il modulo è coperto e non riceve modifiche. Rotazione e ritorno dal secondo piano riprendono alla stessa domanda, con la stessa modalità, la stessa proposta e le stesse parole scelte (lo stato è in memoria nel modulo, D11). Se Android chiude il processo, analisi, guida e testo si perdono: il modulo riparte senza guida (FR2.3, FR7.9)."
    category: workflow
  - id: BR7.20
    statement: "Dopo la denominazione confermata (FR7.7). Con la riga di tabella confermata si ricalcolano tipo (BR1.6 intero, con la riga), paese e regione (BR1.7). Il valore ricalcolato va nel campo se il campo è vuoto oppure se contiene un valore derivato dal testo (segno '✦ dal testo', mai toccato dall'utente): in questo caso lo sostituisce, per esempio il tipo vuoto o 'redLight' di un testo con 'Rosso' diventa 'redStructured' dopo 'Barolo'. Un valore scritto o scelto dall'utente non cambia mai (BR3.3). I campi compilati prendono il segno '✦ dal testo'. Il Livello suggerito si ricalcola (FR4.3) se l'utente non l'ha toccato; la qualifica arriva al Livello dall'analisi (BR7.8 c), non dal nome."
    category: workflow
  - id: BR7.21
    statement: "'Pulisci' (FR1.4, FR7.7) chiude la guida e svuota anche la memoria del modulo: risposte, rifiutati, parole usate e analisi."
    category: workflow
  - id: BR7.22
    statement: "Privacy (FR7.9, FR2.3). Analisi, candidati, parole, rifiutati e risposte vivono solo in memoria nel modulo; il loro toString non contiene testo; non vanno in log, Crashlytics, CatalogEventLogger, eventi, Firestore, disco o nello stato di ripristino di Android. Non ci sono eventi nuovi in questo lavoro."
    category: constraint
  - id: BR7.23
    statement: "Tempo di FR2.8: dal tocco su 'Incolla da Lens', o dalla lettura degli appunti nell'incolla automatico, al primo fotogramma con il risultato al massimo 2 secondi; per il testo condiviso il tempo parte quando il modulo è visibile (avvio dell'app e accesso esclusi, FR2.8). Bilancio: ricerca nella base offline, nel catalogo e su Open Food Facts al massimo 1,5 secondi compresa l'apertura della base (TextAutofillFlow.lookupBudget = defaultLookupBudget = 1500 ms, già nel codice); estrazione dei campi con obiettivo 150 ms per 4000 caratteri (limite bloccante 200 ms di NFR4 nel benchmark CI); candidati e parole con obiettivo 80 ms (limite bloccante 100 ms di NFR5.9); lettura degli appunti e disegno circa 150 ms. Somma degli obiettivi 1880 ms: restano circa 120 ms di margine per il telefono, che è più lento della CI; la prova sul telefono del proprietario (Build and Test) decide se il margine basta. Allo scadere della ricerca il risultato si fa dal testo; la ricerca continua in sottofondo e prepara solo base e cache per il prossimo testo, senza cambiare il modulo. La base offline si apre in anticipo quando il modulo va in secondo piano (AppLifecycleState.hidden, già nel codice)."
    category: constraint
  - id: BR7.24
    statement: "Attesa visibile (FR2.8, G0). Dal tocco fino al risultato il pulsante 'Incolla da Lens' mostra 'Leggo il testo…' con un indicatore circolare, è segnato occupato per il lettore di schermo e non accetta un secondo tocco; lo stesso stato compare nel riquadro durante l'incolla automatico. Al risultato (modulo compilato, proposta sicura, prima domanda o messaggio) il pulsante torna normale e il lettore di schermo annuncia l'esito."
    category: workflow
  - id: BR7.25
    statement: "Accessibilità e lingue (FR7.8). Tutti i testi della guida sono nei 3 file ARB; il fuoco va alla domanda all'apertura ('Domanda 2 di 3: Cascina Castlet è il produttore?') e torna al pulsante che l'ha aperta, o al primo campo compilato, alla chiusura; ogni parola è un pulsante selezionabile con il suo numero d'ordine; le parole disattivate sono lette 'non disponibile'; le parole sono raggruppate per riga ('Riga 2 di 6'); l'anteprima è una regione live; la ruota è un selettore regolabile che cambia di un anno; risposte, parole e righe della ruota sono alte almeno 48 dp e la scheda scorre con testo 2,0; vale la matrice di NFR6."
    category: validation
```

## BR7 — tabelle dei pesi (riassunto di BR7.3–BR7.7)

I valori sono il punto di partenza, tarato a mano sui testi di `label-reference-set.md`. Code Generation li può cambiare solo con l'insieme verde su tutti i criteri di BR7.9 (BR7.7).

**Certezza (tutti i campi):** primo candidato ≥ **0,80** e distacco dal secondo ≥ **0,25**.

### Denominazione (BR7.3)

| Segnale | Peso |
|---|---|
| Alias forte (base) | 0,55 |
| Alias debole (base), senza indicatore vicino né paese | 0,25 |
| Indicatore nella stessa riga o in quella vicina / a 2 righe / altrove | +0,30 / +0,20 / +0,10 |
| Alias di almeno 2 parole | +0,10 |
| Paese della riga nel testo: UE / fuori UE | +0,05 / +0,25 |
| Alias dentro un alias più lungo trovato | −0,30 |
| Alias nella riga del produttore | −0,25 |
| Alias uguale a un vitigno, senza indicatore vicino | −0,20 |
| Testo breve: alias forte in testa a una riga o da solo | +0,25 |

### Produttore (BR7.4)

| Fonte o segnale | Peso |
|---|---|
| PA frase di imbottigliamento + nome | 0,90 |
| PA' verbo di imbottigliamento … da/par/por/by + nome | 0,75 |
| PB riga con parola forte o forma societaria (+0,15 se p ≤ 1) | 0,70 |
| PC riga con parola debole (+0,15 se p ≤ 1) | 0,45 |
| PD imbottigliato all'origine + prima riga semplice | 0,55 |
| PG parola forte dentro una riga lunga | 0,50 |
| PH riga di indirizzo con parola forte | 0,55 |
| PE riga semplice in testa (≤ 3 parole) | 0,35 |
| Unico candidato di tipo PB/PC/PG/PH (PE e PA non contano) | +0,10 |
| Stesso produttore da due fonti | +0,10 |
| Anno o parola di fondazione nella riga (tagliati) | −0,15 |
| Valore fatto solo di parole del produttore o forme societarie | −0,50 |

### Nome (BR7.5)

| Fonte | Peso |
|---|---|
| NA denominazione IT/FR dedicata + marca (denominazione certa / incerta) | 0,85 / 0,60 |
| NB unica marca ≤ 3 parole e p ≤ 2 / altrimenti | 0,85 / 0,70 |
| NC marca + vitigno (marca sola 0,55, vitigno solo 0,40) | 0,70 |
| ND più righe di marca (+0,10 la più lunga) | 0,50 |
| NE riga Château/Domaine/Clos/Quinta/Herdade senza marca né vitigno | 0,85 |
| NF riga di vitigno: senza marca / con marca | 0,55 / 0,40 |
| NI denominazione + vitigno | 0,60 |
| NG riga della denominazione + riga di qualifica o di stile / da sola | 0,50 / 0,45 |
| NG in un testo breve senza marca né vitigno, alias in testa alla riga | +0,35 |
| NH solo l'alias della denominazione | 0,30 |
| NJ produttore come nome / produttore + vitigno | 0,30 / 0,50 |
| Q marca maiuscola di 1–2 parole a p ≤ 1 senza produttore certo | −0,30 |

### Annata (BR7.6)

| Segnale | Peso |
|---|---|
| Anno plausibile (base) | 0,50 |
| Parola di annata entro 3 parole, o sola nella riga sopra | +0,40 |
| Anno solo nella riga | +0,20 |
| Unico anno senza segnali negativi (solo se l'anno stesso non ne ha) | +0,30 |
| Fondazione entro 3 parole prima | −0,45 |
| Entro 5 parole dopo l'imbottigliamento | −0,40 |
| Premi, anniversari, indirizzi, intervallo AAAA - AAAA | −0,35 |
| Dopo cuvée / bin / no | −0,30 |

I calcoli si fanno in centesimi interi (BR7.1): 55 + 25 = 80 è certo, 79 no.

## BR7 — note di Code Generation (2026-11-08)

Precisazioni nate costruendo e provando l'analisi sull'insieme di riferimento e su `label_texts.json`. **Nessun peso delle tabelle sopra è cambiato.** Ogni nota è nel codice di `packages/estimation/lib/src/label_candidates.dart` o `label_words.dart`.

- **BR7.6-N1, anni fino all'anno corrente (scarto da BR7.1, BR7.6, BR7.14).** Un anno è plausibile da 1900 all'**anno corrente**, non all'anno corrente + 1: è l'intervallo della validazione del modulo al salvataggio (`WineRules.validateVintage`). Così un'annata certa, o confermata con la ruota (BR7.13), non fallisce mai su "Salva". Un anno dopo l'anno corrente non è un candidato né una parola mostrata. Scarto dopo la revisione del codice, da confermare con il proprietario.
- **BR7.2-N1, righe di origine.** Una riga con il nome di un paese e una frase di imbottigliamento ("Élaboré par …, Épernay - France") non è una riga di origine: il produttore si legge lì (FR04).
- **BR7.2-N2, fondazione e indirizzo.** Una riga con una parola di fondazione ("depuis 1885", "fundada em 1880") non è un indirizzo, anche se l'anno somiglia a un codice postale (FR11, PT09).
- **BR7.2-N3, la parola "do".** "do" conta come indicatore solo a fine riga: in portoghese è "del" ("Quinta do Vale", "Vinho do Porto").
- **BR7.4-N1, due fonti.** Il +0,10 "stesso produttore da due fonti" vuole due righe diverse: la stessa riga letta come PC e come PE è un solo indizio (IT01, ES06).
- **BR7.5-N1, NG nel testo breve.** Il +0,35 vale solo se la riga della denominazione è l'unica che dà un nome (nessuna riga di produttore o di marca accanto) e NG non aggiunge righe di qualifica o di stile. Un nome fatto di più righe resta incerto ("Brut / Crémant d'Alsace" di `label_texts.json`).
- **BR7.5-N2, cuvée.** NA non si applica a una marca che comincia con "Cuvée", "Bin", "No": la cuvée è il nome (FR13).
- **BR7.5-N3, penalità Q.** Si applica solo alle righe di marca, non a una riga di vitigno maiuscola ("PRIMITIVO", IT11).
- **BR7.5-N4, NJ + vitigno.** "Produttore + vitigno" vale solo senza righe di marca (EN07).
- **BR7.5-N5, parole del produttore nel rumore.** Le parole di una riga di rumore che contiene una parola di produttore non fanno una marca ("Guigal" sopra "E. Guigal, propriétaire-négociant à Ampuis, France").
- **BR7.5-N6, vitigni dell'analisi.** Oltre alla tabella dei vitigni di FR3.2, un elenco di 58 vitigni comuni nelle sei lingue (Grauburgunder, Silvaner, Trollinger, Loureiro, Castelão, Malvasia…) serve solo a riconoscere una riga di vitigno e un alias uguale a un vitigno (BR7.3). Non dà finestre né tipi e non entra nella stima. Decisione enologica presa in Code Generation (correzione di `project.md` del 2026-11-04), correggibile dal proprietario.
- **BR7.5-N7, parole che non sono marca.** "doce", "suave", "meio" sono parole di stile; "collita", "añada", "verema" sono parole di annata; un numero romano ("MMXVIII"), "’24", "2022er" e i numeri di una o due cifre non fanno una marca.
- **BR7.16-N1, corrispondenza più lunga.** Il valore composto si confronta prima intero; solo senza corrispondenza si tolgono in coda, uno alla volta, gli indicatori ("DOCG", "D.O.C.G.") e le qualifiche di invecchiamento, più "Superiore" e "Crianza". "Classico", "Gran", "Cru" da soli non si tolgono: "Chianti Classico" è Chianti Classico, non Chianti.

**Esempi di calcolo.**
- "CASCINA CASTLET / Barbera d'Asti Superiore / 14,5% vol 75 cl / 2019" (caso del proprietario, testo breve: 3 righe utili): denominazione 0,55 + 0,10 + 0,25 = 0,90, certa; produttore PC 0,45 + 0,15 + 0,10 = 0,70, incerto; nome NG "Barbera d'Asti Superiore" 0,45 contro NJ 0,30, incerto (la riga PC non vale come marca per NA); annata 0,50 + 0,20 + 0,30 = 1,00, certa. La guida chiede 2 domande: "Domanda 1 di 2: Cascina Castlet è il produttore?".
- "Barolo Vietti / 2019" (testi dei test di oggi, testo breve): denominazione 0,55 + 0,25 = 0,80, certa; nome NB "Barolo Vietti" 0,85, certo; produttore assente; annata 1,00. Si compilano nome, denominazione, annata, tipo, paese e regione come oggi, senza guida.
- "Tenuta Sconosciuta / Rosso Toscana IGT / 2020": denominazione 0,55 + 0,30 = 0,85, certa (Toscana); produttore PB 0,70 + 0,15 + 0,10 = 0,95, certo; nome NG "Rosso Toscana" 0,45, NH "Toscana" 0,30, incerto. Oggi il nome diventa "Toscana": con BR7.8 resta vuoto e la guida propone prima "Rosso Toscana".
