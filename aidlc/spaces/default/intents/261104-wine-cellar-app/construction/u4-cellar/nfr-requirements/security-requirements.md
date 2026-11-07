# Security Requirements — u4-cellar

Fonti: `requirements.md` (NFR3, NFR4, NFR6, NFR8), `functional-spec.md` e `rules.md` di U4 (in particolare la sezione sulle regole cloud, BR1.10–BR1.15, BR1.19, BR1.20), `contract-summary.md` (aggiunte del 2026-11-06), regole di U1 e U7 (`firestore.rules`), riepilogo confermato in `nfr-requirements-questions.md`.

Il file raccoglie anche accessibilità (NFR3) e affidabilità (NFR6). Gli ID NFRx.y valgono solo per u4: in u7 numeri uguali indicano altri requisiti.

## Regole cloud (NFR4)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR4.1 | **Vini, campi nuovi.** `matchKey` (stringa ≤ 400); `window` e `baseWindow` con la stessa forma validata: mappa con le sole chiavi `startYear`, `peakYear`, `endYear` (interi 1900–2200, con inizio ≤ picco ≤ fine), `confidence` (`high`, `medium`, `low`), `source` (`catalog`, `internalRules`), `basis` (`catalog`, `denomination`, `wineType`, `generic`; obbligatoria nel modello, ma facoltativa nelle regole per i vini salvati prima, come prevede `EstimationBasis.resolveStoredBasis`) e `qualifier` facoltativa (`riserva`, `superiore` o `granSelezione`, come l'enum di C2). La validazione di `window` è nuova: oggi le regole non la controllano. `windowAdjustment` (`kind` tra tooYoung, justRight, pastPeak; `year` intero 1900–2200; `recordId` stringa ≤ 128) sono ammessi in creazione e aggiornamento con `canEditCellar`. Valori fuori forma vengono rifiutati. | Test delle regole sugli emulatori (`test/rules/u4.rules.test.mjs`) con valori validi e al limite. |
| NFR4.2 | **Backfill di `matchKey`.** Un update che cambia **solo** `matchKey` è permesso a chi ha `canEditCellar`, senza `updatedBy` e `updatedAt`. Qualunque altro campo nello stesso update lo fa rifiutare, se non rispetta la validazione completa di U1. | Test: solo `matchKey` → permesso; `matchKey` più `name` senza `updatedBy` → rifiutato. |
| NFR4.3 | **Bevute, aggiornamento.** Permesso con `canEditCellar` se `recordedBy == uid` o se l'utente è il proprietario. Cambiano solo `rating` (1–5 o assente), `notes` (≤ 1.000 o assente), `drankOn` (`YYYY-MM-DD`), `condition` (valori ammessi o assente) e `updatedAt == request.time`. `wineId`, `wineName`, `vintage`, `recordedBy` e `createdAt` sono immutabili. | Test: autore → permesso; proprietario → permesso; altra persona con `edit` → rifiutato; `read` → rifiutato; campo immutabile cambiato → rifiutato. |
| NFR4.4 | **Bevute, eliminazione.** Il proprietario sempre. L'autore solo se ha ancora `canEditCellar` **e** `request.time < createdAt + duration.value(10, 'm')`. | Test con `createdAt` impostato nel passato a regole disattivate (`withSecurityRulesDisabled`): 9 minuti → permesso; 11 minuti → rifiutato; autore passato a `read` → rifiutato; autore revocato → rifiutato. |
| NFR4.5 | **Bevute, creazione.** Si aggiungono `condition` e `updatedAt` facoltativi ai campi di U7; gli altri vincoli restano. | Test. |
| NFR4.6 | **Eliminazione di vini** solo dal proprietario, come in U7. | Test di U7 invariati e verdi. |
| NFR4.7 | **Non regressione:** `u1.rules.test.mjs`, `u7.rules.test.mjs` e `compat/` restano verdi. Le scritture nuove di U4 in `app-writes.json` portano `requiresRules: "cellar"` finché le regole non sono pubblicate, come per U7. | Job `rules`. |
| NFR4.8 | **Indice composto dello Storico** su `drinkingRecords` (`drankOn` desc, `createdAt` desc, ambito `COLLECTION`) in `firestore.indexes.json`, che oggi ha `"indexes": []`. `tool/check_firestore_indexes.sh` **si estende** per controllare anche questo indice. Il suo test aggiorna `ok.json` con l'indice dello Storico e aggiunge `missing_history.json`, che deve fallire. Ogni indice mancante ha un messaggio diverso, e il test controlla quale messaggio esce. Le query `where wineId == …` di BR1.12 e BR1.14 **non ordinano sul server**: l'app ordina in memoria, quindi basta l'indice automatico a campo singolo. | Job `rules` (script e test dello script). |
| NFR4.9 | **`cellars.matchKeyBackfill`.** Un update della cantina che cambia **solo** `matchKeyBackfill`, e solo da assente o `false` a `true`, è permesso al proprietario e a chi ha `canEditCellar`. Si aggiunge alle regole di update di U1 e U7 senza cambiarle. | Test: proprietario → permesso; `edit` → permesso; `read` → rifiutato; `true` → `false` → rifiutato; insieme a `name` da chi ha `edit` → rifiutato. Voce in `compat/app-writes.json` con `requiresRules: "cellar"`. |

