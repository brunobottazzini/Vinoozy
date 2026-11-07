# Contract Summary — Vinoozy

Fonti: `unit-of-work.md` e `unit-of-work-dependency.md` (Units Generation), `components.md` (Domain Design), `requirements.md`, risposte in `contract-design-questions.md` (Q1: funzioni callable Firebase; Q2: versione `v1`, solo aggiunte compatibili).

## Contracts

| # | Provider Unit | Consumer | Mechanism | Owner |
|---|---------------|----------|-----------|-------|
| C1 | u3-wine-catalog | u4-cellar, u6-label-recognition | Interfaccia Dart `WineCatalog` dentro l'app (aggiornato 2026-11-05; in origine callable Firebase) | u3-wine-catalog |
| C2 | u2-estimation | u4-cellar, u5-dashboard | Libreria Dart (API pubblica del pacchetto) | u2-estimation |
| C3 | u1-skeleton | u4-cellar, u5-dashboard, u6-label-recognition, u7-sharing, u8-account | Modello dati Firestore condiviso + regole di sicurezza | u1-skeleton (dati), u7-sharing (regole dei permessi) |
| C4 | u7-sharing | u8-account, u4-cellar | Interfaccia Dart (servizio di condivisione) | u7-sharing |
| C5 | Open Food Facts (API pubblica, dati ODbL) | u3-wine-catalog | HTTPS di Open Food Facts, dietro un adattatore | u3-wine-catalog (adattatore) |

## C1 — WineCatalog (v1)

**Aggiornamento del 2026-11-05 (Functional Design di U3, scelta del proprietario Q1/Q2):** C1 non è più servito da funzioni callable ma da un'interfaccia Dart `WineCatalog` dentro l'app, con le stesse operazioni e gli stessi tipi qui sotto (i percorsi `v1-...` diventano i metodi `suggestWines`, `matchLabelText`, `getWineProfile`). Il cambio di meccanismo non richiede una `v2`: nessuna versione pubblicata dell'app usa ancora C1 (U4 e U6 non sono costruiti). Aggiunte compatibili: `lookupBarcode(code) -> WineCandidate?`; `suggestExternal(query, locale) -> SuggestResult` (solo risultati di Open Food Facts, chiamata da U4 dopo una pausa nella scrittura); in `suggestWines` il parametro facoltativo `cellarWines` (vini della cantina passati da U4); in `WineCandidate` i campi `source` (`internal`, `cellar`, `openFoodFacts`) e `barcode`. Se un giorno servirà un fornitore con chiave, una funzione cloud servirà questa stessa interfaccia. La specifica originale resta sotto come riferimento dei tipi.

**Errori dell'interfaccia Dart:** solo `CatalogArgumentError` (con codice `queryTooShort`, `queryTooLong`, `textTooLong`, `invalidBarcode`) per ingressi non validi. Nessun'altra eccezione: rete assente, Open Food Facts lento, fuori servizio o con risposte non valide danno risultati solo interni, `matched: false` o `null`. "Non trovato" non è un errore.

Specifica originale (riferimento dei tipi):

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

**Aggiunte compatibili del 2026-11-05 (richieste da U3, proprietario U2):** funzioni di catalogo, pure come le altre:
- `normalizeWineText(text) -> String`: la normalizzazione usata nel riconoscimento (minuscole, senza accenti, apostrofi e punteggiatura come spazi).
- `recognizeDenomination(text) -> RecognizedDenomination?`: denominazione riconosciuta per parole intere, con `key`, `displayName`, `wineType`, `region` e `qualifier`.
- `denominationCatalog -> List<DenominationInfo>`: elenco costante delle denominazioni, con `key`, `displayName` (es. "Barolo DOCG"), `aliases` (le varianti dei nomi), `wineType` e `region`.

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

