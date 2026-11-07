# Security Design — u7-sharing

Fonti:
- `security-requirements.md` (NFR4.1–NFR4.9, NFR8.1–NFR8.4, NFR3.1–NFR3.3, NFR6.1–NFR6.4) e `tech-stack-decisions.md`;
- `functional-spec.md` ("Meccanismi senza funzioni nel cloud", "Integrazione con U1") e `logical-components.md`;
- `firestore.rules` di U1 e riepilogo confermato in `nfr-design-questions.md`.

Come nei requisiti, il file raccoglie anche accessibilità e affidabilità. È stato rivisto il 2026-11-06 dopo la prima revisione, che ha riguardato il contatore, l'integrazione con U1, l'accesso perso e la CI.

## 1. Regole cloud (NFR4.1–NFR4.9)

### Funzioni comuni (aggiunte alla sezione comune di U1)

```text
function email()        { return request.auth.token.email.lower(); }
function verified()     { return request.auth.token.email_verified == true; }
function memberPath(c)  { return /databases/$(database)/documents/cellars/$(c)/members/$(email()); }
function isOwner(c)     { return cellarOwner(c) == uid(); }               // funzione di U1
function isActiveMember(c) {
  return verified() && exists(memberPath(c))
      && get(memberPath(c)).data.status == 'active';
}
function canReadCellar(c) { return isOwner(c) || isActiveMember(c); }
function canEditCellar(c) {
  return isOwner(c) || (isActiveMember(c) && get(memberPath(c)).data.permission == 'edit');
}
```

`exists` e `get` sullo stesso percorso contano come un solo accesso, perché la valutazione memorizza i documenti letti in una richiesta. `cellarOwner(c)` è la `get` della cantina di U1, anch'essa memorizzata.

### Legame tra contatore e invito (correzione del Major 1)

Il documento della cantina ha un secondo campo facoltativo, **`memberOpKey`** (stringa), che dice quale invito cambia nello stesso batch.
- Ogni batch di gestione che tocca il contatore scrive la cantina con `memberSlots` ±1 **e** `memberOpKey = <chiave dell'invito>`, più il documento `members` con quella chiave.
- In un batch un documento si scrive una sola volta. C'è quindi un solo aggiornamento della cantina, quindi un solo `memberOpKey`, quindi un solo invito che può superare la regola.

**Regola sulla cantina (`update`)**, oltre al cambio di `name` di U1:

```text
function slotsBefore() { return resource.data.get('memberSlots', 0); }
function opMember()    { return /databases/$(database)/documents/cellars/$(cellarId)/members/$(request.resource.data.memberOpKey); }
function slotDelta(d)  { return request.resource.data.memberSlots == slotsBefore() + d; }
function opAdds() {   // invito nuovo o reinvito
  return getAfter(opMember()).data.status == 'invited'
      && (!exists(opMember()) || get(opMember()).data.status == 'revoked');
}
function opRemoves() { // revoca o uscita
  return exists(opMember())
      && get(opMember()).data.status in ['invited', 'active']
      && getAfter(opMember()).data.status == 'revoked';
}
allow update: if signedIn()
  && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['memberSlots', 'memberOpKey'])
  && request.resource.data.memberSlots is int
  && request.resource.data.memberSlots >= 0 && request.resource.data.memberSlots <= 2
  && ( (resource.data.ownerId == uid() && ((slotDelta(1) && opAdds()) || (slotDelta(-1) && opRemoves())))
    || (verified() && request.resource.data.memberOpKey == email()
        && slotDelta(-1) && opRemoves()
        && getAfter(opMember()).data.closedBy == 'invitee') );
```

**Regole su `members`:** dentro il `match` di `members` ci sono funzioni proprie, perché `slotsBefore()` della cantina non è visibile lì:

```text
function cellarDoc()      { return /databases/$(database)/documents/cellars/$(cellarId); }
function memberSlotsNow() { return get(cellarDoc()).data.get('memberSlots', 0); }
function pairedOp(d) {
  return getAfter(cellarDoc()).data.get('memberOpKey', '') == memberKey
      && getAfter(cellarDoc()).data.get('memberSlots', 0) == memberSlotsNow() + d;
}
```

