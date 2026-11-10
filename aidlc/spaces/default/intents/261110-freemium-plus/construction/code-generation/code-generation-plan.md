# Piano di generazione del codice — Freemium e Plus

## Summary

- Builds: diritti e piani, limite di 15 schede con contatore verificato dalle regole, Plus su Play Billing con verifica in Cloud Functions, script per regalare Plus, strumenti sviluppatore nascosti, misuratore d'uso, modulo annunci spento, protezioni di spesa per Blaze
- Touches: `lib/plan/` (nuovo), `lib/usage/` (nuovo), `lib/ads/` (nuovo), `lib/dev/` (nuovo), `lib/cellar/` (repository e azioni), Profilo, Dashboard, `firestore.rules`, `functions/` (nuovo), `tool/admin/` (nuovo), `tool/check_release_build.sh`, CI, l10n, `docs/`
- Tests: circa 60 test, tra unit e widget (Flutter), test delle regole nell'emulatore, test delle funzioni con l'emulatore e 2 test end-to-end

Fonte: `inception/requirements-analysis/requirements.md` (scope `express`, zero Unit; non ci sono storie, quindi ogni passo rimanda agli identificativi FR/NFR). Contesto del codice: `aidlc/spaces/default/codekb/Vinoozy/`.

## Testing Contract

```json
{
  "version": 1,
  "methodology": "test-after",
  "source": "team",
  "ordering": "Per ogni strato testabile (dominio, dati e sincronizzazione, interfaccia) implementiamo prima il codice, poi scriviamo ed eseguiamo i test di quello strato, e passiamo allo strato successivo solo con quei test verdi.",
  "scope": "express",
  "test_strategy": "minimal",
  "project_type": "brownfield",
  "applicable_notes": [
    {
      "layer": "org",
      "text": "We treat tests as a first-class deliverable in every Bolt. The specific\nmethodology (TDD, BDD, ATDD, or classic test-after) is affirmed at\npractices-discovery and recorded in `team.md` under this heading with explicit\n`Methodology` and `Ordering` fields; Code Generation resolves those fields\nindependently from coverage, tooling, and scope notes.\n\nWhen no posture has been affirmed, our default per scope is:\n- **Methodology**: test-after\n- **Ordering**: implement each applicable testable layer, then write and run\n  that layer's tests.\n- `mvp`, `enterprise`, `feature`, `infra`, `classic` add an 80% line-coverage\n  floor and CI execution before merge.\n- `bugfix`, `security-patch` add a targeted regression for the specific\n  bug/vulnerability and require the existing suite to remain green.\n- `express` uses the Minimal strategy: requirement-driven unit tests (one per\n  requirement, with a happy-path floor per component); existing tests remain\n  green.\n- `poc`, `refactor`, `workshop` add no extra new-test floor and require the\n  existing suite to remain green.\n\nThe active `Test Strategy` still applies in every scope and determines test\nvolume/types. Scope floors are additive; they never reduce or replace the\nselected strategy.\n\nBuild and Test verifies defined coverage floors and affirmed quality targets;\nthey may not be weakened to make a step pass.\n\nAffirm a stricter posture in `team.md` if the team commits to one."
    },
    {
      "layer": "team",
      "text": "- **Methodology**: test-after\n- **Methodology evidence**: scelta in Q5 (\"Dopo il codice, strato per strato\"); coincide con il default di `org.md`.\n- **Ordering**: Per ogni strato testabile (dominio, dati e sincronizzazione, interfaccia) implementiamo prima il codice, poi scriviamo ed eseguiamo i test di quello strato, e passiamo allo strato successivo solo con quei test verdi.\n- **Copertura**: almeno l'**80% delle righe**, calcolato su tutto il codice **senza esclusioni**, compresi codice generato e file di traduzione (Q6). La soglia viene verificata in GitHub Actions e se non è raggiunta il merge in `main` è bloccato.\n- **Strumenti**: `flutter test` con `--coverage` per unit test e test dei widget. Unit test sulla logica (in particolare la stima del momento ideale e l'indice di fiducia), test dei widget per le schermate principali nelle tre lingue dell'interfaccia (it, en, pt-BR).\n- **Integrazione con Firebase**: i test di integrazione girano sulla **Firebase Emulator Suite**, in locale e in GitHub Actions, così non usano il progetto di produzione e non costano nulla (Q9).\n- **End-to-end**: i test che simulano l'uso reale dell'app girano in GitHub Actions su un **emulatore Android** (es. `integration_test` di Flutter), collegato alla Firebase Emulator Suite (Q7). Se falliscono, il merge è bloccato.\n- **Gate prima del merge**: formattazione, analisi statica, test, copertura ed end-to-end devono passare tutti. Un controllo rosso non si aggira e la soglia non si abbassa per far passare un blocco."
    }
  ],
  "obligations": {
    "strategy": "minimal",
    "strategy_volume": [
      "One verifiable test per requirement at the narrowest effective level.",
      "At least one happy-path unit test per component.",
      "Unit tests are the default; a bugfix/security scope floor may require an integration or E2E regression when that is the narrowest level that reproduces the defect."
    ],
    "scope_floor": [
      "Keep the existing test suite green.",
      "This scope adds no extra new-test floor beyond the selected test strategy."
    ],
    "combination_rule": "Apply every selected-strategy obligation and every scope-floor obligation; neither replaces the other, and a targeted scope regression may add the narrowest necessary test type beyond the strategy default."
  },
  "plan_profile": {
    "methodology": "test-after",
    "runner_step": "Verify the existing test runner/configuration and record the exact unit-scoped command.",
    "runner_ready_before_first_test": true,
    "testable_layers": [
      "Data model / database behavior",
      "Repository / data access",
      "Business logic",
      "API / endpoint",
      "Frontend behavior"
    ],
    "steps": [
      "Project structure and production configuration skeleton.",
      "Verify the existing test runner/configuration and record the exact unit-scoped command.",
      "Data model / database behavior - implement.",
      "Data model / database behavior - write and run its tests after implementation.",
      "Repository / data access - implement.",
      "Repository / data access - write and run its tests after implementation.",
      "Business logic - implement.",
      "Business logic - write and run its tests after implementation.",
      "API / endpoint - implement.",
      "API / endpoint - write and run its tests after implementation.",
      "Frontend behavior - implement.",
      "Frontend behavior - write and run its tests after implementation.",
      "Environment/build configuration.",
      "Documentation and traceability."
    ]
  },
  "input_sha256": "sha256:865343873c9f0b328d34ded3554c226044cb3a9b68eef7ea66181ee9d1d90ade",
  "contract_sha256": "sha256:225d0e3aa565626c2c5d1d4d16cc8ad5c6cd32fb293c1c2ca264b1e79bca33f9"
}
```

