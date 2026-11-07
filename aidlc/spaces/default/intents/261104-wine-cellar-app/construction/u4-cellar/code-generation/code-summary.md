# Code Summary — u4-cellar

U4 completa la gestione della cantina (US2.1, US2.3, US3.1–US3.4, US4.1, US4.2, US6.1, US6.2, US7.1, US9.1, US9.2; BR1.1–BR1.20):
- inserimento con i suggerimenti del catalogo di U3 e il produttore nuovo;
- doppioni, con aggiunta di bottiglie anche a un vino finito, e "Possibile doppione" con "Unisci";
- elenco dei soli vini presenti (`quantity > 0`), con ricerca, filtri e archivio "Bevuti";
- dettaglio con finestra, stato, fiducia, fonte, avviso fisso e abbinamenti;
- modifica ed eliminazione;
- bevuta con "Annulla", voto, note, data e "Com'era?", che corregge la finestra;
- Storico a pagine;
- recupero al ritorno della rete.

Tutto gira nell'app, senza funzioni nel cloud: le regole di Firestore fanno rispettare forme e permessi. Nessun test e nessuno strumento ha usato il progetto Firebase reale (`vinoozy-d6f45`): le regole sono state provate solo sull'emulatore `demo-vinoozy`. Nessuna regola pubblicata, nessun `firebase deploy`, nessun commit, nessun push, nessun ramo. Nessuna dipendenza nuova.

La metodologia è quella del Testing Contract: **test-after**, strato per strato (modello dei dati, accesso ai dati, logica, interfaccia), con i test di ogni strato verdi prima di passare al successivo.

## File creati

