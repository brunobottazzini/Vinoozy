# Functional Design — u4-cellar — Domande

Contesto:
- `unit-of-work.md` (U4: gestione completa della cantina, con la decisione del 2026-11-06 sull'archivio dei vini finiti);
- `requirements.md` (FR2.1, FR2.3–FR2.7, FR3.1–FR3.4, FR4.1–FR4.7, FR6.1–FR6.4, FR7.1–FR7.2, FR9.4, NFR1);
- `stories.md` (US2.1, US2.3, US3.1–US3.4, US4.1, US4.2, US6.1, US6.2, US7.1, US9.2);
- contratti C1 (catalogo, U3), C2 (stima, U2), C3 (dati), C4 (condivisione, U7);
- unità già costruite: U1, U2, U3, U5, U7.

Le scelte di enologia, cioè finestre, soglie e abbinamenti, sono già nel pacchetto di stima (U2) e non le chiedo. Restano tre scelte di prodotto.

## Q1. [Prodotto] Si può correggere a mano la finestra di consumo stimata

La stima viene dal catalogo o dalle regole interne. Tu, o chi ha "può modificare", potreste conoscere meglio un vino specifico.

A. Sì: nel dettaglio del vino, "Correggi la finestra" permette di cambiare inizio, picco e fine. La fonte diventa "modificata da te". La correzione resta finché non scegli "Torna alla stima"; un nuovo calcolo automatico (cambio di annata, dati dal catalogo) non la sovrascrive (consigliato).
B. No: la finestra è sempre quella calcolata; si corregge solo cambiando nome, annata o tipologia.
C. Not yet defined
X. Other (please specify)

[Answer]: X. Secondo me deve essere non modificabile. Al massimo se apro qualcosa che pensiamo che non sia adeguato al consumo. Si indica che era ancora buono. Si prende questo dato e si ricalcola automaticamente. Sempre un warning stima bla bla

## Q2. [Prodotto] Come si segna una bottiglia bevuta

FR6.2 prevede voto, note e data, tutti facoltativi.

A. Un tocco su "Bevuta" toglie subito una bottiglia. Compare un messaggio con "Annulla" e "Aggiungi voto e note" per qualche secondo; voto e note si possono aggiungere anche dopo, dallo Storico (consigliato). È il gesto più veloce a tavola.
B. Ogni volta si apre un pannello con voto, note e data (già sulla data di oggi) e il pulsante "Salva"; senza toccare nulla si salva con i valori vuoti.
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q3. [Prodotto] Dove si ritrovano i vini finiti

Hai deciso che l'elenco di tutti i giorni carica solo le bottiglie presenti, e che i vini finiti stanno in un archivio letto solo quando serve.

A. Nello **Storico**, terza scheda in basso accanto a Cruscotto e Cantina: le bevute dalla più recente, con data, voto e note. Toccando una bevuta si apre il vino, anche se è finito, con "Aggiungi di nuovo" per ricomprarlo (consigliato). Non c'è un elenco separato dei vini finiti.
B. Lo Storico come sopra, più un elenco "Finiti" nella Cantina (un filtro) con tutti i vini a quantità 0.
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Analisi delle risposte

- **Q1 (risposta libera):** la finestra non si modifica a mano. Si può però dire com'era una bottiglia quando la si beve, soprattutto se l'app la considerava fuori finestra ("era ancora buono"). L'app usa questo riscontro per ricalcolare da sola la finestra delle bottiglie rimaste dello stesso vino, e mostra sempre un avviso che la stima è indicativa. Come applicare il riscontro è una scelta di enologia, quindi la decido io con una motivazione (vedi riepilogo, "Riscontro sulla bevuta").
- **Q2 e Q3:** A, senza ambiguità.

## Consolidated Summary Confirmation

- **Aggiungere un vino (US2.1):**
  - mentre scrivi, l'app propone i vini dal catalogo interno e da Open Food Facts (U3);
  - scegliendo una proposta, produttore, tipologia, denominazione e regione si compilano da soli;
  - controlli: nome obbligatorio fino a 120 caratteri; annata dal 1900 a quest'anno oppure "senza annata"; quantità da 1 a 99, già impostata a 1;
  - la stima e gli abbinamenti si calcolano subito sul telefono, anche senza rete, e si aggiornano se poi il catalogo dà dati migliori.
  - **Produttore (richiesta del proprietario, 2026-11-06):** il campo produttore propone sia i produttori del catalogo sia quelli già presenti nelle tue cantine. Se il produttore non c'è, l'ultima voce dell'elenco è sempre **"Aggiungi «nome scritto» come nuovo produttore"**. Il nome si salva così com'è scritto e dalla volta successiva compare tra le proposte. Lo stesso vale per un vino che non si trova: si salva con i dati scritti a mano.
  - **Aggiunta con la foto dell'etichetta:** è prevista nell'unità u6, dopo questa, con la lettura del testo sul telefono, quindi senza costi. Qui non si progetta; il pulsante "Foto" comparirà con u6.
- **Doppioni (US2.3):** un vino con lo stesso nome, produttore e annata di uno già presente, anche se finito, non crea una nuova voce. L'app mostra il vino esistente e, se confermi, aggiunge le bottiglie a quello. Un vino finito torna così nella Cantina.
- **Cantina (US3.1, US3.2):**
  - l'elenco carica solo le bottiglie presenti (la tua scelta dell'archivio);
  - ogni riga mostra nome, annata, quantità, stato con icona e testo, e fiducia della stima;
  - ricerca per nome, senza distinguere maiuscole e accenti, e filtri per stato e tipologia;
  - senza risultati compare "Nessun vino con questi filtri" e "Azzera filtri";
  - con la cantina vuota compare l'invito ad aggiungere il primo vino.
