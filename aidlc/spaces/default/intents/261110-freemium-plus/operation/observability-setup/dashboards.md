# Dashboard — Freemium e Plus

Si usano solo le console gratuite già disponibili, senza nuove dashboard da mantenere. La tabella elenca le viste da aprire e quando guardarle.

| Vista | Dove | Cosa guardare | Quando |
|---|---|---|---|
| Stabilità | Firebase Console → Crashlytics | Utenti senza crash (SLO 99,5%), problemi nuovi per versione | A ogni rilascio, poi una volta a settimana |
| Android vitals | Play Console → Qualità → Android vitals | Crash e ANR rispetto alle soglie di Google | Una volta a settimana |
| Quote Firestore | Firebase Console → Firestore → Utilizzo | Letture, scritture e cancellazioni giornaliere rispetto a 50k / 20k / 20k; traffico mensile rispetto a 10 GiB | Una volta a settimana; ogni giorno nelle 2 settimane di misurazione (studio §7.10) |
| Funzioni | Firebase Console → Functions → Dashboard | Chiamate, errori e tempi per funzione | Una volta a settimana dopo la pubblicazione |
| Spesa | Cloud Console → Fatturazione → Report | Costo per servizio (atteso 0 €) | Una volta al mese, e a ogni avviso di budget |
| Abbonamenti | Play Console → Monetizza → Abbonamenti e Ordini | Nuovi abbonati, annullamenti, rimborsi | Una volta al mese |
| Misuratore | Firestore Console → `usage/*/periods/<mese>` | Quanti account superano la soglia di 0,005 € (dato aggregato, nessun contenuto) | Durante le 2 settimane di validazione, prima di accendere gli annunci |

## Golden signals per il backend

Si guardano nella dashboard di Functions:

- **Latenza:** tempo di esecuzione di `verifyPurchase` e `reportUsage`.
- **Traffico:** chiamate al minuto.
- **Errori:** percentuale di esecuzioni con errore.
- **Saturazione:** istanze attive rispetto a `maxInstances: 2`.
