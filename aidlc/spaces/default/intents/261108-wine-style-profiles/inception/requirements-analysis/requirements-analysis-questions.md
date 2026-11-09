# Domande — Requirements Analysis (wine-style-profiles)

## Contesto

- Lo studio enologico (`~/Downloads/vinoozy-handoff-valutazione-vini.xlsx`, 08/11/2026) propone 24 profili di stile, finestre in mesi dalla sboccatura o dall'imbottigliamento per spumanti, Sherry e Porto, e "nessuna stima" quando lo stile non è chiaro. È dichiarato bozza non validata: per quasi tutte le denominazioni conserva i valori attuali.
- Il proprietario chiede anche che Tipologia e Livello siano preselezionati in automatico per ogni vino (base offline, tabelle, denominazione scritta a mano).
- Dalla mappa del codice: oggi il tipo dedotto dalla stima non viene salvato, il catalogo deforma i tipi (Prosecco → metodo classico), 1582 denominazioni generate non hanno tipo, "Quotidiano" non viene mai suggerito.

Le scelte enologiche (quale stile e quale livello per ogni denominazione, i numeri dei profili) le decido io seguendo lo studio, con la motivazione.

## Q1. [Prodotto] Vino il cui stile non è chiaro (es. "Bordeaux", "Napa Valley", "Mosel" senza altro)

A) Come lo studio: nessuna finestra ("Da stimare"), con una domanda nel modulo per scegliere lo stile; appena lo scegli compare la stima (consigliata)

B) Una finestra indicativa con l'avviso "stile da confermare", finché non scegli lo stile

X. Other (please specify)

[Answer]: B

## Q2. [Prodotto] Spumanti, Sherry e Porto che contano dalla sboccatura o dall'imbottigliamento

A) Nuovo campo facoltativo "Sboccatura" o "Imbottigliamento" (mese e anno) solo per quei vini; se manca, si usa il mese in cui aggiungi la bottiglia, con affidabilità bassa (consigliata)

B) Campo obbligatorio per quei vini

C) Se manca, nessuna stima

X. Other (please specify)

[Answer]: A

## Q3. [Prodotto] Come scegliere lo stile nel modulo

A) La Tipologia resta come oggi; sotto compare "Stile" solo quando serve (spumanti, dolci, liquorosi, rossi e bianchi ambigui), già preselezionato (consigliata)

B) Un solo selettore "Stile" con tutti i profili, al posto della Tipologia

X. Other (please specify)

[Answer]: A

## Q4. [Prodotto] Vini già in cantina

A) Ricalcolo automatico una volta: tipo, livello e stile si correggono solo se non li avevi scelti tu; le correzioni manuali di "Consigliato fino al" restano (consigliata)

B) Correggo solo le stime, tipo e livello restano come sono

C) Ricalcolo tutto, anche i campi scelti da te

X. Other (please specify)

[Answer]: A
