# Security Design — u5-dashboard

Fonti: `security-requirements.md` (NFR4.1, NFR8.1, NFR3.1–NFR3.5, NFR6.1–NFR6.4), `tech-stack-decisions.md` (NFR7.5), `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`. Come nei requisiti, questo file raccoglie anche accessibilità e affidabilità.

## 1. Sola lettura (NFR4.1)

- `lib/dashboard/` legge soltanto, tramite i provider di U1 (`winesStreamProvider`, `cellarStreamProvider`). L'unica scrittura è la preferenza del selettore in `shared_preferences`, con la chiave `dashboard.breakdownMode`.
- Le modifiche a U1 sono in sola lettura:
  - il mapper di `Wine` legge i nuovi campi facoltativi e non li riscrive. Le scritture esistenti di U1 aggiornano i campi uno per uno con `update`, quindi non li cancellano;
  - la shell aggiunge solo la navigazione.
- **`tool/check_dashboard_readonly.sh`**, nel job `analyze`, controlla gli import e i nomi dei provider di scrittura, non i metodi. `List.add` e `Map.update` del calcolatore restano quindi permessi. Lo script fallisce se in `lib/dashboard/`:
  1. compare un import di `package:cloud_firestore`, `package:firebase_auth`, `package:firebase_storage`, `cellar/data/wine_repository.dart`, `cellar/data/cellar_repository.dart` o `sync/ledger/`;
  2. compare uno dei nomi `wineRepositoryProvider`, `cellarRepositoryProvider`, `localLedgerProvider`, `syncWatcherProvider`;
  3. un file di `lib/dashboard/domain/` importa `package:flutter`, `package:firebase_*` o `package:shared_preferences`;
  4. `package:shared_preferences` compare fuori da `lib/dashboard/dashboard_providers.dart`.
- Lo script riceve la cartella da controllare come argomento, con `lib/dashboard` come valore predefinito. Il controllo dello script stesso è `tool/check_dashboard_readonly_test.sh`, nello stesso job, con due cartelle di prova in `tool/fixtures/dashboard_readonly/`:
  - `ok/` contiene un calcolatore con `List.add` e `Map.update` e deve passare;
  - `bad/` contiene un import di `wine_repository.dart` e deve fallire.

## 2. Privacy (NFR8.1)

- `DashboardEventLogger.invalidWindow()` non ha parametri: il codice non può passargli dati del vino.
- **Chi chiama il registratore:** il calcolatore è puro e non registra niente. `DashboardSummary` ha un conteggio `invalidWindowCount`. Quando questo è maggiore di 0, `dashboardSummaryProvider` chiama `invalidWindow()`.
- **Percorso:** il registratore usa l'uscita unica di U1, `errorReporterProvider` (`ErrorReporter.report`, NFR8.2), e non chiama Crashlytics direttamente. Così c'è un solo percorso verso Crashlytics, con la stessa sanificazione e lo stesso comportamento in debug (`DebugLogSink`).
  - La chiamata è `report(const DashboardInvalidWindow(), null, reason: 'dashboard_invalid_window', fatal: false)`.
  - `DashboardInvalidWindow` ha un `toString()` fisso, `dashboard_invalid_window: estimation_error=invalidWindow`. Il codice dell'errore sta nel messaggio, non in una chiave personalizzata, quindi non rimane attaccato ai crash successivi.
  - L'eccezione originale di `statusOf` non si inoltra.
- **Una volta per sessione:** `dashboardEventLoggerProvider` è un `Provider` senza `autoDispose`, quindi vive quanto l'app. Il registratore ha un flag interno e invia al massimo un evento per processo.
- **Test:**
  - un vino con anni marcatori (per esempio 1999 e 2088) e un nome marcatore; il `ErrorSink` finto riceve una sola chiamata, e né il messaggio né il motivo contengono i marcatori;
  - due ricalcoli con vini non validi producono comunque una sola chiamata.

## 3. Accessibilità (NFR3.1–NFR3.5)

- **Semantica:** ogni card è `Semantics(container: true, label: <descrizione>)`.
  - Il titolo e i numeri della card stanno dentro `ExcludeSemantics`, perché la descrizione li contiene già. TalkBack non li legge due volte.
  - Nel grafico dello stato fa eccezione ogni barra, che è un nodo figlio `Semantics(button: true, label: '<stato>: <n> bottiglie', hint: 'Apri l'elenco')`. I testi visivi della barra sono esclusi.
  - Le barre non interattive degli altri due grafici sono escluse con `ExcludeSemantics`.
  - Le descrizioni si costruiscono con `AppLocalizations` e i plurali ICU nelle tre lingue.
  - Un test dei widget con `tester.getSemantics` verifica, per ogni card, che ci sia un solo nodo con la descrizione e che il titolo non compaia di nuovo.
