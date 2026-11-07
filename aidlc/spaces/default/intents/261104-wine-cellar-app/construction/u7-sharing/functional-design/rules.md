# Business Rules — u7-sharing

Fonti: `requirements.md` (FR8.1–FR8.4, NFR4), `stories.md` (US8.1–US8.4), `contract-summary.md` (C3, C4), risposte in `functional-design-questions.md` (Q1–Q4). I flussi sono in `functional-spec.md`.

```yaml
rules:
  - id: BR1.1
    statement: Solo il proprietario gestisce la condivisione
    category: authorization
    applies_to: SharingService, SharingScreen
    trigger: invito, cambio di permesso, revoca
    logic: consentito solo se cellars/{cellarId}.ownerId == uid; le persone invitate non vedono i comandi
    violation: errore notOwner; le regole cloud rifiutano la scrittura
    source: FR8.1, FR8.3; AC8.4.2; C4
  - id: BR1.2
    statement: Invito valido
    category: validation
    applies_to: SharingService.invite
    trigger: tocco su "Invita"
    logic: email valida; diversa da quella del proprietario; nessun invito invited o active con la stessa chiave; inviti invited + active <= 2 (memberSlots; limite portato da 5 a 2 il 2026-11-06); permission read o edit; un invito revoked si riattiva e conta di nuovo
    violation: invalidEmail, selfInvite, alreadyInvited, limitReached
    source: FR8.1, FR8.2; AC8.1.1, AC8.1.2, AC8.1.3; C4
  - id: BR1.3
    statement: Avviso alla persona tramite la condivisione di Android
    category: policy
    applies_to: SharingScreen
    trigger: invito riuscito
    logic: messaggio pronto nella lingua dell'app con chi invita, nome della cantina, link a Google Play e indirizzo Google da usare; chiudere la condivisione non annulla l'invito
    violation: nessuna
    source: Q1
  - id: BR1.4
    statement: Accesso senza accettazione
    category: policy
    applies_to: SharingService.activate
    trigger: accesso e ritorno della rete
    logic: inviti con inviteeEmail uguale all'email dell'account e status invited o active; invited diventa active con inviteeUserId e inviteeName; avviso una volta per cantina nuova
    violation: nessun invito -> nessuna cantina condivisa
    source: Q2; FR8.1
  - id: BR1.5
    statement: Scelta tra più cantine
    category: policy
    applies_to: CellarSwitcher, activeCellarProvider
    trigger: più di una cantina accessibile
    logic: cantina personale più quelle con invito active; si parte dalla personale; l'ultima scelta resta sul telefono; se non è più accessibile si torna alla personale
    violation: nessuna
    source: unit-of-work.md U7; C4 listAccessibleCellars
  - id: BR1.6
    statement: Permessi nell'interfaccia
    category: authorization
    applies_to: CellarScreen, DashboardScreen, schermate di U4
    trigger: cantina attiva condivisa
    logic: read vede tutto senza comandi di aggiunta, modifica, eliminazione e bevuta; edit aggiunge, modifica, cambia quantità e segna bevute; nessuna persona invitata elimina vini, rinomina la cantina, invita o revoca
    violation: comando nascosto
    source: FR8.2, FR8.4; AC8.3.1, AC8.4.1, AC8.4.2; Q3
  - id: BR1.7
    statement: Le regole cloud fanno rispettare i permessi
    category: authorization
    applies_to: firestore.rules
    trigger: ogni lettura e scrittura in cellars/{cellarId}
    logic: lettura per proprietario e per members active; scrittura su wines e drinkingRecords solo per proprietario e members active con edit, senza eliminazione per i members; members gestiti solo dal proprietario, salvo attivazione e uscita della persona stessa
    violation: scrittura rifiutata; in coda offline segue il percorso degli errori di sincronizzazione di U1
    source: FR8.4; NFR4; AC8.3.2; C3
  - id: BR1.8
    statement: Revoca con conferma
    category: policy
    applies_to: SharingService.revoke
    trigger: "Revoca" e conferma con il nome o l'email
    logic: status revoked, closedBy owner, memberSlots - 1; la persona perde l'accesso alla sincronizzazione successiva, torna alla cantina personale e vede "Non hai più accesso alla cantina di Mario"
    violation: conferma diversa dal nome -> pulsante disattivato
    source: FR8.3; AC8.2.1
  - id: BR1.9
    statement: Cambio di permesso
    category: policy
    applies_to: SharingService.changePermission
    trigger: scelta del proprietario
    logic: permission read <-> edit; vale dalla sincronizzazione successiva; l'interfaccia della persona si aggiorna da sola
    violation: notOwner, notFound
    source: FR8.2; C4
  - id: BR1.10
    statement: Uscita della persona invitata
    category: policy
    applies_to: SharingService.leave
    trigger: "Esci da questa cantina" e conferma
    logic: status revoked, closedBy invitee, memberSlots - 1; il proprietario la vede come "uscita" e può reinvitarla
    violation: nessuna
    source: Q4
  - id: BR1.11
    statement: La gestione richiede la rete
    category: policy
    applies_to: SharingScreen
    trigger: invito, cambio di permesso, revoca, uscita
    logic: si parte solo con networkStatusProvider online; un solo WriteBatch; si attende commit(), che con la persistenza offline si chiude solo dopo l'accettazione del server; tempo massimo 10 s, poi "non riuscito, riprova"; ripetere dà lo stesso stato finale (BR1.13); senza rete i comandi sono disattivati con la spiegazione; consultazione e modifiche ai vini restano offline come in U1
    violation: "Serve la connessione per gestire la condivisione"
    source: riepilogo confermato; NFR6 (U1)
  - id: BR1.12
    statement: Elenco delle persone
    category: policy
    applies_to: SharingScreen
    trigger: apertura di "Persone"
    logic: l'elenco principale del proprietario mostra le persone invitate e attive con nome o email e permesso; revocate e uscite spariscono dall'elenco principale e vanno nella sezione chiusa "Accessi chiusi", da cui si reinvitano o si eliminano definitivamente; le persone invitate vedono solo il proprietario e il proprio permesso
    violation: nessuna
    source: FR8.1–FR8.3; AC8.1.1, AC8.2.1
  - id: BR1.13
    statement: Transizioni consentite del documento members
    category: authorization
    applies_to: firestore.rules (members, cellars.memberSlots)
    trigger: ogni scrittura su members o su memberSlots
    logic: solo le transizioni della tabella di functional-spec.md (creazione invited, attivazione da parte della persona, cambio di permesso, revoca, uscita, reinvito, eliminazione di un accesso chiuso); members e memberSlots cambiano nello stesso batch, con getAfter sul contatore; memberSlots mancante vale 0
    violation: scrittura rifiutata; la persona invitata non cambia mai permission e non esce da revoked
    source: C3; FR8.2, FR8.3; NFR4
  - id: BR1.14
    statement: Ricezione di revoca e cambio di permesso
    category: policy
    applies_to: SharingService, activeCellarProvider
    trigger: cambio dei propri documenti members o permission-denied su un ascolto
    logic: ascolto della query dei propri inviti; permission aggiorna canEdit subito; revoked chiude gli ascolti, toglie la cantina dal selettore, torna alla personale e mostra il messaggio; le scritture in coda rifiutate vanno in SyncErrorBus, con un solo avviso per cantina oltre al percorso di U1 per i vini creati
    violation: nessuna
    source: FR8.3; AC8.2.1
```

## Riepilogo

| ID | Regola | Categoria |
|---|---|---|
| BR1.1 | Solo il proprietario gestisce la condivisione | authorization |
| BR1.2 | Invito valido | validation |
| BR1.3 | Avviso tramite la condivisione di Android | policy |
| BR1.4 | Accesso senza accettazione | policy |
| BR1.5 | Scelta tra più cantine | policy |
| BR1.6 | Permessi nell'interfaccia | authorization |
| BR1.7 | Le regole cloud fanno rispettare i permessi | authorization |
| BR1.8 | Revoca con conferma | policy |
| BR1.9 | Cambio di permesso | policy |
| BR1.10 | Uscita della persona invitata | policy |
| BR1.11 | La gestione richiede la rete | policy |
| BR1.12 | Elenco delle persone | policy |
| BR1.13 | Transizioni consentite del documento members | authorization |
| BR1.14 | Ricezione di revoca e cambio di permesso | policy |
