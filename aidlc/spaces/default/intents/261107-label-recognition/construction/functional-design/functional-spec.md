# Specifica funzionale — riconoscimento delle etichette

## Fonti

- `inception/requirements-analysis/requirements.md`.
- `inception/refined-mockups/` (`label-mockups.html`, `interaction-spec.md`).
- `codekb/Vinoozy/`.
- `entities.md` e `rules.md` di questa fase.

## Decisioni di progettazione

### D1 — Formato della base offline

**Contesto.** Su Open Food Facts ci sono circa 17.000 vini, misurati il 2026-11-07, con molti prodotti etichettati per errore. Il proprietario vuole la base inclusa nell'app (Q1 = A) e nessun costo.

**Decisione.** Un file dati compresso incluso negli asset dell'app: righe JSON compatte, compresse con gzip. Al primo uso viene decompresso in background e caricato in memoria, con due indici: un dizionario per codice a barre e una lista di parole normalizzate per il confronto del testo. Stima:
- circa 2 MB senza compressione e meno di 1 MB compresso;
- in memoria qualche MB.

**Alternative scartate:**
- **database SQLite incluso** (pacchetto `sqflite`): utile oltre le centinaia di migliaia di righe, qui aggiunge una dipendenza e una copia del file senza vantaggi reali;
- **download al primo avvio**: scartato dal proprietario (Q1).

**Conseguenze.**
- Nessun pacchetto nuovo.
- L'apertura richiede la decompressione: il limite è 1,5 s fuori dal thread dell'interfaccia (NFR2).
- Se la base crescesse oltre 200.000 vini si riconsidera SQLite.

### D2 — Costruzione della base

**Decisione.** Uno strumento Dart da riga di comando in `tool/`:
- legge in streaming l'export CSV compresso di Open Food Facts, scaricato a mano dal proprietario o da un job manuale;
- applica BR2.1–BR2.4;
- scrive il file della base e un piccolo manifesto con la data e il numero di vini.

I test usano un estratto di prova nel repository.

**Alternativa scartata.** L'API di ricerca pagina per pagina: Open Food Facts chiede di usare gli export per i download massivi.

**Conseguenze.** L'aggiornamento è un passo della checklist di rilascio.

### D3 — Confronto del testo

**Decisione.**
- Formula esatta in BR3.6: parole distintive pesate per lunghezza, elenco delle parole comuni, tetto 0,60 per i vini con meno di 2 parole distintive, bonus annata +0,05.
- Soglie di BR3.2: proposta sicura ≥ 0,85 con almeno 2 parole distintive e un distacco di 0,15; candidati ≥ 0,45.
- Il tetto evita che un vino registrato solo come "Barolo" diventi una proposta sicura per qualsiasi etichetta con quella parola.

**Alternativa scartata.** La distanza di modifica su tutto il testo: è troppo lenta su 17.000 vini e sensibile al rumore della lettura.

### D4 — Google Lens

**Decisione.**
- Prima prova: `Intent.ACTION_SEND` con l'immagine, diretto al pacchetto dell'app Google (`com.google.android.googlequicksearchbox`), che la apre in Lens.
- Se il pacchetto non c'è o non accetta l'intent: `Intent.createChooser` (menu Condividi).
- `FileProvider` limitato a `cache/label/`, permesso di lettura temporaneo, `<queries>` per il pacchetto Google e per `ACTION_SEND` di immagini.

**Alternativa scartata.** L'URL web di Lens nel browser: non si può allegare una foto locale.

### D5 — Rete

**Decisione.** Il gradino online si chiede solo se il controllo di connettività dice "rete disponibile" e Open Food Facts è attivo nella build (BR6.1). Questo corregge il falso `off_suspended`.

## Flussi

### F1 — Lettura con fronte e retro

1. L'utente sceglie la foto del fronte (fotocamera, galleria o condivisione).
2. Si mostra "Ora il retro" (BR1.1). La foto del retro arriva da fotocamera o galleria; "Salta", fotocamera annullata o permesso negato equivalgono a nessun retro (BR1.6).
3. Si preparano e si leggono le foto come oggi, una per volta, con l'avanzamento visibile.
4. Si uniscono testo e codice (BR1.2, BR1.3), con i casi di BR1.5.
5. Si applica l'ordine dei tentativi (BR3.1) e si decide l'esito (BR3.2, BR3.4).

### F2 — Esiti

- **Proposta sicura** → conferma come oggi (quantità, Correggi), oppure "Non è questo" → candidati / non trovato (BR3.5).
- **Candidati** → scelta di un candidato → modulo compilato (BR4.4); "Nessuno di questi" → non trovato.
- **Non trovato** (tre tipi, BR3.4) → "Cerca online" (F3), "Scrivi a mano" (modulo con il testo letto) oppure "Apri in Google Lens" (F4).

### F3 — Cerca online

1. Il campo parte già compilato (BR4.1); "Cerca" è disattivato se il campo è vuoto (BR4.2).
2. Si cerca nella base offline e, se possibile, online (BR4.2, BR4.3). Stati possibili: caricamento, risultati, nessun risultato, senza rete, limite raggiunto.
3. La scelta di un risultato apre il modulo compilato (BR4.4).

### F4 — Google Lens

Conferma (BR5.1), intent o menu Condividi (BR5.2), ritorno all'esito (BR5.3).

### Ciclo di vita di `LabelCapture`

| Stato | Evento | Stato successivo |
|---|---|---|
| nessuno | foto del fronte | `frontTaken` |
| `frontTaken` | retro, Salta o annullato | `reading` |
| `reading` | annulla | nessuno (file cancellati) |
| `reading` | lettura finita | `outcomeOpen` |
| `outcomeOpen` | Lens | `outcomeOpen` (file ancora in uso) |
| `outcomeOpen` | conferma, Scrivi a mano, indietro o chiusura | nessuno (file rilasciati e cancellati, BR1.4) |
| qualsiasi | processo chiuso dal sistema | nessuno: al riavvio la Cantina, file rimasti cancellati (BR1.4, BR5.3) |

Il fronte e il retro della lettura corrente sono "in uso" in `TempLabelStore` dall'inizio della lettura fino all'uscita dall'esito: la pulizia a 10 minuti e il `release` di fine lettura non li toccano (BR1.4).

## Escalation al proprietario

La licenza ODbL chiede che la base derivata sia disponibile con la stessa licenza. Il repository `github.com/brunobottazzini/Vinoozy` è previsto pubblico (pagina di cancellazione su GitHub Pages), ma oggi non è verificato. Se resta privato serve un'altra pubblicazione della base (per esempio un rilascio pubblico del solo file). Lo chiedo al proprietario al gate di questa fase.

### Schermata Informazioni

Dal menu della Cantina (`cellar-menu`), contenuto di BR6.3.

## Componenti che cambiano (riepilogo)

- `lib/label/`:
  - `LabelReader` accetta due foto e restituisce la lettura unita;
  - la sessione di lettura gestisce il retro e la vita dei file;
  - l'esito ha tre tipi più "candidati";
  - nuove viste per retro, candidati, "Cerca online" e conferma di Lens.
- `lib/catalog/`:
  - nuova fonte offline: indice puro in `core/`, lettura del file in `platform/`;
  - `matchLabelText` restituisce i candidati con punteggio invece del primo risultato;
  - il gradino online controlla la rete.
- Android:
  - `FileProvider` e `<queries>` nel manifest;
  - codice nativo per l'intent di Lens con ripiego al menu Condividi.
- `tool/`: strumento di costruzione della base ed estratto di prova.
- Nuova schermata Informazioni e voce del menu della Cantina.
