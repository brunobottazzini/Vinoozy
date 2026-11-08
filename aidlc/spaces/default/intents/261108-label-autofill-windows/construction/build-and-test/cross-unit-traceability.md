# Tracciabilità tra le parti

## Fonti

- `inception/requirements-analysis/traceability.json`
- `construction/functional-design/traceability.json`
- `construction/nfr-requirements/traceability.json`
- `construction/code-generation/traceability.json`

Il lavoro non ha Units: è un'unica iterazione. La tracciabilità va dai requisiti al design, agli NFR, al codice e ai test.

| Requisito | Design | NFR | Codice e test |
|---|---|---|---|
| FR1 compilazione dal testo | BR1, D1 | NFR4.1 | `label_fields.dart`, `label_fields_test.dart`, `label_texts.json` |
| FR2.1–FR2.7 Lens, incolla, condividi | BR2, D4 | NFR3.1–NFR3.7 | `lens_channel.dart`, `LensIntentLauncher.kt`, `autofill_test.dart` |
| FR2.8 risultato entro 2 secondi | BR7.23, BR7.24, D12 | NFR4.17, NFR4.18, NFR4.21, NFR4.23, NFR4.24 | `text_autofill.dart`, `autofill_widgets.dart`, `autofill_form_test.dart`, e2e dei 2 secondi |
| FR3 finestre per tutto il mondo | BR3, D2 | NFR4.2–NFR4.5, NFR4.12 | `tables`, `appellations.g.dart`, `world_estimate_test.dart` |
| FR4 Livello | BR4 | NFR4.11 | `wine_level_selector.dart`, `window.dart` |
| FR5 correzione della finestra | BR4.5, BR5 | NFR4.14 | `window_override_widgets.dart`, `override_test.dart` |
| FR6 base reale Open Food Facts | BR6 | NFR5.6 | `assets/wine_db/`, `check_wine_db_release.sh` |
| FR7 conferma guidata | BR7.1–BR7.22, D7–D11, D13, ENT-007–ENT-014 | NFR3.8, NFR3.9, NFR4.19, NFR4.20, NFR4.22, NFR6.2, NFR5.10 | `label_candidates.dart`, `label_words.dart`, `guided_session.dart`, `guided_confirm_sheet.dart`, `label_analysis_test.dart`, `guided_confirm_test.dart`, e2e della guida |

I sensori di tracciabilità di ogni fase danno 0 righe mancanti (code-generation: 174 ID a monte).
