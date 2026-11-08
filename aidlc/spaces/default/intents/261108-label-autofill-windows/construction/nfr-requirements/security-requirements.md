# Requisiti di sicurezza, privacy e compatibilità dei dati

## Fonti

- `inception/requirements-analysis/requirements.md`: NFR1, NFR3, FR2.3, FR2.7.
- `construction/functional-design/`: BR2.3, BR2.5, BR2.6, BR5.
- `firestore.rules`, `test/rules/`, `.github/workflows/promote.yml`.

## Requisiti

| ID | Requisito | Verifica |
|---|---|---|
| NFR3.1 | Gli appunti si leggono solo:<br>- al tocco di "Incolla da Lens";<br>- una volta da soli, se la sessione di Lens ha meno di 5 minuti e l'ora di copia è successiva all'apertura di Lens (BR2.6).<br>Per controllare l'ora di copia, `clipTimestamp()` non legge il contenuto. | test con canale finto: il contenuto non si legge mai fuori da questi due casi; revisione del codice nativo |
| NFR3.2 | Il testo letto, incollato o condiviso:<br>- non finisce su disco, in Firestore, in Crashlytics, nella console, in `CatalogEventLogger` o nei messaggi di errore;<br>- si tronca a 4000 caratteri.<br>Gli eventi registrano solo l'esito. | test: le firme degli eventi accettano solo enum e numeri; test sul testo troncato |
| NFR3.3 | Nessun permesso Android nuovo. Nel manifest cambiano solo due cose:<br>- il filtro `ACTION_SEND` `text/plain`;<br>- la voce `<queries>` per `com.google.ar.lens`. | `tool/check_lens_manifest.sh`, esteso, con fixture |
| NFR3.7 (derivato da NFR3) | Incolla automatico senza risultato: se il testo letto da solo non porta né un vino trovato né un campo, si scarta subito dalla memoria e non si riprova. Verifica automatica con un test del widget e del canale finto (oltre alla revisione del codice nativo). | test |
| NFR3.4 | Il testo condiviso da un'altra app è un dato non fidato:<br>- passa solo dall'estrattore e dalla validazione del modulo (BR1.9);<br>- non si esegue né si interpreta come comando o URL;<br>- caratteri di controllo e spazi anomali si tolgono prima di tutto. | test con testi malevoli (molto lunghi, caratteri di controllo, markup) |
| NFR3.5 | Verso Open Food Facts si manda solo la query di "Cerca online" di oggi, e solo con rete e solo dai gradini esistenti (BR2.2). | test con client HTTP finto |
| NFR1.1 | I vini senza `level` e senza `windowOverride` si leggono e si mostrano come oggi. | test del modello |
| NFR1.2 | Le regole Firestore controllano i nuovi campi:<br>- `level`;<br>- `windowOverride` con `endYear` e `setAt == request.time`;<br>- `basis` `grape`;<br>- le 14 qualifiche;<br>- `denominationKey`;<br>- `tablesVersion`.<br>In aggiornamento i controlli scattano solo se il campo cambia (BR5.1). | `npm run test:rules` con casi validi e non validi per ogni campo |
| NFR1.3 | Le scritture della versione attuale dell'app sono accettate dalle regole nuove. | `test/rules/compat/`, aggiunta di `app-writes.json` |
| NFR1.4 | Un aggiornamento parziale della versione attuale su un vino con `level` e `windowOverride` è accettato, e i due campi restano. | test di compatibilità |
| NFR1.5 | Le regole si pubblicano prima della build, con l'OK del proprietario. `RULES_FEATURES` contiene `level-override`. | voce in `promote.yml` e nella checklist |
| NFR5.6 | Gli export di eAmbrosia e Open Food Facts restano fuori dal repository (`.cache/`, in `.gitignore`). Entrano solo la tabella generata, la base generata, i manifesti e le licenze. | test su `.gitignore`; scansione gitleaks esistente |
| NFR3.8 (FR7.9, BR7.22) | Candidati, parole, risposte e valori rifiutati della guida restano solo in memoria nello stato del modulo: niente disco, `restorationId`, Firestore, Crashlytics, console o eventi. Nessun evento nuovo per la guida (BR7.22): restano solo gli eventi di NFR4.15. | test del logger: nessuna chiamata con dati della guida; revisione: nessun `RestorationMixin` sulla scheda |
| NFR3.9 (FR7.5) | Il valore composto toccando le parole o scritto con "Modifica" passa la stessa validazione del modulo (BR1.9, FR1.5) prima di entrare nel campo. | test unitari con valori troppo lunghi, vuoti e con caratteri di controllo |

## Valutazione dei rischi

| Rischio | Impatto | Mitigazione |
|---|---|---|
| Lettura automatica degli appunti con dati personali (password, indirizzi) | Alto | Solo testo copiato dopo l'apertura di Lens ed entro 5 minuti; senza leggere il contenuto in anticipo; Android mostra il suo avviso (NFR3.1) |
| Un'altra app condivide testo creato ad arte | Basso | Il testo è solo dati. Validazione, troncamento e nessuna esecuzione (NFR3.4) |
| Le regole nuove non sono pubblicate prima della build | Medio | Salvataggio rifiutato con il messaggio di oggi, nessun dato perso, promozione bloccata (NFR1.5) |
| Una versione vecchia riscrive la finestra ignorando livello e correzione | Basso | La versione nuova la ricalcola all'apertura (BR5.2) |
