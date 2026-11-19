# Controllo di salute — Lingue dei paesi del vino

| Controllo | Stato | Evidenza |
|---|---|---|
| CI su `375a581` | Verde | run 44320859372 |
| Pubblicazione sul canale interno | Riuscita | run 44325641297, tag `build-5` |
| Durata del job `unit` (NFR2, ≤ 40 min) | 25 min 14 s | run 44320859372 |
| Test end-to-end in CI | Verdi | job `e2e` |
| Firestore, Functions | Invariati | Nessuna distribuzione |
| Crash ed errori in Crashlytics dopo l'installazione da parte dei tester | Da osservare | Firebase Console, nei giorni dopo la promozione ad Alpha |

Nessun allarme aperto. La salute in uso reale si valuta con Crashlytics quando la 0.3.0 arriva ai tester del test chiuso.
