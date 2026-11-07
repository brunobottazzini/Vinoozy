# Observability Requirements — u3-wine-catalog

Fonti: `requirements.md` (NFR6, NFR8), infrastruttura di U1 (Crashlytics già presente), `rules.md` di U3 (BR2.2, BR5.1), riepilogo confermato in `nfr-requirements-questions.md`.

U3 non ha server, quindi l'osservabilità passa da Crashlytics, già usato da U1, ed è senza dati personali.

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR6.6 | Ogni sospensione di OFF (BR2.2) si registra in Crashlytics come evento non fatale `off_suspended`, con il tipo dell'ultimo errore (`timeout`, `network`, `http_<codice>`, `too_large`, `invalid_json`). Mai il testo cercato né il codice a barre. | Test con un registratore finto: un evento per sospensione, senza la query. |
| NFR6.7 | Metriche di salute calcolate sul telefono e inviate come chiavi personalizzate di Crashlytics solo insieme a un errore: richieste a OFF riuscite e fallite nella sessione, e quota di risposte dalla cache. Bastano a capire se OFF è la causa di un problema segnalato. | Test della raccolta dei contatori. |
| NFR6.8 | Soglia di attenzione: se in Crashlytics, su 7 giorni, gli eventi `off_suspended` sono più di 20 oppure riguardano più di 3 utenti (dato "utenti coinvolti" di Crashlytics), il proprietario valuta OFF (cambio di fonte o di limiti). È un controllo manuale, nella checklist mensile. | Voce in `docs/release-checklist.md`. |
| NFR8.3 | Nessun testo dell'utente (query, testo dell'etichetta, codice a barre) compare nei log, nei messaggi delle eccezioni registrate o nelle chiavi e nei valori personalizzati di Crashlytics. Gli errori di OFF si registrano solo con il tipo (NFR6.6), mai con l'URL della richiesta. | Test con valori marcatori: il registratore finto non riceve mai il marcatore, né in messaggi, né in eccezioni, né in chiavi. |
