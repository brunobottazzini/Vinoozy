# Performance Design — u7-sharing

Fonti: `performance-requirements.md` (NFR2.1–NFR2.4, NFR5.1–NFR5.3), `tech-stack-decisions.md` (stima delle letture, helper del test end-to-end), `functional-spec.md` di U7, `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`.

Per un'unità di interfaccia non esistono file separati `scalability-requirements.md`, `reliability-requirements.md` e `observability-requirements.md`:
- la scala è fissata nei requisiti di prestazioni: 500 vini, 2 persone invitate per cantina (da 5 a 2 il 2026-11-06), fino a 6 cantine visibili;
- l'affidabilità è in `security-requirements.md` (NFR6);
- l'osservabilità, cioè avvisi e controllo mensile, è nel design dell'infrastruttura.

## 1. Tempi delle operazioni (NFR2.1)

- Ogni operazione è **un solo** `WriteBatch` con 1 o 2 documenti: `members` più, se serve, la cantina per il contatore. Un solo viaggio verso il server, nessuna lettura preventiva oltre a quella del documento `members` già in cache.
- `commit().timeout(10 s)` dà il tempo massimo. Il pulsante mostra un indicatore e ignora i doppi tocchi.
- **Misura sul telefono:** 5 prove per operazione con il progetto di produzione, cronometrate dal tocco all'esito con un `Stopwatch` nei log di debug delle build di profilo. La mediana va nella checklist.

## 2. Comparsa e aggiornamento delle cantine condivise (NFR2.2, NFR2.3)

- `myMembershipsProvider` parte appena l'utente è collegato, in parallelo alla cantina personale, così la ricerca degli inviti non rallenta l'avvio.
- L'attivazione degli inviti `invited` è un batch che non blocca l'interfaccia: la cantina compare nel selettore appena l'invito è `active` nella cache locale, quindi subito dopo la scrittura.
- Revoca e cambio di permesso arrivano dall'ascolto, già aperto, senza attese di polling.
- **Test end-to-end** (`integration_test/sharing_test.dart`):
  1. il proprietario `userA` agisce via REST con il proprio token dell'emulatore di Auth (nuovo helper `ownerRestClient()` in `e2e_helpers.dart`);
  2. l'app è `userB`;
  3. ogni attesa usa `pumpUntil(..., timeout: 15 s)`, e oltre quel tempo il test fallisce.

  Sequenza: invito → comparsa della cantina → passaggio a `edit` e aggiunta di un vino → revoca → sparizione e avviso.

## 3. Cambio di cantina (NFR2.4)

- Il Cruscotto e la Cantina ascoltano `winesStreamProvider(activeCellarId)`.
- Quando il valore cambia, il provider della cantina precedente si chiude (`autoDispose`) e quello nuovo parte dalla cache di Firestore.
- Lo scheletro di caricamento di U1 e U5 copre il primo caricamento di una cantina mai aperta.

## 4. Costo (NFR5.1–NFR5.3)

- **Ascolti** sempre aperti per utente:
  - quello sui propri inviti;
  - quelli della cantina attiva (vini e documento della cantina).

  `cellarMembersProvider` si apre solo nella schermata "Persone" del proprietario, con `autoDispose`.
- **Nessun ascolto tenuto vivo in più:** con l'uso previsto al lancio non serve (stima in `tech-stack-decisions.md`). Se il monitoraggio mostra letture vicine all'avviso, la prima misura sarà tenere vivo per 30 minuti l'ascolto della cantina appena lasciata (`ref.keepAlive()` con un timer), così un ritorno rilegge solo le modifiche.
- **Regole:** al più 2 accessi per percorso e 4 per batch di gestione, entro il limite di 3 di NFR5.2 (tabella in `security-design.md` §1).
- **Test del conteggio degli ascolti** (NFR5.1): un repository finto (`mocktail`, già usato) sostituisce gli stream dei provider e conta le sottoscrizioni aperte. Nessuna dipendenza nuova. Al cambio di cantina resta lo stesso numero, e l'apertura di "Persone" ne aggiunge uno che si chiude all'uscita dalla schermata.

## 5. Misure

| Misura | Dove | Soglia |
|---|---|---|
| Esito delle operazioni | Telefono, 5 prove per operazione, checklist | mediana ≤ 3 s; massimo 10 s nel codice |
| Comparsa della cantina condivisa | Telefono, 3 prove; `sharing_test.dart` in CI | ≤ 5 s sul telefono; ≤ 15 s in CI |
| Revoca visibile | Due telefoni, 3 prove; `sharing_test.dart` in CI | ≤ 5 s sul telefono; ≤ 15 s in CI |
| Cambio di cantina dalla cache | Test dei widget | ≤ 1 s |
| Ascolti aperti | Test del provider | 1 + quelli della cantina attiva |
| Letture giornaliere del progetto | Monitoraggio (design dell'infrastruttura) | avviso a 35.000 |
