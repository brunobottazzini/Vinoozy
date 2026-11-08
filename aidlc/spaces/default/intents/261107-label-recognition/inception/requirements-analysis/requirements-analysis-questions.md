# Domande — Requirements Analysis (label-recognition)

Contesto (Reverse Engineering):
- oggi c'è una sola foto per lettura;
- non c'è nessun database locale: offline un codice a barre non trova nulla;
- la ricerca testuale su Open Food Facts esiste ma prende in silenzio il primo risultato;
- Google Lens non c'è;
- la foto si cancella prima che compaia l'esito.

## Q1. [Prodotto] Come arriva la base offline dei vini sul telefono

A) Inclusa nell'app: la base ricavata dall'export di Open Food Facts va dentro l'app a ogni versione e funziona subito, anche senza rete. Si aggiorna con le nuove versioni dell'app. L'app diventa più pesante (stima: qualche MB); avevi detto che il peso non è un problema (consigliata)
B) Scaricata al primo avvio su Wi-Fi da un file pubblico gratuito (per esempio un rilascio GitHub): app più leggera, ma la base manca finché non si scarica
X. Other (please specify)

[Answer]: A

## Q2. [Prodotto] Quali vini mettere nella base offline

A) Tutti i vini di Open Food Facts di tutti i paesi (consigliata)
B) Solo i paesi dell'elenco principale (i 21 della griglia)
C) Solo Italia e Francia, per una base più piccola
X. Other (please specify)

[Answer]: A

## Q3. [Prodotto] Foto del retro

A) Dopo la foto del fronte l'app chiede subito "Ora il retro", con "Salta" sempre visibile (consigliata)
B) Il retro solo con un pulsante facoltativo "Aggiungi il retro" nella schermata dell'esito
C) Fronte e retro in una sola foto, se l'etichetta lo permette, e il retro solo se non si riconosce nulla
X. Other (please specify)

[Answer]: A
