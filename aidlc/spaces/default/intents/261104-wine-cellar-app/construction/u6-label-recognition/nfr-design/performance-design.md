# Performance Design — u6-label-recognition

Fonti: `performance-requirements.md` (NFR1.1–NFR1.4, NFR2.1–NFR2.3, NFR5.1–NFR5.2), `tech-stack-decisions.md` (NFR7.1–NFR7.5), `functional-spec.md` di U6, `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`.

Per un'unità di interfaccia non esistono `scalability-requirements.md`, `reliability-requirements.md` e `observability-requirements.md` separati:
- la scala è una foto alla volta;
- l'affidabilità è in `security-design.md` §7;
- l'osservabilità sono i motivi fissi di `security-design.md` §5.

## 1. Dalla foto alla proposta (NFR1.1, NFR1.2)

```text
picker/receiver ─▶ downscale 2048 ─▶ ┌ barcode scan ─▶ lookupBarcode (rete) ┐
                                     └ text recognize ───────────────────────┴▶ matchLabelText ─▶ proposta
```

- Riduzione a 2.048 pixel sul lato lungo prima di ML Kit, sempre nel preparatore nativo `LabelImagePreparer` (`security-design.md` §3): decodifica con `inSampleSize` per non caricare in memoria l'immagine intera, poi scala esatta e orientamento EXIF.
- Codice e testo in parallelo sulla stessa immagine.
- `lookupBarcode` parte appena c'è un codice valido, mentre il testo è ancora in lettura; se dà un risultato, `matchLabelText` non parte.
- I riconoscitori di ML Kit si creano una volta per sessione e si chiudono alla fine, per non tenere memoria occupata.

## 2. Annulla (NFR1.4)

- "Annulla" porta subito `LabelSession` in `cancelled` e chiude la schermata; le `Future` in corso continuano ma il loro risultato viene ignorato tramite un identificatore di lettura.
- La copia si cancella nel `finally` della lettura ignorata.

## 3. Aggiunta in meno di 30 s (NFR1.3)

- Percorso minimo: "Aggiungi" → "Scatta foto" → scatto → "Conferma". Un test dei widget con lettore e catalogo finti conta i tocchi.
- "Conferma" usa il salvataggio di U4, che torna all'elenco senza aspettare la rete.

## 4. Costo e peso (NFR2.3, NFR5.1, NFR5.2)

| Voce | Costo |
|---|---|
| Richieste a Open Food Facts | Al più 2 per foto, nei limiti di richieste di U3 |
| Firestore | Nessuna lettura o scrittura da U6; il salvataggio è quello di U4 |
| Modelli di ML Kit | Inclusi; dimensione di download misurata con `bundletool get-size total` (≤ +15 MB) |

## 5. Qualità e CI (NFR7.1–NFR7.5)

| Requisito | Collegamento |
|---|---|
| NFR7.1 copertura | Job `unit`: `tool/check_coverage.sh 80 coverage/lcov.info lib/label/` |
| NFR7.2 ID delle regole | Job `analyze`: `tool/check_rule_ids.sh BR1. 15 test/label` |
| NFR7.3 tre lingue | `flutter test`, con `textScaler` 2.0 |
| NFR7.4 end-to-end | Job `e2e`: `integration_test/label_test.dart`. Le immagini di prova si generano con `tool/gen_label_fixtures.dart` (testo "Barolo DOCG 2016" e un codice EAN-13 disegnati su sfondo chiaro, nessuna etichetta reale). Un `ImageSource` finto le consegna; la lettura usa ML Kit vero sull'emulatore; il catalogo usa la base interna e un finto per Open Food Facts (mai il servizio reale in CI). |
| NFR7.5 non regressione | Suite completa; test di U4 per `AddWineInitialValues` e `DuplicateDialog` |
| Manifest | Job `unit`, dentro `tool/check_release_build.sh` dopo la build di rilascio: manifest unito senza permessi di fotocamera o foto, filtro di condivisione solo `ACTION_SEND`/`ACTION_SEND_MULTIPLE` e `image/*` |
| Import | Job `analyze`: `tool/check_label_imports.sh` (nessun Firestore in `lib/label/`) |

## 6. Misure

| Misura | Dove | Soglia |
|---|---|---|
| Foto → proposta, con rete | Telefono, 10 prove, checklist §1-sexies | mediana ≤ 3 s |
| Foto → proposta, senza rete | Telefono, 10 prove | mediana ≤ 2 s |
| Lettura sul telefono | Telefono | ≤ 1,5 s |
| Lettura sull'emulatore | Test end-to-end in CI | ≤ 10 s |
| Riconoscimento | 20 etichette reali, checklist | ≥ 14 su 20 |
| Dimensione dell'app | `bundletool` sul bundle firmato | ≤ +15 MB |
| Annulla | Test dei widget | ≤ 300 ms |
