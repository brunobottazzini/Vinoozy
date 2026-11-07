# Performance Design — u5-dashboard

Fonti: `performance-requirements.md` (NFR2.1–NFR2.4), `tech-stack-decisions.md`, `functional-spec.md` di U5, `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`. Per un'unità di interfaccia non esistono file separati `scalability-requirements.md`, `reliability-requirements.md` e `observability-requirements.md`:
- l'affidabilità e l'unico evento osservabile stanno in `security-requirements.md` (NFR6, NFR8.1);
- la scala è fissata da NFR2, cioè 500 bottiglie per cantina.

## Calcolo in un solo passaggio (NFR2.2)

`DashboardCalculator.compute(wines, today)` è una funzione pura: non registra niente e non ha un parametro per il catalogo, perché `recognizeDenomination` è una funzione di C2. Scorre i vini una sola volta. Per ogni vino con quantità maggiore di 0:
1. calcola lo stato con `statusOf` dentro un try/catch. In caso di errore il vino conta come "da stimare" e incrementa `invalidWindowCount`;
2. aggiorna i quattro conteggi dello stato, il conteggio "da stimare", la colonna dei picchi, la famiglia di tipologia e la regione normalizzata, con le mappe delle forme scritte;
3. se lo stato è `drinkSoon`, aggiunge il vino alla lista.

Alla fine ordina la lista e ne tiene 10 più il totale, poi ordina le regioni e ne tiene 8 più "altre". Il costo cresce in proporzione al numero di vini, con un solo ordinamento piccolo.

La regione di un vino senza `region` ma con `denomination` si ricava da `recognizeDenomination`. I risultati si memorizzano per stringa di denominazione durante il calcolo, così ogni denominazione si riconosce una volta sola. `invalidWindowCount` fa parte di `DashboardSummary`; chi lo usa è descritto in `security-design.md` §2.

## Ricalcolo solo quando serve (NFR2.3)

- `dashboardSummaryProvider` dipende da `winesStreamProvider(Cellar.personalCellarId(uid))` e da `todayProvider`, non dal selettore. È la stessa chiamata di `CellarScreen`. Oggi `personalCellarId(uid)` restituisce l'uid stesso, quindi il flusso condiviso con la Cantina e con `syncStatusProvider` è lo stesso.
- `breakdownModeProvider` sceglie soltanto quale delle due liste già calcolate (`byType` o `byRegion`) mostrare.
- Un test con un calcolatore finto conta le chiamate: un cambio del selettore non produce chiamate.

## Disegno e scorrimento (NFR2.4)

- `DashboardContent` è un `CustomScrollView` con sliver. La lista "da bere presto" ha al massimo 10 righe, costruite subito perché sono poche e leggere.
- Le barre sono `Row` e `Column` con `FractionallySizedBox`, senza `CustomPainter` né animazioni continue. Il grafico dei picchi con 13 colonne usa un `SingleChildScrollView` orizzontale solo se lo spazio non basta.
- I widget delle card sono `const` dove possibile e ricevono solo la parte di `DashboardSummary` che usano, così un cambio del selettore ricostruisce solo la terza card.
- La shell tiene le due schede in un `IndexedStack`. Tornare al Cruscotto non ricostruisce i dati, perché i provider sono condivisi con la scheda Cantina.

## Avvio (NFR2.1)

- La shell mostra il Cruscotto non appena c'è un utente. Lo scheletro di caricamento compare subito e i dati arrivano dal flusso locale di Firestore, che non richiede rete.
- All'avvio non c'è lavoro pesante oltre a quello già fatto da U1. Il calcolo del cruscotto richiede meno di 50 ms (NFR2.2).

## Misura dell'avvio a freddo sul telefono (NFR2.1)

`flutter drive` lancia l'app una sola volta e misura dal driver. Per questo l'avvio a freddo si misura con uno script `adb`, `tool/perf_cold_start.sh`, sul modello di `tool/e2e_force_stop.sh`. La grandezza misurata è quella del requisito: dall'avvio del processo al primo frame con `dashboard-content` e i conteggi caricati. Cambia solo lo strumento, non la soglia. La misura dello scorrimento (NFR2.4) resta con `flutter drive --profile`.

