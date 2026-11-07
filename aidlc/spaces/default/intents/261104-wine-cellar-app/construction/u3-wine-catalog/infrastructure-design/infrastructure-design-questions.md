# Infrastructure Design — u3-wine-catalog — Domande

Contesto: design non funzionale di U3 approvato (`logical-components.md`, `security-design.md`, `performance-design.md`, `reliability-design.md`, `observability-design.md`, `scalability-design.md`), `components.md`, `functional-spec.md`, `contract-summary.md`, workflow `ci.yml` e `release.yml` esistenti.

Nessuna domanda aperta. U3 sta dentro l'app e non ha risorse cloud proprie. Le decisioni sono riassunte qui sotto per conferma.

## Nota dopo la revisione

Nel riepilogo confermato c'era scritto che OFF si spegne "senza nuova versione". Non è esatto: tolto il contatto dal segreto dell'ambiente `play-internal`, serve comunque una nuova build (un push su `main`), che passa dal test interno e poi dalla produzione graduale. Il codice non cambia. È corretto in `cicd-pipeline.md` §4.

## Consolidated Summary Confirmation

- **Infrastruttura:** nessuna risorsa nuova su Firebase o nel cloud. L'unico servizio esterno è Open Food Facts, pubblico e gratuito. Costo 0 €.
- **Configurazione di produzione:** il contatto per Open Food Facts (`OFF_CONTACT`) si aggiunge al JSON di configurazione che `release.yml` già ricostruisce dal segreto di GitHub. Quando lo scegli, aggiorni tu il segreto `FIREBASE_PROD_DEFINES_JSON_B64`; il file di workflow non cambia.
- **Controlli automatici:**
  - nel job `analyze`, lo script `tool/check_off_config.sh`: nessun contatto committato, nessuna email nel codice, nessun Firestore nel catalogo, nucleo senza Flutter;
  - nel job `unit`, il benchmark del catalogo con `dart run` e i test del catalogo dentro la copertura di progetto (80%).
- **Monitoraggio:** l'evento `off_suspended` in Crashlytics, con il controllo mensile nella checklist (più di 20 eventi o più di 3 utenti in 7 giorni).
- **Rilascio e rollback:** come per il resto dell'app (test interno, poi produzione graduale). Se Open Food Facts dà problemi, si può spegnerlo senza nuova versione: basta togliere il contatto dal segreto e ricostruire. Tenerlo acceso o spento resta sempre sicuro.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
