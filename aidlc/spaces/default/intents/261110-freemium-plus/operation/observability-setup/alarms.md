# Avvisi — Freemium e Plus

Ci sono solo avvisi gratuiti, inviati via email al proprietario. Ciascuno indica la gravità e il runbook da seguire. Il runbook generale è `../deployment-pipeline/rollback-runbook.md`.

| Avviso | Dove si configura | Condizione | Gravità | Cosa fare |
|---|---|---|---|---|
| Budget 50% / 90% / 100% di 1 € | Cloud Billing → Budget e avvisi (`docs/blaze-switch.md`) | Spesa effettiva o prevista | 50%: P3, 90%: P2, 100%: P1 | Controllare quale servizio costa in Fatturazione → Report. A 100% `onBudgetAlert` scollega la fatturazione: decidere se riattivarla dopo aver tolto la causa |
| Fatturazione scollegata | Log `onBudgetAlert` (messaggio «billing disabled») e email di Cloud Billing | La funzione ha agito | P1 | Le funzioni sono ferme e gli acquisti non si verificano. `set_policy.mjs --purchases-enabled false`, poi analisi della spesa |
| Nuovo problema di crash / regressione | Crashlytics → Avvisi (email) | Nuovo problema, problema riaperto o aumento improvviso | P2 | Se coinvolge Plus, il misuratore o gli annunci, spegnere il relativo interruttore (runbook §1). Valutare `promote.yml halt` |
| Velocità dei crash | Crashlytics → Velocity alert | Un problema colpisce oltre l'1% delle sessioni in 1 h | P1 | Fermare il rilascio graduale e correggere |
| Quota Firestore all'80% | Firebase Console → Firestore → Utilizzo (controllo settimanale, studio §7.2); su Blaze anche con il budget | Letture o scritture giornaliere ≥ 40.000 / 16.000 | P2 | Preparare quanto previsto dallo studio §8.7. Controllare il misuratore per uso anomalo |
| Android vitals oltre la soglia «cattivo comportamento» | Play Console → Android vitals (email automatiche di Play) | Tasso di crash o ANR oltre le soglie di Google | P1 | Come per la velocità dei crash |
| Errori delle funzioni | Cloud Console → Error Reporting (email gratuita per un nuovo errore) | Nuovo errore in `verifyPurchase`, `onPlayRtdn`, `reportUsage`, `reserveAdSlot`, `onBudgetAlert` | P2 | Leggere il log (query in `log-queries.md`). Per gli acquisti: spegnere `purchasesEnabled` se il problema blocca tutti |

## Gravità e tempi

Il proprietario è l'unico responsabile, quindi non c'è reperibilità a turni.

- **P1:** entro la giornata.
- **P2:** entro 2 giorni.
- **P3:** al controllo settimanale.

Dopo ogni P1, scrivere una breve revisione senza colpe in `docs/`: cronologia, causa, prevenzione.

## Da configurare a mano

1. Il budget con le sue soglie e gli avvisi email: `docs/blaze-switch.md`.
2. Gli avvisi di Crashlytics: Firebase Console → Crashlytics → impostazioni degli avvisi; attivare nuovi problemi, regressioni e velocità.
3. Le notifiche email di Error Reporting: Cloud Console → Error Reporting → Configura notifiche, dopo la prima pubblicazione delle funzioni.
4. Play Console → Impostazioni → Notifiche: Android vitals via email.