## Analisi d'impatto (brownfield)

- **Impatto alto e trasversale** su `firestore.rules`: nuove raccolte e il contatore sulle scritture dei vini. Restano obbligatori i test esistenti `test/rules/*` e `test/rules/compat/`.
- **Impatto medio** su `lib/cellar/data/wine_repository.dart` e `lib/cellar/cellar_actions.dart`, che riguardano tutti i percorsi che cambiano lo stato attivo, e su `lib/app/bootstrap.dart` e sui provider di `lib/app/providers.dart`.
- **Impatto basso**, solo aggiunte: Profilo, Dashboard, `BrandFooter`, `HomeShell` (barra di navigazione), l10n e CI.
- **Base dei test:** prima di toccare il codice, il passo 2 esegue l'intera suite attuale e ne registra l'esito.

## Decisioni tecniche del piano

- **D1 — Contatore `activeWineCount`** (FR2.2). È un campo di `cellars/{ownerUid}`. Ogni batch del client che cambia lo stato attivo di una scheda scrive anche la cantina con `activeWineCount` ±1 e `activeOpWineId` uguale all'id del vino, sullo stesso schema già usato per `memberSlots` e `memberOpKey`. Le regole verificano con `get` e `getAfter` sul vino che `activeAfter − activeBefore` coincida con il delta, dove attivo significa `quantity > 0`. Se il batch non tocca la cantina, le regole accettano la scrittura del vino solo se lo stato attivo non cambia, **oppure** se `config/policy.capacityLimitEnabled == false` e la cantina non ha ancora `activeWineCount`. Così restano valide le scritture della versione già pubblicata (FR2.6). Un delta sbagliato per concorrenza, cioè un incremento risolto sul server in modo diverso dal previsto, viene rifiutato: il client lo tratta come conflitto recuperabile (FR2.5), rilegge e riprova una volta.
- **D2 — Limite effettivo** (FR2.4). Le regole leggono `config/policy` e, solo se il delta è +1, anche `entitlements/{ownerUid}`. Il budget di espressioni e di `get` (NFR2) va verificato con un test dedicato sul caso peggiore, cioè un membro invitato che riattiva una scheda con il limite attivo.
- **D3 — Costo in aritmetica intera** (FR6.2). Si moltiplicano i due lati per `1e8 · 2^30`, così il confronto diventa `R·35·2^30 + W·104·2^30 + B·12·10^6 > 5·10^5·2^30`, calcolato con `BigInt`. Nessuna dipendenza decimale e nessun arrotondamento intermedio.
- **D4 — Backend** (FR3.3, FR3.4, FR6.3, FR7.2, FR9.2): una cartella nuova `functions/` in TypeScript, Cloud Functions di 2ª generazione, regione `europe-west8`, con `firebase-functions`, `firebase-admin`, `googleapis` (androidpublisher) e `@google-cloud/billing`. Si prova solo con la Firebase Emulator Suite e la Play API sostituita da un finto client iniettato. **Non si pubblica**: lo farà il proprietario dopo FR9.1.
- **D5 — Fixture per gli strumenti sviluppatore** (FR5.6). Nella build di sviluppo, il pannello scrive `entitlements/{uid}` attraverso l'API REST dell'**emulatore** Firestore con l'header `Authorization: Bearer owner`, che nell'emulatore salta le regole. Prima verifica che l'host sia quello dell'emulatore e che il progetto sia `demo-vinoozy`. Il codice si compila solo dentro `if (kDevCheatsAvailable)` e non esiste in release (FR5.1, FR5.7).
- **D6 — Plugin**: `in_app_purchase` (Play Billing) e `google_mobile_ads` (AdMob, con UMP per il consenso). L'App ID di AdMob arriva da un placeholder Gradle: l'ID di test Google per debug e CI, l'ID reale da un segreto in release, con fallback all'ID di test se manca. L'SDK non viene mai inizializzato con `adsEnabled=false` (FR7.1).
- **D7 — Script amministrativi** in `tool/admin/` (Node, `firebase-admin`): `grant_plus.mjs` (`grant`/`revoke`), `set_policy.mjs` e `migrate_capacity.mjs`. Le credenziali si leggono da `GOOGLE_APPLICATION_CREDENTIALS` o da `--credentials <path>` fuori dal repository. Gli script verificano l'ID del progetto. Un `.gitignore` copre `*service-account*.json`.

