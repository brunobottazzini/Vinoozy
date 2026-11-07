## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** 2026-11-06
**Iteration:** 1
**Verdict Dictated:** no

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u5-dashboard/infrastructure-design/cicd-pipeline.md > §1, riga `unit` con `tool/check_release_build.sh` esteso | Il controllo positivo con `PERF=true` è descritto come una build in più. Oggi `tool/check_release_build.sh` fa già due `flutter build appbundle --release` (una senza define, una con `E2E=true`), preceduti da `flutter clean`. Il job `unit` in `ci.yml` ha `timeout-minutes: 15` e contiene già test con copertura, pacchetto `estimation`, benchmark del catalogo e queste due build. Una terza build completa non ha nessuna stima di durata nel design. Se il job sfora, tutti i merge restano bloccati. | Far verificare il controllo positivo di `VINOOZY_DASHBOARD_READY` nella build `E2E=true` già esistente, passando anche `PERF=true` (`--dart-define=E2E=true --dart-define=PERF=true`), senza una terza build. In alternativa, indicare una stima misurata della durata e alzare il `timeout-minutes` del job. Descrivere anche che lo script passa da un solo `marker` a una lista di marcatori, ciascuno con il proprio controllo negativo e positivo. | New |
| R-02 | Major | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u5-dashboard/infrastructure-design/monitoring-design.md > §1 Segnali e §3 Aggiunte alla checklist | Il requisito NFR2.2 chiede anche una misura del calcolo sul telefono (sotto 25 ms, requisito 50 ms). Né la tabella dei segnali né la checklist §1-ter la prevedono: ci sono solo il benchmark in CI (10 ms su `ubuntu-latest`) e le due misure di avvio e scorrimento. Il design non coincide con il requisito approvato. | Aggiungere un segnale e una riga della checklist per la misura del calcolo sul telefono, con la soglia di 25 ms e chi la esegue. Oppure dichiarare esplicitamente che NFR2.2 si considera coperto dalla sola misura di avvio (NFR2.1) e dal benchmark in CI. | New |
| R-03 | Minor | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u5-dashboard/infrastructure-design/cicd-pipeline.md > §1, riga `e2e` | Si dice che `flutter test integration_test` esegue anche `dashboard_500_test.dart` nello stesso job, ma non si dice come si isola dagli altri test. `flutter test integration_test` esegue i file in ordine alfabetico: `dashboard_500_test.dart` va prima di `u1_skeleton_test.dart`, quindi 500 vini in emulatore possono restare nella cantina quando partono i test dello scheletro. `integration_test/e2e_helpers.dart` ha `clearEmulators()` e `clearPhone()`. Anche la stima di "1–2 minuti" in più per 500 scritture REST non è motivata. L'attuale `timeout-minutes: 45` basta, ma la stima è un'ipotesi. | Scrivere che il test chiama `clearEmulators()` e `clearPhone()` all'inizio e alla fine, e ripulisce i vini. Indicare che la durata aggiunta è una stima da verificare alla prima esecuzione in CI. | New |
| R-04 | Minor | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u5-dashboard/infrastructure-design/infrastructure-specification.md > §2 Costi e quote, riga CI | "Gratuito per un repository nel piano free" vale senza limiti solo per un repository pubblico. Per un repository privato i minuti di GitHub Actions sono limitati ogni mese. Il design non dice se il repository è pubblico e non stima i minuti aggiunti. | Specificare la visibilità del repository e che i minuti aggiunti (benchmark più eventuale build in più) restano nel limite. Oppure togliere l'affermazione "gratuito" generica. | New |
| R-05 | Minor | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u5-dashboard/infrastructure-design/monitoring-design.md > §2, riga `dashboard_invalid_window` | La soglia usa un filtro Crashlytics per "tipo `DashboardInvalidWindow`", ma il messaggio è una stringa fissa passata attraverso `ErrorReporter` (`lib/app/error_reporter.dart`, `ErrorSink.recordError` con `fatal: false`). Non è detto quale oggetto errore arrivi a Crashlytics, e quindi su che cosa si filtra. Inoltre la soglia "> 3 utenti" è poco significativa per un'app con pochissimi utenti. | Indicare l'oggetto errore e il campo di Crashlytics su cui si filtra (per esempio il tipo dell'errore o il motivo fisso). Ricordare che la soglia sugli utenti vale solo con più di pochi utenti. | New |

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| Lettura di `.github/workflows/ci.yml` | I job `analyze`, `unit` ed `e2e` esistono. In `analyze` ci sono solo `tool/check_off_config.sh` e il controllo sulla configurazione di produzione. | I passi nuovi in `analyze` e `unit` sono realizzabili. Gli script con `grep` e `find` non richiedono altro sul runner. Il benchmark dopo `catalog_benchmark.dart` ha lo stesso schema. |
| Lettura di `tool/check_release_build.sh` | Usa un solo `marker`, con controllo negativo e positivo (`E2E=true`). | L'estensione si può fare, ma richiede più marcatori (vedi la prima finding). |
| Lettura di `tool/check_coverage.sh` | Accetta già un terzo argomento con il prefisso del percorso. | `check_coverage.sh 80 coverage/lcov.info lib/dashboard/` è valido. |
| Lettura di `lib/cellar/domain/wine.dart` | Importa solo `firestore_values.dart` e `quantity.dart`. | Non ho aperto gli altri due file, né verificato che siano senza Flutter. Il benchmark con `dart run` dovrebbe poter importare `wine.dart`, come `catalog_benchmark.dart` importa il suo nucleo puro. |
| Controllo `docs/release-checklist.md` | Esistono le sezioni 1, 1-bis, 2, 3, 4, 5. | La nuova sezione `§1-ter` si inserisce senza conflitti. |
| Controllo di `lib/dashboard/` | Non esiste ancora (design). | Nessuna verifica del codice possibile. I controlli sono giudicati dal solo testo. |

### Summary

Il design è implementabile: nessuna risorsa cloud nuova, nessun contrasto con il design non funzionale approvato, rollback e soglie concrete. Le due questioni Major riguardano il tempo del job `unit` (la terza build di rilascio) e la misura di NFR2.2 sul telefono, che manca. Con al massimo due Major e nessun Critical il verdetto resta READY. Conviene correggerle al gate.
