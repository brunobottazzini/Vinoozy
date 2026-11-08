# Piano del codice — nuova UX di Vinoozy

## Summary

- Builds: paese e regione con bandiere (griglia di 21 paesi e finestra con tutti i 249), "Ho bevuto" con pannello di conferma e voto in un'unica scrittura, nuova palette bordeaux/oro/crema con schede, Dashboard e dettaglio con "Consigliato fino al"
- Touches: `lib/cellar/domain/` (origini, paese), `lib/cellar/data/` (campo `country`, `drink` con voto), `lib/app/theme.dart` e nuovi widget in `lib/app/ui/` e `lib/cellar/ui/`, Dashboard, Storico, `firestore.rules`, file ARB, test e un end-to-end
- Tests: circa 40 test nuovi (unità per origini e dati, regole, widget nelle 3 lingue con testo 1,0/2,0 e tema chiaro/scuro), suite esistente verde, `cellar_test.dart` aggiornato al nuovo flusso

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR3, NFR1–NFR5), approvati con i punti R-01…R-08 della revisione accettati come rischio.
- `inception/refined-mockups/`: `mockups.md`, `vinoozy-mockups.html` (8 schermate, versione 3), `interaction-spec.md` (comprese la finestra con tutti i paesi e "Consigliato fino al"), `design-system-mapping.md`, `accessibility-checklist.md`, e la revisione dei mockup `reviews/review-01.md`.
- `codekb/Vinoozy/`.

## Decisioni prese qui (aperte dalla revisione dei mockup, risolte dall'agente)

- **Tipi di vino (Major 1).** Nel modulo restano gli **8 valori** di `WineType` (`redLight`, `redStructured`, `white`, `rose`, `sparklingClassic`, `sparklingTank`, `sweet`, `fortified`), perché cambiano la stima. Si raggruppano in **5 famiglie grafiche**, ciascuna con colore, icona e nome:
  - Rosso: `redLight`, `redStructured`;
  - Bianco: `white`;
  - Rosato: `rose`;
  - Bollicine: `sparklingClassic`, `sparklingTank`;
  - Dolce: `sweet`, `fortified`.

  Il modulo mostra le 8 scelte con il colore della famiglia.
- **Font dei titoli (Major 2).** Il proprietario ha approvato l'aspetto con i titoli con le grazie. Si usa il **serif di sistema di Android** (`fontFamily: 'serif'`, Noto Serif), che è già sul telefono: niente file nuovi né pacchetti (NFR3). Il risultato è vicino al mockup.
- **Storico (Major 3).** La riga dello Storico mostra la bandiera e la famiglia del tipo **del vino in cantina**, se esiste ancora (anche archiviato). Altrimenti mostra solo nome, annata e voto, come oggi. Le bevute non salvano campi nuovi.
- **Minori:**
  - aree da toccare ≥ 48 dp;
  - griglia con tutti i 21 paesi nell'ordine della specifica;
  - tutte le 20 regioni italiane visibili;
  - "Ho bevuto" disattivato a 0 bottiglie e assente in sola lettura;
  - pannello con "1 → 0";
  - vino senza annata;
  - `WineTypeColors` con i valori scuri;
  - stelle e bordi del tema scuro con contrasto adeguato (stelle ≥ 3:1 come elementi grafici, testo ≥ 4,5:1);
  - icona della scheda Cantina diversa dai calici: `Icons.liquor` per la Cantina, `Icons.wine_bar` per "Ho bevuto".
- **Elenchi enologici.** Le regioni per paese e i nomi canonici li decido io, con le motivazioni in `code-summary.md` (correzione del 2026-11-04 in `project.md`). L'Italia ha le 20 regioni. Gli altri paesi hanno le zone vinicole principali.

## Passi

- [x] **Step 1 — Struttura.** Nuovi file:
  - `lib/cellar/domain/wine_origins.dart`: paesi ISO 3166-1, cioè 249 codici con i nomi it/en/pt-BR, l'emoji della bandiera calcolata dal codice e l'elenco "Rari per il vino"; le regioni dei 21 paesi principali con nome canonico e nomi localizzati; la ricerca senza accenti; il passaggio da denominazione a paese e regione; la regola "regione italiana → Italia";
  - `lib/app/ui/country_flag.dart`;
  - `lib/cellar/ui/origin_pickers.dart` (`CountryPicker`, `AllCountriesSheet`, `RegionPicker`);
  - `lib/cellar/ui/wine_badges.dart` (`StateChip`, `WineTypeBadge`, `WineTypeFamily`);
  - `lib/cellar/ui/wine_card.dart`;
  - `lib/cellar/ui/drink_confirm_sheet.dart`;
  - `lib/cellar/ui/ideal_moment_card.dart`.

  (FR1, FR2, FR3)