## Passi

### Strato 0 — Struttura e verifica dei test

- [x] **Step 1 — Struttura e dipendenze.**
  - In `pubspec.yaml` aggiungere `in_app_purchase` e `google_mobile_ads` alle versioni stabili correnti.
  - Creare le cartelle `lib/plan/`, `lib/usage/`, `lib/ads/`, `lib/dev/`, `functions/` (`package.json`, `tsconfig.json`, `src/index.ts`) e `tool/admin/` (`package.json`).
  - In `firebase.json` aggiungere `functions` con `source: functions`, regione `europe-west8` e l'emulatore `functions`.
  - Riferimenti: NFR5, FR9.3.
- [x] **Step 2 — Base dei test e comandi.**
  - Prima di ogni modifica eseguire `flutter test` (suite completa) e `npm run test:rules`, e registrare in `code-summary.md` il numero di test passati e falliti.
  - Aggiungere `style_profiles.rules.test.mjs` all'elenco di `test:rules` in `package.json` (NFR2).
  - Aggiungere lo script `test:functions`, che è `firebase emulators:exec --only firestore,auth,functions --project demo-vinoozy "npm --prefix functions test"`.
  - Verificare che `flutter test test/plan/` sia eseguibile.

### Strato 1 — Modello dei dati e regole Firestore

