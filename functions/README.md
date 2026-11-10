# Vinoozy Cloud Functions

Backend di Freemium e Plus (intent `261110-freemium-plus`, decisione D4): Cloud Functions di 2ª generazione in TypeScript, regione `europe-west8`, la stessa di Firestore (FR9.3).

**Nessun workflow le pubblica.** Le pubblica il proprietario a mano, dopo il passaggio a Blaze descritto in `docs/blaze-switch.md` (FR9.1). Finché non sono pubblicate, `config/policy.purchasesEnabled` resta `false` e l'app non le chiama per gli acquisti.

## Funzioni

| Nome | Tipo | Requisiti | Cosa fa |
|---|---|---|---|
| `verifyPurchase` | callable, Auth + App Check | FR3.3 | Verifica un acquisto Plus presso Play, lega il token a un solo account, scrive `entitlements/{uid}` solo per uno stato pagato, conferma (acknowledge) l'acquisto. |
| `reportUsage` | callable, Auth + App Check | FR6.3, FR6.5 | Applica il delta dei contatori cumulativi di un'installazione al totale dell'account per il mese UTC. |
| `reserveAdSlot` | callable, Auth + App Check | FR7.2 | Prenota l'unico tentativo pubblicitario dell'account per il giorno UTC. |
| `recordAdOutcome` | callable, Auth + App Check | FR7.6 | Registra richiesta, caricamento, impression, errore e ricavo stimato del tentativo prenotato. |
| `onPlayRtdn` | Pub/Sub (topic `play-rtdn`) | FR3.4 | Notifiche Play (RTDN): scarta i duplicati, rilegge sempre lo stato da Play, ignora gli eventi fuori ordine. |
| `reconcileEntitlements` | scheduler, ogni giorno alle 03:00 UTC | FR3.4 | Rilegge da Play gli acquisti che possono ancora cambiare e ritenta le conferme mancate. |
| `onBudgetAlert` | Pub/Sub (topic `budget-alerts`) | FR9.2 | Se la spesa supera **strettamente** il budget, scollega la fatturazione dal progetto e registra l'evento in `billingEvents/{messageId}`. |
| `onUserDeleted` | Auth (1ª gen., `onDelete`) | NFR6 | All'eliminazione dell'account cancella `entitlements/{uid}`, `usage/{uid}/**` e `adSlots/{uid}/**`. |
| `purgeOldUsage` | scheduler, ogni giorno alle 04:00 UTC | NFR6 | Cancella i dettagli di misurazione oltre 90 giorni: mesi d'uso finiti prima della soglia, giorni degli slot pubblicitari e id delle notifiche Play. |

I nomi dei topic si possono cambiare con `functions/.env` (`PLAY_RTDN_TOPIC`, `BUDGET_ALERT_TOPIC`).

## Prodotto Play

Le costanti stanno in `src/config.ts`. Il proprietario crea in Play Console esattamente questi identificativi (`docs/plus-setup.md`):

- pacchetto: `com.vinoozy.app` (l'`applicationId` dell'app su Google Play; `com.vinoozy.vinoozy` è solo il namespace del codice Kotlin);
- prodotto in abbonamento: `vinoozy_plus`;
- piani base: `monthly` (1,99 €) e `annual` (14,99 €).

Un acquisto di un altro prodotto o di un altro piano base viene rifiutato con `WRONG_PRODUCT`.

## Contratti dei callable

L'app li chiama con `FirebaseFunctions.instanceFor(region: 'europe-west8').httpsCallable('<nome>')`. L'uid arriva **sempre** dall'autenticazione, mai dai dati. Ogni errore è un `FirebaseFunctionsException` con un `code` standard e `details.reason`, un codice stabile su cui l'app può decidere.

Errori comuni a tutti i callable:

| `code` | `details.reason` | Quando |
|---|---|---|
| `unauthenticated` | `UNAUTHENTICATED` (o nessun dettaglio) | Nessun utente, oppure token App Check mancante o non valido. |
| `invalid-argument` | `INVALID_REQUEST` | Un campo manca o ha un formato sbagliato; il messaggio indica il campo. |
| `internal` | `INTERNAL` | Errore inatteso del server; si può ritentare più tardi. |

### `verifyPurchase`

Richiesta:

```json
{
  "purchaseToken": "<token di PurchaseDetails.verificationData.serverVerificationData>",
  "productId": "vinoozy_plus",
  "packageName": "com.vinoozy.app"
}
```

`productId` e `packageName` sono facoltativi; se presenti devono essere quelli sopra. Il token accetta lettere, cifre e `. _ : -`, al massimo 4096 caratteri.

Risposta:

```json
{
  "state": "active",
  "plusActive": true,
  "expiresAt": "2026-12-10T10:00:00.000Z",
  "acknowledged": true
}
```

