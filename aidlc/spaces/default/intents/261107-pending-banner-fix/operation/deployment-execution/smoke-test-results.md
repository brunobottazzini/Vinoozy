# Risultati dello smoke test — pending-banner-fix

## Fonti

- `operation/deployment-pipeline/deployment-strategy.md` (matrice di promozione e prova specifica della fascia).
- Riscontro del proprietario dal suo telefono, 2026-11-07.

| Prova | Esito | Fonte |
|---|---|---|
| Avvio dell'app | **superata**: l'app si apre | `adb` mostra `MainActivity` in primo piano; uso del proprietario |
| Accesso con Google e cantina | **superata**: il proprietario ha usato l'app e aggiunto vini | riscontro del proprietario |
| Storico | **superata**, dopo qualche minuto: all'inizio non funzionava perché l'indice composito appena pubblicato era ancora in costruzione | riscontro del proprietario ("ha appena funzionato lo storico") |
| Fascia "Senza rete" dopo l'ultima bottiglia bevuta offline (prova specifica di questa correzione) | **non eseguita** | il proprietario: "Non l'ho provata" (messaggio c85c5e82) |
| Sincronizzazione al ritorno della rete | **non eseguita** come prova separata | — |

## Osservazioni del proprietario (fuori da questa correzione)

L'esperienza d'uso va rifatta. Diventa il prossimo lavoro:
- la regione non si può aggiungere; la vuole scelta con le bandiere dei paesi;
- il pulsante "Bevuto" non si capisce e agisce subito, senza conferma;
- l'interfaccia deve essere più grafica.
