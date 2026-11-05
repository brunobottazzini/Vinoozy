# Story Map — Vinoozy

Fonti: `stories.md`, `unit-of-work.md`, `requirements.md`, `components.md`.

| Story | Unit ID | Directory |
|-------|---------|-----------|
| US1.1 | U1 | u1-skeleton |
| US1.2 | U8 | u8-account |
| US1.3 | U8 | u8-account |
| US2.1 | U1; U4 | u1-skeleton; u4-cellar |
| US2.2 | U6 | u6-label-recognition |
| US2.3 | U4 | u4-cellar |
| US3.1 | U4 | u4-cellar |
| US3.2 | U4 | u4-cellar |
| US3.3 | U4 | u4-cellar |
| US3.4 | U4 | u4-cellar |
| US4.1 | U2; U3; U4 | u2-estimation; u3-wine-catalog; u4-cellar |
| US4.2 | U2; U4 | u2-estimation; u4-cellar |
| US5.1 | U5 | u5-dashboard |
| US5.2 | U5 | u5-dashboard |
| US6.1 | U4 | u4-cellar |
| US6.2 | U4 | u4-cellar |
| US7.1 | U2; U3; U4 | u2-estimation; u3-wine-catalog; u4-cellar |
| US8.1 | U7 | u7-sharing |
| US8.2 | U7 | u7-sharing |
| US8.3 | U7 | u7-sharing |
| US8.4 | U7 | u7-sharing |
| US9.1 | U1 | u1-skeleton |
| US9.2 | U1; U4 | u1-skeleton; u4-cellar |
| US10.1 | U1 | u1-skeleton |

## Storie su più unità

- **US2.1**: U1 consegna l'aggiunta scritta di base (nome, annata, quantità, validazioni); U4 aggiunge i suggerimenti e la misura dei 30 secondi.
- **US4.1, US7.1**: U2 calcola stima e abbinamenti di riserva, U3 fornisce i dati esterni, U4 li mostra nel dettaglio.
- **US4.2**: U2 calcola lo stato, U4 lo mostra nella Cantina.
- **US9.2**: U1 fornisce la sincronizzazione, U4 le quantità come variazioni.

## Ordine di implementazione dentro ogni unità

Per ogni unità, secondo la pratica del team (test-after per strato): dominio → dati e sincronizzazione → interfaccia, con i test di ciascuno strato prima di passare al successivo.

## Verifica di copertura

- Tutte le 24 storie hanno almeno un'unità.
- Ogni unità ha almeno una storia: U1 (US1.1, US2.1, US9.1, US9.2, US10.1), U2 (US4.1, US4.2, US7.1), U3 (US4.1, US7.1), U4 (12 storie), U5 (US5.1, US5.2), U6 (US2.2), U7 (US8.1–US8.4), U8 (US1.2, US1.3).
