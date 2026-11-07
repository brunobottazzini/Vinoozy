# Infrastructure Specification — u7-sharing

Fonti:
- `logical-components.md`, `security-design.md` e `performance-design.md` di U7;
- `components.md` (inception), `functional-spec.md` di U7, `contract-summary.md` (C3, C4);
- `firebase.json`, `.github/workflows/firebase-deploy.yml`, `ci.yml`, `release.yml`, `docs/firebase-setup.md`;
- riepilogo confermato in `infrastructure-design-questions.md`.

Per un'unità di interfaccia il design non funzionale non ha file separati `scalability-design.md`, `reliability-design.md` e `observability-design.md`:
- l'affidabilità è in `security-design.md` (§4);
- la scala è in `performance-design.md`: 500 vini, 2 persone invitate per cantina;
- l'osservabilità è descritta qui e in `monitoring-design.md`.

## 1. Risorse

| Risorsa | Cambia? | Dettaglio |
|---|---|---|
| Progetto Firebase `vinoozy-d6f45` (Auth, Firestore `europe-west8`, App Check, Crashlytics) | No | Nessun servizio nuovo e nessuna funzione nel cloud. |
| `firestore.rules` | Sì | Funzioni comuni, `members`, gruppo di collezioni, contatore `memberSlots`/`memberOpKey`, `wines` per le persone invitate ed eliminazione del proprietario, `drinkingRecords` (`security-design.md` §1). |
| `firestore.indexes.json` | Sì | `fieldOverrides` con l'indice su `members.inviteeEmail`, ambito `COLLECTION_GROUP`, ordine crescente. |
| `firebase.json` | No | Punta già a `firestore.rules` e `firestore.indexes.json`. |
| Workflow `firebase-deploy.yml` | No | Pubblica regole e indici su avvio manuale, con un tag `v*` o un commit di `main`, dopo l'approvazione dell'ambiente `firebase-prod`. |
| Segreti GitHub, ambienti | No | Nessuna configurazione nuova. |
| Cloud Monitoring | Sì, a mano | Un nuovo criterio di avviso sulle letture giornaliere (`monitoring-design.md`). È configurazione del progetto, non codice: si crea dalla console e si annota in `docs/firebase-setup.md` §7. |
| Telefono | Sì, piccola | La chiave `sharing.activeCellar.<uid>` in `shared_preferences`, cancellata nel reset. |

## 2. Costi e quote

- **Letture:** stima in `tech-stack-decisions.md` dei requisiti.
  - Per un gruppo di 3 persone con cantine piene e uso intenso, circa 9.700 al giorno.
  - Con l'uso occasionale previsto, una piccola frazione.
  - La quota gratuita di 50.000 al giorno vale per tutto il progetto.
- **Scritture:** poche decine al giorno per cantina, contro le 20.000 gratuite. Inviti e attivazioni sono eventi rari.
- **Indice sul gruppo di collezioni:** un indice su un campo occupa pochi byte per invito, trascurabile rispetto a 1 GB.
- **Cloud Monitoring:** un criterio di avviso con notifica email rientra nell'uso gratuito.
- **Totale:** 0 €/mese. L'avviso di spesa a 1 € (C6) resta.

## 3. Ambienti

| Ambiente | Regole e indice | Note |
|---|---|---|
| Locale e CI | Emulatore Firestore (`demo-vinoozy`) con `firestore.rules` del ramo | L'emulatore non richiede indici: il controllo `tool/check_firestore_indexes.sh` sostituisce la verifica. |
| Test interno e produzione | Progetto `vinoozy-d6f45`, pubblicati con `firebase-deploy.yml` | Ordine obbligatorio (§4). |

## 4. Pubblicazione

1. Merge su `main` con tutti i controlli verdi: `format`, `analyze`, `unit`, `rules`, `e2e`.
2. **Regole e indice:** il proprietario avvia `firebase-deploy.yml` con il commit di `main` o il tag `v*` e approva l'ambiente `firebase-prod`.
3. **Indice pronto:** nella console Firebase (Firestore → Indici → Esenzioni a campo singolo) lo stato dell'indice su `members.inviteeEmail` deve essere "Abilitato". Di solito bastano pochi minuti.
4. **App:** `release.yml` è già partito al merge e ha pubblicato la build sul test interno. Si fa la prova con due telefoni della checklist (§1-quater) e poi la promozione in produzione.

**Compatibilità:**
- Le regole nuove consentono al proprietario tutto ciò che consentivano prima, e in più l'eliminazione dei vini. L'app attuale continua a funzionare. Lo verificano i test `compat/` del job `rules`, che provano le regole nuove contro le scritture delle versioni pubblicate.
- La versione dell'app con la condivisione, invece, **non** deve andare in produzione prima delle regole: senza regole e indice la ricerca degli inviti fallisce. La cantina personale funziona comunque.

## 5. Sicurezza

- Nessun permesso Android nuovo: `share_plus` usa la condivisione di sistema, che non richiede permessi. Nessun permesso dei contatti (test sul manifest).
- Nessun segreto nuovo. Le email delle persone invitate stanno solo in Firestore, protette dalle regole (NFR4.5).
- La pubblicazione delle regole usa l'account di servizio esistente con i soli ruoli di `docs/firebase-setup.md` §4.

## 6. Rollback

| Cosa | Come | Effetto |
|---|---|---|
| App | Fermare il rilascio graduale in Play Console e pubblicare una correzione | Come per le altre unità. |
| Regole | Avviare `firebase-deploy.yml` con il tag precedente | Le regole precedenti non conoscono la condivisione. Se l'app con la condivisione è già in produzione:<br>• le persone invitate perdono l'accesso alle cantine condivise;<br>• **il proprietario** continua a usare la propria cantina come prima (vini, quantità), ma non può invitare, revocare né eliminare vini; le sue richieste vengono rifiutate con "Non puoi modificare la condivisione di questa cantina" o con l'errore di salvataggio di U1.<br>Per questo il rollback delle regole va accompagnato dal fermo del rilascio graduale dell'app. Nessun dato si perde: i documenti `members` restano e tornano validi con le regole corrette. |
| Indice | Nessuna azione | `firebase deploy --only firestore:indexes`, eseguito dal workflow senza `--force`, in modo non interattivo non cancella gli indici presenti nel progetto ma assenti dal file: li segnala e basta. Il comportamento si verifica al primo rollback di prova in un progetto di test, prima di farvi affidamento, e il risultato va annotato in `docs/firebase-setup.md`. Un indice in più non fa danni. |
| Dati | Nessuna migrazione | `memberSlots` e `memberOpKey` sono facoltativi; le cantine senza quei campi funzionano. |
