# Riepilogo di Build and Test — compilazione dall'etichetta, finestre per tutto il mondo e conferma guidata

## Fonti

- `construction/code-generation/code-generation-plan.md` (piano approvato, 22 passi)
- `construction/code-generation/unit-test-instructions.md`
- `construction/code-generation/code-summary.md`
- `test-results.md` (questa cartella)

## Esito

**Superato, con un fallimento accettato e le prove sul telefono ancora da fare.**
- Test dell'app 2492/0, copertura del progetto 90,11%; pacchetto della stima 1886/0, copertura 98,84%.
- Regole Firestore 215 passati, 1 saltato; e2e 26/27, con l'unico rosso già accettato (Storico e "Annulla", messaggio ae246174).
- Tabella reale: 2424 denominazioni (724 dedicate, 1700 dai registri); base reale: 15.616 vini. Entrambi i controlli di rilascio sono verdi.
- Formattazione e analisi pulite.

## Cosa è successo in questa fase

1. Sul telefono "Incolla da Lens" non mostrava niente: la ricerca aspettava la base reale e Open Food Facts senza limite. Corretto (FR2.8): risultato entro 2 secondi, "Leggo il testo…" subito, base aperta in anticipo.
2. Su richiesta del proprietario il lavoro è tornato ai requisiti per la **conferma guidata** dei campi incerti (FR7): domande una alla volta, Sì / No / Modifica / Salta, composizione toccando le parole, ruota dell'annata. Mockup, design, NFR e codice sono stati approvati.
3. La revisione del codice ha trovato e fatto correggere "Chianti Classico" riconosciuto come Chianti, "Salva" toccabile con la guida aperta e l'annata dell'anno prossimo.

## Scarti dai requisiti approvati

- La ruota dell'annata arriva all'anno corrente, non all'anno corrente più 1 (FR7.4), per coerenza con il controllo del salvataggio.
- 13 test esistenti hanno cambiato attesa per il comportamento approvato della guida (FR7.1, A19, BR7.8); ora falliscono se la guida non si apre.

## Cosa resta

1. **Prova sul telefono** della guida e dei 2 secondi: la build è installata, il proprietario la prova quando può.
2. Misure sul telefono: apertura della base, memoria, dimensione dell'app (`tool/app_size_baseline.txt`).
3. Prima dello store: Storico e "Annulla", avviso `setState` del `CellarSwitcher`, `OFF_CONTACT` nel segreto di GitHub, scheda "Sicurezza dei dati", repository pubblico.
4. Niente è ancora committato: il commit si fa quando il proprietario lo chiede.

## File di questa fase

- `test-results.md`
- `build-instructions.md`
- `integration-test-instructions.md`
- `performance-test-instructions.md`
- `security-test-instructions.md`
- `cross-unit-traceability.md`
