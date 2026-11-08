# Piano del codice — compilazione dall'etichetta e finestre per tutto il mondo

## Summary

- Builds:
  - lettura dei campi dal testo dell'etichetta (foto, "Incolla da Lens", "Condividi", incolla automatico al ritorno da "Da Google Lens");
  - tabella delle denominazioni di tutto il mondo, generata dai registri ufficiali con valori dedicati, più i vitigni;
  - campo Livello, correzione di "Consigliato fino al", ricalcolo una tantum delle stime;
  - regole Firestore;
  - **riapertura da Build and Test (2026-11-08):** risultato visibile entro 2 secondi dopo l'incolla (FR2.8) e conferma guidata dei campi incerti con Sì / No / Modifica / Salta, composizione toccando le parole e ruota dell'annata (FR7).
- Touches:
  - `packages/estimation/` (tabelle, tabella generata, estrattore, finestra effettiva);
  - `tool/build_appellations.dart` e `tool/data/appellations/`;
  - `lib/cellar/` (modello, repository, moduli, dettaglio);
  - `lib/label/`, `lib/app/home_shell.dart`;
  - Android (canale Lens, filtro `text/plain`, `<queries>`);
  - `firestore.rules`, `test/rules/`, `promote.yml`, file ARB, checklist.
- Tests: circa 150 test nuovi:
  - estrattore con l'insieme di riferimento di 30 o più testi;
  - un test per ogni riga dedicata, per ogni modello e sulla tabella generata intera;
  - livello e finestra effettiva nei 6 punti in cui la finestra si scrive o si mostra;
  - regole e compatibilità;
  - widget nella matrice di accessibilità;
  - 2 e2e;
  - la suite esistente resta verde;
  - riapertura: circa 120 test nuovi (analisi e certezza sull'insieme di riferimento di 69 testi, parole, macchina a stati della guida, widget nella matrice, 2 e2e, benchmark).

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR6, NFR1–NFR6).
- `inception/refined-mockups/` (`autofill-mockups.html`, `interaction-spec.md`, `accessibility-checklist.md`).
- `construction/functional-design/` (D1–D6, BR1–BR6, `world-tables.md`; riapertura: D7–D13, BR7.1–BR7.25, ENT-007–ENT-014, F7, F8, `label-reference-set.md`).
- `construction/nfr-requirements/`.
- `codekb/Vinoozy/`.

Non c'è Units Generation, quindi il lavoro è un'unica iterazione. Le storie sono i requisiti FR e NFR.

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

Gli strati: dominio (pacchetto `estimation`), dati (modello, repository, regole), API/canale nativo, interfaccia.

## Passi

