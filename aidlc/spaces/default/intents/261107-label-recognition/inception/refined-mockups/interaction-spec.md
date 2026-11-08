# Specifica delle interazioni — riconoscimento delle etichette

## Fonti

- `inception/requirements-analysis/requirements.md` e `reviews/review-01.md`. Il proprietario ha approvato accettando i punti come rischio; qui risolvo quelli dell'interazione, e Functional Design e NFR Requirements risolvono i restanti.
- `mockups.md` e `label-mockups.html`.
- `codekb/Vinoozy/code-quality-assessment.md`.

## Flusso

1. "Aggiungi" → scelta (foto, galleria, scrivi), come oggi.
2. Foto del fronte → **"Ora il retro"** (FR1.1). Le scelte sono:
   - "Scatta il retro";
   - "Scegli dalla galleria";
   - "Salta".

   La foto condivisa con "Condividi → Vinoozy" vale come fronte e porta anche lei a "Ora il retro".
3. **Lettura** di fronte e retro (FR1.2), mostrata passo per passo.
   - Se il retro non si legge, si prosegue con il solo fronte e compare l'avviso "Retro non leggibile".
   - Se il fronte non si legge ma il retro sì, si usa il retro.
4. **Esito**, secondo l'ordine di FR2.4:
   - **Proposta sicura (R-01).** Un solo vino viene proposto da solo quando vale una di queste condizioni:
     - il codice a barre corrisponde esattamente a un vino della base o di Open Food Facts;
     - il testo corrisponde a un vino con un punteggio sopra la soglia di Functional Design, e il secondo candidato è staccato di almeno quel margine.
   - **Candidati.** In tutti gli altri casi con almeno una corrispondenza si mostra la lista dei candidati, fino a 10, invece di scegliere in silenzio.
   - **Non trovato.** Nessuna corrispondenza.
5. Da "Proposta sicura", "Non è questo" porta ai "Candidati" e, se la lista è vuota, a "Non trovato".
6. Da "Candidati", "Nessuno di questi" porta a "Non trovato".

## "Cerca online" (FR3)

- **Campo di ricerca:** già compilato con le parole più significative (nome, produttore, denominazione, annata). Si possono cambiare. Senza parole, il pulsante "Cerca" è disattivato e c'è il suggerimento "Scrivi almeno una parola".
- **Risultati:** prima quelli offline, poi quelli online. I doppioni (stesso codice a barre, oppure stesso nome normalizzato e stesso produttore) compaiono una sola volta, segnati "offline" (R-06).
- **Messaggi:**
  - senza rete: "Senza rete: cerco solo nella base sul telefono";
  - Open Food Facts spento o con il limite raggiunto: "Ricerca online non disponibile ora, riprova tra qualche minuto".
- **Scelta di un candidato:** apre il modulo compilato, anche in parte. Dal modulo si può tornare indietro alla lista.

## "Apri in Google Lens" (FR4)

- **Posizione:** ultimo pulsante, sotto "Cerca online" e "Scrivi a mano", con il testo "Google Lens è l'ultima possibilità…".
- **Conferma:** a **ogni** tocco compare il pannello di conferma.
- **Invio:** dopo la conferma si apre l'app Google con la foto del fronte. Se l'app Google non è installata, si apre il menu "Condividi". Le app che Vinoozy può aprire vanno dichiarate in `<queries>`; i dettagli in Functional Design.
- **Ritorno:** si resta nell'esito, con le stesse strade.

## Vita delle foto (R-02)

- Le foto preparate restano in `cache/label/` finché l'esito è aperto, anche più di 10 minuti. Il limite di 10 minuti di `TempLabelStore` si applica solo ai file senza un esito aperto.
- Si cancellano:
  - uscendo dall'esito (conferma, "Scrivi a mano", indietro o chiusura);
  - al prossimo avvio, se l'app è stata chiusa dal sistema anche durante Google Lens.
- La foto passata a Google Lens è una copia letta dall'app Google: Vinoozy non può cancellare la copia che Google eventualmente conserva. Questo va scritto nella conferma e nell'informativa (NFR3).

## Proposta sicura: cosa resta della scheda di oggi

La proposta mantiene quantità, "Correggi" (apre il modulo compilato) e il messaggio di errore di salvataggio dell'attuale `LabelProposalSheet`. Cambiano l'aspetto (`WineCard`) e l'aggiunta di "Non è questo".

Le corrispondenze certe vengono da:
- la base offline;
- il catalogo interno: denominazione → proposta con il solo nome della denominazione, come oggi;
- Open Food Facts online.

Tutte e tre si presentano allo stesso modo, con una nota sull'origine ("dalla base sul telefono", "dal catalogo", "da Open Food Facts").

## Assegnazione dei punti aperti

Punti di `requirements-analysis/reviews/review-01.md` e di `refined-mockups/reviews/review-01.md`.

| Punto | Dove si risolve | Cosa |
|---|---|---|
| Soglia proposta sicura / lista (req R-01) | Functional Design | punteggio, margine e test |
| Vita delle foto, errori del retro (req R-02; mockup minori) | qui, poi Functional Design | regole sopra; fotocamera annullata e permesso negato come il fronte di oggi; lettura annullabile; foto sparita al ritorno da Lens → l'esito offre solo "Cerca online" e "Scrivi a mano" |
| Schermata Informazioni (req R-03) | qui | sotto; si apre dal menu della Cantina (`cellar-menu`: Profilo, Persone, Archivio, **Informazioni**) |
| ODbL e repository pubblico (req R-04) | NFR Requirements, **escalation** al proprietario se il repository non diventa pubblico | obblighi di condivisione della base derivata |
| Velocità e memoria sul telefono (req R-05) | NFR Requirements | soglie sul OnePlus del proprietario con build release; benchmark nei test; limite di memoria |
| Doppioni e uscite (req R-06…R-08) | qui | regole sopra |
| `<queries>`, consenso a ogni tocco (req R-09) | qui e Functional Design | consenso a ogni tocco; `<queries>` per l'app Google e l'azione di condivisione |
| Dimensione dell'app (req R-10) | NFR Requirements | allineamento a `tool/check_app_size.sh` (base `UNSET`, +15 MB) con il tetto di 40 MB |
| Tre esiti "non trovato" (mockup minore) | qui | "non leggibile", "codice letto ma non trovato", "nessun vino riconosciuto": stesso schema, cambiano titolo e testo letto |
| Etichette delle bandiere, focus dopo l'esito (mockup minore) | accessibility-checklist L8–L9 | sotto |

## Schermata "Informazioni" (R-03)

È nuova e si raggiunge dal menu del profilo. Mostra:
- la versione dell'app;
- la base dei vini: numero di vini e data dell'export;
- le licenze, ODbL per la base e DbCL per i contenuti;
- la nota sulla privacy delle foto.
