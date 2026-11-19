# Requisiti — Miglioramenti dal report dei tester

## Sources

- Initial description: "Leggi il report dei test e andiamo a impleemntare/sistemare le cose segnalata nel report ~/Downloads/com.vinoozy.app_feedback.pdf. Ah mi suggerisci che tipologia di aidlc usare express classic o altro" [desc]
- Workflow-selected scope: express, profondità Minimal, revisione advisory [scope]
- Report "Testers Feedback Report" della Testers Community, documento 01a1f2e1-64bd-738e-af38-c638f7b3a3ae (copia locale non versionata in `aidlc/spaces/default/knowledge/documents/`) [desc]
- Risposte alle domande: `requirements-analysis-questions.md`, Q1-Q5 [Q1] [Q2] [Q3] [Q4] [Q5]
- Code knowledge base: `aidlc/spaces/default/codekb/Vinoozy/` (business-overview, architecture, code-structure), scansione del 2026-11-19

## Intent analysis

Il report non segnala difetti: secondo i tester l'app funziona su tutti i dispositivi provati, senza crash. Propone miglioramenti con tre obiettivi:

1. **Far capire l'app a chi la apre per la prima volta.** Oggi c'è solo una presentazione di 3 pagine prima del login; dopo l'accesso non c'è nessun aiuto.
2. **Farsi trovare e far crescere gli utenti in modo organico.** Servono una descrizione dello store pensata per la ricerca, la condivisione dell'app e più recensioni.
3. **Dare un canale di aiuto e di ascolto.** Servono feedback e domande frequenti dentro l'app.

Tipo di lavoro: miglioramento di un'app esistente (brownfield) che tocca App Shell, Account, Localization e la scheda dello store. Complessità standard, ambito ben definito.

Il report consiglia anche grafica, monitoraggio delle prestazioni e localizzazione. Sono indicazioni generiche, senza un problema preciso, e restano fuori dal perimetro (vedi "Out of scope") [Q1].

## Functional requirements

### FR1 — Schermata Impostazioni [Q2]

- **FR1.1** Il menu della Cantina ha una nuova voce "Impostazioni" (chiave widget `cellar-menu-settings`) che apre la nuova schermata Impostazioni.
- **FR1.2** La schermata Impostazioni elenca, in quest'ordine: Profilo, Rivedi la guida (FR2.4), Condividi l'app (FR4), Valuta l'app (FR5), Invia un feedback (FR6), Domande frequenti (FR7), Informazioni. Profilo e Informazioni aprono le schermate che esistono già.
- **FR1.3** Le voci attuali del menu della Cantina (Profilo, Persone, Bevuti, Informazioni) restano dove sono, perché i test E2E e l'abitudine degli utenti dipendono da loro.

Criteri di accettazione:
- Given la persona è nella Cantina, When apre il menu e tocca "Impostazioni", Then vede la schermata Impostazioni con le sette voci nell'ordine di FR1.2.
- Given la schermata Impostazioni è aperta, When la persona tocca "Profilo" o "Informazioni", Then si apre la schermata esistente e il tasto Indietro riporta alle Impostazioni.

### FR2 — Guida per i nuovi utenti [Q3]

