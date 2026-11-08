# Tracciabilità — controllo finale (pending-banner-fix)

Fonte: `aidlc engine sensor-traceability --stage build-and-test` (2026-11-07).

**Verdetto: NON SUPERATO.** 1 elemento su 8 non è coperto: **NFR2**.

| ID | Coperto | Fase / file | Note |
|---|---|---|---|
| FR1.1 | sì | code-generation: `lib/cellar/data/pending_writes_probe.dart` | 3 test di regressione, che falliscono sul codice vecchio |
| FR1.2 | sì | code-generation: `lib/cellar/data/pending_writes_probe.dart` | |
| FR1.3 | sì | code-generation: `lib/cellar/data/pending_writes_probe.dart` | |
| FR2 | sì | code-generation: `lib/cellar/data/pending_writes_probe.dart` | test di avvio invariati e verdi |
| NFR1 | sì | code-generation: `test/cellar/data/drinking_record_repository_test.dart` | suite verde, copertura 89,12% / 95,27% |
| NFR2 | **no** | — | `cellar_test.dart` non passa 5 corse su 5, per il doppione nello Storico (`test-results.md` §3); era `Deferred` a Build and Test |
| NFR3 | sì | code-generation: `lib/cellar/data/pending_writes_probe.dart` | |
| NFR4 | sì | code-generation: `lib/cellar/data/pending_writes_probe.dart` | |

FR1 è coperto tramite FR1.1–FR1.3.