- **Dettaglio del vino (US4.1, US7.1):**
  - finestra con inizio, picco e fine, stato, fiducia e fonte ("base dati vini" o "stima per tipologia");
  - un avviso sempre visibile: **"Stima indicativa: dipende anche da come è stata conservata la bottiglia"**;
  - abbinamenti, con l'indicazione quando sono quelli generici della tipologia.
- **Modifica ed eliminazione (US3.3, US3.4):**
  - si modificano nome, produttore, annata e quantità, e la stima si ricalcola;
  - "Elimina" chiede conferma con il nome del vino, non lascia nulla nello Storico ed è riservata al proprietario (regola di u7);
  - le quantità cambiano sempre come variazioni (+1, −1), così due persone offline non si annullano a vicenda (US9.2), e non scendono mai sotto 0.
- **Bevuta (US6.1, Q2 = A):**
  - un tocco su "Bevuta" toglie una bottiglia e registra la bevuta con la data di oggi;
  - per qualche secondo compare un messaggio con "Annulla" e "Aggiungi voto e note";
  - voto da 1 a 5, note fino a 1.000 caratteri e data si possono aggiungere o cambiare anche dopo, dallo Storico;
  - a quantità 0 il vino esce dalla Cantina e resta nello Storico.
- **Riscontro sulla bevuta (Q1, regola decisa da me):**
  - nella stessa scheda di voto e note c'è una domanda facoltativa: "Com'era?", con le risposte "Ancora giovane", "Al punto giusto" e "Già passato";
  - l'app aggiorna da sola la finestra delle bottiglie rimaste di quel vino, senza modifica a mano:
    - "Al punto giusto" bevuto **dopo** la fine della finestra sposta la fine all'anno successivo a quello della bevuta;
    - "Già passato" bevuto **prima** della fine anticipa la fine all'anno della bevuta;
    - "Ancora giovane" bevuto **dopo** l'inizio sposta l'inizio all'anno successivo, e picco e fine slittano dello stesso numero di anni;
    - negli altri casi la finestra non cambia;
  - conta solo l'ultimo riscontro;
  - la fonte nel dettaglio diventa "stima corretta dalle tue bevute";
  - se la stima di base cambia (nuova annata, dati dal catalogo), il riscontro si applica di nuovo sopra la stima nuova;
  - **motivazione:** spostare solo il limite smentito dalla bottiglia, di un anno, è prudente. Un singolo assaggio non giustifica correzioni più ampie, e chi conosce meglio il vino può comunque dare un nuovo riscontro.
- **Storico (US6.2, Q3 = A):**
  - terza scheda in basso, accanto a Cruscotto e Cantina, con le bevute dalla più recente (data, voto, note);
  - toccando una bevuta si apre il vino, anche se finito, con "Aggiungi di nuovo";
  - senza bevute compare "Qui troverai le bottiglie che hai bevuto".
- **Collegamenti con il resto:**
  - le azioni del Cruscotto (u5) aprono il dettaglio e l'elenco filtrato per stato, al posto della semplice scheda Cantina;
  - nelle cantine condivise i comandi seguono il permesso (u7);
  - la velocità di inserimento resta sotto i 30 secondi nella mediana di 10 prove (NFR1).

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