- **FR2.1** La presentazione di 3 pagine prima del login resta com'è, con "Salta".
- **FR2.2** Al primo accesso alla Cantina dopo il login parte un **giro guidato** di 3-5 passi. Ogni passo evidenzia un comando reale (aggiungi vino, foto dell'etichetta, schede Cruscotto/Cantina/Storico, menu della Cantina) con un breve testo. Ogni passo ha "Avanti" e "Salta"; l'ultimo ha "Fine".
- **FR2.3** Alla **prima apertura** del Cruscotto, dello Storico e della schermata di aggiunta del vino compare un **suggerimento** breve e contestuale, uno per schermata, che si chiude con un tocco.
- **FR2.4** La voce "Rivedi la guida" nelle Impostazioni azzera lo stato del giro guidato e dei suggerimenti e riporta la persona alla Cantina, dove il giro riparte.
- **FR2.5** Lo stato "giro visto" e "suggerimento visto" per ogni schermata è salvato sul telefono, come oggi `onboarding.seen`. Non dipende dalla rete e non viene sincronizzato.
- **FR2.6** Il giro guidato e i suggerimenti non partono nelle build E2E se il test non lo chiede. I test esistenti non devono cambiare comportamento.

Criteri di accettazione:
- Given una persona appena entrata che non ha mai visto il giro, When arriva alla Cantina, Then parte il primo passo del giro.
- Given il giro è in corso, When la persona tocca "Salta", Then il giro si chiude e non riparte ai successivi avvii.
- Given il giro è stato visto, When la persona apre per la prima volta lo Storico, Then compare il suggerimento dello Storico; When lo riapre, Then il suggerimento non compare.
- Given la persona tocca "Rivedi la guida", When torna alla Cantina, Then il giro riparte dal primo passo.
- Given l'archivio locale non è leggibile, When si apre la Cantina, Then il giro non parte e l'app non si blocca (stesso comportamento di `onboarding.seen`).

### FR3 — Descrizione dello store per la ricerca (ASO) [Q1] [Q5]

- **FR3.1** Riscrivo titolo, descrizione breve e descrizione completa delle schede `it-IT` e `en-US` in `distribution/google-play/`. Le parole chiave sono scelte per la ricerca di app per la cantina: per esempio cantina, vino, gestione cantina, etichetta, quando bere, finestra di consumo, wine cellar, wine inventory, drinking window.
- **FR3.2** La descrizione completa ha un paragrafo d'apertura e poi un elenco puntato delle funzioni principali: inventario offline, momento ideale, lettura dell'etichetta, Cruscotto, condivisione della cantina, abbinamenti, Plus.
- **FR3.3** Le altre 23 schede vengono adattate dal testo inglese nella loro lingua, con parole chiave locali, mantenendo la struttura.
- **FR3.4** Ogni testo rispetta i limiti di Google Play: titolo ≤ 30 caratteri, descrizione breve ≤ 80, completa ≤ 4000. Non usa parole vietate dalle regole dei metadati di Play, come "migliore", "n. 1", "gratis" nel titolo, prezzi o emoji ripetute.

Criteri di accettazione:
- Given i 25 file `full-description.txt`, When si esegue il controllo della pubblicazione (`tool/check_publication.mjs`) o un test equivalente, Then ogni file rispetta i limiti di lunghezza.
- Given la scheda `it-IT`, When la si legge, Then contiene un elenco puntato di almeno 6 funzioni e almeno 5 delle parole chiave italiane scelte.

### FR4 — Condividi l'app [Q1]

- **FR4.1** "Condividi l'app" apre il foglio di condivisione di Android con un messaggio promozionale tradotto e il link al Play Store (`https://play.google.com/store/apps/details?id=com.vinoozy.app`).
- **FR4.2** Il link al Play Store diventa una costante unica condivisa da inviti e "Condividi l'app", senza duplicati.

Criteri di accettazione:
- Given la persona tocca "Condividi l'app", When si apre il foglio di condivisione, Then il testo contiene il messaggio nella lingua dell'app e il link al Play Store.
- Given la condivisione fallisce o viene annullata, When si torna all'app, Then non compare nessun errore bloccante; un errore della piattaforma mostra un messaggio tradotto.

### FR5 — Valuta l'app [Q1] [Q4]

- **FR5.1** "Valuta l'app" chiede a Google Play la finestra di recensione dentro l'app. Se non è disponibile (per esempio Play Store assente o app non installata da Play), apre la pagina dell'app sul Play Store nel browser.
- **FR5.2** **Richiesta automatica** in un momento positivo, cioè subito dopo aver registrato una bevuta con 4 o 5 stelle, solo se valgono tutte queste condizioni:
  - **FR5.2.1** in cantina ci sono almeno 5 vini;
  - **FR5.2.2** sono passati almeno 7 giorni dal primo uso dell'app su quel telefono;
  - **FR5.2.3** sono passati almeno 120 giorni dall'ultima richiesta automatica, o non ce n'è mai stata una.
- **FR5.3** La data del primo uso e quella dell'ultima richiesta automatica sono salvate sul telefono. Il pulsante "Valuta l'app" non conta come richiesta automatica.
- **FR5.4** La finestra di Google Play si può sempre chiudere senza votare. L'app non mostra una propria finestra "Ti piace Vinoozy?" e non chiede altro.

Criteri di accettazione:
- Given 5 vini, primo uso di 8 giorni fa, nessuna richiesta precedente, When la persona registra una bevuta con 5 stelle, Then l'app chiede la finestra di recensione e salva la data della richiesta.
- Given le stesse condizioni ma una bevuta con 3 stelle, When la registra, Then nessuna richiesta.
- Given l'ultima richiesta automatica è di 30 giorni fa, When registra una bevuta da 5 stelle, Then nessuna richiesta.
- Given 4 vini in cantina, When registra una bevuta da 5 stelle, Then nessuna richiesta.
- Given la finestra di recensione non è disponibile, When la persona tocca "Valuta l'app", Then si apre la pagina del Play Store.

### FR6 — Invia un feedback [Q1]

- **FR6.1** "Invia un feedback" apre l'app email del telefono con il destinatario già impostato all'indirizzo di supporto della scheda dello store, un oggetto tradotto ("Feedback su Vinoozy") e in fondo al corpo la versione dell'app, il modello e la versione Android del telefono e la lingua dell'app.
- **FR6.2** L'email non parte da sola: la persona la vede, la modifica e decide se inviarla. L'app non invia dati a server propri per il feedback.
- **FR6.3** Se sul telefono non c'è un'app email, compare un messaggio tradotto con l'indirizzo di supporto, che si può copiare.

Criteri di accettazione:
- Given la persona tocca "Invia un feedback", When si apre l'app email, Then destinatario, oggetto e dati tecnici sono compilati.
- Given nessuna app email, When tocca la voce, Then vede il messaggio con l'indirizzo copiabile.

### FR7 — Domande frequenti [Q1]

- **FR7.1** "Domande frequenti" apre una schermata con 6-8 domande e risposte brevi che si aprono e chiudono con un tocco. Temi: aggiungere un vino a mano, leggere un'etichetta e usare Google Lens, come si calcola il momento ideale e come correggerlo, uso senza rete e sincronizzazione, condividere la cantina, piano Plus e limite di bottiglie, cancellare l'account.
- **FR7.2** I testi sono nell'app, tradotti nelle 25 lingue, e funzionano senza rete.
- **FR7.3** In fondo alla schermata un collegamento "Non hai trovato la risposta?" porta a "Invia un feedback" (FR6).

Criteri di accettazione:
- Given la schermata FAQ è aperta senza rete, When la persona tocca una domanda, Then la risposta si espande.
- Given la persona tocca "Non hai trovato la risposta?", Then si apre l'email di feedback come in FR6.

## Non-functional requirements

- **NFR1 — Localizzazione:** ogni testo nuovo dell'interfaccia (Impostazioni, giro guidato, suggerimenti, messaggio di condivisione, feedback, FAQ) esiste in tutte le 25 lingue di `appLocales`. Il controllo dei messaggi non tradotti (`l10n_untranslated.json`) resta vuoto e il test generato `l10n_exercise_test.dart` viene rigenerato.
- **NFR2 — Qualità e test:** copertura delle righe ≥ 80% su tutto `lib/`, codice generato compreso; `dart format`, `flutter analyze` e i test E2E esistenti restano verdi. Per ogni requisito FR c'è almeno un test che lo verifica (strategia Minimal). Ci sono test dei widget per Impostazioni, giro guidato, suggerimenti e FAQ in it, en e pt-BR.
- **NFR3 — Privacy e Data safety:** nessun nuovo dato personale raccolto o inviato a server di Vinoozy. Gli stati di guida e recensione restano sul telefono. Il feedback parte solo dall'app email della persona. La dichiarazione Data safety di Google Play non cambia.
- **NFR4 — Nessuna interruzione aggressiva:** al massimo una richiesta automatica di recensione ogni 120 giorni. Giro guidato e suggerimenti compaiono una sola volta per telefono, salvo "Rivedi la guida".
- **NFR5 — Accessibilità:** le nuove voci e i passi del giro hanno etichette leggibili da TalkBack e aree di tocco di almeno 48×48 dp. Il giro guidato si può chiudere anche con il tasto Indietro.
- **NFR6 — Prestazioni:** aprire Impostazioni o FAQ non richiede rete né letture da Firestore. Il controllo delle condizioni della recensione (FR5.2) non aggiunge letture da Firestore oltre al conteggio dei vini che l'app ha già in memoria.
- **NFR7 — Sicurezza dei link:** i link esterni restano ristretti. Il canale `com.vinoozy.app/links` si estende solo dove serve: email (`mailto:` verso l'indirizzo di supporto) e il ripiego del Play Store su `https`. Nessun altro schema viene aperto.

## Constraints

- Flutter per Android, Riverpod, navigazione con `Navigator.push`; codice, identificatori e commenti in inglese (regola di progetto).
- Budget cloud 0 €/mese: nessun nuovo servizio cloud. In-App Review e condivisione sono API del telefono e di Google Play.
- Dipendenze nuove: solo `in_app_review` (per FR5). `share_plus` c'è già. Dopo l'aggiunta va verificato il manifest unito di release (`tool/check_release_build.sh`).
- Rilascio dal canale di test interno di Google Play, poi produzione con approvazione manuale del proprietario e rilascio graduale. Servono versione nuova e note di rilascio nelle 25 lingue.

## Assumptions

- `[assumption]` L'indirizzo di supporto per il feedback è quello già dichiarato in `distribution/google-play/README.md`.
- `[assumption]` Per l'ASO non uso strumenti a pagamento di ricerca delle parole chiave. Le scelgo dai termini con cui si descrivono le app per la cantina e le spiego nella scheda; il proprietario può correggerle.
- `[assumption]` Traduco io le stringhe nuove e i testi dello store nelle 23 lingue oltre a it/en, come per la versione 0.3.0, segnando i testi da far rileggere a un madrelingua se servisse.
- `[assumption]` "Primo uso" (FR5.2.2) è la data in cui l'app registra per la prima volta questo stato sul telefono dopo l'aggiornamento. Per chi ha già l'app, il conteggio dei 7 giorni parte dall'aggiornamento.
- `[assumption]` Il giro guidato è costruito con widget propri, senza librerie di "coach mark", per non aggiungere dipendenze. La scelta finale spetta alla generazione del codice.
- `[assumption]` Le catture dello store non cambiano in questo giro.

## Out of scope

- Ridisegno della grafica o delle icone ("Visual Enhancements" del report): consiglio generico, senza un problema preciso.
- Monitoraggio delle prestazioni: Crashlytics è già attivo; il report non segnala lentezze.
- Revisione completa delle traduzioni esistenti: il report non indica errori precisi.
- QR code per la condivisione e link brevi con servizi esterni.
- Base di conoscenza online o pagina web delle FAQ.
- Nuove catture dello store.

## Open questions

None.
