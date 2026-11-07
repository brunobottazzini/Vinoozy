# Tech Stack Decisions — u2-estimation

Fonti: `unit-of-work.md` (U2: pacchetto Dart usato dall'app), `contract-summary.md` (C2), `team.md` (Testing Posture, Code Style), risposte in `nfr-requirements-questions.md`.

## Scelte

| Area | Scelta | Motivo | Alternative scartate |
|------|--------|--------|----------------------|
| Linguaggio | Dart puro, stessa versione dell'SDK dell'app (`.flutter-version`) | C2: libreria Dart senza Flutter né Firebase | Logica nella funzione cloud (non funzionerebbe offline, FR4.7) |
| Posizione | Pacchetto locale `packages/estimation` nello stesso repository, usato dall'app con una dipendenza `path` | Un solo repository e una sola CI; versioni sempre allineate | Repository separato (più manutenzione per una persona sola) |
| Tabelle enologiche | Costanti Dart dentro il pacchetto (Q1): una correzione esce con un nuovo aggiornamento dell'app | Funziona offline, costo zero, ogni modifica passa dai test in CI | Tabelle scaricate da Firestore (servirebbero una copia di riserva, controlli sui dati e letture in più) |
| Formato delle tabelle | Una lista tipizzata per le denominazioni e una per le tipologie, in un file `tables.dart` separato dal calcolo | Si correggono senza toccare la logica; i test le controllano tutte | JSON caricato a runtime (meno controlli del compilatore) |
| Test | `package:test` con test a tabella; benchmark con `package:benchmark_harness` | Nessuna dipendenza da Flutter; esecuzione veloce | `flutter_test` (inutile per codice puro) |
| Copertura | Almeno 90% delle righe del pacchetto, **misurata da sola** (`dart test --coverage` del pacchetto, convertita in lcov con `package:coverage`) e controllata con `tool/check_coverage.sh 90`; tutti i file di `lib/` del pacchetto contano, comprese le tabelle (`tables.dart`), senza esclusioni. Lo stesso lcov si unisce poi a quello dell'app per la soglia di progetto dell'80% | Logica centrale del prodotto (team.md: unit test sulla stima e sulla fiducia); il progetto resta all'80% senza esclusioni (NFR7) | Solo la soglia di progetto |
| Qualità | `dart format`, `dart analyze --fatal-infos` con `lints/recommended` | team.md (Code Style) | — |
| Dipendenze | Nessuna dipendenza di produzione; di sviluppo solo `test`, `lints`, `benchmark_harness`, `coverage` | NFR4.1; meno superficie da aggiornare | — |

## Requisiti di qualità

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR7.1 | Il pacchetto ha copertura delle righe almeno del 90%, misurata da sola su tutto `lib/` del pacchetto (tabelle comprese), e contribuisce alla copertura di progetto dell'80% senza esclusioni. | Gate dedicato: passo `estimation` nel job `unit` della CI del progetto. La CI è condivisa e definita da U1; U2 aggiunge un passo e non cambia i controlli esistenti, come prevede la regola delle risorse condivise. Il passo fallisce sotto il 90%. |
| NFR7.2 | Ogni riga delle tabelle ha un test: per ogni denominazione si verifica inizio ≤ picco ≤ fine, da 3 a 5 abbinamenti con chiavi valide e il riconoscimento dei suoi alias. | Test a tabella generati dalle costanti. |
| NFR7.3 | I criteri AC4.2.1 e AC4.2.2 e i casi limite di `functional-spec.md` sono test espliciti con `today` fissato. | Test nominati con l'ID del criterio. |
| NFR7.4 | Formattazione e analisi del pacchetto passano in CI prima del merge. | Job `format` e `analyze` estesi al pacchetto. |
| NFR7.5 | Il benchmark di NFR2.1 e il controllo di purezza di NFR4.1 e NFR4.4 girano in CI a ogni push. | Passi dedicati nel job `unit`. |
