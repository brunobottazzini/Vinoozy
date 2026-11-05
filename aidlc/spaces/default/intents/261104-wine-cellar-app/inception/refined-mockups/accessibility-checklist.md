# Accessibility Checklist — Vinoozy (WCAG 2.1 AA)

Fonti: `requirements.md` (NFR3), `stories.md` (US10.1, AC5.2.2), `mockups.md`, `interaction-spec.md`, `design-system-mapping.md`. Da verificare in Construction con test dei widget e una prova manuale con TalkBack (`team-practices.md`, Testing Posture).

| # | Requisito | Dove si applica | Come si verifica |
|---|-----------|-----------------|------------------|
| A1 | Contrasto testo almeno 4.5:1, icone e bordi almeno 3:1, in tema chiaro e scuro | Tutte le schermate | Controllo dei token di `design-system-mapping.md` con uno strumento di contrasto |
| A2 | Stato mai indicato dal solo colore: icona + testo | StatusBadge, Cruscotto, Cantina | Test dei widget: ogni stato ha testo |
| A3 | Ogni elemento interattivo ha un'etichetta per TalkBack che dice cosa fa | Pulsanti, righe, - / +, grafici | Test dei widget sulle `Semantics` |
| A4 | Grafici con descrizione testuale dei valori | Cruscotto | AC5.2.2 |
| A5 | Aree toccabili almeno 48x48 dp, almeno 8 dp tra elementi vicini | - / +, barra in basso, pulsanti | Test dei widget sulle dimensioni |
| A6 | Testo di sistema al 200% senza contenuti tagliati | Cruscotto, Cantina, Dettaglio, Scrivi | Test dei widget con `textScaleFactor` 2.0 |
| A7 | Errori descritti a parole sotto il campo, con icona | Scrivi, Modifica, Invita | Test dei widget |
| A8 | Ordine di focus logico, dall'alto in basso; focus visibile | Tutte le schermate | Prova con tastiera esterna/TalkBack |
| A9 | Conferme: focus su "Annulla" all'apertura, chiusura con Indietro | ConfirmDialog | Test dei widget |
| A10 | Messaggi temporanei annunciati (regione live) e "Annulla" raggiungibile | UndoSnackbar, fascia offline | Prova con TalkBack |
| A11 | Nessun limite di tempo obbligatorio: lo "Annulla" dura 6 s ma la bevuta resta correggibile dallo Storico | Bevuta | Verifica funzionale |
| A12 | Animazioni ridotte quando il telefono lo richiede | Presentazione, transizioni | Test con "rimuovi animazioni" attivo |
| A13 | Lingua dell'interfaccia dichiarata e testi tradotti senza troncamenti nelle tre lingue | Tutte le schermate | Test dei widget in it, en, pt-BR |

Intestazioni: ogni schermata ha un titolo principale (equivalente h1) nella barra superiore e titoli di sezione (h2) per i riquadri del Cruscotto e del Dettaglio; il primo elemento raggiungibile è il titolo, poi il contenuto, poi la barra in basso.
