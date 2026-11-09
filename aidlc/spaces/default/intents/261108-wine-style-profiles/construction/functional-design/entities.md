# Entità — profili di stile e classificazione automatica

**Collaborator:** aidlc-architect-agent

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR4, NFR1–NFR6).
- `inception/refined-mockups/interaction-spec.md`.
- `codekb/Vinoozy/api-documentation.md` e `architecture.md`, sezioni dell'intent: forma attuale di `WineFacts`, `DrinkingWindow`, documento del vino (C3), `WineDbRecord`, regole Firestore.
- Codice: `packages/estimation/lib/src/models.dart`, `tables.dart`, `wine_level.dart`; `lib/cellar/domain/window_adjuster.dart`, `window_override.dart`; `firestore.rules` (`wineFields`, `validWindow`).
- `rules.md` di questa fase.

Gli identificatori sono in inglese (team.md); i nomi dei campi Firestore sono quelli che il codec scriverà. Le entità esistenti cambiano solo per aggiunte facoltative, così i documenti già salvati restano validi (NFR2.1).

```yaml
entities:
  - id: ENT-101
    name: StyleProfile
    description: "Uno dei 24 profili dello studio (BR1.1). Costante del pacchetto estimation, mai salvato come oggetto."
    attributes:
      - { name: id, type: enum, required: true, unique: true, allowed: [R_FRESH, R_MEDIUM, R_AGE, R_LONG, W_FRESH, W_MEDIUM, W_AGE, ROSE_FRESH, SP_TANK, LAM_FRESH, SP_CLASSIC, SP_CLASSIC_AGE, SW_AROMATIC, SW_PASSITO, SW_BOTRYTIS, PORT_VINTAGE, PORT_LBV, PORT_OX, SH_FINO, SH_AMONT, SH_OLOROSO, SH_PX, FORT_UNKNOWN, UNKNOWN] }
      - { name: anchor, type: enum, required: false, allowed: [vintage, bottling, disgorgement], constraints: "null solo per FORT_UNKNOWN e UNKNOWN" }
      - { name: unit, type: enum, required: false, allowed: [years, months], constraints: "null con anchor null" }
      - { name: start, type: integer, required: false, min: 0 }
      - { name: peak, type: integer, required: false, min: 0, constraints: "null = non stimato (BR1.2)" }
      - { name: end, type: integer, required: false, min: 1, constraints: "null = nessuna fine stimata; start <= peak <= end sui valori presenti" }
      - { name: freshForLevel, type: boolean, required: true, default: false, constraints: "true per R_FRESH, W_FRESH, ROSE_FRESH, SW_AROMATIC, SP_TANK, LAM_FRESH: senza qualifica propone 'Quotidiano' (BR4.3); i numeri valgono sempre per 'Buono' (BR4.1)" }
      - { name: evidence, type: enum, required: true, allowed: [stima_editoriale, legacy_non_validato, solo_prontezza, limite_editoriale_da_fascia, dati_insufficienti] }
      - { name: sources, type: string, required: true, constraints: "riferimenti S1–S20, E1–E3, R0 (NFR6)" }
    relationships:
      - { to: WineStyle, cardinality: "1..N", direction: "WineStyle -> StyleProfile" }

  - id: ENT-102
    name: WineStyle
    description: "Chiave stabile dello Stile mostrato nei chip e salvata sul vino (BR1.4). Più chiavi possono puntare allo stesso profilo."
    attributes:
      - { name: key, type: enum, required: true, unique: true, allowed: [redFresh, redMedium, redAge, redLong, whiteFresh, whiteMedium, whiteAge, roseFresh, tankFresh, lambrusco, classicFresh, classicAge, sweetAromatic, sweetPassito, sweetBotrytis, portVintage, portLbv, portTawny, sherryFino, sherryAmontillado, sherryOloroso, sherryPx, madeira, fortifiedOther] }
      - { name: profile, type: reference, required: true, references: StyleProfile.id }
      - { name: wineTypes, type: "list<WineType>", required: true, constraints: "Tipologie che mostrano la chiave (BR5.2)" }
      - { name: agingStartLabel, type: enum, required: false, allowed: [disgorgement, bottling], constraints: "solo per i profili in mesi (BR8.1)" }

  - id: ENT-103
    name: WineType
    description: "Tipologia, invariata a 8 valori (FR3.1). Il catalogo non la riduce più a 5 famiglie (BR3.5)."
    attributes:
      - { name: value, type: enum, required: true, allowed: [redLight, redStructured, white, rose, sparklingClassic, sparklingTank, sweet, fortified] }

  - id: ENT-104
    name: Qualifier
    description: "Qualifica con scarti o profilo propri. Si aggiungono in coda tre valori, così gli indici delle maschere di oggi non cambiano."
    attributes:
      - { name: value, type: enum, required: true, allowed: [riserva, superiore, granSelezione, crianza, reserva, granReserva, premierCru, grandCru, kabinett, spatlese, auslese, vintage, lbv, colheita, beerenauslese, trockenbeerenauslese, eiswein] }
    constraints:
      - "Le frasi 'beerenauslese' e 'trockenbeerenauslese' non danno più auslese (BR2.6)."

  - id: ENT-105
    name: StyleResolution
    description: "Risultato di resolveStyle: profilo, passo e tipo usati per stimare un vino (BR2.1). Valore in memoria, non salvato; i suoi esiti principali finiscono nella finestra."
    attributes:
      - { name: profile, type: reference, required: true, references: StyleProfile.id }
      - { name: style, type: reference, required: false, references: WineStyle.key, constraints: "null quando la Tipologia è vuota" }
      - { name: wineType, type: reference, required: false, references: WineType.value, constraints: "tipo effettivo dopo le correzioni (BR2.12)" }
      - { name: step, type: integer, required: true, min: 1, max: 4 }
      - { name: windowSource, type: enum, required: true, allowed: [profile, legacy, indicativeRow, indicativeType, generic, none] }
      - { name: styleToConfirm, type: boolean, required: true, default: false }
      - { name: basis, type: enum, required: true, allowed: [denomination, grape, wineType, generic, catalog] }
      - { name: denominationKey, type: string, required: false }
      - { name: qualifier, type: reference, required: false, references: Qualifier.value }

  - id: ENT-106
    name: DrinkingWindow
    description: "Finestra stimata (C2). Estesa con unità, mesi, picco e fine facoltativi, profilo e decorrenza."
    attributes:
      - { name: startYear, type: integer, required: true, min: 1900, max: 2200 }
      - { name: peakYear, type: integer, required: false, min: 1900, max: 2200, constraints: "null = picco non stimato" }
      - { name: endYear, type: integer, required: false, min: 1900, max: 2200, constraints: "null = nessuna fine stimata" }
      - { name: unit, type: enum, required: false, allowed: [years, months], default: years, constraints: "assente nelle finestre salvate prima: years" }
      - { name: startMonth, type: integer, required: false, min: 1, max: 12, constraints: "solo con unit months" }
      - { name: peakMonth, type: integer, required: false, min: 1, max: 12, constraints: "solo con unit months e peakYear" }
      - { name: endMonth, type: integer, required: false, min: 1, max: 12, constraints: "solo con unit months e endYear" }
      - { name: profile, type: reference, required: false, references: StyleProfile.id, constraints: "assente nelle finestre di prima e in quelle del catalogo" }
      - { name: anchor, type: enum, required: false, allowed: [vintage, bottling, disgorgement] }
      - { name: anchorFallback, type: boolean, required: false, default: false, constraints: "true = annata o data assente, usata la data di inserimento (BR6.2, BR8.3)" }
      - { name: indicative, type: boolean, required: false, default: false, constraints: "true = stile non chiaro, stima indicativa (BR2.14)" }
      - { name: confidence, type: enum, required: true, allowed: [high, medium, low] }
      - { name: source, type: enum, required: true, allowed: [catalog, internalRules] }
      - { name: basis, type: enum, required: false, allowed: [catalog, denomination, grape, wineType, generic] }
      - { name: qualifier, type: reference, required: false, references: Qualifier.value }
      - { name: denominationKey, type: string, required: false, constraints: "1-60 caratteri" }
      - { name: tablesVersion, type: integer, required: false, min: 1, max: 1000, constraints: "3 dopo questo intent" }
    constraints:
      - "Ordine start <= peak <= end sugli indici di mese dei valori presenti (BR6.10)."
      - "Una finestra 'Da stimare' non esiste come oggetto: il vino ha window null."

  - id: ENT-107
    name: WineFacts
    description: "Input della stima (C2), esteso."
    attributes:
      - { name: name, type: string, required: true }
      - { name: producer, type: string, required: false }
      - { name: vintage, type: integer, required: false }
      - { name: wineType, type: reference, required: false, references: WineType.value }
      - { name: region, type: string, required: false }
      - { name: denomination, type: string, required: false }
      - { name: referenceYear, type: integer, required: false, constraints: "anno di inserimento; richiesto senza annata" }
      - { name: referenceMonth, type: integer, required: false, min: 1, max: 12, constraints: "mese di inserimento, ripiego dei profili in mesi (BR8.3)" }
      - { name: level, type: enum, required: false, allowed: [everyday, good, aging], constraints: "null = good, come oggi; moltiplicatore assoluto, senza doppio conteggio con gli scarti di una qualifica (BR4.1)" }
      - { name: style, type: reference, required: false, references: WineStyle.key }
      - { name: styleChosen, type: boolean, required: false, default: false, constraints: "true se styleSource = user (BR2.15)" }
      - { name: agingStartYear, type: integer, required: false }
      - { name: agingStartMonth, type: integer, required: false, min: 1, max: 12 }

  - id: ENT-108
    name: Wine
    description: "Documento cellars/{cellarId}/wines/{wineId} (C3). Campi nuovi tutti facoltativi."
    attributes:
      - { name: wineType, type: string, required: false, constraints: "invariato" }
      - { name: level, type: enum, required: false, allowed: [everyday, good, aging], constraints: "invariato" }
      - { name: style, type: reference, required: false, references: WineStyle.key }
      - { name: typeSource, type: enum, required: false, allowed: [user, auto] }
      - { name: levelSource, type: enum, required: false, allowed: [user, auto] }
      - { name: styleSource, type: enum, required: false, allowed: [user, auto] }
      - { name: agingStartMonth, type: map, required: false, constraints: "{year: 1900..2200, month: 1..12}; validazione del modulo BR8.2" }
      - { name: migrationVersion, type: integer, required: false, min: 1, max: 1000, constraints: "3 dopo la migrazione (BR7.6)" }
      - { name: baseWindow, type: reference, required: false, references: DrinkingWindow }
      - { name: window, type: reference, required: false, references: DrinkingWindow }
      - { name: windowOverride, type: map, required: false, constraints: "{endYear, endMonth?, setAt}; endMonth 1..12 (BR6.8)" }
      - { name: windowAdjustment, type: map, required: false, constraints: "{kind, year, month?, recordId}; month 1..12 (BR6.9)" }
    constraints:
      - "Una provenienza esiste solo con il suo campo valorizzato."
      - "Un vino senza i campi nuovi è valido e si legge con: unit years, nessuno stile, provenienze assenti (NFR2.1)."
    relationships:
      - { to: WineStyle, cardinality: "N..0-1", direction: "Wine -> WineStyle" }
      - { to: DrinkingWindow, cardinality: "1..0-2", direction: "Wine -> DrinkingWindow (baseWindow, window)" }

  - id: ENT-109
    name: WineDbRecord
    description: "Riga della base offline (assets/wine_db/wines.jsonl.gz), formatVersion 2: con la classificazione preselezionata (BR9.2)."
    attributes:
      - { name: b, type: string, required: true, constraints: "codice a barre" }
      - { name: n, type: string, required: true }
      - { name: p, type: string, required: false }
      - { name: t, type: reference, required: false, references: WineType.value, constraints: "Tipologia preselezionata da classifyWine, non più il solo tipo dei tag" }
      - { name: l, type: enum, required: false, allowed: [everyday, good, aging], constraints: "Livello preselezionato" }
      - { name: s, type: reference, required: false, references: WineStyle.key, constraints: "solo con t" }
      - { name: d, type: string, required: false, constraints: "nome della riga della tabella riconosciuta" }
      - { name: c, type: string, required: false }
      - { name: v, type: integer, required: false }
    constraints:
      - "Il caricatore legge anche formatVersion 1 (senza l e s): allora l'app classifica al momento della proposta con classifyWine."

  - id: ENT-110
    name: WineDbManifest
    description: "manifest.json della base."
    attributes:
      - { name: formatVersion, type: integer, required: true, allowed: [1, 2] }
      - { name: exportDate, type: date, required: true }
      - { name: wineCount, type: integer, required: true }
      - { name: classifiedTypeShare, type: decimal, required: false, min: 0, max: 1, constraints: "quota con Tipologia (BR9.5)" }
      - { name: source, type: string, required: true }
      - { name: license, type: string, required: false }

  - id: ENT-111
    name: Preselection
    description: "Esito di classifyWine per un vino (BR3, BR4, BR5): valori proposti, in memoria."
    attributes:
      - { name: wineType, type: reference, required: false, references: WineType.value }
      - { name: level, type: enum, required: true, allowed: [everyday, good, aging], default: good }
      - { name: style, type: reference, required: false, references: WineStyle.key }
      - { name: styleToConfirm, type: boolean, required: true }
      - { name: reasons, type: "list<enum>", required: true, allowed: [qualifier, categoryWord, denomination, nameWord, grape, dbType, chateau, genericTable, none] }

  - id: ENT-112
    name: MigrationState
    description: "Stato della migrazione una tantum: per vino nel documento (migrationVersion) e per dispositivo nelle preferenze (tentativi, come oggi)."
    attributes:
      - { name: migrationVersion, type: integer, required: false, constraints: "campo del vino; < 3 o assente = da migrare" }
      - { name: attempts, type: integer, required: true, min: 0, max: 3, constraints: "preferenza estimates.migration.v3, avvii con rifiuto delle regole" }
      - { name: seenUpdatedAt, type: timestamp, required: true, constraints: "in memoria: updatedAt letto quando il vino entra nel giro; la transazione salta il vino se è cambiato (BR7.4)" }
    constraints:
      - "Un vino migrato non si rifà (FR4.2)."
      - "Un vino cambiato da un'altra persona durante il giro resta da migrare e si riprende all'avvio successivo."
```

