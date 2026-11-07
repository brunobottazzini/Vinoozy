# Scalability Design — u3-wine-catalog

Fonti: `scalability-requirements.md` (NFR2.1–NFR2.3, NFR5.1), `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`.

U3 scala con il numero di telefoni senza un server nostro: ogni telefono ha il suo catalogo, la sua cache e il suo budget. Il solo limite comune, quello di OFF, vale per indirizzo IP.

## Budget delle richieste (NFR2.2)

- `RequestBudget` tiene due code di istanti, una per le ricerche e una per i prodotti. Prima di ogni richiesta toglie gli istanti più vecchi di 60 secondi, secondo l'orologio iniettato. Se la coda ha già 8 ricerche o 60 prodotti, la richiesta non parte.
- Le risposte dalla cache non consumano budget. Il budget vive in memoria e riparte a ogni avvio dell'app; non serve salvarlo, perché i limiti di OFF sono al minuto.

## Dimensione della cache (NFR2.3)

- Al massimo 200 voci di risposta, ciascuna con al massimo 10 proposte, e 500 voci di indice dei profili. Quando si supera il limite si eliminano le voci con `storedAt` più vecchio.
- I campi si accorciano al momento della mappatura (`security-design.md` §3), quindi la cache non contiene mai campi più lunghi.
- Caso peggiore serializzato in UTF-8: sotto 3 MB. Nell'uso normale: sotto 200 KB.

## Cantine grandi (NFR2.1)

- La ricerca interna è lineare su denominazioni più `cellarWines` (al massimo 500). Oltre 500 vini il coordinatore usa i primi 500 ricevuti e U4 è responsabile dell'ordine. Il caso è oltre NFR2 e non si prevede.

## Costo (NFR5.1)

- In `lib/catalog/` non c'è nessun import di `cloud_firestore` né di `cloud_functions`: lo controlla `tool/check_off_config.sh` nel job `analyze` (`security-design.md` §2).
- Crashlytics si raggiunge solo da `CrashlyticsCatalogEventLogger`, l'implementazione di produzione del registratore.