- [x] **Step 3 — Modelli di dominio.**
  - `lib/plan/domain/entitlement.dart`: `Entitlement`, enum `EntitlementSource` e `EntitlementStatus`, `fromFirestore` tollerante ai campi mancanti.
  - `lib/plan/domain/plan_policy.dart`: `PlanPolicy`, cioè `config/policy`, con default sicuri `adsEnabled=false`, `capacityLimitEnabled=false`, `purchasesEnabled=false`, `policyVersion='freemium-v1'`, `usageBudgetEuro` come stringa `"0.005"` e `freeActiveWineLimit=15`.
  - `lib/plan/domain/capabilities.dart`: `PlanTier`, cioè `free` o `plus` con l'origine, e `Capabilities`.
  - `lib/usage/domain/usage_counters.dart`.
  - Riferimenti: FR1.1, FR1.2, FR6.5.
- [x] **Step 4 — Regole Firestore** (`firestore.rules`).
  - `entitlements/{uid}`: `get` solo da parte del proprietario, nessuna scrittura dal client.
  - `config/{doc}`: `get` per chi ha fatto l'accesso, nessuna scrittura.
  - `usage/{uid}/**` e `adSlots/{uid}/**`: lettura solo propria, nessuna scrittura.
  - `purchases/{tokenHash}`: nessun accesso dal client.
  - Su `cellars/{cellarId}` i campi `activeWineCount` e `activeOpWineId` con la verifica D1; `legacyActiveWineLimit` non è mai scrivibile dal client.
  - Su vini creati, aggiornati e cancellati, il controllo del delta e del limite D1 e D2, valido anche per i membri `edit`.
  - Eliminazione dell'account: nessuna regola client per `entitlements`, `usage` e `adSlots`; la pulizia avviene nel backend (Step 13).
  - Riferimenti: FR1.1, FR2.2, FR2.3, FR2.4, FR2.6, FR6.5, NFR1, NFR2.
- [x] **Step 5 — Test delle regole** (`test/rules/freemium.rules.test.mjs`, aggiunto a `test:rules`). Casi:
  - scrittura client su `entitlements`, `config`, `usage`, `adSlots`, `purchases` e `legacyActiveWineLimit` rifiutata;
  - creazione di un vino con e senza delta corretto;
  - passaggio 0→2 senza contatore rifiutato e con +1 accettato;
  - Annulla di una bevuta da 0 a 1;
  - cancellazione −1;
  - con il limite attivo, la sedicesima scheda rifiutata, l'incremento di una scheda attiva accettato e la riattivazione rifiutata;
  - Plus valido del proprietario che permette la sedicesima, con lo stesso comportamento per un membro `edit`;
  - Plus scaduto;
  - limite spento senza contatore accettato (compat);
  - caso peggiore di budget.

  Eseguire `npm run test:rules` e ottenere verde su tutti i test, vecchi e nuovi.

### Strato 2 — Accesso ai dati e sincronizzazione

- [x] **Step 6 — Repository.**
  - `lib/plan/data/entitlement_repository.dart`: listener su `entitlements/{uid}`, copia locale in `shared_preferences` con data dell'ultima conferma e validità di 7 giorni (FR1.4), stream `Entitlement?`.
  - `lib/plan/data/policy_repository.dart`: lettura di `config/policy` con cache e default sicuri se non disponibile (NFR4).
- [x] **Step 7 — Contatore nei percorsi di scrittura dei vini.**
  - In `WineRepository` (`create`/`addWine`, `incrementQuantity`/`addBottles`, `removeBottle`, `updateWine` quando cambia la quantità, `mergeInto`, `deleteWineWithRecords`) e nel flusso bevuta/Annulla di `CellarActions`: calcolare il cambio di stato attivo dalla quantità nota, dove attivo significa `> 0` (FR2.1), e aggiungere al batch l'aggiornamento della cantina del proprietario (`FieldValue.increment(±1)` e `activeOpWineId`). Per una cantina condivisa la cantina è quella del proprietario.
  - Su `permission-denied` legato al limite o al delta, mantenere la modifica come bozza recuperabile tramite il registro esistente degli errori di sync (`SyncErrorBus`/ledger), con un motivo `capacityLimit` o `capacityConflict`, e una sola rilettura e ritentativo nel caso di conflitto.
  - Riferimenti: FR2.2, FR2.5.
