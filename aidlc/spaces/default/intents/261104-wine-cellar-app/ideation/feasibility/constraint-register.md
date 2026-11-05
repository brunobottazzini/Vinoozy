# Constraint Register — Vinoozy

Input: `intent-statement.md` e `feasibility-questions.md`.

## Vincoli tecnici

| ID | Vincolo | Origine |
|----|---------|---------|
| C1 | Un solo codice per Android e iPhone; prima distribuzione solo su Android | intent-statement, Q10 |
| C2 | Database cloud su Firebase | Q2 |
| C3 | L'app funziona offline e sincronizza al ritorno della rete | Q8 |
| C4 | Il momento ideale lo stima l'app: prima da base dati esterna, poi da regole interne, sempre con indice di fiducia | intent-statement, Q6 |
| C5 | Il codice è scritto sempre in inglese | intent-statement |

## Vincoli organizzativi ed economici

| ID | Vincolo | Origine |
|----|---------|---------|
| C6 | Budget cloud 0 €/mese; piano a consumo Firebase con avviso di spesa a 1 € | Q3, Q11 |
| C7 | Nessun account Apple Developer per ora | Q4, Q10 |
| C8 | Nessuna scadenza; progetto personale | Q5, intent-statement |
| C9 | Pubblicazione su Google Play tramite l'account già esistente | Q9 |

## Vincoli normativi

| ID | Vincolo | Origine |
|----|---------|---------|
| C10 | Nessun vincolo sulla residenza dei dati; restano dati personali (email, foto) da proteggere con accesso riservato al proprietario e a chi ha i permessi | Q7, intent-statement |

## Assumptions & Open Questions

None.
