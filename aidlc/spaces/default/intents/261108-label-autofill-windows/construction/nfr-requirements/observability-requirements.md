# Requisiti di osservabilità

## Fonti

- `codekb/Vinoozy/`: `CatalogEventLogger`, Crashlytics, i log della console.
- `construction/functional-design/`: BR2.3, BR3.9.

| ID | Requisito | Verifica |
|---|---|---|
| NFR4.15 | Eventi informativi solo in console, quando il log di debug è attivo:<br>- `autofill_result`: origine (`photo`, `paste`, `share`, `auto`) ed esito (`filled`, `noFields`, `sureMatch`), con il numero di campi compilati;<br>- `lens_open`: `lensApp`, `googleApp` o `unavailable`;<br>- `estimates_migrated`: numero di vini e durata. | test del logger |
| NFR4.16 | Su Crashlytics, come errori non fatali, vanno solo:<br>- `estimates_migration_failed`, con motivo da un elenco chiuso;<br>- `appellations_index_failed`.<br>Nessun testo, nome di vino o denominazione. | test del logger con Crashlytics finto |
| NFR3.6 | La checklist dopo il rilascio aggiunge un controllo su Crashlytics: con più di 5 eventi `estimates_migration_failed` in 7 giorni si indaga. | voce in `docs/release-checklist.md` |
