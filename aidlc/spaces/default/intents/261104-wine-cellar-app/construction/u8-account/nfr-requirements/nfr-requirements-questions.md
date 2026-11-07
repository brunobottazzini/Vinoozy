# NFR Requirements — u8-account — Domande

Contesto:
- design funzionale di U8 approvato (`functional-spec.md` BR1.1–BR1.13 con i chiarimenti delle due revisioni, `rules.md`, `frontend-components.md`);
- `requirements.md`: NFR3 accessibilità, NFR4 sicurezza, NFR5 costo, NFR6 affidabilità, NFR7 qualità, NFR8 privacy;
- `contract-summary.md` (C3, C4);
- `team.md` (Testing Posture, Deployment);
- strumenti già presenti: test delle regole, emulatori, `RULES_FEATURES` in `promote.yml`, script degli ID delle regole.

Non ci sono domande aperte: sono scelte tecniche che derivano dal design e dalle regole del team. Le riassumo qui sotto per conferma.

## Consolidated Summary Confirmation

- **Velocità:**
  - presentazione, profilo e finestre di uscita si aprono entro 300 ms;
  - una cantina piena (500 vini presenti, 1.000 finiti, 2.000 bevute, 2 persone invitate) si cancella del tutto in **meno di 60 s** con una buona rete, con l'avanzamento sempre visibile;
  - l'attesa delle modifiche in coda dura al più 30 s.
- **Costo:** 0 €.
  - Ogni documento cancellato è una scrittura. Il caso peggiore usato per il dimensionamento (500 vini presenti, 1.000 finiti, 2.000 bevute) costa circa 3.500 scritture, contro le 20.000 gratuite al giorno. Con l'uso previsto dal proprietario (al più circa 200 bottiglie) il costo è molto più basso.
  - Nessuna funzione nel cloud.
  - GitHub Pages è gratuito.
- **Sicurezza (regole del cloud):**
  - `users`: cancellazione solo da parte dell'utente stesso. `deletionStartedAt` si scrive solo dall'utente, una volta sola, con l'ora del server, anche alla creazione del profilo.
  - `cellars`: cancellazione solo dal proprietario e solo senza inviti aperti.
  - Test sull'emulatore per ogni caso permesso e vietato; le regole di U1, U4 e U7 restano verdi.
  - Le scritture nuove dell'app sono segnate `requiresRules: "account"` e `RULES_FEATURES` diventa `sharing cellar account`: la promozione resta bloccata finché le regole non sono pubblicate.
- **Privacy:**
  - i report degli errori hanno solo motivi fissi (`account_delete_failed`, `account_signout_failed`, `account_reauth_failed`), mai email, nomi o identificativi;
  - la scheda "Sicurezza dei dati" di Google Play dichiara che l'utente può chiedere la cancellazione, nell'app e dalla pagina web;
  - l'informativa elenca i codici tecnici che restano nelle cantine altrui;
  - dopo la cancellazione, sul telefono non resta nulla dell'account: azzeramento di U1, file temporanei di U6, segnale locale tolto.
- **Affidabilità:**
  - ogni passo della cancellazione si può ripetere senza danni;
  - un'interruzione in qualsiasi punto si riprende al prossimo accesso;
  - un account appena creato non viene mai scambiato per uno da cancellare;
  - ogni errore ha "Riprova".
- **Accessibilità:** testo al 200%, TalkBack con l'avanzamento annunciato, contrasto ≥ 4,5:1, aree di tocco ≥ 48 dp, tre lingue, parola di conferma della lingua dell'app.
- **Dipendenze:** nessuna nuova. Riautenticazione con `google_sign_in` e Firebase Auth già presenti.
- **Pagina web:** pagina statica in `docs/account-deletion/` (HTML semplice, tre lingue), pubblicata con GitHub Pages; attivare GitHub Pages sul repository è un'azione tua. **Indirizzo email (scelto dal proprietario il 2026-11-06):** `bottazzinibruno@gmail.com`, per il momento; sarà visibile pubblicamente sulla pagina.
- **Qualità del codice:**
  - copertura ≥ 80% delle righe di `lib/account/` e del progetto, senza esclusioni;
  - ogni regola BR1.1–BR1.13 ha un test con l'ID nel nome;
  - test dei widget nelle tre lingue;
  - due test end-to-end nel job `e2e`, sugli emulatori:
    - uscita con modifiche in coda;
    - cancellazione completa di un account con una cantina condivisa, che verifica che non resti nulla nel cloud;
  - un test di ripresa dopo un'interruzione simulata.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
