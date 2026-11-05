# Scope Document — Vinoozy (prima versione)

Fonti: `intent-statement.md`, `feasibility-assessment.md`, `constraint-register.md`, risposte in `scope-definition-questions.md`.

## Obiettivo della prima versione

Non perdere nessuna bottiglia oltre la sua finestra ideale e avere l'inventario allineato alla cantina reale, aggiungendo una bottiglia in meno di 30 secondi (intent-statement).

## Dentro lo scope

| Capacità | Origine |
|----------|---------|
| Login con account Google | intent-statement; feasibility-assessment (login Apple rimandato con iPhone) |
| Inserimento di un vino scrivendone il tipo (es. "Barolo annata 2016") | intent-statement |
| Inserimento da foto dell'etichetta, con conferma dell'utente | intent-statement, Q6 |
| Inventario delle bottiglie (quantità per vino) | intent-statement |
| Stima automatica del momento ideale: base dati esterna, poi regole interne, con indice di fiducia | intent-statement, constraint-register C4 |
| Cruscotto con grafici: stato (da aspettare / pronte / oltre il picco), picchi per anno, tipologia o regione | intent-statement, Q2 |
| Avvisi nell'app: bottiglie vicine alla fine della finestra evidenziate nel cruscotto | Q1, Q6 |
| Bottiglia bevuta: storico con voto e note | Q4 |
| Abbinamento cibo-vino | intent-statement, Q6 |
| Condivisione della cantina con un'altra persona, con permessi | intent-statement, Q6 |
| Funzionamento offline con sincronizzazione | constraint-register C3 |

## Fuori dallo scope

| Esclusione | Origine |
|------------|---------|
| Valore economico e prezzi di mercato | intent-statement |
| Pubblicazione per altri appassionati | intent-statement |
| Versione iPhone e login Apple (arrivano con l'account Apple Developer) | constraint-register C7 |
| Notifiche sul telefono | Q1 |
| Posizione della bottiglia in cantina | Q3 |

## Vincoli che delimitano lo scope

- Budget cloud 0 €/mese, Firebase, solo Android (constraint-register C2, C6, C1).
- Nessuna scadenza (constraint-register C8).

## Assumptions & Open Questions

None.
