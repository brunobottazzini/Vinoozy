# Base dei test prima delle modifiche (Step 2)

Eseguita il 2026-11-10, prima di qualsiasi modifica al codice di questo lavoro, sull'albero di lavoro del proprietario così com'era (con le sue modifiche non ancora committate).

| Comando | Test | Passati | Falliti | Saltati |
|---|---|---|---|---|
| `flutter test` (suite completa) | 2645 | 2645 | 0 | 0 |
| `npm run test:rules` (u1, u7, u4, u8, label_autofill, compat) | 217 | 215 | 0 | 2 |
| `style_profiles.rules.test.mjs` da solo, nell'emulatore (oggi fuori da `test:rules`) | 30 | 30 | 0 | 0 |

Comandi aggiornati nello Step 2 (`package.json`):

- `test:rules` ora esegue anche `style_profiles.rules.test.mjs` (NFR2) e il nuovo `freemium.rules.test.mjs` (Step 5).
- Nuovo `test:functions`: `firebase emulators:exec --only firestore,auth,functions --project demo-vinoozy "npm --prefix functions test"`. Diventa eseguibile quando lo Step 12/14 aggiunge le funzioni, i test e `npm ci --prefix functions`.
- Comando dei test di dominio di questo lavoro: `flutter test test/plan test/usage` (eseguibile dallo Step 3).

## Esito dopo gli Step 1–5 (strati 0 e 1)

| Comando | Test | Passati | Falliti | Saltati |
|---|---|---|---|---|
| `flutter test` (suite completa) | 2677 | 2677 | 0 | 0 |
| `npm run test:rules` (ora con `style_profiles` e `freemium`) | 284 | 282 | 0 | 2 |
| `freemium.rules.test.mjs` da solo | 37 | 37 | 0 | 0 |
| `npm run test:web` (controllo aggiuntivo, senza base) | 16 | 15 | 1 | 0 |

- I 32 test Flutter in più sono quelli di dominio dello Step 3 (`test/plan/domain`, `test/usage/domain`, `test/cellar/domain/cellar_capacity_fields_test.dart`).
- Il test web che fallisce («BR1.11 with the placeholder configuration…») controlla la pagina con la configurazione segnaposto. Fallisce perché `docs/account-deletion/firebase-config.js`, modificato dal proprietario e non ancora committato, non è più il segnaposto. Non dipende dalle regole né da questo lavoro.

## Esito dopo gli Step 6–11 (strati 2 e 3)

| Comando | Test | Passati | Falliti | Saltati |
|---|---|---|---|---|
| `flutter test` (suite completa) | 2789 | 2789 | 0 | 0 |
| `flutter test test/plan/data test/usage test/cellar/data/active_counter_test.dart` (Step 9) | 63 | 63 | 0 | 0 |
| `flutter test test/plan test/usage test/ads test/dev` (Step 11) | 120 | 120 | 0 | 0 |
| `npm run test:rules` (dopo la deviazione qui sotto) | 287 | 285 | 0 | 2 |
| `flutter analyze` | — | nessun problema | — | — |
| `dart format --set-exit-if-changed lib test` | — | 0 file cambiati | — | — |

