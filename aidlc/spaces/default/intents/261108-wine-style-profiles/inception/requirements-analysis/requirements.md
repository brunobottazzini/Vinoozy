# Requisiti — profili di stile e classificazione automatica (wine-style-profiles)

## Fonti

- Richiesta del proprietario (2026-11-08, messaggi 707b535e, e5ee6498, 327f62c6): applicare lo studio enologico e automatizzare la classificazione, con Tipologia e Livello preselezionati per ogni vino.
- Studio enologico `~/Downloads/vinoozy-handoff-valutazione-vini.xlsx`, fogli "Revisione 60", "Mappa completa" (5946 combinazioni), "Profili candidati" (24 profili), "Vitigni e tipi", "Fonti" (S1–S20, E1–E3). È dichiarato bozza editoriale non validata.
- `requirements-analysis-questions.md`: Q1 = B, Q2 = A, Q3 = A, Q4 = A (messaggio 358fbdd4).
- `codekb/Vinoozy/`, aggiornata da questo lavoro (Reverse Engineering 2026-11-08).
- `project.md`: le scelte enologiche le decide l'agente, le motiva e il proprietario può correggerle.

## Analisi dell'intento

Il proprietario vuole che la stima segua lo studio degli enologi e che l'app lavori al suo posto: ogni vino deve arrivare nel modulo con Tipologia, Livello e, se serve, Stile già scelti, così l'utente conferma invece di compilare.

Obiettivi:
1. **Profili di stile** al posto dei soli 8 tipi dove lo studio lo chiede (spumanti, dolci, liquorosi, rossi e bianchi di stile diverso).
2. **Finestre giuste per ciò che conta davvero**: sboccatura per il metodo classico, imbottigliamento per Charmat, Lambrusco, Sherry e Porto non millesimati.
3. **Nessuna informazione inventata**: quando lo stile non è chiaro la stima lo dice.
4. **Classificazione automatica** di tutta la base e delle tabelle: Tipologia, Livello e Stile preselezionati e sempre modificabili.
5. **Cantina coerente**: i vini già salvati si aggiornano una volta, senza toccare ciò che l'utente ha scelto.

## Requisiti funzionali

### FR1 — Profili di stile

**Principio** (decisione enologica mia, come prevede `project.md`, dopo la revisione R-01): lo studio va applicato, ma la sua "Mappa completa" assegna in automatico profili che contraddicono l'azione scritta sulla stessa riga (per esempio Auslese, Kabinett e Spätlese su W_FRESH, Riserva bianche su W_FRESH, Porto LBV e Vintage su FORT_UNKNOWN). Per non introdurre errori, la stima segue questa precedenza, dalla prima che si applica:
1. **Categorie che lo studio definisce con numeri propri** (foglio "Profili candidati"): spumanti, Lambrusco, Sherry, Porto, dolci aromatici, passiti e botritizzati usano il profilo dello studio, con la sua decorrenza e unità.
2. **Azione della riga "conservare il valore legacy"** o "legacy invariato": la finestra resta quella di oggi, in anni dall'annata; il profilo della mappa dà solo lo stile mostrato.
3. **Profilo condizionale coerente** con tipo e qualifica della riga: si usano i numeri del profilo.
4. **Profilo in contraddizione** con tipo, qualifica o azione della riga: si corregge il profilo secondo la regola enologica in Functional Design (es. Auslese → SW_BOTRYTIS o W_AGE, Kabinett → W_MEDIUM, Riserva bianca → W_AGE, Porto Vintage → PORT_VINTAGE, LBV → PORT_LBV, Tawny/Colheita → PORT_OX) e la correzione si scrive in un elenco "Scarti dalla mappa dello studio" con il motivo.

