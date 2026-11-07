# CI/CD Pipeline — u4-cellar

Fonti: `security-design.md`, `performance-design.md` e `logical-components.md` di U4; `functional-spec.md` di U4 e `components.md`; `.github/workflows/ci.yml`, `release.yml`, `firebase-deploy.yml`, `promote.yml`; `package.json`; riepilogo confermato in `infrastructure-design-questions.md`.

U4 non aggiunge job. Aggiunge passi ai job esistenti di `ci.yml` e cambia una variabile di `promote.yml`. `release.yml` e `firebase-deploy.yml` non cambiano. Tutti i controlli restano obbligatori prima del merge in `main` (team.md).

## 1. Modifiche a `ci.yml`

| Job | Passo | Cosa verifica | Requisito |
|---|---|---|---|
| `rules` | `npm run test:rules`: lo script in `package.json` aggiunge `u4.rules.test.mjs` (`u1 u7 u4 compat/`) | Campi e forme dei vini, backfill, aggiornamento ed eliminazione delle bevute (10 minuti, `resource != null`), flag della cantina, regole di U1 e U7 invariate, compatibilità | NFR4.1–NFR4.7, NFR4.9, NFR8.1 |
| `rules` | `tool/check_firestore_indexes.sh` (esistente, oggi controlla solo `members.inviteeEmail`) controlla anche l'indice composito di `drinkingRecords`, con un messaggio per ogni indice mancante. Il test usa `ok.json` aggiornato; `missing.json` continua a fallire con il messaggio di `members.inviteeEmail`; il nuovo `missing_history.json` fallisce con quello dello Storico | L'indice dello Storico non può sparire dal file | NFR4.8 |
| `analyze` | **File nuovi:** `tool/check_rule_ids.sh BR1. 20 test/cellar test/rules/u4.rules.test.mjs`, il suo test `tool/check_rule_ids_test.sh` e le cartelle di prova `tool/fixtures/rule_ids/ok/` e `missing_br1_1/`, creati in Code Generation | Ogni regola da BR1.1 a BR1.20 è citata in almeno un test; `BR1.10` non conta come `BR1.1` | NFR7.2 |
| `unit` | `flutter test --coverage` include `test/cellar/`; nuovo passo `tool/check_coverage.sh 80 coverage/lcov.info lib/cellar/` | Logica pura, repository, provider, schermate nelle tre lingue; copertura ≥ 80% | NFR3.x, NFR6.x, NFR7.1, NFR7.3, NFR7.5 |
| `unit` | `dart run benchmark/cellar_benchmark.dart`, accanto agli altri benchmark | Filtri ≤ 20 ms e finestra effettiva ≤ 5 ms su 500 vini; `exit(1)` oltre la soglia | NFR2.1, NFR2.4 |
| `e2e` | Nessun passo nuovo: `flutter test integration_test` raccoglie `cellar_test.dart` e `concurrent_drink_test.dart` | Inserimento, doppione, bevuta e Annulla, Storico, offline e ritorno; due bevute contemporanee sullo stesso vino con le regole vere | NFR6.3, NFR6.6, NFR7.4 |

`integration_test_perf/cellar_perf_test.dart` resta fuori dalla CI: si esegue a mano sul telefono per la misura dello scorrimento.

Tempi stimati:
- **`rules`** (limite 15 minuti): circa 1 minuto in più.
- **`unit`:** pochi secondi per il benchmark.
- **`e2e`** (limite 45 minuti): circa 2–3 minuti in più.

## 2. Ordine di pubblicazione

1. **Merge su `main`:** `release.yml` costruisce l'AAB firmato e lo pubblica sul test interno.
2. **Regole e indice:** avvio manuale di `firebase-deploy.yml` con un tag `v*` o un hash completo, e approvazione di `firebase-prod`. Il workflow esegue `npm run test:rules`, quindi anche i test di U4, e i controlli degli indici prima di pubblicare.
3. **Indice "Abilitato"** nella console, poi la prova della checklist §1-quinquies.
4. **Promozione** con `promote.yml`, con rilascio graduale.

**Blocco automatico:**
- **`promote.yml`:** `RULES_FEATURES` passa da `sharing` a `sharing cellar`.
  - Il passo "The rules of the build are the deployed ones" confronta già `firestore.rules` e `firestore.indexes.json` della build con quelli dell'ultima pubblicazione riuscita, e si ferma se sono diversi.
- **`test/rules/compat/app-writes.json`:** si aggiunge una nuova versione registrata, `u4-cellar`, con le scritture dell'app nuova. Portano `"requiresRules": "cellar"`:
  - ogni creazione di vino, perché porta `matchKey`;
  - **ogni scrittura che dipende da un vino creato così** (bottiglie, modifica, stima, bevuta, unione, eliminazione), perché nella direzione (2) quel vino non esisterebbe;
  - il backfill;
  - la bevuta con `condition`;
  - aggiornamento ed eliminazione delle bevute;
  - il flag della cantina.
  
  Le scritture delle versioni già registrate restano come sono, senza il campo, e continuano a essere provate in entrambe le direzioni.
- **Direzioni del test di compatibilità:**
  - la direzione (2) salta queste scritture solo perché `cellar` compare in `RULES_FEATURES`; il test "ogni `requiresRules` è protetto" lo verifica;
  - la direzione (1) le prova tutte contro le regole correnti.
- **Dopo la prima pubblicazione** delle regole di U4, il primo tag `v*` successivo contiene già le regole nuove. A quel punto si tolgono i campi `requiresRules: "cellar"` e le scritture tornano in entrambe le direzioni, come per U7.

## 3. Segreti

Nessun segreto nuovo. Firma, Play e Firebase restano nei segreti di GitHub Actions (team.md). I test usano solo l'emulatore e non chiamano mai Open Food Facts reale.

## 4. Rollback

- **App:** fermare il rilascio graduale e pubblicare una correzione, che passa dal test interno.
- **Regole:** `firebase-deploy.yml` con il tag precedente **solo prima** della promozione dell'app. Dopo l'inizio della promozione si corregge in avanti, perché Play non ritira le build già installate (`infrastructure-specification.md` §6).
- **Controllo di CI rotto per un motivo esterno:** si corregge il test o la configurazione in un blocco nuovo. Non si toglie il controllo e non si abbassano le soglie.
