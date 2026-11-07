# Tech Stack Decisions — u6-label-recognition

Fonti: `components.md` (LabelRecognition: ML Kit), `functional-spec.md` di U6, `team.md` (Code Style, Testing Posture), riepilogo confermato in `nfr-requirements-questions.md`.

## Dipendenze nuove

Tutte gratuite, nell'ultima versione stabile al momento della generazione del codice, fissate in `pubspec.lock`.

| Pacchetto | Uso | Alternative scartate |
|---|---|---|
| `image_picker` | Fotocamera e galleria di sistema (BR1.2, BR1.3); su Android usa il selettore di foto senza permessi | `camera`: anteprima nell'app, scartata con Q2 = A; `file_picker`: meno adatto alle foto |
| `google_mlkit_text_recognition` | Lettura del testo latino sul telefono, modello incluso (BR1.7) | Riconoscimento nel cloud (Google Cloud Vision): costa e manda la foto fuori dal telefono, contro Q1 e NFR8 |
| `google_mlkit_barcode_scanning` | Lettura di EAN-13, EAN-8, UPC-A sul telefono (BR1.7, Q3) | Libreria di scansione dal vivo: serve l'anteprima, scartata con Q2 = A |
| Ricezione delle immagini condivise | "Condividi → Vinoozy" (BR1.4) | Il pacchetto si sceglie nel design non funzionale tra quelli mantenuti; in alternativa un piccolo canale nativo Android |

**Modelli inclusi.** Si usano le varianti con il modello dentro l'app, non quelle scaricate da Google Play Services. Così la lettura funziona al primo uso senza rete (chiarimenti di BR1.7), al costo di qualche MB (NFR2.3).

**Piattaforme.** Android è la piattaforma principale. Le tre librerie supportano anche iPhone; per iPhone servono solo le spiegazioni dei permessi (NFR4.3).

**Separazione.** La lettura sta dietro un'interfaccia Dart (`LabelReader`, con `read(imagePath)` che restituisce codici e testo). I test usano una versione finta; solo il test end-to-end usa ML Kit vero. Il resto del modulo (scelta della riga, ordine di ricerca, annata) è Dart puro.

## Requisiti di qualità

| ID | Requisito | Verifica |
|---|---|---|
| NFR7.1 | Copertura ≥ 80% delle righe del nuovo modulo `lib/label/` e del progetto, senza esclusioni. | `tool/check_coverage.sh 80 coverage/lcov.info lib/label/` nel job `unit`. |
| NFR7.2 | Ogni regola BR1.1–BR1.15 ha almeno un test con l'ID nel nome. | `tool/check_rule_ids.sh BR1. 15 test/label` nel job `analyze`. |
| NFR7.3 | Test dei widget delle schermate nelle tre lingue, con il testo al 200%. | `flutter test`. |
| NFR7.4 | Test end-to-end nel job `e2e`: immagini di prova create da noi (testo e codice a barre generati, nessuna etichetta reale protetta), selettore finto che le consegna, lettura vera con ML Kit sull'emulatore, proposta e conferma con la Firebase Emulator Suite. | Job `e2e`. |
| NFR7.5 | I test di U3 e U4 restano verdi, comprese le estensioni di U4 (`AddWineInitialValues`, `DuplicateDialog` pubblico). | Suite completa in CI. |
