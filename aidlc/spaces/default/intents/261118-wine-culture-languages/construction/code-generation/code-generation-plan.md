# Piano di Code Generation — Lingue dei paesi del vino

## Summary

- Builds: 22 lingue nuove dell'interfaccia (25 in tutto), nomi di paesi e regioni per lingua, scelta della lingua dalle impostazioni di Android, testi della scheda di Google Play
- Touches: `lib/l10n/`, `lib/app/locale_resolution.dart`, `lib/cellar/domain/`, `lib/catalog/core/`, `lib/account/`, `android/app/src/main/`, `distribution/google-play/`, `test/`, `tool/`, `docs/`
- Tests: circa 14 test nuovi (unitari e dei widget), uno o più per requisito, più un test generato che richiama ogni messaggio in ogni lingua

## Contesto

- Requisiti: `aidlc/spaces/default/intents/261118-wine-culture-languages/inception/requirements-analysis/requirements.md` (FR1–FR5, NFR1–NFR6).
- Punti del codice toccati dalle lingue: `aidlc/spaces/default/codekb/Vinoozy/code-structure.md`, sezione "Localization Touchpoints".
- Lavoro senza Unit: un solo giro di implementazione, sul ramo corrente, senza commit (i commit li chiede il proprietario).
- Questo lavoro non ha user story (la fase è saltata): ogni passo rimanda ai requisiti che realizza.

## Le 25 lingue

| Lingua dell'app | File dei testi | Cartella Google Play |
|---|---|---|
| `en` | `app_en.arb` (modello) | `en-US` (esiste) |
| `it` | `app_it.arb` (esiste) | `it-IT` (esiste) |
| `pt-BR` | `app_pt_BR.arb` (esiste) | `pt-BR` (esiste) |
| `pt` | `app_pt.arb` (oggi vuoto: diventa portoghese del Portogallo) | `pt-PT` |
| `fr` | `app_fr.arb` | `fr-FR` |
| `es` | `app_es.arb` | `es-ES` |
| `de` | `app_de.arb` | `de-DE` |
| `ca` | `app_ca.arb` | `ca` |
| `el` | `app_el.arb` | `el-GR` |
| `ro` | `app_ro.arb` | `ro` |
| `hu` | `app_hu.arb` | `hu-HU` |
| `hr` | `app_hr.arb` | `hr` |
| `sl` | `app_sl.arb` | `sl` |
| `cs` | `app_cs.arb` | `cs-CZ` |
| `sk` | `app_sk.arb` | `sk` |
| `bg` | `app_bg.arb` | `bg` |
| `sr` (cirillico) | `app_sr.arb` | `sr` |
| `ka` | `app_ka.arb` | `ka-GE` |
| `nl` | `app_nl.arb` | `nl-NL` |
| `pl` | `app_pl.arb` | `pl-PL` |
| `uk` | `app_uk.arb` | `uk` |
| `da` | `app_da.arb` | `da-DK` |
| `sv` | `app_sv.arb` | `sv-SE` |
| `nb` | `app_nb.arb` | `no-NO` |
| `fi` | `app_fi.arb` | `fi-FI` |

## Decisioni di progetto

