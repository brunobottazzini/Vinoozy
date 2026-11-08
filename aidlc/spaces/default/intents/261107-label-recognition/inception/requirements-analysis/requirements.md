# Requisiti — riconoscimento delle etichette migliorato (label-recognition)

## Analisi dell'intento

Prima della pubblicazione sullo store il proprietario vuole che **fotografare un'etichetta trovi il vino molto più spesso**, anche senza rete. Quando non ci si riesce, deve avere una via semplice per completarlo: scegliere tra candidati trovati online oppure, come ultima possibilità, cercare la foto con Google Lens. Niente servizi a pagamento.

Origine: richiesta del proprietario del 2026-11-07 (descrizione dell'intent, punti 1–4); preferenza per Google Lens come ultima alternativa (messaggio 6a2bfbcb); scelte Q1 = A, Q2 = A, Q3 = A in `requirements-analysis-questions.md`.

Situazione di partenza (Reverse Engineering, `codekb/Vinoozy/`):
- una sola foto per lettura;
- ML Kit legge testo e codici sulla stessa immagine;
- nessun database locale e nessun asset di dati;
- la ricerca testuale su Open Food Facts esiste (`/cgi/search.pl`, categoria `wines`, 10 risultati) ma prende in silenzio il primo risultato;
- nessun intent verso Google Lens, nessun `FileProvider`;
- la foto preparata si cancella prima dell'esito;
- senza rete l'app interroga comunque Open Food Facts e registra falsi guasti.

## Requisiti funzionali

### FR1 — Foto di fronte e retro

- **FR1.1 Retro chiesto subito.** Dopo la foto del fronte, scattata o scelta dalla galleria, l'app chiede "Ora il retro". Sono sempre visibili "Scatta il retro", "Scegli dalla galleria" e "Salta". Vale anche quando la foto arriva da "Condividi → Vinoozy" (Q3 = A). Criterio: test di widget per i tre percorsi; "Salta" porta all'esito con il solo fronte.
- **FR1.2 Lettura di entrambe.** Ciascuna foto è preparata e letta sul telefono con ML Kit, come oggi.
  - **Testo:** si uniscono fronte e retro, senza righe doppie. Il limite resta di 2.000 caratteri per foto.
  - **Codici a barre:** si cerca in entrambe e vince il primo valido, prima del fronte e poi del retro.

  Criterio: test di unità sull'unione, con righe doppie, codice solo sul retro e codice diverso sulle due foto.
- **FR1.3 Foto mai conservate.** Le copie preparate restano nella cartella temporanea dell'app finché si è nella schermata dell'esito, perché servono a FR4. Si cancellano appena si esce dall'esito (conferma, annulla o indietro) e all'avvio successivo se l'app è stata chiusa. Criterio: test che la cartella `cache/label/` sia vuota dopo ogni uscita e dopo un riavvio simulato.

### FR2 — Base offline dei vini

- **FR2.1 Costruzione.** Uno strumento nel repository (`tool/`), eseguito dal proprietario o dalla CI, costruisce la base dall'export pubblico di Open Food Facts:
  - tiene solo i prodotti della categoria vini (`en:wines` e sottocategorie), di tutti i paesi (Q2 = A);
  - campi: codice a barre, nome, produttore, categoria (che dà il tipo di vino), denominazione e paese (aggiunto da me perché compila il paese della UX);
  - scarta i prodotti senza nome;
  - lo strumento non gira nei test né nella CI ordinaria: usa un estratto di prova nel repository.

  Criterio: test dello strumento su un estratto di 50 prodotti misti con il risultato atteso.
- **FR2.2 Inclusa nell'app.** La base è un file dati incluso nell'app (asset) e funziona subito, anche senza rete (Q1 = A). Si aggiorna rigenerandola prima di ogni versione. Una schermata "Informazioni" mostra la data dell'export usato. Criterio: test di widget della data.
- **FR2.3 Ricerca per codice a barre e per testo.**
  - Un codice a barre letto si cerca prima nella base offline.
  - Il testo unito di fronte e retro si confronta con nome, produttore e denominazione della base, come oggi `matchLabelText` fa con il catalogo interno.

  Criterio: test di unità con un codice presente, uno assente e un testo che riconosce un vino della base.
- **FR2.4 Ordine dei tentativi:**
  1. codice a barre nella base offline;
  2. testo nella base offline;
  3. denominazione nel catalogo interno, come oggi;
  4. solo con la rete, Open Food Facts online (codice, poi testo, solo vini);
  5. esito "non trovato" con FR3 e FR4.

  Criterio: test di unità per ciascun gradino.
- **FR2.5 Attribuzione e licenza.**
  - Dove compaiono dati della base o di Open Food Facts c'è l'attribuzione "Dati da Open Food Facts, licenza ODbL": nella lista dei candidati, nella proposta e in "Informazioni".
  - La base derivata è distribuita con la stessa licenza ODbL. Lo strumento e il file della base stanno nel repository pubblico.

  Criterio: test di widget dell'attribuzione.

### FR3 — "Cerca online" con candidati

- **FR3.1 Quando.** Il pulsante "Cerca online" compare negli esiti "non leggibile", "codice letto ma vino non trovato" e "nessun vino riconosciuto".
- **FR3.2 Cosa cerca.**
  - Cerca su Open Food Facts per testo (le parole più significative lette su fronte e retro, che si possono modificare prima di cercare) oppure per codice a barre, solo tra i vini.
  - Mostra fino a 10 **candidati**, ciascuno con nome, produttore e, se presenti, annata, paese e denominazione.
  - La lista comprende anche i candidati simili della base offline, segnati "offline".
- **FR3.3 Scelta e compilazione parziale.** Toccando un candidato si apre il modulo di aggiunta compilato con tutto ciò che il candidato ha, anche se incompleto (per esempio solo nome e produttore). Paese, regione e stima si calcolano come sempre e i campi restano modificabili. Criterio: test di widget con un candidato completo e uno con il solo nome.
- **FR3.4 Senza rete o con limite raggiunto.**
  - Senza rete il pulsante cerca solo nella base offline e lo dice ("Senza rete: cerco solo nella base sul telefono").
  - Si rispettano i limiti attuali di Open Food Facts: 8 ricerche al minuto e sospensione di 5 minuti dopo 3 guasti. In quel caso compare un messaggio chiaro.

  Criterio: test di unità e di widget per i due casi.

### FR4 — "Apri in Google Lens" (ultima alternativa)

- **FR4.1 Quando.** Il pulsante compare sotto "Cerca online" negli stessi esiti, come **ultima** possibilità.
- **FR4.2 Consenso esplicito.** Al tocco compare una breve conferma: "La foto verrà inviata all'app Google sul tuo telefono. Vinoozy non riceve i risultati: torna qui per scegliere o scrivere il vino." Le scelte sono "Apri Google Lens" e "Annulla". Senza conferma la foto non esce. Criterio: test di widget.
- **FR4.3 Come.**
  - L'app passa la foto del fronte all'app Google o a Google Lens con un intent Android, tramite un `FileProvider` sulla cartella `cache/label/` e solo per quel file.
  - Se l'app Google non è installata, si apre il menu "Condividi" del telefono con la stessa foto.
  - Al ritorno l'utente resta nell'esito, con "Scrivi a mano" e "Cerca online".

  Criterio: test nativo (Robolectric) dell'intent e del ripiego, e test che il `FileProvider` esponga solo `cache/label/`.
- **FR4.4 Niente importazione.** Vinoozy non legge i risultati di Google.

### FR5 — Correzione: niente Open Food Facts senza rete

Senza rete l'app non chiama Open Food Facts e non conta guasti, quindi non manda falsi `off_suspended` a Crashlytics. Criterio: test di unità del gradino online con la rete assente.

## Requisiti non funzionali

- **NFR1 Dimensione.** L'aumento dell'app dovuto alla base offline si misura e si riporta. Il proprietario ha detto che il peso non è un problema, quindi non è un controllo bloccante. Si fissa comunque un tetto di sicurezza di 40 MB di aumento: oltre, si chiede al proprietario. La misura è in Build and Test (`tool/check_app_size.sh` a mano).
- **NFR2 Velocità sul telefono di riferimento** (build release; nei test vale un benchmark sullo stesso algoritmo):
  - ricerca per codice nella base ≤ 50 ms;
  - confronto del testo con la base ≤ 300 ms;
  - apertura della base al primo uso ≤ 1,5 s, senza bloccare l'interfaccia.
- **NFR3 Privacy.**
  - Le foto restano sul telefono, tranne quando il proprietario tocca e conferma "Apri Google Lens".
  - Vanno aggiornate l'informativa e la scheda "Sicurezza dei dati" di Google Play (azione del proprietario), con la voce in `docs/release-checklist.md`.
- **NFR4 Test.**
  - Copertura ≥ 80% sul progetto senza esclusioni e su `lib/label/` e `lib/catalog/`.
  - Suite esistente verde.
  - L'end-to-end `integration_test/label_test.dart` aggiunge fronte e retro con la sorgente finta, compresi un codice solo sul retro e "Salta".
  - Nessun test né job CI chiama il vero Open Food Facts o Google.
- **NFR5 Nessun costo.** Nessun servizio a pagamento. Pacchetti nuovi solo open source e gratuiti, se servono per la base, decisi in Functional Design. Le chiamate a Open Food Facts restano dentro le sue regole d'uso (User-Agent con contatto, limiti attuali).
- **NFR6 Stile e lingue.**
  - Codice e commenti in inglese.
  - Testi nei 3 file ARB.
  - Matrice di accessibilità esistente (3 lingue × testo 1,0/2,0 × chiaro/scuro) per le schermate nuove.
  - `dart format` e `flutter analyze --fatal-infos` puliti.

## Vincoli

- `lib/catalog/core/` resta puro (regola di `tool/check_off_config.sh`): l'accesso al file della base sta in `platform/`.
- Le build demo, CI ed end-to-end tengono Open Food Facts spento: la base offline di prova viene dall'estratto nel repository.
- Lavoro in autonomia fino alla consegna, con escalation al proprietario per:
  - aumento oltre 40 MB;
  - costi;
  - dubbi di licenza;
  - pubblicazione delle regole.

## Assunzioni

- L'export pubblico di Open Food Facts si può scaricare liberamente ed è sotto licenza ODbL; i contenuti dei singoli prodotti sono sotto DbCL. Si verifica in NFR Requirements.
- L'app Google (o Google Lens) accetta un'immagine con l'intent di condivisione. Si verifica in Functional Design. Se l'intent diretto non funziona, resta il menu "Condividi".

## Fuori ambito

- Il doppione nello Storico (lavoro dedicato).
- Il rischio R-01 della fascia.
- L'app per iPhone.
- La lettura automatica dei risultati di Google.
- La ricerca con Cloud Vision o altri servizi a pagamento.

## Domande aperte

Nessuna per il proprietario. Dimensione reale della base, formato del file ed eventuale pacchetto per leggerla si decidono in Functional Design e NFR Requirements.
