# Controllo di salute — pending-banner-fix

## Fonti

- `deployment-log.md` e `smoke-test-results.md` di questa fase.
- `operation/deployment-pipeline/deployment-strategy.md`.

| Controllo | Stato | Note |
|---|---|---|
| Regole e indici di `vinoozy-d6f45` | sani | pubblicati e compilati; l'indice dello Storico è attivo (lo Storico funziona) |
| App sul telefono del proprietario | in esecuzione | build di debug collegata al progetto reale |
| Errori `cellar_*` in Crashlytics | non controllati | la build di debug non è il percorso di produzione; nessun rilascio graduale in corso |
| Fascia "in attesa" offline sul telefono | **non verificata** | prova non eseguita dal proprietario; verificata solo in automatico (unità ed emulatore) |

**Esito:** nessun rilascio in produzione in corso e nessun rollback necessario. La correzione resta da portare in `main` con il percorso di `cd-config.md`. La prova sul telefono della fascia resta da fare: va inclusa nello smoke test del primo rilascio sul canale di test interno.
