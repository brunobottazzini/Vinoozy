# Tracciabilità finale dei requisiti

**Esito: PASS.** I 22 requisiti di `requirements.md` sono tutti coperti; nessun elemento scoperto.

Lavoro senza Unit: tutto è stato costruito in un solo giro di Code Generation (stage `code-generation`).

| Requisito | Coperto | Fase | File |
|---|---|---|---|
| FR1.1 | Sì | code-generation | `test/app/language_consistency_test.dart` |
| FR1.2 | Sì | code-generation | `test/l10n/languages_test.dart` |
| FR1.3 | Sì | code-generation | `test/l10n/languages_test.dart` |
| FR1.4 | Sì | code-generation | `test/app/locale_resolution_languages_test.dart` |
| FR1.5 | Sì | code-generation | `test/l10n/languages_test.dart` |
| FR1.6 | Sì | code-generation | `test/l10n/languages_test.dart` |
| FR2.1 | Sì | code-generation | `test/app/locale_resolution_languages_test.dart` |
| FR2.2 | Sì | code-generation | `android/app/src/main/res/xml/locales_config.xml` (presente nella build di rilascio; la prova sul telefono è manuale) |
| FR3.1 | Sì | code-generation | `test/cellar/domain/wine_origins_languages_test.dart` |
| FR3.2 | Sì | code-generation | `test/cellar/domain/wine_origins_languages_test.dart` |
| FR3.3 | Sì | code-generation | `test/cellar/domain/wine_origins_languages_test.dart` |
| FR3.4 | Sì | code-generation | `test/catalog/core/catalog_locale_languages_test.dart` |
| FR3.5 | Sì | code-generation | `test/l10n/languages_test.dart` |
| FR4.1 | Sì | code-generation | `tool/check_publication.mjs` |
| FR4.2 | Sì | code-generation | `docs/store-languages.md` |
| FR5.1 | Sì | code-generation | `test/account/privacy_url_languages_test.dart` |
| NFR1 | Sì | code-generation | `tool/gen_l10n_exercise.dart` (copertura misurata: vedi `test-results.md`) |
| NFR2 | Sì | code-generation | `test/helpers/ui_harness.dart` (durata: vedi `test-results.md`) |
| NFR3 | Sì | code-generation | `test/helpers/ui_harness.dart` |
| NFR4 | Sì | code-generation | `test/l10n/languages_test.dart` |
| NFR5 | Sì | code-generation | `test/app/language_consistency_test.dart` |
| NFR6 | Sì | code-generation | `docs/l10n-glossary.md` |

Fonte: `aidlc engine sensor-traceability --stage build-and-test`, `pass: true`, `uncovered: []`.
