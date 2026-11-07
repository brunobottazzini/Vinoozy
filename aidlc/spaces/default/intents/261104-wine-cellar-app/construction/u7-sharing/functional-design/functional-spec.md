# Functional Specification — u7-sharing

Fonti:
- `unit-of-work.md` (U7), `requirements.md` (FR8.1–FR8.4, NFR4), `stories.md` (US8.1–US8.4), `components.md` (Sharing);
- `contract-summary.md` (C3 `members`, C4 servizio di condivisione);
- codice di U1 (`firestore.rules`, `lib/cellar/`, `lib/app/home_shell.dart`);
- risposte in `functional-design-questions.md`, cioè Q1–Q4 tutte A, e riepilogo confermato.

U7 permette al proprietario di condividere la propria cantina con fino a 2 persone (limite portato da 5 a 2 dal proprietario il 2026-11-06, FR8.1), con permesso "solo lettura" o "può modificare". Alla persona invitata permette di vedere e scegliere le cantine condivise con lei. Possiede anche le regole cloud dei permessi (`members` e accessi delle persone invitate, C3).

Funziona sul piano gratuito di Firebase, senza funzioni nel cloud: tutto avviene nell'app, e le regole di sicurezza garantiscono i permessi.

## Interfacce usate e offerte

- **C3, dati:** `cellars/{cellarId}/members/{memberKey}`.
  - `memberKey` è l'email della persona invitata in minuscolo, senza spazi ai lati.
  - Campi di C3: `inviteeEmail`, `inviteeUserId?`, `permission` (`read` | `edit`), `status` (`invited` | `active` | `revoked`), `invitedAt`, `ownerId`.
  - **Aggiunte compatibili di U7** (C3 v1, campi facoltativi che i consumatori ignorano se non li conoscono):
    - `ownerName`, il nome del proprietario da mostrare, perché la persona invitata non può leggere `users/{ownerId}`;
    - `inviteeName?`, il nome mostrato dalla persona invitata quando entra;
    - `closedBy?` (`owner` | `invitee`), chi ha chiuso l'accesso, per distinguere "revocata" da "uscita";
    - `updatedAt`.
  - **Contatore nel documento della cantina:** `memberSlots`, il numero di inviti con stato `invited` o `active`. Serve alle regole per far rispettare il limite di 2 (BR1.2); le regole non possono contare i documenti.
- **C4, servizio di condivisione** (`lib/sharing/`):
  - `invite`, `changePermission`, `revoke`, `canRead`, `canEdit` e `listAccessibleCellars` come nel contratto;
  - in più `leave(cellarId)`, per la persona invitata (Q4), e `activate(cellarId)`, il primo accesso (BR1.4);
  - `revokeAllForUser(userId)` si prepara qui e la usa U8.
- **U1, cantina attiva:** oggi `CellarScreen`, il Cruscotto (U5) e l'inserimento usano la cantina personale `Cellar.personalCellarId(uid)`. U7 introduce `activeCellarProvider`, la cantina scelta, e i tre punti usano quella. È una modifica compatibile: senza cantine condivise la cantina attiva è quella personale.
- **U1, permessi nell'interfaccia:** `CellarScreen` e le schermate di U4 leggono `canEdit` dalla cantina attiva per mostrare o nascondere i comandi (BR1.6).

## Regole della condivisione

L'elenco completo con trigger e violazioni è in `rules.md`.

