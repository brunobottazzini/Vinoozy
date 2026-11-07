# Security Requirements — u7-sharing

Fonti:
- `requirements.md` (NFR3, NFR4, NFR6, NFR8);
- `functional-spec.md` e `rules.md` di U7, in particolare "Meccanismi senza funzioni nel cloud" e "Integrazione con U1";
- `contract-summary.md` (C3, C4);
- regole di sicurezza di U1 (`firestore.rules`, NFR4.2–NFR4.5 di U1);
- riepilogo confermato in `nfr-requirements-questions.md`.

Come per le altre unità di interfaccia, questo file raccoglie anche l'accessibilità (NFR3) e l'affidabilità (NFR6).

## Sicurezza delle regole cloud (NFR4)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR4.1 | **Matrice di accesso.** Lettura di `cellars/{id}`, `wines` e `drinkingRecords`: proprietario, e invito `active` con `read` o `edit`. Creazione e aggiornamento di `wines` e creazione di `drinkingRecords`: proprietario, e invito `active` con `edit`. Eliminazione di vini: solo il proprietario. Rinomina della cantina: solo il proprietario. Una persona con invito `invited` o `revoked`, oppure un estraneo, non legge né scrive nulla. | Test delle regole sugli emulatori (`test/rules/u7.rules.test.mjs`) con una riga per ogni combinazione: **6 ruoli** (proprietario, `read`, `edit`, `invited`, `revoked`, estraneo) × **9 operazioni**:<br>1. `get` della cantina;<br>2. rinomina della cantina;<br>3. lettura dei vini;<br>4. creazione di un vino;<br>5. aggiornamento di un vino, compreso l'incremento della quantità;<br>6. eliminazione di un vino;<br>7. lettura delle bevute;<br>8. creazione di una bevuta;<br>9. `list` dei `members` della cantina.<br>Ogni caso vietato è un `assertFails`, ogni caso permesso un `assertSucceeds`. |
| NFR4.2 | **Transizioni di `members`** come nella tabella di `functional-spec.md` (BR1.13). La persona invitata non cambia mai `permission`, `ownerId`, `ownerName` o `inviteeEmail`, e non esce da `revoked`. | Un test per ogni transizione consentita e almeno uno per ogni transizione vietata: autopromozione a `edit`, rientro da `revoked`, attivazione di un invito di un'altra email, cambio di `ownerId`. |
| NFR4.3 | **Limite di 2 e contatore `memberSlots`** (limite portato da 5 a 2 il 2026-11-06). Il terzo invito è rifiutato. Il contatore cambia solo di ±1 e insieme al documento `members` (`getAfter`). La persona invitata può solo abbassarlo di 1 uscendo. Se il campo manca vale 0. | Test: 2 inviti riusciti e terzo rifiutato; contatore cambiato senza `members` → rifiuto; cambio di +2 → rifiuto; uscita con −1 → riuscita; cantina senza campo → primo invito riuscito. |
| NFR4.4 | **Identità della persona invitata.** Le regole usano `request.auth.token.email.lower()` solo con `email_verified == true`. | Test con un token ad email non verificata (`unverifiedGoogleUser()`, nuovo helper; `googleUser()` imposta ora `email_verified: true`) → nessun accesso; test con l'email in maiuscolo nel token → accesso corretto. |
| NFR4.5 | **Nessuna fuga di email.** Una persona invitata legge solo il proprio documento `members` (query sul gruppo di collezioni filtrata sulla propria email), mai quelli delle altre persone della stessa cantina. Solo il proprietario elenca i `members` della propria cantina. | Test: `list` di `cellars/{id}/members` da parte di una persona invitata → rifiuto; query sul gruppo di collezioni con l'email di un'altra persona → rifiuto. |
| NFR4.6 | **Le regole di U1 non cambiano comportamento per il proprietario.** | I test esistenti `u1.rules.test.mjs` e `compat/` restano verdi. |
| NFR4.8 | **`drinkingRecords` aperto da U7.** U7 scrive il blocco `match` di `cellars/{cellarId}/drinkingRecords/{recordId}`:<br>• lettura con `canReadCellar`;<br>• creazione con `canEditCellar`, solo con i campi di C3 (`wineId`, `wineName`, `vintage?`, `drankOn`, `rating?`, `notes?`, `recordedBy`, `createdAt`), con `recordedBy == uid`, `createdAt == request.time`, `wineName` di 1–120 caratteri, `drankOn` stringa data `YYYY-MM-DD`, `notes` al più 1.000 caratteri e `rating` intero da 1 a 5 se presente;<br>• eliminazione solo del proprietario della cantina, che serve alla cancellazione dei dati (U8);<br>• nessuna modifica in U7.<br>U4 lo usa e può solo restringere la validazione. U8 deciderà se aggiungere una modifica di `recordedBy` (domanda aperta di C3). Aggiornamento del design funzionale del 2026-11-06. | Test delle regole: creazione valida con `edit` e con il proprietario; rifiuto con `read`, con campi in più, con `recordedBy` di un altro e con modifica o eliminazione. |
| NFR4.9 | **Campi mostrati all'altra persona.**<br>• `ownerName` e `inviteeName`: stringhe di 1–100 caratteri.<br>• `inviteeEmail`: stringa di al più 254 caratteri, in minuscolo e senza spazi, con il formato `x@y.z`. Non può contenere `/`, quindi è sempre una chiave di documento valida.<br>• `permission`: solo `read` o `edit`.<br>• `status` e `closedBy`: solo i valori di C3.<br>Lo stesso controllo c'è nell'app prima della scrittura. | Test delle regole con valori al limite e oltre (101 caratteri, email con maiuscole, con `/`, tipo sbagliato). Test della validazione dell'invito nell'app. |
| NFR4.7 | **Pubblicazione delle regole e dell'indice** (`firestore.rules`, `firestore.indexes.json`) in produzione solo con approvazione manuale del proprietario, come da team.md. Va fatta **prima** della versione dell'app che usa la condivisione, perché senza l'indice la query degli inviti fallisce. | Voce nella checklist di rilascio; il job `rules` di CI resta obbligatorio prima del merge. |

