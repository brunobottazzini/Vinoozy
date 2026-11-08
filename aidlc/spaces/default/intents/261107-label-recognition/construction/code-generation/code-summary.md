# Riepilogo del codice — riconoscimento delle etichette

## Cosa è stato costruito

- **Fronte e retro** (FR1). Dopo la foto del fronte, scattata, dalla galleria o condivisa, compare "Ora il retro" con "Scatta il retro", "Scegli dalla galleria" e "Salta". Il fronte viene preparato subito. Le due foto si leggono con ML Kit e si uniscono:
  - righe senza doppioni, al massimo 2000 caratteri per foto e 4000 in tutto;
  - codice a barre del fronte, altrimenti del retro;
  - "Retro non leggibile" quando il retro non si legge.

  Le copie preparate restano in `cache/label/` finché l'esito è aperto, perché servono a Google Lens. Si cancellano alla chiusura della schermata, all'annullamento e all'avvio dell'app.
- **Base dei vini sul telefono** (FR2):
  - righe JSON compresse con gzip in `assets/wine_db/`, aperte una sola volta in un isolate al primo uso;
  - un indice per codice a barre e un indice inverso delle parole;
  - punteggio del testo come in BR3.6, con le soglie di BR3.2 in un solo punto (`LabelMatchThresholds`).
- **Ordine dei tentativi** (BR3.1). `CatalogCoordinator.matchLabel` sostituisce `matchLabelText`. L'ordine è:
  1. codice nella base;
  2. testo nella base;
  3. denominazione del catalogo interno, sempre a 0,70 e mai proposta sicura da sola;
  4. solo con la rete e Open Food Facts attivo, codice e poi testo su Open Food Facts.

  Il risultato è una proposta sicura, una lista di candidati senza doppioni (vince la base offline) oppure nessun risultato.
- **Correzione FR5.** Senza rete Open Food Facts non viene chiamato, anche per i suggerimenti, e non si conta nessun guasto.
- **Esiti nuovi:**
  - proposta sicura con la fonte, "Non è questo" e l'attribuzione ODbL;
  - "Quale di questi?" con al massimo 10 candidati e i chip "offline", "online" o "catalogo";
  - "Non trovato" in tre tipi, con "Cerca online", "Scrivi a mano" e per ultimo "Apri in Google Lens".
- **Cerca online** (FR3):
  - campo già compilato con le parole più significative e l'annata, o con il codice a barre;
  - prima i risultati della base, poi quelli online;
  - messaggi per "senza rete" e per "non disponibile ora";
  - un risultato apre il modulo compilato sopra la lista: "indietro" torna alla lista, il salvataggio torna alla Cantina.
- **Google Lens** (FR4):
  - la conferma compare a ogni tocco;
  - canale `vinoozy/lens` con `LensIntentLauncher.kt`: `ACTION_SEND` verso l'app Google, poi il menu Condividi senza Vinoozy, oppure "failed";
  - `FileProvider` non esportato e limitato a `cache/label/`, `<queries>` limitate;
  - prima dell'invio, il Dart rifiuta un file che ha ancora metadati EXIF o XMP.
- **Informazioni** (BR6.3), dal menu della Cantina: versione, numero di vini e data dell'export, licenze ODbL e DbCL con il repository, nota sulla privacy delle foto.
- **Eventi** (NFR4.13–NFR4.15):
  - `wine_db_opened`, `label_outcome`, `online_search` e `lens_opened` vanno solo in console;
  - `wine_db_unavailable` va anche su Crashlytics, come errore non fatale, con il motivo e il numero di righe scartate.
- **Strumento** `tool/build_wine_db.dart`:
  - legge l'export in streaming, gzip o testo;
  - applica BR2.1–BR2.4;
  - si ferma oltre 3 MB compressi o 30 MB non compressi, e lascia la base precedente se un controllo fallisce.

## File toccati

**Nuovi:**
- `lib/catalog/core/offline/`:
  - `wine_db_record.dart`;
  - `text_score.dart`;
  - `wine_db_index.dart`.
