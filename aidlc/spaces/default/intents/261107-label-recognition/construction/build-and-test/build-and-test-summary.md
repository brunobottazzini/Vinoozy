# Riepilogo di Build and Test — riconoscimento delle etichette

## Fonti

- `construction/code-generation/code-generation-plan.md` (piano approvato, 19 passi)
- `construction/code-generation/unit-test-instructions.md` (comandi dei test)
- `construction/code-generation/code-summary.md` (cosa è stato costruito, scostamenti, correzioni della revisione)

## Esito

**Superato, con un fallimento accettato.** Il riconoscimento delle etichette è verde in tutti i controlli:
- test di unità e widget 2070/0;
- copertura 89,17% sul progetto, 98,81% su `lib/label/`, 98,17% su `lib/catalog/`;
- e2e delle etichette 5/5;
- formattazione e analisi pulite.

L'unico rosso è un e2e della cantina, "drink, History, Undo". Riguarda il flusso della bevuta della UX e non questo lavoro. Il proprietario l'ha accettato (messaggio ae246174): va risolto insieme al doppione dello Storico prima dello store.

## Cosa è stato trovato e corretto in questa fase

- I servizi della lettura (fotocamera, catalogo, Lens) venivano dallo scope sbagliato. È stato corretto, con un test di regressione.
- I difetti del supporto dell'e2e: pulsanti fuori schermo, memoria temporanea della ricerca, tasto indietro cercato in inglese.
- Le correzioni R-01…R-05 della revisione del codice. La più importante: la base di prova non può più passare per Open Food Facts e non può arrivare in produzione.
- La prima corsa completa dell'e2e (6 falliti) dipendeva dall'emulatore con testo al 200%, non dal codice. Il proprietario lo ha riportato al 100%.

## Cosa resta prima dello store

1. **Base reale:**
   - scaricare l'export di Open Food Facts;
   - generare la base con `tool/build_wine_db.dart`;
   - misurare dimensione, apertura e memoria sul telefono (NFR1.1, NFR2.3, NFR2.5).
2. **`OFF_CONTACT`** in `config/firebase_prod.json` e nel segreto di GitHub. È un'azione del proprietario.
3. **Informativa e scheda "Sicurezza dei dati"** per Lens, poi il repository pubblico con i controlli di NFR3.10. Sono azioni del proprietario.
4. **Doppione nello Storico e "Annulla"** nella scheda Storico: lavoro dedicato.
5. **Avviso Flutter "setState during build"** su `CellarSwitcher` all'avvio a freddo: instabile e già presente. Va seguito a parte.

## Lavoro successivo approvato

Un nuovo lavoro, che parte dai mockup:
- "Compila dall'etichetta";
- "Incolla da Lens";
- stima della finestra estesa ai vini di tutto il mondo, con le denominazioni e i vitigni, il campo "Livello" e la correzione manuale.

## File di questa fase

- `test-results.md`
- `build-instructions.md`
- `integration-test-instructions.md`
- `cross-unit-traceability.md`