| ID | Regola |
|---|---|
| BR1.1 | **Chi può invitare.** Solo il proprietario della cantina (`ownerId == uid`) invita, cambia permesso e revoca. Le persone invitate non vedono questi comandi (AC8.4.2). |
| BR1.2 | **Invito valido (FR8.1, FR8.2).** L'email deve essere valida; non può essere quella del proprietario (`selfInvite`) né quella di una persona già `invited` o `active` (`alreadyInvited`). Gli inviti `invited` più `active` sono al massimo 2 (`limitReached`). Il permesso è `read` o `edit`. Un invito con stato `revoked` si riattiva con un nuovo invito, che conta di nuovo nel limite. |
| BR1.3 | **Avviso alla persona (Q1).** Dopo un invito riuscito, l'app apre la condivisione di Android con un messaggio pronto nella lingua dell'app: chi invita, il nome della cantina, il link all'app su Google Play e l'indicazione di accedere con quell'indirizzo Google. Se il proprietario chiude la condivisione, l'invito resta valido. |
| BR1.4 | **Accesso senza accettazione (Q2).** All'accesso, e a ogni ritorno della rete, l'app cerca gli inviti con l'email dell'account Google (`inviteeEmail ==` email dell'account, `status` `invited` o `active`). Ogni invito `invited` diventa `active` (`activate`), con `inviteeUserId` e `inviteeName`. Per ogni cantina nuova compare una volta l'avviso "Mario ti ha condiviso la sua cantina". |
| BR1.5 | **Più cantine.** `listAccessibleCellars` restituisce la cantina personale più quelle con invito `active`. Con più di una cantina compare il selettore (`CellarSwitcher`). Parte dalla cantina personale e ricorda l'ultima scelta sul telefono; se la cantina ricordata non è più accessibile, torna a quella personale. |
| BR1.6 | **Permessi (FR8.4, Q3).** "Solo lettura" (`read`) vede vini, stime, Cruscotto e bevute, ma non i comandi di aggiunta, modifica, eliminazione e bevuta (AC8.3.1). "Può modificare" (`edit`) aggiunge e modifica vini, cambia le quantità e segna le bevute. Nessuna persona invitata elimina vini, rinomina la cantina, invita o revoca. |
| BR1.7 | **Le regole cloud decidono comunque (NFR4, AC8.3.2).** Ogni scrittura non permessa è rifiutata dalle regole, anche se l'interfaccia la lasciasse passare. Una scrittura in coda offline rifiutata dalle regole segue il percorso degli errori di sincronizzazione di U1 (il vino rifiutato è segnalato con la possibilità di riaggiungerlo). |
| BR1.8 | **Revoca (FR8.3, US8.2).** Il proprietario sceglie "Revoca" e conferma scrivendo il nome della persona, o l'email se il nome non c'è ancora. L'invito passa a `revoked` con `closedBy: owner` e `memberSlots` scende di 1. Alla sincronizzazione successiva della persona, la lettura viene rifiutata: la cantina sparisce dal selettore, l'app torna alla cantina personale e mostra "Non hai più accesso alla cantina di Mario". |
| BR1.9 | **Cambio di permesso.** Il proprietario passa una persona da `read` a `edit` o viceversa. Vale dalla sincronizzazione successiva della persona, e l'interfaccia della persona si aggiorna da sola. |
| BR1.10 | **Uscire (Q4).** La persona invitata sceglie "Esci da questa cantina" e conferma. L'invito passa a `revoked` con `closedBy: invitee` e `memberSlots` scende di 1. Il proprietario la vede come "uscita" e può invitarla di nuovo. |
| BR1.11 | **Rete obbligatoria per gestire (riepilogo).** Invito, cambio di permesso, revoca e uscita richiedono la rete. "Confermata dal server" significa: l'app parte solo se lo stato di rete di U1 (`networkStatusProvider`) dice "online", esegue la scrittura in un unico `WriteBatch` e aspetta il completamento di `commit()`, che con la persistenza offline di Firestore si chiude solo quando il server ha accettato. Il tempo massimo è 10 s. Oltre quel tempo l'esito è "non riuscito, riprova", e la scrittura eventualmente rimasta in coda produce lo stesso stato finale se ripetuta, grazie alle transizioni di BR1.13. Senza rete i pulsanti sono disattivati, con la spiegazione "Serve la connessione per gestire la condivisione". La consultazione e le modifiche ai vini restano possibili offline come in U1. |
| BR1.12 | **Elenco delle persone.** Il proprietario vede nell'elenco principale le persone "invitate" (non hanno ancora aperto l'app) e "attive", con nome (o email) e permesso. Una persona revocata o uscita **sparisce dall'elenco principale** (AC8.2.1) e passa nella sezione chiusa "Accessi chiusi", da cui si può reinvitare o eliminare definitivamente. Le persone invitate vedono solo il nome del proprietario e il proprio permesso. |
| BR1.13 | **Transizioni consentite del documento `members`.** Solo quelle della tabella in "Meccanismi senza funzioni nel cloud"; le regole cloud rifiutano tutte le altre. Una persona invitata, in particolare, non può cambiarsi il permesso né rientrare dopo una revoca. |
| BR1.14 | **Ricezione di revoca e cambio di permesso.** L'app della persona invitata ascolta i propri documenti `members` e reagisce come descritto in "Meccanismi senza funzioni nel cloud". |

## Meccanismi senza funzioni nel cloud

Aggiunti il 2026-11-06 dopo la prima revisione. Le regole di sicurezza sono il solo punto di controllo lato cloud. Qui c'è il comportamento richiesto; la forma esatta delle regole è nel design non funzionale.

### Chiave e identità

