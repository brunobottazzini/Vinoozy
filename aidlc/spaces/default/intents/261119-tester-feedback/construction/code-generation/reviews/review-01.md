## Review

**Verdict:** READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** 2026-11-19
**Iteration:** 1
**Verdict Dictated:** no

Revisione advisory (un solo passaggio, a supporto della decisione al gate). Ho letto requisiti, piano, riepilogo, tracciabilità e il codice nuovo o modificato. Non ho rieseguito i test: i 5177 test e il 97,35% di copertura sono citati dal riepilogo, non verificati da me.

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | lib/settings/ui/settings_screen.dart:35-39 (`_showGuideAgain`) e lib/guide/ui/guide_tour.dart:62-90 (`_maybeStart`) | C-01. "Rivedi la guida" fa prima `await reset()` e solo dopo `popUntil(isFirst)`. `reset()` cambia subito lo stato in memoria, poi aspetta fino a 4 scritture su shared_preferences. `GuideTourStarter` si rimette in attesa sul primo frame e può far partire il giro mentre la schermata Impostazioni è ancora in cima. Il giro viene allora spinto sopra Impostazioni e subito dopo `popUntil` lo chiude: `finishTour()` lo segna come visto, quindi il giro non riparte (FR2.4, criterio "il giro riparte dal primo passo" non rispettato). Il test a riga 408 di settings_screen_test.dart usa un archivio finto sincrono, quindi non vede la corsa, e non verifica che il giro riparta. | Fare il pop prima del reset (o `reset()` senza await prima del pop), oppure far partire il giro solo se la route della Cantina è quella corrente (`ModalRoute.of(context)?.isCurrent`). Aggiungere un test con archivio lento che verifichi che dopo "Rivedi la guida" compaia `tour-step-addWine`. | New |
| R-02 | Minor | lib/guide/review_prompter.dart:36-38 | C-02. Il risultato di `markPrompted` è ignorato. Se la scrittura fallisce (ritorna false) la richiesta parte lo stesso e la data non è salvata: a ogni bevuta qualificante si richiederebbe di nuovo la finestra, contro NFR4 (max 1 ogni 120 giorni). Google Play limita comunque la finestra, ma l'app non dovrebbe contarci. | Chiedere la recensione solo se `markPrompted` ritorna true; aggiungere un test con archivio che rifiuta la scrittura. | New |
| R-03 | Minor | lib/settings/app_review.dart:65-75 (`openRatingPage`) | C-03. Per il tocco esplicito su "Valuta l'app" la finestra In-App Review non dà errore quando Google la sopprime per quota: `requestReview` ritorna, la funzione dà `true` e il ripiego sulla pagina del Play Store non scatta mai. La persona tocca e non vede nulla. Il riepilogo lo segnala già come rischio, ma è un difetto di FR5.1 su un percorso comune, non un caso raro. | Decisione del proprietario: per il pulsante usare direttamente `openStoreListing` / la pagina Play (più affidabile e consigliato da Google) e riservare In-App Review alla richiesta automatica; oppure lasciare com'è e accettare il rischio al gate. | New |
| R-04 | Minor | android/.../LinksChannelHandler.kt:22 e lib/app/store_links.dart (`supportEmail`) | C-04. L'indirizzo di supporto è in due posti senza un test che li confronti; il riepilogo lo ammette. Se divergono, il feedback parte a un indirizzo diverso da quello mostrato nel dialogo "Copia" (FR6.3). | Aggiungere un test Dart che legge `LinksChannelHandler.kt` e confronta la costante `SUPPORT_EMAIL` con `supportEmail`. | New |
| R-05 | Minor | lib/guide/ui/guide_tour.dart:73-76 | C-05. Con cache vuota e senza rete la decisione "utente nuovo o esistente" viene rimandata finché non arriva il server. Un utente nuovo che apre l'app la prima volta offline non vede il giro fino al ritorno della rete. È coerente con R-02 (evita di trattare un utente esistente come nuovo) ma non è dichiarato come limite in FR2.5. | Documentare il limite nel riepilogo, oppure accettarlo esplicitamente al gate. | New |
| R-06 | Minor | lib/guide/review_prompter.dart:21-24 e lib/guide/review_prompt_policy.dart:41-55 | C-06. Le condizioni sul voto e sul numero di vini sono scritte due volte (controlli rapidi nel prompter e `shouldAutoPrompt`). Oggi coincidono, ma una modifica futura a una sola copia cambia la regola in modo silenzioso. | Far chiamare a `maybeAskForReview` solo `shouldAutoPrompt` dopo aver letto le date, oppure esporre un helper unico per i controlli rapidi. | New |

