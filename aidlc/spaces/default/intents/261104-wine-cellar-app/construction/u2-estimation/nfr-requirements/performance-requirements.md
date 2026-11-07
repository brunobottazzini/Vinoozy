# Performance Requirements — u2-estimation

Fonti: `requirements.md` (NFR2), `functional-spec.md` e `rules.md` di u2, risposte in `nfr-requirements-questions.md`.

**Telefono di riferimento:** lo stesso usato per NFR2 nelle altre unità, cioè un Android di fascia media con 4 GB di RAM e Android 10 o superiore. Per le prove si usa il telefono del proprietario (OnePlus CPH2581, OnePlus 12), che è di fascia alta e quindi più veloce del telefono di riferimento: su questo telefono la soglia diventa la metà, cioè 25 ms, per tenere conto della differenza.

| ID | Requisito | Verifica |
|----|-----------|----------|
| NFR2.1 | `estimateWindow`, `statusOf` e `pairingsFor` per 500 vini insieme finiscono in meno di 50 ms sul telefono di riferimento. Il cruscotto (NFR2, 2 s con 500 bottiglie) ha così più di un secondo e mezzo per tutto il resto. | (a) **In CI, come guardia contro i peggioramenti:** benchmark del pacchetto su 500 vini sintetici, mediana di 10 giri dopo 3 giri di riscaldamento, soglia fissa di **10 ms** sul runner `ubuntu-latest`. Un runner è molto più veloce del telefono, quindi 10 ms lasciano un margine di 5 volte. Se la soglia viene superata, il job fallisce. (b) **Sul telefono:** misura del valore reale una volta per versione con la build release, prevista nella checklist dello smoke test; deve restare sotto 25 ms sul telefono del proprietario, equivalenti ai 50 ms del telefono di riferimento. |
| NFR2.2 | Le tabelle sono costanti create una sola volta, alla prima chiamata, e poi riusate. Le chiamate successive non ricostruiscono strutture. | Benchmark: la mediana di un secondo blocco di 500 stime non supera di più del 10% quella del primo blocco. |
| NFR2.3 | Il riconoscimento dal nome (BR1.1) per un nome di 60 caratteri richiede meno di 20 µs sul runner di CI. Gli alias sono preparati una sola volta, insieme alle tabelle (NFR2.2). | Benchmark con 500 nomi di 60 caratteri, mediana sotto 10 ms in totale. |
