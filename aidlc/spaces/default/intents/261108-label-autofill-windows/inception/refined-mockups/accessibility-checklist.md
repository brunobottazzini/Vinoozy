# Checklist di accessibilità

## Fonti

- `interaction-spec.md` e `design-system-mapping.md` di questa cartella.
- Matrice esistente: 3 lingue × testo 1,0/2,0 × chiaro/scuro (NFR6).

| ID | Controllo | Dove |
|---|---|---|
| A1 | Ogni campo compilato dal testo annuncia "compilato dall'etichetta" al lettore di schermo, non solo con il simbolo ✦ | modulo |
| A2 | Pulisci, Cerca online, Lens, Incolla da Lens, le scelte del Livello e gli anni hanno un'area di tocco di almeno 48×48 dp | tutti |
| A3 | Il Livello suggerito si distingue anche senza colore: bordo tratteggiato più la parola "suggerito" | Livello |
| A4 | Gli anni non validi sono esclusi anche per il lettore di schermo (non attivabili) e non solo barrati | Correggi |
| A5 | Con testo al 200% il modulo, la barra e la griglia degli anni vanno a capo senza tagliare e senza scorrimento orizzontale | tutti |
| A6 | Il contrasto è almeno 4,5:1 per il testo e 3:1 per i bordi in chiaro e scuro, compresi "✦ dal testo" e "corretto da te" | tutti |
| A7 | I messaggi (appunti vuoti, modulo svuotato, ripristino) sono annunciati e restano 10 secondi con il lettore di schermo attivo, come "Bevuta segnata" | messaggi |
| A8 | Il dialogo e i pannelli prendono il fuoco quando si aprono e lo restituiscono quando si chiudono | Pulisci, Correggi |
| A9 | Tutti i testi nuovi sono nei 3 file ARB, e le date e gli anni sono formattati nella lingua dell'app | tutti |
| A10 | Il selettore del Livello è un gruppo a scelta singola: il lettore di schermo annuncia per esempio "Livello, Da invecchiamento, 3 di 4, suggerito" | Livello |
| A11 | Dopo "Svuota" il fuoco va al campo Nome e "Modulo svuotato" viene annunciato | Pulisci |
| A12 | Ordine del fuoco nel modulo: barra (Pulisci, Cerca online, Lens), campi in ordine visivo, Livello, Salva | modulo |
| A14 | La scelta "Da Google Lens" annuncia che apre un'altra app ("apre Google Lens"). Il pannello con le 3 istruzioni prende il fuoco e legge i passi in ordine, come elenco numerato. | Aggiungi vino, Lens |
| A13 | Il segno "✦ dal testo" sta sotto il campo e non copre il valore, anche con nomi lunghi e testo al 200% | modulo |
| A15 | Il pulsante in attesa annuncia "Leggo il testo" ed è segnato occupato; al risultato il lettore di schermo annuncia l'esito (FR2.8) | Incolla da Lens |
| A16 | All'apertura della guida il fuoco va alla domanda, letta come "Domanda 2 di 3: Cascina Castlet è il produttore?"; alla chiusura torna al pulsante che l'ha aperta o al primo campo compilato | Conferma guidata |
| A17 | Ogni parola del testo è un pulsante selezionabile ("Barbera, selezionata, 1"); l'anteprima è una regione live letta a ogni cambio | Conferma guidata |
| A18 | Risposte e parole alte almeno 48 dp; con testo al 200% la scheda scorre e le risposte restano visibili | Conferma guidata |
| A19 | Il tasto Indietro chiude la scheda prima di chiudere il modulo | Conferma guidata |
| A20 | Dopo "No, un'altra" il lettore di schermo annuncia il nuovo valore proposto ("Proposta: Cascina Castlet") | Conferma guidata |
| A21 | Le parole disattivate sono lette come "non disponibile", non solo barrate; le parole sono raggruppate per riga ("Riga 2 di 6") per non leggere 120 pulsanti di fila | Conferma guidata |
| A22 | La ruota dell'annata è un selettore regolabile: scorrere su e giù cambia l'anno di uno e annuncia il nuovo anno | Conferma guidata |
