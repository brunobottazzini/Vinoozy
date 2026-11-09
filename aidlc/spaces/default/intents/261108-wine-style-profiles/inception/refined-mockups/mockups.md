# Mockup — profili di stile e classificazione automatica

**Mockup visivi:** https://claude.ai/artifact/Bf6R7SGnoy473yWTzKkhrz. Il file sorgente è `style-mockups.html` in questa cartella. Lo stile grafico è quello della UX approvata.

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR4, NFR1–NFR6), risposte Q1–Q4.
- Mockup approvati dei lavori precedenti (`261107-ux-redesign`, `261108-label-autofill-windows`).
- `codekb/Vinoozy/`: modulo, dettaglio, cantina, cruscotto.

## Schermate

| # | Schermata | Stato mostrato | Requisiti |
|---|---|---|---|
| S1 | Modulo dalla base (Barolo) | Tipologia e Livello preselezionati "✦ suggerito", stima con il profilo | FR2.1–FR2.4, FR3.6 |
| S2 | Modulo spumante (Champagne) | Stile preselezionato, campo facoltativo "Sboccatura" mese/anno | FR3.2, FR3.3 |
| S3 | Dettaglio in mesi | finestra marzo 2026 / marzo 2027 / marzo 2029, profilo e decorrenza | FR3.4, FR1.1 |
| S4 | Stile da confermare (Bordeaux) | avviso, stima indicativa, scelta dello stile | FR1.4, FR3.2 |
| S5 | Cantina, liquorosi | Porto LBV "pronto, nessuna fine stimata"; Fino "entro feb 2027"; Madeira "Da stimare" | FR1.3, FR1.4 |
| S6 | Cruscotto, tema scuro | "Bevi presto" con il mese, conteggio e lista "Da confermare" | FR3.4, FR1.4 |

## Stati da coprire anche senza disegno

- **Sboccatura o imbottigliamento mancanti:** il dettaglio dice "dalla data di inserimento: aggiungi la sboccatura per una stima migliore", affidabilità bassa (FR3.3).
- **Tipologia vuota:** "Stile" non compare finché non si sceglie la Tipologia (FR3.2).
- **"Consigliato fino al" in mesi:** il selettore mostra mese e anno (FR3.5).
- **Vini già in cantina:** dopo l'aggiornamento i campi preselezionati portano "✦ suggerito"; quelli già presenti restano senza segno (FR4.1).
- **Charmat/Prosecco e Lambrusco:** campo "Imbottigliamento" invece di "Sboccatura" (FR3.3).
