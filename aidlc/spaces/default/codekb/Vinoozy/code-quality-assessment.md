# Code Quality Assessment

Valutazione da sola lettura: nessun test, build o misura di copertura è stato eseguito in questa scansione. Le percentuali reali di copertura non sono note qui; sono note le soglie.

## Test Coverage

### Suites

| Suite | Dove | Strumento |
|---|---|---|
| Unit e widget dell'app | `test/` (per modulo) | `flutter test --coverage`, `mocktail` |
| Stima | `packages/estimation/test/` | `dart test` |
| Regole Firestore | `test/rules/` | `@firebase/rules-unit-testing` su emulatore |
| Cloud Functions | `functions/test/` | mocha su emulatori |
| Script del proprietario | `test/admin/` | `node --test` |
| Pagina web | `test/web/` | `node --test`, Playwright, c8 |
| Kotlin | `android/app/src/test/` | Robolectric, JaCoCo |
| End-to-end | `integration_test/` | `integration_test` su emulatore Android API 34 con emulatori Firebase |
| Prestazioni | `integration_test_perf/`, `benchmark/`, `packages/estimation/benchmark/` | Soglie di tempo |
| Script di CI | `tool/*_test.sh` | Ogni controllo ha il suo test su casi buoni e cattivi |

### Thresholds

| Ambito | Soglia | Controllo |
|---|---|---|
| App più `estimation`, tutte le righe, nessuna esclusione | 80% | `tool/check_coverage.sh 80 coverage/merged.lcov.info` |
| `lib/catalog/`, `lib/dashboard/`, `lib/sharing/`, `lib/cellar/`, `lib/label/`, `lib/account/`, ciascuno | 80% | `tool/check_coverage.sh 80 coverage/lcov.info <prefisso>` |
| `packages/estimation/lib` | 90% | Job `estimation` |
| `docs/account-deletion/account-deletion.js` | 80% | c8 |
| Codice Kotlin dell'etichetta | 80% | JaCoCo |

`tool/gen_coverage_helper.dart` importa ogni file di `lib/`, così un file senza test conta 0% invece di sparire dal rapporto. `lib/l10n/` non ha una soglia propria ma entra nella soglia totale.

### Localization Testing

- `test/helpers/ui_harness.dart` offre `pumpScreen` (lingua predefinita italiana) e `accessibilityMatrix`: per ogni lingua, scala del testo 1.0 e 2.0, tema chiaro e scuro, verifica assenza di overflow, contrasto, dimensione dei bersagli e presenza di etichette. Oggi sono 12 test per ogni schermata che la usa.
- Dodici file di test iterano su `testLocales`; gli altri test dei widget confrontano i testi italiani con `lookupAppLocalizations(const Locale('it'))`.
- `test/app/e2e_locale_test.dart` verifica che la lingua segua il telefono fuori dalle build E2E.
- I test end-to-end cercano testi italiani e girano con la lingua forzata.
- Non esiste un test che percorra tutti i messaggi di ogni lingua, né uno che confronti le chiavi tra i file ARB (il generatore segnala le chiavi mancanti solo se configurato).
- Nessuna prova di layout da destra a sinistra è stata trovata.

## Linting and Static Analysis

| Controllo | Configurazione |
|---|---|
| `dart format --set-exit-if-changed .` | Job `format` |
| `flutter analyze --fatal-infos` | `analysis_options.yaml` (`flutter_lints`); esclude `build/`, `android/`, `packages/`, `tool/fixtures/` |
| `dart analyze --fatal-infos` nel pacchetto | `packages/estimation/analysis_options.yaml` |
| `tsc` strict | `functions/tsconfig.json` |
| actionlint | Job `format` |
| gitleaks su tutta la cronologia | Job `secrets`, eccezioni in `.gitleaksignore` |

I file di localizzazione generati portano `// ignore_for_file: type=lint`.

## CI/CD

| Workflow | Innesco | Cosa fa |
|---|---|---|
| `ci.yml` | Ogni push e ogni pull request verso `main` | Sette job obbligatori: `format`, `secrets`, `analyze`, `unit` (limite 40 minuti), `estimation`, `rules`, `e2e` (limite 75 minuti) |
| `release.yml` | CI riuscita su `main` | AAB firmato sul canale di test interno |
| `promote.yml` | Manuale, con approvazione | Produzione con rilascio graduale; `halt` come rientro |
| `firebase-deploy.yml` | Manuale | Regole e indici Firestore |
| `functions-deploy.yml` | Manuale | Cloud Functions |
| `pages.yml` | Manuale | Pagine di privacy e cancellazione account |

