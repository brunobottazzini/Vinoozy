# Units Generation — Domande

Contesto: `components.md` (8 componenti), `decisions.md`, `requirements.md`, `stories.md`. Qui raggruppo i componenti in **unità di lavoro**: blocchi costruiti e verificati uno alla volta. Il primo è la fetta funzionante decisa nelle pratiche del team.

## Piano di decomposizione proposto

Distribuzione: **una sola app Android (Flutter)** più **una funzione nel cloud** (WineCatalog) e le regole di sicurezza Firebase. Unità tagliate per funzionalità visibili all'utente:

| Unità | Tipo | Contenuto | Dipende da |
|-------|------|-----------|------------|
| U1 u1-skeleton | ui | Fetta funzionante: app avviabile, login Google, aggiunta di un vino scritto, salvataggio offline, sincronizzazione Firebase, regole di sicurezza di base, lingue e tema | — |
| U2 u2-estimation | library | Stima con regole interne, stato, "da bere presto", fiducia, abbinamenti per tipologia (logica pura, testabile da sola) | — |
| U3 u3-wine-catalog | service | Funzione cloud intermediaria: suggerimenti, riconoscimento da testo, finestre e abbinamenti dalla base dati esterna | — |
| U4 u4-cellar | ui | Cantina completa: elenco, ricerca e filtri, modifica, eliminazione, + e -, doppioni, dettaglio con stima, bevuta, storico, annulla | U1, U2, U3 |
| U5 u5-dashboard | ui | Cruscotto: "da bere presto" e i tre grafici | U1, U2 |
| U6 u6-label-recognition | ui | Aggiunta da foto dell'etichetta | U1, U3 |
| U7 u7-sharing | ui | Inviti, permessi, revoca, cantina condivisa, regole cloud dei permessi | U1 |
| U8 u8-account | ui | Presentazione iniziale, uscita, cancellazione account | U1, U7 |

## Q1. [Sviluppo] Quanto grandi le unità

A. 8 unità come nel piano (consigliato: ognuna dimostrabile da sola)
B. Meno unità più grandi (circa 5, unendo Cruscotto con Cantina e Account con Condivisione)
C. Not yet defined
X. Other (please specify)

[Answer]: A

## Q2. [Sviluppo] Approvi il piano di decomposizione

A. Approve Plan
B. Revise Plan
X. Other (please specify)

[Answer]: A

## Consolidated Summary Confirmation

- Granularità (Q1): 8 unità come nel piano: U1 skeleton (fetta funzionante), U2 estimation, U3 wine-catalog, U4 cellar, U5 dashboard, U6 label-recognition, U7 sharing, U8 account.
- Piano (Q2): approvato; distribuzione come una sola app Android Flutter più una funzione cloud e le regole di sicurezza Firebase.

Does this all look correct before I generate the artifact?

- Looks correct
- Request changes

[Answer]: Looks correct
