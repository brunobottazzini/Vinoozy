# Monitoring Design — u3-wine-catalog

Fonti: `observability-design.md` e `reliability-design.md` (NFR Design di U3), `infrastructure-specification.md`, riepilogo confermato in `infrastructure-design-questions.md`.

U3 non ha server. Il monitoraggio usa Crashlytics, già attivo da U1 e gratuito, ed è senza dati personali.

| Segnale | Fonte | Contenuto | Soglia | Azione |
|---|---|---|---|---|
| `off_suspended` | Errore non fatale in Crashlytics | Tipo dell'ultimo errore (`timeout`, `network`, `http_<codice>`, `too_large`, `invalid_json`) e contatori di sessione (`off_ok`, `off_failed`, `cache_hit_ratio`, `cache_resets`) | Più di 20 eventi oppure più di 3 utenti coinvolti in 7 giorni | Il proprietario valuta OFF: controlla lo stato del servizio, eventuali cambi di formato, e se serve lo spegne togliendo `OFF_CONTACT` dal segreto |
| Errori fatali nel catalogo | Crash in Crashlytics (già attivo da U1) | Stack trace senza testi dell'utente (i messaggi degli errori del catalogo sono fissi) | Qualsiasi crash con `lib/catalog/` nello stack | Correzione con una nuova versione |
| Reset della cache | Chiave `cache_resets` negli eventi `off_suspended` | Numero di reset nella sessione | Diverso da 0 su più utenti | Indagine sul file di cache. È un segnale parziale per scelta: arriva solo insieme a una sospensione, per non creare eventi in più. |

## Controllo mensile

Nuova riga nella checklist di `docs/release-checklist.md`, sezione mensile: "Crashlytics, ultimi 7 giorni: eventi `off_suspended` (soglia 20 eventi o 3 utenti) e crash con `lib/catalog/`". È un controllo manuale, senza avvisi automatici, per restare a costo zero.

## Cosa non si raccoglie

Nessun evento per ricerca, nessuna metrica continua, nessun testo cercato, testo dell'etichetta o codice a barre. I contatori di sessione arrivano solo insieme a un evento.
