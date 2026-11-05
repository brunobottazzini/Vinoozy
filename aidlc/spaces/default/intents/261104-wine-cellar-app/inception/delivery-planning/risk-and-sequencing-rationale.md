# Risk and Sequencing Rationale — Vinoozy

Fonti: `bolt-plan.md`, `unit-of-work-dependency.md`, `contract-summary.md` (domande aperte), `requirements.md`, `team-practices.md`, risposte in `delivery-planning-questions.md`.

Un **Bolt** è un passaggio di costruzione su una parte del lavoro che termina con qualcosa di funzionante; il **walking skeleton** (Cockburn) è la versione minima che funziona da capo a fondo, costruita per prima.

## Euristica scelta

**Walking skeleton prima, poi rischio prima, poi valore** (Q1 "misto", Q4 "affidabilità della stima"). Non usiamo un punteggio formale (WSJF, cioè valore e urgenza divisi per dimensione): con un solo sviluppatore e nessuna scadenza basta un ordine motivato.

| Posizione | Bolt | Perché qui |
|-----------|------|------------|
| 1 | B1 skeleton | Prova l'integrazione Flutter + Firestore offline + accesso Google + CI gratuita: il rischio tecnico di base (team-practices, Walking Skeleton) |
| 2 | B2 estimation | Affronta la preoccupazione principale (Q4): stima affidabile; rischio basso perché logica pura, valore alto perché è l'obiettivo "non perdere il vino" |
| 3 | B3 wine-catalog | Rischio più alto del progetto: esistenza di una fonte dati gratuita (feasibility R1, contract C5); scoprirlo presto evita di costruire la cantina su un'ipotesi sbagliata |
| 4 | B4 cellar | Massimo valore d'uso; dipende da B1, B2, B3 |
| 5 | B5 dashboard | Rende visibile l'obiettivo principale; dipende da B1, B2 |
| 6 | B6 label-recognition | Velocizza l'inserimento, ma il percorso scritto funziona già |
| 7 | B7 sharing | Valore per la persona invitata, non per l'uso personale di base |
| 8 | B8 account | Necessario prima della produzione su Google Play (cancellazione account), non per l'uso di prova |

## Rispetto del grafo

L'ordine è uno degli ordini permessi dal grafo di `unit-of-work-dependency.md`: nessun Bolt precede una sua dipendenza. Nessuna deviazione dall'ordine topologico da giustificare.

## Rischi

| Rischio | Probabilità | Impatto | Mitigazione | Bolt |
|---------|-------------|---------|-------------|------|
| Nessuna fonte dati vini gratuita adatta | Media | Alto | B3 inizia con la scelta e una prova; ripiego sulle regole interne di B2 | B3 |
| Minuti gratuiti di GitHub Actions insufficienti per l'emulatore Android | Media | Medio | Misurarli in B1; se servono, eseguire l'emulatore solo su `main` senza abbassare il controllo | B1 |
| Copertura 80% senza esclusioni difficile con codice generato e traduzioni | Media | Medio | Impostare la misura in B1 e tenere minimo il codice generato | B1 |
| Regole di sicurezza condivise tra U1 e U7 | Bassa | Alto | Perimetro scritto in `contract-summary.md`; test delle regole nell'emulatore in B1 e B7 | B1, B7 |
| Cancellazione dati e accessi ricevuti non coperta dai contratti (revisione di Contract Design) | Media | Alto | Da risolvere nella progettazione funzionale di U7 e U8 prima del codice | B7, B8 |

## Controlli tra un Bolt e l'altro

Dopo ogni Bolt: comando di verifica verde e approvazione del proprietario. Dopo B3: decisione esplicita se la fonte esterna resta o si usa solo B2.
