# Performance Requirements — u6-label-recognition

Fonti: `requirements.md` (NFR1, NFR5), `functional-spec.md` e `rules.md` di U6 (BR1.7, BR1.8, BR1.13, BR1.15 e chiarimenti), `contract-summary.md` (C1), riepilogo confermato in `nfr-requirements-questions.md`.

Telefono di riferimento: lo stesso delle altre unità (Android di fascia media, indicato nella checklist di rilascio §1).

Per un'unità di interfaccia non esistono requisiti separati di scalabilità, affidabilità e osservabilità:
- la scala è una foto alla volta;
- l'affidabilità è in `security-requirements.md`;
- l'osservabilità si limita ai motivi fissi degli errori.

## Tempi

| ID | Requisito | Verifica |
|---|---|---|
| NFR1.1 | **Dalla foto alla proposta:** mediana di 10 prove **≤ 3 s** con la rete e **≤ 2 s** senza rete, dal ritorno dalla fotocamera o dalla galleria alla comparsa della proposta, del messaggio di etichetta illeggibile o del modulo di U4. | Misura manuale nella checklist di rilascio (§1-sexies). |
| NFR1.2 | **Lettura sul telefono** (codice e testo, immagine ridotta a 2.048 pixel sul lato lungo): **≤ 1,5 s** per foto sul telefono di riferimento. | Misura manuale; in CI un test end-to-end sull'emulatore verifica che la lettura delle immagini di prova finisca entro 10 s (limite largo, l'emulatore è lento). |
| NFR1.3 | **Aggiunta con la foto:** dal tocco su "Aggiungi" alla conferma, mediana di 10 prove **< 30 s** su vini riconosciuti (NFR1). | Misura manuale nella checklist. In CI un test dei widget conta i passi minimi: "Scatta foto", "Conferma". |
| NFR1.4 | **Annulla** durante la lettura risponde entro **300 ms** e cancella la copia. | Test dei widget con lettura finta bloccata. |

## Qualità del riconoscimento

| ID | Requisito | Verifica |
|---|---|---|
| NFR2.1 | Su **20 etichette reali** di vini italiani (fronte), almeno **14 su 20** propongono il nome giusto con la rete; senza rete, almeno 14 su 20 propongono la denominazione giusta quando l'etichetta ne riporta una riconosciuta. | Misura manuale a ogni versione che cambia lettura o ricerca; elenco delle bottiglie e risultato nella checklist (§1-sexies). |
| NFR2.2 | Nessuna proposta salva un vino senza "Conferma" o "Salva" (FR2.3). | Test dei widget. |

## Peso dell'app

| ID | Requisito | Verifica |
|---|---|---|
| NFR2.3 | I modelli inclusi di ML Kit aumentano la **dimensione di download per telefono** al più di **15 MB** rispetto alla versione precedente. | `bundletool get-size total` sul bundle firmato, confrontato con la versione precedente; annotato nella checklist. |

## Costo (NFR5)

| ID | Requisito | Verifica |
|---|---|---|
| NFR5.1 | **Al più 2 richieste** a Open Food Facts per foto: una per codice, una per testo, nei limiti di richieste di U3. | Test con catalogo finto che conta le chiamate. |
| NFR5.2 | **Nessuna lettura né scrittura nuova** su Firestore oltre al salvataggio di U4; nessun servizio a pagamento; ML Kit gratuito sul telefono. | Revisione del codice; test che il modulo non dipende da Firestore. |