`validInviteNew()` e `validReinvite()` includono `pairedOp(1)`; `validOwnerRevoke()` e `validLeave()` includono `pairedOp(-1)`. Due inviti nello stesso batch non possono quindi superarle entrambi, perché `memberOpKey` è uno solo. Il terzo invito fallisce perché il contatore supererebbe 2 (limite portato da 5 a 2 il 2026-11-06, FR8.1).

### Blocco `members` (righe esplicite)

```text
match /cellars/{cellarId}/members/{memberKey} {
  allow get:    if signedIn() && (isOwner(cellarId) || (verified() && memberKey == email()));
  allow list:   if signedIn() && isOwner(cellarId);
  allow create: if signedIn() && isOwner(cellarId) && validInviteNew();          // → invited, conta +1
  allow update: if signedIn() && (
      (isOwner(cellarId) && (validReinvite() || validPermissionChange() || validOwnerRevoke()))
   || (verified() && memberKey == email() && (validActivate() || validLeave())) );
  allow delete: if signedIn() && resource.data.status == 'revoked'
                && (isOwner(cellarId) || (verified() && memberKey == email()));
}
```

Ogni `validX()` usa `affectedKeys().hasOnly([...])` con i campi della tabella delle transizioni. Le validazioni comuni dei campi (NFR4.9) sono:
- `memberKey == inviteeEmail` e `inviteeEmail == inviteeEmail.lower()`;
- lunghezza al più 254 e `matches('^[^@/\\s]+@[^@/\\s]+\\.[^@/\\s]+$')`;
- `ownerName` e `inviteeName` stringhe di 1–100 caratteri;
- `permission in ['read','edit']`, `closedBy in ['owner','invitee']`, `updatedAt == request.time`.

**Nomi di ripiego:** se l'account Google non ha un nome, l'app usa la parte dell'email prima della `@`, troncata a 100 caratteri. L'attivazione non fallisce mai per un nome vuoto. Un test unitario di `displayNameOrFallback` prova nome presente, nome vuoto, solo spazi e un nome di 150 caratteri; un test delle regole prova l'attivazione con il nome di ripiego.

**Gruppo di collezioni:** `match /{path=**}/members/{memberKey} { allow get, list: if signedIn() && verified() && resource.data.inviteeEmail == email(); }`. La query dell'app filtra solo su `inviteeEmail`, quindi le regole possono provare che il risultato contiene solo i documenti di quella persona.

### Cantina letta dalla persona invitata

```text
// in match /cellars/{cellarId}, accanto alle righe di U1:
allow get:  if signedIn() && (cellarId == uid() || resource.data.ownerId == uid() || isActiveMember(cellarId));
allow list: if signedIn() && resource.data.ownerId == uid();   // invariata: le cantine condivise si trovano dagli inviti
```

### Vini e bevute

- **`wines`:**
  - lettura con `canReadCellar`;
  - creazione e aggiornamento con `canEditCellar`, con la validazione dei campi di U1 invariata e `updatedBy == uid()`;
  - **eliminazione: U7 la apre solo per `isOwner(cellarId)`** (oggi è `if false` in U1). Così la matrice di NFR4.1 ha un caso consentito, il proprietario, e cinque vietati, comprese le persone con `edit` (Q3). U4 userà questa regola per il comando "Elimina". Decisione della seconda revisione, 2026-11-06.
- **`drinkingRecords`** (NFR4.8):
  - lettura con `canReadCellar`;
  - creazione con `canEditCellar && validDrinkingRecord()`;
  - eliminazione solo con `isOwner`;
  - nessun update.

  `validDrinkingRecord()` richiede:
  - solo le chiavi `wineId`, `wineName`, `vintage`, `drankOn`, `rating`, `notes`, `recordedBy`, `createdAt`;
  - `wineId` stringa di 1–128 caratteri e `wineName` stringa di 1–120;
  - `vintage` assente o intero da 1900 a 2100;
  - `drankOn` stringa che soddisfa `matches('^[0-9]{4}-[0-9]{2}-[0-9]{2}$')`;
  - `rating` assente o intero da 1 a 5;
  - `notes` assente o stringa di al più 1.000 caratteri;
  - `recordedBy == uid()` e `createdAt == request.time`.

