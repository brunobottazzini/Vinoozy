# Domande — Requirements Analysis (label-autofill-windows)

## Contesto

Dalla mappa del codice (Reverse Engineering):
- **Testo dell'etichetta.** Oggi Vinoozy ne ricava solo il nome (la riga più significativa) e l'annata, e non riceve testo da fuori: non legge gli appunti e non accetta testo condiviso.
- **Stima.** Copre 47 denominazioni italiane, senza vitigni.
- **Finestra di consumo.** Viene ricalcolata in tre punti (modifica, aggiornamento della stima, ricalcolo dopo le bevute), quindi una correzione a mano andrebbe persa se non la proteggiamo.
- **Regole Firestore.** Accettano solo la forma attuale della finestra.

Le scelte enologiche le decido io e le motivo:
- denominazioni e vitigni del mondo;
- quanto il "Livello" sposta la finestra.

## Q1. [Prodotto] Come arriva in Vinoozy il testo letto da Google Lens

A) In tutti e due i modi (consigliata):
- in Lens tocchi "Condividi" → Vinoozy, e il testo arriva direttamente;
- oppure tocchi "Copia" in Lens e in Vinoozy premi "Incolla da Lens" nel modulo.

B) Solo con il pulsante "Incolla da Lens" nel modulo (copia in Lens, poi incolla).

C) Solo con "Condividi" da Lens verso Vinoozy.

X. Other (please specify)

[Answer]: A

## Q2. [Prodotto] Cosa succede quando la foto non trova il vino in nessuna base

A) Si apre subito il modulo già compilato con i campi ricavati dal testo dell'etichetta (nome, produttore, denominazione, annata, tipo, paese, regione). Controlli e salvi. "Cerca online" e "Apri in Google Lens" restano disponibili dal modulo (consigliata)

B) Resta la schermata "Non trovato" di oggi, con un nuovo pulsante "Compila dall'etichetta" che apre il modulo compilato

X. Other (please specify)

[Answer]: X — A, con in più un pulsante "Pulisci" nel modulo per svuotare i campi se la precompilazione non va bene

## Q3. [Prodotto] Il campo "Livello" (Quotidiano / Buono / Da invecchiamento)

A) Facoltativo. Se non lo scegli vale "Buono", cioè la stima di oggi. L'app lo propone da sola quando il nome contiene "Riserva", "Gran Selezione" o "Grand Cru", e tu puoi cambiarlo (consigliata)

B) Obbligatorio a ogni vino nuovo

C) Facoltativo, senza nessuna proposta automatica

X. Other (please specify)

[Answer]: A

## Q4. [Prodotto] Correzione a mano della finestra

A) Correggi solo "Consigliato fino al", con "Ripristina stima" per tornare al calcolo dell'app. La correzione resta valida anche quando la stima si aggiorna (consigliata)

B) Correggi sia "Pronto da" sia "Consigliato fino al"

X. Other (please specify)

[Answer]: A

## Aggiunta in Build and Test (2026-11-08): conferma guidata

Il proprietario ha provato la build sul telefono (messaggi 4e9809bc e c19931c2). Propone una conferma guidata quando i campi letti dal testo non sono certi, per esempio: "Barbera d'Asti: è la denominazione? Sì", poi "Cascina Castlet è il produttore? Sì / No / Modifica". Con "No" l'app propone un'altra parola del testo, finché il modulo è completo. La guida deve essere leggera e chiedere il minimo lavoro.

Decido io, e il proprietario può correggere:
- la guida è una scheda in basso sopra il modulo, con il progresso (per esempio 2 di 4) e "Salta" sempre disponibile;
- con "No" si propone il candidato successivo più probabile; quando i candidati finiscono il campo resta vuoto e si passa al successivo;
- "Modifica" apre il campo da scrivere a mano.

## Q5. [Prodotto] Quando parte la conferma guidata

A) Da sola, dopo "Incolla da Lens", il testo condiviso o la foto, ma solo se almeno un campo importante è incerto. Se tutto è certo il modulo si compila senza domande (consigliata)

B) Solo quando tocchi un pulsante "Conferma guidata" nel modulo

X. Other (please specify)

[Answer]: A

## Q6. [Prodotto] Su quali campi fa domande

A) Solo sui campi incerti tra denominazione, produttore, nome e annata. Tipo, paese e regione seguono dalla denominazione confermata, senza domande (consigliata)

B) Su tutti i campi ricavati, anche quelli certi, uno per uno

X. Other (please specify)

[Answer]: A