- `memberKey` = `inviteeEmail`, cioè l'email in minuscolo, senza spazi ai lati.
- L'identità della persona invitata nelle regole è `request.auth.token.email.lower()`, valida solo con `request.auth.token.email_verified == true`. Gli account Google hanno sempre l'email verificata.
- Un accesso è valido solo se il documento `cellars/{cellarId}/members/{email in minuscolo}` esiste con `status == 'active'`. Un invito `invited` non dà accesso finché la persona non lo attiva (BR1.4).

### Contatore `memberSlots` (limite di 2)

- `memberSlots` è un campo facoltativo di `cellars/{cellarId}`. Se manca vale 0 (`resource.data.get('memberSlots', 0)`), così le cantine già esistenti funzionano senza migrazione. `validCellarCreate` di U1 non cambia: il campo nasce al primo invito.
- Ogni operazione che cambia il numero di inviti `invited` o `active` scrive **nello stesso `WriteBatch`** il documento `members` e il contatore:

| Operazione | Chi | `members` | `memberSlots` | Controllo delle regole |
|---|---|---|---|---|
| Invito nuovo | proprietario | crea con `status: invited` | +1 | sul documento `members`: `getAfter(cellar).memberSlots == get(cellar).memberSlots (o 0) + 1` e `<= 2` |
| Reinvito di un accesso chiuso | proprietario | `revoked` → `invited` | +1 | come sopra |
| Revoca | proprietario | `invited` o `active` → `revoked`, `closedBy: owner` | −1 | `getAfter(cellar).memberSlots == get(cellar).memberSlots − 1` |
| Uscita | persona invitata | `active` → `revoked`, `closedBy: invitee` | −1 | come sopra |
| Cambio di permesso | proprietario | `permission` read ↔ edit | invariato | nessuna modifica al contatore |

- Sul documento della cantina le regole aggiungono due casi di `update`, accanto al cambio di `name` di U1:
  - il proprietario può cambiare **solo** `memberSlots`, di +1 o −1, senza scendere sotto 0 né salire sopra 5;
  - la persona invitata può cambiare **solo** `memberSlots`, di −1, se nello stesso batch il proprio documento `members` passa da `active` a `revoked` (`get` prima e `getAfter` dopo, sul percorso calcolato dalla propria email).
- Un proprietario con un client modificato potrebbe abbassare il contatore da solo. Il rischio è accettato: il limite di 2 è una scelta di prodotto per il proprietario, non una protezione dei dati di altri.

### Transizioni del documento `members` (BR1.13)

| Da → a | Chi | Campi che possono cambiare |
|---|---|---|
| (nessuno) → `invited` | proprietario | crea: `inviteeEmail` (= chiave), `permission`, `status`, `invitedAt` (= ora del server), `ownerId` (= uid), `ownerName`, `updatedAt` |
| `invited` → `active` | persona invitata (`inviteeEmail` = la propria email) | `status`, `inviteeUserId` (= il proprio uid), `inviteeName`, `updatedAt` |
| `invited` o `active` → stesso stato | proprietario | `permission`, `updatedAt` |
| `invited` o `active` → `revoked` | proprietario | `status`, `closedBy: owner`, `updatedAt` |
| `active` → `revoked` | persona invitata | `status`, `closedBy: invitee`, `updatedAt` |
| `revoked` → `invited` | proprietario | `status`, `permission`, `invitedAt`, `closedBy` (rimosso), `updatedAt` |
| eliminazione | proprietario | solo se `status == revoked` ("elimina definitivamente") |
| eliminazione | persona invitata (il proprio documento) | solo se `status == revoked`; serve a U8 e a togliere la propria email (aggiunto il 2026-11-06, NFR8.3 di U7) |

Qualunque altra modifica è rifiutata. In particolare la persona invitata non tocca mai `permission`, `ownerId`, `ownerName`, `inviteeEmail`, e non esce da `revoked`.

### Letture della persona invitata

