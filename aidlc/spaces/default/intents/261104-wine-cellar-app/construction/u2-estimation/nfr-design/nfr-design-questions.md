# NFR Design — u2-estimation — Domande

Contesto: `performance-requirements.md`, `security-requirements.md`, `tech-stack-decisions.md` (NFR Requirements di U2, approvati), `functional-spec.md`, `contract-summary.md` (C2), revisione 2 delle NFR Requirements (READY, con 4 punti minori da chiudere qui).

Nessuna domanda aperta. U2 è una libreria pura senza interfaccia, rete o dati salvati, quindi le scelte di questo passo sono tecniche e derivano dai requisiti approvati. Le decisioni prese sono riassunte qui sotto per conferma.

## Consolidated Summary Confirmation

- Organizzazione del pacchetto `packages/estimation`: un solo punto d'ingresso pubblico (`estimation.dart`) con le quattro funzioni di C2 e i tipi; dentro, parti separate per controllo degli ingressi, riconoscimento del nome, finestra, stato, abbinamenti e tabelle. L'app vede solo il punto d'ingresso.
- Tabelle: costanti Dart in `tables.dart`. L'indice degli alias per il riconoscimento si prepara una sola volta, alla prima chiamata, in una variabile `final` di primo livello, e poi si riusa. Un test verifica che le chiamate successive usino lo stesso indice e lo script di purezza verifica che nessuna funzione rilegga le tabelle per costruire strutture (punto minore della revisione su NFR2.2).
- Velocità: il budget CI di 10 ms per 500 vini si divide così: riconoscimento dei nomi al massimo 4 ms, il resto per finestra, stato e abbinamenti (punto minore su NFR2.3). Sul tuo telefono la soglia resta 25 ms.
- Ingressi non validi: tutte e quattro le funzioni di C2, compresa `needsRefinement`, controllano gli ingressi e danno solo un errore di argomento con un codice stabile (per esempio `emptyName`, `vintageOutOfRange`, `missingReferenceYear`, `invalidWindow`), così U4 sa cosa è successo senza leggere testi (punto minore su NFR4.2). I test casuali con seme fisso coprono tutte e quattro le funzioni.
- Purezza: nessun orologio, numero casuale, rete, disco o stato globale modificabile; uno script in CI controlla import, parole vietate e dipendenze, e un test controlla che stessi ingressi diano sempre lo stesso risultato.
- Dati personali: i tipi del pacchetto non hanno campi per email, uid o posizione; un test lo verifica.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