1. **Segnale dell'app:**
   - una costante `kIsPerfBuild = bool.fromEnvironment('PERF')` in `lib/firebase/firebase_env.dart`, accanto a `kIsE2EBuild`;
   - solo con `PERF=true`, quando `DashboardContent` disegna per la prima volta uno stato con i dati (non il caricamento, non "Sincronizzazione…"), un `addPostFrameCallback` emette `Timeline.instantSync('vinoozy_dashboard_ready')` e scrive su logcat la riga `VINOOZY_DASHBOARD_READY bottles=<totale>`;
   - nelle build normali il ramo è codice morto e il compilatore lo elimina.

   `tool/check_release_build.sh` aggiunge `VINOOZY_DASHBOARD_READY` ai marcatori che non devono comparire nella build di rilascio.
2. **Preparazione dei dati** (telefono collegato via USB, emulatori Firebase sul computer):
   - lo script apre le porte di Auth e Firestore con `adb reverse tcp:9099 tcp:9099` e `adb reverse tcp:8080 tcp:8080`. La build di profilo usa `--dart-define=FIREBASE_ENV=demo --dart-define=E2E=true --dart-define=PERF=true --dart-define=EMULATOR_HOST=127.0.0.1`, perché l'host predefinito `10.0.2.2` vale solo nell'emulatore Android;
   - un target di preparazione, `integration_test_perf/dashboard_seed.dart`, eseguito con `flutter drive --profile --keep-app-running` e gli stessi define:
     - accede come `userA` con l'accesso fittizio delle build E2E, come i test di `integration_test/`;
     - legge l'uid assegnato dall'emulatore di Auth;
     - solo dopo crea i 500 vini in `cellars/{uid}/wines` con la REST di amministrazione (`e2e_helpers.dart`);
     - aspetta che il Cruscotto mostri 500 bottiglie, così Firestore ha riempito la cache locale. La sessione di accesso resta salvata sul telefono per gli avvii successivi;
   - poi lo script toglie il collegamento con `adb reverse --remove-all`. È questo che rende irraggiungibili gli emulatori: la modalità aereo non interrompe il cavo USB. Spegne anche Wi‑Fi e dati con `adb shell svc wifi disable` e `adb shell svc data disable`, che funzionano su tutte le versioni di Android supportate, così l'app è davvero senza rete.
3. **Cinque avvii a freddo:**
   - per ogni giro: `adb shell am force-stop`, `adb logcat -c`, `adb shell am start -W -n com.vinoozy.app/com.vinoozy.vinoozy.MainActivity`;
   - aspetta la riga `VINOOZY_DASHBOARD_READY` con `adb logcat -v epoch`;
   - il tempo è la differenza fra il timestamp di quella riga e quello della riga `Start proc … com.vinoozy.app` di `ActivityManager`, cioè l'avvio del processo;
   - se una riga ha un numero di bottiglie diverso da 500, il giro non è valido e lo script fallisce.
4. **Risultato:** lo script stampa i cinque tempi e la mediana, poi riaccende Wi‑Fi e dati (`svc wifi enable`, `svc data enable`). Lo fa anche se fallisce, con un `trap`. Si esegue una volta per versione sui due telefoni, con la soglia del requisito (2 s e 1 s), e il risultato va nella checklist di rilascio (`docs/release-checklist.md`). Non gira in CI.

## Misure

| Misura | Dove | Soglia |
|---|---|---|
| `compute` su 500 vini | `benchmark/dashboard_benchmark.dart` con `dart run` nel job `unit`: mediana di 10 giri dopo 3 di riscaldamento, una ripetizione se sfora, poi `exit(1)` | ≤ 10 ms su `ubuntu-latest` |
| Avvio a freddo fino al Cruscotto con 500 vini, senza rete | `tool/perf_cold_start.sh` sul telefono, mediana di 5 avvii (sezione precedente) | ≤ 2 s sul telefono di riferimento, ≤ 1 s sul telefono del proprietario |
| Cruscotto con 500 vini in CI | `integration_test/dashboard_500_test.dart` nel job `e2e` | compare con 500 bottiglie; nessuna soglia di tempo |
| Fluidità dello scorrimento | `integration_test_perf/dashboard_perf_test.dart` con `flutter drive --profile`, `traceAction` e `FrameTimingSummarizer` | 99° percentile sotto il periodo dello schermo (8,3 ms a 120 Hz, 16,7 ms a 60 Hz) |

Il benchmark importa solo `lib/dashboard/domain/`, `lib/cellar/domain/wine.dart` e il pacchetto `estimation`, che non usano Flutter. Lo script di sola lettura verifica che `lib/dashboard/domain/` non importi `package:flutter`.
