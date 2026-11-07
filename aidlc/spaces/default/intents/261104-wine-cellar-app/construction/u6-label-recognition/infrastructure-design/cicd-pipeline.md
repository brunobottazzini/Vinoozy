# CI/CD Pipeline — u6-label-recognition

Fonti: `security-design.md`, `performance-design.md` e `logical-components.md` di U6; `functional-spec.md` di U6 e `components.md`; `.github/workflows/ci.yml`, `release.yml`, `promote.yml`; `tool/check_release_build.sh`; riepilogo confermato in `infrastructure-design-questions.md`.

U6 non aggiunge job. Aggiunge passi ai job esistenti di `ci.yml`; `release.yml`, `promote.yml` e `firebase-deploy.yml` non cambiano. Tutti i controlli restano obbligatori prima del merge in `main` (team.md).

## 1. Modifiche a `ci.yml`

| Job | Passo | Cosa verifica | Requisito |
|---|---|---|---|
| `analyze` | `tool/check_rule_ids.sh BR1. 15 test/label` | Ogni regola BR1.1–BR1.15 è citata in almeno un test | NFR7.2 |
| `analyze` | Nuovo `tool/check_label_imports.sh` e il suo test `tool/check_label_imports_test.sh` (cartelle di prova `ok/` e `firestore_import/`) | Nessun file di `lib/label/` importa `cloud_firestore` o `firebase_storage` | NFR4.1, NFR5.2 |
| `unit` | `flutter test --coverage` include `test/label/`; nuovo passo `tool/check_coverage.sh 80 coverage/lcov.info lib/label/` | Logica, adattatori finti, schermate nelle tre lingue; copertura ≥ 80% | NFR3.x, NFR6.x, NFR7.1, NFR7.3 |
| `unit` | `tool/check_release_build.sh` (esistente) esteso. Dopo la build di rilascio legge il manifest unito **in chiaro** prodotto da Gradle nella cartella intermedia (`build/app/intermediates/merged_manifest/release/.../AndroidManifest.xml`), non quello binario dentro l'AAB | **Controllo negativo:** nessun `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE`. **Controllo positivo:** il filtro di condivisione esiste, con solo `ACTION_SEND`/`ACTION_SEND_MULTIPLE` e `image/*`. Lo script fallisce se il file non esiste | NFR4.2, NFR4.4 |
| `unit` | **Nuovo (correzione dopo la revisione):** `cd android && ./gradlew :app:testDebugUnitTest :app:jacocoLabelReport` | Test JUnit con Robolectric per `LabelImagePreparer` e `SharedImageReceiver`: schema `file://` e percorsi fuori da `cacheDir` rifiutati; tipo dichiarato sbagliato; byte non immagine; flusso oltre 20 MB interrotto e cancellato; 60 milioni di pixel; HEIC con API 27 e 28; `OutOfMemoryError` simulato; EXIF ruotato; `ACTION_SEND_MULTIPLE` con il solo primo URI; intent consumato in `onCreate` e `onNewIntent`. Copertura JaCoCo ≥ 80% delle righe delle due classi, con soglia nello script Gradle | NFR4.4, NFR4.5, NFR8.1 |
| `unit` | **Nuovo:** `tool/check_app_size.sh` dopo la build di rilascio | `bundletool get-size total` (jar scaricato a versione fissa con controllo SHA-256) sull'AAB; fallisce se la dimensione massima supera di oltre 15 MB il valore in `tool/app_size_baseline.txt`. Il valore di base si aggiorna solo con un blocco dedicato | NFR2.3 |
| `e2e` | Nessun passo nuovo: `flutter test integration_test` raccoglie `label_test.dart` | Vedi sotto "Immagini di prova" | NFR1.2, NFR4.4, NFR7.4 |

**Immagini di prova dell'end-to-end (correzione dopo la revisione).**
- **Nessun file nel repository né negli asset**, quindi nulla finisce nella build di rilascio.
- Il test le **disegna sull'emulatore, al momento**, con `dart:ui` (`PictureRecorder`, `Canvas`, `TextPainter` con il carattere di sistema di Android) e le salva come PNG in `cacheDir/label/`:
  - un'immagine con "Barolo DOCG 2016" in nero su sfondo chiaro, 1.600 × 1.000 pixel;
  - un'immagine con un codice EAN-13 noto, le cui barre si calcolano con un piccolo codificatore Dart solo di test (`integration_test/support/ean13_painter.dart`);
  - un file con byte casuali e nome `.jpg`.
- **Consegna:** il test sostituisce `imageSourceProvider` con un `FakeImageSource` (`integration_test/support/fake_image_source.dart`) che restituisce quei percorsi al posto del selettore di sistema. Le immagini passano comunque dal canale vero verso `LabelImagePreparer`, poi da ML Kit vero.
- **Casi provati:** codice letto e proposta dal catalogo finto; testo letto e proposta "Barolo DOCG" senza rete; file non immagine con "Non riesco a leggere l'etichetta"; conferma che salva tramite U4 sulla Firebase Emulator Suite; cartella `label/` vuota alla fine.
- **Condivisione tramite intent:** si prova nei test Robolectric del job `unit`. L'end-to-end non simula un'altra app che condivide.

Tempi stimati, da misurare alla prima esecuzione:
- **`analyze`:** pochi secondi.
- **`unit`:** da 2 a 4 minuti in più (test Gradle e Robolectric, build di rilascio più pesante, `bundletool`). Il job ha oggi `timeout-minutes: 15`. Se la misura supera 12 minuti, il limite sale a 25 nello stesso blocco: alzare il tempo massimo non abbassa nessun controllo.
- **`e2e`:** circa 2 minuti in più.

I test non chiamano mai Open Food Facts reale.

## 2. Pubblicazione

1. **Merge su `main`:** `release.yml` costruisce l'AAB firmato e lo pubblica sul test interno.
2. **Prova** della checklist §1-sexies sul telefono, compresa la misura della dimensione con `bundletool`.
3. **Promozione** con `promote.yml` e la tua approvazione, con rilascio graduale.

Non serve `firebase-deploy.yml`: U6 non cambia regole né indici, quindi il controllo delle regole di `promote.yml` passa senza azioni.

## 3. Segreti

Nessun segreto nuovo. Firma, Play e Firebase restano nei segreti di GitHub Actions (team.md).

## 4. Rollback

- **App:** fermare il rilascio graduale e pubblicare una correzione, che passa dal test interno.
- **Regole, indici, dati:** nessuna azione.
- **Controllo di CI rotto per un motivo esterno** (per esempio una nuova versione di ML Kit che cambia la lettura delle immagini di prova): si corregge il test o le immagini in un blocco nuovo. Non si toglie il controllo e non si abbassano le soglie.
