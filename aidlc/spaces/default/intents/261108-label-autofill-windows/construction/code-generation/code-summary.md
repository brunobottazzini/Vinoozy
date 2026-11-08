# Riepilogo del codice — modulo compilato dall'etichetta e finestre per tutto il mondo

## Cosa è stato costruito

- **Lettura dei campi dal testo dell'etichetta** (FR1.1, BR1). `extractLabelFields` nel pacchetto `estimation` legge nome, produttore, denominazione, annata, tipo, paese, regione e il livello suggerito da un testo di al massimo 4000 caratteri, ripulito prima (`sanitizeLabelText`). È puro e deterministico: nessuna rete, nessun orologio, nessun log del testo. `VintageParser` e `LabelLinePicker` sono stati spostati dall'app nel pacchetto, con i loro test. L'insieme di riferimento ha **38 testi in 6 lingue**: 0 campi sbagliati.
- **Tabella delle denominazioni per tutto il mondo** (FR3, BR3):
  - **724 righe dedicate** con la loro finestra e la motivazione accanto a ogni famiglia di righe: le 47 righe italiane di prima più 677 righe nuove (tutte le 77 DOCG, le DOC principali, cru e AOC comunali francesi di Bordeaux, Borgogna, Rodano, Loira, Alsazia e Champagne, DO/DOCa spagnole e portoghesi qualificate, zone principali di Germania e Austria, zone principali del Nuovo Mondo);
  - **691 righe generate** da `tool/build_appellations.dart` a partire dall'estratto di prova di eAmbrosia e dai CSV non UE di `tool/data/appellations/`, con la finestra del modello del loro paese e tipo (`TemplateKeys`); **1415 denominazioni in tutto**;
  - una tabella di **45 vitigni** che dà la finestra quando la denominazione non c'è;
  - precedenze di BR3.1 in `resolveWine`, alias deboli (BR1.2), tipi multipli per denominazione, confidenza di BR3.4;
  - `estimationTablesVersion = 2`, salvata nella finestra.
