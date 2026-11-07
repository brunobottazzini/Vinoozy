# NFR Design — u5-dashboard — Domande

Contesto: requisiti non funzionali di U5 approvati (`performance-requirements.md`, `security-requirements.md`, `tech-stack-decisions.md`), design funzionale di U5 (`functional-spec.md`, `rules.md`, `frontend-components.md`), codice esistente di U1 (`lib/app/`, `lib/cellar/`).

Nessuna domanda aperta. Le scelte di questo passo sono tecniche e derivano dai requisiti approvati. Le riassumo qui sotto per conferma.

## Consolidated Summary Confirmation

- **Organizzazione del codice** in `lib/dashboard/`:
  - un calcolo puro (`DashboardCalculator`) che in un solo passaggio sui vini produce lista e grafici;
  - un provider Riverpod che lo ricalcola solo quando cambiano i vini, il giorno o il selettore;
  - i widget, che mostrano solo dati già pronti.
- **Modifiche a U1:**
  - la shell dell'app apre il Cruscotto, con una barra in basso Cruscotto/Cantina;
  - il modello del vino legge in più produttore, tipologia, regione, denominazione e finestra, solo in lettura.

  I test di U1 restano verdi.
- **Giorno:** un piccolo servizio "oggi" avvisa a mezzanotte, ora legale compresa, e quando l'app torna in primo piano.
- **Grafici:** barre fatte con i widget standard. Ogni grafico ha un contenitore leggibile da TalkBack, e ogni barra dello stato è raggiungibile da sola, con la sua icona. I colori vengono dal tema e sono verificati da un test di contrasto.
- **Errori:**
  - un vino rovinato viene saltato e conta come "da stimare";
  - a Crashlytics arriva al massimo un evento con messaggio fisso;
  - un errore di lettura mostra "Riprova".
- **Controlli in CI:**
  - script per la sola lettura;
  - benchmark del calcolo;
  - copertura di `lib/dashboard/` almeno 80%;
  - test end-to-end in cui dopo l'accesso compare il Cruscotto.

  Le misure dei tempi si fanno sul telefono, a ogni versione.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
