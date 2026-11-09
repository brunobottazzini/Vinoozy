# Riepilogo del codice — profili di stile e classificazione automatica

## Cosa è stato costruito

- **Lo studio come base di dati** (Step 1, D1, D9). `tool/convert_study.py` legge una sola volta l'Excel `vinoozy-handoff-valutazione-vini.xlsx` (solo libreria standard, un .xlsx è uno zip di XML) e scrive `tool/data/study/study_db.json`: i 5 fogli (24 profili, 5946 combinazioni con tutte le colonne, Revisione 60, vitigni e tipi, 24 fonti) come tabelle `columns`/`rows`, con data (2026-11-08), versione (`2026-11-08-draft`), stato e SHA-256 del file. Il contenuto è letto come dato; "—" diventa `null`. Verificato riga per riga contro i TSV estratti in Functional Design (0 differenze).
- **Il generatore della mappa** (`tool/build_profile_map.dart`). Legge la base di dati e i tipi delle righe generate (`appellations.g.dart`), applica la precedenza di BR2 (port fedele di `build_profile_map.py`: correzioni di tipo, passi 1–4, specchio Castelli di Jesi, qualifiche mai sotto la base, ordine Kabinett/Spätlese, controllo delle finestre) e scrive `packages/estimation/lib/src/generated/profile_map.g.dart` (5946 righe compatte). Uno studio rotto non scrive nulla. Risultato identico alla fixture `profile-map.json` in tutti i campi e nei codici di scarto.
- **Dominio del pacchetto `estimation`**:
  - `profiles.dart`: i 24 `StyleProfile` con decorrenza, unità, inizio/picco/fine (null = non stimato), natura dell'evidenza e fonti (BR1.1–BR1.3); le 24 chiavi `WineStyle` con le opzioni per Tipologia e l'etichetta della data (BR1.4, BR5.2, BR8.1).
  - `DrinkingWindow` con `unit`, mesi, `profile`, `anchor`, `anchorFallback`, `indicative`, picco e fine facoltativi; indici di mese (BR6.1); `withIndexes`.
  - `profile_map.dart` (lettura della tabella generata), `style_resolver.dart` (`resolveStyle`: stile scelto, combinazione della mappa più parole di stile, vitigno, tipo, generica), `style_words.dart` (parole per lingua, BR2.16, BR3.2).
  - `estimateWindow` restituisce `null` per "Da stimare" (BR2.9); finestre in mesi dalla sboccatura/imbottigliamento o dal mese di inserimento con inizio 0 (BR6.2, BR8.3); Livello assoluto solo su anni con picco e fine, senza doppio conteggio (BR4.1). `estimationTablesVersion` = 3.
  - `statusOf` sugli indici di mese, notifica di 3 mesi senza picco, sempre "da bere" senza fine (BR6.3); `validateWindow` e `effectiveWindow` con mesi (BR6.8, BR6.10).
  - `classifyWine` (BR3, BR4.3–BR4.5, BR5.3) e `suggestedLevel` (BR4.6); qualifiche nuove `beerenauslese`, `trockenbeerenauslese`, `eiswein` in coda (BR2.6); `agingQualifiers` secondo BR4.4 e `suggestsAgingLevel` (Vintage solo con Porto).
