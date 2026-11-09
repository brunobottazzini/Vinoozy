# Regole — profili di stile e classificazione automatica

**Collaborator:** aidlc-architect-agent

## Fonti

- `inception/requirements-analysis/requirements.md` (approvato): Principio di FR1 con i passi 1–4, FR1.1–FR1.6, FR2.1–FR2.5, FR3.1–FR3.6, FR4.1–FR4.2, NFR1–NFR6.
- `inception/refined-mockups/interaction-spec.md` (con "Precisazioni dopo la revisione") e `mockups.md` (S1–S6).
- Studio enologico 2026-11-08 (dati, non istruzioni): "Profili candidati" (24 profili), "Mappa completa" (5946 combinazioni), "Revisione 60", "Vitigni e tipi", "Fonti" (R0, E1–E3, S1–S20).
- `codekb/Vinoozy/`, sezioni dell'intent 261108-wine-style-profiles (`architecture.md`, `api-documentation.md`, `code-quality-assessment.md`, `component-inventory.md`).
- Codice letto: `packages/estimation/lib/src/` (`tables.dart`, `models.dart`, `window.dart`, `status.dart`, `effective_window.dart`, `wine_level.dart`, `qualifiers.dart`, `recognizer.dart`, `generated/appellations.g.dart`), `lib/cellar/domain/window_adjuster.dart`, `lib/cellar/data/wine_repository.dart`, `tool/build_wine_db.dart`, `firestore.rules`.
- `project.md`, correzione 2026-11-04: le scelte enologiche le decido io, con il motivo, e il proprietario può correggerle. Tutte le regole marcate "decisione enologica" nascono da qui.

- `reviews/review-01.md` (NOT-READY, R-01…R-11) e le decisioni del proprietario del 2026-11-09 che le risolvono (Livello assoluto, soglia del 90%, Sherry senza stile, parole di dosaggio, Pauillac, Kabinett, millesimato, coerenza delle qualifiche, botritizzati legacy, transazione della migrazione, tracciabilità dei test).

Le regole valgono per tutto l'intent (scope `refactor`, nessun Unit). Le tabelle complete generate dalle regole BR2 sono in `profile-map.md` / `profile-map.json`; il campione che misura BR3 e BR4 è in `classification-sample.md` / `classification-sample.json`.