## Privacy (NFR8)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR8.1 | Note e voti sono dati dell'utente, salvati solo in Firestore e visibili solo a chi vede la cantina, secondo le regole. | Test delle regole (lettura con `read`; nessuna lettura da estranei). |
| NFR8.2 | Gli errori di U4 passano da `ErrorReporter` con `reason` fissi (`cellar_save_failed`, `cellar_drink_failed`, `cellar_undo_failed`, `cellar_delete_failed`, `estimate_refresh_failed`). Nome del vino, note e produttore sono tra i valori sensibili tolti. | Test con valori marcatore: nessun marcatore arriva al `ErrorSink` finto. |
| NFR8.3 | La scheda "Sicurezza dei dati" include già i dati della cantina; si verifica che note e voti ci rientrino. | Voce nella checklist di rilascio. |

## Accessibilità (NFR3)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR3.1 | Stato sempre con icona e testo; fiducia e fonte lette come testo. | Test dei widget con `tester.getSemantics`. |
| NFR3.2 | Stelle del voto con etichetta ("Voto 4 su 5") e ruolo di pulsante selezionabile. | Test dei widget. |
| NFR3.3 | Il messaggio dopo una bevuta dura **6 s**, o **10 s** se il sistema chiede animazioni ridotte o è attivo un lettore schermo (`MediaQuery.accessibleNavigation`). | Test dei widget con le due impostazioni. |
| NFR3.4 | Aree di tocco ≥ 48×48 dp, contrasto del testo ≥ 4,5:1, testo al 200% senza tagli, nelle tre lingue. | Guideline nei test dei widget. |

## Affidabilità e offline (NFR6)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR6.1 | Inserimento, bevuta, annulla, voto, modifica, eliminazione e consultazione funzionano senza rete (FR9.1). | Test con il repository finto in modalità offline. In `integration_test/cellar_test.dart`, un caso offline con `FirebaseFirestore.instance.disableNetwork()`: aggiunta, bevuta e annulla senza rete, poi `enableNetwork()` e controllo sul server. |
| NFR6.2 | **Quantità:** solo `increment`; correzione dei valori negativi come in BR1.15; diminuzioni disattivate a valore mostrato 0. | Test del repository con valori salvati −2, 0 e 3. |
| NFR6.3 | **Due bevute offline** di persone diverse sullo stesso vino si sommano (AC9.2.1). | Test end-to-end `concurrent_drink_test.dart` sugli emulatori:<br>1. il proprietario crea il vino con quantità 4 via REST e invita la persona dell'app con `edit`;<br>2. l'app accede, attiva l'invito, sceglie la cantina condivisa e aspetta che il vino compaia, così è nella cache;<br>3. l'app va offline (`disableNetwork()`) e segna una bevuta, che resta in coda;<br>4. intanto il proprietario segna una bevuta via REST con `increment(-1)`;<br>5. l'app torna online.<br>Atteso: quantità 2 sul server. `OwnerRestClient` di `e2e_helpers.dart` aggiunge `createWine` e `recordDrink`, che scrivono con il token del proprietario usando `fieldTransforms.increment`. |
| NFR6.4 | **Stima:** un errore di `estimateWindow` o del catalogo non blocca il salvataggio; il vino risulta "da stimare" e si riprova (BR1.5, BR1.6). | Test con errori simulati. |
| NFR6.5 | **Annulla:** se la bevuta non esiste più, nessuna scrittura e messaggio "Non c'è più nulla da annullare". | Test. |
| NFR6.6 | **Recupero dopo la rete** (limite senza rete di BR1.12 e BR1.14): al ritorno della rete il riscontro si riapplica dal server e le bevute rimaste di un vino eliminato si cancellano. | Test con un repository finto che restituisce prima la cache e poi il server. |