Punti forti: azioni fissate per SHA, versione di Flutter fissata e verificata, nessun segreto nei job di CI, autenticazione senza chiavi verso Firebase, controlli che la build di rilascio non contenga i ganci E2E né gli strumenti di sviluppo.

## Documentation Quality

- `README.md` breve e corretto, con i comandi di sviluppo e le deviazioni dal piano.
- Guide operative in `docs/` (Firebase, GitHub Actions, Play Console, rilascio, passaggio a Blaze, Plus).
- Commenti di testata che spiegano il perché e citano le regole di origine: buona tracciabilità, a costo di riferimenti a documenti di progetto esterni al codice.
- I messaggi del modello ARB portano una descrizione con la regola d'origine, utile a chi traduce.

## Quick Assessment

| Aspetto | Giudizio | Evidenza |
|---|---|---|
| Chiarezza dei nomi | Buono | Nomi descrittivi e coerenti tra moduli |
| Dimensione dei file | Discreto | Alcuni file oltre 40 KB (vedi sotto) |
| Gestione degli errori | Buono | Reporter unico, errori di sincronizzazione mostrati alla radice, avvio con schermata di errore |
| Presenza di test | Buono | Suite per ogni strato e soglie bloccanti |
| Duplicazione | Discreto | Elenco delle lingue ripetuto in più punti |
| Codice morto | Buono | Nessun `TODO`, `FIXME` o `HACK` nei sorgenti |

## Technical Debt

| # | Debito | Dove | Effetto |
|---|---|---|---|
| 1 | Elenco delle lingue senza una sola fonte | Vedi `code-structure.md`, "Localization Touchpoints" | Ogni lingua nuova richiede modifiche coordinate in codice, test, strumenti, store e web |
| 2 | Classe `AppLocalizationsPt` in inglese, quasi senza test | `lib/l10n/app_localizations_pt.dart` | Righe non coperte che contano nella soglia |
| 3 | Nomi di paesi e regioni con un campo per lingua | `lib/cellar/domain/wine_origins.dart` | Il modello non scala oltre tre lingue senza cambiare struttura; dati e logica nello stesso file di 1.221 righe |
| 4 | Ripiegamento del testo solo per lettere latine | `foldOriginText` in `wine_origins.dart` | La ricerca dei paesi non funziona con nomi in altre scritture |
| 5 | Plurali solo con `=0`/`=1`/`other` | `lib/l10n/app_en.arb` | Corretti per le lingue attuali; le lingue con più categorie richiedono forme proprie |
| 6 | Frasi composte con `select` su nomi di campo | `guideWordUsedFor`, `guideUsedMark`, `guideSkippedNotice` | Genere e concordanza diversi per lingua |
| 7 | File generati versionati senza controllo di allineamento | `lib/l10n/`, job `analyze` | Un ARB modificato senza rigenerare può passare inosservato |
| 8 | Nessun file dei messaggi non tradotti | `l10n.yaml` | Un messaggio mancante appare in inglese senza avviso |
| 9 | Schede dello store e catture caricate a mano | `distribution/google-play/`, `tool/play_api.sh` | Lavoro manuale proporzionale al numero di lingue |
| 10 | File grandi | `lib/cellar/ui/add_wine_screen.dart`, `lib/cellar/data/wine_repository.dart`, `packages/estimation/lib/src/label_candidates.dart` | Più difficili da modificare in sicurezza |
| 11 | Indirizzo della privacy fisso sulla pagina italiana | `lib/account/account_providers.dart` | Chi usa un'altra lingua arriva sulla pagina italiana |
| 12 | `firebase-tools` fermo alla 14 | `package.json`, `README.md` | Debito dichiarato, legato a Java 17 |

## Risks for Adding Languages

Stime da verificare con una misura, non misure di questa scansione.

- **Copertura**: ogni lingua aggiunge una classe generata di circa 2.450 righe sorgente. Se restano non esercitate, la copertura totale scende; la soglia dell'80% non ammette esclusioni né riduzioni.
- **Tempo di CI**: la matrice di accessibilità cresce in proporzione al numero di lingue, dentro un job con limite di 40 minuti.
- **Lunghezza dei testi**: i test falliscono su un overflow a scala 2.0; lingue con parole lunghe possono far emergere difetti di layout.
- **Scritture non latine e direzione da destra a sinistra**: aree non provate oggi.
