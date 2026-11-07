## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** 2026-11-06
**Iteration:** 1
**Verdict Dictated:** no

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Minor | lib/app/home_shell.dart > `onOpenWine` / `onOpenStatus`; lib/dashboard/ui/chart_cards.dart > `StatusChartCard` (`semanticsHint: l10n.openListHint`); lib/dashboard/ui/drink_soon_section.dart > "Vedi tutti (N)" | Le barre di stato e "Vedi tutti" dichiarano a TalkBack "Apri l'elenco" (`openListHint`), ma `HomeShell` porta solo alla scheda Cantina, senza alcun filtro per stato. Anche toccare una riga di "Da bere presto" apre la Cantina e non il dettaglio del vino. Finché U4 non fornisce elenco filtrato e dettaglio, il suggerimento promette più di quello che succede. | Finché U4 non è collegato, usare un suggerimento che dica "Apri la cantina" (oppure togliere il suggerimento alle barre). Annotare nel code-summary che il collegamento del filtro e del dettaglio è un lavoro rimasto aperto per U4. | New |
| R-02 | Minor | tool/check_dashboard_readonly.sh > controlli 1 e 2; lib/dashboard/ui/dashboard_screen.dart > `OfflineBanner` | Il controllo di sola lettura vieta solo gli import di `wine_repository.dart`, `cellar_repository.dart`, `sync/ledger/` e quattro nomi di provider. Non vieta `sync/sync_watcher.dart`, `sync/sync_gateway.dart` e `cellar/data/retry.dart`. Inoltre non vede i percorsi indiretti: il Cruscotto monta `OfflineBanner`, che osserva `syncStatusProvider`, e questo, al ritorno della rete, chiama `syncWatcherProvider.trigger()` (`lib/app/providers.dart`). Oggi non scrive nulla di nuovo, perché il provider è condiviso con la Cantina già montata nell'`IndexedStack`. Però la garanzia "sola lettura" regge per un caso concreto e non per costruzione. | Aggiungere al controllo gli import di `sync/sync_watcher.dart`, `sync/sync_gateway.dart` e `cellar/data/`, con un'eccezione esplicita per `offline_banner.dart` che spieghi perché è ammesso. In alternativa, scrivere nel design che il banner è l'unico ingresso indiretto e che il provider è condiviso con U1. | New |
| R-03 | Minor | aidlc/spaces/default/intents/261104-wine-cellar-app/construction/u5-dashboard/nfr-design/security-design.md §4 e frontend-components.md (testo "Impossibile leggere la cantina" di NFR6.2) | I design di U5 si contraddicono sul messaggio d'errore: `security-design.md` §4 sceglie `cellarSetupFailed` ("Impossibile preparare la cantina"), mentre NFR6.2 e `frontend-components.md` citano "Impossibile leggere la cantina". Il codice segue §4, ed è la scelta ragionevole: lo stesso testo e lo stesso "Riprova" di U1 coprono sia l'errore di preparazione sia quello dei listener. Resta però un'incoerenza non sanata nei documenti approvati. | Accettare lo scostamento e allineare NFR6.2 e `frontend-components.md` alla scelta di §4, in modo che chi legge i design non cerchi una stringa che non esiste. | New |
| R-04 | Minor | integration_test/dashboard_500_test.dart; tool/perf_cold_start.sh; integration_test_perf/ | Né il test da 500 vini, né il nuovo test 11 di U1, né le misure sul telefono (avvio a freddo, scorrimento, 25 ms di `compute`) sono stati eseguiti: `adb devices` era vuoto e le porte 8080 e 9099 non rispondevano. Dalla lettura il codice è plausibile (un solo `:commit` da 500 scritture, pari al massimo di Firestore; pulizia in `finally`; `trap` che riaccende rete e dati; conteggio dei 500 vini verificato per ogni avvio). Ma finché non gira non è provato che l'e2e passi in CI, né che i due telefoni rispettino 2 s e 1 s. | Eseguire `dashboard_500_test.dart` e il test 11 nel job `e2e` di GitHub Actions in Build and Test, e `tool/perf_cold_start.sh` sui due telefoni, prima di dichiarare chiuse NFR2.1 e il test dei 500 vini. Registrare i risultati in `docs/release-checklist.md` §1-ter. | New |

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| `tool/check_dashboard_readonly.sh` | OK (11 file in `lib/dashboard`) | Nessun import di Firebase, di repository di scrittura o del ledger. Il controllo ha i limiti del secondo finding. |
| `tool/check_dashboard_readonly_test.sh` | OK: `ok/` passa, `bad/` fallisce con exit 1, cartella mancante rifiutata | Il controllo del controllo è significativo: dimostra che lo script sa fallire. |
| `flutter analyze --fatal-infos` | nessun problema | Conferma quanto dichiarato dallo sviluppatore. |
| `flutter test test/dashboard test/app test/account` | 141 test verdi | Eseguiti da me. La suite completa (610 test), la copertura (99,04% per `lib/dashboard/`, 90,20% di progetto) e il benchmark (1,08 ms) non sono stati rieseguiti: sono valori dello sviluppatore, non verificati da me. |
| Confronto dei file `.arb` | it, en e pt-BR hanno le stesse 77 chiavi, senza differenze | Nessuna chiave manca in una lingua. I plurali ICU sono presenti nelle tre lingue. |

### Summary

Il codice rispetta i design approvati: il calcolatore è puro e passa una sola volta sui vini, ogni `statusOf` ha il suo try/catch, il mapper di `Wine` non lancia mai eccezioni, e `todayProvider` usa `DateTime(y, m, d + 1)`, si riprogramma alla ripresa e si cancella in `ref.onDispose`. Il registratore di eventi non ha parametri, invia un solo evento per processo e passa da `ErrorReporter`. Anche il cablaggio di `HomeShell` e dell'accesso, con gli stati di preparazione e di errore, è coerente, e i quattro scostamenti dichiarati sono accettabili. Restano quattro rilievi Minor, nessuno bloccante: il suggerimento "Apri l'elenco" promette un filtro che ancora non c'è, il controllo di sola lettura ha lacune sui percorsi indiretti, il testo d'errore è incoerente tra i design, e le misure su emulatore e telefono non sono ancora state eseguite.
