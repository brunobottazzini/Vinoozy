# Requisiti — nuova UX di Vinoozy (ux-redesign)

## Analisi dell'intento

Il proprietario ha provato la prima versione sul suo telefono (2026-11-07) e chiede di rifare l'esperienza d'uso. Obiettivi:
- **registrare paese e regione** di ogni vino, scegliendoli in modo grafico con le bandiere;
- rendere **"bevuto" chiaro e sicuro**: oggi il tocco salva subito e c'è solo "Annulla";
- dare all'app un'**identità visiva** più ricca.

Scelte del proprietario (`requirements-analysis-questions.md`):
- Q1 = A: elenco con bandiere, compreso il Nuovo Mondo (Brasile, Cile, Argentina, Australia ecc.);
- Q2 = A: pannello di conferma con voto;
- Q3 = A: nuova identità visiva, con la navigazione invariata.

Situazione di partenza (Reverse Engineering, `codekb/Vinoozy/code-quality-assessment.md`):
- il modulo non ha campi per regione o paese;
- il paese non esiste nel modello;
- `firestore.rules` accetta solo un elenco chiuso di campi del vino;
- "Bevuta" è un'icona `wine_bar` senza testo nella riga, la stessa della scheda Cantina;
- il tema ha 5 colori.

## Requisiti funzionali

### FR1 — Paese e regione

- **FR1.1 Scelta del paese.** Nel modulo di aggiunta e in quello di modifica c'è un campo "Paese" che apre una griglia di paesi, ciascuno con la **bandiera** (emoji) e il nome nella lingua dell'app. L'elenco contiene 21 paesi del vino:
  - Vecchio Mondo: Italia, Francia, Spagna, Portogallo, Germania, Austria, Svizzera, Grecia, Ungheria, Slovenia, Croazia, Georgia;
  - Nuovo Mondo: Stati Uniti, Canada, Argentina, Cile, Brasile, Uruguay, Australia, Nuova Zelanda, Sudafrica;
  - in fondo "Altro paese", che apre una ricerca su tutti i paesi ISO 3166.

  L'Italia è in testa. Criterio: in un test di widget la griglia mostra le 21 bandiere e "Altro paese", e la scelta salva il codice ISO del paese.
- **FR1.2 Scelta della regione.** Scelto il paese, compaiono le sue **regioni vinicole principali** come pulsanti da toccare:
  - Italia: tutte le 20 regioni;
  - Francia: 11 (Bordeaux, Borgogna, Champagne, Valle del Rodano, Valle della Loira, Alsazia, Linguadoca-Rossiglione, Provenza, Beaujolais, Jura, Sud-Ovest);
  - per ogni altro paese le principali, decise da me con le motivazioni in Code Generation (per esempio Argentina: Mendoza, Salta, San Juan, Patagonia; Brasile: Serra Gaúcha, Campanha, Vale do São Francisco).

  C'è sempre "Altra regione", da scrivere a mano (1–80 caratteri, spazi esterni tolti). Paese e regione sono facoltativi. Criterio: test di widget per l'Italia (20 regioni), per un paese del Nuovo Mondo e per "Altra regione".
- **FR1.3 Compilazione automatica.** Quando il vino è riconosciuto, paese e regione si compilano da soli, e restano modificabili:
  - dal catalogo interno: per esempio Barolo DOCG → Italia, Piemonte;
  - da un'etichetta o da Open Food Facts, quando il paese è riconoscibile.

  Criterio: test di unità sul passaggio da denominazione a paese e regione per almeno 3 denominazioni.
- **FR1.4 Visualizzazione.** La bandiera del paese compare:
  - nella riga della Cantina;
  - nel dettaglio del vino, con il nome della regione;
  - nella scheda per regione della Dashboard.

  Un vino senza paese non mostra bandiera. Criterio: test di widget.
- **FR1.5 Dati.**
  - Il paese si salva come nuovo campo `country` (codice ISO 3166-1 alpha-2, facoltativo); la regione resta nel campo `region` esistente.
  - I vini già salvati con una regione italiana e senza paese vengono letti come Italia solo per la visualizzazione, senza riscriverli.
  - `firestore.rules` accetta `country` (2 lettere maiuscole) e `region` (1–80 caratteri, come FR1.2), e i test delle regole lo verificano.

### FR2 — Conferma della bevuta

- **FR2.1 Pulsante chiaro.**
  - Nella riga della Cantina e nel dettaglio "bevuto" è un pulsante con **il verbo**: "Ho bevuto" (it), "I drank one" (en), "Bebi uma" (pt-BR).
  - Usa un'icona di bicchiere diversa da quella della scheda Cantina.
  - L'area da toccare è di almeno 48 × 48 dp.
- **FR2.2 Pannello di conferma.** Il tocco **non registra nulla**: apre un pannello dal basso con:
  - bandiera, nome e annata del vino;
  - le bottiglie prima e dopo (per esempio "2 → 1");
  - il voto facoltativo da 1 a 5 stelle;
  - "Sì, l'ho bevuta" e "Annulla".

  Criterio: test di widget. Senza conferma non c'è nessuna scrittura; con "Annulla" o chiudendo il pannello non succede nulla.
