# Insieme di riferimento della conferma guidata (FR7.3)

## Fonti

- `inception/requirements-analysis/requirements.md`: FR1.1, FR7.3, FR7.4, NFR5.8.
- `rules.md` di questa fase: BR1, BR7.1–BR7.9 e le tabelle dei pesi.
- `packages/estimation/lib/src/label_fields.dart`, `vintage_parser.dart`, `recognizer.dart` e le tabelle del pacchetto (alias, alias deboli).
- Casi segnalati dal proprietario in Build and Test (messaggi 4e9809bc, c19931c2, 595f45dc): IT01, IT02, IT03.

## A cosa serve

- **Cos'è.** È la prova dei candidati e della regola di certezza (BR7.9).
- **Test.** In Code Generation diventa la fixture `packages/estimation/test/fixtures/label_reference_set.json` (D13), con `currentYear: 2026`. L'anno corrente vale per la ruota (anno di partenza 2024) e per gli anni plausibili (1900–2027).
- **Nomi.** Produttori e nomi dei vini sono **inventati**. Le denominazioni sono quelle pubbliche delle tabelle di FR3.1. Nessun testo copia un'etichetta vera.

**Come si legge.** Per ogni testo:
- il testo, come arriva da Lens: righe spezzate, maiuscole, rumore;
- il **valore giusto** di ogni campo chiave;
- lo **stato atteso**.

Il valore giusto della denominazione è il nome della riga di tabella; nel JSON si scrive la sua chiave. "—" vuol dire che il campo non ha un valore giusto nel testo.

| Stato | Significato |
|---|---|
| `C` | certo: il campo si compila da solo con il valore giusto |
| `I·1`, `I·2`, `I·3` | incerto: la guida lo chiede; il valore giusto è il 1°, 2° o 3° candidato |
| `I·✗` | incerto, il valore giusto è **scritto nel testo** ma **non** è tra i candidati: si compone toccando le parole, si scrive con "Modifica" o, per l'annata, si sceglie sulla ruota |
| `I·?` | incerto, il valore giusto **non è nel testo** (testo parziale): non conta tra i valori fuori dai candidati (BR7.9) |
| `I·—` | incerto e senza valore giusto (vino senza annata): la ruota parte dal 2024, la risposta giusta è "Senza annata" |
| `A` | assente (BR7.8): nessun candidato e nessun indizio; non si chiede e resta vuoto |
| `A·✗` | assente, ma il valore c'è nel testo: un limite noto, da scrivere a mano |

Il rango atteso (`·1`, `·2`, `·3`) è informativo. Il test controlla le percentuali di BR7.9, non il rango di ogni testo (BR7.9).

**Nota "Perché".** Ogni testo ha una riga che cita i punteggi dei candidati principali, calcolati con i pesi di `rules.md`. Serve a chi tara i pesi in Code Generation.

## Riepilogo

| Lingua | Testi | Denominazione I | Produttore I | Nome I | Annata I | Campi incerti |
|---|---|---|---|---|---|---|
| it | 14 | 1 | 3 | 11 | 4 | 19 |
| fr | 14 | 6 | 4 | 5 | 3 | 18 |
| es | 12 | 4 | 3 | 10 | 3 | 20 |
| en | 10 | 3 | 4 | 9 | 3 | 19 |
| de | 10 | 5 | 2 | 9 | 2 | 18 |
| pt | 9 | 2 | 5 | 7 | 3 | 17 |
| **Totale** | **69** | **21** | **21** | **51** | **18** | **111** |

I conteggi sono rifatti con uno script sulle righe "Atteso" di questo file, dopo la revisione (testo breve, parole riusabili, tipo con denominazione incerta, 4 testi nuovi: FR14, ES11, ES12, DE10).

Sui criteri di FR7.3 e BR7.9:
- **Campi incerti per testo.** In media 111 / 69 = **1,61** (al massimo 2). Il massimo è **4**: FR11, ES08, EN05 e PT09.
- **Almeno 15 incerti per campo.** Denominazione 21, produttore 21, nome 51, annata 18.
- **Valore giusto scritto nel testo e fuori dai candidati** (`I·✗`): **10 testi** (IT03, IT12, FR07, FR08, ES12, EN03, DE05, DE09, DE10, PT07), per 12 campi. Non contano IT14 e PT03, la cui annata non è nel testo (`I·?`), né ES10, il cui produttore è `A·✗`.
- **Rango del valore giusto.** Ci sono 88 campi incerti con il valore giusto tra i candidati: 20 denominazioni, 19 produttori, 46 nomi (31 primi, 13 secondi, 2 terzi) e 3 annate. Il valore giusto è primo in **73 su 88 (83%)** e tra i primi 3 in **88 su 88 (100%)**. Il criterio chiede almeno il 70% e il 90%.
- **Campi attesi certi.** Denominazione 44, produttore 46, nome 18, annata 51. Gli assenti sono 6: 4 denominazioni (`A`), 1 produttore `A` e 1 produttore `A·✗`. Le soglie di FR1.1 si misurano su questi (BR7.9).
- **Vini senza annata** (`I·—`): 9. **Annata non nel testo** (`I·?`): 2.
- **Tipo con la denominazione incerta** (BR7.8 b, BR7.20): FR14 e ES11 controllano che il tipo resti vuoto senza guida e prenda il tipo della riga dopo "Sì".

**Campi compilati senza guida (misura riportata, non bloccante, BR7.9).** È la conseguenza accettata di FR7.3: un campo incerto resta vuoto finché non si risponde alla guida.

| Campo | Compilati da soli | Percentuale |
|---|---|---|
| Denominazione | 44 su 69 | 64% |
| Produttore | 46 su 69 | 67% |
| Nome | 18 su 69 | 26% |
| Annata | 51 su 69 | 74% |