```yaml
rules:
  # ------------------------------------------------------------------
  # BR1 — Profili (FR1.1, FR1.3, NFR6)
  # ------------------------------------------------------------------
  - id: BR1.1
    statement: "La stima conosce 24 profili, valori costanti nel pacchetto estimation. Ogni profilo ha decorrenza (vintage, bottling, disgorgement o nessuna), unità (years, months o nessuna) e inizio/picco/fine; '—' dello studio diventa null."
    category: constraint
    applies_to: "StyleProfile (entities.md ENT-101)"
    trigger: "ogni stima"
    logic: "Tabella: R_FRESH vintage years 0/1/3; R_MEDIUM vintage years 2/4/8; R_AGE vintage years 4/8/15; R_LONG vintage years 8/15/30; W_FRESH vintage years 0/1/3; W_MEDIUM vintage years 1/3/6; W_AGE vintage years 3/7/15; ROSE_FRESH vintage years 0/1/2; SP_TANK bottling months 0/6/18; LAM_FRESH bottling months 0/6/24; SP_CLASSIC disgorgement months 0/12/36; SP_CLASSIC_AGE disgorgement months 12/36/72; SW_AROMATIC vintage years 0/1/2; SW_PASSITO vintage years 3/8/20; SW_BOTRYTIS vintage years 5/15/30; PORT_VINTAGE vintage years 15/30/60; PORT_LBV bottling months 0/null/null; PORT_OX bottling months 0/null/null; SH_FINO bottling months 0/null/12; SH_AMONT bottling months 0/null/18; SH_OLOROSO bottling months 0/null/24; SH_PX bottling months 0/null/24; FORT_UNKNOWN none none null/null/null; UNKNOWN none none null/null/null."
    violation: "Un valore diverso dalla tabella fa fallire il test per profilo (NFR4.2)."
    source: "FR1.1, NFR6"
    rationale: "Sono i numeri del foglio 'Profili candidati', copiati senza ritocchi: il proprietario ha chiesto di applicare lo studio."
  - id: BR1.2
    statement: "Un picco o una fine null non si inventano mai: nessuna durata infinita, nessun valore di ripiego dentro il profilo."
    category: constraint
    applies_to: "StyleProfile, DrinkingWindow"
    trigger: "costruzione di una finestra da un profilo"
    logic: "IF il profilo ha peak null THEN la finestra ha peak null; IF ha end null THEN la finestra ha end null; lo stato e la visualizzazione seguono BR6.4 e BR6.5."
    violation: "Una finestra con un valore inventato è un errore di programma (test)."
    source: "FR1.3"
    rationale: "Lo studio dichiara '— = non stimato, mai durata infinita'."
  - id: BR1.3
    statement: "Ogni profilo porta nel commento della tabella le fonti dello studio e la natura dell'evidenza (stima_editoriale, legacy_non_validato, solo_prontezza, limite_editoriale_da_fascia, dati_insufficienti)."
    category: policy
    applies_to: "tabella dei profili"
    trigger: "scrittura della tabella in Code Generation"
    logic: "R_FRESH E1; R_MEDIUM E1; R_AGE E1,E3; R_LONG R0,E1; W_FRESH E1; W_MEDIUM E1; W_AGE E1,S10; ROSE_FRESH R0,E1; SP_TANK E1; LAM_FRESH S2,S3; SP_CLASSIC S6,S7; SP_CLASSIC_AGE S6,S7; SW_AROMATIC E1; SW_PASSITO E1; SW_BOTRYTIS E1,S11; PORT_VINTAGE R0,S8; PORT_LBV S8; PORT_OX S8; SH_* S9; FORT_UNKNOWN E1; UNKNOWN E1."
    violation: "Revisione di Code Generation."
    source: "NFR6"
    rationale: "Lo studio è una bozza editoriale non validata: chi legge il codice deve sapere quanto vale ogni numero."
  - id: BR1.4
    statement: "Lo Stile salvato è una chiave stabile (WineStyle) che punta a un profilo; due chiavi possono puntare allo stesso profilo (madeira e fortifiedOther → FORT_UNKNOWN)."
    category: constraint
    applies_to: "Wine.style"
    trigger: "salvataggio e lettura dello stile"
    logic: "redFresh→R_FRESH, redMedium→R_MEDIUM, redAge→R_AGE, redLong→R_LONG, whiteFresh→W_FRESH, whiteMedium→W_MEDIUM, whiteAge→W_AGE, roseFresh→ROSE_FRESH, tankFresh→SP_TANK, lambrusco→LAM_FRESH, classicFresh→SP_CLASSIC, classicAge→SP_CLASSIC_AGE, sweetAromatic→SW_AROMATIC, sweetPassito→SW_PASSITO, sweetBotrytis→SW_BOTRYTIS, portVintage→PORT_VINTAGE, portLbv→PORT_LBV, portTawny→PORT_OX, sherryFino→SH_FINO, sherryAmontillado→SH_AMONT, sherryOloroso→SH_OLOROSO, sherryPx→SH_PX, madeira→FORT_UNKNOWN, fortifiedOther→FORT_UNKNOWN. UNKNOWN non è mai uno stile salvato."
    violation: "Una chiave sconosciuta letta da Firestore vale 'nessuno stile' (NFR2.1); le regole la rifiutano in scrittura (BR10.2)."
    source: "FR3.2, interaction-spec (Madeira)"
    rationale: "Il chip Madeira deve restare selezionato dopo il salvataggio anche se il profilo è lo stesso di 'Altro'."

  # ------------------------------------------------------------------
  # BR2 — Precedenza: profilo e finestra di ogni combinazione (FR1)
  # ------------------------------------------------------------------
  - id: BR2.1
    statement: "Il profilo e la finestra di una combinazione (denominazione, tipo, qualifica) si decidono con il primo passo che si applica, dopo le correzioni di tipo."
    category: calculation
    applies_to: "resolveStyle nel pacchetto estimation; ogni riga di profile-map.json"
    trigger: "ogni stima interna"
    logic: "0) Correzioni di tipo (BR2.12, BR2.4, BR2.6, BR2.9). IF la riga corretta non fa il tipo scelto THEN la denominazione si salta e vale la stima per tipo (BR2.12). 1) Categoria con numeri propri: tipo sparklingClassic o sparklingTank, Lambrusco, dolce, Porto, Sherry, Prädikat dolci → profilo di categoria (BR2.3–BR2.8), finestra = numeri del profilo; fanno eccezione i botritizzati con riga dedicata legacy (BR2.5) e lo Sherry senza parola di stile (BR2.8), che tengono la finestra di oggi (passo 2). Dopo i passi, controllo su tutta la mappa: nessuna qualifica sotto la sua base (BR2.2). 2) Riga dedicata con azione 'Conservare valore legacy' o proposta 'legacy invariato' (BR2.13) → finestra di oggi in anni dall'annata (offset della qualifica compresi, salvo BR2.10); il profilo dà solo lo stile mostrato (BR2.2). 3) Profilo dello studio coerente con tipo e qualifica → numeri del profilo. 4) Profilo in contraddizione → profilo corretto (BR2.2 per i fermi, BR2.11 per le righe generate, BR2.12 per i tipi sbagliati), numeri del profilo corretto, voce in 'Scarti dalla mappa dello studio'. Le righe con profilo finale UNKNOWN o FORT_UNKNOWN seguono BR2.14 e BR5.4."
    violation: "Il test per combinazione (NFR4.2) confronta profilo, decorrenza, unità, valori e passo con profile-map.json."
    source: "FR1.2, FR1.5"
    rationale: "È il Principio approvato di FR1, reso deterministico: ogni passo ha un criterio verificabile e un esito unico."
  - id: BR2.2
    statement: "Stile dei vini fermi (rossi, bianchi, rosati): è il profilo della famiglia del tipo più vicino ai valori della riga, alzato dalle soglie delle qualifiche e mai sotto lo stile della base della stessa denominazione."
    category: calculation
    applies_to: "combinazioni di tipo redLight, redStructured, white, rose ai passi 2 e 4"
    trigger: "profilo dello studio 'di ripiego per tipo' (ambito 'Fallback condizionale; stile da confermare') o in contraddizione"
    logic: "Famiglie: rosso = R_FRESH, R_MEDIUM, R_AGE, R_LONG; bianco = W_FRESH, W_MEDIUM, W_AGE; rosato = ROSE_FRESH. Distanza = |Δinizio|+|Δpicco|+|Δfine| dai valori di oggi; a parità vince il profilo più breve. Soglie: bianco con Riserva, Reserva, Gran Reserva, Gran Selezione, Grand Cru, Premier Cru o Spätlese → almeno W_AGE; bianco Kabinett → W_MEDIUM (BR2.6); rosso con Riserva, Reserva, Gran Reserva, Gran Selezione, Grand Cru, Premier Cru → almeno R_AGE; rosso Crianza → almeno R_MEDIUM; Superiore → nessuna soglia. Un profilo dello studio 'Solo ipotesi da revisione' (Revisione 60) si tiene se è della famiglia giusta e rispetta le soglie. Controllo su tutta la mappa: la finestra di una qualifica non è mai più corta di quella della base dello stesso tipo e unità; ogni valore più basso si rialza a quello della base (oggi: Napa Reserva fine 15 → 18; Ribera del Duero Crianza picco 6 → 7, fine 12 → 15)."
    violation: "Scarto con codice LABEL_NEAREST, QUALIFIER_FLOOR, CONTRADICTION o QUALIFIER_BELOW_BASE in profile-map; lo script della mappa fallisce se dopo la correzione resta una qualifica sotto la base."
    source: "FR1, passi 2 e 4; FR1.5"
    rationale: "Decisione enologica. Lo studio ha messo R_FRESH su tutti i redLight, W_FRESH su tutti i bianchi e R_AGE su tutti i redStructured, dichiarandolo 'stile da confermare'. Lo stile mostrato deve descrivere la finestra che l'utente vede: un Rosso di Montalcino 2/4/8 è 'Medio', non 'Fresco'; una Riserva non è mai più breve della sua base (Barolo Riserva = R_LONG come il Barolo)."
  - id: BR2.3
    statement: "Spumanti: metodo classico SP_CLASSIC dalla sboccatura; con Riserva, Gran Reserva o millesimo SP_CLASSIC_AGE; Charmat SP_TANK dall'imbottigliamento."
    category: calculation
    applies_to: "tipo sparklingClassic e sparklingTank: Champagne, Franciacorta, Trento, Alta Langa, Oltrepò Metodo Classico, Cava, ogni Crémant, Prosecco, Asolo Prosecco, Conegliano Valdobbiadene, Clairette de Die, Sekt"
    trigger: "passo 1"
    logic: "IF tipo sparklingClassic AND (qualifica in {riserva, granReserva, vintage} OR parola 'millesimato/millésimé/vintage' nel nome OR campo annata valorizzato) THEN SP_CLASSIC_AGE ELSE SP_CLASSIC. Un metodo classico con annata è un millesimato: l'annata nel campo basta (decisione del proprietario, R-07). Nella mappa le combinazioni di metodo classico si provano senza annata (non millesimati) e il caso con annata ha un test a parte. IF tipo sparklingTank AND non Lambrusco THEN SP_TANK; Superiore non aggiunge nulla (Prosecco Superiore = SP_TANK). La Tipologia resta quella del metodo: Prosecco e ogni Charmat restano sparklingTank; Champagne, Franciacorta, Trento, Cava, Crémant restano sparklingClassic."
    violation: "Scarto SPARKLING_AGE quando lo studio indicava SP_CLASSIC."
    source: "FR1, passo 1; FR2.3; FR3.3"
    rationale: "Decisione enologica. Franciacorta Riserva (≥60 mesi sui lieviti), Trento e Alta Langa Riserva (≥36), Cava Gran Reserva (≥30) e Champagne millesimato (≥36) sono cuvée con attitudine documentata all'evoluzione (S6, S7: millesimati 5–10 anni). Lo studio dice di non dare ai Cava i numeri dello Champagne come dato validato: SP_CLASSIC è una stima di stile, non della denominazione, e resta tale."
  - id: BR2.4
    statement: "Lambrusco: Tipologia sparklingTank (Charmat), stile lambrusco, profilo LAM_FRESH dall'imbottigliamento; un Lambrusco metodo classico è SP_CLASSIC."
    category: calculation
    applies_to: "riga lambrusco e righe generate Reggiano e Modena (BR2.12)"
    trigger: "passo 1"
    logic: "IF denominazione Lambrusco (o nome con 'lambrusco') AND nessuna parola di metodo classico THEN tipo sparklingTank, LAM_FRESH. IF 'metodo classico/rifermentato in bottiglia/ancestrale' nel nome THEN tipo sparklingClassic, SP_CLASSIC."
    violation: "Tipo corretto segnato in profile-map (TYPE_FIX)."
    source: "FR1 passo 1; FR2.3; interaction-spec (chip Charmat → Lambrusco)"
    rationale: "Il Lambrusco è un rosso frizzante Charmat bevuto giovane (S2, S3); lo studio chiede il profilo distinto per il metodo classico (S4)."
  - id: BR2.5
    statement: "Dolci: ogni denominazione dolce ha uno dei tre profili SW_AROMATIC, SW_PASSITO, SW_BOTRYTIS, secondo come si concentra lo zucchero."
    category: calculation
    applies_to: "righe di tipo sweet (dedicate e corrette)"
    trigger: "passo 1"
    logic: "SW_AROMATIC (giovani aromatici, VDN di Muscat): Asti, Brachetto d'Acqui, Canelli, Malvasia di Castelnuovo Don Bosco, Sangue di Giuda, Colli Euganei Fior d'Arancio, Cannellino di Frascati, Muscat de Beaumes-de-Venise, Muscat de Rivesaltes, Samos, Kindzmarauli, Khvanchkara, i Muscat VDN generati (Frontignan, Lunel, Mireval, Saint-Jean-de-Minervois, Cap Corse), Malvasia di Casorzo, Moscato di Sardegna. SW_PASSITO (appassimento, vendemmia tardiva, ghiaccio; niente muffa nobile): Recioto della Valpolicella, di Soave, di Gambellara, Passito di Pantelleria, Vin Santo (anche Riserva), Loazzolo, Caluso Passito, Moscato di Scanzo, Torcolato, Picolit, Ramandolo, Albana passito, Aleatico (Elba, Gradoli, Puglia), Primitivo di Manduria Dolce Naturale, Greco di Bianco, Malvasia delle Lipari, Sciacchetrà, Alsace Vendanges Tardives, Jurançon dolce, Málaga, Icewine del Niagara, Vin de Constance, Moscato di Trani, Moscato di Sorso, Malvasie greche DOP, Commandaria. SW_BOTRYTIS (muffa nobile): Sauternes, Barsac, Loupiac, Sainte-Croix-du-Mont, Cérons, Cadillac, Monbazillac, Vouvray e Montlouis dolci, Coteaux du Layon, Quarts de Chaume, Bonnezeaux, Coteaux de l'Aubance, Alsace SGN, Neusiedlersee dolce, Ruster Ausbruch, Tokaji. Un dolce senza denominazione: stile da confermare, stima indicativa con i valori di oggi del tipo dolce 2/8/20 (BR2.14). Eccezione: un botritizzato con riga dedicata e azione legacy (o 'legacy invariato') conserva la finestra di oggi (passo 2) e il profilo SW_BOTRYTIS dà solo lo stile: Sauternes, Barsac, Tokaji, Quarts de Chaume, Ruster Ausbruch restano 5/15/40, Bonnezeaux 5/15/35, Coteaux du Layon 3/10/25 e così via."
    violation: "Una riga dolce senza decisione fa fallire lo script della mappa e il test."
    source: "FR1 passo 1; FR1.4"
    rationale: "Decisione enologica. 'Zucchero non significa lunga guardia' (studio): un Moscato d'Asti non è un Sauternes. Il profilo passito copre ogni concentrazione senza botrite, ghiaccio compreso. Per i grandi botritizzati la fine di oggi è più credibile dei 30 anni del profilo, che lo studio chiama 'candidato prudente, non soglia universale per Sauternes o TBA': qui vince il passo 2 (decisione del proprietario, R-09)."
  - id: BR2.6
    statement: "Prädikat tedeschi e austriaci: Kabinett e Spätlese restano bianchi; Auslese, Beerenauslese (BA), Trockenbeerenauslese (TBA) ed Eiswein sono dolci con profilo proprio."
    category: calculation
    applies_to: "qualifiche kabinett, spatlese, auslese e le nuove beerenauslese, trockenbeerenauslese, eiswein"
    trigger: "qualifica trovata nel nome o nella denominazione"
    logic: "Kabinett → white, stile W_MEDIUM. Spätlese → white, stile W_AGE. Per Kabinett e Spätlese la finestra è quella di oggi della riga (passo 2), anche per Mosel e Rheingau: così il Kabinett non parte mai prima della base (Mosel base 2, Kabinett 2/6/15) e la Spätlese resta sopra il Kabinett (3/8/20). Auslese → sweet, SW_BOTRYTIS 5/15/30. BA e TBA → sweet, SW_BOTRYTIS, mai riportate ad Auslese. Eiswein/Icewine → sweet, SW_PASSITO. IF 'trocken' accanto ad Auslese THEN white, W_AGE. Lo script della mappa verifica per ogni zona: inizio del Kabinett ≥ inizio della base; Spätlese > Kabinett."
    violation: "Scarti PRADIKAT e PRADIKAT_STILL in profile-map; lo script fallisce se l'ordine Kabinett/Spätlese non regge."
    source: "FR1.5; FR1 passo 4 (esempio 'Kabinett → W_MEDIUM'); S11"
    rationale: "Decisione del proprietario (R-06): Kabinett W_MEDIUM come nell'esempio approvato di FR1. I valori di oggi restano perché descrivono bene i Riesling della Mosella e tengono l'ordine fra base, Kabinett e Spätlese. Lo studio chiede che BA, TBA ed Eiswein non diventino Auslese (oggi le frasi BA e TBA danno auslese)."
  - id: BR2.7
    statement: "Porto: Vintage → PORT_VINTAGE dall'annata; LBV e Ruby → PORT_LBV dall'imbottigliamento; Tawny, Tawny con età, Colheita e Porto senza categoria → PORT_OX dall'imbottigliamento."
    category: calculation
    applies_to: "denominazione porto e parole del nome"
    trigger: "passo 1"
    logic: "IF qualifica vintage (solo con denominazione Porto) THEN PORT_VINTAGE 15/30/60 anni. IF lbv OR parola 'ruby' THEN PORT_LBV 0/—/— mesi. IF colheita OR parola 'tawny' (anche '10/20/30/40 anni') OR nessuna categoria THEN PORT_OX 0/—/— mesi. 'White Port' e 'Rosé Port' → PORT_LBV (pronti, da bere giovani)."
    violation: "Scarti PORT_CATEGORY quando lo studio dava FORT_UNKNOWN."
    source: "FR1 passo 1 e 4 (esempi Porto Vintage, LBV, Tawny/Colheita)"
    rationale: "Decisione enologica. S8 distingue le categorie: solo il Vintage evolve in bottiglia; LBV, Ruby e Tawny sono pronti all'imbottigliamento e la loro fine non è nota, quindi 'nessuna fine stimata'. Senza categoria lo studio propone PORT_OX: per tutti i non Vintage la finestra è la stessa (0/—/—), cambia solo il nome mostrato."
  - id: BR2.8
    statement: "Sherry e Montilla-Moriles: con una parola di stile Fino e Manzanilla SH_FINO, Amontillado e Medium SH_AMONT, Oloroso e Cream SH_OLOROSO, Pedro Ximénez SH_PX; senza parola di stile 'Stile da confermare' con stima indicativa dai valori di oggi della riga, mai un Fino silenzioso."
    category: calculation
    applies_to: "denominazioni jerez (Jerez-Xérès-Sherry, Manzanilla-Sanlúcar) e montillaMoriles; parole del nome"
    trigger: "passo 1 con parola di stile; passo 2 senza"
    logic: "Parole: fino, manzanilla, pale cream → SH_FINO; amontillado, medium → SH_AMONT; oloroso, cream, palo cortado → SH_OLOROSO; pedro ximenez, px → SH_PX; decorrenza imbottigliamento, mesi, picco null. Nessuna parola → profilo FORT_UNKNOWN, stima indicativa in anni con i valori di oggi della riga (Jerez 0/1/3, Montilla-Moriles 0/2/5), confidence low, avviso 'Stile da confermare', nessuno stile preselezionato; scelto lo stile dall'utente vale il suo profilo (BR2.15)."
    violation: "Scarto SHERRY_NO_STYLE in profile-map."
    source: "FR1 passo 1; FR1.3; FR1.4"
    rationale: "Decisione del proprietario (R-03). Senza la parola di stile uno Sherry può essere un Fino (12 mesi) o un Oloroso, un Amontillado, un PX che durano anni: un Fino scelto in silenzio farebbe dire 'Finestra passata' dopo 13 mesi a vini che durano decenni. Montilla-Moriles produce le stesse categorie di Jerez e segue la stessa regola. Palo Cortado sta con l'Oloroso perché ha la stessa fascia ossidativa."
  - id: BR2.9
    statement: "Madeira e liquorosi non distinti: profilo FORT_UNKNOWN; vin doux naturel di Grenache, vin de liqueur e moscati mutizzati ossidativi sono liquorosi."
    category: calculation
    applies_to: "madeira, marsala, vernacciaDiOristano, banyuls, maury, rivesaltes, grandRoussillon, condadoDeHuelva, carcavelos, mavrodaphneOfPatras e di Cefalonia, rutherglen, Pineau des Charentes, Floc de Gascogne, Macvin du Jura, Setúbal, Moscatel de Setúbal, Moscatel do Douro, Rasteau dolce, righe generate liquorose"
    trigger: "tipo fortified fuori da Porto e Sherry"
    logic: "Tipo corretto in fortified per Rasteau dolce, Moscatel de Setúbal, Moscatel do Douro, Setúbal, Pineau, Floc, Macvin, Grand Roussillon, Mavrodaphne di Cefalonia. Riga dedicata con azione legacy → passo 2: stima indicativa con i valori di oggi, affidabilità bassa, 'Stile da confermare'. Madeira (lo studio ritira 5/20/50), righe generate e tipo liquoroso senza denominazione → 'Da stimare' (finestra null) finché l'utente non sceglie uno stile; scelto 'Madeira' o 'Altro' vale BR2.15."
    violation: "Una stima con numeri per Madeira senza stile scelto è un errore (test)."
    source: "FR1.4"
    rationale: "Decisione enologica. Lo studio non dà numeri per questi stili e chiede di non inventarli; i valori di oggi delle righe dedicate restano visibili solo come indicazione, perché sono la sola informazione che l'app ha."
  - id: BR2.10
    statement: "Qualifiche sui bianchi fermi e altre qualifiche: Riserva bianca almeno W_AGE; Soave Superiore non aggiunge anni; il Grand Cru Classé conserva i suoi scarti in tutti i comuni di Bordeaux, Pauillac compreso; Crianza almeno R_MEDIUM."
    category: calculation
    applies_to: "varianti qualifier"
    trigger: "qualifica riconosciuta"
    logic: "Riserva, Reserva, Gran Reserva, Grand Cru, Premier Cru su un bianco → stile almeno W_AGE (Verdicchio, Fiano, Greco, Gavi, Lugana, Vernaccia Riserva; Chablis e Côte de Beaune Premier/Grand Cru; Alsace Grand Cru). Soave Superiore → finestra della base (QUALIFIER_DISABLED, azione dello studio). Pauillac Grand Cru → scarti di oggi 10/20/40 come Margaux, Saint-Julien, Saint-Estèphe e Pessac-Léognan (ACTION_OVERRIDDEN: l'azione dello studio sulla riga non si segue). Le altre Superiore conservano i loro scarti (passo 2) con lo stile più vicino. Una qualifica non si applica a un tipo diverso dal principale della riga (come oggi)."
    violation: "Scarti QUALIFIER_FLOOR, QUALIFIER_DISABLED, ACTION_OVERRIDDEN."
    source: "FR1.5; FR1 passo 4 (esempio Riserva bianca → W_AGE)"
    rationale: "Decisione enologica e del proprietario (R-05). Una Riserva bianca ha almeno 12–18 mesi di affinamento e struttura per evolvere. La classificazione del 1855 è la stessa in tutti i comuni del Médoc: togliere lo scarto solo a Pauillac darebbe a Latour, Lafite e Mouton una finestra più corta di un Margaux Grand Cru. La coerenza vince sull'azione della singola riga dello studio; lo scostamento è elencato in profile-map.md."
  - id: BR2.11
    statement: "Righe generate: la riga non conosce mai lo stile. Con i tipi di ripiego (redLight, white, rose) e nessun tipo scelto vale la stima generica 1/3/6 indicativa; con un tipo noto vale il profilo del tipo con 'Stile da confermare'."
    category: calculation
    applies_to: "1700 righe generate (1582 con i tipi di ripiego)"
    trigger: "denominazione generata riconosciuta"
    logic: "Profilo del tipo (BR5.6): redLight→R_FRESH, redStructured→R_MEDIUM, white→W_MEDIUM, rose→ROSE_FRESH, sparklingClassic→SP_CLASSIC, sparklingTank→SP_TANK, sweet→UNKNOWN (indicativa 2/8/20), fortified→FORT_UNKNOWN (Da stimare). IF tipi = ripiego AND nessun tipo scelto THEN UNKNOWN, 1/3/6 anni dall'annata, indicativa. IF tipo scelto o tipo reale della riga THEN profilo del tipo, 'Stile da confermare' per rossi e bianchi (più stili possibili); rosato e spumanti senza avviso (un solo stile o stile di default dello studio)."
    violation: "Scarti FAKE_TYPE e GENERATED_STYLE."
    source: "FR1.4, FR1.6"
    rationale: "Lo studio scrive 'fallback solo se stile noto' su tutte le righe generate: un R_FRESH applicato a una zona che fa soprattutto bianchi era un dato inventato (FR1.6). Il bianco senza stile va a W_MEDIUM come dice FR1.4; il rosso strutturato a R_MEDIUM perché lo studio vieta R_AGE per tutto il tipo."
  - id: BR2.12
    statement: "Tipi sbagliati: i tipi di alcune denominazioni si correggono; se la riga corretta non fa il tipo scelto, la stima salta la denominazione."
    category: calculation
    applies_to: "righe elencate"
    trigger: "costruzione della tabella delle denominazioni"
    logic: "Castelli di Jesi Verdicchio Riserva → white, W_AGE, con la stessa finestra della combinazione dedicata verdicchioDeiCastelliDiJesi:qualifier:riserva (3/6/12 anni): un solo valore per lo stesso vino. Cabernet de Saumur → rose, ROSE_FRESH. Coulée de Serrant → white, W_AGE. Cour-Cheverny → white, W_MEDIUM. Arabako e Bizkaiko Txakolina → white (principale), rose, redLight; W_FRESH. Retsina (15 righe) → white, rose; W_FRESH. Picpoul de Pinet → white, W_FRESH. Roussette de Savoie e du Bugey → white, W_MEDIUM. Clairette du Languedoc e de Bellegarde → white, W_MEDIUM da confermare. Cortese dell'Alto Monferrato, Ortrugo → white, W_MEDIUM da confermare. Pinot nero dell'Oltrepò Pavese → redLight, R_FRESH da confermare. Moscato di Trani → sweet, SW_PASSITO. Reggiano, Modena → sparklingTank, LAM_FRESH. Commandaria (Koumandaria) → sweet, SW_PASSITO, con l'alias 'commandaria'. Altri dolci e liquorosi: BR2.5, BR2.9. Madeirense resta multi-tipo (non è il Madeira). IF tipo scelto non tra i tipi della riga corretta THEN denominazione saltata, vale il profilo del tipo (basis wineType)."
    violation: "Scarti TYPE_FIX e TYPE_NOT_MADE; elenco 'Correzioni di tipo' in profile-map.md."
    source: "FR1.6; FR1 passo 4"
    rationale: "Decisione enologica, sostenuta da S19 (Verdicchio bianco) e S20 (Cabernet de Saumur rosato) e dai disciplinari: Coulée de Serrant è uno Chenin secco di lunga vita, il Txakoli è quasi tutto bianco fresco, la Retsina è per legge un bianco resinato."
  - id: BR2.13
    statement: "Righe della Revisione 60: si segue la proposta numerica della riga."
    category: calculation
    applies_to: "30 denominazioni dedicate e 30 generate della Revisione 60"
    trigger: "costruzione della mappa"
    logic: "'legacy invariato' (Barolo, Barbaresco, Brunello, Chianti Classico, Soave, Chablis, Pauillac, Vinho Verde, Sauternes) → passo 2 per tutte le varianti della chiave. 'candidato condizionale' con numeri (Muscadet W_FRESH, Rioja R_MEDIUM, Barossa R_AGE, spumanti, Lambrusco, Canelli, Castelli di Jesi, Cabernet de Saumur, Crémant de Die) → passo 3 con i numeri del profilo. '—/—/—' (Bordeaux, Mosel, Rheingau, Wachau, Kamptal, Napa, Hunter Valley, Marlborough) → UNKNOWN sulla base con i valori di oggi come stima indicativa; le altre varianti della chiave usano BR2.2 con 'Stile da confermare', salvo Bordeaux bianco e rosato che restano legacy come chiede lo studio."
    violation: "Test di NFR4.2 sulle 60 righe."
    source: "FR1.2, FR1.4, NFR4.2"
    rationale: "La Revisione 60 è la parte dello studio rivista riga per riga: dove propone un numero o un 'legacy invariato' lo applico senza reinterpretarlo."
  - id: BR2.14
    statement: "Stile non chiaro (UNKNOWN, FORT_UNKNOWN): la stima è indicativa con affidabilità bassa e avviso, o 'Da stimare'."
    category: calculation
    applies_to: "profilo finale UNKNOWN o FORT_UNKNOWN"
    trigger: "risoluzione dello stile"
    logic: "UNKNOWN su riga dedicata → valori di oggi della riga (Bordeaux 2/5/10, Napa 4/8/18). UNKNOWN su riga generata o vino senza denominazione → profilo del tipo se il tipo è noto (BR2.11), altrimenti generica 1/3/6. Tipo dolce senza stile → 2/8/20 indicativa. FORT_UNKNOWN → BR2.9. Mai il ripiego 'rosso leggero'. Confidence low, flag indicative = true."
    violation: "Test della mappa (estimate = indicative/none)."
    source: "FR1.4"
    rationale: "È la scelta del proprietario (Q1 = B): una stima indicativa e dichiarata vale più di nessuna stima, tranne dove lo studio ritira i numeri."
  - id: BR2.15
    statement: "Stile scelto dall'utente: vale il profilo di quello stile, con i suoi numeri, decorrenza e unità; per UNKNOWN e FORT_UNKNOWN restano i valori indicativi."
    category: calculation
    applies_to: "Wine.style con styleSource = user"
    trigger: "stima di un vino con stile scelto"
    logic: "IF styleSource = user THEN profilo = profilo dello stile; finestra = numeri del profilo (anche quando la denominazione avrebbe dato una finestra legacy). IF stile madeira o fortifiedOther THEN stima indicativa: valori di oggi della riga dedicata se c'è (Madeira 5/20/50, Marsala 3/10/30), altrimenti valori di oggi del tipo liquoroso 3/10/30; 'Stile da confermare' resta. Le qualifiche non cambiano la finestra di uno stile scelto, tranne la soglia di BR2.10 che riguarda solo la proposta."
    violation: "Test di stima con stile scelto."
    source: "FR1.4 ('Appena l'utente sceglie lo stile, vale il profilo scelto'); interaction-spec (Madeira)"
    rationale: "Scegliere lo stile è l'informazione più forte che l'app possa avere; per Madeira l'interaction-spec chiede di togliere 'Da stimare' senza inventare numeri."
  - id: BR2.16
    statement: "Parole di stile nel nome valgono come la qualifica: decidono il profilo dentro la categoria."
    category: calculation
    applies_to: "nome, denominazione scritta, testo dell'etichetta"
    trigger: "risoluzione dello stile"
    logic: "Porto: vintage, lbv, late bottled vintage, ruby, tawny, colheita, white port (BR2.7). Sherry: BR2.8. Spumanti: millesimato, millésimé, vintage, riserva, gran reserva (BR2.3); metodo classico/méthode traditionnelle con Lambrusco (BR2.4). Dolci: passito, appassimento, vendemmia tardiva, vendange tardive, late harvest, spätlese edelsüß → SW_PASSITO; sélection de grains nobles, botrytis, muffa nobile, aszú, ausbruch, beerenauslese, trockenbeerenauslese → SW_BOTRYTIS; eiswein, icewine, vin de glace → SW_PASSITO; moscato d'asti, moscatel, muscat (senza 'sec') senza altre parole → SW_AROMATIC. Riconoscimento a parole intere sul testo normalizzato, come qualifierMaskOf."
    violation: "Test della risoluzione con parole di stile."
    source: "FR1.5; FR2.3 (qualifica prima di tutto)"
    rationale: "Sono le parole con cui le etichette dichiarano la categoria; le BA e TBA oggi finiscono in Auslese e lo studio chiede di separarle."
  - id: BR2.17
    statement: "Il risultato della mappa è profile-map.json; estimationTablesVersion passa da 2 a 3."
    category: policy
    applies_to: "tabelle del pacchetto estimation"
    trigger: "Code Generation"
    logic: "Il test di NFR4.2 legge profile-map.json (fixture) e, per ogni combinazione, chiama la stima con gli input della 'inputConvention' e confronta tipo, profilo, passo, esito, decorrenza, unità e valori. Alzare la versione fa partire la migrazione (BR7.4)."
    violation: "Il test fallisce."
    source: "FR1.2, NFR4.2"
    rationale: "La mappa generata è l'unica specifica dei 5946 casi; il test la rende vincolante."

  # ------------------------------------------------------------------
  # BR3 — Tipologia preselezionata (FR2.1–FR2.3)
  # ------------------------------------------------------------------
  - id: BR3.1
    statement: "La Tipologia si preseleziona con la precedenza di FR2.3: qualifica > profilo della denominazione > parole del nome > vitigno > tipo della base."
    category: calculation
    applies_to: "classifyWine (pacchetto estimation), usato dal tool della base, dal modulo e dalla migrazione"
    trigger: "nuovo vino dalla base, dal testo o scritto a mano; migrazione"
    logic: "1) Qualifica che decide la categoria (Auslese, BA, TBA, Eiswein → dolce; Vintage, LBV, Colheita con Porto → liquoroso). 2) Denominazione riconosciuta (nel nome con le parole del nome della denominazione escluse dalla ricerca del vitigno, poi nel campo denominazione, poi nel produttore): un solo tipo → quello; più tipi → il selettore di BR3.3; tipi di ripiego → nessun tipo dalla denominazione; colore o vitigno che la riga non fa → la riga si salta (BR2.12). 3) Parole del nome (BR3.2): parole di metodo e di categoria, poi colore; decidono il tipo solo se nessuna denominazione o profilo è noto. 4) Vitigno nel nome (BR3.6). 5) Tipo della base (campo t). 6) Regola Château (BR3.7). 7) Nulla: Tipologia vuota."
    violation: "Le soglie di FR2.1 sul campione falliscono."
    source: "FR2.1, FR2.2, FR2.3"
    rationale: "È la precedenza approvata di FR2.3 (revisione R-04, decisione del proprietario): una parola del nome non batte mai una denominazione."
  - id: BR3.2
    statement: "Parole di Tipologia per lingua, a parole intere sul testo normalizzato."
    category: calculation
    applies_to: "nome e testo dell'etichetta"
    trigger: "BR3.1 passi 1 e 3"
    logic: "Liquoroso: porto, port, sherry, jerez, xeres, marsala, madeira, liquoroso, fortified, vin doux naturel, vdn, vin de liqueur, pineau, generoso, vinho generoso, likörwein, fino, manzanilla, amontillado, oloroso, pedro ximenez, tawny, ruby. Dolce (categoria): passito, liquoreux, edelsüß, dessert, vendange tardive, late harvest, eiswein, icewine, recioto, vin santo, tokaji aszu, commandaria. Parole di dosaggio (dolce, doux escluso 'vin doux naturel', sweet, dulce, demi-sec, demi sec, amabile, abboccato, lieblich, süß, suss, moelleux, medium dry, semi seco): danno 'dolce' solo se non c'è nessuna denominazione, nessun profilo, nessuna parola di metodo (spumante, metodo classico, Charmat, Lambrusco, frizzante, sekt) e nessuna parola di colore; non cambiano mai un profilo spumante o Lambrusco (Lambrusco dell'Emilia Dolce resta sparklingTank LAM_FRESH, Crémant d'Alsace Doux resta sparklingClassic, Prosecco Dolce resta sparklingTank, Dornfelder Rosé lieblich resta rosato). Metodo classico: champagne, cremant, crémant, cava, franciacorta, trento doc, alta langa, metodo classico, methode traditionnelle, méthode champenoise, traditional method, espumante natural, sekt b.a. con 'flaschengärung'. Charmat: prosecco, spumante, frizzante, sekt, mousseux, petillant, espumoso, asti spumante (va al dolce, BR2.5), lambrusco. Rosato: rosato, rosé, rose, rosado, roze, vin gris, gris de gris, clairet, blush, cerasuolo d'abruzzo, weissherbst ('rosa' non è una parola di tipo: colpirebbe marchi come 'Rosa dei Venti'). Le parole di colore si cercano nel nome e, se il nome non ne ha, nel produttore (nella base i due campi sono a volte scambiati). Bianco: bianco, blanc, blanco, branco, white, weiss, weißwein, wit, blanca. Rosso: rosso, rouge, red, tinto, tinta, rot, rotwein, vermelho, rood, negre. 'pinot gris', 'pinot grigio', 'grauburgunder' sono vitigni bianchi, non rosato."
    violation: "Errori di Tipologia nel campione; test con i quattro casi di dosaggio sopra e 'Rosa dei Venti' (nessuna Tipologia dal nome)."
    source: "FR2.1, FR2.3"
    rationale: "Copre le lingue della base (fr, it, es, de, en, pt, nl) e unifica le tre liste di oggi, diverse fra loro (codekb, 'Duplicazioni'). Le parole di dosaggio dicono quanto zucchero ha uno spumante o un Lambrusco, non che è un vino da dessert (decisione del proprietario, R-04)."
  - id: BR3.3
    statement: "Denominazione con più tipi: il tipo lo sceglie la parola di colore, poi il vitigno, poi il tipo della base, solo fra i tipi della riga; altrimenti il tipo principale."
    category: calculation
    applies_to: "righe dedicate multi-tipo (Bordeaux, Pessac-Léognan, Côtes du Rhône, Napa, Mendoza...)"
    trigger: "BR3.1 passo 2"
    logic: "IF parola di colore e la riga fa quel colore THEN quel tipo; ELSE IF vitigno con tipo della riga THEN quel tipo; ELSE IF tipo della base fra quelli della riga THEN quello; ELSE tipo principale."
    violation: "Errori nel campione (es. Pessac-Léognan bianco, n. 55)."
    source: "FR2.3"
    rationale: "Il tipo principale di una zona larga è giusto in media, ma ogni indizio specifico del vino vale di più."
  - id: BR3.4
    statement: "Rosso leggero o strutturato: decide la riga o il vitigno; uno stile R_AGE o R_LONG rende il rosso strutturato; il vino generico da tavola è leggero."
    category: calculation
    applies_to: "Tipologia rossa"
    trigger: "Tipologia rossa decisa"
    logic: "IF denominazione → tipo della riga; IF stile risolto R_AGE o R_LONG → redStructured (Pécharmant, Chianti Riserva). IF qualifica Riserva/Reserva/Gran Reserva/Crianza/Grand Cru → redStructured. IF parole nouveau, primeur, novello, joven → redLight. IF vino generico (BR3.8) o IGP/IGT senza vitigno → redLight. IF vitigno → tipo del vitigno. ELSE tipo della base se rosso, altrimenti redLight."
    violation: "Errori nel campione."
    source: "FR2.3"
    rationale: "Toglie i default opposti di oggi (redStructured nella base, redLight nel generatore e nell'etichetta) con un criterio unico legato allo stile."
  - id: BR3.5
    statement: "Il catalogo non riduce più gli 8 tipi a 5 famiglie: il tipo arriva nel modulo com'è."
    category: constraint
    applies_to: "WineDbRecord.toCandidate, InternalCatalog, wineFamilyOf, catalogTypeOf"
    trigger: "proposta di un vino dal catalogo"
    logic: "Il candidato porta WineType (8 valori). Prosecco e ogni Charmat restano sparklingTank; Porto, Sherry e Marsala restano fortified; Champagne, Franciacorta, Trento, Cava, Crémant restano sparklingClassic; un rosso leggero resta redLight. Le 5 famiglie restano solo per colori, icone e filtri (WineTypeFamily, TypeFilter, DashboardCalculator), con una sola funzione di mappatura."
    violation: "Test: Prosecco dalla base arriva nel modulo come sparklingTank, Porto come fortified, Champagne come sparklingClassic."
    source: "FR2.3 (criterio)"
    rationale: "Oggi un Prosecco arriva come metodo classico e un Porto come dolce (codekb); la riduzione serviva solo al catalogo esterno C1, che resta compatibile leggendo i valori C1 come oggi."
  - id: BR3.6
    statement: "Vitigni per la Tipologia: oltre ai 46 della tabella di stima, un elenco di vitigni con il solo colore."
    category: calculation
    applies_to: "BR3.1 passo 4"
    trigger: "vitigno trovato nel nome"
    logic: "Rossi in più: mondeuse, dornfelder, spätburgunder, trollinger, lemberger, bonarda, cannonau, carignan, cinsault, corvina, refosco, lagrein, teroldego, dolcetto, negroamaro, monastrell, bobal, garnacha tinta, mencía, tinta roriz, castelão, baga, agiorgitiko, saperavi, plavac mali, kadarka, gamaret, cornalin, humagne rouge. Bianchi in più: trebbiano, verdicchio, arneis, cortese, garganega, grillo, inzolia, fiano, greco, falanghina, friulano, ribolla, macabeo, viura, airén, picpoul, colombard, ugni blanc, melon de bourgogne, muscadet, savagnin, chasselas, fendant, petite arvine, müller-thurgau, silvaner, kerner, grauburgunder, weissburgunder, pinot blanc, pinot bianco, malvasia bianca, loureiro, encruzado, moschofilero, roditis. Moscato/Muscat/Moscatel → dolce (salvo 'sec', 'secco', 'dry', 'trocken' → bianco). Un vitigno senza tabella di stima dà solo la Tipologia; lo stile è quello del tipo, da confermare."
    violation: "Errori nel campione."
    source: "FR2.1 ('vitigni trovati nel nome')"
    rationale: "La base non ha il campo vitigno; il nome lo contiene spesso (codekb: cabernet, merlot, pinot fra le parole più frequenti dei vini senza tipo)."
  - id: BR3.7
    statement: "Château francese senza altro indizio: rosso strutturato, stile da confermare."
    category: calculation
    applies_to: "nome che inizia con 'château', 'chateau' o 'ch.' e paese FR o assente"
    trigger: "BR3.1 passo 6, solo se i passi 1–5 non hanno dato nulla"
    logic: "THEN Tipologia redStructured, stile redMedium (auto, da confermare), Livello good."
    violation: "Errori nel campione (n. 31, 34, 38, 40, 47)."
    source: "FR2.1 (soglia del 90%)"
    rationale: "Decisione enologica. Un 'Château X' senza colore è quasi sempre un rosso di Bordeaux (circa l'85% della produzione bordolese è rossa); riguarda 574 vini della base; con essa il prototipo misura 83,5% di vini con Tipologia (classification-sample.md). L'avviso 'Stile da confermare' dichiara l'incertezza."
  - id: BR3.8
    statement: "Vino generico da tavola: designazione 'vin/vino/wine/wein/vinho' con colore o tipo della base, senza denominazione, IGP o vitigno."
    category: calculation
    applies_to: "nome"
    trigger: "BR3.1 passo 3"
    logic: "IF il nome contiene solo parole generiche (vin, vino, wine, wein, vinho, colore, bio, biologique, formato, annata, marchio non riconosciuto dopo 'vin/vino') AND nessuna denominazione/AOP/IGP/vitigno THEN vino da tavola: rosso → redLight, R_FRESH; bianco → white, W_FRESH; rosato → rose; Livello everyday. Senza colore e senza tipo della base ('Vin', 'Wine', 'Vino'): nessun indizio."
    violation: "Errori nel campione (n. 2, 30, 32, 33, 41, 90)."
    source: "FR2.3 ('vini da tavola' → Quotidiano)"
    rationale: "Decisione enologica. 'Vin rouge', 'Vino rosso' senza denominazione sono vini da tavola semplici e da bere presto."
  - id: BR3.9
    statement: "Nessun indizio, o prodotto che non è vino: Tipologia vuota."
    category: validation
    applies_to: "classifyWine"
    trigger: "BR3.1 passo 7"
    logic: "IF nessun passo dà un tipo THEN Tipologia null, Stile null, Livello good, stima FR1.4 (generica indicativa). IF parole di non-vino (seltzer, cider, cidre, sidra, calvados, glühwein, gluhwein, sangria, spritz, vermouth, liqueur senza 'vin de', beer, bière, birra, cocktail, punch) THEN Tipologia null anche con un tipo della base, e il tool esclude il record (BR9.4)."
    violation: "Un vino atteso senza Tipologia a cui ne viene data una conta come errore nel campione."
    source: "FR2.1, FR2.3"
    rationale: "Meglio un campo vuoto che un tipo sbagliato (n. 100: un seltzer con tipo 'white' nella base)."

  # ------------------------------------------------------------------
  # BR4 — Livello (FR2.3)
  # ------------------------------------------------------------------
  - id: BR4.1
    statement: "Il Livello resta il moltiplicatore assoluto di oggi e vale solo per le finestre in anni con picco e fine: i numeri dei profili e le finestre conservate sono la finestra 'Buono'."
    category: calculation
    applies_to: "estimateWindow, WineLevel.apply"
    trigger: "stima con finestra in anni"
    logic: "good o null → numeri invariati. everyday → inizio ×0,5, picco ×0,6, fine ×0,6. aging → inizio ×1,25, picco ×1,3, fine ×1,4, ma NON moltiplica quando sono già usati gli scarti di una qualifica (nessun doppio conteggio, come oggi). Arrotondamento e ordine come WineLevel.apply (fine ≥ inizio + 1). Profili in mesi, con picco o fine null, stima 'Da stimare': il livello non cambia nulla."
    violation: "Test di WineLevel; test della mappa con level null."
    source: "FR2.3 ('il Livello resta un moltiplicatore come oggi')"
    rationale: "Decisione del proprietario (R-01): un Barolo con 'Buono' salvato resta 8/15/30 prima e dopo l'aggiornamento; il Livello significa quello che significa oggi."
  - id: BR4.2
    statement: "Il profilo descrive già il vino da invecchiamento: un profilo R_LONG, R_AGE, W_AGE, SW_BOTRYTIS o PORT_VINTAGE da solo non preseleziona 'Da invecchiamento'."
    category: policy
    applies_to: "classifyWine"
    trigger: "BR4.3"
    logic: "Profili R_LONG, R_AGE, W_AGE, SW_BOTRYTIS, PORT_VINTAGE senza qualifica da lunga evoluzione → 'Buono'. Scostamento dichiarato dall'elenco di FR2.3, che li metteva fra i 'Da invecchiamento'."
    violation: "Test della preselezione (Barolo senza qualifica → good)."
    source: "FR2.3 (scostamento)"
    rationale: "Decisione del proprietario (R-01). Con il moltiplicatore assoluto, 'Da invecchiamento' su un Barolo darebbe 10/20/42 invece di 8/15/30: i numeri del profilo contano già l'attitudine all'invecchiamento e il Livello non la deve contare due volte. 'Da invecchiamento' resta il segnale di una selezione (Riserva, Grand Cru...)."
  - id: BR4.3
    statement: "Il Livello si preseleziona così: 'Da invecchiamento' solo con una qualifica da lunga evoluzione; 'Quotidiano' per i profili freschi senza qualifica, IGT/IGP, vini da tavola, SP_TANK e LAM_FRESH; 'Buono' in tutti gli altri casi."
    category: calculation
    applies_to: "classifyWine"
    trigger: "come BR3.1"
    logic: "1) Qualifica di BR4.4 → aging. 2) Profilo SP_TANK o LAM_FRESH → everyday. 3) Profilo fresco (R_FRESH, W_FRESH, ROSE_FRESH, SW_AROMATIC) senza qualifica e con stile noto (non da confermare; il rosato conta sempre come noto) → everyday. 4) Denominazione di classe IGT, IGP, Vin de Pays, Landwein, Vino de la Tierra, Vin de France (templateKey IT-IGT o FR-IGP o parole) → everyday. 5) Parole del nome di BR4.5 o vino generico di BR3.8 → everyday. 6) Tutto il resto, R_LONG e R_AGE compresi, e nessuna informazione → good."
    violation: "Soglia dell'85% sul campione e superamento del riferimento 'sempre Buono' (BR9.5)."
    source: "FR2.3"
    rationale: "Decisione del proprietario (R-01). Un profilo fresco ricavato solo dal tipo o dal vitigno (stile da confermare) non dice che il vino è economico, quindi non propone 'Quotidiano'."
  - id: BR4.4
    statement: "Qualifiche che suggeriscono 'Da invecchiamento'."
    category: calculation
    applies_to: "agingQualifiers"
    trigger: "BR4.3 passo 1"
    logic: "riserva, gran reserva, grand cru, gran selezione, auslese, beerenauslese, trockenbeerenauslese, eiswein, vintage (solo con Porto). Non suggeriscono: reserva, premier cru, crianza, superiore, kabinett, spätlese, lbv, colheita, vintage su spumanti, 'reserve' e 'réserve', 'grande réserve', 'selection'."
    violation: "Test della lista."
    source: "FR2.3"
    rationale: "È l'elenco di FR2.3 confermato dal proprietario (R-01). Reserva e Premier Cru restano 'Buono': i loro scarti di qualifica allungano già la finestra."
  - id: BR4.5
    statement: "Parole del nome che suggeriscono 'Quotidiano'."
    category: calculation
    applies_to: "BR4.3 passo 4"
    trigger: "nome"
    logic: "vino da tavola, vin de table, vin de france, vino de mesa, tafelwein, table wine, bag in box, bib, fontaine, cubi, brick, tetra, novello, nouveau, primeur, joven, vino generico di BR3.8."
    violation: "Test."
    source: "FR2.3"
    rationale: "Sono le diciture del vino da bere subito o venduto sfuso."
  - id: BR4.6
    statement: "Cambiare lo Stile ricalcola il Livello suggerito solo se il Livello è automatico."
    category: policy
    applies_to: "modulo, dettaglio"
    trigger: "nuovo stile scelto o nuova Tipologia"
    logic: "IF levelSource = auto THEN livello = BR4.3 con il nuovo stile; ELSE invariato."
    violation: "Test del modulo."
    source: "FR2.4; interaction-spec S1"
    rationale: "Una scelta dell'utente non si sovrascrive mai."

  # ------------------------------------------------------------------
  # BR5 — Stile nel modulo e nel dettaglio (FR3.2, FR3.6)
  # ------------------------------------------------------------------
  - id: BR5.1
    statement: "Il gruppo 'Stile' compare sotto la Tipologia solo quando serve."
    category: policy
    applies_to: "StyleField"
    trigger: "Tipologia scelta"
    logic: "IF Tipologia null THEN nascosto. IF Tipologia sparklingClassic, sparklingTank, sweet, fortified THEN visibile. IF rosso o bianco AND (stile risolto da confermare OR UNKNOWN OR riga con più stili possibili per quel colore: righe della Revisione con base UNKNOWN, righe generate, nessuna denominazione) THEN visibile. IF rosato THEN mai (un solo stile). ELSE nascosto (lo stile è salvato comunque come auto)."
    violation: "Test widget."
    source: "FR3.2"
    rationale: "Non chiedere ciò che la denominazione già dice (un Barolo è un Barolo)."
  - id: BR5.2
    statement: "Opzioni per Tipologia."
    category: constraint
    applies_to: "StyleField"
    trigger: "costruzione dei chip"
    logic: "Spumante metodo classico: classicFresh, classicAge. Charmat: tankFresh, lambrusco. Dolce: sweetAromatic, sweetPassito, sweetBotrytis. Liquoroso: portVintage, portLbv, portTawny, sherryFino, sherryAmontillado, sherryOloroso, sherryPx, madeira, fortifiedOther. Rosso (leggero o strutturato): redFresh, redMedium, redAge, redLong. Bianco: whiteFresh, whiteMedium, whiteAge."
    violation: "Test widget."
    source: "FR3.2; interaction-spec S2"
    rationale: "Sono le etichette approvate; 'Porto LBV' diventa 'Porto LBV/Ruby' perché il Ruby usa lo stesso profilo (BR2.7)."
  - id: BR5.3
    statement: "Lo Stile preselezionato è lo stile del profilo risolto; cambiare la Tipologia lo ricalcola se è automatico."
    category: calculation
    applies_to: "classifyWine, modulo"
    trigger: "preselezione; cambio di Tipologia, nome, denominazione"
    logic: "stile = chiave di BR1.4 del profilo di BR2 per (denominazione, Tipologia, qualifica, parole); profilo UNKNOWN → stile del profilo del tipo (BR2.11), FORT_UNKNOWN → fortifiedOther, salvo madeira con denominazione Madeira; Sherry e Montilla senza parola di stile → nessuno stile preselezionato (BR2.8). IF styleSource = auto THEN si ricalcola a ogni cambio; IF user THEN mai."
    violation: "Test del modulo."
    source: "FR2.1, FR2.2, FR2.4"
    rationale: "Una sola funzione decide per base, testo, scrittura a mano e migrazione."
  - id: BR5.4
    statement: "'Stile da confermare' compare quando la stima è indicativa o lo stile è un'ipotesi non confermata."
    category: policy
    applies_to: "dettaglio, cruscotto"
    trigger: "lettura della finestra"
    logic: "IF window.indicative = true OR (window.profile in UNKNOWN, FORT_UNKNOWN) OR (stile risolto da confermare AND styleSource ≠ user) THEN avviso e confidence low. Toccare il chip già suggerito lo conferma (styleSource = user) e l'avviso sparisce, salvo FORT_UNKNOWN (resta)."
    violation: "Test widget."
    source: "FR1.4, FR3.6; interaction-spec S4, R-07"
    rationale: "L'utente deve sapere quando un numero è un'ipotesi; per Madeira lo studio non ha numeri e l'avviso resta."
  - id: BR5.5
    statement: "La riga di origine della stima nomina il profilo e da dove viene."
    category: policy
    applies_to: "IdealMomentCard, estimateOriginText"
    trigger: "dettaglio"
    logic: "Testo 'Stima dal profilo {stile} ({denominazione})'; senza denominazione '{stile}, dal tipo' o 'dal vitigno {vitigno}'; profilo in mesi + data assente → riga in più 'dalla data di inserimento: aggiungi la sboccatura per una stima migliore' (o 'l'imbottigliamento')."
    violation: "Test widget."
    source: "FR3.6, FR3.3"
    rationale: "Rende tracciabile la stima e invita a dare il dato che la migliora."
  - id: BR5.6
    statement: "Profilo del tipo quando lo stile non è noto."
    category: calculation
    applies_to: "BR2.11, BR2.12, BR5.3"
    trigger: "Tipologia nota, stile no"
    logic: "redLight → R_FRESH; redStructured → R_MEDIUM; white → W_MEDIUM; rose → ROSE_FRESH; sparklingClassic → SP_CLASSIC; sparklingTank → SP_TANK; sweet → UNKNOWN (2/8/20 indicativa); fortified → FORT_UNKNOWN (Da stimare)."
    violation: "Test."
    source: "FR1.4"
    rationale: "Decisione enologica: il 'Rosso leggero' scelto è un segnale vero di freschezza; il 'Rosso strutturato' va al medio perché lo studio vieta R_AGE per tutto il tipo; dolci e liquorosi hanno stili troppo diversi per un default."

  # ------------------------------------------------------------------
  # BR6 — Mesi, stato e visualizzazione (FR1.3, FR3.4, FR3.5)
  # ------------------------------------------------------------------
  - id: BR6.1
    statement: "Il tempo si conta in mesi assoluti: indice = anno × 12 + (mese − 1)."
    category: calculation
    applies_to: "status, finestra effettiva, cruscotto"
    trigger: "ogni confronto di date"
    logic: "Finestra in anni: inizio = gennaio dell'anno di inizio; picco = anno del picco (gennaio per l'ordinamento); fine = dicembre dell'anno di fine. Finestra in mesi: inizio, picco, fine = mese di decorrenza + scarti. Oggi = mese corrente (il giorno non conta)."
    violation: "Test di statusOf."
    source: "FR3.4"
    rationale: "Un solo modo di confrontare permette di trattare anni e mesi con la stessa funzione senza cambiare il comportamento di oggi per gli anni."
  - id: BR6.2
    statement: "Finestra da un profilo: decorrenza annata (anni) o mese di sboccatura/imbottigliamento (mesi)."
    category: calculation
    applies_to: "estimateWindow"
    trigger: "stima"
    logic: "Anni: anno base = annata; senza annata = anno di inserimento in cantina − 1 per fermi e dolci (come oggi). Mesi: mese base = agingStartMonth; senza data = mese di inserimento in cantina (anchorFallback = true, confidence low) e in quel caso l'inizio è 0 (picco e fine restano quelli del profilo): una bottiglia comprata è già pronta, quindi non è mai 'In attesa' (decisione del proprietario, R-07; vale per SP_CLASSIC_AGE 12/36/72 → 0/36/72). Il Porto Vintage resta in anni dall'annata; senza annata usa l'anno di inserimento − 1 e confidence low."
    violation: "Test."
    source: "FR3.3"
    rationale: "Per i profili in mesi conta solo quando il vino ha smesso di evolvere in cantina del produttore; l'annata di un Champagne non dice quando è stato sboccato."
  - id: BR6.3
    statement: "Stato del mese: in attesa, da bere, bevi presto, finestra passata."
    category: calculation
    applies_to: "statusOf"
    trigger: "cantina, dettaglio, cruscotto"
    logic: "T, S, E sono indici di mese anno × 12 + mese (BR6.1): T = oggi, S = inizio, E = fine. IF T < S THEN waiting. IF E esiste AND T > E THEN pastWindow. IF E null THEN ready. Avviso: con picco, avviso = arrotonda(25% × (E − S + 1)) limitato a 3..12 mesi; senza picco, avviso = 3 mesi. Mesi rimasti = E − T + 1. IF rimasti ≤ avviso THEN drinkSoon ELSE ready. Per le finestre in anni il risultato è identico a quello di oggi."
    violation: "Test di statusOf (anni invariati, mesi, picco null, fine null)."
    source: "FR1.3, FR3.4"
    rationale: "Conserva la regola del 25% già usata e dà allo Sherry esattamente 'Bevi presto negli ultimi 3 mesi' come chiede FR1.3."
  - id: BR6.4
    statement: "Picco null: niente riga 'Al meglio', niente segno del picco, il vino non entra nel grafico degli anni al meglio."
    category: policy
    applies_to: "dettaglio, scheda, cruscotto"
    trigger: "window.peak null"
    logic: "IdealMomentCard non mostra 'Al meglio'; la barra 'Momento ideale' non ha il segno del picco; DashboardCalculator salta il vino nel conteggio dei picchi per anno."
    violation: "Test widget e del calcolatore."
    source: "FR1.3; interaction-spec R-05"
    rationale: "Un picco non stimato non si disegna."
  - id: BR6.5
    statement: "Fine null: 'Pronto, nessuna fine stimata', stato sempre 'Da bere', barra aperta a destra."
    category: policy
    applies_to: "PORT_LBV, PORT_OX"
    trigger: "window.end null"
    logic: "Testo 'nessuna fine stimata' al posto di 'Consigliato fino al'; mai 'Bevi presto' né 'Finestra passata'; il vino non entra nella lista 'Da bere presto'; 'Consigliato fino al' resta disponibile e, se impostato, diventa la fine (BR6.8)."
    violation: "Test."
    source: "FR1.3"
    rationale: "S8: LBV e Tawny sono pronti e la loro fine dipende dal produttore."
  - id: BR6.6
    statement: "Formati delle date."
    category: policy
    applies_to: "UI"
    trigger: "visualizzazione di una finestra"
    logic: "Anni: '2028' come oggi. Mesi: dettaglio 'marzo 2027' (mese per esteso nella lingua dell'app: it 'marzo 2027', en 'March 2027', pt-BR 'março de 2027'); liste, scheda e cruscotto 'mar 2027' (abbreviato: en 'Mar 2027', pt-BR 'mar. de 2027'). Lettore di schermo: sempre per esteso."
    violation: "Test widget nelle 3 lingue."
    source: "FR3.4; interaction-spec"
    rationale: "Formati di intl per locale, senza testi scritti nel codice."
  - id: BR6.7
    statement: "Cruscotto: anni al meglio con l'anno del picco; 'Da bere presto' con il mese per le finestre in mesi; riquadro 'Da confermare'."
    category: calculation
    applies_to: "DashboardCalculator"
    trigger: "calcolo del cruscotto"
    logic: "Picchi per anno: anno del picco (anche per i mesi); picco null escluso. Da bere presto: ordinati per indice di fine; testo 'entro mar 2027' per i mesi, '2027' per gli anni. Da confermare: vini con avviso BR5.4 più i vini 'Da stimare'; conteggio e lista."
    violation: "Test del calcolatore."
    source: "FR3.4, FR1.4; interaction-spec S6"
    rationale: "Il grafico resta per anni come chiede FR3.4; i vini incerti hanno un posto dove trovarli."
  - id: BR6.8
    statement: "'Consigliato fino al' si salva con la sua unità."
    category: calculation
    applies_to: "WindowOverride, effectiveWindow"
    trigger: "correzione manuale"
    logic: "Profilo in anni: endYear come oggi. Profilo in mesi o fine null: endYear + endMonth. Intervallo ammesso: dall'inizio a inizio + 60 anni (anni) o inizio + 120 mesi (mesi). Un override senza endMonth su una finestra in mesi vale dicembre di quell'anno. Inizio e picco si fermano alla fine se la superano (come oggi)."
    violation: "Le regole Firestore rifiutano mesi fuori 1..12 (BR10.2)."
    source: "FR3.5, FR4.1"
    rationale: "L'utente corregge con la stessa precisione della stima; i dati di oggi restano validi."
  - id: BR6.9
    statement: "Il riscontro delle bevute vale anche per le finestre in mesi, con il mese della bevuta."
    category: calculation
    applies_to: "WindowAdjuster"
    trigger: "bevuta con condizione"
    logic: "WindowAdjustment salva anche month (1..12) di drankOn. Le regole di oggi (justRight, pastPeak, tooYoung) si applicano sugli indici di mese: Y diventa l'indice della bevuta e 'Y + 1' diventa il mese successivo. Finestra in anni: si confronta l'anno come oggi. Adjustment senza month su finestra in mesi: dicembre di quell'anno. Fine null: justRight e pastPeak non cambiano nulla, tooYoung sposta l'inizio."
    violation: "Test di WindowAdjuster."
    source: "FR3.4, FR4.1"
    rationale: "Stesse decisioni enologiche di u4-cellar, alla granularità della finestra."
  - id: BR6.10
    statement: "Una finestra valida ha inizio ≤ picco ≤ fine sugli indici di mese, con i valori presenti."
    category: validation
    applies_to: "validateWindow, regole Firestore"
    trigger: "stima e scrittura"
    logic: "start obbligatorio; peak e end facoltativi; ordine sui valori presenti; anni 1900..2200; mesi 1..12 solo con unit months."
    violation: "EstimationArgumentError; rifiuto delle regole."
    source: "FR1.3, NFR2.2"
    rationale: "Estende la validazione di oggi ai valori null."

  # ------------------------------------------------------------------
  # BR7 — Provenienza e migrazione (FR2.4, FR4)
  # ------------------------------------------------------------------
  - id: BR7.1
    statement: "Ogni vino salva da dove vengono Tipologia, Livello e Stile: user o auto."
    category: constraint
    applies_to: "Wine.typeSource, levelSource, styleSource"
    trigger: "ogni salvataggio dal modulo, dalla migrazione, dal dettaglio"
    logic: "Campo compilato dalla preselezione e non toccato → auto. Scelta di un'altra opzione o tocco sull'opzione suggerita → user. Campo vuoto → nessuna provenienza."
    violation: "Le regole rifiutano valori diversi da user e auto (BR10.2)."
    source: "FR2.4"
    rationale: "Senza provenienza non si può rispettare la regola 'mai sovrascrivere una scelta dell'utente'."
  - id: BR7.2
    statement: "Una nuova compilazione automatica cambia solo i campi auto o vuoti."
    category: policy
    applies_to: "modulo (incolla, foto, cambio di nome o denominazione), migrazione"
    trigger: "nuova preselezione"
    logic: "IF source = user THEN invariato ELSE nuovo valore auto."
    violation: "Test del modulo."
    source: "FR2.4; interaction-spec S1"
    rationale: "Richiesta esplicita del proprietario."
  - id: BR7.3
    statement: "'Ripristina suggerimento' riporta un campo user al valore auto calcolato ora."
    category: policy
    applies_to: "Tipologia, Livello, Stile nel modulo di modifica"
    trigger: "tocco su 'Ripristina suggerimento' (visibile solo se il campo è user e il suggerimento esiste e differisce)"
    logic: "valore = preselezione corrente; source = auto."
    violation: "Test widget."
    source: "interaction-spec R-06"
    rationale: "Dà un'uscita a chi ha cambiato un valore per errore. Il selettore del Livello resta quello di oggi (con 'Nessuno', che vale 'Buono' nella stima)."
  - id: BR7.4
    statement: "Migrazione una tantum (tablesVersion 3): provenienza, preselezione dei vuoti, stile, nuova stima."
    category: policy
    applies_to: "EstimatesMigration"
    trigger: "apertura dell'app o ritorno in rete, vino con migrationVersion < 3"
    logic: "Per ogni vino: wineType presente → typeSource user; assente → preselezione BR3, typeSource auto. level presente (anche 'good') → levelSource user; assente → preselezione BR4, levelSource auto. style: preselezione BR5.3, styleSource auto (lo stile è nuovo). baseWindow e window ricalcolate con BR2 per le finestre internalRules; le finestre del catalogo restano. windowAdjustment e windowOverride restano (BR7.5). Il Livello salvato conserva il suo significato (BR4.1): un Barolo con 'good' salvato ha 8/15/30 prima e dopo. Scrittura per vino in una transazione: si rilegge il documento, IF updatedAt è diverso da quello letto all'inizio THEN il vino si salta in questo giro (resta con migrationVersion < 3 e si riprende al prossimo avvio con i dati nuovi) ELSE update dei campi di classificazione, della stima e di migrationVersion = 3. Come la scrittura quiet di setEstimate di oggi, la migrazione scrive anche updatedAt (ora del server) e updatedBy, quindi passa le regole di validWineUpdate; il confronto usa l'updatedAt letto quando il vino è entrato nel giro della migrazione. Test: (a) Barolo con level 'good' → levelSource user, finestra 8/15/30 prima e dopo; (b) vino modificato da un altro membro fra lettura e transazione → saltato e migrato all'avvio successivo."
    violation: "Test di migrazione (NFR4.4)."
    source: "FR4.1"
    rationale: "Oggi Tipologia e Livello arrivano solo dal modulo e l'utente li ha confermati salvando (FR4.1)."
  - id: BR7.5
    statement: "Correzioni conservate: un override in anni su un profilo in mesi vale fino a dicembre di quell'anno; un adjustment senza mese vale dicembre."
    category: calculation
    applies_to: "migrazione, effectiveWindow, WindowAdjuster"
    trigger: "unità diverse"
    logic: "override.endMonth assente con finestra in mesi → mese 12 di endYear. Se l'override cade prima dell'inizio della nuova finestra, l'inizio si ferma lì come oggi."
    violation: "Test."
    source: "FR4.1"
    rationale: "La correzione dell'utente vince sempre e non si reinterpreta."
  - id: BR7.6
    statement: "La migrazione riprende dove si è fermata."
    category: policy
    applies_to: "EstimatesMigration"
    trigger: "interruzione (app chiusa, rete, rifiuto)"
    logic: "Lo stato è nel vino: migrationVersion = 3 scritto insieme agli altri campi. Al prossimo avvio si riprendono solo i vini con migrationVersion < 3. Rifiuto delle regole: stop per quell'avvio, tentativi contati come oggi (3 avvii, poi attesa della versione successiva)."
    violation: "Test di ripresa (NFR4.4)."
    source: "FR4.2"
    rationale: "Lo stato nel documento è atomico con la scrittura e vale su ogni dispositivo."
  - id: BR7.7
    statement: "La migrazione è silenziosa e i campi che compila portano '✦ suggerito'."
    category: policy
    applies_to: "UI dopo l'aggiornamento"
    trigger: "migrazione completata"
    logic: "Nessun messaggio; i campi auto mostrano il segno; quelli user no."
    violation: "Test widget."
    source: "interaction-spec R-06"
    rationale: "Come la migrazione di oggi."
  - id: BR7.8
    statement: "Una versione vecchia dell'app non cancella i campi nuovi."
    category: constraint
    applies_to: "WineRepository delle versioni ≤ attuale"
    trigger: "modifica da un'app non aggiornata"
    logic: "updateWine usa update() (verificato in wine_repository.dart): i campi non scritti restano. Se riscrive window/baseWindow con il formato di oggi, tablesVersion 2 < 3 fa ripartire la stima alla prossima apertura dell'app nuova. Se cambia wineType o level, la provenienza resta quella di prima (rischio accettato, functional-spec D7)."
    violation: "Test con documento scritto nel formato vecchio."
    source: "NFR2.3"
    rationale: "Compatibilità ottenuta senza cambiare il codice già pubblicato."

  # ------------------------------------------------------------------
  # BR8 — Data di sboccatura o imbottigliamento (FR3.3)
  # ------------------------------------------------------------------
  - id: BR8.1
    statement: "Un solo campo agingStartMonth (mese e anno) vale come sboccatura o imbottigliamento secondo lo stile."
    category: constraint
    applies_to: "Wine.agingStartMonth"
    trigger: "profilo in mesi"
    logic: "Etichetta 'Sboccatura' per classicFresh, classicAge; 'Imbottigliamento' per tankFresh, lambrusco, portLbv, portTawny, sherry*. Campo visibile solo per i profili in mesi. Se lo stile cambia, la data resta salvata e cambia solo l'etichetta; per i profili in anni non si usa."
    violation: "Test widget."
    source: "FR3.3; interaction-spec R-02"
    rationale: "Il dato è sempre 'quando il vino è stato messo in bottiglia nella sua forma finale'."
  - id: BR8.2
    statement: "Validazione di mese e anno."
    category: validation
    applies_to: "modulo, Firestore"
    trigger: "salvataggio"
    logic: "Entrambi o nessuno ('Indica mese e anno'). Anno da 1950 all'anno corrente; mese 1..12; non dopo il mese corrente; anno non prima dell'annata se c'è ('Non può essere prima dell'annata'). Regole: year 1900..2200, month 1..12."
    violation: "Errore sotto il campo; salvataggio bloccato."
    source: "FR3.3; interaction-spec R-02"
    rationale: "Impedisce date impossibili che sposterebbero la finestra nel futuro."
  - id: BR8.3
    statement: "Senza data vale il mese di inserimento in cantina, con affidabilità bassa e invito ad aggiungerla."
    category: calculation
    applies_to: "BR6.2"
    trigger: "profilo in mesi senza agingStartMonth"
    logic: "mese base = createdAt (ora locale); window.anchorFallback = true; confidence low; BR5.5 mostra l'invito."
    violation: "Test."
    source: "FR3.3"
    rationale: "Assunzione approvata (Q2 = A): chi compra una bottiglia di Prosecco la compra di solito poco dopo l'imbottigliamento."

  # ------------------------------------------------------------------
  # BR9 — Classificazione della base offline (FR2.1, FR2.5)
  # ------------------------------------------------------------------
  - id: BR9.1
    statement: "Il tool build_wine_db.dart classifica ogni vino quando genera la base, con la stessa funzione classifyWine del pacchetto."
    category: policy
    applies_to: "tool/build_wine_db.dart"
    trigger: "generazione della base dall'export in .cache/"
    logic: "Per ogni vino tenuto: tipo dei tag (wineTypeOfTags) come 'tipo della base'; denominazione con la tabella completa (2424 righe, non più solo le 47 italiane); classifyWine(nome, produttore, denominazione, tipo dei tag, paese) → wineType, level, style. Il record salva i valori preselezionati (BR9.2)."
    violation: "Test del tool su fixture."
    source: "FR2.1, FR2.5"
    rationale: "Una sola implementazione evita le tre liste di parole diverse di oggi; calcolare nel tool tiene il telefono leggero (NFR3)."
  - id: BR9.2
    statement: "Il record della base porta la classificazione in chiavi brevi."
    category: constraint
    applies_to: "WineDbRecord"
    trigger: "scrittura e lettura della base"
    logic: "t = Tipologia preselezionata (8 valori); l = livello (everyday, good, aging); s = stile (BR1.4), solo se c'è una Tipologia; d = denominazione riconosciuta (nome della riga). formatVersion del manifest 2; il caricatore accetta 1 (senza l, s) e 2."
    violation: "Righe danneggiate scartate come oggi."
    source: "FR2.1, FR2.5"
    rationale: "Pochi byte in più per riga: la base resta sotto 3 MB compressa."
  - id: BR9.3
    statement: "Limiti della base e del tempo di generazione."
    category: constraint
    applies_to: "build_wine_db"
    trigger: "generazione"
    logic: "≤ 3 MB compressa, ≤ 30 MB di dati (come oggi); generazione ≤ 2 minuti; il manifest registra classifiedTypeShare (quota con Tipologia)."
    violation: "Il tool non scrive nulla e la base precedente resta."
    source: "FR2.5, NFR3"
    rationale: "Limiti già decisi dal proprietario."
  - id: BR9.4
    statement: "Il tool esclude i prodotti che non sono vino."
    category: validation
    applies_to: "build_wine_db (DropReason.excludedCategory)"
    trigger: "parole di BR3.9 nel nome o nei tag"
    logic: "IF parola di non-vino THEN record escluso."
    violation: "Test del tool."
    source: "FR2.1"
    rationale: "Un seltzer o un calvados non è un vino da classificare; toglierli migliora anche la quota della soglia del 90%."
  - id: BR9.5
    statement: "Soglie misurate sul campione e sulla base."
    category: validation
    applies_to: "test di NFR4.3"
    trigger: "CI"
    logic: "Bloccanti in CI. Campione classification-sample.json: Tipologia giusta ≥ 95% dei preselezionati; Livello giusto ≥ 85% e sopra l'accuratezza di 'sempre good' sugli stessi vini; nessuna Tipologia per i vini con indizio 'none'; le righe 'usedForTuning' sono stampate a parte. Base intera: il test ricalcola la quota di vini con Tipologia sulla base spedita e verifica che coincida con classifiedTypeShare del manifest (misura registrata alla generazione). Il 90% di FR2.1 è l'obiettivo: il test lo stampa con la misura ma non blocca il merge."
    violation: "Test rosso, merge bloccato (campione o quota diversa dal manifest)."
    source: "FR2.1, NFR4.3"
    rationale: "Decisione del 2026-11-09 (R-02). Con i dati di oggi il prototipo misura 83,5% sulla base: un test bloccante al 90% fermerebbe il Code Generation su un obiettivo che la base non raggiunge. Se la base ricostruita resta sotto il 90%, al gate il proprietario decide se accettare una copertura più bassa."

  # ------------------------------------------------------------------
  # BR10 — Regole Firestore (NFR2)
  # ------------------------------------------------------------------
  - id: BR10.1
    statement: "wineFields() accetta i campi nuovi, tutti facoltativi."
    category: authorization
    applies_to: "firestore.rules, cellars/{cellarId}/wines/{wineId}"
    trigger: "create e update"
    logic: "Nuovi: style, typeSource, levelSource, styleSource, agingStartMonth, migrationVersion. I vini senza di essi restano validi."
    violation: "permission-denied."
    source: "NFR2.1, NFR2.2"
    rationale: "hasOnly rifiuta ogni campo non elencato: senza questa modifica ogni scrittura nuova fallirebbe."
  - id: BR10.2
    statement: "Validatori dei campi nuovi, controllati solo quando cambiano."
    category: validation
    applies_to: "firestore.rules"
    trigger: "update con il campo fra quelli cambiati; create"
    logic: "style: null o una delle 24 chiavi di BR1.4. *Source: null, 'user' o 'auto'. agingStartMonth: null o mappa con solo e tutte le chiavi year (intero 1900..2200) e month (intero 1..12). migrationVersion: null o intero 1..1000. window/baseWindow: chiavi in più unit ('years','months'), startMonth, peakMonth, endMonth (interi 1..12), profile (una delle 24 chiavi di profilo), anchor ('vintage','bottling','disgorgement'), anchorFallback (bool), indicative (bool); peakYear e endYear facoltativi; hasAll solo startYear, confidence, source; ordine controllato sui valori presenti come un unico intero: per unit 'months' indice = anno * 12 + mese (startYear*12+startMonth <= peakYear*12+peakMonth <= endYear*12+endMonth), per unit 'years' o assente sugli anni come oggi; test dedicato con una finestra SP_TANK dentro lo stesso anno (marzo → settembre ammessa, settembre → marzo rifiutata); qualifier anche 'beerenauslese','trockenbeerenauslese','eiswein'. windowOverride: endMonth facoltativo 1..12. windowAdjustment: month facoltativo 1..12."
    violation: "permission-denied; la migrazione conta il rifiuto (BR7.6)."
    source: "NFR2.2"
    rationale: "Stesso stile di validazione delle regole di oggi (controllo solo al cambio, come validLevel)."
  - id: BR10.3
    statement: "Le regole aggiornate si pubblicano prima della build, con l'OK del proprietario."
    category: policy
    applies_to: "rilascio"
    trigger: "Deployment"
    logic: "Ordine: test delle regole nell'emulatore → OK del proprietario → deploy delle regole sul progetto reale → build al canale di test interno."
    violation: "Le scritture della nuova app sarebbero rifiutate."
    source: "NFR2.2; vincoli; team.md Deployment"
    rationale: "Le nuove regole accettano anche le scritture della versione attuale, quindi possono andare prima."

  # ------------------------------------------------------------------
  # BR11 — Test (NFR4)
  # ------------------------------------------------------------------
  - id: BR11.1
    statement: "Copertura: almeno 80% delle righe sul progetto senza esclusioni e almeno 90% sul pacchetto estimation, misurate in GitHub Actions."
    category: policy
    applies_to: "CI"
    trigger: "ogni pull request verso main"
    logic: "flutter test --coverage per l'app e dart test --coverage per packages/estimation; il passo di CI fallisce sotto 80% (progetto, codice generato e traduzioni compresi) o sotto 90% (estimation). File di test previsti: packages/estimation/test/style_profiles_test.dart (BR1), profile_map_test.dart (BR2.17, fixture profile-map.json), classify_wine_test.dart (BR3, BR4, BR5), month_status_test.dart (BR6), window_level_test.dart (BR4.1)."
    violation: "Merge bloccato."
    source: "NFR4.1"
    rationale: "Sono le soglie di team.md e di NFR4.1; i file di test nominati rendono verificabile la copertura per strato."
  - id: BR11.2
    statement: "La suite esistente resta verde e un test end-to-end prova il modulo con Stile e data di sboccatura."
    category: policy
    applies_to: "CI, integration_test"
    trigger: "ogni pull request verso main"
    logic: "Tutti i test di oggi verdi. integration_test/style_profile_flow_test.dart sull'emulatore Android con la Firebase Emulator Suite: aggiunta di uno Champagne dalla base (Tipologia e Stile '✦ suggerito'), scelta 'Da evoluzione', inserimento della sboccatura marzo 2024, salvataggio, dettaglio con 'Al meglio marzo 2027'; poi un Prosecco Dolce che resta 'spumante Charmat'."
    violation: "Merge bloccato."
    source: "NFR4.5"
    rationale: "È il percorso nuovo più esposto: modulo, regole Firestore e visualizzazione in mesi insieme."
  - id: BR11.3
    statement: "Test di migrazione e delle regole."
    category: policy
    applies_to: "test/cellar/estimates_migration_test.dart, test delle regole Firestore"
    trigger: "CI"
    logic: "Migrazione: campi scelti dall'utente non toccati; Barolo con level 'good' resta 8/15/30; correzione 'Consigliato fino al' in anni su un profilo in mesi = dicembre; vino cambiato fra lettura e transazione saltato; ripresa dopo interruzione. Regole: ogni validatore nuovo con un caso valido e due non validi; finestra in mesi nello stesso anno (BR10.2); scritture dell'app di oggi accettate."
    violation: "Merge bloccato."
    source: "NFR4.4, NFR2.2"
    rationale: "Rende verificabili BR7.4–BR7.6 e BR10.2."
```

