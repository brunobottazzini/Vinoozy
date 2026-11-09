# Tracciabilità tra le parti

## Fonti

- `aidlc engine sensor-traceability --stage build-and-test` (eseguito il 2026-11-09)
- `inception/requirements-analysis/traceability.json`
- `construction/code-generation/traceability.json`

## Esito

**Superato**: 31 ID tracciati, 0 scoperti. Il lavoro non ha Units: è un'unica iterazione, quindi ogni ID è costruito in Code Generation.

| ID | Coperto | Costruito in | Test principali |
|---|---|---|---|
| FR1.1 profili dello studio | sì | `packages/estimation/lib/src/profiles.dart` | `profiles_test.dart` |
| FR1.2 mappa delle combinazioni | sì | `generated/profile_map.g.dart` | `profile_map_test.dart`, `build_profile_map_test.dart` |
| FR1.3 stato in mesi | sì | `status.dart` | `month_window_test.dart` |
| FR1.4 stile mancante → stima indicativa | sì | `style_resolver.dart` | `classifier_test.dart`, `revision60_test.dart` |
| FR1.5 qualifiche nuove | sì | `qualifiers.dart` | `revision60_test.dart` |
| FR1.6 studio come base di dati | sì | `tool/build_profile_map.dart` | `build_profile_map_test.dart` |
| FR2.1 Tipologia preselezionata | sì | `classifier.dart` | `classification_sample_test.dart` |
| FR2.2 stato della classificazione nel modulo | sì | `classification_state.dart` | `style_widgets_test.dart` |
| FR2.3 Livello preselezionato | sì | `classifier.dart` | `classifier_test.dart`, `autofill_form_test.dart` |
| FR2.4 provenienza `user`/`auto` | sì | `wine_classification.dart` | `wine_repository_style_test.dart` |
| FR2.5 base offline classificata | sì | `tool/build_wine_db.dart` | `build_wine_db_classify_test.dart` |
| FR3.1 Stile nel modulo | sì | `add_wine_screen.dart` | `style_widgets_test.dart` |
| FR3.2 avviso "Stile da confermare" | sì | `style_widgets.dart` | `style_widgets_test.dart`, `style_dashboard_test.dart` |
| FR3.3 data di sboccatura/imbottigliamento | sì | `wine_validator.dart` | `style_widgets_test.dart` |
| FR3.4 momento ideale in mesi | sì | `ideal_moment_card.dart` | `style_widgets_test.dart` |
| FR3.5 "Consigliato fino al" con il mese | sì | `window_override_widgets.dart` | `autofill_components_test.dart` |
| FR3.6 scelta dello stile nel dettaglio | sì | `wine_detail_screen.dart` | `style_widgets_test.dart` |
| FR4.1 migrazione | sì | `estimates_migration.dart` | `style_migration_test.dart` |
| FR4.2 scritture del repository | sì | `wine_repository.dart` | `wine_repository_style_test.dart` |
| NFR1 offline, senza costi | sì | `window.dart` | test con rete spenta |
| NFR2.1–NFR2.3 compatibilità e regole | sì | `wine.dart`, `firestore.rules`, `compat/app-writes.json` | `style_profiles.rules.test.mjs`, `compat/` |
| NFR3 prestazioni (NFR3.1–NFR3.8) | sì | benchmark del pacchetto, `build_wine_db.dart` | `estimation_benchmark.dart` |
| NFR4.1 copertura | sì | `coverage_helper_test.dart` | `check_coverage.sh` |
| NFR4.2 mappa completa | sì | `profile_map_test.dart` | — |
| NFR4.3 campione di 100 vini | sì | `classification_sample_test.dart` | — |
| NFR4.4 migrazione sicura | sì | `style_migration_test.dart` | — |
| NFR4.5 e2e del modulo | sì (scritto) | `integration_test/style_profile_flow_test.dart` | non eseguito in questo ambiente (vedi `test-results.md`) |
| NFR5 lingue e accessibilità (NFR5.1–NFR5.2) | sì | ARB, `style_widgets_test.dart` | matrice di accessibilità |
| NFR6 osservabilità (NFR6.1–NFR6.3) | sì | manifest, logger, riferimenti alle fonti | `about_screen`, test del logger |

Nessun ID scoperto. L'unico elemento con prova incompleta è NFR4.5: il test esiste ed è tracciato, ma non è stato eseguito qui.
