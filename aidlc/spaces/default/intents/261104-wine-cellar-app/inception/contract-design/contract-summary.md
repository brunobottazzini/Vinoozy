# Contract Summary — Vinoozy

Fonti: `unit-of-work.md` e `unit-of-work-dependency.md` (Units Generation), `components.md` (Domain Design), `requirements.md`, risposte in `contract-design-questions.md` (Q1: funzioni callable Firebase; Q2: versione `v1`, solo aggiunte compatibili).

## Contracts

| # | Provider Unit | Consumer | Mechanism | Owner |
|---|---------------|----------|-----------|-------|
| C1 | u3-wine-catalog | u4-cellar, u6-label-recognition | Firebase callable functions (HTTPS) | u3-wine-catalog |
| C2 | u2-estimation | u4-cellar, u5-dashboard | Libreria Dart (API pubblica del pacchetto) | u2-estimation |
| C3 | u1-skeleton | u4-cellar, u5-dashboard, u6-label-recognition, u7-sharing, u8-account | Modello dati Firestore condiviso + regole di sicurezza | u1-skeleton (dati), u7-sharing (regole dei permessi) |
| C4 | u7-sharing | u8-account, u4-cellar | Interfaccia Dart (servizio di condivisione) | u7-sharing |
| C5 | Base dati vini esterna (da scegliere) | u3-wine-catalog | HTTPS del fornitore, dietro un adattatore | u3-wine-catalog (adattatore) |

## C1 — WineCatalog callable functions (v1)

Chiamate solo da utenti autenticati (Firebase controlla il token); limite di 60 richieste al minuto per utente; timeout lato app 8 secondi; nessun dato personale inoltrato al fornitore esterno.

```yaml
openapi: 3.0.3
info:
  title: WineCatalog callable functions
  version: v1
paths:
  /v1-suggestWines:
    post:
      summary: Suggerimenti di vini mentre l'utente scrive (FR2.1)
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [query]
              properties:
                query: { type: string, minLength: 2, maxLength: 120 }
                locale: { type: string, enum: [it, en, pt-BR] }
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object
                properties:
                  suggestions:
                    type: array
                    maxItems: 10
                    items: { $ref: '#/components/schemas/WineCandidate' }
  /v1-matchLabelText:
    post:
      summary: Vino corrispondente al testo letto sull'etichetta (FR2.2)
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [text]
              properties:
                text: { type: string, maxLength: 2000 }
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object
                properties:
                  candidate: { $ref: '#/components/schemas/WineCandidate' }
                  matched: { type: boolean }
  /v1-getWineProfile:
    post:
      summary: Finestra e abbinamenti dalla base dati esterna (FR4.2, FR7.2)
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [name]
              properties:
                name: { type: string, maxLength: 120 }
                producer: { type: string, maxLength: 120 }
                vintage: { type: integer, nullable: true }
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object
                properties:
                  found: { type: boolean }
                  window:
                    type: object
                    nullable: true
                    properties:
                      startYear: { type: integer }
                      peakYear: { type: integer }
                      endYear: { type: integer }
                  confidence: { type: string, enum: [high, medium, low], nullable: true }
                  pairings: { type: array, items: { type: string } }
                  wineType: { type: string, enum: [red, white, rose, sparkling, sweet], nullable: true }
                  region: { type: string, nullable: true }
                  denomination: { type: string, nullable: true }
components:
  schemas:
    WineCandidate:
      type: object
      properties:
        name: { type: string }
        producer: { type: string, nullable: true }
        vintage: { type: integer, nullable: true }
        wineType: { type: string, enum: [red, white, rose, sparkling, sweet], nullable: true }
        region: { type: string, nullable: true }
        denomination: { type: string, nullable: true }
```

