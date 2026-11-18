# Domande sulla pipeline di deployment

Nessuna nuova domanda: le scelte che questa fase dovrebbe chiedere sono già
state decise e affermate dal proprietario in `team.md` (sezione Deployment) e
nelle risposte di Requirements Analysis. Per non ripetere domande già
risposte, qui ne registro la fonte.

| Argomento | Decisione già presa | Fonte |
|---|---|---|
| Strategia di deployment | canale di test interno di Google Play come staging a ogni merge su `main`; produzione con rilascio graduale (20%, poi 100%) | `team.md` Deployment (Q8) |
| Gate di promozione | CI verde su `main` → `release.yml` (canale interno) → smoke test sul telefono → `promote.yml` con approvazione del proprietario | `team.md` Deployment; Q2 di Requirements Analysis (`play-production` completo) |
| Approvazione della produzione | approvazione obbligatoria del proprietario nell'ambiente `play-production` | `team.md` Deployment; Q5 di Requirements Analysis (lo crea il proprietario) |
| Rollback | stop del rilascio graduale (`promote.yml` `halt`), poi nuova versione con la correzione che passa dal canale interno | `team.md` Deployment |
| Feature flag | flag remoti in `config/policy` (`adsEnabled`, `capacityLimitEnabled`, `purchasesEnabled`), cambiati solo dagli script admin del proprietario; nessun servizio di flag esterno | codice (`lib/plan/domain/plan_policy.dart`, `tool/admin/set_policy.mjs`) |
| Credenziali | solo segreti degli ambienti GitHub, inseriti dal proprietario | `team.md` Deployment; Q1 di Requirements Analysis |
