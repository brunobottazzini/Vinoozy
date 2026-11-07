# Infrastructure Design — u6-label-recognition — Domande

Contesto:
- design non funzionale di U6 approvato (`logical-components.md`, `security-design.md`, `performance-design.md`);
- `functional-spec.md` di U6, `components.md`, `contract-summary.md`;
- infrastruttura esistente: `ci.yml` (job `format`, `analyze`, `unit` con `tool/check_release_build.sh`, `estimation`, `rules`, `e2e`), `release.yml`, `promote.yml`, `firebase-deploy.yml`, `docs/release-checklist.md`.

Non ci sono domande aperte: U6 gira tutta sul telefono. Le decisioni sono riassunte qui sotto per conferma.

## Consolidated Summary Confirmation

- **Infrastruttura:** nessuna risorsa nuova nel cloud.
  - Niente regole, niente indici, niente pubblicazione di `firebase-deploy.yml`.
  - Cambia solo l'app: tre librerie nuove, il codice Android per le immagini, il filtro di condivisione nel manifest.
  - Costo 0 €.
- **Pubblicazione:** come sempre. Merge su `main`, build sul test interno, prova sul telefono, promozione con la tua approvazione. Non serve un ordine con le regole, perché U6 non ne cambia.
- **Controlli automatici in `ci.yml`, nessun job nuovo:**
  - `analyze`: controllo degli ID BR1.1–BR1.15 nei test e dello script che vieta Firestore in `lib/label/`;
  - `unit`: copertura dell'80% su `lib/label/`; dentro `tool/check_release_build.sh`, il controllo del manifest finale (nessun permesso di fotocamera o foto, condivisione solo di immagini);
  - `e2e`: il test con le immagini di prova generate da noi e la lettura vera sull'emulatore. Un emulatore senza Google Play va bene, perché i modelli sono inclusi.
- **Monitoraggio:**
  - nessun avviso nuovo;
  - gli errori arrivano in Crashlytics senza email, con i 4 motivi fissi;
  - nel controllo mensile si guarda anche `label_read_failed`. Se cresce, vuol dire che le etichette non si leggono bene.
- **Checklist di rilascio, nuova sezione §1-sexies "Foto dell'etichetta":**
  - tempi (foto → proposta con e senza rete);
  - riconoscimento su 20 etichette reali (almeno 14);
  - importazione dalla galleria e condivisione verso Vinoozy;
  - verifica che dopo una lettura nella cartella dell'app non resti nessuna foto;
  - dimensione dell'app con `bundletool` (al più +15 MB);
  - HEIC non letto su Android più vecchi della versione 9.
  
  Inoltre:
  - §1-bis e §2: codice e parole lette verso Open Food Facts, foto non raccolte, dati di ML Kit verificati sulla guida di Google con data, informativa aggiornata;
  - una voce per la prima build iPhone: spiegazioni dei permessi tradotte.
- **Rollback:** solo dell'app. Si ferma il rilascio graduale e si pubblica una correzione; nessun dato da sistemare.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
