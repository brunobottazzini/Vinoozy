# Infrastructure Design — u1-skeleton — Domande

Contesto: `security-design.md`, `performance-design.md`, `logical-components.md` (NFR Design di U1), `team.md` (Deployment, Testing Posture), `feasibility-assessment.md` (Firebase, Blaze con avviso a 1 €). Quasi tutto è già deciso: un progetto Firebase di produzione, l'emulatore per i test, GitHub Actions e il canale di test interno di Google Play. Restano due scelte che non si possono cambiare facilmente dopo.

## Q1. [Infrastruttura] Dove tenere i dati nel cloud

La posizione del database Firestore si sceglie una volta e **non si può più cambiare**. Le funzioni cloud (WineCatalog, u3) andranno nella stessa zona.

A. Milano (`europe-west8`): la più vicina, risposte più rapide dall'Italia, dati in Italia (consigliato)
B. Europa multi-regione (`eur3`): i dati sono copiati in più paesi europei, più resistenza ai guasti, ma costa di più oltre la quota gratuita
C. Stati Uniti (`us-central1`): più servizi disponibili, ma più lontano e dati fuori dall'Europa
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q2. [CI/CD] Il repository su GitHub è pubblico o privato?

Su GitHub Actions i minuti sono illimitati per i repository pubblici e 2.000 al mese per i privati. Con l'emulatore Android per i test da capo a fondo stimiamo circa 15–20 minuti per ogni merge, quindi un repository privato regge circa 100 merge al mese.

A. Privato: il codice resta riservato. I test con l'emulatore girano a ogni merge su `main` e a ogni richiesta di merge; i test veloci a ogni push (consigliato)
B. Pubblico: minuti illimitati, ma il codice è visibile a tutti
C. Not yet defined
X. Other (please specify)

[Answer]: X — "c'è già il repo lo sei dentro ed è pubblico" (repository esistente `github.com/brunobottazzini/Vinoozy`, pubblico)

## Consolidated Summary Confirmation

- **Regione (Q1):** Firestore e le funzioni cloud a Milano (`europe-west8`), una sola volta e per sempre.
- **Repository (Q2):** si usa il repository pubblico che esiste già, `brunobottazzini/Vinoozy`. I minuti di GitHub Actions sono illimitati, quindi tutti i controlli, compresi i test con l'emulatore Android, girano a ogni push e a ogni richiesta di merge.
- **Sicurezza del repository pubblico:**
  - nessuna chiave e nessuna configurazione di produzione nel codice, ma solo nei segreti di GitHub Actions;
  - le richieste di merge da fork esterni non ricevono i segreti e non pubblicano build;
  - `main` è protetto e accetta solo merge con tutti i controlli verdi;
  - è attiva la scansione dei segreti di GitHub.
- **Già deciso e applicato:**
  - un progetto Firebase di produzione (piano Blaze, avviso di spesa a 1 €) e l'emulatore per test e CI;
  - a ogni merge su `main`, una build firmata pubblicata sul canale di test interno di Google Play;
  - la produzione solo con la tua approvazione manuale e rilascio graduale;
  - regole di sicurezza distribuite in produzione solo con approvazione manuale.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
