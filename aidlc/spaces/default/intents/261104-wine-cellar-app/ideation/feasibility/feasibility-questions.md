# Feasibility & Constraints — Domande

Contesto: `intent-statement.md` (Intent Capture). Hai chiesto anche una stima dei costi con la cantina su un database cloud: queste domande servono a renderla concreta.

## Q1. [Sviluppo] Che esperienza hai con lo sviluppo di app mobili

Determina quale tecnologia multipiattaforma (Android + iPhone con un solo codice) è più realistica per te.

A. Conosco già un framework multipiattaforma (es. React Native o Flutter)
B. Sviluppo web o backend, ma non ho mai fatto app mobili
C. Nessuna preferenza: scegli tu la soluzione più adatta
D. Not yet defined
X. Other (please specify)

[Answer]: C

## Q2. [Sviluppo] Hai una preferenza per il fornitore cloud del database

Il fornitore incide su costi, login Google/Apple e semplicità.

A. Firebase (Google)
B. Supabase
C. AWS
D. Nessuna preferenza: il più semplice ed economico
X. Other (please specify)

[Answer]: A

## Q3. [Prodotto] Qual è il budget mensile massimo per il cloud

A. 0 €: solo piani gratuiti
B. Fino a 5 €/mese
C. Fino a 25 €/mese
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q4. [Prodotto] Account Apple Developer (circa 99 $/anno)

Serve per installare l'app in modo stabile su iPhone; senza, l'installazione da computer scade dopo 7 giorni.

A. Ce l'ho già
B. Lo sottoscrivo
C. Preferisco evitarlo per ora (all'inizio solo Android)
D. Not yet defined
X. Other (please specify)

[Answer]: C

## Q5. [Prodotto] Entro quando vorresti usare la prima versione

A. Entro 1 mese
B. Entro 1–3 mesi
C. Nessuna scadenza
D. Not yet defined
X. Other (please specify)

[Answer]: C

## Q6. [Prodotto] Come deve stimare l'app il momento ideale e gli abbinamenti

È il rischio tecnico principale: l'app deve sapere da sola quando un vino è pronto e con cosa abbinarlo.

A. Con un servizio di intelligenza artificiale (piccolo costo a ogni richiesta, risposte più ricche)
B. Con una base dati di vini esterna, se disponibile (dipende da fornitori terzi)
C. Con regole interne per tipologia, denominazione e annata (gratis, meno precise)
D. Not yet defined
X. Other (please specify)

[Answer]: X. cercherei 2 se non si trova una regola interna meno precisa. Magari dare un fiducia indici

## Q7. [Conformità] Ci sono vincoli su dove stanno i dati

Con il login vengono salvati email e foto: dati personali.

A. I dati devono restare in Unione Europea
B. Nessun vincolo particolare
C. Not applicable
D. Not yet defined
X. Other (please specify)

[Answer]: C

## Q8. [Sviluppo] L'app deve funzionare anche senza connessione

In cantina spesso il segnale è scarso.

A. Sì: deve funzionare offline e sincronizzare quando torna la rete
B. No: basta che funzioni online
C. Solo consultazione offline, modifiche online
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q9. [Prodotto] Hai già un account sviluppatore Google Play

A. Sì, ho già un'app pubblicata su Google Play
B. No
C. Not yet defined
X. Other (please specify)

[Answer]: A. ho un app pubblicatgo già su google play store eh almeno questo

## Q10. [Prodotto] Come gestire iPhone nella prima versione

In Intent Capture l'app è per Android e iPhone, ma in Q4 hai scelto di evitare per ora l'account Apple. Il codice resta unico per entrambe le piattaforme; cambia solo dove la installi.

A. Prima versione solo su Android; iPhone quando sottoscrivo l'account Apple
B. Android stabile + iPhone in prova (reinstallazione da computer ogni 7 giorni)
C. Sottoscrivo comunque l'account Apple, mia moglie usa iPhone
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q11. [Prodotto] Piano a consumo di Firebase con budget 0 €

Con Firebase, per salvare le foto delle etichette serve attivare il piano a consumo (con carta collegata). Con i tuoi volumi resti nella quota gratuita, quindi 0 €, e si può impostare un avviso di spesa.

A. Va bene: piano a consumo con avviso di spesa a 1 €
B. No carta collegata: le foto restano solo sul telefono, nel cloud solo i dati testuali
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Consolidated Summary Confirmation

- Tecnologia (Q1): nessuna preferenza, scelgo io la soluzione multipiattaforma più adatta.
- Cloud (Q2): Firebase.
- Budget (Q3, Q11): 0 €/mese; piano a consumo Firebase attivato con avviso di spesa a 1 €, restando nella quota gratuita.
- Piattaforme (Q4, Q9, Q10): prima versione solo su Android (hai già un account Google Play con un'app pubblicata); iPhone quando sottoscriverai l'account Apple. Il codice resta unico per entrambe.
- Tempi (Q5): nessuna scadenza.
- Momento ideale e abbinamenti (Q6): prima una base dati di vini esterna; se il vino non si trova, regole interne meno precise, mostrando un indice di fiducia della stima.
- Dati personali (Q7): nessun vincolo di residenza dei dati.
- Offline (Q8): l'app funziona senza connessione e sincronizza quando torna la rete.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
