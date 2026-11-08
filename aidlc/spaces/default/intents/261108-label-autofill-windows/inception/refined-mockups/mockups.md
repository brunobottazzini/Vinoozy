# Mockup — compilazione dall'etichetta e finestre per tutto il mondo

**Mockup visivi:** https://claude.ai/artifact/Ti6qLMAaD3yCPdPwy5AiJx. Il file sorgente è `autofill-mockups.html` in questa cartella. Lo stile è quello della UX approvata.

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR7, NFR1–NFR6) e le risposte Q1–Q6 del proprietario.
- La UX approvata e i mockup del riconoscimento delle etichette: `aidlc/spaces/default/intents/261107-ux-redesign/` e `261107-label-recognition/inception/refined-mockups/`.
- `codekb/Vinoozy/`: `AddWineScreen`, `EditWineScreen`, `IdealMomentCard`, `LabelReadingScreen`.

Il piano salta i mockup grezzi. Si parte dalle schermate di oggi.

Richieste del proprietario al gate dei mockup (messaggi 171e8ee1 e a1260ab6):
- l'ingresso diretto "Da Google Lens" (schermata 9, in cima alla pagina). La schermata "Aggiungi vino" passa da 3 a 4 scelte: "Scatta foto", "Da Google Lens", "Scegli dalla galleria", "Scrivi a mano";
- la base reale di Open Food Facts (FR6), che si fa in Build and Test e non ha schermate nuove.

Una schermata in più, "8b", mostra il modulo nel tema scuro.

Aggiunta in Build and Test (2026-11-08, messaggi 4e9809bc, c19931c2, 595f45dc): le schermate G0–G5 mostrano l'attesa visibile (FR2.8) e la conferma guidata dei campi incerti (FR7), con la composizione toccando le parole (FR7.5).

## Schermate

| # | Schermata | Stato mostrato | Requisiti |
|---|---|---|---|
| 1 | Modulo compilato dalla foto | campi con "✦ dal testo", Livello suggerito, barra con Pulisci / Cerca online / Lens | FR1.1, FR1.2, FR1.3, FR4.3 |
| 2 | Conferma "Pulisci" | dialogo quando ci sono campi scritti a mano | FR1.4 |
| 3 | "Incolla da Lens" | riquadro nel modulo vuoto, messaggio "Negli appunti non c'è testo" | FR2.2, FR2.4, NFR3.1 |
| 4 | "Condividi" da Lens | testo selezionato in Lens, foglio di condivisione con Vinoozy | FR2.1 |
| 5 | Campo "Livello" | tre scelte, spiegazione, anteprima della finestra | FR4.1, FR4.2, FR4.4 |
| 6 | Dettaglio con correzione | "Consigliato fino al 2038 · corretto da te", stima dell'app sotto, Correggi / Ripristina stima | FR5.2, FR5.4, FR4.4 |
| 7 | Correggi l'anno | griglia degli anni, anni non validi barrati, nota sullo spostamento di "al meglio" | FR5.1, FR5.3, FR5.6 |
| 3b | Dopo un solo tocco su "Incolla da Lens" | testo copiato e tutti i campi compilati, finestra già calcolata; incolla automatico al ritorno da Lens | FR2.2, FR2.7 |
| 9 | "Aggiungi vino" con "Da Google Lens" | ingresso diretto in Lens, senza foto in Vinoozy | FR2.6 |
| 8 | Vini del mondo, tema scuro | Malbec da Mendoza, Riesling Spätlese, Tannat stimato dal vitigno | FR3.1–FR3.4, NFR6 |
| G0 | Attesa dopo "Incolla da Lens" | pulsante "Leggo il testo…" con indicatore, non ritoccabile | FR2.8 |
| G1 | Prima domanda della guida | "Barbera d'Asti è la denominazione?", Sì / No, un'altra / Modifica / Salta, progresso "1 di 4", parole del testo | FR7.1–FR7.4, FR7.6 |
| G2 | Comporre toccando le parole | tre parole scelte e numerate, anteprima con segno DOCG, Conferma / Annulla | FR7.5 |
| G3 | Domanda dopo un "No" | candidato successivo per il produttore, parole già usate disattivate | FR7.4, FR7.5, FR7.7 |
| G4 | Fine o chiusura della guida | modulo con i campi confermati, "Conferma guidata" per riprendere, messaggio sul campo saltato | FR7.6, FR7.7 |
| G5 | Annata con la ruota, tema scuro | ruota degli anni che parte dal 2024 (anno corrente meno 2) o dall'anno del testo, anni del testo segnati, Conferma / Senza annata | FR7.3, FR7.4, FR7.8, NFR6 |

## Stati da coprire anche senza disegno

- **Testo illeggibile:** resta "Non trovato" di oggi (FR1.2).
- **Vino certo nella base:** proposta sicura come oggi (FR1.6, FR2.5).
- **Condivisione da Lens con l'app chiusa o senza accesso:** prima l'accesso, poi il modulo (FR2.1).
- **Condivisione con un modulo già aperto e modificato:** domanda "Usare il testo per i campi vuoti?" con "Usa" / "Ignora" (FR2.1, FR2.4).
- **Testo condiviso vuoto:** messaggio "Nessun testo ricevuto" (FR2.1).
- **Vino senza stima affidabile:** resta "⚠︎ Indicativo"; con la correzione diventa "corretto da te" (FR5.2).
- **Guida con tutti i campi certi:** non compare; il modulo si compila come oggi (FR7.1).
- **Nuovo testo a guida aperta:** la guida si chiude tenendo i campi confermati; il nuovo testo riempie i campi vuoti e, se serve, apre una nuova guida (FR7.7).
- **Rotazione o ritorno dal secondo piano:** la guida riprende alla stessa domanda (FR7.7).
- **"Modifica" confermato vuoto:** il campo resta vuoto e si passa avanti; un valore non valido mostra l'errore e la domanda resta (FR7.4).
