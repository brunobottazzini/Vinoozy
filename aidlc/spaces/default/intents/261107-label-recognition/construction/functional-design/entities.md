# Entità — riconoscimento delle etichette

## Fonti

- `inception/requirements-analysis/requirements.md` (FR1–FR5, NFR1–NFR6).
- `inception/refined-mockups/interaction-spec.md`, con l'assegnazione dei punti aperti.
- `codekb/Vinoozy/`: `LabelInput`, `LabelReading`, `WineCandidate` e `AddWineInitialValues` esistenti.

```yaml
entities:
  - name: LabelCapture
    description: Le foto di una lettura (fronte obbligatorio, retro facoltativo), finché l'esito è aperto.
    attributes:
      - { name: frontPath, type: file path, required: true, constraints: "dentro cache/label/" }
      - { name: backPath, type: file path, required: false, constraints: "dentro cache/label/" }
      - { name: backStatus, type: enum, required: true, allowed: [taken, skipped, unreadable], default: skipped }
      - { name: openedAt, type: timestamp, required: true }
    constraints:
      - "I file esistono solo finché l'esito è aperto (BR1.4)"
  - name: MergedReading
    description: Il risultato della lettura di fronte e retro.
    attributes:
      - { name: text, type: string, required: true, max: 4000, constraints: "righe del fronte, poi righe nuove del retro" }
      - { name: barcode, type: string, required: false, constraints: "EAN-13, EAN-8 o UPC-A valido" }
      - { name: barcodeSide, type: enum, required: false, allowed: [front, back] }
  - name: OfflineWine
    description: Un vino della base offline ricavata da Open Food Facts.
    attributes:
      - { name: code, type: string, required: true, unique: true, constraints: "codice a barre normalizzato" }
      - { name: name, type: string, required: true, min: 2, max: 120 }
      - { name: producer, type: string, required: false, max: 120 }
      - { name: wineType, type: enum, required: false, allowed: [redLight, redStructured, white, rose, sparklingClassic, sparklingTank, sweet, fortified] }
      - { name: denomination, type: string, required: false, max: 120 }
      - { name: country, type: string, required: false, constraints: "ISO 3166-1 alpha-2" }
      - { name: vintage, type: integer, required: false, min: 1900, max: 2100 }
  - name: OfflineWineDb
    description: La base offline inclusa nell'app.
    attributes:
      - { name: exportDate, type: date, required: true }
      - { name: wineCount, type: integer, required: true, min: 1 }
      - { name: formatVersion, type: integer, required: true, default: 1 }
      - { name: wines, type: list of OfflineWine, required: true }
  - name: Candidate
    description: Un vino proposto all'utente, da una delle fonti.
    attributes:
      - { name: source, type: enum, required: true, allowed: [offline, catalog, online] }
      - { name: name, type: string, required: true }
      - { name: producer, type: string, required: false }
      - { name: vintage, type: integer, required: false }
      - { name: wineType, type: enum, required: false }
      - { name: denomination, type: string, required: false }
      - { name: country, type: string, required: false }
      - { name: code, type: string, required: false }
      - { name: score, type: number, required: true, min: 0, max: 1 }
  - name: RecognitionOutcome
    description: L'esito mostrato dopo la lettura.
    attributes:
      - { name: kind, type: enum, required: true, allowed: [sure, candidates, unreadable, barcodeNotFound, noMatch] }
      - { name: candidates, type: list of Candidate, required: false, max: 10 }
      - { name: reading, type: MergedReading, required: true }
```
