# Piano del codice — profili di stile e classificazione automatica

## Summary

- Builds:
  - i 24 profili dello studio e la mappa di tutte le 5946 combinazioni (Excel come base, con le correzioni approvate);
  - finestre in mesi dalla sboccatura o dall'imbottigliamento, valori "—" senza fine inventata, "Stile da confermare";
  - classificazione automatica di Tipologia, Livello e Stile (modulo, etichetta, base offline) senza appiattire i tipi;
  - campi nuovi del vino, regole Firestore, migrazione una tantum dei vini in cantina;
  - modulo con Stile e data di sboccatura/imbottigliamento; dettaglio, cantina e cruscotto in mesi.
- Touches:
  - `packages/estimation/` (profili, mappa, `classifyWine`, finestra con unità, stato in mesi, qualifiche);
  - `tool/build_wine_db.dart` (classificazione della base, manifest), `assets/wine_db/`, `tool/data/study/study_db.json` (studio convertito dall'Excel);
  - `lib/cellar/` (modello, repository, migrazione, stimatore, modulo, dettaglio, cantina), `lib/dashboard/`, `lib/catalog/`;
  - `firestore.rules`, `test/rules/`, `promote.yml`, file ARB, checklist.
- Tests: profili e mappa (5946 casi da fixture), Revisione 60, campione di 100 vini, mesi e stati, migrazione con emulator, regole e compatibilità, widget nella matrice di accessibilità, 2 e2e; suite esistente verde.

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR4, NFR1–NFR6; decisioni 2c43a871 e 141399c1: Excel come sorgente con le correzioni approvate).
- `inception/refined-mockups/` (S1–S6, `interaction-spec.md`).
- `construction/functional-design/` (BR1–BR11, D1–D9, ENT-101–ENT-112, `profile-map.json`, `classification-sample.json`).
- `construction/nfr-requirements/`.
- Studio `~/Downloads/vinoozy-handoff-valutazione-vini.xlsx`.

Non c'è Units Generation: un'unica iterazione.

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

Gli strati: dominio (pacchetto `estimation`), dati (modello, repository, regole, migrazione, tool della base), interfaccia. Nessuna API esterna.

## Passi

- [ ] **Step 1 — Struttura.** Nel pacchetto: `profiles.dart` (24 profili, D1), `classifier.dart` (`classifyWine`), `month_window.dart`, e `generated/profile_map.g.dart` generato da `tool/build_profile_map.dart`. Lo studio Excel si converte **una volta** in una base di dati strutturata nel repository, `tool/data/study/study_db.json` (profili, 5946 combinazioni con tutte le colonne dello studio, fonti, data e versione dello studio), con uno script di conversione fuori dall'app; nessun CSV. Il generatore legge la base di dati e applica le regole di BR2. Così lo studio resta la sorgente della verità: se viene aggiornato si riconverte e si rigenera. (D1, D9, decisioni 141399c1, 2ecb8ec8, 6e07a42d)
- [ ] **Step 2 — Esecutore dei test.** Verifico i comandi di `unit-test-instructions.md` sul codice di oggi. (NFR4.5)
- [ ] **Step 3 — Dominio: profili, mappa, finestra in mesi.** (FR1, BR1, BR2, BR5, BR6)
  - profili con decorrenza, unità, picco e fine facoltativi; precedenza a 4 passi; correzioni di tipo; qualifiche come varianti;
  - `DrinkingWindow` con unità e campi facoltativi (D2), stato per mese (BR6.1, BR6.3), "—" senza fine;
  - Livello assoluto come oggi, senza doppio conteggio (BR4.1–BR4.4); `estimationTablesVersion` = 3.
