# CI/CD Pipeline — u7-sharing

Fonti: `security-design.md`, `performance-design.md` e `logical-components.md` di U7; `functional-spec.md` di U7 e `components.md`; `.github/workflows/ci.yml`, `release.yml`, `firebase-deploy.yml`; `package.json`; riepilogo confermato in `infrastructure-design-questions.md`.

U7 non aggiunge job nuovi. Modifica i passi dei job esistenti di `ci.yml`, e `release.yml` non cambia. La pubblicazione delle regole usa `firebase-deploy.yml` così com'è. Tutti i controlli restano obbligatori prima del merge in `main` (team.md).

## 1. Modifiche a `ci.yml`

| Job | Passo | Cosa verifica | Requisito |
|---|---|---|---|
| `rules` | Il passo che oggi esegue `npx firebase emulators:exec … "npm --prefix test/rules test -- u1.rules.test.mjs compat/"` diventa `npm run test:rules`. Lo script in `package.json` diventa l'unica lista dei file: `u1.rules.test.mjs u7.rules.test.mjs compat/` | Regole di U1 invariate, regole di U7 (matrice 6×9, transizioni, contatore, campi, identità), compatibilità con le versioni pubblicate | NFR4.1–NFR4.6, NFR4.8, NFR4.9 |
| `rules` | Nuovo passo `tool/check_firestore_indexes.sh` | `firestore.indexes.json` contiene l'override su `members.inviteeEmail` con `queryScope: COLLECTION_GROUP` (controllo con `jq`, presente sui runner `ubuntu-latest`) | NFR4.7 |
| `rules` | Nuovo passo `tool/check_firestore_indexes_test.sh` | Il controllo passa su `tool/fixtures/firestore_indexes/ok.json` e fallisce su `missing.json` | NFR4.7 |
| `unit` | `flutter test --coverage` include `test/sharing/` e i test aggiornati di U1 e U5; nuovo passo `tool/check_coverage.sh 80 coverage/lcov.info lib/sharing/` | Logica, provider, schermate nelle tre lingue, nome di ripiego, conteggio degli ascolti, manifest senza `READ_CONTACTS`; copertura ≥ 80% | NFR3.x, NFR5.1, NFR6.x, NFR7.1–NFR7.3, NFR8.1 |
| `e2e` | Nessun passo nuovo: `flutter test integration_test` esegue anche `sharing_test.dart`, che usa `ownerRestClient()` per il proprietario | Invito, comparsa (≤ 15 s), permesso, revoca (≤ 15 s), con le regole vere | NFR2.2, NFR2.3, NFR7.4 |

Il job `rules` ha oggi un limite di 15 minuti. I test nuovi sono qualche centinaio di asserzioni sull'emulatore e aggiungono circa 1 minuto. Il job `e2e` (limite 45 minuti) aggiunge circa 1–2 minuti per il test con due utenti.

## 1-bis. Test di compatibilità e scritture nuove (correzione dopo la revisione, 2026-11-06)

`test/rules/compat/compat.rules.test.mjs` prova due direzioni:
- **(1)** le regole correnti accettano le scritture di ogni versione registrata dell'app;
- **(2)** le scritture dell'app corrente passano le regole dell'ultimo tag `v*`, cioè quelle in produzione.

Le scritture nuove di U7 (inviti, attivazione, revoca, uscita, contatore) e l'eliminazione dei vini **non possono** passare (2), perché le regole in produzione non le conoscono finché non si pubblicano. Le regole si pubblicano dopo il merge, quindi (2) fallirebbe sempre.

**Soluzione:**
- in `app-writes.json` ogni scrittura può avere il campo `"requiresRules": "<id della funzione>"` (per U7, `"sharing"`). La direzione (2) **salta** le scritture con quel campo e lo scrive nel log del test. La direzione (1) le prova tutte, contro le regole correnti;
- le scritture di U1 non hanno il campo, quindi restano controllate in entrambe le direzioni: una regressione per il proprietario continua a bloccare il merge;
- il permesso di saltare non è libero: il campo `requiresRules` è ammesso solo se lo stesso id compare nel controllo dell'ordine di pubblicazione (§2), così ogni scrittura saltata è coperta da quel controllo;
- dopo la prima pubblicazione delle regole con la condivisione, il primo tag `v*` successivo contiene già le regole nuove. A quel punto si toglie il campo e le scritture di U7 tornano in entrambe le direzioni.

## 2. Pubblicazione

Il flusso è lo stesso delle altre unità, con un passo in più **prima** della promozione:
1. **Merge su `main`:** `release.yml` costruisce l'AAB firmato e lo pubblica sul test interno.
2. **Regole e indice:** avvio manuale di `firebase-deploy.yml` con il commit di `main` o il tag `v*`, approvazione dell'ambiente `firebase-prod`. Il workflow pubblica `firestore.rules` e `firestore.indexes.json`.
3. **Indice "Abilitato"** nella console, poi la prova con due telefoni (`monitoring-design.md` §4).
4. **Promozione** in produzione con `promote.yml`, con rilascio graduale.

**L'ordine è imposto dai workflow, non solo dalla checklist:**
- **`firebase-deploy.yml`, job `rules`:**
  - la lista fissa `u1.rules.test.mjs compat/` diventa `npm run test:rules`, la stessa lista della CI, così i test di U7 girano anche prima della pubblicazione in produzione;
  - si aggiungono `tool/check_firestore_indexes.sh` e il suo test.
- **`firebase-deploy.yml`, job di pubblicazione:** usa già `environment: firebase-prod`, quindi GitHub registra una *deployment* con il commit pubblicato.
- **`promote.yml`, nuovo passo prima della promozione:**
  1. con `gh api repos/{owner}/{repo}/deployments?environment=firebase-prod` legge l'ultima pubblicazione riuscita delle regole e il suo commit;
  2. ricava il commit della build da promuovere dal tag `build-<versionCode>`, che `release.yml` crea già sul commit esatto di ogni build;
  3. confronta i blob di `firestore.rules` e `firestore.indexes.json` nei due commit (`git rev-parse <sha>:firestore.rules`);
  4. se sono diversi, si ferma con "Pubblica prima le regole con firebase-deploy.yml".

  Così una versione dell'app non va in produzione con regole o indici diversi da quelli pubblicati.
- **Indice "Abilitato":** non è verificabile dal workflow senza nuovi permessi. Resta nella checklist (§1-quater) e la promozione richiede comunque l'approvazione del proprietario.

## 3. Rollback

- **App:** fermare il rilascio graduale e pubblicare una correzione, che passa dal test interno.
- **Regole:** `firebase-deploy.yml` con il tag precedente. Effetti in `infrastructure-specification.md` §6.
- **Controllo di CI rotto per un motivo esterno** (per esempio una nuova versione dell'emulatore): si corregge il test o la configurazione in un blocco nuovo. Non si toglie il controllo e non si abbassano le soglie.
