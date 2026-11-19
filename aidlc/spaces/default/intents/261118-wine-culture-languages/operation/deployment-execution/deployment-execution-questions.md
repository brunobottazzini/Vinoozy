# Deployment Execution — Domande

Il rilascio in questo progetto è: merge in `main` → CI verde (format, analisi, test, copertura, end-to-end) → GitHub Actions costruisce il bundle firmato e lo pubblica sul canale di test interno di Google Play. La produzione resta una tua approvazione separata (`promote.yml`). Nessuna regola di Firestore cambia, quindi niente da distribuire su Firebase.

Nel repository ci sono anche modifiche tue non salvate in git che non fanno parte di questo lavoro: `docs/play-console-handoff.md`, `docs/release-checklist.md`, `distribution/google-play/data-safety.csv`, `distribution/google-play/beta-tester-instructions.txt`, `docs/github-config-handoff.md`, la cartella del lavoro `261111-actions-release-fix`, `.swp`.

## Q1. [Responsabile dei rilasci] Come portiamo il lavoro in `main`

A. Ramo di breve durata `wine-culture-languages`, commit del solo lavoro delle lingue, push e pull request: la CI gira sul ramo e, quando è verde, faccio lo squash merge in `main`. È la mia raccomandazione: segue la regola di squadra (un blocco, un commit in `main`) e la CI verifica end-to-end e durata prima che il codice entri in `main`.

B. Commit del lavoro delle lingue direttamente su `main` e push: la CI gira dopo, e se fallisce `main` resta rosso finché non correggiamo.

C. Preparo solo il commit in locale, sul ramo che scegli tu; il push e il merge li fai tu.

X. Other (please specify)

[Answer]: B

## Q2. [Responsabile dei rilasci] Versione dell'app

Oggi `pubspec.yaml` dice `0.2.1+3`; il numero di build lo genera GitHub Actions. Le lingue nuove sono una funzione nuova.

A. Passo a `0.3.0` (nuova funzione, versionamento semantico). È la mia raccomandazione.

B. Lascio `0.2.1`.

X. Other (please specify)

[Answer]: A

## Q3. [Responsabile dei rilasci] Le tue altre modifiche non salvate

A. Le lascio fuori dal commit, come sono ora sul disco. È la mia raccomandazione: non fanno parte di questo lavoro e le gestisci tu.

B. Le includo in un commit separato sullo stesso ramo, prima di quello delle lingue.

X. Other (please specify)

[Answer]: B
