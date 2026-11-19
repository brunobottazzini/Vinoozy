# Istruzioni per i test di unità — Miglioramenti dal report dei tester

## Framework e configurazione

- Runner: `flutter test` (pacchetto `flutter_test`), con `mocktail` per i finti, come nel resto del progetto. Nessuna configurazione nuova: valgono `dart_test.yaml` e `analysis_options.yaml` esistenti.
- I test dei widget usano `test/helpers/ui_harness.dart` per le lingue it, en e pt-BR.
- Per servizi del telefono (canale `com.vinoozy.app/links`, `InAppReview`, `share_plus`, `SharedPreferences`) si sovrascrivono i provider (`externalLinkOpenerProvider`, `appReviewLauncherProvider`, `shareLauncherProvider`, provider di `GuideStateStore`) oppure si usano `SharedPreferences.setMockInitialValues` e `TestDefaultBinaryMessengerBinding` per il `MethodChannel` finto.

## Comando di verifica del runner (prima del primo test)

```bash
flutter test test/app/language_consistency_test.dart
```

## Come eseguire i test di questo lavoro

Comando con i file esatti di questo lavoro, senza soglia di copertura:

```bash
flutter test test/guide/guide_state_store_test.dart test/guide/review_prompt_policy_test.dart test/guide/guide_policy_test.dart test/settings/feedback_email_test.dart test/app/external_links_test.dart test/settings/app_review_test.dart test/settings/settings_screen_test.dart test/settings/faq_screen_test.dart test/guide/guide_tour_test.dart test/guide/first_visit_hint_test.dart test/cellar/drink_review_prompt_test.dart test/app/store_listing_test.dart test/l10n/l10n_exercise_test.dart test/app/language_consistency_test.dart
```

Controllo di non regressione sulle aree toccate (menu della Cantina, presentazione, condivisione), in un comando a parte:

```bash
flutter test test/cellar test/account test/sharing
```

## Test previsti (strategia Minimal: un test per requisito)

| File | Requisiti |
|---|---|
| `test/guide/guide_state_store_test.dart` | FR2.5, FR5.3 |
| `test/guide/review_prompt_policy_test.dart` | FR5.2, FR5.2.1, FR5.2.2, FR5.2.3, NFR4 |
| `test/guide/guide_policy_test.dart` | FR2.2, FR2.3, FR2.6 |
| `test/settings/feedback_email_test.dart` | FR6.1 |
| `test/app/external_links_test.dart` | FR6.1, FR6.2, FR6.3, NFR7 |
| `test/settings/app_review_test.dart` | FR5.1, FR5.4 |
| `test/settings/settings_screen_test.dart` | FR1.1, FR1.2, FR1.3, FR2.4, FR4.1, FR4.2, FR5.1, FR6.3, NFR5 |
| `test/settings/faq_screen_test.dart` | FR7.1, FR7.2, FR7.3 |
| `test/guide/guide_tour_test.dart` | FR2.1, FR2.2, FR2.6 |
| `test/guide/first_visit_hint_test.dart` | FR2.3 |
| `test/cellar/drink_review_prompt_test.dart` | FR5.2, NFR6 |
| `test/app/store_listing_test.dart` | FR3.1, FR3.2, FR3.3, FR3.4 |
| `test/l10n/l10n_exercise_test.dart` (rigenerato) | NFR1 |

Ogni file copre il caso positivo e almeno due casi d'errore o di bordo (regola della fase Construction).

## Copertura attesa

- La soglia del progetto è l'**80% delle righe su tutto `lib/`**, codice generato compreso (team.md, Testing Posture). Viene misurata da Build and Test sulla suite completa (`tool/check_coverage.sh` dopo `flutter test --coverage`), non da questi comandi limitati al lavoro.
- I nuovi testi delle 25 lingue sono coperti dal test generato `l10n_exercise_test.dart`, che va rigenerato con `dart run tool/gen_l10n_exercise.dart` dopo `flutter gen-l10n`.
- La soglia non si abbassa e non si escludono file per farla passare.

## Finti e dati di test

- Date: si usa `Clock` di `lib/core/clock.dart` con un orologio fisso, così i conteggi di 7 e 120 giorni sono deterministici.
- Vini: liste di `Wine` costruite in memoria, nessun Firestore; la soglia dei 5 vini si prova con 4 e 5 vini.
- Email e dispositivo: il `MethodChannel` finto restituisce `{manufacturer: 'Google', model: 'Pixel 8', release: '15'}` e `true` o `false` per `email`.
- Recensione: un finto `AppReviewLauncher` registra le chiamate a `requestReview` e `openRatingPage`.
- Schede dello store: il test legge i file reali sotto `distribution/google-play/`.
