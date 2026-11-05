# Wireframes (bassa fedeltà) — Vinoozy

Fonti: `intent-statement.md`, `scope-document.md`, `intent-backlog.md`, risposte in `rough-mockups-questions.md`.

Principi trasversali:
- Telefono Android, una colonna; tema chiaro e scuro secondo il telefono; palette proposta: bordeaux come colore principale, crema e grigio caldo come neutri (Q4, Q5).
- WCAG AA: contrasto minimo 4.5:1, testi ridimensionabili, ogni elemento etichettato per il lettore schermo, aree toccabili di almeno 48x48 dp, lo stato di una bottiglia mai indicato dal solo colore (sempre icona + testo) (Q6).
- Interfaccia in italiano, inglese e portoghese brasiliano: i testi devono reggere parole più lunghe senza troncarsi (Q7).
- Barra in basso fissa con 4 sezioni: Cruscotto, Cantina, Aggiungi, Storico (Q2).
- Indicatore "offline - sincronizzazione in attesa" in alto quando manca la rete (constraint-register C3).

## Architettura delle informazioni

```
Accesso (login Google)
  |
  v
[Barra in basso]
  +-- Cruscotto (apertura)    -> Dettaglio vino
  +-- Cantina (elenco)        -> Dettaglio vino -> Segna come bevuta
  +-- Aggiungi                -> Scatta foto | Scrivi -> Conferma
  +-- Storico (bevute)        -> Dettaglio bevuta
[Icona profilo in alto] -> Condivisione cantina e permessi, lingua
```

<!-- Text fallback: dopo il login si arriva alla barra in basso con Cruscotto, Cantina, Aggiungi e Storico; l'icona profilo porta a condivisione e lingua. -->

## S1 — Accesso

```
+--------------------------------+
|                                |
|            VINOOZY             |
|   La tua cantina, al momento   |
|            giusto              |
|                                |
|  [ Continua con Google ]       |
|                                |
+--------------------------------+
```

Stati: caricamento (pulsante con indicatore), errore ("Accesso non riuscito. Riprova." + Riprova), senza rete al primo avvio ("Serve la connessione per il primo accesso").
Accessibilità: titolo h1 "Vinoozy"; regione main; il primo elemento raggiungibile è il pulsante Google.

## S2 — Cruscotto (schermata di apertura)

```
+--------------------------------+
| Cruscotto              (prof.) |
+--------------------------------+
| ! Da bere presto (3)           |
|  - Barolo 2016   entro 6 mesi  |
|  - Barbera Sup.  entro 2 mesi  |
|  > vedi tutte                  |
+--------------------------------+
| Stato delle bottiglie          |
|  [Aspettare 12][Pronte 9]      |
|  [Oltre il picco 1]            |
+--------------------------------+
| Picchi per anno                |
|  2026 ####  2027 ######        |
|  2028 ##    2029 ###           |
+--------------------------------+
| Per tipologia / regione        |
|  Rossi ####### Bianchi ##      |
+--------------------------------+
| [Cruscotto][Cantina][+][Stor.] |
+--------------------------------+
```

Stati: vuoto ("La tua cantina è vuota. Aggiungi il primo vino" + pulsante Aggiungi); caricamento (segnaposto a forma di riquadro); errore di sincronizzazione (banner con "Riprova", i dati locali restano visibili); "Da bere presto" vuoto ("Nessuna bottiglia in scadenza").
Note: ogni barra dei grafici riporta anche il numero; i grafici hanno una descrizione testuale per il lettore schermo; toccare una voce apre il Dettaglio vino. Le bottiglie in scadenza sono gli avvisi nell'app (Q1 di scope).
Accessibilità: h1 "Cruscotto", h2 per ogni riquadro; regioni header, main, nav (barra in basso); il primo elemento è "Da bere presto".

## S3 — Cantina (elenco)

```
+--------------------------------+
| Cantina            [cerca]     |
| Filtro: [Tutti v] Ordina: [v]  |
+--------------------------------+
| Barolo DOCG 2016          x2   |
|  (o) Pronto  fiducia: alta     |
+--------------------------------+
| Barbera d'Asti Sup. 2019  x3   |
|  (!) Bere entro 2 mesi  media  |
+--------------------------------+
| Dolcetto d'Alba 2022      x1   |
|  (~) Aspettare fino 2025 bassa |
+--------------------------------+
| [Cruscotto][Cantina][+][Stor.] |
+--------------------------------+
```

