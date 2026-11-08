# Tracciabilità — controllo finale (ux-redesign)

Fonte: `aidlc engine sensor-traceability --stage build-and-test` (2026-11-07).

**Verdetto: SUPERATO.** 18 elementi su 18 sono coperti: FR1.1–FR1.5, FR2.1–FR2.4, FR3.1–FR3.4 e NFR1–NFR5. Nessun elemento è scoperto.

| Gruppo | Coperto | Dove è costruito (sintesi) |
|---|---|---|
| FR1 Paese e regione | sì | `lib/cellar/domain/wine_origins.dart`, `lib/cellar/ui/origin_pickers.dart`, `lib/app/ui/country_flag.dart`, `wine_repository.dart`, `firestore.rules` |
| FR2 "Ho bevuto" | sì | `lib/cellar/ui/drink_confirm_sheet.dart`, `drink_flow.dart`, `drinking_record_repository.dart` (voto nello stesso batch) |
| FR3 Identità visiva | sì | `lib/app/theme.dart`, `wine_card.dart`, `wine_badges.dart`, `ideal_moment_card.dart`, Dashboard |
| NFR1–NFR5 | sì | test di accessibilità e contrasto, copertura, nessuna dipendenza, compatibilità delle regole, ARB |

La tracciabilità statica è completa. A runtime NFR2 resta `Not Met` per un end-to-end (`build-and-test-summary.md`), ma l'elemento è costruito.
