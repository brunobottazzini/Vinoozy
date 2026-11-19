# Piano di generazione del codice — Miglioramenti dal report dei tester

## Summary

- Builds: schermata Impostazioni, giro guidato e suggerimenti, Condividi, Valuta (con In-App Review), Feedback via email, FAQ, testi dello store ottimizzati per la ricerca nelle 25 lingue
- Touches: `lib/settings/` (nuovo), `lib/guide/` (nuovo), `lib/cellar/ui/cellar_screen.dart`, `lib/cellar/ui/drink_flow.dart`, `lib/app/external_links.dart`, `lib/sharing/ui/share_launcher.dart`, `MainActivity.kt`, 25 ARB, `pubspec.yaml`, `distribution/google-play/*/`
- Tests: circa 14 test nuovi (unit e widget, in it/en/pt-BR) più rigenerazione di `l10n_exercise_test.dart`; suite esistente verde

## Contesto

Lavoro a zero Unit (scope express): un'unica iterazione dai requisiti `inception/requirements-analysis/requirements.md` (FR1-FR7, NFR1-NFR7) e dalla code knowledge base `aidlc/spaces/default/codekb/Vinoozy/`.

### Decisioni sulle osservazioni aperte della revisione dei requisiti

Il proprietario ha approvato i requisiti accettando le osservazioni come rischio. Il piano le risolve così:

- **R-01 (modello e versione Android nel feedback):** non aggiungo dipendenze. Il canale nativo `com.vinoozy.app/links` riceve due metodi nuovi:
  - `deviceInfo` restituisce `Build.MANUFACTURER`, `Build.MODEL` e `Build.VERSION.RELEASE`;
  - `email` apre `ACTION_SENDTO` con `mailto:` solo verso l'indirizzo di supporto fisso.

  Resta valido il vincolo "solo `in_app_review` come nuova dipendenza".