**Modello dei dati `lib/cellar/domain/`** (solo Dart, senza Flutter: lo usa il benchmark con `dart run`)
- `drinking_record.dart`: `DrinkingRecord` con `condition` e `updatedAt`, mapper che non lancia mai, `DrinkCondition`, `RecordRules` (voto 1–5, note fino a 1.000 caratteri, data non futura e non prima dell'annata), `formatDrankOn`/`parseDrankOn` (`YYYY-MM-DD`), ordinamento "più recente prima" (`drankOn`, poi `createdAt`).
- `wine_validator.dart`: `WineValidator` con un errore per campo (nome, produttore, annata, quantità; BR1.3). La quantità minima è 1 in inserimento e 0 in modifica.
- `match_key.dart`: `matchKeyOf(nome, produttore, annata)` con `normalizeWineText` di C2, al più 400 caratteri (BR1.4).
- `window_adjuster.dart`: `WindowAdjustment` e `WindowAdjuster`, puro: le regole di BR1.12, la fiducia abbassata di un livello solo quando la finestra cambia, la scelta del riscontro valido, l'etichetta della fonte. Un risultato fuori da 1900–2200 lascia la finestra di base.
- `quantity_delta.dart`: `forIncrease(s, n) = n − min(0, s)`, `canDecrease`, `forEdit` per la modifica (BR1.15).
- `cellar_filter.dart`: `CellarFilter` (ricerca senza maiuscole e accenti su nome e produttore, filtri per stato con "da stimare" e per famiglia con "non indicata", combinabili), `wineStatusOn`, `statusIndexOf` per calcolare gli stati una volta per lista.
- `producer_options.dart`: proposte del produttore, ultima voce sempre "Aggiungi «testo» come nuovo produttore" (BR1.2).
- `wine_estimate.dart`: `WineEstimate` (`baseWindow`, `window`, `windowAdjustment`, `pairings`) e i campi da scrivere.

**Accesso ai dati `lib/cellar/data/`**
- `drinking_record_repository.dart`: `drink` (un batch con −1 e la bevuta), `undo` (lettura dalla cache, `nothingToUndo`, rifiuto segnalato con `CellarNotice` e motivo `cellar_undo_failed`, mai con `reportWriteRejected`), `updateRecord`, `pageHistory` (30 per pagina, cursore sul documento), `recordsOfWine` (server con tempo massimo di 1 s, cache, o solo server).
- `match_key_backfill.dart`: una volta per cantina, batch da 400 attesi uno per uno, poi `matchKeyBackfill: true`; ripresa senza riscritture; `keyLoaded` per i vini caricati ancora senza chiave.
- `record_reconciler.dart`: voci `reapplyAdjustment` e `purgeRecords` in `shared_preferences` con la chiave `cellar.pending.<uid>`, idempotenti, al più 50, scadenza dopo 7 giorni, ripiego in memoria segnalato una volta.
- `pending_writes_probe.dart`: segna le bevute "in attesa" finché `waitForPendingWrites()` non si chiude; controllo all'avvio con attesa di 300 ms; motivo `pending_probe_failed`.
- `cellar_errors.dart`: i motivi fissi degli errori e i valori sensibili di un vino (nome, produttore, denominazione).
- `server_or_cache.dart`: lettura dal server entro un tempo massimo, poi dalla cache.

**Logica `lib/cellar/`**
- `cellar_providers.dart`: `drinkingRecordRepositoryProvider`, `matchKeyBackfillProvider`, `recordReconcilerProvider` (iniettati all'avvio), `estimateRefresherProvider`, `cellarActionsProvider`, `cellarMaintenanceProvider`, `cellarMaintenanceTriggerProvider`, `wineProvider`, `archivedWinesProvider`, `recentDrinksProvider`, `cellarFilterProvider`, `historyPagerProvider`, `wineSuggestionsProvider` (250 ms per i suggerimenti interni, 600 ms per Open Food Facts come chiede U3).
- `cellar_actions.dart`: le operazioni dietro le schermate (salvataggio con controllo dei doppioni, modifica, bevuta, annulla, voto e note, ricalcolo del riscontro, stime mancanti, eliminazione, unione), con i permessi.
- `estimate_refresher.dart`: al più 20 vini per ritorno della rete, uno per volta, solo con `canEdit`, un errore per vino che non ferma gli altri.
- `wine_estimator.dart`: stima interna, miglioramento dal profilo del catalogo, stima calcolata in memoria per chi ha solo lettura (BR1.19).
- `cellar_maintenance.dart`: stime mancanti, backfill, riconciliazione e miglioramento delle stime all'apertura della cantina e al ritorno della rete.

**Interfaccia `lib/cellar/ui/`**
- `wine_detail_screen.dart` (dettaglio), `edit_wine_screen.dart`, `history_screen.dart`, `archived_wines_screen.dart` ("Bevuti");
- `drinking_record_sheet.dart` (voto con stelle "Voto N su 5", note, data, "Com'era?");
- `window_card.dart` (`WindowCard`, `PairingsCard`), `duplicate_banner.dart`, `cellar_dialogs.dart` (`DuplicateDialog`, `DeleteWineDialog`, `MergeDialog`), `drink_snack_bar.dart` (6 s, 10 s con lettore di schermo o animazioni ridotte), `drink_flow.dart` (bevuta con "Annulla" anche dopo la chiusura della schermata), `wine_labels.dart` (testi tradotti di stato, tipologia, fiducia, fonte, abbinamenti).

**Test, strumenti, CI**
- `test/cellar/` (313 test): `cellar_harness.dart`; `domain/` (7 file); `data/` (5 file); `cellar_providers_test.dart`, `estimate_refresher_test.dart`, `adjustment_flow_test.dart`; `ui/` (`cellar_ui_harness.dart` e 7 file di test, nelle tre lingue, con la matrice di accessibilità a testo 1,0 e 2,0, tema chiaro e scuro).
- `test/rules/u4.rules.test.mjs` (35 test, 70 punti di verifica, più di 120 asserzioni eseguite con i cicli).
- `tool/check_rule_ids.sh`, `tool/check_rule_ids_test.sh`, `tool/fixtures/rule_ids/ok/` e `missing_br1_1/`; `tool/fixtures/firestore_indexes/missing_history.json`.
- `benchmark/cellar_benchmark.dart`.
- `integration_test/cellar_test.dart`, `integration_test/concurrent_drink_test.dart`, `integration_test_perf/cellar_perf_test.dart`.

## File modificati

- **Regole e indici:**
  - `firestore.rules`: `validWindow`, `validAdjustment`, `validMatchKey`, `validWineExtras`; caso del backfill (`onlyChanged(['matchKey'])` con `canEditCellar`); flag `matchKeyBackfill` della cantina; `validRating`, `validNotes`, `validDrankOn`, `validCondition`, `validDrinkingRecord` completa, update delle bevute da chi le ha registrate o dal proprietario, delete del proprietario o dell'autore entro 10 minuti, sempre con `resource != null`.
  - `firestore.indexes.json`: indice composito di `drinkingRecords` (`drankOn` DESC, `createdAt` DESC, `COLLECTION`).
- **Codice di U1:**
  - `wine.dart`: campi `matchKey`, `baseWindow`, `windowAdjustment`, `pairings`, scrittura di finestra e abbinamenti, `compareByAge`;
  - `wine_draft.dart`: `withDetails` (produttore, tipologia, regione, denominazione), senza cambiare i campi di U1;
  - `wine_repository.dart`: `watchCellarWines` con `where quantity > 0` al posto di `watchWines`, `watchWine`, `fetchArchived`, `findByMatchKey`, `addWine`, `addBottles`, `removeBottle`, `updateWine`, `setEstimate`, `mergeInto`, `deleteWineWithRecords` a parti di 400 con un nuovo tentativo, `purgeRecords`; `create` e `incrementQuantity` di U1 restano;
  - `firestore_codec.dart`: percorsi delle bevute;
  - `cellar_screen.dart`, `add_wine_screen.dart` (versione completa), `wine_list_tile.dart`, `quantity_stepper.dart` (minimo configurabile, 0 in modifica).
- **Sincronizzazione:** `lib/sync/sync_status.dart` (`SyncSource.drinkingRecords`, `setPending`); `lib/sync/sync_error_bus.dart` (`CellarNotice`).
- **App:** `lib/app/providers.dart` (`watchCellarWines`, `drinkingRecordsPendingProvider` nel calcolo dello stato, invalidazione dei nuovi ascolti al reset); `lib/app/home_shell.dart` (terza scheda Storico, collegamenti dal Cruscotto, avvio della manutenzione); `lib/app/bootstrap.dart` (creazione dei servizi nuovi e controllo all'avvio); `lib/app/vinoozy_app.dart` (messaggi di `CellarNotice`).
- **Traduzioni:** `lib/l10n/app_it.arb`, `app_en.arb`, `app_pt_BR.arb` e i file generati da `flutter gen-l10n`. `openListHint` diventa "Apri l'elenco" (BR1.17).
- **Test esistenti:** `test/u1/` (repository con `watchCellarWines`, stato della sincronizzazione, form di inserimento sostituito, riga con lo stato), `test/dashboard/` (harness con i servizi della cantina, suggerimento "Apri l'elenco"), `test/app/home_shell_test.dart` (i tre collegamenti e la scheda Storico), `test/account/account_gate_home_shell_test.dart`, `test/sharing/` (harness, `watchCellarWines`, cantina di partenza dal server).
- **Compatibilità e CI:** `test/rules/compat/app-writes.json` (versione `u4-cellar`, `requiresRules: "cellar"`), `package.json` (`u4.rules.test.mjs`), `.github/workflows/ci.yml` (job `analyze`, `unit`, commenti del job `rules`), `.github/workflows/promote.yml` (`RULES_FEATURES: sharing cellar`), `tool/check_firestore_indexes.sh` e il suo test, `tool/fixtures/firestore_indexes/ok.json`.
- **E2E:** `integration_test/e2e_helpers.dart` (`createWine`, `recordDrink`, `cloudQuantity`, `cloudDrinkCount`; "Salva" reso visibile prima del tocco, perché i suggerimenti possono spingerlo in basso).
- **Documenti:** `docs/release-checklist.md` (§1-quinquies Cantina, §2 Data Safety e chiave `cellar.pending.<uid>`, §3 indice dello Storico "Abilitato", §4 rollback delle regole solo prima della promozione, §5 controllo mensile `cellar_*`).

## Decisioni di implementazione

- **Riscontro (BR1.12):** la fiducia scende di un livello solo quando la finestra cambia davvero; un riscontro che non la cambia viene salvato senza effetti, come dice il chiarimento "Fonte mostrata". `source` e `basis` restano quelli della stima di base, perché le regole ammettono solo `catalog` e `internalRules`.
- **Doppioni:** la query ha 1 s per il server, poi legge la cache. Se fallisce, il salvataggio procede comunque (motivo `cellar_save_failed`): il controllo dei doppioni non blocca mai l'inserimento.
- **Eliminazione:** con la rete ogni parte è attesa, e un rifiuto porta a una nuova lettura dal server e a un solo nuovo tentativo. Senza rete tutte le parti vanno in coda sul telefono, il vino sparisce subito dall'elenco e una voce `purgeRecords` cancella al ritorno della rete le bevute non ancora scaricate. Dopo due rifiuti il vino resta, la voce `purgeRecords` completa l'eliminazione più tardi e compare "L'eliminazione non è ancora completa: continuerà appena possibile" (dopo la revisione, R-06). La schermata si chiude subito e l'eliminazione continua in background.
- **Miglioramento delle stime:** con le fonti attuali di U3 `getWineProfile` non ha finestre: tipologia, regione e denominazione del profilo completano i fatti vuoti e le regole interne ripartono. Si scrive solo se il risultato è diverso; ogni vino si prova una volta per sessione.
- **Elenco:** un elenco vuoto letto dalla sola cache mostra "Sincronizzazione della cantina…" e, dopo 2 s senza server, l'invito (BR1.7; dopo la revisione, R-03). Gli stati del giorno si calcolano una volta per lista.
- **Dettaglio:** un vino presente si legge dall'elenco già caricato; solo un vino che non c'è (finito, o aperto dallo Storico) apre l'ascolto del documento, e solo dopo che l'elenco è arrivato.
- **Bevute in attesa:** `PendingWritesProbe` aggiorna `drinkingRecordsPendingProvider`, che `SyncStatusNotifier` passa a `SyncStatusTracker.setPending`; lo stato "offline" continua a venire dagli snapshot.
- **Accessibilità:** stelle con `Semantics(button, selected, "Voto N su 5")`; stato sempre con icona e testo (icone di U5); azioni del messaggio di bevuta di almeno 48×48 dp.
- **Chiavi di prova:** le chiavi di U1 già usate dagli E2E restano (`add-wine-name-field`, `add-wine-vintage-field`, `add-wine-no-vintage-switch`, `add-wine-save-button`, `cellar-add-button`, `quantity-*`), come chiede la regola sulla stabilità delle chiavi. Gli elementi nuovi usano le chiavi di `frontend-components.md`.
- **Motivo in più:** `cellar_history_failed` per una pagina dello Storico non letta (per esempio un indice non ancora "Abilitato"). È fisso e senza dati, come gli altri, ed è aggiunto anche al controllo mensile.

## Risultati

| Controllo | Esito |
|---|---|
| `dart format --output=none --set-exit-if-changed .` | 0 file cambiati |
| `flutter analyze --fatal-infos` | nessun problema |
| `flutter test` (suite completa) | **1.123 test verdi** (prima di U4: 817) |
| `flutter test test/cellar` | 313 test verdi |
| `npm run test:rules` (emulatore Firestore, `demo-vinoozy`) | 169 test: 168 verdi, 1 saltato (direzione 2 della compatibilità: nessun tag `v*`) |
| `tool/check_rule_ids.sh BR1. 20 test/cellar test/rules/u4.rules.test.mjs` | OK, BR1.1–BR1.20 in 24 file |
| `tool/check_rule_ids_test.sh` | OK |
| `tool/check_firestore_indexes.sh` e il suo test | OK |
| Copertura di `lib/cellar/` | **95,19%** (2.593/2.724 righe) |
| Copertura dell'app (`lib/`, senza esclusioni) | 88,12% (6.562/7.447) |
| Copertura di progetto (app + `estimation`, come in CI) | **88,64%** (6.905/7.790) |
| Copertura di `lib/catalog/`, `lib/dashboard/`, `lib/sharing/` | 99,48%, 99,04%, 98,42% |
| `dart run benchmark/cellar_benchmark.dart` | filtri 1,56 ms (soglia 20 ms); finestra effettiva 0,06 ms (soglia 5 ms) |
| Altri benchmark (`dashboard`, `catalog`) | verdi |

Nessuna soglia è stata abbassata e nessun file è stato escluso dalla copertura.

## Test scritti ma non eseguiti

- `integration_test/cellar_test.dart` e `integration_test/concurrent_drink_test.dart`: richiedono un emulatore Android collegato alla Firebase Emulator Suite. Su questa macchina non c'è nessun dispositivo Android (`adb devices` vuoto), quindi non sono stati eseguiti. Girano nel job `e2e` di `ci.yml` (raccolti da `flutter test integration_test`) e in Build and Test. Compilano e passano `flutter analyze`.
- Gli E2E esistenti di U1, U5 e U7 (`u1_skeleton_test.dart`, `force_stop_queue.dart`, `dashboard_500_test.dart`, `sharing_test.dart`) non sono stati rieseguiti, per lo stesso motivo. Possono risentire di tre cambiamenti di U4: il form di inserimento completo (l'helper `addWine` ora porta "Salva" in vista prima del tocco), il controllo dei doppioni (fino a 1 s senza rete prima della cache) e l'elenco vuoto letto dalla sola cache, che mostra "Sincronizzazione della cantina…" fino al server o per 2 s.
- `integration_test_perf/cellar_perf_test.dart`: fuori dalla CI per scelta del piano. Si esegue a mano sul telefono (checklist §1-quinquies).

## Scostamenti dal piano

- **Posizione di `winesStreamProvider`:** resta in `lib/app/providers.dart`, dove l'ha messo U1 e dove lo leggono Cruscotto e condivisione. Ora usa `watchCellarWines`. In `cellar_providers.dart` ci sono gli altri provider del piano.
- **File in più rispetto all'elenco del piano:** `cellar_actions.dart`, `cellar_maintenance.dart`, `wine_estimator.dart`, `domain/wine_estimate.dart`, `data/cellar_errors.dart`, `data/server_or_cache.dart`, e in `ui/` `wine_labels.dart`, `window_card.dart`, `duplicate_banner.dart`, `drink_flow.dart` e `archived_wines_screen.dart`. Sono una divisione delle responsabilità del piano, senza funzioni in più.
- **File di U1 e U7 toccati in più:** `lib/sync/sync_error_bus.dart` (evento `CellarNotice`, per il messaggio di un "Annulla" rifiutato senza passare da `reportWriteRejected`) e `lib/app/vinoozy_app.dart` (il suo messaggio). `lib/cellar/domain/quantity.dart` non è cambiato: è bastato `quantity_delta.dart`. `lib/sharing/` e `lib/dashboard/` non sono cambiati: i collegamenti del Cruscotto (BR1.17) stanno nella `HomeShell`, che li inietta.
- **`watchWines` → `watchCellarWines`:** il piano diceva che i test con flussi finti di U5 e U7 non sarebbero cambiati. È cambiato solo il nome del metodo negli stub. Gli harness di U5 e U7 aggiungono i servizi finti della cantina, perché la `HomeShell` ora avvia la manutenzione.
- **`addWine` e `create`:** `addWine` è il nuovo metodo completo; `create` di U1 resta per compatibilità e per i suoi test.
- **Tempo nei test:** `package:fake_async` non è una dipendenza dichiarata e il piano vieta dipendenze nuove. Le attese (250/600 ms, 1 s, 300 ms, 6/10 s) si provano con il tempo finto di `testWidgets` (`tester.pump(durata)`), che usa `fakeAsync` internamente; i 7 giorni con un orologio iniettato.
- **`itemExtent` fisso:** non usato nell'elenco, perché con il testo al 200% le righe di altezza fissa verrebbero tagliate (NFR3.4); l'elenco resta comunque pigro (`ListView.builder`) e gli stati sono precalcolati.
- **Etichetta dello stato nelle righe:** riusa i testi di stato del Cruscotto (es. "pronte"), condivisi tra le due schermate.
- **Strumenti:** due modifiche in posto a file del piano (`lib/app/providers.dart` e i tre `.arb` per `openListHint`) sono state fatte con `sed -i` invece che con lo strumento di modifica dei file; il risultato è identico a una modifica a mano.

## Correzioni dopo la revisione

Revisione: `reviews/review-01.md` (verdetto READY, 1 Major e 6 Minor). Tutti i punti sono corretti, ognuno con un test di regressione.

- **R-01 (Major) — Storico aggiornato nella stessa sessione (BR1.16, US6.2).**
  - Il nuovo `invalidateDrinkReads` in `cellar_providers.dart` ricarica la prima pagina dello Storico della cantina e le ultime bevute dei vini toccati. Lo chiamano la bevuta e "Annulla" (`drink_flow.dart`), il salvataggio di voto e note (`drinking_record_sheet.dart`), l'eliminazione (`wine_detail_screen.dart`, a eliminazione finita) e l'unione (`duplicate_banner.dart`).
  - Usa il `ProviderContainer` letto prima delle attese, quindi funziona anche quando la schermata che ha avviato la scrittura è già chiusa.
  - In più, tornando sulla scheda Storico, la `HomeShell` lo ricarica: così compaiono anche le bevute scritte da altre persone di una cantina condivisa.
  - La ricarica a mano dopo il foglio di modifica nello Storico è stata tolta, perché ora è automatica.
  - Test: `test/cellar/ui/drink_reads_refresh_test.dart` (bevuta e "Annulla", voto e note, eliminazione, unione) e `test/app/home_shell_test.dart` (ritorno sulla scheda).
- **R-02 — Ultime bevute del dettaglio.** Lo stesso `invalidateDrinkReads` invalida `recentDrinksProvider` dopo "Annulla", dopo voto e note, dopo l'eliminazione e dopo l'unione. Test nello stesso file.
- **R-03 — Elenco vuoto dalla sola cache.**
  - Al posto del cerchio senza fine, la Cantina mostra lo stesso testo del Cruscotto ("Sincronizzazione della cantina…", chiave `cellar-syncing`), con "Aggiungi" sempre disponibile in basso.
  - Dopo 2 s senza uno snapshot del server, quindi anche senza rete, compare l'invito ad aggiungere il primo vino. Con la rete lo snapshot del server lo mostra subito, come prima.
  - Il Cruscotto (U5, non modificato) mostra già in questo caso "Sincronizzazione della cantina…" con il pulsante di aggiunta: i due stati non sono vicoli ciechi e usano lo stesso testo.
  - Test: `test/cellar/ui/cellar_screen_test.dart`.
- **R-04 — Manutenzione al primo snapshot del server.**
  - `cellarMaintenanceTriggerProvider` parte all'apertura. Se il primo snapshot veniva dalla cache, riparte una volta al primo snapshot del server con i vini veri (stime mancanti, `keyLoaded`, miglioramento dal catalogo).
  - `CellarMaintenance.run` non gira mai due volte insieme: una richiesta che arriva durante un giro viene messa in coda (l'ultima vince) e parte una sola volta subito dopo.
  - Test: `test/cellar/cellar_providers_test.dart` e `test/cellar/adjustment_flow_test.dart`.
- **R-05 — Tetto di 99 bottiglie (BR1.3) e limiti delle regole.**
  - App:
    - `QuantityDelta.room` e `canIncrease`;
    - `WineRepository.addBottles` e `mergeInto` rifiutano oltre 99 senza scrivere;
    - "+" del dettaglio disattivato a 99;
    - `DuplicateDialog` aggiunge al più fino a 99; a 99 mostra "Questo vino ha già 99 bottiglie…" e disattiva "Aggiungi", con la chiave nuova `duplicateFull` in it, en e pt-BR;
    - il form di inserimento usa lo stesso numero limitato.
  - Regole:
    - `validWineUpdate` aggiunge `quantity <= 99` solo quando la quantità cambia. Un valore negativo resta modificabile, e un vino già sopra 99 resta modificabile negli altri campi.
    - `validOptionalText` limita `producer`, `region` e `denomination` a 120 caratteri, sia alla creazione (in `validWineExtras`) sia nell'aggiornamento quando cambiano.
    - `validPairings` controlla la forma di `pairings` (chiavi `items`, `categoryKeys`, `source`, liste di al più 10) in creazione e in aggiornamento.
    - La compatibilità nella direzione (1) resta verde per tutte le versioni registrate.
  - Test: 4 test nuovi in `test/rules/u4.rules.test.mjs`, più `quantity_delta_test.dart`, `wine_repository_test.dart`, `dialogs_test.dart`, `wine_detail_screen_test.dart` e `add_wine_screen_test.dart`.
- **R-06 — Eliminazione rifiutata due volte.**
  - Il comportamento resta quello di `security-design.md` §4: la richiesta di eliminare dell'utente viene completata da `purgeRecords` al ritorno della rete, e il vino si cancella solo nell'ultima parte, dopo che tutte le bevute sono state cancellate. Una parte rifiutata ferma tutto e il vino resta.
  - Il messaggio ora dice il vero: "L'eliminazione non è ancora completa: continuerà appena possibile" (en e pt-BR tradotti), mai "riprova".
  - Test: `wine_repository_test.dart` (parte rifiutata, il vino resta) e `dialogs_test.dart` (testo nelle tre lingue).
- **R-07 — E2E "bevuta, Storico, Annulla".**
  - Nuovo scenario in `integration_test/cellar_test.dart`: lo Storico aperto una volta mostra la bevuta nuova e la toglie dopo "Annulla".
  - Compila e passa `flutter analyze`. Non è stato eseguito (nessun dispositivo Android su questa macchina): va verificato nel job `e2e` prima del merge in `main`.

**Risultati dopo le correzioni:**
- `dart format`: 0 file cambiati;
- `flutter analyze --fatal-infos`: nessun problema;
- `flutter test`: **1.142 test verdi** (`test/cellar`: 331);
- `npm run test:rules`: 173 test, 172 verdi e 1 saltato (direzione 2, nessun tag `v*`); `u4.rules.test.mjs` da solo: 39/39;
- `check_rule_ids`: OK, BR1.1–BR1.20 in 25 file; `check_rule_ids_test`, `check_firestore_indexes_test`: OK;
- copertura di `lib/cellar/`: **95,29%** (2.669/2.801);
- copertura dell'app: 88,29% (6.650/7.532);
- copertura di progetto con `estimation`: **88,80%** (6.993/7.875);
- copertura di `lib/catalog/`, `lib/dashboard/`, `lib/sharing/`: 99,48%, 99,04%, 98,42%;
- benchmark: filtri 1,58 ms (soglia 20 ms), finestra effettiva 0,06 ms (soglia 5 ms).

Nessuna soglia abbassata, nessuna esclusione. I file toccati rientrano nei percorsi già elencati in `source-manifest.json`: il nuovo test sta sotto `test/cellar/`.

## Comandi

```bash
flutter test test/cellar
npm run test:rules
flutter test test/u1 test/dashboard test/sharing test/app
flutter test --coverage test/cellar && tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/
tool/check_firestore_indexes.sh
tool/check_firestore_indexes_test.sh
tool/check_rule_ids.sh BR1. 20 test/cellar test/rules/u4.rules.test.mjs
tool/check_rule_ids_test.sh
dart run benchmark/cellar_benchmark.dart
```