- `state`: `pending` | `active` | `grace` | `on_hold` | `paused` | `expired` | `revoked` | `none`. Con `pending` non viene concesso nulla: l'app mostra l'acquisto in attesa e aspetta (la notifica Play concede Plus quando il pagamento arriva).
- `plusActive`: se il diritto ora scritto dà Plus. È solo un'indicazione: la fonte resta il listener su `entitlements/{uid}`.
- `acknowledged`: `false` se la conferma a Play non è riuscita; la ritenta il job giornaliero, il diritto resta.
- Un secondo invio dello stesso token dallo stesso account è idempotente: nessun duplicato.

Errori propri:

| `code` | `details.reason` | Quando |
|---|---|---|
| `invalid-argument` | `INVALID_TOKEN` | Token assente o di formato non valido. |
| `failed-precondition` | `WRONG_PACKAGE` | `packageName` diverso da `com.vinoozy.app`. |
| `failed-precondition` | `WRONG_PRODUCT` | Il token non è del prodotto `vinoozy_plus` con piano `monthly` o `annual`. |
| `not-found` | `PURCHASE_NOT_FOUND` | Play non conosce il token (falso, di un'altra app o scaduto da tempo). |
| `permission-denied` | `TOKEN_IN_USE` | Il token (o il token a cui è collegato) appartiene già a un altro account. |
| `unavailable` | `PLAY_UNAVAILABLE` | Play non risponde: l'app ritenta più tardi con lo stesso token. |

### `reportUsage`

Richiesta, con i nomi di `UsageCounters.toCumulativeMap()`:

```json
{
  "installationId": "a1B2c3",
  "periodId": "2026-11",
  "sequence": 7,
  "policyVersion": "freemium-v1",
  "cumulativeReadCount": 1200,
  "cumulativeWriteCount": 40,
  "cumulativeEgressBytes": 2457600
}
```

- `installationId`: lettere, cifre, `_` e `-`, da 1 a 128 caratteri.
- `periodId`: `YYYY-MM`, il mese UTC dei contatori.
- `sequence`: intero da 1 a 2^31−1; cresce di uno per ogni nuovo cumulativo.
- i tre cumulativi: interi non negativi.

Risposta:

```json
{
  "accepted": true,
  "reason": null,
  "periodId": "2026-11",
  "estimatedReadCount": 5400,
  "estimatedWriteCount": 120,
  "estimatedEgressBytes": 9830400,
  "aboveBudget": false,
  "serverTime": "2026-11-10T09:30:00.000Z",
  "nextResetUtc": "2026-12-01T00:00:00.000Z",
  "policy": {
    "adsEnabled": false,
    "capacityLimitEnabled": false,
    "purchasesEnabled": false,
    "policyVersion": "freemium-v1",
    "usageBudgetEuro": "0.005",
    "freeActiveWineLimit": 15
  }
}
```

- `estimated*`: totale dell'account nel mese `periodId`, somma di tutti i dispositivi (anche quando `accepted` è `false`).
- `aboveBudget`: `C_hat` del mese strettamente sopra `usageBudgetEuro`, con lo stesso calcolo intero di `lib/usage/usage_cost.dart` (D3).
- `serverTime` e `nextResetUtc` (inizio del mese UTC successivo all'ora del server) sono in ISO 8601 UTC.

Regole (studio §7.6):

| Caso | Esito |
|---|---|
| Prima sequenza del dispositivo, o sequenza più alta con cumulativi uguali o maggiori | `accepted: true`; si somma solo il delta rispetto all'ultimo cumulativo accettato. |
| Stessa sequenza, stessi valori | `accepted: true`, nulla di nuovo (idempotente). |
| Stessa sequenza, valori diversi | `accepted: false`, `reason: "SEQUENCE_CONFLICT"`. |
| Sequenza più vecchia | `accepted: false`, `reason: "STALE_SEQUENCE"`. |
| Un cumulativo diminuisce | `accepted: false`, `reason: "DECREASING_CUMULATIVE"`. |
| Nuova sequenza meno di 10 s dopo l'ultima accettata | `accepted: false`, `reason: "TOO_FREQUENT"`. |
| Mese precedente a quello dell'ora del server | accettato e applicato a quel mese (upload tardivo), mai al mese corrente. |
| Mese più vecchio del precedente | `accepted: false`, `reason: "PERIOD_CLOSED"`. |
| Mese futuro rispetto all'ora del server | `accepted: false`, `reason: "PERIOD_NOT_STARTED"`. |

Con `accepted: false` l'app non considera riconosciuto il cumulativo e ne manda uno nuovo con una nuova sequenza (`UsageUploader`). Per `PERIOD_CLOSED` il mese non verrà mai più accettato: l'app può dimenticarlo.

### `reserveAdSlot`

Richiesta: `{}` (nessun campo).

Risposta:

```json
{
  "granted": true,
  "reason": null,
  "reservationId": "6f1c2a9e-3b7d-4c55-9a0e-2f4b8d1e7c3a",
  "day": "2026-11-10",
  "serverTime": "2026-11-10T09:30:00.000Z"
}
```

In una sola transazione il server ricontrolla `adsEnabled`, il Plus valido, la soglia del mese UTC corrente (sul totale del server, quindi l'app invia prima `reportUsage`) e lo slot del giorno UTC. Se `granted` è `false`, `reservationId` è `null` e `reason` vale `ADS_DISABLED`, `PLUS_ACTIVE`, `BELOW_THRESHOLD` oppure `ALREADY_RESERVED`. Lo slot è uno per account e giorno UTC, condiviso tra dispositivi, e resta consumato anche se l'annuncio non arriva o va in errore. Se la chiamata fallisce, l'app non carica nessun annuncio.

### `recordAdOutcome`

Nome scelto per il registro degli esiti (FR7.6). Richiesta:

```json
{
  "reservationId": "6f1c2a9e-3b7d-4c55-9a0e-2f4b8d1e7c3a",
  "day": "2026-11-10",
  "event": "impression"
}
```

- `event`: `request` | `loaded` | `impression` | `failed` | `revenue`. `loaded` (cioè `onAdLoaded`) **non** vale come impression: ogni evento ha il proprio campo (`requestedAt`, `loadedAt`, `impressionAt`, `failedAt`, `revenueAt`).
- Solo per `revenue` (callback `onPaidEvent`): `valueMicros` (intero ≥ 0), `currencyCode` (tre lettere maiuscole) e `precision` facoltativo (`unknown` | `estimated` | `publisher_provided` | `precise`).
- `day` e `reservationId` sono quelli restituiti da `reserveAdSlot`.

Risposta: `{ "recorded": true }`. Con `false` lo stesso evento era già registrato e si conserva il primo (deduplicazione con la prenotazione).

Errore proprio: `not-found` con `NO_RESERVATION` se non esiste uno slot di quel giorno con quel `reservationId` per l'account.

## Dati scritti

- `entitlements/{uid}`: `plan`, `source` (`play_purchase`), `status`, `expiresAt`, `startedAt`, `updatedAt`, `purchaseTokenHash` (sha256, mai il token), `basePlanId`. Uno stato che non dà Plus non sostituisce mai un diritto ancora valido scritto da un altro token o da un regalo.
- `purchases/{sha256(token)}`: raccolta privata del server (le regole negano ogni accesso). Contiene il token, l'uid legato, lo stato, la conferma e l'ora dell'ultimo evento Play. All'eliminazione dell'account l'uid diventa `null` (conservazione minima: il token resta per rimborsi e contestazioni e può essere ripristinato su un nuovo account).
- `usage/{uid}/periods/{YYYY-MM}` e `.../devices/{installationId}`: solo numeri, versioni, date e identificatori (NFR6).
- `adSlots/{uid}/days/{YYYY-MM-DD}`: `reservationId`, `reservedAt`, `periodId` e i campi degli eventi.
- `playEvents/{messageId}` e `billingEvents/{messageId}`: registri tecnici del server.

## Credenziali e sicurezza

- La Play Developer API e Cloud Billing usano solo l'account di servizio di runtime delle funzioni (Application Default Credentials). Nessuna chiave nel repository né nell'app (NFR1). I permessi da dare all'account di servizio sono in `docs/plus-setup.md` e `docs/blaze-switch.md`.
- I token d'acquisto non compaiono mai nei log: si registra solo un'etichetta di 12 caratteri dell'hash (NFR6).
- Nell'emulatore il client Play risponde sempre «non disponibile» e il client Billing scrive solo un log: un'esecuzione locale non tocca mai Play né un conto di fatturazione reale.
- RTDN: Pub/Sub consegna i messaggi alla funzione con un'identità di Google; la funzione accetta solo messaggi con `packageName` uguale a `com.vinoozy.app` e rilegge comunque lo stato da Play.

## Sviluppo e test

```bash
npm ci --prefix functions
npm --prefix functions run build      # tsc
npm run test:functions                # compila, avvia gli emulatori e lancia mocha
```

`test:functions` avvia Firestore, Auth e Functions dell'emulatore sul progetto `demo-vinoozy`. I test chiamano i gestori con un client Play e un client Billing finti, e chiamano i callable veri attraverso l'emulatore Functions. I test si rifiutano di partire se `FIRESTORE_EMULATOR_HOST` non è impostato.

**App Check nell'emulatore.** L'emulatore Functions decodifica i token di Auth e di App Check senza verificarli, ma con `enforceAppCheck: true` un token App Check **deve esserci**. Nell'app di sviluppo basta attivare il provider di debug di App Check; nei test si usa un JWT non firmato con `sub` uguale all'app id.
