# Wine appellation table

The appellations Vinoozy uses to estimate when a wine is ready
(label-autofill-windows FR3, BR3.6, BR3.7, NFR5.6, NFR5.7). Only the names
of protected appellations are used: public geographical data, no personal
data.

## Two parts

- **Dedicated rows** (`packages/estimation/lib/src/tables.dart`,
  `italy_tables.dart`, `france_tables.dart`, `europe_tables.dart`,
  `new_world_tables.dart`): 724 appellations with their own drinking
  window, chosen at Code Generation with the reason written next to each
  family of rows (all 77 Italian DOCGs and the main DOCs, the French crus and
  communal AOCs, the qualified Spanish and Portuguese DOs, the main German
  and Austrian zones, the main New World zones).
- **Generated rows** (`packages/estimation/lib/src/generated/appellations.g.dart`
  and `appellations_manifest.json`): every other registered appellation,
  written by `tool/build_appellations.dart` with the window of the model of
  its country and type (`TemplateKeys` in `world_tables.dart`). A
  dedicated row always wins over a generated one with the same name.

## Sources and licences

| File | Source | Licence |
|---|---|---|
| eAmbrosia export (downloaded by hand into `.cache/eambrosia/`, never committed) | European Commission, eAmbrosia, the EU register of geographical indications, wines (PDO and PGI): https://ec.europa.eu/agriculture/eambrosia/ | Reuse of Commission documents and data (Commission Decision 2011/833/EU); public register |
| `us_ava.csv` | TTB, "Established American Viticultural Areas" (27 CFR part 9) | Public domain (17 U.S.C. 105) |
| `au_nz_gi.csv` | Wine Australia, Register of Protected GIs; IPONZ, Geographical Indications Register | Public registers of the two governments |
| `za_wo.csv` | Wine and Spirit Board, Wine of Origin Scheme (SAWIS, WOSA) | Public regulation of South Africa |
| `south_america.csv` | INV (Argentina), SAG (Chile), INPI (Brazil), INAVI (Uruguay) | Public registers of the four governments |
| `ch_aoc.csv` | Federal Office for Agriculture, Swiss AOC register, and cantonal AOC rules | Public data of the Confederation and the cantons |

Each CSV file names its source, its date and its licence in its header.
The files outside the EU were checked in Build and Test (2026-11-08)
against the official lists named in their headers: the TTB list of 278
AVAs, the Wine Australia and IPONZ registers, the INV list of Argentina,
Decreto 464 of Chile, the INPI lists of Brazil and the federal Swiss AOC
repertory. Two lists could not be checked one by one: the Wine of Origin
tables of South Africa (published only as maps) and the zones of Uruguay
(no current official list in a readable form); their headers say what was
checked. No licence of these registers was found that forbids reusing the
protected names, which are public geographical data: no file was excluded.

## Current content

**The real registers** (Build and Test, 2026-11-08): the eAmbrosia export
of 2026-11-08 (JSON of the public API, 4022 GIs, 1666 registered wines of
which 15 removed) with the CSV files of this folder: 2457 register rows, 724
dedicated and 1700 generated appellations, 2424 in all (756 rows left out
because a dedicated row, a grape or an earlier row already has the name, 1
dropped without a type of its model). The manifest says `"source":
"eAmbrosia and official national registers"` and
`tool/check_appellations_release.sh` passes.

A table built with `--allow-sample` from the hand-written sample
`tool/fixtures/eambrosia_sample.csv` says `"source": "sample"`: the About
screen says it is a sample, and `tool/check_appellations_release.sh` (run
by `promote.yml`) refuses to promote a build that carries it.

## How to rebuild it

From the root of the project, after downloading the eAmbrosia export (the
JSON of its public API; a CSV export is read too):

```bash
curl -o .cache/eambrosia/eambrosia-<YYYY-MM-DD>.json \
  https://webgate.ec.europa.eu/eambrosia-api/api/geographical-indications
dart run tool/build_appellations.dart \
  --eambrosia .cache/eambrosia/eambrosia-<YYYY-MM-DD>.json \
  --export-date <YYYY-MM-DD>
tool/check_appellations_release.sh
(cd packages/estimation && dart test)
```

The tool writes nothing and keeps the previous table when there are fewer
than 1500 appellations, a duplicate key, a model that does not exist or a
region that is not a region of the app. The same inputs always give the same
file, already in `dart format` layout. From the JSON export it reads only
the names, country, GI type, product type and status of each GI, never the
producer group fields.
