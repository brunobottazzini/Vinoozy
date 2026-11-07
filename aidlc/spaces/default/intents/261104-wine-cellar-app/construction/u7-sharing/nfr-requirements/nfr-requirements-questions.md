# NFR Requirements — u7-sharing — Domande

Contesto:
- design funzionale di U7 approvato (`functional-spec.md`, `rules.md`, `frontend-components.md`);
- `requirements.md`: NFR4 sicurezza, NFR5 costo 0 €, NFR6 offline, NFR7 qualità, NFR8 privacy;
- `contract-summary.md` (C3, C4);
- `team.md` (Testing Posture, Deployment);
- strumenti già presenti: `test/rules/` con `@firebase/rules-unit-testing` e il job `rules` in CI.

Non ci sono domande aperte. Le scelte di questo passo sono tecniche e derivano dal design e dalle regole del team. Le riassumo qui sotto per conferma.

## Consolidated Summary Confirmation

- **Sicurezza (NFR4), la parte principale:**
  - ogni regola di condivisione è provata sugli emulatori con test automatici nel job `rules` già esistente:
    - la matrice di lettura e scrittura per proprietario, "solo lettura", "può modificare", invitata non ancora attiva, revocata ed estranea;
    - ogni passaggio di stato consentito e vietato di un invito;
    - il limite di 5 e il contatore;
    - l'email non verificata;
  - una persona invitata non vede le email delle altre persone invitate;
  - le regole nuove vanno in produzione solo con la tua approvazione.
- **Privacy (NFR8):**
  - si salvano solo l'email e il nome necessari all'invito;
  - un invito eliminato definitivamente sparisce dal cloud;
  - le email non finiscono mai in Crashlytics;
  - la scheda "Sicurezza dei dati" di Google Play va aggiornata, perché ora l'app conserva l'email di altre persone indicata dall'utente.
- **Velocità:**
  - con rete, invito, revoca, cambio di permesso e uscita danno l'esito entro 3 secondi, con un massimo di 10 secondi prima di "non riuscito, riprova";
  - una cantina condivisa compare entro 5 secondi dall'accesso;
  - con l'app aperta e online, una revoca o un cambio di permesso arriva all'altra persona entro qualche secondo.
- **Costo (NFR5):** al massimo 2 letture in più per ogni operazione controllata dalle regole e un ascolto in più per utente. Si resta molto sotto i limiti gratuiti; la stima è in un test.
- **Offline e affidabilità (NFR6):**
  - senza rete la cantina condivisa si consulta e si modifica come quella personale, secondo il permesso;
  - la gestione delle persone è disattivata;
  - un'operazione ripetuta dopo un errore non sbaglia il contatore.
- **Accessibilità e lingue:** stessi standard del Cruscotto per tutte le schermate nuove, cioè TalkBack, contrasto, bersagli di 48 dp e testo al 200%, nelle tre lingue.
- **Nuova dipendenza:** `share_plus`, il pacchetto ufficiale della community Flutter per la condivisione di Android, con versione fissata.
- **Qualità e test:**
  - test della logica di condivisione e dei widget in it, en e pt-BR;
  - copertura almeno 80%;
  - un test end-to-end con due utenti sugli emulatori: il proprietario invita, la persona vede la cantina, il proprietario revoca, la cantina sparisce.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