- [x] **Step 2 — Esecutore dei test.** Verifico che `flutter test test/cellar test/dashboard test/app` giri sul codice di oggi e registro i comandi in `unit-test-instructions.md`. (NFR2)
- [x] **Step 3 — Dominio: implementazione.** Implemento `wine_origins.dart` come allo Step 1, poi: (FR1.1, FR1.2, FR1.3, FR1.5)
  - `Wine`, `WineInput`, `WineDraft` e `WineFields` ricevono il campo `country`, codice di 2 lettere, facoltativo;
  - `WineValidator` controlla il codice e la regione (1–120 caratteri, spazi esterni tolti);
  - la famiglia di ogni `WineType`.
- [x] **Step 4 — Dominio: test.** Test di unità:
  - ricerca di "Giappone", "Japan" e "Japão", che trovano JP;
  - "marian", che trova MP;
  - 21 paesi in ordine; 20 regioni italiane;
  - Barolo → Piemonte → IT, e almeno altre 2 denominazioni;
  - `origins` di Open Food Facts con paese e senza regione;
  - "regione italiana → Italia" ignorando accenti e maiuscole;
  - cambio di paese che azzera la regione;
  - validazione di `country` e `region`, compreso un valore di 100 caratteri valido;
  - famiglie degli 8 tipi;
  - bandiera di riserva (sigla).

  Comando dello Step 2 verde. (FR1.1–FR1.5, NFR2)
- [x] **Step 5 — Dati e sincronizzazione: implementazione.** (FR1.5, FR2.3, NFR4)
  - `WineRepository` legge e scrive `country`. Un vino vecchio modificato e salvato scrive `country = IT` se la sua regione è italiana.
  - `DrinkingRecordRepository.drink` riceve un `rating` facoltativo, salvato nello **stesso batch** della bevuta. La fascia "in attesa" continua a usare la sonda corretta.
  - `firestore.rules`:
    - `country` entra in `wineFields()`;
    - controllo `country` nullo oppure stringa di 2 lettere maiuscole;
    - `region` resta 1–120;
    - la creazione della bevuta accetta `rating` (`validRating` esiste già).
- [x] **Step 6 — Dati: test.**
  - Test del repository: `country` scritto e letto; `drink` con voto in un solo batch, senza voto e offline (commit aperto).
  - Test delle regole in `test/rules/`: `country` valido e non valido, vino senza `country`, bevuta con voto.
  - Test di compatibilità in `test/rules/compat/`: le regole nuove accettano le scritture della versione di oggi.
  - Comandi: `flutter test test/cellar` e `npm run test:rules`, verdi.

  (FR1.5, FR2.3, NFR2, NFR4)
- [x] **Step 7 — Interfaccia: implementazione.** (FR1–FR3, NFR1, NFR5)
  - **Tema:** palette bordeaux/oro/crema in chiaro e scuro, `StatusColors` aggiornati, `WineTypeColors` come `ThemeExtension`, titoli con `fontFamily: 'serif'`.
  - **Componenti:** `CountryFlag`, `CountryPicker` (griglia di 21 paesi + "Altro paese…"), `AllCountriesSheet` (249 paesi, "Rari per il vino", ricerca), `RegionPicker`, `WineTypeBadge`, `StateChip`, `WineCard`, `DrinkConfirmSheet` (bottiglie "n → n−1", 5 stelle facoltative, "Sì, l'ho bevuta"/"Annulla"), `IdealMomentCard`:
    - mostra "Consigliato fino al …" e "Al meglio dal … al …", la barra e l'avviso "⚠︎ Indicativo…" sempre visibile;
    - ha i casi "finestra passata" e "stima non disponibile".
  - **Schermate:**
    - `AddWineScreen` e `EditWineScreen`: paese, regione e 8 tipi con i colori delle famiglie; compilazione automatica dal catalogo e dall'etichetta;
    - Cantina: `WineCard` e "Aggiungi" come pulsante flottante che si alza con la SnackBar;
    - dettaglio: bandiera grande, `IdealMomentCard`, "Ho bevuto una bottiglia", "Togli una bottiglia senza bevuta" con conferma;
    - `drink_flow.dart`: apre il pannello prima di qualsiasi scrittura e passa il voto a `drink`;
    - Dashboard: riquadro con il totale e quanti vini sono da bere ora, "Da bere presto" con bandiere, `BarChart` con bandiera o icona per riga;
    - Storico: bandiera e famiglia dal vino in cantina se esiste;
    - proposta dell'etichetta: paese, regione e famiglia.
  - **Testi:** tutti i testi nuovi nei 3 file ARB, e `flutter gen-l10n`.
