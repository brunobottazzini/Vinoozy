# User Flow — Vinoozy

Fonti: `intent-statement.md`, `scope-document.md`, `intent-backlog.md`, `wireframes.md`.

## Flusso principale (percorso felice)

```
[Accesso Google] --> [Cruscotto]
                        |
          +-------------+--------------+
          |                            |
          v                            v
   [Aggiungi vino]              [Da bere presto]
     |         |                       |
     v         v                       v
 [Foto]     [Scrivi]            [Dettaglio vino]
     |         |                       |
     +----+----+                       v
          v                    [Segna come bevuta]
     [Conferma]                        |
          |                            v
          v                       [Storico]
  [Stima momento ideale]
          |
          v
     [Cruscotto aggiornato]
```

<!-- Text fallback: dopo l'accesso si arriva al cruscotto; da lì si aggiunge un vino (foto o testo, poi conferma e stima) oppure si apre una bottiglia da bere presto, la si segna come bevuta e finisce nello storico. -->

## Flussi dettagliati

### F1 — Aggiungere un vino scrivendo
- Persona: proprietario della cantina (intent-statement)
- Trigger: tocca "Aggiungi" nella barra in basso
- Passi:
  1. Aggiungi -> tocca "Scrivi" -> si apre il campo di testo
  2. Scrive "Barolo 2016" -> l'app propone i vini corrispondenti
  3. Sceglie un suggerimento e la quantità -> tocca "Salva"
  4. L'app salva il vino e mostra la stima del momento ideale con la fiducia
- Esito: la bottiglia compare in Cantina e nei grafici del Cruscotto
- Errori:
  - Nessun suggerimento -> salva con il testo scritto; stima con le regole interne e fiducia bassa
  - Senza rete -> salva in locale; la stima arriva alla sincronizzazione

### F2 — Aggiungere un vino con foto
- Trigger: Aggiungi -> "Scatta foto"
- Passi: inquadra l'etichetta -> scatta -> l'app propone il vino -> "Conferma" (oppure "Correggi", che apre F1 già compilato)
- Errori: etichetta illeggibile -> proposta di passare a "Scrivi"; fotocamera negata -> spiegazione e link alle impostazioni

### F3 — Non perdere una bottiglia
- Trigger: apertura dell'app (cruscotto)
- Passi: vede "Da bere presto" -> tocca una bottiglia -> legge finestra, fiducia e abbinamenti -> la beve -> "Segna come bevuta" -> voto e note -> Salva
- Esito: la quantità scende; con l'ultima bottiglia il vino passa allo Storico

### F4 — Condividere la cantina
- Trigger: icona profilo -> Condivisione
- Passi: "Invita una persona" -> email -> sceglie i permessi (solo lettura / può modificare) -> invia
- Esito: la persona invitata, dopo l'accesso con Google, vede la stessa cantina
- Errori: email non valida -> messaggio sotto il campo; revoca -> conferma con il nome della persona

## Assumptions & Open Questions

- [assumption] L'invito avviene tramite l'email dell'account Google della persona invitata.
