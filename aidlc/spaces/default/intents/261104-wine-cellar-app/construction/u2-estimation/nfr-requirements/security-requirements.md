# Security Requirements — u2-estimation

Fonti: `requirements.md` (NFR4, NFR7, NFR8), `contract-summary.md` (C2), `functional-spec.md` e `rules.md` di u2 (BR4.4, BR4.5, BR1.6).

U2 è una libreria pura: non accede al cloud, alla rete, al disco né a Firebase, e non tratta dati personali (`WineFacts` contiene solo dati del vino). Gran parte della sicurezza del progetto non la riguarda.

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR4.1 | Il pacchetto non dipende da Flutter, Firebase, `dart:io` né da librerie di rete. Usa solo `dart:core`, `dart:collection` e `dart:math`, quest'ultima solo per gli arrotondamenti. | Script `tool/check_estimation_purity.sh` in CI: controlla le dipendenze di produzione di `packages/estimation/pubspec.yaml`, che devono essere vuote, e gli import ammessi. |
| NFR4.2 | Ogni ingresso è validato ai confini (BR4.5). `estimateWindow` e `pairingsFor` danno un errore di argomento chiaro con nome vuoto, anni fuori da 1900–2200, oppure annata e anno di riferimento entrambi mancanti. `statusOf` dà un errore di argomento se la finestra non rispetta inizio ≤ picco ≤ fine. Un profilo esterno incoerente viene ignorato (BR1.6). Nessun ingresso fa fallire la libreria con un'eccezione diversa da un errore di argomento. | Test con ingressi non validi. Test casuali su nomi e anni con un **seme fisso** (`Random(42)`), 1000 casi per funzione, ripetibili. |
| NFR4.3 | I testi della fonte esterna (abbinamenti in `items`) passano così come sono, al massimo 5. U2 non li interpreta e non li esegue. | Test sugli abbinamenti della fonte. |
| NFR4.4 | **Purezza e determinismo (BR4.4).** Nel codice di `lib/` del pacchetto non compaiono `DateTime.now`, `Random`, `Stopwatch`, `Platform` né variabili globali modificabili: sono ammessi solo `const` e `final` di primo livello. Con gli stessi ingressi, compreso `today`, ogni funzione dà sempre lo stesso risultato. | Lo stesso script di NFR4.1 cerca queste parole vietate in `lib/`. Un test chiama ogni funzione due volte con gli stessi ingressi e confronta i risultati. |
| NFR8.1 | Nessun dato personale entra o esce dalla libreria: niente email, uid o posizione. | Revisione dei tipi di C2 e test sui campi di `WineFacts`. |

Non applicabili a U2, perché a carico di U1, U4 e U8:
- **NFR4, accesso e regole del cloud:** U2 non accede al cloud.
- **NFR5, costo:** U2 non usa servizi a pagamento.
- **NFR6, durabilità:** U2 non salva dati.
- **NFR8, cancellazione dei dati:** U2 non conserva nulla.