- **I propri inviti:** una regola sul gruppo di collezioni (`match /{path=**}/members/{memberKey}`) consente `get` e `list` quando `resource.data.inviteeEmail == request.auth.token.email.lower()` e l'email è verificata, **in ogni stato**, così l'app vede anche le revoche.
- **Indice:** `firestore.indexes.json` aggiunge un `fieldOverride` con scopo `COLLECTION_GROUP` su `members.inviteeEmail`, che oggi è vuoto.
- **Cantina, vini e bevute:** `get` del documento `cellars/{cellarId}` (nome, proprietario), lettura di `wines` e `drinkingRecords` per un invito `active` con permesso `read` o `edit`.
- **Scrittura:** creazione e aggiornamento di `wines` e creazione di `drinkingRecords` solo per un invito `active` con `edit`. Mai eliminazione di vini.
- **Costo in letture:** ogni regola che controlla un permesso legge al più 2 documenti (cantina e `members`). Le valutazioni delle regole sono memorizzate per richiesta, quindi una query o una scrittura costa al più 2 letture in più, non 2 per documento restituito. Con l'uso previsto (una cantina da 500 vini, pochi inviti) si resta molto sotto le 50.000 letture al giorno del piano gratuito. La stima precisa va nei requisiti non funzionali.
- **`drinkingRecords`:** oggi `firestore.rules` non ha regole per questa raccolta. U7 prepara le funzioni comuni `canReadCellar(cellarId)` e `canEditCellar(cellarId)`. (Aggiornato il 2026-11-06 nei requisiti non funzionali di U7, NFR4.8.) U7 scrive anche il blocco `match` di `drinkingRecords`: lettura con `canReadCellar`; creazione con `canEditCellar` e con i campi di C3 validati (tipi, lunghezze, `recordedBy == uid`); nessuna modifica né eliminazione. U4 lo usa e può solo restringere la validazione.

### Ricezione di revoca e cambio di permesso (BR1.14)

- Dopo l'accesso, l'app della persona invitata tiene aperto un ascolto sulla query dei propri inviti (`members` con `inviteeEmail` = propria email). È la stessa query di BR1.4.
- **Cambio di permesso:** il documento cambia `permission`; `canEdit` della cantina attiva si aggiorna da solo e i comandi compaiono o spariscono subito.
- **Revoca o uscita:** il documento passa a `revoked`. L'app chiude gli ascolti di quella cantina, la toglie dal selettore, torna alla cantina personale e mostra il messaggio di BR1.8 (non per l'uscita fatta dalla persona stessa).
- **Rifiuto sugli ascolti:** se un ascolto di vini o cantina viene chiuso dalle regole (`permission-denied`) prima che arrivi il cambio del documento, l'effetto è lo stesso.
- **Dati in cache:** i documenti della cantina restano nella cache locale di Firestore, ma l'app non li mostra più, perché nessuna schermata apre una cantina fuori da `listAccessibleCellars`. La cache si svuota del tutto all'uscita dall'account (U1, reset) e con la cancellazione dell'account (U8).
- **Scritture in coda rifiutate:** ogni scrittura rifiutata dalle regole va nel bus degli errori di sincronizzazione di U1 (`SyncErrorBus`). Comprende la creazione di un vino, l'incremento di una quantità e la creazione di una bevuta.
  - Un vino creato e rifiutato segue il percorso di U1, con l'avviso e la possibilità di riaggiungerlo.
  - Gli altri rifiuti sulla stessa cantina si raccolgono in un solo avviso: "Alcune modifiche alla cantina di Mario non sono state salvate perché non hai più accesso".

## Integrazione con U1 (dopo la seconda revisione, 2026-11-06)

Punti di U1 che oggi assumono la cantina personale e che U7 cambia, in modo compatibile: senza condivisioni il comportamento resta identico.

| Punto di U1 | Cambio |
|---|---|
| `CellarScreen`, `AddWineScreen`, Cruscotto (U5) | Usano `activeCellarProvider` invece di `Cellar.personalCellarId(uid)`. |
| `OfflineBanner(uid)` e `syncStatusProvider(uid)` | Ricevono l'id della cantina attiva. Per la cantina personale l'id coincide con l'uid, quindi il comportamento non cambia. |
| `reopenCellarListeners`, `invalidateFirestoreListeners`, `AccountGate.retryCellar` | Invalidano anche l'ascolto dei propri inviti (`myMembershipsProvider`) e i flussi della cantina attiva, non solo di quella personale. |
| Reset all'uscita dall'account (NFR4.10 di U1) | Chiude anche `myMembershipsProvider` e cancella la cantina scelta salvata sul telefono. |
| Conteggio degli ascolti (NFR5.1 di U1) | Un ascolto in più per utente (i propri inviti), più quelli della cantina attiva, uno per volta. |
| `SyncErrorBus` | Nuovo evento compatibile `CellarAccessLost(cellarId, ownerName)`. Ogni rifiuto `permission-denied` su una scrittura con percorso in una cantina condivisa (incremento di quantità, bevuta, modifica) pubblica questo evento, con il `cellarId` letto dal percorso del documento. L'interfaccia mostra un solo avviso per cantina e sessione. La creazione di un vino rifiutata continua a pubblicare anche `WriteRejected`, come in U1. I rifiuti si rilevano dove U1 già li intercetta, cioè sul completamento delle scritture in coda nei repository. |
| `NetworkStatus` | Oggi offre solo `hasNetwork()`. U7 aggiunge uno stream compatibile `onChanged` (da `connectivity_plus`), che abilita e disabilita i comandi di BR1.11. Il controllo puntuale `hasNetwork()` resta prima di ogni operazione. |

