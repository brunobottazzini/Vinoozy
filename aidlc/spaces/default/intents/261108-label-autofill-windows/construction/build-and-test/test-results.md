# Risultati dei test — compilazione dall'etichetta, finestre per tutto il mondo e conferma guidata

## Fonti

- `construction/code-generation/unit-test-instructions.md` (comandi)
- `construction/code-generation/code-summary.md` (cosa è stato costruito e scostamenti)
- Esecuzioni del 2026-11-08 su macOS, emulatore Android `emulator-5554` e Firebase Emulator Suite (porte 8080/9099, avviata da un'altra sessione e mai riavviata)

## Riepilogo

| Controllo | Comando | Esito |
|---|---|---|
| Formattazione | `dart format --set-exit-if-changed .` | 439 file, 0 cambiati |
| Analisi dell'app | `flutter analyze --fatal-infos` | nessun problema |
| Analisi del pacchetto | `dart analyze --fatal-infos` in `packages/estimation` | nessun problema |
| Test dell'app | `flutter test --coverage` | **2492 passati, 0 falliti** |
| Copertura del progetto | `tool/check_coverage.sh 80` | **90,11%** (15643/17359), soglia 80% |
| Test del pacchetto | `dart test --coverage` in `packages/estimation` | **1886 passati, 0 falliti** |
| Copertura del pacchetto | `check_coverage.sh 90` | **98,84%** (2131/2156), soglia 90% |
| Regole Firestore | `FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm --prefix test/rules test -- u1 u7 u4 u8 label_autofill compat/` | **215 passati, 0 falliti, 1 saltato** (già saltato prima) |
| End-to-end completo | 8 file in `integration_test/` su `emulator-5554` | **26 passati, 1 fallito** (vedi sotto) |
| Tabella delle denominazioni | `tool/check_appellations_release.sh` | OK: 2424 denominazioni, 724 dedicate, 1700 generate dai registri |
| Base dei vini | `tool/check_wine_db_release.sh` | OK: 15.616 vini da Open Food Facts |

Copertura per cartella: catalog 98,34%, dashboard 98,84%, sharing 98,42%, cellar 95,64%, label 97,28%, account 97,44%.

`npm run test:rules` così com'è non parte perché avvia un suo emulatore sulla porta 8080, già occupata da quello dell'altra sessione: lo stesso comando interno gira contro l'emulatore già avviato.

## End-to-end

| File | Esito |
|---|---|
| `u1_skeleton_test.dart`, `account_test.dart`, `concurrent_drink_test.dart`, `sharing_test.dart` | verdi |
| `cellar_test.dart` | verde tranne "drink, History, Undo: the History follows in the same session" |
| `label_test.dart` | 5/5 |
| `autofill_test.dart` | 4/4, compresi la guida completa sul testo di Cascina Castlet e i 2 secondi con base reale a freddo e Open Food Facts che non risponde |
| `override_test.dart` | 1/1 |

**Il fallimento** "drink, History, Undo" è lo stesso del lavoro precedente: riguarda lo Storico della UX, non questo lavoro. Il proprietario l'ha accettato (messaggio ae246174) e va risolto con il doppione dello Storico prima dello store.

## Prestazioni (benchmark CI)

| Misura | Risultato | Limite |
|---|---|---|
| `extractLabelFields`, 4000 caratteri | 1,7–3,3 ms | 200 ms (NFR4.1) |
| `analyzeLabelText`, 4000 caratteri | 2,8–5,4 ms | 100 ms (NFR4.19) |
| Tabella unita e indice degli alias | 8,7 ms | 150 ms (NFR4.3) |
| Apertura della base reale a freddo (emulatore) | circa 1,7 s | dentro i 1,5 s di ricerca grazie all'apertura anticipata (NFR4.18, NFR4.24) |

## Insieme di riferimento della guida (69 testi, FR7.3)

| Criterio | Risultato | Soglia |
|---|---|---|
| Campi certi sbagliati | 0 (precisione 100%) | 0 |
| Valore giusto primo tra i candidati | 72/88 (81,8%) | ≥ 70% |
| Valore giusto tra i primi 3 | 88/88 (100%) | ≥ 90% |
| Campi incerti per testo | media 1,61, massimo 4 | ≤ 2, ≤ 4 |

È l'insieme su cui sono stati fissati i pesi, quindi non è una verifica indipendente: la conferma vera è la prova sul telefono.

## Difetti trovati e corretti in questa fase

1. **"Incolla da Lens" senza risultato sul telefono** (messaggio 4e9809bc): la ricerca nel catalogo aspettava senza limite l'apertura della base reale e Open Food Facts (7,7 s di schermo fermo in prova). Corretto con il limite di 1,5 s, l'apertura anticipata della base e l'attesa visibile (FR2.8). Regressione: test unitari, widget ed e2e.
2. Riapertura dei requisiti per la **conferma guidata** (FR7), con mockup, design, NFR e codice approvati.
3. Dalla revisione del codice: "Chianti Classico" composto prendeva la riga Chianti; "Salva" toccabile con la guida aperta; annata dell'anno prossimo compilabile e poi rifiutata al salvataggio; test adattati che non controllavano l'apertura della guida. Tutti corretti con test.

## Da misurare sul telefono del proprietario

Non ancora fatte: il proprietario non può provare ora (messaggio 83c8c274). La build con le correzioni è installata sul telefono (OnePlus CPH2581).
- I 2 secondi dopo "Incolla da Lens" (NFR4.17) e la guida (FR7).
- Apertura della base e memoria (FR6.3), dimensione dell'app (`tool/app_size_baseline.txt` ancora vuoto).