## Privacy (NFR8)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR8.1 | **Dati minimi.** Un invito conserva solo `inviteeEmail`, `inviteeName` (dopo l'attivazione), permesso, stato, date, `ownerId` e `ownerName`. L'app non legge rubrica né contatti: l'email si scrive a mano. | Revisione del modello; test del modulo di invito (nessun permesso Android per i contatti nel manifest). |
| NFR8.2 | **Nessuna email nei report.** Gli errori della condivisione passano da `ErrorReporter` di U1, che toglie email e id; i messaggi d'errore di U7 hanno testi fissi. | Test con un'email marcatore: nessuna stringa con l'email arriva al `ErrorSink` finto. |
| NFR8.3 | **Cancellazione.**<br>• "Elimina definitivamente" del proprietario rimuove il documento `members` dal cloud.<br>• La persona invitata può eliminare il **proprio** documento `members` solo se è `revoked`. Serve a U8 (`revokeAllForUser` rimuove gli accessi ricevuti) e a chi vuole togliere la propria email dalla cantina di un altro dopo essere uscito. Il contatore non cambia, perché un accesso `revoked` non occupa posti.<br>• L'uscita normale lascia il documento con `closedBy: invitee`, così il proprietario vede "uscita". | Test delle regole: la persona elimina il proprio documento `revoked` → riuscita; il proprio `active` o quello di un'altra persona → rifiuto. |
| NFR8.4 | **Data Safety di Google Play.** La dichiarazione si aggiorna: l'app ora conserva l'email di altre persone indicata dall'utente, per la funzione di condivisione, senza venderla né condividerla con terze parti. | Voce nella checklist di rilascio (`docs/release-checklist.md` §2). |

## Accessibilità (NFR3)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR3.1 | Le schermate e i dialoghi nuovi (`SharingScreen`, `InviteForm`, `MemberTile`, dialoghi di revoca e uscita, `CellarSwitcher`, avvisi) hanno etichette per TalkBack. Il permesso e lo stato sono sempre letti come testo. | Test dei widget con `tester.getSemantics`. |
| NFR3.2 | Contrasto del testo almeno 4,5:1; aree di tocco di almeno 48×48 dp. | `textContrastGuideline`, `androidTapTargetGuideline`, `labeledTapTargetGuideline` nelle tre lingue. |
| NFR3.3 | Testo al 200% senza tagli né errori di overflow. | Test dei widget con `textScaler` 2.0 in it, en e pt-BR. |

## Affidabilità e offline (NFR6)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR6.1 | **Offline.** Una cantina condivisa si consulta e si modifica senza rete come quella personale, secondo il permesso. I comandi di gestione sono disattivati e si riattivano da soli al ritorno della rete (`NetworkStatus.onChanged`). | Test dei widget con rete finta assente e poi presente. |
| NFR6.2 | **Operazioni ripetibili.** Ogni operazione di gestione è un solo `WriteBatch` atomico. Ripeterla dopo un tempo scaduto non lascia il contatore diverso dal numero di inviti `invited` + `active`: un batch rimasto in coda e poi ripetuto viene rifiutato dalle regole, perché la transizione non è più valida. | Test delle regole: doppio invito o doppia revoca → il secondo è rifiutato e il contatore resta corretto. Test del servizio: tempo scaduto → "non riuscito, riprova". |
| NFR6.3 | **Accesso perso.** Revoca, uscita o `permission-denied` su un ascolto della cantina condivisa: si torna alla cantina personale senza crash, con un solo avviso per cantina (`CellarAccessLost`). | Test del provider e dei widget con eventi simulati. |
| NFR6.4 | **Reset.** All'uscita dall'account si chiude l'ascolto dei propri inviti e si cancella la cantina scelta salvata sul telefono (estende NFR4.10 di U1). | Test del reset con un utente che ha una cantina condivisa scelta. |