- [ ] **Step 1 — Struttura.** (D1, D2)
  - File nuovi nel pacchetto `estimation`:
    - `src/label_fields.dart` (`extractLabelFields`, `LabelFields`);
    - `src/vintage_parser.dart` e `src/label_line_picker.dart`, spostati da `lib/label/core` e reimportati da lì;
    - `src/world_tables.dart` (righe dedicate e modelli);
    - `src/grapes.dart`;
    - `src/generated/appellations.g.dart`;
    - `src/effective_window.dart`;
    - `src/wine_level.dart`.
  - Strumento: `tool/build_appellations.dart`, `tool/data/appellations/*.csv` (non UE, con fonte, data e licenza nell'intestazione) e `tool/fixtures/eambrosia_sample.csv` (estratto di prova).
  - `.gitignore` aggiunge `.cache/`.
- [ ] **Step 2 — Esecutore dei test.** Verifico i comandi di `unit-test-instructions.md` sul codice di oggi: `dart test` nel pacchetto, `flutter test` dell'app, `npm run test:rules`. (NFR5.5)
- [ ] **Step 3 — Dominio: tabelle e stima.** (FR3, FR4, BR3, BR4.1, BR4.2)
  - Righe dedicate: le 80 estere di `world-tables.md` e le 47 italiane di oggi, portate ad **almeno 500**, con motivazione nei commenti (decisione del proprietario, messaggio 94dc0883). Comprendono:
    - tutte le 77 DOCG italiane e le DOC principali;
    - per la Francia, i cru e le AOC comunali di Bordeaux, Borgogna, Rodano, Loira e Alsazia, più Champagne;
    - le DO e DOCa qualificate di Spagna e Portogallo;
    - le zone principali di Germania e Austria;
    - le zone principali del Nuovo Mondo.

    Tutte le altre (DOC locali minori, IGT, IGP) prendono la finestra dai modelli.
  - Tipi multipli, alias deboli, qualifiche nuove (BR1.8).
  - Modelli (BR3.7) e tabella dei vitigni.
  - `resolveWine` con la precedenza di BR3.1 e BR3.2; basis `grape`.
  - `estimateWindow(..., level)` con BR4.1 e BR4.2.
  - `effectiveWindow` con BR4.4.
  - `WineOrigins._denominations` diventa una vista sulla tabella del pacchetto (BR3.5).
- [ ] **Step 4 — Strumento della tabella.** (BR3.6, NFR4.5, NFR4.12)
  - `build_appellations.dart` legge l'estratto eAmbrosia e i CSV, scrive il file generato ordinato e stabile, con i controlli di BR3.6.
  - Fino al download reale in Build and Test, il file generato si costruisce dall'estratto di prova più i CSV non UE. Il controllo "≥ 1500 righe" si sospende solo con l'opzione `--allow-sample`, che il manifesto registra e che `check_wine_db_release.sh` / promote bloccano, come per la base di Open Food Facts.
- [ ] **Step 5 — Dominio: estrattore.** (FR1.1, BR1)
  - `extractLabelFields` con BR1.1–BR1.9.
  - `VintageParser` con `ambiguousAsNull`.
  - `LabelLinePicker` nel pacchetto.
  - Nomi dei paesi in più lingue per BR1.7.
- [ ] **Step 6 — Dominio: test.**
  - `packages/estimation/test/`:
    - un test per ogni riga dedicata e per ogni modello;
    - un test che percorre tutta la tabella generata e i vitigni (BR3.9: finestra valida per ogni tipo);
    - coerenza con `WineOrigins` (BR3.5);
    - precedenze (BR3.1, BR3.2, BR3.3), compreso "Chardonnay Napa" con risultato bianco;
    - livello (BR4.1, BR4.2, catalogo non toccato);
    - `effectiveWindow` (BR4.4, FR5.6);
    - estrattore con l'insieme di riferimento di 30 o più testi in 6 lingue (BR1.10, soglie verificate dal test), testi malevoli (NFR3.4) e annate ambigue;
    - strumento (BR3.6: stabile, rifiuti, `--allow-sample`).
  - Benchmark del pacchetto entro i limiti di oggi (NFR4.2); estrattore ≤ 200 ms (NFR4.1); indice ≤ 150 ms (NFR4.3).
  - Copertura del pacchetto ≥ 90%.
- [ ] **Step 7 — Dati: implementazione.** (FR4, FR5, BR4.3–BR4.7, BR3.9, NFR4.8a)
  - `Wine` e `WineFields`: `level`, `windowOverride`; `window` con `denominationKey` e `tablesVersion`.
  - Repository: livello, correzione (un solo `update`), "Ripristina stima" (`FieldValue.delete`).
  - I 6 punti di BR4.5 (`saveNewWine`, `saveEdit`, `ensureEstimates`, `EstimateRefresher`, `recomputeAdjustment`, `WineEstimator.displayed`) passano livello e correzione.
  - Migrazione una tantum in `ensureEstimates`:
    - si scrive un vino alla volta, solo con `canEdit`;
    - offline, le scritture restano in coda;
    - su permesso negato, al massimo 3 tentativi in 3 avvii diversi, con l'evento `estimates_migration_failed`.
  - `WindowAdjuster.labelOf` con la priorità di BR4.7.
- [ ] **Step 8 — Dati: regole e test.** (BR5, NFR1)
  - `firestore.rules` con BR5.1.
  - `test/rules/`: casi validi e non validi per ogni campo nuovo.
  - `test/rules/compat/`: le scritture di oggi, più un aggiornamento parziale su un vino con i campi nuovi.
  - `promote.yml`: `RULES_FEATURES` aggiunge `level-override`.
  - Test del modello e del repository: un test per ognuno dei 6 punti di BR4.5 (NFR4.11).
  - Test della migrazione con l'emulatore Firestore: online, offline, permesso negato, due utenti, 1000 vini (NFR4.7, NFR4.8a).
- [ ] **Step 9 — Canale nativo: implementazione.** (FR2.1, FR2.6, FR2.7, BR2.4–BR2.6, NFR3.1, NFR3.3)
  - `LensIntentLauncher.kt`: `openLensCamera()` (prima l'app Lens, poi Lens nell'app Google, altrimenti `unavailable`) e `clipTimestamp()` (`{timestamp, mime}`, API ≥ 26, senza leggere il contenuto).
  - Il ricevitore di condivisione accetta anche `text/plain` (`kind: 'text'`).
  - Nel manifest: il filtro `text/plain` e `com.google.ar.lens` in `<queries>`.
  - Lato Dart: `LensSession`, controllo al ritorno in primo piano e al primo focus della finestra.
- [ ] **Step 10 — Canale nativo: test.**
  - Robolectric: `LensIntentLauncherTest` (tre esiti, timestamp, API < 26).
  - Test del canale Dart con piattaforma finta: incolla automatico sì e no (timestamp vecchio, oltre 5 minuti, già consumato, MIME diverso, nessun campo → testo scartato, NFR3.7).
  - `tool/check_lens_manifest.sh` esteso, con fixture.
- [ ] **Step 11 — Interfaccia: implementazione.** (FR1.2–FR1.4, FR2, FR4.1–FR4.4, FR5)
  - `AddChoiceScreen` con 4 scelte ("Da Google Lens").
  - `AddWineScreen` ed `EditWineScreen`:
    - `AutofillToolbar`, `FilledFromTextBadge`, `PasteFromLensCard`, `ClearFormDialog`;
    - `WineLevelSelector`, con esempi, "Nessuno" e il suggerimento con le regole di BR4.3;
    - `LevelPreview`.
  - Flusso della foto verso il modulo compilato (BR2.1); testo condiviso nella `HomeShell` (BR2.4).
  - `IdealMomentCard`: `CorrectedBadge`, `CorrectEndYearSheet`, `RestoreEstimateDialog`, `EstimateSourceLine`.
  - `LensInstructionsSheet`.
  - Informazioni: fonte delle denominazioni (NFR5.7).
  - Testi nei 3 file ARB.
- [ ] **Step 12 — Interfaccia: test.** Widget nella matrice (it, en, pt-BR × testo 1,0/2,0 × chiaro/scuro) per ogni componente nuovo, con le regole di `interaction-spec.md`:
  - Pulisci, con e senza conferma;
  - incolla solo nei campi vuoti, nessun dato, vino trovato;
  - Livello: suggerito, accettato al salvataggio, "Nessuno", modifica;
  - correzione: limiti, preselezione, ripristino;
  - "Da Google Lens": tre esiti;
  - condivisione: app chiusa, modulo modificato, testo vuoto;
  - controlli di accessibilità A1–A14.
- [ ] **Step 13 — End-to-end.** (NFR5.4)
  - `integration_test/autofill_test.dart`: testo condiviso o incollato finto che compila il modulo e lo salva.
  - `integration_test/override_test.dart`: correzione di "Consigliato fino al", riapertura e ripristino.
  - Con l'emulatore Firebase, senza Google né Open Food Facts reali.
- [ ] **Step 14 — Configurazione e documentazione.** (NFR3.6, NFR5.6, NFR5.7, FR6, BR6)
  - `docs/release-checklist.md`:
    - download di eAmbrosia e Open Food Facts e generazione delle due tabelle;
    - pubblicazione delle regole prima della build;
    - controllo `estimates_migration_failed`;
    - prova di "Da Google Lens" e dell'incolla automatico sul telefono.
  - `README` della tabella delle denominazioni, con fonti e licenze.
  - `code-summary.md` e `traceability.json`.

### Riapertura da Build and Test: FR2.8 e conferma guidata (FR7)

Stessa metodologia test-after, strato per strato. Il codice di FR2.8 già scritto in Build and Test (`lookupBudget` in `text_autofill.dart`, apertura anticipata della base in `add_wine_screen.dart`) resta com'è; qui si aggiunge l'attesa visibile e si completa.

- [x] **Step 15 — Dominio: analisi dell'etichetta.** (FR7.2, FR7.3, FR7.5, D7, D8, BR7.1–BR7.9, BR7.14–BR7.16, ENT-007–ENT-011)
  - `packages/estimation/lib/src/`: `label_lines.dart` (righe, rumore e alias condivisi con `extractLabelFields`, che non cambia), `label_scoring.dart` (segnali e pesi in centesimi interi), `label_candidates.dart` (fino a 5 candidati per campo chiave, stati certo / incerto / assente, regola del testo breve), `label_words.dart` (parole per la composizione: apostrofi e trattini dentro la parola, filtri, al massimo 120, ordine del testo, limite di 8 parole e 80 caratteri, corrispondenza con le tabelle senza maiuscole e accenti).
  - `analyzeLabelText(text, currentYear:) → LabelAnalysis` esportata dal pacchetto, con `certainFields`, `uncertainFields` e `words`.
- [x] **Step 16 — Dominio: test.** (NFR5.8, NFR4.19, BR7.9)
  - fixture `packages/estimation/test/fixtures/label_reference_set.json` dai 69 testi di `label-reference-set.md`, con le chiavi delle righe delle tabelle e `currentYear: 2026`;
  - test delle soglie di FR7.3: nessun campo certo sbagliato; valore giusto primo ≥ 70% e nei primi 3 ≥ 90%; in media ≤ 2 incerti, massimo 4; soglie di FR1.1 sui campi attesi certi;
  - test di BR7.9 sui 39 testi di `label_texts.json`: nessun campo compilato diverso dall'atteso; il test di oggi di `extractLabelFields` resta com'è;
  - test di parole e composizione (ordine, apostrofi, limiti, tabelle) e dei casi IT01, IT02, FR04, ES10;
  - benchmark: `analyzeLabelText` su 4000 caratteri ≤ 100 ms in CI.
  - Se i pesi vanno ritoccati per far passare l'insieme, si ritoccano solo con l'insieme intero verde, e lo scrivo in `code-summary.md`; le soglie del requisito non si abbassano.
- [x] **Step 17 — Logica dell'app: flusso e guida.** (FR2.8, FR7.1, FR7.4, FR7.6, FR7.7, D9, D11, BR7.10–BR7.21, BR7.23, ENT-012–ENT-014)
  - `TextFields` porta anche `analysis`; `TextAutofillFlow` e `LabelLookupFlow._fieldsOf` usano `analyzeLabelText`; `AddWineInitialValues` riceve l'analisi in memoria per il modulo dalla foto.
  - `lib/label/core/guided_session.dart`: `GuidedSession`, `GuidedAnswer`, `GuidedMemory`, transizioni pure (Sì, No, Modifica, Salta, Componi, ruota, Senza annata, Chiudi, nuovo testo, Pulisci, avviso "Nessun'altra proposta" con scadenza).
  - Dopo la conferma della denominazione: tipo, paese e regione ricalcolati sostituendo solo i valori derivati; Livello suggerito aggiornato se non scelto a mano.
- [x] **Step 18 — Logica: test.** Unit test della macchina a stati (ogni transizione, i casi limite di FR7.7, il conteggio "Domanda N di T", "Senza annata" come risposta, parole riusabili tra campi) e del flusso con analisi (testi brevi come "Barolo Vietti\n2019" compilano come oggi senza guida; tipo non ricavato da una denominazione incerta). (NFR5.8, NFR4.21, NFR4.22)
- [x] **Step 19 — Interfaccia: implementazione.** (FR2.8, FR7.4–FR7.8, D10, BR7.24, BR7.25, NFR4.23, NFR4.24)
  - `PasteFromLensCard` con stato `busy` ("Leggo il testo…", indicatore, secondo tocco ignorato, torna attivo al risultato);
  - `GuidedConfirmSheet` (livello dentro il modulo, non una rotta), `WordPicker`, `VintageWheel` (`ListWheelScrollView`, tocco sull'anno per la tastiera numerica), chip "Conferma guidata" nella barra;
  - nuove chiavi ARB in it, en, pt-BR (`frontend-components.md`); semantica e annunci di A15–A22.
- [x] **Step 20 — Interfaccia: test.** Widget nella matrice (it, en, pt-BR × testo 1,0/2,0 × chiaro/scuro) per scheda, parole, ruota, chip e attesa; tap target e contrasto; Indietro, Chiudi, tocco fuori in "Componi", rotazione e ritorno dal secondo piano, nuovo testo a guida aperta, Pulisci; ricreazione del modulo senza stato (chiusura da parte di Android). Tutti i test di oggi restano verdi senza cambiare le attese (tabella in `functional-spec.md`). (NFR6.2, NFR4.20, NFR4.22, NFR4.23, NFR4.24, NFR5.8)
- [x] **Step 21 — End-to-end.** In `integration_test/autofill_test.dart`, con Firebase Emulator, base e2e o base reale e Open Food Facts finto, senza Google: (NFR5.8, NFR5.9, NFR4.17)
  - guida completa sul testo di Cascina Castlet: Sì, No, Modifica, Salta, composizione con le parole, ruota dell'annata, Indietro e nuovo testo a guida aperta;
  - i 2 secondi con base reale aperta a freddo e Open Food Facts che non risponde (il caso già scritto in Build and Test resta);
  - correzione dell'override del catalogo nel `ProviderScope` annidato, così i casi di oggi usano davvero la base e2e.
- [x] **Step 22 — Documentazione.** `code-summary.md`, `unit-test-instructions.md` e `traceability.json` aggiornati (FR2.8, FR7.x, NFR5.8, NFR5.9, BR7.x, D7–D13); checklist di rilascio: prova della guida e dei 2 secondi sul telefono.

## Decisioni prese qui

- **Il download reale di eAmbrosia e Open Food Facts si fa in Build and Test**, con il tuo OK già dato (a1260ab6). In Code Generation si usano gli estratti di prova. Nessun test scarica nulla.
- **La tabella generata si versiona nel repository**, così la build non dipende dalla rete.
- **Fuori da questo lavoro:** doppione dello Storico e "Annulla", e l'avviso `setState` del `CellarSwitcher`.
- **Riapertura, test esistenti:** durante la costruzione l'orchestratore ha autorizzato il cambio delle attese di alcuni test esistenti (helper `backFromFilledForm` di `label_screens_test` e `label_scope_test`, il test dei 2 secondi di `autofill_form_test`, `label_test.dart` e `autofill_test.dart`). Cambiano per il comportamento approvato FR7.1 / A19 / BR7.8, non per una regressione. L'elenco e i motivi sono in `code-summary.md`; il proprietario li vede al gate.
- **Riapertura:** nessun pacchetto nuovo; nessuna modifica alle regole Firestore (la guida non salva nulla di nuovo), quindi nessuna pubblicazione di regole serve per questa parte.
