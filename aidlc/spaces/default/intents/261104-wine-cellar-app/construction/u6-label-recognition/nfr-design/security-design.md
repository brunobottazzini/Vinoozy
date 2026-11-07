# Security Design — u6-label-recognition

Fonti: `security-requirements.md` (NFR4.1–NFR4.5, NFR8.1–NFR8.3, NFR3.1–NFR3.3, NFR6.1–NFR6.3), `tech-stack-decisions.md`, `functional-spec.md`, `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`. Come nei requisiti, il file raccoglie anche accessibilità e affidabilità.

## 1. Confine con il cloud (NFR4.1)

- I file di `lib/label/` non importano `cloud_firestore` né `firebase_storage`. Un test di script (`tool/check_label_imports.sh`) lo verifica nel job `analyze`, come lo script di sola lettura del Cruscotto.
- Il salvataggio passa da `CellarActions.saveNewWine` di U4: valgono le regole di U4 e U7.
- Verso Open Food Facts, tramite U3, escono solo il codice normalizzato e il testo letto; `matchLabelText` ne ricava le parole di ricerca. Un test con catalogo finto verifica gli argomenti: mai percorsi, byte o metadati dell'immagine.

## 2. Permessi e manifest (NFR4.2, NFR4.3)

- `AndroidManifest.xml` non dichiara `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE`. Le dipendenze potrebbero aggiungerli: si rimuovono con `tools:node="remove"`.
- **Verifica sul manifest unito (correzione dopo la revisione):** il controllo sta in `tool/check_release_build.sh`, che costruisce già la build di rilascio nel job `unit`. Dopo la build legge con `grep` sugli attributi `android:name` il manifest unito della build di rilascio di produzione, la prima delle due build dello script (`build/app/intermediates/merged_manifest/release/processReleaseMainManifest/AndroidManifest.xml`; il percorso esatto si verifica alla prima esecuzione e lo script fallisce se il file non esiste) e fallisce se compare uno dei tre permessi, o se il filtro di condivisione ammette azioni o tipi diversi da `ACTION_SEND`/`ACTION_SEND_MULTIPLE` e `image/*`. Il test del manifest sorgente di U7 resta com'è.
- Filtro di condivisione sulla `MainActivity`: `ACTION_SEND` e `ACTION_SEND_MULTIPLE`, categoria `DEFAULT`, `mimeType="image/*"`; nessun'altra azione nuova.
- iPhone: voce della checklist per la prima build, perché la cartella `ios/` non esiste ancora.

## 3. Immagini in ingresso (NFR4.4, NFR4.5)

Tutte le immagini, condivise **e** da `image_picker`, passano da un unico preparatore nativo Android, `LabelImagePreparer` (correzione dopo la revisione). Dart non decodifica né controlla le immagini da sé.

**Ingresso:**
- per una condivisione, il `SharedImageReceiver` fa i primi controlli, copia e poi chiama il preparatore;
- per `image_picker`, il file arriva **senza** `maxWidth`/`maxHeight` (il plugin non riduce) e Dart chiama `prepare(path)` sul canale. Il preparatore accetta solo percorsi canonici dentro `cacheDir`, dove `image_picker` scrive; altrimenti rifiuta con `scheme` senza leggere né cancellare nulla. Cancella il file di ingresso solo se sta dentro `cacheDir`.

```text
[share only] uri.scheme == "content"             else reject(scheme)
[share only] type startsWith "image/"            else reject(type)
[share only] copy 64 KB chunks to cacheDir/label abort+delete when bytes > 20 MB
size(file) <= 20 MB                              else delete+reject(size)
magic bytes in {JPEG, PNG, WebP, HEIC}           else delete+reject(format)
HEIC and SDK_INT < 28                            -> delete+reject(format)
bounds = BitmapFactory(inJustDecodeBounds)       w*h > 50_000_000 -> delete+reject(size)
inSampleSize = largest power of 2 with long side / n >= 2048
bitmap = decode(inSampleSize)                    OOM or exception -> delete+reject(decode)
scale to 2048 long side, apply EXIF orientation (androidx.exifinterface)
write JPEG q90 to cacheDir/label/<id>.jpg, delete the input file
return path
```

