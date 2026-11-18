# Strategia di deployment

Fonte: `team.md` (Deployment), confermata dal codice dei workflow.

## Ambienti e promozione

| Passo | Ambiente | Chi decide | Criterio per passare al successivo |
|---|---|---|---|
| 1. Merge su `main` | — | il proprietario (squash merge) | i 7 job di `ci.yml` verdi |
| 2. Canale di test interno (staging) | `play-internal` | automatico | build caricata e tag `build-N` creato |
| 3. Smoke test | telefono del proprietario | il proprietario | avvio, accesso Google e sincronizzazione funzionano (`docs/release-checklist.md` §1) |
| 4. Produzione | `play-production` | il proprietario (approvazione nel job) | regole Firestore della build già distribuite; base dati vini e tabella denominazioni di rilascio (controlli di `promote.yml`) |

## Rilascio graduale

| Rilascio | `fraction` | Note |
|---|---|---|
| Prima pubblicazione in produzione | `1.0` | Google Play non ammette un rilascio graduale per la prima versione |
| Aggiornamenti | `0.2`, poi `action: complete` | criteri di avanzamento qui sotto |

**Criteri per passare dal 20% al 100%** (dopo almeno 24 ore al 20%):

- nessun nuovo crash in Crashlytics per la versione;
- nessun picco di errori di sincronizzazione o di rifiuti delle regole;
- nessuna recensione o segnalazione che indichi un blocco di avvio, accesso
  o sincronizzazione.

**Criteri di interruzione** (si esegue subito `halt`, vedi
`rollback-runbook.md`):

- un crash all'avvio o all'accesso con Google;
- scritture rifiutate o perse dopo la sincronizzazione;
- uno qualsiasi dei controlli dello smoke test che fallisce sulla build in
  produzione.

## Flag

Funzioni rischiose (annunci, limite di capacità, acquisti) restano dietro i
flag di `config/policy` e si accendono separatamente dal rilascio, con
`tool/admin/set_policy.mjs`. Spegnerle è il primo rimedio se un problema
riguarda solo una di quelle funzioni.

## Sicurezza

- Credenziali solo nei segreti degli ambienti GitHub; i valori non compaiono
  mai nei log (verifica senza stampa, messaggi con soli nomi).
- `release.yml` non lascia il token di scrittura in `.git/config` e lo passa
  solo allo step del tag.
- Account di servizio separati con permessi minimi: test interno e
  produzione.
