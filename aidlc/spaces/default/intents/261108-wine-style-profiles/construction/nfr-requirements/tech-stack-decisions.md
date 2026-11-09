# Scelte tecniche — profili di stile

## Fonti

- `inception/requirements-analysis/requirements.md` (NFR1–NFR6, FR1–FR4).
- `construction/functional-design/` (BR1–BR11, D1–D9, ENT-101–ENT-112).
- NFR dei lavori precedenti (`261108-label-autofill-windows/construction/nfr-requirements/`), che restano validi.

## Scelte

- **Nessun pacchetto nuovo.** Profili e mappa nel pacchetto `estimation` (Dart puro, D1); ruota dell'anno con `ListWheelScrollView` già usata per l'annata.
- **Base classificata generata nel tool** (D3) dalla stessa funzione `classifyWine` del pacchetto, così app e tool non divergono.
- **Fixture** `profile-map.json` e `classification-sample.json` solo in `packages/estimation/test/fixtures/` (D9).

## Requisiti di qualità

| ID | Requisito |
|---|---|
| NFR4.1 | Copertura ≥ 80% delle righe sul progetto senza esclusioni, ≥ 90% sul pacchetto `estimation` (BR11.1) |
| NFR4.2 | Un test per ogni profilo e per ogni combinazione della mappa (5946) con profilo, decorrenza, unità e valori; le 60 righe della "Revisione 60" |
| NFR4.3 | Campione di 100 vini: Tipologia giusta ≥ 95% dei preselezionati, Livello ≥ 85%, vini senza indizi lasciati vuoti. Copertura della base: il test fallisce sotto l'**84%** (minimo accettato dal proprietario, messaggio 2c43a871) e se la quota misurata non coincide con `classifiedTypeShare` del manifest; obiettivo 90% stampato |
| NFR4.5 | Suite esistente verde; e2e del modulo con Stile e data di sboccatura (BR11.2) |
| NFR5.1 (NFR5) | Codice in inglese; testi nei 3 file ARB; matrice di accessibilità (3 lingue × testo 1,0/2,0 × chiaro/scuro) per chip dello Stile, campo mese/anno, avviso e riquadro "Da confermare" |
| NFR5.2 (NFR5) | Criteri verificabili in ogni combinazione della matrice: `meetsGuideline(androidTapTargetGuideline)` (≥ 48 dp), `meetsGuideline(textContrastGuideline)` (AA), `meetsGuideline(labeledTapTargetGuideline)`; "✦ suggerito" e la stima aggiornata letti dal lettore di schermo; nessun overflow con testo 2,0 |
