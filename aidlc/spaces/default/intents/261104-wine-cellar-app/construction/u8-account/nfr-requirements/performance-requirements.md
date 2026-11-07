# Performance Requirements — u8-account

Fonti: `requirements.md` (NFR1, NFR2, NFR5), `functional-spec.md` e `rules.md` di U8 (BR1.1–BR1.13 e chiarimenti), riepilogo confermato in `nfr-requirements-questions.md`.

Telefono di riferimento: lo stesso delle altre unità.

**Dimensionamento:**
- **Caso peggiore usato per i limiti:** 500 vini presenti, 1.000 finiti, 2.000 bevute, 2 persone invitate.
- **Uso previsto dal proprietario:** al più circa 200 bottiglie.

Per un'unità di interfaccia non esistono requisiti separati di scalabilità, affidabilità e osservabilità:
- l'affidabilità è in `security-requirements.md`;
- l'osservabilità si limita ai motivi fissi degli errori.

## Tempi

| ID | Requisito | Verifica |
|---|---|---|
| NFR1.1 | **Presentazione, profilo e finestre di uscita** compaiono entro **300 ms** dal tocco. | Test dei widget; misura manuale nella checklist. |
| NFR1.2 | **Cancellazione completa** del caso peggiore in **meno di 60 s** con una buona rete, con l'avanzamento aggiornato a ogni passo. | Test end-to-end sugli emulatori con una cantina più piccola (50 vini, 100 bevute) e limite di 60 s; misura manuale del caso peggiore nella checklist. |
| NFR1.3 | **Attesa delle modifiche in coda** prima della cancellazione: al più **30 s**, poi messaggio con "Riprova". | Test con `waitForPendingWrites` finto che non finisce. |

## Costo (NFR5)

| ID | Requisito | Verifica |
|---|---|---|
| NFR5.1 | **Scritture della cancellazione:** una per documento. Caso peggiore circa 3.500, contro 20.000 gratuite al giorno. Con l'uso previsto (≈ 200 bottiglie) qualche centinaio. | Calcolo nella checklist; test che conta le scritture con dati di prova. |
| NFR5.2 | **Letture della cancellazione:** lettura dal server di vini e bevute della cantina; al più circa 3.500 nel caso peggiore, contro 50.000 gratuite al giorno. | Come sopra. |
| NFR5.3 | **Nessun servizio a pagamento:** nessuna funzione nel cloud; pagina su GitHub Pages gratuita. | Revisione. |