## Riepilogo delle regole

| ID | Regola | Categoria | Fonte |
|---|---|---|---|
| BR1.1 | 24 profili con decorrenza, unità, valori; "—" = null | constraint | FR1.1, NFR6 |
| BR1.2 | Mai valori inventati né durate infinite | constraint | FR1.3 |
| BR1.3 | Fonti e natura dell'evidenza nel commento | policy | NFR6 |
| BR1.4 | Chiavi di stile salvate → profilo | constraint | FR3.2 |
| BR2.1 | Precedenza a 4 passi resa esatta | calculation | FR1.2, FR1.5 |
| BR2.2 | Stile dei fermi: più vicino ai valori, con soglie | calculation | FR1 |
| BR2.3 | Spumanti: SP_CLASSIC, SP_CLASSIC_AGE, SP_TANK | calculation | FR1, FR2.3, FR3.3 |
| BR2.4 | Lambrusco: Charmat, LAM_FRESH | calculation | FR1, FR2.3 |
| BR2.5 | Dolci: aromatico, passito, botritizzato; botritizzati legacy conservano la finestra | calculation | FR1, FR1.4 |
| BR2.6 | Prädikat: Kabinett W_MEDIUM, Spätlese W_AGE, Auslese, BA, TBA, Eiswein | calculation | FR1.5 |
| BR2.7 | Porto: Vintage, LBV/Ruby, Tawny/Colheita | calculation | FR1 |
| BR2.8 | Sherry e Montilla; senza parola di stile da confermare | calculation | FR1, FR1.3 |
| BR2.9 | Madeira e liquorosi non distinti | calculation | FR1.4 |
| BR2.10 | Riserva bianca, Soave Superiore, Grand Cru Classé anche a Pauillac, Crianza | calculation | FR1.5 |
| BR2.11 | Righe generate | calculation | FR1.4, FR1.6 |
| BR2.12 | Tipi sbagliati e tipo non fatto | calculation | FR1.6 |
| BR2.13 | Revisione 60 | calculation | FR1.2, FR1.4 |
| BR2.14 | Stile non chiaro: indicativa o Da stimare | calculation | FR1.4 |
| BR2.15 | Stile scelto dall'utente | calculation | FR1.4 |
| BR2.16 | Parole di stile nel nome | calculation | FR1.5, FR2.3 |
| BR2.17 | profile-map.json fixture, tablesVersion 3 | policy | FR1.2, NFR4.2 |
| BR3.1 | Precedenza della Tipologia (FR2.3) | calculation | FR2.1–FR2.3 |
| BR3.2 | Parole per lingua; dosaggio mai sopra denominazione o spumante | calculation | FR2.1, FR2.3 |
| BR3.3 | Denominazioni multi-tipo | calculation | FR2.3 |
| BR3.4 | Rosso leggero o strutturato | calculation | FR2.3 |
| BR3.5 | Niente riduzione a 5 famiglie | constraint | FR2.3 |
| BR3.6 | Vitigni con il solo colore | calculation | FR2.1 |
| BR3.7 | Château senza indizi → rosso | calculation | FR2.1 |
| BR3.8 | Vino generico da tavola | calculation | FR2.3 |
| BR3.9 | Nessun indizio o non vino → vuoto | validation | FR2.1, FR2.3 |
| BR4.1 | Livello assoluto come oggi, solo anni | calculation | FR2.3 |
| BR4.2 | Profilo da invecchiamento senza qualifica → Buono (scostamento da FR2.3) | calculation | FR2.3 |
| BR4.3 | Preselezione del Livello | calculation | FR2.3 |
| BR4.4 | Qualifiche da invecchiamento | calculation | FR2.3 |
| BR4.5 | Parole da Quotidiano | calculation | FR2.3 |
| BR4.6 | Cambio di stile e livello automatico | policy | FR2.4 |
| BR5.1 | Quando compare lo Stile | policy | FR3.2 |
| BR5.2 | Opzioni per Tipologia | constraint | FR3.2 |
| BR5.3 | Stile preselezionato | calculation | FR2.1, FR2.2, FR2.4 |
| BR5.4 | "Stile da confermare" | policy | FR1.4, FR3.6 |
| BR5.5 | Riga del profilo nel dettaglio | policy | FR3.6, FR3.3 |
| BR5.6 | Profilo del tipo | calculation | FR1.4 |
| BR6.1 | Indice di mese | calculation | FR3.4 |
| BR6.2 | Decorrenza e anno/mese base | calculation | FR3.3 |
| BR6.3 | Stato al mese | calculation | FR1.3, FR3.4 |
| BR6.4 | Picco null | policy | FR1.3 |
| BR6.5 | Fine null | policy | FR1.3 |
| BR6.6 | Formati delle date | policy | FR3.4 |
| BR6.7 | Cruscotto | calculation | FR3.4, FR1.4 |
| BR6.8 | "Consigliato fino al" con unità | calculation | FR3.5, FR4.1 |
| BR6.9 | Riscontro delle bevute in mesi | calculation | FR3.4, FR4.1 |
| BR6.10 | Validità della finestra | validation | FR1.3, NFR2.2 |
| BR7.1 | Provenienza user/auto | constraint | FR2.4 |
| BR7.2 | Mai sovrascrivere user | policy | FR2.4 |
| BR7.3 | Ripristina suggerimento | policy | interaction-spec |
| BR7.4 | Migrazione una tantum | policy | FR4.1 |
| BR7.5 | Correzioni in anni su profili in mesi | calculation | FR4.1 |
| BR7.6 | Ripresa della migrazione | policy | FR4.2 |
| BR7.7 | Migrazione silenziosa | policy | interaction-spec |
| BR7.8 | App vecchia non cancella i campi | constraint | NFR2.3 |
| BR8.1 | Campo unico sboccatura/imbottigliamento | constraint | FR3.3 |
| BR8.2 | Validazione mese e anno | validation | FR3.3 |
| BR8.3 | Ripiego sulla data di inserimento | calculation | FR3.3 |
| BR9.1 | Classificazione nel tool | policy | FR2.1, FR2.5 |
| BR9.2 | Chiavi brevi del record | constraint | FR2.1, FR2.5 |
| BR9.3 | Limiti della base | constraint | FR2.5, NFR3 |
| BR9.4 | Esclusione dei non vini | validation | FR2.1 |
| BR9.5 | Soglie del campione bloccanti; quota della base = manifest, 90% obiettivo | validation | FR2.1, NFR4.3 |
| BR10.1 | Campi nuovi ammessi | authorization | NFR2.1, NFR2.2 |
| BR10.2 | Validatori dei campi nuovi | validation | NFR2.2 |
| BR10.3 | Ordine di pubblicazione delle regole | policy | NFR2.2 |
| BR11.1 | Copertura 80% e 90% su estimation, file di test | policy | NFR4.1 |
| BR11.2 | Suite verde ed e2e del modulo | policy | NFR4.5 |
| BR11.3 | Test di migrazione e delle regole | policy | NFR4.4, NFR2.2 |
