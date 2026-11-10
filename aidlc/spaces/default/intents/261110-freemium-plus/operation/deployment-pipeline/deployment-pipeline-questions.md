# Deployment Pipeline — domande

Il resto della pipeline di rilascio è già deciso (team.md): build firmata sul test interno a ogni merge, promozione manuale in produzione con rilascio graduale tramite `promote.yml`, regole Firestore pubblicate solo con approvazione tramite `firebase-deploy.yml` nell'ambiente `firebase-prod`. Questo lavoro aggiunge una cosa nuova da pubblicare: le Cloud Functions, dopo il passaggio a Blaze.

## Q1. [Release engineer] Come pubblichiamo le Cloud Functions?

Oggi `firebase-deploy.yml` pubblica solo regole e indici, dopo la tua approvazione nell'ambiente `firebase-prod`. Le funzioni richiedono permessi in più per l'account di servizio del deploy: Cloud Functions Admin, Service Account User, Artifact Registry, Cloud Build.

A. **Estendere `firebase-deploy.yml`** con una scelta in più all'avvio: «regole», «funzioni» oppure «entrambe». Resta la stessa approvazione manuale in `firebase-prod`, con la stessa verifica del tag o del commit su `main`. L'account di servizio del deploy riceve i permessi delle funzioni, descritti in `docs/blaze-switch.md`.
B. **Solo a mano dal Mac**, con `firebase deploy --only functions` seguendo `docs/blaze-switch.md`. Nessuna modifica ai workflow e nessun permesso in più all'account di GitHub.
X. Other (please specify)

[Answer]: A