- `lib/catalog/core/network_status.dart`.
- `lib/catalog/platform/`:
  - `wine_db_loader.dart`;
  - `connectivity_network_status.dart`.
- `lib/label/core/`:
  - `label_merge.dart`;
  - `lens_launcher.dart`.
- `lib/label/platform/lens_channel.dart`.
- `lib/label/ui/`:
  - `back_photo_prompt.dart`;
  - `reading_progress.dart`;
  - `candidate_list.dart`;
  - `not_found_view.dart`;
  - `online_search_screen.dart`;
  - `lens_confirm_sheet.dart`.
- `lib/app/ui/about_screen.dart`.
- `tool/`:
  - `build_wine_db.dart`;
  - `fixtures/off_wines_sample.csv`;
  - `check_lens_manifest.sh` e `check_lens_manifest_test.sh`, con `fixtures/lens_manifest/` (anche `comment_ok/` e `comment_bad/`, revisione R-05);
  - `check_wine_db_release.sh` e `check_wine_db_release_test.sh`, con `fixtures/wine_db_release/` (revisione R-02).
- `assets/wine_db/`: `wines.jsonl.gz`, `manifest.json`, `LICENSE`, `README.md`.
- `android/.../LensIntentLauncher.kt` e il suo test Robolectric.
- `android/.../res/xml/label_file_paths.xml`.
- `dart_test.yaml`, con il tag `benchmark`.
- `integration_test/support/fake_label_services.dart`.
- I test elencati in `traceability.json`.

**Modificati:**
- catalogo:
  - `wine_catalog.dart` (fonte `offline`, campo `country`, `LabelMatchResult`, `OnlineSearchResult`);
  - `catalog_coordinator.dart`;
  - `catalog_event_logger.dart`;
  - `crashlytics_catalog_event_logger.dart`;
  - `catalog_providers.dart`.
- etichetta:
  - `label_session.dart`, `label_lookup_flow.dart`, `label_reading.dart` (commento);
  - `label_providers.dart`, che contiene il controller;
  - `temp_label_store.dart`;
  - `label_reading_screen.dart`, `label_proposal_sheet.dart`, `label_capture_flow.dart`.
- cantina:
  - `add_wine_screen.dart`: `guessOrigin` usa il paese della base, nuovo `returnToRootOnSave`;
  - `cellar_screen.dart`: voce "Informazioni".
- `lib/l10n/*.arb`, poi `flutter gen-l10n`.
- `MainActivity.kt`, `AndroidManifest.xml`, `pubspec.yaml` (solo gli asset).
- `.github/workflows/ci.yml`, `docs/release-checklist.md`.
- `benchmark/catalog_benchmark.dart` e `integration_test_perf/estimation_perf_test.dart`, per il cambio di firma.
- Test esistenti adattati al nuovo percorso.

**Eliminati** (come da piano): `lib/label/ui/label_unreadable_view.dart` e `barcode_only_view.dart`, sostituiti da `NotFoundView`. `test/coverage_helper_test.dart` è stato rigenerato.

## Scostamenti dal piano

Il piano approvato (`code-generation-plan.md`) e `unit-test-instructions.md` restano come sono stati approvati. Le differenze tra il piano e il codice sono tutte qui, in un solo posto (revisione R-04):

