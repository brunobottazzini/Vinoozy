# Security Requirements — u5-dashboard

Fonti: `requirements.md` (NFR3, NFR4, NFR6, NFR8), `functional-spec.md` e `rules.md` di U5, regole di sicurezza di U1 e U7 (C3), riepilogo confermato in `nfr-requirements-questions.md`.

U5 è una schermata in sola lettura sui dati locali della cantina. Le regole di accesso al cloud restano quelle di U1 e U7: U5 non legge altro che i vini della cantina che l'utente può già vedere. Questo file raccoglie anche l'accessibilità (NFR3) e l'affidabilità (NFR6), perché per un'unità di interfaccia non c'è un file separato.

## Sicurezza e privacy

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR4.1 | U5 non scrive su Firestore né su altri archivi, a parte la preferenza del selettore Tipologia/Regione nelle preferenze locali. Legge solo la cantina attiva di U1. Le sue modifiche a U1 (shell dell'app e lettura dei nuovi campi del `Wine`) sono solo in lettura e non toccano le scritture di U1. | **Controllo automatico in CI:** uno script `tool/check_dashboard_readonly.sh` nel job `analyze` fallisce se in `lib/dashboard/` compaiono `.set(`, `.update(`, `.add(`, `.delete(` o import di `cloud_firestore`. Test: la preferenza è l'unico valore scritto. Le modifiche a `lib/cellar/` passano dai test di U1 (NFR7.5). |
| NFR8.1 | Nessun dato della cantina esce dal telefono per colpa di U5. L'unico evento verso Crashlytics, una finestra non valida (BR1.2), è un errore non fatale con **messaggio fisso** `dashboard_invalid_window` e il solo codice dell'errore di C2 (`invalidWindow`). L'eccezione originale di `statusOf` non si inoltra, perché il suo messaggio potrebbe contenere gli anni, e lo stack trace è quello del punto di registrazione nel cruscotto. L'evento si invia al massimo una volta per sessione dell'app, anche se più vini sono rovinati; BR1.2 si legge in questo senso. | Test con un registratore finto e un vino con anni marcatori: il registratore riceve solo il messaggio fisso e il codice. |

## Accessibilità (NFR3)

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR3.1 | Ogni grafico ha una descrizione testuale con titolo e coppie etichetta–valore; ogni barra interattiva è un nodo raggiungibile da TalkBack con etichetta e suggerimento (BR1.7). | Test dei widget con `SemanticsTester`/`find.bySemanticsLabel` nelle tre lingue. |
| NFR3.2 | Contrasto del testo almeno 4,5:1; contrasto delle barre almeno 3:1 rispetto allo sfondo, in tema chiaro e scuro. | `textContrastGuideline` per il testo. Per le barre, un test calcola il rapporto di luminanza relativa WCAG tra ogni colore di barra del tema e lo sfondo della card, in tema chiaro e scuro, e fallisce sotto 3:1. |
| NFR3.3 | Bersagli di tocco di almeno 48 dp (barre, righe, selettore, pulsanti). | `androidTapTargetGuideline` e `labeledTapTargetGuideline` nei test dei widget. |
| NFR3.4 | Testo ingrandito al 200% senza tagli né sovrapposizioni; i grafici diventano scorrevoli in orizzontale. | Test dei widget con `textScaler` 2.0 nelle tre lingue, senza eccezioni di overflow. |
| NFR3.5 | Lo stato non è mai indicato solo dal colore: icona e testo in ogni barra dello stato (FR4.5). | Test: ogni barra dello stato contiene icona ed etichetta. |

## Affidabilità (NFR6)

In `requirements.md` NFR6 è "Durabilità" dei dati; U5 non salva dati, quindi qui NFR6 copre la parte che la riguarda, cioè la tenuta della schermata davanti a dati rovinati, errori di lettura e sincronizzazione (le stesse cause che metterebbero a rischio la visione dei dati salvati).

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR6.1 | Un vino con dati non validi (finestra incoerente, tipologia sconosciuta, quantità negativa) non blocca il Cruscotto e viene contato secondo BR1.1, BR1.2, BR1.6. | Test del calcolo con vini rovinati mescolati a vini validi. |
| NFR6.2 | Un errore del flusso dei vini mostra "Impossibile preparare la cantina" con "Riprova", che riapre gli ascolti come in U1. (Nota del 2026-11-06: allineato a `security-design.md` §4, che riusa il messaggio di U1 per tutti gli errori; prima c'era "Impossibile leggere la cantina".) | Test dei widget con flusso in errore. |
| NFR6.3 | Durante la prima sincronizzazione con 0 bottiglie dalla sola cache non compare lo stato vuoto (BR1.8). | Test con `isFromCache` vero e falso. |
| NFR6.4 | Cambio di giorno (BR1.9): con l'app aperta, il cruscotto si ricalcola alla mezzanotte locale e quando l'app torna in primo piano, anche nel giorno del cambio dell'ora legale (il timer si ricalcola sull'ora locale reale, non con 24 ore fisse). | Test con orologio simulato: passaggio di mezzanotte, ritorno in primo piano, giorni di cambio dell'ora legale in Europa/Roma. |
