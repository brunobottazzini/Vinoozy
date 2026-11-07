# Monitoring Design — u1-skeleton

Fonti: `security-design.md` (§7 Crashlytics, App Check, budget), `performance-design.md`, `infrastructure-specification.md`, `team.md` (Deployment). U1 non ha un'unità di osservabilità dedicata: il monitoraggio usa solo strumenti gratuiti di Firebase, Google Cloud e Google Play, senza server da gestire.

## Metrics & KPIs

| Metric | Source | Threshold | Why it matters |
|--------|--------|-----------|----------------|
| Utenti senza crash | Crashlytics | ≥ 99% su 28 giorni | Stabilità dell'app |
| Tasso di ANR (app bloccata) | Google Play Console, Android vitals | < 0,47% (soglia di Google Play) | Sotto questa soglia l'app non viene penalizzata dal Play Store |
| Scritture rifiutate (`SyncRejected`) | Crashlytics, evento non fatale da `ErrorReporter`, uno per ogni voce che diventa `rejected` | Atteso 0; ogni nuovo evento genera un alert | Segnala regole troppo strette o un'app non aggiornata |
| Richieste verificate da App Check | Console App Check | ≥ 99% per 7 giorni prima di renderlo obbligatorio | Condizione di NFR4.6 |
| Letture e scritture Firestore al giorno | Console Firebase, pannello Utilizzo | < 10.000 letture e < 2.000 scritture | Margine ampio sotto la quota gratuita (NFR5.2) |
| Spesa mensile | Budget di fatturazione Cloud (attivo dal passaggio a Blaze, prima della prima pubblicazione) | 1 € | Budget di 0 €/mese (NFR5.3) |
| Quote gratuite (finché il progetto è su Spark) | Utilizzo di Firestore nella Console Firebase | 80% della quota giornaliera | Su Spark non c'è spesa: il rischio è il blocco del servizio a quota esaurita, controllato a mano durante le prove |
| Tempo di avvio a freddo | `startup_test.dart` in CI; smoke test sul telefono; Android vitals ("avvii a freddo lenti", ≥ 5 s) in produzione | ≤ 4 s in CI, ≤ 2 s sul telefono di riferimento, avvii lenti < 5% | NFR2.1 |

## Alerts

| Alert | Condition | Severity | Routes to |
|-------|-----------|----------|-----------|
| Spesa | Budget al 50%, 90% o 100% di 1 € | Alta | Email al proprietario |
| Nuovo tipo di crash | Crashlytics: nuovo problema o regressione di un problema chiuso | Alta | Email al proprietario (notifiche Crashlytics) |
| Picco di crash | Crashlytics velocity alert, soglia impostata all'1% degli utenti in 1 ora nelle impostazioni di Crashlytics | Critica | Email al proprietario; si valuta di fermare il rilascio |
| Scrittura rifiutata | Crashlytics: nuovo evento non fatale `SyncRejected` (alert sui nuovi problemi non fatali) | Alta | Email al proprietario |
| Rifiuti delle regole | Cloud Monitoring, metrica delle valutazioni delle regole Firestore con esito negato > 50 in 1 ora. Nome ed etichette esatti della metrica vanno verificati nel Metrics Explorer durante la configurazione | Media | Email al proprietario |
| CI o rilascio falliti | Esecuzione GitHub Actions fallita su `main` | Media | Email di GitHub al proprietario |

Gli alert sotto la soglia di 1 € sono avvisi e non bloccano la spesa; il rischio è accettato in NFR5.4 e vale dal passaggio a Blaze. Finché il progetto è su Spark (solo prove via cavo del proprietario) non c'è spesa possibile, e al superamento delle quote il servizio si ferma fino al giorno dopo. Le metriche di Cloud Monitoring che richiedono un account di fatturazione si attivano anch'esse con Blaze. Il servizio non ha reperibilità continua: la persona di riferimento è il proprietario, l'unico responsabile.

## SLIs / SLOs

| SLI | SLO target | Measurement window |
|-----|------------|--------------------|
| Sessioni senza crash | 99,5% | 28 giorni mobili |
| Scritture dei vini arrivate nel cloud senza rifiuto: 1 − (eventi `SyncRejected` / scritture Firestore del pannello Utilizzo) | 99,9% | Mese di calendario, calcolata a mano nella revisione mensile |
| Avvii a freddo non lenti (Android vitals: sotto 5 s) | 95% | 28 giorni mobili |

Le soglie degli alert scattano prima che gli SLO siano violati:

- il picco di crash all'1% in 1 ora arriva prima dello SLO del 99,5% su 28 giorni;
- ogni singola scrittura rifiutata genera un alert, molto prima dello 0,1% dello SLO;
- il tempo di avvio si controlla prima del rilascio, con la CI e lo smoke test, perché Android vitals non manda alert.

Il target di 2 s sul telefono di riferimento non ha uno SLI in produzione, perché Android vitals misura solo la soglia degli avvii lenti.

## Logs & Tracing

- **Server:** in U1 non c'è codice nostro sul server, quindi nessun log del server da raccogliere. I log di valutazione delle regole restano in Cloud Monitoring.
- **App:** `ErrorReporter` invia a Crashlytics gli errori fatali e non fatali, ripuliti da uid, email, percorsi e nomi di vini (NFR8.2). In debug i log vanno solo sulla console locale.
- **Tracing:** non usato in U1, perché non ci sono chiamate tra servizi nostri. Si valuterà con le funzioni cloud di u3, in Firebase Performance Monitoring o Cloud Trace.
- **Cruscotti:** si usano quelli già pronti di Crashlytics, Android vitals, Utilizzo di Firestore e App Check. Non si costruiscono cruscotti propri in U1.
