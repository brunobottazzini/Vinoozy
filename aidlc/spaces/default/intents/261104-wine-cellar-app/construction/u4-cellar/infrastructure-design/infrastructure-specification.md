# Infrastructure Specification — u4-cellar

Fonti:
- `logical-components.md`, `security-design.md` e `performance-design.md` di U4;
- `components.md` (inception), `functional-spec.md` di U4, `contract-summary.md` (C3);
- `firebase.json`, `.github/workflows/firebase-deploy.yml`, `ci.yml`, `release.yml`, `promote.yml`, `docs/firebase-setup.md`;
- riepilogo confermato in `infrastructure-design-questions.md`.

Per un'unità di interfaccia il design non funzionale non ha file separati `scalability-design.md`, `reliability-design.md` e `observability-design.md`:
- la scala è in `performance-design.md`: 500 vini presenti, 1.000 finiti, 2.000 bevute;
- l'affidabilità è in `security-design.md` §4;
- l'osservabilità è descritta qui e in `monitoring-design.md`.

## 1. Deployment

| Aspetto | Scelta | Motivo |
|---|---|---|
| Calcolo | Nessuno nel cloud: tutta la logica (validazione, chiave dei doppioni, riscontro, filtri, backfill, riconciliazione) gira nell'app | Budget 0 € e nessuna Cloud Function (C6). |
| Rete | Invariata: l'app parla con Firestore e Auth tramite gli SDK, protetta da App Check | Nessun servizio nuovo. |
| Archiviazione | Firestore `europe-west8`, cache offline dell'SDK; sul telefono la chiave `cellar.pending.<uid>` in `shared_preferences` per `RecordReconciler` | Le operazioni rimaste a metà offline sopravvivono al riavvio (NFR6.6). |
| Ambienti | Emulatore (`demo-vinoozy`) in locale e in CI; progetto `vinoozy-d6f45` per test interno e produzione | Come team.md. |
| Configurazione come codice | `firestore.rules` e `firestore.indexes.json` nel repository, pubblicati con `firebase-deploy.yml` | Nessuna modifica dalla console. |
| Dimensioni | Nessuna da scegliere: Firestore scala da solo | — |

## 2. Risorse

| Risorsa | Ruolo | Configurazione | Note |
|---|---|---|---|
| Progetto Firebase `vinoozy-d6f45` (Auth, Firestore, App Check, Crashlytics) | Database e servizi | Invariato | Nessun servizio nuovo. |
| `firestore.rules` | Regole | Vini: `matchKey`, `baseWindow`, `windowAdjustment` con le funzioni di validazione e il caso del backfill. Bevute: `condition`, `updatedAt`, aggiornamento da chi l'ha registrata o dal proprietario, eliminazione entro 10 minuti o dal proprietario con `resource != null`. Cantina: `matchKeyBackfill` (`security-design.md` §1) | Compatibile con l'app attuale (§4). |
| `firestore.indexes.json` | Indice | Composito su `drinkingRecords`: `drankOn` DESCENDING, `createdAt` DESCENDING, ambito `COLLECTION` | Serve lo Storico a pagine (NFR2.3, NFR5.2). |
| `firebase.json` | Configurazione | Invariato | Punta già ai due file. |
| Workflow | Pubblicazione | `firebase-deploy.yml` invariato; `promote.yml`: `RULES_FEATURES: sharing cellar` | `cicd-pipeline.md`. |
| Segreti GitHub, ambienti | — | Invariati | Nessuna configurazione nuova. |
| Cloud Monitoring | Avvisi | Invariato | Restano l'avviso a 35.000 letture e quello sui rifiuti (`monitoring-design.md`). |

Nessuna risorsa condivisa nuova tra unità: U4 estende le raccolte `wines` e `drinkingRecords` già condivise con U1, U5 e U7. I contratti sono in `contract-summary.md` C3.

## 3. Costi e quote

