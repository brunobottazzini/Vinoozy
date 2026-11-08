# Domande — Deployment Pipeline (pending-banner-fix)

Già deciso in `team.md` e già costruito nella prima versione, quindi non lo richiedo:
- **Strategia:** ogni merge in `main` produce un AAB firmato sul canale di test interno di Google Play (`release.yml`), che è lo staging. La produzione passa da `promote.yml`, con la tua approvazione e il rilascio graduale (20%, poi 100%).
- **Rollback:** si ferma il rilascio graduale e si pubblica una nuova versione corretta.
- **Smoke test:** avvio, accesso con Google e sincronizzazione, dalla build del test interno.
- **Flag di funzionalità:** nessuno. La correzione cambia solo un comportamento interno; non c'è nulla da accendere o spegnere.

## Q1. [Rilascio] Versione della correzione

L'app non è ancora mai stata pubblicata in produzione: non esiste un tag `v*`. Con quale versione esce questa correzione?

A) Entra nella prima versione `v0.1.0`, senza un numero a parte, perché nessun utente ha mai avuto la versione con il difetto (consigliata)
B) Versione a sé `v0.1.1`, dopo una `v0.1.0` pubblicata senza correzione
X. Other (please specify)

[Answer]: A