- **Un solo elenco delle lingue** (NFR5): `appLocales` in `lib/app/locale_resolution.dart` resta la fonte. Un test di coerenza fallisce se non coincidono con quell'elenco: i file ARB, `AppLocalizations.supportedLocales`, `android/app/src/main/res/xml/locales_config.xml`, `distribution/google-play/languages.json` e le cartelle dello store. Alternativa scartata: un file JSON letto da tutti, perché Dart non può leggerlo a tempo di compilazione senza un generatore in più.
- **Nomi dei paesi da CLDR** (FR3.1): i nomi dei 249 paesi nelle 22 lingue nuove vengono generati dai dati pubblici Unicode CLDR con uno script, non scritti a mano; il file Dart generato è versionato. I nomi di oggi in italiano, inglese e portoghese del Brasile restano com'sono. Alternativa scartata: scrivere a mano circa 5.500 nomi, troppo esposta a errori. Se i dati CLDR non si possono scaricare, lo sviluppatore si ferma e lo segnala: non inventa i nomi.
- **Portoghese**: oggi `nameIn('pt')` restituisce i nomi brasiliani. Le schermate passano d'ora in poi un'etichetta di lingua calcolata in un solo punto (`pt` per `pt-BR`, come oggi; `pt-PT` per il portoghese europeo), così i valori salvati e il comportamento attuale non cambiano.
- **Regioni vinicole** (FR3.2): una traduzione solo dove la lingua ha un nome d'uso consolidato (per esempio `Burgund`, `Borgoña`, `Toskana`); altrimenti il nome canonico. È una scelta enologica presa in autonomia e motivata in `code-summary.md`.
- **Test** (NFR3, NFR4): `accessibilityMatrix` gira su 10 lingue; i test che oggi hanno attese scritte per le tre lingue restano su quelle tre. Un test generato richiama ogni messaggio di ogni lingua, e copre così anche il codice generato (NFR1).
- **Non cambia**: lingua forzata dei test end-to-end, nome della cantina predefinita, catture dello store, pagine web, lettura delle etichette, `docs/play-console-handoff.md` e `docs/release-checklist.md` (hanno modifiche del proprietario non ancora salvate in git).

## Passi

### Struttura e configurazione

- [x] **Step 1** — Elenco delle lingue. Portare `appLocales` in `lib/app/locale_resolution.dart` alle 25 lingue della tabella; `lib/app/vinoozy_app.dart` continua a usarlo. Aggiungere a `l10n.yaml` il file dei messaggi non tradotti (`untranslated-messages-file`), ignorato da git. (FR1.1, NFR5)
- [x] **Step 2** — Verificare il runner esistente: eseguire `flutter test test/app/` sull'albero non ancora modificato dai passi successivi e confermare che il comando di `unit-test-instructions.md` sia eseguibile. Annotare l'esito in `code-summary.md`.

### Dati di dominio (paesi e regioni)

- [x] **Step 3** — Nomi dei paesi. Creare `tool/gen_origin_names.mjs`, che legge i dati CLDR (pacchetto `cldr-localenames-modern`, scaricato con `npm pack cldr-localenames-modern` in `.cache/`, già ignorata da git; nessuna dipendenza aggiunta a `package.json`) e genera `lib/cellar/domain/origin_country_names.g.dart`: una mappa costante per ognuna delle 22 lingue nuove, dal codice ISO al nome. Estendere `OriginCountry.nameIn` in `lib/cellar/domain/wine_origins.dart` per usare quelle mappe (chiave `pt-PT` per il portoghese europeo, inglese come ripiego), `sortedFor` e `searchCountries` per cercare anche nel nome della lingua corrente. Il file resta Dart puro. (FR3.1, FR3.3)
- [x] **Step 4** — Regioni e ricerca. Aggiungere a `WineRegion` una mappa facoltativa di nomi per lingua e compilarla solo dove esiste un nome d'uso consolidato; `forms` e `nameIn` la includono. Estendere `foldOriginText` a greco (accenti e sigma finale), cirillico e georgiano, e alle lettere latine che mancano per le lingue nuove. I valori salvati non cambiano. (FR3.2, FR3.3)
- [x] **Step 5** — Test del dominio in `test/cellar/domain/wine_origins_languages_test.dart`: ogni paese ha un nome non vuoto in ognuna delle 25 lingue (FR3.1); una regione mostra il nome tradotto e il valore canonico resta uguale cambiando lingua (FR3.2); la ricerca trova un paese in greco, cirillico e georgiano con e senza accenti e con maiuscole diverse (FR3.3). Eseguirli fino al verde.

### Accesso ai dati (catalogo)