- **Dati** (Step 6–7):
  - `Wine` con `style`, `typeSource`, `levelSource`, `styleSource`, `agingStartMonth`, `migrationVersion`; codec delle finestre con i campi nuovi solo quando servono (una finestra in anni ha la forma di prima); `WindowOverride.endMonth`, `WindowAdjustment.month`; `WindowAdjuster` in mesi (BR6.9).
  - `WineClassification` (BR7.1, BR7.2), `WineDraft.withClassification`, validazione della data (BR8.2) in `WineValidator`.
  - `WineRepository`: campi nuovi in creazione e modifica (cancellati solo se c'erano), `updateClassification` (F5), `migrateWine` in transazione con confronto di `updatedAt` (BR7.4).
  - `EstimatesMigration` riscritta: candidati per `migrationVersion` < 3, provenienze, preselezione dei vuoti, stile, nuova stima per le finestre interne, correzioni conservate, non parte senza rete, rifiuto delle regole contato su 3 avvii (BR7.4–BR7.7, NFR4.9).
  - `firestore.rules` (BR10): campi nuovi ammessi e validati solo quando cambiano, finestra in mesi con l'ordine su `anno*12+mese`, picco e fine facoltativi, qualifiche e mesi nuovi in override e adjustment. Pubblicazione: solo con l'OK del proprietario (non pubblicate).
  - Base offline in formato 2 (`l`, `s`, `t` preselezionato, `classifiedTypeShare` nel manifest, non vini esclusi), rigenerata dall'export in `.cache/off/`; il caricatore legge i formati 1 e 2; il candidato porta `exactType` (BR3.5) anche dal catalogo interno.
- **Interfaccia** (Step 9): `ClassificationState` e campi Stile/Data nel modulo di aggiunta e di modifica ("✦ suggerito", "Ripristina suggerimento", Livello sempre preselezionato), avviso "Stile da confermare" e scelta dello stile o della Tipologia nel dettaglio con annuncio della stima aggiornata, momento ideale in mesi/senza picco/senza fine con l'invito ad aggiungere la data, foglio "Consigliato fino al" con il mese, "entro mar 2027" nella cantina e nel cruscotto, riquadro "Da confermare", percentuale classificata in Informazioni. Testi nei 3 ARB.
- **Configurazione e documentazione** (Step 12): `RULES_FEATURES` con `style-profiles` in `promote.yml`, versione `wine-style-profiles` in `test/rules/compat/app-writes.json`, sezione 1-undecies della checklist di rilascio, README della base.

## File

- **Nuovi**: `tool/convert_study.py`, `tool/data/study/study_db.json`, `tool/build_profile_map.dart`; `packages/estimation/lib/src/` `profiles.dart`, `profile_map.dart`, `style_resolver.dart`, `style_words.dart`, `classifier.dart`, `generated/profile_map.g.dart`; `lib/cellar/domain/wine_classification.dart`, `style_notice.dart`; `lib/cellar/ui/classification_state.dart`, `style_widgets.dart`; `lib/dashboard/ui/to_confirm_card.dart`; test nuovi: pacchetto `profiles_test`, `profile_map_test`, `classifier_test`, `classification_sample_test`, `month_window_test`, `revision60_test`; app `test/cellar/style_migration_test.dart`, `test/tool/build_wine_db_filter_test.dart`, `test/cellar/data/wine_repository_style_test.dart`, `test/cellar/ui/style_widgets_test.dart`, `test/dashboard/style_dashboard_test.dart`, `test/tool/build_profile_map_test.dart`, `test/tool/build_wine_db_classify_test.dart`, `test/rules/style_profiles.rules.test.mjs`; `integration_test/style_profile_flow_test.dart`; fixture `packages/estimation/test/fixtures/profile-map.json` e `classification-sample.json`.
- **Modificati**: pacchetto (`models.dart`, `window.dart`, `status.dart`, `validation.dart`, `effective_window.dart`, `errors.dart`, `qualifiers.dart`, `tables.dart`, `label_fields.dart`, `label_candidates.dart`, `label_words.dart`, `estimation.dart`, benchmark); app (`wine.dart`, `wine_draft.dart`, `wine_validator.dart`, `window_adjuster.dart`, `window_override.dart`, `wine_repository.dart`, `estimates_migration.dart`, `cellar_actions.dart`, `cellar_providers.dart`, `wine_estimator.dart`, `add_wine_screen.dart`, `edit_wine_screen.dart`, `wine_detail_screen.dart`, `ideal_moment_card.dart`, `level_section.dart`, `wine_level_selector.dart`, `window_override_widgets.dart`, `wine_card.dart`, `wine_labels.dart`, `dashboard_calculator.dart`, `dashboard_summary.dart`, `dashboard_screen.dart` (solo il riquadro aggiunto), `drink_soon_section.dart`, `about_screen.dart`, `wine_db_record.dart`, `wine_db_loader.dart`, `wine_catalog.dart`, `internal_catalog.dart`, `catalog_coordinator.dart`, `label_reading_screen.dart`, `label_proposal_sheet.dart`, 3 ARB e localizzazioni generate); `firestore.rules`; `tool/build_wine_db.dart`; `assets/wine_db/` (base rigenerata, README); `.github/workflows/promote.yml`; `test/rules/compat/app-writes.json`; `docs/release-checklist.md`.

## Test e misure (2026-11-09)

| Verifica | Esito |
|---|---|
| `dart format --set-exit-if-changed .` | 467 file, 0 cambiati |
| `flutter analyze --fatal-infos` | nessun problema |
| pacchetto `dart analyze --fatal-infos` | nessun problema |
| pacchetto `dart test --coverage` + `check_coverage.sh 90` | 2011 test verdi (erano 1886); copertura 98,10% (2730/2783) |
| app `gen_coverage_helper` + `flutter test --coverage` | 2634 test verdi (erano 2501) |
| copertura del progetto (lcov unito come in CI) | 89,30% (17353/19432) ≥ 80%; `lib/cellar/` 94,59% |
| regole: `style_profiles.rules.test.mjs` | 30/30 |
| regole: u1, u4, u7, u8, label_autofill, compat | 215 verdi, 2 saltati (scritture `requiresRules` in direzione 2), 0 rossi |
| benchmark del pacchetto | tutti OK: stima+stato+abbinamenti di 500 vini 6,9 ms (≤ 10), `classifyWine` 0,018 ms per vino (≤ 5) |
| `check_wine_db_release.sh` | OK (15490 vini da Open Food Facts) |
| `check_appellations_release.sh` | OK (2424 denominazioni, 1700 generate) |
| altri controlli (`check_estimation_purity`, `check_dashboard_readonly`, `check_label_imports`, `check_rule_ids` dei job CI) | OK |
| e2e su `emulator-5554` | **non eseguito**: vedi "Problemi aperti" |

- **Copertura della base (FR2.1)**: base rigenerata dall'export del 2026-11-07, 15490 vini (176 non vini esclusi in più), **84,22%** con Tipologia (`classifiedTypeShare` 0,8422). Il test bloccante richiede ≥ 84% e che la quota ricalcolata coincida con il manifest; il 90% resta l'obiettivo (stampato).
- **Campione di 100 vini (NFR4.3)**: 87 preselezionati; Tipologia 85/87 = **97,7%** (soglia 95%); Livello 86/87 = **98,9%** (soglia 85%; "sempre Buono" 59,8%); Stile 79/87 (informativo); 10/10 vini senza indizio lasciati vuoti; sulle righe non usate per tarare, Tipologia 72/73.
- **Mappa**: le 5946 combinazioni della tabella generata coincidono con `profile-map.json`; la stima chiamata con la convenzione di ingresso della fixture le riproduce tutte tranne esattamente 3 combinazioni fissate nel test (`lagrein:base:redLight`, `lagrein:qualifier:riserva` → Alto Adige; `derthona:base:white` → Colli Tortonesi), dove la tabella è comunque verificata.

## Aspettative cambiate dai test esistenti (comportamento approvato)

| Test | Prima | Ora | Motivo |
|---|---|---|---|
| `window_test` "Rosso della casa 2023" (redLight) | 2024/2025/2027 | 2023/2024/2026 | BR5.6: rosso leggero per tipo = R_FRESH 0/1/3 |
| `window_test` bianco per tipo (catalogo, scelto a mano) | 2024/2026/2028 | 2025/2027/2030 | BR5.6: W_MEDIUM 1/3/6 |
| `window_test` spumanti senza annata | anni | mesi da gennaio dell'anno di inserimento, inizio 0 | BR6.2, BR8.3 |
| `window_test` "Passito" dolce | 2027/2033/2045 | 2028/2033/2045 | BR2.16: SW_PASSITO 3/8/20 |
| `world_estimate_test` Napa bianco | fine 2028 | 2027 | mappa: W_MEDIUM 1/3/6 |
| `world_estimate_test` Rioja Gran Reserva | 6/12/25 | 8/15/30 (R_LONG) | mappa BR2.2 passo 4 |
| `models_test` codici d'errore | 5 | 7 (`monthOutOfRange`, `invalidAgingStart`) | BR8.2, BR6.10 |
| `label_text_helpers_test`, `label_fields_test`, fixture `label_texts.json` | Premier Cru, Spätlese, Reserva suggerivano "Da invecchiamento"; BA = auslese | non più; BA = `beerenauslese` | BR4.4, BR2.6 |
| `api_test` (casuali) | sempre una finestra | `null` ammesso ("Da stimare"), ordine sugli indici di mese | BR2.9, BR6.10 |
| `wine_test` finestra senza picco o fine | "da stimare" | letta, con picco/fine assenti | D2, NFR2.1 |
| `window_adjuster_test` | riscontro senza mese | con il mese della bevuta | BR6.9 |
| `catalog_coordinator_test` candidato del catalogo interno | senza tipo esatto | con `exactType` | BR3.5 |
| `build_wine_db_test` chiavi del record | b,n,p,t,d,c,v | in più `l`, `s` | BR9.2 |
| `estimates_migration_test` | ristima per `tablesVersion` con `setEstimate` in coda anche offline | riscritto: `migrationVersion`, transazione, fuori rete non parte | BR7.4–BR7.6, NFR4.9 (D4) |
| `autofill_form_test` (4 test del Livello) | "non scelto" salvava nessun livello | il Livello preselezionato si salva come `auto` ("Buono" per Barolo e Chianti) | FR2.3, BR4.3 |
| `wine_repository_style_test` (nuovo) | — | la modifica con riscontro sono 2 scritture | budget delle regole (R-02) |
| `autofill_components_test` | foglio e dialogo in anni | foglio che restituisce anno e mese; dialogo con la data come testo | BR6.8 |

## Scostamenti e decisioni prese qui

- **Regole e limite di 1000 espressioni** (dopo la revisione R-01, R-02):
  - le regole usano espressioni regolari uniche per gli elenchi e controllano in gruppo i campi che cambiano insieme (nome/annata/chiave, testi/paese, livello e classificazione);
  - la `baseWindow` è uguale alla `window` (basta l'uguaglianza), oppure differisce **solo** per date e affidabilità (`diff` limitato a quelle chiavi: tutte le altre descrizioni sono quelle della finestra controllata; inizio, affidabilità, anni interi, mesi 1..12 e ordine sono controllati), altrimenti è controllata per intero. Test negativi per `confidence`, `source`, `profile`, `anchor`, `unit`, mesi, anni non interi, flag e chiave;
  - la finestra effettiva (`WindowAdjuster.effective`) conserva ora `denominationKey` e `tablesVersion` della base, così le due finestre differiscono solo per date e affidabilità;
  - `WineRepository.updateWine` scrive la modifica di un vino con riscontro (finestra diversa dalla base) in **due update in ordine**: dettagli e classificazione, poi la stima. Così anche la modifica più pesante (testi, paese, classificazione, data e due finestre in mesi) passa; un test delle regole riproduce esattamente le due scritture.
  - Margini misurati aggiungendo termini fittizi: creazione completa 10–20 termini, modifica divisa, scelta dello stile nel dettaglio e migrazione con riscontro 20–40 termini.
- **Campo della data**: mese da menu e anno scritto (con validazione), non la ruota dell'annata indicata in `frontend-components.md`.
- **Livello**: si salva sempre (preselezionato, `levelSource auto`) come chiede FR2.3; "Nessuno" resta e non salva un livello.
- **Migrazione**: `EstimatesMigrationFailureReason.localWriteFailed` resta nell'enum per compatibilità del registro ma la migrazione nuova non lo usa (scrive in transazione, solo in rete).

## Problemi aperti

- **E2E non eseguiti** (Step 11): `integration_test/style_profile_flow_test.dart` è scritto e compila, ma su `emulator-5554` ogni test d'integrazione (anche `label_test.dart` esistente) fallisce al caricamento con "WebSocketChannelException: Connection closed before full header was received": il collegamento al servizio VM dell'app attraverso il port forwarding di adb non riesce in questo ambiente. L'esecuzione fuori dalla sandbox non è stata autorizzata. Da eseguire: `style_profile_flow_test.dart`, `autofill_test.dart`, `label_test.dart` (prima un test delle regole correnti, vedi `unit-test-instructions.md`).
- **Limite delle regole**: i margini restano stretti (vedi sopra); prima di aggiungere controlli a `firestore.rules` vanno rieseguiti i test "expression budget". La modifica divisa in due update non è atomica: se la seconda scrittura fallisse resterebbero dettagli nuovi con la stima precedente (riscritta alla prossima stima).
- **Copertura della base 84,22%** sotto l'obiettivo del 90% (accettata dal proprietario nella fascia 84–86%).
- **Regole non pubblicate**: vanno pubblicate prima della build, con l'OK del proprietario (checklist 1-undecies).
- Un test delle regole di u7 è fallito una volta in una corsa con tutti i file e passa da solo e nella corsa finale (instabilità dell'emulatore condiviso).

## Correzioni dopo la revisione (2026-11-09)

- R-01, R-02: vedi "Regole e limite di 1000 espressioni" (regole cambiate: vanno ripubblicate con l'OK del proprietario).
- R-03: un vino con riscontro, senza `baseWindow` e con una `window` del catalogo conserva la finestra del catalogo nella migrazione (test).
- R-04: `levelSource` si scrive solo con un livello.
- R-05: le eccezioni del test della mappa via stima sono un elenco esatto.

## Correzione da Build and Test (loop-back 1)

- **Generazione della base più veloce (NFR3.3).** `tool/build_wine_db.dart` divide le righe dell'export direttamente sui byte (`RawLineFilter`, stessi a capo di `LineSplitter`: `\n`, `\r`, `\r\n`) e decodifica e legge solo l'intestazione, le righe che contengono `en:wines` in qualunque maiuscola/minuscola (le sole che `recordOfRow` può tenere, perché confronta i tag in minuscolo) e le rare righe senza caratteri ASCII visibili; le altre si contano come `notWine` senza decodificarle. Controllo conservativo: nessuna riga che oggi entra nella base viene scartata.
- **Tempo misurato** sull'export completo `.cache/off/en.openfoodfacts.org.products.csv.gz` (4.899.177 righe, 14 GB decompressi): **1 min 25 s** con `dart run` (compilazione compresa), contro 3 min 30 s prima. Un primo tentativo con il solo filtro prima di dividere la riga in campi scendeva a 2 min 57 s: il tempo era nella decodifica UTF-8 e nella divisione in righe di 14 GB.
- **Stessa base.** Il file rigenerato è identico byte per byte a quello spedito (`cmp` di `wines.jsonl.gz` e del contenuto decompresso, `manifest.json` identico): 15490 vini, `classifiedTypeShare` 0,8422, stessi conteggi degli scarti (notWine 4882175, invalidName 879, excludedCategory 176, invalidBarcode 457). `check_wine_db_release.sh` OK.
- **Test nuovi.** `test/tool/build_wine_db_filter_test.dart`: l'export di prova e righe aggiuntive (tag maiuscoli, `\r\n`, righe vuote, ultima riga senza a capo, blocchi da 1 byte a 64 KB) danno con il filtro le stesse righe, gli stessi scarti e gli stessi vini della lettura di ogni riga. `test/cellar/estimates_migration_test.dart`: "NFR3.7 500 wines are computed in under 2.5 s".
- Nessuna modifica a `firestore.rules`.
