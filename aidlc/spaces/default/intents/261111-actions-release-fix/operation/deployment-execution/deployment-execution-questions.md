# Domande sull'esecuzione del deployment

Stato verificato il 12/11/2026 leggendo solo i nomi: l'ambiente `play-internal`
non ha segreti né la variabile `GOOGLE_SERVER_CLIENT_ID`; `play-production` non
esiste; il repository non ha ruleset su `main`. Nessuna migrazione di database
è necessaria (le regole Firestore non cambiano in questo lavoro).

## Q1. [Proprietario] Come porto il codice su `main`?

`team.md` prevede un ramo breve e uno squash merge, con la CI verde prima del
merge. Il merge su `main` avvia `release.yml`.

A. Creo un ramo breve, faccio commit e push e apro una pull request; lo squash merge lo fai tu quando la CI (con l'E2E) è verde
B. Creo ramo, commit, push e pull request, e faccio io lo squash merge quando la CI è verde
C. Commit diretto su `main` e push
X. Other (please specify)

[Answer]: C

## Q2. [Proprietario] I segreti: quando li configuri?

Senza segreti, dopo il merge `release.yml` si fermerà nel nuovo step di
verifica con l'elenco degli 8 nomi mancanti: è la prova di FR1 in CI, ma la
release sul canale interno (FR6.1) resterà da verificare.

A. Prima del merge: li configuro con `docs/github-actions-setup.md` e ti dico quando ho finito, così la prima release dopo il merge è quella vera
B. Dopo il merge: guardiamo il messaggio della verifica, poi li configuro e rilanci la release
C. Più avanti, fuori da questo lavoro: per ora va bene la verifica che fallisce in modo leggibile
X. Other (please specify)

[Answer]: A

## Q3. [Proprietario] Quali file non di questo lavoro includo nel commit?

Nel tuo albero di lavoro ci sono modifiche tue non committate:
`distribution/google-play/data-safety.csv`, `docs/release-checklist.md`,
`docs/play-console-handoff.md` (dove ho aggiunto anche una riga di rimando) e i
file nuovi `docs/github-actions-handoff.md` e
`distribution/google-play/beta-tester-instructions.txt`. I file
`firestore-debug.log` e `android/local.properties`, riscritti dagli strumenti
locali, e `.swp` restano comunque fuori.

A. Solo i file di questo lavoro più `docs/github-actions-handoff.md` (il documento di partenza); in `docs/play-console-handoff.md` metto solo la mia riga di rimando, le tue modifiche restano non committate
B. I file di questo lavoro e tutte le tue modifiche elencate sopra
C. Solo i file di questo lavoro; `docs/play-console-handoff.md` resta tutto fuori dal commit
X. Other (please specify)

[Answer]: A, più la rotazione della chiave web Firebase segnalata da GitHub in `docs/account-deletion/firebase-config.js` (richiesta del proprietario, 12/11/2026)

## Q4. [Proprietario] La chiave web Firebase segnalata da GitHub (alert #1): ruotarla?

La chiave sta in `docs/account-deletion/firebase-config.js` ed è pubblica per
necessità, perché la pagina pubblicata deve contenerla. È già limitata ai
referrer `brunobottazzini.github.io` e `vinoozy-d6f45.firebaseapp.com` e a 4 API
(`docs/firebase-setup.md` §10). Una chiave nuova finirebbe di nuovo nella
pagina pubblica.

A. Ruota la chiave
B. Non ruotare: verifica dei log e chiusura della segnalazione come chiave pubblica della pagina
C. Prima verifichiamo i limiti in Google Cloud, poi decidiamo
X. Other (please specify)

[Answer]: B
