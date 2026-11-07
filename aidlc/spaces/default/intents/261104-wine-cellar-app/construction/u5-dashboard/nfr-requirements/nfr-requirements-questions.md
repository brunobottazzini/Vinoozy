# NFR Requirements — u5-dashboard — Domande

Contesto: design funzionale di U5 approvato (`functional-spec.md`, `rules.md`, `frontend-components.md`), `requirements.md` (NFR2: cruscotto entro 2 secondi con 500 bottiglie; NFR3: accessibilità; NFR7: qualità), `team.md` (Testing Posture, Code Style).

Nessuna domanda aperta. Le scelte di questo passo sono tecniche e derivano dal design e dalle regole del team. Le riassumo qui sotto per conferma.

## Consolidated Summary Confirmation

- **Velocità:**
  - il cruscotto compare entro 2 secondi dall'apertura con 500 bottiglie e senza rete (NFR2), sul telefono di riferimento;
  - il calcolo di lista e grafici richiede meno di 50 ms;
  - lo scorrimento resta fluido;
  - il ricalcolo parte solo quando cambiano i vini o il giorno.
- **Grafici:** sono disegnati con i widget standard di Flutter, senza librerie esterne. Così il controllo su TalkBack, contrasto e testo ingrandito è completo, e non si aggiungono dipendenze.
- **Accessibilità (NFR3):**
  - descrizioni per TalkBack;
  - contrasto almeno 4,5:1 per il testo e 3:1 per le barre;
  - icone e numeri oltre al colore;
  - bersagli di almeno 48 dp;
  - testo ingrandito fino al 200% senza tagli.

  Tutto è verificato da test automatici nelle tre lingue.
- **Affidabilità:**
  - un vino con dati rovinati non blocca il cruscotto;
  - un errore di lettura mostra "Riprova";
  - durante la prima sincronizzazione non compare "cantina vuota".
- **Sicurezza e privacy:** il cruscotto legge soltanto. Non manda dati a nessuno, a parte un evento anonimo in Crashlytics per una finestra rovinata.
- **Qualità e test:**
  - test della logica di calcolo;
  - test dei widget in it, en e pt-BR;
  - copertura del codice del cruscotto almeno 80%;
  - test end-to-end in CI: dopo l'accesso compare il Cruscotto.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
