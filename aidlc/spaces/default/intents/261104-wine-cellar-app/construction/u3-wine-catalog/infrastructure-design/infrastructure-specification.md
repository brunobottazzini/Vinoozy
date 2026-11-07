# Infrastructure Specification — u3-wine-catalog

Fonti: `logical-components.md`, `security-design.md`, `scalability-design.md` (NFR Design di U3), `components.md` (WineCatalog, aggiornato il 2026-11-05), `functional-spec.md`, `contract-summary.md` (C1, C5), riepilogo confermato in `infrastructure-design-questions.md`.

U3 è un modulo dentro l'app Android (`lib/catalog/`). Non ha risorse cloud proprie: niente funzioni, database, bucket o code. Questo documento elenca cosa usa e dove sta la sua configurazione.

## Distribuzione

| Elemento | Dove gira | Chi lo gestisce | Note |
|---|---|---|---|
| Modulo `lib/catalog/` | Sul telefono, dentro l'app | U3 | Viaggia nel bundle firmato dell'app (`release.yml` di U1) |
| Funzioni di catalogo di C2 | Sul telefono, pacchetto `estimation` | U2 | Aggiunte compatibili, nello stesso bundle |
| `catalog_cache.json` | Cartella di supporto privata dell'app | U3 | Esclusa da backup e trasferimento dalle regole di U1 |

## Servizi esterni

| Servizio | Tipo | Uso | Costo | Limiti |
|---|---|---|---|---|
| Open Food Facts (`world.openfoodfacts.org`) | API pubblica HTTPS, senza chiave, dati ODbL | Ricerca dei vini per nome e lettura per codice a barre, solo in produzione | 0 € | 100 letture al minuto per prodotto, ricerca più limitata; U3 resta sotto con 8 ricerche e 60 letture al minuto per telefono |
| Firebase Crashlytics | Già usato da U1 | Solo l'evento `off_suspended` | 0 € | — |

Nessun nuovo servizio Firebase e nessun passaggio al piano Blaze per U3.

## Configurazione

| Valore | Dove | Ambienti | Note |
|---|---|---|---|
| `OFF_CONTACT` | Chiave nel JSON di configurazione di produzione (`config/firebase_prod.json`, mai committato), ricostruito da `release.yml` dal segreto `FIREBASE_PROD_DEFINES_JSON_B64` | Solo produzione | Senza contatto OFF è spento. Il proprietario lo aggiunge al segreto quando sceglie l'indirizzo |
| Host di OFF | Costante nel codice (`CatalogConfig.offHost`) | Tutti | Fisso, solo HTTPS |
| Versione dell'app | `package_info_plus` al momento dell'avvio | Tutti | Per l'identificativo della richiesta |

Per aggiornare il segreto il proprietario rigenera il JSON di produzione con la chiave in più, lo codifica in base64 e lo salva in GitHub nel segreto `FIREBASE_PROD_DEFINES_JSON_B64` dell'**ambiente `play-internal`** (Settings, Environments, `play-internal`), come descritto in `docs/firebase-setup.md` §5. L'effetto arriva con la versione successiva dell'app (`cicd-pipeline.md` §4). La procedura sarà in `docs/firebase-setup.md`, in una sezione nuova scritta in Code Generation.

## Dipendenze nuove dell'app

`http`, `path_provider`, `package_info_plus`, `crypto` in `pubspec.yaml` (ultime versioni stabili compatibili, fissate in `pubspec.lock`).

## Sicurezza

- Nessun segreto nel repository: `OFF_CONTACT` è un indirizzo di contatto, non un segreto, ma sta comunque solo nella configurazione di produzione per evitare chiamate dai test.
- Nessun permesso Android nuovo: `INTERNET` è già presente per Firebase.
- Il backup resta disattivato dalle regole di U1 (verificato da un test di U3).