**Errori** (codici delle callable Firebase): `unauthenticated` (nessun accesso), `invalid-argument` (campi non validi), `resource-exhausted` (limite superato), `unavailable` (fornitore esterno non raggiungibile: l'app usa le regole interne di C2), `deadline-exceeded` (timeout). "Non trovato" non è un errore: `found: false` / `matched: false`. Nessun nuovo tentativo automatico lato app oltre uno, dopo 2 secondi, solo per `unavailable`.

## C2 — Estimation library API (v1)

Pacchetto Dart puro, senza Flutter né Firebase.

```yaml
shared-schema:
  name: estimation
  version: v1
  functions:
    estimateWindow:
      input: { wine: WineFacts, external: ExternalProfile? }
      output: DrinkingWindow
      rule: usa external se presente, altrimenti regole interne per wineType, denomination, vintage
    statusOf:
      input: { window: DrinkingWindow, today: Date }
      output: WineStatus
    pairingsFor:
      input: { wine: WineFacts, external: ExternalProfile? }
      output: Pairings
    needsRefinement:
      input: { window: DrinkingWindow }
      output: bool
      rule: true quando source = internalRules (vino da ristimare al ritorno della rete, FR4.7)
  types:
    WineFacts: { name: string, producer: string?, vintage: int?, wineType: enum?, region: string?, denomination: string? }
    ExternalProfile: "risposta di C1 v1-getWineProfile con found = true"
    DrinkingWindow: { startYear: int, peakYear: int, endYear: int, confidence: [high, medium, low], source: [catalog, internalRules] }
    WineStatus: [waiting, ready, drinkSoon, pastWindow]
    Pairings: { items: [string], source: [catalog, internalRules] }
  rules:
    - "drinkSoon e' un caso di ready: mesi alla fine <= max(3, min(12, 25% della durata))"
    - "durata della finestra in mesi = (endYear - startYear + 1) x 12, dal 1 gennaio di startYear al 31 dicembre di endYear"
    - "senza annata: stima con confidence low"
```

## C3 — Modello dati Firestore condiviso (v1)

```yaml
shared-schema:
  name: firestore
  version: v1
  collections:
    users/{userId}:
      fields: { displayName: string, email: string, onboardingSeen: bool, createdAt: timestamp, schemaVersion: 1 }
    cellars/{cellarId}:
      fields: { ownerId: string, name: string, createdAt: timestamp, schemaVersion: 1 }
      subcollections:
        wines/{wineId}:
          fields: { name: string, producer: string?, vintage: int?, wineType: string?, region: string?, denomination: string?, quantity: int, window: DrinkingWindow?, pairings: Pairings?, createdAt: timestamp, updatedAt: timestamp, updatedBy: string }
          rules: "quantity aggiornata solo con incrementi (FieldValue.increment); il risultato sotto 0 viene riportato a 0 dall'app alla lettura e corretto alla scrittura successiva (ADR-004)"
        drinkingRecords/{recordId}:
          fields: { wineId: string, wineName: string, vintage: int?, drankOn: date, rating: int?, notes: string?, recordedBy: string, createdAt: timestamp }
        members/{memberUserIdOrEmailKey}:
          fields: { inviteeEmail: string, inviteeUserId: string?, permission: [read, edit], status: [invited, active, revoked], invitedAt: timestamp, ownerId: string }
  security:
    owner: "legge e scrive tutto in cellars/{cellarId} se ownerId == uid (u1-skeleton)"
    members: "read con permission read o edit; write su wines e drinkingRecords solo con edit e status active (u7-sharing)"
    members-management: "solo il proprietario crea, modifica o revoca members (u7-sharing)"
    users: "ognuno legge e scrive solo users/{uid}"
```

La copia di `ownerId` in ogni `members` permette alle regole e a Sharing di verificare il proprietario senza leggere `cellars` (chiarisce la dipendenza Sharing–Cellar segnalata in Domain Design). Il wine, la sua stima e gli abbinamenti stanno nello stesso documento: eliminando il vino si elimina anche la stima.

## C4 — Sharing service (v1)

```yaml
shared-schema:
  name: sharing-service
  version: v1
  operations:
    invite: { input: { cellarId, email, permission: [read, edit] }, errors: [limitReached, alreadyInvited, selfInvite, invalidEmail, notOwner] }
    changePermission: { input: { cellarId, memberKey, permission }, errors: [notOwner, notFound] }
    revoke: { input: { cellarId, memberKey }, errors: [notOwner, notFound] }
    revokeAllForUser: { input: { userId }, effect: "revoca gli accessi concessi dalle sue cantine e rimuove quelli ricevuti", consumer: u8-account }
    canRead: { input: { cellarId, userId }, output: bool }
    canEdit: { input: { cellarId, userId }, output: bool }
    listAccessibleCellars: { input: { userId }, output: "[ { cellarId, ownerName, permission } ]" }
```

## C5 — Base dati vini esterna (adattatore)

U3 incapsula il fornitore dietro un'interfaccia interna con le stesse tre operazioni di C1 (`suggest`, `matchText`, `profile`). Il formato del fornitore non esce mai da U3; cambiare fornitore cambia solo l'adattatore. Timeout verso il fornitore 5 secondi; risposte memorizzate per 30 giorni per nome+annata per restare nella quota gratuita.

## Contract ownership rules

- Ogni contratto ha un solo proprietario (colonna Owner); solo il proprietario cambia la specifica.
- Versione `v1` nei nomi delle funzioni (`v1-...`), nel pacchetto `estimation` e in `schemaVersion` dei documenti.
- Modifiche compatibili: solo aggiunta di campi o operazioni facoltativi; i consumatori ignorano i campi sconosciuti.
- Modifiche incompatibili: nuova versione (`v2-...`) affiancata alla precedente finché le versioni vecchie dell'app sono in circolazione su Google Play.
- Le regole di sicurezza stanno in un solo file nel repository: U1 possiede le regole del proprietario e di `users`, U7 quelle di `members` e dei permessi delle persone invitate.

## Open questions

| Contract | Question | Blocks |
|----------|----------|--------|
| C5 | Quale base dati vini esterna usare (disponibilità, quota gratuita, licenza dei dati) | u3-wine-catalog |
| C1 | Il limite di 60 richieste al minuto va confermato rispetto alla quota del fornitore scelto | u3-wine-catalog |
| C3 | Cosa fare delle bevute registrate da una persona che cancella l'account in cantine altrui (anonimizzare `recordedBy` o mantenerlo) | u8-account |