- **R-02 (chi ha già l'app):** il giro guidato parte solo se la cantina era vuota al primo avvio della versione nuova. Chi ha già almeno un vino viene considerato "giro visto", ma può farlo partire con "Rivedi la guida". I suggerimenti per schermata seguono la stessa regola.
- **R-03 (giro e suggerimenti insieme):** i suggerimenti non compaiono mentre il giro è in corso, né prima che sia finito o saltato. Se il comando che un passo deve indicare non è sullo schermo (per esempio con la cantina non pronta), il passo viene saltato.
- **R-04 (parole chiave ASO):** l'elenco fisso è in FR3 qui sotto (Step 15). Un test verifica per it-IT e en-US che ce ne siano almeno 5 e, per tutte le 25 schede, i limiti di lunghezza e la presenza dell'elenco puntato.
- **R-05 (conteggio dei vini):** si contano i vini della cantina attiva prima della bevuta (la lista caricata, archiviati esclusi).
- **R-06 (build E2E e debug):** la richiesta automatica di recensione è spenta nelle build E2E e in debug, come il giro guidato. Il pulsante resta.
- **R-07 (limite Plus nelle FAQ):** il numero di bottiglie del piano senza costi è un segnaposto `{limit}` letto dalla costante dell'app, non scritto nel testo.

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

Strati di questo lavoro: non ci sono database o API nuove. Gli strati testabili sono **dati locali** (preferenze sul telefono), **logica** (regole di giro e recensione, testi da comporre), **piattaforma** (canale nativo) e **interfaccia**. Ogni strato si implementa, poi si scrivono ed eseguono i suoi test, e si passa al successivo solo con quei test verdi.

## Steps

### Struttura e configurazione

- [ ] **Step 1 — Struttura e dipendenza.** Aggiungo `in_app_review` (ultima versione stabile compatibile) a `pubspec.yaml` ed eseguo `flutter pub get`. Creo i moduli `lib/settings/` (`ui/`) e `lib/guide/` (radice per stato e regole, `ui/`). Sposto la costante `playStoreLink` in `lib/app/store_links.dart`; `share_launcher.dart` la importa da lì (FR4.2). Ci metto anche `supportEmail = 'bottazzinibruno@gmail.com'` (FR6.1). (FR1, FR4.2, FR5, FR6)
- [ ] **Step 2 — Runner dei test.** Verifico che `flutter test test/app/language_consistency_test.dart` giri sul repository così com'è. Registro in `unit-test-instructions.md` il comando con i file esatti di questo lavoro.

### Dati locali (preferenze sul telefono)

- [ ] **Step 3 — Implementazione dello stato locale.** Il file `lib/guide/guide_state_store.dart` contiene `GuideStateStore` su `SharedPreferences` (stesso schema di `OnboardingFlag`, con il `PreferencesOpener` iniettato). Gestisce queste chiavi:
  - `guide.tour.seen` (bool);
  - `guide.hint.<screen>` (bool) per `dashboard`, `history` e `addWine`;
  - `guide.firstRun.version` (per R-02);
  - `review.firstUse` (data ISO) e `review.lastPrompt` (data ISO).

  Sono previsti `reset()` per "Rivedi la guida" (azzera solo tour e suggerimenti) e `ensureFirstUse(now)`. Un archivio illeggibile conta come "visto" e come "nessuna richiesta"; una scrittura rifiutata restituisce `false`. Provider in `lib/guide/guide_providers.dart`, iniettati in `lib/app/bootstrap.dart` come `onboardingFlagProvider`. (FR2.5, FR5.3)
- [ ] **Step 4 — Test dello stato locale.** `test/guide/guide_state_store_test.dart` copre: valori iniziali, segna e rileggi, `reset` che non tocca le date della recensione, archivio che lancia eccezione (conta come visto), `ensureFirstUse` idempotente. (FR2.5, FR5.3)

### Logica

- [ ] **Step 5 — Implementazione della logica.**
  - `lib/guide/review_prompt_policy.dart`: funzione pura `shouldAutoPrompt({rating, activeWineCount, firstUse, lastPrompt, now, enabled})`, che rende `true` solo con rating ≥ 4, almeno 5 vini, almeno 7 giorni dal primo uso, almeno 120 giorni dall'ultima richiesta (o nessuna) e `enabled`. `enabled` è falso con `kDebugMode` o nelle build E2E (`lib/e2e/`). (FR5.2, FR5.2.1-3, R-05, R-06)
  - `lib/guide/guide_policy.dart`: regole pure del giro.
    - `shouldStartTour(tourSeen, firstRunHadWines, e2e)` (R-02, FR2.6).
    - `shouldShowHint(screen, tourSeen, hintSeen, tourRunning)`: nessun suggerimento prima della fine del giro (R-03).
  - `lib/settings/feedback_email.dart`: `buildFeedbackBody(l10n, appVersion, device, locale)` compone il corpo dell'email con i dati tecnici in fondo. (FR6.1)
- [ ] **Step 6 — Test della logica.**
  - `test/guide/review_prompt_policy_test.dart` copre: caso positivo, 3 stelle, 4 vini, 6 giorni, ultima richiesta a 30 giorni, disattivata in E2E e debug.
  - `test/guide/guide_policy_test.dart` copre: utente nuovo, utente con vini, E2E, suggerimento durante il giro e dopo.
  - `test/settings/feedback_email_test.dart` verifica che corpo e dati tecnici siano presenti.

  (FR2.2, FR2.3, FR2.6, FR5.2, FR6.1)

### Piattaforma (canale nativo e servizi del telefono)

- [ ] **Step 7 — Implementazione della piattaforma.**
  - In `MainActivity.kt` il canale `com.vinoozy.app/links` riceve due metodi nuovi:
    - `deviceInfo` restituisce produttore, modello e versione Android;
    - `email(subject, body)` apre `Intent.ACTION_SENDTO` con `mailto:` verso l'indirizzo fisso di supporto (il destinatario non arriva da Dart) e restituisce `false` se nessuna app lo gestisce.

    `open` resta solo `https` (NFR7).
  - In Dart, `lib/app/external_links.dart` aggiunge `openSupportEmail` e `readDeviceInfo`, dietro provider sostituibili nei test.
  - `lib/settings/app_review.dart`: interfaccia `AppReviewLauncher`, implementata su `InAppReview`:
    - `requestReview()` per la richiesta automatica;
    - `openRatingPage()` chiede la finestra se `isAvailable()`, altrimenti apre `playStoreLink` con `openExternalLink`.

    Provider `appReviewLauncherProvider`. Gli errori della piattaforma vengono catturati e registrati con `ErrorReporter`, senza bloccare. (FR5.1, FR5.4, FR6.1, FR6.3, NFR7)
- [ ] **Step 8 — Test della piattaforma.**
  - `test/app/external_links_test.dart` usa un `MethodChannel` finto: email aperta, nessuna app email (`false`), `deviceInfo` letto, `open` che rifiuta ancora `mailto:` e `market://`.
  - `test/settings/app_review_test.dart` usa un finto `InAppReview`: disponibile chiede la finestra, non disponibile apre il Play Store, eccezione senza crash.
  - Test Kotlin in `android/app/src/test/` per l'indirizzo fisso, solo se la struttura dei test Kotlin esistenti lo permette senza dipendenze nuove; altrimenti lo annoto in `code-summary.md`.

  (FR5.1, FR6.1, FR6.3, NFR7)

### Interfaccia

- [ ] **Step 9 — Testi nelle 25 lingue.** Aggiungo a `app_en.arb` (modello, con descrizioni) e ai 24 altri ARB le chiavi per:
  - Impostazioni: titolo e 7 voci;
  - giro guidato: 4 passi con titolo e testo, più Avanti, Salta e Fine;
  - suggerimenti: 3, più il pulsante di chiusura;
  - messaggio di condivisione e oggetto;
  - feedback: oggetto, intestazione dei dati tecnici, messaggio "nessuna app email" con l'indirizzo, "Copia";
  - FAQ: titolo, 8 domande e risposte, "Non hai trovato la risposta?". La risposta sul piano Plus usa il segnaposto `{limit}` (R-07).

  Traduzioni scritte da me. Eseguo `flutter gen-l10n`, verifico `l10n_untranslated.json` = `{}` e rigenero `test/l10n/l10n_exercise_test.dart` con `dart run tool/gen_l10n_exercise.dart`. (NFR1)
- [ ] **Step 10 — Schermata Impostazioni e menu.**
  - `lib/settings/ui/settings_screen.dart`: `SettingsScreen.open(context, user)`. È un `ListView` con le 7 voci di FR1.2 nell'ordine e chiavi `settings-profile`, `settings-guide`, `settings-share`, `settings-rate`, `settings-feedback`, `settings-faq`, `settings-about`, con icone e aree di tocco da 48 dp e `Semantics` (NFR5).
    - "Condividi" usa `shareLauncherProvider` con il testo tradotto e `playStoreLink`; un errore mostra un messaggio tradotto.
    - "Valuta" chiama `openRatingPage`.
    - "Feedback" compone l'email; se nessuna app la gestisce, mostra un dialogo con l'indirizzo e "Copia".
    - "Rivedi la guida" chiama `reset()` e torna alla Cantina.
  - In `cellar_screen.dart`, `_CellarMenu` riceve la voce `cellar-menu-settings` "Impostazioni", prima di Informazioni; le altre voci restano (FR1.1, FR1.3).

  (FR1, FR2.4, FR4.1, FR5.1, FR6)
- [ ] **Step 11 — FAQ.** `lib/settings/ui/faq_screen.dart` mostra 8 `ExpansionTile` (chiavi `faq-item-0` … `faq-item-7`) e il collegamento `faq-feedback`, che apre il feedback come in FR6. Funziona senza rete, e la risposta sul piano Plus usa la costante del limite. (FR7, R-07)
- [ ] **Step 12 — Giro guidato e suggerimenti.**
  - `lib/guide/ui/guide_tour.dart`: sovrapposizione propria (`OverlayEntry`) che scurisce lo schermo, ritaglia il comando indicato da una `GlobalKey` e mostra una scheda con titolo, testo, "Avanti"/"Fine" e "Salta" (chiavi `guide-next`, `guide-skip`, `guide-done`). Il tasto Indietro chiude il giro.
  - Passi: pulsante "Aggiungi vino", voce foto/etichetta se presente, barra delle schede, menu della Cantina. I passi senza un comando sullo schermo vengono saltati (R-03).
  - Parte da `CellarScreen` dopo il primo frame, quando la cantina è pronta e `shouldStartTour` è vero. Alla fine o con "Salta" scrive `guide.tour.seen`.
  - `lib/guide/ui/first_visit_hint.dart`: widget che mostra una volta un suggerimento chiudibile (`MaterialBanner` in testa allo schermo, chiave `hint-<screen>-close`) nel Cruscotto, nello Storico e nella schermata di aggiunta del vino, secondo `shouldShowHint`.
  - Nelle build E2E è tutto spento (FR2.6).

  (FR2.2, FR2.3, FR2.6, NFR4, NFR5)
- [ ] **Step 13 — Richiesta automatica di recensione.** In `drink_flow.dart`, dopo `DrinkAccepted`, leggo il numero di vini della cantina attiva prima della bevuta (la lista già caricata da `winesStreamProvider`, archiviati esclusi) e chiamo `shouldAutoPrompt`. Se è vero, salvo `review.lastPrompt` e chiamo `requestReview()` dopo il messaggio "Bevuto". `ensureFirstUse` viene chiamato all'avvio in `bootstrap.dart`. Non aggiungo letture da Firestore (NFR6). (FR5.2, FR5.3, NFR4)
- [ ] **Step 14 — Test dell'interfaccia** (widget, in it, en e pt-BR con `test/helpers/ui_harness.dart`):
  - `test/settings/settings_screen_test.dart`: voce del menu presente; 7 voci nell'ordine; Profilo e Informazioni aperte; Condividi con link nel testo; Valuta che chiama il launcher; Feedback senza app email che mostra il dialogo; Rivedi la guida che azzera.
  - `test/settings/faq_screen_test.dart`: una domanda si espande; il limite Plus compare; il collegamento apre il feedback.
  - `test/guide/guide_tour_test.dart`: il giro parte per un utente nuovo; "Salta" scrive lo stato; il passo senza bersaglio viene saltato; non parte con vini già presenti.
  - `test/guide/first_visit_hint_test.dart`: compare la prima volta e non la seconda; non compare durante il giro.
  - `test/cellar/drink_review_prompt_test.dart`: una bevuta da 5 stelle con le condizioni soddisfatte chiama `requestReview`, da 3 stelle no.

  Eseguo anche `test/cellar/` e `test/account/` per controllare che non ci siano regressioni sul menu e sulla presentazione. (FR1-FR7, NFR2, NFR5)

### Testi dello store, configurazione e documentazione

- [ ] **Step 15 — ASO, schede dello store.**
  - Parole chiave fisse it-IT: `cantina`, `vino`, `vini`, `gestione cantina`, `etichetta`, `quando bere`, `finestra di consumo`, `abbinamenti`.
  - Parole chiave fisse en-US: `wine cellar`, `wine`, `cellar manager`, `wine inventory`, `wine label`, `drinking window`, `when to drink`, `food pairing`.

  Riscrivo `title.txt` (≤ 30), `short-description.txt` (≤ 80) e `full-description.txt` (≤ 4000) di it-IT e en-US: paragrafo d'apertura, elenco puntato di almeno 6 funzioni, nessun termine vietato. Adatto le altre 23 schede dall'inglese con termini locali e la stessa struttura.

  Aggiungo `test/app/store_listing_test.dart`, che legge `distribution/google-play/languages.json` e per ogni scheda verifica:
  - limiti di lunghezza;
  - almeno 6 righe di elenco puntato nella descrizione completa;
  - per it-IT e en-US, almeno 5 parole chiave della propria lista;
  - nessuna delle parole vietate (`migliore`, `best`, `#1`, `n. 1`, `gratis`/`free` nel titolo).

  Eseguo anche `node tool/check_publication.mjs` se gira senza credenziali. (FR3, R-04)
- [ ] **Step 16 — Versione e note di rilascio.** Porto `pubspec.yaml` a `0.4.0+3` (il numero di build lo genera GitHub Actions) e scrivo `distribution/google-play/release-notes.txt` nelle 25 lingue con un blocco per scheda. Controllo con `tool/check_release_build.sh`, se gira in locale senza segreti, che il manifest unito non aggiunga permessi indesiderati per `in_app_review`. (Constraints)
- [ ] **Step 17 — Formattazione, analisi e documentazione.** Eseguo `dart format lib test` e `flutter analyze` (zero problemi). Aggiorno i commenti in testa ai file nuovi con i riferimenti FR/NFR, come nel resto del codice. Scrivo `code-summary.md` e `traceability.json` (gestiti dal conduttore dopo la generazione).

### Correzioni da Build and Test (Loop-back 1, 2026-11-19)

Fonte: prova sul telefono del proprietario e decisione 453206ce; diagnosi in `construction/build-and-test/test-results.md`, `## Loop-Back Log`.

- [ ] **Step 18 — Riquadro del giro che segue il comando.** In `lib/guide/ui/guide_tour.dart` lo stato del giro usa un `Ticker` (`SingleTickerProviderStateMixin`) che a ogni fotogramma rilegge `targets.rectOf(step)` e chiama `setState` solo quando il rettangolo cambia; il ticker si ferma con il `dispose`. Così il buco nella velatura segue il pulsante "Aggiungi" anche mentre entra in scena. Test in `test/guide/guide_tour_test.dart`: un comando che si sposta dopo l'apertura del giro e il buco (`tour-scrim`, rettangolo del painter) che lo segue; più il caso del comando che sparisce (passo senza buco, nessun errore). (FR2.1, NFR5)
- [ ] **Step 19 — R-02: data salvata prima della richiesta.** In `lib/guide/review_prompter.dart`, `maybeAskForReview` chiama `requestReview()` solo se `markPrompted` restituisce `true`; se la scrittura fallisce non chiede e lascia la segnalazione già fatta dall'archivio. Test in `test/cellar/drink_review_prompt_test.dart` o `test/guide/review_prompt_policy_test.dart` con un archivio che rifiuta la scrittura: nessuna richiesta. (FR5.2.3, NFR4)
- [ ] **Step 20 — R-04: indirizzo di supporto uguale in Dart e Android.** Nuovo test `test/app/support_email_consistency_test.dart` che legge `android/app/src/main/kotlin/com/vinoozy/vinoozy/LinksChannelHandler.kt`, estrae `SUPPORT_EMAIL` e lo confronta con `supportEmail` di `lib/app/store_links.dart`; fallisce anche se la costante non si trova. (FR6.1, FR6.3)

### Correzione dalla CI (Loop-back 2, 2026-11-19)

Fonte: job `analyze` di GitHub Actions (run 44542254404), `tool/check_off_config.sh` rifiuta l'indirizzo email in `lib/app/store_links.dart`; decisione e000ed61. Diagnosi in `construction/build-and-test/test-results.md`, `## Loop-Back Log`.

- [x] **Step 21 — Indirizzo di supporto solo lato Android.** Tolgo `supportEmail` da `lib/app/store_links.dart`: nessun indirizzo email nel codice Dart di `lib/`. Il canale `com.vinoozy.app/links` (`LinksChannelHandler.kt`) riceve il metodo `supportEmail`, che restituisce `SUPPORT_EMAIL`; in `lib/app/external_links.dart` un provider sostituibile `supportEmailReaderProvider` lo legge (`null` se il canale fallisce, errore segnalato). Il dialogo "nessuna app email" di `lib/settings/ui/feedback_flow.dart` legge l'indirizzo da lì; se è `null` mostra il messaggio senza indirizzo e senza "Copia". Elimino `test/app/support_email_consistency_test.dart` (una sola copia, niente da confrontare) e aggiorno i test toccati: `test/app/external_links_test.dart` (metodo letto, canale che fallisce), `test/settings/settings_screen_test.dart` (dialogo con indirizzo dal provider e senza indirizzo), test Kotlin `LinksChannelHandlerTest` (metodo `supportEmail`). Verifica: `tool/check_off_config.sh` OK, più tutti i controlli del job `analyze` di `.github/workflows/ci.yml`. (FR6.1, FR6.3)

## Fuori da questo piano

- Nessuna modifica a Firestore, regole o Cloud Functions; la scheda Data safety non cambia (NFR3).
- I test E2E esistenti non cambiano: il giro guidato e la richiesta automatica sono spenti nelle build E2E. Build and Test li riesegue.
