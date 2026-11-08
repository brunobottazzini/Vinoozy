# Istruzioni dei test di prestazione

## Fonti

- `construction/nfr-requirements/performance-requirements.md` (NFR4.1–NFR4.4, NFR4.17–NFR4.24)

## Benchmark in CI

```bash
(cd packages/estimation && dart run benchmark/estimation_benchmark.dart)
```

Misura `extractLabelFields` e `analyzeLabelText` su 4000 caratteri, la costruzione della tabella unita e dell'indice degli alias, e la stima di 500 vini. Ogni misura ha il suo limite e il benchmark esce con errore se lo supera.

## I 2 secondi (NFR4.17)

- In CI: il caso di `integration_test/autofill_test.dart` con la base reale aperta a freddo e Open Food Facts che non risponde.
- Sul telefono: la prova manuale di `integration-test-instructions.md`, con il tempo riportato in `test-results.md`.

## Sul telefono

Apertura della base, memoria e fluidità della scheda della guida si misurano sul telefono del proprietario con la build di profilo (`flutter run --profile`) e si riportano in `test-results.md`.
