# Performance Requirements — u4-cellar

Fonti: `requirements.md` (NFR1, NFR2, NFR5), `functional-spec.md` di U4 (BR1.1, BR1.4–BR1.7, BR1.16, BR1.18), requisiti di U1 (NFR1.1, NFR5.1, NFR5.2) e di U3 (tempi dei suggerimenti), riepilogo confermato in `nfr-requirements-questions.md`.

**Scala di riferimento:**
- cantina di 500 vini presenti e fino a 1.000 vini finiti;
- 2.000 bevute;
- telefono di riferimento Android di fascia media, come in U1.

## Tempi

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR1.1 | **Inserimento (NFR1):** dal tocco su "Aggiungi" al salvataggio di un vino presente nei suggerimenti, mediana di 10 prove **< 30 s**. | Misura manuale sul telefono di riferimento, una volta per versione, annotata nella checklist. In CI, un test dei widget verifica il percorso minimo: nome attivo all'apertura, una proposta toccata, "Salva" senza altri passi. |
| NFR1.2 | **Suggerimenti interni** (catalogo interno e vini della cantina) visibili entro **300 ms** dalla pausa di scrittura (attesa di 250 ms più il calcolo). Open Food Facts aggiunge le sue proposte quando arrivano, senza bloccare. | Test dei widget con orologio finto per l'attesa; il benchmark di U3 copre il calcolo dei suggerimenti interni. |
| NFR1.3 | **Salvataggio:** il ritorno all'elenco con il vino visibile avviene entro **300 ms** sul telefono di riferimento, senza aspettare la rete né il catalogo. | Misura manuale (NFR1.1 di U1). Test: il salvataggio non attende `getWineProfile`. |
| NFR2.1 | **Ricerca e filtri** su 500 vini: risultato entro **100 ms** sul telefono. | Benchmark `benchmark/cellar_benchmark.dart`, aggiunto al job `unit` di `ci.yml` con `dart run`: misura "filtri", mediana di 10 dopo 3 di riscaldamento, una ripetizione se sfora, soglia di **20 ms** su `ubuntu-latest`. |
| NFR2.2 | **Dettaglio:** si apre entro **500 ms**, dalla cache per un vino presente, con una lettura per un vino finito. | Test dei widget; misura manuale nella checklist. |
| NFR2.3 | **Scorrimento** della Cantina con 500 vini e dello Storico con 2.000 bevute fluido: 99° percentile dei frame sotto il periodo dello schermo. | `integration_test_perf/cellar_perf_test.dart` con `FrameTimingSummarizer`, una volta per versione. |
| NFR2.4 | **Calcolo della finestra effettiva** (stima di base più riscontro) su 500 vini **< 20 ms** sul telefono. | Stesso benchmark, misura separata "finestra effettiva", con soglia propria di **5 ms** su `ubuntu-latest`. |

**Misure manuali** (NFR1.1, NFR1.3, NFR2.2, NFR2.3): si registrano nella nuova sezione §1-quinquies "Cantina" di `docs/release-checklist.md`, con la soglia accanto a ogni misura. Una versione va in produzione solo se le misure rientrano, oppure se il proprietario accetta per iscritto lo scostamento nella stessa sezione, come per il Cruscotto.

## Costo (NFR5)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR5.1 | **Elenco:** un solo ascolto, `where quantity > 0`, sulla cantina attiva. I vini finiti non si leggono nell'uso quotidiano. | Test del repository e del provider. |
| NFR5.2 | **Storico:** pagine di 30 bevute; la pagina successiva si legge solo scorrendo fino in fondo. | Test del provider con un repository finto. |
| NFR5.3 | **Doppioni:** una query per salvataggio, con al più 1 risultato atteso. Il backfill delle chiavi si fa una volta per cantina, su 1.500 vini alla scala dichiarata:<br>• batch da 400 aggiornamenti, scrivendo solo sui vini ancora senza `matchKey`;<br>• `matchKeyBackfill: true` si scrive **solo dopo l'ultima parte riuscita**;<br>• se si interrompe (app chiusa, rete persa), alla riapertura riparte e salta i vini che hanno già la chiave. | Test con 1.500 vini finti: 4 batch, flag scritto alla fine; interruzione dopo il secondo batch e ripresa senza riscritture. |
| NFR5.4 | **Miglioramento delle stime:** un vino per volta, nei limiti di U3 (8 ricerche e 60 letture di prodotto per minuto); al più 20 vini per ritorno della rete. | Test con orologio finto. |
| NFR5.5 | **Eliminazione:** il batch del vino con le sue bevute è diviso in parti di 400 operazioni. | Test con 900 bevute finte. |