**Altri chiarimenti:**
- **Una sola query degli inviti.** BR1.4 e BR1.14 usano la stessa query: `inviteeEmail ==` la propria email, **senza filtro sullo stato**. L'app filtra gli stati in memoria. Basta quindi l'indice su un solo campo `inviteeEmail`, con scopo gruppo di collezioni.
- **Creazione di `members`:** `permission` deve essere `read` o `edit`, e `inviteeEmail` deve coincidere con la chiave del documento ed essere in minuscolo.
- **Email Gmail con puntini:** la chiave è l'email così come Google la restituisce nel token, in minuscolo. L'app non toglie i puntini, quindi il proprietario deve scrivere l'indirizzo esatto. Il messaggio di BR1.3 dice di usare proprio quell'indirizzo.
- **Errori del cloud nelle operazioni di gestione:** `permission-denied` diventa `notOwner`, oppure "Hai raggiunto il limite di 2 persone" se il contatore è al massimo; `not-found` diventa `notFound`; `unavailable` e il tempo scaduto diventano "non riuscito, riprova".
- **Cache dopo la revoca (rischio accettato):** i documenti della cantina restano nella cache locale finché la persona non esce dall'account. L'app non li mostra mai. Chi ha accesso al telefono sbloccato con strumenti di sviluppo potrebbe leggerli. Il rischio è accettato: sono dati che la persona ha già visto legittimamente.
- **U4 e le bevute:** U4 usa le funzioni comuni delle regole `canReadCellar` e `canEditCellar` scritte da U7, che stanno nello stesso file `firestore.rules`. Il contratto C4 indica già U4 tra i consumatori di U7, e nell'ordine di lavoro U7 viene prima di U4. Il test di AC8.4.1 sulle bevute dall'app si completa quindi in U4. In U7 si prova con i test delle regole sugli emulatori, scrivendo un documento `drinkingRecords` con un permesso `edit`.

## Flussi

1. **Invitare.** Proprietario → "Persone" nella cantina → "Invita" → email e permesso → controlli locali (formato, sé stesso, già invitata, limite) → scrittura con conferma del server → messaggio di Android (BR1.3) → la persona compare come "invitata".
2. **Primo accesso dell'invitata.** Accesso Google → ricerca degli inviti (BR1.4) → attivazione → avviso → il selettore mostra la nuova cantina.
3. **Lavorare in una cantina condivisa.** Selettore → cantina di Mario → Cruscotto e Cantina con i comandi del permesso (BR1.6). Le modifiche offline si sincronizzano come in U1.
4. **Revocare, cambiare permesso, uscire.** Vedi BR1.8–BR1.10. L'esito per l'altra persona arriva alla sua sincronizzazione successiva.

## Errori e casi limite

| Caso | Comportamento |
|---|---|
| Email non valida | Errore sotto il campo, "Inserisci un'email valida" (AC8.1.3). |
| 2 persone già invitate o attive | "Hai raggiunto il limite di 2 persone" e pulsante disattivato (AC8.1.2). |
| Invito a sé stessi | "Non puoi invitare te stesso". |
| Persona già invitata | "Questa persona è già invitata". |
| Nessuna rete | Comandi di gestione disattivati (BR1.11). |
| Errore del server durante l'invito | "Invito non riuscito. Riprova", senza cambiare l'elenco. |
| L'invitata accede con un altro account Google | Non vede la cantina: l'invito vale solo per quell'email. Il messaggio di BR1.3 lo spiega. |
| Revoca mentre la persona è offline con modifiche in coda | Al ritorno della rete le sue scritture sono rifiutate (BR1.7) e la cantina sparisce (BR1.8). |
| Il proprietario cancella l'account | Gestito da U8 con `revokeAllForUser`. |

## Fuori ambito

- Notifiche push o email automatiche (Q1: servirebbe il piano a pagamento).
- Trasferire la proprietà di una cantina.
- Più di una cantina propria per utente.
- Cancellazione dell'account (U8).
