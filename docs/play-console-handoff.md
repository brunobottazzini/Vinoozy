# Handoff pubblicazione Google Play — Vinoozy 0.2.1 (3)

Stato all'11 novembre 2026. I tester (test chiuso, account dei tester) li gestisce il proprietario e restano fuori da questo documento.

## 1. Cosa è fatto

| Area | Stato |
|---|---|
| Build | `0.2.1 (3)` firmata con la chiave di caricamento, sul **test interno**. Installata sul telefono del proprietario: parte, nessun crash. Il crash all'avvio della 0.2.0 (R8 e WorkManager) è corretto, e ora `tool/check_release_launch.sh` avvia in CI una build release ridotta da R8. |
| Codice | Tutto su `main` e su GitHub, ultimo commit `c777f03`. |
| CI | Il controllo dei segreti, che falliva per le copie su `gh-pages`, ora è verde. La CI completa di `c777f03` è in corso. |
| Freemium e Plus | Il codice c'è, ma è **tutto spento** in `config/policy`: acquisti, limite di 15 vini e pubblicità. Nessun utente ha limiti. Il Profilo mostra «Gratuito» e «Plus arriverà presto». |
| Pubblicità | Il modulo AdMob è nell'app ma non parte (`adsEnabled` è `false`). Il permesso AD_ID è **tolto** dal manifest, e `tool/check_release_build.sh` lo controlla. |
| Firebase | Regole e indici Firestore pubblicati il 10/11. Il progetto è ancora sul piano gratuito Spark e le Cloud Functions non sono pubblicate. |
| Pagine pubbliche | Online e verificate (HTTP 200): informativa privacy `https://brunobottazzini.github.io/Vinoozy/privacy/` e cancellazione dell'account `https://brunobottazzini.github.io/Vinoozy/account-deletion/`. |
| Scheda dello store | Testi it/en/pt-BR in `distribution/google-play/{it-IT,en-US,pt-BR}/`, icona 512, feature graphic, 4 catture per lingua in `distribution/google-play/assets/`. |
| Note di rilascio | `distribution/google-play/release-notes.txt` (it, en, pt-BR). |
| Sicurezza dei dati | Risposte pronte da importare in `distribution/google-play/data-safety.csv`. |
| Istruzioni per i revisori | Bozza in inglese in `distribution/google-play/reviewer-instructions.txt`. |
| Plus da remoto | `node tool/admin/grant_plus.mjs grant --email <email> --no-expiry --reason owner_test --project vinoozy-d6f45 --firebase-login`. Usa il tuo login della Firebase CLI e non richiede chiavi. Non è ancora stato provato sul progetto reale: lancialo tu. |

## 2. Cosa configurare in Play Console

App: **Vinoozy: la tua cantina**, package `com.vinoozy.app`.

### 2.1 Scheda dello store principale (Crescita → Presenza nello store)

- [ ] Nome, descrizione breve ed estesa: copiale da `distribution/google-play/<lingua>/title.txt`, `short-description.txt` e `full-description.txt`. Aggiungi le traduzioni en-US e pt-BR.
- [ ] Icona: `assets/icon-512.png`. Feature graphic: `assets/feature-graphic-it-IT-v1.jpg`.
- [ ] Screenshot del telefono: `assets/screenshots/it/` (le stesse catture in `en/` e `pt-BR/` per le altre lingue).
- [ ] Categoria **Cibo e bevande**. Email di contatto `bottazzinibruno@gmail.com`.

### 2.2 Contenuti dell'app (Norme → Contenuti dell'app)

- [ ] **Norme sulla privacy**: `https://brunobottazzini.github.io/Vinoozy/privacy/`
- [ ] **Accesso all'app**: «Tutte le funzionalità o alcune sono limitate». Aggiungi un'istruzione con un account Google di prova dedicato, **senza verifica in due passaggi** e con la password scritta solo in Console. Nel campo «Altre informazioni» incolla il testo già pronto (425 caratteri) da `reviewer-instructions.txt`.
- [ ] **Annunci**: «No, la mia app non contiene annunci».
- [ ] **Classificazione dei contenuti**: questionario IARC con categoria «Utilità/Produttività/Altro». Rispondi sì a «riferimenti ad alcol», senza vendita di alcolici e senza incitare al consumo. La classificazione attesa è PEGI 16 o 18 / Teen o Mature, che va bene.
- [ ] **Pubblico di destinazione**: solo **18 anni e oltre**. Non è un'app per bambini.
- [ ] **Sicurezza dei dati**: importa `distribution/google-play/data-safety.csv` (pulsante «Importa da CSV») e controlla il riepilogo. Il CSV dichiara come **raccolti e non condivisi**:
  - nome, email e ID utente (login Google);
  - foto: è la foto del profilo Google, non le etichette, che restano sul telefono;
  - contatti: le email delle persone invitate;
  - contenuti generati dall'utente: cantina, bevute, note;
  - interazioni con l'app;
  - log degli arresti anomali e dati diagnostici (Crashlytics);
  - ID dispositivo.