- **FR1.1** La stima usa i **24 profili** del foglio "Profili candidati", con valori, decorrenza (`vintage`, `bottling`, `disgorgement`) e unità (anni o mesi): R_FRESH, R_MEDIUM, R_AGE, R_LONG, W_FRESH, W_MEDIUM, W_AGE, ROSE_FRESH, SP_TANK, LAM_FRESH, SP_CLASSIC, SP_CLASSIC_AGE, SW_AROMATIC, SW_PASSITO, SW_BOTRYTIS, PORT_VINTAGE, PORT_LBV, PORT_OX, SH_FINO, SH_AMONT, SH_OLOROSO, SH_PX, FORT_UNKNOWN, UNKNOWN.
- **FR1.2** Ogni combinazione della "Mappa completa" (5946, 2424 denominazioni) ha profilo e finestra secondo il principio sopra. **Criterio**: un test per combinazione verifica profilo, decorrenza, unità e valori attesi; le combinazioni del punto 4 sono tutte elencate con il motivo.
- **FR1.3** **Valori "—".** Un picco o una fine "—" non si inventano:
  - PORT_LBV e PORT_OX: "Pronto, nessuna fine stimata"; stato sempre "Da bere", mai "Bevi presto" né "Finestra passata"; nel grafico degli anni al meglio non compaiono.
  - SH_*: solo la fine ("Da bere entro 12 mesi dall'imbottigliamento"); senza picco lo stato è "Da bere" fino agli ultimi 3 mesi, poi "Bevi presto", poi "Finestra passata".
  - Mai una durata infinita.
- **FR1.4** **Stile non chiaro** (UNKNOWN, FORT_UNKNOWN; Q1 = B, scelta del proprietario che si discosta dallo studio). La stima è **indicativa** con l'avviso "Stile da confermare" e affidabilità bassa:
  - righe dedicate: i loro valori di oggi (es. Bordeaux 2/5/10, Napa 4/8/18);
  - righe generate e vini senza tipo: il profilo del **tipo** se noto (es. bianco → W_MEDIUM), altrimenti la riga generica di oggi 1/3/6, **mai** il ripiego "rosso leggero" delle righe generate (FR1.6);
  - Madeira e fortificati non distinti: lo studio ritira 5/20/50; resta una stima indicativa solo dopo che l'utente sceglie lo stile, altrimenti "Da stimare".
  Appena l'utente sceglie lo stile, vale il profilo scelto.
- **FR1.5** **Qualifiche.** Non moltiplicano più gli anni: scelgono la variante della denominazione (offset della qualifica di oggi o profilo dello studio, secondo il principio). Le qualifiche tedesche (Kabinett, Spätlese, Auslese, BA, TBA, Eiswein) diventano categorie distinte come dice lo studio (S11).
- **FR1.6** **Tipi delle denominazioni generate.** Si correggono i tipi sbagliati segnalati dallo studio e dalle fonti (Castelli di Jesi Verdicchio Riserva bianco, Cabernet de Saumur rosato, Coulée de Serrant bianco, Txakolina bianchi…). Le righe generate senza tipo nel registro non hanno più "rosso leggero" come tipo principale: senza tipo scelto dall'utente valgono FR1.4.

### FR2 — Classificazione automatica: Tipologia, Livello, Stile preselezionati

