# Requisiti di osservabilità — profili di stile

## Fonti

- `inception/requirements-analysis/requirements.md` (NFR1–NFR6, FR1–FR4).
- `construction/functional-design/` (BR1–BR11, D1–D9, ENT-101–ENT-112).
- NFR dei lavori precedenti (`261108-label-autofill-windows/construction/nfr-requirements/`), che restano validi.

## Requisiti

| ID | Requisito | Verifica |
|---|---|---|
| NFR6.1 (NFR6) | Il manifest della base registra `classifiedTypeShare` (quota di vini con Tipologia) e la versione delle regole di classificazione; la schermata Informazioni la mostra | test del manifest e della schermata |
| NFR6.2 (NFR6) | Eventi solo in console con il log di debug: `style_migration` (numero di vini aggiornati, saltati, durata); su Crashlytics solo `style_migration_failed` con motivo da elenco chiuso | test del logger |
| NFR6.3 (NFR6) | Ogni profilo e valore delle tabelle porta nel codice il riferimento alla fonte dello studio (S1–S20, E1–E3, R0) e il passo della precedenza | test che legge la mappa e verifica i campi `source` e `step` |