Stati: vuoto (come nel Cruscotto); filtro senza risultati ("Nessun vino con questi filtri" + "Azzera filtri"); nomi lunghi su due righe, mai troncati senza poterli leggere.
Accessibilità: h1 "Cantina"; ogni riga è letta come "nome, annata, quantità, stato, fiducia".

## S4 — Aggiungi (scelta)

```
+--------------------------------+
| Aggiungi vino                  |
+--------------------------------+
|                                |
|   [   Scatta foto   ]          |
|                                |
|   [      Scrivi     ]          |
|                                |
+--------------------------------+
| [Cruscotto][Cantina][+][Stor.] |
+--------------------------------+
```

Due pulsanti sullo stesso piano (Q3). Accessibilità: h1 "Aggiungi vino"; il primo elemento è "Scatta foto".

## S4a — Scatta foto -> proposta

```
+--------------------------------+
| < Foto etichetta               |
+--------------------------------+
|  [  anteprima fotocamera   ]   |
|          ( scatta )            |
+--------------------------------+
| Ho riconosciuto:               |
|  Barolo DOCG 2016 (Cantina X)  |
|  [ Conferma ] [ Correggi ]     |
+--------------------------------+
```

Stati: testo non riconosciuto ("Non riesco a leggere l'etichetta" + "Scrivi a mano"); permesso fotocamera negato (spiegazione + "Apri impostazioni"). Il vino viene salvato solo dopo la conferma.

## S4b — Scrivi -> conferma

```
+--------------------------------+
| < Scrivi il vino               |
+--------------------------------+
| Vino: [Barolo 2016_________]   |
| Suggerimenti:                  |
|  - Barolo DOCG 2016            |
|  - Barolo Riserva DOCG 2016    |
| Quantità: [-] 1 [+]            |
|        [ Salva ]               |
+--------------------------------+
```

Dopo il salvataggio compare la stima: "Bere tra 2025 e 2032 - fiducia media". Errori: campo vuoto ("Scrivi almeno il nome del vino"), senza rete il vino si salva comunque e la stima arriva alla sincronizzazione.
Obiettivo: meno di 30 secondi per bottiglia (intent-statement).

## S5 — Dettaglio vino

```
+--------------------------------+
| < Barolo DOCG 2016        x2   |
+--------------------------------+
| Finestra ideale: 2024 - 2032   |
| Picco: 2027                    |
| Stato: (o) Pronto              |
| Fiducia della stima: alta      |
|  (fonte: base dati vini)       |
+--------------------------------+
| Abbinamenti                    |
|  Brasato, tartufo, formaggi    |
|  stagionati                    |
+--------------------------------+
| [ Segna una come bevuta ]      |
| [ Modifica ]  [ Elimina ]      |
+--------------------------------+
```

Note: se la stima viene dalle regole interne la fonte lo dice ("stima per tipologia") e la fiducia è più bassa; "Elimina" chiede conferma indicando il vino.
Accessibilità: h1 nome del vino, h2 "Finestra ideale" e "Abbinamenti".

## S6 — Segna come bevuta

```
+--------------------------------+
| Barolo DOCG 2016 - bevuta      |
+--------------------------------+
| Voto: ( ) ( ) ( ) ( ) ( )      |
| Note: [__________________]     |
| Data: [oggi v]                 |
|  [ Annulla ]   [ Salva ]       |
+--------------------------------+
```

La quantità scende di 1; con l'ultima bottiglia il vino passa allo Storico.

## S7 — Storico

```
+--------------------------------+
| Storico                        |
+--------------------------------+
| 12/10/2026 Nebbiolo 2018  ***  |
|  "Ottimo con il brasato"       |
| 03/09/2026 Arneis 2023    **   |
+--------------------------------+
| [Cruscotto][Cantina][+][Stor.] |
+--------------------------------+
```

Stato vuoto: "Qui troverai le bottiglie che hai bevuto". Il voto è letto come "3 su 5".

## S8 — Condivisione cantina (dall'icona profilo)

```
+--------------------------------+
| < Condivisione                 |
+--------------------------------+
| Persone con accesso:           |
|  maria@...    [Può modificare] |
|  [ Invita una persona ]        |
| Permessi: Solo lettura |       |
|           Può modificare       |
+--------------------------------+
```

Revocare l'accesso chiede conferma. La persona invitata vede la stessa cantina con i permessi assegnati (intent-statement).

## Assumptions & Open Questions

- [assumption] I nomi delle sezioni e i testi sono provvisori; verranno ridefiniti nei mockup rifiniti.
- [assumption] Le soglie per "Da bere presto" (es. entro 6 mesi dalla fine della finestra) saranno definite nei requisiti.
