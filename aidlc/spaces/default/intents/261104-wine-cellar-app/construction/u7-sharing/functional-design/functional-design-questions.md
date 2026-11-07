# Functional Design — u7-sharing — Domande

Contesto:
- `unit-of-work.md` (U7: inviti fino a 5 persone, permessi, revoca, accesso della persona invitata, scelta tra più cantine, regole cloud dei permessi);
- `requirements.md` (FR8.1–FR8.4, NFR4);
- `stories.md` (US8.1–US8.4);
- contratti C3 (`members/{memberUserIdOrEmailKey}` con `inviteeEmail`, `permission` read/edit, `status` invited/active/revoked) e C4 (servizio di condivisione).

Vincolo: piano gratuito di Firebase, senza funzioni nel cloud. L'app non può quindi mandare email da sola.

## Q1. [Prodotto] Come la persona invitata viene a sapere dell'invito

A. Dopo "Invita" l'app apre la condivisione di Android (WhatsApp, email, SMS...) con un messaggio già pronto: chi invita, il link all'app su Google Play e l'indicazione di accedere con quell'indirizzo Google (consigliato). È gratis e non serve nessun servizio esterno.
B. Nessun messaggio: lo dici tu alla persona, e la cantina comparirà quando accede con quell'email.
C. Email automatica inviata dal sistema. Richiede il piano a pagamento di Firebase (Blaze) e un servizio di posta, quindi non rispetta il budget di 0 €.
D. Not yet defined
X. Other (please specify)

[Answer]: A

## Q2. [Prodotto] Serve che la persona invitata accetti l'invito

A. No: quando accede con l'email invitata, la cantina condivisa compare subito nella sua app, con un avviso "Mario ti ha condiviso la sua cantina" che si chiude con un tocco (consigliato). Se non la vuole, può uscire dalla cantina (vedi Q4).
B. Sì: compare un invito con "Accetta" e "Rifiuta". Finché non accetta, la cantina non compare.
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q3. [Prodotto] Cosa può fare chi ha "può modificare"

FR8.2 e US8.4 parlano di aggiungere vini e segnare le bottiglie bevute.

A. Aggiungere e modificare vini, cambiare le quantità e segnare le bevute. Non può eliminare vini, rinominare la cantina, né invitare o revocare persone (consigliato): la cancellazione resta una scelta del proprietario.
B. Tutto quello che fa il proprietario sui vini, eliminazione compresa. Non può comunque rinominare la cantina, né invitare o revocare persone.
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q4. [Prodotto] La persona invitata può uscire da sola da una cantina condivisa

A. Sì: nel profilo, "Esci da questa cantina", con una conferma. Il proprietario vede che la persona è uscita e può invitarla di nuovo (consigliato).
B. No: solo il proprietario può togliere l'accesso.
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Analisi delle risposte

Non ci sono ambiguità: tutte e quattro le risposte sono A. Le scelte tecniche che non toccano il prodotto le ho decise io e sono elencate nel riepilogo.

## Consolidated Summary Confirmation

- **Invitare (US8.1):**
  - nel profilo della propria cantina, il proprietario inserisce l'email Google della persona e sceglie "solo lettura" o "può modificare";
  - controlli: email valida, non la propria, non già invitata, al massimo 5 persone tra invitate e attive;
  - dopo "Invita" si apre la condivisione di Android con un messaggio pronto (Q1).
  - **Invito, cambio di permesso e revoca richiedono la rete:** così il limite di 5 e gli errori sono confermati dal cloud. Senza rete il pulsante è disattivato e c'è una spiegazione.
- **Accesso della persona invitata (Q2):**
  - appena accede con l'email invitata, la cantina condivisa compare senza passaggi di accettazione, con un avviso "Mario ti ha condiviso la sua cantina";
  - la cantina si trova cercando gli inviti col proprio indirizzo Google, che Google ha già verificato;
  - al primo accesso l'invito passa da "invitata" ad "attiva".
- **Più cantine:** chi ha più di una cantina (la propria più quelle condivise) vede un selettore in alto nel Cruscotto e nella Cantina, con il nome del proprietario e il permesso. Parte dalla propria cantina e ricorda l'ultima scelta sul telefono.
- **Permessi (Q3):**
  - "solo lettura" vede vini, stime, cruscotto e bevute, ma non i comandi di aggiunta, modifica, eliminazione e bevuta (AC8.3.1);
  - "può modificare" aggiunge e modifica vini, cambia le quantità e segna le bevute;
  - nessuna persona invitata elimina vini, rinomina la cantina, invita o revoca (AC8.4.2);
  - le regole cloud rifiutano comunque ogni scrittura non permessa (AC8.3.2, NFR4).
- **Revoca (US8.2):** il proprietario sceglie "Revoca" e conferma scrivendo il nome o l'email della persona. Alla sua sincronizzazione successiva, la persona non vede più la cantina e riceve il messaggio "Non hai più accesso alla cantina di Mario". Il proprietario può invitarla di nuovo.
- **Cambio di permesso:** il proprietario può passare una persona da "solo lettura" a "può modificare" e viceversa; vale dalla sincronizzazione successiva.
- **Uscire (Q4):** la persona invitata sceglie "Esci da questa cantina" e conferma. Il proprietario la vede come "uscita" e può invitarla di nuovo.
- **Dati:**
  - nel documento dell'invito aggiungo il nome del proprietario e chi ha chiuso l'accesso (proprietario o persona). Sono aggiunte compatibili al modello dati condiviso;
  - la chiave dell'invito è l'email in minuscolo.
- **Regole cloud:** il nuovo file delle regole si prova solo sugli emulatori. In produzione va pubblicato solo con la tua approvazione.
- **Fuori da questa unità:** la cancellazione dell'account, che revoca tutte le condivisioni, è di u8, che userà l'operazione di revoca preparata qui.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
