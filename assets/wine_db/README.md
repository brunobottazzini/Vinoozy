# Offline wine database

The wines Vinoozy recognises without a network when it reads a label
(label-recognition FR2). Derived from Open Food Facts, under the ODbL
(see `LICENSE`).

## Files

- `wines.jsonl.gz`: one wine per line (JSON with short keys: `b` barcode,
  `n` name, `p` producer, `t` type, `d` denomination, `c` country ISO code,
  `v` vintage), gzip-compressed. Only public product data, no personal data.
  Format 2 (wine-style-profiles BR9.2): `t` is the Type preselected by
  `classifyWine` of the estimation package, `l` the Level and `s` the Style
  it preselects; products that are not wine are left out.
- `manifest.json`: format version, export date, number of wines, source,
  licence and `classifiedTypeShare`, the share of wines with a Type.
- `LICENSE`: ODbL 1.0 for the database, DbCL 1.0 for its contents.

## Source

- Open Food Facts, https://world.openfoodfacts.org, the full CSV export
  published for bulk downloads (never the search API page by page).
- Export date: see `exportDate` in `manifest.json`.
- Current content: **the real export** of 2026-11-07
  (`en.openfoodfacts.org.products.csv.gz`, 4,899,177 products), built again
  on 2026-11-09 in format 2: 15,490 wines (176 more products left out as
  not wine), 84.22% with a Type, `wines.jsonl.gz` of 385,466 bytes
  (1,789,829 bytes uncompressed). Its manifest says `"source": "Open Food Facts"` with
  the ODbL licence, and `tool/check_wine_db_release.sh` passes on it.
- A database built from the hand-written sample
  (`tool/fixtures/off_wines_sample.csv`) says `"source": "sample"` and has
  no licence: the app does not show the Open Food Facts attribution for its
  results, the About screen says it is a sample, and
  `tool/check_wine_db_release.sh` (run by `promote.yml`) refuses to promote
  a build that carries it.

## How to rebuild it

1. Download the Open Food Facts CSV export by hand (about 1 GB compressed,
   over 9 GB uncompressed). It is never downloaded by CI.
2. From the project root:

   ```bash
   dart run tool/build_wine_db.dart --input <export.csv.gz> --output assets/wine_db/ --export-date <YYYY-MM-DD>
   ```

3. The tool keeps only wines, checks that there are at least 5000 of them,
   no duplicated barcode and an export of at most 180 days, and refuses a
   file over 3 MB compressed or 30 MB uncompressed. When a check fails it
   exits with an error and leaves the previous files untouched.
4. Check `manifest.json` (date and number of wines) and commit the two files.

The sample database is rebuilt with:

```bash
dart run tool/build_wine_db.dart --input tool/fixtures/off_wines_sample.csv --output assets/wine_db/ --export-date 2026-11-07 --skip-freshness-check --allow-small-sample
```