- [x] **Step 6** — Lingua del catalogo. Estendere `CatalogLocale` in `lib/catalog/core/wine_catalog.dart` e il parametro `lc` in `lib/catalog/core/off/open_food_facts_source.dart` alle 25 lingue, con l'inglese come ripiego quando il catalogo non ha testi in quella lingua; aggiornare i punti che costruiscono `CatalogLocale` dalla lingua dell'app. `lib/catalog/core/` resta senza import di Flutter. (FR3.4)
- [x] **Step 7** — Test del catalogo in `test/catalog/core/catalog_locale_languages_test.dart`: una lingua nuova passa il proprio codice; un prodotto senza testi in quella lingua mostra quelli inglesi. Eseguirli fino al verde. (FR3.4)

### Logica (risoluzione della lingua, privacy)

- [x] **Step 8** — Risoluzione della lingua. Riscrivere `resolveAppLocale` senza `switch` per lingua: corrispondenza esatta lingua e paese (`pt-BR`), poi la lingua base (`fr-CA` riceve `fr`, ogni altro portoghese riceve `pt`), `nn` e `no` ricevono `nb`, altrimenti inglese; l'ordine di preferenza del telefono resta rispettato. (FR1.4, FR2.1)
- [x] **Step 9** — Pagina della privacy. In `lib/account/account_providers.dart` aggiungere una funzione che dà l'indirizzo per lingua: italiano la pagina base, inglese `en/`, portoghese del Brasile `pt-BR/`, ogni altra lingua `en/`; un indirizzo impostato con `PRIVACY_POLICY_URL` resta usato così com'è. Aggiornare il punto del profilo che apre il collegamento. (FR5.1)
- [x] **Step 10** — Test della logica: in `test/app/locale_resolution_languages_test.dart` i casi `fr-CA`, `es-AR`, `de-AT`, `pt-PT`, `pt-BR`, `nn`, `no`, una lingua non offerta, lista vuota (FR1.4); in `test/account/privacy_url_languages_test.dart` italiano, portoghese del Brasile, una lingua nuova e l'indirizzo configurato (FR5.1). Eseguirli fino al verde.

### Interfaccia (testi e schermate)