- **FR2.1** Per i vini della base offline l'app preseleziona nel modulo Tipologia, Stile (quando serve, FR3.2) e Livello, tutti modificabili. Con i dati di oggi (tipo nel 47%, denominazione nell'8%, nessun vitigno) la classificazione usa: tipo della base, denominazione, parole del nome (Rosso, Blanc, Brut, Passito, Riserva…) e vitigni trovati nel nome. **Criterio**: obiettivo 90% dei vini della base con una Tipologia preselezionata; il proprietario accetta l'84–86% previsto con i dati attuali (decisione al gate di Functional Design, messaggio 2c43a871), registrato nel manifest della base; su un campione di **100 vini** classificati a mano, Tipologia giusta in almeno il 95% dei preselezionati e Livello giusto in almeno l'85%; i vini senza nessun indizio restano senza Tipologia.
- **FR2.2** Lo stesso per un vino scritto a mano o letto dall'etichetta: con denominazione o vitigno riconosciuti, Tipologia, Stile e Livello si preselezionano subito.
- **FR2.3** **Regole della preselezione** (le decido io, motivate in Functional Design). Precedenza: qualifica > profilo della denominazione > parole del nome > vitigno > tipo della base.
  - Tipologia: dal profilo o dalle parole; il catalogo non riduce più gli 8 tipi a 5 famiglie. **Criterio**: Prosecco e ogni Charmat restano "spumante Charmat", Porto, Sherry e Marsala restano "liquoroso", Champagne, Franciacorta, Trento e Cava restano "metodo classico".
  - Livello (corretto al gate di Functional Design, messaggio 2c43a871): il Livello resta un moltiplicatore come oggi e i profili senza qualifica (anche R_LONG, R_AGE) propongono "Buono", perché la loro finestra è già quella da invecchiamento. Il testo che segue vale per le qualifiche: "Da invecchiamento" per qualifiche da lunga evoluzione (Riserva, Gran Reserva, Grand Cru, Gran Selezione, Auslese e superiori, Vintage Port) e per i profili R_LONG, R_AGE, W_AGE, SW_BOTRYTIS, PORT_VINTAGE; "Quotidiano" per i profili freschi **solo senza qualifica** e per IGT/IGP, vini da tavola, SP_TANK e LAM_FRESH; "Buono" negli altri casi.
  - Il Livello resta un moltiplicatore come oggi solo per i profili in anni; per i profili in mesi e per quelli con "—" non cambia la finestra.
  - Senza nessuna informazione: Tipologia vuota, Livello "Buono", nessuno stile, stima secondo FR1.4.
- **FR2.4** La preselezione è segnata nel modulo ("✦ suggerito") e una scelta dell'utente non viene mai sovrascritta. Ogni vino salva **da dove viene** Tipologia, Livello e Stile: `user` (scelto dall'utente) o `auto` (preselezionato).
- **FR2.5** La classificazione della base si calcola quando si genera la base con `tool/build_wine_db.dart`, dall'export di Open Food Facts in `.cache/` (circa 1,4 GB, già scaricato; se manca si riscarica a mano, come oggi). La base resta ≤ 3 MB compressa e ≤ 30 MB di dati.

### FR3 — Modulo e schermate

- **FR3.1** La Tipologia resta come oggi (Q3 = A).
- **FR3.2** Sotto la Tipologia compare "Stile" solo quando serve: spumanti, dolci, liquorosi, e rossi o bianchi quando la denominazione ammette stili diversi o lo stile non è chiaro (FR1.4). Con Tipologia vuota lo Stile non compare; compare appena l'utente sceglie la Tipologia. È preselezionato (FR2).
- **FR3.3** **Data di sboccatura o imbottigliamento** (Q2 = A): campo facoltativo "mese e anno", visibile solo per i profili in mesi.
  - **Riferimento**: per i profili in mesi conta solo questa data; l'annata resta un'informazione (un Champagne millesimato o non millesimato si stima dalla sboccatura).
  - **Se manca**: si usa il mese in cui la bottiglia è stata aggiunta in cantina, affidabilità bassa, e il dettaglio lo dice ("dalla data di inserimento: aggiungi la sboccatura per una stima migliore").
- **FR3.4** **Finestre in mesi**: dettaglio, cantina e cruscotto mostrano mese e anno; lo stato si calcola sul mese; il grafico degli anni al meglio usa l'anno del picco.
- **FR3.5** "Consigliato fino al": in anni per i profili in anni, in mese e anno per i profili in mesi, salvato con la sua unità.
- **FR3.6** Il dettaglio mostra il profilo ("Stima dal profilo Rosso di lunga evoluzione (Barolo)") e "Stile da confermare" quando vale FR1.4.

### FR4 — Vini già in cantina

