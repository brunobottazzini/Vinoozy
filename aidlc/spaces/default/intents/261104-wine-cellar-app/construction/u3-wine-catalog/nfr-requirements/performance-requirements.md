# Performance Requirements — u3-wine-catalog

Fonti: `requirements.md` (NFR1, NFR2), `functional-spec.md` e `rules.md` di U3 (BR1.1–BR1.5, BR2.2, BR2.3), riepilogo confermato in `nfr-requirements-questions.md`.

**Telefono di riferimento:** lo stesso delle altre unità, cioè un Android di fascia media con 4 GB di RAM e Android 10 o superiore. La misura reale si fa sul telefono del proprietario (OnePlus 12, fascia alta) con soglie dimezzate, come per U2.

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR1.1 | `suggestWines` (solo interno) risponde in meno di 50 ms con 500 vini in cantina più tutte le denominazioni, per query da 2 a 60 caratteri, così i suggerimenti seguono la scrittura (NFR1). | Benchmark in CI: mediana di 10 giri dopo 3 di riscaldamento, soglia di 5 ms su `ubuntu-latest`. Misura sul telefono una volta per versione, sotto 25 ms. |
| NFR1.2 | `matchLabelText` senza OFF richiede meno di 100 ms per un testo di 2000 caratteri. | Benchmark in CI con soglia di 10 ms; misura sul telefono sotto 50 ms. |
| NFR1.3 | Ogni chiamata a OFF termina entro 5 secondi, oppure viene abbandonata (BR2.2). Nessuna chiamata a OFF blocca l'interfaccia: le chiamate sono asincrone. | Test con un client HTTP finto che risponde dopo 6 secondi: l'operazione restituisce risultati interni entro 5,1 secondi (tempo simulato). |
| NFR1.4 | Una risposta presente in cache non chiama la rete e arriva in meno di 10 ms sul telefono di riferimento. | Test: seconda chiamata identica senza richieste HTTP. Benchmark della lettura dalla cache in CI con soglia di 1 ms. |
| NFR1.5 | La costruzione del catalogo interno avviene una volta per sessione e richiede meno di 20 ms sul runner di CI. | Benchmark. |