- [ ] **Step 4 — Dominio: classificazione.** `classifyWine` (Tipologia, Livello, Stile, con provenienza): precedenza qualifica > profilo > parole > vitigno > tipo della base; parole di dosaggio mai sopra la denominazione; nessun appiattimento a 5 famiglie. (FR2, BR3, BR4)
- [ ] **Step 5 — Dominio: test.** Fixture `profile-map.json` (5946 casi: profilo, decorrenza, unità, valori, passo) e confronto tabella generata = fixture; Revisione 60; `classification-sample.json` con le soglie di NFR4.3; mesi e stati; Livello (Barolo "Buono" 8/15/30); Lambrusco Dolce, Crémant Doux, Prosecco Dolce, Rosa dei Venti; Kabinett/Spätlese; Pauillac. Benchmark. (NFR4.1–NFR4.3, NFR3.1, NFR3.2)
- [ ] **Step 6 — Dati: modello, repository, regole.** Campi nuovi (ENT-101…): `style`, `typeSource`, `levelSource`, `styleSource`, `agingStartMonth`, finestra con unità, `migrationVersion`; `wineFields()`; regole Firestore con elenchi chiusi e confronto dei mesi come intero (BR10); `RULES_FEATURES` `style-profiles`. (FR3.3, NFR2.1–NFR2.4)
- [ ] **Step 7 — Dati: migrazione e base.** Migrazione per vino in transazione con `updatedAt`, solo campi vuoti, offline non parte, integrità (BR7, NFR4.4, NFR4.6, NFR4.9); `tool/build_wine_db.dart` classifica la base con `classifyWine` e scrive `classifiedTypeShare` nel manifest; rigenerazione della base dall'export in `.cache/`. (FR2.5, FR4, NFR3.3, NFR3.5, NFR6.1)
- [ ] **Step 8 — Dati: test.** Regole e compatibilità (`style_profiles.rules.test.mjs` + `compat/`), repository, migrazione con Firestore emulator (online, offline, interruzione, concorrenza, integrità), tool della base (quota ≥ 84%). (NFR2, NFR4.3, NFR4.4, NFR4.6–NFR4.9)
- [ ] **Step 9 — Interfaccia: implementazione.** Chip dello Stile, "✦ suggerito" e "Ripristina suggerimento", campo mese/anno con la ruota, avviso "Stile da confermare", finestra in mesi in dettaglio, cantina e cruscotto, riquadro "Da confermare", catalogo senza appiattimento, Informazioni con la quota classificata; testi nei 3 ARB. (FR3, FR2.4, NFR6.1)
- [ ] **Step 10 — Interfaccia: test.** Widget nella matrice (3 lingue × testo 1,0/2,0 × chiaro/scuro) con `meetsGuideline` (NFR5.2), validazione della data (NFR4.8), annuncio della stima aggiornata. Suite esistente verde.
- [ ] **Step 11 — End-to-end.** Modulo con Stile e sboccatura (Champagne); vino "Stile da confermare" e scelta dello stile; migrazione su emulator. (NFR4.5)
- [ ] **Step 12 — Configurazione e documentazione.** `code-summary.md`, `unit-test-instructions.md`, `traceability.json`; checklist di rilascio (pubblicare le regole `style-profiles` prima della build, con l'OK del proprietario).
- [x] **Step 13 — Correzione da Build and Test (loop-back 1).**
  - **Generazione della base più veloce (NFR3.3).** In `tool/build_wine_db.dart`, le righe dell'export senza indizi di vino si scartano con un controllo sul testo grezzo prima di `jsonDecode`. Il controllo deve essere conservativo: non deve mai scartare una riga che oggi entra nella base.
  - **Stessa base di prima.** La base rigenerata resta identica a quella attuale: stessi vini, stesso `classifiedTypeShare`, e `check_wine_db_release.sh` deve passare. Va misurato il tempo sull'export completo, con obiettivo ≤ 2 minuti. Se il controllo cambiasse la base, ci si ferma e si riporta.
  - **Test del filtro.** Con un piccolo export di prova, le righe di vino passano e quelle non di vino vengono scartate con lo stesso esito di prima.
  - **Migrazione di 500 vini (NFR3.7).** Nuovo test "NFR3.7 500 wines are computed in under 2.5 s" accanto a quello dei 200 vini in `test/cellar/estimates_migration_test.dart`.
  - **Verifiche come per gli altri passi.** Formattazione, analisi, suite completa con copertura (soglie invariate), `check_wine_db_release.sh`. Nessuna modifica alle regole Firestore.

## Decisioni prese qui

- **Lo studio entra nel repository come base di dati JSON** (`tool/data/study/study_db.json`, convertita dall'Excel), non come CSV, e la mappa si genera da lì con le regole di BR2 (Excel come sorgente della verità, decisioni 141399c1, 2ecb8ec8, 6e07a42d). L'app non carica la base a runtime: le tabelle restano costanti nel codice, veloci e offline.
- **Nessun pacchetto nuovo.**
- **Le regole Firestore cambiano**: vanno pubblicate sul progetto reale prima di installare la build, solo con l'OK del proprietario.