- I 112 test Flutter in più sono quelli degli strati 2 e 3 di questo lavoro più 1 test U1 nuovo (contatore sull'ultima bottiglia).
- Alcuni test esistenti sono stati aggiornati perché ora il batch contiene anche il contatore della cantina: `test/u1/data/wine_repository_test.dart` (create e incrementQuantity passano da `set`/`update` diretti a un batch), `test/cellar/data/wine_repository_test.dart` (cancellazione e unione), `test/cellar/data/wine_repository_level_test.dart` e `test/cellar/data/wine_repository_style_test.dart` (il vino si cerca per percorso). Nessuna asserzione è stata indebolita: ogni test controlla anche l'operazione del contatore.

## Esito dopo gli Step 12–14 (strato 4, backend e script)

| Comando | Test | Passati | Falliti | Saltati |
|---|---|---|---|---|
| `npm --prefix functions run build` (tsc, `strict`) | — | nessun errore | — | — |
| `npm run test:functions` (mocha nell'emulatore Firestore, Auth e Functions) | 69 | 69 | 0 | 0 |
| `firebase emulators:exec --only firestore,auth --project demo-vinoozy "node --test test/admin/grant_plus.test.mjs"` | 8 | 8 | 0 | 0 |
| `npm run test:admin` (tutti i test degli script) | 13 | 13 | 0 | 0 |

- Tutto gira solo sulla Firebase Emulator Suite `demo-vinoozy`, con Play e Billing finti. Nessun deploy e nessuna chiamata a progetti reali.
- `npm install` segnala vulnerabilità di livello moderato nelle dipendenze transitive (30 in `functions/`, 8 in `tool/admin/`). Non ho eseguito `npm audit fix`, perché cambierebbe versioni non previste dal piano: da valutare in Build and Test.

## Esito dopo gli Step 15–17 (strato 5, interfaccia)

| Comando | Test | Passati | Falliti | Saltati |
|---|---|---|---|---|
| `flutter test` (suite completa) | 2877 | 2874 | 0 | 3 |
| `flutter test test/plan/ui test/ads/ui test/dev/ui test/account test/cellar/ui` (Step 17) | 819 | 816 | 0 | 3 |
| `flutter test --dart-define=ENABLE_DEV_CHEATS=true test/dev/ui` (sequenza segreta) | 12 | 12 | 0 | 0 |
| `flutter analyze` | — | nessun problema | — | — |
| `dart format --set-exit-if-changed lib test` | — | 0 file cambiati | — | — |

- Gli 85 test Flutter in più: sessione del piano e hook del reset (7), contratti delle callable (7), `PERIOD_CLOSED` e motivi di rifiuto nell'uploader (3), riga del piano nel Profilo e schermata Plus (28), limite di capacità, motivo della bozza rifiutata e avvisi della Dashboard (23), slot annunci (8), pannello sviluppatore, piè di pagina e sequenza (12, di cui 3 solo con il flag).
- I 3 test saltati sono quelli della sequenza segreta nella `HomeShell`: esistono solo quando `kDevCheatsAvailable` è vero, quindi si eseguono con `--dart-define=ENABLE_DEV_CHEATS=true` (riga dedicata qui sopra, tutti verdi).
- Nessun test esistente di Profilo, Dashboard, `ux_redesign`, HomeShell o account è stato modificato.

## Deviazioni

- **Segnale «cantina non ancora migrata» nelle regole (decisione del conductor, Step 4).** In `firestore.rules`, `uncountedWriteAllowed()` non guarda più l'assenza di `activeWineCount` ma l'assenza di `legacyActiveWineLimit` nella cantina del proprietario, cioè il campo che scrive solo la migrazione amministrativa (FR2.3). Motivo: la nuova app scrive `activeWineCount` già prima della migrazione; con la regola precedente, in una cantina condivisa con un membro che usa ancora la versione pubblicata, le scritture di quel membro sarebbero state rifiutate appena il proprietario aggiornava l'app (FR2.6). Ora:
  - prima della migrazione, con il limite spento, una scrittura che cambia lo stato attivo è accettata con o senza contatore; se il contatore c'è, il delta deve essere comunque giusto (lo verifica la regola della cantina);
  - dopo la migrazione (`legacyActiveWineLimit` presente) il contatore è obbligatorio e verificato, anche con il limite spento;
  - il limite resta applicato solo con `config/policy.capacityLimitEnabled == true`, e con il limite acceso la scrittura senza contatore resta rifiutata come prima.
  - Test aggiunti in `test/rules/freemium.rules.test.mjs`: scrittura della versione pubblicata accettata in una cantina mista non migrata dopo che la nuova app ha già scritto `activeWineCount`; contatore inviato con delta sbagliato rifiutato anche prima della migrazione; scrittura senza contatore rifiutata dopo la migrazione anche con il limite spento. Il helper `counted()` dei test esistenti ora rappresenta una cantina migrata (`legacyActiveWineLimit: 15`), così i casi che si aspettano il contatore obbligatorio restano gli stessi.
- **`incrementQuantity` (API dati di U1, senza schermata e senza chiamanti nell'app)** ha un nuovo parametro obbligatorio `storedQuantity`: senza la quantità nota non si può sapere se l'incremento cambia lo stato attivo. Aggiornati i soli test U1 che la usano.
- **Unione di due schede quando la più vecchia è finita e la più nuova è attiva.** Le regole accoppiano il contatore a un solo vino per batch, e qui cambiano stato tutte e due (+1 e −1). L'unione allora avviene in due batch: prima le bottiglie passano alla scheda vecchia (+1), poi, solo dopo la conferma del server, la scheda nuova viene cancellata (−1). Se il primo batch viene rifiutato non si perde nessuna bottiglia: resta al massimo il doppione. Limite noto: con il limite acceso e 15 schede su 15, il primo batch porta temporaneamente a 16 e viene rifiutato anche se il saldo finale sarebbe 15. Nei casi comuni (scheda vecchia attiva, o nuova finita) l'unione resta un solo batch.
- **Uscite dal filtro e cancellazioni nel misuratore.** Nello snapshot di un listener una cancellazione e l'uscita dal filtro `quantity > 0` sono entrambe `removed` e non si distinguono. Le conto entrambe come una lettura senza byte (lo studio §7.5 chiede di contare le uscite dal filtro). Sovrastima al massimo una lettura per vino cancellato.
- **Motivo del rifiuto dopo un riavvio.** Il motivo `capacityLimit`/`capacityConflict` arriva dalla callback della scrittura. Se l'app viene chiusa mentre la scrittura è ancora in coda offline, al riavvio `SyncWatcher` trova la scheda mancante e la segna come rifiutata, ma senza motivo (testo generico). Per le riattivazioni rifiutate (non creazioni) la spiegazione arriva come evento `WriteRejected` con motivo, non come voce del registro: il registro esistente traccia solo le creazioni e il dato non viene mai mostrato come sincronizzato, perché Firestore annulla la scrittura rifiutata.
- **`test:functions` compila prima di avviare gli emulatori (Step 14).** L'emulatore Functions carica `functions/lib/` all'avvio. Con lo script dello Step 2, che compilava solo dentro `emulators:exec`, l'emulatore partiva senza codice. Ora lo script è `npm --prefix functions run build && firebase emulators:exec … "npm --prefix functions test"`. Ho aggiunto anche `test:admin`, che esegue tutti i `test/admin/*.test.mjs` (il comando delle istruzioni dei test ne esegue solo uno). Oltre a `grant_plus.test.mjs` c'è `policy_and_migration.test.mjs` per `set_policy.mjs` e `migrate_capacity.mjs`.
- **`onUserDeleted` è una funzione di 1ª generazione.** Le funzioni di 2ª generazione non hanno un trigger per l'eliminazione di un utente Auth. Uso `firebase-functions/v1` `auth.user().onDelete`, anch'essa in `europe-west8`.
- **Il token d'acquisto resta in `purchases/{sha256(token)}`.** La riconciliazione giornaliera e i tentativi ripetuti di conferma devono poter rileggere Play, quindi il token sta nella raccolta privata del server, come previsto dallo studio §5.5. Non compare mai in `entitlements`, nei contatori o nei log: nei log c'è solo un'etichetta di 12 caratteri dell'hash. Quando si elimina l'account, l'uid del record diventa `null` (conservazione minima per rimborsi e contestazioni) e lo stesso abbonamento si può ripristinare su un nuovo account.
- **Nuove raccolte riservate al server: `playEvents/{messageId}` (deduplicazione delle RTDN, cancellate dopo 90 giorni) e `billingEvents/{messageId}` (registro dello scollegamento della fatturazione).** Non hanno regole client, perché le regole negano già ogni percorso che non corrisponde a un `match`.
- **RTDN per un token mai verificato.** Una notifica su un token che l'app non ha ancora inviato a `verifyPurchase` viene registrata come `ignored-unknown-token`: senza `obfuscatedAccountId` il server non sa a quale account appartiene. Il diritto nasce quando l'app chiama `verifyPurchase`, anche con «Ripristina acquisti».
- **Guardia sul diritto.** Uno stato Play che non dà Plus (scaduto, sospeso, revocato) non sostituisce mai un diritto ancora valido scritto da un altro token o da un regalo. Così la scadenza di un vecchio abbonamento non toglie Plus a uno nuovo. Un acquisto pagato sostituisce invece un regalo.
- **Riconciliazione sui record d'acquisto.** Il job giornaliero non rilegge `entitlements` ma i `purchases` con `reconcile == true`, cioè quelli ancora in uno stato che può cambiare (attivo, grace, hold, pausa, in attesa). Lì c'è il token e serve solo l'indice automatico su un campo.
- **Frequenza in `reportUsage`.** Una nuova sequenza che arriva meno di 10 s dopo l'ultima accettata dello stesso dispositivo viene rifiutata con `TOO_FREQUENT` e non viene sommata. Lo studio §7.6 chiede di verificare anche la frequenza, e la cadenza dell'app (15 minuti, fine sessione, primo superamento) resta ben sopra questa soglia.
- **Registro degli esiti pubblicitari:** il callable si chiama `recordAdOutcome`. Il ricavo stimato è l'evento `revenue` dello stesso callable.
- **Dipendenza `cloud_functions` (Step 15, autorizzata dal conductor).** Aggiunta con `flutter pub add cloud_functions` (`^7.0.1`): serve ai client delle callable `verifyPurchase`, `reportUsage`, `reserveAdSlot` e `recordAdOutcome` previsti dal piano. Il piano nominava solo `in_app_purchase` e `google_mobile_ads`. Nelle build demo i client usano l'emulatore Functions (`useFunctionsEmulator(emulatorHost, 5001)`), accanto a quelli di Auth e Firestore.
- **App Check nelle build demo (richiesta del conductor).** Le callable applicano App Check anche nell'emulatore, quindi `bootstrap.dart` ora attiva il provider di debug di App Check anche con gli emulatori, ma solo fuori dalla release. Prima App Check si attivava solo con il progetto reale. Rischio da verificare sul telefono: il provider di debug scambia il token con il servizio App Check di Google, e con il progetto `demo-vinoozy` lo scambio potrebbe non riuscire. In quel caso le callable rispondono `unauthenticated`, l'app non si blocca (l'attivazione fallita viene solo registrata nel log) e la verifica resta da fare nello Step 18.
- **`reportUsage` con `PERIOD_CLOSED` (richiesta del conductor).** `UsageReportResult` ha il campo `reason`. Con `PERIOD_CLOSED` l'uploader dimentica quel mese passato, nel misuratore e nel proprio stato, invece di ritentare con una nuova sequenza. Gli altri motivi (`STALE_SEQUENCE`, `SEQUENCE_CONFLICT`, `DECREASING_CUMULATIVE`, `TOO_FREQUENT`, `PERIOD_NOT_STARTED`) mantengono il comportamento di prima. Il mese corrente non viene mai scartato. Test in `test/usage/usage_uploader_test.dart`.
- **Client allineati a `functions/README.md`.** `verifyPurchase` legge `state`/`plusActive` e decide gli errori in base a `details.reason` (`TOKEN_IN_USE` → account diverso). Non invia `basePlanId`, perché il backend lo legge da Play. `reserveAdSlot` si chiama con `{}` e restituisce `reservationId` e `day`. `recordAdOutcome` invia `reservationId`, `day` ed `event`; per il ricavo aggiunge `valueMicros` come intero e `precision` nel formato del backend (`publisher_provided`).
- **I contatori d'uso restano sul telefono dopo il logout (Step 15).** Il piano chiede di pulire i contatori locali sia al logout sia al cambio di account. Al logout invece li conservo, legati all'uid, e li invio alla sessione successiva dello stesso account. Il motivo: un cumulativo azzerato verrebbe rifiutato da `reportUsage` come `DECREASING_CUMULATIVE`, e le sequenze ripartite da 1 come `STALE_SEQUENCE`, fino alla fine del mese. Al logout si cancellano l'override sviluppatore e la copia del diritto. Al cambio di account e all'eliminazione dell'account, tramite `ResetCoordinator`, si cancellano anche i contatori e lo stato dell'upload dell'account precedente. Il logout passa dallo stato dell'`AccountGate` (`GateSignIn` senza avviso dopo una sessione) e non dal `ResetCoordinator`, perché oggi il logout non esegue un reset.
- **Base plan nel client di Billing.** `in_app_purchase` non esporta il tipo Android che contiene il `basePlanId`, e il piano non prevede `in_app_purchase_android` come dipendenza diretta. `InAppPurchaseBillingClient` lo legge quindi in modo dinamico, con un ripiego sicuro. Se Play non lo fornisce, il pulsante mostra solo il prezzo dello store, senza «al mese» o «all'anno».
- **Sequenza segreta testata con il flag.** Il codice della sequenza e del pannello è raggiungibile solo dentro `if (kDevCheatsAvailable)`, una costante, così la release lo elimina (FR5.7). Per questo i 3 test della sequenza nella `HomeShell` si eseguono solo con `--dart-define=ENABLE_DEV_CHEATS=true` e la suite normale li salta. Lo Step 19 dovrebbe aggiungere in CI il comando dedicato.
- **Spiegazione della soglia solo con gli annunci accesi.** La spiegazione della FR7.5 compare solo quando l'utente è davvero idoneo agli annunci: `adsEnabled`, stato verificato, niente Plus e soglia superata. Con gli annunci spenti, dire «potresti vedere annunci» non sarebbe vero. Una volta mostrata viene registrata subito come vista per quel mese, e resta sullo schermo finché non si chiude.

Note:

- I 2 test saltati di `test:rules` sono saltati per scelta del test stesso (per esempio il confronto con le regole dell'ultimo tag `v*`, che salta quando non può confrontare), non per errori.
- `flutter test` stampa avvisi di `tap()` fuori bersaglio in `test/cellar/ui/add_wine_screen_test.dart`: sono avvisi, non fallimenti, e c'erano già.
- Durante l'esecuzione di `firebase-tools` compare l'avviso che Java < 21 non sarà più supportato da `firebase-tools@15`: non blocca nulla oggi.