| Voce | Stima | Quota gratuita |
|---|---|---|
| Letture dell'elenco | Solo i vini presenti (`quantity > 0`), all'apertura e poi le modifiche | 50.000 al giorno per progetto |
| Letture dello Storico | 30 bevute per pagina, solo quando si apre | — |
| Doppione | 1 query per salvataggio, di solito 0 o 1 documento | — |
| Backfill di `matchKey` | Una volta per cantina, su tutti i vini, compresi i finiti: al più 1.500 letture e 1.500 scritture in 4 parti da 400, più 1 scrittura del flag (NFR5.3) | 50.000 letture e 20.000 scritture al giorno |
| Miglioramento delle stime | Al più 20 vini per ritorno della rete | — |
| `PendingWritesProbe` | Nessuna lettura: usa `waitForPendingWrites()` | — |
| Indice composito | Pochi byte per bevuta | 1 GB |
| **Totale** | **0 €/mese**, avviso di spesa a 1 € (C6) invariato | — |

L'archivio dei vini finiti riduce le letture rispetto a oggi, perché l'elenco non legge più le bottiglie finite.

## 4. Pubblicazione e compatibilità

1. Merge su `main` con tutti i controlli verdi: `format`, `analyze`, `unit`, `estimation`, `rules`, `e2e`.
2. **Regole e indice:** il proprietario avvia `firebase-deploy.yml` con un tag `v*` o un hash completo di 40 caratteri e approva l'ambiente `firebase-prod`.
3. **Indice pronto:** nella console Firebase (Firestore → Indici → Compositi) l'indice di `drinkingRecords` deve risultare "Abilitato".
   - **Limite noto:** nessun workflow lo verifica, perché `firebase deploy` termina prima che l'indice sia costruito e leggere lo stato richiederebbe nuovi permessi. Il passo resta manuale nella checklist (§3), e la promozione richiede comunque l'approvazione del proprietario.
   - Se l'indice non è pronto, solo lo Storico è colpito: la query fallisce con `failed-precondition` e lo Storico mostra il messaggio di errore con "Riprova". Elenco, dettaglio e bevute funzionano.
4. **App:** `release.yml` ha già pubblicato la build sul test interno al merge. Si fa la prova della checklist (§1-quinquies), poi la promozione.

**Compatibilità:**
- Le regole nuove accettano le scritture dell'app attuale, che non manda i campi nuovi (sono tutti facoltativi). Lo verificano i test `compat/` nella direzione (1).
- L'app nuova **non** può andare in produzione prima delle regole: ogni creazione di vino porta `matchKey`, che le regole di oggi rifiutano. Il blocco è automatico in `promote.yml` (`cicd-pipeline.md` §2).
- Nessuna migrazione sul server. I vini senza `matchKey` ricevono la chiave dal backfill fatto dall'app la prima volta che apre la cantina (NFR5.3).

## 5. Sicurezza

- Nessun permesso Android nuovo e nessun segreto nuovo.
- Le note e i voti stanno solo in Firestore, letti con `canReadCellar`, e non finiscono nei report degli errori (NFR8.1, NFR8.2).
- La pubblicazione delle regole usa l'account di servizio esistente con i soli ruoli di `docs/firebase-setup.md` §4.

## 6. Rollback

| Cosa | Come | Effetto |
|---|---|---|
| App | Fermare il rilascio graduale e pubblicare una correzione | Come per le altre unità. |
| Regole, **prima** della promozione dell'app | `firebase-deploy.yml` con il tag precedente | Nessun effetto su chi usa l'app in produzione, che non manda i campi nuovi. |
| Regole, **dopo** l'inizio della promozione | **Non** si torna alle regole vecchie: si corregge in avanti, con nuove regole o una nuova versione dell'app | Play non ritira una build già installata. Con le regole vecchie, chi ha l'app nuova vedrebbe rifiutate le creazioni dei vini, le modifiche e le cancellazioni delle bevute e il backfill. Si ferma il rilascio graduale per non allargare il problema, e si pubblica la correzione. I dati salvati restano intatti. |
| Indice | Nessuna azione | Un indice in più non fa danni. |
| Dati | Nessuna migrazione da annullare | `matchKey`, `baseWindow`, `windowAdjustment`, `condition` e `matchKeyBackfill` sono facoltativi. |
