# Specifica delle interazioni

## Fonti

- `requirements.md` (FR1–FR5, NFR3, NFR6).
- `mockups.md` e `autofill-mockups.html` di questa cartella.

## Modulo compilato dal testo (schermate 1–3)

| Azione | Risultato | Requisiti |
|---|---|---|
| La lettura della foto finisce senza un vino trovato e con almeno una riga utile | Si apre `AddWineScreen` con i campi ricavati. Ogni campo compilato ha il segno "✦ dal testo" e la sua etichetta semantica dice "compilato dall'etichetta". Il fuoco va sul primo campo. | FR1.2, FR1.3 |
| La lettura finisce senza righe utili | Si apre la schermata "Non trovato" di oggi | FR1.2 |
| L'utente modifica un campo compilato | Il segno "✦ dal testo" di quel campo sparisce: il campo ora è suo | FR1.3, FR1.4 |
| Tocco su "Pulisci" senza campi modificati a mano | Svuota subito i campi descrittivi, toglie i segni e lascia il Livello "non scelto". Quantità, posizione e note restano. Compare il messaggio "Modulo svuotato". | FR1.4 |
| Tocco su "Pulisci" con almeno un campo modificato a mano | Dialogo "Svuotare il modulo?" con "Annulla" o "Svuota" | FR1.4 |
| Tocco su "Cerca online" | Apre la ricerca di oggi con le parole del modulo | FR1.2 |
| Tocco su "Lens" | Apre la conferma di Lens di oggi, se c'è la foto del fronte; altrimenti il pulsante non c'è | FR1.2 |
| Tocco su "Incolla da Lens" | Legge gli appunti una volta. Con testo, riempie solo i campi vuoti e li segna "✦ dal testo". Senza testo, compare "Negli appunti non c'è testo". | FR2.2, FR2.4, NFR3.1 |
| Testo incollato che porta a un vino certo | Pannello della proposta sicura di oggi, sopra il modulo | FR2.5 |

| Testo incollato o condiviso che non dà nessun campo (nessuna riga utile, oppure tutti i campi utili già pieni) | Messaggio "Nel testo non ho trovato dati da aggiungere". Il modulo non cambia. | FR2.2, FR2.4 |

**La barra (Pulisci, Cerca online, Lens).**
- **Quando compare.** Dalla prima volta che il modulo riceve campi da un testo: lettura della foto, "Incolla da Lens" o "Condividi". Anche in un modulo iniziato a mano.
- **Quando resta.** Resta finché il modulo è aperto, anche dopo che i segni "✦ dal testo" spariscono perché hai modificato i campi.
- **Lens.** Il pulsante compare solo se c'è la foto del fronte.
- **"Incolla da Lens".** Compare nel modulo di aggiunta quando almeno un campo descrittivo è vuoto.

**Conferma di "Pulisci".** Chiede conferma se almeno un campo descrittivo contiene testo scritto o modificato da te, oppure se il Livello è stato toccato. Il segno "✦ dal testo" non conta.

**Dopo "Svuota".**
- Il fuoco va al campo Nome.
- Il messaggio "Modulo svuotato" viene annunciato al lettore di schermo.

## "Da Google Lens" senza foto (schermata 9)

