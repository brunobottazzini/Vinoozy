# Mockup — riconoscimento delle etichette

**Mockup visivi di questo lavoro:** https://claude.ai/artifact/38HssQticqj3xk48RH5E7F. Il file sorgente è `label-mockups.html`, in questa cartella. Lo stile è quello della UX approvata: https://claude.ai/artifact/9eQbXQaRuCowMnZH2qdakd.

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR5, NFR1–NFR6) e la sua revisione `reviews/review-01.md`. I punti R della revisione vengono risolti qui e in Functional Design.
- Stile e componenti della nuova UX approvata: `aidlc/spaces/default/intents/261107-ux-redesign/inception/refined-mockups/`.
- `codekb/Vinoozy/`: schermate di oggi del riconoscimento (`AddChoiceScreen`, `LabelReadingScreen`, `LabelProposalSheet`, viste "non leggibile" e "solo codice").

Il piano salta i mockup grezzi: si parte dalle schermate attuali e dalla UX appena approvata.

## Schermate

| # | Schermata | Stato mostrato | Requisiti |
|---|---|---|---|
| 1 | "Ora il retro" | dopo il fronte, con "Scatta il retro", "Scegli dalla galleria" e "Salta" | FR1.1 |
| 2 | Lettura in corso | fronte e retro letti, codice trovato sul retro, ricerca nella base sul telefono | FR1.2, FR2.4 |
| 3 | Proposta sicura | un solo vino certo dalla base offline, con "Conferma e aggiungi", "Non è questo" e l'attribuzione | FR2.3, FR2.5 |
| 4 | Candidati | più vini simili, segnati "offline" o "online", con "Nessuno di questi" | FR3.2, FR3.3 |
| 5 | Non trovato | testo letto; "Cerca online", "Scrivi a mano", "Apri in Google Lens" per ultimo | FR3.1, FR4.1 |
| 6 | Cerca online | parole modificabili, risultati, avviso "Senza rete", attribuzione | FR3.2, FR3.4 |
| 7 | Conferma Google Lens | pannello con la spiegazione e "Apri Google Lens" / "Annulla" | FR4.2, FR4.3, NFR3 |
| 8 | Informazioni | versione, base dei vini (numero, data), licenze, privacy | FR2.2, FR2.5 |

## Stati da coprire anche senza disegno

- Il retro non si legge o è una foto sbagliata: si continua con il solo fronte, con un avviso "Retro non leggibile".
- "Salta" sul retro: esito con il solo fronte.
- Open Food Facts spento (build demo) o con il limite raggiunto: "Cerca online" mostra solo i risultati offline, con un messaggio.
- Testo di ricerca vuoto: "Cerca online" chiede di scrivere almeno una parola.
- App Google assente: si apre il menu "Condividi".
- Ritorno da Google Lens: l'esito è ancora lì, con le stesse strade.