| Punto del piano | Cosa dice il piano | Cosa c'è nel codice | Perché |
|---|---|---|---|
| Passo 5 | interfaccia `NetworkStatus` | `CatalogNetworkStatus` in `lib/catalog/core/network_status.dart`, implementata da `ConnectivityCatalogNetworkStatus` in `lib/catalog/platform/connectivity_network_status.dart` | esiste già `lib/account/network_status.dart` con lo stesso nome: il nome nuovo evita il conflitto negli import |
| Passi 7 e 8 | estratto di prova `tool/fixtures/off_wines_sample.csv.gz` | `tool/fixtures/off_wines_sample.csv`, in testo | un file binario non si scrive senza la shell, e un estratto scritto a mano si rivede meglio in chiaro. Lo strumento riconosce da solo gzip o testo, e il test prova anche la lettura gzip comprimendo l'estratto al volo |
| Passi 7 e 8 | i test dello strumento girano con `dart test` | girano con `flutter test` (`test/tool/build_wine_db_test.dart`, dentro la suite normale) | il progetto è un pacchetto Flutter e lo strumento importa codice di `package:vinoozy`: i suoi test girano come tutti gli altri, dentro `flutter test --coverage` in CI |
| Passo 7 | la base dell'app si costruisce dall'estratto | serve l'opzione `--allow-small-sample` | l'estratto ha 45 vini, sotto la soglia di plausibilità di 5000 (BR2.4). L'opzione abbassa solo quella soglia e vale solo per l'estratto |
| Passo 7 (aggiunta della revisione R-02) | il manifesto dice `source: Open Food Facts` | con `--allow-small-sample` il manifesto dice `"source": "sample"` e non ha la licenza | così l'estratto non sembra mai un dato reale di Open Food Facts: l'app non mostra l'attribuzione per i risultati offline, la schermata Informazioni dice che è una base di prova, e `tool/check_wine_db_release.sh` blocca la promozione in produzione |

## Correzioni dopo la revisione 1

