# Runbook di rollback — Freemium e Plus

## 1. Spegnere una funzione: il modo più rapido

Con `tool/admin/set_policy.mjs` il cambio vale in pochi secondi per tutte le app, senza una nuova build:

| Problema | Comando | Effetto |
|---|---|---|
| Acquisti che non si verificano | `--purchases-enabled false` | La schermata Plus mostra «Plus arriverà presto». I Plus già attivi restano validi |
| Limite che blocca a torto | `--capacity-limit-enabled false` | Le regole non applicano più il limite. Il contatore resta aggiornato |
| Annunci con problemi | `--ads-enabled false` | Nessun nuovo caricamento; i banner aperti vengono rimossi |

Verifica: apri l'app su un telefono di prova e controlla che il comportamento sia cambiato.

## 2. App in produzione

Google Play non permette di tornare a una build già pubblicata (team.md).

1. `promote.yml` con `action: halt`: ferma il rilascio graduale.
2. Correzione su `main`, nuova versione sul test interno, smoke test.
3. `promote.yml` con la nuova versione.

## 3. Regole Firestore

1. `firebase-deploy.yml` con il ref dell'ultimo tag buono, per esempio il `v*` precedente.
2. **Attenzione:** le regole precedenti rifiutano il contatore che la nuova app scrive. Se l'app con Freemium è già in produzione, tornare indietro con le regole blocca le sue scritture. In quel caso:
   - correggi le regole in avanti con un nuovo tag;
   - oppure ferma prima il rilascio dell'app (§2).
3. Il controllo di `promote.yml` impedisce di promuovere una build con regole diverse da quelle pubblicate.

## 4. Cloud Functions

1. Sintomo grave, per esempio spesa anomala: la funzione `onBudgetAlert` scollega la fatturazione da sola al superamento del budget, con un certo ritardo. Puoi farlo anche a mano: Cloud Console → Fatturazione → **Disattiva la fatturazione** per `vinoozy-d6f45`. Le funzioni si fermano, mentre Firestore resta entro le quote gratuite.
2. Versione difettosa: `functions-deploy.yml` con il ref dell'ultimo tag buono.
3. Una funzione da togliere: `npx firebase functions:delete <nome> --region europe-west8 --project vinoozy-d6f45`.
4. Senza funzioni gli acquisti non si verificano: spegni prima `purchasesEnabled` (§1).

## 5. Plus regalato per errore

`node tool/admin/grant_plus.mjs revoke --email <email> --project vinoozy-d6f45 --credentials <file>`. I dati della persona restano tutti.

## 6. Migrazione del limite

`migrate_capacity.mjs` non cancella nulla e può essere rieseguito. Se i contatori risultano sbagliati:

1. `--capacity-limit-enabled false`;
2. ripeti la migrazione;
3. riaccendi il limite.

## Contatti

Il proprietario è l'unica persona coinvolta: decide e agisce. Per Play rivolgiti al supporto di Play Console, per Firebase e la fatturazione al supporto di Google Cloud Billing.
