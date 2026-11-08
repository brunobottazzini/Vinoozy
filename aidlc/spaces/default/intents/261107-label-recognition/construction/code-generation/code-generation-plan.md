# Piano del codice — riconoscimento delle etichette

## Summary

- Builds: fronte e retro dell'etichetta, base offline dei vini derivata da Open Food Facts (strumento di costruzione, indice in memoria, punteggio del testo), candidati da scegliere, "Cerca online", "Apri in Google Lens" con ripiego sul menu Condividi, schermata Informazioni
- Touches: `lib/catalog/core/` (base offline, punteggio, coordinatore con rete), `lib/catalog/platform/` (caricatore della base, rete con `connectivity_plus`, eventi), `lib/label/` (sessione a due foto, esiti e nuove viste), Android (`MainActivity.kt`, `FileProvider`, `<queries>`), `tool/build_wine_db.dart`, `assets/wine_db/`, file ARB, checklist di rilascio, test ed end-to-end
- Tests: circa 90 test nuovi (unità per base, punteggio, unione fronte/retro, coordinatore, strumento; widget per le 6 viste nuove nelle 3 lingue, testo 1,0/2,0, chiaro/scuro; benchmark; e2e di `label_test.dart` esteso), suite esistente verde

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR5, NFR1–NFR6).
- `inception/refined-mockups/` (`label-mockups.html`, `interaction-spec.md`, `design-system-mapping.md`, `accessibility-checklist.md` L1–L9).
- `construction/functional-design/` (`functional-spec.md` D1–D5, `rules.md` BR1.1–BR6.3, `entities.md`, `frontend-components.md`).
- `construction/nfr-requirements/` (NFR1.1–NFR6.7, TS1–TS6).
- `codekb/Vinoozy/`.

Non c'è Units Generation (scope `refactor`): il lavoro è un'unica iterazione a livello di fase. Le "storie" di riferimento sono i requisiti FR e NFR.

## Testing Contract

