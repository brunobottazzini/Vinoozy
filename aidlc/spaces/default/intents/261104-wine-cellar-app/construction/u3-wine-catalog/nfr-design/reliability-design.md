# Reliability Design — u3-wine-catalog

Fonti: `reliability-requirements.md` (NFR6.1–NFR6.4), `rules.md` di U3 (BR2.1, BR2.2), `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`.

## Esiti di una richiesta a OFF (NFR6.2)

`OpenFoodFactsSource` restituisce sempre un esito tipizzato e non lancia eccezioni:

| Esito | Quando | Effetto |
|---|---|---|
| `found(list)` | HTTP 200 con almeno un prodotto valido | In cache, azzera il conteggio degli errori |
| `notFound` | HTTP 404; HTTP 200 con `status: 0`; ricerca con zero risultati | In cache come lista vuota, azzera il conteggio degli errori |
| `failure(kind)` | `timeout`, `network`, `http_<codice>` (per esempio `http_429`, `http_503`, `http_301` per un redirect), `too_large`, `invalid_json` (gli stessi nomi di NFR6.6) | Non va in cache, conta per il circuit breaker |

## Circuit breaker (NFR6.2, NFR6.3)

- Stati: **chiuso** (OFF usabile) e **aperto** (OFF sospeso fino a un istante preciso).
- Da chiuso ad aperto: al terzo `failure` di fila. Si registra un solo evento `off_suspended` con il tipo dell'ultimo errore (`observability-design.md`).
- Da aperto a chiuso: quando l'orologio iniettato supera l'istante di fine sospensione, cioè 5 minuti dopo. La richiesta successiva è normale. Se fallisce, il conteggio riparte da 1.
- Un `found` o un `notFound` azzera il conteggio.
- Nessun nuovo tentativo: ogni operazione fa al massimo una richiesta a OFF.

## Senza rete (NFR6.1)

Non c'è un controllo preventivo della connessione: una richiesta senza rete fallisce subito con `network`, i risultati interni ci sono già e il circuit breaker conta l'errore. Dopo tre tentativi falliti senza rete OFF si sospende per 5 minuti e non si spreca batteria.

## Cache resistente ai guasti (NFR6.4)

- **Caricamento:** si legge `catalog_cache.json` e lo si decodifica. Se la lettura fallisce o il JSON non è valido, si cancella il file e si parte da una cache vuota. Non si registra un evento a parte: si incrementa il contatore `cacheResets` di `CatalogHealth`, che arriva in Crashlytics solo insieme a un eventuale `off_suspended`.
- **Scrittura:** ogni modifica segna la cache come "da salvare". Un timer di 2 secondi salva al massimo una volta per finestra. Il salvataggio scrive `catalog_cache.json.tmp` e lo rinomina in `catalog_cache.json`; la rinomina è atomica sullo stesso disco, quindi un'interruzione non lascia un file a metà. Le scritture sono serializzate: un solo salvataggio alla volta, e un nuovo salvataggio richiesto durante uno in corso parte dopo.
- **Errore di scrittura:** si ignora per l'operazione in corso, perché la cache in memoria resta valida, e si riprova al prossimo salvataggio.

## Cancellazione sicura (NFR8.1)

`CatalogCacheStore` ha un numero di **epoca**, che parte da 0.
- **`clear()`:**
  1. incrementa l'epoca;
  2. svuota la memoria;
  3. annulla il timer di salvataggio;
  4. attende la fine di un salvataggio in corso;
  5. cancella `catalog_cache.json` e `catalog_cache.json.tmp`.

  Dopo il passo 5 non resta nulla dell'utente precedente.
- **Salvataggi:** ogni salvataggio legge l'epoca all'inizio. Se prima della rinomina l'epoca è cambiata, cancella il `.tmp` e non rinomina.
- **Risposte di OFF in volo:** il coordinatore registra l'epoca quando parte la richiesta. Se la risposta arriva con un'epoca diversa, la scarta: non va in cache e non va al chiamante.
- **Chi la chiama:** `catalogSessionProvider` ascolta l'uid di U1 e chiama `clear()` a ogni cambio, prima di servire richieste del nuovo utente. U8 la chiama anche alla cancellazione dell'account.
- **Proprietario della cache:** il file contiene il campo `owner`, l'hash SHA-256 dell'uid di chi l'ha scritta, calcolato con `package:crypto` (già dipendenza indiretta di Flutter; si aggiunge in modo esplicito). Al caricamento il provider passa l'uid corrente. Se `owner` è diverso o manca, il file si cancella e si parte vuoti. Così una pulizia interrotta, per esempio con l'app chiusa subito dopo l'uscita, non serve mai la cache del vecchio utente al nuovo. Senza utente collegato il catalogo non carica la cache.
- **Attesa:** tutte le operazioni del coordinatore attendono la fine di un `clear()` in corso prima di leggere o scrivere la cache, con un `Future` di "pronto" che `clear()` sostituisce e completa alla fine. Un salvataggio richiesto durante la pulizia parte solo dopo, con la nuova epoca.

## Risposte fuori tempo

Lo scarto delle risposte arrivate quando la query è cambiata è compito di U4 (`reliability-requirements.md`, nota). U3 restituisce la risposta per la query ricevuta.