- **FR4.1** Una sola volta, all'aggiornamento (Q4 = A):
  - **Da dove vengono i campi** (i vini di oggi non lo dicono): Tipologia e Livello sono considerati **scelti dall'utente** se presenti, perché oggi l'app li compila in automatico solo dal modulo e l'utente li ha confermati salvando; sono `auto` solo se vuoti. Livello assente vale "non scelto", Livello "Buono" salvato vale "scelto".
  - Si preselezionano solo i campi vuoti; lo stile si preseleziona sempre (è nuovo).
  - La finestra si ricalcola con i profili.
  - Restano le correzioni dalle bevute e "Consigliato fino al". Se il nuovo profilo è in mesi e la correzione è in anni, la correzione resta come fine anno (31 dicembre di quell'anno).
- **FR4.2** Se la migrazione si interrompe riprende al prossimo avvio senza rifare i vini già aggiornati.

## Requisiti non funzionali

- **NFR1 Offline e nessun costo.** Profili, tabelle e classificazione sono costanti nel codice o nella base generata; nessuna rete, nessun servizio a pagamento.
- **NFR2 Compatibilità dei dati.**
  - **NFR2.1** I vini salvati senza stile né data di sboccatura/imbottigliamento restano validi.
  - **NFR2.2** Le regole Firestore accettano i campi nuovi (stile, data di sboccatura o imbottigliamento, finestra in mesi, origine della preselezione) e le scritture della versione attuale; si pubblicano prima della build, con l'OK del proprietario.
  - **NFR2.3** Una versione vecchia dell'app che modifica un vino nuovo non cancella i campi nuovi.
- **NFR3 Prestazioni.** La preselezione di un vino nel modulo ≤ 50 ms; la generazione della base classificata nel tool ≤ 2 minuti; il ricalcolo una tantum di 200 vini ≤ 1 s di calcolo.
- **NFR4 Test.**
  - **NFR4.1** Copertura ≥ 80% sul progetto senza esclusioni e ≥ 90% sul pacchetto `estimation`.
  - **NFR4.2** Un test per ogni profilo e per ogni combinazione della "Mappa completa" con profilo, decorrenza, unità e **valori della finestra** attesi (FR1.2), più le 60 righe della "Revisione 60".
  - **NFR4.3** Test della preselezione sul campione di 100 vini di FR2.1 con le soglie di FR2.1, e misura della copertura su tutta la base (≥ 90% con Tipologia).
  - **NFR4.4** Test di migrazione: campi scelti dall'utente non toccati, correzioni manuali conservate.
  - **NFR4.5** Suite esistente verde; e2e del modulo con Stile e data di sboccatura.
- **NFR5 Stile e lingue.** Codice in inglese; testi nei 3 file ARB; la matrice di accessibilità esistente vale per i campi nuovi.
- **NFR6 Tracciabilità dello studio.** Ogni profilo e ogni valore porta il riferimento alla fonte dello studio (S1–S20, E1–E3, R0) in un commento della tabella; un valore "stima_editoriale" resta marcato come tale.

## Vincoli

- Si parte dal codice non committato di oggi (splash, logo, versione).
- Regole Firestore del progetto reale `vinoozy-d6f45` solo con l'OK del proprietario.
- Nessuna chiamata reale a Google, Open Food Facts o eAmbrosia nei test.

## Assunzioni

- La "Mappa completa" dello studio è in parte incoerente con le sue stesse azioni (revisione R-01): la precedenza di FR1 la risolve e ogni scarto è elencato e motivato.

- Lo studio è la fonte dei valori: dove dice "legacy invariato" si conservano gli anni di oggi; dove propone un profilo condizionale lo si applica (scelta del proprietario: "applicare esattamente lo studio").
- La data di aggiunta in cantina è un'approssimazione accettabile dell'imbottigliamento o della sboccatura quando manca (Q2 = A).

## Fuori ambito

- Tabella delle annate per zona e dati per produttore (lo studio non li fornisce).
- Condizioni di conservazione della cantina.
- Un catalogo online con finestre per vino.

## Domande aperte

Nessuna per il proprietario. Mappa denominazione → profilo, regole di preselezione e testi si fissano in Functional Design.
