# Campione di classificazione — 100 vini della base offline

**Collaborator:** aidlc-architect-agent

Campione di riferimento per FR2.1 e NFR4.3: 100 vini reali della base spedita, con la Tipologia, il Livello e lo Stile che mi aspetto dalla preselezione. Lo scelgo io come enologo (correzione di `project.md`): ogni valore si può correggere. La versione leggibile da macchina è `classification-sample.json`, fixture del test delle soglie.

## Fonti

- `assets/wine_db/wines.jsonl.gz` (15.616 vini, export Open Food Facts 2026-11-07, ODbL): campi `b`, `n`, `p`, `t`, `d`, `c`, `v`.
- Estrazione riproducibile: `random.Random(261108)`, 50 record con tipo e 50 senza, ordinati per codice a barre (script `sample.py` nella cartella di lavoro del job).
- `rules.md` di questa fase (BR3 tipologia, BR4 livello, BR5 stile) per il significato dei valori.

## Come si usa nel test (NFR4.3)

1. Il test cerca ogni codice a barre nella base **ricostruita** con la classificazione (FR2.5) e legge Tipologia, Livello e Stile preselezionati.
2. **Tipologia**: tra i vini a cui la preselezione dà una Tipologia, almeno il **95%** coincide con l'attesa. Un vino atteso senza Tipologia (`—`) a cui ne viene data una conta come errore.
3. **Livello**: tra gli stessi vini, almeno l'**85%** coincide.
4. **Nessun indizio**: i vini con indizio `none` restano senza Tipologia.
5. **Stile**: la concordanza si misura e si stampa, ma non blocca (FR2.1 non fissa una soglia).
6. **Confronto con "sempre Buono"**: il test calcola anche l'accuratezza del Livello di un classificatore che risponde sempre `good` sugli stessi vini e richiede che la preselezione la superi.
7. **Copertura della base**: il tool scrive nel manifest `classifiedTypeShare`; il test ricalcola la quota sulla base spedita e verifica che coincida con quella registrata. Il 90% di FR2.1 resta l'obiettivo e viene stampato, ma non blocca il merge (BR9.5): se la base reale resta sotto, decide il proprietario al gate.

La colonna "Indizio" dice dove sta l'informazione: `knowledge` vuol dire che la risposta la conosce chi conosce il vino (Château Latour, Mouton Cadet), ma il record non la contiene; una preselezione vuota lì non è un errore.

## Riepilogo

- Vini con Tipologia attesa: 90; senza: 10; solo per conoscenza: 3.
- Per Tipologia: None 10, fortified 4, redLight 22, redStructured 25, rose 13, sparklingClassic 5, sparklingTank 3, sweet 3, white 15.
- Per Livello: aging 1, everyday 34, good 65.
- Per indizio: dbType 5, denomination 38, grape 11, knowledge 3, name 30, none 10, producer 2, qualifier 1.

## Misura con il prototipo delle regole

Prototipo Python di BR3–BR5 (`prototype.py`, nella cartella di lavoro del job, fuori dal repository), applicato alla base spedita e al campione. Riconosce le denominazioni solo dai nomi di `profile-map.json`, senza alias: è una stima prudente della funzione Dart.

| Misura | Preselezione | Sempre "Buono" | Soglia |
|---|---|---|---|
| Vini del campione con Tipologia preselezionata | 87 su 100 (attesi con Tipologia: 90) | — | — |
| Tipologia giusta fra i preselezionati | 86/87 = 98.9% | — | ≥ 95% |
| Livello giusto fra i preselezionati | 84/87 = 96.5% | 52/87 = 59.8% | ≥ 85% e sopra il riferimento |
| Stile giusto (informativo) | 79/87 = 90.8% | — | nessuna |
| Vini senza indizio lasciati vuoti | 10/10 | — | tutti |
| Solo le righe non usate per tarare (73 preselezionate) | Tipologia 100.0%, Livello 95.9% | Livello 60.3% | — |
| Base intera: vini con Tipologia | 12941 su 15492 = **83.5%** (esclusi 124 non vini) | — | obiettivo 90% |