### Verifiche per area (senza finding)

- **Policy della recensione.** `shouldAutoPrompt` rispetta FR5.2: voto ≥4, ≥5 vini attivi, ≥7 giorni dal primo uso (confine incluso), ≥120 giorni dall'ultima richiesta (confine incluso), `firstUse` nullo = nessuna richiesta, spento in debug ed E2E (`autoReviewEnabledProvider`). La data è salvata prima della richiesta (vedi però C-02). Il conteggio usa `winesStreamProvider` già in memoria, filtrato su quantity > 0: nessuna lettura Firestore in più (NFR6). Il pulsante "Valuta l'app" non scrive `review.lastPrompt` (FR5.3).
- **Primo uso.** `ensureFirstUse` all'avvio è idempotente e non blocca (`unawaited`); una data malformata conta come mancante, quindi nessuna richiesta.
- **Macchina a stati del giro e dei suggerimenti.** Gli utenti esistenti (cantina con vini al primo avvio) hanno giro e suggerimenti segnati come visti; i suggerimenti compaiono solo con `tourSeen` e `!tourRunning`; l'E2E li disattiva; un archivio illeggibile conta come "visto" e non blocca. Il giro è una route trasparente, quindi il tasto Indietro lo chiude; il `finally` registra sempre la fine. Ripetibile solo con "Rivedi la guida" (ma vedi C-01).
- **Confini di piattaforma.** `LinksChannelHandler`: destinatario fisso lato Android, schemi limitati a `https` e `mailto:` verso un solo indirizzo, `ActivityNotFoundException` e `SecurityException` diventano `false`; lato Dart `PlatformException` e `MissingPluginException` sono catturate e segnalate. `InAppReviewLauncher` cattura gli errori di `isAvailable` e `requestReview`. Condivisione: errori segnalati e messaggio tradotto, l'annullamento non è un errore.
- **Privacy (NFR3, NFR7).** Nessun nuovo dato lascia il telefono: stato guida e date in shared_preferences, il feedback passa solo dall'app email della persona con i dati tecnici visibili e modificabili. Nessun nuovo permesso nel manifest riportato dal riepilogo.
- **Qualità dei test.** Test per requisito presenti (policy, store, giro, suggerimenti, impostazioni, FAQ, feedback, listing store 25 lingue, flusso bevuta). Nessun test vuoto o sempre verde individuato. `the thresholds are the ones of the requirements` fissa solo le costanti: poco valore ma non dannoso. Manca il test di riavvio del giro (C-01).
- **Verifiche non completate dal riepilogo.** Build di rilascio ed E2E su emulatore restano da fare in Build and Test; sono dichiarate e non bloccano questa revisione.

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| flutter test / flutter analyze / dart format | Non rieseguiti da me | Esiti del riepilogo: 5177 test passati, 97,35% di copertura, analisi pulita. Non verificati in questa revisione. |
| tool/check_release_build.sh | Non completata (segnalato dal riepilogo) | Problema d'ambiente locale; da rieseguire in Build and Test dopo `flutter clean`. |

### Summary

Il codice rispetta i requisiti e gestisce gli errori ai confini di piattaforma; la policy della recensione e la macchina a stati della guida sono corrette sui casi indicati. Il punto da pesare prima dell'approvazione è C-01 (corsa in "Rivedi la guida" che può far perdere il riavvio del giro); gli altri sono migliorie.

READY