- [x] **Step 8 — Strumentazione del misuratore.**
  - `lib/usage/cloud_usage_meter.dart`: contatori per uid, mese UTC e installazione, salvati in `shared_preferences`, con contatore di sistema separato.
  - Agganci prima del mapping nei punti dello studio §7.5: listener condiviso dei vini (dedup per identità di sottoscrizione; primo snapshot dal server `max(1, n)`, poi `docChanges` non da cache), dettaglio del vino, `drinking_record_repository` (pagina dal server, minimo 1), `server_or_cache` (richiesta originale contata una sola volta anche dopo il fallback), conferme delle scritture (dal ledger, al completamento), condivisione e profilo.
  - Le migrazioni ed `estimate_refresher` usano il contatore di sistema. B = 2 KiB per documento ricevuto.
  - Riferimenti: FR6.1, FR6.4.
- [x] **Step 9 — Test dello strato dati** (`test/plan/data/`, `test/usage/`, `test/cellar/data/active_counter_test.dart`). Con `fake_cloud_firestore` o i mock già usati nei test di `test/cellar/data/`:
  - copia locale del diritto valida o scaduta dopo 7 giorni;
  - default della policy in caso di errore;
  - ogni percorso di scrittura aggiunge il delta corretto e nessun delta quando lo stato attivo non cambia;
  - rifiuto trasformato in bozza recuperabile;
  - listener condiviso contato una volta;
  - cache e metadata non contati;
  - query vuota uguale a 1 lettura e 0 byte;
  - scrittura in coda contata solo alla conferma;
  - completamento del server dopo il fallback contato una volta.

  Eseguire `flutter test test/plan/data test/usage test/cellar/data/active_counter_test.dart` e ottenere verde, poi la suite `test/cellar/` esistente, anch'essa verde.

### Strato 3 — Logica di prodotto

- [x] **Step 10 — Logica.**
  - `lib/plan/capability_resolver.dart`: diritto, ora del server stimata e override di sviluppo producono `PlanTier` e `Capabilities` (FR1.2, FR1.5).
  - `lib/plan/capacity_guard.dart`: controllo preventivo del limite effettivo (`legacyActiveWineLimit` oppure 15) prima di aggiungere o riattivare (FR2.4, FR2.5).
  - `lib/usage/usage_cost.dart`: costo intero con BigInt e soglia stretta (D3, FR6.2).
  - `lib/usage/usage_uploader.dart`: cumulativi, sequenza, invio ogni 15 minuti, in background e al primo superamento, totale ricevuto dal server più solo il delta locale non ancora riconosciuto (FR6.3, NFR3).
  - `lib/ads/ad_eligibility.dart`: le formule `eligible` e `canAttemptAd` dello studio §7.7 (FR7.2).
  - `lib/dev/dev_cheats.dart`: `kDevCheatsAvailable`, cioè `!kReleaseMode && bool.fromEnvironment('ENABLE_DEV_CHEATS') && usesEmulators && projectId == 'demo-vinoozy'`; `DevOverride`, salvato per uid e progetto e cancellato al logout o al cambio account; `SecretSequenceDetector`, con la sequenza logo×2 seguita da Cantina×3, Storico×3, Cantina, Storico, Cruscotto, entro 20 s e azzerata se un passo è sbagliato (FR5.1, FR5.2, FR5.5).
