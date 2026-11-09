# Requisiti di sicurezza, privacy e compatibilità dei dati — profili di stile

## Fonti

- `inception/requirements-analysis/requirements.md` (NFR1–NFR6, FR1–FR4).
- `construction/functional-design/` (BR1–BR11, D1–D9, ENT-101–ENT-112).
- NFR dei lavori precedenti (`261108-label-autofill-windows/construction/nfr-requirements/`), che restano validi.

## Requisiti

| ID | Requisito | Verifica |
|---|---|---|
| NFR2.1 | I vini salvati senza stile, provenienza, data di sboccatura o imbottigliamento, finestra in mesi restano validi e si mostrano come oggi | test del modello e delle regole con documenti di oggi |
| NFR2.2 | Le regole Firestore accettano i campi nuovi (`style`, `typeSource`, `levelSource`, `styleSource`, `agingStartMonth`, finestra con unità e picco/fine facoltativi, `migrationVersion`) con valori da elenchi chiusi e intervalli validi; le finestre in mesi si confrontano come intero anno×12+mese (BR10.2) | `npm run test:rules` con casi validi e non validi per ogni campo |
| NFR2.3 | Una versione vecchia dell'app che aggiorna un vino nuovo non cancella i campi nuovi (aggiornamenti parziali `update`) | test di compatibilità in `test/rules/compat/` |
| NFR2.4 (NFR2) | Le regole nuove si pubblicano prima della build, solo con l'OK del proprietario; `RULES_FEATURES` di `promote.yml` contiene `style-profiles` | voce in `promote.yml` e nella checklist; **ripristino**: le regole precedenti restano nel repository (tag della versione) e si ripubblicano con lo stesso comando se la build nuova va ritirata; le regole nuove accettano anche le scritture di oggi, quindi il ritorno indietro dell'app non richiede altro |
| NFR2.5 (NFR2) | Nessun dato personale nuovo: stile, provenienza e date riguardano il vino; nessun evento o log nuovo contiene nomi di vini | test del logger |
| NFR2.6 (NFR1) | Nessuna rete né servizio a pagamento per stimare o classificare | test con rete finta spenta |
