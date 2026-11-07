# Performance Design — u3-wine-catalog

Fonti: `performance-requirements.md` (NFR1.1–NFR1.5), `scalability-requirements.md` (NFR2.1), `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`.

## Catalogo interno (NFR1.1, NFR1.5, NFR2.1)

- **Costruzione unica:** `InternalCatalog` si costruisce alla prima chiamata e resta in un provider Riverpod per tutta la sessione. Per ogni denominazione tiene `displayName` e la lista delle parole normalizzate di tutti i `searchTerms`, preparate una sola volta.
- **Ricerca:** la query si normalizza e si divide in parole una volta per chiamata. Una voce corrisponde se ogni parola della query è l'inizio di una sua parola (`startsWith`). Il costo è proporzionale a numero di voci per numero di parole: con 47 denominazioni e 500 vini resta sotto il millisecondo sul runner di CI.
- **Vini della cantina:** U4 passa `cellarWines` già convertiti. U3 li normalizza e tiene in memoria il risultato finché la lista non cambia (stesso oggetto), così la scrittura lettera per lettera non ripete il lavoro.

## Cache (NFR1.4)

- La cache vive in memoria, in una mappa per chiave, ed è caricata dal file al primo uso. Le letture non toccano il disco. Le scritture su file sono raggruppate e asincrone (vedi `reliability-design.md`).

## Chiamate a OFF (NFR1.3)

- Tutte asincrone, con `timeout(5 s)` sul `Future` della richiesta e della lettura del corpo. L'interfaccia non attende mai OFF per mostrare i risultati interni: `suggestWines` è separata da `suggestExternal` (C1).

## Benchmark in CI (NFR1.1, NFR1.2, NFR1.4, NFR1.5, NFR7.4)

File `benchmark/catalog_benchmark.dart` nell'app, eseguito con `dart run`. Nel job `unit` è un passo nuovo, dopo i test. Ogni misura usa la mediana di 10 giri dopo 3 di riscaldamento, ripete una volta se sfora e termina con `exit(1)` se sfora di nuovo, come il benchmark di U2.

| Misura | Soglia in CI (`ubuntu-latest`) | Requisito |
|---|---|---|
| `suggestWines` con 500 vini, query da 2 a 60 caratteri | ≤ 5 ms | NFR1.1 |
| `matchLabelText` su 2000 caratteri, senza OFF | ≤ 10 ms | NFR1.2 |
| Lettura dalla cache in memoria | ≤ 1 ms | NFR1.4 |
| Costruzione di `InternalCatalog` | ≤ 20 ms | NFR1.5 |

Il benchmark importa solo il nucleo puro `lib/catalog/core/` (`InternalCatalog`, `CatalogCacheStore` in memoria, riconoscimento di C2), che non importa Flutter, `path_provider` né Firebase (`logical-components.md`), quindi gira con `dart run`. Un controllo in `tool/check_off_config.sh` verifica che nessun file di `lib/catalog/core/` importi `package:flutter`, `path_provider` o `firebase_`.

## Misura sul telefono

Il test di velocità sul telefono di U2 (`integration_test_perf/estimation_perf_test.dart`) si estende con le misure di `suggestWines` e `matchLabelText`. Soglie sul telefono del proprietario: 25 ms e 50 ms. Si annotano nella checklist di rilascio.
