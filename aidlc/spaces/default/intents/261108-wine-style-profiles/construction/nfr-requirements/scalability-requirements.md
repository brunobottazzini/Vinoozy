# Requisiti di scalabilità — profili di stile

## Fonti

- `inception/requirements-analysis/requirements.md` (NFR1–NFR6, FR1–FR4).
- `construction/functional-design/` (BR1–BR11, D1–D9, ENT-101–ENT-112).
- NFR dei lavori precedenti (`261108-label-autofill-windows/construction/nfr-requirements/`), che restano validi.

## Requisiti

| ID | Requisito | Verifica |
|---|---|---|
| NFR3.7 (NFR3) | Cantine fino a 500 vini: calcolo della migrazione ≤ 2,5 s, ricalcolo delle stime ≤ 10 ms per 500 vini | benchmark con 500 vini |
| NFR3.8 (D3) | La base classificata scala con l'export: la classificazione è lineare nel numero di vini | misura nel tool |
