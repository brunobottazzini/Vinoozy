# CI/CD Pipeline — u5-dashboard

Fonti:
- `performance-design.md`, `security-design.md` e `logical-components.md` di U5;
- `functional-spec.md` di U5 e `components.md`;
- `.github/workflows/ci.yml` e `release.yml` esistenti;
- riepilogo confermato in `infrastructure-design-questions.md`.

U5 non aggiunge job nuovi: aggiunge passi ai job esistenti di `ci.yml`. `release.yml` non cambia. Tutti i controlli restano obbligatori prima del merge in `main` (team.md, "Gate prima del merge").

## 1. Modifiche a `ci.yml`

| Job | Passo nuovo o modificato | Cosa verifica | Requisito |
|---|---|---|---|
| `analyze` | `tool/check_dashboard_readonly.sh` dopo `tool/check_off_config.sh` | `lib/dashboard/` non importa Firebase né i repository di scrittura e non nomina i provider di scrittura; `lib/dashboard/domain/` non importa Flutter, Firebase o `shared_preferences`; `shared_preferences` solo in `dashboard_providers.dart` | NFR4.1 |
| `analyze` | `tool/check_dashboard_readonly_test.sh` | Lo script passa su `tool/fixtures/dashboard_readonly/ok/` e fallisce su `bad/`, così un controllo rotto non passa in silenzio | NFR4.1 |
| `unit` | Nessun passo nuovo per i test: `flutter test --coverage` include `test/dashboard/` | Test di calcolo, provider, `todayProvider` con orologio finto, mapper `Wine`, widget nelle tre lingue, semantica, contrasto, tocchi, testo grande, registratore | NFR2.3, NFR3.x, NFR6.x, NFR8.1 |
| `unit` | Copertura: invariata a livello di progetto (80% su `coverage/merged.lcov.info`); più `tool/check_coverage.sh 80 coverage/lcov.info lib/dashboard/`, come per il catalogo | Il nuovo modulo non abbassa la copertura | team.md (Copertura) |
| `unit` | `dart run benchmark/dashboard_benchmark.dart` dopo il benchmark del catalogo | `compute` su 500 vini ≤ 10 ms (mediana di 10 dopo 3 di riscaldamento, una ripetizione) | NFR2.2 |
| `unit` | `tool/check_release_build.sh` esteso | Oltre a `EmulatorGoogleAuthService`, anche `VINOOZY_DASHBOARD_READY` deve mancare dalla build di rilascio normale. Il controllo positivo **non aggiunge una terza build**: la build di controllo esistente riceve `--dart-define=E2E=true --dart-define=PERF=true` e deve contenere entrambi i marcatori. Le build restano due, quindi il tempo del job `unit` (limite di 15 minuti) non cambia. | NFR2.1 (strumentazione solo nelle build di misura) |
| `e2e` | Nessun passo nuovo: `flutter test integration_test` esegue anche `dashboard_500_test.dart`, e i test dello scheletro aggiornati passano dalla scheda "Cantina"; `tool/e2e_force_stop.sh` cerca il vino nella scheda Cantina | Il Cruscotto compare dopo l'accesso, un vino aggiunto entra nei conteggi, 500 vini danno 500 bottiglie | NFR2.1 (parte CI), NFR7.5 |

**Isolamento del test da 500 vini:**
- usa un'identità propria, `userDashboard` (`dashboard@example.com`), quindi una cantina che nessun altro test legge o conta;
- i 500 vini si creano con **una sola** richiesta `:commit` della REST di amministrazione dell'emulatore, con 500 scritture: pochi secondi;
- l'attesa principale è la prima sincronizzazione dei 500 documenti nell'app, limitata a 60 s dal test;
- per questo la stima di costo è di circa 1 minuto in più sul job `e2e`, che oggi ha un limite di 45 minuti.

Alla fine il test cancella la cantina con la REST, come gli altri test e2e fanno con i propri dati.

Gli script nuovi sono `bash` con `set -euo pipefail`, eseguibili (`chmod +x`), e usano solo `grep` e `find`, già presenti sui runner `ubuntu-latest`.

## 2. Fuori dalla CI (una volta per versione)

| Strumento | Dove | Note |
|---|---|---|
| `tool/perf_cold_start.sh` | Mac del proprietario, telefono collegato via USB, emulatori Firebase locali | Prepara 500 vini con `integration_test_perf/dashboard_seed.dart`, toglie la rete e misura 5 avvii a freddo (`performance-design.md`). Riaccende la rete con un `trap`. |
| `integration_test_perf/dashboard_perf_test.dart` | `flutter drive --profile --driver=test_driver/perf_driver.dart` | Due misure sul telefono, nello stesso file:<br>• scorrimento completo con `FrameTimingSummarizer` (NFR2.4);<br>• tempo di `DashboardCalculator.compute` su 500 vini generati in memoria, con mediana di 10 giri dopo 3 di riscaldamento e soglia di 25 ms (NFR2.2, parte telefono), come fa già `estimation_perf_test.dart`. |

I risultati vanno nella checklist di rilascio (`monitoring-design.md` §3). Non girano in CI perché l'emulatore di GitHub Actions dà tempi troppo variabili (NFR2.1).

## 3. Rilascio

Invariato. Un merge su `main` fa partire `release.yml`, che costruisce l'AAB firmato e lo pubblica sul test interno. La produzione graduale richiede l'approvazione del proprietario dopo il controllo §1-ter della checklist.

## 4. Rollback

- **Problema in produzione:** si ferma il rilascio graduale in Play Console e si pubblica una versione corretta, che passa dal test interno.
- **Controllo di CI rotto per un motivo esterno** (per esempio un runner più lento per il benchmark): si corregge il controllo o il codice in un blocco nuovo. Non si disattiva il controllo e non si alza la soglia.
- Non ci sono dati cloud da ripristinare, perché il Cruscotto non scrive.
