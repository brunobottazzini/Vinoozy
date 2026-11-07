# Infrastructure Design — u5-dashboard — Domande

Contesto: design non funzionale di U5 approvato (`logical-components.md`, `security-design.md`, `performance-design.md`), `components.md`, `functional-spec.md`, `contract-summary.md`, workflow `ci.yml` e `release.yml` esistenti.

Non ci sono domande aperte. U5 è una schermata dentro l'app, in sola lettura, e non ha risorse cloud proprie. Le decisioni sono riassunte qui sotto per conferma.

## Consolidated Summary Confirmation

- **Infrastruttura:** nessuna risorsa nuova su Firebase o nel cloud, e nessun indice Firestore nuovo. Il Cruscotto usa lo stesso ascoltatore dei vini della Cantina, quindi non aggiunge letture: con 500 vini la prima sincronizzazione costa sempre 500 letture, ben sotto la quota gratuita di 50.000 al giorno. Costo 0 €.
- **Configurazione:** nessun segreto nuovo e nessuna modifica a `release.yml`. La preferenza del selettore Tipologia/Regione resta sul telefono (`shared_preferences`).
- **Controlli automatici in `ci.yml`:**
  - job `analyze`: `tool/check_dashboard_readonly.sh` e il suo test (`tool/check_dashboard_readonly_test.sh`);
  - `tool/check_release_build.sh`: deve anche verificare che il marcatore di misura `VINOOZY_DASHBOARD_READY` sia assente dalla build di rilascio;
  - job `unit`: il benchmark `benchmark/dashboard_benchmark.dart` con `dart run` (soglia 10 ms) e i test del cruscotto dentro la copertura di progetto (80%);
  - job `e2e`: il nuovo `integration_test/dashboard_500_test.dart` e i test dello scheletro aggiornati per passare dalla scheda "Cantina".
- **Misure sul telefono:** `tool/perf_cold_start.sh` (avvio a freddo, mediana di 5 avvii) e `integration_test_perf/dashboard_perf_test.dart` (scorrimento). Si eseguono a mano una volta per versione, con il risultato annotato in `docs/release-checklist.md`. Non girano in CI.
- **Monitoraggio:** l'evento `dashboard_invalid_window` in Crashlytics, al massimo uno per avvio. Il controllo mensile è nella checklist, con una soglia di attenzione di più di 10 eventi o più di 3 utenti in 7 giorni, che indica un problema nei dati delle finestre.
- **Rilascio e rollback:** come per il resto dell'app, cioè test interno e poi produzione graduale. Se il Cruscotto dà problemi, si ferma il rilascio graduale e si pubblica una correzione. Non ci sono dati da migrare, perché il Cruscotto non scrive niente.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