- **Thread:** tutto il lavoro gira su un thread in background (`Executors.newSingleThreadExecutor`), mai sul thread principale; il risultato torna al canale sul thread principale.
- **Eccezioni native:** ogni passo è in `try/catch (Throwable)`, compreso `OutOfMemoryError`; il canale restituisce solo un codice di scarto (`scheme`, `type`, `size`, `format`, `decode`), mai messaggi o percorsi. In Dart diventano "Non riesco a leggere l'etichetta" con `label_pick_failed`.
- **HEIC prima di Android 9 (API 28):** non decodificabile da `BitmapFactory`; si scarta con il codice `format`. Con `minSdk` 24 è un limite noto, annotato nella checklist. Le fotocamere di quei telefoni salvano in JPEG.
- **Quando si controlla cosa:** azione, primo URI di `ACTION_SEND_MULTIPLE`, schema `content://` e tipo dichiarato si controllano alla **ricezione** dell'intent, prima di tenere l'URI; copia, dimensione, formato e pixel si controllano alla **lettura**, quando Dart la chiede.
- **Consumo dell'intent:** dopo averlo letto, il receiver sostituisce l'intent dell'Activity con uno vuoto (`setIntent(Intent())`), così una rotazione o un ritorno all'app non ripresenta la stessa condivisione. Gestisce sia `onCreate` sia `onNewIntent`.
- **Cartella condivisa tra Kotlin e Dart:** è `context.cacheDir/label`, la stessa che `path_provider` restituisce in Dart come `getTemporaryDirectory()/label`. Il nome `label` è una costante in entrambi i lati, verificata da un test di integrazione sul canale.

- Con `ACTION_SEND_MULTIPLE` si legge solo il primo URI; gli altri non si aprono.
- Avvio a freddo: il receiver tiene solo l'URI in memoria. La copia parte quando Dart chiede la lettura, cioè dopo accesso e cantina attiva (BR1.4). Il conteggio dei 60 s parte da lì; se l'utente annulla l'accesso, l'URI si scarta subito.


## 4. File temporanei (NFR8.1)

- Una sola cartella: `<cartella temporanea dell'app>/label/`. Nessun file di U6 vive altrove; il file di `image_picker` si sposta lì appena arriva.
- `TempLabelStore.release(id)` si chiama in un `finally` della lettura, in `dispose` della sessione e quando una nuova lettura sostituisce la vecchia.
- **All'avvio (correzione dopo la revisione):** lo svuotamento di `label/` e `retrieveLostData` di `image_picker` (letto e scartato) partono in background dopo il primo frame, senza rallentare l'apertura. `TempLabelStore` tiene una `Future` di pulizia: ogni nuova lettura la attende prima di creare file, così la pulizia avviene comunque prima di qualsiasi lettura. Di solito la cartella è vuota e la pulizia dura pochi millisecondi.
- A ogni nuova lettura si cancellano i file più vecchi di 10 minuti.

## 5. Report degli errori e privacy (NFR8.2, NFR8.3)

- **Motivi fissi:** `label_read_failed`, `label_pick_failed`, `label_lookup_failed`, `label_cleanup_failed`, solo tramite `LabelErrorReporter`, con il tipo dell'eccezione e senza messaggio.
- **Eccezioni catturate nel modulo:** ogni `await` verso un adattatore è in try/catch; nessuna eccezione di U6 arriva a `FlutterError.onError` o a `PlatformDispatcher.onError`.
- **Test:** un test fa fallire lettura, scelta e ricerca con messaggi marcatore e verifica che nessun marcatore arrivi né all'`ErrorSink` finto né ai gestori globali.
- **Checklist di rilascio:**
  - §1-bis: il codice e le parole lette dalla foto vanno a Open Food Facts come i suggerimenti;
  - §2: le foto non si raccolgono, e i dati di ML Kit si verificano sulla guida di Google, con data;
  - l'informativa sulla privacy si aggiorna.

## 6. Accessibilità (NFR3)

- Pulsanti di `AddChoiceScreen` con `minimumSize` 48 dp, icona e testo; `Semantics(button: true)`.
- `LabelReadingScreen` con `Semantics(liveRegion: true)` per "Leggo l'etichetta…"; proposta ed errori annunciati con `SemanticsService.announce`.
- Testo al 200% senza tagli: proposta in `SingleChildScrollView`.

## 7. Affidabilità (NFR6)

- **Senza rete:** `LabelLookupFlow` salta `lookupBarcode`; `matchLabelText` usa la denominazione interna; i modelli inclusi leggono sempre.
- **Uscite garantite:** ogni stato finale di `LabelSession` ha "Riprova" o "Scrivi a mano"; un test per ogni stato verifica che almeno una delle due sia presente e attiva.
- **Errori del catalogo:** U3 lancia solo `CatalogArgumentError` (testo troppo lungo, codice non valido) e restituisce `null` o `LabelMatch.none()` quando Open Food Facts non risponde. `CatalogArgumentError` e qualsiasi altra eccezione valgono "nessun risultato" per quel passo; solo le eccezioni diverse da `CatalogArgumentError` si registrano come `label_lookup_failed`.
- **Letture annullate:** una lettura annullata continua in background, ma la sua `Future` ha sempre un gestore (`.catchError` che registra il motivo fisso e scarta il risultato). Così un suo errore non arriva mai ai gestori globali.
