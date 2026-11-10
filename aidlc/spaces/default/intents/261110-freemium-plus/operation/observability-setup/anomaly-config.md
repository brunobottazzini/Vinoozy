# Rilevamento delle anomalie — Freemium e Plus

Nessun rilevamento automatico a pagamento. Le anomalie da cercare, con lo strumento gratuito che le mostra:

| Anomalia | Segnale | Strumento | Soglia |
|---|---|---|---|
| Uso del cloud insolito | Letture o scritture giornaliere che crescono più delle installazioni | Firestore → Utilizzo | +50% in una settimana senza una crescita di utenti simile; oppure ≥ 70% della quota (studio §8.7) |
| Account che consumano molto | Account oltre la soglia di 0,005 € nel mese | `usage/*/periods/<mese>` (campo `aboveBudget` restituito da `reportUsage`) | Più del 10% degli account attivi: rivedere misuratore e soglia prima di accendere gli annunci |
| Misuratore da calibrare | Rapporto tra letture reali e stimate | Utilizzo di Firestore rispetto alla somma di `usage` | Fuori da 0,8–1,2 per 2 settimane (studio §7.5): correggere i coefficienti |
| Picco di rimborsi o annullamenti | Rimborsi e annullamenti nel mese | Play Console → Ordini | Più del 10% dei nuovi abbonamenti |
| Spesa | Costo previsto | Avvisi di budget (`alarms.md`) | 50% / 90% / 100% di 1 € |
| Crash in aumento | Velocità dei problemi | Crashlytics velocity | Oltre l'1% delle sessioni in 1 h |

Il controllo settimanale (`dashboards.md`) è il momento in cui leggere queste soglie. Superarne una non blocca l'app: porta a una decisione del proprietario, per esempio spegnere un interruttore o rivedere la soglia, valida dal mese successivo (studio §7.10).