Senza guida il nome si compila in circa un testo su quattro; con la guida la prima proposta per il nome è giusta in 31 casi su 46.
- **Anni di fondazione:** IT05, IT08, FR11, ES06, EN04, DE03, DE08, PT05, PT09. **Anni di imbottigliamento:** IT07, FR07, PT04. **Premi e anniversari:** IT08, IT09, FR12.

---

## Italiano (14)

### IT01 — caso del proprietario
```text
CASCINA CASTLET
Barbera d'Asti Superiore
14,5% vol  75 cl
2019
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Barbera d'Asti DOCG | Cascina Castlet | Barbera d'Asti Superiore | 2019 |
| Atteso | C | I·1 | I·1 | C |

**Perché.**
- **Testo breve:** 3 righe utili (la riga del volume si scarta).
- **Denominazione:** 0,55 + 0,10 + 0,25 (testa del testo breve) = 0,90.
- **Produttore:** PC "cascina" 0,45 + 0,15 + 0,10 = 0,70.
- **Nome:** NG 0,45 contro NJ 0,30. La riga "CASCINA CASTLET" è una riga PC: vale come marca solo per NC, quindi niente NA.
- **Annata:** 0,50 + 0,20 + 0,30 = 1,00.

Due domande: "Domanda 1 di 2: Cascina Castlet è il produttore?". Se il nome proposto viene rifiutato, si compone toccando "Barbera", "d'Asti" e "Superiore": sono parole della denominazione, ma restano selezionabili (BR7.15).

### IT02 — caso "Toscana" (oggi sbagliato)
```text
Tenuta Sconosciuta
Rosso Toscana IGT
2020
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Toscana | Tenuta Sconosciuta | Rosso Toscana | 2020 |
| Atteso | C | C | I·1 | C |

**Perché.**
- **Denominazione:** 0,55 + 0,30 = 0,85.
- **Produttore:** PB 0,70 + 0,15 + 0,10 = 0,95.
- **Nome:** NG "Rosso Toscana" 0,45, NH "Toscana" 0,30, NJ 0,30. Oggi il nome diventa "Toscana": ora resta vuoto e la guida propone prima "Rosso Toscana".

### IT03 — caso del proprietario, righe spezzate da Lens
```text
CASCINA
CASTLET
BARBERA D'ASTI
SUPERIORE
DENOMINAZIONE DI ORIGINE
CONTROLLATA E GARANTITA
2019
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Barbera d'Asti DOCG | Cascina Castlet | Barbera d'Asti Superiore | 2019 |
| Atteso | C | I·✗ | I·2 | C |

**Perché.**
- **Denominazione:** indicatore a 2 righe, quindi 0,55 + 0,20 + 0,10 = 0,85.
- **Produttore:** l'unico candidato è "Cascina" (PC 0,45 + 0,15 + 0,10 − 0,50 perché fatto solo di una parola del produttore = 0,20). "CASTLET" è a p = 1 e non è un candidato PE (solo p = 0). Il produttore giusto è spezzato su due righe: si compone toccando CASCINA e CASTLET, che diventa "Cascina Castlet" (BR7.15).
- **Nome:** la riga CASCINA è una riga PC e non è una marca; CASTLET è l'unica marca, con la penalità Q. NA "Barbera d'Asti Superiore Castlet" 0,85 − 0,30 = 0,55, NG "Barbera d'Asti Superiore" 0,50, marca sola 0,50 − 0,30 = 0,20.

### IT04
```text
BAROLO
DENOMINAZIONE DI ORIGINE CONTROLLATA E GARANTITA
Bricco Sorì Alto
2018
Imbottigliato all'origine da Azienda Agricola Ferro Lungo
La Morra - Italia
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Barolo DOCG | Azienda Agricola Ferro Lungo | Barolo Bricco Sorì Alto | 2018 |
| Atteso | C | C | C | C |

**Perché.**
- **Denominazione:** 0,55 + 0,30 + 0,05 = 0,90.
- **Produttore:** PA 0,90.
- **Nome:** NA 0,85 contro NG 0,45. "La Morra - Italia" è una riga di origine (BR7.2) e non è una marca.

### IT05 — anno di fondazione
```text
Fattoria di Poggio Ventoso
dal 1921
CHIANTI CLASSICO
Riserva
Denominazione di Origine Controllata e Garantita
Vendemmia 2019
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Chianti Classico DOCG | Fattoria di Poggio Ventoso | Chianti Classico Riserva | 2019 |
| Atteso | C | C | I·1 | C |

**Perché.**
- **Denominazione:** indicatore a 2 righe, 0,85.
- **Produttore:** PB 0,95.
- **Nome:** nessuna marca, NG con la riga "Riserva" 0,50.
- **Annata:** 1921 vale 0,05 (fondazione); 2019 vale 0,50 + 0,40 + 0,30 = 1,00.

### IT06 — senza annata, rumore di Lens
```text
PROSECCO
DENOMINAZIONE DI ORIGINE CONTROLLATA
EXTRA DRY
SPUMANTE
Prodotto e imbottigliato da Vigne del Sile S.r.l., Roncade - Italia
11% vol 750ml
www.vignedelsile.it
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Prosecco DOC | Vigne del Sile S.r.l. | Prosecco Extra Dry | — |
| Atteso | C | C | I·1 | I·— |

**Perché.**
- **Nome:** NG con la prima riga di stile 0,50.
- **Annata:** nessun anno; la ruota parte dal 2024 e la risposta giusta è "Senza annata". Le righe di volume e del sito si scartano.

