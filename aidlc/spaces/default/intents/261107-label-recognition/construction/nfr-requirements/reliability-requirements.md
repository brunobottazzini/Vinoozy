# Requisiti di affidabilità — riconoscimento delle etichette

## Fonti

- `construction/functional-design/rules.md` (BR1.4–BR1.6, BR2.4, BR3.1, BR4.3, BR5.2, BR6.1).
- `inception/requirements-analysis/requirements.md` (NFR4).
- `codekb/Vinoozy/` (interruttore di Open Food Facts, `TempLabelStore`).

## Requisiti

| ID | Requisito | Verifica |
|---|---|---|
| NFR4.5 | Base offline mancante, corrotta o illeggibile: l'app non si blocca. Si salta la base, si registra un evento `wine_db_unavailable` e si continua con il catalogo interno e Open Food Facts. | test unitario con file vuoto, gzip rotto e riga JSON rotta |
| NFR4.6 | Una riga rotta nella base si scarta e non ferma il caricamento delle altre. | test unitario |
| NFR4.7 | Lo strumento di costruzione non sostituisce la base se il controllo di plausibilità fallisce (BR2.4): esce con errore e lascia il file precedente. | test dello strumento |
| NFR4.8 | Senza rete il gradino online non si chiama e non conta come guasto (BR6.1). | test con controllo di rete finto |
| NFR4.9 | Ogni chiamata a Open Food Facts ha la scadenza esistente di 5 s; un errore porta ai soli risultati offline con il messaggio corrispondente, mai a un errore senza uscita. | test con client finto (timeout, 429, 500) |
| NFR4.10 | Google Lens: pacchetto mancante o `ActivityNotFoundException` portano al menu Condividi (BR5.2); se anche quello fallisce si mostra un messaggio e l'esito resta aperto. | test del canale finto + prova a mano sul telefono |
| NFR4.11 | Retro non leggibile, annullato o negato: la lettura continua col fronte (BR1.5, BR1.6). | test unitari + e2e "Salta" |
| NFR4.12 | Processo chiuso dal sistema mentre l'utente è in Google: al riavvio si parte dalla Cantina e `cache/label/` è vuota (BR1.4, BR5.3). | test di `TempLabelStore` all'avvio |

## Motivazioni

La base offline è un aiuto, non un servizio indispensabile: se manca, il riconoscimento torna a funzionare come oggi (catalogo interno + Open Food Facts). Per questo i guasti della base si registrano ma non si mostrano all'utente come errore.
