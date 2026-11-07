# Business Rules — u1-skeleton

Fonti: `unit-of-work.md` (U1), `unit-of-work-story-map.md`, `stories.md` (US1.1, US2.1, US9.1, US9.2, US10.1), `requirements.md`, `components.md` (Account, Cellar, Sync), `contract-summary.md` (C3), risposte in `functional-design-questions.md`.

```yaml
rules:
  - id: BR1.1
    statement: Il primo accesso richiede un account Google e la rete
    category: authorization
    applies_to: Account
    trigger: avvio dell'app senza sessione
    logic: IF nessuna sessione valida THEN mostra Accesso; IF accesso riuscito THEN crea o carica il profilo e apre la Cantina
    violation: accesso annullato o fallito -> messaggio "Accesso non riuscito" con "Riprova", nessun dato creato; senza rete -> "Serve la connessione per il primo accesso"
    source: FR1.1
  - id: BR1.2
    statement: La sessione resta attiva tra un avvio e l'altro anche senza rete
    category: policy
    applies_to: Account
    trigger: avvio dell'app con sessione esistente
    logic: IF sessione salvata sul telefono THEN apre direttamente l'app, con o senza rete
    violation: sessione revocata dal cloud -> al ritorno della rete torna ad Accesso
    source: FR1.2
  - id: BR1.3
    statement: Al primo accesso viene creata automaticamente una cantina personale
    category: policy
    applies_to: Cellar
    trigger: primo accesso riuscito senza cantine esistenti
    logic: la cantina personale ha ID fisso cellars/{uid} (ricavato dall'utente, non generato a caso); al primo accesso si legge cellars/{uid} dal cloud; IF non esiste THEN la si crea con ownerId = uid e nome "La mia cantina" (tradotto); su piu' telefoni o dopo una reinstallazione si ottiene sempre la stessa cantina, quindi non nascono doppioni. In U1 la Cantina mostra sempre cellars/{uid}
    violation: lettura o creazione fallita, oppure errore dell'ascolto della cantina o dei vini -> la Cantina mostra "Impossibile preparare la cantina" con "Riprova"; "Riprova" rifa' la verifica e riapre entrambi gli ascolti; nessun vino si puo' aggiungere finche' la cantina non esiste
    source: FR2.1
  - id: BR1.4
    statement: Le modifiche non ancora inviate appartengono all'utente che le ha fatte; un altro account non puo' accedere sullo stesso telefono finche' restano in coda
    category: policy
    applies_to: Account, Sync
    trigger: accesso con un account Google sullo stesso telefono
    logic: l'app ricorda sul telefono l'uid dell'ultimo utente (lastUid); IF uid nuovo = lastUid THEN le modifiche in coda ripartono; IF uid diverso AND modifiche in attesa > 0 THEN accesso bloccato con "Ci sono modifiche di <email> non ancora salvate nel cloud: accedi con quell'account e collegati alla rete"; IF uid diverso AND 0 in attesa THEN si cancella la memoria offline e si entra
    violation: accesso con uid diverso bloccato, nessuna modifica persa
    source: FR9.1, NFR4, NFR6
  - id: BR2.1
    statement: Il nome del vino e' obbligatorio, da 1 a 120 caratteri dopo aver tolto gli spazi esterni
    category: validation
    applies_to: Wine.name
    trigger: uscita dal campo e tocco su Salva
    logic: IF nome vuoto o solo spazi o oltre 120 caratteri THEN errore sotto il campo
    violation: "Scrivi il nome del vino" / "Massimo 120 caratteri"; quanto scritto resta
    source: FR2.6
  - id: BR2.2
    statement: L'annata e' un anno tra 1900 e l'anno corrente, oppure "senza annata"
    category: validation
    applies_to: Wine.vintage
    trigger: uscita dal campo e tocco su Salva
    logic: IF annata presente e fuori da 1900..anno corrente THEN errore
    violation: "Annata tra 1900 e <anno corrente>"; quanto scritto resta
    source: FR2.6
  - id: BR2.3
    statement: La quantita' e' un intero tra 1 e 99, predefinita 1
    category: validation
    applies_to: Wine.quantity
    trigger: inserimento
    logic: i pulsanti - e + non scendono sotto 1 ne' salgono oltre 99
    violation: non applicabile (limiti imposti dai controlli)
    source: FR2.4
  - id: BR2.4
    statement: Salvare crea un vino nella cantina dell'utente e lo mostra subito nell'elenco
    category: constraint
    applies_to: Wine
    trigger: Salva con dati validi
    logic: l'ID del vino e' generato sul telefono una sola volta all'apertura del modulo; al primo tocco su Salva il pulsante si disattiva fino alla chiusura del modulo, quindi un doppio tocco non crea due vini; il vino e' scritto con i campi elencati in functional-spec.md > Campi scritti in U1; l'elenco lo mostra subito anche offline
    violation: errore di scrittura locale -> messaggio "Impossibile salvare, riprova", nessun dato perso di quelli gia' salvati
    source: FR2.1
  - id: BR2.5
    statement: In U1 si gestiscono solo bottiglie da 0,75 L, senza campo formato
    category: constraint
    applies_to: Wine
    trigger: inserimento
    logic: nessun campo formato; tutte le bottiglie sono 0,75 L
    violation: non applicabile
    source: FR2.7
  - id: BR3.1
    statement: Ogni modifica si salva prima sul telefono e si invia al cloud quando c'e' rete
    category: policy
    applies_to: Sync
    trigger: qualsiasi scrittura
    logic: scrittura nella memoria offline di Firestore; invio automatico al ritorno della rete
    violation: invio rifiutato dal cloud (permessi) -> il Future della scrittura termina con errore permission-denied, Firestore annulla la modifica sul telefono e l'utente vede "Modifica non consentita"
    source: FR9.1, FR9.2
  - id: BR3.2
    statement: L'indicatore offline compare quando ci sono modifiche non ancora inviate
    category: policy
    applies_to: Sync
    trigger: cambio dello stato di invio
    logic: lo stato globale si legge dagli snapshot della cantina e dei vini con includeMetadataChanges (hasPendingWrites su uno o piu' documenti = modifiche in attesa) insieme allo stato della rete del telefono; IF in attesa AND senza rete THEN "Offline - sincronizzazione in attesa"; IF in attesa AND con rete THEN "Sincronizzazione in corso"; IF nessuna in attesa THEN nascondi
    violation: non applicabile
    source: FR9.3
  - id: BR3.3
    statement: Le modifiche in attesa sopravvivono alla chiusura dell'app
    category: constraint
    applies_to: Sync
    trigger: chiusura o riavvio dell'app
    logic: memoria offline persistente attiva; alla riapertura le modifiche sono presenti e ripartono
    violation: non applicabile
    source: NFR6, FR9.1
  - id: BR3.4
    statement: Le variazioni di quantita' si inviano come incrementi, cosi' modifiche contemporanee si sommano
    category: calculation
    applies_to: Wine.quantity
    trigger: modifica della quantita' dopo la creazione
    logic: scrittura con incremento relativo (+n / -n) invece del valore assoluto. In U1 nessuna schermata modifica la quantita' dopo la creazione; la regola vale come vincolo del livello dati (metodo del repository) e si verifica con un test nell'emulatore; i comandi arrivano con u4-cellar e la prova con due persone con u7-sharing
    violation: risultato sotto 0 mostrato come 0 (ADR-004)
    source: FR9.4
  - id: BR4.1
    statement: Ogni utente legge e scrive solo le cantine di cui e' proprietario
    category: authorization
    applies_to: Cellar, Wine
    trigger: ogni lettura o scrittura nel cloud
    logic: le regole di sicurezza consentono l'accesso solo se ownerId = utente corrente
    violation: richiesta rifiutata dal cloud
    source: NFR4
  - id: BR5.1
    statement: La lingua dell'interfaccia segue il telefono (italiano, inglese, portoghese brasiliano), con inglese come riserva
    category: policy
    applies_to: interfaccia
    trigger: avvio e cambio lingua del telefono
    logic: IF lingua del telefono in [it, en, pt-BR] THEN usala ELSE inglese
    violation: non applicabile
    source: FR10.1
  - id: BR5.2
    statement: Il tema chiaro o scuro segue il telefono
    category: policy
    applies_to: interfaccia
    trigger: avvio e cambio tema
    logic: tema del sistema
    violation: non applicabile
    source: FR10.2
  - id: BR5.3
    statement: L'interfaccia rispetta WCAG AA (contrasto, testo al 200%, aree toccabili 48x48 dp, etichette per TalkBack)
    category: constraint
    applies_to: interfaccia
    trigger: ogni schermata
    logic: nessun testo tagliato al 200%; ogni controllo ha un'etichetta
    violation: test dei widget falliscono
    source: NFR3
```