- **FR2.3 Registrazione.**
  - Alla conferma la bevuta viene registrata, con il voto se dato, attraverso la scrittura di oggi (`drink` di `DrinkingRecordRepository`, con la fascia "in attesa" offline).
  - Poi compare un breve messaggio con "Annulla", che resta come rete di sicurezza.
  - Criterio: test di widget e test esistenti del repository verdi; l'end-to-end `cellar_test.dart` aggiornato al nuovo flusso.
- **FR2.4 "−" nel dettaglio.** Il pulsante che toglie una bottiglia senza registrare una bevuta ha un'etichetta esplicita ("Togli una bottiglia senza bevuta") e chiede conferma anche lui.

### FR3 — Nuova identità visiva

- **FR3.1 Palette.**
  - Colori del vino in tema chiaro e scuro: bordeaux come colore principale, oro come accento, crema come sfondo nel tema chiaro.
  - Secondario, terziario, contenitori e superfici diventano distinti; oggi sono tutti uguali.
  - Criterio: un test verifica il contrasto di ogni coppia testo/sfondo del tema (≥ 4,5:1).
- **FR3.2 Schede dei vini.** Nella Cantina ogni vino è una scheda con:
  - una fascia colorata e un'icona per il tipo: rosso, bianco, rosato, bollicine, dolce/fortificato;
  - la bandiera;
  - nome e annata in evidenza;
  - lo stato (da bere ora, da aspettare, oltre il picco) come etichetta colorata;
  - il numero di bottiglie.
- **FR3.3 Dashboard più ricca.**
  - Grafici con i colori della nuova palette, icone per tipo e bandiere nella scheda per regione.
  - In cima, un riquadro "Da bere presto" con le schede dei vini.
  - Nessuna libreria di grafici nuova: si estende `BarChart` esistente.
- **FR3.4 Coerenza.**
  - Modulo di aggiunta, dettaglio, Storico e lettura dell'etichetta usano gli stessi componenti visivi (schede, etichette di stato, bandiere).
  - La navigazione in basso (Dashboard, Cantina, Storico) resta com'è, con icone distinte.

## Requisiti non funzionali

- **NFR1 Accessibilità.**
  - Ogni schermata cambiata supera la matrice esistente: 3 lingue × testo 1,0/2,0 × tema chiaro/scuro.
  - Le bandiere hanno un'etichetta di accessibilità con il nome del paese, non l'emoji.
  - Aree da toccare di almeno 48 dp.
  - Contrasto ≥ 4,5:1 per il testo.
- **NFR2 Test e copertura.**
  - La copertura resta ≥ 80% sul progetto senza esclusioni e su `lib/cellar/` e `lib/dashboard/`.
  - Tutta la suite esistente resta verde, compresi i test delle regole.
  - Gli end-to-end che usano il vecchio pulsante (`Icons.wine_bar`) vengono aggiornati al nuovo flusso, senza togliere verifiche.
- **NFR3 Nessuna dipendenza né costo nuovi.**
  - Bandiere come emoji Unicode; elenchi di paesi e regioni nel codice dell'app, quindi offline.
  - Nessuna lettura Firestore in più.
  - Nessun pacchetto nuovo in `pubspec.yaml`.
- **NFR4 Compatibilità.**
  - Le nuove regole accettano anche i vini senza `country`, e l'app di oggi continua a funzionare con le regole nuove (test di compatibilità in `test/rules/compat/`).
  - La pubblicazione delle regole su `vinoozy-d6f45` avviene **solo con il via del proprietario**: è il punto di escalation di questo lavoro.
- **NFR5 Stile.**
  - Codice, identificatori e commenti in inglese.
  - Ogni testo nuovo nei 3 file ARB (it, en, pt-BR).
  - `dart format` e `flutter analyze --fatal-infos` puliti.

## Vincoli

- Navigazione invariata (Q3 = A). Si lavora sulla app Android esistente, nel progetto Firebase reale per la prova sul telefono e nell'emulatore per i test.
- Dopo l'approvazione dei mockup il lavoro prosegue in autonomia fino alla consegna, con escalation al proprietario se necessario (messaggio 03522ea6). Restano punti di escalation fissi:
  - la pubblicazione delle regole sul progetto reale;
  - ogni costo;
  - ogni dubbio che cambi quanto approvato nei mockup.

## Assunzioni

- Le emoji di bandiera sono visualizzate a colori dal font di sistema di Android (Noto Color Emoji). Il proprietario ha un OnePlus Android 14 o superiore.
- Le regioni dei paesi le scelgo io (correzione del 2026-11-04 in `project.md`), con le motivazioni in Code Generation; il proprietario può correggerle.

## Fuori ambito

Da fare come lavori separati:
- foto di fronte e retro dell'etichetta e base offline dei vini;
- il doppione nello Storico;
- il rischio R-01 della fascia dopo un cambio di account;
- l'app per iPhone.

## Domande aperte

Nessuna.
