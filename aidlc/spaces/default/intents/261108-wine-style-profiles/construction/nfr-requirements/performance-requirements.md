# Requisiti di prestazione — profili di stile

## Fonti

- `inception/requirements-analysis/requirements.md` (NFR1–NFR6, FR1–FR4).
- `construction/functional-design/` (BR1–BR11, D1–D9, ENT-101–ENT-112).
- NFR dei lavori precedenti (`261108-label-autofill-windows/construction/nfr-requirements/`), che restano validi.

## Requisiti

Telefono di riferimento: OnePlus CPH2581 del proprietario. In CI i limiti sono il doppio dell'obiettivo sul telefono.

| ID | Requisito | Soglia in CI (criterio) | Telefono |
|---|---|---|---|
| NFR3.1 (NFR3) | Preselezione di Tipologia, Livello e Stile per un vino nel modulo (`classifyWine`) | ≤ 5 ms per vino, misurato come media su 1000 vini nel benchmark del pacchetto | ≤ 50 ms per vino, compreso il ridisegno del modulo |
| NFR3.2 (NFR3) | Stima con profilo (`estimateWindow` con la tabella dei profili e la mappa) | il benchmark di oggi (500 vini ≤ 10 ms) resta entro il limite, senza alzarlo | — |
| NFR3.3 (NFR3) | Generazione della base classificata in `tool/build_wine_db.dart` | ≤ 2 minuti sull'export completo | — |
| NFR3.4 (NFR3) | Migrazione una tantum di 200 vini | ≤ 1 s di calcolo; le scritture una alla volta, in background | la Cantina resta usabile |
| NFR3.5 (FR2.5) | Peso della base classificata | ≤ 3 MB compressa, ≤ 30 MB di dati (`check_wine_db_release.sh`) | — |
| NFR3.6 (D9) | Fixture `profile-map.json` (circa 4,3 MB) | solo nei test, mai nell'app; il pacchetto dell'app non cresce per la fixture | — |

## Motivazioni

- La classificazione della base si fa una volta nel tool (D3): sul telefono costa solo la lettura di un campo.
- La mappa dei profili è una tabella costante come quelle di oggi: nessun costo di avvio in più oltre all'indice già esistente.
