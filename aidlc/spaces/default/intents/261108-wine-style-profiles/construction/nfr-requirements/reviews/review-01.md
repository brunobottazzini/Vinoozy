## Review

**Verdict:** NOT-READY
**Reviewer:** aidlc-architecture-reviewer-agent
**Date:** non indicata nel brief di dispatch
**Iteration:** 1
**Verdict Dictated:** no

### Findings

| ID | Severity | Location | Finding | Required action | Status |
|---|---|---|---|---|---|
| R-01 | Major | aidlc/spaces/default/intents/261108-wine-style-profiles/construction/nfr-requirements/performance-requirements.md > NFR3.1 | (1) La soglia in CI "≤ 50 ms per 100 vini" è incoerente con la soglia del telefono "≤ 50 ms per vino" e con NFR3 ("≤ 50 ms per vino"). La regola "in CI il doppio" darebbe 100 ms per vino, mentre il benchmark da 100 vini a 50 ms vale 0,5 ms per vino. Le due soglie non misurano la stessa cosa. | Definire un'unica unità (per vino), con soglia in CI = 2 × telefono (100 ms per vino) oppure spiegare perché il benchmark in blocco è più stretto, e dichiarare come si misura sul telefono. | New |
| R-02 | Major | aidlc/spaces/default/intents/261108-wine-style-profiles/construction/nfr-requirements/security-requirements.md > NFR5.1 (in tech-stack-decisions.md) | (2) L'accessibilità ha un solo requisito, senza criteri di passaggio. La matrice (3 lingue × testo 1,0/2,0 × chiaro/scuro) non dice cosa significa "passa". Il design pone aree toccabili ≥ 48 dp, contrasto AA e semantica (frontend-components.md), ma gli NFR non li riprendono come soglie verificabili. | Aggiungere NFR misurabili: area toccabile ≥ 48 dp, contrasto AA in chiaro e scuro, nessun overflow a testo 2,0, etichette semantiche presenti (`suggestedSemantics`, `styleGroupSemantics`). Indicare chi li verifica (widget test o controllo manuale sul telefono). | New |
| R-03 | Major | aidlc/spaces/default/intents/261108-wine-style-profiles/construction/nfr-requirements/reliability-requirements.md > NFR4.4 e NFR4.6 | (3) NFR4.4 prevede di verificare la migrazione "offline", ma BR7.4 la fa con una transazione Firestore, che offline non si completa. Il comportamento atteso offline (salta, ritenta, resta in coda, non blocca la Cantina) non è scritto. Mancano anche: idempotenza dichiarata, tempo massimo per riprendere, nessuna perdita di dati misurabile (conteggio dei vini prima e dopo). | Scrivere il risultato atteso offline e con rete instabile (vino saltato con `migrationVersion` invariato, ripresa all'avvio dopo). Aggiungere un criterio di integrità: numero di vini invariato e campi `user` identici prima e dopo. | New |
| R-04 | Minor | aidlc/spaces/default/intents/261108-wine-style-profiles/construction/nfr-requirements/tech-stack-decisions.md > NFR4.3 | La soglia accettata dal proprietario (84–86%, FR2.1) è scritta come "obiettivo 90%, accettato 84–86%". Non dice quando il controllo fallisce: sotto 84%? solo se diverge dal manifest? Il floor non è una condizione di pass/fail verificabile (BR9.5 dice "quota = manifest"). | Fissare la regola: il tool/CI fallisce sotto 84% di `classifiedTypeShare`; fra 84 e 90 registra l'avviso. Indicare che 84–86% è l'accettazione del proprietario con riferimento alla sua decisione. | New |
| R-05 | Minor | aidlc/spaces/default/intents/261108-wine-style-profiles/construction/nfr-requirements/traceability.json | `upstream_ids` non include FR2.1, FR4, né NFR4.6–NFR4.8, NFR2.4–NFR2.6, NFR3.x, NFR6.x, che compaiono come target e nelle colonne "(FR…)". Nessun legame con BR7, BR9, BR10, BR11 e D1–D9, che pure sono citati nei file. NFR6.1 e NFR6.2 (manifest, eventi) non derivano da NFR6 dei requisiti, che riguarda la tracciabilità dello studio: sono aggiunte non marcate come tali. | Completare `upstream_ids` e le righe `coverage` con FR2.1, FR4, BR7, BR9, BR10, BR11. Marcare NFR6.1 e NFR6.2 come requisiti nuovi o ricondurli a un requisito. | New |
| R-06 | Minor | aidlc/spaces/default/intents/261108-wine-style-profiles/construction/nfr-requirements/scalability-requirements.md > NFR3.7; security-requirements.md > NFR2.4 | NFR3.7 dice "in proporzione" senza numeri (500 vini ≤ 2,5 s?). NFR2.4 non prevede cosa fare se le regole nuove vanno annullate (rollback delle regole). | Scrivere la soglia numerica per 500 vini. Aggiungere nota di ripristino delle regole precedenti (file versionato nel repository). | New |

### Validation Tool Results

| Tool | Result | Interpretation |
|---|---|---|
| Nessuno eseguito | n/a | Lo stage non indica strumenti di validazione; confronto fatto a mano su requirements.md (NFR1–NFR6, FR2.1, FR4) e rules.md (BR7, BR9–BR11). |

### Summary

Gli NFR coprono bene regole Firestore, compatibilità, copertura (80%/90%) e costi, e restano coerenti con BR7, BR9, BR10 e BR11. Tre lacune Major bloccano il giudizio: la soglia di NFR3.1 è incoerente, l'accessibilità non ha criteri misurabili e la sicurezza della migrazione offline non ha il comportamento atteso.
