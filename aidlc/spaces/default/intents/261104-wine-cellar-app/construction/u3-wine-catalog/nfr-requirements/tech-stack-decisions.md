# Tech Stack Decisions — u3-wine-catalog

Fonti: `functional-spec.md` di U3, `contract-summary.md` (C1, C2, C5), `team.md` (Testing Posture, Code Style), riepilogo confermato in `nfr-requirements-questions.md`.

| Area | Scelta | Motivo | Alternative scartate |
|------|--------|--------|----------------------|
| Posizione | `lib/catalog/` nell'app Flutter, con l'interfaccia `WineCatalog` e l'adattatore `OpenFoodFactsSource` separato | C5: il formato di OFF resta nell'adattatore | Pacchetto separato (non serve, U3 dipende da Flutter solo per la cache) |
| Client HTTP | `package:http` (ultima versione stabile compatibile), con il `Client` iniettato | Leggero e testabile con `MockClient` di `package:http/testing.dart` | `dio` (più dipendenze del necessario) |
| Cache | File JSON proprio `catalog_cache.json` nella cartella di supporto dell'app (`path_provider`), scritto in modo atomico (file temporaneo poi rinomina) | Si esclude dal backup senza toccare i dati delle altre unità (NFR8.1); semplice da cancellare all'uscita | `shared_preferences` (file condiviso con U1, non escludibile per chiave), database locale (eccessivo) |
| Riconoscimento | Funzioni di catalogo del pacchetto `estimation` (C2), aggiunte in questa unità | Una sola normalizzazione condivisa con la stima | Seconda implementazione in U3 (rischio di divergenza) |
| Tempo | `Clock` iniettato (orologio sostituibile) per budget, sospensione e scadenze | Test deterministici con tempo simulato | `DateTime.now()` diretto (test lenti e instabili) |
| Configurazione | `OFF_CONTACT` via `--dart-define`, solo in `config/firebase_prod.json` (produzione); assente negli altri ambienti, quindi OFF è spento in sviluppo, test, end-to-end e CI | Mai nel codice e mai verso il vero OFF fuori dalla produzione (NFR4.3) | Costante nel codice; contatto di test (accenderebbe OFF nei test end-to-end) |
| Test | `flutter test`; client HTTP finto (`MockClient` iniettato) con risposte registrate in `test/catalog/fixtures/`, compresi 404, 429, 503, redirect, lentezza e JSON non valido. È il "server finto" del riepilogo: simula il server dentro il test, senza processi esterni. Nessuna chiamata al vero OFF (NFR4.3) | Ripetibili e gratuiti | Test contro OFF reale (instabili, consumano la quota); server HTTP locale (più lento, nessun vantaggio) |

## Requisiti di qualità

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR7.1 | Copertura delle righe di `lib/catalog/` almeno 80%, dentro la soglia di progetto dell'80% senza esclusioni. | Job `unit` della CI (lcov unito). |
| NFR7.2 | Ogni regola da BR1.1 a BR5.2 ha almeno un test con il suo ID nel nome. | Revisione dei nomi dei test. |
| NFR7.3 | Formattazione e analisi passano in CI (`dart format`, `flutter analyze`). | Job esistenti `format` e `analyze`. |
| NFR7.4 | Il benchmark dei suggerimenti (NFR1.1, NFR1.2) gira in CI a ogni push. | Passo nel job `unit` o `estimation`, da decidere in NFR Design. |
