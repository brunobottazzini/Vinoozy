# NFR Design — u6-label-recognition — Domande

Contesto:
- requisiti non funzionali di U6 approvati (`performance-requirements.md`, `security-requirements.md` con le correzioni della revisione, `tech-stack-decisions.md`);
- `functional-spec.md` di U6 (BR1.1–BR1.15 e chiarimenti);
- `contract-summary.md` (C1);
- codice esistente: `lib/catalog/` (U3), `lib/cellar/` (U4), `lib/app/` (avvio, gestori degli errori), `android/app/src/main/`.

Non ci sono domande aperte: sono scelte tecniche che derivano dai requisiti. Le riassumo qui sotto per conferma.

## Consolidated Summary Confirmation

- **Modulo nuovo `lib/label/`**, separato in tre parti:
  - **logica pura**, senza Flutter e senza plugin: scelta della riga più significativa, lettura dell'annata, filtro dei codici a barre, ordine di ricerca, macchina degli stati della lettura (in lettura, proposta, illeggibile, codice senza risultato, permesso negato, annullata);
  - **adattatori**: `LabelReader` con la versione ML Kit (codice e testo in parallelo sulla stessa immagine), `ImageSource` con la versione `image_picker`, `TempLabelStore` per la cartella `label/` e le sue pulizie;
  - **schermate**: "Aggiungi" con tre pulsanti, lettura, proposta, errori.
  
  Nei test tutti gli adattatori si sostituiscono con versioni finte.
- **Foto condivise da altre app:** niente pacchetto esterno, ma un **piccolo canale nativo Android** in `MainActivity`. Così controlliamo noi ogni verifica di sicurezza:
  - solo `content://`;
  - copia interrotta a 20 MB;
  - controllo dei primi byte;
  - solo il primo elemento di una condivisione multipla.
  
  Il canale consegna a Dart solo il percorso della copia già verificata, oppure un motivo di scarto. All'avvio a freddo tiene solo il riferimento, come previsto.
- **Velocità:**
  - l'immagine si riduce a 2.048 pixel sul lato lungo sul lato nativo, prima di ML Kit, leggendo prima solo le dimensioni (scarto oltre 50 milioni di pixel);
  - codice e testo si leggono in parallelo;
  - la ricerca nel catalogo parte appena c'è il codice, senza aspettare il testo;
  - "Annulla" interrompe l'attesa subito e la lettura in corso viene ignorata.
- **Collegamento con U4:** `AddWineInitialValues` per il modulo, `DuplicateDialog` reso pubblico, "Conferma" tramite `CellarActions.saveNewWine`. La conversione della tipologia del catalogo usa la funzione già usata da U4 per i suggerimenti.
- **Privacy:**
  - ogni eccezione del modulo si cattura e si traduce in uno dei 4 motivi fissi;
  - una sola funzione scrive nei report, così un test può verificare che non passi mai testo letto, codice o percorso;
  - la pulizia della cartella `label/` parte all'avvio dell'app, prima di qualsiasi lettura, e cancella anche i file più vecchi di 10 minuti.
- **Qualità e CI:**
  - copertura dell'80% su `lib/label/` nel job `unit`;
  - controllo degli ID BR1.1–BR1.15 nel job `analyze`;
  - un test del manifest unito: nessun permesso di fotocamera o foto, filtro di condivisione solo per immagini;
  - un test end-to-end nel job `e2e` con immagini di prova generate da uno script nostro (testo e codice a barre), consegnate da un selettore finto, con la lettura vera di ML Kit;
  - la misura della dimensione dell'app con `bundletool` va nella checklist.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
