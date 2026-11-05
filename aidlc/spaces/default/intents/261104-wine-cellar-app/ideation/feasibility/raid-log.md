# RAID Log — Vinoozy

Input: `intent-statement.md` e `feasibility-questions.md`.

## Risks

| ID | Rischio | Probabilità | Impatto | Mitigazione |
|----|---------|-------------|---------|-------------|
| R1 | Non esiste una base dati vini esterna gratuita con finestre di consumo affidabili | Media | Alto (obiettivo principale: non perdere il vino) | Regole interne come ripiego, con indice di fiducia visibile (Q6) |
| R2 | Stime imprecise portano a bere troppo presto o troppo tardi | Media | Medio | Mostrare l'indice di fiducia e avvisare con anticipo quando la finestra si avvicina |
| R3 | I listini Firebase cambiano e si esce dalla quota gratuita | Bassa | Basso | Avviso di spesa a 1 € (Q11) |
| R4 | Conflitti di sincronizzazione quando due persone modificano la cantina offline | Bassa | Medio | Regole di unione dei conflitti da definire nella progettazione |

## Assumptions

| ID | Ipotesi |
|----|---------|
| A1 | Meno di 100 bottiglie e 2 utenti restano dentro le quote gratuite Firebase |
| A2 | La lettura del testo dell'etichetta sul telefono basta a proporre il vino; l'utente conferma sempre |

## Issues

| ID | Problema | Proposta |
|----|----------|----------|
| I1 | In Intent Capture il login è "Google o Apple", ma il login Apple richiede l'account Apple Developer, rimandato (Q4, Q10) | Prima versione su Android con solo login Google; login Apple insieme al supporto iPhone |

## Dependencies

| ID | Dipendenza |
|----|------------|
| D1 | Account Firebase con piano a consumo e avviso di spesa (Q11) |
| D2 | Account Google Play già esistente (Q9) |
| D3 | Eventuale base dati vini esterna (R1) |
| D4 | Account Apple Developer, solo quando si aggiunge iPhone |

## Assumptions & Open Questions

None.