| Rilievo | Cosa è cambiato |
|---|---|
| R-02 (base di prova) | `WineDbManifest` ha il campo `source` (`WineDbSource.openFoodFacts` o `WineDbSource.sample`); un valore sconosciuto vale come prova, mai come Open Food Facts. `tool/build_wine_db.dart` con `--allow-small-sample` scrive `"source": "sample"` senza licenza. `assets/wine_db/` è stato rigenerato dall'estratto. `WineDbLoader.isSample` legge la base già aperta senza aprirla; la lettura dell'etichetta e "Cerca online" non mostrano "Dati da Open Food Facts, licenza ODbL" per i risultati offline della base di prova (per quelli di Open Food Facts sì). La schermata Informazioni mostra "Base di prova…" al posto della data dell'export (stringa `aboutDbSample` in it, en, pt_BR). Nuovo `tool/check_wine_db_release.sh`: fallisce con meno di 5000 vini o con `source` diverso da `Open Food Facts`; lo chiama `promote.yml` sul manifesto della build `build-<versionCode>`, prima di contattare Google Play (non per "halt"). Il deploy sul canale interno non lo chiama. In `ci.yml` gira solo il suo test, `tool/check_wine_db_release_test.sh`, sulle fixture di `tool/fixtures/wine_db_release/`. |
| R-03 (Open Food Facts spento) | Nuovo stato `OnlineSearchStatus.unavailable` per Open Food Facts spento nella build; limite e guasto restano `rateLimited`. "Cerca online" mostra un messaggio proprio (`onlineSearchUnavailable` in it, en, pt_BR: "La ricerca online non è attiva in questa versione dell'app…"). L'evento `online_search` conta ancora `limited: true` in quel caso. |
| R-05 (commenti nel manifesto) | `tool/check_lens_manifest.sh` toglie ogni commento XML fino al primo `-->`, anche con `>` dentro; un `<!--` non chiuso resta e il resto viene controllato. Nuove fixture `tool/fixtures/lens_manifest/comment_ok/` (testo vietato solo dentro un commento con `>`: passa) e `comment_bad/` (l'unico provider è dentro un commento: fallisce). Con il filtro vecchio la prima falliva e la seconda passava. |
| R-01 (end-to-end) | `integration_test/label_test.dart` è diviso in 5 `testWidgets`, uno per scenario (file rovinato, fronte e retro, "Salta", "Cerca online" senza rete, Lens annullato), con il setup comune nella classe `_LabelE2E`. Ogni scenario parte da telefono ed emulatori puliti e alla fine controlla che `cache/label/` sia vuota. Non è stato eseguito: lo esegue il proprietario. |
| R-04 | Sezione "Scostamenti dal piano" qui sopra. |

Verifiche dopo le correzioni (2026-11-07): `dart format --set-exit-if-changed .` pulito (372 file, 0 cambiati); `flutter analyze --fatal-infos` nessun problema; `flutter test --coverage` **2066 passati, 0 falliti** (47 in più); copertura progetto 89,16% (11056/12400), `lib/label/` 98,80% (1485/1503), `lib/catalog/` 98,17% (1183/1205); `check_lens_manifest_test.sh`, `check_wine_db_release_test.sh`, `check_off_config.sh`, `check_label_imports.sh` e il suo test, `check_rule_ids.sh BR1. 15 test/label` tutti OK. L'end-to-end non è stato eseguito.

## Decisioni prese qui

- **`CatalogNetworkStatus` invece di `NetworkStatus`.** Esiste già `lib/account/network_status.dart` con lo stesso nome: per evitare il conflitto negli import l'interfaccia del catalogo si chiama `CatalogNetworkStatus`. L'implementazione è `ConnectivityCatalogNetworkStatus`. `connectivity_plus` era già una dipendenza, quindi `pubspec.yaml` non aggiunge pacchetti. Uno stato di rete sconosciuto conta come "rete presente", come prima della correzione (BR6.1, caso residuo).
- **Estratto di prova in testo (`off_wines_sample.csv`), non `.csv.gz`.** Non si può scrivere un file binario senza passare dalla shell, e un estratto scritto a mano si rivede meglio in chiaro. Lo strumento riconosce da solo gzip o testo. Il test prova anche la lettura gzip, comprimendo l'estratto al volo.
  - L'estratto ha 60 righe: 45 vini validi, 7 falsi positivi, 6 righe non valide e 2 doppioni.
  - Per costruire la base dall'estratto, che ha meno di 5000 vini, serve l'opzione `--allow-small-sample`. Vale solo per l'estratto.
- **Scelte enologiche dello strumento**, decise da me come prevede `project.md`:
  - categorie escluse: marmellate, succhi, aceti, salse, condimenti, piatti pronti, zuppe;
  - tipo letto dalle parole intere dei tag, con lo stile prima del colore: fortificato, poi dolce, poi metodo classico (champagne, crémant, cava, franciacorta, "traditional"), poi metodo charmat, rosato, bianco, rosso (leggero con light/young/nouveau/primeur). Così `en:portuguese-wines` non diventa un porto;
  - denominazione dal nome o dai tag riconosciuti dal catalogo interno, altrimenti da un tag che finisce con un marchio (AOC, DOC…).
- **Il fronte si prepara prima di "Ora il retro".** In questo modo un file rovinato dà subito "non leggibile" e la foto condivisa viene letta prima che scada. Il controller espone `takeBack`, `skipBack`, `notThis`, `noneOfThese` e `openLens`.
- **Lens:**
  - la logica nativa sta in una classe a sé (`LensIntentLauncher`), così si prova con Robolectric; `MainActivity` la collega soltanto;
  - il controllo EXIF lato Dart è una difesa in più: la copia preparata da `Bitmap.compress` non ha metadati, ma un file che li avesse non parte.
- **Annata letta:** sostituisce quella della proposta sicura, come prima. Nei candidati riempie solo quelli che non ne hanno una.
- **La base si apre al primo uso:** la prima lettura o la schermata Informazioni. Non c'è un'apertura anticipata all'avvio, per non pesare sull'avvio a freddo. La pulizia completa di `cache/label/` all'avvio c'era già (`startCleanup`, ora anche `wipeAll`).
- **Stringhe ARB tolte**, perché non più usate: `labelOfflineNotice`, `labelBarcodeNeedsNetwork`, `labelRetryOnline`.
- **Il percorso minimo per aggiungere un vino** con la foto passa da 2 a 3 tocchi: foto, "Salta", "Conferma". È l'effetto di FR1.1.
- **Il test di "Annulla" (BR1.13, NFR1.4)** ora controlla che l'uscita parta nello stesso fotogramma del tocco. Prima la schermata spariva entro 300 ms; ora la si cerca dopo 600 ms, perché la transizione di pagina di una route già mostrata dura più di 300 ms in questa versione di Flutter.

## Verifiche fatte

| Verifica | Esito |
|---|---|
| Suite di partenza (`flutter test`) | 1705 passati, 0 falliti |
| Suite finale (`flutter test --coverage`) | **2019 passati, 0 falliti** (314 test in più, al netto di quelli sostituiti) |
| Copertura delle righe, progetto | 89,15% |
| Copertura `lib/label/` | 98,79% |
| Copertura `lib/catalog/` | 98,16% |
| Copertura `lib/cellar/`, `lib/dashboard/`, `lib/sharing/`, `lib/account/` | tutte sopra l'80% |
| Test nativi (`./gradlew :app:testDebugUnitTest :app:jacocoLabelReport`) | 36 passati, di cui 5 nuovi di `LensIntentLauncherTest`; controllo JaCoCo superato |
| `dart format --set-exit-if-changed .` | pulito |
| `flutter analyze --fatal-infos` | nessun problema |
| `check_off_config.sh` (purezza di `lib/catalog/core`), `check_label_imports.sh` e il suo test, `check_rule_ids.sh` (label e cantina), `check_lens_manifest_test.sh` | tutti OK |
| `dart run benchmark/catalog_benchmark.dart` | OK |

`lib/app/` da solo è al 79,46%, ma non ha una soglia di cartella in CI: lo pesano soprattutto `theme.dart` e il lavoro della UX. `about_screen.dart` è al 100%.

## Come eseguirlo

```bash
flutter pub get && flutter gen-l10n
flutter test test/catalog/offline/
flutter test test/catalog/ test/label/ test/app/about_screen_test.dart test/tool/build_wine_db_test.dart
tool/check_lens_manifest_test.sh
tool/check_wine_db_release_test.sh
android/gradlew -p android :app:testDebugUnitTest :app:jacocoLabelReport
# base dall'estratto di prova (manifesto con "source": "sample")
dart run tool/build_wine_db.dart --input tool/fixtures/off_wines_sample.csv --output assets/wine_db/ --export-date 2026-11-07 --skip-freshness-check --allow-small-sample
# controllo prima della produzione: oggi fallisce, la base è quella di prova
tool/check_wine_db_release.sh
# end-to-end (un emulatore Android avviato e libero; la Firebase Emulator
# Suite demo-vinoozy la avvia il comando)
npx firebase emulators:exec --only auth,firestore --project demo-vinoozy "flutter test integration_test/label_test.dart -d <id-emulatore> --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
```

## Ancora aperto (Build and Test e proprietario)

- **L'end-to-end `integration_test/label_test.dart` è scritto ma non ha girato fino in fondo.** Analisi e formattazione sono pulite. Ho provato a eseguirlo sull'emulatore `emulator-5554` (AVD `Medium_Phone_API_36.1`) con la Firebase Emulator Suite: entrambi erano già avviati da un'altra sessione, con Android Studio aperto.
  - Il comando `flutter test` è rimasto fermo per oltre 30 minuti senza output, con un processo figlio defunto.
  - Sull'emulatore era in primo piano l'app Camera.
  - L'ho fermato per non interferire con l'ambiente del proprietario.

  Lo esegue Build and Test, su un emulatore libero, con il comando qui sopra.

- **Base reale.** La base in `assets/wine_db/` è quella dell'estratto di prova, marcata `"source": "sample"`. Prima del rilascio va generata dall'export reale, scaricato a mano: è nella checklist, §1-nonies. Finché non lo è, `promote.yml` rifiuta la promozione in produzione (`tool/check_wine_db_release.sh`).
- **Misure sul telefono:** NFR2.3 (apertura della base), NFR2.5 (memoria), NFR1.1 (dimensione dell'app) e i tempi di NFR2.1 e NFR2.2.
- **Azioni del proprietario:** informativa privacy, scheda "Sicurezza dei dati", i quattro controlli prima di rendere pubblico il repository e la prova sul telefono che l'app Google apra Lens.
