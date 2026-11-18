# Avvisi

Decisione del proprietario (Q1): **bastano le email di GitHub**, nessun avviso
aggiuntivo nei workflow.

## Catena di consegna

| Avviso | Condizione | Gravità | Canale | Azione |
|---|---|---|---|---|
| CI fallita su `main` | run `ci` conclusa `failure` | P2 | email di GitHub all'autore del push | leggere il job rosso; un E2E con "On screen" indica cosa c'era a schermo |
| Release fallita | job `internal` di `release.yml` `failure` | P2 | email di GitHub | step `Check the play-internal configuration`: segreti; step `Versions`: credenziali Play (`play_api` uscita 3/4/5); upload: chiave di firma o permessi |
| Promozione in attesa | `promote.yml` in attesa di approvazione | informativa | email di GitHub ai revisori dell'ambiente | approvare solo dopo lo smoke test |
| Segreto esposto | nuova segnalazione di secret scanning | P1 | email di GitHub (sicurezza) | valutare e, se è una credenziale vera, ruotarla subito |

**Da verificare una volta** (proprietario): GitHub → Settings → Notifications →
System → Actions: "Notify me" su **Email** per i workflow falliti, solo quelli
avviati da te. È la voce "GitHub: notifiche email per i workflow falliti su
`main`" di `docs/firebase-setup.md` §7.

## App in produzione (invariati, già definiti)

Crashlytics (nuovi problemi, regressioni, velocity all'1% degli utenti in 1
ora), Cloud Monitoring (rifiuti delle regole Firestore > 50/ora, letture
giornaliere > 35.000), avviso di budget a 1 €: `docs/firebase-setup.md` §3 e §7.

## Escalation

Proprietario unico (Bruno Bottazzini): riceve tutti gli avvisi e decide.
Problemi della piattaforma: assistenza Google Play Console, supporto GitHub.
