# Requisiti di osservabilità — riconoscimento delle etichette

## Fonti

- `codekb/Vinoozy/`: `CatalogEventLogger`, `ConsoleCatalogEventLogger` e `CrashlyticsCatalogEventLogger` in `lib/catalog/platform/crashlytics_catalog_event_logger.dart`, con l'evento `off_suspended`.
- `construction/functional-design/rules.md` (BR3.1, BR3.4, BR4.3, BR5.2).
- `docs/release-checklist.md` (scheda "Sicurezza dei dati", controlli Crashlytics dopo il rilascio).

## Contesto

In release l'app manda già a Crashlytics, come errori non fatali anonimi, gli eventi di guasto del catalogo (`off_suspended`). Le firme dei metodi accettano solo enum e numeri. La scheda "Sicurezza dei dati" dichiara già i "Rapporti di crash (Crashlytics, anonimi)". Non c'è un servizio di analisi dell'uso e non se ne aggiunge uno.

## Requisiti

| ID | Requisito | Verifica |
|---|---|---|
| NFR4.13 | Eventi informativi nuovi, **solo in console** (`ConsoleCatalogEventLogger`, visibili con `adb logcat` quando il log di debug è attivo), mai mandati a Crashlytics: `wine_db_opened` (numero di vini, durata in ms), `label_outcome` (tipo di esito, gradino che ha deciso), `online_search` (numero di risultati offline e online, limite raggiunto sì/no), `lens_opened` (via diretta o menu Condividi). | test unitari: `CrashlyticsCatalogEventLogger` non chiama Crashlytics per questi eventi |
| NFR4.15 | Un solo evento nuovo verso Crashlytics, come errore non fatale: `wine_db_unavailable`. Il motivo è un enum chiuso (`missing`, `corruptGzip`, `noValidRows`, `unexpected`) e c'è come chiave un solo numero, le righe scartate. | test unitario con Crashlytics finto: chiavi e valori ammessi |
| NFR4.14 | Nessun evento, in console o su Crashlytics, contiene il testo letto, la foto, il codice a barre, la query di "Cerca online" o dati dell'utente: le firme dei metodi accettano solo enum e numeri, come oggi. | revisione delle firme + test |
| NFR3.9 | Il nuovo evento rientra nella voce "Rapporti di crash (Crashlytics, anonimi)" già dichiarata nella scheda "Sicurezza dei dati": nessun tipo di dato nuovo. La checklist dopo il rilascio aggiunge il controllo di `wine_db_unavailable`: più di 10 eventi o più di 3 utenti in 7 giorni → si controlla il file della base nella build. | voce in `docs/release-checklist.md` |
| NFR6.7 | La schermata Informazioni mostra numero di vini e data della base (BR6.3), così il proprietario vede subito se la base è caricata e quanto è vecchia. | test dei widget |

## Motivazioni

- Gli eventi informativi in console bastano per misurare NFR2.3 sul telefono durante le prove. Mandarli a Crashlytics li farebbe diventare dati d'uso, una categoria che oggi non dichiariamo.
- `wine_db_unavailable` va invece su Crashlytics perché indica una build difettosa. Va visto anche quando il proprietario non ha il telefono collegato.
