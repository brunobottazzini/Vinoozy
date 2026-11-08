# Checklist di accessibilità — nuova UX

## Fonti

- `inception/requirements-analysis/requirements.md`, NFR1.
- La matrice di accessibilità della prima versione: 3 lingue × testo 1,0/2,0 × tema chiaro/scuro (test esistenti in `test/`).
- `design-system-mapping.md` e `interaction-spec.md`.

| # | Controllo | Dove | Come si verifica |
|---|---|---|---|
| A1 | Contrasto del testo ≥ 4,5:1 in chiaro e scuro, compresi gli stati e il testo su bordeaux | tema, `StatusColors` | test sulle coppie di colori del tema, sul modello di `status_colors_test.dart` |
| A2 | Il colore non è mai l'unico segnale: tipo con nome, stato con testo | `WineCard`, Dashboard | test di widget: testo del tipo e dello stato presenti |
| A3 | Le bandiere sono lette con il nome del paese, non con l'emoji | `CountryFlag`, `CountryPicker`, schede | test di semantica: etichetta "Italia", "Argentina" ecc. |
| A4 | Aree da toccare di almeno 48 × 48 dp | "Ho bevuto", celle dei paesi, chip delle regioni, stelle, FAB | test con le guide di Flutter (`androidTapTargetGuideline`) |
| A5 | Nessun overflow con il testo a 2,0 nelle 3 lingue | tutte le schermate cambiate | matrice esistente estesa ai nuovi componenti |
| A6 | Il pannello "Ho bevuto" è annunciato come finestra, con "Annulla" raggiungibile e chiusura con il gesto indietro | `DrinkConfirmSheet` | test di widget e di semantica |
| A7 | Le stelle del voto sono leggibili ("3 stelle su 5") e si cambiano anche con il lettore di schermo | `DrinkConfirmSheet` | test di semantica |
| A8 | Il contrasto del testo bianco sul bordeaux del FAB e dei pulsanti è ≥ 4,5:1 | tema | A1 |
| A9 | Le animazioni del pannello rispettano la riduzione del movimento del sistema | `DrinkConfirmSheet` | animazioni standard di Flutter (`MediaQuery.disableAnimations`) |