- [x] **Step 11 — Test della logica.**
  - `test/plan/capability_resolver_test.dart`: tutti gli stati della FR1.2, grace valido, `expiresAt` passato, `manual_grant` senza scadenza, override di sviluppo.
  - `test/plan/capacity_guard_test.dart`: 15 su 15 e la sedicesima, aumento su una scheda attiva, legacy 22, Plus.
  - `test/usage/usage_cost_test.dart`: tutti i confini dello studio §7.11 (14.285/14.286, 4.807/4.808, 44.739.242/44.739.243 byte, 14.256+10 uguale alla soglia, 479/480, 427/428).
  - `test/usage/usage_uploader_test.dart`: idempotenza locale, delta non riconosciuto, cambio di mese.
  - `test/ads/ad_eligibility_test.dart`.
  - `test/dev/dev_cheats_test.dart`: disponibilità con le 4 condizioni, sequenza completa, passo sbagliato, oltre 20 s, cambio uid.

  Eseguire `flutter test test/plan test/usage test/ads test/dev` e ottenere verde.

### Strato 4 — Backend (API ed endpoint)

- [x] **Step 12 — Cloud Functions** (`functions/src/`).
  - `verifyPurchase`: callable, autenticata, `enforceAppCheck: true`; verifica il pacchetto `com.vinoozy.vinoozy` e il prodotto Plus presso `purchases.subscriptionsv2.get`; lega `purchases/{sha256(token)}` all'uid in una transazione e rifiuta un altro uid; scrive l'entitlement solo per uno stato pagato; esegue l'acknowledge idempotente; con `PENDING` non concede nulla (FR3.3).
  - `onPlayRtdn`: Pub/Sub, topic configurabile; deduplica per `messageId`, rilegge dalla Play API, gestisce le transizioni e ignora gli eventi fuori ordine tramite `updatedAt` (FR3.4).
  - `reconcileEntitlements`: scheduler giornaliero (FR3.4).
  - `reportUsage`: callable con App Check; delta per dispositivo, sequenze idempotenti, regole di monotonia, periodo dall'ora del server; risponde con totale, policy, ora del server e prossimo reset (FR6.3, FR6.5).
  - `reserveAdSlot`: callable; transazione su `adSlots/{uid}/days/{YYYY-MM-DD}` con ricontrollo di periodo, soglia, `adsEnabled` e Plus; più l'endpoint di registro degli esiti (richiesta, caricamento, impression) (FR7.2, FR7.6).
  - `onBudgetAlert`: Pub/Sub del budget; se `costAmount > budgetAmount` scollega la fatturazione con `@google-cloud/billing` e registra l'evento (FR9.2).
  - `onUserDeleted`: pulizia di `entitlements`, `usage` e `adSlots` dell'uid (NFR6).
  - `purgeOldUsage`: scheduler che cancella i dettagli oltre 90 giorni (NFR6).
  - Credenziali solo da Secret Manager o dall'account di servizio di runtime; nessun token nei log (NFR1, NFR6).
- [x] **Step 13 — Script amministrativi** (`tool/admin/`).
  - `grant_plus.mjs grant --email <e> (--until YYYY-MM-DD | --no-expiry) [--reason gift|owner_test]` e `grant_plus.mjs revoke --email <e>`: `getUserByEmail`, si ferma su un'email sconosciuta, stampa uid e scadenza (FR4.1, FR4.2, FR4.4).
  - `set_policy.mjs`: imposta i flag di `config/policy`.
  - `migrate_capacity.mjs`: per ogni cantina conta le schede con `quantity > 0` e scrive `activeWineCount` e `legacyActiveWineLimit = max(15, n)` (FR2.3).
  - Tutti gli script stampano e verificano l'ID del progetto e offrono `--emulator` per i test.
  - `.gitignore`: `*service-account*.json` e `tool/admin/*.key.json`.