### Tabella degli accessi (commento in testa al file, NFR5.2)

| Percorso e operazione | Accessi distinti (`get`/`exists`/`getAfter`) |
|---|---|
| `wines`, `drinkingRecords`: lettura e scrittura del proprietario | 1 (cantina) |
| `wines`, `drinkingRecords`: lettura e scrittura della persona invitata | 2 (cantina, `members`) |
| `cellars/{id}`: `get` della persona invitata | 1 (`members`) |
| `cellars/{id}`: update del contatore | 2 (`members` prima e dopo) |
| `members`: create, update e delete | 2 (cantina prima e dopo; la `get` per il proprietario è la stessa) |
| gruppo di collezioni `members`: lettura | 0 |

In un batch di gestione (cantina più `members`) la somma è 4, molto sotto il limite di 20 per batch. Il massimo per singolo percorso è 2, sotto i 3 di NFR5.2.

### Test delle regole e collegamento alla CI (correzione del Major 4)

- **`test/rules/u7.rules.test.mjs`:**
  - matrice 6 ruoli × 9 operazioni generata da una tabella;
  - ogni transizione consentita;
  - le transizioni vietate: autopromozione, rientro da `revoked`, attivazione con un'altra email, `ownerId` cambiato;
  - il contatore: +2, contatore senza `members`, **due inviti nello stesso batch con un solo +1**, terzo invito, `memberOpKey` di un altro invito;
  - i valori al limite dei campi;
  - `unverifiedGoogleUser()`.
- **`test/rules/helpers.mjs`:** `googleUser()` con `email_verified: true` e il nuovo `unverifiedGoogleUser()`.
- **`package.json`:** lo script `test:rules` aggiunge `u7.rules.test.mjs`.
- **`firestore.indexes.json`:** oggi ha `fieldOverrides: []`; si aggiunge l'override di `members.inviteeEmail` (`COLLECTION_GROUP`, ordine crescente).
- **Test del controllo dell'indice:** `tool/check_firestore_indexes_test.sh` con due file di prova in `tool/fixtures/firestore_indexes/`: `ok.json` deve passare e `missing.json` deve fallire. Gira nel job `rules`.
- **`.github/workflows/ci.yml`, job `rules`:**
  - il comando che oggi elenca a mano `u1.rules.test.mjs compat/` diventa `npm run test:rules`, che è l'unica lista dei file;
  - un nuovo passo `tool/check_firestore_indexes.sh` controlla con `jq` il `fieldOverride` su `members.inviteeEmail` con `queryScope: COLLECTION_GROUP`.
- **Non regressione:** `u1.rules.test.mjs` e `compat/` restano verdi.

## 2. Privacy (NFR8.1–NFR8.4)

- **Dati salvati:** solo i campi di C3 e le aggiunte compatibili. Un test legge `android/app/src/main/AndroidManifest.xml` e verifica che non ci sia `READ_CONTACTS`.
- **Errori:** ogni errore del repository passa da `errorReporterProvider` con un `reason` fisso (`sharing_invite_failed`, `sharing_revoke_failed`, ecc.) e con l'email tra i valori sensibili. Il messaggio mostrato è un testo fisso tradotto.
- **Cancellazione:** `deleteClosed` del proprietario e l'eliminazione del proprio documento `revoked` da parte della persona invitata.
- **Data Safety:** voce nella checklist di rilascio, nel design dell'infrastruttura.

## 3. Accessibilità (NFR3.1–NFR3.3)

