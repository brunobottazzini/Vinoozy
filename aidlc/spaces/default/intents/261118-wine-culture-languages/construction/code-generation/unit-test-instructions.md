# Istruzioni per i test — Lingue dei paesi del vino

## Framework e configurazione

- `flutter test` (pacchetto `flutter_test`), già configurato nel progetto; nessuna nuova dipendenza di test.
- `node` per `tool/check_publication.mjs`, già usato in CI.
- Versione di Flutter: quella fissata in `.flutter-version`.

## Come eseguire i test di questo lavoro

Prima generare il test dei messaggi (il file generato è ignorato da git):

```bash
dart run tool/gen_l10n_exercise.dart
```

Poi eseguire solo i test di questo lavoro:

```bash
flutter test test/app/locale_resolution_languages_test.dart test/app/language_consistency_test.dart test/account/privacy_url_languages_test.dart test/cellar/domain/wine_origins_languages_test.dart test/catalog/core/catalog_locale_languages_test.dart test/l10n/languages_test.dart test/l10n/l10n_exercise_test.dart
```

Controllo dei testi della scheda di Google Play:

```bash
node tool/check_publication.mjs --draft
```

Prima del primo test nuovo, il runner si verifica sull'albero esistente con:

```bash
flutter test test/app/
```

## Test previsti (strategia Minimal: uno o più per requisito)

| File | Requisiti | Cosa controlla |
|---|---|---|
| `test/app/locale_resolution_languages_test.dart` | FR1.4, FR2.1 | Varianti regionali, `nn` e `no`, lingua non offerta, lista vuota |
| `test/app/language_consistency_test.dart` | FR1.1, FR2.2, NFR5 | Le stesse 25 lingue in elenco, ARB, codice generato, Android, store |
| `test/account/privacy_url_languages_test.dart` | FR5.1 | Indirizzo della privacy per italiano, portoghese del Brasile, lingua nuova, indirizzo configurato |
| `test/cellar/domain/wine_origins_languages_test.dart` | FR3.1, FR3.2, FR3.3 | Nomi dei paesi in 25 lingue, regioni tradotte con valore canonico stabile, ricerca in greco, cirillico, georgiano |
| `test/catalog/core/catalog_locale_languages_test.dart` | FR3.4 | Lingua passata al catalogo e ripiego sull'inglese |
| `test/l10n/languages_test.dart` | FR1.2, FR1.3, FR1.6, FR3.5, NFR3, NFR4 | Chiavi e segnaposto degli ARB, lingua con i testi più lunghi, schermata mostrata nelle 15 lingue fuori matrice, termini non tradotti, date e numeri |
| `test/l10n/l10n_exercise_test.dart` (generato) | FR1.5, NFR1, NFR4 | Ogni messaggio in ogni lingua; plurali con 0, 1, 2, 5, 21 |
| `node tool/check_publication.mjs --draft` | FR4.1 | Presenza e lunghezza dei testi dello store nelle 25 cartelle |

FR4.2 e NFR6 sono documenti (`docs/store-languages.md`, `docs/l10n-glossary.md`): si controllano leggendo i file. FR2.2 sul telefono è una verifica manuale sulla build del canale di test interno.

## Copertura attesa

- Soglia di progetto: almeno l'80% delle righe su tutto il codice, senza esclusioni, codice generato compreso (regola di squadra). La misura Build and Test sull'intera suite con `tool/check_coverage.sh`; i comandi qui sopra non la giudicano e la soglia non si modifica.
- Il test generato dei messaggi serve a coprire le circa 2.450 righe generate per ogni lingua.

## Finti e dati di prova

- Nessun servizio esterno: i test del catalogo usano i finti già presenti sotto `test/catalog/` per Open Food Facts.
- I test dei widget usano `pumpScreen` di `test/helpers/ui_harness.dart`.
- I test di coerenza leggono i file del repository (`lib/l10n/*.arb`, `android/app/src/main/res/xml/locales_config.xml`, `distribution/google-play/languages.json`) con percorsi relativi alla radice del progetto.
- Nessun dato da preparare o ripulire.
