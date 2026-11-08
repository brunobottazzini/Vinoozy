# Requisiti di sicurezza e privacy — riconoscimento delle etichette

## Fonti

- `inception/requirements-analysis/requirements.md` (NFR3, NFR4, NFR5).
- `construction/functional-design/rules.md` (BR1.4, BR5.1–BR5.3, BR6.1).
- `inception/refined-mockups/accessibility-checklist.md`, `interaction-spec.md`.
- `docs/release-checklist.md`, `firestore.rules`.

## Requisiti

| ID | Requisito | Verifica |
|---|---|---|
| NFR3.1 | Le foto non lasciano il telefono, tranne dopo il tocco su "Apri in Google Lens" **e** la conferma (BR5.1). Nessun caricamento automatico, nessun invio a Firebase o a Open Food Facts. | test: senza conferma il canale `vinoozy/lens` non viene chiamato; revisione del codice |
| NFR3.2 | Il testo della conferma dice che la foto passa all'app Google e che Google può conservarne una copia. Il testo sta nei 3 file ARB. | test dei widget nelle 3 lingue |
| NFR3.3 | Si condivide solo la foto del fronte, nella copia preparata per la lettura, che non ha metadati EXIF (posizione GPS, modello del telefono, data). La foto passa da un `FileProvider` limitato a `cache/label/`, solo con permesso di lettura temporaneo (`FLAG_GRANT_READ_URI_PERMISSION`), mai con permesso di scrittura e mai con `exported=true`. Con il ripiego del menu Condividi la foto va all'app scelta dall'utente: il testo di conferma (NFR3.2) dice "app Google o l'app che scegli". | test: la copia condivisa non ha EXIF; script in `tool/` che controlla nel manifest il provider, i percorsi e i `<queries>` (solo il pacchetto Google e `ACTION_SEND image/*`) |
| NFR3.4 | Le foto temporanee si cancellano all'uscita dall'esito e all'avvio (BR1.4): nessun file rimane in `cache/label/` dopo il riavvio. | test unitario di `TempLabelStore` + test e2e |
| NFR3.5 | Il codice nativo di Lens non legge niente dall'app Google e non riceve risultati (BR5.3). | revisione del codice nativo |
| NFR3.6 | `docs/release-checklist.md` ha la voce per aggiornare l'informativa privacy e la scheda "Sicurezza dei dati" di Google Play (foto condivisa con Google solo su richiesta). È un'azione del proprietario prima della pubblicazione. | presenza della voce |
| NFR3.7 | La base offline contiene solo dati pubblici dei prodotti (nome, produttore, denominazione, paese, annata, codice). Nessun dato personale. | test dello strumento sui campi in uscita |
| NFR3.8 | La ricerca online manda a Open Food Facts solo il testo che l'utente vede nel campo "Cerca online" o il codice a barre. Mai la foto, mai l'identità dell'utente. | test con client HTTP finto: controllo dei parametri |
| NFR4.4 | Nessun test e nessun job CI chiama il vero Open Food Facts o Google: client HTTP finto, canale Lens finto, `OFF_ENABLED=false` nelle build di test. | test + `tool/check_off_config.sh` esistente |
| NFR5.4 | Nessuna credenziale nuova. Il contatto nel User-Agent viene dalla configurazione esistente (`offContact`), non dal codice. | `tool/check_off_config.sh` + revisione |
| NFR3.10 | Prima di rendere pubblico il repository (Q1 = A, azione del proprietario): (a) il job `secrets` di CI (gitleaks su tutta la storia, `fetch-depth: 0`) è verde sull'ultimo commit di `main`; (b) `git log --all -- config/firebase_prod.json android/app/google-services.json` non restituisce nulla, cioè questi file non sono mai entrati in un commit; (c) il contatto `offContact` è un indirizzo che il proprietario accetta di rendere pubblico, perché sta già nel User-Agent dell'APK; (d) `firebase-config.js` contiene solo i segnaposto TODO. È una voce nuova di `docs/release-checklist.md`, da spuntare prima di cambiare la visibilità. | voce nella checklist + il comando (b) eseguito in B&T e riportato |

## Valutazione dei rischi

| Rischio | Impatto | Mitigazione |
|---|---|---|
| La foto finisce a Google senza che l'utente lo voglia | Alto (privacy) | conferma a ogni tocco, testo chiaro, solo il fronte (NFR3.1–NFR3.3) |
| Un'altra app legge le foto dal `FileProvider` | Medio | provider non esportato, permesso temporaneo per un solo URI, cartella limitata (NFR3.3) |
| Il file della base viene manomesso nell'APK | Basso | il file è dentro l'APK firmato; la base contiene solo dati pubblici |
| Testo malevolo nei dati di Open Food Facts | Basso | i dati entrano solo come testo nei campi del modulo, con i limiti di lunghezza e la validazione esistenti (`WineValidator`) |
| Un segreto finisce in pubblico quando il repository diventa pubblico | Alto | gitleaks su tutta la storia in CI, controllo dei file di configurazione di produzione nella storia, checklist prima di cambiare la visibilità (NFR3.10). Le regole Firestore restano l'unica protezione dei dati e non dipendono dalla segretezza della configurazione Firebase |

## Regole Firestore

Questo lavoro non cambia `firestore.rules`. I vini aggiunti da una proposta passano dalle stesse regole di oggi. Restano da distribuire, con l'OK del proprietario, le regole della UX (campo `country`): è un punto della release, non di questo lavoro.