- **`CellarSwitcher`:** `Semantics` "Cantina di Mario, può modificare. Tocca per cambiare cantina".
- **`MemberTile`:** `MergeSemantics`, letto come "nome, permesso, stato".
- **Dialogo di revoca:** il campo di conferma ha `labelText`; il pulsante disattivato spiega il motivo con `hint`.
- **Verifiche:** contrasto, aree di tocco e testo al 200% con le stesse guideline dei test del Cruscotto, nelle tre lingue.

## 4. Affidabilità e integrazione con U1 (NFR6.1–NFR6.4)

### Modifiche a U1 (correzione del Major 2)

| File di U1 | Modifica |
|---|---|
| `firestore.rules` | Funzioni comuni, `get` della cantina per la persona invitata, update del contatore, `wines` con `canReadCellar`/`canEditCellar` ed eliminazione del proprietario, blocchi `members`, gruppo di collezioni e `drinkingRecords` (§1). Le righe del proprietario di U1 restano equivalenti. |
| `firestore.indexes.json` | Override di `members.inviteeEmail` (§1). |
| `lib/cellar/domain/cellar.dart` | `Cellar` aggiunge `memberSlots` (int, 0 se manca) e `memberOpKey?`, letti senza mai lanciare. |
| `lib/cellar/data/cellar_repository.dart` | `watchCellar(cellarId)` al posto di `watchCellar(uid)`. La cantina personale passa `Cellar.personalCellarId(uid)`, che oggi è l'uid stesso. |
| `lib/app/providers.dart` | `cellarStreamProvider` e `syncStatusProvider` diventano indicizzati per **`cellarId`**. `reopenCellarListeners` e `invalidateFirestoreListeners` invalidano anche `myMembershipsProvider`, `accessibleCellarsProvider`, `activeCellarProvider` e `cellarMembersProvider`. |
| `lib/sync/ui/offline_banner.dart` | Riceve `cellarId`. |
| `lib/cellar/data/wine_repository.dart` | Ogni metodo di scrittura conosce già il `cellarId` del percorso; `_onWriteError` lo riceve come argomento e chiama `reportWriteRejected(cellarId, …)` (sotto). |
| `lib/sync/sync_error_bus.dart` | Nuovo evento `CellarAccessLost(cellarId)` e funzione `reportWriteRejected(bus, cellarId, uid, error, {wineId, wineName})`. La funzione pubblica `WriteRejected` come oggi e, se `cellarId != Cellar.personalCellarId(uid)` e l'errore è `permission-denied`, anche `CellarAccessLost`. U4 userà la stessa funzione per le bevute. |
| `lib/account/network_status.dart` | `NetworkStatus` aggiunge `Stream<bool> get onChanged`. `ConnectivityNetworkStatus` lo implementa con `connectivity_plus`. I finti dei test (`FakeNetwork` in `test/u1/ui/sign_in_screen_test.dart` e simili) si aggiornano con uno stream. |
| `lib/account/account_gate.dart` | `retryCellar` riapre anche gli ascolti della condivisione. Il reset cancella `sharing.activeCellar.<uid>`. |
| `lib/cellar/ui/*`, `lib/dashboard/*` (U5), `lib/app/home_shell.dart` | Usano `activeCellarProvider`. Il nome della cantina attiva viene da `accessibleCellarsProvider`. |

### Accesso perso (correzione del Major 3)

Le sorgenti sono tre e convergono su `CellarAccessLost(cellarId)`. Nessuna riguarda mai la cantina personale.
1. **Cambio dell'invito:** `myMembershipsProvider` confronta lo stato precedente con quello nuovo. Se un invito passa a `revoked` **con `closedBy == 'owner'`**, oppure il documento sparisce, pubblica l'evento. Con `closedBy == 'invitee'` (uscita volontaria) non pubblica nulla, e `activeCellarProvider` torna alla personale senza avviso.
2. **Ascolti della cantina attiva:** `activeCellarProvider` ascolta lo stato di `winesStreamProvider(activeId)` e `cellarStreamProvider(activeId)`. Se uno dei due è un `AsyncError` con `FirebaseException.code == 'permission-denied'` e `activeId` non è la cantina personale, pubblica l'evento con `activeId`. **Eccezione:** `leave(cellarId)` imposta prima del batch un insieme `leavingCellarIds`, svuotato quando la cantina è tolta dall'elenco. Un rifiuto su una cantina in quell'insieme non produce l'avviso, così l'uscita volontaria non mostra mai "Non hai più accesso". L'eccezione non porta il percorso, ma non serve: il `cellarId` è quello dell'ascolto.
3. **Scritture in coda rifiutate:** `reportWriteRejected` con il `cellarId` del percorso scritto.

