# Scalability Requirements — u3-wine-catalog

Fonti: `requirements.md` (NFR2, NFR5), `rules.md` di U3 (BR2.1, BR2.3), riepilogo confermato in `nfr-requirements-questions.md`.

U3 gira su ogni telefono e non ha un server nostro: il carico non si somma da nessuna parte da noi. L'unico limite comune è quello di OFF, che vale per indirizzo IP, cioè per telefono.

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR2.1 | Cantine fino a 500 vini (NFR2) restano entro le soglie di velocità di `performance-requirements.md`, perché la ricerca interna è lineare sui vini passati. | Benchmark con 500 vini. |
| NFR2.2 | Ogni telefono resta sotto i limiti di OFF qualunque sia il numero di utenti: al massimo 8 ricerche e 60 letture di prodotto in 60 secondi (BR2.3), contro i 100 al minuto pubblicati da OFF per le letture e un limite più basso per la ricerca. | Test del budget: la nona ricerca in 60 secondi non parte e quella del sessantunesimo secondo parte. |
| NFR2.3 | La cache resta piccola anche nel caso peggiore: al massimo 200 voci, ciascuna con al massimo 10 proposte; campi troncati (nome 120, produttore 80, regione 60, denominazione 60 caratteri, codice 13). Indice dei profili al massimo 500 voci. Totale serializzato in UTF-8 sotto 3 MB nel caso peggiore, con tutti i campi al limite e caratteri da 4 byte; nell'uso normale sotto 200 KB. Le scritture su disco sono una alla volta, raggruppate al massimo ogni 2 secondi. | Test con 250 risposte al limite di lunghezza: restano 200 voci e la dimensione serializzata in byte UTF-8 è sotto 3 MB, anche con testi di caratteri da 4 byte. Test di due scritture contemporanee: nessuna perdita. |
| NFR5.1 | Costo 0 €: nessuna funzione cloud, nessuna lettura o scrittura di Firestore da U3, OFF gratuito (NFR5). L'unico servizio Firebase usato è Crashlytics, già presente da U1 e gratuito, solo per gli eventi di NFR6.6. | Ricerca nel codice: nessun riferimento a `cloud_firestore` o `cloud_functions` in `lib/catalog/`. Crashlytics si usa solo attraverso l'interfaccia di registrazione iniettata. |
