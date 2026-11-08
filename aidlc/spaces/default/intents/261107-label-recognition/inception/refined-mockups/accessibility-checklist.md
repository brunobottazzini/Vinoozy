# Checklist di accessibilità — riconoscimento delle etichette

## Fonti

- `requirements.md`, NFR6 (matrice 3 lingue × testo 1,0/2,0 × chiaro/scuro).
- La checklist della UX: `aidlc/spaces/default/intents/261107-ux-redesign/inception/refined-mockups/accessibility-checklist.md`.

| # | Controllo | Dove |
|---|---|---|
| L1 | Matrice esistente sulle schermate nuove | "Ora il retro", lettura, candidati, "Cerca online", conferma Lens, Informazioni |
| L2 | Aree da toccare ≥ 48 dp | tutti i pulsanti, i candidati, "Salta" |
| L3 | La lettura in corso è annunciata dal lettore di schermo, passo per passo (regione live) | `ReadingProgress` |
| L4 | I chip "offline"/"online" e l'attribuzione si leggono come testo | `CandidateList` |
| L5 | Il pannello di Lens è annunciato come finestra; "Annulla" si raggiunge e il gesto indietro chiude | `LensConfirmSheet` |
| L6 | Contrasto ≥ 4,5:1 per avvisi e testo piccolo dell'attribuzione | tema |
| L7 | Il campo "Cerca online" ha un'etichetta e un suggerimento leggibili | `OnlineSearchScreen` |
| L8 | Ogni bandiera, anche nei candidati e nei risultati online, si legge con il nome del paese | `CandidateList`, `OnlineSearchScreen` |
| L9 | Dopo l'esito il focus va sul titolo dell'esito, che viene annunciato | esiti della lettura |
