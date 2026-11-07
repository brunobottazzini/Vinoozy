# Functional Design — u2-estimation — Domande

Contesto: `unit-of-work.md` (U2: logica pura della stima, pacchetto Dart senza Flutter né Firebase), `unit-of-work-story-map.md` (US4.1, US4.2, US7.1), `stories.md`, `requirements.md` (FR4.1–FR4.7, FR7.2, A1, A3), `components.md`, `contract-summary.md` (C2 v1: `estimateWindow`, `statusOf`, `pairingsFor`, `needsRefinement`).

Già deciso e non richiesto di nuovo: la regola "da bere presto" (25% della durata, minimo 3 e massimo 12 mesi, A3), i quattro stati, la fiducia alta/media/bassa, "senza annata" con fiducia bassa, la precedenza della base dati esterna sulle regole interne.

## Decisioni enologiche prese da me (regola del progetto)

Le scelte che richiedono competenza enologica le decido io, motivandole, e restano correggibili (`project.md`, Corrections). In sintesi, da dettagliare in `rules.md`:

- **Tabella interna per denominazione**: circa 40 denominazioni italiane più diffuse (per esempio Barolo, Barbaresco, Brunello di Montalcino, Amarone, Chianti Classico, Barbera d'Asti, Nebbiolo d'Alba, Franciacorta, Prosecco, Soave, Verdicchio, Etna Rosso, Taurasi, Sagrantino, Primitivo di Manduria) con anni di inizio, picco e fine contati dall'annata, e una variante "Riserva" o "Superiore" dove la tradizione la allunga.
- **Tabella per tipologia** quando la denominazione non è nota: rosso leggero, rosso strutturato, bianco, rosato, spumante metodo classico, spumante charmat, dolce o passito, fortificato.
- **Fiducia**: alta solo dalla base dati esterna; media dalle regole per denominazione con annata; bassa dalla sola tipologia o senza annata.
- **Abbinamenti di riserva** per tipologia e, dove utile, per denominazione.

## Q1. [Prodotto] Tipologia non indicata dall'utente

Nello scheletro l'utente scrive solo il nome, per esempio "Barolo 2016". Per stimare serve almeno la tipologia o la denominazione.

A. Riconoscerle dal nome: se il nome contiene una denominazione nota ("Barolo", "Prosecco", ...) se ne ricavano denominazione e tipologia; altrimenti la tipologia resta sconosciuta (consigliato: nessun campo in più da compilare)
B. Chiedere sempre la tipologia nel modulo di aggiunta (un campo in più per ogni vino)
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q2. [Prodotto] Vino non riconoscibile

Né la base dati esterna né le regole interne riconoscono il vino (nessuna denominazione nota e tipologia sconosciuta).

A. Mostrare comunque una stima generica, con fiducia bassa e la fonte "stima per tipologia" (consigliato: il vino compare nel cruscotto e l'utente può correggerla)
B. Mostrare "stima non disponibile": il vino non entra in nessuno stato finché l'utente non indica la tipologia
C. Not yet defined
X. Other (please specify)

[Answer]: X. Stime generica ma con un warning che non è precisa per mancanza di tipologia

## Q3. [Prodotto] Forma degli abbinamenti

A. Categorie di cibi ("carni rosse brasate", "formaggi stagionati", "funghi e tartufo"), da 3 a 5 per vino, tradotte nelle tre lingue (consigliato: brevi, chiare e facili da tradurre)
B. Piatti precisi ("brasato al Barolo", "tajarin al tartufo"), più evocativi ma difficili da tradurre e da tenere coerenti
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Requested Changes Feedback

Avviso stima generica — "Se non abbiamo la tipoligia. Facciamo quello definito e diamo la possibilità del utente inserire a mano la tipologia del vino"

[Answer]: Se non abbiamo la tipoligia. Facciamo quello definito e diamo la possibilità del utente inserire a mano la tipologia del vino

## Consolidated Summary Confirmation

- Tipologia (Q1): ricavata dal nome quando contiene una denominazione nota (es. "Barolo" → rosso, denominazione Barolo); altrimenti resta sconosciuta. Nessun campo in più nel modulo.
- Vino non riconoscibile (Q2): stima generica con fiducia bassa e un avviso visibile che la stima non è precisa perché manca la tipologia; l'utente può indicare la tipologia a mano, e la tipologia indicata dall'utente ha sempre la precedenza su quella ricavata dal nome (la stima si ricalcola). Il campo per inserirla sta nella cantina (u4); u2 riceve la tipologia come dato opzionale del vino. Per questo la finestra stimata porta un'indicazione della base usata (base dati, denominazione, tipologia, generica): un'aggiunta compatibile al contratto C2, che U4 userà per mostrare l'avviso.
- Abbinamenti (Q3): da 3 a 5 categorie di cibi, tradotte in it, en e pt-BR.
- Decisioni enologiche mie, correggibili: tabella di circa 40 denominazioni italiane con varianti Riserva/Superiore; tabella per tipologia (rosso leggero, rosso strutturato, bianco, rosato, spumante metodo classico, spumante charmat, dolce o passito, fortificato); fiducia alta solo dalla base dati, media da denominazione con annata, bassa da sola tipologia, senza annata o generica.
- Già deciso: regola "da bere presto" (25% della durata, tra 3 e 12 mesi), quattro stati, precedenza della base dati esterna, pacchetto Dart puro senza Flutter né Firebase.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