- [x] **Step 11** — Glossario. Creare `docs/l10n-glossary.md` con i termini del vino usati nell'app (annata, vitigno, denominazione, cantina, finestra di consumo, apice, bevuta, abbinamento e gli altri ricorrenti in `app_en.arb`) e la loro traduzione fissata per ognuna delle 25 lingue, più l'elenco dei termini che non si traducono. (NFR6, FR1.6)
- [x] **Step 12** — Traduzioni. Creare i 21 file ARB nuovi e compilare `app_pt.arb` in portoghese del Portogallo: tutti i messaggi di `app_en.arb`, stessi segnaposto, termini secondo il glossario, forme di plurale proprie di ogni lingua (`few`, `many` dove la lingua le ha), i `select` invariati nelle chiavi. Termini di legge del vino e nome Vinoozy non tradotti. (FR1.1, FR1.2, FR1.3, FR1.5, FR1.6, NFR6)
- [x] **Step 13** — Codice generato. Eseguire `flutter gen-l10n`; versionare i file `lib/l10n/app_localizations*.dart`; il file dei messaggi non tradotti deve risultare vuoto. (FR1.2)
- [x] **Step 14** — Schermate. Creare `lib/cellar/ui/origin_language.dart` con la funzione che dà l'etichetta di lingua per i nomi d'origine, e usarla negli 11 punti che oggi leggono `languageCode` (`lib/app/ui/country_flag.dart`, `lib/cellar/ui/origin_pickers.dart`, `wine_card.dart`, `wine_detail_screen.dart`, `drink_confirm_sheet.dart`, `lib/dashboard/ui/chart_cards.dart`, `lib/label/ui/candidate_list.dart`, `label_proposal_sheet.dart`). Controllare che date e numeri usino la lingua del contesto in `lib/cellar/ui/wine_labels.dart`, `lib/app/ui/about_screen.dart`, `lib/plan/ui/dashboard_plan_notices.dart`. (FR3.1, FR3.2, FR3.5)
- [x] **Step 15** — Harness dei test. In `test/helpers/ui_harness.dart`: `supportedLocales` da `appLocales`; nuovo elenco `matrixLocales` con le 10 lingue di NFR3 (`it`, `en`, `pt-BR`, `fr`, `es`, `de`, `el`, `uk`, `ka` e la lingua con i testi più lunghi tra le altre), usato da `accessibilityMatrix`; `testLocales` resta alle tre lingue per i test con attese scritte per lingua. (NFR3)
- [x] **Step 16** — Test generato dei messaggi. Creare `tool/gen_l10n_exercise.dart`, sul modello di `tool/gen_coverage_helper.dart`: da `app_en.arb` genera `test/l10n/l10n_exercise_test.dart` (ignorato da git), che per ognuna delle 25 lingue richiama ogni messaggio con argomenti di esempio e ne controlla il testo non vuoto, e per i messaggi con conteggio prova 0, 1, 2, 5 e 21. Aggiungere la sua generazione dove la CI e `tool/check_coverage.sh` generano già l'aiuto di copertura. (FR1.5, NFR1, NFR4)
- [x] **Step 17** — Test dell'interfaccia in `test/l10n/languages_test.dart`: ogni ARB ha le stesse chiavi e gli stessi segnaposto del modello (FR1.2); `matrixLocales` contiene davvero la lingua con i testi più lunghi, misurata sugli ARB (NFR3); per ognuna delle 15 lingue fuori dalla matrice una schermata principale viene mostrata senza eccezioni (NFR4); `qualifierDisplayName` è identico in tutte le lingue (FR1.6); una data e un numero decimale sono formattati secondo la lingua in `el`, `uk`, `ka` e `de` (FR3.5); il portoghese europeo e quello brasiliano danno testi diversi per uno stesso messaggio (FR1.3). Eseguire questi test e l'intera cartella `test/` fino al verde, correggendo le schermate che in una lingua della matrice escono dai margini.

### Configurazione di build e store