Alla radice dell'app, un ascoltatore tiene per sessione l'insieme dei `cellarId` già avvisati. Mostra "Non hai più accesso alla cantina di Mario" una sola volta, con il nome preso dall'ultimo `AccessibleCellar` noto, e `activeCellarProvider` torna alla cantina personale.

### Operazioni, rete ed errori

- **Rete:** i comandi di gestione osservano `onChanged`. Prima di ogni operazione si controlla anche `hasNetwork()`.
- **Batch e tempo massimo:** `batch.commit().timeout(const Duration(seconds: 10))`. Se il tempo scade, l'esito è `SharingError.timeout`. Il batch eventualmente rimasto in coda o viene accettato, ed è la stessa operazione, o viene rifiutato perché la transizione non è più valida. In entrambi i casi il contatore resta coerente (NFR6.2).
- **Controlli prima della scrittura** (dalla cache, con `Source.serverAndCache` sui documenti già ascoltati):
  - `alreadyInvited` se esiste un `members` con quella chiave e stato `invited` o `active`;
  - `limitReached` se `Cellar.memberSlots >= 2`.
- **Traduzione degli errori del cloud dopo la scrittura:**

| Errore di Firestore | Errore di C4 | Messaggio |
|---|---|---|
| `permission-denied` e una nuova lettura della cantina dà `memberSlots >= 2` | `limitReached` | "Hai raggiunto il limite di 2 persone" |
| `permission-denied` e una nuova lettura del `members` dà `invited` o `active` | `alreadyInvited` | "Questa persona è già invitata" |
| `permission-denied`, altri casi | `notOwner` | "Non puoi modificare la condivisione di questa cantina" |
| `not-found` | `notFound` | "Questa persona non è più nell'elenco" |
| `unavailable`, `deadline-exceeded`, tempo scaduto | `timeout` / `failed` | "Non riuscito, riprova" |

- **Reset:** come in "Modifiche a U1"; il test del reset usa un utente con una cantina condivisa scelta.

## 5. Proprietario nel test end-to-end

`ownerRestClient()` in `integration_test/e2e_helpers.dart`:
1. chiama l'emulatore di Auth con `POST /identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=fake-api-key`:
   - `postBody` contiene `id_token=<JWT non firmato con sub, email, email_verified: true>` e `providerId=google.com`;
   - `requestUri` è `http://localhost`;
   - `returnSecureToken` è `true`;
2. dalla risposta prende **`idToken`** e **`localId`**, cioè l'uid assegnato a caso dall'emulatore, che si usa come `ownerId` e come id della cantina personale;
3. scrive su Firestore con `Authorization: Bearer <idToken>` tramite `documents:commit`, così ogni batch passa dalle regole vere:
   - `invitedAt` e `updatedAt` usano `updateTransforms` con `setToServerValue: REQUEST_TIME`, così valgono `request.time` nelle regole;
   - lo stesso commit contiene la cantina (`memberSlots`, `memberOpKey`) e il `members`, come fa l'app.

## 6. Non regressione (NFR7.5)

- Senza condivisioni, la cantina attiva è quella personale e il suo id è l'uid, quindi le schermate di U1 e U5 si comportano come oggi.
- I test esistenti si aggiornano solo dove cambia la firma: `cellarId` al posto di `uid` e `onChanged` nei finti della rete.
- Il nuovo `integration_test/sharing_test.dart` copre il percorso con due utenti.