### IT07 — anno di imbottigliamento
```text
AMARONE DELLA VALPOLICELLA
CLASSICO
DENOMINAZIONE DI ORIGINE CONTROLLATA E GARANTITA
2017
Corte Sasso Nero
Imbottigliato nel 2022 da Corte Sasso Nero, Negrar (VR)
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Amarone della Valpolicella DOCG | Corte Sasso Nero | Amarone della Valpolicella Classico | 2017 |
| Atteso | C | C | I·1 | C |

**Perché.**
- **Denominazione:** 0,55 + 0,20 + 0,10 = 0,85. "Valpolicella", contenuta nell'alias più lungo, vale 0,55 + 0,20 − 0,30 = 0,45: distacco 0,40.
- **Produttore:** PA' 0,75 più la stessa riga, due fonti: 0,85.
- **Nome:** NG con "Classico" 0,50.
- **Annata:** 2022 vale 0,10 (imbottigliamento); 2017 vale 1,00.

### IT08 — fondazione e anniversario
```text
Tenuta Pietra Lavica
1890 - 2025
135 anni di storia
ETNA ROSSO
Denominazione di Origine Controllata
Contrada Feudo
2021
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Etna Rosso DOC | Tenuta Pietra Lavica | Etna Rosso Contrada Feudo | 2021 |
| Atteso | C | C | C | C |

**Perché.**
- **Riga dell'anniversario.** È rumore per il nome.
- **Nome:** NA 0,85 contro NG 0,45.
- **Annata:** 1890 è prima del 1900; 2025 è in un intervallo, 0,15; 2021 vale 1,00.

### IT09 — premio
```text
Grande Vino Rosso d'Italia
Medaglia d'Oro Concorso Enologico 2018
2019
Imbottigliato da Cantine Riunite del Sole, Bari
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | — | Cantine Riunite del Sole | Grande Vino Rosso d'Italia | 2019 |
| Atteso | A | C | I·1 | C |

**Perché.**
- **Denominazione:** nessun alias e nessun indicatore, quindi assente.
- **Nome:** NB con più di 3 parole 0,70.
- **Annata:** 2018 vale 0,15 (premio); 2019 vale 1,00.

### IT10 — anno dentro la riga del produttore
```text
CANTINA VALLE SCURA 1957
LUGANA
Denominazione di Origine Controllata
2022
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Lugana DOC | Cantina Valle Scura | Lugana | 2022 |
| Atteso | C | C | I·1 | I·1 |

**Perché.**
- **Produttore:** 0,70 + 0,15 + 0,10 − 0,15 = 0,80, con l'anno tagliato.
- **Nome:** NG 0,45.
- **Annata:** 2022 vale 0,70 e 1957 vale 0,50, senza parole che li distinguono: distacco 0,20.

### IT11 — vitigno in testa
```text
PRIMITIVO
Salento
Indicazione Geografica Tipica
Masseria Ulivo Grande
2023
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Salento | Masseria Ulivo Grande | Masseria Ulivo Grande Primitivo | 2023 |
| Atteso | C | I·1 | I·1 | C |

**Perché.**
- **Produttore:** PC 0,45 + 0,10 = 0,55.
- **Nome:** NC 0,70; marca sola 0,55; NG "Salento" 0,45; vitigno 0,40.

### IT12 — errori di lettura di Lens
```text
TENUTA CA' BIANCA
BARBARESOO
DENOMINAZIONE DI ORIGINE
CONTROLLATA E GARANTITA
Rio Sordo
2O19
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Barbaresco DOCG | Tenuta Ca' Bianca | Barbaresco Rio Sordo | 2019 |
| Atteso | I·✗ | C | I·✗ | I·✗ |

**Perché.**
- **Denominazione:** c'è un indicatore ma nessun alias, quindi è incerta e senza candidati. La guida propone di comporla; BARBARESOO non è nelle tabelle, quindi si corregge con "Modifica".
- **Nome:** due righe di marca, ND: "Barbaresoo" 0,60, "Rio Sordo" 0,50.
- **Annata:** "2O19" non è un anno; la ruota parte dal 2024.

### IT13 — produttore da due fonti
```text
Valpolicella Ripasso
Denominazione di Origine Controllata
Classico Superiore
Ca' dei Mori
2021
Imbottigliato da Ca' dei Mori Società Agricola, Fumane (VR) - Italia
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Valpolicella Ripasso DOC | Ca' dei Mori Società Agricola | Valpolicella Ripasso Classico Superiore | 2021 |
| Atteso | C | C | I·1 | C |

**Perché.**
- **Produttore:** PA 0,90 più la riga "Ca' dei Mori", due fonti: 1,00.
- **Nome:** la riga del produttore non è una marca; NG con "Classico Superiore" 0,50.

### IT14 — testo parziale, senza indicatore né annata
```text
Vermentino di Sardegna
Is Arenas
Cantina del Golfo
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Vermentino di Sardegna | Cantina del Golfo | Vermentino di Sardegna Is Arenas | non nel testo |
| Atteso | C | C | C | I·? |

**Perché.**
- **Testo breve:** 3 righe.
- **Denominazione:** 0,55 + 0,10 + 0,25 = 0,90.
- **Produttore:** PB 0,70 + 0,10 = 0,80.
- **Nome:** NA con la denominazione certa 0,85, marca sola 0,50, NG 0,45.
- **Annata:** il vino ha un'annata che il testo non riporta: si sceglie sulla ruota. Non conta tra i "valori fuori dai candidati", perché il valore non è nel testo.

---

## Français (14)

### FR01
```text
CHÂTEAU LA GRAVIÈRE HAUTE
SAINT-ÉMILION GRAND CRU
Appellation Saint-Émilion Grand Cru Contrôlée
2018
Mis en bouteille au château
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Saint-Émilion | Château La Gravière Haute | Château La Gravière Haute | 2018 |
| Atteso | C | C | C | C |

**Perché.**
- **Denominazione:** 0,95.
- **Produttore:** PB 0,95.
- **Nome:** NE 0,85.

### FR02 — alias debole senza indicatore
```text
Domaine des Roches Fines
BOURGOGNE
Pinot Noir
2022
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Bourgogne | Domaine des Roches Fines | Bourgogne Pinot Noir | 2022 |
| Atteso | I·1 | C | I·1 | C |

