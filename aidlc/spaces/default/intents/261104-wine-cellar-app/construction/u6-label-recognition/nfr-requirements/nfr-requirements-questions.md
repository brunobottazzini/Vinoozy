# NFR Requirements — u6-label-recognition — Domande

Contesto:
- design funzionale di U6 approvato (`functional-spec.md` BR1.1–BR1.15 con i chiarimenti, `rules.md`, `frontend-components.md`);
- `requirements.md`: NFR1 velocità di inserimento, NFR3 accessibilità, NFR5 costo, NFR6 offline, NFR7 qualità, NFR8 privacy (aggiornato il 2026-11-06: le foto non si conservano);
- `contract-summary.md` (C1: `lookupBarcode`, `matchLabelText` di U3);
- `team.md` (Testing Posture, Deployment);
- strumenti già presenti: emulatori, job `e2e`, script di copertura e degli ID delle regole.

Non ci sono domande aperte. Le scelte di questo passo sono tecniche e derivano dal design e dalle regole del team. Le riassumo qui sotto per conferma.

## Consolidated Summary Confirmation

- **Velocità:**
  - dalla foto scattata o scelta alla proposta: mediana di 10 prove **≤ 3 s** con la rete e **≤ 2 s** senza rete, sul telefono di riferimento;
  - la lettura sul telefono (codice e testo) richiede al più 1,5 s: prima l'immagine si riduce a 2.048 pixel sul lato lungo;
  - la ricerca nel catalogo usa i tempi massimi di U3 e al più 2 richieste per foto (una per codice, una per testo);
  - aggiungere un vino con la foto, dal tocco su "Aggiungi" alla conferma, richiede meno di 30 s, come la scrittura (NFR1).
- **Qualità del riconoscimento** (misura manuale, non in CI):
  - su 20 etichette reali di vini italiani, almeno **14 su 20** propongono il nome giusto (o la denominazione giusta senza rete);
  - nessuna proposta salva un vino senza "Conferma";
  - la misura si annota nella checklist di rilascio a ogni versione che cambia la lettura.
- **Peso dell'app:** i modelli di ML Kit inclusi aumentano la dimensione di download al più di **15 MB** per telefono, misurata con `bundletool` sul bundle firmato.
- **Costo:** 0 €. ML Kit gira sul telefono ed è gratuito; Open Food Facts resta nei limiti già fissati da U3; nessuna scrittura nuova su Firestore oltre al salvataggio di U4.
- **Privacy e sicurezza:**
  - nessuna immagine esce dal telefono;
  - la copia temporanea sta nella cartella temporanea dell'app e si cancella entro 1 s dalla fine della lettura, e comunque all'avvio successivo;
  - testo, codice e immagine non vanno mai nei report degli errori, solo i 4 motivi fissi;
  - su Android il manifest **non** dichiara `CAMERA` né permessi di lettura delle foto (selettore di sistema);
  - su iPhone le spiegazioni dei permessi (fotocamera, foto) sono tradotte nelle tre lingue;
  - un'immagine condivisa da un'altra app si accetta solo se è un'immagine e pesa al più 20 MB; altrimenti "Non riesco a leggere l'etichetta";
  - la scheda "Sicurezza dei dati" di Google Play non dichiara foto, perché non si raccolgono: la lettura avviene solo sul telefono.
- **Accessibilità:** aree di tocco ≥ 48 dp, contrasto ≥ 4,5:1, testo al 200%, avvisi di TalkBack per lettura, proposta ed errori, nelle tre lingue.
- **Affidabilità:** ogni errore (fotocamera, galleria, lettura, catalogo) porta a una via d'uscita ("Riprova" o "Scrivi a mano"), mai a un blocco; la lettura senza rete funziona sempre.
- **Dipendenze nuove**, nell'ultima versione stabile, tutte gratuite:
  - `image_picker` per fotocamera e galleria di sistema;
  - `google_mlkit_text_recognition` e `google_mlkit_barcode_scanning` con i modelli inclusi;
  - un pacchetto per ricevere le immagini condivise (scelto nel design non funzionale).
- **Qualità del codice:**
  - copertura ≥ 80% delle righe del nuovo modulo e del progetto, senza esclusioni;
  - ogni regola BR1.1–BR1.15 ha un test con l'ID nel nome;
  - test dei widget nelle tre lingue;
  - un test end-to-end nel job `e2e` con immagini di prova create da noi, senza etichette reali protette, e la lettura vera sull'emulatore;
  - i test di U3 e U4 restano verdi.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