- [x] **Step 8 — Interfaccia: test.** Test di widget nelle 3 lingue, con testo 1,0 e 2,0 e tema chiaro e scuro:
  - `CountryPicker`: 21 bandiere + "Altro paese", con etichette di accessibilità;
  - `AllCountriesSheet`: ricerca "marian" → Isole Marianne Settentrionali;
  - `RegionPicker`: Italia con 20 regioni, Argentina, "Altra regione";
  - `WineCard` per ognuna delle 5 famiglie: icona, nome del tipo, bandiera e stato visibili;
  - `DrinkConfirmSheet`:
    - nessuna scrittura senza conferma;
    - "Annulla" non fa nulla;
    - la conferma con 4 stelle chiama `drink(rating: 4)`;
    - "1 → 0";
  - "Ho bevuto": disattivato a 0 bottiglie, assente in sola lettura, area ≥ 48 dp, icona diversa da quella della scheda Cantina;
  - `IdealMomentCard`: 3 casi con avviso;
  - "Togli una bottiglia senza bevuta" chiede conferma;
  - Dashboard con bandiere;
  - Storico con e senza vino in cantina;
  - contrasto del tema (A1, A8) con il test sulle coppie di colori.

  I test di widget esistenti vanno aggiornati ai nuovi componenti, senza togliere verifiche. Comando `flutter test` verde. (FR1–FR3, NFR1, NFR2)
- [x] **Step 9 — End-to-end.** Si aggiornano gli end-to-end che toccano "Bevuta" (`integration_test/cellar_test.dart`, `concurrent_drink_test.dart`, `e2e_helpers.dart`): "Ho bevuto", poi il pannello, poi "Sì, l'ho bevuta". Si aggiunge una verifica di paese e regione nel modulo. Nessun limite di tempo cambiato. Li esegue Build and Test. (FR1, FR2, NFR2)
- [x] **Step 10 — Configurazione.**
  - Nessun pacchetto nuovo in `pubspec.yaml` (NFR3).
  - Si rigenera `test/coverage_helper_test.dart` per i nuovi file di `lib/`.
  - `RULES_FEATURES`/`requiresRules` di `promote.yml` si aggiorna con la funzione `origin`, così la promozione richiede le regole nuove (R-01).
  - **Escalation al proprietario:** la pubblicazione delle regole nuove su `vinoozy-d6f45` avviene prima di installare la build sul telefono, solo con il suo via.
- [x] **Step 11 — Documentazione e tracciabilità.**
  - `code-summary.md`, con le regioni scelte e le motivazioni;
  - `traceability.json`;
  - `docs/release-checklist.md`: prova sul telefono di bandiere, pannello e "Consigliato fino al";
  - commenti nel codice in inglese.

  (NFR5)

## Tracciabilità

| ID | Passi |
|---|---|
| FR1.1 | 1, 3, 4, 7, 8 |
| FR1.2 | 1, 3, 4, 7, 8 |
| FR1.3 | 3, 4, 7 |
| FR1.4 | 7, 8 |
| FR1.5 | 3, 5, 6 |
| FR2.1 | 7, 8 |
| FR2.2 | 7, 8 |
| FR2.3 | 5, 6, 7, 8, 9 |
| FR2.4 | 7, 8 |
| FR3.1 | 7, 8 |
| FR3.2 | 7, 8 |
| FR3.3 | 7, 8 |
| FR3.4 | 7, 8 |
| NFR1 | 7, 8 |
| NFR2 | 2, 4, 6, 8, 9 |
| NFR3 | 10 |
| NFR4 | 5, 6, 10 |
| NFR5 | 7, 11 |

## Testing Contract

```json
{
  "version": 1,
  "methodology": "test-after",
  "source": "team",
  "ordering": "Per ogni strato testabile (dominio, dati e sincronizzazione, interfaccia) implementiamo prima il codice, poi scriviamo ed eseguiamo i test di quello strato, e passiamo allo strato successivo solo con quei test verdi.",
  "scope": "bugfix",
  "test_strategy": "minimal",
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
    "strategy": "minimal",
    "strategy_volume": [
      "One verifiable test per requirement at the narrowest effective level.",
      "At least one happy-path unit test per component.",
      "Unit tests are the default; a bugfix/security scope floor may require an integration or E2E regression when that is the narrowest level that reproduces the defect."
    ],
    "scope_floor": [
      "Include a targeted regression for the bug or vulnerability.",
      "Keep the existing test suite green."
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
  "input_sha256": "sha256:6b79cc8a219ad6572e15428d8214daccc99fb8e7a8601774190ae13f0f8ebf09",
  "contract_sha256": "sha256:7881c95b5f8395e5513b7e5712e3f7bd09316316a7c3316e39261d1c6b335119"
}
```
