# Vinoozy — pubblicazione su Google Play

Verifica del **9 novembre 2026**, su `main`, commit `ee114e34ecdb2ec0dff873d20ad23d0004996947`. Documento complementare a `docs/release-checklist.md` e `docs/firebase-setup.md`. Studio economico: [vinoozy-studio-monetizzazione.md](vinoozy-studio-monetizzazione.md).

## Esito e metodo

**La pubblicazione non è ancora pronta.** Esistono codice, test e workflow sostanziali, ma sono presenti blocchi di configurazione, CI e trasparenza privacy. Questo lavoro prepara i documenti e verifica lo stato: non pubblica app, pagine, regole o nuovi prezzi e non modifica il codice applicativo.

Le etichette usate sono: **verificato nel progetto** (file o comando esaminato), **verificato online** (fonte primaria o API GitHub), **da verificare in console** (stato non accessibile), **ipotesi/proposta** (stima di lavoro o scelta di prodotto). Le durate sono tutte **ipotesi di impegno**, escluse le attese indicate; non sono SLA dei fornitori. Le fonti sono state consultate il 9/11/2026, salvo diversa precisazione.

### Stato effettivo rispetto all'handoff

| Area | Evidenza | Conclusione |
|---|---|---|
| App | `pubspec.yaml`: Flutter, Android, versione `0.1.0+1`; `android/app/build.gradle.kts`: `applicationId=com.vinoozy.app`, minSdk 24 | Package confermato. `com.vinoozy.vinoozy` è il namespace del codice, non il package Play. |
| API Android | `targetSdk=flutter.targetSdkVersion`; SDK Flutter installato: 36 | Compatibile sulla carta con API 36; verificare il valore dell'AAB effettivo, anche in CI. |
| Catalogo offline | `assets/wine_db/manifest.json`: **15.490 vini**, fonte OFF, export 7/11/2026, formato 2 | Controllo di release passato. Non è un campione. |
| Denominazioni | Manifest generato: **2.424 denominazioni**, eAmbrosia **e registri nazionali**, export 8/11/2026 | Controllo di release passato. Non attribuire tutto soltanto all'UE. |
| Account | Google Auth, Firestore persistente offline, App Check Play Integrity e Crashlytics in release | Implementati; configurazione e progetto remoto non certificati. |
| Dati aggiuntivi | Foto profilo visualizzata da URL Google; email degli invitati, nomi e UID nei documenti di condivisione; query OFF; diagnostica ML Kit | L'elenco dei dati nell'handoff era incompleto. |
| Cancellazione | Runner Android e JavaScript web; pagine it/en/pt-BR già presenti | Non serve costruire da zero il flusso web. Serve renderlo operativo e correggerne le promesse. |
| Configurazione web | `node tool/check_web_config.mjs docs/account-deletion/firebase-config.js`: fallisce su **cinque valori TODO** | Blocco certo: apiKey, authDomain, projectId, appId, chiave pubblica reCAPTCHA. Non inventare credenziali. |
| Hosting | [API del repository](https://api.github.com/repos/brunobottazzini/Vinoozy): `private=false`, `has_pages=false`, `license=null` | Repository già pubblico; Pages non abilitato al momento della lettura. Il fetch dell'URL web non è riuscito: non dichiararlo pubblicato. |
| Privacy | Il provider in `lib/account/account_providers.dart` ripiega sull'URL della pagina di cancellazione; `profile_screen.dart` mostra un URL selezionabile e il comando Copia, senza aprirlo | Una breve sezione sui residui non sostituisce l'informativa completa. Mancano un testo completo individuato e un collegamento direttamente consultabile dall'app. |
| CI/CD | `release.yml`, `promote.yml`, `firebase-deploy.yml`, `pages.yml` presenti | Automazione definita, operatività non dimostrata. Non è corretto dire che l'AAB sia già stato caricato. |
| CI remota | [Run CI di HEAD](https://github.com/brunobottazzini/Vinoozy/actions/runs/42595346078) terminata **failure**: step Flutter test e coperture superati; job `unit` fallisce nello step **Native label tests (Robolectric, JaCoCo 80%)**; regole/web superati; anche il job **e2e è fallito** | CI non verde. Il controllo della build release è saltato dopo il fallimento. La causa del fallimento E2E corrente non è stata diagnosticata e non va automaticamente identificata col doppione storico già documentato. |
| Workflow rilascio | [release](https://github.com/brunobottazzini/Vinoozy/actions/runs/42595344219) e [promote](https://github.com/brunobottazzini/Vinoozy/actions/runs/42595342598): failure, zero job | Verificare gli errori di validazione/configurazione del workflow. La causa esatta non è stata determinata. |
| Sicurezza repository | Job remoto `secrets` di HEAD superato | Evidenza utile di scansione, non garanzia assoluta di assenza di segreti. Non letti né copiati valori di credenziali. |
| Monetizzazione | Nessuna dipendenza Billing/AdMob in `pubspec.yaml`, nessuna gestione premium individuata | Ricavi e paywall sono proposte future. |

**Controlli eseguiti localmente:** 241 test passati con `flutter test --no-pub test/account test/cellar/ui/history_screen_test.dart test/cellar/ui/drink_snack_bar_test.dart test/app/about_screen_test.dart --reporter expanded`; controlli catalogo, denominazioni e indici Firestore passati; configurazione web fallita come sopra. I test unitari/widget non riproducono l'E2E del doppione sul telefono e non dimostrano cancellazione o OAuth in produzione. Nessuna nuova build firmata o prova su dispositivo eseguita in questo lavoro.

## Checklist ordinata

Ogni casella resta aperta finché non esiste l'evidenza richiesta. Una fonte ufficiale stabilisce il requisito, non dimostra che il progetto lo abbia già soddisfatto.

| # | Passo e criterio di chiusura | Chi / dove | Tempo ipotizzato | Fonte primaria |
|---|---|---|---|---|
| 1 | [ ] Leggere tipo di account, data di creazione, verifiche pendenti anche del dispositivo e dashboard della **nuova app**. Registrare i valori. Avere un'altra app pubblicata non prova l'esenzione dai test di questa app. | Proprietario, Play Console | 20–40 min | [Test account personali](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en), [verifica dispositivo](https://support.google.com/googleplay/android-developer/answer/6112435?hl=en) |
| 2 | [ ] Verificare identità, profilo pagamenti, contatti e dati pubblici. Account personale: nome legale, paese ed email pubblici; indirizzo completo se monetizza. Organizzazione: nome, indirizzo e telefono, D-U-N-S ove richiesto. | Proprietario, account Play/Payments | 30–90 min + verifiche esterne | [Informazioni richieste](https://support.google.com/googleplay/android-developer/answer/13628312?hl=en) |
| 3 | [ ] Preparare dichiarazione trader coerente con l'attività. Per account esistenti scadenza **1 febbraio 2027**; cambiamenti di pubblicazione dei contatti annunciati dal **1 marzo 2027**. Non confondere account personale con non-trader. | Proprietario, Play; commercialista per l'inquadramento | 30–60 min | [Trader status](https://support.google.com/googleplay/android-developer/answer/17594752) |
| 4 | [ ] Creare/selezionare Vinoozy: lingua predefinita italiano, app, gratuita al download, categoria proposta **Cibo e bevande**, supporto `bottazzinibruno@gmail.com`, package **`com.vinoozy.app`**. Controllare eventuale app già creata. | Proprietario, Play Console | 20–40 min | [Creazione app](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en) |
| 5 | [ ] Configurare Play App Signing. Copiare SHA-1 e SHA-256 della **app signing key di Google** nell'app Android Firebase; registrare SHA-256 in App Check. Verificare client OAuth Android package+SHA-1 e `GOOGLE_SERVER_CLIENT_ID` web. Provare login dall'installazione Play. | Proprietario, Play/Firebase/Cloud; eventuale aggiornamento configurazione CI | 45–90 min + propagazione | [Firebase Google Sign-in](https://firebase.google.com/docs/auth/android/google-signin), [App Check Android](https://firebase.google.com/docs/app-check/android/play-integrity-provider) |
| 6 | [ ] Risolvere CI Android nativa e failure dei workflow release/promote; ottenere run verde su un commit identificato, AAB firmato, upload interno visibile e `versionCode` annotato. Primo caricamento/configurazione manuale in Console se richiesto dal bootstrap API. Verificare segreti per nome e presenza senza esportarne il contenuto, permessi service account e reviewer degli ambienti. | Codice/workflow + proprietario GitHub/Play | 0,5–2 giorni, causa da diagnosticare | [Rilascio Play](https://support.google.com/googleplay/android-developer/answer/9859348?hl=en); evidenze CI sopra |
| 7 | [ ] Validare AAB: API target **36+** per nuova app Android mobile alla data di verifica, supporto 64 bit e pagine memoria 16 KB, permessi effettivi, assenza flag E2E/PERF, simboli Crashlytics. Non limitarsi al manifest sorgente. | Codice/build + Play App Bundle Explorer | 2–4 h | [Target API](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-sg), [16 KB](https://developer.android.com/guide/practices/page-sizes) |
| 8 | [ ] Chiudere bug noti e smoke test § successivo; confermare regole/indici del commit esatto della build. Pubblicazione regole resta manuale con il workflow predisposto. | Codice + proprietario Firebase e telefono | 1–3 giorni, ipotesi | `docs/release-checklist.md`; [Preparazione review](https://support.google.com/googleplay/android-developer/answer/9859455?hl=en) |
| 9 | [ ] Riesaminare testo/UI alcol, impostare target proposto solo **18+**, completare IARC con risposte veritiere. Valutare Restrict Minor Access se disponibile; non falsificare il rating IARC per ottenere 18. | Proprietario Play + testi app | 1–2 h | [Alcol](https://support.google.com/googleplay/android-developer/answer/9878810?hl=en), [Target](https://support.google.com/googleplay/android-developer/answer/9867159?hl=en) |
| 10 | [ ] Verificare applicabilità UGC per note e cantine condivise: termini accettati prima del caricamento, regole sui contenuti, segnalazione in-app e gestione abusi proporzionata; valutare blocco utenti per interazioni pertinenti. Revoca e uscita esistono, segnalazione/accettazione termini non individuate. | Codice + proprietario policy | 0,5–2 giorni, ambito da confermare | [Policy UGC](https://support.google.com/googleplay/android-developer/answer/9876937?hl=en) |
| 11 | [ ] Compilare Sicurezza dei dati dalla matrice sotto, includendo SDK e query OFF; dichiarare dati cifrati in transito e percorso cancellazione effettivo. La scheda descrive tutte le versioni distribuite pertinenti. | Proprietario Play, con verifica codice/SDK | 2–4 h | [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en), [Firebase disclosure](https://firebase.google.com/docs/android/play-data-disclosure), [ML Kit disclosure](https://developers.google.com/ml-kit/android-data-disclosure) |
| 12 | [ ] Approvare gestione dei dati residui: UID e note nelle cantine altrui, diagnostica, copie tecniche. Eliminare promessa «nessun altro dato» e presunta anonimizzazione. Definire base giuridica e conservazione limitata. Per email fornite da chi invita verificare anche l'informazione individuale art. 14 GDPR, minimizzazione e scadenza degli inviti: la sola pagina privacy non dimostra ricezione da parte dell'invitato. | Codice + proprietario, consulenza privacy se necessaria | 1–3 giorni | [GDPR, testo del Garante](https://www.garanteprivacy.it/it/il-testo-del-regolamento), [Firebase privacy](https://firebase.google.com/support/privacy) |
| 13 | [ ] Compilare i cinque valori web pubblici, domini Firebase Auth, OAuth e reCAPTCHA; pubblicare via `pages.yml`, attivare GitHub Pages, provare cancellazione completa dal browser con account di prova, senza app installata. Inserire URL esatto in Console. | Proprietario Firebase/GitHub; configurazione web | 2–4 h | [Cancellazione account](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en), [GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages) |
| 14 | [ ] Pubblicare privacy in HTML accessibile senza login, non solo PDF/documento modificabile. Rendere il link **apribile** dal profilo o mostrare lì il testo: oggi è solo copiabile; cambiare `PRIVACY_POLICY_URL` non basta. Inserire il link anche in Play. Applicare appendice A dopo chiusura dei campi e delle scelte. | Proprietario + modifica UI/link/configurazione | 3–6 h + valutazione giuridica | [Review/privacy](https://support.google.com/googleplay/android-developer/answer/9859455?hl=en), [Guida Garante](https://www.garanteprivacy.it/documents/10160/0/Guida%2Ball%2Bapplicazione%2Bdel%2BRegolamento%2BUE%2B2016%2B679.pdf) |
| 15 | [ ] Configurare OAuth per pubblico esterno/produzione, contatti e branding; scopes minimi; verificare domini e branding secondo la sezione dedicata. | Proprietario, Google Auth Platform/Search Console/Firebase | 1–3 h; review manuale branding normalmente 2–3 giorni lavorativi | [Brand verification](https://developers.google.com/identity/protocols/oauth2/production-readiness/brand-verification), [OAuth compliance](https://developers.google.com/identity/protocols/oauth2/production-readiness/policy-compliance) |
| 16 | [ ] Rendere reperibili database derivato della versione distribuita, licenze e attribuzioni; inventariare anche registri nazionali. Scegliere licenza codice separata e mantenere scansione segreti. | Codice/dati + proprietario repository | 2–5 h + chiarimenti eventuali sui registri | [ODbL](https://opendatacommons.org/licenses/odbl/1-0/), [OFF licenze](https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/tutorials/license-be-on-the-legal-side/), [UE riuso](https://commission.europa.eu/legal-notice_en) |
| 17 | [ ] Inserire testi it/en/pt-BR appendice C, icona store 512×512, feature graphic 1024×500, almeno 2 screenshot reali; proposta 6 per lingua. Controllare limiti 30/80/4000 caratteri. | Proprietario Play + grafica/screenshot | 0,5–1 giorno | [Asset](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en-GB), [Metadati](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en) |
| 18 | [ ] App content: ads «No» per build attuale. Fornire istruzioni **in inglese** e dati di accesso completi anche per Google Sign-in, riutilizzabili, validi ovunque e senza OTP/2FA bloccanti. Usare account dimostrativi dedicati e dati fittizi, mai l'account del proprietario. Verificare con Play un'alternativa ammessa se Google blocca il login di prova; nessuna backdoor di produzione. Spiegare condivisione e ulteriori dichiarazioni della dashboard. | Proprietario Play | 1–2 h + prova effettiva | [Accesso per review](https://support.google.com/googleplay/android-developer/answer/15748846?hl=en) |
| 19 | [ ] Eseguire test interno con build scaricata dallo store; chiudere login, offline, riavvio, condivisione, cancellazione, performance e crash. | Proprietario e tester | 2–3 giorni di uso, proposta | [Test Play](https://support.google.com/googleplay/android-developer/answer/9845334?hl=en) |
| 20 | [ ] Se account personale creato dopo 13/11/2023, pianificare test chiuso di **12 tester aderenti continuativamente per almeno 14 giorni**, poi domanda di accesso produzione per Vinoozy; confermare dashboard. Negli altri casi non applicare automaticamente questo vincolo, ma testare comunque. | Proprietario Play + tester | ≥14 giorni se applicabile + review, nessuna garanzia | [Requisito ufficiale](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en) |
| 21 | [ ] Primo lancio nei paesi scelti, proposta Italia: **100% degli utenti eleggibili di quei paesi**, dopo review. Il 20% del workflow è per aggiornamenti successivi; per primo lancio scegliere percorso compatibile e verificare API/Console. | Proprietario Play | 30–60 min + review variabile; riserva di calendario 7–14 giorni, ipotesi | [Primo rilascio](https://support.google.com/googleplay/android-developer/answer/9859348?hl=en), [Staged rollout](https://support.google.com/googleplay/android-developer/answer/6346149?hl=en) |

### Bug noti: cosa serve davvero per chiuderli

| Punto handoff | Riscontro | Prova/azione prima dello store |
|---|---|---|
| Righe duplicate nello Storico | Documentato in `aidlc/spaces/default/intents/261107-ux-redesign/construction/build-and-test/test-results.md`: E2E secondo test di `integration_test/cellar_test.dart`, doppione della bevuta; accettato allora come lavoro separato | Riprodurre, distinguere duplicazione dei documenti da duplicazione del rendering/paginazione, correggere, far passare E2E su telefono e riavvio/offline. Il widget test verde odierno non lo chiude. |
| «Annulla» | Implementato in `drink_flow.dart`/`drink_snack_bar.dart`; test presente. La review UX segnala possibile snackbar sovrapposta tornando dal dettaglio | Provare conferma annullata senza scritture, undo con ripristino quantità e storico unico, percorso dettaglio→indietro, doppio tocco e offline. |
| Avviso tecnico all'avvio | Descrizione insufficiente per identificare univocamente messaggio e causa; nessun testo inventato | Catturare messaggio e log sanitizzati della build interna, classificare se errore App Check/config oppure UI, correggere; non silenziare errori prima della diagnosi. |
| Contatto OFF | `OFF_CONTACT` abilita la ricerca online; CI legge i dart-defines da `FIREBASE_PROD_DEFINES_JSON_B64` | Controllare che il contatto sia valorizzato nell'ambiente `play-internal`, ricostruire e provare. È contatto nel User-Agent, non password: estrarlo dal binario è possibile. Preferibile casella dedicata. |
| Repository pubblico/licenza | Già pubblico; nessuna licenza generale rilevata dall'API. `package.json` è `UNLICENSED`; ODbL nel dataset non licenzia il codice | Decidere licenza e aggiungere avvisi per codice, dipendenze, dataset e registri; scanner storia superato in CI, mantenere controllo. Il codice può restare proprietario con dataset derivato accessibile separatamente. |

## Alcol, pubblico e paesi

La policy Play consente di trattare vino; vieta incoraggiare uso illegale/inappropriato, uso/vendita ai minori e rappresentazione favorevole di consumo eccessivo o competitivo. Il target **18+ è la proposta di prodotto**, non una dichiarazione che ogni app sul vino abbia per regola un rating IARC 18. Rispondere al questionario su alcol e interazioni effettive; conservare l'esito regionale. [Policy alcol](https://support.google.com/googleplay/android-developer/answer/9878810?hl=en), [pubblico](https://support.google.com/googleplay/android-developer/answer/9867159?hl=en).

Per Vinoozy: presentare le finestre come **stime di evoluzione della bottiglia**, senza precisione garantita né inviti ad aumentare le bevute. Evitare «bevi ogni giorno», sfide, serie giornaliere o premi per consumo, benefici di salute, successo sociale grazie all'alcol e notifiche insistenti «devi bere oggi». Usare «Controlla le bottiglie nella finestra stimata». Conservazione, stile e annata influenzano la stima. I grafici devono descrivere l'inventario, non premiare quantità bevute.

**Proposta geografica:** primo rilascio Italia; inglese e pt-BR sono localizzazioni, non autorizzazioni alla distribuzione in tutti i paesi. Prima di aggiungere un paese verificare leggi locali su promozione/vendita di alcol, rating, età e termini; riesaminare da zero se si introducono affiliazioni. Non è stata verificata una matrice legale mondiale: qualunque elenco di paesi «sempre ammessi» sarebbe un'ipotesi. Per l'Italia il riferimento pubblicitario è l'[art. 13 legge 125/2001, testo pubblicato in Gazzetta](https://www.gazzettaufficiale.it/atto/serie_generale/caricaArticolo?art.codiceRedazionale=001G0181&art.dataPubblicazioneGazzetta=2001-04-18&art.flagTipoArticolo=0&art.idArticolo=13&art.idGruppo=3&art.idSottoArticolo=1&art.idSottoArticolo1=10&art.progressivo=0&art.versione=1); applicazione al futuro specifico flusso commerciale da verificare con un professionista.

## Sicurezza dei dati: proposta di compilazione

Matrice basata sui flussi trovati; **da convalidare sull'AAB distribuito e sugli SDK Android risolti**, non soltanto sui package Flutter. «Raccolto» per Play comprende l'invio fuori dal telefono; non implica vendita. Firebase come fornitore di servizio può rientrare nell'eccezione alla «condivisione»; azioni consapevoli verso altri utenti/app possono avere altra eccezione. Non spuntare indiscriminatamente «nessun dato condiviso». [Definizioni Play](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en).

| Flusso verificato / tipo proposto nel modulo | Raccolta e finalità | Obbligatorio/facoltativo e condivisione proposta |
|---|---|---|
| Nome, email, UID Google/Firebase → Informazioni personali: nome, email, ID utente | Sì; gestione account, funzionalità | Necessari al login attuale. Google/Firebase fornitori; nomi/email/ruoli possono essere visibili alle persone della condivisione scelta. |
| URL/foto profilo Google → foto o altri dati personali, classificazione da confermare | Download dall'host Google per il profilo; non individuato upload foto profilo su Firestore | Considerare l'autorizzazione iniziale Google e gli IP del download; non assimilarla alle etichette OCR. |
| Cantina, quantità, annate, date, voti, note → contenuti generati dagli utenti | Sì; funzionalità, sincronizzazione | Inserimento volontario, necessario alla funzione usata; visibili nella cantina condivisa ai membri autorizzati. Non classificarli automaticamente come dati sanitari. |
| Email/nome invitati, anche non iscritti → informazioni personali | Sì; inviti, controllo accessi | Condivisione facoltativa; indicare provenienza da chi invita nella privacy e dare informazione agli invitati. |
| Query OFF: codice a barre e parole selezionate/ricavate dall'OCR → cronologia ricerche in-app o altri contenuti, mappatura da confermare | Sì se `OFF_CONTACT` abilita il fallback; funzionalità. OFF vede anche IP e User-Agent | Non dichiarare soltanto «tutto offline». Non verificata conservazione OFF né applicabilità dell'eccezione fornitore: valutare come condivisione verso terzo indipendente finché documentato diversamente. Non inferire posizione approssimativa dal solo passaggio di IP senza analisi SDK/finalità. |
| Crashlytics → crash log, diagnostica, ID dispositivo/installazione; Sessions e Installations transitivi | Sì nelle build release reali; analisi qualità/funzionalità | Raccolta automatica attuale, nessun interruttore utente trovato. Non dichiararla facoltativa finché non c'è un controllo effettivo. |
| App Check/Play Integrity → dati e segnali tecnici, attestation | Sì secondo provider; sicurezza/prevenzione frodi | In uso su progetto reale. Verificare categorie effettive da SDK e provider; non ignorarlo perché assente nell'handoff. |
| ML Kit OCR/barcode → metadati app/dispositivo/installazione, metriche tecniche | Diagnostica e analisi d'uso SDK anche se OCR e barcode sono elaborati sul telefono | Le immagini non sono inviate dall'OCR locale, ma «nessuna telemetria» sarebbe falso. |
| Foto etichette | Nessun upload Vinoozy individuato per OCR; copie temporanee locali | Escludere dalla raccolta cloud di Vinoozy se confermato. Con «Apri in Google Lens» l'immagine può passare all'app scelta con conferma: descrivere il flusso e valutare l'eccezione per azione esplicita dell'utente. |

Per gli SDK: [Firebase disclosure](https://firebase.google.com/docs/android/play-data-disclosure) e [ML Kit disclosure](https://developers.google.com/ml-kit/android-data-disclosure). La sanitizzazione in `lib/app/error_reporter.dart` è utile, ma non elimina gli identificativi generati automaticamente dagli SDK.

Altre risposte: **raccolta dati sì**, **crittografia in transito sì** per i flussi HTTPS verificati, **richiesta cancellazione sì dopo attivazione del web**, **creazione account tramite Google** secondo le opzioni effettive del modulo. Non dichiarare cifratura end-to-end, audit di sicurezza indipendente o cancellazione di ogni copia istantanea. La sola autenticazione Google non rende vera una dichiarazione di assenza di raccolta.

## OAuth, hosting e licenze

**OAuth.** Nel codice non individuati scopes di Drive, Gmail o altri dati sensibili: il semplice login non giustifica automaticamente una verifica per scopes sensibili. Verificare la lista reale su Google Auth Platform e le dipendenze. La verifica del **branding** è distinta: nome/logo personalizzati per app esterna in produzione possono richiederla. Compilare homepage, privacy, supporto e domini; togliere la limitazione ai soli test user quando si passa in produzione. [Branding](https://developers.google.com/identity/protocols/oauth2/production-readiness/brand-verification).

Il dominio `brunobottazzini.github.io` serve per Auth web/reCAPTCHA della pagina esistente; `vinoozy-d6f45.firebaseapp.com` è l'authDomain previsto dalla documentazione. Questo non equivale alla verifica di proprietà del dominio radice `github.io`. La guida OAuth richiede domini verificabili in Search Console e consiglia un dominio proprio quando il provider usa domini condivisi. **Proposta:** dominio proprio per homepage/privacy/termini, oppure verificare con Google il percorso ammesso per il dominio ospitato prima di assumere che basti GitHub Pages. Non inventare un dominio già acquistato. [OAuth domini e homepage](https://developers.google.com/identity/protocols/oauth2/production-readiness/policy-compliance).

**Hosting.** GitHub Pages è disponibile gratuitamente per repository pubblici; su repository privati dipende dal piano. Si può mantenere privato il codice e pubblicare un repository separato per pagine e database. Il workflow `pages.yml` attuale copia **solo** `docs/account-deletion/`: aggiungere un Markdown privacy a `docs/` non lo pubblica. Per gli URL privacy proposti sotto servono HTML, routing e aggiornamento esplicito del workflow. Controllare che link e privacy siano accessibili prima di inviarli a Play. [GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages).

**Open Food Facts.** Distribuire il database derivato in formato leggibile da macchina con ODbL e avvisi preservati; l'offerta deve corrispondere alla versione presente nell'AAB, anche se il codice diventa privato. Il dataset `wines.jsonl.gz`, manifest, README, licenza e tool sono già nel repository. Preferire un permalink al commit o un archivio di versione, non il solo ramo mobile `main`. ODbL riguarda il database, non impone da sola di aprire tutto il codice né di pubblicare le cantine personali. [ODbL, §§2.3, 4.2–4.6](https://opendatacommons.org/licenses/odbl/1-0/).

Attribuzione proposta in Informazioni e, come scelta di trasparenza, nella descrizione estesa dello store:

> Dati del catalogo da Open Food Facts, disponibili con licenza Open Database License (ODbL 1.0); contenuti con Database Contents License (DbCL 1.0). Database derivato e informazioni sulla versione: https://github.com/brunobottazzini/Vinoozy/tree/ee114e34ecdb2ec0dff873d20ad23d0004996947/assets/wine_db .

Nessun obbligo specifico di collocare l'attribuzione proprio nella scheda Play è stato verificato; deve comunque accompagnare dati e utilizzi pertinenti. Per immagini eventualmente aggiunte in futuro verificare la relativa licenza separata. OFF richiede identificazione dell'app e limiti di uso dell'API: il modello economico non può promettere richieste online senza limiti. [Documentazione API OFF](https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/).

**UE e altri registri.** La nota legale della Commissione consente in generale riuso dei contenuti UE sotto CC BY 4.0 salvo avvisi diversi: citare fonte, data e trasformazioni; non suggerire approvazione ufficiale delle stime. Questa regola generale **non certifica ogni riga del dataset misto**. Controllare `tool/data/appellations/README.md`, fonti nazionali e specifici termini del registro eAmbrosia; annotare ciò che resta non verificato. [Nota legale Commissione](https://commission.europa.eu/legal-notice_en).

Testo proposto, subordinato al controllo delle fonti nazionali:

> Denominazioni da eAmbrosia della Commissione europea e dai registri nazionali indicati nella documentazione dei dati; estrazione del 8 novembre 2026, normalizzazione e classificazione a cura di Vinoozy. Le finestre di evoluzione sono stime di Vinoozy e non indicazioni approvate dai registri.

## Piano di rilascio e verifiche a ogni promozione

1. **Prima di distribuire:** CI verde, regole/indici compatibili pubblicati manualmente, pagine pubbliche effettive, privacy e dichiarazioni coerenti, bug noti chiusi. Dati/chiavi devono provenire dall'ambiente corretto. Una release non deve iniziare con richieste negate dalle nuove regole.
2. **Interno:** installazione Play, vero account Google, App Check, OCR offline/online, due account per sharing, cancellazione da app e browser, crash simbolicati, it/en/pt-BR, accessibilità e modalità aereo. Il controllo dei test interni è distinto dal test chiuso obbligatorio. [Tipi di test](https://support.google.com/googleplay/android-developer/answer/9845334?hl=en).
3. **Chiuso:** se il caso account lo richiede, 12 tester per 14 giorni continuativi; raccogliere feedback e correzioni. Non presentare il trascorrere dei 14 giorni come approvazione automatica. Se non richiesto, un piccolo test chiuso resta una proposta utile.
4. **Prima produzione:** Italia come proposta, nessun link di acquisto vino, niente ads o premium ancora assenti. Prima release al 100% nel paese selezionato, dopo review. Il workflow consente anche `fraction=1.0`, ma il percorso deve essere validato per il primo rilascio; non eseguire il default 0.2. [Primo lancio](https://support.google.com/googleplay/android-developer/answer/9859348?hl=en).
5. **Aggiornamenti:** opzioni attuali del workflow **20%→100%**. Proposta: 24–48 h al 20%, poi completamento con dati sufficienti, zero crash riproducibili su flussi critici, login/deletion funzionanti e utilizzo Firestore entro previsione. Non dare valore statistico a «zero crash» con pochi tester. Per percentuali intermedie cambiare prima il workflow. [Rollout](https://support.google.com/googleplay/android-developer/answer/6346149?hl=en).
6. **Problema:** fermare il rollout degli aggiornamenti, diagnosticare e pubblicare correzione con `versionCode` maggiore. `halt` non disinstalla le copie già ricevute e non costituisce downgrade. Per prima release valutare sospensione della disponibilità ai nuovi utenti; le installazioni esistenti restano da gestire.

Prima di ogni passaggio annotare commit, AAB, versionCode, regole/indici effettivamente in servizio, versioni dei dataset, risultati smoke, dati Crashlytics/Play vitals, costo e quote, URL pubblici e responsabilità della decisione. Le approvazioni degli ambienti GitHub sono una configurazione da verificare: i commenti YAML non la impongono.

## Appendice A — informativa privacy, testi da pubblicare

**Istruzioni editoriali, da non pubblicare:** queste sono bozze per la build attuale, non per un'app già monetizzata. Sostituire `[INDIRIZZO DEL TITOLARE]`, `[URL PRIVACY]`, `[URL CANCELLAZIONE]`, `[DATA]`; confermare che Bruno Bottazzini sia il titolare legale e che l'email indicata sia la casella operativa scelta. La policy proposta presuppone: valutazione documentata del legittimo interesse per diagnostica e inviti; verifica degli adempimenti relativi agli SDK sul dispositivo, incluso eventuale consenso; approvazione della gestione dei dati condivisi e delle richieste manuali; verifica dei contratti/garanzie di trasferimento. Per dati ricevuti da chi invita, definire modalità e termini dell'informazione ex art. 14: normalmente entro un mese o prima comunicazione/disclosure se antecedente, salvo eccezione documentata applicabile. Non è richiesta alcuna spedizione di messaggi in questo lavoro. Se queste condizioni non reggono, cambiare configurazione/codice e testo prima della pubblicazione. Pubblicare tre pagine con contenuto equivalente. Non chiamare questi testi «conformità GDPR certificata».

### A1. Italiano

**Informativa privacy di Vinoozy — aggiornata al [DATA]**

**Titolare e contatti.** Il titolare del trattamento è Bruno Bottazzini, [INDIRIZZO DEL TITOLARE], Italia. Per informazioni e per esercitare i tuoi diritti: bottazzinibruno@gmail.com. Questa informativa riguarda l'app Vinoozy e la pagina per cancellare l'account. Vinoozy è destinata a persone maggiorenni.

**Dati e finalità.** Quando accedi con Google trattiamo nome, email, identificativo dell'account e foto profilo disponibile per autenticarti e mostrarti il profilo. Salviamo la tua cantina, i vini, le quantità, le date e le registrazioni delle bevute, i voti e le note che inserisci, per fornire il servizio e sincronizzarlo tra dispositivi. I dati sono conservati anche sul telefono per l'uso offline.

Se condividi una cantina, trattiamo email, nomi, identificativi e permessi degli invitati e rendiamo i contenuti accessibili alle persone autorizzate. Possiamo ricevere il tuo indirizzo email da una persona che ti invita, anche prima della tua registrazione. Usiamo questi dati soltanto per gestire invito e accesso. Puoi chiedere la rimozione di un invito scrivendo al contatto sopra. Non inserire nelle note dati sensibili o informazioni su altre persone non necessarie al servizio.

Le foto delle etichette sono elaborate sul dispositivo con ML Kit; Vinoozy non le carica sul proprio database. Le copie temporanee create dall'app sono eliminate al termine del flusso o durante la pulizia al riavvio. L'originale nella tua galleria rimane sotto il tuo controllo. Se usi la ricerca online, alcune parole cercate o ricavate dall'etichetta e i codici a barre possono essere inviati a Open Food Facts, che riceve anche IP e dati tecnici della richiesta. Se confermi l'apertura della foto in Google Lens o in un'altra app, l'immagine passa a quel servizio, che la tratta secondo le proprie condizioni.

Usiamo Firebase Crashlytics per diagnosticare errori, App Check/Play Integrity per proteggere il servizio e ML Kit per la lettura locale. Questi servizi possono trattare identificativi di installazione, metadati di dispositivo e app, log di crash, eventi e metriche tecniche. Il fatto che l'OCR sia locale non esclude la diagnostica degli SDK. Nella versione descritta non sono integrati pubblicità o pagamenti.

**Basi giuridiche.** Account, archivio, sincronizzazione e condivisione richiesta servono a eseguire il servizio che scegli di usare, ai sensi dell'art. 6(1)(b) GDPR. Gestione degli inviti ricevuti da altri utenti, sicurezza e diagnostica essenziale si basano sul legittimo interesse a fornire un servizio funzionante e sicuro, art. 6(1)(f), con minimizzazione e valutazione degli interessi coinvolti. Gestiamo le richieste relative ai diritti e gli eventuali obblighi legali ai sensi dell'art. 6(1)(c). Puoi opporti ai trattamenti fondati sul legittimo interesse. Il mancato conferimento dei dati necessari all'account impedisce l'uso delle funzioni con accesso; note e condivisioni sono scelte facoltative.

**Destinatari e trasferimenti.** I fornitori tecnici comprendono Google/Firebase e i relativi subfornitori; Open Food Facts riceve le richieste online; i membri da te autorizzati accedono alla cantina condivisa. Il fornitore di hosting della pagina riceve i normali dati tecnici di navigazione. Non vendiamo i dati della cantina. Alcuni servizi e subfornitori possono trattare dati fuori dallo Spazio economico europeo: la regione scelta per Firestore non copre necessariamente tutti gli altri servizi. I trasferimenti avvengono secondo i contratti applicabili e, quando richiesto, decisioni di adeguatezza o clausole contrattuali standard. Puoi chiedere informazioni e una copia delle garanzie applicabili al contatto del titolare. Informazioni sui fornitori: https://firebase.google.com/support/privacy e https://policies.google.com/privacy .

**Conservazione e cancellazione.** Conserviamo account e cantina finché usi il servizio o chiedi la cancellazione. Puoi cancellare account e cantina personale dall'app o tramite [URL CANCELLAZIONE], senza reinstallare l'app. Rimuoviamo profilo, cantina personale, relativi vini e bevute, inviti e accessi collegati secondo la procedura indicata sulla pagina. Per richieste manuali rispondiamo normalmente entro un mese dal ricevimento; se serve verificare l'identità o ricorrono le condizioni di legge per un'estensione, te lo comunichiamo.

Nelle cantine appartenenti ad altre persone possono rimanere registrazioni e note inserite da te, insieme a identificativi tecnici persistenti. Questi dati non sono necessariamente anonimi e possono restare finché il titolare della cantina li elimina o viene accolta una richiesta di rimozione. Per chiederne la cancellazione o contestarne la conservazione scrivi al titolare: valuteremo i dati effettivamente presenti, i tuoi diritti e quelli delle altre persone. Le copie già esportate da altri utenti non sono direttamente controllabili da Vinoozy.

La cancellazione dell'account non elimina istantaneamente tutti i dati diagnostici o le copie tecniche dei fornitori. Firebase indica per Crashlytics 90 giorni prima dell'avvio della rimozione dai sistemi attivi e di backup; alcuni dati di Authentication possono richiedere fino a 180 giorni dopo l'avvio della cancellazione. Eventuali ulteriori conservazioni per obblighi legali o difesa di diritti sono limitate ai dati necessari e motivate. I dati temporanei e la cache sul telefono sono gestiti dalle procedure dell'app; i file che hai salvato autonomamente restano sotto il tuo controllo.

**Diritti.** Nei casi previsti puoi chiedere accesso, rettifica, cancellazione, limitazione, portabilità e opposizione; se un trattamento si basa sul consenso, puoi revocarlo. Puoi proporre reclamo al Garante per la protezione dei dati personali, https://www.garanteprivacy.it, o all'autorità competente. Le stime enologiche servono a organizzare la cantina e non prendono decisioni automatizzate con effetti giuridici o analogamente significativi su di te. Le modifiche rilevanti a questa informativa saranno comunicate nell'app e sulla pagina [URL PRIVACY].

### A2. English

**Vinoozy privacy notice — updated [DATA]**

**Controller and contact.** The data controller is Bruno Bottazzini, [INDIRIZZO DEL TITOLARE], Italy. Contact bottazzinibruno@gmail.com for privacy information or to exercise your rights. This notice covers the Vinoozy app and its account deletion page. Vinoozy is intended for adults.

**Data and purposes.** When you sign in with Google, we process your name, email, account identifier and available profile picture to authenticate you and display your profile. We store the cellar, wines, quantities, dates, drinking records, ratings and notes you enter to provide the service and synchronise it across devices. Data is also stored on your device for offline use.

If you share a cellar, we process invitees' email addresses, names, identifiers and permissions, and make cellar contents accessible to authorised members. Another user may provide your email address to invite you before you register. We use it to manage that invitation and access. You can ask us to remove an invitation at the contact above. Please do not enter sensitive data or unnecessary information about other people in notes.

Label photos are processed on your device using ML Kit; Vinoozy does not upload them to its database. Temporary copies made by the app are deleted at the end of the flow or during cleanup after restart. Originals in your gallery remain under your control. Online searches may send selected search or label words and barcodes to Open Food Facts, which also receives your IP address and technical request information. If you confirm opening a photo in Google Lens or another app, that service receives the image and processes it under its own terms.

We use Firebase Crashlytics for error diagnosis, App Check/Play Integrity for service protection and ML Kit for local reading. These services may process installation identifiers, device and app metadata, crash logs, technical events and performance metrics. On-device OCR does not exclude SDK diagnostics. The version described here has no integrated advertising or payments.

**Legal bases.** Account management, storage, synchronisation and sharing you request are necessary to provide the service you choose, under GDPR Article 6(1)(b). Invitations provided by other users, security and essential diagnostics rely on our legitimate interest in operating a reliable and secure service, Article 6(1)(f), subject to minimisation and assessment of the interests involved. Rights requests and legal obligations rely on Article 6(1)(c). You may object to processing based on legitimate interests. Required account data is necessary for signed-in features; notes and sharing are optional choices.

**Recipients and transfers.** Technical providers include Google/Firebase and their subprocessors. Open Food Facts receives online queries; authorised members receive shared cellar content. The page hosting provider receives ordinary technical browsing data. We do not sell cellar data. Some services and subprocessors may process data outside the EEA: a Firestore region does not necessarily cover every service. Transfers follow the applicable contracts and, where required, adequacy decisions or standard contractual clauses. Contact the controller for information and a copy of the applicable safeguards. Provider information: https://firebase.google.com/support/privacy and https://policies.google.com/privacy .

**Retention and deletion.** We retain your account and cellar until you request deletion or otherwise end use of the service through the available deletion process. Delete your account and personal cellar in the app or at [URL CANCELLAZIONE], without reinstalling the app. The procedure removes your profile, personal cellar and its wines and drinking records, and related invitations and access records. We normally respond to manual requests within one month of receipt and explain any necessary identity verification or lawful extension.

Records and notes you created in another person's cellar may remain with persistent technical identifiers. They are not necessarily anonymous and may remain until the cellar owner removes them or a removal request is granted. Contact the controller to request removal or object to retention; we will assess the data, your rights and other people's rights. Copies independently exported by other users are outside Vinoozy's direct control.

Account deletion does not instantly erase every diagnostic record or provider backup. Firebase states that Crashlytics begins removing crash data and associated identifiers after 90 days; some Authentication data may take up to 180 days after deletion is initiated. Additional retention for legal obligations or legal claims is limited to necessary data and justified. The app manages its temporary files and device cache through its cleanup procedures; files you saved yourself remain under your control.

**Your rights.** Where applicable, you may request access, rectification, erasure, restriction and portability, and object to processing. If processing relies on consent, you may withdraw it. You may complain to the Italian data protection authority at https://www.garanteprivacy.it or another competent authority. Wine estimates organise your cellar and do not make automated decisions with legal or similarly significant effects on you. Material changes will be communicated in the app and at [URL PRIVACY].

### A3. Português do Brasil

**Aviso de privacidade do Vinoozy — atualizado em [DATA]**

**Controlador e contato.** O controlador é Bruno Bottazzini, [INDIRIZZO DEL TITOLARE], Itália. Para informações ou para exercer seus direitos, escreva para bottazzinibruno@gmail.com. Este aviso abrange o aplicativo Vinoozy e sua página de exclusão da conta. O Vinoozy é destinado a pessoas adultas.

**Dados e finalidades.** Ao entrar com o Google, tratamos nome, e-mail, identificador da conta e foto de perfil disponível para autenticar você e mostrar seu perfil. Armazenamos a adega, os vinhos, as quantidades, as datas, os registros de consumo, as avaliações e as notas que você insere para prestar o serviço e sincronizá-lo entre dispositivos. Os dados também ficam no aparelho para uso sem conexão.

Ao compartilhar uma adega, tratamos e-mails, nomes, identificadores e permissões das pessoas convidadas e disponibilizamos o conteúdo aos membros autorizados. Outra pessoa pode fornecer seu e-mail para um convite antes de você se cadastrar. Usamos esses dados para gerenciar o convite e o acesso. Você pode pedir a remoção de um convite pelo contato acima. Evite inserir dados sensíveis ou informações desnecessárias sobre outras pessoas nas notas.

As fotos dos rótulos são processadas no aparelho com ML Kit; o Vinoozy não as envia ao seu banco de dados. As cópias temporárias criadas pelo aplicativo são apagadas ao concluir o fluxo ou na limpeza após reiniciar. Os originais da galeria continuam sob seu controle. As buscas online podem enviar palavras selecionadas da busca ou do rótulo e códigos de barras ao Open Food Facts, que também recebe o endereço IP e informações técnicas da solicitação. Se você confirmar a abertura de uma foto no Google Lens ou em outro aplicativo, esse serviço receberá a imagem e aplicará suas próprias condições.

Usamos Firebase Crashlytics para diagnosticar erros, App Check/Play Integrity para proteger o serviço e ML Kit para leitura local. Esses serviços podem tratar identificadores de instalação, metadados do dispositivo e do aplicativo, registros de falhas, eventos e métricas técnicas. O OCR local não exclui a coleta de diagnóstico dos SDKs. A versão aqui descrita não integra publicidade nem pagamentos.

**Bases legais.** Conta, armazenamento, sincronização e compartilhamento solicitado são necessários para prestar o serviço escolhido, conforme o art. 6(1)(b) do GDPR. Convites fornecidos por outros usuários, segurança e diagnóstico essencial se baseiam no legítimo interesse de manter um serviço funcional e seguro, art. 6(1)(f), com minimização e avaliação dos interesses envolvidos. Solicitações de direitos e obrigações legais se baseiam no art. 6(1)(c). Você pode se opor ao tratamento baseado em legítimo interesse. Os dados obrigatórios da conta são necessários às funções com acesso; notas e compartilhamentos são opcionais.

**Destinatários e transferências.** Os fornecedores técnicos incluem Google/Firebase e seus suboperadores. O Open Food Facts recebe buscas online; os membros autorizados acessam o conteúdo compartilhado. O provedor da página recebe dados técnicos comuns de navegação. Não vendemos os dados da adega. Alguns serviços e suboperadores podem tratar dados fora do Espaço Econômico Europeu: a região do Firestore não abrange necessariamente todos os serviços. As transferências seguem os contratos aplicáveis e, quando necessário, decisões de adequação ou cláusulas contratuais padrão. Solicite ao controlador informações e uma cópia das garantias aplicáveis. Informações dos fornecedores: https://firebase.google.com/support/privacy e https://policies.google.com/privacy .

**Conservação e exclusão.** Mantemos a conta e a adega até que você solicite a exclusão pelo procedimento disponível. Você pode excluir a conta e a adega pessoal pelo aplicativo ou em [URL CANCELLAZIONE], sem reinstalá-lo. O procedimento remove perfil, adega pessoal, seus vinhos e registros de consumo, convites e acessos vinculados. Normalmente respondemos às solicitações manuais em até um mês do recebimento e informamos sobre eventual verificação de identidade ou prorrogação permitida por lei.

Registros e notas inseridos por você em adegas de outras pessoas podem permanecer com identificadores técnicos persistentes. Esses dados não são necessariamente anônimos e podem permanecer até a remoção pelo dono da adega ou o atendimento de uma solicitação de exclusão. Entre em contato para pedir a remoção ou contestar a conservação; avaliaremos os dados, seus direitos e os direitos de outras pessoas. Cópias exportadas de forma independente por outros usuários ficam fora do controle direto do Vinoozy.

A exclusão da conta não apaga imediatamente todos os dados de diagnóstico ou as cópias técnicas dos fornecedores. Segundo o Firebase, o Crashlytics inicia a remoção dos dados de falhas e identificadores associados após 90 dias; alguns dados do Authentication podem levar até 180 dias após o início da exclusão. Qualquer conservação adicional por obrigação legal ou defesa de direitos é limitada aos dados necessários e justificada. O aplicativo gerencia arquivos temporários e cache pelas suas rotinas de limpeza; arquivos salvos por você continuam sob seu controle.

**Seus direitos.** Quando aplicável, você pode pedir acesso, correção, exclusão, limitação e portabilidade e se opor ao tratamento. Se houver tratamento baseado em consentimento, você poderá revogá-lo. Você pode apresentar reclamação à autoridade italiana, https://www.garanteprivacy.it, ou à autoridade competente. As estimativas enológicas organizam sua adega e não tomam decisões automatizadas com efeitos jurídicos ou semelhantes sobre você. Mudanças relevantes serão comunicadas no aplicativo e em [URL PRIVACY].

Nota editoriale: tradurre in pt-BR non equivale a completare una valutazione LGPD o ad approvare il lancio in Brasile. Prima della distribuzione lì integrare le informazioni/diritti richiesti dalla normativa applicabile.

## Appendice B — pagina di cancellazione

Testi sostitutivi per le tre pagine esistenti. **Pubblicabili solo dopo configurazione, prova reale e decisione sui residui condivisi.** Conservare i controlli di accesso/conferma del flusso JavaScript; questi testi non implementano il backend. Allineare la procedura email della vecchia checklist: un mese decorre normalmente dalla ricezione della richiesta; non promettere automaticamente un nuovo termine di 30 giorni dalla risposta di conferma.

### B1. Italiano

**Cancella il tuo account Vinoozy**

Puoi chiedere la cancellazione da questa pagina anche senza avere Vinoozy installata. Accedi con lo stesso account Google usato nell'app, controlla l'indirizzo mostrato e segui la conferma sullo schermo.

**Che cosa viene cancellato:** il profilo Vinoozy, la tua cantina personale con i suoi vini e lo Storico, gli inviti e gli accessi associati al tuo account. La cantina di cui sei proprietario non sarà più disponibile alle persone con cui l'hai condivisa. La cancellazione di Vinoozy non cancella il tuo account Google.

**Dati nelle cantine altrui:** possono rimanere le registrazioni e le note inserite da te nelle cantine di altre persone, con identificativi tecnici persistenti. Non sono necessariamente anonimi. Per chiederne la rimozione o contestarne la conservazione scrivi a bottazzinibruno@gmail.com. Le copie esportate da altri utenti restano sotto il loro controllo.

**Tempi e assistenza:** la procedura automatica esegue la cancellazione durante la sessione connessa; se si interrompe, torna alla pagina e completa il flusso. Non possiamo garantire l'eliminazione immediata di ogni copia tecnica o dato diagnostico dei fornitori. Se non riesci a usare l'accesso Google, scrivi a bottazzinibruno@gmail.com indicando l'account Vinoozy interessato, senza inviare password o documenti non richiesti. Verificheremo l'identità con un metodo appropriato e risponderemo normalmente entro un mese dalla richiesta, comunicando eventuali estensioni previste dalla legge.

Puoi effettuare la stessa operazione nell'app: **Profilo → Cancella account**. Maggiori dettagli su conservazione e diritti: [URL PRIVACY].

Pulsanti: **Accedi con Google** · **Cancella definitivamente l'account Vinoozy** · **Annulla**.

### B2. English

**Delete your Vinoozy account**

You can request deletion here without installing Vinoozy. Sign in with the Google account you used in the app, check the displayed email address and follow the on-screen confirmation.

**What is deleted:** your Vinoozy profile, personal cellar with its wines and History, and invitations and access records associated with your account. People you shared your own cellar with will lose access to that cellar. Deleting Vinoozy does not delete your Google account.

**Data in other people's cellars:** records and notes you entered there may remain with persistent technical identifiers. They are not necessarily anonymous. To request removal or object to retention, contact bottazzinibruno@gmail.com. Copies exported by other users remain under their control.

**Timing and help:** the automatic process deletes data during the connected session. If interrupted, return to the page and complete it. We cannot guarantee immediate removal of every provider backup or diagnostic record. If Google sign-in is unavailable, email bottazzinibruno@gmail.com and identify your Vinoozy account; do not send passwords or unsolicited identity documents. We will verify identity appropriately and normally respond within one month of receipt, explaining any lawful extension.

The same option is available in the app under **Profile → Delete account**. Retention and rights: [URL PRIVACY].

Buttons: **Sign in with Google** · **Permanently delete Vinoozy account** · **Cancel**.

### B3. Português do Brasil

**Exclua sua conta Vinoozy**

Você pode solicitar a exclusão nesta página sem instalar o Vinoozy. Entre com a mesma conta Google usada no aplicativo, confira o e-mail exibido e siga a confirmação na tela.

**O que será excluído:** seu perfil Vinoozy, sua adega pessoal com os vinhos e o Histórico, além dos convites e acessos vinculados à conta. As pessoas com quem você compartilhou sua própria adega perderão acesso a ela. A exclusão do Vinoozy não exclui sua conta Google.

**Dados em adegas de outras pessoas:** os registros e as notas inseridos por você podem permanecer com identificadores técnicos persistentes. Esses dados não são necessariamente anônimos. Para pedir a remoção ou contestar a conservação, escreva para bottazzinibruno@gmail.com. Cópias exportadas por outros usuários continuam sob o controle deles.

**Prazo e ajuda:** o processo automático exclui os dados durante a sessão conectada. Se houver interrupção, volte à página e conclua o processo. Não podemos garantir a remoção imediata de todas as cópias técnicas ou dos dados de diagnóstico dos fornecedores. Se não conseguir entrar com o Google, escreva para bottazzinibruno@gmail.com e identifique a conta Vinoozy; não envie senhas ou documentos de identidade não solicitados. Verificaremos sua identidade de forma adequada e normalmente responderemos em até um mês do recebimento, informando eventuais prorrogações permitidas por lei.

A mesma opção está no aplicativo em **Perfil → Excluir conta**. Conservação dos dados e direitos: [URL PRIVACY].

Botões: **Entrar com o Google** · **Excluir permanentemente a conta Vinoozy** · **Cancelar**.

## Appendice C — scheda Play pronta da incollare

Le descrizioni riguardano le funzioni attuali. Non includono premium, notifiche o export non implementati. Supporto: `bottazzinibruno@gmail.com`. Nome uguale nelle tre lingue. Prima dell'invio provare tutti i flussi descritti con l'AAB selezionato.

Controllo automatico dei caratteri completato: titolo/breve/estesa **it 23/78/1778**, **en 25/68/1663**, **pt-BR 18/79/1754**; tutti entro 30/80/4000.

### C1. Italiano — it-IT

**Nome**

```text
Vinoozy: la tua cantina
```

**Descrizione breve**

```text
Organizza i tuoi vini, consulta le stime di evoluzione e condividi la cantina.
```

**Descrizione estesa**

```text
La tua cantina, a portata di mano.

Con Vinoozy organizzi le bottiglie che possiedi e consulti una stima della loro evoluzione nel tempo: inizio della finestra, picco e fine indicativa.

AGGIUNGI I TUOI VINI
Inserisci i dati a mano, leggi un'etichetta con la fotocamera, usa un codice a barre o importa il testo da Google Lens. Controlla sempre i dati proposti prima di salvarli.

TIENI IN ORDINE LA CANTINA
Gestisci quantità, annate e caratteristiche. Consulta il Cruscotto, filtra i vini e ritrova nello Storico le registrazioni con voti e note. Scopri gli abbinamenti con il cibo.

ANCHE SENZA RETE
Consulta e aggiorna i dati disponibili sul telefono: le modifiche si sincronizzano quando torna la connessione. Il primo accesso con Google richiede Internet; alcune ricerche richiedono la rete.

CONDIVIDI CON LE PERSONE CHE SCEGLI
Invita altre persone nella tua cantina e scegli se possono soltanto consultarla o anche modificarla.

LEGGI L'ETICHETTA SUL TELEFONO
Il riconoscimento del testo avviene sul dispositivo. Le ricerche online possono inviare parole e codici a barre a Open Food Facts. L'apertura di una foto in Google Lens richiede la tua conferma.

Le finestre sono stime indicative: conservazione, stile e condizioni della singola bottiglia possono cambiare il risultato. Non sono una garanzia di qualità né un invito al consumo.

Vinoozy è destinata a persone maggiorenni. Non vende bevande alcoliche.

Interfaccia in italiano, inglese e portoghese brasiliano.

Dati del catalogo da Open Food Facts, con licenze ODbL 1.0 e DbCL 1.0. Database derivato e attribuzioni: https://github.com/brunobottazzini/Vinoozy/tree/main/assets/wine_db
Denominazioni da eAmbrosia e dai registri nazionali indicati nella documentazione dei dati. Le stime sono elaborate da Vinoozy.
```

### C2. English — en

**Name**

```text
Vinoozy: your wine cellar
```

**Short description**

```text
Organise your wines, explore ageing estimates and share your cellar.
```

**Full description**

```text
Your wine cellar, close at hand.

Vinoozy helps you organise the bottles you own and explore estimates of how they may evolve: the start, peak and indicative end of their drinking window.

ADD YOUR WINES
Enter details manually, read a label with your camera, use a barcode or import text from Google Lens. Always review suggested details before saving.

KEEP YOUR CELLAR ORGANISED
Manage quantities, vintages and wine characteristics. Explore the Dashboard, filter your wines and keep ratings and notes in History. Find food pairing suggestions.

WORK OFFLINE
View and update data available on your phone. Changes synchronise when your connection returns. Your first Google sign-in requires Internet; some searches also require a connection.

SHARE WITH PEOPLE YOU CHOOSE
Invite people to your cellar and choose whether they can view it or also make changes.

READ LABELS ON YOUR PHONE
Text recognition runs on your device. Online searches may send words and barcodes to Open Food Facts. Opening a photo in Google Lens requires your confirmation.

Drinking windows are indicative estimates. Storage, style and the condition of each bottle may change the result. Estimates are not a quality guarantee or an invitation to consume alcohol.

Vinoozy is intended for adults. It does not sell alcoholic drinks.

Interface available in Italian, English and Brazilian Portuguese.

Catalogue data from Open Food Facts under ODbL 1.0 and DbCL 1.0. Derived database and attribution: https://github.com/brunobottazzini/Vinoozy/tree/main/assets/wine_db
Appellations from eAmbrosia and the national registers listed in the data documentation. Estimates are produced by Vinoozy.
```

### C3. Português do Brasil — pt-BR

**Nome**

```text
Vinoozy: sua adega
```

**Descrição curta**

```text
Organize seus vinhos, consulte estimativas de evolução e compartilhe sua adega.
```

**Descrição completa**

```text
Sua adega sempre à mão.

Com o Vinoozy, você organiza as garrafas que possui e consulta estimativas de sua evolução: início, auge e fim indicativo da janela de consumo.

ADICIONE SEUS VINHOS
Insira os dados manualmente, leia um rótulo com a câmera, use um código de barras ou importe texto do Google Lens. Confira os dados sugeridos antes de salvar.

MANTENHA SUA ADEGA ORGANIZADA
Gerencie quantidades, safras e características. Consulte o Painel, filtre seus vinhos e guarde avaliações e notas no Histórico. Encontre sugestões de harmonização com alimentos.

USE MESMO SEM CONEXÃO
Consulte e atualize os dados disponíveis no celular. As alterações serão sincronizadas quando a conexão voltar. O primeiro acesso com o Google exige Internet; algumas buscas também precisam de conexão.

COMPARTILHE COM QUEM VOCÊ ESCOLHER
Convide outras pessoas para sua adega e escolha se elas podem apenas consultar ou também fazer alterações.

LEIA O RÓTULO NO CELULAR
O reconhecimento de texto acontece no aparelho. As buscas online podem enviar palavras e códigos de barras ao Open Food Facts. A abertura de uma foto no Google Lens exige sua confirmação.

As janelas são estimativas indicativas: armazenamento, estilo e condições de cada garrafa podem alterar o resultado. Não representam garantia de qualidade nem incentivo ao consumo.

O Vinoozy é destinado a pessoas adultas. Não vende bebidas alcoólicas.

Interface em italiano, inglês e português do Brasil.

Dados do catálogo do Open Food Facts, sob as licenças ODbL 1.0 e DbCL 1.0. Banco derivado e atribuições: https://github.com/brunobottazzini/Vinoozy/tree/main/assets/wine_db
Denominações do eAmbrosia e dos registros nacionais listados na documentação dos dados. As estimativas são elaboradas pelo Vinoozy.
```

### C4. Piano immagini e testi brevi sulle immagini

Nessun pacchetto store completo individuato: l'icona launcher Android non dimostra che esista l'export store richiesto. Preparare icona **512×512 PNG 32 bit**, massimo 1024 KB, senza badge/prezzi; feature graphic **1024×500 JPEG o PNG 24 bit senza alpha**. Screenshot: JPEG/PNG 24 bit, 320–3840 px, lato lungo non oltre doppio del corto; proposta **1080×1920, sei immagini per lingua**. Almeno due sono richiesti; quattro a risoluzione adeguata sono raccomandati per alcune superfici promozionali. [Specifiche Play](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en-GB).

| Schermata reale | Italiano | English | Português do Brasil |
|---|---|---|---|
| Cantina | La tua cantina, in ordine | Your cellar, organised | Sua adega organizada |
| Cruscotto | Una vista sui tuoi vini | An overview of your wines | Uma visão dos seus vinhos |
| Dettaglio finestra | Stime di evoluzione, da consultare | Explore ageing estimates | Consulte estimativas de evolução |
| Lettura etichetta | Leggi l'etichetta sul telefono | Read labels on your phone | Leia rótulos no celular |
| Storico | Ritrova voti e note | Find your ratings and notes | Encontre avaliações e notas |
| Condivisione | Scegli con chi condividere | Choose who to share with | Escolha com quem compartilhar |

Usare dati di esempio inventati, nessuna email reale nei capture, UI della versione distribuita. Non usare screenshot simulati che mostrano funzioni future. Feature graphic proposta: «La tua cantina, a portata di mano» / «Your cellar, close at hand» / «Sua adega sempre à mão». Non rappresentare minori o consumo competitivo; niente garanzie scientifiche, salutistiche, classifiche o riconoscimenti non ottenuti. [Linee guida metadati](https://support.google.com/googleplay/android-developer/answer/13393723?hl=en).

## Verifica dell'agente antagonista

Revisione indipendente svolta dall'agente `/root/antagonista`: lettura del repository, ricerca primaria e controllo di questa bozza. I rilievi sostanziali sono stati accettati e incorporati; il controllo non equivale a un'approvazione Google o a una certificazione legale.

| Contestazione | Cambiamento incorporato | Incertezza residua |
|---|---|---|
| Handoff presume pipeline operativa | Verifica API GitHub: workflow falliti e nessuna prova di upload | Causa dei workflow a zero job e stato effettivo Play/Firebase |
| Primo lancio «graduale» | Primo lancio per paese al 100%; percentuale solo aggiornamenti | Validazione del percorso API del primo lancio |
| UID condiviso scambiato per anonimizzazione | Testi sostitutivi espliciti; gate su note e riferimenti persistenti | Base giuridica e politica definitiva di cancellazione/conservazione |
| Solo email/nome/crash nell'informativa | Inclusi invitati non iscritti, query OFF, foto profilo, App Check e diagnostica ML Kit | Categorie finali Data safety sull'AAB e condizioni SDK |
| Target 18+ confuso con rating | Separati pubblico scelto, protezione minori e risultato IARC | Esito regionale del questionario e paesi ulteriori |
| Sharing privato ritenuto automaticamente escluso da UGC | Aggiunto controllo termini, segnalazione e moderazione proporzionata | Applicazione concreta alla condivisione Vinoozy |
| Solo eAmbrosia come fonte dati | Esplicitati registri nazionali e controllo licenze per fonte | Termini di ogni registro e dello studio enologico a monte |
| Reviewer invitato a usare un account proprio | Richiesti credenziali dimostrative dedicate e istruzioni EN riutilizzabili | Accesso reale senza blocchi Google; mai credenziali del proprietario |
| URL privacy soltanto copiabile nell'app | Aggiunta modifica UI per consultazione diretta | Modifica non implementata in questo studio |
| Informativa invitati data per assolta dal solo sito | Aggiunta verifica art. 14, modalità di informazione e scadenza inviti | Procedura e tempi da implementare/approvare |