## Sintesi

- **StyleProfile** (ENT-101) e **WineStyle** (ENT-102) sono costanti: il primo porta i numeri dello studio, il secondo è la chiave che l'utente vede e che si salva.
- **StyleResolution** (ENT-105) e **Preselection** (ENT-111) sono risultati di calcolo, non salvati; uno decide la finestra, l'altro propone Tipologia, Livello e Stile.
- **DrinkingWindow** (ENT-106) resta la forma C2 con aggiunte facoltative: `unit`, mesi, `profile`, `anchor`, `anchorFallback`, `indicative`, e picco e fine facoltativi.
- **Wine** (ENT-108) aggiunge `style`, le tre provenienze, `agingStartMonth`, `migrationVersion`; `windowOverride` e `windowAdjustment` ricevono un mese facoltativo.
- **WineDbRecord** (ENT-109) passa a formatVersion 2 con `l` e `s`, e `t` diventa la Tipologia preselezionata.

## Nomi dei campi Firestore e compatibilità

| Campo | Dove | Forma | Vino di oggi senza il campo | App di oggi che modifica un vino nuovo |
|---|---|---|---|---|
| `style` | vino | stringa, chiave di WineStyle | nessuno stile; si preseleziona alla migrazione | il campo resta (update) |
| `typeSource`, `levelSource`, `styleSource` | vino | `user` / `auto` | dedotti dalla migrazione (BR7.4) | restano; un cambio di tipo o livello non aggiorna la provenienza (rischio D7) |
| `agingStartMonth` | vino | `{year, month}` | si usa il mese di inserimento | resta |
| `migrationVersion` | vino | intero | vino da migrare | resta |
| `unit`, `startMonth`, `peakMonth`, `endMonth`, `profile`, `anchor`, `anchorFallback`, `indicative` | `window`, `baseWindow` | come ENT-106 | unit years | l'app di oggi riscrive la finestra nel formato vecchio; `tablesVersion` 2 fa ripartire la stima |
| `peakYear`, `endYear` | `window`, `baseWindow` | facoltativi | sempre presenti | un documento senza di essi l'app di oggi lo legge come "Da stimare" (`windowFrom` → null), senza perdere dati |
| `endMonth` | `windowOverride` | 1..12 | dicembre dell'anno (BR7.5) | resta se la correzione non cambia |
| `month` | `windowAdjustment` | 1..12 | dicembre dell'anno | riscritto senza mese da una bevuta nuova |
| `qualifier` (+3 valori) | finestre | `beerenauslese`, `trockenbeerenauslese`, `eiswein` | — | l'app di oggi li legge come qualifica sconosciuta |

Le modifiche alle regole sono in `rules.md` BR10.1–BR10.3 e in `functional-spec.md` D6.