- [ ] **Decisione da prendere: Open Food Facts.** Il CSV **non** dichiara nessuna condivisione. La tabella di `docs/release-checklist.md` §2 dice invece che testo cercato, parole dell'etichetta e codici a barre vanno a Open Food Facts insieme all'IP. Google esclude dalla «condivisione» i trasferimenti avviati dall'utente che l'utente si aspetta, e la ricerca online è una sua azione esplicita. Il consiglio prudente è comunque dichiararla: in Console spunta «Attività nell'app → Cronologia delle ricerche in-app», condivisa, per funzionalità dell'app. Dichiarare di più non costa nulla, mentre una mancata dichiarazione può far respingere la revisione.
  - **Crittografati in transito:** sì.
  - **Cancellazione:** sì, nell'app e all'URL `https://brunobottazzini.github.io/Vinoozy/account-deletion/`.
  - **Cronologia acquisti e ID pubblicità:** non dichiarare nulla per ora (acquisti e annunci sono spenti). Vanno aggiunti **prima** di accendere gli acquisti o la pubblicità (`docs/release-checklist.md` §2).
- [ ] **ID pubblicità**: «No, l'app non usa l'ID pubblicità».
- [ ] **App governative**: no. **Funzionalità finanziarie**: nessuna. **Salute**: nessuna. **App di notizie**: no.
- [ ] **Autorizzazioni**: se la Console chiede una dichiarazione per una delle autorizzazioni presenti, scegli «funzionalità principale». Il manifest non chiede fotocamera, galleria né rubrica: le foto arrivano dal selettore di sistema o dalla condivisione.

### 2.3 Paesi e prezzo

- [ ] **Paesi/regioni** della release di produzione: Italia al primo rilascio, come previsto. Aggiungine altri quando vuoi.
- [ ] **Prezzo**: gratuita. Ricorda che un'app pubblicata come gratuita non può più diventare a pagamento; Plus sarà un abbonamento in-app.

### 2.4 Release di produzione

- [ ] Account personale creato dopo novembre 2023: Google chiede un **test chiuso con almeno 12 tester per 14 giorni consecutivi** prima di dare accesso alla produzione. Lo gestisci tu: nella Dashboard compare «Richiedi l'accesso alla produzione» quando i requisiti sono soddisfatti.
- [ ] Quando hai l'accesso: Test interno → release `0.2.1 (3)` → **Promuovi release → Produzione**, oppure crea la release in Produzione scegliendo l'app bundle già caricato.
- [ ] Note di rilascio: da `distribution/google-play/release-notes.txt`.
- [ ] Prima release in produzione: va bene il 100%, perché non ci sono utenti da proteggere. Dagli aggiornamenti successivi usa il rilascio graduale (20%, poi 100%).
- [ ] Invia per la revisione (Panoramica pubblicazione → «Invia modifiche per la revisione»). Di solito la revisione richiede da qualche ora a qualche giorno.

### 2.5 Prima di approvare la produzione

- [ ] Smoke test sul telefono con la build dal test interno: avvio, login Google, aggiunta di un vino, sincronizzazione. Il 11/11 l'avvio della 0.2.1 è stato verificato.
- [ ] Se una release cambia regole o indici di Firestore, prima esegui `firebase-deploy.yml` (`docs/release-checklist.md` §3). Per la 0.2.1 è già fatto.

## 3. Rimandato (non serve per la prima pubblicazione)

- Plus in vendita: passaggio a Blaze con le protezioni (`docs/blaze-switch.md`), pubblicazione delle funzioni, prodotto `vinoozy_plus` in Play Console, `purchasesEnabled`, aggiornamento della Sicurezza dei dati (`docs/plus-setup.md`).
- Limite di 15 vini: prima `migrate_capacity.mjs`, poi `capacityLimitEnabled`.
- Pubblicità: dopo circa 2 settimane di misure. Bisogna rimettere AD_ID, dichiarare annunci e ID pubblicità in Console, configurare il consenso UMP in AdMob e poi `adsEnabled`.
- `release.yml` e `promote.yml` non hanno i segreti GitHub (chiave di firma, account di servizio Play): per ora carichi e promuovi a mano.