```json
{
  "version": 1,
  "methodology": "test-after",
  "source": "team",
  "ordering": "Per ogni strato testabile (dominio, dati e sincronizzazione, interfaccia) implementiamo prima il codice, poi scriviamo ed eseguiamo i test di quello strato, e passiamo allo strato successivo solo con quei test verdi.",
  "scope": "refactor",
  "test_strategy": "standard",
  "project_type": "brownfield",
  "applicable_notes": [
    {
      "layer": "org",
      "text": "We treat tests as a first-class deliverable in every Bolt. The specific\nmethodology (TDD, BDD, ATDD, or classic test-after) is affirmed at\npractices-discovery and recorded in `team.md` under this heading with explicit\n`Methodology` and `Ordering` fields; Code Generation resolves those fields\nindependently from coverage, tooling, and scope notes.\n\nWhen no posture has been affirmed, our default per scope is:\n- **Methodology**: test-after\n- **Ordering**: implement each applicable testable layer, then write and run\n  that layer's tests.\n- `mvp`, `enterprise`, `feature`, `infra`, `classic` add an 80% line-coverage\n  floor and CI execution before merge.\n- `bugfix`, `security-patch` add a targeted regression for the specific\n  bug/vulnerability and require the existing suite to remain green.\n- `express` uses the Minimal strategy: requirement-driven unit tests (one per\n  requirement, with a happy-path floor per component); existing tests remain\n  green.\n- `poc`, `refactor`, `workshop` add no extra new-test floor and require the\n  existing suite to remain green.\n\nThe active `Test Strategy` still applies in every scope and determines test\nvolume/types. Scope floors are additive; they never reduce or replace the\nselected strategy.\n\nBuild and Test verifies defined coverage floors and affirmed quality targets;\nthey may not be weakened to make a step pass.\n\nAffirm a stricter posture in `team.md` if the team commits to one."
    },
    {
      "layer": "team",
      "text": "- **Methodology**: test-after\n- **Methodology evidence**: scelta in Q5 (\"Dopo il codice, strato per strato\"); coincide con il default di `org.md`.\n- **Ordering**: Per ogni strato testabile (dominio, dati e sincronizzazione, interfaccia) implementiamo prima il codice, poi scriviamo ed eseguiamo i test di quello strato, e passiamo allo strato successivo solo con quei test verdi.\n- **Copertura**: almeno l'**80% delle righe**, calcolato su tutto il codice **senza esclusioni**, compresi codice generato e file di traduzione (Q6). La soglia viene verificata in GitHub Actions e se non è raggiunta il merge in `main` è bloccato.\n- **Strumenti**: `flutter test` con `--coverage` per unit test e test dei widget. Unit test sulla logica (in particolare la stima del momento ideale e l'indice di fiducia), test dei widget per le schermate principali nelle tre lingue dell'interfaccia (it, en, pt-BR).\n- **Integrazione con Firebase**: i test di integrazione girano sulla **Firebase Emulator Suite**, in locale e in GitHub Actions, così non usano il progetto di produzione e non costano nulla (Q9).\n- **End-to-end**: i test che simulano l'uso reale dell'app girano in GitHub Actions su un **emulatore Android** (es. `integration_test` di Flutter), collegato alla Firebase Emulator Suite (Q7). Se falliscono, il merge è bloccato.\n- **Gate prima del merge**: formattazione, analisi statica, test, copertura ed end-to-end devono passare tutti. Un controllo rosso non si aggira e la soglia non si abbassa per far passare un blocco."
    }
  ],
  "obligations": {
    "strategy": "standard",
    "strategy_volume": [
      "Five to eight tests per component.",
      "Unit tests plus integration tests for key boundaries.",
      "Add E2E, performance, or security tests when requirements demand them."
    ],
    "scope_floor": [
      "Keep the existing test suite green.",
      "This scope adds no extra new-test floor beyond the selected test strategy."
    ],
    "combination_rule": "Apply every selected-strategy obligation and every scope-floor obligation; neither replaces the other, and a targeted scope regression may add the narrowest necessary test type beyond the strategy default."
  },
  "plan_profile": {
    "methodology": "test-after",
    "runner_step": "Verify the existing test runner/configuration and record the exact unit-scoped command.",
    "runner_ready_before_first_test": true,
    "testable_layers": [
      "Data model / database behavior",
      "Repository / data access",
      "Business logic",
      "API / endpoint",
      "Frontend behavior"
    ],
    "steps": [
      "Project structure and production configuration skeleton.",
      "Verify the existing test runner/configuration and record the exact unit-scoped command.",
      "Data model / database behavior - implement.",
      "Data model / database behavior - write and run its tests after implementation.",
      "Repository / data access - implement.",
      "Repository / data access - write and run its tests after implementation.",
      "Business logic - implement.",
      "Business logic - write and run its tests after implementation.",
      "API / endpoint - implement.",
      "API / endpoint - write and run its tests after implementation.",
      "Frontend behavior - implement.",
      "Frontend behavior - write and run its tests after implementation.",
      "Environment/build configuration.",
      "Documentation and traceability."
    ]
  },
  "input_sha256": "sha256:7cc0b5dd8b6f5367959d629875e8e956b4f4648b88ddfff608313c0e469007d9",
  "contract_sha256": "sha256:65c1744b642bc4f2ac39ac382fb35cdf6c3b0cdc2b3c767db30dffdb18acd189"
}
```

Gli strati di questo lavoro sono: dominio (base offline, punteggio, unione fronte/retro, ordine dei tentativi), dati (strumento di costruzione, caricatore del file, rete, canale Lens) e interfaccia. Non ci sono API né modifiche alla base dati Firestore: "API / endpoint" diventa il canale nativo `vinoozy/lens`.

## Passi

