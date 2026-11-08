# Requisiti di prestazione

## Fonti

- `inception/requirements-analysis/requirements.md`: NFR2, NFR4, FR3.1, FR6.
- `construction/functional-design/`: D1–D3, BR1, BR3.6, BR3.9, BR4.
- Benchmark esistenti in `benchmark/` e in `packages/estimation`.

## Requisiti

Il telefono di riferimento è il OnePlus CPH2581 del proprietario, con la build release.

| ID | Requisito | Soglia in CI (criterio di superamento) | Telefono (misura riportata) |
|---|---|---|---|
| NFR4.1 | `extractLabelFields` su 4000 caratteri | ≤ 200 ms nel benchmark con 1500 e più denominazioni | obiettivo 100 ms |
| NFR4.2 (derivato da NFR4) | `estimateWindow` con la tabella completa (≥ 1500 righe più 42 vitigni) | il benchmark esistente `packages/estimation/benchmark/estimation_benchmark.dart` resta entro i limiti di oggi (500 vini in ≤ 10 ms in tutto), senza alzarli; l'indice degli alias si costruisce fuori dalla misura | — |
| NFR4.3 | Costruzione dell'indice degli alias (una sola volta, la prima volta che serve) | ≤ 150 ms | ≤ 300 ms, fuori dal thread dell'interfaccia se supera 50 ms |
| NFR4.4 | Ricalcolo una tantum di tutti i vini dopo l'aggiornamento (BR3.9) | 200 vini in ≤ 1 s di calcolo | in background, senza bloccare la Cantina |
| NFR1.6 | Peso della tabella generata | `appellations.g.dart` ≤ 1 MB di sorgente; crescita dell'AAB ≤ 15 MB in tutto, base Open Food Facts compresa (controllo esistente) | misura riportata in B&T |
| NFR2.1 | Funzionamento senza rete | estrazione, incolla e stima non fanno chiamate di rete (test con rete finta spenta) | — |
| NFR4.17 (FR2.8, BR7.23) | Dal tocco su "Incolla da Lens" (o dalla lettura degli appunti nell'incolla automatico, o dal modulo visibile per il testo condiviso) al primo risultato visibile | ≤ 2 s nell'e2e con base reale aperta a freddo e Open Food Facts che non risponde (NFR5.9) | ≤ 2 s sul telefono del proprietario, ripetendo la prova del difetto (Build and Test) |
| NFR4.18 (FR2.8) | Ricerca nella base offline, nel catalogo e su Open Food Facts nel percorso dell'incolla | `lookupBudget` = 1500 ms, compresa l'apertura della base; test unitario con catalogo che non risponde | — |
| NFR4.19 (FR7.3, BR7.23) | `analyzeLabelText` (candidati, certezza, parole) su 4000 caratteri | ≤ 100 ms nel benchmark CI; obiettivo 80 ms, come il bilancio di BR7.23 | ≤ 80 ms |
| NFR4.23 (FR2.8, BR7.24) | Attesa visibile: dal tocco su "Incolla da Lens" il pulsante mostra "Leggo il testo…" entro un frame e non accetta un secondo tocco; al risultato torna attivo | test del widget con catalogo lento | controllo sul telefono |
| NFR4.24 (FR2.8, D12) | La base offline si apre in anticipo quando il modulo va in secondo piano (`AppLifecycleState.hidden`), al massimo una volta; un errore di apertura non mostra nulla e si riprova all'incolla | test del widget con ciclo di vita simulato | — |
| NFR4.20 (FR7.6) | Apertura della scheda della guida e passaggio da una domanda all'altra | test del widget: la scheda si apre e cambia domanda senza errori di layout, con testo 2,0 | nessun frame sopra 16 ms nel profilo del telefono, riportato in Build and Test |

## Motivazioni

- **Margine ×2 in CI.** Le macchine di GitHub Actions sono più lente di un telefono recente. Il limite vero resta l'esperienza: il modulo deve comparire subito dopo il tocco.
- **Indice costruito una volta.** Con 1500 righe e circa 4000 alias, una mappa dalla prima parola agli alias mantiene `findAlias` lineare nelle parole del testo, non nel numero delle righe.