- [x] **Step 14 — Test del backend e degli script** (`functions/test/`, mocha o jest con `firebase-functions-test` e l'emulatore; Play API e Billing finti).
  - `verifyPurchase`: token falso, pacchetto o prodotto sbagliato, replay su un altro uid, `PENDING`, invio doppio idempotente, acknowledge.
  - RTDN: annullamento che resta attivo fino alla scadenza, rimborso uguale a revoked, evento fuori ordine, duplicato.
  - `reportUsage`: delta, sequenza vecchia, valori diversi rifiutati, due dispositivi, upload tardivo del mese precedente.
  - `reserveAdSlot`: due richieste concorrenti con un solo slot; con Plus, nessuno slot.
  - `onBudgetAlert`: sopra e sotto il budget.
  - `test/admin/grant_plus.test.mjs` sull'emulatore: concessione, email sconosciuta e revoca.

  Eseguire `npm run test:functions` e ottenere verde.

### Strato 5 — Interfaccia

- [x] **Step 15 — Provider e avvio.**
  - `lib/plan/plan_providers.dart` (Riverpod): diritto, policy, `PlanTier`, `Capabilities` e override di sviluppo.
  - Aggancio del misuratore e dell'uploader al ciclo di vita dell'app in `bootstrap.dart` e nel resume/pause.
  - Pulizia dell'override, della copia del diritto e dei contatori locali al logout e al cambio account, tramite il `reset_coordinator` esistente (FR5.5, FR1.4).
- [x] **Step 16 — Schermate e componenti.**
  - Profilo: riga del piano «Gratuito / Plus / Plus in regalo / DEV · …» con chiave `profile-plan` e voce «Scopri Plus» (FR1.3, FR5.4).
  - `lib/plan/ui/plus_screen.dart`: prezzi dai `ProductDetails`, termini, rinnovo, «Ripristina acquisti» e link a `https://play.google.com/store/account/subscriptions?sku=…&package=com.vinoozy.vinoozy`; con `purchasesEnabled=false` mostra «Plus arriverà presto» senza pulsante (FR3.1, FR3.2, FR3.5).
  - `lib/plan/billing/billing_service.dart`: `in_app_purchase` → `verifyPurchase`, gestione di pending, errori e annullamento (FR3.3).
  - Spiegazione del limite con «Scopri Plus» negli ingressi di aggiunta e riattivazione, e banner della bozza rifiutata (FR2.5).
  - Presentazione del piano gratuito, una volta, solo con il limite attivo (FR8.2).
  - Dashboard: spiegazione al superamento della soglia, una volta per periodo, con il reset nell'ora locale, «Come funziona» e «Scopri Plus» (FR7.5); slot del banner `lib/ads/ui/dashboard_ad_slot.dart` (FR7.1, FR7.3, FR7.4); CMP UMP prima della richiesta; nessun annuncio in altre schermate.
  - `lib/dev/ui/dev_tools_screen.dart`, con marker `VINOOZY_DEV_CHEATS_PANEL` e i 4 comandi più l'indicatore (FR5.3, FR5.4, FR5.6). Sequenza collegata in `BrandFooter` (doppio tocco; il tocco singolo apre ancora Informazioni) e in `HomeShell` (barra di navigazione), solo dentro `if (kDevCheatsAvailable)` (FR5.2).
  - Ogni testo sta in `lib/l10n/app_it.arb`, `app_en.arb` e `app_pt_BR.arb`, con i testi dello studio §7.8 (FR8.1); poi `flutter gen-l10n`.
  - Chiavi di test (`Key`) su ogni elemento interattivo.
- [x] **Step 17 — Test dei widget** (`test/plan/ui/`, `test/ads/ui/`, `test/dev/ui/`), nelle tre lingue dove ci sono testi.
  - Riga del piano nel Profilo per gratuito, Plus, regalo e DEV.
  - Schermata Plus con `purchasesEnabled` falso o vero e prezzi finti.
  - Spiegazione del limite con 15 su 15.
  - Spiegazione della soglia una volta sola e reset nell'ora locale.
  - Slot annuncio: niente SDK con `adsEnabled=false`, rimozione all'attivazione di Plus, nessun ricaricamento nello stesso giorno (servizio annunci finto).
  - Pannello sviluppatore: sequenza che lo apre, sequenza sbagliata che non apre nulla, tocco singolo sul logo che apre ancora Informazioni.
  - I test esistenti di Profilo, Dashboard e `ux_redesign` restano verdi.

  Eseguire `flutter test test/plan/ui test/ads/ui test/dev/ui test/account test/cellar/ui` e ottenere verde.
- [x] **Step 18 — End-to-end** (`integration_test/freemium_test.dart`, sulla Firebase Emulator Suite).
  - Con il limite attivo via fixture: 15 schede, la sedicesima bloccata con la spiegazione, poi «Sblocca tutto» dal pannello sviluppatore e la sedicesima salvata e sincronizzata.
  - Plus in regalo scritto con lo script in modalità `--emulator`, che il Profilo mostra senza azioni dell'utente.
  - Aggiunta al job E2E esistente della CI.

### Strato 6 — Configurazione, build e documentazione

- [x] **Step 19 — Build e CI.**
  - `android/app/build.gradle.kts`: placeholder `admobAppId` con l'ID di test Google come default e quello reale da una proprietà o variabile `ADMOB_APP_ID`, più `<meta-data>` nel manifest.
  - `tool/check_release_build.sh`: marker `VINOOZY_DEV_CHEATS_PANEL` assente nell'AAB release, presente in una build `--profile` con `ENABLE_DEV_CHEATS=true` usata come controllo positivo; aggiornamento del controllo dei permessi del manifest (BILLING e AD_ID ammessi e attesi) (FR5.7).
  - `.github/workflows/ci.yml`: passi `npm ci --prefix functions`, `npm run test:functions` e il nuovo test delle regole; copertura all'80% invariata (NFR5).
  - Nessun deploy delle funzioni nei workflow.
- [x] **Step 20 — Documentazione.**
  - `docs/blaze-switch.md`, in italiano: procedura Spark → Blaze nell'ordine budget con avviso a 1 €, topic Pub/Sub del budget, permesso del service account per scollegare la fatturazione, criterio di pulizia di Artifact Registry (ultime 2 immagini), deploy delle funzioni in `europe-west8`, accensione di `purchasesEnabled` (FR9.1, FR9.3).
  - `docs/plus-setup.md`: prodotto e piani base in Play Console, collegamento della Play Developer API al service account, RTDN, App Check, uso di `tool/admin/grant_plus.mjs`.
  - Aggiornamento di `docs/privacy/` e della Data safety (diritti, acquisti, misurazione, annunci) e della pagina di eliminazione dell'account (NFR6).
- [x] **Step 21 — Verifica finale del passo.** Eseguire `dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test --coverage` (suite completa, con soglia dell'80% via `tool/check_coverage.sh`), `npm run test:rules` e `npm run test:functions`. Riportare in `code-summary.md` l'esito e i test non eseguiti con il motivo, per esempio l'E2E su emulatore Android se non disponibile in locale.

## Tracciabilità dei passi

| Requisito | Passi |
|---|---|
| FR1.1–FR1.5 | 3, 4, 6, 9, 10, 11, 15, 16, 17 |
| FR2.1–FR2.6 | 4, 5, 7, 9, 10, 11, 13, 16, 17, 18 |
| FR3.1–FR3.5 | 12, 14, 16, 17 |
| FR4.1–FR4.4 | 13, 14, 18 |
| FR5.1–FR5.7 | 10, 11, 16, 17, 18, 19 |
| FR6.1–FR6.5 | 3, 4, 8, 9, 10, 11, 12, 14 |
| FR7.1–FR7.6 | 10, 11, 12, 14, 16, 17 |
| FR8.1–FR8.2 | 16, 17 |
| FR9.1–FR9.3 | 1, 12, 14, 20 |
| NFR1 | 4, 5, 12, 14 |
| NFR2 | 2, 4, 5 |
| NFR3 | 10, 11 |
| NFR4 | 6, 7, 9 |
| NFR5 | 2, 5, 9, 11, 14, 17, 18, 19, 21 |
| NFR6 | 12, 14, 20 |
| NFR7 | 16, 21 |

## Rischi

- **Budget delle regole**: le regole dei vini sono vicine al limite di 1000 espressioni. Se il caso peggiore lo supera, la soluzione è spostare il controllo del limite in una funzione separata delle regole per la sola riattivazione. Il limite non va mai indebolito.
- **Concorrenza sul contatore**: due dispositivi che riattivano la stessa scheda insieme. Uno viene rifiutato e recuperato come previsto dalla FR2.5, e la migrazione ricalcola i contatori prima dell'accensione.
- **Plugin nativi**: `google_mobile_ads` e `in_app_purchase` aumentano la dimensione dell'app. Se `tool/check_app_size.sh` segnala il superamento, va riportato e non si alza la soglia.
