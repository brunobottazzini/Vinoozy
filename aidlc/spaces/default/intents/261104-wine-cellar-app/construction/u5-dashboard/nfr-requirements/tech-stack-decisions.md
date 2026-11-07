# Tech Stack Decisions — u5-dashboard

Fonti: `functional-spec.md` e `frontend-components.md` di U5, `team.md` (Testing Posture, Code Style), riepilogo confermato in `nfr-requirements-questions.md`.

| Area | Scelta | Motivo | Alternative scartate |
|------|--------|--------|----------------------|
| Posizione | `lib/dashboard/`: `domain/` per il calcolo puro di `DashboardSummary`, `ui/` per i widget, `dashboard_providers.dart` per Riverpod | Calcolo testabile senza Flutter; stessa struttura di `lib/cellar/` | Tutto nei widget (difficile da testare e misurare) |
| Grafici | Widget standard di Flutter (`Row`/`Column` con barre proporzionali, `Semantics`), nessuna libreria | Pieno controllo su accessibilità, contrasto e testo ingrandito; nessuna nuova dipendenza; i grafici sono semplici barre | `fl_chart` o simili (accessibilità limitata, dipendenza in più) |
| Stato | Riverpod, già usato: un provider derivato da `winesStreamProvider` e dall'orologio | Ricalcolo solo quando cambiano i dati (NFR2.3) | Calcolo nel `build` dei widget |
| Preferenza del selettore | `shared_preferences`, già usato | Nessuna nuova dipendenza | — |
| Stima | Funzioni di C2 del pacchetto `estimation` (`statusOf`, `WineType.tryParse`, `recognizeDenomination`) | Una sola logica di stima e di tipologia | Copia della logica in U5 |
| Test | `flutter test` per logica e widget nelle tre lingue; test end-to-end in `integration_test/` sull'emulatore con la Firebase Emulator Suite | Regole del team | — |

## Requisiti di qualità

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR7.1 | Copertura delle righe di `lib/dashboard/` almeno 80%, dentro la soglia di progetto dell'80% senza esclusioni. | `tool/check_coverage.sh 80 coverage/lcov.info lib/dashboard/` nel job `unit`. |
| NFR7.2 | Ogni regola BR1.1–BR1.9 ha almeno un test con l'ID nel nome; i widget principali hanno test nelle tre lingue (it, en, pt-BR). | Revisione dei nomi dei test in Code Generation. |
| NFR7.3 | Un test end-to-end in CI verifica che dopo l'accesso la prima schermata sia il Cruscotto e che un vino aggiunto compaia nei conteggi. | Job `e2e` esistente. |
| NFR7.4 | Il benchmark del calcolo (NFR2.2) gira in CI a ogni push. | Passo nel job `unit`, accanto a quello del catalogo. |
| NFR7.5 | I test esistenti di U1 (shell, cantina, sincronizzazione) e il test end-to-end dello scheletro restano verdi dopo le modifiche di U5 alla shell e al modello `Wine`; quelli che controllavano l'elenco come prima schermata si aggiornano per aprire la Cantina dalla barra di navigazione. | Suite completa nel job `unit` e job `e2e`. |
