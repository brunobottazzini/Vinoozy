# Requirements Analysis — Domande

Contesto: `intent-statement.md`, `scope-document.md`, `team-practices.md` e le fasi precedenti. Chiedo solo ciò che non è ancora deciso.

## Q1. [Prodotto] Quando una bottiglia diventa "da bere presto"

Determina quali bottiglie il cruscotto evidenzia come avviso.

A. Quando mancano 6 mesi o meno alla fine della finestra ideale
B. Quando mancano 3 mesi o meno
C. Quando mancano 12 mesi o meno
D. Not yet defined
X. Other (please specify)

[Answer]: X. Scelta lasciata a me ("che ne so io non sono sommelier. Mi aspettavo una risposta tua signora ia con tutta la conoscenza umana"): proporzionale alla finestra. Una bottiglia è "da bere presto" quando resta il 25% o meno della sua finestra ideale, con un minimo di 3 mesi e un massimo di 12 mesi prima della fine. Così un bianco con finestra di 2 anni viene segnalato 6 mesi prima, un Barolo con finestra di 15 anni 12 mesi prima.

## Q2. [Prodotto] Come registrare più bottiglie dello stesso vino e annata

Riguarda sia l'inserimento scritto sia quello da foto (la revisione dei mockup ha segnalato che nel percorso foto mancava la quantità).

A. Una sola voce con la quantità (es. Barolo 2016 x3), in entrambi i percorsi
B. Ogni bottiglia è una voce separata
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q3. [Prodotto] Formato della bottiglia

Il formato (es. magnum) cambia la velocità di invecchiamento e quindi la stima.

A. Solo bottiglia standard da 0,75 L
B. Formato facoltativo (0,375 / 0,75 / 1,5 L), considerato nella stima
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q4. [Prodotto] Con quante persone puoi condividere la cantina

A. Una sola persona oltre a te
B. Fino a 5 persone
C. Not yet defined
X. Other (please specify)

[Answer]: B

## Q5. [Prodotto] Come mostrare l'indice di fiducia della stima

A. Tre livelli: alta / media / bassa
B. Una percentuale (es. 80%)
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q6. [Prodotto] Vuoi poter esportare l'inventario

A. Sì: esportazione in un file (CSV) da aprire con un foglio di calcolo
B. No: basta il salvataggio nel cloud
C. Not yet defined
X. Other (please specify)

[Answer]: B

## Consolidated Summary Confirmation

- Da bere presto (Q1, scelta lasciata a me): quando resta il 25% o meno della finestra ideale, con minimo 3 e massimo 12 mesi di preavviso.
- Quantità (Q2): una sola voce per vino e annata con la quantità, sia scrivendo sia da foto.
- Formato (Q3): solo bottiglia standard da 0,75 L.
- Condivisione (Q4): fino a 5 persone oltre al proprietario.
- Fiducia della stima (Q5): tre livelli, alta / media / bassa.
- Esportazione (Q6): no, basta il cloud.
- Oltre a questo i requisiti riprendono quanto già deciso nelle fasi precedenti (login Google, solo Android, offline con sincronizzazione, Firebase a 0 €, WCAG AA, lingue it/en/pt-BR, storico con voto e note, avvisi solo nel cruscotto) e aggiungo la cancellazione dell'account dall'app, obbligatoria su Google Play per le app con account.

Does this all look correct before I generate the requirements artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
