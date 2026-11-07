# Security Design — u3-wine-catalog

Fonti: `security-requirements.md` (NFR4.1–NFR4.6, NFR8.1, NFR8.2), `observability-requirements.md` (NFR8.3), `rules.md` di U3 (BR4.1, BR5.1–BR5.3), `logical-components.md`, riepilogo confermato in `nfr-design-questions.md`.

## 1. Richieste verso OFF (NFR4.1, NFR4.2)

- **Host fisso:** `CatalogConfig.offHost = 'world.openfoodfacts.org'`, una costante del codice di produzione. Gli URL si costruiscono con `Uri.https(host, path, queryParameters)`, che codifica i parametri. Nessun pezzo dell'URL viene dall'utente, a parte i valori dei parametri.
- **Percorsi usati**, solo lettura:
  - ricerca: `/cgi/search.pl`, con il testo, il filtro sulla categoria vini, `json=1`, `page_size=10`, la lingua preferita e i soli campi necessari (`fields=code,product_name,brands,categories_tags,origins`);
  - prodotto: `/api/v2/product/<codice>.json`, con lo stesso elenco di campi.
- **Niente redirect:** ogni richiesta è una `http.Request` con `followRedirects = false`, inviata con `Client.send`. Una risposta 3xx è un errore.
- **Lettura a flusso:** si leggono i byte di `StreamedResponse.stream` sommando le lunghezze. Oltre 1 MB si interrompe la lettura e l'esito è un errore `tooLarge`.
- **Dati inviati:** solo i parametri sopra e l'header `User-Agent`. `cellarWines` non arriva mai all'adattatore, perché il coordinatore lo usa solo per il catalogo interno.

- **Una sola scadenza di 5 secondi** per tutta la richiesta: invio, attesa della risposta e lettura del corpo. Allo scadere si annulla l'iscrizione al flusso (`StreamSubscription.cancel`), così il corpo non viene più letto, e l'esito è `timeout`.

```dart
// Illustrative only
final request = http.Request('GET', uri)
  ..followRedirects = false
  ..headers['User-Agent'] = config.userAgent;
final outcome = await _fetch(request).timeout(
  const Duration(seconds: 5),
  onTimeout: () { _subscription?.cancel(); return const Failure('timeout'); },
); // _fetch = send + capped streamed read (1 MB)
```

Dopo il timeout il `Future` interno di `_fetch` può ancora completarsi o fallire. Il suo risultato si ignora, ed eventuali errori si intercettano con `catchError` all'interno di `_fetch`, così non diventano errori non gestiti. Il client HTTP resta lo stesso per tutta la sessione e si chiude solo quando si chiude il provider.

## 2. Contatto e accensione di OFF (NFR4.3)

- `CatalogConfig.offContact = String.fromEnvironment('OFF_CONTACT')` è vuoto per default. `userAgent = 'Vinoozy/<versione> (<contatto>)'`, con la versione letta all'avvio da `package_info_plus` (nuova dipendenza, vedi `logical-components.md`, Risorse condivise).
- **OFF spento:** se il contatto è vuoto, il provider non crea `OpenFoodFactsSource` e tutte le operazioni restano interne.
- **Dove sta il contatto:** solo in `config/firebase_prod.json` (mai committato), che `release.yml` ricostruisce dal segreto esistente. Il proprietario lo aggiunge al segreto prima della pubblicazione (BR5.3).
- **Controllo in CI:** nuovo passo nel job `analyze`, `tool/check_off_config.sh`, che fallisce se:
  1. un file tracciato da git, compresi quelli in `.github/workflows/`, contiene `OFF_CONTACT` con un valore, cioè il nome seguito da `=` o `:` e da un testo non vuoto. Sono esclusi lo script stesso e i documenti di progetto in `aidlc/` e `docs/`;
  2. un file `.dart` in `lib/`, esclusi quelli generati delle traduzioni (`lib/l10n/`), contiene un indirizzo email (espressione `[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}`);
  3. un file in `lib/catalog/` importa `cloud_firestore` o `cloud_functions` (NFR5.1).

## 3. Risposte non fidate (NFR4.4)

- Parsing con controllo dei tipi: un campo si usa solo se è del tipo atteso, altrimenti si considera assente.
- Pulizia: si tolgono i caratteri di controllo (U+0000–U+001F, U+007F–U+009F) e si accorciano i campi (nome 120, produttore 80, regione e denominazione 60 caratteri). Un prodotto senza nome valido si scarta.
- Il JSON non valido è un errore (`invalidJson`).
- Mostrare i dati è compito di U4 e U6, sempre con widget di solo testo, mai HTML o link.

## 4. Validazione degli ingressi (NFR4.5)

`CatalogCoordinator` controlla gli ingressi prima di tutto e lancia `CatalogArgumentError` con il codice `queryTooShort`, `queryTooLong`, `textTooLong` o `invalidBarcode`. L'errore porta solo il codice e un messaggio fisso in inglese, mai il valore ricevuto, così non può portare testo dell'utente in un log (NFR8.3). Nessun'altra eccezione esce dal modulo.

## 5. Dati sul telefono (NFR8.1)

- `catalog_cache.json` sta nella cartella di supporto dell'app (`getApplicationSupportDirectory()` di `path_provider`).
- **Esclusione dal backup: già garantita da U1, nessuna modifica.** Il manifest ha `android:allowBackup="false"`, `android:fullBackupContent="false"` e `android:dataExtractionRules="@xml/data_extraction_rules"`. Il file `data_extraction_rules.xml` esclude tutti i domini, `file` compreso, sia dal backup cloud sia dal trasferimento tra dispositivi. `getApplicationSupportDirectory()` su Android sta nel dominio `file`, quindi `catalog_cache.json` è già escluso. U3 non tocca né il manifest né le regole.
- **Controllo di non regressione:** un test di U3 (`test/catalog/backup_rules_test.dart`) legge il manifest e `data_extraction_rules.xml` e verifica `allowBackup="false"` e l'esclusione del dominio `file` in `cloud-backup` e in `device-transfer`. Se un giorno U1 cambiasse le regole, il test fallirebbe.
- **Cancellazione (`clear()`):** vedi `reliability-design.md`, "Cancellazione sicura". La innesca `catalogSessionProvider`, che ascolta l'utente collegato di U1: a ogni cambio di uid (uscita o cambio di account) chiama `clear()` prima di servire qualunque richiesta del nuovo utente. U8 la chiamerà anche alla cancellazione dell'account.

## 6. Attribuzione ODbL (NFR4.6)

- Ogni proposta mappata da OFF ha `source = openFoodFacts`.
- Nei file di traduzione si aggiunge la chiave `offAttribution` ("Dati da Open Food Facts (ODbL)" e traduzioni), più la costante `offLicenseUrl`. U4 e U6 le usano accanto alle proposte, e la schermata delle informazioni ha una voce fissa.

## 7. Prima della pubblicazione (NFR8.2)

Righe nuove in `docs/release-checklist.md`:
- `OFF_CONTACT` configurato nel segreto di produzione;
- informativa privacy aggiornata;
- scheda "Sicurezza dei dati" di Google Play aggiornata;
- voce di attribuzione presente nell'app.

## Rischi residui

| Rischio | Gravità | Mitigazione |
|---|---|---|
| OFF cambia formato o percorsi | Media | Parsing difensivo; i risultati interni restano; test con risposte registrate |
| OFF blocca l'IP per abuso | Bassa | Budget per telefono sotto i limiti pubblicati, circuit breaker, nessun nuovo tentativo |
| Contatto pubblicato per errore | Bassa | Controllo in CI, configurazione solo nei segreti |