**Aggiunte compatibili di C3 v1 (2026-11-06, design di u7-sharing)**, tutte campi facoltativi che i consumatori ignorano se non li conoscono:
- in `members`: `ownerName` (stringa, 1–100 caratteri), `inviteeName` (stringa, 1–100 caratteri, dopo l'attivazione), `closedBy` (`owner` | `invitee`), `updatedAt` (timestamp);
- in `cellars`: `memberSlots` (intero da 0 a 2, limite di FR8.1 portato da 5 a 2 il 2026-11-06, numero di inviti `invited` + `active`; se manca vale 0) e `memberOpKey` (stringa, la chiave dell'invito cambiato nello stesso batch del contatore);
- la chiave di `members` è l'email in minuscolo (`inviteeEmail`);
- `drinkingRecords.drankOn` è una stringa data `YYYY-MM-DD`.

**Aggiunte compatibili di C3 v1 (2026-11-06, design di u4-cellar)**, campi facoltativi:
- in `wines`:
  - `matchKey` (stringa ≤ 400, chiave dei doppioni da nome, produttore e annata normalizzati);
  - `baseWindow` (`DrinkingWindow`, stima di base senza riscontri; `window` resta la finestra effettiva);
  - `windowAdjustment` (`{ kind: tooYoung | justRight | pastPeak, year: int, recordId: string }`);
- in `drinkingRecords`:
  - `condition` (`tooYoung` | `justRight` | `pastPeak`) e `updatedAt` (timestamp);
  - si possono aggiornare solo `rating`, `notes`, `drankOn`, `condition` e `updatedAt`, da chi ha registrato la bevuta o dal proprietario;
  - chi l'ha registrata può eliminarla entro 10 minuti ("Annulla");
- in `cellars`: `matchKeyBackfill` (booleano);
- `wines` e `drinkingRecords`: l'eliminazione è riservata al proprietario.

Dettagli in `construction/u4-cellar/functional-design/functional-spec.md`.

I dettagli sono in `construction/u7-sharing/functional-design/functional-spec.md`, sezione "Meccanismi senza funzioni nel cloud".

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

U3 incapsula il fornitore dietro un'interfaccia interna con le operazioni `search` e `product` (aggiornato il 2026-11-05). Il fornitore è Open Food Facts: API pubblica senza chiave, dati con licenza ODbL, identificativo obbligatorio `Vinoozy/<versione> (<contatto>)`. Il formato del fornitore non esce mai da U3; cambiare fornitore cambia solo l'adattatore. Timeout verso il fornitore 5 secondi; risposte riuscite memorizzate sul telefono per 30 giorni; limiti sul telefono di 8 ricerche e 60 letture di prodotto in 60 secondi (finestra mobile), sotto i limiti pubblicati da Open Food Facts.

## Contract ownership rules

- Ogni contratto ha un solo proprietario (colonna Owner); solo il proprietario cambia la specifica.
- Versione `v1` nei nomi delle funzioni (`v1-...`), nel pacchetto `estimation` e in `schemaVersion` dei documenti.
- Modifiche compatibili: solo aggiunta di campi o operazioni facoltativi; i consumatori ignorano i campi sconosciuti.
- Modifiche incompatibili: nuova versione (`v2-...`) affiancata alla precedente finché le versioni vecchie dell'app sono in circolazione su Google Play.
- Le regole di sicurezza stanno in un solo file nel repository: U1 possiede le regole del proprietario e di `users`, U7 quelle di `members` e dei permessi delle persone invitate.

## Open questions

| Contract | Question | Blocks |
|----------|----------|--------|
| C5 | ~~Quale base dati vini esterna usare~~ Risolta il 2026-11-05: catalogo interno + Open Food Facts (Functional Design di U3, Q1) | — |
| C1 | ~~Limite di 60 richieste al minuto~~ Risolta il 2026-11-05: sostituito dai limiti sul telefono verso Open Food Facts (C5) | — |
| C3 | Cosa fare delle bevute registrate da una persona che cancella l'account in cantine altrui (anonimizzare `recordedBy` o mantenerlo) | u8-account |
