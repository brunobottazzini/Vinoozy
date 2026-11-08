# Risultati di Build and Test — pending-banner-fix

Data: 2026-11-07. Ambiente:
- MacBook Air, Flutter 3.47.9;
- emulatore Android `Medium_Phone_API_36.1` con 4 core, 4 GB, densità 420;
- Firebase Emulator Suite (Auth + Firestore, `demo-vinoozy`).

**Esito: NON superato.** Il difetto corretto (NFR6.6, fascia "in attesa") non si è più presentato. Però `cellar_test.dart` non passa 5 corse su 5 (NFR2) per un **altro** difetto preesistente, nello Storico.

## 1. Build e controlli statici

| Comando | Uscita | Risultato |
|---|---|---|
| `dart format --output=none --set-exit-if-changed .` | 0 | nessuna differenza |
| `flutter analyze --fatal-infos` | 0 | nessun problema |

## 2. Test di unità e copertura

| Comando | Uscita | Risultato |
|---|---|---|
| `flutter test test/cellar/data/pending_writes_probe_test.dart test/cellar/data/drinking_record_repository_test.dart` | 0 | 24 superati (7 + 17) |
| Stessi 3 test di regressione `FR1.1` con le versioni di `HEAD` dei due file di `lib/` (prova fatta in questa sessione, poi ripristinata la correzione) | 1 | **3 falliti su 3**: la regressione riproduce il difetto |
| `flutter test test/u1/sync/sync_status_test.dart test/cellar/cellar_providers_test.dart` | 0 | 25 superati |
| `flutter test --coverage` (suite completa) | 0 | **1.533 superati**, 0 falliti |
| `packages/estimation`: `dart test --coverage=coverage` + `format_coverage` | 0 | superati |
| `tool/check_coverage.sh 80` su app + stima | 0 | **89,12%** (9.006/10.106) |
| `tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/` | 0 | **95,27%** (2.699/2.833) |

## 3. End-to-end

### `integration_test/cellar_test.dart` da solo (NFR2: 5 corse consecutive su 5)

| Gruppo | Corse | Superate | Fallite e causa |
|---|---|---|---|
| prima serie, come da NFR2 | 5 | 3 | 2 (causa non registrata in questa serie) |
| seconda serie, con il dettaglio | 9 | 6 | 3, tutte alla **riga 135**: nello Storico la bevuta "Dolcetto di Dogliani" compare **due volte** (`Found 2 widgets ... descending from history-list`, due `Text("Dolcetto di Dogliani Senza annata")`) |

- **Fascia "in attesa" (riga 95, il difetto di questa correzione):** 0 fallimenti in tutte le corse registrate. Prima della correzione falliva 3 volte su 5.
- **NFR2 non soddisfatto** per il doppione nello Storico. È una riga duplicata vera, che vedrebbe anche chi usa l'app. Si verifica circa 1 volta su 3 quando si torna sulla scheda Storico dopo una bevuta: `HomeShell._select` invalida `historyPagerProvider` e `HistoryPager` ricarica la prima pagina. La causa precisa non è stata individuata. Questa correzione non tocca lo Storico; il difetto preesisteva.

### Suite completa e riavvio forzato

| Comando | Uscita | Risultato |
|---|---|---|
| `flutter test integration_test --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true` | 1 | **19 superati, 1 fallito**: `cellar_test` primo test, all'avvio, per `SocketException: Connection timed out` verso `10.0.2.2` in `clearEmulators()`. È un errore di rete dell'ambiente, prima di qualsiasi azione dell'app. Il secondo test di `cellar_test` è passato. Lo scenario 8 di U1, instabile in passato, è passato. |
| `tool/e2e_force_stop.sh` | 0 | il vino "Sangiovese" sopravvive al kill e arriva al cloud |

Tempi: salvataggio offline fino alla lista 1.838 ms (limite provvisorio 2 s); avvio con la lista, mediana 615 ms (limite CI 4 s).

## 4. Rischio accettato al gate di Code Generation (R-01 Major)

Il caso "uscita con bevute in coda, poi accesso con un altro account e reset di Firestore" non è stato provato sull'emulatore. Il rischio è che la fascia "in attesa" resti accesa per il nuovo account fino alla chiusura dell'app. Il proprietario l'ha accettato approvando Code Generation, con la correzione proposta (`PendingWritesProbe.reset()` con numero di generazione).

## 5. Esito e prossimo passo

Il predicato di fallimento scatta: NFR2 è `Not Met`. Correzioni nella fase stessa: nessuna applicabile. La causa sta nel codice dell'app (Storico di U4), fuori dai requisiti di questo lavoro, e non è stata individuata con precisione: non c'è una correzione già definita da stimare.

Le scelte vanno al proprietario, nella forma senza correzione definita del protocollo di ritorno.

**Decisione del proprietario (2026-11-07, messaggio 080c578c): "Accept failure".** Il fallimento resta registrato qui, la fase va al gate e il doppione nello Storico diventa un lavoro separato.
