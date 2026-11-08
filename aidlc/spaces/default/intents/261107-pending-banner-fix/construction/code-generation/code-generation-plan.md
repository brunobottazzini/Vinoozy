# Piano del codice — correzione della fascia "modifiche in attesa"

## Summary

- Builds: stato "in attesa" delle bevute legato al completamento della stessa scrittura, non a `waitForPendingWrites()`
- Touches: `lib/cellar/data/pending_writes_probe.dart`, `lib/cellar/data/drinking_record_repository.dart` e i loro test
- Tests: 10 test di unità (7 della sonda, di cui 2 invariati per l'avvio, e 3 di regressione nel repository per bevuta, annulla e modifica) più 5 corse consecutive dell'end-to-end `cellar_test.dart`

## Contesto

- Requisiti: `inception/requirements-analysis/requirements.md` (FR1, FR1.1–FR1.3, FR2, NFR1–NFR4), approvati con le osservazioni minori R-01, R-02 e R-03 da applicare qui.
- Causa (Reverse Engineering): `_commit` avvia `batch.commit()` senza attenderlo e chiama `_probe.trackWrite()`, che a sua volta chiama `waitForPendingWrites()`. Nel plugin Android le due chiamate girano su thread diversi: se l'attesa arriva per prima finisce subito e spegne la fascia.
- Nessuna unità di lavoro: è una correzione a livello di fase, in un solo blocco.

## Scelta di progettazione

`PendingWritesProbe.trackWrite` riceve il `Future` della scrittura (`write`) e conta le scritture **ancora aperte**:
- la fascia si accende quando il conteggio passa da 0 a 1;
- si spegne quando torna a 0, cioè quando ogni scrittura avviata si è completata, confermata o rifiutata.

Il `Future` di `batch.commit()` si completa solo alla conferma del server, oppure con un errore. Offline resta aperto (verificato nel plugin `cloud_firestore` 7.1.0). Lo stato quindi non dipende più dall'ordine delle chiamate sul canale nativo.

**R-02.** La regola copre ogni ordine di completamento:
- se l'ultima scrittura finisce prima di una precedente ancora aperta, la fascia resta accesa finché anche quella non finisce;
- se una precedente fallisce mentre l'ultima è ancora aperta, la fascia resta accesa per l'ultima.

È una forma più prudente di "la spegne solo l'ultima iniziata" (FR1.2). Poiché Firestore conferma le scritture nell'ordine in cui sono state accodate, nel caso normale i due criteri coincidono.

**Alternativa scartata.** Tenere un "token" e far spegnere la fascia solo al completamento dell'ultima scrittura. Con il token, una scrittura precedente ancora aperta potrebbe restare senza fascia se il completamento arrivasse fuori ordine sul canale nativo, che è proprio la classe di problema da eliminare.

**Errori.** Un errore della scrittura spegne la sua parte del conteggio. Il report resta quello di oggi in `_commit` (`onError`, sessione scaduta, motivo fisso), senza un secondo report `pending_probe_failed` per la stessa scrittura (FR1.3).

**Avvio (FR2).** `checkAtStartup` resta com'è: `waitForPendingWrites()` con il margine di 300 ms. Usa un proprio stato separato. La fascia è accesa se c'è almeno una scrittura aperta **oppure** il controllo d'avvio è in attesa.

## Passi

- [x] **Step 1 — Struttura.** Nessun file nuovo nell'app. Cambiano solo i file indicati sotto. (FR1)
- [x] **Step 2 — Esecutore dei test.** Verifico che il comando di unità giri prima delle modifiche: `flutter test test/cellar/data/pending_writes_probe_test.dart test/cellar/data/drinking_record_repository_test.dart` (verde sul codice di oggi). (NFR1)
- [x] **Step 3 — Dati e sincronizzazione: implementazione.** (FR1, FR1.1, FR1.2, FR1.3, FR2, NFR3, NFR4)
  - `lib/cellar/data/pending_writes_probe.dart`: `Future<void> trackWrite(Future<void> write)` incrementa il conteggio e si accende. Al completamento o all'errore di `write` decrementa il conteggio e, a 0, spegne la fascia. Non chiama mai `waitForPendingWrites()`. Gli errori di `write` non vengono riportati qui (li riporta `_commit`). `checkAtStartup` resta invariato nel comportamento, con il suo stato separato. `isPending` è vero se il conteggio è sopra 0 o se il controllo d'avvio è in attesa. Commenti aggiornati: tolto il riferimento a "delete", che non usa la sonda.
  - `lib/cellar/data/drinking_record_repository.dart` (`_commit`): `unawaited(_probe.trackWrite(write))` con il `Future` della stessa scrittura, invece di `trackWrite()`. Nessun altro cambiamento.
  - `lib/app/bootstrap.dart`: nessun cambiamento, perché la costruzione della sonda resta uguale (`waitForPendingWrites` serve ancora all'avvio).
- [x] **Step 4 — Dati e sincronizzazione: test dopo l'implementazione.** (FR1.1–FR1.3, FR2, NFR1)
  - `test/cellar/data/pending_writes_probe_test.dart`, riscritto per il nuovo contratto di `trackWrite` (R-03; i 2 test di `checkAtStartup` restano invariati):
    1. una scrittura aperta tiene la fascia accesa e si spegne al completamento; `waitForPendingWrites` non viene chiamato (FR1.1);
    2. due scritture, la prima si completa per prima: resta accesa fino alla seconda (FR1.2);
    3. due scritture, la seconda si completa per prima: resta accesa fino alla prima (FR1.2, R-02);
    4. la scrittura fallisce: la fascia si spegne e nessun `pending_probe_failed` (FR1.3);
    5. la prima fallisce mentre la seconda è aperta: resta accesa fino alla seconda (FR1.3, R-02);
    6. e 7. (invariati) avvio entro 300 ms senza fascia; avvio oltre 300 ms con fascia fino alla conferma (FR2).
  - `test/cellar/data/drinking_record_repository_test.dart`: 3 test di regressione dell'**ordine inverso**, uno per ciascun chiamante di `_commit` (R-01). `BatchRecorder.commitWith` tiene aperto il commit e `waitForPendingWrites` della sonda si completa **subito**, come nella corsa reale:
    8. `drink` → `isPending` vero finché il commit è aperto, falso dopo il suo completamento (FR1.1);
    9. `undo` → come sopra (FR1.1);
    10. `updateRecord` → come sopra (FR1.1).
    Questi 3 test falliscono con il codice di oggi: l'attesa immediata spegne la fascia (NFR1).
  - Comando: quello dello Step 2, verde.
- [x] **Step 5 — Logica, API, interfaccia.** Non si applica: nessun cambiamento in questi strati. La fascia (`OfflineBanner`, `SyncStatusTracker`, `syncStatusProvider`) resta invariata, e i suoi test (`test/u1/sync/sync_status_test.dart`, `test/cellar/cellar_providers_test.dart`) devono restare verdi.
- [x] **Step 6 — Suite e copertura.** (NFR1, NFR4)
  - `dart format --output=none --set-exit-if-changed .` e `flutter analyze --fatal-infos`;
  - `flutter test --coverage`, tutta la suite verde;
  - `tool/check_coverage.sh 80 coverage/merged.lcov.info` dopo aver unito la copertura del pacchetto di stima (soglia del progetto, team.md);
  - `tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/`: soglia di U4 (u4-cellar NFR7.1, già controllata da `ci.yml`). È questa la fonte della soglia su `lib/cellar/` (R-03).
- [ ] **Step 7 — End-to-end.** `integration_test/cellar_test.dart` in **5 corse consecutive** sull'emulatore Android a 4 core con la Firebase Emulator Suite, poi la cartella `integration_test` completa più `tool/e2e_force_stop.sh` una volta. Nessun limite di tempo cambiato, nessuna modifica al test (NFR2). Lo verifica Build and Test.
- [x] **Step 8 — Configurazione.** Nessuna: niente dipendenze, regole, indici o workflow cambiati (NFR3).
- [x] **Step 9 — Documentazione e tracciabilità.** `code-summary.md`, `traceability.json` e commenti nel codice in inglese (NFR4).

## Tracciabilità

| ID | Passi |
|---|---|
| FR1 | 3, 4 |
| FR1.1 | 3, 4 (test 1, 8, 9, 10), 7 |
| FR1.2 | 3, 4 (test 2, 3) |
| FR1.3 | 3, 4 (test 4, 5) |
| FR2 | 3, 4 (test 6, 7) |
| NFR1 | 2, 4, 6 |
| NFR2 | 7 |
| NFR3 | 3, 8 |
| NFR4 | 3, 6, 9 |

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