- [x] **Step 1 — Struttura e configurazione.** (FR2.1, FR4.3, FR5, TS1–TS4)
  - Nuovi file vuoti con le firme pubbliche:
    - `lib/catalog/core/offline/wine_db_record.dart`;
    - `lib/catalog/core/offline/wine_db_index.dart`;
    - `lib/catalog/core/offline/text_score.dart`;
    - `lib/catalog/core/network_status.dart`;
    - `lib/catalog/platform/wine_db_loader.dart`;
    - `lib/catalog/platform/connectivity_network_status.dart`;
    - `lib/label/core/label_merge.dart`;
    - `lib/label/core/lens_launcher.dart`;
    - `lib/label/platform/lens_channel.dart`;
    - le viste in `lib/label/ui/` (Step 15);
    - `lib/app/ui/about_screen.dart`;
    - `tool/build_wine_db.dart`.
  - `pubspec.yaml`:
    - `connectivity_plus` (versione stabile corrente, BSD-3);
    - asset `assets/wine_db/`.
  - `assets/wine_db/` con `LICENSE` (ODbL 1.0), `README.md` (fonte, data dell'export, comando di generazione) e una base iniziale generata dall'estratto di prova finché il proprietario non scarica l'export reale (vedi "Base reale" sotto).
- [x] **Step 2 — Esecutore dei test.** Verifico che i comandi di `unit-test-instructions.md` girino sul codice di oggi (`flutter test test/catalog test/label`) e li registro. (NFR4.2)
- [x] **Step 3 — Modello della base: implementazione.** (FR2.1, FR2.3, BR2.5, D1)
  - `WineDbRecord`: codice, nome, produttore, denominazione, paese, annata, tipo; da e verso una riga JSON compatta. Una riga rotta si scarta (NFR4.6).
  - `WineDbIndex`: dizionario per codice e lista di parole normalizzate per vino; costruzione da righe; `byBarcode`, `matchText(testo) → candidati con punteggio`.
  - `TextScore` (BR3.6): normalizzazione (minuscole, senza accenti né punteggiatura), parole comuni, pesi per lunghezza, tetto 0,60 sotto 2 parole distintive, bonus annata +0,05. Costanti e soglie in un solo punto (`LabelMatchThresholds`: sicura ≥ 0,85, distacco 0,15, candidati ≥ 0,45, massimo 10, gradino 3 = 0,70).
- [x] **Step 4 — Modello della base: test.**
  - `test/catalog/offline/text_score_test.dart`: record di una sola parola (tetto 0,60), nome + produttore, annata (bonus e tetto 1,0), rumore, accenti e maiuscole, parole comuni ignorate, testo vuoto.
  - `test/catalog/offline/wine_db_index_test.dart`: codice esatto, codice assente, ordine dei candidati, massimo 10, soglia 0,45, riga rotta scartata, base vuota.
  - `test/catalog/offline/wine_db_record_test.dart`: andata e ritorno JSON, campi facoltativi, nomi fuori misura.
  - `test/catalog/offline/wine_db_benchmark_test.dart`: base sintetica di 20.000 e di 50.000 vini; 1.000 ricerche per codice ≤ 50 ms in totale; confronto di 4000 caratteri ≤ 600 ms. Il tag `benchmark` è eseguito in CI come gli altri. (NFR2.1, NFR2.2, NFR2.7)
- [x] **Step 5 — Strumento di costruzione: implementazione.** (FR2.1, BR2.1–BR2.4, D2, NFR1.2, NFR2.8, NFR5.8)
  - `tool/build_wine_db.dart`, eseguito con `dart run tool/build_wine_db.dart --input <export.csv.gz> --output assets/wine_db/ [--skip-freshness-check]`:
    - legge l'export CSV di Open Food Facts in streaming, separato da tabulazioni e compresso con gzip;
    - filtra con BR2.1;
    - ricava tipo, denominazione, paese e annata con BR2.2 e BR2.3;
    - controlla la plausibilità con BR2.4 (≥ 5000 vini, nessun doppione, export ≤ 180 giorni);
    - scrive `wines.jsonl.gz` e `manifest.json` (data, numero di vini, versione del formato) solo se tutto passa;
    - esce con errore se il file compresso supera 3 MB, oppure se i dati non compressi superano **30 MB**. Il limite dei 30 MB l'ha posto il proprietario (messaggio 38a2e81d) e non si alza senza di lui. Il test dello Step 6 lo verifica con un limite iniettato.
  - Estratto di prova in `tool/fixtures/off_wines_sample.csv.gz`: circa 60 righe, scritte a mano, tra vini veri, falsi positivi (marmellate, succhi, aceti), codici non validi, doppioni e nomi fuori misura. Non contiene dati personali.
- [x] **Step 6 — Strumento: test.** `test/tool/build_wine_db_test.dart`:
  - filtri di BR2.1;
  - tipo, denominazione, paese e annata;
  - doppioni rifiutati;
  - plausibilità sotto soglia: nessun file scritto e uscita con errore (NFR4.7);
  - export vecchio rifiutato senza l'opzione;
  - limite di 3 MB compressi e limite di 30 MB non compressi (decisione del proprietario);
  - nessun campo personale in uscita (NFR3.7);
  - presenza di `LICENSE` e `README.md` in `assets/wine_db/` (NFR5.6).
- [x] **Step 7 — Caricatore e rete: implementazione.** (BR2.5, BR6.1, NFR2.3–NFR2.6, NFR4.5, NFR4.15)
  - `WineDbLoader` in `platform/`: legge l'asset; decompressione, lettura delle righe e indicizzazione passano da `runInBackground`, che in produzione è `Isolate.run`. L'apertura avviene una sola volta, anche con richieste contemporanee. In caso di guasto restituisce "non disponibile" con il motivo (`missing`, `corruptGzip`, `noValidRows`, `unexpected`) e il numero di righe scartate.
  - `NetworkStatus` (interfaccia in `core/`) e `ConnectivityNetworkStatus` (`connectivity_plus`, in `platform/`).
  - `CatalogEventLogger`:
    - nuovi metodi `wineDbOpened`, `labelOutcome`, `onlineSearch` e `lensOpened`, solo in console;
    - nuovo metodo `wineDbUnavailable`, in console e come errore non fatale su Crashlytics;
    - le firme accettano solo enum e numeri.
- [x] **Step 8 — Caricatore e rete: test.**
  - `test/catalog/wine_db_loader_test.dart`: apertura riuscita; `runInBackground` chiamato una volta; due richieste contemporanee con una sola lettura; file mancante, gzip rotto e nessuna riga valida danno "non disponibile" con il motivo giusto.
  - `test/catalog/connectivity_network_status_test.dart` con la piattaforma finta.
  - `test/catalog/crashlytics_catalog_event_logger_test.dart`, esteso: gli eventi informativi non chiamano Crashlytics; `wine_db_unavailable` sì, con le chiavi ammesse (NFR4.13–NFR4.15).
- [x] **Step 9 — Coordinatore e ordine dei tentativi: implementazione.** (FR2.4, FR3.4, FR5, BR3.1–BR3.4, BR4.2, BR4.3, BR6.1, NFR5.5)
  - `CatalogCoordinator` riceve la base offline (futura) e `NetworkStatus`.
  - `lookupBarcode` cerca prima nella base offline.
  - `matchLabelText` diventa `matchLabel(text, barcode)` e restituisce `LabelMatchResult`:
    - `sure(candidato)`, oppure `candidates(lista)`, oppure `none`;
    - segue l'ordine dei gradini 1–5 e si ferma alla prima proposta sicura;
    - toglie i doppioni con BR3.3.
  - Senza rete o con OFF spento il gradino 4 non si chiama e non conta come guasto.
  - `maxLabelTextLength` passa da 2000 a 4000.
  - Nuovo `searchOnline(query)`: risultati offline più quelli online (categoria vini, massimo 10), stato `offline`/`rateLimited`/`ok`. Passa da `RequestBudget` e `OffCircuitBreaker`, già esistenti.
  - `OpenFoodFactsSource`: una ricerca per testo limitata alla categoria vini, con il User-Agent esistente; manda solo il testo della query (NFR3.8).
- [x] **Step 10 — Coordinatore: test.**
  - `test/catalog/catalog_coordinator_test.dart`, esteso:
    - codice trovato nella base offline, e codice trovato solo su OFF;
    - testo sicuro dalla base, e testo solo con candidati;
    - gradino 3 a 0,70, mai sicuro da solo;
    - doppioni tra offline e OFF, dove vince l'offline;
    - senza rete: nessuna chiamata e nessun `off_suspended`;
    - base non disponibile: il flusso continua;
    - 4000 caratteri accettati e 4001 rifiutati.
  - `test/catalog/online_search_test.dart`: risultati uniti, budget esaurito che dà `rateLimited`, senza rete solo offline, timeout, 429 e 500 che danno solo offline (NFR4.9).
  - `test/catalog/open_food_facts_source_test.dart`, esteso: parametri della ricerca per testo, nessun altro dato inviato.
- [x] **Step 11 — Fronte e retro: implementazione.** (FR1.1–FR1.3, BR1.2–BR1.6, BR3.4, BR3.5)
  - `label_merge.dart`: testo unito (max 2000 per foto, 4000 in tutto, righe del retro non già presenti); codice prima dal fronte e poi dal retro; esiti di BR1.5.
  - `LabelSession` e `LabelLookupFlow`:
    - due foto, con il retro facoltativo;
    - stati nuovi `LabelBackPromptState`, `LabelCandidatesState` e `LabelNotFoundState` con il tipo (`unreadable`, `barcodeNotFound`, `noMatch`);
    - "Non è questo" passa ai candidati o al non trovato;
    - annullamento.
  - `TempLabelStore`:
    - un insieme "in uso", protetto da `beforeRead` e `release`;
    - `releaseCapture()` all'uscita dall'esito;
    - `wipeAll()` all'avvio dell'app.
- [x] **Step 12 — Fronte e retro: test.**
  - `test/label/core/label_merge_test.dart`: righe ripetute, limiti 2000/4000, codice solo sul retro, codici diversi con vittoria del fronte, retro illeggibile, fronte illeggibile, entrambi illeggibili.
  - `test/label/core/label_session_test.dart` e `label_lookup_flow_test.dart`, estesi: "Salta" o retro annullato, che equivalgono al solo fronte; esiti sicuro, candidati e tre non trovati; "Non è questo"; annullamento.
  - `test/label/platform/temp_label_store_test.dart`, esteso: file in uso non cancellati oltre 10 minuti; rilascio all'uscita; pulizia all'avvio (NFR3.4, NFR4.12).
- [x] **Step 13 — Canale Lens (nativo): implementazione.** (FR4.1–FR4.4, BR5.1–BR5.3, D4, NFR3.1–NFR3.5)
  - `MainActivity.kt`: `MethodChannel('vinoozy/lens')`, metodo `open(path)`.
    - Prima prova: `ACTION_SEND` con `image/jpeg`, `EXTRA_STREAM`, `ClipData` e `FLAG_GRANT_READ_URI_PERMISSION`, verso `com.google.android.googlequicksearchbox`.
    - Se il pacchetto manca o lancia `ActivityNotFoundException`: `Intent.createChooser` con `EXTRA_EXCLUDE_COMPONENTS` che esclude Vinoozy.
    - Risultato: `direct`, `chooser` oppure `failed`.
  - `AndroidManifest.xml`:
    - `androidx.core.content.FileProvider` con `exported=false` e `grantUriPermissions=true`;
    - `res/xml/label_file_paths.xml`, limitato a `cache/label/`;
    - `<queries>` per il pacchetto Google e per `ACTION_SEND image/*`.
  - `lens_channel.dart` e `LensLauncher` (interfaccia in `core/`). Si condivide solo il fronte, nella copia preparata, che è un JPEG ricodificato senza EXIF.
- [x] **Step 14 — Canale Lens: test.**
  - `test/label/platform/lens_channel_test.dart`: chiamata con il percorso giusto; i tre risultati; eccezione della piattaforma che dà `failed`.
  - `test/label/platform/label_image_exif_test.dart`: la copia preparata da una foto con EXIF e GPS non ha EXIF.
  - `tool/check_lens_manifest.sh` con il suo test `tool/check_lens_manifest_test.sh`: provider non esportato, percorsi limitati a `cache/label/`, `<queries>` limitati al pacchetto Google e a `ACTION_SEND image/*`. Si aggiunge al job di analisi della CI esistente. (NFR3.3)
- [x] **Step 15 — Interfaccia: implementazione.** (FR1.1, FR2.2, FR2.4, FR2.5, FR3.1–FR3.4, FR4.1–FR4.4, BR6.2, BR6.3, NFR6.2, NFR6.3)
  - Nuove viste:
    - `back_photo_prompt.dart`: "Ora il retro" con Scatta, Galleria e Salta;
    - `reading_progress.dart`: passi con annunci per il lettore di schermo e Annulla;
    - `candidate_list.dart`;
    - `not_found_view.dart`: sostituisce `label_unreadable_view.dart` e `barcode_only_view.dart`, che si eliminano insieme ai loro test se non servono più;
    - `online_search_screen.dart`: stati `idle`, `loading`, `results`, `empty`, `offline`, `rateLimited`;
    - `lens_confirm_sheet.dart`.
  - `label_proposal_sheet.dart`: "Non è questo" e attribuzione.
  - `label_capture_flow.dart` e `label_reading_screen.dart` collegano i nuovi stati.
  - Il modulo di aggiunta riceve `AddWineInitialValues` con paese e regione (logica della UX) e si può tornare alla lista.
  - `AboutScreen`: versione, numero di vini e data della base, dicitura ODbL/DbCL, nota privacy delle foto, link al repository. Si apre dal menu della Cantina.
  - All'avvio dell'app: `TempLabelStore.wipeAll()` e apertura della base in background, la prima volta che serve.
  - Testi nei 3 ARB con prefisso `label*`/`about*`. Elementi interattivi con chiavi di test (`Key('label-back-skip')` e simili, come nel resto dell'app).
- [x] **Step 16 — Interfaccia: test.**
  - `test/label/ui/label_screens_test.dart`, esteso, più un file per ogni vista nuova in `test/label/ui/`. Ogni vista è provata nella matrice esistente (it/en/pt-BR × testo 1,0/2,0 × chiaro/scuro) e con i suoi stati:
    - conferma di Lens con il testo su Google e l'annullamento, che non chiama il canale (NFR3.1, NFR3.2);
    - "Cerca" disattivato con il campo vuoto;
    - limite raggiunto;
    - senza rete;
    - candidato scelto, che apre il modulo compilato.
  - `test/app/about_screen_test.dart`: numero di vini, data e dicitura nelle 3 lingue (NFR6.7).
  - Test di attribuzione (BR6.2) nella proposta, nei candidati e nella ricerca.
- [x] **Step 17 — End-to-end.** `integration_test/label_test.dart`, esteso con la sorgente di foto finta, il catalogo finto per OFF e il canale Lens finto (NFR4.3, NFR4.4):
  - fronte e retro con codice solo sul retro, che dà una proposta sicura;
  - "Salta";
  - candidati, poi scelta e modulo compilato;
  - "Cerca online" senza rete;
  - conferma di Lens annullata.
- [x] **Step 18 — Configurazione e CI.** (NFR4.1, NFR4.4, NFR6.4–NFR6.6)
  - `tool/check_label_imports.sh` e il controllo di purezza di `lib/catalog/core` coprono i nuovi file.
  - In CI la copertura per cartella si controlla con `tool/check_coverage.sh 80 coverage/lcov.info lib/label/` e `... lib/catalog/`, in aggiunta al controllo sul progetto intero.
  - Nessuna soglia cambia. Nessun job scarica l'export né chiama servizi esterni.
- [x] **Step 19 — Documentazione e tracciabilità.** (NFR3.6, NFR3.9, NFR3.10, NFR5.7, NFR5.8)
  - `docs/release-checklist.md`:
    - aggiornamento della base: scaricare l'export a mano, eseguire `build_wine_db`, controllare il manifesto;
    - Sicurezza dei dati e informativa per Lens;
    - controllo di `wine_db_unavailable` dopo il rilascio;
    - voce "prima di rendere pubblico il repository" con i 4 controlli di NFR3.10;
    - prova sul telefono che l'app Google apra Lens.
  - `code-summary.md`, `traceability.json` e `README` della base.

## Base reale

L'export completo di Open Food Facts (oltre 9 GB scompattato) non si scarica in CI né da me senza il tuo OK. Il codice e i test usano l'estratto di prova. Prima del rilascio sullo store si genera la base reale con lo strumento: la checklist lo richiede, e in Build and Test ti chiederò se scaricarlo io in locale (gratuito, dal sito pubblico di Open Food Facts) oppure se preferisci farlo tu.

## Decisioni prese qui

- **Viste non trovato unificate.** `label_unreadable_view.dart` e `barcode_only_view.dart` confluiscono in `NotFoundView` con il tipo, come in `frontend-components.md`. Se uno dei due resta usato altrove lo tengo.
- **`matchLabelText` → `matchLabel`.** L'interfaccia `WineCatalog` cambia la firma. L'unico chiamante è `LabelLookupFlow`, e i finti dei test si aggiornano.
- **Lo strumento di costruzione non è in `lib/`.** Sta in `tool/` e non entra nell'app né nella copertura dell'app. I suoi test girano con `flutter test test/tool/` e sono inclusi nei comandi; sono contati nella suite ma lo strumento non entra nella copertura di `lib/`.
- **Fuori da questo lavoro:** la riga doppia dello Storico, il banner dopo il cambio di account e la distribuzione delle regole Firestore. Hanno lavori a parte.
