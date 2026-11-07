# Tracciabilità tra le unità — controllo finale

Fonte: `aidlc engine sensor-traceability --stage build-and-test` (2026-11-07).

## Verdetto

**NON SUPERATO.** 2 elementi su 108 non sono coperti: **NFR1** e **NFR2**. In entrambi i casi l'unica parte mancante è una misura di U1 sul telefono di riferimento con build release:

| ID | Parte mancante | Stato registrato in Code Generation di U1 | Dove si chiude |
|---|---|---|---|
| NFR1 | `u1-skeleton: NFR1.1`: salvataggio fino alla lista ≤ 300 ms | `Deferred`: misurato solo su emulatore debug (in questa fase 1.987–2.084 ms contro il limite provvisorio di 2 s) | misura del proprietario, `docs/release-checklist.md` §1 |
| NFR2 | `u1-skeleton: NFR2.1`: avvio a freddo con la lista ≤ 2 s | `Deferred`: su emulatore mediana 586 ms (limite CI 4 s) | misura del proprietario, `docs/release-checklist.md` §1 |

Nel piano nessuna fase successiva possiede queste misure (Operation è saltata), quindi le segnalo al gate.

## Copertura per ID

### Requisiti funzionali (44 su 44 coperti)

| ID | Coperto tramite | Unità e file principali |
|---|---|---|
| FR1.1, FR1.2 | AC1.1.1–AC1.1.3 | u1-skeleton: `lib/account/account_gate.dart`, `lib/account/ui/sign_in_screen.dart` |
| FR1.3 | AC1.2.1–AC1.2.2 | u8-account: `lib/account/ui/profile_screen.dart` |
| FR1.4 | AC1.3.1–AC1.3.2 | u8-account: `lib/account/ui/delete_account_screen.dart`, `lib/account/deletion/account_deletion_runner.dart` |
| FR2.1, FR2.6, FR2.7 | AC2.1.1–AC2.1.4 | u1-skeleton + u4-cellar: `lib/cellar/ui/add_wine_screen.dart`, `lib/cellar/data/wine_repository.dart`, `lib/cellar/domain/wine_validator.dart` |
| FR2.2, FR2.3 | AC2.2.1–AC2.2.5 | u6-label-recognition: `lib/label/ui/*` |
| FR2.4 | AC2.1.x, AC2.2.x | u4-cellar, u6-label-recognition |
| FR2.5 | AC2.3.1 | u4-cellar: `lib/cellar/cellar_actions.dart` |
| FR3.1–FR3.4 | AC3.1.1–AC3.4.2 | u4-cellar: `lib/cellar/ui/wine_list_tile.dart`, `cellar_screen.dart`, `domain/cellar_filter.dart`, `ui/cellar_dialogs.dart` |
| FR4.1–FR4.4, FR4.7 | AC4.1.1–AC4.1.3 | u2-estimation `packages/estimation/lib/src/window.dart`; u3-wine-catalog `lib/catalog/core/catalog_coordinator.dart`; u4-cellar `window_card.dart`, `window_adjuster.dart`, `estimate_refresher.dart` |
| FR4.5, FR4.6 | AC4.2.1–AC4.2.3 | u2-estimation `test/status_test.dart`; u4-cellar `cellar_filter.dart`, `wine_labels.dart` |
| FR5.1, FR5.2 | AC5.1.1–AC5.1.2 | u5-dashboard: `lib/dashboard/ui/drink_soon_section.dart` |
| FR5.3–FR5.6 | AC5.2.1–AC5.2.3 | u5-dashboard: `chart_cards.dart`, `dashboard_card.dart`, `tool/perf_cold_start.sh` |
| FR6.1, FR6.2, FR6.4 | AC6.1.1–AC6.1.2 | u4-cellar: `drinking_record_repository.dart`, `wine_repository.dart` |
| FR6.3 | AC6.2.1–AC6.2.2 | u4-cellar: `lib/cellar/ui/history_screen.dart` |
| FR7.1, FR7.2 | AC7.1.1–AC7.1.2 | u2-estimation `pairings.dart`; u3-wine-catalog; u4-cellar `window_card.dart` |
| FR8.1, FR8.2 | AC8.1.1–AC8.1.3, AC8.4.1–AC8.4.2 | u7-sharing: `invite_form.dart`, `invite_validator.dart`, `sharing_screen.dart` |
| FR8.3 | AC8.2.1 | u7-sharing: `sharing_screen.dart` |
| FR8.4 | AC8.3.1–AC8.3.2 | u7-sharing: `lib/cellar/ui/cellar_screen.dart`, `firestore.rules` |
| FR9.1–FR9.3 | AC9.1.1–AC9.1.3 | u1-skeleton: `integration_test/u1_skeleton_test.dart`, `lib/sync/sync_status.dart`, `lib/firebase/firestore_bootstrap.dart` |
| FR9.4 | AC9.2.1 | u1-skeleton `wine_repository.dart`; u4-cellar `integration_test/concurrent_drink_test.dart` |
| FR10.1, FR10.2 | AC10.1.1–AC10.1.3 | u1-skeleton: `lib/app/locale_resolution.dart`, `theme.dart`, `test/helpers/ui_harness.dart` |

### Criteri di accettazione (56 su 56 costruiti)

Ogni AC da AC1.1.1 ad AC10.1.3 ha almeno un file che lo costruisce, con l'unità indicata nella tabella sopra.

### Requisiti non funzionali (6 su 8 coperti)

| ID | Coperto | Unità che lo consegnano | Note |
|---|---|---|---|
| NFR1 | **no** | u1, u3, u4, u6, u8 | manca `u1-skeleton: NFR1.1` (vedi Verdetto). `u1-skeleton: NFR1.2` è N/A: consegnato da u4-cellar |
| NFR2 | **no** | u1, u2, u3, u4, u5, u6, u7 | manca `u1-skeleton: NFR2.1` (vedi Verdetto). `u1-skeleton: NFR2.3` è N/A: consegnato da u5-dashboard |
| NFR3 | sì | u1, u4, u5, u6, u7, u8 | |
| NFR4 | sì | tutte le unità | `u6-label-recognition: NFR4.3` è N/A: non c'è ancora una cartella `ios/`; i testi dei permessi iPhone sono in `docs/release-checklist.md` §1-sexies |
| NFR5 | sì | u1, u3, u4, u6, u7, u8 | |
| NFR6 | sì | u1, u3, u4, u5, u6, u7, u8 | nota: in Build and Test **u4-cellar NFR6.6 è `Not Met`** a runtime (vedi `build-and-test-summary.md`), anche se è costruito |
| NFR7 | sì | u5-dashboard (NFR7.5) | |
| NFR8 | sì | tutte le unità | `u1-skeleton: NFR8.5` è N/A: cancellazione in u8-account, foto in u6-label-recognition |

## Elementi non coperti

- `u1-skeleton: NFR1.1`: misura sul telefono di riferimento (proprietario).
- `u1-skeleton: NFR2.1`: misura sul telefono di riferimento (proprietario).