**Perché.**
- **Denominazione:** "bourgogne" è debole: 0,25.
- **Nome:** NI 0,60, NF 0,55, NJ 0,50.

### FR03 — più produttori
```text
CHÂTEAU MOULIN DE BEL-AIR
Bordeaux Supérieur
Appellation Bordeaux Supérieur Contrôlée
2020
Vignobles Martineau Frères
Propriétaires à Saint-Seurin
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Bordeaux (riga `Bordeaux`, alias "bordeaux superieur") | Château Moulin de Bel-Air | Château Moulin de Bel-Air | 2020 |
| Atteso | C | I·1 | C | C |

**Perché.**
- **Denominazione:** l'alias forte "bordeaux superieur" (2 parole) con l'indicatore vicino: 0,95. La riga di tabella è Bordeaux.
- **Produttore:** tre righe PB, con "vignobles" e "proprietaire" nella lista di BR7.4 (0,85, 0,70, 0,70), nessuna unica: distacco 0,15.
- **Nome:** NE 0,85.

### FR04 — Champagne senza annata
```text
CHAMPAGNE
MAISON VERMONT-LAURENT
BRUT RÉSERVE
Élaboré par Vermont-Laurent, Épernay - France
12% vol
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Champagne | Maison Vermont-Laurent | Champagne Brut Réserve | — |
| Atteso | I·1 | C | I·1 | I·— |

**Perché.**
- **Denominazione:** 0,55 + 0,05 = 0,60, senza indicatore.
- **Produttore:** PA "élaboré par" più la riga Maison, due fonti: 1,00.
- **Nome:** NG con la riga "Brut Réserve" 0,50. Dopo "Sì" alla denominazione, il nome proposto "Champagne Brut Réserve" usa la parola CHAMPAGNE già usata: "Sì" resta ammesso e la parola resta selezionabile per comporre (BR7.12, BR7.15).

### FR05 — sito web e indirizzo
```text
SANCERRE
Appellation Sancerre Contrôlée
Les Caillottes
2023
Domaine Henri Lauvergne
Vigneron à Bué - Cher - France
www.lauvergne-sancerre.fr
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Sancerre | Domaine Henri Lauvergne | Sancerre Les Caillottes | 2023 |
| Atteso | C | C | C | C |

**Perché.**
- **Produttore:** PB 0,70 + 0,10 = 0,80. La riga "Vigneron…" è una riga di origine.
- **Nome:** NA 0,85.

### FR06
```text
Côtes du Rhône Villages
Les Hauts Cailloux
Appellation Côtes du Rhône Villages Contrôlée
Cave des Vignerons de Sablet
Rouge 2021
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Côtes du Rhône Villages | Cave des Vignerons de Sablet | Côtes du Rhône Villages Les Hauts Cailloux | 2021 |
| Atteso | C | C | C | C |

**Perché.**
- **Denominazione:** 0,95. "Côtes du Rhône", contenuta, ha l'occorrenza migliore nella riga dell'indicatore: 0,55 + 0,10 + 0,30 − 0,30 = 0,65; distacco 0,30.
- **Nome:** NA 0,85.
- **Annata:** 0,50 + 0,30 = 0,80.

### FR07 — data di imbottigliamento
```text
Domaine Klein-Aubert
Riesling
Vendanges Tardives
Alsace
2017
Mis en bouteille le 12/03/2019
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Alsace | Domaine Klein-Aubert | Riesling Vendanges Tardives | 2017 |
| Atteso | I·1 | C | I·✗ | C |

**Perché.**
- **Denominazione:** 0,55, senza indicatore.
- **Nome:** i candidati sono "Alsace Riesling" 0,60, "Riesling" 0,55 e "Alsace Vendanges Tardives" 0,50. Il nome giusto si compone toccando "Riesling", "Vendanges" e "Tardives".
- **Annata:** 2019 è dopo "mis en bouteille" e vale 0,10.

### FR08 — Lens senza a capo
```text
Morgon Côte du Py Appellation Morgon Contrôlée Domaine du Vieux Pressoir 2020 Mis en bouteille à la propriété 13% vol 75cl
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Morgon | Domaine du Vieux Pressoir | Morgon Côte du Py | 2020 |
| Atteso | C | I·1 | I·✗ | C |

