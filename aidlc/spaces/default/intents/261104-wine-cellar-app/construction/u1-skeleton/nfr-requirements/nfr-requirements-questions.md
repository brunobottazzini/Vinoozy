# NFR Requirements — u1-skeleton — Domande

Contesto: `functional-spec.md` e `rules.md` (U1), `requirements.md` (NFR1–NFR8), `contract-summary.md` (C3), `team.md` (stack, CI, segreti). Quasi tutti i requisiti non funzionali di U1 sono già decisi: tempi, accessibilità, regole di sicurezza, costo 0 €, copertura 80%. Restano due scelte che toccano la privacy e la protezione del cloud.

## Q1. [Sicurezza] Proteggere il database da app false

La configurazione Firebase dentro l'app è pubblica per natura. Le regole di sicurezza impediscono a chiunque di leggere i dati altrui, ma qualcuno potrebbe usare il progetto con un'app falsa e consumare la quota gratuita. Firebase App Check (gratuito, usa Play Integrity su Android) accetta solo richieste che arrivano dalla nostra app.

A. Attivare App Check già nello scheletro, in modalità obbligatoria dopo aver verificato che funziona (consigliato: protegge il budget di 0 € fin da subito)
B. Attivarlo più avanti, prima della pubblicazione in produzione
C. Non usarlo: bastano le regole di sicurezza
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q2. [Osservabilità] Segnalazione dei crash

Firebase Crashlytics (gratuito) invia un rapporto quando l'app si blocca: modello del telefono, versione dell'app e punto del codice. Non invia email, nomi né dati della cantina. Senza, sappiamo dei crash solo se qualcuno ce li racconta.

A. Attivare Crashlytics senza identificare l'utente nei rapporti (consigliato: dati minimi, coerente con NFR8)
B. Attivare Crashlytics collegando i rapporti all'ID dell'utente, per capire chi ha il problema
C. Nessuna segnalazione automatica dei crash
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Consolidated Summary Confirmation

- App Check (Q1): attivo già nello scheletro con Play Integrity; prima in modalità di controllo, poi obbligatorio per Firestore dopo la verifica. Nei test si usa il provider di debug dell'emulatore.
- Crash (Q2): Crashlytics attivo, senza l'ID dell'utente nei rapporti.
- Già deciso e applicato a U1:
  - prestazioni: avvio, salvataggio e indicatore offline in tempi da telefono di fascia media;
  - sicurezza: solo il proprietario accede a `cellars/{uid}` e `users/{uid}`; nessun segreto nel repository; connessioni cifrate;
  - accessibilità WCAG AA; durabilità offline;
  - costo 0 € con avviso a 1 €; copertura 80% senza esclusioni;
  - stack: Flutter, Firebase Auth (Google), Firestore offline.
- Da risolvere qui, perché aperti dal design approvato: cantina creata con una regola basata sull'ID uguale all'account; modifiche in coda di un altro account controllate prima del cambio di utente; errori di sincronizzazione gestiti in un unico punto.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
