# CI/CD Pipeline — u3-wine-catalog

Fonti: `security-design.md` §2, `performance-design.md`, `logical-components.md` (NFR Design di U3), `tech-stack-decisions.md` (NFR7.1–NFR7.4), `functional-spec.md` di U3, `components.md`, `contract-summary.md`, workflow `ci.yml` e `release.yml` esistenti, riepilogo confermato in `infrastructure-design-questions.md`. Per un modulo dentro l'app non esiste un `performance-design.md` di servizio separato dal resto: le soglie vengono dal `performance-design.md` di U3.

U3 viaggia dentro l'app: non ha una pipeline propria. Aggiunge passi ai job esistenti di `ci.yml` e non cambia `release.yml`.

## 1. Controlli in CI (`ci.yml`)

| Job | Passo nuovo | Comando | Requisito | Blocca il merge se |
|---|---|---|---|---|
| `analyze` | Configurazione di OFF | `tool/check_off_config.sh` | NFR4.3, NFR5.1, NFR7.3 | contatto committato (anche nei workflow), email in un file `.dart` di `lib/` (escluso `lib/l10n/`), import di `cloud_firestore` o `cloud_functions` in `lib/catalog/`, import di Flutter, `path_provider` o Firebase in `lib/catalog/core/` |
| `unit` | Test del catalogo | Già compresi in `flutter test --coverage`, con il file di copertura unito all'80% | NFR7.1 | test rossi o copertura di progetto sotto l'80% |
| `unit` | Copertura del solo catalogo | `tool/check_coverage.sh 80 coverage/lcov.info lib/catalog/` (terzo argomento facoltativo, nuovo: conta solo i file con quel prefisso) | NFR7.1 | copertura delle righe di `lib/catalog/` sotto l'80% |

NFR7.2 (un test per ogni regola, con l'ID nel nome) non è un passo di CI: lo verifica la revisione del codice in Code Generation.
| `unit` | Benchmark del catalogo | `dart run benchmark/catalog_benchmark.dart` | NFR1.1, NFR1.2, NFR1.4, NFR1.5, NFR7.4 | una soglia superata due volte di fila (`exit(1)`) |

Le nuove funzioni di catalogo del pacchetto `estimation` (C2) passano dal job `estimation` già esistente (test, copertura al 90%, purezza). La cartella `benchmark/` alla radice dell'app è nuova e si crea in Code Generation. I job `format` ed `e2e` non cambiano. Nei test end-to-end OFF è spento perché manca il contatto, quindi non c'è nessuna chiamata esterna. Le azioni restano quelle già fissate per hash di commit.

## 2. Rilascio (`release.yml`)

- Nessuna modifica al file. Il catalogo è compilato nel bundle firmato come il resto dell'app.
- `OFF_CONTACT` entra nella configurazione di produzione tramite il segreto esistente (`infrastructure-specification.md`, Configurazione). Finché il proprietario non lo aggiunge, la produzione funziona con il solo catalogo interno.

## 3. Prima della produzione

Righe nuove in `docs/release-checklist.md`:
- `OFF_CONTACT` presente nel segreto di produzione, oppure scelta consapevole di pubblicare con OFF spento.
- Informativa privacy e scheda "Sicurezza dei dati" di Google Play aggiornate per l'invio del testo cercato e dei codici a barre a Open Food Facts.
- Voce di attribuzione a Open Food Facts presente nella schermata delle informazioni.
- Misure sul telefono di `suggestWines` e `matchLabelText` (25 ms e 50 ms).

## 4. Rollback

- **Problema nel codice del catalogo:** come per l'app. Si ferma il rilascio graduale e si pubblica una correzione che passa dal test interno.
- **Problema di OFF** (servizio cambiato, risposte sbagliate, blocchi): si toglie `OFF_CONTACT` dal segreto `FIREBASE_PROD_DEFINES_JSON_B64` dell'ambiente GitHub `play-internal`. Il segreto con lo stesso nome a livello di repository non conta, perché quello dell'ambiente lo sovrascrive. Poi serve una **nuova versione dell'app**: `release.yml` parte solo dopo un `ci` riuscito su un push in `main`. Un push qualsiasi su `main` (anche solo un aggiornamento di `docs/release-checklist.md`) produce un nuovo `versionCode` e lo pubblica sul test interno; la produzione segue la promozione manuale e graduale abituale. Non cambia il codice, ma non è un interruttore remoto: i telefoni già aggiornati continuano a usare OFF finché non installano la nuova versione. Nel frattempo il circuit breaker limita comunque l'effetto, e il catalogo interno funziona sempre.
- **Simboli per Crashlytics:** gli stack trace sono leggibili solo con il job `crashlytics-symbols` configurato (`CRASHLYTICS_WIF_SERVICE_ACCOUNT`, `FIREBASE_ANDROID_APP_ID`), già previsto da U1 prima della prima pubblicazione.
- La cache sul telefono non richiede migrazioni. Un formato cambiato o illeggibile si scarta da solo (NFR6.4).

## 5. Segreti e costi

- Nessun segreto nuovo; si aggiunge solo una chiave al segreto di configurazione esistente.
- Pochi secondi in più di CI per lo script e il benchmark, dentro il piano gratuito. Costo 0 €.
