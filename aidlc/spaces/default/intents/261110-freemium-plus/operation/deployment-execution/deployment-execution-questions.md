# Deployment Execution — domande

Stato attuale. Niente è stato committato né pubblicato. Su `main` ci sono 118 file modificati o nuovi rispetto a `ee114e3`: tutto Freemium e Plus, più le tue modifiche precedenti già non committate (pubblicazione, privacy, CI, `docs/account-deletion/firebase-config.js` e altre). Firebase è ancora su Spark.

I controlli prima del rilascio sono tutti verdi (Build and Test): unit e widget, regole, funzioni, script, end-to-end di freemium, controllo della release, copertura all'88,11%. Non ci sono migrazioni di dati da eseguire adesso: `migrate_capacity.mjs` va lanciato solo più avanti, prima di accendere il limite.

## Q1. [Release engineer] Cosa pubblichiamo adesso?

Un merge su `main` fa partire la CI e poi `release.yml`, che carica un AAB firmato sul **test interno** di Play. Le regole Firestore nuove vanno pubblicate in produzione con `firebase-deploy.yml` e la tua approvazione, **prima** di promuovere l'app.

A. **Rilascio sul test interno.** Commit su un ramo `freemium-plus`, push, PR verso `main` con CI verde, squash merge (team.md). Poi pubblichi le regole con `firebase-deploy.yml`, approvando tu. Produzione, Blaze e funzioni restano per dopo.
B. **Solo il commit e la PR, senza merge.** Preparo ramo e PR. Merge e pubblicazioni le fai tu quando vuoi.
C. **Niente per ora.** Il codice resta non committato nella cartella e la pubblicazione è rimandata.
X. Other (please specify)

[Answer]: A

## Q2. [Release engineer] Cosa facciamo delle altre modifiche non committate?

Insieme a Freemium ci sono modifiche tue precedenti, non ancora committate, su pubblicazione, privacy, workflow e configurazione della pagina di cancellazione. Alcuni file, come `.github/workflows/ci.yml`, `release.yml` e le pagine `docs/privacy/`, contengono sia le tue modifiche sia quelle di Freemium. Separarle file per file non è possibile senza rischiare di perderne una parte.

A. **Un solo commit con tutto** (Freemium più le tue modifiche), con un messaggio che descrive entrambe le parti.
B. **Due commit**: prima le tue modifiche precedenti nei file che toccano solo quelle, poi Freemium con tutto il resto, compresi i file misti.
X. Other (please specify)

[Answer]: B

## Q3. [Release engineer] Come uniamo i due commit su `main`?

Seguito di Q1 e Q2. Emergono due vincoli:

- team.md prevede lo **squash merge**, che su `main` fonde i due commit in uno solo.
- Il primo commit da solo non si compila: le tue modifiche precedenti usano testi nuovi che stanno nei file di traduzione misti, finiti nel secondo commit. Non può quindi diventare una PR separata con la CI verde.

In più, su questo Mac non c'è la CLI `gh`. Posso fare il push del ramo, ma la PR e il merge li devi fare tu dal sito di GitHub.

A. **Rebase and merge sulla PR.** I due commit arrivano su `main` così come sono, separati. È un'eccezione allo squash di team.md, solo per questa volta.
B. **Squash merge come da regola.** Su `main` resta un solo commit; i due commit restano visibili solo nella cronologia della PR.
X. Other (please specify)

[Answer]: A
