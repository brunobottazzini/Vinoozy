# Handoff pubblicazione Google Play — Vinoozy 0.2.1 (3)

Stato all'11 novembre 2026. Il test chiuso Alpha è pubblicato e Vinoozy è stata inviata a **Testers Community**, lo stesso servizio usato per Trasloco, con il piano Starter scelto e pagato dal proprietario. I tester useranno i propri account Google; la password dell'account riservato ai revisori resta soltanto in Play Console.

## Aggiornamento configurazione — 11 novembre 2026

Verifica effettuata nella Play Console reale:

- **Configurazione iniziale completata.** La Dashboard non mostra più il blocco «Completa la configurazione dell'app». In Contenuti app, «Attenzione richiesta» mostra: **«Non hai niente in sospeso»**.
- Scheda già presente in it-IT, en-US e pt-BR, con testi, icona, feature graphic e quattro screenshot per lingua. Categoria **Cibi e bevande** ed email di supporto corrette.
- Annunci: **no**. ID pubblicità: **no**. IARC già completato: **PEGI 16** in Europa, **17+ ESRB** in Nord America, 14 anni in Brasile. Queste classificazioni sono distinte dal pubblico di destinazione.
- Norme sulla privacy, salute, funzionalità finanziarie e app governative risultano tra le dichiarazioni con azione completata.
- **Dettagli di accesso salvati**: account Google dedicato creato; accesso a Vinoozy e salvataggio di un vino fittizio confermati dal proprietario sul telefono. Nome della voce: «Vinoozy — Google review account». Email, password e istruzioni sono presenti in Console; la password resta fuori dal repository e dalla chat.
- **Pubblico di destinazione salvato: solo 18 o più**, con l'opzione per bloccare l'accesso agli utenti identificati da Google come minorenni attivata.
- **Sicurezza dei dati salvata definitivamente e inviata per la revisione**: comprende la cronologia delle ricerche in-app per Open Food Facts, raccolta e condivisa, facoltativa, per funzionalità dell'app. `distribution/google-play/data-safety.csv` è allineato. L'anteprima mostra i dati condivisi, gli 11 tipi raccolti, la crittografia in transito e il link di cancellazione.
- Canale di test interno ricaricato e verificato: ultima release **3 (0.2.1)**.
- **Release di test chiuso Alpha approvata e pubblicata:** `3 (0.2.1)`, riutilizzando l'app bundle già caricato, con note it-IT/en-US/pt-BR. Il canale risulta «Attivo» e la release «Disponibile per tester selezionati», con pubblicazione indicata l'11 novembre alle 10:40. Dimensioni indicate nell'anteprima: 23 MB per una nuova installazione. Verificata anche la scheda sul Play Store con quattro screenshot nell'account del proprietario.
- **Test chiuso in tutti i 178 paesi/regioni disponibili**, come richiesto dal proprietario. Contatto per i feedback: `bottazzinibruno@gmail.com`.
- **Tester configurati tramite Google Gruppi:** `testers-community@googlegroups.com`, ricavato dalla guida del servizio e salvato in Play Console. Il modulo per la mailing list individuale è stato chiuso senza crearla; non serve per questo servizio.
- **17 modifiche inviate dopo l'approvazione esplicita del proprietario**, incluse release, gruppo, paesi, schede e dichiarazioni. La successiva verifica del canale Alpha conferma la pubblicazione della release. Pubblicazione gestita disattivata.
- **Vinoozy inviata a Testers Community con Starter**, dopo il pagamento di €14 effettuato dal proprietario e la sua richiesta di completare l'invio. Il riepilogo mostrava **1 credito Starter, 15 tester**; conferma finale **«App Submitted Successfully!»**, un credito consumato e saldo residuo zero. Caricati link di adesione, icona ufficiale e istruzioni inglesi da `distribution/google-play/beta-tester-instructions.txt`. La pagina dell'app mostra **«In Progress»**, piano **Starter**, **0/16 giorni**, **0/15 tester**, **0/2 report**, invio l'11 novembre 2026 e avvio previsto tra circa **6 ore** al momento della verifica. Non sono stati acquistati altri crediti o componenti aggiuntivi.