| Azione | Risultato | Requisiti |
|---|---|---|
| Tocco su "Da Google Lens" nella scelta "Aggiungi vino" | Vinoozy apre prima il **modulo vuoto** (schermata 3) e subito dopo Lens. Al ritorno l'utente è sul modulo vuoto. | FR2.6 |
| Tocco su "Da Google Lens" nel modulo vuoto | Apre Lens; al ritorno si resta sul modulo | FR2.6 |
| Come si apre Lens | Prima l'app Lens (`com.google.ar.lens`, dichiarata in `<queries>`), poi Lens dentro l'app Google. **"Non si apre" vuol dire che entrambe le chiamate lanciano `ActivityNotFoundException`.** | FR2.6, NFR3.3 |
| Nessuna delle due si apre | Pannello con l'istruzione in 3 passi: inquadra, seleziona il testo, Condividi → Vinoozy. Pulsante "Ho capito". Si resta sul modulo. | FR2.6 |
| In Lens: Condividi → Vinoozy | Il modulo aperto riceve il testo con le regole di FR2.4 (solo i campi vuoti) | FR2.1 |
| Ritorno da Lens entro 5 minuti dall'apertura di Lens, dopo "Da Google Lens" | Se gli appunti sono stati copiati **dopo** l'apertura di Lens (controllo con l'ora di copia, senza leggere il contenuto), Vinoozy li legge **una volta da sola** e compila tutti i campi come "Incolla da Lens". Il lettore di schermo annuncia "Modulo compilato dal testo di Lens" e Android 12+ mostra il suo avviso. Se gli appunti sono più vecchi, vuoti o senza testo, non cambia nulla e resta il pulsante. Lo stesso testo non si incolla due volte. | FR2.7, NFR3.1 |
| In Lens: Copia, poi ritorno in Vinoozy (oltre i 5 minuti, o se Android non permette la lettura automatica) | Il modulo vuoto mostra **sempre** il riquadro "Incolla da Lens" in cima, anche senza sapere cosa c'è negli appunti (NFR3.1). Non c'è un'evidenza che dipende dagli appunti. | FR2.2, NFR3.1 |

Nella scelta "Aggiungi vino" l'ordine è: "Scatta foto", "Da Google Lens", "Scegli dalla galleria", "Scrivi a mano". Ogni scelta ha una riga di spiegazione.

## "Condividi" da Lens (schermata 4)

| Stato dell'app | Risultato | Requisiti |
|---|---|---|
| Chiusa o in secondo piano, con accesso fatto | Si apre la Cantina e poi il modulo compilato | FR2.1 |
| Senza accesso | Prima l'accesso, poi il modulo. Il testo resta solo in memoria. | FR2.1, FR2.3 |
| Modulo aperto con modifiche | Domanda "Usare il testo per i campi vuoti?" con "Usa" o "Ignora" | FR2.1, FR2.4 |
| Testo vuoto o solo spazi | Messaggio "Nessun testo ricevuto" | FR2.1 |
| Testo più lungo di 4000 caratteri | Si tronca senza avviso | FR2.3 |

## Livello (schermata 5)

- Tre scelte a pulsante, larghe almeno 48 dp: "Quotidiano (economico)", "Buono" e "Da invecchiamento". Sotto c'è un riquadro "Cosa cambia" con esempi per ogni livello (FR4.1).
- "Incolla da Lens" è **un solo pulsante**: un tocco compila tutti i campi insieme. Non si incolla campo per campo (FR2.2).
- **Livello non scelto:** nessuna scelta evidenziata e vale "Buono".
- **Proposta automatica:** la scelta proposta ha un bordo tratteggiato color oro, la nota "suggerito" e il motivo sotto. Il lettore di schermo legge "suggerito, perché il nome contiene Gran Reserva".
- **Conferma:** toccare la scelta proposta la conferma. Toccarne un'altra la sostituisce. Da quel momento la proposta non cambia più (FR4.3).
- **"Salva" senza toccare:** salva il livello suggerito. Il suggerimento è visibile, quindi vale come accettato. Chi non lo vuole tocca un'altra scelta o "Nessuno".
- **Qualifica tolta dal nome:** se la qualifica sparisce prima che il Livello sia stato toccato, sparisce anche il suggerimento e si torna a "non scelto".
- **"Nessuno":** un quarto pulsante, alto 48 dp, che riporta a "non scelto" (cioè "Buono", FR4.1), anche dopo un tocco. **"Nessuno" spegne il suggerimento:** finché il modulo è aperto, nessuna scelta torna a essere suggerita, e "Salva" non salva nessun livello.
- **Modulo di modifica:** il suggerimento compare solo se il vino non ha un livello salvato. Un livello salvato non viene mai sostituito.
- **Anteprima:** compare quando c'è una stima e mostra la finestra con il livello attuale accanto a quella con il livello scelto.

## Correzione di "Consigliato fino al" (schermate 6–7)

| Azione | Risultato | Requisiti |
|---|---|---|
| Tocco su "Correggi" nella scheda Momento ideale | Si apre un pannello dal basso con una griglia di anni: da "Pronto da" a "Pronto da" più 60, a gruppi, e "altro…" per scegliere da una lista. Gli anni prima di "Pronto da" sono barrati e non si possono toccare. | FR5.1 |
| Scelta di un anno prima di "al meglio" | Sotto la griglia compare l'avviso che anche "al meglio" si sposta | FR5.1 |
| "Salva correzione" | La scheda mostra "Consigliato fino al <anno>" con "corretto da te" e, sotto, "Stima dell'app: fino al <anno>". Stati e Dashboard usano l'anno corretto. | FR5.2, FR5.5 |
| "Ripristina stima" | Dialogo breve "Tornare alla stima dell'app (fino al <anno>)?" con "Annulla" o "Ripristina". Non c'è un "Annulla" a tempo, quindi una sola scrittura. | FR5.4 |
| Apertura di "Correggi" senza una correzione | È preselezionato l'anno di fine stimato dall'app | FR5.1 |
| Un adeguamento dalle bevute sposterebbe "Pronto da" oltre l'anno corretto | L'adeguamento si ferma all'anno corretto: "Pronto da" e "al meglio" non lo superano mai. Il dettaglio mostra la finestra che ne risulta. | FR5.6 |
| Modifica del vino, aggiornamento della stima, bevuta | La correzione resta | FR5.3, FR5.6 |

"Ripristina stima" compare solo quando c'è una correzione.

## Tema scuro

Tutti i componenti nuovi hanno la variante scura con i token del tema. Il segno "✦ dal testo" e "corretto da te" usano la stessa coppia dei chip esistenti: `onSecondaryContainer` su `secondaryContainer`. È una coppia contrastata in chiaro e in scuro, non oro su oro chiaro. La schermata 8 dei mockup mostra il tema scuro; gli altri componenti seguono gli stessi token.

## Origine della stima (schermata 8)

Il dettaglio mostra in una riga piccola da dove viene la stima:
- "Stima dalla denominazione <nome>", con la qualifica se c'è;
- oppure "Stima dal vitigno <nome>";
- oppure "Stima dal tipo di vino".

La riga sostituisce il testo di oggi `estimateSourceText` e ne aggiunge i casi. Resta anche con la correzione. L'avviso `uxIdealDisclaimer` ("⚠︎ Indicativo") resta come oggi; con una correzione diventa "corretto da te" (FR5.2).

## Attesa dopo l'incolla (schermata G0, FR2.8)

- Al tocco su "Incolla da Lens" il pulsante diventa "Leggo il testo…" con un indicatore circolare e non accetta altri tocchi.
- Entro 2 secondi lo sostituisce uno di questi: modulo compilato, proposta di un vino certo, prima domanda della guida, messaggio.
- Con l'incolla automatico al ritorno da Lens lo stesso stato compare nel riquadro "Hai il testo da Google Lens?".

## Conferma guidata (schermate G1–G5, FR7)

**Apertura.** La scheda sale dal basso sopra il modulo, che resta sotto, oscurato. Parte da sola solo se almeno un campo chiave è incerto (FR7.1). L'ordine delle domande è denominazione, produttore, nome, annata, saltando i campi certi e quelli scritti a mano.

**Testata.** "Domanda N di T" (nei mockup 4 campi incerti) a sinistra, barre di progresso al centro, "Chiudi ✕" a destra. T è il numero di campi incerti, fissato all'apertura. Un "No" non cambia N.

**Domanda.** Il valore proposto, grande, in bordeaux, poi "è la denominazione?" (o il produttore, il nome, l'annata). Per l'annata ambigua, una riga piccola cita gli altri anni trovati nel testo.

**Risposte** (griglia 2 × 2, ognuna alta almeno 48 dp):
- **Sì** (pieno, bordeaux): compila il campo con "✦ dal testo" e passa alla domanda successiva con una transizione orizzontale breve. Con il movimento ridotto il cambio è immediato.
- **No, un'altra**: sostituisce il valore con il candidato successivo e mostra sopra "\"<valore>\" no: ti propongo il prossimo". Senza altri candidati vale la precisazione "Ultimo candidato" più sotto.
- **Modifica**: la scheda mostra un campo di testo con il valore proposto e la tastiera aperta, con "Conferma" e "Annulla". Valore vuoto: campo vuoto, si passa avanti. Valore non valido: messaggio di errore sotto il campo, si resta.
- **Salta** (testo semplice): campo vuoto, si passa avanti.

**Parole del testo** (FR7.5). Sotto le risposte, l'etichetta "Oppure componila toccando le parole del testo" e un riquadro scorrevole con le parole, una riga del testo per riga, al massimo 120.
- Al primo tocco su una parola la scheda passa in modalità "Componi": scompaiono le quattro risposte, compaiono l'anteprima e "Conferma" / "Annulla".
- Le parole scelte diventano piene con un numerino d'ordine. L'anteprima le unisce nell'ordine del testo, con uno spazio.
- Un secondo tocco toglie la parola. Con zero parole "Conferma" è disattivato. "Annulla" torna alla domanda.
- Se l'anteprima corrisponde a una denominazione delle tabelle, accanto compare "✓ DOCG" (o la sigla) e il campo prenderà il nome della tabella.
- Le parole già confermate per un altro campo restano selezionabili, con il segno "usata per la denominazione" (o il campo); una parola non entra due volte nello stesso valore. Oltre 8 parole o 80 caratteri le altre si disattivano.

**Chiusura.** "Chiudi", il tasto Indietro o un tocco fuori chiudono la scheda tenendo i campi confermati. Nel modulo compare "🧭 Conferma guidata" nella barra, accanto a "Pulisci", finché resta un campo incerto senza risposta. Alla fine dell'ultima domanda la scheda si chiude da sola e, se un campo è stato saltato, compare il messaggio "Nome saltato: puoi scriverlo o riprendere la guida".

**Dopo la denominazione.** Alla conferma si compilano tipo, paese e regione, e il Livello suggerito si aggiorna se non scelto a mano (FR7.7).

**Casi limite.** Nuovo testo a guida aperta: la guida si chiude tenendo i confermati, il nuovo testo riempie i campi vuoti e, se serve, apre una nuova guida. Rotazione e secondo piano: si riprende alla stessa domanda. "Pulisci": chiude la guida e svuota anche le risposte.

**Annata con la ruota** (FR7.4, messaggio c40106d0). Per l'annata la scheda mostra una ruota degli anni (`ListWheelScrollView`, come i selettori di data di Android) al posto delle parole del testo. Parte dall'anno trovato nel testo, altrimenti dall'anno corrente meno 2 (2024 nel 2026). Va dal 1900 all'anno corrente più 1. Gli altri anni del testo hanno un puntino. Sotto ci sono "Conferma" e "Senza annata". Con il lettore di schermo la ruota è un selettore regolabile: scorrere su e giù cambia l'anno di uno.

**Precisazioni dalla revisione.**
- **"Conferma" in "Componi"** fa come "Sì": compila il campo con "✦ dal testo" e passa alla domanda successiva. Un valore composto non valido (FR1.5) mostra l'errore sotto l'anteprima e la domanda resta aperta.
- **Quali parole si vedono** (FR7.5): niente parole di una lettera, niente numeri che non sono anni plausibili, niente righe di soli gradi, volume o indirizzi web; al massimo 120 parole. Più denominazioni uguali: vale la regola della stima (BR1), e la scelta resta modificabile nel modulo.
- **Ultimo candidato:** su "No, un'altra" senza altri candidati compare per 2 secondi "Nessun'altra proposta: puoi comporla o saltare", con le parole e "Salta" ancora disponibili. Il campo resta vuoto solo con "Salta" o alla chiusura.
- **Tocco fuori durante "Componi":** non chiude la scheda. Chiudono solo "Chiudi" e Indietro, che in "Componi" prima torna alla domanda.
- **Riapertura:** "Conferma guidata" riprende dal primo campo incerto senza risposta; il totale T si ricalcola sui campi rimasti.
- **Campo scritto a mano a guida chiusa:** non si chiede più alla riapertura.
- **Android chiude l'app:** guida e testo si perdono (FR2.3, FR7.9); il modulo torna com'era nell'ultimo stato salvato, senza guida.
- **Attesa G0:** al risultato il pulsante torna "📋 Incolla da Lens" e attivo. Se la ricerca scade a 1,5 secondi, il risultato è il modulo dal testo o la guida; la ricerca che finisce dopo non cambia nulla.
- **Lingue e privacy:** tutti i testi della guida sono nei 3 file ARB (FR7.8). Candidati e parole restano in memoria e non vanno in log o eventi (FR7.9).
- **Ruota dell'annata:** righe alte 48 dp, leggibili con testo 2,0; gli anni del testo hanno il segno • oltre al colore. Un tocco sull'anno al centro apre la tastiera numerica. Sotto: "Conferma <anno>", "Senza annata" (conta come risposta, non si richiede più) e "Salta".
