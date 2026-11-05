# Feasibility Assessment — Vinoozy (app gestione cantina)

Input: `intent-statement.md` (Intent Capture & Framing) e le risposte in `feasibility-questions.md`.

## Esito

**Fattibile**, con un rischio principale: trovare una fonte affidabile e gratuita per stimare il momento ideale di ogni vino (vedi R1 in `raid-log.md`).

| Area | Valutazione | Motivo |
|------|-------------|--------|
| App multipiattaforma | Fattibile | Un solo codice per Android e iPhone è pratica comune; la prima versione esce solo su Android (Q10), dove hai già un account Google Play (Q9). |
| Database cloud + sincronizzazione | Fattibile | Firebase (Q2) offre database con funzionamento offline e sincronizzazione automatica (Q8). |
| Login e cantina condivisa | Fattibile, con un vincolo | Il login Google è gratuito. Il login Apple richiede l'account Apple Developer, rimandato (Q4): vedi I1. |
| Inserimento da testo e da foto | Fattibile | Lettura del testo dell'etichetta direttamente sul telefono, senza costi. Riconoscere il vino dal testo letto resta impreciso: serve sempre una conferma dell'utente (ipotesi). |
| Momento ideale e abbinamenti | Fattibile con rischio | Prima una base dati esterna, poi regole interne con indice di fiducia (Q6). La disponibilità di una base dati esterna gratuita è da verificare (R1). |
| Budget 0 €/mese | Fattibile | Con meno di 100 bottiglie (intent-statement) i volumi restano dentro le quote gratuite (stima sotto). |
| Tempi | Nessun vincolo | Nessuna scadenza (Q5). |

## Stima dei costi (indicativa, da verificare sul listino al momento dell'attivazione)

Volumi stimati: circa 100 schede vino (meno di 1 MB), circa 100 foto compresse (circa 30 MB), 2 utenti, poche centinaia di letture e scritture al giorno.

| Voce | Quota gratuita indicativa | Uso previsto | Costo stimato |
|------|---------------------------|--------------|---------------|
| Firebase database (Firestore) | 1 GB di dati, 50.000 letture e 20.000 scritture al giorno | meno di 1 MB, centinaia di operazioni al giorno | 0 €/mese |
| Firebase archivio foto (Storage) | alcuni GB gratuiti sul piano a consumo | circa 30 MB | 0 €/mese |
| Firebase login (Google) | gratuito per volumi personali | 2 utenti | 0 €/mese |
| Lettura etichetta sul telefono | gratuita | — | 0 € |
| Base dati vini esterna | da verificare (R1) | poche richieste al mese | 0 € se si trova una fonte gratuita, altrimenti regole interne a 0 € |
| Account Google Play | già posseduto (Q9) | — | 0 € aggiuntivi |
| Account Apple Developer | rimandato (Q10) | — | 0 € ora; circa 99 $/anno quando si aggiunge iPhone |

**Totale prima versione: 0 €/mese**, con avviso di spesa Firebase a 1 € (Q11) come protezione.

## Approcci considerati per la stima del momento ideale

| Approccio | Pro | Contro | Scelta |
|-----------|-----|--------|--------|
| Base dati vini esterna | Stime più precise per etichetta e annata | Disponibilità e costi da verificare; dipendenza da terzi | Prima scelta (Q6) |
| Regole interne per tipologia, denominazione e annata | Gratis, sempre disponibili, funzionano offline | Meno precise | Ripiego, con indice di fiducia (Q6) |
| Servizio di intelligenza artificiale | Risposte ricche | Costo per richiesta, in contrasto con il budget 0 € (Q3) | Scartato per la prima versione |

## Assumptions & Open Questions

- [assumption] Le quote gratuite indicate per Firebase sono quelle note al momento della stima e vanno verificate sul listino quando si attiva il progetto.
- [assumption] Il riconoscimento da foto legge il testo dell'etichetta e propone il vino; l'utente conferma sempre prima di salvare.
