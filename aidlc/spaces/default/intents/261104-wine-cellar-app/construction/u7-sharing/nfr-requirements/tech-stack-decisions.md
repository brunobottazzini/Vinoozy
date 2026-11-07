# Tech Stack Decisions — u7-sharing

Fonti: `functional-spec.md`, `rules.md` e `frontend-components.md` di U7; `contract-summary.md` (C3, C4); `team.md` (Testing Posture, Deployment, Code Style); strumenti esistenti (`package.json`, `test/rules/`, `pubspec.yaml`); riepilogo confermato in `nfr-requirements-questions.md`.

| Area | Scelta | Motivo | Alternative scartate |
|------|--------|--------|----------------------|
| Posizione | `lib/sharing/`: `domain/` (modelli `Membership`, `AccessibleCellar`, validazione dell'invito, errori di C4), `data/` (`SharingRepository` su Firestore con `WriteBatch`), `sharing_providers.dart` (`myMembershipsProvider`, `accessibleCellarsProvider`, `activeCellarProvider`), `ui/` | Stessa struttura di `lib/cellar/` e `lib/dashboard/`; logica testabile senza Flutter | Logica nei widget |
| Backend | Solo Firestore con regole di sicurezza; nessuna Cloud Function | Budget di 0 € e piano senza funzioni (NFR5) | Funzioni per inviti ed email (richiedono il piano a pagamento e un servizio di posta, Q1) |
| Limite di 5 | Contatore `memberSlots` nella cantina con `getAfter` nelle regole | Le regole non contano i documenti | Query nelle regole (non possibile); limite solo nell'app (non sicuro) |
| Ricerca degli inviti | Query sul gruppo di collezioni `members` con `inviteeEmail ==` email in minuscolo; indice su un campo con scopo gruppo di collezioni in `firestore.indexes.json` | Funziona senza funzioni nel cloud; una sola query per utente | Documento indice `invites/{email}` scritto dal proprietario (dati duplicati da tenere allineati) |
| Condivisione dell'invito | Pacchetto `share_plus`, versione fissata nel `pubspec.lock`, la più recente stabile al momento della generazione del codice | Pacchetto della community Flutter (Flutter Community Plus), usato da milioni di app; apre la condivisione di sistema senza permessi | `Intent` Android scritto a mano (codice nativo da mantenere) |
| Rete | `connectivity_plus` già presente; si aggiunge uno stream `onChanged` a `NetworkStatus` | Nessuna nuova dipendenza | — |
| Stato | Riverpod, già usato | Coerenza con U1 e U5 | — |
| Cantina scelta | `shared_preferences`, già usato, con chiave per utente | Nessuna nuova dipendenza; si cancella nel reset | — |
| Test delle regole | `@firebase/rules-unit-testing` 6.0.0 e `firebase-tools` già fissati in `package.json`; nuovo file `test/rules/u7.rules.test.mjs`, aggiunto allo script `test:rules` e quindi al job `rules` della CI. In `test/rules/helpers.mjs`, `googleUser()` aggiunge `email_verified: true` al token, e un nuovo `unverifiedGoogleUser()` lo imposta a `false` (NFR4.4) | Strumenti già in uso per U1 | — |
| Collegamento alla CI | Lo script `test:rules` di `package.json` elenca i file a mano: va aggiunto `u7.rules.test.mjs`. Il job `rules` di `ci.yml` va esteso con `tool/check_firestore_indexes.sh` (nuovo, da scrivere nella generazione del codice). Senza queste due modifiche i test di U7 non girano in CI | I file non sono raccolti in automatico | — |
| Proprietario nel test end-to-end | Nuovo helper in `integration_test/e2e_helpers.dart` che ottiene il token di `userA` dall'emulatore di Auth (REST `signInWithIdp` con un token fittizio) e lo usa come `Authorization: Bearer` verso l'emulatore di Firestore. Oggi c'è solo il token amministratore (`Bearer owner`), che salta le regole | Le azioni del proprietario devono passare dalle regole vere (NFR2.3) | Token amministratore |
| Indice | `firestore.indexes.json` con il `fieldOverride` su `members.inviteeEmail`, ambito `COLLECTION_GROUP`. L'emulatore non richiede indici, quindi uno script `tool/check_firestore_indexes.sh` nel job `rules` verifica che il campo ci sia | Senza l'indice la query degli inviti fallisce solo in produzione | Affidarsi alla console Firebase (non è versionato) |
| Test end-to-end | `integration_test/` sull'emulatore Android con la Firebase Emulator Suite e due identità finte (`userA`, `userB`, già presenti in `e2e_helpers.dart`) | Regole del team | — |

## Stima delle letture (NFR5.3)

Corretta il 2026-11-06 dopo la prima revisione. Firestore rilegge solo i documenti cambiati quando un ascolto si riapre **entro circa 30 minuti** dalla chiusura. Oltre quel tempo riapre l'intera query, e ogni documento restituito conta come una lettura, anche se è già nella cache. Il selettore chiude gli ascolti delle cantine non attive (NFR5.1), quindi ogni apertura a ore di distanza legge di nuovo tutti i vini.

Ipotesi prudenti per un giorno e per persona:
- 3 aperture dell'app, a ore di distanza;
- cantina di 500 vini;
- 20 modifiche.

| Voce | Letture al giorno |
|---|---|
| Riapertura dell'ascolto dei vini (3 × 500) | 1.500 |
| Ascolto dei propri inviti (3 × fino a 6 documenti) | ≤ 18 |
| Documento della cantina (3 × 1) | 3 |
| Controlli delle regole all'apertura degli ascolti (3 × 2) | 6 |
| 20 modifiche (2 letture delle regole ciascuna) | 40 |
| Aggiornamenti in tempo reale mentre l'app è aperta (modifiche di altre persone, stima 50) | ≤ 50 |
| **Totale per persona** | **≈ 1.620, sotto la soglia di 2.000** |

**Per cantina condivisa** (limite portato da 5 a 2 persone invitate il 2026-11-06): il proprietario più 2 persone attive con lo stesso uso fanno circa 3 × 1.620 ≈ 4.900 letture al giorno sulla cantina condivisa, sotto la soglia di 6.000.

**Per gruppo di persone:** ogni persona apre anche la **propria** cantina personale (costo di U1, stesso calcolo, circa 1.620 se piena). Un gruppo di 3 persone con cantine personali piene costa quindi circa 4.900 + 3 × 1.620 ≈ **9.700 letture al giorno**.

**Per progetto:** la quota gratuita di 50.000 letture al giorno è condivisa da tutti gli utenti. Circa **5 gruppi** così, pieni e usati in modo intenso, la esauriscono. Con l'uso previsto dal proprietario (aperture occasionali ai pasti, spesso la domenica) il consumo reale è una piccola frazione di questa stima. L'archivio dei vini finiti, deciso per U4, la riduce ancora. Per il lancio, con il proprietario e pochi amici, il margine c'è. Due protezioni:
- l'avviso al 70% (NFR5.3);
- il controllo mensile.

Se l'uso cresce, le opzioni sono due, da decidere allora con il proprietario:
- tenere aperto per 30 minuti l'ascolto della cantina appena lasciata;
- passare al pagamento a consumo, circa 0,06 $ ogni 100.000 letture.

Passare avanti e indietro tra le cantine nel selettore costa poco: un ascolto riaperto entro 30 minuti legge solo i documenti cambiati.

## Requisiti di qualità

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR7.1 | Copertura almeno 80% delle righe di `lib/sharing/` e del progetto, senza esclusioni. | `tool/check_coverage.sh 80 coverage/lcov.info lib/sharing/` nel job `unit`. |
| NFR7.2 | Ogni regola BR1.1–BR1.14 ha almeno un test con l'ID nel nome (logica, widget o regole cloud). | Ricerca degli ID nei nomi dei test durante la generazione del codice. |
| NFR7.3 | Test dei widget delle schermate nuove in it, en e pt-BR. | `flutter test`. |
| NFR7.4 | Test end-to-end con due utenti sugli emulatori: invito, comparsa della cantina, modifica con `edit`, revoca e sparizione. Il merge è bloccato se fallisce. | Job `e2e`. |
| NFR7.5 | I test esistenti di U1, U3 e U5 restano verdi dopo le modifiche di integrazione (cantina attiva, `OfflineBanner`, `SyncErrorBus`). | Suite completa nel job `unit` e nel job `e2e`. |
