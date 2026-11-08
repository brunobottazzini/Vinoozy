# Requisiti di scalabilità

## Fonti

- `construction/functional-design/`: D2, BR3.6, BR3.7, BR3.9.
- `inception/requirements-analysis/requirements.md`: FR3.1, FR6.

| ID | Requisito | Verifica |
|---|---|---|
| NFR4.5 | Lo strumento `build_appellations` accetta registri fino a 10.000 righe senza cambiare formato. La tabella generata resta ordinata e stabile: a parità di input, il file è identico, quindi le differenze in git sono leggibili. | test dello strumento: doppia esecuzione con file uguali |
| NFR4.6 | Aggiungere una denominazione dedicata o un modello è una modifica di codice con il suo test. Ogni modello è usato da almeno una riga. | test di struttura |
| NFR4.7 (derivato da NFR4) | Il ricalcolo dopo l'aggiornamento (BR3.9) funziona fino a 1000 vini per cantina, con la scrittura un vino alla volta di oggi (NFR4.8a) e non con batch. Il calcolo di 1000 vini sta sotto 1 s; le scritture vanno in coda senza bloccare l'interfaccia. | test con 1000 vini finti |