- **Contrasto:** i colori delle barre sono nuovi token in `lib/app/theme.dart` (modifica di U1). Una `ThemeExtension` `StatusColors` ha quattro colori di stato (`waiting`, `ready`, `drinkSoon`, `pastWindow`) e un colore per le barre neutre dei grafici dei picchi e delle tipologie, in tema chiaro e scuro, aggiunta a `ThemeData.extensions`. Gli stessi colori servono a U4 per gli stati.
  - Un test calcola il rapporto di luminanza relativa WCAG di ogni colore di barra contro il colore della card (≥ 3:1), e del testo dei numeri contro la barra o lo sfondo su cui si trova (≥ 4,5:1).
  - I test dei widget usano anche `textContrastGuideline`.
- **Icone:** ogni barra dello stato ha l'icona dello stato più l'etichetta e il numero. Le icone stanno in una mappa condivisa `statusIcons`, che U4 riusa.
- **Tocchi:** barre interattive, righe e selettore hanno un'area minima di 48×48 dp (`ConstrainedBox`). Si verifica con `androidTapTargetGuideline` e `labeledTapTargetGuideline`.
- **Testo grande:** con `textScaler` 2.0 le etichette vanno a capo; i grafici dei picchi e delle regioni diventano scorrevoli in orizzontale. I test dei widget nelle tre lingue verificano che non ci siano errori di overflow.

## 4. Affidabilità (NFR6.1–NFR6.4)

- **Vini rovinati:** un try/catch per singolo vino attorno a `statusOf`. Il vino conta come "da stimare" e incrementa `invalidWindowCount`. Le quantità negative valgono 0 e una tipologia sconosciuta vale "non indicata".
- **Finestra malformata nel documento:** il mapper di `Wine` resta "mai lancia". Una `window` che non è una mappa, oppure ha `startYear`, `peakYear` o `endYear` mancanti o non interi, diventa `null`, cioè "da stimare" (dettagli in `logical-components.md`). Un test del mapper prova mappe incomplete, tipi sbagliati e valori sconosciuti di `confidence` e `source`.
- **Preparazione della cantina** (stati della shell di U1):
  - con `CellarSetup.preparing` il Cruscotto mostra lo scheletro di caricamento e non apre ascoltatori Firestore, come fa `CellarScreen`;
  - con `CellarSetup.failed`, o con un errore di `cellarStreamProvider` o `winesStreamProvider`, mostra lo stesso messaggio di U1, "Impossibile preparare la cantina", con "Riprova" che chiama `onRetrySetup` (`AccountGate.retryCellar`, che riapre i due ascoltatori);
  - lo stato "cantina vuota" non compare mai in questi casi.
- **Prima sincronizzazione:** con 0 bottiglie e `isFromCache` vero compare "Sincronizzazione della cantina…" (BR1.8). Sotto c'è comunque il pulsante "Aggiungi il primo vino", così un utente nuovo senza rete, che non riceve mai un elenco dal server, non resta bloccato. Il banner offline di U1 spiega l'attesa. Quando arriva un elenco dal server, la schermata mostra lo stato vuoto oppure i dati.
- **Cambio di giorno:** `todayProvider` imposta un `Timer` fino a `DateTime(y, m, d + 1)` in ora locale, che resta corretto nei giorni del cambio dell'ora legale. Il timer si riprogramma a ogni scatto e al ritorno in primo piano (`AppLifecycleListener`). Legge l'ora da `clockProvider` di U1, così i test usano un orologio finto.

## 5. Non regressione di U1 (NFR7.5)

- File di U1 che cambiano:
  - `lib/account/ui/account_gate_view.dart`;
  - `lib/app/home_shell.dart` (nuovo);
  - `lib/app/theme.dart`;
  - `lib/cellar/domain/wine.dart`;
  - le traduzioni.
- I test di U1 che aprivano l'elenco come prima schermata si aggiornano per toccare "Cantina" nella barra di navigazione. Anche il test end-to-end dello scheletro e `tool/e2e_force_stop.sh` passano da "Cantina": cercano il vino nella scheda Cantina, oppure la scheda resta montata con `IndexedStack`.
- I test del gate verificano che `GateEnsureCellar` e `GateCellar` mostrino `HomeShell` con il Cruscotto e passino `setup` e `onRetrySetup` a entrambe le schede.
- Il test end-to-end dello scheletro verifica che dopo l'accesso compaia il Cruscotto e che un vino aggiunto entri nei conteggi.
- Il nuovo test end-to-end `integration_test/dashboard_500_test.dart`, nel job `e2e`, verifica il caso da 500 vini (NFR2.1, parte CI):
  1. crea 500 vini nell'emulatore Firestore con la REST di amministrazione, come fa `e2e_helpers.dart`, in parte con `window` e in parte senza;
  2. accede come `userA`;
  3. verifica che compaia `dashboard-content` con 500 bottiglie in totale e con i conteggi dello stato attesi.

  Non c'è una soglia di tempo.
