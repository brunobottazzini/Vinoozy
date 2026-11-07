# Business Rules — u8-account

Fonti: `requirements.md` (FR1.3, FR1.4, NFR8), `stories.md` (US1.2, US1.3), `contract-summary.md` (C3, C4), risposte in `functional-design-questions.md`. Il testo completo e i flussi sono in `functional-spec.md`.

```yaml
rules:
  - id: BR1.1
    statement: Presentazione al primo avvio
    category: workflow
    applies_to: OnboardingScreen
    trigger: avvio con onboarding.seen falso
    logic: tre pagine, Salta e Inizia portano all'accesso e impostano onboarding.seen
    violation: nessuna
    source: unit-of-work U8; mockup S0
  - id: BR1.2
    statement: Profilo
    category: workflow
    applies_to: ProfileScreen
    trigger: menu, voce Profilo
    logic: nome, email, foto, Esci, Cancella account, informativa
    violation: nessuna
    source: FR1.3; FR1.4
  - id: BR1.3
    statement: Uscita senza modifiche in coda
    category: workflow
    applies_to: ProfileScreen
    trigger: Esci con registro vuoto
    logic: conferma, signOut di U1, ritorno all'accesso
    violation: Annulla -> resta nel profilo
    source: FR1.3; AC1.2.1
  - id: BR1.4
    statement: Uscita con modifiche in coda
    category: validation
    applies_to: SignOutWarningDialog
    trigger: Esci con N scritture non confermate
    logic: avviso con N, Resta e sincronizza oppure Esci comunque
    violation: nessuna
    source: AC1.2.2; Q1
  - id: BR1.5
    statement: La cancellazione richiede la rete
    category: validation
    applies_to: DeleteAccountScreen
    trigger: Cancella account
    logic: senza rete messaggio e nessuna azione
    violation: Collegati a Internet per cancellare l'account
    source: FR1.4
  - id: BR1.6
    statement: Conferma esplicita della cancellazione
    category: validation
    applies_to: DeleteAccountScreen
    trigger: schermata di cancellazione
    logic: elenco di cosa si cancella, parola di conferma della lingua, riautenticazione Google
    violation: parola errata o riautenticazione annullata -> nessuna cancellazione
    source: FR1.4; AC1.3.1
  - id: BR1.7
    statement: Ordine della cancellazione
    category: workflow
    applies_to: AccountDeletionRunner
    trigger: conferma e riautenticazione riuscite
    logic: deletionStartedAt, uscita dalle cantine altrui, revoca e cancellazione degli inviti, bevute e vini, cantina e profilo, deleteUser, azzeramento locale
    violation: errore -> fermo con Riprova
    source: FR1.4; AC1.3.2; NFR8
  - id: BR1.8
    statement: Ripresa della cancellazione
    category: workflow
    applies_to: AccountDeletionRunner
    trigger: accesso con deletionStartedAt presente, o profilo assente con account Firebase presente
    logic: riprende dal primo passo non completato prima di ogni altra schermata
    violation: nessuna
    source: FR1.4; NFR6
  - id: BR1.9
    statement: Cantine altrui
    category: constraint
    applies_to: AccountDeletionRunner
    trigger: inviti attivi o in attesa in cantine altrui
    logic: uscita e cancellazione del proprio members; bevute conservate, nome mostrato come Persona non più presente
    violation: nessuna scrittura oltre al proprio members
    source: Q3; C4
  - id: BR1.10
    statement: Permessi del cloud per la cancellazione
    category: constraint
    applies_to: firestore.rules
    trigger: delete di users e cellars
    logic: users delete e deletionStartedAt solo dall'utente; cellars delete solo dal proprietario con memberSlots 0
    violation: rifiuto delle regole
    source: FR1.4; C3
  - id: BR1.11
    statement: Pagina web per la cancellazione
    category: constraint
    applies_to: docs/account-deletion
    trigger: pubblicazione su Google Play
    logic: pagina statica su GitHub Pages in tre lingue con istruzioni ed email
    violation: email segnaposto -> la checklist blocca la pubblicazione
    source: Q2; FR1.4
  - id: BR1.12
    statement: Richieste di cancellazione via email
    category: workflow
    applies_to: docs/release-checklist.md
    trigger: email di richiesta
    logic: verifica del mittente, cancellazione dalla console degli stessi dati, risposta entro 30 giorni
    violation: nessuna
    source: NFR8; Q2
  - id: BR1.13
    statement: Contratto con il resto dell'app durante la cancellazione
    category: constraint
    applies_to: AccountDeletionRunner, AccountGate
    trigger: avvio della cancellazione e deleteUser
    logic: avviso sulle scritture in coda; al passo 0 registro azzerato, SyncWatcher e ascolti fermati; stato deletionCompleted prima di deleteUser per mostrare Account cancellato
    violation: nessuna
    source: FR1.4; AC1.3.2; NFR6
```

Correzioni dopo la revisione (2026-11-06): BR1.1, BR1.7, BR1.8, BR1.9, BR1.10 e la nuova BR1.13 sono aggiornate in `functional-spec.md`. In particolare la ripresa (BR1.8) parte solo da un segnale esplicito, locale o `deletionStartedAt`, mai dall'assenza del profilo.

Correzioni dopo la seconda revisione (2026-11-06): attesa delle scritture in coda prima di cancellare, cancellazione diretta di vini e bevute dal server, creazione del profilo con `deletionStartedAt` se manca, ordine e stati del gate, fine della cancellazione, residui dichiarati, procedura manuale completa, presentazione saltata con una sessione esistente. Testo in `functional-spec.md`, sezione "Chiarimenti dopo la seconda revisione".
