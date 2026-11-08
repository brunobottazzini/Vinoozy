# Tracciabilità finale — riconoscimento delle etichette

Il lavoro non ha Unit (scope `refactor`), quindi c'è un'unica iterazione. Questa tabella collega i requisiti alle prove eseguite in questa fase.

| Requisito | Prova | Esito |
|---|---|---|
| FR1.1–FR1.3 fronte e retro | `label_merge_test`, `label_session_controller_test`, `temp_label_store_test`, e2e scenari 2-3 | verde |
| FR2.1 base offline | `build_wine_db_test`, `wine_db_record_test`, `wine_db_index_test` | verde |
| FR2.2–FR2.5 ricerca, candidati, attribuzione, Informazioni | `catalog_coordinator_test`, `candidate_list_test`, `about_screen_test`, e2e scenari 2-3 | verde |
| FR3.1–FR3.4 "Cerca online" | `online_search_test`, `online_search_screen_test`, e2e scenario 4 | verde |
| FR4.1–FR4.4 Google Lens | `lens_channel_test`, `LensIntentLauncherTest` (Robolectric), `label_scope_test`, e2e scenario 5 | verde. L'apertura vera di Lens con la foto è stata provata dal proprietario sul telefono: Lens legge l'etichetta. |
| FR5 rete | `catalog_coordinator_test` (nessun `off_suspended` senza rete) | verde |
| NFR1.1 dimensione | — | rimandato: va misurato con la base reale |
| NFR1.2 limiti del file (3 MB compressi, 30 MB non compressi) | `build_wine_db_test` | verde |
| NFR2.1, NFR2.2, NFR2.7 velocità | benchmark nella suite | verde |
| NFR2.3, NFR2.5 apertura e memoria sul telefono | — | rimandati: base reale |
| NFR2.4, NFR2.6 apertura in background, una sola volta | `wine_db_loader_test` | verde |
| NFR3.1–NFR3.5 privacy delle foto e di Lens | `lens_channel_test`, `label_image_exif_test`, `check_lens_manifest_test.sh`, e2e scenario 5 | verde |
| NFR3.6, NFR3.10 checklist (Sicurezza dei dati, repository pubblico) | voci in `docs/release-checklist.md` | presenti; sono azioni del proprietario |
| NFR4.1 copertura | `check_coverage.sh` su progetto, `lib/label/` e `lib/catalog/` | 89,17% / 98,81% / 98,17% |
| NFR4.2 suite esistente | `flutter test` 2070/0; e2e 22/24 più il rilancio | un fallimento accettato (ae246174), fuori da questo lavoro |
| NFR4.3, NFR4.4 e2e senza servizi reali | `label_test.dart` 5/5 | verde |
| NFR4.5–NFR4.15 affidabilità ed eventi | `wine_db_loader_test`, `crashlytics_catalog_event_logger_test`, `online_search_test` | verde |
| NFR5.x costi e licenze | nessun pacchetto nuovo (`connectivity_plus` c'era già); `assets/wine_db/LICENSE` e `README.md`; `check_wine_db_release.sh` | verde |
| NFR6.x stile, lingue, accessibilità | format, analyze, matrice nelle 3 lingue × testo 1,0/2,0 × chiaro/scuro | verde |