**Alla ripresa:** controllare adesioni, progressi e report nella [Dashboard di Testers Community](https://testerscommunity.com/dashboard) e i requisiti di accesso alla produzione nella Play Console. L'invio al servizio è completato: non ripeterlo e non acquistare altri crediti. Il servizio mostra un percorso di 16 giorni; il requisito Google dei 14 giorni consecutivi dipende dalle adesioni dei tester, non dall'acquisto o dall'invio alla revisione. Raccogliere feedback e correzioni prima della richiesta di accesso alla produzione. La scheda Chrome di Testers Community è sulla pagina di Vinoozy.

## 1. Cosa è fatto

| Area | Stato |
|---|---|
| Build | `0.2.1 (3)` firmata con la chiave di caricamento, sul **test interno**. Installata sul telefono del proprietario: parte, nessun crash. Il crash all'avvio della 0.2.0 (R8 e WorkManager) è corretto, e ora `tool/check_release_launch.sh` avvia in CI una build release ridotta da R8. |
| Codice | Tutto su `main` e su GitHub, ultimo commit `c777f03`. |
| CI | Il controllo dei segreti risultava verde nell'handoff iniziale. L'esito della CI completa di `c777f03` resta da ricontrollare: la consultazione effettuata durante questa sessione non ha restituito lo stato dei workflow su `main`. |
| Freemium e Plus | Il codice c'è, ma è **tutto spento** in `config/policy`: acquisti, limite di 15 vini e pubblicità. Nessun utente ha limiti. Il Profilo mostra «Gratuito» e «Plus arriverà presto». |
| Pubblicità | Il modulo AdMob è nell'app ma non parte (`adsEnabled` è `false`). Il permesso AD_ID è **tolto** dal manifest, e `tool/check_release_build.sh` lo controlla. |
| Firebase | Regole e indici Firestore pubblicati il 10/11. Il progetto è ancora sul piano gratuito Spark e le Cloud Functions non sono pubblicate. |
| Pagine pubbliche | Online e verificate (HTTP 200): informativa privacy `https://brunobottazzini.github.io/Vinoozy/privacy/` e cancellazione dell'account `https://brunobottazzini.github.io/Vinoozy/account-deletion/`. |
| Scheda dello store | Testi it/en/pt-BR in `distribution/google-play/{it-IT,en-US,pt-BR}/`, icona 512, feature graphic, 4 catture per lingua in `distribution/google-play/assets/`. |
| Note di rilascio | `distribution/google-play/release-notes.txt` (it, en, pt-BR). |
| Test chiuso | Alpha `3 (0.2.1)` approvata e pubblicata l'11 novembre, disponibile per tester selezionati in 178 paesi/regioni, note in tre lingue, gruppo Testers Community e feedback via email configurati. |
| Servizio beta tester | Testers Community Starter, 15 tester, €14 pagati dal proprietario. Invio completato, credito consumato, saldo zero. Stato «In Progress», 0/16 giorni e 0/15 tester; avvio indicato tra circa 6 ore al momento della verifica. |
| Sicurezza dei dati | Inviata per la revisione Google, inclusa la ricerca verso Open Food Facts; CSV allineato in `distribution/google-play/data-safety.csv`. |
| Accesso e istruzioni per i revisori | Voce salvata in Console con account dedicato, password inserita dal proprietario e istruzioni inglesi da `distribution/google-play/reviewer-instructions.txt`. Accesso e salvataggio nell'app confermati dal proprietario. |
| Plus da remoto | `node tool/admin/grant_plus.mjs grant --email <email> --no-expiry --reason owner_test --project vinoozy-d6f45 --firebase-login`. Usa il tuo login della Firebase CLI e non richiede chiavi. Non è ancora stato provato sul progetto reale: lancialo tu. |

## 2. Cosa configurare in Play Console

App: **Vinoozy: la tua cantina**, package `com.vinoozy.app`.

### 2.1 Scheda dello store principale (Crescita → Presenza nello store)

- [x] Nome, descrizione breve ed estesa presenti in it-IT, en-US e pt-BR; fonti in `distribution/google-play/<lingua>/`.
- [x] Icona: `assets/icon-512.png`. Feature graphic: `assets/feature-graphic-it-IT-v1.jpg`.
- [x] Quattro screenshot del telefono per ciascuna lingua, da `assets/screenshots/{it,en,pt-BR}/`.
- [x] Categoria **Cibi e bevande**. Email di contatto `bottazzinibruno@gmail.com`.

### 2.2 Contenuti dell'app (Norme → Contenuti dell'app)

- [x] **Norme sulla privacy**: `https://brunobottazzini.github.io/Vinoozy/privacy/`
- [x] **Accesso all'app**: «Sì» alla domanda sulle limitazioni. Salvata la voce «Vinoozy — Google review account», con account Google dedicato e password inserita dal proprietario soltanto in Console. Istruzioni inglesi di 425 caratteri da `reviewer-instructions.txt`; accesso e salvataggio di un vino fittizio nell'app confermati dal proprietario.
- [x] **Annunci**: «No, la mia app non contiene annunci».
- [x] **Classificazione dei contenuti**: IARC completato il 9 novembre; classificazioni verificate in Console: PEGI 16 in Europa e 17+ ESRB in Nord America.
- [x] **Pubblico di destinazione**: solo **18 anni e oltre**, con blocco degli utenti identificati da Google come minorenni attivato.
- [x] **Sicurezza dei dati**: riepilogo controllato, dichiarazione salvata definitivamente e inviata per la revisione Google. Per una nuova importazione usare `distribution/google-play/data-safety.csv`. Il CSV dichiara come **raccolti e non condivisi**:
  - nome, email e ID utente (login Google);
  - foto: è la foto del profilo Google, non le etichette, che restano sul telefono;
  - contatti: le email delle persone invitate;
  - contenuti generati dall'utente: cantina, bevute, note;
  - interazioni con l'app;
  - log degli arresti anomali e dati diagnostici (Crashlytics);
  - ID dispositivo.
- [x] **Open Food Facts — risposta salvata.** Testo cercato, parole dell'etichetta e codici a barre vanno a Open Food Facts insieme all'IP. La voce «Attività nell'app → Cronologia delle ricerche in-app» è dichiarata **raccolta e condivisa**, facoltativa, per funzionalità dell'app. Il CSV contiene le stesse risposte. Per Google, «raccolta» comprende anche l'invio dal dispositivo direttamente a una terza parte, indipendentemente da chi conserva i dati. Si dichiara anche la condivisione per rendere esplicito il destinatario terzo; l'esenzione per le azioni avviate dall'utente resta descritta nella [guida ufficiale](https://support.google.com/googleplay/android-developer/answer/10787469?hl=it), consultata l'11 novembre 2026. Non è stata dichiarata la sola elaborazione temporanea, perché non è verificata per il servizio terzo.
  - **Crittografati in transito:** sì.
  - **Cancellazione:** sì, nell'app e all'URL `https://brunobottazzini.github.io/Vinoozy/account-deletion/`.
  - **Cronologia acquisti e ID pubblicità:** non dichiarare nulla per ora (acquisti e annunci sono spenti). Vanno aggiunti **prima** di accendere gli acquisti o la pubblicità (`docs/release-checklist.md` §2).
- [x] **ID pubblicità**: «No, l'app non usa l'ID pubblicità».
- [x] **App governative, funzionalità finanziarie e salute**: dichiarazioni già completate. La Console non presenta una dichiarazione per app di notizie da compilare.
- [x] **Autorizzazioni**: nessuna ulteriore dichiarazione richiesta nella panoramica Contenuti app al termine della configurazione. Il manifest non chiede fotocamera, galleria né rubrica: le foto arrivano dal selettore di sistema o dalla condivisione.

### 2.3 Paesi e prezzo

- [ ] **Paesi/regioni** della release di produzione: Italia al primo rilascio, come previsto. Aggiungine altri quando vuoi.
- [ ] **Prezzo**: gratuita. Ricorda che un'app pubblicata come gratuita non può più diventare a pagamento; Plus sarà un abbonamento in-app.

### 2.4 Test chiuso per l'accesso alla produzione

- [x] Canale **Alpha**: [gestione del canale](https://play.google.com/console/u/1/developers/7355456641864294998/app/4974010218208182861/tracks/4699198808214484790).
- [x] Release **3 (0.2.1)** preparata dalla raccolta degli app bundle e salvata, con note in tutte e tre le lingue. [Controllo della release](https://play.google.com/console/u/1/developers/7355456641864294998/app/4974010218208182861/tracks/4699198808214484790/releases/1/review).
- [x] Selezionati tutti i **178 paesi/regioni** disponibili per questo test e impostata l'email dei feedback.
- [x] Selezionato **Google Gruppi** nella [scheda Tester](https://play.google.com/console/u/1/developers/7355456641864294998/app/4974010218208182861/tracks/4699198808214484790?tab=testers) e salvato `testers-community@googlegroups.com`. Il proprietario ha chiesto di usare lo stesso fornitore di Trasloco; non serve una mailing list individuale.
- [x] Verificate e inviate **17 modifiche** dalla Panoramica della pubblicazione, dopo la conferma esplicita del proprietario. Il successivo controllo conferma la release Alpha pubblicata e disponibile per tester selezionati.
- [x] Verificata l'approvazione Google: canale Alpha «Attivo», release «Disponibile per tester selezionati». [Link di adesione al test chiuso](https://play.google.com/apps/testing/com.vinoozy.app) fornito al servizio. Scheda dello store visibile nell'account del proprietario.
- [x] Compilato e inviato il modulo [Submit App di Testers Community](https://testerscommunity.com/submit-app), con nome, link, `assets/icon-512.png`, piano **Starter** e testo da `distribution/google-play/beta-tester-instructions.txt`. Conferma «App Submitted Successfully!» e app presente nella Dashboard.
- [x] Il proprietario ha pagato **1 credito Starter (€14, 15 tester)** e autorizzato l'invio. Credito verificato e consumato per Vinoozy; saldo finale zero. I tester useranno il proprio account Google, con dati fittizi; nessuna password dei revisori è stata fornita al servizio.
- [ ] Verificare l'arrivo dei tester: stato iniziale «In Progress», 0/15 tester, 0/16 giorni e 0/2 report, con avvio previsto tra circa 6 ore al momento dell'invio. Non è ancora la conferma che i tester abbiano aderito.
- [ ] Ogni tester deve aderire con il proprio account Google autorizzato, installare l'app e provarla. Aggiungere le email all'elenco non equivale all'adesione. Per i criteri correnti servono almeno **12 tester attivi per 14 giorni consecutivi**, poi la richiesta di accesso alla produzione; mantenere un riepilogo dei feedback e delle correzioni. [Requisiti ufficiali verificati l'11 novembre 2026](https://support.google.com/googleplay/android-developer/answer/14151465?hl=it).

### 2.5 Release di produzione

- [ ] Account personale creato dopo novembre 2023: Google chiede un **test chiuso con almeno 12 tester per 14 giorni consecutivi** prima di dare accesso alla produzione. Lo gestisci tu: nella Dashboard compare «Richiedi l'accesso alla produzione» quando i requisiti sono soddisfatti.
- [ ] Quando hai l'accesso: Test interno → release `0.2.1 (3)` → **Promuovi release → Produzione**, oppure crea la release in Produzione scegliendo l'app bundle già caricato.
- [ ] Note di rilascio: da `distribution/google-play/release-notes.txt`.
- [ ] Prima release in produzione: va bene il 100%, perché non ci sono utenti da proteggere. Dagli aggiornamenti successivi usa il rilascio graduale (20%, poi 100%).
- [ ] Invia per la revisione (Panoramica pubblicazione → «Invia modifiche per la revisione»). Di solito la revisione richiede da qualche ora a qualche giorno.

### 2.6 Prima di approvare la produzione

- [ ] Smoke test sul telefono con la build dal test interno: avvio, login Google, aggiunta di un vino, sincronizzazione. L'11/11 sono stati verificati l'avvio della 0.2.1 e, dal proprietario, accesso e salvataggio con l'account dei revisori. Resta da verificare la sincronizzazione.
- [ ] Se una release cambia regole o indici di Firestore, prima esegui `firebase-deploy.yml` (`docs/release-checklist.md` §3). Per la 0.2.1 è già fatto.

## 3. Rimandato (non serve per la prima pubblicazione)

- Plus in vendita: passaggio a Blaze con le protezioni (`docs/blaze-switch.md`), pubblicazione delle funzioni, prodotto `vinoozy_plus` in Play Console, `purchasesEnabled`, aggiornamento della Sicurezza dei dati (`docs/plus-setup.md`).
- Limite di 15 vini: prima `migrate_capacity.mjs`, poi `capacityLimitEnabled`.
- Pubblicità: dopo circa 2 settimane di misure. Bisogna rimettere AD_ID, dichiarare annunci e ID pubblicità in Console, configurare il consenso UMP in AdMob e poi `adsEnabled`.
- `release.yml` e `promote.yml` non hanno i segreti GitHub (chiave di firma, account di servizio Play): per ora carichi e promuovi a mano. Per configurarli segui `docs/github-actions-setup.md`.