**Perché.**
- **Riga lunga.** È più lunga di 8 parole: si toglie solo "13% vol 75cl" (BR7.2a).
- **Produttore:** PG 0,50 + 0,10 = 0,60.
- **Nome:** solo "Morgon" (NG sull'alias, 0,45). Il nome giusto si compone con 4 parole.

### FR09 — denominazione contenuta in un'altra
```text
CHÂTEAU LES TROIS ORMEAUX
LALANDE-DE-POMEROL
Appellation Lalande-de-Pomerol Contrôlée
2019
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Lalande-de-Pomerol | Château Les Trois Ormeaux | Château Les Trois Ormeaux | 2019 |
| Atteso | C | C | C | C |

**Perché.** Lalande-de-Pomerol vale 0,95; "Pomerol", contenuta, vale 0,55 − 0,30 + 0,30 = 0,55, con distacco 0,40.

### FR10 — négociant
```text
Château Belle Rive
BORDEAUX
Appellation Bordeaux Contrôlée
Mis en bouteille par SAS Les Vins de Lormont, 33310 Lormont
2022
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Bordeaux | Château Belle Rive | Château Belle Rive | 2022 |
| Atteso | C | I·1 | C | C |

**Perché.**
- **Denominazione:** debole con indicatore vicino, quindi 0,55 + 0,30 = 0,85.
- **Produttore:** PB unico 0,95 contro PA "SAS Les Vins de Lormont" 0,90: distacco 0,05.

### FR11 — fondazione prima del 1900
```text
Crémant de Loire
Brut
Méthode Traditionnelle
Caves Saint-Florent depuis 1885
Saumur - France
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Crémant de Loire | Caves Saint-Florent | Crémant de Loire Brut | — |
| Atteso | I·1 | I·1 | I·1 | I·— |

**Perché.**
- **Denominazione:** 0,55 + 0,10 + 0,05 = 0,70.
- **Produttore:** PB con fondazione tagliata, 0,70 + 0,10 − 0,15 = 0,65.
- **Nome:** NG con "Brut" 0,50.
- **Annata:** 1885 non è plausibile.

### FR12 — millésime e medaglia
```text
Château Doisy-Rieussec
SAUTERNES
Appellation Sauternes Contrôlée
Millésime 2015
Grand Vin de Bordeaux
Médaille d'Or Concours de Bordeaux 2017
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Sauternes | Château Doisy-Rieussec | Château Doisy-Rieussec | 2015 |
| Atteso | C | C | C | C |

**Perché.**
- **"Grand vin".** È una parola di stile e non una marca.
- **Annata:** 2015 vale 1,00; 2017 vale 0,15 (premio).

### FR13 — anno nel nome della cuvée
```text
CHAMPAGNE
Cuvée 2000
Extra Brut
Blanc de Blancs
R. Lemaire-Fontaine, Récoltant-Manipulant, Avize
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Champagne | R. Lemaire-Fontaine | Cuvée 2000 | — |
| Atteso | I·1 | C | C | I·— |

**Perché.**
- **Nome:** NB "Cuvée 2000" 0,85, con l'anno tenuto (BR7.5).
- **Annata:** 2000 dopo "cuvée" ha un segnale negativo, quindi non riceve "unico": 0,50 − 0,30 = 0,20, incerta. La risposta giusta è "Senza annata".

### FR14 — "Rouge" con la denominazione incerta (tipo)
```text
Domaine de la Combe Haute
Vin Rouge
Côtes de Bourg
2020
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Côtes de Bourg | Domaine de la Combe Haute | Domaine de la Combe Haute | 2020 |
| Atteso | I·1 | C | C | C |

**Perché.**
- **Denominazione:** 4 righe, non è un testo breve; nessun indicatore e nessun paese: 0,55 + 0,10 = 0,65.
- **Nome:** NE 0,85 contro NG 0,45.
- **Tipo (BR7.8 b, BR7.20):** senza guida il tipo resta **vuoto**: "Rouge" dice rosso, ma senza la denominazione non si sceglie tra redLight e redStructured. Dopo "Sì" a Côtes de Bourg il tipo diventa **redStructured** (tipo della riga). Il test controlla tutti e due i momenti.

---

## Español (12)

### ES01
```text
BODEGAS VIÑA ALTA
RIOJA
Denominación de Origen Calificada
CRIANZA
2020
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Rioja | Bodegas Viña Alta | Rioja Crianza | 2020 |
| Atteso | C | C | I·1 | C |

**Perché.**
- **Denominazione:** debole con indicatore vicino, 0,85.
- **Nome:** NG con "Crianza" 0,50.

### ES02 — "toro" debole, marca con l'alias
```text
Toro Bravo
Tinta de Toro
Bodega Los Arcos
2019
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Toro | Bodega Los Arcos | Toro Bravo | 2019 |
| Atteso | I·1 | C | I·2 | C |

**Perché.**
- **Denominazione:** debole senza indicatore, 0,25.
- **Produttore:** PB unico 0,80.
- **Nome:** NC "Toro Bravo Tinta de Toro" 0,70, marca sola 0,55.

### ES03 — produttore da due fonti
```text
PAGO DEL CIERZO
Ribera del Duero
Denominación de Origen
RESERVA 2016
Embotellado por Bodegas Pago del Cierzo S.L., Roa (Burgos) - España
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Ribera del Duero | Bodegas Pago del Cierzo S.L. | Ribera del Duero Reserva | 2016 |
| Atteso | C | C | I·1 | C |

**Perché.**
- **Produttore:** PA più la prima riga, due fonti: 1,00.
- **Nome:** NG con "Reserva" 0,50.
- **Annata:** 0,50 + 0,30 = 0,80.

### ES04 — Cava senza indicatore
```text
MIRADOR
CAVA
BRUT NATURE
Reserva
Elaborado por Cavas Mirador, Sant Sadurní d'Anoia
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Cava | Cavas Mirador | Cava Brut Nature Reserva | — |
| Atteso | I·1 | C | I·1 | I·— |

**Perché.**
- **Denominazione:** "cava" debole, 0,25.
- **Produttore:** PA "elaborado por" più "MIRADOR", due fonti: 1,00.
- **Nome:** NG 0,50.

### ES05 — catalano, "collita"
```text
Clos de l'Ermità Vella
Priorat
Denominació d'Origen Qualificada
Collita 2017
Vi negre
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Priorat | Clos de l'Ermità Vella | Clos de l'Ermità Vella | 2017 |
| Atteso | C | C | C | C |

### ES06 — "desde"
```text
Pazo de Lourido
Albariño
Rías Baixas
Denominación de Origen
2023
Desde 1987
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Rías Baixas | Pazo de Lourido | Pazo de Lourido Albariño | 2023 |
| Atteso | C | I·1 | I·1 | C |

**Perché.**
- **Produttore:** PC "pazo" 0,70.
- **Nome:** NC 0,70.
- **Annata:** 1987 vale 0,05; 2023 vale 1,00.

### ES07 — lotto e solfiti
```text
JUMILLA
Denominación de Origen Protegida
MONASTRELL
Bodegas Hoya del Viento
Contiene sulfitos
L-23/118
Cosecha 2021
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Jumilla | Bodegas Hoya del Viento | Jumilla Monastrell | 2021 |
| Atteso | C | C | I·1 | C |

**Perché.**
- **Rumore.** "L-23/118" è una riga numerica (BR7.2f).
- **Nome:** NI 0,60, NF 0,55.

### ES08 — quattro campi incerti
```text
Señorío de Valcuerna
Garnacha Viñas Viejas 2019
Navarra
Edición 2021
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Navarra | Señorío de Valcuerna | Garnacha Viñas Viejas | 2019 |
| Atteso | I·1 | I·1 | I·1 | I·1 |

**Perché.**
- **Denominazione:** debole, 0,25.
- **Produttore:** PC 0,70.
- **Nome:** ND tra 3 righe, la più lunga 0,60.
- **Annata:** 2019 e 2021 valgono 0,50; a parità vince il primo nel testo.

### ES09 — vino senza denominazione
```text
VIÑA DEL PÁRAMO
Vino de España
Tempranillo
Bodegas del Páramo
2022
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | — | Bodegas del Páramo | Viña del Páramo Tempranillo | 2022 |
| Atteso | A | C | I·1 | C |

**Perché.**
- **Produttore:** PB unico 0,80; la riga PE non conta per l'unicità.
- **Nome:** NC 0,70.

### ES10 — indicatore basco, produttore senza parole chiave
```text
GETARIAKO TXAKOLINA
Jatorri Deitura
Txomin Etxeberria
2024
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Getariako Txakolina | Txomin Etxeberria | Txomin Etxeberria | 2024 |
| Atteso | C | A·✗ | C | C |

**Perché.**
- **Produttore:** nessuna parola di produttore e nessuna frase di imbottigliamento, quindi assente. È un limite noto: si scrive a mano.
- **Nome:** NB 0,85.

### ES11 — "Tinto" con la denominazione incerta (tipo)
```text
FINCA LOS OLIVOS
Vino Tinto
Ribera del Guadiana
2021
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Ribera del Guadiana | Finca Los Olivos | Finca Los Olivos | 2021 |
| Atteso | I·1 | I·1 | I·2 | C |

**Perché.**
- **Denominazione:** 0,55 + 0,10 = 0,65.
- **Produttore:** PC "finca" 0,45 + 0,15 + 0,10 = 0,70.
- **Nome:** la riga PC non è una marca: NG "Ribera del Guadiana" 0,45, NJ "Finca Los Olivos" 0,30.
- **Tipo:** vuoto senza guida; dopo "Sì" alla denominazione diventa **redLight** (tipo della riga).

### ES12 — annata in numeri romani
```text
Bodegas Altamira
Rioja
Denominación de Origen Calificada
Reserva
Cosecha MMXVIII
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Rioja | Bodegas Altamira | Rioja Reserva | 2018 |
| Atteso | C | C | I·1 | I·✗ |

**Perché.**
- **Denominazione:** "rioja" debole con l'indicatore vicino: 0,55 + 0,30 = 0,85.
- **Nome:** NG con "Reserva" 0,50.
- **Annata:** "MMXVIII" è scritto nel testo ma non è un anno di 4 cifre: nessun candidato; si sceglie 2018 sulla ruota.

---

## English (10)

### EN01 — Napa senza paese
```text
HOLLOW OAK
Cabernet Sauvignon
Napa Valley
2019
Produced and bottled by Hollow Oak Cellars, St. Helena, CA
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Napa Valley | Hollow Oak Cellars | Hollow Oak Cabernet Sauvignon | 2019 |
| Atteso | I·1 | C | I·3 | C |

**Perché.**
- **Denominazione:** 0,65; USA non scritto.
- **Nome:** NI "Napa Valley Cabernet Sauvignon" 0,60, NF 0,55, NJ con la riga in testa 0,50.

### EN02
```text
Red Gum Creek
Shiraz
Barossa Valley
2021
Product of Australia
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Barossa Valley | Red Gum Creek | Red Gum Creek Shiraz | 2021 |
| Atteso | C | I·1 | I·1 | C |

**Perché.**
- **Denominazione:** 0,55 + 0,10 + 0,25 = 0,90, paese fuori dall'UE.
- **Produttore:** PE 0,35 + 0,10 = 0,45.
- **Nome:** NC 0,70.

### EN03 — annata a due cifre
```text
Kōwhai Ridge
Sauvignon Blanc ’24
Marlborough
Wine of New Zealand
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Marlborough | Kōwhai Ridge | Kōwhai Ridge Sauvignon Blanc | 2024 |
| Atteso | C | I·1 | I·1 | I·✗ |

**Perché.**
- **Denominazione:** 0,55 + 0,25 = 0,80.
- **Annata:** "’24" non è un anno di 4 cifre. La ruota parte comunque dal 2024 (anno corrente − 2), quindi basta "Conferma".

### EN04 — "Est."
```text
BERGWIND ESTATE
Est. 1692
Chenin Blanc
Wine of Origin Swartland
Vintage 2023
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Swartland | Bergwind Estate | Chenin Blanc | 2023 |
| Atteso | C | C | I·2 | C |

**Perché.**
- **Nome:** NI "Swartland Chenin Blanc" 0,60, NF 0,55.

### EN05 — retro con un altro anno
```text
FERN HOLLOW
Willamette Valley
Pinot Noir
2022
The 2021 growing season began with a cool spring
and ended with a warm harvest.
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Willamette Valley | Fern Hollow | Fern Hollow Pinot Noir | 2022 |
| Atteso | I·1 | I·1 | I·2 | I·1 |

**Perché.**
- **Prosa.** Le due righe di prosa non danno nomi (BR7.2e).
- **Nome:** NI 0,60; NC 0,70 − 0,30 (Q) = 0,40, prima del vitigno 0,40 perché viene prima nel testo.
- **Annata:** 2022 vale 0,70 e 2021 vale 0,50.

### EN06
```text
Sonoma Coast
Chardonnay
2022
Grown, produced and bottled by Driftwood Point Winery, Healdsburg, CA
Product of USA
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Sonoma Coast | Driftwood Point Winery | Sonoma Coast Chardonnay | 2022 |
| Atteso | C | C | I·1 | C |

### EN07 — denominazione fuori tabella, rumore
```text
Mount Arbel Winery
Galilee
Cabernet Sauvignon
2020
Product of Israel
Kosher for Passover
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | — (Galilee non è nelle tabelle) | Mount Arbel Winery | Cabernet Sauvignon | 2020 |
| Atteso | A | C | I·3 | C |

**Perché.**
- **Nome:** ND "Kosher for Passover" 0,60, "Galilee" 0,50, NF con marca 0,40.

### EN08 — Port senza annata
```text
QUINTA DA SERRA ALTA
Fine Ruby Port
Porto
Product of Portugal
20% vol 75cl
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Porto | Quinta da Serra Alta | Fine Ruby Port | — |
| Atteso | I·1 | C | C | I·— |

**Perché.**
- **Denominazione:** debole con il paese vicino, 0,55 + 0,05 = 0,60.
- **Nome:** NB 0,85.

### EN09
```text
VALLE DEL CÓNDOR
RESERVA
Carmenère
Colchagua Valley
Harvest 2021
Wine of Chile
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Valle de Colchagua | Valle del Cóndor | Valle del Cóndor Carmenère | 2021 |
| Atteso | C | I·1 | I·1 | C |

### EN10 — solo rumore e vitigno
```text
@condorwines
8 410702 016254
SCAN FOR TASTING NOTES
Merlot
2023
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | — | — | Merlot | 2023 |
| Atteso | A | A | I·2 | C |

**Perché.**
- **Nome:** NB con 4 parole 0,70 ("Scan for Tasting Notes"), NF con marca 0,40.
- **Produttore:** PE ammette al massimo 3 parole, quindi assente.

---

## Deutsch (10)

### DE01 — "2022er" e numero A.P.
```text
Weingut Brückner-Stein
2022er
Lindauer Sonnenhang
Riesling Kabinett
Mosel
Qualitätswein mit Prädikat
A.P.Nr. 2 602 041 07 23
Gutsabfüllung
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Mosel | Weingut Brückner-Stein | Lindauer Sonnenhang Riesling Kabinett | 2022 |
| Atteso | C | C | I·1 | C |

**Perché.**
- **Nome:** NC 0,70.
- **Rumore.** La riga A.P.Nr. è numerica.

### DE02
```text
WEINGUT ALTER HOF
SPÄTBURGUNDER
trocken
PFALZ
2021
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Pfalz | Weingut Alter Hof | Spätburgunder | 2021 |
| Atteso | I·1 | C | I·2 | C |

### DE03 — "gegründet"
```text
Schlossgut Rabenfels
gegründet 1911
Rheingau
Riesling Auslese
Jahrgang 2018
Prädikatswein
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Rheingau | Schlossgut Rabenfels | Riesling Auslese | 2018 |
| Atteso | I·1 | C | I·2 | C |

**Perché.**
- **Denominazione:** indicatore a 3 righe, 0,55 + 0,10 = 0,65.
- **Annata:** 1911 vale 0,05.

### DE04 — produttore nella riga dell'indirizzo
```text
Franken
Qualitätswein
Silvaner trocken
Sommerauer Kreuzweg
2023
Winzerkeller Mainblick eG, 97332 Volkach
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Franken | Winzerkeller Mainblick eG | Sommerauer Kreuzweg Silvaner trocken | 2023 |
| Atteso | C | I·1 | I·1 | C |

**Perché.**
- **Produttore:** PH 0,55 + 0,10 = 0,65.
- **Nome:** NC 0,70.

### DE05 — anno spezzato da Lens
```text
Weingut Rebenhang
Riesling Spätlese
Nahe
20
19
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Nahe | Weingut Rebenhang | Riesling Spätlese | 2019 |
| Atteso | C | C | I·2 | I·✗ |

**Perché.**
- **Testo breve:** "20" e "19" sono righe numeriche, quindi restano 3 righe. "Nahe" da sola nella riga: 0,55 + 0,25 = 0,80.
- **Annata:** "20" e "19" non danno anni; l'annata giusta, scritta nel testo ma spezzata, si sceglie sulla ruota.

### DE06 — Austria, DAC
```text
Domäne Donautal
Grüner Veltliner Smaragd
Wachau DAC
2022
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Wachau | Domäne Donautal | Grüner Veltliner Smaragd | 2022 |
| Atteso | C | C | C | C |

### DE07 — Sekt senza annata
```text
Sektkellerei Lindenhof
Riesling Sekt
Brut
Rheinhessen
Hergestellt von Sektkellerei Lindenhof GmbH, D-55232 Alzey
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Rheinhessen | Sektkellerei Lindenhof GmbH | Riesling Sekt | — |
| Atteso | I·1 | C | I·2 | I·— |

### DE08 — "seit" nella riga del produttore
```text
Weinmanufaktur Neckarhalde seit 1949
Trollinger mit Lemberger
Württemberg
Qualitätswein trocken
2023
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Württemberg | Weinmanufaktur Neckarhalde | Trollinger mit Lemberger | 2023 |
| Atteso | C | C | I·2 | C |

**Perché.** Produttore: 0,70 + 0,15 + 0,10 − 0,15 = 0,80.

### DE09 — alias debole "Baden"
```text
BADEN
Grauburgunder
Kaiserstühler Winzergenossenschaft
Kabinett trocken 2022
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Baden | Kaiserstühler Winzergenossenschaft | Grauburgunder Kabinett | 2022 |
| Atteso | I·1 | C | I·✗ | C |

**Perché.** Nome: "Baden Grauburgunder" 0,60, "Grauburgunder" 0,55; il nome giusto si compone con 2 parole.

### DE10 — produttore spezzato da Lens
```text
Weingut
Hahn-Berger
Riesling trocken
Rheinhessen
2023
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Rheinhessen | Weingut Hahn-Berger | Hahn-Berger Riesling trocken | 2023 |
| Atteso | I·1 | I·✗ | I·1 | C |

**Perché.**
- **Denominazione:** 5 righe, non è un testo breve: 0,55.
- **Produttore:** l'unico candidato è "Weingut", fatto solo di una parola del produttore: 0,70 + 0,15 + 0,10 − 0,50 = 0,45. Il produttore giusto si compone toccando "Weingut" e "Hahn-Berger".
- **Nome:** NC 0,70, NI "Rheinhessen Riesling trocken" 0,60, marca sola 0,55.

---

## Português (9)

### PT01
```text
QUINTA DO VALE FUNDO
DOURO
Denominação de Origem Controlada
Colheita 2020
Tinto
Engarrafado na origem por Quinta do Vale Fundo, Lda.
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Douro | Quinta do Vale Fundo | Quinta do Vale Fundo | 2020 |
| Atteso | C | C | C | C |

### PT02
```text
Herdade da Coutada Velha
Alentejo
Denominação de Origem Controlada
Reserva
2019
Engarrafado por: Herdade da Coutada Velha, Évora
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Alentejo | Herdade da Coutada Velha | Herdade da Coutada Velha | 2019 |
| Atteso | C | C | C | C |

**Perché.** "Herdade" è una parola di casa come "Quinta" (NE, BR7.5).

### PT03 — testo parziale
```text
Casa do Lago
Vinho Verde
Loureiro
11,5% vol
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Vinho Verde | Casa do Lago | Casa do Lago Loureiro | non nel testo |
| Atteso | C | I·1 | I·1 | I·? |

**Perché.** Testo breve (3 righe): "Vinho Verde" in testa alla riga, 0,55 + 0,10 + 0,25 = 0,90.

### PT04 — Porto Vintage e imbottigliamento
```text
VINHO DO PORTO
VINTAGE 2017
Engarrafado em 2019
Caves Ribeira Alta
Vila Nova de Gaia - Portugal
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Porto | Caves Ribeira Alta | Vinho do Porto Vintage | 2017 |
| Atteso | I·1 | C | I·1 | C |

**Perché.**
- **Denominazione:** senza indicatore; il paese è lontano.
- **Annata:** 2017 vale 1,00; 2019 vale 0,10.

### PT05 — fondazione, "Colheita" a capo
```text
Adega Serra Velha
Fundada em 1952
Dão
Denominação de Origem Controlada
Colheita
2018
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Dão | Adega Serra Velha | Dão | 2018 |
| Atteso | C | C | I·1 | C |

### PT06 — Brasile, due produttori
```text
Vinícola Monte Belo
Cooperativa Vinícola Aliança Gaúcha
Cabernet Franc
Serra Gaúcha
Safra 2022
Produto do Brasil
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Serra Gaúcha | Vinícola Monte Belo | Cabernet Franc | 2022 |
| Atteso | C | I·1 | I·2 | C |

**Perché.** Produttore: due PB a 0,85, distacco 0.

### PT07 — spumante senza annata
```text
VALE DOS VINHEDOS
Indicação de Procedência
Espumante Brut
Método Tradicional
Família Bertolin
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Vale dos Vinhedos | Família Bertolin | Família Bertolin Espumante Brut | — |
| Atteso | C | I·1 | I·✗ | I·— |

### PT08
```text
Encosta do Moinho
Vinho Regional Lisboa
Castelão · Touriga Nacional
2021
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Lisboa | Encosta do Moinho | Encosta do Moinho | 2021 |
| Atteso | C | I·1 | I·2 | C |

**Perché.**
- **"·".** Divide la riga in due (BR1.1).
- **Nome:** NC "Encosta do Moinho Castelão" 0,70, marca sola 0,55.

### PT09 — Madeira, fondazione prima del 1900
```text
MADEIRA
10 Anos
Malvasia
Doce
Companhia Vinícola da Ilha, fundada em 1880
```
| | Denominazione | Produttore | Nome | Annata |
|---|---|---|---|---|
| Valore giusto | Madeira | Companhia Vinícola da Ilha | Madeira Malvasia | — |
| Atteso | I·1 | I·1 | I·1 | I·— |

**Perché.**
- **"10 Anos".** È una riga di anniversario o età, quindi rumore.
- **Produttore:** 0,70 + 0,10 − 0,15 = 0,65.

---

## Note per la taratura (Code Generation)

- **Righe verificate.** Ho controllato nel codice del pacchetto (`france_tables.dart`, `europe_tables.dart`, `new_world_tables.dart`, `catalog.dart`, `generated/appellations.g.dart`) che le righe usate esistano con questi nomi: tra le altre Lalande-de-Pomerol, Côtes du Rhône Villages, Côtes de Bourg, Getariako Txakolina, Ribera del Guadiana, Sonoma Coast, Willamette Valley, Valle de Colchagua, Vale dos Vinhedos, Salento, Barbera d'Asti DOCG. Bordeaux Supérieur non è una riga: è un alias della riga Bordeaux. `world-tables.md` raggruppa alcune di queste sotto righe più ampie (per esempio `sonoma`, `oregon`, `serraGaucha`): fa fede il codice.
- **Nomi delle denominazioni.** I nomi mostrati si confrontano con il `displayName` delle righe vere. Se una riga ha un nome diverso, si corregge il JSON (chiave e nome), non la regola.
- **Alias da ricontrollare nel JSON.** "Vinho do Porto" è alias della riga Porto in `world-tables.md`; "colchagua" e "colchagua valley" sono alias di Valle de Colchagua nel codice. Se in Code Generation un alias risulta diverso, il testo resta e si annota nel file che il campo diventa `I·✗` o `A`, senza abbassare le soglie.
- **Testo breve.** I testi con al massimo 3 righe utili sono IT01, IT02, IT09, IT14, FR08, EN03, EN08, EN10, DE05, PT03: in questi la denominazione in testa a una riga riceve +0,25 (BR7.3).
- **Pesi.** Se un peso cambia per far tornare un testo, si ricalcolano tutti i testi. Il riepilogo sopra va aggiornato.
