# Regole — riconoscimento delle etichette

## Fonti

- `inception/requirements-analysis/requirements.md` e `reviews/review-01.md` (punti R-01…R-10).
- `inception/refined-mockups/interaction-spec.md` e `reviews/review-01.md`.
- `codekb/Vinoozy/code-quality-assessment.md`.

```yaml
rules:
  # BR1 — fronte e retro
  - id: BR1.1
    statement: "Dopo una foto del fronte (scattata, dalla galleria o condivisa) si mostra 'Ora il retro' con Scatta, Galleria e Salta."
    category: workflow
  - id: BR1.2
    statement: "Testo unito = righe del fronte seguite dalle righe del retro non già presenti (confronto senza maiuscole, accenti e spazi doppi); massimo 2000 caratteri per foto e 4000 in tutto. maxLabelTextLength di matchLabelText passa da 2000 a 4000 (con test e benchmark aggiornati a 4000 caratteri)."
    category: computation
  - id: BR1.3
    statement: "Codice a barre: il primo valido del fronte, altrimenti il primo valido del retro; se fronte e retro hanno codici validi diversi vince il fronte e il retro si ignora."
    category: computation
  - id: BR1.4
    statement: "TempLabelStore tiene un insieme di file 'in uso' (fronte e retro della lettura corrente): beforeRead non li cancella anche oltre 10 minuti, release a fine lettura non li cancella più; la sessione li rilascia e cancella all'uscita dall'esito (conferma, Scrivi a mano, indietro, chiusura della schermata) o all'annullamento. All'avvio dell'app si cancella ogni file rimasto in cache/label/ (nessun ripristino dopo la chiusura del processo)."
    category: constraint
  - id: BR1.5
    statement: "Retro non leggibile o lettura fallita: si continua con il solo fronte e si mostra 'Retro non leggibile'. Fronte non leggibile ma retro leggibile: si usa il retro. Entrambi non leggibili: esito 'unreadable'."
    category: workflow
  - id: BR1.6
    statement: "Fotocamera annullata o permesso negato sul retro: come Salta. La lettura si può annullare e torna alla scelta iniziale cancellando le foto."
    category: workflow

  # BR2 — base offline
  - id: BR2.1
    statement: "Lo strumento di costruzione tiene un prodotto solo se ha la categoria en:wines e nessuna categoria di esclusione (marmellate, succhi, aceti, salse, cibi), un nome di 2-120 caratteri e un codice a barre valido."
    category: validation
  - id: BR2.2
    statement: "Tipo di vino dal tag di categoria (red-wines → redStructured, salvo tag light/young → redLight; white-wines → white; rose-wines → rose; champagnes, crémants, metodo classico → sparklingClassic; altri sparkling/prosecco → sparklingTank; sweet/dessert → sweet; port/sherry/marsala/fortified → fortified); altrimenti vuoto."
    category: computation
  - id: BR2.3
    statement: "Denominazione da tag di etichette o categorie riconoscibili (AOC/DOC/DOCG/DO/IGT…); paese dal primo countries_tags; annata da quattro cifre 1900-2100 nel nome o nella quantità."
    category: computation
  - id: BR2.4
    statement: "Controllo di plausibilità della base generata, dopo i filtri di BR2.1: almeno 5000 vini (soglia prudente sotto i circa 17000 prodotti della categoria, da rivedere con il primo export reale), nessun codice duplicato, tutti i nomi validi, data dell'export non più vecchia di 180 giorni (controllo disattivabile con un'opzione, usata dai test con l'estratto di prova); se fallisce la base non si aggiorna e lo strumento esce con errore."
    category: validation
  - id: BR2.5
    statement: "La base si apre al primo uso in background e resta in memoria; ricerca per codice esatta; ricerca per testo con punteggio di somiglianza su nome, produttore e denominazione."
    category: workflow

  # BR3 — ordine dei tentativi ed esito
  - id: BR3.1
    statement: "Ordine: (1) codice nella base offline; (2) testo nella base offline; (3) denominazione nel catalogo interno; (4) solo con rete e OFF attivo: codice poi testo su Open Food Facts; (5) esito non trovato. Ci si ferma al primo gradino che dà una proposta sicura (BR3.2); altrimenti i candidati dei gradini 2, 3 e 4 si sommano (senza doppioni, BR3.3) e si decide alla fine. Il gradino 3 dà un candidato con punteggio fisso 0,70 (mai proposta sicura da solo)."
    category: workflow
  - id: BR3.2
    statement: "Proposta sicura se: corrispondenza esatta del codice a barre (base o OFF), oppure punteggio di testo ≥ 0,85, almeno 2 parole distintive del vino trovate (oppure nome + produttore) e il secondo candidato sotto di almeno 0,15; altrimenti, con almeno un candidato ≥ 0,45, si mostra la lista (massimo 10, ordinata per punteggio)."
    category: computation
  - id: BR3.6
    statement: "Punteggio del testo (0..1): parole del vino (nome, produttore, denominazione) normalizzate (minuscole, senza accenti e punteggiatura); si scartano le parole di 1-2 lettere e le parole comuni [vino, vin, wine, wein, vinho, vinos, rosso, rouge, red, bianco, blanc, white, rosato, rose, doc, docg, igt, aoc, aop, do, doca, igp, dop, cuvee, reserve, riserva, reserva, gran, grand, cru, chateau, domaine, tenuta, cantina, bodega, estate, the, del, della, di, de, la, le, les, el, and, et, e]; peso di ogni parola = lunghezza in lettere; punteggio = somma dei pesi delle parole presenti nel testo letto / somma dei pesi di tutte le parole distintive del vino; se il vino ha meno di 2 parole distintive il punteggio massimo è 0,60; bonus +0,05 se l'annata del vino compare nel testo, con tetto 1,0. Le soglie e la lista delle parole comuni sono costanti in un solo punto, con test per ogni caso (record di una sola parola, nome+produttore, annata, rumore)."
    category: computation
  - id: BR3.3
    statement: "Candidati uguali (stesso codice, oppure stesso nome normalizzato e stesso produttore) compaiono una volta sola; vince la fonte offline."
    category: computation
  - id: BR3.4
    statement: "Esiti non trovato: 'unreadable' (nessun testo né codice), 'barcodeNotFound' (codice letto, nessun vino), 'noMatch' (testo letto, nessun candidato)."
    category: workflow
  - id: BR3.5
    statement: "La proposta sicura mantiene quantità, Correggi, errore di salvataggio e aggiunge 'Non è questo', che porta ai candidati o, se non ce ne sono, al non trovato."
    category: workflow

  # BR4 — Cerca online
  - id: BR4.1
    statement: "Cerca online è disponibile negli esiti non trovato e da 'Nessuno di questi'; il campo parte con le parole più significative (nome, produttore, denominazione, annata) e si può modificare."
    category: workflow
  - id: BR4.2
    statement: "Cerca è disattivato con il campo vuoto; la ricerca include i risultati offline e, con rete e OFF attivo, quelli online (categoria vini, massimo 10), senza doppioni (BR3.3)."
    category: validation
  - id: BR4.3
    statement: "Senza rete, OFF spento o limite superato (8 ricerche al minuto, 5 minuti dopo 3 guasti) si cercano solo i vini offline e compare il messaggio corrispondente."
    category: constraint
  - id: BR4.4
    statement: "Un candidato scelto apre il modulo compilato con tutti i campi disponibili, anche solo il nome; paese e regione con la stessa logica della UX; i campi restano modificabili; dal modulo si torna alla lista."
    category: workflow

  # BR5 — Google Lens
  - id: BR5.1
    statement: "Apri in Google Lens è l'ultimo pulsante degli esiti non trovato; a ogni tocco si chiede conferma con il testo che la foto passa all'app Google, che può conservarne una copia."
    category: authorization
  - id: BR5.2
    statement: "Dopo la conferma si condivide la sola foto del fronte con ACTION_SEND (image/*, EXTRA_STREAM e ClipData con FLAG_GRANT_READ_URI_PERMISSION) verso il pacchetto com.google.android.googlequicksearchbox; se il pacchetto manca o startActivity lancia ActivityNotFoundException si usa createChooser escludendo Vinoozy (EXTRA_EXCLUDE_COMPONENTS); il file è esposto in sola lettura da un FileProvider limitato a cache/label/; <queries> dichiara il pacchetto Google e ACTION_SEND image/*. Che l'app Google apra Lens con l'immagine si verifica sul telefono del proprietario (checklist); in ogni caso resta il menu Condividi."
    category: authorization
  - id: BR5.3
    statement: "Vinoozy non legge i risultati di Google; al ritorno l'esito è ancora aperto con le foto (BR1.4). Se il sistema chiude Vinoozy mentre l'utente è in Google, al riavvio si riparte dalla Cantina e le foto sono cancellate."
    category: workflow

  # BR6 — rete, attribuzione, informazioni
  - id: BR6.1
    statement: "Senza rete il gradino online non viene chiamato e non conta come guasto (nessun off_suspended). Il controllo di rete entra in CatalogCoordinator come interfaccia iniettata (lib/catalog/core resta puro); l'implementazione con connectivity_plus sta in platform/. Una rete senza Internet reale (portale captive) resta un caso residuo: conta come guasto come oggi."
    category: constraint
  - id: BR6.2
    statement: "Ovunque compaiano dati da base offline o OFF si mostra 'Dati da Open Food Facts, licenza ODbL'."
    category: constraint
  - id: BR6.3
    statement: "La schermata Informazioni, dal menu della Cantina, mostra versione, numero di vini e data della base, licenze ODbL e DbCL, nota privacy delle foto."
    category: workflow
```