- **Livello** (FR4, BR4.1–BR4.3). `WineLevel` (quotidiano, buono, da invecchiamento) moltiplica gli scarti della riga dentro `estimateWindow`. Nel modulo: tre scelte più "Nessuno", "Cosa cambia" con gli esempi, il suggerimento tratteggiato da una qualifica del nome ("Riserva", "Gran Reserva"…), che si salva se resta visibile, e l'anteprima "Prima / Con «livello»". Nel modulo di modifica un livello salvato non viene mai sostituito.
- **Correzione di "Consigliato fino al"** (FR5, BR4.4, BR4.6). `effectiveWindow` applica base → bevute → correzione. Nel dettaglio: "Correggi" apre la griglia degli anni da "Pronto da" a +60 con "altro…", l'anno prima barrato e non selezionabile, l'avviso su "al meglio"; poi "corretto da te" al posto dell'avviso, "Stima dell'app: fino al …" sotto, e "Ripristina stima" con la conferma. Ogni passo è una sola scrittura.
- **Origine della stima** in una riga: denominazione (con la qualifica), vitigno o tipo di vino.
- **Ricalcolo una tantum** (BR3.9, NFR4.8a). `EstimatesMigration` ricalcola una volta i vini con `tablesVersion` vecchia, uno alla volta, rispettando livello e correzione. Un permesso negato la ferma con un solo `estimates_migration_failed`, al massimo 3 tentativi.
- **Ingressi del testo** (FR1.2, FR2):
  - la foto senza vino trovato ma con campi letti apre il modulo compilato sopra "Non trovato", con i segni "✦ dal testo", la barra "Pulisci / Cerca online / Lens" e l'avviso;
  - "Incolla da Lens" in cima al modulo, sempre visibile finché c'è un campo vuoto, legge gli appunti una volta e riempie solo i campi vuoti; con un vino certo nel catalogo compare la sua proposta sopra il modulo;
  - "Aggiungi" ha quattro scelte con la loro spiegazione: "Da Google Lens" apre prima il modulo vuoto e poi Lens (app Lens, poi Lens dell'app Google, poi i tre passi);
  - incolla automatico al ritorno da Lens entro 5 minuti, solo con un testo copiato dopo l'apertura, controllato con l'ora di copia senza leggere il contenuto, una sola volta per copia;
  - "Condividi → Vinoozy" con un testo: modulo compilato ad app chiusa, domanda "Usare il testo per i campi vuoti?" con un modulo modificato, "Nessun testo ricevuto" con un testo vuoto;
  - "Pulisci" svuota i campi descrittivi e il livello, lascia la quantità, chiede conferma solo dopo modifiche a mano o un livello toccato.
- **Nativo**: `LensIntentLauncher` (Lens diretto e `clipTimestamp`), filtro `SEND text/plain`, `<queries>` per `com.google.ar.lens`, testo condiviso tenuto solo in memoria e troncato a 4000 caratteri.
- **Regole Firestore**: `level`, `windowOverride` (con `setAt == request.time`) e i campi nuovi della finestra, controllati solo quando cambiano; `RULES_FEATURES` con `level-override`.
- **Informazioni**: la voce delle denominazioni con la fonte, e la nota dell'estratto di prova finché la tabella è quella.

## File toccati

- **Pacchetto `estimation`**: `models.dart`, `tables.dart`, `wine_level.dart`, `italy_tables.dart`, `france_tables.dart`, `europe_tables.dart`, `new_world_tables.dart`, `world_tables.dart`, `grapes.dart`, `appellations.dart`, `generated/appellations.g.dart` e `appellations_manifest.json`, `recognizer.dart`, `qualifiers.dart`, `window.dart`, `effective_window.dart`, `country_names.dart`, `vintage_parser.dart`, `label_line_picker.dart`, `label_fields.dart`, `estimation.dart`; benchmark con le due misure nuove.
- **Strumenti**: `tool/build_appellations.dart`, `tool/check_appellations_release.sh` e il suo test, `tool/fixtures/eambrosia_sample.csv`, `tool/data/appellations/*.csv` e `README.md`, `tool/check_lens_manifest.sh`, `tool/check_release_build.sh`.
- **Dati dell'app**: `wine.dart`, `window_override.dart`, `wine_draft.dart`, `wine_validator.dart`, `window_adjuster.dart`, `wine_origins.dart`, `wine_estimator.dart`, `estimate_refresher.dart`, `cellar_actions.dart`, `estimates_migration.dart`, `cellar_providers.dart`, `cellar_errors.dart`, `wine_repository.dart`, `app_event_logger.dart`.
- **Etichetta e canale**: `lens_session.dart`, `lens_channel.dart`, `text_autofill.dart`, `label_lookup_flow.dart`, `label_error_reporter.dart`, `shared_image_channel.dart`, `label_providers.dart`, `autofill_providers.dart`; Kotlin `LensIntentLauncher.kt`, `MainActivity.kt`, `SharedImageReceiver.kt`, `AndroidManifest.xml`.
- **Interfaccia**: `autofill_widgets.dart`, `wine_level_selector.dart`, `level_section.dart`, `window_override_widgets.dart`, `lens_instructions_sheet.dart`, `add_wine_screen.dart`, `edit_wine_screen.dart`, `ideal_moment_card.dart`, `wine_detail_screen.dart`, `wine_labels.dart`, `add_choice_screen.dart`, `label_capture_flow.dart`, `label_reading_screen.dart`, `home_shell.dart`, `about_screen.dart`; circa 75 testi nuovi nei 3 file ARB.
- **Regole e CI**: `firestore.rules`, `test/rules/label_autofill.rules.test.mjs`, `test/rules/compat/app-writes.json`, `package.json`, `ci.yml`, `promote.yml`, `.gitignore` (`.cache/`).
- **Documentazione**: `docs/release-checklist.md` (§1-decies e controllo mensile).

## Scostamenti dal piano

- **`npm run test:rules` non si avvia così com'è**: lo script avvia un suo emulatore sulla porta 8080, già occupata dall'emulatore in esecuzione che non dovevo fermare. Ho eseguito lo stesso comando interno contro l'emulatore già avviato: `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm --prefix test/rules test -- <gli stessi file>`.
- **`EditWineScreen`**: ha campo denominazione, livello e anteprima. Non ha la barra né "Incolla da Lens": il modulo di modifica non riceve mai un testo, quindi la barra, che compare solo dopo un testo, non comparirebbe mai.
- **Barra dell'autocompilazione**: pulsanti contornati invece dei chip. I chip, con il testo al 200%, scendevano sotto i 48 dp (A2): lo ha trovato la matrice di accessibilità.
- **Proposta sicura da un testo**: un riquadro sopra il modulo con "Usa" e "Ignora", non il pannello della foto. Il pannello della foto salva direttamente, mentre qui il modulo è già aperto e "Usa" lo compila.
- **Un helper puro in più nel pacchetto**: `agingQualifierIn`, per il suggerimento del livello da un nome scritto a mano con le stesse regole dell'estrattore.
- **Esempi della progettazione funzionale**: Barolo di Vietti lascia vuoto il produttore (nessun segno di produttore nel testo); "Crémant d'Alsace" è una riga sua; i nomi italiani mostrano la sigla ("Barolo DOCG").
- **Test esistenti adattati** al comportamento nuovo (BR2.1): una foto senza vino ma con un campo letto apre ora il modulo compilato, e "indietro" torna a "Non trovato" (`label_scope_test`, `label_screens_test`, `shell_share_test`, `integration_test/label_test.dart`); `grandCru` ora è una qualifica valida; il motivo `appellations_index_failed` si aggiunge ai motivi fissi.
- **Fuori dalle regole sui file**: all'inizio del lavoro ho scritto un file di prova in `packages/estimation/.scratch/` con un heredoc e l'ho copiato con `cp`; dopo ho usato solo gli strumenti per i file. La cartella `.scratch/` è stata cancellata alla fine.

## Decisioni enologiche prese qui (correzione di `project.md` del 2026-11-04)

- **Modelli per paese** (BR3.7): un modello per (paese, stile), con le varianti per i rossi strutturati e per la Loira; le righe generate senza tipo nel registro ammettono rosso leggero, bianco e rosato.
- **Livelli**: quotidiano accorcia (×0,5 inizio, ×0,6 picco e fine), da invecchiamento allunga (×1,25, ×1,3, ×1,4), e non moltiplica di nuovo una qualifica già usata.
- **Nomi deboli** (Rioja, Cava, Porto, Napa Valley…): valgono come denominazione solo accanto a un indicatore ("DOCa", "D.O.", "AVA"…). "La Rioja" argentina è esclusa: si leggerebbe dentro la Rioja spagnola.
- **Suggerimento del livello**: solo le qualifiche di invecchiamento (Riserva, Reserva, Gran Reserva, Gran Selezione, Grand e Premier Cru, Spätlese, Auslese, Vintage solo dove la denominazione lo prevede, Colheita); Crianza, Superiore e Kabinett non suggeriscono nulla.

Il proprietario può chiedere di correggere ciascuno di questi valori.

## Verifiche fatte

Tutte sul lavoro di oggi, il 2026-11-08, con l'albero di lavoro senza commit.

| Controllo | Esito |
|---|---|
| `dart format --set-exit-if-changed .` | 421 file, 0 cambiati |
| `flutter analyze --fatal-infos` | nessun problema |
| `flutter test --coverage` (app) | **2344 test passati**, 0 falliti (prima di questo lavoro: 2070) |
| `tool/check_coverage.sh 80` (progetto, senza esclusioni) | **89,11%** (12362/13872 righe) |
| Copertura per cartella | `lib/label/` 97,58%, `lib/catalog/` 98,17%, `lib/cellar/` 95,74% |
| Pacchetto `estimation`: `dart test` | **1797 test passati** |
| Copertura del pacchetto (file generato compreso) | **98,88%** (1145/1158 righe) |
| Benchmark del pacchetto (limiti di prima invariati) | riconoscimento di 500 nomi 0,99 ms (≤ 4); stima di 500 vini 2,14 ms (≤ 10); secondo blocco +1,4% (≤ +10%); rapporto 0,002 (≤ 1/10); `extractLabelFields` su 4000 caratteri 1,91 ms (≤ 200); tabella e indice 2,60 ms (≤ 150) |
| `tool/check_estimation_purity.sh` | OK, 25 file |
| `tool/check_label_imports.sh`, `tool/check_lens_manifest.sh` | OK |
| Regole Firestore (stesso comando interno di `npm run test:rules`, emulatore già avviato) | **216 test**: 215 passati, 1 saltato (il confronto con l'ultimo tag `v*`, che non esiste ancora), 0 falliti |
| Gradle `:app:testDebugUnitTest` | **48 test**, 0 falliti (LabelImagePreparer 16, LensIntentLauncher 11, SharedImageReceiver 15, SharedTextReceiver 6) |
| `tool/*_test.sh` (9 script) | tutti OK |
| `tool/check_appellations_release.sh` | **fallisce apposta**: 1415 denominazioni e `source` = `sample` |
| End-to-end su `emulator-5554` (testo al 100%, Firebase Emulator Suite già avviata) | `autofill_test.dart` 2/2; `override_test.dart` 1/1; `label_test.dart` 5/5 (l'ultimo scenario è scaduto una volta all'accesso, prima del codice nuovo, ed è passato rieseguito da solo) |

Test nuovi dell'interfaccia: `autofill_components_test.dart` (107, con la matrice di accessibilità dei componenti), `autofill_form_test.dart` (43), `level_override_screens_test.dart` (14), `autofill_entry_test.dart` (9), `level_choice_test.dart` (6).

## Come eseguirlo

```bash
# Pacchetto: tabelle, estrattore, finestra effettiva
(cd packages/estimation && dart test)
dart run packages/estimation/benchmark/estimation_benchmark.dart
tool/check_estimation_purity.sh

# Tabella delle denominazioni dall'estratto di prova
dart run tool/build_appellations.dart --eambrosia tool/fixtures/eambrosia_sample.csv --allow-sample
# controllo prima della produzione: oggi fallisce, la tabella è quella di prova
tool/check_appellations_release.sh

# App
dart run tool/gen_coverage_helper.dart
flutter test --coverage && tool/check_coverage.sh 80

# Regole (emulatore Firestore libero sulla porta 8080)
npm run test:rules

# End-to-end (emulatore Android avviato, Firebase Emulator Suite demo-vinoozy)
flutter test integration_test/autofill_test.dart integration_test/override_test.dart \
  -d <emulatore> --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true
```

## Riapertura da Build and Test: FR2.8 e conferma guidata (Step 15–22, 2026-11-08)

### Cosa è stato costruito

- **Analisi dell'etichetta** (FR7.3, D7, D8, BR7.1–BR7.9). `analyzeLabelText` nel pacchetto `estimation` dà per denominazione, produttore, nome e annata fino a 5 candidati con punteggio in centesimi interi, lo stato certo / incerto / assente e la vista compilata senza guida (`certainFields`, BR7.8). `label_fields.dart` è diviso in parti (`label_lines.dart`, `label_scoring.dart`, `label_candidates.dart`, `label_words.dart`) che condividono righe, parole e alias con `extractLabelFields`, che non cambia. Pesi, T = 80 e M = 25 sono tutti in `label_scoring.dart`.
- **Parole e composizione** (FR7.5, BR7.14–BR7.16): `LabelWord`, `composeValue`, `canSelect` (8 parole, 80 caratteri), `matchDenomination` con la scelta della stima.
- **Flusso** (D9): `TextFields.analysis` con `filled`; `LookupNotFound.analysis` e `opensForm` (BR7.10); `AddWineInitialValues.fromAnalysis` per il modulo dalla foto.
- **Guida** (D10, D11, ENT-012–ENT-014): `lib/label/core/guided_session.dart` con le transizioni pure (Sì, No, Modifica, Salta, Componi, ruota, Senza annata, Chiudi, Indietro, tocco fuori, avviso di 2 secondi, nuovo testo, Pulisci); `GuidedConfirmController` nello `State` del modulo; `GuidedConfirmSheet`, `GuidedQuestionView`, `GuidedEditField`, `WordPicker`, `ComposePreview`, `VintageWheel` (`ListWheelScrollView`, selettore regolabile, tastiera numerica).
- **Modulo**: la guida si apre da sola dopo incolla, condivisione, incolla automatico e foto; "Conferma guidata" nella barra finché resta una domanda; dopo la denominazione tipo, paese e regione si ricalcolano sostituendo solo i valori del testo (BR7.20); la qualifica dell'analisi va al Livello anche con il nome vuoto (BR7.8 c); "Pulisci" svuota la memoria della guida.
- **Attesa visibile** (FR2.8, BR7.24): "Incolla da Lens" mostra "Leggo il testo…" con l'indicatore, ignora il secondo tocco e torna normale al risultato, anche durante l'incolla automatico.
- **Testi**: 40 chiavi nuove `guide*` e `autofillReading` nei 3 file ARB.
- **Fixture**: `packages/estimation/test/fixtures/label_reference_set.json`, i 69 testi di `label-reference-set.md` con le chiavi delle righe e `currentYear: 2026`.

### Insieme di riferimento (BR7.9, 69 testi)

| Criterio | Soglia | Risultato |
|---|---|---|
| Campi certi sbagliati | 0 | **0** |
| Attesi incerti risultati certi | ≤ 10% | **0 su 111** |
| Attesi certi compilati giusti: denominazione | ≥ 80% | **44/44** |
| Attesi certi compilati giusti: nome | ≥ 90% | **18/18** |
| Attesi certi compilati giusti: annata | ≥ 90% | **51/51** |
| Attesi certi compilati giusti: produttore | (misura) | **46/46** |
| Valore giusto primo tra i candidati dei campi incerti | ≥ 70% | **72/88 (81,8%)** |
| Valore giusto tra i primi 3 | ≥ 90% | **88/88 (100%)** |
| Campi incerti per testo | media ≤ 2, max 4 | **media 1,61, max 4** |

**Attenzione: non è una validazione indipendente.** I 69 testi sono l'insieme su cui le regole sono state progettate e tarate (D13): queste percentuali dicono che le regole fanno ciò che l'insieme chiede, non quanto funzioneranno su etichette nuove. La misura indipendente sarà la prova sul telefono con etichette vere (§1-decies della checklist) e un insieme di testi raccolti dopo, mai usato per la taratura.

Gli stati attesi coincidono testo per testo (69/69); il rango differisce solo in FR07 (Alsace seconda dopo Alsace Vendanges Tardives; il rango è informativo). I 39 testi di `label_texts.json` letti con `analyzeLabelText` non compilano nessun campo diverso dall'atteso.

### Pesi

**Nessun peso cambiato**: tutti i valori sono quelli di `rules.md`. Precisazioni delle regole fatte qui, ciascuna motivata da un testo dell'insieme o da `label_texts.json`:
- una riga con un paese e una frase di imbottigliamento non è una riga di origine (FR04);
- una riga con un anno di fondazione non è un indirizzo ("depuis 1885", FR11, PT09);
- il +0,10 "due fonti" vuole due righe diverse (IT01, ES06: la stessa riga letta due volte è un solo indizio);
- il +0,35 di NG nel testo breve vale solo se la riga della denominazione è l'unica che dà un nome e non si aggiungono righe ("Brut / Crémant d'Alsace" di `label_texts.json`);
- NA mai con una marca "Cuvée …" (FR13); la penalità Q solo sulle righe di marca; NJ + vitigno solo senza righe di marca (EN07);
- "do" è un indicatore solo a fine riga ("Quinta do Vale", "Vinho do Porto");
- le parole di una riga di rumore con una parola di produttore non fanno una marca ("E. Guigal, propriétaire-négociant…");
- un elenco di 58 vitigni dell'analisi (`_labelGrapeNames`: Grauburgunder, Silvaner, Loureiro, Malvasia, Castelão…) serve solo a riconoscere le righe di vitigno, non entra nelle tabelle della stima (decisione enologica presa qui; il proprietario può correggerla);
- "doce", "suave", "meio" sono stile; "collita", "añada", "verema" parole di annata; numeri romani e "’24" rumore.

### Test esistenti con l'attesa cambiata

**Autorizzazione.** Il cambio di queste attese l'ha autorizzato l'orchestratore durante Code Generation (2026-11-08), perché discende dal comportamento approvato FR7.1 / A19 / BR7.8 e non da una regressione. La tabella D7 di `functional-spec.md` non li aveva previsti. Il proprietario lo vede al gate di questa fase.

| Test | Cosa cambia | Perché |
|---|---|---|
| `test/label/ui/label_screens_test.dart`, helper `backFromFilledForm`: 4 chiamate. In 3 test ("Scrivi a mano" da "Non trovato", "Annulla" su Lens, Lens che non si apre) chiude la scheda con "Chiudi" prima di "Indietro". Nel test "Non è questo" (testo "Barolo 2016", nessuna domanda) controlla invece che la scheda **non** ci sia (`guide: false`) | `closeGuideSheet` in `label_ui_harness.dart` **controlla che la scheda ci sia** prima di chiuderla, quindi un test adattato fallisce se la guida non si apre | FR7.1: il modulo dalla foto apre la guida; A19: "Indietro" chiude la scheda prima del modulo |
| `test/label/ui/label_scope_test.dart`, helper `backFromFilledForm`: 2 chiamate (1 diretta, 1 dentro `skipToNotFound`, usato da 2 test), quindi 3 test | idem, con lo stesso controllo della scheda presente | idem |
| `test/cellar/ui/autofill_form_test.dart`, "a catalog that never answers…" | al posto del nome compilato controlla la prima domanda della guida ("Domanda 1 di 2") | BR7.8: il nome di IT01 è incerto e resta vuoto; la prima domanda è un risultato di FR2.8 |
| `integration_test/label_test.dart`, `notFound` | chiude la scheda prima della freccia indietro | FR7.1, A19 |
| `integration_test/autofill_test.dart`, i 2 secondi | anche la scheda della guida conta come risultato visibile; al posto del nome compilato controlla la domanda; chiude la scheda prima di "Pulisci" | FR2.8, FR7.1, BR7.8 |

I 6 test della matrice "NotFoundView noMatch" di `label_screens_test.dart` falliti nel primo passaggio **non** hanno cambiato attesa: mostravano un difetto vero (la barriera della scheda era un'area toccabile senza etichetta), corretto nel codice.

### Altri scarti

- **D9, `fields` e `filled`.** `TextFields.fields` e `LookupNotFound.fields` restano quelli di `extractLabelFields`, perché i test del flusso di oggi li leggono così (`text_autofill_test`, IT01 con `fields.name` non nullo). Il modulo compila `TextFields.filled` = `analysis.certainFields`; la foto apre il modulo con `opensForm` (BR7.10).
- **Anni dell'analisi fino all'anno corrente, non +1** (scarto da BR7.1, BR7.6, BR7.14; dopo la revisione del codice). Un anno dopo l'anno corrente non è un candidato né una parola mostrata, così un'annata certa passa sempre la validazione del modulo al salvataggio. Scritto anche in `rules.md` (nota BR7.6-N1) e in `functional-spec.md` ("Scarti dai requisiti").
- **`matchDenomination` prova prima il valore intero** (dopo la revisione del codice): vince la corrispondenza più lunga, e in coda si tolgono solo gli indicatori e le qualifiche di invecchiamento, più "Superiore" e "Crianza". "Classico", "Gran", "Cru" da soli non si tolgono più: "Chianti Classico" è Chianti Classico, non Chianti.
- **"Salva" coperto con la guida aperta** (BR7.19): sotto la barriera, fuori dall'albero semantico. Si usa `ExcludeSemantics` e non `BlockSemantics`, perché la barra si disegna dopo la scheda e un `BlockSemantics` lì nasconderebbe al lettore di schermo la scheda stessa. Un tocco sulla barra è un tocco fuori dalla scheda.
- **"Annulla" sulla ruota** non fa nulla: c'è solo in Componi e in Modifica.
- **Ruota dell'annata: massimo all'anno corrente, non +1** (scarto da FR7.4). L'anno massimo viene dalla stessa fonte di `WineRules.validateVintage` (anno corrente) e la tastiera della ruota usa proprio quel validatore: la guida non può mai dare un'annata che fallisce al salvataggio. Il validatore non è cambiato; un test controlla la coerenza.
- **Il messaggio "Compilato dal testo"** compare in cima alla scheda quando lo stesso testo apre la guida, non come SnackBar: lo SnackBar copriva i pulsanti della scheda (A18).
- **La scheda è nello spazio `bottomSheet` dello Scaffold**, con la barriera e `BlockSemantics` sopra il modulo (D10: livello del modulo, non una rotta).
- **Stato "occupato" (A15)**: Flutter non ha una semantica "busy"; il pulsante è disattivato con l'etichetta "Leggo il testo…" in una regione live.
- **`coverage_helper_test.dart` del pacchetto**: elenco `partFiles` per le 4 parti, che non si possono importare; l'elenco di prima non cambia.
- **`recognizer.dart`**: tolti due import inutilizzati (c'erano già), così `dart analyze --fatal-infos` del pacchetto passa.
- **e2e**: `openForm` di `autofill_test.dart` sostituisce anche `textAutofillFlowProvider` nel `ProviderScope` annidato, così l'incolla usa davvero la base e2e.
- **Regole**: `npm run test:rules` non parte perché la porta 8080 è dell'emulatore dell'altra sessione; eseguito lo stesso comando interno contro l'emulatore già avviato.

### Verifiche (2026-11-08, ripetute dopo le correzioni della revisione del codice)

| Controllo | Esito |
|---|---|
| `dart format --set-exit-if-changed .` | 439 file, 0 cambiati |
| `flutter analyze --fatal-infos` | nessun problema |
| `dart analyze --fatal-infos` (pacchetto) | nessun problema |
| `flutter test --coverage` | **2492 test passati** |
| Copertura del progetto come in CI (`merged.lcov.info`, senza esclusioni) | **90,11%** (15643/17359) |
| Cartelle | catalog 98,34%, dashboard 98,84%, sharing 98,42%, cellar 95,64%, label 97,28%, account 97,44% |
| Pacchetto `dart test` | **1886 test passati**, copertura **98,84%** (2131/2156) |
| Regole (comando interno di `test:rules`, prima delle correzioni; le correzioni non toccano regole né scritture) | 216 test: 215 passati, 1 saltato, 0 falliti |
| e2e `autofill_test.dart` su emulator-5554 | **4/4** |
| e2e `label_test.dart` su emulator-5554 | **5/5** |
| Benchmark | `analyzeLabelText` 4000 caratteri **5,392 ms** (≤ 100); `extractLabelFields` 3,307 ms (≤ 200); misure di prima OK. Tempi circa doppi rispetto al passaggio precedente (2,849 ms) con la macchina carica degli emulatori; il codice misurato non è più lento |
| Sensore di tracciabilità | nessun ID mancante, 0 `GAP` |

Test nuovi: `label_analysis_test.dart` (69), `label_words_test.dart` (16), `guided_session_test.dart` (34), `text_autofill_analysis_test.dart` (9), `guided_confirm_controller_test.dart` (7), `guided_confirm_test.dart` (83, di cui 60 nella matrice di accessibilità; compresi "Salva" coperto e la privacy di NFR3.8), 1 e2e nuovo in `autofill_test.dart`.

## Ancora aperto (Build and Test e proprietario)

- Provare sul telefono i 2 secondi e la conferma guidata (§1-decies della checklist).
- Confermare gli scarti dai requisiti di `functional-spec.md` e quello della ruota (anno corrente invece di +1).
- Scaricare a mano l'export reale di eAmbrosia e quello di Open Food Facts, rigenerare le due tabelle e far passare `tool/check_appellations_release.sh` e `tool/check_wine_db_release.sh` (oggi falliscono apposta: le tabelle sono quelle di prova).
- Verificare i CSV non UE con le liste ufficiali.
- Pubblicare le regole prima della build.
- Provare sul telefono "Da Google Lens", l'incolla automatico e la condivisione del testo (§1-decies della checklist).
- Fuori da questo lavoro, come deciso nel piano: il doppione dello Storico e "Annulla", e l'avviso `setState` del `CellarSwitcher`.