- [x] **Step 18** — Android. Creare `android/app/src/main/res/xml/locales_config.xml` con le 25 lingue e dichiararlo in `android/app/src/main/AndroidManifest.xml` (`android:localeConfig`). (FR2.2)
- [x] **Step 19** — Scheda di Google Play. Creare `distribution/google-play/languages.json` (lingua dell'app → cartella dello store) e le 22 cartelle nuove con `title.txt` (massimo 30 caratteri), `short-description.txt` (massimo 80), `full-description.txt` (massimo 4000), tradotte dai testi inglesi secondo il glossario; aggiungere le note di rilascio per lingua (massimo 500) nel formato già usato da `distribution/google-play/release-notes.txt`. Estendere `tool/check_publication.mjs` a leggere `languages.json` e a controllare tutte le cartelle e le note. (FR4.1)
- [x] **Step 20** — Test di coerenza in `test/app/language_consistency_test.dart`: `appLocales`, i file ARB, `AppLocalizations.supportedLocales`, `locales_config.xml`, `languages.json` e le cartelle dello store elencano le stesse 25 lingue (NFR5, FR1.1, FR2.2). Eseguire `node tool/check_publication.mjs --draft` (FR4.1).

### Documentazione e chiusura

- [x] **Step 21** — Creare `docs/store-languages.md`: le 25 lingue, la cartella di ognuna e i passi per caricare a mano i testi su Google Play; come aggiungere una lingua in futuro (un elenco più i file dei testi). (FR4.2, NFR5)
- [x] **Step 22** — Eseguire `dart format .` e `flutter analyze` senza errori; aggiornare i commenti che parlano di "tre lingue" nei file toccati.

### Correzione da Build and Test (Loop-back 1)

- [x] **Step 23** — Elenco delle lingue nelle impostazioni di Android (FR2.2). Sul telefono l'elenco mostrava 23 voci su 25: mancava il serbo, e `pt-BR` e `pt` erano fusi in un solo "Português". In `android/app/src/main/res/xml/locales_config.xml` dichiarare `pt-BR` e `pt-PT` come voci distinte e il serbo con scrittura cirillica esplicita (`sr-Cyrl`, verificando nella documentazione Android la forma accettata da `locale-config`). Allineare `appLocales` se serve e `resolveAppLocale`, in modo che `pt-PT` dia il portoghese europeo, `pt-BR` il brasiliano e `sr-Cyrl` / `sr-Cyrl-RS` il serbo; aggiornare `test/app/language_consistency_test.dart` e `test/app/locale_resolution_languages_test.dart`. Rifare `flutter gen-l10n`, la suite completa, `dart format`, `flutter analyze`, `tool/check_release_build.sh`. (FR2.2, NFR5)

## Tracciabilità requisiti → passi

| Requisito | Passi |
|---|---|
| FR1.1 | 1, 12, 20 |
| FR1.2 | 12, 13, 17 |
| FR1.3 | 12, 17 |
| FR1.4 | 8, 10 |
| FR1.5 | 12, 16 |
| FR1.6 | 11, 12, 17 |
| FR2.1 | 8 |
| FR2.2 | 18, 20 |
| FR3.1 | 3, 5, 14 |
| FR3.2 | 4, 5, 14 |
| FR3.3 | 3, 4, 5 |
| FR3.4 | 6, 7 |
| FR3.5 | 14, 17 |
| FR4.1 | 19, 20 |
| FR4.2 | 21 |
| FR5.1 | 9, 10 |
| NFR1 | 16 (misurata in Build and Test) |
| NFR2 | 15 (misurata in Build and Test) |
| NFR3 | 15, 17 |
| NFR4 | 16, 17 |
| NFR5 | 1, 20, 21 |
| NFR6 | 11, 12 |

## Rischi

- La verifica di FR2.2 sul telefono (voce della lingua nelle impostazioni di Android 13 o successivo) è manuale: resta da fare sulla build del canale di test interno.
- Tempi dei controlli (NFR2) e copertura (NFR1) si misurano in Build and Test sull'intera suite; le soglie non si toccano.
- Traduzioni senza revisione di un madrelingua (assunzione dei requisiti).

## Testing Contract

```json
{
  "version": 1,
  "methodology": "test-after",
  "source": "team",
  "ordering": "Per ogni strato testabile (dominio, dati e sincronizzazione, interfaccia) implementiamo prima il codice, poi scriviamo ed eseguiamo i test di quello strato, e passiamo allo strato successivo solo con quei test verdi.",
  "scope": "express",
  "test_strategy": "minimal",
  "project_type": "brownfield",
  "applicable_notes": [
    {
      "layer": "org",
      "text": "We treat tests as a first-class deliverable in every Bolt. The specific\nmethodology (TDD, BDD, ATDD, or classic test-after) is affirmed at\npractices-discovery and recorded in `team.md` under this heading with explicit\n`Methodology` and `Ordering` fields; Code Generation resolves those fields\nindependently from coverage, tooling, and scope notes.\n\nWhen no posture has been affirmed, our default per scope is:\n- **Methodology**: test-after\n- **Ordering**: implement each applicable testable layer, then write and run\n  that layer's tests.\n- `mvp`, `enterprise`, `feature`, `infra`, `classic` add an 80% line-coverage\n  floor and CI execution before merge.\n- `bugfix`, `security-patch` add a targeted regression for the specific\n  bug/vulnerability and require the existing suite to remain green.\n- `express` uses the Minimal strategy: requirement-driven unit tests (one per\n  requirement, with a happy-path floor per component); existing tests remain\n  green.\n- `poc`, `refactor`, `workshop` add no extra new-test floor and require the\n  existing suite to remain green.\n\nThe active `Test Strategy` still applies in every scope and determines test\nvolume/types. Scope floors are additive; they never reduce or replace the\nselected strategy.\n\nBuild and Test verifies defined coverage floors and affirmed quality targets;\nthey may not be weakened to make a step pass.\n\nAffirm a stricter posture in `team.md` if the team commits to one."
    },
    {
      "layer": "team",
      "text": "- **Methodology**: test-after\n- **Methodology evidence**: scelta in Q5 (\"Dopo il codice, strato per strato\"); coincide con il default di `org.md`.\n- **Ordering**: Per ogni strato testabile (dominio, dati e sincronizzazione, interfaccia) implementiamo prima il codice, poi scriviamo ed eseguiamo i test di quello strato, e passiamo allo strato successivo solo con quei test verdi.\n- **Copertura**: almeno l'**80% delle righe**, calcolato su tutto il codice **senza esclusioni**, compresi codice generato e file di traduzione (Q6). La soglia viene verificata in GitHub Actions e se non è raggiunta il merge in `main` è bloccato.\n- **Strumenti**: `flutter test` con `--coverage` per unit test e test dei widget. Unit test sulla logica (in particolare la stima del momento ideale e l'indice di fiducia), test dei widget per le schermate principali nelle tre lingue dell'interfaccia (it, en, pt-BR).\n- **Integrazione con Firebase**: i test di integrazione girano sulla **Firebase Emulator Suite**, in locale e in GitHub Actions, così non usano il progetto di produzione e non costano nulla (Q9).\n- **End-to-end**: i test che simulano l'uso reale dell'app girano in GitHub Actions su un **emulatore Android** (es. `integration_test` di Flutter), collegato alla Firebase Emulator Suite (Q7). Se falliscono, il merge è bloccato.\n- **Gate prima del merge**: formattazione, analisi statica, test, copertura ed end-to-end devono passare tutti. Un controllo rosso non si aggira e la soglia non si abbassa per far passare un blocco."
    }
  ],
  "obligations": {
    "strategy": "minimal",
    "strategy_volume": [
      "One verifiable test per requirement at the narrowest effective level.",
      "At least one happy-path unit test per component.",
      "Unit tests are the default; a bugfix/security scope floor may require an integration or E2E regression when that is the narrowest level that reproduces the defect."
    ],
    "scope_floor": [
      "Keep the existing test suite green.",
      "This scope adds no extra new-test floor beyond the selected test strategy."
    ],
    "combination_rule": "Apply every selected-strategy obligation and every scope-floor obligation; neither replaces the other, and a targeted scope regression may add the narrowest necessary test type beyond the strategy default."
  },
  "plan_profile": {
    "methodology": "test-after",
    "runner_step": "Verify the existing test runner/configuration and record the exact unit-scoped command.",
    "runner_ready_before_first_test": true,
    "testable_layers": [
      "Data model / database behavior",
      "Repository / data access",
      "Business logic",
      "API / endpoint",
      "Frontend behavior"
    ],
    "steps": [
      "Project structure and production configuration skeleton.",
      "Verify the existing test runner/configuration and record the exact unit-scoped command.",
      "Data model / database behavior - implement.",
      "Data model / database behavior - write and run its tests after implementation.",
      "Repository / data access - implement.",
      "Repository / data access - write and run its tests after implementation.",
      "Business logic - implement.",
      "Business logic - write and run its tests after implementation.",
      "API / endpoint - implement.",
      "API / endpoint - write and run its tests after implementation.",
      "Frontend behavior - implement.",
      "Frontend behavior - write and run its tests after implementation.",
      "Environment/build configuration.",
      "Documentation and traceability."
    ]
  },
  "input_sha256": "sha256:865343873c9f0b328d34ded3554c226044cb3a9b68eef7ea66181ee9d1d90ade",
  "contract_sha256": "sha256:225d0e3aa565626c2c5d1d4d16cc8ad5c6cd32fb293c1c2ca264b1e79bca33f9"
}
```
