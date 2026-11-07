# Monitoring Design — u5-dashboard

Fonti: `security-design.md` di U5 (§2 privacy, §4 affidabilità), `performance-design.md` di U5 (misure), `logical-components.md` di U5, `functional-spec.md` di U5, riepilogo confermato in `infrastructure-design-questions.md`. Il resto dell'app resta monitorato come in U1, con Crashlytics e la checklist mensile in `docs/release-checklist.md` §5.

## 1. Segnali

| Segnale | Origine | Contenuto | Frequenza massima |
|---|---|---|---|
| `dashboard_invalid_window` (errore non fatale) | `DashboardEventLogger` → `ErrorReporter` → Crashlytics | Messaggio fisso `dashboard_invalid_window: estimation_error=invalidWindow`; nessun nome, anno, uid o id | 1 per avvio dell'app |
| Crash ed errori dell'interfaccia | Gestori globali di U1 (`ErrorReporter`) | Come in U1, con i dati sanificati (NFR8.2) | Come in U1 |
| Tempo di avvio fino al Cruscotto | `tool/perf_cold_start.sh` sul telefono | Mediana di 5 avvii a freddo | 1 volta per versione |
| Fluidità dello scorrimento | `integration_test_perf/dashboard_perf_test.dart` | 99° percentile del tempo dei frame | 1 volta per versione |
| Tempo del calcolo sul telefono | Stesso file | Mediana di `compute` su 500 vini, soglia 25 ms (NFR2.2) | 1 volta per versione |
| Tempo del calcolo | `benchmark/dashboard_benchmark.dart` nel job `unit` | Mediana su 500 vini | A ogni push e pull request |

Il Cruscotto non ha metriche di utilizzo: non ci sono Analytics, coerentemente con la scelta di U1 di non raccogliere dati d'uso.

## 2. Soglie e azioni

| Condizione | Dove si vede | Azione |
|---|---|---|
| `dashboard_invalid_window` > 10 eventi **o** > 3 utenti in 7 giorni | Crashlytics, controllo mensile. `ErrorReporter` registra un `SanitizedError` con tipo `DashboardInvalidWindow` e motivo `dashboard_invalid_window`, quindi l'evento si trova cercando `dashboard_invalid_window` tra i non fatali. | Cercare la causa nelle finestre salvate (U2/U4), che producono `window` incoerenti; correggere chi le scrive. Il Cruscotto continua a funzionare (vini "da stimare"). |
| Benchmark > 10 ms (dopo una ripetizione) | Job `unit` rosso | Il merge è bloccato. Si corregge il calcolo; la soglia non si alza. |
| Avvio a freddo sopra 2 s sul telefono di riferimento o sopra 1 s sul telefono del proprietario | Risultato annotato nella checklist di rilascio | La versione non va in produzione finché non rientra, oppure il proprietario accetta lo scostamento per iscritto nella checklist. |
| Scorrimento con 99° percentile sopra il periodo dello schermo | Checklist di rilascio | Come la riga precedente. |
| Nuovo crash dell'interfaccia del Cruscotto | Avviso standard di Crashlytics (email) | Fermare il rilascio graduale se riguarda la produzione; correggere con una nuova versione. |

## 3. Aggiunte alla checklist (`docs/release-checklist.md`)

- **§1-ter Cruscotto (u5-dashboard):** sul telefono, dalla build di test interno:
  - dopo l'accesso compare il Cruscotto, con lista, tre grafici e selettore Tipologia/Regione;
  - una barra di stato porta alla Cantina;
  - si annotano i risultati di `tool/perf_cold_start.sh` (avvio) e di `dashboard_perf_test.dart` (scorrimento e calcolo ≤ 25 ms), con le soglie.
- **§5 Controllo mensile:** una riga per `dashboard_invalid_window`, con la soglia della tabella precedente.
