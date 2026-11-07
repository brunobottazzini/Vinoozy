# Domande — CI Pipeline

Quello che `team.md` ha già deciso non lo richiedo:
- **strumento:** GitHub Actions, piano gratuito;
- **rami:** trunk-based su `main`, rami brevi, squash merge, tag `v*`;
- **controlli prima del merge:** formattazione, analisi, test, copertura all'80% senza esclusioni ed end-to-end, tutti bloccanti;
- **artefatti:** AAB firmato pubblicato sul canale di test interno di Google Play a ogni merge, produzione con la tua approvazione.

I workflow esistono già: `ci.yml` (6 job di controllo), `release.yml`, `promote.yml`, `firebase-deploy.yml`, `pages.yml`, più `dependabot.yml`. Restano queste scelte.

## Q1. [Rilascio] Risorse dell'emulatore nel job e2e
L'emulatore del job `e2e` usa core e RAM predefiniti. In Build and Test, con 1 core, i tempi erano 5–10 volte più lunghi e i test con limiti di tempo fallivano. I runner Linux gratuiti di GitHub hanno 4 vCPU e 16 GB. Come configuriamo l'emulatore?

A) `cores: 4` e `ram-size: 4096M` (consigliata: come nell'ultima corsa valida di Build and Test)
B) `cores: 2` e `ram-size: 3072M`, per lasciare risorse al resto del job
X. Other (please specify)

[Answer]: A

## Q2. [Qualità] Test instabile di U4 nel job bloccante
`cellar_test.dart` fallisce circa 3 volte su 5 per il difetto accettato di U4 NFR6.6. Con il job `e2e` bloccante, molti merge in `main` verrebbero fermati finché il difetto non è corretto. Le regole del team vietano di aggirare un controllo rosso. Come procediamo?

A) Il job resta bloccante così com'è. La correzione di U4 diventa il primo lavoro separato dopo la prima versione, prima di qualsiasi altro merge (consigliata: rispetta "un controllo rosso non si aggira")
B) Il job resta bloccante, ma è consentito un solo nuovo tentativo automatico del job `e2e` quando fallisce. Questo nasconderebbe in parte il difetto, quindi la sconsiglio
X. Other (please specify)

[Answer]: A

## Q3. [Sicurezza] Ricerca di segreti in CI
Il repository diventerà pubblico per la pagina di cancellazione su GitHub Pages. Oggi la ricerca di segreti (gitleaks) è un controllo da fare a mano una volta, prima di renderlo pubblico. La aggiungiamo anche alla CI, a ogni push?

A) Sì: un job `secrets` con gitleaks su tutta la storia, bloccante, senza costi (consigliata)
B) No: basta il controllo a mano prima di rendere pubblico il repository, più quello già presente su `google-services.json`, `config/firebase_prod.json` e keystore
X. Other (please specify)

[Answer]: A

## Q4. [Rilascio] Dependabot per il pacchetto di stima
`dependabot.yml` aggiorna le action, i pacchetti Dart della radice e gli strumenti npm, ma non il pacchetto `packages/estimation`. Lo aggiungiamo?

A) Sì, settimanale come gli altri (consigliata)
B) No, lo aggiorno a mano
X. Other (please specify)

[Answer]: A

## Consolidated Summary Confirmation

- **Emulatore del job `e2e`:** `cores: 4` e `ram-size: 4096M` in entrambi i passi di `reactivecircus/android-emulator-runner` (tentativo e riprova per mancato avvio). Nessun limite di tempo dei test cambia.
- **Test instabile di U4:** il job `e2e` resta bloccante, senza riprove sui test falliti. La correzione di U4 NFR6.6 è il primo lavoro separato dopo la prima versione, prima di altri merge in `main`.
- **Segreti:** nuovo job `secrets` in `ci.yml` con gitleaks su tutta la storia del repository, bloccante e gratuito. Si aggiunge ai controlli obbligatori di `main` (da 6 a 7). Resta anche il controllo a mano prima di rendere pubblico il repository.
- **Dependabot:** aggiunto `pub` per `/packages/estimation`, settimanale.
- **Resta com'è:**
  - `ci.yml` con `format`, `analyze`, `unit`, `estimation`, `rules`, `e2e` su ogni push e pull request verso `main`;
  - `release.yml` (AAB firmato sul canale di test interno a ogni merge);
  - `promote.yml` (produzione con la tua approvazione e rilascio graduale);
  - `firebase-deploy.yml` e `pages.yml` manuali con approvazione.
- **Documenti:** `ci-config.md` (workflow, trigger, job e segreti), `quality-gates.md` (ogni controllo bloccante con il comando di Build and Test che applica) e la verifica di fine Construction in `verification/phase-check-construction.md`.
- **Da fare a mano da te (fuori dalla CI):**
  - protezione di `main` con i 7 controlli obbligatori;
  - segreti di firma, Play e Firebase nei segreti di GitHub;
  - gitleaks prima di rendere pubblico il repository.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
