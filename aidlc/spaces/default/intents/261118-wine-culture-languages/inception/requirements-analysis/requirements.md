# Requisiti — Lingue dei paesi del vino

## Intent Analysis

- **Richiesta** `[desc]`: "aggiungere lingue supportate obbligatorio francese, spagnolo, tedesco e tutti i paesi con cultura di "vino". Mi suggeriesci tutte le lingue che pensi che sia necesasrio suportare. Vorrei qualcosina minimo 20 lingue"
- **Obiettivo**: far usare Vinoozy nella propria lingua a chi vive nei paesi dove il vino si produce e si colleziona, e far trovare l'app su Google Play in quei paesi.
- **Tipo**: estensione di una funzione esistente (oggi 3 lingue: italiano, inglese, portoghese del Brasile).
- **Ampiezza**: trasversale. Tocca i testi dell'app, i nomi di paesi e regioni, la ricerca nel catalogo, i test, i controlli automatici e la scheda dello store (vedi `aidlc/spaces/default/codekb/Vinoozy/code-structure.md`, sezione "Localization Touchpoints").
- **Decisioni prese** in `requirements-analysis-questions.md`: 25 lingue `[Q1]`; lingua scelta dalle impostazioni di Android `[Q2]`; app più scheda di Google Play `[Q3]`; prova completa su un sottoinsieme di lingue `[Q4]`.

### Elenco delle 25 lingue `[Q1]`

| # | Lingua | Codice | Perché |
|---|---|---|---|
| 1 | Italiano | `it` | Già presente |
| 2 | Inglese | `en` | Già presente, lingua di ripiego |
| 3 | Portoghese del Brasile | `pt-BR` | Già presente |
| 4 | Francese | `fr` | Obbligatoria `[desc]`; Francia, Belgio, Svizzera, Canada |
| 5 | Spagnolo | `es` | Obbligatoria `[desc]`; Spagna, Argentina, Cile |
| 6 | Tedesco | `de` | Obbligatoria `[desc]`; Germania, Austria, Svizzera |
| 7 | Portoghese del Portogallo | `pt` | Portogallo: Douro, Porto, Madeira |
| 8 | Catalano | `ca` | Catalogna: Cava, Priorat, Penedès |
| 9 | Greco | `el` | Grecia e Cipro |
| 10 | Rumeno | `ro` | Romania e Moldavia |
| 11 | Ungherese | `hu` | Ungheria: Tokaj |
| 12 | Croato | `hr` | Croazia: Istria, Dalmazia |
| 13 | Sloveno | `sl` | Slovenia: Brda, Štajerska |
| 14 | Ceco | `cs` | Cechia: Moravia |
| 15 | Slovacco | `sk` | Slovacchia: Tokaj slovacco, Piccoli Carpazi |
| 16 | Bulgaro | `bg` | Bulgaria: Valle della Tracia |
| 17 | Serbo | `sr` | Serbia |
| 18 | Georgiano | `ka` | Georgia, la culla del vino |
| 19 | Olandese | `nl` | Paesi Bassi e Belgio, grandi importatori |
| 20 | Polacco | `pl` | Mercato in forte crescita |
| 21 | Ucraino | `uk` | Ucraina: produzione propria e mercato ampio |
| 22 | Danese | `da` | Alto consumo per persona, molti collezionisti |
| 23 | Svedese | `sv` | Grande mercato d'importazione |
| 24 | Norvegese (bokmål) | `nb` | Grande mercato d'importazione |
| 25 | Finlandese | `fi` | Mercato d'importazione |

## Functional Requirements

### FR1 — Lingue dell'interfaccia

