# Deployment Execution — Domande

Pipeline usata: quella esistente del repository (`ci.yml` → `release.yml` sul canale di test interno di Google Play a ogni push su `main`; `promote.yml` per la produzione con approvazione manuale). Nessuna migrazione di dati, nessun servizio dipendente nuovo.

## Domanda 1

Come pubblicare la 0.4.0 sul canale di test interno?

A. Un solo commit su `main` con tutti i file non committati (tranne PDF dei tester, `.swp`, `config/firebase_prod.json`, `google-services.json`), poi push
B. Solo commit locale, push a cura del proprietario
C. Commit dei soli file di questo lavoro
X. Other (please specify)

[Answer]: A
