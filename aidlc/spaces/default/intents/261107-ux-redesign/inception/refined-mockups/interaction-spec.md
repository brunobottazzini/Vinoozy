# Specifica delle interazioni — nuova UX

## Fonti

- `inception/requirements-analysis/requirements.md` e la sua revisione `reviews/review-01.md` (R-01…R-08, accettati dal proprietario come rischio e risolti qui).
- `mockups.md` e `vinoozy-mockups.html`.
- `codekb/Vinoozy/code-quality-assessment.md`.

## Componenti

### CountryPicker (FR1.1)

- **Scopo:** scegliere il paese del vino.
- **Aspetto:** griglia di 4 colonne. Ogni cella ha la bandiera (emoji) e il nome localizzato. In fondo c'è "Altro paese…" (🌍).
- **Ordine:** Italia, Francia, Spagna, Portogallo, Germania, Austria, Svizzera, Grecia, Ungheria, Slovenia, Croazia, Georgia (Vecchio Mondo), poi Stati Uniti, Canada, Argentina, Cile, Brasile, Uruguay, Australia, Nuova Zelanda, Sudafrica (Nuovo Mondo).
- **Stati:** nessuna scelta; scelto (bordo bordeaux, sfondo `surface2`); disabilitato durante il salvataggio.
- **"Altro paese":** apre una finestra con **tutti i 249 paesi e territori ISO 3166-1**, ognuno con la sua bandiera, anche i più rari per il vino (per esempio le Isole Marianne Settentrionali, MP). Richiesta del proprietario, messaggio 2f5fe44e. I paesi sono in ordine alfabetico, con in cima "Rari per il vino" e un campo di ricerca. Il paese scelto compare poi in cima alla griglia del modulo. I nomi dei paesi vengono da una tabella nel codice dell'app con i nomi in it, en e pt-BR (R-05), quindi la ricerca funziona offline. La ricerca ignora maiuscole e accenti, e trova il paese in tutte e 3 le lingue: "Giappone", "Japan" e "Japão" trovano JP.
- **Bandiera mancante:** se l'emoji non è disponibile si vede la sigla di 2 lettere in un riquadro (R-05).
- **Accessibilità:** ogni cella ha il nome del paese come etichetta e un'area da toccare di almeno 48 dp.

### RegionPicker (FR1.2)

- **Scopo:** scegliere la regione del paese scelto.
- **Aspetto:** pulsanti a pillola (chip) che vanno a capo, più "＋ Altra regione".
- **Cambio di paese:** quando cambia il paese, la regione scelta si azzera (R-06).
- **Senza paese:** si vede solo "Altra regione" (R-06).
- **Valore salvato (R-02):**
  - per le regioni dell'elenco si salva un **nome canonico fisso**, che non cambia con la lingua (per esempio `Piemonte`, `Bourgogne`, `Mendoza`, `Serra Gaúcha`) e si mostra tradotto quando esiste una traduzione (per esempio Bourgogne si mostra come "Borgogna" in italiano);
  - per "Altra regione" si salva il testo scritto, senza spazi esterni.

  La Dashboard raggruppa per valore salvato normalizzato. Lo stesso vino inserito in it, en o pt-BR finisce quindi nello stesso gruppo.
- **Lunghezza (R-03):** 1–120 caratteri, come oggi. I vini già salvati restano modificabili.

### Compilazione automatica (FR1.3, R-06)

- **Dal catalogo:** denominazione → regione → paese. Per esempio Barolo DOCG → Piemonte → Italia, Chablis → Bourgogne → Francia.
- **Da Open Food Facts:** se `origins` contiene il nome di un paese dell'elenco (in qualsiasi delle 3 lingue o in inglese), si sceglie quel paese. Se contiene anche una sua regione dell'elenco, si sceglie la regione; altrimenti la regione resta vuota e si può scegliere.
- I valori compilati restano modificabili.

### Vini già salvati (R-06)

- Se un vino non ha `country` e la sua regione coincide, ignorando maiuscole e accenti, con una delle 20 regioni italiane, viene **mostrato** come Italia.
- Il documento non viene riscritto da solo. Se il vino viene modificato e salvato, si salva anche `country = IT`.

### WineCard (FR1.4, FR3.2)

- **Contenuto:** fascia sinistra larga 6 dp con il colore del tipo; bandiera; nome e annata; produttore e regione; etichetta di stato; numero di bottiglie; tipo con pallino colorato **e nome**; pulsante "Ho bevuto".
- **Il colore non è mai l'unico segnale (NFR1):** lo stato è un'etichetta con testo, e il tipo ha sempre il nome.
- **Tipi grafici (R-07)**, collegati ai valori esistenti di `wineType`:

| `wineType` esistente | Tipo grafico | Colore | Icona |
|---|---|---|---|
| `red` | Rosso | bordeaux | 🔴 |
| `white` | Bianco | oro | 🟡 |
| `rose` | Rosato | rosa | 🌸 |
| `sparkling` | Bollicine | verde oliva | 🫧 |
| `sweet`, `fortified` | Dolce | ambra | 🍯 |
| nessuno | — | neutro | — |

### "Ho bevuto" (FR2)

- **Pulsante (FR2.1, R-07):**
  - testo "Ho bevuto" / "I drank one" / "Bebi uma";
  - icona 🥂 (calici), diversa dall'icona della scheda Cantina;
  - almeno 48 × 48 dp;
  - nessun overflow con il testo a 2,0 nelle 3 lingue.
- **Pannello di conferma (FR2.2):**
  - si apre dal basso con la bandiera, il nome e l'annata del vino;
  - mostra le bottiglie "2 → 1" e 5 stelle facoltative;
  - pulsanti "Sì, l'ho bevuta" (principale) e "Annulla";
  - chiudendo il pannello o premendo "Annulla" non succede nulla.
- **Registrazione (FR2.3, R-04):**
  - alla conferma si fa **una sola scrittura**, cioè un solo batch: −1 bottiglia e il record della bevuta, con `rating` se è stato dato;
  - `DrinkingRecordRepository.drink` riceve un parametro `rating` facoltativo, quindi non serve una seconda scrittura;
  - funziona offline come oggi, con la fascia "in attesa";
  - dopo la conferma compare il messaggio "Bevuta segnata" con "Annulla", come oggi.
- **"Togli una bottiglia senza bevuta" (FR2.4):** pulsante secondario nel dettaglio, con una finestra di conferma.

### Momento ideale nel dettaglio (richiesta del proprietario, messaggio e22b8032)

- **Frase in chiaro:** "Consigliato fino al <anno>", con l'anno di fine della finestra effettiva. Sotto, "Al meglio dal <inizio> al <fine>".
- **Barra:** la barra colorata della finestra, con il segno di oggi.
- **Avviso sempre visibile:** "⚠︎ Indicativo: è una stima basata su tipo, denominazione e annata. Conservazione e singola bottiglia possono cambiarla." Usa il colore di avviso ed è letto dal lettore di schermo come nota.
- **Casi particolari:**
  - finestra già passata: "Consigliato fino al <anno>: è passato", con lo stato "Oltre il picco";
  - nessuna stima (vino da stimare): al posto della frase compare "Stima non disponibile", con l'avviso su come ottenerla (indicare annata e tipo).
- **Testi:** nei 3 file ARB.
- **Criterio:** test di widget per i 3 casi, nelle 3 lingue.

### Dashboard (FR3.3)

In alto un riquadro con il totale delle bottiglie e quante sono da bere ora. Poi "Da bere presto" con le bandiere, il grafico per regione (bandiera + nome) e il grafico per tipo (colore + nome). Il `BarChart` esistente viene esteso con un'icona o una bandiera per riga.

### "Aggiungi"

Diventa un pulsante flottante (FAB) in basso a destra. Si alza quando compare una SnackBar, così non viene più coperto: era l'osservazione della prima versione.

## Ordine tra regole e app (R-01)

1. Le nuove regole di Firestore (`country` facoltativo, `region` 1–120) sono **compatibili all'indietro**: la versione dell'app di oggi continua a scrivere senza errori. Lo verifica un test in `test/rules/compat/`.
2. Le regole vanno pubblicate su `vinoozy-d6f45` **prima** di installare sul telefono la build che scrive `country`. La pubblicazione richiede il via del proprietario: è il punto di escalation.
3. Se la build nuova scrive con le regole vecchie, il server rifiuta e compare l'avviso "non salvato" già esistente, con il nome del vino. Lo verifica un test sull'emulatore con le regole vecchie.

## Criteri verificabili aggiunti (R-07)

- **WineCard:** test di widget per ogni tipo grafico: icona, nome del tipo, bandiera e stato visibili, nelle 3 lingue a testo 1,0 e 2,0.
- **Tema:** un test confronta ogni coppia testo/sfondo della palette chiara e scura, con contrasto ≥ 4,5:1.
- **Schermate:** Cantina, dettaglio, modulo e Dashboard usano `WineCard`, `CountryFlag` e `StateChip` condivisi. Un test di widget verifica che compaiano in ciascuna.
- **Icone:** l'icona di "Ho bevuto" è diversa dall'icona della scheda Cantina.