- **FR1.1** `[Q1]` L'app offre le 25 lingue dell'elenco. Verifica: con il telefono impostato su ciascuna delle 25 lingue, l'app mostra i testi in quella lingua.
- **FR1.2** `[Q1]` Ogni messaggio del modello inglese (oggi 670) esiste in ognuna delle 25 lingue, con gli stessi segnaposto. Verifica: un controllo automatico fallisce se in una lingua manca un messaggio o un segnaposto è diverso dal modello.
- **FR1.3** `[Q1]` Il portoghese del Portogallo ha testi propri (oggi mostra l'inglese). Il portoghese del Brasile resta una variante distinta. Verifica: telefono in `pt-PT` mostra testi portoghesi europei; telefono in `pt-BR` mostra i testi di oggi.
- **FR1.4** `[Q1]` Una variante regionale non elencata riceve la lingua base (per esempio `fr-CA` riceve `fr`, `es-AR` riceve `es`, `de-AT` riceve `de`, `nn` e `no` ricevono `nb`). Una lingua non offerta riceve l'inglese, come oggi. Verifica: un test per ognuno di questi casi.
- **FR1.5** `[Q1]` Ogni lingua usa le proprie forme di plurale (per esempio tre o quattro forme in polacco, ceco, slovacco, croato, serbo, sloveno, ucraino, rumeno). Verifica: per ogni messaggio con un conteggio, un test controlla i valori 0, 1, 2, 5 e 21 nelle lingue con più di due forme.
- **FR1.6** `[memory:M1]` I termini di legge del vino (Riserva, Grand Cru, Spätlese e simili) e il nome Vinoozy restano uguali in ogni lingua. Verifica: i valori di `qualifierDisplayName` sono identici in tutte le lingue.

### FR2 — Scelta della lingua

- **FR2.1** `[Q2]` L'app segue la lingua del telefono; non viene aggiunta una scelta della lingua dentro l'app. Verifica: nessuna schermata nuova; il cambio di lingua del telefono cambia la lingua dell'app.
- **FR2.2** `[Q2]` L'app dichiara ad Android le 25 lingue, così da Android 13 in poi la persona può scegliere la lingua di Vinoozy dalle impostazioni di sistema dell'app. Verifica: nelle impostazioni di sistema dell'app, su Android 13 o successivo, la voce della lingua elenca le 25 lingue e la scelta cambia la lingua dell'app.

### FR3 — Dati legati alla lingua

- **FR3.1** `[Q1]` I nomi dei 249 paesi sono mostrati in ognuna delle 25 lingue. Verifica: un test controlla che ogni paese abbia un nome non vuoto in ogni lingua.
- **FR3.2** `[Q1]` I nomi delle regioni vinicole sono mostrati nella lingua dell'app quando in quella lingua esiste un nome d'uso comune; altrimenti resta il nome canonico. I valori salvati non cambiano (codice del paese, nome canonico della regione). Verifica: un vino salvato in una lingua mostra paese e regione corretti dopo il cambio di lingua, senza migrazione dei dati.
- **FR3.3** `[Q1]` La ricerca di paesi e regioni trova i nomi scritti nella lingua dell'app, senza distinguere maiuscole e accenti, anche in greco, cirillico e georgiano. Verifica: per ogni scrittura, un test cerca un paese con e senza accenti e con maiuscole diverse.
- **FR3.4** `[Q1]` La ricerca nel catalogo online passa la lingua dell'app; se il catalogo non ha testi in quella lingua, valgono quelli inglesi. Verifica: un test per una lingua nuova e uno per il ripiego.
- **FR3.5** `[Q1]` Date e numeri seguono le regole della lingua dell'app. Verifica: un test su una data e un numero decimale in almeno una lingua per scrittura.

### FR4 — Scheda di Google Play

- **FR4.1** `[Q3]` Il repository contiene, per ognuna delle 22 lingue nuove, i testi della scheda: titolo (massimo 30 caratteri), descrizione breve (massimo 80), descrizione completa (massimo 4000), note di rilascio (massimo 500). Verifica: il controllo di pubblicazione esistente passa su tutte le 25 cartelle e fallisce se un testo manca o supera il limite.
- **FR4.2** `[Q3]` La guida di pubblicazione elenca le lingue da caricare su Google Play e l'ordine dei passi. Il caricamento resta manuale. Verifica: la guida nomina le 25 lingue.

### FR5 — Pagina della privacy aperta dall'app

- **FR5.1** `[Q3]` Il collegamento alla privacy apre la pagina nella lingua dell'app quando esiste (italiano, inglese, portoghese del Brasile); per ogni altra lingua apre quella inglese. Oggi apre sempre quella italiana. Verifica: un test per italiano, per portoghese del Brasile e per una lingua nuova.

## Non-Functional Requirements

- **NFR1** `[memory:M2]` La copertura resta almeno all'80% delle righe su tutto il codice, senza esclusioni, compreso il codice generato per le lingue nuove. La soglia non viene abbassata.
- **NFR2** `[Q4]` Il controllo dei test unitari su GitHub Actions resta entro il limite attuale di 40 minuti.
- **NFR3** `[Q4]` La prova completa delle schermate principali (2 dimensioni del testo × 2 temi) gira per 10 lingue: `it`, `en`, `pt-BR`, `fr`, `es`, `de`, `el` (greco), `uk` (cirillico), `ka` (georgiano) e la lingua con i testi più lunghi tra le rimanenti, scelta misurando la lunghezza totale dei testi. In queste lingue nessuna schermata principale produce errori di impaginazione.
- **NFR4** `[Q4]` Per le altre 15 lingue un controllo automatico verifica che ogni messaggio esista, sia completo (FR1.2) e venga mostrato senza errori.
- **NFR5** `[Q1]` L'elenco delle lingue è scritto in un solo punto, da cui derivano la risoluzione della lingua, i test, la dichiarazione ad Android e i controlli dello store. Verifica: aggiungere una lingua di prova richiede di toccare un solo elenco, oltre ai file dei testi.
- **NFR6** `[Q1]` Un glossario dei termini del vino (annata, vitigno, denominazione, cantina, finestra di consumo, apice e simili) fissa la traduzione per ogni lingua; lo stesso termine è tradotto allo stesso modo in tutta l'app. Verifica: il glossario è nel repository e un controllo a campione su 20 messaggi per lingua non trova traduzioni diverse dello stesso termine.

## Constraints

- Budget cloud di 0 €/mese: nessun servizio di traduzione a pagamento. `[memory:M3]`
- Codice, identificatori e commenti in inglese; i testi dell'interfaccia stanno solo nei file di localizzazione. `[memory:M4]`
- Tutti i controlli di GitHub Actions (formattazione, analisi, test, copertura, end-to-end) devono passare prima del merge. `[memory:M2]`
- I test end-to-end restano in italiano, come oggi.
- Le pagine web di privacy e cancellazione dell'account restano in italiano, inglese e portoghese del Brasile. `[Q3]`

## Assumptions

- `[assumption]` Le traduzioni sono scritte da me, senza revisione di un madrelingua. Motivo: una persona sola e budget zero. Rischio: frasi corrette ma poco naturali; si correggono per lingua quando arriva una segnalazione.
- `[assumption]` Il serbo usa la scrittura cirillica, quella ufficiale e quella che i telefoni impostati in serbo chiedono di norma. Si può passare alla scrittura latina.
- `[assumption]` Il norvegese è il bokmål, la forma scritta più diffusa.
- `[assumption]` Il nome della cantina predefinita resta nella lingua del primo accesso, come oggi.
- `[assumption]` La regola di squadra che cita "tre lingue (it, en, pt-BR)" per i test dei widget viene estesa da NFR3 e NFR4, non sostituita.
- `[assumption]` Flutter fornisce già i testi di sistema (pulsanti, calendari) per tutte le 25 lingue.

## Out of Scope

- Russo, turco, giapponese, cinese, coreano e le lingue scritte da destra a sinistra (arabo, ebraico). `[Q1]`
- Scelta della lingua dentro l'app. `[Q2]`
- Traduzione delle pagine web di privacy e cancellazione dell'account. `[Q3]`
- Catture di schermo dello store nelle lingue nuove: Google Play mostra quelle della lingua predefinita.
- Lettura delle etichette in scritture non latine: il riconoscimento resta sull'alfabeto latino.
- Caricamento automatico dei testi su Google Play.
- Nomi dei paesi letti sulle etichette (pacchetto di stima): non dipendono dalla lingua dell'interfaccia.

## Open Questions

- La lingua con i testi più lunghi (NFR3) si conosce solo a traduzioni fatte; se è già tra le prime nove, la prova completa copre 9 lingue.
- L'effetto reale delle lingue nuove sulla copertura (NFR1) e sui tempi (NFR2) si misura in Build and Test; la stima è di circa 2.450 righe generate per lingua.

## Sources

- `[desc]` Initial description: richiesta del proprietario, riportata sopra.
- `[Q1]`–`[Q4]`: `requirements-analysis-questions.md`.
- `[memory:M1]`: `aidlc/spaces/default/codekb/Vinoozy/business-overview.md`, "Domain Knowledge in the Code".
- `[memory:M2]`: `aidlc/spaces/default/memory/team.md`, "Testing Posture".
- `[memory:M3]`: `aidlc/spaces/default/memory/team.md`, "Deployment".
- `[memory:M4]`: `aidlc/spaces/default/memory/team.md`, "Code Style".
