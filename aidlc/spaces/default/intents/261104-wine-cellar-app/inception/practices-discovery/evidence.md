# Evidence — Practices Discovery

## Partecipanti

- Lead: `aidlc-pipeline-deploy-agent`, che ha lavorato da solo. Non ci sono agenti di supporto né file di contributo.
- Persona: ha risposto all'intervista e confermato il riepilogo ("Looks correct").

## Cosa è stato esaminato

| Fonte | Uso |
|-------|-----|
| `aidlc/spaces/default/memory/org.md` (Way of Working, Walking Skeleton, Testing Posture, Deployment, Code Style) | Default suggeriti per le proposte, non fatti del team |
| `aidlc/spaces/default/memory/team.md` | Vuoto: nessuna pratica già affermata |
| `aidlc/spaces/default/intents/261104-wine-cellar-app/aidlc-state.md` | Progetto greenfield, scope `mvp`, Test Strategy Standard |
| `.claude/scopes/aidlc-mvp.md` | Lo scope dichiara `skeleton: on` |
| `aidlc/spaces/default/intents/261104-wine-cellar-app/ideation/feasibility/constraint-register.md` | Vincoli C1–C10 |
| `aidlc/spaces/default/intents/261104-wine-cellar-app/ideation/scope-definition/scope-document.md` | Capacità della prima versione |
| `.claude/knowledge/aidlc-pipeline-deploy-agent/branching-strategies.md` | Elenco delle strategie di branching |
| `aidlc/spaces/default/intents/261104-wine-cellar-app/inception/practices-discovery/practices-discovery-questions.md` | Risposte dell'intervista Q1–Q10 e riepilogo confermato |

Nessun codice, nessuna configurazione di CI e nessun commit esistenti: il progetto è greenfield.

## Decisioni dell'intervista

| Domanda | Decisione | Dove si riflette |
|---------|-----------|------------------|
| Q1 Tecnologia | Flutter | Code Style, Testing Posture |
| Q2 Rami | Trunk-based su `main`, rami brevi con squash merge, un commit per blocco | Way of Working |
| Q3 Codice e CI | GitHub + GitHub Actions (piano gratuito) | Way of Working, Deployment |
| Q4 Scheletro funzionante | Sì, con la fetta proposta: login Google, un vino scritto a mano, salvataggio offline, sincronizzazione Firebase | Walking Skeleton |
| Q5 Test | Dopo il codice, strato per strato (`test-after`) | Testing Posture |
| Q6 Copertura | 80% delle righe, senza esclusioni, verificato in CI prima del merge | Testing Posture |
| Q7 End-to-end | In CI su emulatore Android | Testing Posture |
| Q8 Rilascio | Ogni merge su `main` va al canale di test interno di Google Play; produzione con approvazione del proprietario e rilascio graduale | Deployment |
| Q9 Firebase | Emulator Suite in locale e in CI, più un solo progetto di produzione | Testing Posture, Deployment |
| Q10 Regole rigide | Nessuna oltre al codice sempre in inglese | discovered-rules |

## Dichiarato vs dedotto

- **Dichiarato**: tutte le decisioni Q1–Q10. A queste si aggiungono, dalla descrizione e dal constraint-register, il codice in inglese (C5), Firebase con budget 0 €/mese e avviso a 1 € (C2, C6), il funzionamento offline (C3), l'account Google Play esistente (C9) e la UI in it, en, pt-BR.
- **Dedotto dal lead** (dettagli operativi coerenti con le risposte, da correggere se non vanno bene):
  - gli strumenti `flutter test --coverage` e `integration_test`, con `flutter_lints` in `analysis_options.yaml`;
  - i tag di versione su `main` e il semantic versioning;
  - un rilascio graduale indicativo di 20%, poi 100%;
  - lo smoke test manuale sul canale interno prima della produzione;
  - le regole Firebase versionate nel repository e distribuite con approvazione manuale;
  - i segreti solo in GitHub Actions.

## Incertezze non risolte

- **Minuti gratuiti di GitHub Actions**: l'emulatore Android per gli end-to-end, insieme alla build AAB, consuma molti minuti. I limiti gratuiti non sono stati verificati, e su repository privati potrebbero non bastare per un end-to-end a ogni merge. Va verificato in Construction e non si risolve abbassando il gate.
- **Copertura senza esclusioni**: includere codice generato e file di traduzione può rendere più difficile raggiungere l'80%. È una scelta esplicita della persona e va rispettata. Se diventa un problema, va riaperta come pratica, non aggirata.
- **Primo commit**: il repository non ha ancora commit, quindi il timestamp non può indicare un hash.
