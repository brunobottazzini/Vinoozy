# Performance Design — u8-account

Fonti: `performance-requirements.md` (NFR1.1–NFR1.3, NFR5.1–NFR5.3), `tech-stack-decisions.md` (NFR7.1–NFR7.6), `functional-spec.md`, `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`.

Per un'unità di interfaccia non esistono `scalability-requirements.md`, `reliability-requirements.md` e `observability-requirements.md` separati:
- la scala è quella del dimensionamento (caso peggiore 3.500 documenti; uso previsto ≈ 200 bottiglie);
- l'affidabilità è in `security-design.md` §6;
- l'osservabilità sono i motivi fissi di `security-design.md` §4.

## 1. Aperture (NFR1.1)

- Presentazione, profilo e dialoghi non leggono il cloud: nome ed email vengono dall'accesso già in memoria, il numero di modifiche in coda dal `LocalLedger`.

## 2. Cancellazione (NFR1.2, NFR1.3)

- **Passo 0:** `waitForPendingWrites()` con `timeout(30 s)`.
- **Passo 4:**
  - lettura dal server di `drinkingRecords` e poi di `wines`, a pagine di 400 (`limit(400)`);
  - per ogni pagina, un batch di cancellazione da 400 con `commit` atteso;
  - si ripete finché la pagina è vuota.
  
  Con ≈ 200 bottiglie bastano 1–2 batch. Nel caso peggiore (3.500 documenti) circa 9 batch, sotto i 60 s con una buona rete.
- **Avanzamento:** il runner emette lo stato dopo ogni batch, così l'utente vede il conteggio scendere.

## 3. Costo (NFR5.1–NFR5.3)

| Voce | Uso previsto (≈ 200 bottiglie) | Caso peggiore | Quota gratuita al giorno |
|---|---|---|---|
| Letture della cancellazione | qualche centinaio | ≈ 3.500 | 50.000 |
| Scritture della cancellazione | qualche centinaio | ≈ 3.500 | 20.000 |
| Funzioni nel cloud | 0 | 0 | — |
| Pagina web | GitHub Pages gratuito | — | — |

## 4. Qualità e CI (NFR7.1–NFR7.6)

| Requisito | Collegamento |
|---|---|
| NFR7.1 copertura | Job `unit`: `tool/check_coverage.sh 80 coverage/lcov.info lib/account/` |
| NFR7.2 ID delle regole | Job `analyze`: `tool/check_rule_ids.sh BR1. 13 test/account test/rules/u8.rules.test.mjs` |
| NFR7.3 tre lingue | `flutter test` con `textScaler` 2.0 |
| NFR7.4 end-to-end | Job `e2e`: `integration_test/account_test.dart` (uscita con modifiche in coda; cancellazione completa con una cantina condivisa e verifica del cloud vuoto) |
| NFR7.5 non regressione | Suite completa; test esistenti di `AccountGate` aggiornati |
| NFR7.6 pagina web | Job `rules`: `npm run test:web` (emulatori di Firestore e Auth, regole caricate esplicitamente, accesso Google simulato), vedi `security-design.md` §7 |
| Versioni fissate | Job `analyze`: `tool/check_web_pins.sh` (cartella `vendor/` uguale al pacchetto npm della stessa versione; nessuno script esterno) |
| Pubblicazione della pagina | Workflow manuale `pages.yml` verso `gh-pages`, dopo le regole |

## 5. Misure

| Misura | Dove | Soglia |
|---|---|---|
| Aperture di profilo e dialoghi | Test dei widget | ≤ 300 ms |
| Cancellazione di 50 vini e 100 bevute | End-to-end sugli emulatori | ≤ 60 s |
| Cancellazione del caso peggiore | Telefono, una volta per versione che tocca la cancellazione, checklist | ≤ 60 s |
| Attesa delle modifiche in coda | Test con orologio finto | 30 s, poi Riprova |
