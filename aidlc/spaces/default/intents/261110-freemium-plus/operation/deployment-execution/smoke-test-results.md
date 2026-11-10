# Smoke test — Freemium e Plus

**Stato: da eseguire.** Il proprietario li esegue dopo il merge, sulla build del test interno installata dal Play Store, prima di qualsiasi promozione (team.md, Deployment).

## Prima della pubblicazione (eseguiti)

Emulatore Android con la Firebase Emulator Suite (Build and Test):

| Prova | Esito |
|---|---|
| `tool/e2e_freemium.sh`: regalo applicato senza azioni, limite a 15 con sblocco dal pannello sviluppatore, `reportUsage` | 3/3 verdi |
| `tool/check_release_build.sh`: marker degli strumenti sviluppatore assente nella release | OK |

## Dopo il merge (build del test interno)

Tutte le prove sono **da fare**.

| Prova | Atteso | Esito |
|---|---|---|
| Avvio | L'app parte e appare il marchio | ______ |
| Login Google | Accesso riuscito | ______ |
| Sincronizzazione | Un vino aggiunto offline compare in Firebase al ritorno della rete | ______ |
| Profilo | Riga «Gratuito», senza indicatori DEV | ______ |
| Schermata Plus | «Plus arriverà presto», nessun pulsante d'acquisto (`purchasesEnabled=false`) | ______ |
| Annunci | Nessun banner nella Dashboard (`adsEnabled=false`) | ______ |
| Limite | La sedicesima scheda si salva (`capacityLimitEnabled=false`) | ______ |
| Sequenza segreta | Due tocchi sul logo e poi la sequenza non aprono nulla nella build release | ______ |
| Regalo (facoltativo) | `grant_plus.mjs grant --email <tua> --no-expiry --reason owner_test --project vinoozy-d6f45`: il Profilo mostra «Plus in regalo» senza azioni | ______ |

Il regalo funziona anche su Spark, perché scrive direttamente in Firestore. Serve però che le regole nuove siano già pubblicate.