## Riepilogo

| ID | Regola | Fonte |
|----|--------|-------|
| BR1.1 | Primo accesso con Google e rete | FR1.1 |
| BR1.2 | Sessione mantenuta offline | FR1.2 |
| BR1.3 | Cantina personale con ID fisso cellars/{uid} | FR2.1 |
| BR1.4 | Modifiche in coda legate all'utente | FR9.1, NFR4, NFR6 |
| BR2.1 | Nome obbligatorio, 1–120 caratteri | FR2.6 |
| BR2.2 | Annata 1900–anno corrente o senza annata | FR2.6 |
| BR2.3 | Quantità 1–99, predefinita 1 | FR2.4 |
| BR2.4 | Salva crea il vino (ID dal telefono, niente doppio tocco) e lo mostra subito | FR2.1 |
| BR2.5 | Solo 0,75 L | FR2.7 |
| BR3.1 | Prima sul telefono, poi nel cloud | FR9.1, FR9.2 |
| BR3.2 | Indicatore offline | FR9.3 |
| BR3.3 | Modifiche in attesa sopravvivono al riavvio | NFR6 |
| BR3.4 | Quantità come incrementi | FR9.4 |
| BR4.1 | Solo il proprietario accede alla sua cantina | NFR4 |
| BR5.1 | Lingua del telefono, riserva inglese | FR10.1 |
| BR5.2 | Tema del telefono | FR10.2 |
| BR5.3 | Accessibilità WCAG AA | NFR3 |
