# Observability Design — u3-wine-catalog

Fonti: `observability-requirements.md` (NFR6.6–NFR6.8, NFR8.3), `reliability-design.md`, `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`.

## Registratore iniettato

```dart
// Illustrative only
abstract interface class CatalogEventLogger {
  void offSuspended(OffFailureKind lastFailure, CatalogHealth health);
}
```

- **Produzione:** `CrashlyticsCatalogEventLogger` registra un errore non fatale con messaggio fisso `off_suspended`, l'unico evento del modulo. Usa le chiavi personalizzate `off_last_failure` (tipo), `off_ok`, `off_failed`, `cache_hit_ratio` e `cache_resets`, cioè i contatori di sessione di `CatalogHealth`. Nessun URL, testo cercato, testo dell'etichetta o codice a barre: le firme dei metodi accettano solo enum e numeri, quindi non possono riceverli.
- **Test:** un registratore finto conserva gli eventi. I test passano valori marcatori come query e verificano che non compaiano in nessun campo registrato (NFR8.3).
- **Log di debug:** il registratore riceve un flag `debugLogging`, impostato dal provider con `kDebugMode`, così il nucleo non dipende da Flutter. Con il flag attivo stampa solo nomi di eventi ed esiti, mai testi dell'utente; in release non stampa nulla.

## Metriche di salute (NFR6.7)

`CatalogHealth` conta, per la sessione, le richieste a OFF riuscite (`found` e `notFound`), quelle fallite e la quota di risposte dalla cache. Si invia solo insieme a un evento, mai da sola, così resta a costo zero e senza tracciamento continuo.

## Soglia di attenzione (NFR6.8)

Nella checklist mensile di `docs/release-checklist.md`: "Crashlytics, ultimi 7 giorni: `off_suspended` con più di 20 eventi o più di 3 utenti coinvolti, allora valutare la fonte o i limiti di OFF". È un controllo manuale, senza costi né avvisi automatici.

## SLI di riferimento

| Indicatore | Fonte | Valore atteso |
|---|---|---|
| Sospensioni di OFF a settimana | Crashlytics `off_suspended` | ≤ 20 |
| Utenti coinvolti dalle sospensioni a settimana | Crashlytics | ≤ 3 |
| Reset della cache | chiave `cache_resets` negli eventi `off_suspended` | 0; se compare spesso si indaga |