**Righe usate per tarare le regole**: 5, 8, 23, 25, 26, 42, 43, 46, 63, 72, 86, 88, 93, 94 (14 righe). Dopo la prima misura ho corretto il prototipo dove non applicava le regole scritte (righe generate con tipi di ripiego, colore che la denominazione non fa, vitigno contenuto nel nome della denominazione, IGP rosso) e ho aggiunto due regole nuove: parole di dosaggio che non battono il colore (decisione del proprietario) e profilo fresco da confermare che non dà "Quotidiano" (BR4.3). Le altre 86 righe servono solo a misurare.

**Copertura proiettata**: 83.5% sulla base di oggi con il prototipo, circa 84–86% con gli alias della tabella Dart. Sotto il 90% di FR2.1: la decisione spetta al proprietario al gate.

Tipologie sbagliate del prototipo: n. 46 Arbin Mondeuse - Château de Mérande: redLight invece di redStructured.
Livelli diversi: n. 10 Muscat Belle saison: good invece di everyday; n. 89 Cuvee 21 dolce: good invece di everyday; n. 90 Beccaccia rosso: good invece di everyday.

## Vini

Colonne "Prototipo": la preselezione ottenuta (Tipologia / Livello / Stile); "T" = riga usata per tarare.

| # | Codice | Nome | Produttore | Tipo base | Den. | Paese | Annata | Tipologia | Livello | Stile | Prototipo | T | Indizio | Nota |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `0082896710294` | FETZER Sundial CHARDONNAY |  |  |  | CH |  | white | good | whiteMedium | white / good / whiteMedium |  | grape | Chardonnay californiano (Fetzer); il paese CH del record è sbagliato. |
| 2 | `0085904000011` | Vin rouge |  | redStructured |  | FR |  | redLight | everyday | redFresh | redLight / everyday / redFresh |  | name | Designazione generica "vin rouge" senza denominazione: vino da tavola. |
| 3 | `0853086008091` | Rose |  | rose |  | US |  | rose | everyday | roseFresh | rose / everyday / roseFresh |  | name | Solo "Rose": rosato generico. |
| 4 | `20045654` | Vino Gran Reserva 2013 | Vespral | redStructured |  | ES | 2013 | redStructured | aging | redAge | redStructured / aging / redMedium |  | qualifier | Gran Reserva spagnolo: almeno 5 anni di affinamento. |
| 5 | `3021891300144` | Aude Rouge | Commandeur | redStructured |  | FR |  | redLight | everyday | redFresh | redLight / everyday / redFresh | T | denomination | IGP Aude rosso: vino quotidiano. |
| 6 | `3113889000041` | Champagne |  | sparklingClassic |  | IT |  | sparklingClassic | good | classicFresh | sparklingClassic / good / classicFresh |  | denomination | Champagne non millesimato. |
| 7 | `3180280413534` | Malesan Rouge | Malesan | redStructured |  | FR |  | redStructured | good | redMedium | redStructured / good / redMedium |  | dbType | Malesan è un marchio di Bordeaux rosso; nel record c'è solo "Rouge". |
| 8 | `3187858470135` | PINOT NOIR ALSACE | STEPHANE BERG |  |  | FR |  | redLight | good | redMedium | redLight / good / redMedium | T | grape | Pinot Noir d'Alsace: la riga Alsace fa solo bianchi, decide il vitigno. |
| 9 | `3211209136347` | Chateau latour 2011 |  |  |  | FR | 2011 | redStructured | good | redLong | redStructured / good / redMedium |  | knowledge | Château Latour, Pauillac primo cru: nel record nessuna denominazione. |
| 10 | `3221240557025` | Muscat Belle saison |  |  |  | FR |  | sweet | everyday | sweetAromatic | sweet / good / sweetAromatic |  | grape | Muscat francese senza "sec": di solito dolce aromatico; caso incerto. |
| 11 | `3222471124086` | Bordeaux 2016 | club des sommeliers | redStructured |  | FR | 2016 | redStructured | good | redMedium | redStructured / good / — |  | denomination | Bordeaux rosso: stile da confermare (riga UNKNOWN), proposta Medio. |
| 12 | `3222471459607` | Pineau des Charentes |  | fortified |  | FR |  | fortified | good | fortifiedOther | fortified / good / fortifiedOther |  | name | Pineau des Charentes: vin de liqueur. |
| 13 | `3222477006133` | Cotes du Rhone |  |  |  | FR |  | redLight | good | redMedium | redLight / good / redMedium |  | denomination | Côtes du Rhône senza colore: rosso, tipo principale della riga. |
| 14 | `3233960019714` | vin rosé | cuvée vauban | rose |  | FR |  | rose | everyday | roseFresh | rose / everyday / roseFresh |  | name | Vin rosé generico. |
| 15 | `3245414037007` | Saumur Champigny | La Cave d'Augustin Florent | redStructured |  | FR |  | redLight | good | redMedium | redLight / good / redMedium |  | denomination | Saumur-Champigny: Cabernet Franc, struttura media. |
| 16 | `3245414538757` | 75CL MONTAGNE SAINT EMILION ROUGE | La Cave d'Augustin Florent | redStructured |  | FR |  | redStructured | good | redAge | redStructured / good / redAge |  | denomination | Montagne-Saint-Émilion di marca della distribuzione: stile da evoluzione della riga, livello Buono (satellite). |
| 17 | `3245414606241` | Vin saint chinian rouge |  |  |  | FR |  | redLight | good | redMedium | redLight / good / redMedium |  | denomination | Saint-Chinian rosso. |
| 18 | `3245414761223` | Rose de loire | La Cave d'Augustin Florent | rose |  | BE |  | rose | everyday | roseFresh | rose / everyday / roseFresh |  | denomination | Rosé de Loire. |
| 19 | `3248840303050` | Chat | Marie |  |  | CH |  | — | good | — | — / good / — |  | none | "Chat", produttore "Marie": nessun indizio. |
| 20 | `3250390030072` | Porto valadao |  | fortified |  | FR |  | fortified | good | portTawny | fortified / good / portTawny |  | denomination | Porto senza categoria: base della riga (Tawny/Colheita), pronto. |
| 21 | `3250391098149` | Cremant d'Alsace brut, cuvee St Sebastien Hauller, | Expert club | sparklingClassic |  | FR |  | sparklingClassic | good | classicFresh | sparklingClassic / good / classicFresh |  | denomination | Crémant d'Alsace brut. |
| 22 | `3254569806178` | vin gris | Pierre Chanau |  |  | FR |  | rose | everyday | roseFresh | rose / everyday / roseFresh |  | name | "Vin gris" è un rosato chiarissimo (non Pinot gris). |
| 23 | `3256220660730` | Vin rouge AOP Côtes de Duras Roc de Breyssac 75cl | U | redStructured |  | FR |  | redStructured | good | redMedium | redStructured / good / redMedium | T | denomination | Côtes de Duras AOP rosso (uvaggio bordolese); riga generata: stile da confermare. |
| 24 | `3256220660853` | Vin Rouge Cotes du Rhone AOP Croix des Alliances 37,5cl | U | redStructured |  | FR |  | redLight | good | redMedium | redLight / good / redMedium |  | denomination | Côtes du Rhône AOP rosso: tipo della riga, non quello della base. |
| 25 | `3256225432349` | Bergerac AOP rosé Roc de Breyssac fontaine à vin 3L | U | rose |  | FR |  | rose | everyday | roseFresh | rose / everyday / roseFresh | T | name | Bergerac rosé in fontaine 3 L. |
| 26 | `3256227446887` | Bergerac AOP rosé Roc de Breyssac 75cl | U | rose |  | FR |  | rose | everyday | roseFresh | rose / everyday / roseFresh | T | name | Bergerac rosé. |
| 27 | `3257985315347` | Champagne Veuve heringer |  | sparklingClassic |  | FR |  | sparklingClassic | good | classicFresh | sparklingClassic / good / classicFresh |  | denomination | Champagne. |
| 28 | `3262153108751` | Mouton cadet |  |  |  | CH |  | redStructured | good | redMedium | — / good / — |  | knowledge | Mouton Cadet: marchio di Bordeaux rosso; nessun indizio nel record. |
| 29 | `3263810142460` | Le Petit Cochonnet Grenache 2014 | La Compagnie Rhodanienne |  |  | FR | 2014 | redLight | good | redMedium | redLight / good / redMedium |  | grape | Grenache 2014. |
| 30 | `3264066214000` | Vin Belouson |  | white |  | FR |  | white | everyday | whiteFresh | white / everyday / whiteFresh |  | name | "Vin Belouson": designazione "vin" + marchio, senza denominazione: vino da tavola bianco. |
| 31 | `3306380095054` | château valet |  |  |  | FR |  | redStructured | good | redMedium | redStructured / good / redMedium |  | name | "Château" francese senza colore né denominazione: rosso di Bordeaux come regola BR3.7. |
| 32 | `3380330001203` | Vin blanc Pont de Caylus | La Maison des Terroirs Vivants | white |  | DE |  | white | everyday | whiteFresh | white / everyday / whiteFresh |  | name | "Vin blanc" + marchio, senza denominazione: vino da tavola. |
| 33 | `3391180003934` | Vin rouge |  | redStructured |  | FR |  | redLight | everyday | redFresh | redLight / everyday / redFresh |  | name | Vin rouge generico. |
| 34 | `3423290188376` | Chateau lataste |  |  |  | FR |  | redStructured | good | redMedium | redStructured / good / redMedium |  | name | "Château" francese senza colore né denominazione: rosso di Bordeaux come regola BR3.7. |
| 35 | `3435850001193` | Côté du Rhône |  |  |  | FR |  | redLight | good | redMedium | — / good / — |  | denomination | "Côté du Rhône" (refuso): Côtes du Rhône rosso. |
| 36 | `3436730002040` | Beaujolais-Villages Natural | Vignerons de Bel Air | redStructured |  | FR |  | redLight | everyday | redFresh | redLight / everyday / redFresh |  | denomination | Beaujolais-Villages: rosso fresco; il tipo della base (strutturato) è sbagliato. |
| 37 | `3438910042648` | Château chêne de Gombeau | Canon Fronsac |  |  | FR |  | redStructured | good | redAge | redStructured / good / redAge |  | producer | Canon-Fronsac nel campo produttore. |
| 38 | `3438910874362` | Château Cantegric |  |  |  | FR |  | redStructured | good | redMedium | redStructured / good / redMedium |  | name | "Château" francese senza colore né denominazione: rosso di Bordeaux come regola BR3.7. |
| 39 | `3453521250008` | Côtes de Bourg 2016 | Château Sauman | redStructured |  | FR | 2016 | redStructured | good | redAge | redStructured / good / redAge |  | denomination | Côtes de Bourg: riga da evoluzione, livello Buono (satellite). |
| 40 | `3459189106756` | Chateau Joumes - Fillon |  |  |  | FR |  | redStructured | good | redMedium | redStructured / good / redMedium |  | name | "Château" francese senza colore né denominazione: rosso di Bordeaux come regola BR3.7. |
| 41 | `3465932011598` | Vin rouge |  | redStructured |  | FR |  | redLight | everyday | redFresh | redLight / everyday / redFresh |  | name | Vin rouge generico. |
| 42 | `3477370000089` | Bugey Mondeuse | Maison Angelot |  |  | FR |  | redLight | good | redMedium | redLight / good / redFresh | T | grape | Mondeuse del Bugey: rosso di struttura media. |
| 43 | `3514123111385` | GERARD BERTRAND | Gris de gris pays d'oc |  |  | FR |  | rose | everyday | roseFresh | rose / everyday / roseFresh | T | name | "Gris de gris" IGP Pays d'Oc: rosato chiaro. |
| 44 | `3523151320195` | Fronsac |  | redStructured |  | DE |  | redStructured | good | redAge | redStructured / good / redAge |  | denomination | Fronsac generico: riga da evoluzione, livello Buono. |
| 45 | `3559660020226` | Vin biologique cahors domaine ichard |  |  |  | FR |  | redStructured | good | redAge | redStructured / good / redAge |  | denomination | Cahors (Malbec) di domaine. |
| 46 | `3574750000018` | Arbin Mondeuse - Château de Mérande | Château de Mérande | redStructured |  | FR |  | redStructured | good | redMedium | redLight / good / redFresh | T | name | Mondeuse di Arbin (cru di Savoia), la più strutturata delle Mondeuse. |
| 47 | `3604894755632` | Chateau Roquefeuille |  |  |  | FR |  | redStructured | good | redMedium | redStructured / good / redMedium |  | name | Château di Provenza (rosso, rosato e bianco): il rosso resta il più probabile, regola BR3.7; caso incerto. |
| 48 | `3653200928000` | vin rosé |  | rose |  | FR |  | rose | everyday | roseFresh | rose / everyday / roseFresh |  | name | Vin rosé generico. |
| 49 | `3660327011119` | Château Léoville Barton Saint-Julien 2011 |  |  |  | CH | 2011 | redStructured | good | redLong | redStructured / good / redLong |  | denomination | Léoville Barton, Saint-Julien secondo cru. |
| 50 | `3660989179653` | Cabernet Sauvignon |  |  |  | FR |  | redStructured | good | redMedium | redStructured / good / redAge |  | grape | Cabernet Sauvignon varietale senza altro: stile Medio, livello Buono. |
| 51 | `3700395900615` | Saint chou an | MAS DES HUPPÉS |  |  | FR |  | — | good | — | — / good / — |  | none | "Saint chou an" (gioco di parole su Saint-Chinian): nessun colore. |
| 52 | `3760014285851` | MOULIN A VENT |  |  |  | FR |  | redLight | good | redMedium | redLight / good / redMedium |  | denomination | Moulin-à-Vent, il cru più longevo del Beaujolais. |
| 53 | `3760045850165` | Bordeaux | Château Mémoires |  |  | LU |  | redStructured | good | redMedium | redStructured / good / — |  | denomination | Bordeaux senza colore: rosso (tipo principale), stile da confermare. |
| 54 | `3760054940079` | Chateau capion |  | redStructured |  | FR |  | redStructured | good | redMedium | redStructured / good / redMedium |  | dbType | Château Capion (Languedoc), solo il tipo della base. |
| 55 | `3760072792513` | Pessac-Léognan | Château Olivier | white |  | FR |  | white | good | whiteAge | white / good / whiteAge |  | denomination | Pessac-Léognan bianco (tipo della base bianco): bianco da evoluzione. |
| 56 | `3760082030070` | Roussette De Savoie |  | white |  | FR |  | white | good | whiteMedium | white / good / whiteMedium |  | denomination | Roussette de Savoie (Altesse). |
| 57 | `3760127953104` | Péchamant 2017 | vin | redStructured |  | FR | 2017 | redStructured | good | redAge | redStructured / good / redMedium |  | denomination | Pécharmant: il rosso più strutturato del Bergerac. |
| 58 | `3760128560073` | Côtes de Bergerac | Château Les Violines | white |  | FR |  | white | good | whiteMedium | white / good / whiteMedium |  | dbType | Côtes de Bergerac bianco (moelleux leggero): resta Bianco, non dolce da dessert. |
| 59 | `3760140143032` | Grande réserve | Saint-Emilion | redStructured |  | FR |  | redStructured | good | redAge | redStructured / good / redAge |  | producer | Saint-Émilion nel produttore; "Grande réserve" è una dicitura commerciale, non una qualifica. |
| 60 | `3760140250747` | Beaujolais Les Ronzières | Manoir du Carra | redStructured |  | FR |  | redLight | everyday | redFresh | redLight / everyday / redFresh |  | denomination | Beaujolais. |
| 61 | `3760164230138` | Vin |  |  |  | FR |  | — | good | — | — / good / — |  | none | Solo "Vin". |
| 62 | `3770001376004` | Quincy | André Pigeat | white |  | FR |  | white | everyday | whiteFresh | white / everyday / whiteFresh |  | denomination | Quincy (Sauvignon). |
| 63 | `4003301037467` | Dornfelder Rosé lieblich | Turmfalke |  |  | DE |  | rose | everyday | roseFresh | rose / everyday / roseFresh | T | name | Dornfelder rosé lieblich: rosato amabile, resta rosato. |
| 64 | `4011900535109` | Jules Mumm Medium Dry | Jules Mumm | sparklingTank |  | DE |  | sparklingTank | everyday | tankFresh | sparklingTank / everyday / tankFresh |  | dbType | Sekt Jules Mumm Medium Dry (Charmat). |
| 65 | `4041584003861` | Riesling Gewürztraminer, feinherb, Reinhessen | Andreas Oster | white |  | DE |  | white | good | whiteMedium | white / good / whiteMedium |  | denomination | Rheinhessen Riesling-Gewürztraminer feinherb. |
| 66 | `4044551028713` | Wine |  |  |  | GB |  | — | good | — | — / good / — |  | none | Solo "Wine". |
| 67 | `4049366005935` | Pinot Noir Rosé | Hans Baer |  |  | DE |  | rose | everyday | roseFresh | rose / everyday / roseFresh |  | name | Pinot Noir rosé: la parola rosé vince sul vitigno rosso. |
| 68 | `4056489121442` | Cava | Arestel | sparklingTank |  | BE |  | sparklingClassic | good | classicFresh | sparklingClassic / good / classicFresh |  | denomination | Cava (metodo tradizionale); il tipo della base (Charmat) è sbagliato. |
| 69 | `4333465053684` | Chardonnay bag in box | LOS PAGOS |  |  | DE |  | white | everyday | whiteFresh | white / everyday / whiteFresh |  | name | Chardonnay in bag in box. |
| 70 | `4335619420359` | Crémant de Bordeaux | Croix de Ceyssac |  |  | FR |  | sparklingClassic | good | classicFresh | sparklingClassic / good / classicFresh |  | denomination | Crémant de Bordeaux. |
| 71 | `5201022540504` | Vin |  |  |  | GR |  | — | good | — | — / good / — |  | none | Solo "Vin". |
| 72 | `5290011000365` | St John Commandaria | KEO |  |  | FR |  | sweet | good | sweetPassito | sweet / good / sweetPassito | T | name | Commandaria: dolce da uve appassite al sole. |
| 73 | `5400141032895` | CORDILLERA Chili wit BIB | CORDILLERA | white |  | BE |  | white | everyday | whiteFresh | white / everyday / whiteFresh |  | name | Bianco cileno in BIB ("wit" = bianco in olandese). |
| 74 | `5425030340028` | Night Orient | NIGHT ORIENT |  |  | FR |  | — | good | — | — / good / — |  | none | "Night Orient": nessun indizio. |
| 75 | `7290015951869` | Vin rosé |  | rose |  | FR |  | rose | everyday | roseFresh | rose / everyday / roseFresh |  | name | Vin rosé generico. |
| 76 | `7610807046175` | Terres D'Aquitaine Bordeaux Rosé 2015 |  |  |  | CH | 2015 | rose | everyday | roseFresh | rose / everyday / roseFresh |  | name | Bordeaux rosé. |
| 77 | `7610807241037` | Croix d'Amont : Côtes du Rhône |  |  |  | CH |  | redLight | good | redMedium | redLight / good / redMedium |  | denomination | Côtes du Rhône. |
| 78 | `7610827981982` | VIEUX PLANT DU PAYS PINOT NOIR DEFAYES & CRETTENAND |  |  |  | CH |  | redLight | good | redMedium | redLight / good / redMedium |  | grape | Pinot Noir del Vallese. |
| 79 | `7798104410414` | Clos de los Siete | MICHEL ROLLAND |  |  | AU |  | redStructured | good | redMedium | — / good / — |  | knowledge | Clos de los Siete (Mendoza, Rolland): nel record solo il nome e un paese sbagliato. |
| 80 | `8000037001515` | Prosecco |  | sparklingTank | Prosecco DOC | FR |  | sparklingTank | everyday | tankFresh | sparklingTank / everyday / tankFresh |  | denomination | Prosecco DOC. |
| 81 | `8000128165065` | Nero d Avola | Verga |  |  | IT |  | redLight | good | redMedium | redLight / good / redMedium |  | grape | Nero d'Avola. |
| 82 | `8000160643149` | Pinot grigio | Conti Formentini | white |  | IT |  | white | everyday | whiteFresh | white / everyday / whiteFresh |  | grape | Pinot grigio. |
| 83 | `8000453111461` | Marsala | Giarola |  | Marsala DOC | FR |  | fortified | good | fortifiedOther | fortified / good / fortifiedOther |  | denomination | Marsala DOC senza categoria. |
| 84 | `8003325600698` | Vino |  |  |  | IT |  | — | good | — | — / good / — |  | none | Solo "Vino". |
| 85 | `8003625018926` | Prosecco bio |  | sparklingTank | Prosecco DOC | IT |  | sparklingTank | everyday | tankFresh | sparklingTank / everyday / tankFresh |  | denomination | Prosecco DOC. |
| 86 | `8004006000103` | Colli Tortonesi - Barbera |  |  |  | ES |  | redLight | good | redMedium | redLight / good / redMedium | T | grape | Barbera dei Colli Tortonesi. |
| 87 | `8006030002412` | Chianti 2011 | Cecchi | redStructured | Chianti DOCG | NL | 2011 | redLight | good | redMedium | redLight / good / redMedium |  | denomination | Chianti DOCG 2011 (tipo della riga, non della base). |
| 88 | `8007555000112` | Vino Nobile di Montepulciano | Fattoria del Cerro | redStructured | Vino Nobile di Montepulciano DOCG | NL |  | redStructured | good | redAge | redStructured / good / redAge | T | denomination | Vino Nobile di Montepulciano. |
| 89 | `8008820168285` | Cuvee 21 dolce | Vinicola Decordi |  |  | IT |  | sweet | everyday | sweetAromatic | sweet / good / sweetAromatic |  | name | "Dolce" di marca da supermercato: dolce giovane; stile incerto. |
| 90 | `8011510003230` | Beccaccia rosso | Ronco |  |  | IT |  | redLight | everyday | redFresh | redLight / good / redFresh |  | name | "Beccaccia rosso": vino rosso da tavola. |
| 91 | `8053904174485` | Montepulciano d’Abruzzo | Salvia |  | Montepulciano d'Abruzzo DOC | IT |  | redLight | good | redMedium | redLight / good / redMedium |  | denomination | Montepulciano d'Abruzzo. |
| 92 | `8410013562013` | RAIMAT Castell de Raimat 2012 |  |  |  | CH | 2012 | — | good | — | — / good / — |  | none | "Castell de Raimat": nessun colore nel record. |
| 93 | `8410702027274` | Vino Rosado Tempranillo Félix Solis - La Mancha |  |  |  | ES |  | rose | everyday | roseFresh | rose / everyday / roseFresh | T | name | Rosado di Tempranillo, La Mancha. |
| 94 | `8411203042445` | Vino fino Corredera | Gracia Hermanos |  |  | ES |  | fortified | good | sherryFino | fortified / good / sherryFino | T | name | Fino (Gracia Hermanos, Montilla-Moriles). |
| 95 | `8420871200057` | Vino Blanco Albariño &quot;Torre la Moreira&quot; | Torre la Moreira | white |  | ES |  | white | everyday | whiteFresh | white / everyday / whiteFresh |  | grape | Albariño. |
| 96 | `8431876262957` | Vino do rueda viña espolon blanco verdejo | Viña espolón | white |  | ES |  | white | everyday | whiteFresh | white / everyday / whiteFresh |  | denomination | Rueda Verdejo. |
| 97 | `8437001025114` | Rueda Verdejo |  |  |  | ES |  | white | everyday | whiteFresh | white / everyday / whiteFresh |  | denomination | Rueda Verdejo. |
| 98 | `8437006755016` | Dehesa el carrascal |  | white |  | ES |  | white | good | whiteMedium | white / good / whiteMedium |  | dbType | Solo il tipo della base: bianco, stile da confermare. |
| 99 | `8437015640037` | Campo Arriba 2013 |  |  |  | CH | 2013 | — | good | — | — / good / — |  | none | "Campo Arriba 2013": nessun indizio di colore. |
| 100 | `9310495084968` | smitnoff seltzer | Smirnoff | white |  | AU |  | — | good | — | — / good / — |  | none | Smirnoff seltzer non è un vino: il tipo "white" della base è un errore da non preselezionare. |
