# Infrastructure Specification — u5-dashboard

Fonti:
- `logical-components.md`, `security-design.md` e `performance-design.md` di U5;
- `components.md` (inception), `functional-spec.md` di U5, `contract-summary.md`;
- workflow `.github/workflows/ci.yml` e `release.yml`;
- riepilogo confermato in `infrastructure-design-questions.md`.

Per un'unità di interfaccia il design non funzionale non ha file separati `scalability-design.md`, `reliability-design.md` e `observability-design.md`:
- l'affidabilità e l'unico evento osservabile stanno in `security-design.md` (§2 e §4);
- la scala è fissata da `performance-design.md`, cioè 500 bottiglie per cantina.

## 1. Risorse

U5 è una schermata dell'app Android, in sola lettura (NFR4.1). **Non aggiunge risorse cloud.**

| Risorsa | Cambia? | Motivo |
|---|---|---|
| Progetto Firebase `vinoozy-d6f45` (Auth, Firestore `europe-west8`, App Check, Crashlytics) | No | Il Cruscotto legge i vini con l'ascoltatore già usato dalla Cantina (`winesStreamProvider`, C3). |
| Regole Firestore (`firestore.rules`) | No | Nessuna nuova lettura o scrittura: le regole di U1 sui vini della cantina valgono già. |
| Indici Firestore (`firestore.indexes.json`) | No | Nessuna query nuova: conteggi, ordinamenti e raggruppamenti si fanno sul telefono (`DashboardCalculator`). |
| Segreti GitHub e ambienti (`play-internal`) | No | Nessuna configurazione nuova. |
| `release.yml` | No | La build firmata e la pubblicazione restano quelle di U1. |
| Archiviazione sul telefono | Sì, piccola | Una chiave `dashboard.breakdownMode` in `shared_preferences` (pochi byte), cancellata con i dati dell'app. |

## 2. Costi e quote (piano Spark)

- **Letture Firestore:** il Cruscotto e la Cantina condividono lo stesso flusso, perché il provider con parametro e `IndexedStack` tengono un solo ascoltatore. Il Cruscotto quindi non aggiunge letture.
  - Una cantina di 500 vini costa 500 letture alla prima sincronizzazione su un telefono nuovo, poi solo i documenti cambiati.
  - Il limite gratuito è di 50.000 letture al giorno.
- **Crashlytics:** gratuito; al massimo un evento `dashboard_invalid_window` per avvio.
- **CI:** il test end-to-end con 500 vini usa l'emulatore Firebase sul runner di GitHub Actions e aggiunge circa 1 minuto al job `e2e` (`cicd-pipeline.md` §1).
  - Se il repository è pubblico, i minuti sono illimitati.
  - Se è privato, il piano free include 2.000 minuti al mese sui runner Linux. Il minuto in più va contato in quel budget, che si controlla in GitHub sotto Settings → Billing.
- **Totale:** 0 €/mese. L'avviso di spesa a 1 € (C6) resta invariato.

## 3. Ambienti

| Ambiente | Dati del Cruscotto | Note |
|---|---|---|
| Locale e CI | Emulatori Firebase (`demo-vinoozy`) | `dashboard_500_test.dart` crea i 500 vini con la REST di amministrazione dell'emulatore. |
| Misure sul telefono | Emulatori Firebase sul computer, raggiunti con `adb reverse` e `EMULATOR_HOST=127.0.0.1` | Solo build di profilo con `PERF=true`, mai sul progetto di produzione (`performance-design.md`). |
| Test interno e produzione (Google Play) | Progetto `vinoozy-d6f45` | Nessuna differenza rispetto a U1. |

## 4. Sicurezza

- Nessun nuovo permesso Android, nessuna nuova chiamata di rete e nessun nuovo segreto.
- Il segnale della misura (`VINOOZY_DASHBOARD_READY`) esiste solo nelle build con `--dart-define=PERF=true`. `tool/check_release_build.sh` verifica che manchi dalla build di rilascio, come per gli strumenti E2E (`cicd-pipeline.md` §1).
- Crashlytics riceve solo un messaggio fisso, attraverso l'uscita unica di U1 (`ErrorReporter`), senza dati del vino (NFR8.1).

## 5. Rilascio e rollback

- Il Cruscotto esce con la build normale dell'app: merge su `main`, poi test interno, poi produzione graduale con approvazione del proprietario.
- **Rollback:** si ferma il rilascio graduale in Play Console e si pubblica una versione corretta. Non ci sono dati da migrare né da ripristinare, perché il Cruscotto non scrive niente nel cloud. La preferenza sul telefono è facoltativa: se è assente o non valida, vale "Tipologia".
