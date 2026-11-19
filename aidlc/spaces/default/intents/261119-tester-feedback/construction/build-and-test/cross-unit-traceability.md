# Tracciabilità finale — Build and Test

Fonte: `aidlc engine sensor-traceability --stage build-and-test` del 2026-11-19.
Lavoro express senza Unit: tutti i requisiti sono costruiti dallo stadio Code Generation.

**Verdetto: PASS.** 34 requisiti su 34 risultano costruiti; nessun elemento scoperto.

| ID | Coperto | Stadio | File |
|---|---|---|---|
| FR1.1 | sì | code-generation | `lib/settings/ui/settings_screen.dart` |
| FR1.2 | sì | code-generation | `lib/settings/ui/settings_screen.dart` |
| FR1.3 | sì | code-generation | `lib/cellar/ui/cellar_screen.dart` |
| FR2.1 | sì | code-generation | `lib/guide/ui/guide_tour.dart` |
| FR2.2 | sì | code-generation | `lib/guide/guide_policy.dart` |
| FR2.3 | sì | code-generation | `lib/guide/ui/first_visit_hint.dart` |
| FR2.4 | sì | code-generation | `lib/settings/ui/settings_screen.dart` |
| FR2.5 | sì | code-generation | `lib/guide/guide_state_store.dart` |
| FR2.6 | sì | code-generation | `lib/guide/guide_providers.dart` |
| FR3.1 | sì | code-generation | `distribution/google-play/it-IT/full-description.txt` |
| FR3.2 | sì | code-generation | `distribution/google-play/en-US/full-description.txt` |
| FR3.3 | sì | code-generation | `distribution/google-play/de-DE/full-description.txt` |
| FR3.4 | sì | code-generation | `test/app/store_listing_test.dart` |
| FR4.1 | sì | code-generation | `lib/app/store_links.dart` |
| FR4.2 | sì | code-generation | `lib/sharing/ui/share_launcher.dart` |
| FR5.1 | sì | code-generation | `lib/settings/app_review.dart` |
| FR5.2.1 | sì | code-generation | `lib/guide/review_prompt_policy.dart` |
| FR5.2.2 | sì | code-generation | `lib/guide/review_prompt_policy.dart` |
| FR5.2.3 | sì | code-generation | `lib/guide/review_prompt_policy.dart` |
| FR5.3 | sì | code-generation | `lib/guide/guide_state_store.dart` |
| FR5.4 | sì | code-generation | `lib/settings/app_review.dart` |
| FR6.1 | sì | code-generation | `lib/settings/feedback_email.dart` |
| FR6.2 | sì | code-generation | `android/app/src/main/kotlin/com/vinoozy/vinoozy/LinksChannelHandler.kt` |
| FR6.3 | sì | code-generation | `lib/settings/ui/feedback_flow.dart` |
| FR7.1 | sì | code-generation | `lib/settings/ui/faq_screen.dart` |
| FR7.2 | sì | code-generation | `lib/settings/ui/faq_screen.dart` |
| FR7.3 | sì | code-generation | `lib/settings/ui/faq_screen.dart` |
| NFR1 | sì | code-generation | `lib/l10n/app_it.arb` |
| NFR2 | sì | code-generation | `test/settings/settings_screen_test.dart` |
| NFR3 | sì | code-generation | `lib/guide/guide_state_store.dart` |
| NFR4 | sì | code-generation | `lib/guide/review_prompter.dart` |
| NFR5 | sì | code-generation | `lib/guide/ui/guide_tour.dart` |
| NFR6 | sì | code-generation | `lib/cellar/ui/drink_flow.dart` |
| NFR7 | sì | code-generation | `lib/app/external_links.dart` |

## Nota

"Costruito" significa che c'è il file che lo realizza. Il criterio di FR2.4 ("il giro riparte dal primo passo") ha un difetto noto, R-01 della revisione di Code Generation, accettato come rischio al gate: va provato sul telefono.
