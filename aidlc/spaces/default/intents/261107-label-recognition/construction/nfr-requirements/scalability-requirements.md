# Requisiti di scalabilità — riconoscimento delle etichette

## Fonti

- `construction/functional-design/functional-spec.md` (D1, D2), `rules.md` (BR2.4, BR4.3).
- `inception/requirements-analysis/requirements.md` (NFR2, NFR5).

## Contesto

Un solo utente, il proprietario, con al massimo circa 200 bottiglie. La crescita che conta è quella della base offline, non degli utenti.

## Requisiti

| ID | Requisito | Verifica |
|---|---|---|
| NFR2.7 | Indice e confronto restano entro NFR2.1–NFR2.3 fino a 50.000 vini. Oltre 200.000 si riconsidera SQLite (D1). | benchmark con 50.000 vini sintetici, soglia CI ×2 come per NFR2.2 |
| NFR2.8 | Lo strumento di costruzione legge l'export CSV in streaming, senza caricarlo tutto in memoria. L'export completo di Open Food Facts supera i 9 GB non compresso. | test con un estratto: lettura riga per riga |
| NFR5.5 | "Cerca online" e il gradino online usano i limitatori **già esistenti**, senza duplicarli: `RequestBudget` (`lib/catalog/core/request_budget.dart`, 8 ricerche e 60 letture di prodotto in 60 secondi, sotto i limiti pubblicati di 10 e 100) e `OffCircuitBreaker` (5 minuti di pausa dopo 3 guasti). Con il budget esaurito si mostra lo stato `rateLimited` (BR4.3). | test: "Cerca online" passa da `RequestBudget`; test esistenti dei limitatori verdi |
| NFR5.8 | L'export di Open Food Facts si scarica a mano dal proprietario, al massimo una volta per rilascio, dal file pubblico indicato da Open Food Facts per i download completi, mai pagina per pagina dall'API. Nessun job CI lo scarica. | voce nella checklist di rilascio + revisione dei workflow |

## Motivazioni

- **50.000 vini.** Circa tre volte la base attesa. Copre la crescita di Open Food Facts per alcuni anni senza cambiare formato.
- **Limiti esistenti.** `RequestBudget` applica già 8 ricerche e 60 letture al minuto, sotto i limiti pubblicati di Open Food Facts (10 ricerche e 100 letture di prodotto al minuto). Il nuovo "Cerca online" ci passa sopra e non introduce un secondo contatore.
