# Interaction Spec — Vinoozy

Fonti: `mockups.md`, `wireframes.md`, `user-flow.md`, `stories.md`, `requirements.md`. Formato componenti da `component-spec-template.md`. Piattaforma: telefono Android (Flutter, `team-practices.md`); "desktop/tablet" = stessa interfaccia allargata.

## Schemi di interazione

| Schema | Dove | Regola |
|--------|------|--------|
| Barra in basso | Tutte le schermate principali | 4 voci fisse; il tocco sulla voce attiva riporta in cima |
| Conferma | Elimina, "-" sull'ultima bottiglia, Bevuta, Revoca, Esci con modifiche, Cancella account | Finestra con testo che nomina l'oggetto; pulsante distruttivo a destra |
| Annulla dopo l'azione | Bevuta | Messaggio in basso per 6 s con "Annulla" |
| Validazione | Scrivi, Modifica, Invita | Alla perdita del focus; errore sotto il campo con icona e testo; quanto scritto resta |
| Foglio dal basso | Dettagli della bevuta | Si chiude con trascinamento o "Salta" |
| Progressive disclosure | Dettaglio vino | Produttore/regione in una riga; dettagli della fonte in un tocco su "Fonte" |

## Componenti

## WineListTile

| Field | Value |
|---|---|
| Component | WineListTile |
| Description | Riga di un vino in Cantina e nel Cruscotto |
| Category | display |

| State | Description | Trigger |
|---|---|---|
| default | Nome, annata, stato, fiducia, quantità con - / + | dati presenti |
| focus | Bordo di focus da 2 dp | navigazione con tastiera/TalkBack |
| disabled | Senza - / + | utente "solo lettura" |
| loading | Segnaposto grigio | caricamento iniziale |
| error | Icona di sincronizzazione fallita sulla riga | modifica non sincronizzata da più di 24 h |

| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| wine | object | yes | — | nome, annata, quantità, stato, fiducia |
| canEdit | boolean | yes | — | mostra - / + |
| onTap | function | yes | — | apre il Dettaglio |
| onQuantityChange | function | no | — | correzione inventario |

| Breakpoint | Behaviour |
|---|---|
| mobile (<768px) | Due righe di testo, - / + a destra |
| tablet (768–1024px) | Una riga, stessa struttura |
| desktop (>1024px) | Non previsto |

| Requirement | Implementation |
|---|---|
| ARIA role | Semantics: button (riga), button (- e +) |
| Keyboard interaction | Tab sulla riga e sui pulsanti, Invio per attivare |
| Label / aria-label | "Barolo DOCG 2016, 2 bottiglie, pronto, fiducia alta" |
| Contrast ratio | WCAG AA (4.5:1 testo, 3:1 icone) |
| Screen reader | - / + annunciano "Togli una bottiglia" / "Aggiungi una bottiglia" e la nuova quantità |
| Focus management | Dopo la conferma del "-" sull'ultima bottiglia il focus va alla riga successiva |

## StatusBadge

| Field | Value |
|---|---|
| Component | StatusBadge |
| Description | Stato del vino con icona e testo |
| Category | feedback |

| State | Description | Trigger |
|---|---|---|
| default | ⏳ / ✓ / ⚠ / ✕ + testo | stato calcolato |

| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| status | string | yes | — | waiting / ready / drinkSoon / pastWindow |

| Requirement | Implementation |
|---|---|
| ARIA role | Semantics: text |
| Label / aria-label | Testo dello stato, mai solo il colore |
| Contrast ratio | WCAG AA |

## DrinkingWindowBar

| Field | Value |
|---|---|
| Component | DrinkingWindowBar |
| Description | Barra della finestra ideale con inizio, picco, fine e posizione di oggi |
| Category | display |

| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| start, peak, end | number | yes | — | anni |
| today | date | yes | oggi | posizione dell'indicatore |

| Requirement | Implementation |
|---|---|
| Screen reader | "Finestra ideale dal 2024 al 2036, picco nel 2030, oggi nella finestra" |

## QuantityStepper

| Field | Value |
|---|---|
| Component | QuantityStepper |
| Description | Pulsanti - / + con valore, 1–99 in inserimento, 0–99 in Cantina |
| Category | input |

| State | Description | Trigger |
|---|---|---|
| default | - valore + | sempre |
| disabled | "-" disattivo al minimo, "+" al massimo | limiti |

| Requirement | Implementation |
|---|---|
| Keyboard interaction | Frecce su/giù cambiano il valore |
| Screen reader | Annuncia il nuovo valore |

## ConfirmDialog e UndoSnackbar

Conferma: titolo che nomina l'oggetto, [Annulla] a sinistra, azione a destra; Indietro chiude come Annulla; focus sul pulsante "Annulla" all'apertura. Snackbar: 6 s, pulsante "Annulla" raggiungibile da TalkBack, annunciato con regione live.

## Stati per schermata

| Schermata | Caricamento | Vuoto | Errore | Parziale |
|-----------|------------|-------|--------|----------|
| Cruscotto | segnaposto | "La tua cantina è vuota" + Aggiungi | fascia "Non riesco a sincronizzare" | dati locali + fascia offline |
| Cantina | segnaposto righe | come Cruscotto / "Nessun vino con questi filtri" | come Cruscotto | come Cruscotto |
| Scrivi | — | campo vuoto | errore sotto il campo | nessun suggerimento: "Salva con il nome scritto" |
| Foto | anteprima | — | etichetta illeggibile / fotocamera negata | proposta incompleta → Correggi |
| Dettaglio | segnaposto | — | stima non disponibile: "Stima in arrivo alla prossima connessione" | fonte "stima per tipologia" |
| Storico | segnaposto | "Qui troverai le bottiglie che hai bevuto" | come Cruscotto | — |
| Condivisione | segnaposto | "Non condividi la cantina con nessuno" | invito non riuscito con motivo | limite 5 raggiunto |

## Responsive

Solo telefono in verticale; su schermi larghi il contenuto resta centrato con larghezza massima 600 dp. Testo di sistema fino al 200%: le righe vanno a capo, nessun testo troncato senza poterlo leggere per intero (NFR3).
