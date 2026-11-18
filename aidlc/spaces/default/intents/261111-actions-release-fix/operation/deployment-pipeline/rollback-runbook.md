# Runbook di rollback

Google Play non permette di tornare a una build già pubblicata. Il rollback
consiste nel fermare la diffusione, poi pubblicare una nuova versione con la
correzione (`team.md`, Deployment).

## 1. Produzione con rilascio graduale in corso

1. Actions → **promote** → Run workflow: `versionCode` della build,
   `action: halt` (`fraction` è ignorata).
2. Il job legge la traccia di produzione e porta a `halted` solo il rilascio
   `inProgress` di quel `versionCode`, lasciando la percentuale raggiunta e la
   versione completa precedente. Se non c'è un rilascio in corso, esce con
   "no staged rollout in progress for versionCode N".
3. In alternativa, dalla Play Console: Release → Produzione → "Interrompi
   l'implementazione".
4. Verifica: in Play Console il rilascio risulta "interrotto"; i nuovi utenti
   ricevono la versione completa precedente.

## 2. Problema limitato a una funzione dietro un flag

1. Spegni il flag in `config/policy` con `tool/admin/set_policy.mjs`
   (`adsEnabled`, `capacityLimitEnabled` o `purchasesEnabled`).
2. Verifica sul telefono che la funzione non sia più attiva (la policy arriva
   con il listener di Firestore).

## 3. Correzione

1. Correggi su un ramo breve e fai lo squash merge su `main` con la CI verde.
2. `release.yml` carica la nuova build sul canale interno; ripeti lo smoke
   test.
3. Promuovi la nuova build con `fraction: 0.2`, poi `complete`.

## 4. Canale di test interno

Non serve un rollback: si carica una nuova build. Se una build interna è
difettosa, la si sostituisce con la successiva.

## 5. Se la release automatica fallisce

| Messaggio nel job | Significato | Rimedio |
|---|---|---|
| "The play-internal configuration is incomplete (N problem(s))" | segreti o variabile mancanti o non validi | sistemali seguendo `docs/github-actions-setup.md`, poi rilancia la release (rerun: stesso commit) |
| `play_api: ... key file ...` (uscita 3) | chiave dell'account di servizio assente o non valida | sostituisci il segreto `PLAY_INTERNAL_SA_JSON` |
| `play_api: Google Play authentication failed ...` (uscita 4) | chiave revocata o account disattivato | crea una nuova chiave in Google Cloud e aggiorna il segreto |
| `play_api: Play API ... failed with HTTP 403` (uscita 5) | permessi Play mancanti per l'account | in Play Console concedi "Rilascia nei canali di test" all'account, solo sull'app Vinoozy |

Nessun file di credenziale resta sul runner: lo step `Remove secret files`
gira sempre (`if: always()`).

## Contatti ed escalation

Proprietario unico: Bruno Bottazzini (decide halt, correzione e promozione).
Supporto esterno: Google Play Console (assistenza sviluppatori) per problemi
della piattaforma.
